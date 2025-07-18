# QML 动态便签板 (QML Dynamic Sticky Notes)

![运行演示](Desktop%202025.07.10%20-%2022.31.20.02.gif)


这是一款使用 **Qt 6**、**QML** 和 **C++** 构建的现代化桌面便签应用程序。

---

## ✨ 主要功能

### 界面与交互 (UI & Interaction)

* **动态创建便签**: 点击“+”号展开多彩的调色板，选择颜色即可在画布上创建新便签。
* **流畅的动画效果**:
    * 便签创建时，带有“弹性”效果的弹出动画 (`SpringAnimation`)。
    * 调色板展开与收起时，颜色点带有延迟的、依次出现的动画。
    * 删除便签时，有平滑的淡出与缩小动画。
    * 拖动便签时，有轻微的放大效果，提供即时反馈。
* **自由布局**: 使用鼠标随意拖动便签，在无限大的画布上安排你的想法。
* **实时编辑**: 直接在便签上进行文本输入和修改。
* **智能UI**:
    * 鼠标悬浮在便签上时，才会显示删除按钮。
    * 当调色板展开时，“+”号会平滑旋转为“×”号。
    * 点击画布空白区域可以自动收起调色板。

### 数据与存储 (Data & Storage)

* **C++后端驱动**: 核心的存取逻辑由 C++ 编写的 `NoteManager` 类处理，性能高效且稳定。
* **持久化存储**: 关闭应用后所有便签（包括内容、位置、颜色）都会被自动保存，下次打开时完美恢复。
* **结构化数据**:
    * 每个便签的内容被保存为独立的 `.md` (Markdown) 文件。
    * 所有便签的位置、颜色等元数据被统一存储在 `metadata.json` 文件中。
    * 每个“画布”的数据被存储在独立的文件夹中。
* **自定义存储路径**:
    * 用户可以在界面上清晰地看到当前的保存路径。
    * 提供“更改路径”功能，用户可以通过系统的文件对话框选择任意文件夹作为新的保存位置。
    * 当路径更改后，应用会自动刷新，并从新路径加载便签。

---

## 🛠️ 技术栈

* **框架**: Qt 6 (本项目在 Qt 6.8+ 上开发测试)
* **语言**:
    * **QML**: 用于构建全部的用户界面和动画效果。
    * **C++**: 用于实现后端业务逻辑，如文件读写、JSON处理、系统对话框调用等。
* **构建系统**: CMake
* **核心模块**: `QtQuick`, `QtWidgets`

---

## 🚀 如何构建

本项目使用 Qt Creator 作为推荐的 IDE。

1.  **先决条件**:
    * Qt 6.8 或更高版本
    * 支持 C++17 的编译器 (MSVC, GCC, Clang 等)
    * CMake
2.  **克隆仓库**:
    ```bash
    git clone [你的仓库URL]
    ```
3.  **打开项目**:
    * 启动 Qt Creator。
    * 选择 `文件` -> `打开文件或项目...`，然后选择项目中的 `CMakeLists.txt` 文件。
4.  **配置与构建**:
    * 选择一个合适的构建套件 (Kit)。
    * 点击左下角的“锤子”图标进行构建，或点击“绿色三角”直接运行。

---

## 📂 项目结构

```
note/
├── res/                  # 存放所有资源文件
├── qml/                  # 存放所有 .qml 组件文件
│   ├── Main.qml
│   ├── StickyNote.qml
│   ├── ColorDot.qml
│   └── ShadowButton.qml
├── notemanager.h         # C++ 后端 - 头文件
├── notemanager.cpp       # C++ 后端 - 实现文件
├── main.cpp              # C++ 主程序入口
├── CMakeLists.txt        # 项目构建配置文件
└── res.qrc               # Qt 资源文件 (如图标等)
```

---

## 🔮 功能预告


* [ ] **便签搜索功能**: 快速过滤和查找便签。
* [ ] **置顶功能**: 将重要的便签固定在最顶层。
* [ ] **多画布管理**: 在UI上实现对不同画布（文件夹）的切换、新建和删除。
* [ ] **富文本支持**: 允许用户修改字体、颜色、添加列表等。
* [ ] **自定义主题**: 黑夜模式、更多主题预设等。
---

## 📄 开源许可

本项目采用 [MIT](https://choosealicense.com/licenses/mit/) 许可。

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This project is developed based on the Qt open source framework, which is licensed under the LGPL 3.0 (or GPL depending on Qt version). For more information about Qt licensing, visit [https://www.qt.io/licensing](https://www.qt.io/licensing).
