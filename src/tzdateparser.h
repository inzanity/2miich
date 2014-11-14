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

#ifndef TZDATEPARSER_H
#define TZDATEPARSER_H

#include <QDateTime>
#include <QObject>

class TzDateParser : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString tz READ tz WRITE setTz NOTIFY tzChanged)
public:
    explicit TzDateParser(QObject *parent = 0);

    QString tz() const;
    void setTz(QString tz);

    Q_INVOKABLE QDateTime parseDateTime(QString date, QString format);

signals:
    void tzChanged();

private:
    QString m_tz;
};

#endif // TZDATEPARSER_H
