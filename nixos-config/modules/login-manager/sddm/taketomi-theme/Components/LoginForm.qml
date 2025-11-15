import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: loginForm
    spacing: 18

    property alias usernameText: username.text
    property alias passwordText: password.text
    property Item sessionControl
    property Item layoutControl

    signal loginRequested(string user, string pass, int sessionIdx)

    Item { Layout.preferredHeight: 110 }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "Welcome"
        font.pointSize: 26
        font.weight: Font.Light
        color: Colors.textPrimary
    }

    Item { Layout.preferredHeight: 12 }

    TextField {
        id: username
        Layout.fillWidth: true
        Layout.preferredHeight: 56
        placeholderText: "Username"
        font.pointSize: 13
        color: Colors.textPrimary
        placeholderTextColor: Colors.textSecondary
        leftPadding: 20
        rightPadding: 20

        KeyNavigation.tab: password
        KeyNavigation.backtab: layoutControl

        background: Rectangle {
            radius: 10
            color: Colors.surfaceLight
            border.width: 1
            border.color: username.activeFocus ? Colors.accent : Colors.border
        }

        Keys.onReturnPressed: password.forceActiveFocus()

        Component.onCompleted: {
            if (text === "") {
                forceActiveFocus()
            }
        }
    }

    TextField {
        id: password
        Layout.fillWidth: true
        Layout.preferredHeight: 56
        placeholderText: "Password"
        echoMode: TextInput.Password
        font.pointSize: 13
        color: Colors.textPrimary
        placeholderTextColor: Colors.textSecondary
        leftPadding: 20
        rightPadding: 20

        KeyNavigation.tab: loginButton
        KeyNavigation.backtab: username

        background: Rectangle {
            radius: 10
            color: Colors.surfaceLight
            border.width: 1
            border.color: password.activeFocus ? Colors.accent : Colors.border
        }

        Keys.onReturnPressed: loginForm.loginRequested(username.text, password.text, sessionControl.currentIndex)

        Component.onCompleted: {
            if (username.text !== "") {
                forceActiveFocus()
            }
        }
    }

    Item { Layout.preferredHeight: 12 }

    Rectangle {
        id: loginButton
        Layout.fillWidth: true
        Layout.preferredHeight: 54
        radius: 10
        color: loginButtonArea.pressed ? Colors.accentPressed : (loginButtonArea.containsMouse ? Colors.accentHover : Colors.accent)
        focus: true

        KeyNavigation.tab: sessionControl
        KeyNavigation.backtab: password

        Text {
            anchors.centerIn: parent
            text: "Login"
            font.pointSize: 14
            font.weight: Font.Medium
            color: Colors.textPrimary
        }

        MouseArea {
            id: loginButtonArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: loginForm.loginRequested(username.text, password.text, sessionControl.currentIndex)
        }

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                loginForm.loginRequested(username.text, password.text, sessionControl.currentIndex)
                event.accepted = true
            }
        }
    }

    Item { Layout.preferredHeight: 24 }
}
