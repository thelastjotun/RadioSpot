import QtQuick
import QtQuick.Controls

BasicButton {
    id: root

    property alias image: img
    property string unpressSource: ""
    property string pressSource: ""
    property string disableSource: ""
    property bool useToolTip: false
    property alias toolTipObj: toolTip

    width: 1.62 * height
    highlighted: false
    flat: true
    background: Item {}

    contentItem: Item {}

    Image {
        id: img

        anchors.centerIn: parent
        source: (!root.enabled) ? disableSource : (root.pressed
                                                   || root.checked) ? root.pressSource : root.unpressSource
        sourceSize.width: width
        sourceSize.height: height
    }

    UIToolTip {
        id: toolTip
        visible: root.hovered && useToolTip
        parent: root
        enabled: useToolTip
        delay: 1000
        timeout: 5000
    }
}
