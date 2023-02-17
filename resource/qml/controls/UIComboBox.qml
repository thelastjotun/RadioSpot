import QtQuick
import QtQuick.Controls

ComboBox {
    id: root

    implicitWidth: 150
    implicitHeight: 25

    property alias label: textItem
    property alias backgroundColor: backg.color
    property string prefix: ""
    property string suffix: ""
    property bool pushed: pressed || down || hovered
    property alias popupMenu: menuPopup

    // стилизация фона
    background: Rectangle {
        id: backg
        radius: 3
        color: ((root.pressed || root.down || root.hovered) && enabled) ? "#757575" : "#616161"

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    // текст текущего состояния
    contentItem: UIText {
        id: textItem
        width: root.width
        text: root.prefix + root.displayText + root.suffix
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    // наложение стиля
    indicator: Item {}

    delegate: ItemDelegate {
        width: parent.width
        height: root.height
        highlighted: root.highlightedIndex === index
        Rectangle {
            anchors.fill: parent
            border.width: 0
            color: highlighted ? "#616161" : "#525252"

            UIText {
                id: label
                text: modelData
                anchors.fill: parent
                horizontalAlignment: textItem.horizontalAlignment
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                elide: Text.ElideRight
            }
        }
    }

    popup: Popup {
        id: menuPopup
        y: root.height
        width: root.width
        height: contentItem.implicitHeigh
        padding: 1
        clip: true

        contentItem: ListView {
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            spacing: 1
        }

        background: Rectangle {
            color: "#282828"
            border.color: "#777777"
        }
    }
}
