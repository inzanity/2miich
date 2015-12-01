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
    id: root
    property string source
    property int status: 0
    property variant date: datesModel.ready && datesModel.count ? new Date(datesModel.get(0).current) : undefined
    property variant next: datesModel.ready && datesModel.count ? new Date(datesModel.get(0).next) : undefined
    property variant prev: datesModel.ready && datesModel.count ? new Date(datesModel.get(0).prev) : undefined

    property Timer delayedReady: Timer {
        interval: 0
        repeat: false
        onTriggered: root.status = 3
    }

    property var teamFix: {
                'Assat': 'Ässät',
                'Hpk': 'HPK',
                'Hifk': 'HIFK',
                'Kookoo': 'KooKoo',
                'Jyp': 'JYP',
                'Saipa': 'SaiPa',
                'Tps': 'TPS',
                'Kalpa': 'KalPa',
                'Karpat': 'Kärpät'
    }
    function teamFromLogo(logo) {
        var tmp;

        if ((tmp = logo.match(/Logot_[0-9]+_([^_.]+)/))) {
            logo = tmp[1];
        } else if ((tmp = logo.match(/\/([^-]+)[^\/]*$/))) {
            logo = tmp[1];
        }
        logo = logo.replace(/^(.)(.*)$/, function (full, first, rest) {
            return first.toUpperCase() + rest.toLowerCase();
        });

        if (teamFix.hasOwnProperty(logo))
            return teamFix[logo];
        return logo;
    }

    property HtmlListModel datesModel: HtmlListModel {
        markup: root.markup

        onReadyChanged: {
            if (ready && root.ready)
                root.delayedReady.start()
        }

        query: '/html/body/div[@class = "dates"]'
        HtmlRole {
            name: 'current'
            query: 'div[@class = "current"]/@data-date'
        }
        HtmlRole {
            name: 'prev'
            query: 'div[@class = "prev"]/@data-date'
        }
        HtmlRole {
            name: 'next'
            query: 'div[@class = "next"]/@data-date'
        }
    }

    query: '/html/body/div[contains(@class, "games-container")]/div/div[@class="game"]'

    property variant resource: TzDateParser {
        id: dateParser
        tz: 'Europe/Helsinki'
    }

    onReadyChanged: {
        if (ready && datesModel.ready)
            delayedReady.start()
    }

    onMarkupChanged: {
        status = 1
    }

    onSourceChanged: {
        status = 0
        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                markup = '<html><body>' + xhr.responseText;
        }
        xhr.open('GET', source);
        xhr.send();
    }

    HtmlRole {
        name: 'homelogo'
        query: 'a/div/div[@class="home"]/div/div/img/@src'
    }
    HtmlRole {
        name: 'home'
        query: 'a/div/div[@class="home"]/div/div/img/@src'
        function process(logo) {
            return root.teamFromLogo(logo);
        }
    }
    HtmlRole {
        name: 'homescore'
        query: 'a/div/div[@class="home"]/div/div[@class="goals"]'

        function process(score) {
            if (score === '-')
                return '';
            return score;
        }
    }
    HtmlRole {
        name: 'awaylogo'
        query: 'a/div/div[@class="away"]/div/div/img/@src'
    }
    HtmlRole {
        name: 'away'
        query: 'a/div/div[@class="away"]/div/div/img/@src'
        function process(logo) {
            return root.teamFromLogo(logo);
        }
    }
    HtmlRole {
        name: 'tournament'
        query: 'a[@class="game_link"]/@href'

        function process(link) {
            if (link.match(/\/runkosarja\//))
                return 'rs';
            return 'po';
        }
    }
    HtmlRole {
        name: 'awayscore'
        query: 'a/div/div[@class="away"]/div/div[@class="goals"]'

        function process(score) {
            if (score === '-')
                return '';
            return score;
        }
    }
    HtmlRole {
        name: 'startTime'
        query: 'concat(/html/body/div[@class = "dates"]/div[@class = "current"]/@data-date, " ", div[@class="status-short"])'

        function process(text) {
            if (!text.match(/Ottelu alkaa/))
                return undefined;
            return dateParser.parseDateTime(text, "yyyy-M-d' Ottelu alkaa klo 'hh:mm")
        }
    }
    HtmlRole {
        name: 'started'
        query: 'div[@class="status-short"]'

        function process(text) {
            return !text.match(/Ottelu alkaa/);
        }
    }
    HtmlRole {
        name: 'finished'
        query: 'div[@class="status-short"]'

        function process(text) {
            return !!text.match(/Ottelu päättynyt/);
        }
    }
    HtmlRole {
        name: 'report'
        query: 'div/div/a[@class="report_link"]/@href'
    }
    HtmlRole {
        name: 'played'
        query: 'div[@class="status-short"]'

        function process(text) {
            if (text.match(/Ottelu alkaa/))
                return '00:00';
            return (text.match(/([0-9]+:[0-9]+)/ || [undefined, '']))[1];
        }
    }

    HtmlRole {
        name: 'overtime'
        query: 'div[@class="status-short"]'

        function process(text) {
            return (text.match(/Ottelu päättynyt \(([^)]+)\)/) || [undefined, ''])[1];
        }
    }
    HtmlRole {
        name: 'detail'
        query: 'normalize-space(div[@class="latest-event"])'
    }
}
