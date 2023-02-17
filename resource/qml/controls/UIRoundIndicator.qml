import QtQuick
import Qt5Compat.GraphicalEffects


Item {
    id: root

    property int status: 0

    Rectangle {
        id: tciIndicator
        anchors.fill: parent
        radius: 0.5*height
        color: status === 0 ? "#9e9e9e" : status === 1 ? "#00c853" : status === 2 ? "#fdd835" : "#ef5350"

        Behavior on color { ColorAnimation { duration: 200 }}
    }

    RectangularGlow {
        anchors.fill: tciIndicator
        glowRadius: tciIndicator.radius
        spread: 0.0
        cornerRadius: tciIndicator.radius
        color: tciIndicator.color
        opacity: status === 0 ? 0.0 : 0.8

        Behavior on opacity { NumberAnimation { duration: 200 }}
    }
}
