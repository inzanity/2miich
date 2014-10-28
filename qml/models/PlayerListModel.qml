import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    query: '/div/table/tr'

    XmlRole {
        name: 'name'
        query: 'normalize-space(td[2]/string())'
    }
    XmlRole {
        name: 'teamName'
        query: 'normalize-space(td[3]/string())'
    }
    XmlRole {
        name: 'detail'
        query: 'normalize-space(td[position() = last()]/string())'
    }
}
