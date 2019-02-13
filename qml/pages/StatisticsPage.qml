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

import '../widgets'
import '../models'

Page {
    property variant mainPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var xhr = new XMLHttpRequest;
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    standings.model.xml = xhr.responseText.match(/(?:<div[^>]+team-standings[^>]+>(?:[\r\n]|.)*?)(<table(?:[\r\n]|.)*?<\/table>)/)[1];
                    var tmp = xhr.responseText.match(/(<div[^>]+goal-leaders[^>]+>(?:[\r\n]|.)*?<\/table>[\r\n\s]*<\/div>)/)[1];
                    tmp = tmp.replace(/<(?:img|br)[^>]*>/g, '');
                    goalLeaders.model.xml = tmp;
                    goalLeader.model.xml = tmp;
                    tmp = xhr.responseText.match(/(<div[^>]+point-leaders[^>]+>(?:[\r\n]|.)*?<\/table>[\r\n\s]*<\/div>)/)[1];
                    tmp = tmp.replace(/<(?:img|br)[^>]*>/g, '');
                    pointLeaders.model.xml = tmp;
                    pointLeader.model.xml = tmp;
                }
            }
            xhr.open("GET", "https://liiga.fi/");
            xhr.send();
        }
    }
    SilicaFlickable {
        anchors.fill: parent

        contentHeight: column.height
        contentWidth: parent.width

        VerticalScrollDecorator {}

        Column {
            id: column
            property ListModel widths: ListModel {}

            anchors.left: parent.left
            anchors.right: parent.right

            PageHeader {
                title: qsTr("Statistics");
            }

            Heading {
                text: qsTr("Standings")
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: children[1].height

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.3
                    color: Theme.highlightColor
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.paddingLarge + 41 + 10 // logo width + spacing
                    anchors.rightMargin: Theme.paddingLarge
                    height: children[0].contentHeight

                    spacing: 10

                    WidthLabel {
                        text: qsTr("Team")

                        widthModel: column.widths
                        widthIndex: 0
                    }
                    WidthLabel {
                        text: qsTr("G")

                        widthModel: column.widths
                        widthIndex: 1
                        horizontalAlignment: Text.AlignRight
                    }
                    WidthLabel {
                        text: qsTr("W")

                        widthModel: column.widths
                        widthIndex: 1
                        horizontalAlignment: Text.AlignRight
                    }
                    WidthLabel {
                        text: qsTr("T")

                        widthModel: column.widths
                        widthIndex: 1
                        horizontalAlignment: Text.AlignRight
                    }
                    WidthLabel {
                        text: qsTr("L")

                        widthModel: column.widths
                        widthIndex: 1
                        horizontalAlignment: Text.AlignRight
                    }
                    WidthLabel {
                        text: qsTr("EP")

                        widthModel: column.widths
                        widthIndex: 1
                        horizontalAlignment: Text.AlignRight
                    }
                    WidthLabel {
                        text: qsTr("P")

                        widthModel: column.widths
                        widthIndex: 2
                        horizontalAlignment: Text.AlignRight
                    }
                    WidthLabel {
                        text: qsTr("GD")

                        widthModel: column.widths
                        widthIndex: 3
                        horizontalAlignment: Text.AlignRight
                    }

                }
            }

            Repeater {
                id: standings
                model: StandingsModel {}

                anchors.left: parent.left
                anchors.right: parent.right

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge

                        spacing: 10

                        height: children[1].contentHeight
                        Logo {
                            id: logo
                            team: name
                        }
                        WidthLabel {
                            text: name

                            widthModel: column.widths
                            widthIndex: 0
                        }
                        WidthLabel {
                            text: games

                            widthModel: column.widths
                            widthIndex: 1
                            horizontalAlignment: Text.AlignRight
                        }
                        WidthLabel {
                            text: wins

                            widthModel: column.widths
                            widthIndex: 1
                            horizontalAlignment: Text.AlignRight
                        }
                        WidthLabel {
                            text: ties

                            widthModel: column.widths
                            widthIndex: 1
                            horizontalAlignment: Text.AlignRight
                        }
                        WidthLabel {
                            text: losses

                            widthModel: column.widths
                            widthIndex: 1
                            horizontalAlignment: Text.AlignRight
                        }
                        WidthLabel {
                            text: extraPoints

                            widthModel: column.widths
                            widthIndex: 1
                            horizontalAlignment: Text.AlignRight
                        }
                        WidthLabel {
                            text: points

                            widthModel: column.widths
                            widthIndex: 2
                            horizontalAlignment: Text.AlignRight
                        }
                        WidthLabel {
                            text: (goalsFor - goalsAgainst)

                            widthModel: column.widths
                            widthIndex: 3
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                    Rectangle {
                        color: Theme.highlightColor
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        visible: index == 5 || index == 9
                    }
                }
            }

            Component {
                id: player

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.rightMargin: Theme.paddingLarge

                    height: children[1].contentHeight

                    Logo {
                        id: pLogo
                        anchors.left: parent.left
                        team: teamName
                    }
                    Label {
                        text: name
                        anchors.left: pLogo.right
                        anchors.leftMargin: 10
                    }
                    Label {
                        text: detail
                        anchors.right: parent.right
                    }
                }
            }

            Heading {
                text: qsTr("Point leaders")
            }

            Repeater {
                id: pointLeader
                model: LeaderModel {}

                delegate: player
            }
            Repeater {
                id: pointLeaders
                model: PlayerListModel {}

                delegate: player
            }

            Heading {
                text: qsTr("Goal leaders")
            }

            Repeater {
                id: goalLeader
                model: LeaderModel {}

                delegate: player
            }
            Repeater {
                id: goalLeaders
                model: PlayerListModel {}

                delegate: player
            }
        }
    }
}
