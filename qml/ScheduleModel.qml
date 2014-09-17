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
import QtQuick.XmlListModel 2.0

XmlListModel {
    query: '/data//table/tbody/tr'

    XmlRole {
        name: 'date'
        query: 'td[2][string() != ""]/string()'
    }
    XmlRole {
        name: 'time'
        query: 'td[3]/string()'
    }
    XmlRole {
        name: 'home'
        query: 'normalize-space(substring-before(td[4], " - "))'
    }
    XmlRole {
        name: 'away'
        query: 'normalize-space(substring-after(td[4], " - "))'
    }
    XmlRole {
        name: 'result'
        query: 'td[6]/string()'
    }
    XmlRole {
        name: 'overtime'
        query: 'td[7]/string()'
    }
}
