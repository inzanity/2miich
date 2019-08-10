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
#include <QThread>
#include <QUrl>

#include "diskcacheimageprovider.h"
#include "diskcache.h"

class DiskCacheImageRequest;
class Resizer;

class DiskCacheImageProviderPrivate : public QObject {
	Q_OBJECT
public:
	DiskCacheImageProviderPrivate();
	~DiskCacheImageProviderPrivate();

public slots:
	void request(QString id, DiskCacheImageRequest *req, QSize requestedSize);
	void imageReady(DiskCacheImageRequest *req, QImage result);

signals:
	void dataReady(QString file, DiskCacheImageRequest *req, const QSize &requestedSize);

private:
	DiskCache m_cache;
	QNetworkAccessManager m_manager;
	QThread m_resizerThread;
};

class DiskCacheImageRequest : public QQuickImageResponse {
	Q_OBJECT
public:
	DiskCacheImageRequest(DiskCacheImageProviderPrivate *p, QString url);
	~DiskCacheImageRequest() {}
	virtual QString errorString() const;
	virtual QQuickTextureFactory *textureFactory() const;
	virtual void cancel();

	void waitForFinished();
	QString url() const;

	QByteArray data;

public slots:
	void ready(QImage data);

private:
	DiskCacheImageProviderPrivate *prov;
	QEventLoop blocker;
	QImage image;
	QString id;
};

class Resizer : public QObject
{
	Q_OBJECT
public:
	Resizer() {}
	~Resizer() {}

public slots:
	void resize(QString file, DiskCacheImageRequest *req, QSize requestedSize);

signals:
	void resized(DiskCacheImageRequest *req, QImage result);
};

DiskCacheImageProviderPrivate::DiskCacheImageProviderPrivate()
{
	Resizer *resizer = new Resizer;
	resizer->moveToThread(&m_resizerThread);
	connect(&m_resizerThread, &QThread::finished, resizer, &QObject::deleteLater);
	connect(this, &DiskCacheImageProviderPrivate::dataReady, resizer, &Resizer::resize);
	connect(resizer, &Resizer::resized, this, &DiskCacheImageProviderPrivate::imageReady);
	m_resizerThread.start();
}

DiskCacheImageProviderPrivate::~DiskCacheImageProviderPrivate()
{
	m_resizerThread.quit();
	m_resizerThread.wait();
}

void DiskCacheImageProviderPrivate::imageReady(DiskCacheImageRequest *req, QImage result)
{
	QMetaObject::invokeMethod(req, "ready", Q_ARG(QImage, result));
}

void Resizer::resize(QString file, DiskCacheImageRequest *req, QSize requestedSize)
{
	QImage result(file);

	if (requestedSize.isValid()) {
		QSize scaleTo = requestedSize;
		if (scaleTo.isEmpty()) {
			if (scaleTo.height())
				scaleTo.setWidth(result.width() * scaleTo.height() / result.height());
			else
				scaleTo.setHeight(result.height() * scaleTo.width() / result.width());
		}
		result = result.scaled(scaleTo, Qt::KeepAspectRatio);
	}

	emit resized(req, result);
}

DiskCacheImageRequest::DiskCacheImageRequest(DiskCacheImageProviderPrivate *p, QString url) :
	QQuickImageResponse(),
	prov(p),
	id(url)
{
}

DiskCacheImageProvider::DiskCacheImageProvider() :
	QQuickAsyncImageProvider(),
	m_priv(new DiskCacheImageProviderPrivate)
{
	qRegisterMetaType<DiskCacheImageRequest *>("DiskCacheImageRequest");
}

DiskCacheImageProvider::~DiskCacheImageProvider()
{
	delete m_priv;
}

QString DiskCacheImageRequest::url() const
{
	return id;
}

QQuickImageResponse *DiskCacheImageProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
	DiskCacheImageRequest *rv = new DiskCacheImageRequest(m_priv, id);

	QMetaObject::invokeMethod(m_priv, "request", Qt::QueuedConnection,
				  Q_ARG(QString, id),
				  Q_ARG(DiskCacheImageRequest *, rv),
				  Q_ARG(QSize, requestedSize));

	return rv;
}

void DiskCacheImageProviderPrivate::request(QString id, DiskCacheImageRequest *rv, QSize requestedSize)
{
	QString cached = m_cache.getFile(id, -1);

	if (!cached.isNull()) {
		emit dataReady(QUrl(cached).path(), rv, requestedSize);
		return;
	}

	QNetworkRequest req;

	req.setUrl(id);
	QNetworkReply *rep = m_manager.get(req);

	connect(rep, &QNetworkReply::finished, this, [=]() {
		QByteArray data;
		if (rep->error())
			return;
		data = rep->readAll();
		emit dataReady(m_cache.setFileBinary(id, data), rv, requestedSize);
	});
}

void DiskCacheImageRequest::waitForFinished()
{
	blocker.exec();
}

void DiskCacheImageRequest::ready(QImage data)
{
	image = data;
	emit finished();
}

void DiskCacheImageRequest::cancel()
{
}

QString DiskCacheImageRequest::errorString() const
{
	return QString();
}

QQuickTextureFactory *DiskCacheImageRequest::textureFactory() const
{
	return QQuickTextureFactory::textureFactoryForImage(image);
}

QImage DiskCacheImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
	return QImage();
}

#include "diskcacheimageprovider.moc"
