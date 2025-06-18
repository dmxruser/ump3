import QtQuick 2.15
import QtQuick.Controls 2.15
ApplicationWindow {
    visible: true
    width: 300
    height: 200
    title: "Button Demo"
    Column {
        spacing: 5
        Text {text: "Why"}
        Text {text: "Why"}
        Button {
            text: "Ok"
            onClicked: console.log()
        }

    }
}
