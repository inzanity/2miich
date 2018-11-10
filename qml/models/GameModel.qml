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

HtmlListModel {
	query: '/html//table/tr[(@class = "odd" or @class = "even") and contains(td[@class = "time"], ":") or (@class != "period" and preceding-sibling::tr[@class = "period"][1]/td = "Maalivahdit")]/td[not(@class = "time") and normalize-space(.) != ""]'

	HtmlRole {
		name: 'time'
		query: 'normalize-space(../td[@class = "time"])'

		function process(text) {
			if (text === 'Torjunnat')
				return '';
			return text;
		}
	}
	HtmlRole {
		name: 'event'
		query: 'normalize-space(.)'

		function process(text) {
			var cln = text.replace(/#[0-9]+\s*/g, '');
			var r;
			if ((r = cln.match(/^(Maalivah(?:ti (?:ulos|sisään)|din vaihto)): ([^,]+?(?: ulos)?)(?:, (.*))?$/)))
				return { text: r[3] || r[2], detail: r[1] + (r[3] ? ': ' + r[2] : '') };
			if ((r = cln.match(/^(.* [0-9]+-[0-9]+)(?: (\([^)]+\)))?(.*)$/)))
				return { type: 'goal', text: r[1] + r[3], detail: r[2] || '' };
			if ((r = cln.match(/^(.*) (aikalisä)/)))
				return { type: 'timeout', text: r[1], detail: r[2] };
			if ((r = cln.match(/^(.*Rangaistuslaukaus.*)\(([^)]+)\)/)))
				return { type: 'penaltyShot', text: r[1], detail: r[2] };
			if ((r = cln.match(/^(.*?) ([0-9]+ min .*)$/)))
				return { type: 'penalty', text: r[1], detail: r[2] };
			if ((r = cln.match(/^(.*?) ([a-zåäö][a-zåäö ]+)$/)))
				return { type: 'penalty', text: r[1], detail: r[2] };
			if ((r = cln.match(/^(.*? \d+(?:\+\d+)*=\d+)\s*(.*?)$/)))
				return { text: r[1], detail: r[2] };
			return { text: cln, detail: '' };
		}
	}
	HtmlRole {
		name: 'team'
		query: '@class'
	}
    HtmlRole {
        name: 'period'
        query: '../preceding-sibling::tr[@class = "period"][1]/td[1]'

        function process(text) {
            var rv = {};
            if (text === 'Maalivahdit') {
                rv.text = QT_TR_NOOP('Goalies');
            } else if (text === 'Jatkoaika') {
                rv.text = QT_TR_NOOP('Overtime');
            } else {
                var m = text.match(/^(\d+)\. (jatko)?erä/);
                if (m[2]) {
                    rv.text = QT_TR_NOOP("%1 overtime");
                } else {
                    rv.text = QT_TR_NOOP("%1 period");
                }
                rv.num = m[1];
            }
            return JSON.stringify(rv);
        }
    }
}
