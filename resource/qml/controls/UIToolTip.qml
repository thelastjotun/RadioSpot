import QtQuick
import QtQuick.Controls

ToolTip {
    id: root

    property string suffix: ""
    property string prefix: ""
    property alias label: txt

    contentItem: UIText {
        id: txt
        text: root.prefix + root.text + root.suffix
        color: "#eeeeee"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: "#616161"
        radius: 5
        border.width: 1
        border.color: "#757575"
    }
}
