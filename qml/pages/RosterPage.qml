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
    property string source: 'http://liiga.fi' + details.rosters
    property variant details

    onSourceChanged: refresh();

    function refresh() {
        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                rosterModel.markup = xhr.responseText;
            }
        }
        xhr.open('GET', source);
        xhr.send();
    }
    RosterModel {
        id: rosterModel
    }

    Component {
        id: bgComponent
        Item {
            property string place
            anchors.fill: parent
            Image {
                id: bgImg
                source: 'image://cache/http://liiga.fi' + details[place + 'logo']
                anchors.right: parent.left
                anchors.rightMargin: -width / 2
            }
            MonochromeEffect {
                sourceItem: bgImg
                opacity: 0.3
                scale: page.height * 1.5 / sourceItem.height
                transformOrigin: Item.Top
            }
        }
    }
    SilicaListView {
        anchors.fill: parent
        model: rosterModel

        header: PageHeader {
            title: qsTr('Rosters')
        }

        delegate: BackgroundItem {
            anchors.left: parent.left
            anchors.right: parent.right
            id: bgItem
            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
                Image {
                    source: 'image://cache/http://liiga.fi' + image
                    sourceSize.height: bgItem.height
                }
                Label {
                    text: number + ' ' + name
                }
            }
        }

        section.property: 'section-json'
        section.delegate: Rectangle {
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
            anchors.left: parent.left
            anchors.right: parent.right
            height: sectItem.height + 2 * Theme.paddingMedium

            Component.onCompleted: {
                if (sectItem.sectData.line === '1. kenttä')
                    bgComponent.createObject(this, { place: (sectItem.sectData.team === details.home ? 'home' : 'away') })
            }

            Row {
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium

                height: childrenRect.height
                id: sectItem
                property var sectData: JSON.parse(section)

                Label {

                    text: sectItem.sectData.team + ' '
                    visible: sectItem.sectData.line === '1. kenttä'
                }
                Label {
                    text: sectItem.sectData.line
                }
            }
        }

    }
}
