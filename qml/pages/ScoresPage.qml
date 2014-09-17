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
import '..'


Page {
    id: page
    property int detailsIndex: -1

    onStatusChanged: if (status === PageStatus.Active) detailsIndex = -1;

    SilicaListView {
        id: games
        anchors.fill: parent
        model: LiigaModel {
            onStatusChanged: {
                games.isError = status === 4
                if (status === 3) {
                    var pending = false;
                    var running = false;
                    var goals = false;
                    if (games.date.toDateString() === new Date().toDateString()) {
                        for (var i = 0; i < count; i++) {
                            var r = get(i);
                            if (games.cache[r.home] !== undefined && r.homescore > games.cache[r.home])
                                goals = true;
                            games.cache[r.home] = r.homescore;

                            if (games.cache[r.away] !== undefined && r.awayscore > games.cache[r.away])
                                goals = true;
                            games.cache[r.away] = r.awayscore;

                            if (!r.started)
                                pending = true;
                            else if (!r.finished)
                                running = true;

                            if (i === detailsIndex) {
                                pageStack.nextPage(page).details = r;
                                pageStack.nextPage(page).refresh();
                            }
                        }
                    }
                    games.gamesPending = pending;
                    games.gamesRunning = running;
                }
            }
        }
        property variant date: new Date();
        property bool isError: false
        property variant cache: new Object
        property bool gamesRunning: false
        property bool gamesPending: false

        Timer {
             interval: games.gamesRunning ? 30000 : 600000
             running: games.gamesRunning || games.gamesPending
             repeat: true

             onTriggered: {
                 games.refresh();
             }
        }

        header: PageHeader {
            title: Qt.formatDate(games.model.date, 'ddd, ') + Qt.formatDate(games.model.date)
        }

        ViewPlaceholder {
            enabled: games.model.count === 0
            text: qsTr('No games for the day')
        }

        PullDownMenu {
            MenuItem {
                text: qsTr('Go to today')
                onClicked: games.date = new Date()
            }
            MenuItem {
                text: qsTr('Previous: ') + Qt.formatDate(games.model.prev, 'ddd, ') + Qt.formatDate(games.model.prev)
                onClicked: games.date = games.model.prev
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr('Next: ') + Qt.formatDate(games.model.next, 'ddd, ') + Qt.formatDate(games.model.next)
                onClicked: games.date = games.model.next
            }
        }

        onDateChanged: {
            cache = {};
            refresh();
        }

        function setCover(component) {
            if (component.status === Component.Error) {
                console.log('Failed: ' + component.errorString());
            } else {
                cover = component.createObject();
                cover.model = model;
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
                if (xhr.readyState == 4)
                    games.model.json = xhr.responseText;
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
                    Label {
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
                    Label {
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
                    text: !finished ? detail : ''
                    linkColor: Theme.highlightColor
                    width: parent.width
                    horizontalAlignment: started && !finished ? Text.AlignLeft : Text.AlignHCenter
                    color: bgItem.txtColor
                }
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("DetailsPage.qml"), { source: report, details: games.model.get(index) })
                detailsIndex = index
            }
        }
    }
}


