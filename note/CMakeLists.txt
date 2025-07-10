cmake_minimum_required(VERSION 3.16)

project(note VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_resources(APP_RESOURCES
    res.qrc
)

qt_add_executable(appnote
    main.cpp
    notemanager.cpp
    notemanager.h
    ${APP_RESOURCES}
)

qt_add_qml_module(appnote
    URI note
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/ColorDot.qml
        qml/StickyNote.qml
        qml/ShadowButton.qml
    SOURCES
        notemanager.h
        notemanager.cpp
)

set_target_properties(appnote PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)


target_link_libraries(appnote
    PRIVATE Qt6::Quick Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appnote
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
