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

#ifndef OLEDIFY_H
#define OLEDIFY_H

#include <QObject>
#include <QImage>
#include <QSharedPointer>

class Oledify : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QByteArray data READ data NOTIFY dataChanged)
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)

public:
    explicit Oledify(QObject *parent = 0);
    virtual ~Oledify();

    Q_INVOKABLE QByteArray data() const;
    Q_INVOKABLE int width() const;
    Q_INVOKABLE int height() const;

    Q_INVOKABLE void clear();
    Q_INVOKABLE void clearRect(int x, int y, int w, int h);

    Q_INVOKABLE void setWidth(int width);
    Q_INVOKABLE void setHeight(int height);

    Q_INVOKABLE void drawPixmap(int x, int y, QString pixmap);
    Q_INVOKABLE void drawText(int x, int y, bool white, int align, int size, bool bold, QString text);

signals:
    void dataChanged();
    void widthChanged();
    void heightChanged();

public slots:

private:
    QImage *buffer;
};

#endif // OLEDIFY_H
