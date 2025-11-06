import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    width: 640
    height: 480

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            password.text = ""
            password.focus = true
        }
    }

    // Background Image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // Overlay for dimming
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.3
    }

    // Login Container
    Rectangle {
        anchors.centerIn: parent
        width: 360
        height: 380
        color: "#E6FFFFFF"
        radius: 16

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 80

            // Welcome text
            Text {
                width: parent.width
                text: "Welcome"
                font.pixelSize: 28
                font.weight: Font.Light
                color: "#1A1A1A"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { height: 8 }

            // Username field
            TextField {
                id: username
                width: parent.width
                height: 48
                placeholderText: "Username"
                text: userModel.lastUser
                font.pixelSize: 15
                color: "#1A1A1A"
                placeholderTextColor: "#999999"

                background: Rectangle {
                    color: "#FFFFFF"
                    radius: 8
                    border.color: username.activeFocus ? "#4A90E2" : "#E0E0E0"
                    border.width: 1
                }

                leftPadding: 16
                rightPadding: 16

                Keys.onReturnPressed: password.focus = true
            }

            // Password field
            TextField {
                id: password
                width: parent.width
                height: 48
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.pixelSize: 15
                color: "#1A1A1A"
                placeholderTextColor: "#999999"

                background: Rectangle {
                    color: "#FFFFFF"
                    radius: 8
                    border.color: password.activeFocus ? "#4A90E2" : "#E0E0E0"
                    border.width: 1
                }

                leftPadding: 16
                rightPadding: 16

                Keys.onReturnPressed: {
                    sddm.login(username.text, password.text, session.currentIndex)
                }

                Component.onCompleted: {
                    if (username.text !== "")
                        password.focus = true
                    else
                        username.focus = true
                }
            }

            // Session selector
            ComboBox {
                id: session
                width: parent.width
                height: 48
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                font.pixelSize: 15

                background: Rectangle {
                    color: "#FFFFFF"
                    radius: 8
                    border.color: session.activeFocus ? "#4A90E2" : "#E0E0E0"
                    border.width: 1
                }

                contentItem: Text {
                    text: session.displayText
                    color: "#1A1A1A"
                    font: session.font
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 16
                }

                delegate: ItemDelegate {
                    width: session.width
                    contentItem: Text {
                        text: model.name
                        color: "#1A1A1A"
                        font: session.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: session.highlightedIndex === index
                }

                popup: Popup {
                    y: session.height + 4
                    width: session.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 4

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: session.popup.visible ? session.delegateModel : null
                        currentIndex: session.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        color: "#FFFFFF"
                        radius: 8
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                }
            }

            Item { height: 4 }

            // Login button
            Button {
                width: parent.width
                height: 48
                text: "Sign In"
                font.pixelSize: 15
                font.weight: Font.Medium

                background: Rectangle {
                    color: parent.pressed ? "#357ABD" : (parent.hovered ? "#5AA3E8" : "#4A90E2")
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }

                onClicked: {
                    sddm.login(username.text, password.text, session.currentIndex)
                }
            }
        }
    }

    // Power controls
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 12

        Button {
            width: 44
            height: 44
            text: "\u27F3"
            font.pixelSize: 20
            visible: sddm.canReboot
            onClicked: sddm.reboot()

            background: Rectangle {
                color: parent.pressed ? "#99FFFFFF" : (parent.hovered ? "#CCFFFFFF" : "#B3FFFFFF")
                radius: 22
            }

            contentItem: Text {
                text: parent.text
                color: "#1A1A1A"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
            }
        }

        Button {
            width: 44
            height: 44
            text: "\u23FB"
            font.pixelSize: 20
            visible: sddm.canPowerOff
            onClicked: sddm.powerOff()

            background: Rectangle {
                color: parent.pressed ? "#99FFFFFF" : (parent.hovered ? "#CCFFFFFF" : "#B3FFFFFF")
                radius: 22
            }

            contentItem: Text {
                text: parent.text
                color: "#1A1A1A"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
            }
        }
    }
}
