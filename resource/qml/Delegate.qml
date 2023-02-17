import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtWebSockets
import Qt5Compat.GraphicalEffects
import Qt.labs.platform
import "controls" as UI

Rectangle {
    id: root

    property int expandHeight: tciRect.y + tciRect.height + 5

    function updateHeight() {
        if (visibleSettingsButton.checked)
            height = expandHeight
    }

    onExpandHeightChanged: updateHeight()

    // свойства
    property int currentIndex: -1

    property double uuid: 0.0

    property alias switchOn: telnetEnable.checked

    property alias configTitle: titleEdit.text
    property string address: telnetHostD + ":" + telnetPortD
    property alias callsign: telnetCallsign.text
    property alias tciHost: hostAddress.text
    property alias telnetHostD: telnetHost.text
    property alias telnetPortD: telnetPort.text

    // 0 - disconnect
    // 1 - connected
    // 2 - disconnected
    property int tciConnectStatus: 0

    // 0 - Disconnected
    // 1 - Disconnecting
    // 2 - Connecting
    // 3 - Connected
    // 4 - Authorizing
    // 5 - Authorized
    property int telnetConnectStatus: 0

    // сигналы
    signal remove
    signal removeAll

    // наложение стиля
    radius: 5
    border.width: 1
    color: "#202020"
    border.color: "#424242"
    clip: true

    // конструктор
    Component.onCompleted: {
        height = visibleSettingsButton.checked ? root.expandHeight : rectTitle.height
    }

    //
    SequentialAnimation on height {
        id: animatorMinimize
        loops: 1
        running: false
        alwaysRunToEnd: true
        NumberAnimation { from: root.height; to: rectTitle.height; duration: 200 }
    }

    SequentialAnimation on height {
        id: animatorMaximize
        loops: 1
        running: false
        alwaysRunToEnd: true
        NumberAnimation { from: rectTitle.height; to: root.expandHeight; duration: 200 }
    }

    WebSocket {
        id: webSocket

        active: switchOnVal ? true : false

        url: "ws://" + tciAddressVal

        onStatusChanged: {
            tciConnectStatus = webSocket.status
        }
    }

    Connections {
        target: main

        function onSpotChanged(callsign, frequency) {
            webSocket.sendTextMessage("SPOT:" + callsign + ",CW," + frequency * 1000 + "," + main.convertFromHexdecimalToDecimal(colorPicker.color) + ",ANY_TEXT")
        }

        function onTelnetStatusChanged(uuid,status) {
            telnetConnectStatus = status
        }
    }

    Rectangle {
        id: rectTitle

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 30
        radius: 5
        color: "#424242"

        Rectangle {
            color: "#424242"
            anchors.top: parent.verticalCenter
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            opacity: visibleSettingsButton.checked ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 }}
        }

        UI.UIImageButton {
            id: visibleSettingsButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 5
            height: parent.height
            width: height
            unpressSource: "qrc:/qml/svg/bottom2.svg"
            pressSource: unpressSource
            checkable: true
            checked: true
            rotation: (checked || down) ? 0 : 90
            Behavior on rotation { NumberAnimation { duration: 200 }}

            DropShadow {
                anchors.fill: parent.image
                horizontalOffset: 0
                verticalOffset: 1
                radius: 8.0
                color: "#70000000"
                source: parent.image
            }

            onCheckedChanged: {
                if (checked)
                    animatorMaximize.start()
                else
                    animatorMinimize.start()
            }
        }

        UI.UISwitch {
            id: telnetEnable

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 5
            height: 18
            useToolTip: true
            toolTipObj.text: checked ? qsTr("Disable connection") : qsTr("Enable connection")


            onCheckedChanged: {
                switchOn = checked
            }
        }

        Rectangle {
            id: rectConnectionTitle
            anchors.left: telnetEnable.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 160
            radius: 3
            color: telnetEnable.checked ? "#424242" : "#202020"
            anchors.margins: 2
            anchors.leftMargin: 10

            Behavior on color { ColorAnimation { duration: 200 }}
            Behavior on border.color { ColorAnimation { duration: 200 }}

            TextInput {
                id: titleEdit
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                text: root.configTitle
                color: "#e0e0e0"
                focus: true
                selectByMouse: true
                selectionColor: 'darkgray'
                selectedTextColor: 'white'
                enabled: !telnetEnable.checked
            }
        }

        Item {
            anchors.left: rectConnectionTitle.right
            anchors.right: removeButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            opacity: visibleSettingsButton.checked ? 0 : 1

            Behavior on opacity { NumberAnimation { duration: 200 }}

            UI.UIText {
                id: tciTitleIndicator
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                text: "TCI"
                color: "#e0e0e0"

                UI.UIRoundIndicator {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5
                    height: 8
                    width: 8
                    status: tciConnectStatus
                }
            }

            UI.UIText {
                id: telnetTitleIndicator
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: tciTitleIndicator.left
                anchors.leftMargin: 40
                text: "Telnet"
                color: "#e0e0e0"

                UI.UIRoundIndicatorTelnet {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5
                    height: 8
                    width: 8
                    status: telnetConnectStatus
                }
            }
        }

        UI.UIImageButton {
            id: removeButton

            anchors.right: visibleSettingsButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            anchors.rightMargin: 15
            width: height
            unpressSource: "qrc:/qml/svg/remove.svg"
            pressSource: unpressSource
            image.width: width
            image.height: height
            enabled: !telnetEnable.checked
            opacity: enabled ? 1 : 0
            useToolTip: true
            toolTipObj.text: qsTr("Remove synchronization")

            Behavior on opacity { NumberAnimation { duration: 200 }}

            DropShadow {
                anchors.fill: parent.image
                horizontalOffset: 1
                verticalOffset: 1
                radius: 8.0
                color: "#70000000"
                source: parent.image
            }

            ColorOverlay {
                anchors.fill: parent.image
                source: parent.image
                color: parent.pressed ? "#ef5350" : "#757575"
            }

            onClicked: {
                removeDialog.open()
            }

            MessageDialog {
                id: removeDialog
                buttons: StandardButton.Yes | StandardButton.No
                title: main.applicationName() + qsTr(" Remove synchronization")
                text: qsTr("Do you really want to delete the sync?")

                onYesClicked: {
                    root.remove()
                }
            }
        }
    }

    Rectangle {
        id: tciRect
        anchors.left: parent.left
        anchors.right: parent.horizontalCenter
        anchors.top: rectTitle.bottom
        anchors.margins: 5
        anchors.rightMargin: 0.5*anchors.margins
        height: 113
        radius: 5
        color: "#2a2a2a"

        Rectangle {
            id: tciSettingsTitleRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 20
            radius: 5
            color: "#424242"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.verticalCenter
                anchors.bottom: parent.bottom
                color: parent.color
            }

            UI.UIText {
                id: tciTitle
                anchors.centerIn: parent
                text: "TCI"
                color: "#e0e0e0"

                UI.UIRoundIndicator {
                    id: tciIndicator
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    height: 8
                    width: 8
                    status: tciConnectStatus
                }
            }
        }

        Rectangle {
            id: rectHostaddress
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
            height: 24
            radius: 3
            color: "black"
            border.color: "#4b4b4b"
            enabled: !root.switchOn

            TextInput {
                id: hostAddress
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                text: "localhost:50001"
                color: "#e0e0e0"
                focus: true
                selectByMouse: true
                selectionColor: 'darkgray'
                selectedTextColor: 'white'
                opacity: switchOn ? 0.7 : 1.0
                enabled: !telnetEnable.checked
            }
        }

        Rectangle {
            id: colorPickerWrapper

            height: colorPickerTitle.height + 10

            color: "#2a2a2a"

            Text {
                id: colorPickerTitle

                text: "Spot color: "

                color: "#FFF"

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 5
                }
            }

            Rectangle {
                id: colorPicker

                width: colorPickerTitle.height + 10
                height: colorPickerTitle.height + 10

                MouseArea {
                    onClicked: {
                        colorDialog.open()
                    }

                    anchors {
                        fill: parent
                    }
                }

                anchors {
                    left: colorPickerTitle.right
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
            }

            anchors {
                top: rectHostaddress.bottom
                topMargin: 5
                left: rectHostaddress.left
            }
        }

        ColorDialog {
            id: colorDialog

            title: "Please choose a color"
            onAccepted: {
                colorPicker.color = colorDialog.color
            }
            onRejected: {
                colorDialog.close()
            }
        }
    }

    Rectangle {
        id: connectionRect
        anchors.left: parent.horizontalCenter
        anchors.right: parent.right
        anchors.top: rectTitle.bottom
        anchors.margins: 5
        anchors.rightMargin: 0.5*anchors.margins
        height: 113
        radius: 5
        color: "#2a2a2a"

        Rectangle {
            id: telnetSettingsTitleRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 20
            radius: 5
            color: "#424242"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.verticalCenter
                anchors.bottom: parent.bottom
                color: parent.color
            }

            UI.UIText {
                id: telnetTitle
                anchors.centerIn: parent
                text: "Telnet"
                color: "#e0e0e0"

                UI.UIRoundIndicatorTelnet {
                    id: telnetIndicator
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    height: 8
                    width: 8
                    status: telnetConnectStatus
                }
            }
        }

        Rectangle {
            id: telnetCallsignSettingsRect
            anchors.top: telnetSettingsTitleRect.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right

            UI.UIText {
                id: callsignTitle
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Callsign:"
                color: "#e0e0e0"
            }

            Rectangle {
                id: telnetRectCallsign
                anchors.left: callsignTitle.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 15
                height: 24
                radius: 3
                color: "black"
                border.color: "#4b4b4b"
                enabled: !root.switchOn

                TextInput {
                    id: telnetCallsign
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    color: "#e0e0e0"
                    focus: true
                    selectByMouse: true
                    selectionColor: 'darkgray'
                    selectedTextColor: 'white'
                    opacity: switchOn ? 0.7 : 1.0
                    enabled: !telnetEnable.checked
                    maximumLength: 5
                }
            }
        }

        Rectangle {
            id: telnetHostSettingsRect
            anchors.top: telnetCallsignSettingsRect.bottom
            anchors.topMargin: 26
            anchors.left: parent.left
            anchors.right: parent.right

            UI.UIText {
                id: hostTitle
                width: callsignTitle.width
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Host:"
                color: "#e0e0e0"
            }

            Rectangle {
                id: telnetRectHost
                anchors.left: hostTitle.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 15
                height: 24
                radius: 3
                color: "black"
                border.color: "#4b4b4b"
                enabled: !root.switchOn

                TextInput {
                    id: telnetHost
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    color: "#e0e0e0"
                    focus: true
                    selectByMouse: true
                    selectionColor: 'darkgray'
                    selectedTextColor: 'white'
                    opacity: switchOn ? 0.7 : 1.0
                    enabled: !telnetEnable.checked
            }
        }

        Rectangle {
            id: telnetPortSettingsRect
            anchors.top: telnetHostSettingsRect.bottom
            anchors.topMargin: 26
            anchors.left: parent.left
            anchors.right: parent.right

            UI.UIText {
                id: portTitle
                width: callsignTitle.width
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Port:"
                color: "#e0e0e0"
            }

            Rectangle {
                id: telnetRectPort
                anchors.left: portTitle.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 15
                height: 24
                radius: 3
                color: "black"
                border.color: "#4b4b4b"
                enabled: !root.switchOn

                TextInput {
                    id: telnetPort
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    color: "#e0e0e0"
                    focus: true
                    selectByMouse: true
                    selectionColor: 'darkgray'
                    selectedTextColor: 'white'
                    opacity: switchOn ? 0.7 : 1.0
                    enabled: !telnetEnable.checked
                    validator: IntValidator {
                        bottom: 0
                        top: 65536
                    }
                }
            }
        }
    }
}
}
