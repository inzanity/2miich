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

Rectangle {
    property string team: 'Tappara'
    property bool active: true
    width: 41
    height: 41
    color: 'transparent'

    Rectangle {
        property variant widths: [25, 28, 30, 33, 35, 30, 28, 42, 31, 36, 37, 27, 32, 34, 37]
        property variant offsets: [0, 36, 74, 113, 153, 200, 240, 276, 327, 367, 414, 462, 501, 542, 580]

        property variant teams: {
            'Blues': 0,
                    'HIFK': 1,
                    'HPK': 2,
                    'Ilves': 3,
                    'Jokerit': 4,
                    'JYP': 5,
                    'Kalpa': 6,
                    'KalPa': 6,
                    'Kärpät': 7,
                    'Karpat': 7,
                    'Lukko': 8,
                    'Pelicans': 9,
                    'Saipa': 10,
                    'SaiPa': 10,
                    'Tappara': 11,
                    'TPS': 12,
                    'Ässät': 13,
                    'Assat': 13,
                    'Sport': 14
        }
        property int teamIndex: teams[team]
        anchors.centerIn: parent
        color: 'transparent'
        width: widths[teamIndex]
        height: 41
        clip: true
        Image {
            source: 'qrc:///images/teams.png'
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: -parent.offsets[parent.teamIndex]
            anchors.topMargin: active ? -41 : 0
        }
    }
}
