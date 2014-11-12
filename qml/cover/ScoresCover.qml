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
import '../widgets'
import '../effects'

CoverBackground {
    id: cover
    property alias model: view.model
    property int detailsIndex: -1

    signal next()

    CoverActionList {
        CoverAction {
            iconSource: 'image://theme/icon-cover-next'
            onTriggered: {
                next();
            }
        }
    }

    onDetailsIndexChanged: {
        if (detailsIndex != -1) {
            view.positionViewAtIndex(detailsIndex, ListView.Center);
        } else {
            view.contentY = (view.contentHeight - view.height) / 2
        }
    }

    Component.onCompleted: view.contentY = (view.contentHeight - view.height) / 2

    Image {
        id: coverLogo
        source: '/usr/share/icons/hicolor/86x86/apps/harbour-toomiich.png'
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }
    MonochromeEffect {
        sourceItem: coverLogo
        opacity: 0.2
        scale: 1.5
        transformOrigin: Item.Center
    }

    ListView {
        id: view;

        topMargin: cover.height
        bottomMargin: cover.height

        anchors.fill: parent
        anchors.topMargin: Theme.paddingMedium

        onModelChanged: model.countChanged.connect(function () { view.contentY = Qt.binding(function () { return (view.contentHeight - view.height) / 2 }); })

        delegate: Rectangle {
            id: row
            color: 'transparent'
            width: view.width
            height: isActive ? homeScore.height + awayScore.height : Math.max(homeScore.height, awayScore.height, awayLogo.height)
            property bool isActive: view.model.count === 1 || detailsIndex === index
            property int fontSize: (detailsIndex == -1 && view.model.count > 1 ?
                                        Theme.fontSizeMedium :
                                        (isActive ?
                                             Theme.fontSizeHuge :
                                             Theme.fontSizeExtraSmall))

            ProgressCircle {
                height: bigHomeLogo.height
                width: height
                anchors.right: bigHomeLogo.left
                visible: started && !finished
                property real p: played.split(':').reduce(function (a, b) { return a * 60 + b * 1 })
                value: (((p - 1) % 1200) + 1) / ((tournament === 'rs' && p > 3600) ? 300.0 : 1200.0)
                inAlternateCycle: !((Math.floor(Math.max(p - 1, 0) / 1200) + 1) % 2)

                Label {
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: true
                    text: tournament == 'rs' && parent.p > 3600 ? qsTr('OT') : Math.floor(Math.max(parent.p - 1, 0) / 1200) + 1
                }
            }

            Image {
                id: bigHomeLogo
                anchors.right: homeScore.left
                source: isActive ? 'http://liiga.fi' + homelogo : ''
                height: children[0].height * (isActive ? 2 : 1)
                width: children[0].width * (isActive ? 2 : 1)

                Logo {
                    id: homeLogo
                    team: home
                    anchors.centerIn: parent
                    visible: !isActive || parent.status !== Image.Ready
                    scale: isActive ? 2.0 : 1.0
                }
            }
            Label {
                id: homeScore
                text: homescore
                anchors.right: separator.left
                font.bold: homescore >= awayscore
                font.pixelSize: row.fontSize
            }

            Label {
                id: separator
                anchors.horizontalCenter: parent.horizontalCenter
                text: '-'
                font.pixelSize: row.fontSize
            }
            Label {
                id: awayScore
                text: awayscore
                anchors.left: separator.right
                font.bold: awayscore >= homescore
                font.pixelSize: row.fontSize
            }
            Image {
                id: bigAwayLogo
                anchors.left: awayScore.right
                source: isActive ? 'http://liiga.fi' + awaylogo : ''
                height: children[0].height * (isActive ? 2 : 1)
                width: children[0].width * (isActive ? 2 : 1)

                Logo {
                    id: awayLogo
                    team: away
                    anchors.centerIn: parent
                    visible: !isActive || parent.status !== Image.Ready
                    scale: isActive ? 2.0 : 1.0
                }
            }
            Label {
                anchors.left: bigAwayLogo.right
                font.pixelSize: Theme.fontSizeExtraSmall
                text: overtime
            }
        }
    }
}
