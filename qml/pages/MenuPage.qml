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
    id: page

    property variant mainPage;

    SilicaFlickable {
        anchors.fill: parent
        Column {
            anchors.fill: parent
            PageHeader {
                title: qsTr('Menu')
            }

            BackgroundItem {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    text: qsTr("Statistics");
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: pageStack.push('StatisticsPage.qml', { mainPage: mainPage });
            }
            BackgroundItem {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    text: qsTr("Schedule");
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: pageStack.push('SchedulePage.qml', { mainPage: mainPage });
            }
        }
    }
}
