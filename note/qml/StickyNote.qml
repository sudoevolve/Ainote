import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

FocusScope {
    id: noteRoot
    width: 280
    height: 280
    scale: 0.0

    // --- 属性与信号 ---
    property string noteId: ""
    property color noteColor: "#ffdd57"
    property string noteText: ""
    property real finalX: 100
    property real finalY: 100
    signal deleteRequested
    property alias closingAnimation: closingAnimation

    ParallelAnimation {
        id: closingAnimation
        NumberAnimation { target: noteRoot; properties: "opacity, scale"; to: 0.0; duration: 150; easing.type: Easing.InQuad }
    }

    state: ""
    states: [
        State {
            name: "expanded"
            PropertyChanges { target: noteRoot; width: 280; height: 280; opacity: 1.0; scale: 1.0 }
            PropertyChanges { target: background; radius: 15 }
        }
    ]

    transitions: [
        Transition {
            from: ""
            to: "expanded"
            ParallelAnimation {
                SpringAnimation { target: noteRoot; property: "x"; to: finalX; spring: 2.5; damping: 0.3 }
                SpringAnimation { target: noteRoot; property: "y"; to: finalY; spring: 2.5; damping: 0.3 }
                SpringAnimation { target: noteRoot; property: "scale"; to: 1.0; spring: 3.0; damping: 0.4 }
                NumberAnimation { target: noteRoot; properties: "width, height, opacity"; duration: 400; easing.type: Easing.OutQuad }
                NumberAnimation { target: background; property: "radius"; duration: 400; easing.type: Easing.OutQuad }
            }
        }
    ]

    Rectangle {
        id: background
        anchors.fill: parent
        radius: width / 2
        color: noteColor
        border.color: Qt.darker(noteColor, 1.2)
        border.width: noteRoot.activeFocus ? 2 : 1
        scale: dragArea.drag.active ? 1.05 : 1.0
        Behavior on scale { NumberAnimation { duration: 150 } }
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 15; samples: 20; color: "#80000000"
            horizontalOffset: 3; verticalOffset: 3
        }
    }

    TextArea {
        id: editor
        anchors.fill: background
        anchors.margins: 10
        text: noteRoot.noteText
        onTextChanged: noteRoot.noteText = text
        placeholderText: "输入内容..."
        font.pixelSize: 16
        wrapMode: Text.Wrap
        background: null
        focus: true
    }

    MouseArea {
        id: dragArea
        anchors.fill: background
        drag.target: noteRoot
        drag.axis: Drag.XAndYAxis
        hoverEnabled: true
        onPressed: noteRoot.z = 999
        onClicked: noteRoot.forceActiveFocus()
    }

    Rectangle {
        id: deleteButton
        width: 24; height: 24
        radius: 12
        color: "#e74c3c"
        anchors.top: background.top
        anchors.right: background.right
        anchors.margins: -8
        visible: dragArea.containsMouse
        scale: mouseArea.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        Text {
            text: "×"; color: "white"; font.bold: true; font.pixelSize: 18
            anchors.centerIn: parent
            y: parent.height / 2 - height / 2 - 1
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: noteRoot.deleteRequested()
        }
    }

}
