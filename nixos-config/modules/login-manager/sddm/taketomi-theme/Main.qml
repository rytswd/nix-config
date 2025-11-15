import QtQuick
import QtQuick.Effects
import SddmComponents 2.0
import "Components"

Rectangle {
    id: root
    anchors.fill: parent

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            loginForm.passwordText = ""
            loginForm.forceActiveFocus()
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

    // Gradient overlay
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#30000000" }
            GradientStop { position: 1.0; color: "#50000000" }
        }
    }

    // Clock
    Clock {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 60
        anchors.topMargin: 50
    }

    // Blurred background source for login box
    ShaderEffectSource {
        id: blurSource
        sourceItem: backgroundImage
        anchors.fill: loginBox
        sourceRect: Qt.rect(loginBox.x, loginBox.y, loginBox.width, loginBox.height)
        visible: false
    }

    // Login box with blur
    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -30
        width: 520
        height: 580
        radius: 20
        color: "#35000000"
        border.width: 1
        border.color: Colors.borderAccent
        clip: true

        MultiEffect {
            anchors.fill: parent
            source: blurSource
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            saturation: 0.7
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colors.surfaceDark
        }

        LoginForm {
            id: loginForm
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 60
            usernameText: userModel.lastUser
            sessionControl: topControls.sessionControl
            layoutControl: topControls.layoutControl
            onLoginRequested: function(user, pass, sessionIdx) {
                sddm.login(user, pass, sessionIdx)
            }
        }
    }

    // Avatar
    Avatar {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: loginBox.top
        anchors.bottomMargin: -150
        username: userModel.lastUser
        z: 10
    }

    // Top right controls
    TopControls {
        id: topControls
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 50
        anchors.rightMargin: 60
        loginButtonControl: loginForm.children[loginForm.children.length - 2]
        usernameControl: loginForm.children[2]
    }
}
