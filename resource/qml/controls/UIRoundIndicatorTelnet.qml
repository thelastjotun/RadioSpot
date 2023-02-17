import QtQuick
import Qt5Compat.GraphicalEffects


// 0 - Disconnected
// 1 - Disconnecting
// 2 - Connecting
// 3 - Connected
// 4 - Authorizing
// 5 - Authorized

Item {
    id: root

    property int status: 0

    Rectangle {
        id: tciIndicator
        anchors.fill: parent
        radius: 0.5*height
        color: status === 0 ? "#9e9e9e" : status === 1 ? "#312afa" : status === 2 ? "#312afa" : status === 3 ? "#ac26ff" : status === 4 ? "#ac26ff" : status === 5 ? "#00c853" :  "#ef5350"

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
