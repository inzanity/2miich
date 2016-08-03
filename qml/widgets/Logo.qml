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

Rectangle {
    property string team: 'Tappara'
    property bool active: true
    width: 41
    height: 41
    color: 'transparent'

    Rectangle {
        property variant widths: [25, 28, 30, 33, 35, 30, 28, 42, 31, 40, 37, 27, 32, 34, 37, 32, 32]
        property variant offsets: [0, 36, 74, 113, 153, 200, 240, 276, 327, 365, 414, 462, 501, 542, 580, 621, 667]

        property variant teams: {
            'Blues': 0,
                    'BLU': 0,
                    'HIFK': 1,
                    'IFK': 1,
                    'HPK': 2,
                    'Ilves': 3,
                    'ILV': 3,
                    'Jokerit': 4,
		    'Jukurit': 16,
		    'JUK': 16,
                    'JYP': 5,
                    'Kalpa': 6,
                    'KalPa': 6,
                    'KAL': 6,
		    'KooKoo': 15,
		    'KOO': 15,
                    'Kärpät': 7,
                    'Karpat': 7,
                    'KÄR': 7,
                    'Lukko': 8,
                    'LUK': 8,
                    'Pelicans': 9,
                    'PEL': 9,
                    'Saipa': 10,
                    'SaiPa': 10,
                    'SAI': 10,
                    'Tappara': 11,
                    'TAP': 11,
                    'TPS': 12,
                    'Ässät': 13,
                    'Assat': 13,
                    'ÄSS': 13,
                    'Sport': 14,
                    'SPO': 14
        }
        property variant teamIndex: teams[team]
        anchors.centerIn: parent
        color: 'transparent'
        width: widths[teamIndex]
        height: 41
        clip: true
        Image {
            source: 'qrc:///images/teams.png'
            visible: parent.teamIndex !== undefined
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: -parent.offsets[parent.teamIndex]
            anchors.topMargin: active ? -41 : 0
        }
        Label {
            text: team
            visible: parent.teamIndex === undefined
            anchors.centerIn: parent
            color: Theme.primaryColor
        }
    }
}
