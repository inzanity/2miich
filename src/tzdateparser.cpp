#include "tzdateparser.h"

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
}
