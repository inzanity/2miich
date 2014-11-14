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

#ifndef DISKCACHEIMAGEPROVIDER_H
#define DISKCACHEIMAGEPROVIDER_H

#include <QQuickImageProvider>

class DiskCache;

class DiskCacheImageProvider : public QQuickImageProvider
{
public:
	DiskCacheImageProvider(QQuickImageProvider::Flags flags = 0);
	virtual ~DiskCacheImageProvider();

	virtual QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

private:
	DiskCache *m_cache;
};

#endif // DISKCACHEIMAGEPROVIDER_H
