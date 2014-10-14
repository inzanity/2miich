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

#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QStandardPaths>
#include <QDateTime>
#include "diskcache.h"

#include <QDebug>
#include <QtGlobal>

DiskCache::DiskCache(QObject *parent) :
    QObject(parent)
{
}

QString DiskCache::getFile(const QString &what, int maxage)
{
    QString fn = QCryptographicHash::hash(what.toUtf8(), QCryptographicHash::Md5).toHex();
    QStringList caches = QStandardPaths::standardLocations(QStandardPaths::CacheLocation);

    if (caches.empty())
        return QString();

    QFileInfo info(QDir(caches[0]).filePath(fn));

    if (!info.exists() || info.lastModified().secsTo(QDateTime::currentDateTime()) > maxage)
        return QString();

    return QUrl::fromLocalFile(info.absoluteFilePath()).toString();
}

bool DiskCache::setFile(const QString &what, const QString &towhat)
{
    QString fn = QCryptographicHash::hash(what.toUtf8(), QCryptographicHash::Md5).toHex();
    QStringList caches = QStandardPaths::standardLocations(QStandardPaths::CacheLocation);
    bool rv;

    if (caches.empty())
        return false;

    QDir::root().mkpath(caches[0]);
    QFile out(QDir(caches[0]).filePath(fn));

    out.open(QIODevice::WriteOnly);

    if (!out.isOpen())
        return false;

    rv = out.write(towhat.toUtf8());
    out.close();

    return rv;
}
