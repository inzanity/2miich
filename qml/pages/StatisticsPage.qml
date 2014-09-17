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

Page {
    property variant mainPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var xhr = new XMLHttpRequest;
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    standings.text = xhr.responseText.match(/(?:<div[^>]+team-standings[^>]+>(?:[\r\n]|.)*?)(<table(?:[\r\n]|.)*?<\/table>)/)[1];
                }
            }
            xhr.open("GET", "http://liiga.fi/");
            xhr.send();
        }
    }
    SilicaFlickable {
        anchors.fill: parent
    Column {
        anchors.fill: parent
        PageHeader {
            title: qsTr("Statistics");
        }
        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            height: contentHeight
            id: standings
            textFormat: Text.RichText
        }
    }
    }
}
