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

ListModel {
    property string source
    property string json
    property variant _object
    property int status: 0
    property variant date: _object ? new Date(_object.dates.current.isoformat) : undefined
    property variant next: _object ? new Date(_object.dates.next.isoformat) : undefined
    property variant prev: _object ? new Date(_object.dates.prev.isoformat) : undefined

    onSourceChanged: {
        clear();
        status = 0
        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                json = xhr.responseText;
        }
        xhr.open('GET', source);
        xhr.send();
        status = 1
    }

    onJsonChanged: {
        status = 2
        try {
            _object = JSON.parse(json);

            for (var i = 0; i < _object.games.length; i++) {

                var g = _object.games[i];
                set(i, {
                        'home': g.home.name,
                        'away': g.away.name,
                        'homelogo': g.home.logo,
                        'awaylogo': g.away.logo,
                        'tournament': (g.link.match(/\/runkosarja\//) ? 'rs' : 'po'),
                        'game': g.home.name + ' - ' + g.away.name,
                        'homescore': (g.home.goals !== '-' ? '' + g.home.goals : ''),
                        'awayscore': (g.away.goals !== '-' ? '' + g.away.goals : ''),
                        'started': g.started,
                        'finished': g.finished,
                        'report': g.report,
                        'played': (g.started ? (g.status.match(/([0-9]+:[0-9]+)/) || [undefined, ''])[1] : '00:00'),
                        'overtime': (g.finished ? (g.status.match(/\(([^)]+)\)/) || [undefined, ''])[1] : ''),
                        'detail': (g.started ? g['latest-event'].time + ' ' + g['latest-event'].text : g.status.split(' ').pop())
                    });
            }
            status = 3
        } catch (e) {
            if (count == 0)
                _object = undefined;
            status = 4;
        }

    }
}
