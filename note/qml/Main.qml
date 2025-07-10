import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

// 主窗口
ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 720
    title: "Aino"
    color: "#f0f0f0"

    property string currentCanvasName: "MyNotes"
    property bool isPaletteVisible: false
    property var activeNotes: []
    property var noteComponent: null

    // 调色板颜色模型
    ListModel {
        id: colorModel
        ListElement { colorValue: "#ffdd57" }
        ListElement { colorValue: "#ff6961" }
        ListElement { colorValue: "#77dd77" }
        ListElement { colorValue: "#aec6cf" }
        ListElement { colorValue: "#f4f0e0" }
    }

    // --- 启动时与路径变化时的逻辑 ---
    Component.onCompleted: {
        noteComponent = Qt.createComponent("StickyNote.qml")
        if (noteComponent.status === Component.Error) {
            console.log("组件加载失败:", noteComponent.errorString()); return;
        }
        loadNotesAndCreate()
    }

    Connections {
        target: noteManager
        function onCurrentPathChanged() {
            clearAllNotes()
            loadNotesAndCreate()
        }
    }


    // --- JS 函数 ---
    function loadNotesAndCreate() {
        console.log("Loading notes from path:" + noteManager.currentPath + "/" + root.currentCanvasName)
        var loadedNotes = noteManager.loadNotes(root.currentCanvasName)
        if (loadedNotes && loadedNotes.length > 0) {
            for (let i = 0; i < loadedNotes.length; i++) {
                createNoteFromData(loadedNotes[i])
            }
        }
    }

    function clearAllNotes() {
        while (activeNotes.length > 0) {
            let note = activeNotes.pop()
            note.destroy()
        }
    }

    function createNote(noteColor, sourceDot) {
        if (noteComponent.status !== Component.Ready) { return }
        var startPos = sourceDot.mapToItem(noteCanvas, 0, 0)
        var noteFinalWidth = 280, noteFinalHeight = 280
        var finalX = canvasFlickable.contentX + Math.random() * Math.max(0, canvasFlickable.width - noteFinalWidth)
        var finalY = canvasFlickable.contentY + Math.random() * Math.max(0, canvasFlickable.height - noteFinalHeight)
        var note = noteComponent.createObject(noteCanvas, {
            noteId: "note_" + Date.now(), noteColor, finalX, finalY,
            x: startPos.x, y: startPos.y, width: sourceDot.width, height: sourceDot.height,
            opacity: 0.0, z: activeNotes.length + 1
        })
        if (note) {
            activeNotes.push(note)
            note.state = "expanded"
            note.deleteRequested.connect(() => deleteNote(note))
        }
    }

    function createNoteFromData(noteData) {
        if (noteComponent.status !== Component.Ready) return;
        var note = noteComponent.createObject(noteCanvas, {
            noteId: noteData.noteId, noteText: noteData.noteText,
            noteColor: noteData.noteColor, x: noteData.x, y: noteData.y, z: noteData.z,
            state: "expanded", opacity: 1.0, scale: 1.0
        })
        if (note) {
            activeNotes.push(note)
            note.deleteRequested.connect(() => deleteNote(note))
        }
    }

    function deleteNote(noteToDelete) {
        if (!noteToDelete) return
        const index = activeNotes.indexOf(noteToDelete)
        if (index > -1) activeNotes.splice(index, 1)
        noteToDelete.closingAnimation.start()
        noteToDelete.destroy(150)
    }

    // --- 左侧控制面板 ---
    Rectangle {
        id: controlPanel
        width: Math.max(90, Math.min(150, root.width * 0.2)); color: "#e0e0e0"
        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left

        // 顶部控件
        Rectangle {
            id: addButton
            width: Math.max(50, Math.min(70, controlPanel.width * 0.6)); height: width; radius: width / 2; color: "#5cb85c"
            anchors.top: parent.top; anchors.topMargin: 20; anchors.horizontalCenter: parent.horizontalCenter
            Text { text: "+"; font.pixelSize: addButton.width * 0.6; color: "white"; anchors.centerIn: parent; rotation: isPaletteVisible ? 45 : 0; Behavior on rotation { NumberAnimation { duration: 300 } } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: isPaletteVisible = !isPaletteVisible }
            layer.enabled: true; layer.effect: DropShadow { radius: 15; samples: 20; color: "#848686"; horizontalOffset: 3; verticalOffset: 3 }
        }
        Column {
            id: colorPalette
            anchors.top: addButton.bottom; anchors.topMargin: 20; anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10; visible: isPaletteVisible
            Repeater {
                model: colorModel
                delegate: ColorDot {
                    itemColor: model.colorValue; dotIndex: index; paletteVisible: colorPalette.visible
                    width: Math.max(30, Math.min(50, controlPanel.width * 0.5)); height: width; radius: width / 2
                    onDotClicked: (selectedColor) => { createNote(selectedColor, this) }
                }
            }
        }

        // 底部控件
        Column {
            id: bottomControls
            anchors.bottom: parent.bottom; anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9; spacing: 10

            Text { text: "保存路径:"; font.pixelSize: 12; color: "#555" }
            Text {
                width: parent.width
                text: noteManager.currentPath
                font.pixelSize: 11; color: "#333"; font.bold: true
                textFormat: Text.PlainText; elide: Text.ElideLeft
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { Qt.copyToClipboard(noteManager.currentPath); console.log("Path copied!") }
                }
            }
            Item { width: 1; height: 10 }

            Text { text: "画布名称"; font.bold: true; color: "#333"; anchors.horizontalCenter: parent.horizontalCenter }
            TextField {
                id: canvasNameInput
                width: parent.width; text: root.currentCanvasName; placeholderText: "输入名称..."; horizontalAlignment: Text.AlignHCenter
                onEditingFinished: { root.currentCanvasName = text }
            }

            ShadowButton {
                width: parent.width; height: 35; text: "更改路径..."; fontSize: 13; radius: 8
                buttonColor: "#6c757d"
                onClicked: { noteManager.selectNewPath() }
            }
            Item { width: 1; height: 5 }
            ShadowButton {
                id: saveButton
                width: parent.width; height: 40; text: "保存进度"; fontSize: 14; radius: 8; buttonColor: "#007BFF"
                onClicked: {
                    console.log("Save button clicked! Gathering note data...")
                    let notesToSave = []
                    for (let i = 0; i < activeNotes.length; i++) {
                        let note = activeNotes[i]
                        let noteData = {
                            "noteId": note.noteId, "noteText": note.noteText,
                            "x": note.x, "y": note.y, "z": note.z,
                            "noteColor": note.noteColor.toString()
                        }
                        notesToSave.push(noteData)
                    }
                    noteManager.saveNotes(root.currentCanvasName, notesToSave)
                    console.log(notesToSave.length + " notes data sent to C++ for saving.")
                }
            }
        }
    }

    // --- 滚动画布 ---
    Flickable {
        id: canvasFlickable
        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: controlPanel.right; anchors.right: parent.right
        clip: true; boundsBehavior: Flickable.StopAtBounds

        onWidthChanged: { noteCanvas.width = Math.max(3000, width) }
        onHeightChanged: { noteCanvas.height = Math.max(2000, height) }

        MouseArea {
            anchors.fill: parent; propagateComposedEvents: true
            onClicked: (mouse) => { if (isPaletteVisible) { isPaletteVisible = false; mouse.accepted = true } }
        }

        Item {
            id: noteCanvas
            Rectangle { anchors.fill: parent; color: "#fafafa"; border.color: "#e0e0e0" }
        }
        contentWidth: noteCanvas.width
        contentHeight: noteCanvas.height
    }
}
