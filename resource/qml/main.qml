import QtQuick
import QtQuick.Controls
import Qt.labs.platform

QtObject {
    id: root

    property var mainWindow: MainWindow {
        id: window

        visible: true

        onClosing: {
            if (!tray.readyToClose)
                tray.showMessage(main.applicationName() + " " + main.applicationVersion(),
                                 qsTr("The program is hidden to the system tray and continues to work."))
        }
    }

    property var systemTray: SystemTrayIcon {
        id: tray

        tooltip: main.applicationName()
        visible: true
        icon.source: "qrc:/logo_tray.png"

        property bool readyToClose: false

        onActivated: {
            window.show()
            window.requestActivate()
        }

        menu: Menu {
            MenuItem {
                text: qsTr("Show")
                onTriggered: {
                    window.show()
                    window.requestActivate()
                }
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Quit")
                onTriggered: {
                    tray.readyToClose = true
                    // сохраняем настройки
                    window.saveConfig()
                    // закрываем программу
                    window.close()
                    tray.visible = false
                    main.onQuit()
                }
            }
        }
    }
}
