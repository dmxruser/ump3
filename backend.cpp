#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
}

void Backend::openFileDialog(const QString &mediaType)
{
    QFileDialog dialog;
    dialog.setFileMode(QFileDialog::ExistingFile);

    if (mediaType == "audio") {
        dialog.setNameFilter(tr("Audio Files (*.mp3 *.ogg *.wav)"));
    } else if (mediaType == "video") {
        dialog.setNameFilter(tr("Video Files (*.mp4 *.mov *.avi)"));
    } else if (mediaType == "image") {
        dialog.setNameFilter(tr("Image Files (*.gif *.jpeg *.jpg *.png *.webp)"));
    } else {
        dialog.setNameFilter(tr("All Files (*.*)"));
    }

    if (dialog.exec()) {
        QString file_path = dialog.selectedFiles().first();
        QUrl url = QUrl::fromLocalFile(file_path);
        emit fileSelected(url.toString());
    }
}
