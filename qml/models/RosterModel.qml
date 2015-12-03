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
import harbour.toomiich.HtmlListModel 1.0
import harbour.toomiich.TzDateParser 1.0

HtmlListModel {
    property string source
    query: '//div[@class = "rosters"]/div/div/div[@class = "line"]/div/a[@class = "player"]'

    onSourceChanged: {
        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                markup = '<html><body>' + xhr.responseText;
        }
        xhr.open('GET', source);
        xhr.send();
    }

    HtmlRole {
        name: 'team'
        query: '../../../../span[@class = "team-name"]'
    }

    HtmlRole {
        name: 'name'
        query: 'div[@class = "name"]'
    }

    HtmlRole {
        name: 'number'
        query: 'div[@class = "jersey"]'
    }

    HtmlRole {
        name: 'image'
        query: 'div[@class = "img"]/img/@src'
    }

    HtmlRole {
        name: 'position'
        query: '../@class'
    }

    HtmlRole {
        name: 'positionIndex'
        query: 'count(preceding-sibling::a[@class = "player"])'
    }

    HtmlRole {
        name: 'line'
        query: '../../div[@class = "head"]'
    }

    HtmlRole {
        name: 'section-json'
        query: 'concat(\'{"team":"\',../../../../span[@class = "team-name"],\'","line":"\',../../div[@class = "head"],\'"}\')'
    }
}
