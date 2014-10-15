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

Item {
	property alias text: fx.text
	property alias color: real.color
	property alias contentHeight: fx.contentHeight
	property alias contentWidth: fx.contentWidth
	property alias font: real.font

    height: real.height
    width: real.width

    Label {
		id: real
		anchors.top: parent.top
		anchors.left: parent.left

        Label {
			id: fx
            anchors.top: parent.top
            anchors.right: parent.right
			color: parent.color
			opacity: 0.0
			font.pixelSize: parent.font.pixelSize
			transformOrigin: Item.Center

            onTextChanged: if (!behaviorAnimation.running) real.text = text

			Behavior on text {
				SequentialAnimation {
                    id: behaviorAnimation
					PropertyAction {}
					ParallelAnimation {
						NumberAnimation { target: fx; property: 'scale'; from: 3.0; to: 1.0 }
						NumberAnimation { target: fx; property: 'opacity'; from: 0.0; to: 1.0 }
					}
					ScriptAction { script: real.text = fx.text }
					ParallelAnimation {
						NumberAnimation { target: fx; property: 'scale'; from: 1.0; to: 1.2 }
						NumberAnimation { target: fx; property: 'opacity'; from: 1.0; to: 0.0 }
					}
				}
			}

		}
	}
}
