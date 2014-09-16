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

ShaderEffect {
    property alias sourceItem: source.sourceItem
    anchors.fill: sourceItem
    property variant source: ShaderEffectSource { id: source; hideSource: true }
    property color color: Theme.highlightColor;
    fragmentShader:
        "uniform lowp float qt_Opacity;" +
        "uniform sampler2D source;" +
        "uniform highp vec4 color;" +
        "varying highp vec2 qt_TexCoord0;" +
        "void main() {" +
        "    highp vec4 c = texture2D(source, qt_TexCoord0);" +
        "    highp float m = (c.r + c.g + c.b) / 3.0;" +
        "    gl_FragColor = vec4(color.r * m, color.g * m, color.b * m, c.a) * qt_Opacity;" +
        "}"
}
