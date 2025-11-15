import QtQuick
import QtQuick.Effects

Rectangle {
    id: avatarContainer
    width: 240
    height: 240
    radius: 120
    color: Colors.surface
    border.width: 3
    border.color: Colors.accent

    property string username: ""

    Image {
        id: avatarImage
        anchors.centerIn: parent
        width: 228
        height: 228
        source: "file:///var/lib/AccountsService/icons/" + username
        fillMode: Image.PreserveAspectCrop
        smooth: true
        antialiasing: true
        asynchronous: true
        visible: false
    }

    Item {
        id: avatarMask
        anchors.centerIn: parent
        width: 228
        height: 228
        layer.enabled: true
        layer.smooth: true
        layer.textureSize: Qt.size(228, 228)
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: 114
            color: "black"
            antialiasing: true
        }
    }

    MultiEffect {
        anchors.centerIn: parent
        width: 228
        height: 228
        source: avatarImage
        maskEnabled: true
        maskSource: avatarMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        visible: avatarImage.status === Image.Ready
    }

    Text {
        anchors.centerIn: parent
        text: username.charAt(0).toUpperCase()
        font.pointSize: 84
        font.weight: Font.Medium
        color: Colors.textPrimary
        visible: avatarImage.status !== Image.Ready
    }
}
