import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    query: '/table/tbody/tr'

    XmlRole {
        query: 'td[2]/string()'
        name: 'name'
    }
    XmlRole {
        query: 'td[3]/string()'
        name: 'games'
    }
    XmlRole {
        query: 'td[4]/string()'
        name: 'wins'
    }
    XmlRole {
        query: 'td[5]/string()'
        name: 'ties'
    }
    XmlRole {
        query: 'td[6]/string()'
        name: 'losses'
    }
    XmlRole {
        query: 'td[7]/string()'
        name: 'extraPoints'
    }
    XmlRole {
        query: 'td[8]/string()'
        name: 'goalsFor'
    }
    XmlRole {
        query: 'td[9]/string()'
        name: 'goalsAgainst'
    }
    XmlRole {
        query: 'td[10]/string()'
        name: 'points'
    }
}
