import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {
    id: button
    text: ""
    visible: true
    style: ButtonStyle {
        label: Text {
            font.family: "Helvetica"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 30
            text: button.text
            wrapMode: Text.WordWrap
        }
        background: Rectangle {
            border.width: width/40
            border.color: "steelblue"
            radius: width/20
            color: "AliceBlue"
        }
    }
}
