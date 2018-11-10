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

#ifndef HTMLLISTMODEL_H
# define HTMLLISTMODEL_H

#include <QAbstractListModel>
#include <QTimer>
#include <QQmlListProperty>
#include <libxml/HTMLparser.h>
#include <QHash>
#include <libxml/xpath.h>
#include "htmlrole.h"

template<typename T> void ScoPtr_del(T *t) { delete t; }
template<typename T, void (*D)(T *) = ScoPtr_del<T> > class ScoPtr
{
public:
    ScoPtr() : obj(0) { }
    ScoPtr(T *t) : obj(t) { }
    ~ScoPtr() { if (obj) D(obj); }

    T &operator*() { return *obj; }
    const T &operator*() const { return *obj; }
    T *operator->() { return obj; }
    const T *operator->() const { return obj; }
    operator bool() const { return !!obj; }
    bool operator!() const { return !obj; }
    operator T*() { return obj; }
    operator const T*() const { return obj; }
    T *operator&() { return obj; }
    const T *operator&() const { return obj; }

    ScoPtr<T, D> &operator=(T *t) {
        if (obj)
            D(obj);
        obj = t;
        return *this;
    }

    static void _delete(T *t) { delete t; }
private:
    T *obj;
};

class HtmlListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<HtmlRole> data READ data)
    Q_PROPERTY(QString query WRITE setQuery READ query)
    Q_PROPERTY(QString markup
               WRITE setMarkup
               READ markup
               NOTIFY markupChanged)
    Q_PROPERTY(bool ready READ isReady NOTIFY readyChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_CLASSINFO("DefaultProperty", "data")

public:
    HtmlListModel(QObject *parent = 0);
    virtual ~HtmlListModel();

    QQmlListProperty<HtmlRole> data();
    QString query() const;
    QString markup() const;
    bool isReady() const;
    int count() const;

    void setQuery(QString query);
    void setMarkup(QString markup);

    Q_INVOKABLE QVariantMap get(int index);

    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    bool isReady();

signals:
    void readyChanged();
    void countChanged();
    void markupChanged();

private slots:
    void parse();

private:
    static void role_append(QQmlListProperty<HtmlRole> *list,
                            HtmlRole *role);
    static int role_count(QQmlListProperty<HtmlRole> *list);
    static HtmlRole *role_at(QQmlListProperty<HtmlRole> *list,
                             int pos);
    static void role_clear(QQmlListProperty<HtmlRole> *list);

    QString query_;
    QList<HtmlRole *> roles;
    QString markup_;
    QTimer timer;
    bool ready;

    ScoPtr<xmlDoc, xmlFreeDoc> root;
    ScoPtr<xmlXPathContext, xmlXPathFreeContext> xp_context;
    ScoPtr<xmlXPathObject, xmlXPathFreeObject> xp_results;
    QVector<QMap<int, QVariant> > cache;
};

#endif // HTMLLISTMODEL_H
