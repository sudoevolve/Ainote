// ColorDot.qml
import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: colorDot
    width: 30
    height: 30
    radius: width / 2
    color: itemColor
    opacity: 0
    scale: 0
    transformOrigin: Item.Center

    property color itemColor: "transparent"
    property int dotIndex: 0
    property bool paletteVisible: false
    signal dotClicked(color selectedColor)


    state: paletteVisible ? "shown" : ""

    states: [
        State {
            name: "shown"
            PropertyChanges { target: colorDot; opacity: 1.0; scale: 1.0 }
        }
    ]

    transitions: [
        Transition {
            from: ""
            to: "shown"
            SequentialAnimation {
                PauseAnimation { duration: dotIndex * 50 }
                ParallelAnimation {

                    NumberAnimation {
                        target: colorDot; properties: "opacity"
                        duration: 300; easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: colorDot; properties: "scale"
                        duration: 350; easing.type: Easing.OutBack
                    }
                }
            }
        },
        Transition {
            from: "shown"
            to: ""
            NumberAnimation {
                properties: "opacity, scale"; duration: 50
                easing.type: Easing.InQuad
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: colorDot.opacity === 1.0
        onClicked: colorDot.dotClicked(itemColor)
    }

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 15
        samples: 20
        color: "#848686"
        horizontalOffset: 3
        verticalOffset: 3
    }
}
