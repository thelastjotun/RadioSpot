import QtQuick
import QtQuick.Controls

Switch {
    id: switcher

    property bool useToolTip: false
    property alias toolTipObj: toolTip

    indicator: Rectangle {
        width: 2 * height
        height: switcher.height
        x: switcher.leftPadding
        y: parent.height / 2 - height / 2
        radius: 0.5 * height
        color: switcher.checked ? "#43a047" : "black"
        border.color: "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        Rectangle {
            x: switcher.checked ? parent.width - width : 0
            width: parent.height
            height: parent.height
            radius: height / 2
            color: (switcher.down || switcher.checked) ? "#eeeeee" : "#b7b7b7"
            border.color: "transparent"

            Behavior on x {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }

    UIToolTip {
        id: toolTip
        visible: switcher.hovered && useToolTip
        parent: switcher
        enabled: useToolTip
        delay: 1000
        timeout: 5000
    }
}
