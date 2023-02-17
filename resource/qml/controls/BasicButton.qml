import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

T.Button {
    id: control

    //readonly property bool __nativeBackground: background instanceof NativeStyle.StyleItem

    // Since QQuickControl will subtract the insets from the control size to
    // figure out the background size, we need to reverse that here, otherwise
    // the control ends up too big.
    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
    implicitHeight: implicitBackgroundHeight + topInset + bottomInset

    leftPadding: 5
    rightPadding: 5
    topPadding: 5
    bottomPadding: 5

    background: Rectangle {
        color: control.checked || control.down ? "gray" : "black"
    }

    icon.width: 24
    icon.height: 24
    icon.color: control.checked
                || control.highlighted ? control.palette.brightText : control.flat
                                         && !control.down ? (control.visualFocus ? control.palette.highlight : control.palette.windowText) : control.palette.buttonText

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: control.flat
               && !control.down ? (control.visualFocus ? control.palette.highlight : control.palette.windowText) : control.palette.buttonText
    }
}
