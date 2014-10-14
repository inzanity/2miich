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

#ifndef DISKCACHE_H
#define DISKCACHE_H

#include <QObject>

class DiskCache : public QObject
{
    Q_OBJECT
public:
    explicit DiskCache(QObject *parent = 0);

    Q_INVOKABLE QString getFile(const QString &what, int maxage = 3600);
    Q_INVOKABLE bool setFile(const QString &what, const QString &to);
signals:

public slots:

};

#endif // DISKCACHE_H
