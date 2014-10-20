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
import harbour.toomiich.Oledify 1.0
import harbour.toomiich.PersistentTimer 1.0

import harbour.toomiich.DBusInterface 1.0

Oledify {
    id: oledify
    property bool present: false;
    property bool enable: false;
    property bool _active: present && enable;
    property bool haveLock: false

    property alias clockX: clock.x
    property alias clockY: clock.y
    property alias clockW: clock.width
    property alias clockH: clock.height
    property bool clockEnabled: false

    property list<QtObject> resources: [
        DBusInterface {
            id: tohOled

            destination: 'com.kimmoli.toholed'
            iface: 'com.kimmoli.toholed'
            path: '/'
            busType: DBusInterface.SystemBus
        },
        DBusInterface {
            id: dbusNames

            destination: 'org.freedesktop.DBus'
            iface: 'org.freedesktop.DBus'
            path: '/org/freedesktop/DBus'
            signalsEnabled: true

            busType: DBusInterface.SystemBus

            signal rcNameOwnerChanged(string name, string prevOwner, string newOwner);

            onRcNameOwnerChanged: {
                if (name === tohOled.destination)
                    oledify.present = !!newOwner
            }

            Component.onCompleted: {
                dbusNames.typedCallWithReturn('GetNameOwner',
                                              [{type: 's', value: tohOled.destination}],
                                              function (owner) {
                                                  oledify.present = !!owner;
                                              });
            }
        },
        PersistentTimer {
            interval: 25000
            running: _active
            repeat: true
            wakeUp: true

            onTriggered: {
                tohOled.typedCallWithReturn("draw", [
                                                {type: 's', value: 'lock'},
                                                {type: 'b', value: enable},
                                                {type: 's', value: 'fi.inz.2miich'}
                                            ],
                                            function (reply) {
                                                var hadLock = haveLock;
                                                haveLock = reply === 'ok';
                                                if (haveLock) {
                                                    if (!hadLock)
                                                        oledify.update();
                                                    else
                                                        clock.update();
                                                }
                                            });

            }
        },
        Oledify {
            id: clock
            width: 128
            height: 16

            property int x: 0
            property int y: 48

            function update() {
                if (!clockEnabled)
                    return false;
                clock.clear();
                clock.drawText(width / 2, 0, true, 0, new Date().toLocaleTimeString(Qt.locale(), "hh:mm"));
                tohOled.call("drawPicture", [x, y, clock.data]);
            }
        }

    ]

    on_ActiveChanged: {
        if (present) {
            tohOled.typedCallWithReturn("draw", [
                                            {type: 's', value: 'lock'},
                                            {type: 'b', value: enable},
                                            {type: 's', value: 'fi.inz.2miich'}
                                        ],
                                        function (reply) {
                                            var hadLock = haveLock;
                                            haveLock = enable && reply === 'ok';
                                            if (haveLock && !hadLock)
                                                oledify.update();
                                        });
        }
    }

    onPresentChanged: {
        if (!present)
            haveLock = false;
    }

    function update() {
        if (haveLock) {
            if (clockEnabled) {
                oledify.clearRect(clockX, clockY, clockW, clockH);
                oledify.drawText(clockX + clockW / 2, clockY, true, 0, new Date().toLocaleTimeString(Qt.locale(), "hh:mm"))
            }
            tohOled.call("drawPicture", [0, 0, oledify.data]);
        }
    }
}
