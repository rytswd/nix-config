import QtQuick

Column {
    id: clockComponent
    spacing: 8

    Text {
        id: clockText
        font.pointSize: 56
        font.weight: Font.ExtraLight
        color: Colors.textPrimary
        text: Qt.formatTime(new Date(), "hh:mm")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }

    Text {
        font.pointSize: 18
        font.weight: Font.Light
        color: Colors.textMuted
        text: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: parent.text = Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")
        }
    }
}
