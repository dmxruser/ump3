QT       += core gui qml quick multimedia widgets

TARGET = HEllo
TEMPLATE = app

SOURCES += main.cpp \
    backend.cpp

HEADERS  += backend.h

RESOURCES += resources.qrc

# Default rules for deployment.
#qnx: target.path = /tmp/${TARGET}/bin
#else: unix:!android: target.path = /opt/${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

