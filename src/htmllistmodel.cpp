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

#include <QtGlobal>
#include <QDebug>

#include "htmllistmodel.h"

void _xmlFreeChar(xmlChar *ptr) {
    xmlFree(ptr);
}

HtmlListModel::HtmlListModel(QObject *parent) :
    QAbstractListModel(parent),
    root(0),
    xp_context(0),
    xp_results(0)
{
    timer.setSingleShot(true);
    timer.setInterval(0);
    connect(&timer, &QTimer::timeout,
            this, &HtmlListModel::parse);
}

HtmlListModel::~HtmlListModel()
{
}

QString HtmlListModel::query() const
{
    return query_;
}

void HtmlListModel::setQuery(QString query)
{
    if (ready) {
        ready = false;
        emit readyChanged();
    }

    query_ = query;

    timer.start();
}

bool HtmlListModel::isReady()
{
    return ready;
}

void HtmlListModel::parse()
{
    int oldCount = count();
    if (markup_.isEmpty() || query_.isEmpty()) {
        if (oldCount)
            beginRemoveRows(QModelIndex(), 0, oldCount - 1);
        xp_results = 0;
        xp_context = 0;
        root = 0;
        if (oldCount)
            endRemoveRows();
        return;
    }

    QByteArray mup_utf8 = markup_.toUtf8();
    root = htmlParseDoc((xmlChar *)mup_utf8.data(),
                        "UTF-8");
    xp_context = xmlXPathNewContext(root);

    QByteArray qry_utf8 = query_.toUtf8();
    xp_results = xmlXPathEval((const xmlChar *)qry_utf8.data(),
                              xp_context);

    ready = true;
    emit readyChanged();
    if (count() != oldCount) {
        if (count() < oldCount) {
            beginRemoveRows(QModelIndex(), count(), oldCount - 1);
            endRemoveRows();
        } else {
            beginInsertRows(QModelIndex(), oldCount, count() - 1);
            endInsertRows();
        }
        emit countChanged();
    }
    emit dataChanged(index(0, 0), index(count() - 1, 0));
}

QString HtmlListModel::markup() const
{
    return markup_;
}

void HtmlListModel::setMarkup(QString markup)
{
    if (ready) {
        ready = false;
        emit readyChanged();
    }
    markup_ = markup;

    timer.start();

    emit markupChanged();
}

QQmlListProperty<HtmlRole> HtmlListModel::data()
{
    return QQmlListProperty<HtmlRole>(this, 0,
                                      HtmlListModel::role_append,
                                      HtmlListModel::role_count,
                                      HtmlListModel::role_at,
                                      HtmlListModel::role_clear);
}

void HtmlListModel::role_append(QQmlListProperty<HtmlRole> *list,
                                HtmlRole *role)
{
    HtmlListModel *that = static_cast<HtmlListModel *>(list->object);
    that->roles << role;
}

int HtmlListModel::role_count(QQmlListProperty<HtmlRole> *list)
{
    HtmlListModel *that = static_cast<HtmlListModel *>(list->object);
    return that->roles.size();
}

HtmlRole *HtmlListModel::role_at(QQmlListProperty<HtmlRole> *list,
                                 int pos)
{
    HtmlListModel *that = static_cast<HtmlListModel *>(list->object);
    return that->roles[pos];
}

void HtmlListModel::role_clear(QQmlListProperty<HtmlRole> *list)
{
    HtmlListModel *that = static_cast<HtmlListModel *>(list->object);
    that->roles.clear();
}

QVariant HtmlListModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole || role >= Qt::UserRole + roles.size())
        return QVariant();
    if (!xp_results || xp_results->type != XPATH_NODESET ||
            index.row() < 0 ||
            index.row() >= xmlXPathNodeSetGetLength(xp_results->nodesetval))
        return QVariant();

    QByteArray qry_utf8 = roles[role - Qt::UserRole]->query().toUtf8();
    xmlNodePtr node = xmlXPathNodeSetItem(xp_results->nodesetval,
                                          index.row());
    ScoPtr<xmlXPathObject, xmlXPathFreeObject> res = xmlXPathNodeEval(
                node,
                (const xmlChar *)qry_utf8.data(),
                (xmlXPathContextPtr)&xp_context);
    ScoPtr<xmlChar, _xmlFreeChar> val = xmlXPathCastToString(res);
    QVariant rv = QString::fromUtf8((const char *)&val);
    if (roles[role - Qt::UserRole]->hasProcess)
        QMetaObject::invokeMethod(roles[role - Qt::UserRole], "process",
                Q_RETURN_ARG(QVariant, rv),
                Q_ARG(QVariant, rv));

    return rv;
}

QVariantMap HtmlListModel::get(int pos)
{
    if (pos < 0 || pos >= count())
        return QVariantMap();
    QVariantMap rv;
    QModelIndex idx = index(pos);

    for (int i = 0; i < roles.size(); i++)
        rv[roles[i]->name()] = data(idx, Qt::UserRole + i);
    /*
        QByteArray qry_utf8 = roles[i]->query().toUtf8();
        xmlNodePtr node = xmlXPathNodeSetItem(
                    xp_results->nodesetval,
                    pos);
        ScoPtr<xmlXPathObject, xmlXPathFreeObject> res =
                xmlXPathNodeEval(
                    node,
                    (const xmlChar *)qry_utf8.data(),
                    xp_context);
        ScoPtr<xmlChar, _xmlFreeChar> val = xmlXPathCastToString(res);
        QVariant data = QString::fromUtf8((const char *)&val);
        QMetaObject::invokeMethod(roles[i], "process",
                                  Q_RETURN_ARG(QVariant, data),
                                  Q_ARG(QVariant, data));

        rv[roles[i]->name()] = data;

    }
    */
    return rv;
}

QHash<int, QByteArray> HtmlListModel::roleNames() const
{
    QHash<int, QByteArray> rv;

    for (int i = 0; i < roles.size(); i++)
        rv[Qt::UserRole + i] = roles[i]->name().toUtf8();

    return rv;
}

int HtmlListModel::count() const
{
    if (!xp_results || xp_results->type != XPATH_NODESET)
        return 0;
    return xmlXPathNodeSetGetLength(xp_results->nodesetval);
}

int HtmlListModel::rowCount(const QModelIndex &parent) const
{
    if (parent != QModelIndex())
        return 0;
    return count();
}
