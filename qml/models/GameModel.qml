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
	query: '/data//table/tr[(@class = "odd" or @class = "even") and contains(td[@class = "time"], ":")]'

	XmlRole {
		name: 'time'
		query: 'normalize-space(td[@class = "time"]/string())'
	}
	XmlRole {
		name: 'event'
		query: 'concat(normalize-space(td[1]/string()), normalize-space(td[3]/string()))'
	}
	XmlRole {
		name: 'team'
		query: 'td[(@class = "home" or @class = "away") and boolean(./string())][1]/@class/string()'
	}
    XmlRole {
        name: 'period'
        query: 'floor((number(substring-before(td[@class = "time"], ":")) * 60 + number(substring-after(td[@class = "time"], ":")) - 1) div 1200) + 1'
    }
}
