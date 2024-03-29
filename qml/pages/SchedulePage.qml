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
import '../models'
import QtQuick.XmlListModel 2.0
import harbour.toomiich.DiskCache 1.0
import harbour.toomiich.TzDateParser 1.0

Page {
    property variant mainPage

    DiskCache { id: xmlCache }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var src = "https://old.liiga.fi/ottelut/";
            var cached = xmlCache.getFile(src);
            var uri = src;

            if (cached) uri = cached;

            var xhr = new XMLHttpRequest;
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (uri === src)
                        xmlCache.setFile(src, xhr.responseText);
                    var begin = xhr.responseText.indexOf("<table");
                    var end = xhr.responseText.lastIndexOf('</table>');
                    listView.model.markup = '<html><body>' + xhr.responseText.substring(begin, end + 8) + '</body></html>';
                }
            }
            xhr.open("GET", uri);
            xhr.send();
        }
    }

    TzDateParser {
        id: dateParser
        tz: 'Europe/Helsinki'
    }

    SilicaListView {
        id: listView

        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Schedule");
        }

        section.property: 'date'
        section.delegate: BackgroundItem {
            Label {
                id: sLbl
                property date dt: new Date(Date.parse(section.replace(/^([0-9]+)([0-9]{2})([0-9]{2})$/, '$2/$3/$1')))
                text: section ? Qt.formatDate(dt, 'ddd, ') + Qt.formatDate(dt) : ''
                width: contentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
            }
            onClicked: { mainPage.date = sLbl.dt; pageStack.popAttached(); }
        }

        model: ScheduleModel {
            onReadyChanged: {
                if (ready) {
                    var i;

                    for (i = 0; i < count; i++) {
                        var r = get(i);

                        if (r.date && new Date(Date.parse(section.replace(/^([0-9]+)([0-9]{2})([0-9]{2})$/, '$2/$3/$1'))) >= mainPage.date) {
                            listView.positionViewAtIndex(i, ListView.Center);
                            break;
                        }
                    }
                }
            }
        }

        delegate: BackgroundItem {
            height: Theme.fontSizeExtraSmall
            anchors.left: parent.left
            anchors.right: parent.right

            Row {
                height: Theme.fontSizeExtraSmall
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge

                Label {
                    text: Qt.formatTime(dateParser.parseDateTime(date + ' ' + time, 'yyyyMMdd hh:mm'))
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: parent.parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Logo {
                    team: home
                    scale: Theme.fontSizeExtraSmall / height
                }
                Label {
                    text: home + ' - ' + away
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: parent.parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Logo {
                    team: away
                    scale: Theme.fontSizeExtraSmall / height
                }
                Label {
                    text: result !== ' - ' ? result + overtime : ''
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: parent.parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }

            onClicked: { var i; for (i = index; !listView.model.get(i).date; i--); mainPage.date = new Date(Date.parse(listView.model.get(i).date.replace(/^([0-9]+)([0-9]{2})([0-9]{2})$/, '$2/$3/$1'))); pageStack.popAttached(); }
        }
        VerticalScrollDecorator {}
    }
}
