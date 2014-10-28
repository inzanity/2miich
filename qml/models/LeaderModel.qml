import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    query: '/div//div[@class="info"]'

    XmlRole {
        name: 'name'
        query: 'normalize-space(span[@class="name"]/string())'
    }
    XmlRole {
        name: 'teamName'
        query: 'normalize-space(span[@class="team"]/string())'
    }
    XmlRole {
        name: 'detail'
        query: 'normalize-space(span[@class="points" or @class = "goals"]/string())'
    }
}
