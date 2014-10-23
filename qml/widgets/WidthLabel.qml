import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    property ListModel widthModel
    property int widthIndex

    width: widthModel.count > widthIndex ? widthModel.get(widthIndex).width : contentWidth

    onContentWidthChanged: {
        while (widthModel.count < widthIndex)
            widthModel.append({ width: 0 });

        if (widthModel.count <= widthIndex || widthModel.get(widthIndex).width < contentWidth)
            widthModel.set(widthIndex, { width: contentWidth });
    }
}
