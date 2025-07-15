#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <QFileDialog>
#include <QUrl>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

signals:
    void fileSelected(const QString &fileUrl);

public slots:
    void openFileDialog(const QString &mediaType);
};

#endif // BACKEND_H
