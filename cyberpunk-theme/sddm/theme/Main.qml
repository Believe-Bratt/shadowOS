// ============================================================================
// ShadowOS SDDM Theme — Cyberpunk
// ============================================================================

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

Item {
    id: root

    // ─── Configuration ───────────────────────────────────────────────────────
    property int sessionIndex: 0
    property int userIndex: 0
    property bool passwordVisible: false

    // ─── Color Palette ────────────────────────────────────────────────────────
    readonly property color bgDark: "#0a0a0f"
    readonly property color bgPanel: "#1a1a2e"
    readonly property color fgLight: "#f0f0ff"
    readonly property color neonCyan: "#00ffff"
    readonly property color neonPurple: "#c54dff"
    readonly property color neonAmber: "#ffbf00"
    readonly property color neonGreen: "#00ff88"

    // ─── Background ───────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: root.bgDark
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0a0a0f" }
            GradientStop { position: 1.0; color: "#1a1a2e" }
        }
    }

    // ─── Animated Grid Background ─────────────────────────────────────────────
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        opacity: 0.15
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = root.neonCyan;
            ctx.lineWidth = 1;
            var gridSize = 40;
            for (var x = 0; x < width; x += gridSize) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
                ctx.stroke();
            }
            for (var y = 0; y < height; y += gridSize) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
        Timer {
            interval: 100; running: true; repeat: true
            onTriggered: gridCanvas.requestPaint()
        }
    }

    // ─── Neon Border Frame ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            color: root.neonCyan
            width: 3
        }
        radius: 10
        layer.enabled: true
        layer.effect: DropShadow {
            color: root.neonCyan
            radius: 20
            samples: 30
            horizontalOffset: 0
            verticalOffset: 0
        }
    }

    // ─── Corner Decorations ────────────────────────────────────────────────────
    Row {
        anchors { left: parent.left; top: parent.top; margins: 20 }
        spacing: 10
        Repeater {
            model: 2
            Rectangle {
                width: 30; height: 3
                color: root.neonCyan
                radius: 2
                layer.enabled: true
                layer.effect: DropShadow { color: root.neonCyan; radius: 8; samples: 16 }
            }
        }
    }
    Row {
        anchors { left: parent.left; top: parent.top; margins: 23 }
        spacing: 10
        Repeater {
            model: 2
            Rectangle {
                width: 3; height: 30
                color: root.neonCyan
                radius: 2
                layer.enabled: true
                layer.effect: DropShadow { color: root.neonCyan; radius: 8; samples: 16 }
            }
        }
    }

    Row {
        anchors { right: parent.right; top: parent.top; margins: 20 }
        spacing: 10
        Repeater {
            model: 2
            Rectangle {
                width: 30; height: 3
                color: root.neonPurple
                radius: 2
                layer.enabled: true
                layer.effect: DropShadow { color: root.neonPurple; radius: 8; samples: 16 }
            }
        }
    }
    Row {
        anchors { right: parent.right; top: parent.top; margins: 23 }
        spacing: 10
        Repeater {
            model: 2
            Rectangle {
                width: 3; height: 30
                color: root.neonPurple
                radius: 2
                layer.enabled: true
                layer.effect: DropShadow { color: root.neonPurple; radius: 8; samples: 16 }
            }
        }
    }

    // ─── Title ─────────────────────────────────────────────────────────────────
    Column {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 60 }
        spacing: 10
        Label {
            text: "SHADOWOS"
            font.pixelSize: 48
            font.bold: true
            color: root.neonCyan
            horizontalAlignment: Text.AlignHCenter
            layer.enabled: true
            layer.effect: DropShadow {
                color: root.neonCyan
                radius: 15
                samples: 30
                horizontalOffset: 0
                verticalOffset: 0
            }
        }
        Label {
            text: "Neon Vanguard Edition"
            font.pixelSize: 16
            color: root.neonPurple
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.9
        }
    }

    // ─── User Selection ────────────────────────────────────────────────────────
    Column {
        id: userColumn
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -80 }
        spacing: 15
        width: 350

        Label {
            text: "USER"
            font.pixelSize: 14
            color: root.neonAmber
            opacity: 0.8
        }

        ComboBox {
            id: userCombo
            model: sddm.users
            currentIndex: root.userIndex
            onActivated: root.userIndex = currentIndex
            width: parent.width
            height: 40
            font.pixelSize: 14
            padding: 10

            background: Rectangle {
                color: root.bgPanel
                border { color: root.neonCyan; width: 2 }
                radius: 6
            }
            contentItem: Text {
                text: userCombo.currentText
                color: root.fgLight
                font: userCombo.font
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
            delegate: ItemDelegate {
                width: parent.width
                highlighted: hovered
                contentItem: Text {
                    text: modelData
                    color: root.fgLight
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                background: Rectangle {
                    color: hovered ? root.neonCyan : root.bgPanel
                    radius: 0
                }
            }
        }
    }

    // ─── Session Selection ─────────────────────────────────────────────────────
    Column {
        id: sessionColumn
        anchors { horizontalCenter: parent.horizontalCenter; top: userColumn.bottom; topMargin: 20 }
        spacing: 15
        width: 350

        Label {
            text: "SESSION"
            font.pixelSize: 14
            color: root.neonAmber
            opacity: 0.8
        }

        ComboBox {
            id: sessionCombo
            model: sddm.sessions
            currentIndex: root.sessionIndex
            onActivated: root.sessionIndex = currentIndex
            width: parent.width
            height: 40
            font.pixelSize: 14
            padding: 10

            background: Rectangle {
                color: root.bgPanel
                border { color: root.neonCyan; width: 2 }
                radius: 6
            }
            contentItem: Text {
                text: sessionCombo.currentText
                color: root.fgLight
                font: sessionCombo.font
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
            delegate: ItemDelegate {
                width: parent.width
                highlighted: hovered
                contentItem: Text {
                    text: modelData
                    color: root.fgLight
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                background: Rectangle {
                    color: hovered ? root.neonCyan : root.bgPanel
                    radius: 0
                }
            }
        }
    }

    // ─── Password Field ────────────────────────────────────────────────────────
    Column {
        id: passwordColumn
        anchors { horizontalCenter: parent.horizontalCenter; top: sessionColumn.bottom; topMargin: 20 }
        spacing: 15
        width: 350
        visible: sddm.currentUser && sddm.currentUser.requirePassword

        TextField {
            id: passwordField
            width: parent.width
            height: 40
            font.pixelSize: 14
            echoMode: root.passwordVisible ? TextInput.Normal : TextInput.Password
            placeholderText: "Password"
            color: root.fgLight
            selectionColor: root.neonCyan
            selectedTextColor: root.bgDark

            background: Rectangle {
                color: root.bgPanel
                border { color: root.neonCyan; width: 2 }
                radius: 6
            }

            // Password visibility toggle
            Button {
                id: eyeButton
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 24; height: 24
                background: null
                icon {
                    source: root.passwordVisible ? "eye-open" : "eye-closed"
                    color: root.neonCyan
                }
                onClicked: root.passwordVisible = !root.passwordVisible
            }
        }
    }

    // ─── Login Button ──────────────────────────────────────────────────────────
    Button {
        id: loginButton
        anchors { horizontalCenter: parent.horizontalCenter; top: passwordColumn.bottom; topMargin: 30 }
        width: 350; height: 50
        text: "LOGIN"
        font.pixelSize: 16
        font.bold: true
        background: Rectangle {
            color: root.neonCyan
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                color: root.neonCyan
                radius: 15
                samples: 30
                horizontalOffset: 0
                verticalOffset: 0
            }
        }
        contentItem: Text {
            text: loginButton.text
            color: root.bgDark
            font: loginButton.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: sddm.login(sddm.currentUser.name, passwordField.text, sessionCombo.currentText)
    }

    // ─── Power Buttons ─────────────────────────────────────────────────────────
    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: 30 }
        spacing: 15
        Button {
            width: 50; height: 50
            background: Rectangle {
                color: root.bgPanel
                border { color: root.neonAmber; width: 2 }
                radius: 25
            }
            icon {
                source: "system-reboot"
                color: root.neonAmber
            }
            onClicked: sddm.reboot()
        }
        Button {
            width: 50; height: 50
            background: Rectangle {
                color: root.bgPanel
                border { color: root.neonRed; width: 2 }
                radius: 25
            }
            icon {
                source: "system-shutdown"
                color: root.neonRed
            }
            onClicked: sddm.powerOff()
        }
    }

    // ─── Clock ─────────────────────────────────────────────────────────────────
    Column {
        anchors { left: parent.left; bottom: parent.bottom; margins: 30 }
        spacing: 5
        Label {
            id: clockLabel
            font.pixelSize: 24
            font.bold: true
            color: root.neonCyan
            text: Qt.formatDateTime(new Date(), "HH:mm:ss")
        }
        Label {
            font.pixelSize: 12
            color: root.neonPurple
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
        }
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "HH:mm:ss")
        }
    }

    // ─── Status Message ────────────────────────────────────────────────────────
    Label {
        id: statusLabel
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 30 }
        font.pixelSize: 12
        color: root.neonAmber
        opacity: sddm.status === SDDM.AuthenticationSuccess ? 0 : 1
        text: {
            switch (sddm.status) {
            case SDDM.AuthenticationError: return "Authentication failed"
            case SDDM.AuthenticationInfo: return sddm.lastMessage
            default: return ""
            }
        }
    }
} 


