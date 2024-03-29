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
import '../effects'
import '../widgets'
import '../models'

Page {
    id: page
    property string source: 'https://old.liiga.fi' + details.report + 'ajax'
    property variant details

    onSourceChanged: refresh();

    function refresh() {
        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                var xml = '<html>' + xhr.responseText.replace(/&ndash;/g, '-').replace(/&nbsp;/g, ' ').replace(/(<img[^>]*[^\/>])(>)/g, '$1/$2').replace(/<br>/g, '<br/>') + '</html>';
                listView.model.markup = xml;
                shotsModel.xml = xml;
            }
        }
        xhr.open('GET', source);
        xhr.send();
    }
    ShotsModel {
        id: shotsModel
    }

    function formatOrdinal(n) {
        if ((n - 1) % 10 > 2 || Math.floor(n / 10) % 10 == 1)
            return qsTr("%1th").arg(n);
        if (n % 10 === 1)
            return qsTr("%1st").arg(n);
        if (n % 10 === 2)
            return qsTr("%1nd").arg(n);
        if (n % 10 === 3)
            return qsTr("%1rd").arg(n);
    }

    Image {
        id: bgHome
        source: 'image://cache/https://old.liiga.fi' + details.homelogo
        anchors.right: parent.left
        anchors.rightMargin: -parent.width / 2
        anchors.verticalCenter: parent.verticalCenter
    }
    MonochromeEffect {
        sourceItem: bgHome
        opacity: 0.15
        scale: parent.height / sourceItem.height
        transformOrigin: Item.Right
    }

    Image {
        id: bgAway
        source: 'image://cache/https://old.liiga.fi' + details.awaylogo
        anchors.left: parent.right
        anchors.leftMargin: -parent.width / 2
        anchors.verticalCenter: parent.verticalCenter

    }
    MonochromeEffect {
        sourceItem: bgAway
        opacity: 0.15
        scale: parent.height / sourceItem.height
        transformOrigin: Item.Left
    }

    SilicaListView {
        id: listView

        PullDownMenu {
            id: pullDown
            MenuItem {
                text: qsTr('Rosters')
                onClicked: pageStack.push('RosterPage.qml', { 'details': details })
            }
        }
        header: Column {
            anchors.left: parent.left
            anchors.right: parent.right
            PageHeader {
                title: details['home'] + ' - ' + details['away']
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    source: 'image://cache/https://old.liiga.fi' + details.homelogo
                }

                Column {
                    Row {
                        GoalLabel {
                            text: details.homescore
                            height: contentHeight
                            width: contentWidth
                            font.pixelSize: Theme.fontSizeHuge
                        }

                        Label {
                            text: ' - '
                            height: contentHeight
                            width: contentWidth
                            font.pixelSize: Theme.fontSizeHuge
                        }
                        GoalLabel {
                            text: details.awayscore
                            height: contentHeight
                            width: contentWidth
                            font.pixelSize: Theme.fontSizeHuge
                        }
                    }
                    Label {
                        horizontalAlignment: Text.AlignHCenter
                        text: details.played
                        height: contentHeight
                        width: parent.width
                    }
                }

                Image {
                    source: 'image://cache/https://old.liiga.fi' + details.awaylogo
                }
            }
        }

        anchors.fill: parent
        model: GameModel { }
        section.property: 'period'
        section.delegate: Rectangle {
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
            anchors.left: parent.left
            anchors.right: parent.right
            height: periodLbl.contentHeight + 2 * Theme.paddingMedium

            Label {
                id: periodLbl
                property var sectData: JSON.parse(section)
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                text: sectData.hasOwnProperty('num') ? qsTr(sectData.text).arg(formatOrdinal(sectData.num)) : qsTr(sectData.text)
            }
        }

        delegate: BackgroundItem {
            id: bgi

            Image {
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                source: (event.type ? 'qrc:///images/' + event.type + '.png' : '')
                visible: event.type !== undefined
                opacity: 0.7
            }
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                property string tm: team

                spacing: 5

                Column {
                    Logo {
                        team: page.details[parent.parent.tm]
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        text: time
                        font.pixelSize: Theme.fontSizeExtraSmall
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.secondaryColor
                    }
                }
                Column {
                    Label {
                        text: event.text
                    }
                    Label {
                        color: Theme.secondaryColor
                        text: event.detail
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

        }
        footer: Item {
            width: parent.width
            height: rink.height
            Image {
                id: rink
                source: 'qrc:///images/rink.svg'
                sourceSize.width: parent.width
            }
            MonochromeEffect {
                sourceItem: rink
            }
            Repeater {
                model: shotsModel

                delegate: Image {
                    source: 'image://cache/https://old.liiga.fi' + details[(cssclass.indexOf('home') != -1 ? 'homelogo' : 'awaylogo')]
                    width: rink.width * 20 / 973
                    height: width
                    opacity: cssclass.indexOf('goal') !== -1 ? 1.0 : 0.5
                    y: style.match(/top: ([0-9.]+)%/)[1] * rink.height / 100
                    x: style.match(/left: ([0-9.]+)%/)[1] * rink.width / 100
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
