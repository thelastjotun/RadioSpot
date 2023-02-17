import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtWebSockets
import Qt.labs.platform
import "controls" as UI

ApplicationWindow {
    id: root

    // параметров по умолчанию
    width: 650
    height: 600

    minimumWidth:  600
    minimumHeight: 300

    // Наложение стиля
    background: Rectangle {
        color: "#222222"
    }

    function restoreConfig() {
        let config = main.loadConfig()
        for (let i in config)
            model.addNew(config[i])
    }

    function saveConfig() {
        let config = []
        for (let i = 0; i < spotView.model.count; ++i)
            config.push(spotView.model.get(i))
        main.saveConfig(config)
    }

    function setConfig(config) {
        let data = JSON.stringify(config)
        if (data === "{}")
            return

        // выключаем существующие соединения
        for (let j = 0; j < model.count; j++) {
            spotView.model.get(j).switchOnVal = false
        }

        main.removeAll()
        model.clear()

        for (let i in config)
            model.addNew(config[i])
    }

    function getConfig() {
        let config = []
        for (let i = 0; i < spotView.model.count; ++i)
            config.push(spotView.model.get(i))
        return config
    }

    // восстанавливаем настройки
    Component.onCompleted: restoreConfig()

    // список подключений
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: toolBar.top
        anchors.margins: 8
        anchors.bottomMargin: 0
        radius: 5
        color: "black"
        border.color: "#4b4b4b"
        border.width: 1

        ListView {
            id: spotView
            anchors.fill: parent
            anchors.margins: 5
            clip: true
            snapMode: ListView.SnapToItem
            cacheBuffer: 20000
            spacing: 4
            property bool visibleScrollBar: contentHeight > height
            property int currentActiveWindow: 0

            signal updateWidth(int val)

            delegate: Delegate {
                id: spotObj

                // инициализация свойств
                required property int    index
                required property double uuidVal
                required property bool   switchOnVal
                required property string tciAddressVal
                required property string configTitleVal
                required property string hostVal
                required property string portVal
                required property string callsignVal

                currentIndex: index
                uuid:         uuidVal
                switchOn:     switchOnVal
                address:      hostVal + ":" + portVal
                configTitle:  configTitleVal
                tciHost:      tciAddressVal
                telnetHostD:  hostVal
                telnetPortD:  portVal
                callsign:     callsignVal

                onUuidChanged:        spotView.model.get(index).uuidVal = uuid
                onConfigTitleChanged: spotView.model.get(index).configTitleVal = configTitle
                onTelnetHostDChanged: spotView.model.get(index).hostVal = telnetHostD
                onTelnetPortDChanged: spotView.model.get(index).portVal = telnetPortD
                onCallsignChanged:    spotView.model.get(index).callsignVal = callsign
                onTciHostChanged:     spotView.model.get(index).tciAddressVal = tciHost

                // инициализация геометрии
                state: spotView.visibleScrollBar ? "visibleScrollBar" : "invisibleScrollBar"

                // обработка событий
                onSwitchOnChanged: {
                    spotView.model.get(index).switchOnVal = switchOn

                    if (switchOn) {
                        main.connectToHost(uuid, address, callsignVal)
                    } else {
                        main.disconnectFromHost(uuid)
                    }

                    // обновляем конфигурацию
                    main.updateConnection(uuid, spotView.model.get(index))
                }

                onRemove: {
                    main.removeConnection(uuid)
                    spotView.model.remove(index)
                }

                // определяем состояния
                states: [
                    State {
                        name: "visibleScrollBar"
                        PropertyChanges {
                            target: spotObj
                            width: spotView.width - 20
                        }
                    },
                    State {
                        name: "invisibleScrollBar"
                        PropertyChanges {
                            target: spotObj
                            width: spotView.width
                        }
                    }
                ]

                // задаём анимацию перехода между состояниями
                transitions: [
                    Transition {
                        from: "*"; to: "*";
                        NumberAnimation { properties: "width"; duration: 200; }
                    }
                ]
            }

            model: ListModel {
                id: model

                function addNew(config) {
                    // добавляем в список
                    model.append(config)
                    // создаём синхронизацию с уникальным ключом
                    main.createConnection(config.uuidVal, config.index)
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }
    }

    // инструментальная панель (снизу)
    Item {
        id: toolBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 46

        UI.UIImageButton {
            id: addButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8
            height: 30
            width: height
            image.height: 24
            image.width: image.height
            pressSource: "qrc:/qml/svg/add.svg"
            unpressSource: "qrc:/qml/svg/add.svg"
            useToolTip: true
            toolTipObj.text: qsTr("Add new synchronization")

            onClicked: {
                // генерируем уникальный ключ
                let uuid = main.generateUuid()
                //
                let spotIndex = spotView.model.count

                // добавляем в список
                model.append({
                                 uuidVal: uuid,
                                 switchOnVal: false,
                                 tciAddressVal: "localhost:50001",
                                 configTitleVal: "Title [" + (spotIndex + 1) + "]",
                                 hostVal: "dxc.nc7j.com",
                                 portVal: "7373",
                                 callsignVal: "K3KPG"
                             })
                // создаём синхронизацию с уникальным ключом
                main.createConnection(uuid, spotView.model.get(model.get(model.count - 1)))
            }

            DropShadow {
                anchors.fill: parent.image
                horizontalOffset: 1
                verticalOffset: 1
                radius: 8.0
                color: "black"
                source: parent.image
            }

            ColorOverlay {
                id: addColorOverley
                anchors.fill: parent.image
                source: parent.image
                color: parent.pressed ? "#818181" : "#b0b0b0"
            }
        }

        UI.UIImageButton {
            id: removeButton

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            unpressSource: "qrc:/qml/svg/remove.svg"
            anchors.leftMargin: 8
            height: 30
            width: height
            image.height: 24
            image.width: image.height
            useToolTip: true
            toolTipObj.text: qsTr("Remove all connections")

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
                text: qsTr("Do you really want to delete all connections?")

                onYesClicked: {
                    // Выключаем все соединения
                    for (let i = 0; i < model.count; i++) {
                        spotView.model.get(i).switchOnVal = false
                    }
                    model.clear()
                    main.removeAll()
                }
            }
        }

        UI.UIImageButton {
            id: exportButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            height: 30
            width: height
            image.height: 28
            image.width: image.height
            useToolTip: true
            toolTipObj.text: qsTr("Export configuration")

            pressSource: "qrc:/qml/svg/export.svg"
            unpressSource: "qrc:/qml/svg/export.svg"

            DropShadow {
                anchors.fill: parent.image
                horizontalOffset: 1
                verticalOffset: 1
                radius: 8.0
                color: "black"
                source: parent.image
            }

            ColorOverlay {
                anchors.fill: parent.image
                source: parent.image
                color: parent.pressed ? "#818181" : "#b0b0b0"
            }

            onClicked: main.exportConfig(root.getConfig())
        }

        UI.UIImageButton {
            id: importButton
            anchors.left: exportButton.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            height: 30
            width: height
            image.height: 28
            image.width: image.height
            useToolTip: true
            toolTipObj.text: qsTr("Import configuration")

            pressSource: "qrc:/qml/svg/import.svg"
            unpressSource: "qrc:/qml/svg/import.svg"

            Image {
                id: importImg
                anchors.centerIn: parent
                source: "qrc:/qml/svg/import.svg"
                sourceSize.width: width
                sourceSize.height: height
                anchors.fill: parent
                anchors.margins: 2
            }

            DropShadow {
                anchors.fill: parent.image
                horizontalOffset: 1
                verticalOffset: 1
                radius: 8.0
                color: "black"
                source: parent.image
            }

            ColorOverlay {
                anchors.fill: parent.image
                source: parent.image
                color: parent.pressed ? "#818181" : "#b0b0b0"
            }

            onClicked: root.setConfig(main.importConfig())
        }
    }
}
