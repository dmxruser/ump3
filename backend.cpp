#include "backend.h"
#include <QFileInfo>
#include <QDir>

Backend::Backend(QObject *parent) : QObject(parent)
{
}

void Backend::openFileDialog(const QString &mediaType)
{
    QFileDialog dialog;

    if (mediaType == "audio") {
        dialog.setFileMode(QFileDialog::ExistingFile);
        dialog.setNameFilter(tr("Audio Files (*.mp3 *.ogg *.wav)"));
    } else if (mediaType == "video") {
        dialog.setFileMode(QFileDialog::ExistingFile);
        dialog.setNameFilter(tr("Video Files (*.mp4 *.mov *.avi)"));
    } else if (mediaType == "image") {
        dialog.setFileMode(QFileDialog::ExistingFile);
        dialog.setNameFilter(tr("Image Files (*.gif *.jpeg *.jpg *.png *.webp)"));
    } else if (mediaType == "folder") {
        dialog.setFileMode(QFileDialog::Directory);
        dialog.setOption(QFileDialog::ShowDirsOnly, true);
    }
    else {
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
