#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QFileInfo>
#include "backend.h"

int main(int argc, char *argv[])
{
    // Initialize Qt application for media playback
    qputenv("QT_MEDIA_BACKEND", "ffmpeg");
    qputenv("QT_AVOID_VAAPI", "1");
    qputenv("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", "");

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/sure.png"));
    app.setApplicationName("ump3");
    app.setDesktopFileName("HEllo.desktop");

    QQmlApplicationEngine engine;
    Backend backend;
    engine.rootContext()->setContextProperty("backend", &backend);

    // Pass the first command-line argument to QML
    if (argc > 1) {
        QString initialMedia = QString::fromLocal8Bit(argv[1]);
        engine.rootContext()->setContextProperty("initialMedia", QUrl::fromLocalFile(initialMedia));
    }


    const QUrl url(QStringLiteral("qrc:/first.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}