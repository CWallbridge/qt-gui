import QtQuick 2.0
import Ros 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Box2D 2.0

Item {
    id: staticImage
    property double scale: 1.6
    width: 180
    height: width
    x: -100
    y: -100
    visible: true
    rotation: 0
    property int centerX: x+width/2
    property int centerY: y+height/2
    property int number: 0
    property bool broadcasting: false

    property string name: ""
    property string image: "res/"+"target"+".png"
    property int epsilon: 20
    property double bbScale: 1.0
    property point bbOrigin: Qt.point(width/2, height/2)
    property double bbRadius: bbScale * width/2
    property var boundingbox:
    Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(bbOrigin.x + bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y + bbRadius),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x - bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y - bbRadius),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius)
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }

    Image {
        id: im
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        source: parent.image

        Item {
            // this item sticks to the 'visual' origin of the object, taking into account
            // possible margins appearing when resizing
            id: imageOrigin
            rotation: parent.rotation
            x: parent.x + (parent.width - parent.paintedWidth)/2
            y: parent.y + (parent.height - parent.paintedHeight)/2
        }
    }
    
    Item {
        id: objectCenter
        anchors.centerIn: parent
        rotation: parent.rotation
        TFBroadcaster {
            target: parent
            frame: maps.mapNumber+1+"_"+-number+"_"+"target"
            active: staticImage.broadcasting

            origin: mapOrigin
            parentframe: mapOrigin.name

            //pixelscale: 9/sandbox.width
            pixelscale: sandbox.pixel2meter
        }
    }
    onImageChanged: console.log(image)
}
