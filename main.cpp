#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QFileInfo>
#include "backend.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/sure.png"));

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
