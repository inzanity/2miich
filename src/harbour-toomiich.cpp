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
#include <QtQml>
#include <sailfishapp.h>

#include "diskcache.h"
#include "oledify.h"
#include "persistenttimer.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<DiskCache, 1>("harbour.toomiich.DiskCache", 1, 0, "DiskCache");
    qmlRegisterType<Oledify, 1>("harbour.toomiich.Oledify", 1, 0, "Oledify");
    qmlRegisterType<PersistentTimer, 1>("harbour.toomiich.PersistentTimer", 1, 0, "PersistentTimer");
    return SailfishApp::main(argc, argv);
}

