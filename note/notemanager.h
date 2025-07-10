#ifndef NOTEMANAGER_H
#define NOTEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariant>

class NoteManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath WRITE setCurrentPath NOTIFY currentPathChanged)

public:
    explicit NoteManager(QObject *parent = nullptr);

    Q_INVOKABLE void saveNotes(const QString &canvasName, const QVariantList &notes);
    Q_INVOKABLE QVariantList loadNotes(const QString &canvasName);

    //打开文件夹选择对话框
    Q_INVOKABLE void selectNewPath();

    // 属性的读写接口
    QString currentPath() const;
    void setCurrentPath(const QString &newCurrentPath);

signals:
    void currentPathChanged();

private:
    //私有成员变量，用于存储当前路径
    QString m_currentPath;
};

#endif // NOTEMANAGER_H
