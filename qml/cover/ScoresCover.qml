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
    property alias model: view.model;

    Image {
        id: coverLogo
        source: '/usr/share/icons/hicolor/86x86/apps/harbour-2miich.png'
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

        anchors.fill: parent
        anchors.topMargin: Theme.paddingMedium

        delegate: Rectangle {
            color: 'transparent'
            width: view.width
            height: Math.max(homeScore.height, awayScore.height, awayLogo.height)
            ProgressCircle {
                height: homeLogo.height
                width: height
                anchors.right: homeLogo.left
                visible: started && !finished
                property real p: played.split(':').reduce(function (a, b) { return a * 60 + b * 1 })
                value: (((p - 1) % 1200) + 1) / ((tournament === 'rs' && p > 3600) ? 300.0 : 1200.0)

                Label {
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: true
                    text: tournament == 'rs' && parent.p > 3600 ? qsTr('OT') : Math.floor(Math.max(parent.p - 1, 0) / 1200) + 1
                }
            }

            Logo {
                id: homeLogo
                team: home
                anchors.right: homeScore.left
            }
            Label {
                id: homeScore
                text: homescore
                anchors.right: separator.left
                font.bold: homescore >= awayscore
            }

            Label {
                id: separator
                anchors.horizontalCenter: parent.horizontalCenter
                text: '-'
            }
            Label {
                id: awayScore
                text: awayscore
                anchors.left: separator.right
                font.bold: awayscore >= homescore
            }

            Logo {
                id: awayLogo
                anchors.left: awayScore.right
                team: away
            }
            Label {
                anchors.left: awayLogo.right
                font.pixelSize: Theme.fontSizeExtraSmall
                text: overtime
            }
        }
    }
}
