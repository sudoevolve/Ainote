#include "notemanager.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileDialog>

NoteManager::NoteManager(QObject *parent)
    : QObject{parent}
{
    QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (defaultPath.isEmpty())
        defaultPath = ".";
    setCurrentPath(defaultPath);
}

QString NoteManager::currentPath() const
{
    return m_currentPath;
}

void NoteManager::setCurrentPath(const QString &newCurrentPath)
{
    if (m_currentPath == newCurrentPath)
        return;

    m_currentPath = newCurrentPath;
    emit currentPathChanged();
    qDebug() << "Current path changed to:" << m_currentPath;
}

void NoteManager::selectNewPath()
{
    QString dir = QFileDialog::getExistingDirectory(nullptr, "选择一个新的保存路径", m_currentPath); // 弹出对话框

    if (!dir.isEmpty()) {
        setCurrentPath(dir);
    }
}

void NoteManager::saveNotes(const QString &canvasName, const QVariantList &notes)
{
    QDir canvasDir(m_currentPath + "/" + canvasName);
    if (!canvasDir.exists()) {
        canvasDir.mkpath(".");
    }

    QSet<QString> notesToSaveIds;
    for (const QVariant &noteVariant : notes) {
        notesToSaveIds.insert(noteVariant.toMap()["noteId"].toString());
    }

    QStringList existingFiles = canvasDir.entryList(QStringList() << "*.md", QDir::Files);
    for (const QString &fileName : existingFiles) {
        QString existingId = fileName.left(fileName.lastIndexOf('.'));
        if (!notesToSaveIds.contains(existingId)) {
            canvasDir.remove(fileName);
        }
    }

    QJsonObject metadataObject;
    for (const QVariant &noteVariant : notes) {
        QVariantMap noteMap = noteVariant.toMap();
        QString noteId = noteMap["noteId"].toString();
        QString noteText = noteMap["noteText"].toString();
        double x = noteMap["x"].toDouble();
        double y = noteMap["y"].toDouble();
        double z = noteMap["z"].toDouble();
        QString color = noteMap["noteColor"].toString();

        if (noteId.isEmpty()) continue;

        QFile mdFile(canvasDir.filePath(noteId + ".md"));
        if (mdFile.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
            mdFile.write(noteText.toUtf8());
            mdFile.close();
        }

        QJsonObject noteMetadata;
        noteMetadata["x"] = x;
        noteMetadata["y"] = y;
        noteMetadata["z"] = z;
        noteMetadata["color"] = color;
        metadataObject[noteId] = noteMetadata;
    }

    QFile jsonFile(canvasDir.filePath("metadata.json"));
    if (jsonFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        jsonFile.write(QJsonDocument(metadataObject).toJson());
        jsonFile.close();
    }
}

QVariantList NoteManager::loadNotes(const QString &canvasName)
{
    QVariantList loadedNotes;
    QDir canvasDir(m_currentPath + "/" + canvasName);
    if (!canvasDir.exists()) { return loadedNotes; }

    QFile jsonFile(canvasDir.filePath("metadata.json"));
    if (!jsonFile.open(QIODevice::ReadOnly)) { return loadedNotes; }

    QJsonDocument doc = QJsonDocument::fromJson(jsonFile.readAll());
    jsonFile.close();
    QJsonObject metadataObject = doc.object();

    for (const QString &noteId : metadataObject.keys()) {
        QJsonObject noteMetadata = metadataObject[noteId].toObject();
        QFile mdFile(canvasDir.filePath(noteId + ".md"));
        QString noteText;
        if (mdFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            noteText = mdFile.readAll();
            mdFile.close();
        }
        QVariantMap noteData;
        noteData["noteId"] = noteId;
        noteData["noteText"] = noteText;
        noteData["x"] = noteMetadata["x"].toDouble();
        noteData["y"] = noteMetadata["y"].toDouble();
        noteData["z"] = noteMetadata["z"].toDouble();
        noteData["color"] = noteMetadata["color"].toString();
        loadedNotes.append(noteData);
    }
    return loadedNotes;
}
