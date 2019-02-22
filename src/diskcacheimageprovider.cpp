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

#include <QDebug>
#include <QtGlobal>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QStandardPaths>

#include "diskcacheimageprovider.h"
#include "diskcache.h"

DiskCacheImageProvider::DiskCacheImageProvider(QQuickImageProvider::Flags flags) :
    QQuickImageProvider(QQuickImageProvider::Image, flags),
    m_cache(new DiskCache)
{
}

DiskCacheImageProvider::~DiskCacheImageProvider()
{
    delete m_cache;
}

QImage DiskCacheImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage rv;
    QString cached = m_cache->getFile(id, -1);

    if (!cached.isNull())
        rv = QImage(QUrl(cached).toLocalFile());
    else {
        QNetworkRequest req;

        req.setUrl(id);

        QNetworkReply *rep = m_manager.get(req);
        QEventLoop blocker;

        QObject::connect(rep, SIGNAL(finished()), &blocker, SLOT(quit()));
        blocker.exec();

        if (!rep->error()) {
            QByteArray data = rep->readAll();

            rv = QImage::fromData(data);
            if (!rv.isNull())
                m_cache->setFileBinary(id, data);
        }
    }

    if (rv.isNull() || rv.size().isEmpty())
        return rv;

    *size = rv.size();
    if (requestedSize.isValid()) {
        QSize scaleTo = requestedSize;
        if (scaleTo.isEmpty()) {
            if (scaleTo.height())
                scaleTo.setWidth(rv.width() * scaleTo.height() / rv.height());
            else
                scaleTo.setHeight(rv.height() * scaleTo.width() / rv.width());
        }
        rv = rv.scaled(scaleTo, Qt::KeepAspectRatio);
    }

    return rv;
}
