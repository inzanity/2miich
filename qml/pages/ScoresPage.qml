/*
 * 2miich - Liiga scores app
 * Copyright (C) 2014 Santtu Lakkala <inz@inz.fi>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.toomiich.PersistentTimer 1.0
import '../models'
import '../effects'
import '../widgets'
import '../helpers'


Page {
    id: page
    property int detailsIndex: -1
    property alias date: games.date

    onStatusChanged: if (status === PageStatus.Active) { detailsIndex = -1; }

    onDetailsIndexChanged: {
        oledify.redraw(games.model);
        if (detailsIndex != -1) {
            if (status === PageStatus.Active) {
                pageStack.push(Qt.resolvedUrl("DetailsPage.qml"), { parent: page, details: games.model.get(detailsIndex) });
            } else {
                pageStack.replaceAbove(page, Qt.resolvedUrl("DetailsPage.qml"), { parent: page, details: games.model.get(detailsIndex) });
            }
        } else {
            pageStack.pop(page);
            pageStack.pushExtra(schedule, { parent: page, mainPage: page });
        }
    }
    Component {
        id: schedule
        SchedulePage {}
    }

    Component.onDestruction: {
        oledify.enable = false;
    }

    Toholed {
        id: oledify

        function redraw(model) {
            if (!oledify.enable)
                return;

            var teamImages = {
                'Blues': 'Blues',
                'HIFK': 'HIFK',
                'HPK': 'HPK',
                'Ilves': 'Ilves',
                'JYP': 'JYP',
                'KalPa': 'KalPa',
                'Kärpät': 'Karpat',
                'Lukko': 'Lukko',
                'Pelicans': 'Pelicans',
                'SaiPa': 'SaiPa',
                'Tappara': 'Tappara',
                'TPS': 'TPS',
                'Sport': 'Sport',
                'Ässät': 'Assat'
            };
            var r;
            oledify.clear();

            if (detailsIndex === -1 && model.count > 1) {
                for (var i = 0; i < model.count; i++) {
                    r = model.get(i);
                    oledify.drawPixmap((i & 1) * 66, (i >> 1) * 16, ':/images/' + teamImages[r.home] + '-1bit.png');
                    oledify.drawText((i & 1) * 66 + 17, (i >> 1) * 16, true, -1, 14, false, r.homescore);
                    oledify.drawText((i & 1) * 66 + 30, (i >> 1) * 16, true, 0, 14, false, '-');
                    oledify.drawText((i & 1) * 66 + 45, (i >> 1) * 16, true, 1, 14, false, r.awayscore);
                    oledify.drawPixmap((i & 1) * 66 + 46, (i >> 1) * 16, ':/images/' + teamImages[r.away] + '-1bit.png');
                }
            } else if (model.count) {
                r = model.get(Math.max(detailsIndex, 0));
                oledify.drawPixmap(0, 0, ':/images/' + teamImages[r.home] + '-1bit-40.png');
                oledify.drawText(42, 0, true, -1, 30, true, r.homescore);
                oledify.drawText(64, 0, true, 0, 30, true, '-');
                oledify.drawText(86, 0, true, 1, 30, true, r.awayscore);
                oledify.drawText(64, 32, true, 0, 14, false, r.played);
                oledify.drawPixmap(88, 0, ':/images/' + teamImages[r.away] + '-1bit-40.png');
            }

            if (model.count < 7 || detailsIndex !== -1) {
                oledify.clockW = 128;
                oledify.clockX = 0;
                oledify.clockEnabled = true;
            } else if (model.count < 8) {
                oledify.clockW = 64;
                oledify.clockX = 64;
                oledify.clockEnabled = true;
            } else {
                oledify.clockEnabled = false;
            }

            oledify.update();
        }
    }

    SilicaListView {
        id: games
        anchors.fill: parent
        model: LiigaModel {
            onStatusChanged: {
                games.isError = status === 4;
                if (status === 3) {
                    var pending = false;
                    var running = false;
                    var goals = false;
                    var firstGame = undefined;

                    if (date && date.toDateString() === new Date().toDateString() && count > 0) {
                        for (var i = 0; i < count; i++) {
                            var r = get(i);
                            if (games.cache[r.home] !== undefined && r.homescore > games.cache[r.home])
                                goals = true;
                            games.cache[r.home] = r.homescore;

                            if (games.cache[r.away] !== undefined && r.awayscore > games.cache[r.away])
                                goals = true;
                            games.cache[r.away] = r.awayscore;

                            if (!firstGame || r.startTime < firstGame)
                                firstGame = r.startTime;

                            if (!r.started)
                                pending = true;
                            else if (!r.finished)
                                running = true;

                            if (i === detailsIndex) {
                                pageStack.nextPage(page).details = r;
                                pageStack.nextPage(page).refresh();
                            }
                        }

                        oledify.enable = true;
                        oledify.redraw(this);

                        if (goals)
                            oledify.blink();
                    } else {
                        oledify.enable = false;
                    }

                    games.gamesPending = pending;
                    games.gamesRunning = running || (pending && firstGame - new Date() < 600000);

                } else if (status === 4) {
                    oledify.enable = false;
                }
            }
        }
        property variant date: new Date();
        property bool isError: false
        property var cache: ({})
        property bool gamesRunning: false
        property bool gamesPending: false

        PersistentTimer {
             interval: games.gamesRunning ? 30000 : 600000
             maxError: 10000
             running: games.gamesRunning || games.gamesPending
             repeat: true
             wakeUp: oledify.haveLock

             onTriggered: {
                 games.refresh();
             }
        }

        header: PageHeader {
            title: { var d = games.model.date || games.date; return Qt.formatDate(d, 'ddd, ') + Qt.formatDate(d) }
        }

        ViewPlaceholder {
            enabled: games.model.count === 0
            text: qsTr('No games for the day')
        }

        PullDownMenu {
            id: pullDown
            MenuItem {
                text: qsTr('Statistics')
                onClicked: pageStack.push('StatisticsPage.qml', { mainPage: page })
            }

            MenuItem {
                text: qsTr('Go to today')
                onClicked: { pullDown.close(true); games.date = new Date() }
            }
            MenuItem {
                text: { var d = games.model.prev || new Date(games.date.getFullYear(), games.date.getMonth(), games.date.getDate() - 1); return qsTr('Previous: ') + Qt.formatDate(d, 'ddd, ') + Qt.formatDate(d) }
                onClicked: { pullDown.close(true); games.date = (games.model.prev || new Date(games.date.getFullYear(), games.date.getMonth(), games.date.getDate() - 1)) }
            }
        }

        PushUpMenu {
            id: pushUp
            MenuItem {
                text: { var d = games.model.next || new Date(games.date.getFullYear(), games.date.getMonth(), games.date.getDate() + 1); return qsTr('Next: ') + Qt.formatDate(d, 'ddd, ') + Qt.formatDate(d) }
                onClicked: { pushUp.close(true); games.date = (games.model.next || new Date(games.date.getFullYear(), games.date.getMonth(), games.date.getDate() + 1)) }
            }
        }

        onDateChanged: {
            cache = {};
            games.model.clear();
            refresh();
        }

        function setCover(component) {
            if (component.status === Component.Error) {
                console.log('Failed: ' + component.errorString());
            } else {
                cover = component.createObject();
                cover.model = model;
                cover.detailsIndex = Qt.binding(function () { return detailsIndex; });
                cover.next.connect(function () { detailsIndex = (detailsIndex + 2) % (games.model.count + 1) - 1 });
                cover.prev.connect(function () { detailsIndex = (detailsIndex + games.model.count + 1) % (games.model.count + 1) - 1 });
            }
        }

        function updateCover() {
            var coverComp = Qt.createComponent('../cover/ScoresCover.qml');

            if (coverComp.status === Component.Ready)
                setCover(coverComp);
            else
                coverComp.statusChanged.connect(setCover.bind(this, coverComp));
        }

        function refresh() {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function (e) {
                if (xhr.readyState == 4) {
                    games.model.json = xhr.responseText;
                }
            }
            xhr.open('GET', 'http://liiga.fi/media/game-tracking/' + date.getFullYear().toString() + '-' + ('0' + (date.getMonth() + 1).toString()).substr(-2) + '-' +  ('0' + date.getDate().toString()).substr(-2) + '.json');
            xhr.send();
        }

        Component.onCompleted: {
            updateCover();
        }

        delegate: BackgroundItem {
            id: bgItem
            property variant txtColor: highlighted ? Theme.highlightColor : Theme.primaryColor

            Column {
                anchors.fill: parent
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                Rectangle {
                    radius: 5
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                    width: parent.width
                    height: Math.max(homeLogo.height, homeTeam.height, awayTeam.height, awayLogo.height)
                    Logo {
                        id: homeLogo
                        team: home
                        active: homescore > awayscore
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padding
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        id: homeTeam
                        anchors.left: homeLogo.right
                        anchors.leftMargin: Theme.paddingMedium
                        text: home
                        font.weight: homescore > awayscore ? Font.Bold : Font.Normal
                        color: bgItem.txtColor
                    }
                    GoalLabel {
                        id: homeScore
                        anchors.right: dash.left
                        text: homescore
                        font.weight: homescore > awayscore ? Font.Bold : Font.Normal
                        color: bgItem.txtColor
                    }

                    Label {
                        id: dash
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ' - '
                        color: bgItem.txtColor
                    }
                    GoalLabel {
                        id: awayScore
                        anchors.left: dash.right
                        text: awayscore + overtime
                        font.weight: awayscore > homescore ? Font.Bold : Font.Normal
                        color: bgItem.txtColor
                    }
                    Label {
                        anchors.left: awayScore.right
                        anchors.bottom: awayScore.bottom

                        text: started && !finished ? played : ''
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: bgItem.txtColor
                    }

                    Label {
                        id: awayTeam
                        anchors.right: awayLogo.left
                        anchors.rightMargin: Theme.paddingMedium
                        text: away
                        font.weight: awayscore > homescore ? Font.Bold : Font.Normal
                        color: bgItem.txtColor
                    }
                    Logo {
                        id: awayLogo
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.padding
                        anchors.verticalCenter: parent.verticalCenter
                        team: away
                        active: awayscore > homescore
                    }
                }

                Label {
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: (!started ? Qt.formatTime(startTime) : (!finished ? detail : ''))
                    linkColor: Theme.highlightColor
                    width: parent.width
                    horizontalAlignment: started && !finished ? Text.AlignLeft : Text.AlignHCenter
                    color: bgItem.txtColor
                }
            }
            onClicked: {
                detailsIndex = index
            }
        }
    }
}


