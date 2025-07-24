#include "backend.h"
#include <QFileInfo>
#include <QDir>

Backend::Backend(QObject *parent) : QObject(parent)
{
    m_appDescription = "This is a simple backend for a media player application.";
}

QString Backend::appDescription() const
{
    return m_appDescription;
}

void Backend::openFileDialog(const QString &mediaType)
{
    m_folderImageCheckVar = false;
    QFileDialog dialog;
    if (mediaType == "all_media") {
        m_folderImageCheckVar = false;
        dialog.setFileMode(QFileDialog::ExistingFile);
        dialog.setNameFilter(tr("All Media Files (*.mp3 *.ogg *.wav *.mp4 *.mov *.avi *.gif *.jpeg *.jpg *.png *.webp);;Audio Files (*.mp3 *.ogg *.wav);;Video Files (*.mp4 *.mov *.avi);;Image Files (*.gif *.jpeg *.jpg *.png *.webp)"));
    } else if (mediaType == "folder") {
        m_folderImageCheckVar = true;
        dialog.setFileMode(QFileDialog::Directory);
        dialog.setOption(QFileDialog::ShowDirsOnly, true);
    }
    else {
        m_folderImageCheckVar = false;
        dialog.setFileMode(QFileDialog::ExistingFile);
        dialog.setNameFilter(tr("All Files (*.*)"));
    }

    if (dialog.exec()) {
        QString file_path = dialog.selectedFiles().first();
        QUrl url = QUrl::fromLocalFile(file_path);
        emit fileSelected(url.toString());
        emit fileSelectionCompleted(true);
    } else {
        emit fileSelectionCompleted(false);
    }
}

bool Backend::isDir(const QString &path)
{
    QUrl url(path);
    return QFileInfo(url.toLocalFile()).isDir();
}

QStringList Backend::getFilesInDir(const QString &path)
{
    QUrl url(path);
    QDir dir(url.toLocalFile());
    QStringList nameFilters;
    nameFilters << "*.mp3" << "*.ogg" << "*.wav" << "*.mp4" << "*.mov" << "*.avi" << "*.gif" << "*.jpeg" << "*.jpg" << "*.png" << "*.webp";
    QStringList fileList = dir.entryList(nameFilters, QDir::Files);
    for (int i = 0; i < fileList.size(); ++i) {
        fileList[i] = QUrl::fromLocalFile(dir.absoluteFilePath(fileList[i])).toString();
    }
    return fileList;
}
