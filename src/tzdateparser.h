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
