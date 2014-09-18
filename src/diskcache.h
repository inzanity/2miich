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
