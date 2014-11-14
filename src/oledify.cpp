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

#include <QPainter>
#include <QFont>
#include <QBuffer>
#include "oledify.h"

Oledify::Oledify(QObject *parent) :
    QObject(parent),
    buffer(new QImage(128, 64, QImage::Format_Mono))
{
}

Oledify::~Oledify()
{
    delete buffer;
}

QByteArray Oledify::data() const
{
    QBuffer buf;
    buffer->save(&buf, "PNG");

    return buf.buffer();
}

int Oledify::width() const
{
    return buffer->width();
}

int Oledify::height() const
{
    return buffer->height();
}

void Oledify::clear()
{
    buffer->fill(Qt::color0);
}

void Oledify::clearRect(int x, int y, int w, int h)
{
    QPainter p;

    p.begin(buffer);
    p.setBrush(Qt::black);
    p.drawRect(x, y, w, h);
    p.end();
}

void Oledify::setWidth(int width)
{
    int h = buffer->height();
    delete buffer;
    buffer = new QImage(width, h, QImage::Format_Mono);
}

void Oledify::setHeight(int height)
{
    int w = buffer->width();
    buffer = new QImage(height, w, QImage::Format_Mono);
}

void Oledify::drawPixmap(int x, int y, QString pixmap)
{
    QImage from(pixmap);
    QPainter p;

    p.begin(buffer);
    p.drawImage(x, y, from, 0, 0, from.width(), from.height());
    p.end();
}

void Oledify::drawText(int x, int y, bool white, int align, int size, bool bold, QString text)
{
    QPainter p;
    QFont font("Sail Sans Pro");

    font.setPixelSize(size);
    if (bold)
        font.setWeight(QFont::Bold);

    p.begin(buffer);

    p.setFont(font);

    if (white)
        p.setPen(QColor("white"));
    else
        p.setPen(QColor("black"));

    if (align < 0)
        p.drawText(x, y, width() - x, height() - y, Qt::AlignLeft | Qt::AlignTop, text);
    else if (align > 0)
        p.drawText(0, y, x, height() - y, Qt::AlignRight | Qt::AlignTop, text);
    else
        p.drawText(x - width() / 2, y, width(), height() - y, Qt::AlignHCenter | Qt::AlignTop, text);

    p.end();
}
