#include <QApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include "notemanager.h"

int main(int argc, char *argv[])
{

    QApplication app(argc, argv);

    app.setWindowIcon(QIcon(":/new/prefix1/res/notes.ico"));

    NoteManager noteManager;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("noteManager", &noteManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("note", "Main");

    return app.exec();
}
