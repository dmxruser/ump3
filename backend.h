#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <QFileDialog>
#include <QUrl>
#include <QStringList>

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appDescription READ appDescription CONSTANT)
public:
    explicit Backend(QObject *parent = nullptr);

    QString appDescription() const;

signals:
    void fileSelected(const QString &fileUrl);
    void fileSelectionCompleted(bool success);

public slots:
    void openFileDialog(const QString &mediaType);
    bool isDir(const QString &path);
    QStringList getFilesInDir(const QString &path);

private:
    QString m_appDescription;
    bool m_folderImageCheckVar;
};

#endif // BACKEND_H
