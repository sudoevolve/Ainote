import QtQuick
import QtQuick.Effects

// 自定义按钮组件
Item {
    id: root

    // === 外部可配置属性 ===
    property alias text: buttonText.text       // 按钮文本内容
    property color buttonColor: "#ff428587"    // 按钮背景颜色
    property color textColor: "white"          // 文本颜色
    property real radius: 15                   // 圆角半径
    property int fontSize: 16                  // 文本字号（使用 pixelSize）
    property color shadowColor: "#848686"
    property real shadowBlur: 1.0
    property real shadowVerticalOffset: 3
    property real shadowHorizontalOffset: 3
    property bool shadowEnabled: true

    signal clicked()

    transform: Scale {
        id: scaleTransform
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: 1.0
        yScale: 1.0
    }

    MultiEffect {
        source: background
        anchors.fill: background
        shadowEnabled: root.shadowEnabled
        shadowColor: root.shadowColor
        shadowBlur: root.shadowBlur
        shadowVerticalOffset: root.shadowVerticalOffset
        shadowHorizontalOffset: root.shadowHorizontalOffset
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.buttonColor
        radius: root.radius
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        font.pixelSize: root.fontSize
        font.bold: true
        color: root.textColor
    }

    MouseArea {
        anchors.fill: parent

        onPressed: {
            scaleTransform.xScale = 0.96
            scaleTransform.yScale = 0.96
            background.opacity = 0.5
        }

        onReleased: {
            root.clicked()
            background.opacity = 1.0
            springX.restart()
            springY.restart()
        }

        onCanceled: {
            background.opacity = 1.0
            springX.restart()
            springY.restart()
        }
    }

    SpringAnimation {
        id: springX
        target: scaleTransform
        property: "xScale"
        to: 1.0
        spring: 3
        damping: 0.3
    }

    SpringAnimation {
        id: springY
        target: scaleTransform
        property: "yScale"
        to: 1.0
        spring: 3
        damping: 0.3
    }
}
