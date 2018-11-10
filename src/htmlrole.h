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

#ifndef HTMLROLE_H
# define HTMLROLE_H

#include <QObject>
#include <QVariant>

class HtmlRole : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name WRITE setName READ name)
    Q_PROPERTY(QString query WRITE setQuery READ query)

public:
    HtmlRole(QObject *parent = 0);
    virtual ~HtmlRole();

    QString name() const;
    QString query() const;

    void setName(QString name);
    void setQuery(QString query);

    Q_INVOKABLE QVariant process(QVariant result);

    bool hasProcess;

private:
    QString name_;
    QString query_;
};

#endif // HTMLROLE_H
