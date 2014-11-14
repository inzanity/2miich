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
#include <QGuiApplication>
#include <QQuickView>
#include <sailfishapp.h>

#include "diskcache.h"
#include "oledify.h"
#include "persistenttimer.h"
#include "declarativedbusadaptor.h"
#include "declarativedbusinterface.h"
#include "diskcacheimageprovider.h"
#include "tzdateparser.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<DiskCache, 1>("harbour.toomiich.DiskCache", 1, 0, "DiskCache");
    qmlRegisterType<Oledify, 1>("harbour.toomiich.Oledify", 1, 0, "Oledify");
    qmlRegisterType<PersistentTimer, 1>("harbour.toomiich.PersistentTimer", 1, 0, "PersistentTimer");
    qmlRegisterType<DeclarativeDBusInterface, 1>("harbour.toomiich.DBusInterface", 1, 0, "DBusInterface");
    qmlRegisterType<DeclarativeDBusAdaptor, 1>("harbour.toomiich.DBusAdaptor", 1, 0, "DBusAdaptor");
    qmlRegisterType<TzDateParser, 1>("harbour.toomiich.TzDateParser", 1, 0, "TzDateParser");

    int result = 0;
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
    view->engine()->addImageProvider(QLatin1String("cache"),
                                     new DiskCacheImageProvider(QQuickImageProvider::ForceAsynchronousImageLoading));
    QString qml = QString("qml/harbour-toomiich.qml");
    view->setSource(SailfishApp::pathTo(qml));
    view->show();
    result = app->exec();
    delete view;
    delete app;
    return result;
}

