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
    query: '/table/tbody/tr'

    XmlRole {
        query: 'td[2]/string()'
        name: 'name'
    }
    XmlRole {
        query: 'td[3]/string()'
        name: 'games'
    }
    XmlRole {
        query: 'td[4]/string()'
        name: 'wins'
    }
    XmlRole {
        query: 'td[5]/string()'
        name: 'ties'
    }
    XmlRole {
        query: 'td[6]/string()'
        name: 'losses'
    }
    XmlRole {
        query: 'td[7]/string()'
        name: 'extraPoints'
    }
    XmlRole {
        query: 'td[8]/string()'
        name: 'goalsFor'
    }
    XmlRole {
        query: 'td[9]/string()'
        name: 'goalsAgainst'
    }
    XmlRole {
        query: 'td[10]/string()'
        name: 'points'
    }
}
