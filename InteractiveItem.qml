import QtQuick 2.2
import Box2D 2.0

import Ros 1.0

Item {
        id:item
        width: 2*parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
        height: width
        rotation: Math.random() * 360
        property int number: 0

        objectName: "interactive"

        property string name
        property string image: "res/"+name+".png"
        property var boundingbox:
            Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(origin.x, origin.y),
                    Qt.point(origin.x + image.sourceSize.width * bbratio, origin.y),
                    Qt.point(origin.x + image.sourceSize.width * bbratio, origin.y + image.sourceSize.height * bbratio),
                    Qt.point(origin.x, origin.y + image.sourceSize.height * bbratio),
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }

        property alias body: cubeBody
        property double bbratio: 1 // set later (cf below) once paintedWidth is known
        property alias origin: imageOrigin

        Image {
            id: image
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
            onPaintedWidthChanged: {
                bbratio= image.paintedWidth/image.sourceSize.width;
            }

            // Draw a red border around the interactive items
            Rectangle {
                color:"transparent"
                anchors.fill:parent
                border.color: "red"
                border.width: parent.width/20
            }
        }
        Body {
                id: cubeBody

                target: item
                world: physicsWorld
                bodyType: Body.Dynamic

                Component.onCompleted: {
                    cubeBody.addFixture(item.boundingbox);
                }

                angularDamping: 5
                linearDamping: 5
        }

    Item {
        id: objectCenter
        anchors.centerIn: parent
        rotation: parent.rotation
        TFBroadcaster {
            target: parent
            frame: maps.mapNumber+1+"_"+-number+"_"+parent.parent.name
            active: sandbox.visible

            origin: mapOrigin
            parentframe: mapOrigin.name

            pixelscale: 9/sandbox.width
        }
    }

}
