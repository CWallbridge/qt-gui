import QtQuick 2.7
import QtQuick.Controls 1.4
 import QtQuick.Controls.Styles 1.4

Label{
    font.family: "Helvetica"
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignLeft
    font.pointSize: 30
    text: button.text
    wrapMode: Text.WordWrap
    color: "white"
    font.pixelSize: 40
}
