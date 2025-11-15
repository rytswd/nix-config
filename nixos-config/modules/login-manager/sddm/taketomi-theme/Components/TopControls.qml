import QtQuick
import QtQuick.Controls as QQC
import SddmComponents 2.0

Row {
    id: topControls
    spacing: 24

    property alias sessionIndex: session.currentIndex
    property alias sessionControl: session
    property alias layoutControl: layoutBox
    property Item loginButtonControl
    property Item usernameControl

    QQC.ComboBox {
        id: session
        anchors.verticalCenter: parent.verticalCenter
        width: 220
        height: 48
        model: sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex
        font.pointSize: 12

        KeyNavigation.tab: layoutBox
        KeyNavigation.backtab: loginButtonControl

        contentItem: Text {
            leftPadding: 16
            rightPadding: session.indicator.width + session.spacing
            text: session.displayText
            font: session.font
            color: Colors.textPrimary
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: 8
            color: Colors.surfaceDark
            border.color: session.activeFocus ? Colors.accent : Colors.border
            border.width: 1
        }

        popup: QQC.Popup {
            y: session.height + 2
            width: session.width
            implicitHeight: contentItem.implicitHeight + 2
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: session.popup.visible ? session.delegateModel : null
                currentIndex: session.highlightedIndex

                QQC.ScrollIndicator.vertical: QQC.ScrollIndicator { }
            }

            background: Rectangle {
                color: Colors.surfaceDark
                border.color: Colors.border
                border.width: 1
                radius: 8
            }
        }

        delegate: QQC.ItemDelegate {
            width: session.width
            contentItem: Text {
                text: model.name
                color: Colors.textPrimary
                font: session.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                leftPadding: 16
            }
            highlighted: session.highlightedIndex === index
            background: Rectangle {
                color: highlighted ? Colors.border : "transparent"
            }
        }

        indicator: Canvas {
            id: canvas
            x: session.width - width - session.rightPadding - 8
            y: session.topPadding + (session.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: session
                function onPressedChanged() { canvas.requestPaint() }
            }

            onPaint: {
                context.reset()
                context.moveTo(0, 0)
                context.lineTo(width, 0)
                context.lineTo(width / 2, height)
                context.closePath()
                context.fillStyle = Colors.accent
                context.fill()
            }
        }
    }

    QQC.ComboBox {
        id: layoutBox
        anchors.verticalCenter: parent.verticalCenter
        width: 200
        height: 48
        model: keyboard.layouts
        textRole: "longName"
        currentIndex: keyboard.currentLayout
        font.pointSize: 11

        onActivated: keyboard.currentLayout = currentIndex

        KeyNavigation.tab: topControls.usernameControl
        KeyNavigation.backtab: session

        contentItem: Text {
            leftPadding: 12
            rightPadding: layoutBox.indicator.width + layoutBox.spacing
            text: layoutBox.displayText
            font: layoutBox.font
            color: Colors.textPrimary
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: 8
            color: Colors.surfaceDark
            border.color: layoutBox.activeFocus ? Colors.accent : Colors.border
            border.width: 1
        }

        popup: QQC.Popup {
            y: layoutBox.height + 2
            width: layoutBox.width
            implicitHeight: contentItem.implicitHeight + 2
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: layoutBox.popup.visible ? layoutBox.delegateModel : null
                currentIndex: layoutBox.highlightedIndex

                QQC.ScrollIndicator.vertical: QQC.ScrollIndicator { }
            }

            background: Rectangle {
                color: Colors.surfaceDark
                border.color: Colors.border
                border.width: 1
                radius: 8
            }
        }

        delegate: QQC.ItemDelegate {
            width: layoutBox.width
            contentItem: Text {
                text: model.longName
                color: Colors.textPrimary
                font: layoutBox.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }
            highlighted: layoutBox.highlightedIndex === index
            background: Rectangle {
                color: highlighted ? Colors.border : "transparent"
            }
        }

        indicator: Canvas {
            id: layoutCanvas
            x: layoutBox.width - width - layoutBox.rightPadding - 8
            y: layoutBox.topPadding + (layoutBox.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: layoutBox
                function onPressedChanged() { layoutCanvas.requestPaint() }
            }

            onPaint: {
                context.reset()
                context.moveTo(0, 0)
                context.lineTo(width, 0)
                context.lineTo(width / 2, height)
                context.closePath()
                context.fillStyle = Colors.accent
                context.fill()
            }
        }
    }

    Rectangle {
        width: 52
        height: 52
        radius: 26
        color: rebootArea.pressed ? Colors.accentSubtlePressed : (rebootArea.containsMouse ? Colors.accentSubtle : Colors.surfaceLight)
        border.width: 1
        border.color: Colors.borderAccent
        visible: sddm.canReboot

        Text {
            anchors.centerIn: parent
            text: "⟳"
            font.pointSize: 20
            color: Colors.textPrimary
        }

        MouseArea {
            id: rebootArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sddm.reboot()
        }
    }

    Rectangle {
        width: 52
        height: 52
        radius: 26
        color: poweroffArea.pressed ? Colors.accentSubtlePressed : (poweroffArea.containsMouse ? Colors.accentSubtle : Colors.surfaceLight)
        border.width: 1
        border.color: Colors.borderAccent
        visible: sddm.canPowerOff

        Text {
            anchors.centerIn: parent
            text: "⏻"
            font.pointSize: 20
            color: Colors.textPrimary
        }

        MouseArea {
            id: poweroffArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sddm.powerOff()
        }
    }
}
