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

#include "tzdateparser.h"

#if QT_VERSION >= QT_VERSION_CHECK(5, 2, 0)
# include <QTimeZone>
#endif

TzDateParser::TzDateParser(QObject *parent) :
    QObject(parent),
    m_tz("Europe/Helsinki")
{
}

QString TzDateParser::tz() const
{
    return m_tz;
}

void TzDateParser::setTz(QString tz)
{
    m_tz = tz;

    emit tzChanged();
}

QDateTime TzDateParser::parseDateTime(QString date, QString format)
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 2, 0)
    QDateTime parsed = QDateTime::fromString(date, format);

    if (QTimeZone::isTimeZoneIdAvailable(m_tz.toLocal8Bit()))
        parsed.setTimeZone(QTimeZone(m_tz.toLocal8Bit()));

    return parsed.toLocalTime();
#else
    const char *tmp = getenv("TZ");

    setenv("TZ", m_tz.toLocal8Bit().constData(), 1);
    tzset();

    time_t dt = QDateTime::fromString(date, format).toTime_t();

    if (tmp)
        setenv("TZ", tmp, 1);
    else
        unsetenv("TZ");
    tzset();

    return QDateTime::fromTime_t(dt);
#endif
}
