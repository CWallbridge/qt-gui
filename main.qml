import QtQuick 2.7
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
 import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtTest 1.1

import Box2D 2.0

import Ros 1.0

Window {

    id: window

    visible: true
    visibility: Window.FullScreen
    width: Screen.width
    height: Screen.height

    property string  qlogfilename: ""
    property var startingTime:""

    color: "black"
    title: qsTr("Free-play sandbox")

    StateGroup {
        id: globalstates
        state: "start"

        states: [
            // default state ("") is a blank, black, screen
            State {
                name: "start"
                PropertyChanges {
                   target: startPanel
                   visible: true
               }
                StateChangeScript {
                     script: {
                         condition.visible=false
                     }
                 }
            },
            State {
                name: "tuto"
                PropertyChanges {
                   target: tutoPanel
                   visible: true
               }
            },
            State {
                name: "placement1"
                 PropertyChanges {
                    target: sandbox
                    visible: true
                }
                 StateChangeScript {
                      script: {
                          maps.updateMap()
                          publish("start_placement1")
                      }
                  }
            },
            State {
                name: "midScreen"
                 PropertyChanges {
                    target: midPanel
                    visible: true
                }
            },
            State {
                name: "placement2"
                 PropertyChanges {
                    target: sandbox
                    visible: true
                }
                 StateChangeScript {
                      script: {
                          maps.updateMap()
                          publish("start_placement2")
                      }
                  }
            },
            State {
                name: "end"
                PropertyChanges {
                   target: endPanel
                   visible: true
               }
                StateChangeScript {
                     script: {
                         publish("endStudy")
                     }
                 }
            }
        ]
    }

    Item {
        id: condition
        anchors.fill: parent
        visible: true
        Grid {
            anchors.fill:parent
            columns: 2
            spacing: width/10
            topPadding: spacing
            leftPadding: spacing
            rightPadding: spacing
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            property int cellWidth: (width-(columns+1)*spacing)/columns
            property int cellHeight: height/5
            PrettyButton{
                width: parent.cellWidth
                height: parent.cellHeight
                text: "Condition: Dynamic-NonAmbiguous Map 1-2"
                onClicked: {condition.start(0,"D-N")}
            }
            PrettyButton{
                width: parent.cellWidth
                height: parent.cellHeight
                text: "Condition: Dynamic-NonAmbiguous Map 2-1"
                onClicked: {condition.start(1,"D-N")}
            }
            PrettyButton{
                width: parent.cellWidth
                height: parent.cellHeight
                text: "Condition: NonAmbiguous-Dynamic Map 1-2"
                onClicked: {condition.start(0,"N-D")}
            }
            PrettyButton{
                width: parent.cellWidth
                height: parent.cellHeight
                text: "Condition: NonAmbiguous-Dynamic Map 2-1"
                onClicked: {condition.start(1,"N-D")}
            }
        }
        function start(order, condition){
            maps.order=order
            globalstates.state="start"
            publish("Condition:"+condition+" Starting map: "+(order+1))
        }
    }

    Item {
        id: startPanel
        anchors.fill: parent
        visible: false

        PrettyButton{
            width: parent.width/5
            height: parent.height/5
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Start"
            onClicked: {
                var d = new Date()
                startingTime = d.getTime()
                qlogfilename = "placement-data/"+d.toISOString().split(".")[0].replace(":","-").replace(":","-")
                globalstates.state="tuto"
                publish("startStudy_"+qlogfilename)
            }
        }
    }

    Item {
        id: midPanel
        anchors.fill: parent
        visible: false
        PrettyLabel{
            width: parent.width/2
            height: parent.height/5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -height
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text:"You finished the first map, now the roles are inverted."
        }
        PrettyButton{
            width: parent.width/5
            height: parent.height/5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: height
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Start"
            onClicked: {
                globalstates.state="placement2"
            }
        }
    }

    Item {
        id: endPanel
        anchors.fill: parent
        visible: false
        PrettyLabel{
            width: parent.width/2
            height: parent.height/5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -height
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text:"You finished the study, thank you for participating."
        }
    }

    Item {
        id: tutoPanel
        anchors.fill: parent
        visible: false
        Grid {
            anchors.fill:parent
            columns: 6
            spacing: width/20
            topPadding: spacing
            leftPadding: spacing
            rightPadding: spacing
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            property int cellWidth: (width-(columns+1)*spacing)/columns
            property int cellHeight: height/5
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/church.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Church"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/commercial.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Commercial District"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/factory.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Factory"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/fire.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Fire Department"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/hospital.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Hospital"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/manor.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Manor"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/police.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Police Department"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/power.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Power Plant"
            }
            Image {
                width: parent.cellWidth
                height: parent.cellHeight
                fillMode: Image.PreserveAspectFit
                source: "res/residential.png"
            }
            PrettyLabel{
                width: parent.cellWidth
                height: parent.cellHeight
                text:"Residence"
            }
        }

        PrettyButton{
            width: parent.width/5
            height: parent.height/15
            text: "Continue"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height/2
            onClicked: {globalstates.state="placement1"}
        }
    }

    Item {
        id: sandbox
        anchors.fill:parent
        visible: false

        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        //property double pixel2meter: (physicalMapWidth / 1000) / map.paintedWidth
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width

        Image {
            id: map
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            visible: true
            source: "res/BG1.png"

            Item {
                // this item sticks to the 'visual' origin of the map, taking into account
                // possible margins appearing when resizing
                id: mapOrigin
                property string name: "sandtray"
                rotation: parent.rotation
                x: parent.width/2 // + (parent.width - parent.paintedWidth)/2
                y: parent.height/2 //+ (parent.height - parent.paintedHeight)/2
            }
        }
    }

    Item {
        id: interactiveitems

        anchors.fill: parent

        visible: sandbox.visible

        property var collisionCategories: Box.All
        property int currentMaxZ: 0 // hold the max Z value, incremented every time an interactive item is clicked. This allows proper restacking of objects by sequentially clicking them

        property bool showRobotChild: false
        property bool publishRobotChild: false

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }

        MouseJoint {
            id: externalJoint
            bodyA: anchor
            dampingRatio: 1
            maxForce: 1
        }

        MultiPointTouchArea {
            id: touchArea
            anchors.fill: parent

            touchPoints: [
                TouchJoint {id:touch1;name:"touch1"},
                TouchJoint {id:touch2;name:"touch2"},
                TouchJoint {id:touch3;name:"touch3"},
                TouchJoint {id:touch4;name:"touch4"},
                TouchJoint {id:touch5;name:"touch5"},
                TouchJoint {id:touch6;name:"touch6"}
            ]
        }

        TFListener {
            id: robotLocation
            frame: "torso"
            origin: mapOrigin
            parentframe: mapOrigin.name
            pixelscale: sandbox.pixel2meter
        }

        RosPoseSubscriber {
            id: rostouch
            x: 0
            y: 0
            topic: "poses"

            Image {
                id:robot_hand
                source: "res/nao_hand.svg"
                y: - 10
                x: - 30
                width: 120
                fillMode: Image.PreserveAspectFit
                // tracks the position of the robot
                transform: Rotation {origin.x: 15;origin.y: 5;angle: 180/Math.PI * (-Math.PI/2 + Math.atan2(robotLocation.y - rostouch.y, robotLocation.x - rostouch.x))}
                visible: false
            }

            z:100
            property var target: null
            property string draggedObject: ""
            origin: mapOrigin
            pixelscale: sandbox.pixel2meter

            onPositionChanged: {

                // the playground is hidden, nothing to do
                if(!interactiveitems.visible) return;

                robot_hand.visible=true;

                if (target === null) {
                    var obj = interactiveitems.childAt(x, y);
                    if (obj.objectName === "interactive") {
                        draggedObject = obj.name;
                        console.log("ROS controller touched object: " + obj.name);

                        target = obj.body

                        externalJoint.maxForce = target.getMass() * 500;
                        externalJoint.target = Qt.point(x,y);
                        externalJoint.bodyB = target;
                    }

                }
                if (target != null) {
                    externalJoint.target = Qt.point(x, y);
                    releasetimer.restart();
                }
            }

            Timer {
                id: releasetimer
                interval: 1000
                running: false
                onTriggered: {
                    console.log("Auto-releasing ROS contact with " + parent.draggedObject);
                    interactionEvents.text = "robot_releasing_" + parent.draggedObject;
                    parent.draggedObject = "";
                    parent.target = null;
                    externalJoint.bodyB = null;
                    robot_hand.visible=false;
                }
            }
        }

        World {
            id: physicsWorld
            gravity: Qt.point(0.0, 0.0);

        }

        RectangleBoxBody {
            id: rightwall
            color: "#000000FF"
            width: 32
            anchors {
                left: parent.right
                bottom: parent.bottom
                top: parent.top
            }
            world: physicsWorld
            friction: 1
            density: 1
            categories: Box.Category2
        }
        RectangleBoxBody {
            id: leftwall
            color: "#000000FF"
            width: 32
            anchors {
                right: parent.left
                bottom: parent.bottom
                top: parent.top
            }
            world: physicsWorld
            friction: 1
            density: 1
            categories: Box.Category2
        }
        RectangleBoxBody {
            id: top
            color: "#000000FF"
            height: 32
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.top
            }
            world: physicsWorld
            friction: 1
            density: 1
            categories: Box.Category2
        }
        RectangleBoxBody {
            id: bottom
            color: "#000000FF"
            height: 32
            anchors {
                left: parent.left
                right: parent.right
                top: parent.bottom
            }
            world: physicsWorld
            friction: 1
            density: 1
            categories: Box.Category2
        }

        Body {
            id: anchor
            world: physicsWorld
        }
        Item {
            id: maps
            visible: true
            anchors.fill: parent
            property var order: 0
            //-X targets, 0 empty, 1 residential, 2 manor, 3 factory, 4 police, 5 fire, 6 church, 7 hospital, 8 power, 9 commercial
            property var names: ["", "residential", "manor", "factory", "police", "fire", "church", "hospital", "power", "commercial"]
            property var mapDesc: [ [ 1, 6, 8, 1,-6, 7, 1,-2, 1,
                                     1, 5, 0, 1, 9, 1, 4, 5, 1,
                                     1,-4, 7,-1, 0, 3, 1, 0, 6,
                                     1, 9, 0, 4,-5, 1, 5,-3, 1,
                                     1, 1, 2, 1, 9, 1, 0, 7, 1],
                                   [ 1, 9, 0, 5,-1, 1, 6, 1, 1,
                                     1, 6, 4, 1, 9,-5, 0,-2, 1,
                                    -6,-7, 1, 2, 0, 4, 1, 1, 1,
                                     4, 1, 1, 1, 1, 9,-4, 5, 1,
                                    -3, 3, 9, 0, 5, 0, 4, 1, 1]]
            //property var targets: [[1,2,9,4,1,4],[7,7,1,7,1,2,8]]
            property var targets: [[1,2],[7,7]]

            property var mapNumber: order
            property var currentId: 0
            property var currentType: names[targets[mapNumber][currentId]]
            Item{
                id: caseLists
                visible: true
                anchors.fill:parent
            }
            function createMap(){
                console.log(mapNumber)
                for(var i=0; i<45; i++){
                    var component = Qt.createComponent("StaticImage.qml")
                    var newCase = component.createObject(caseLists,{"x":(i%9+.5)*window.width/9-movingItem.width/2,"y":(parseInt(i/9)+.5)*window.height/5-movingItem.height/2,"number":mapDesc[mapNumber][i]})
                    if(mapDesc[mapNumber][i]<1){
                        newCase.image = "res/empty.png"
                        if(newCase.number==-1){
                            newCase.broadcasting=true
                        }
                    }
                    else{
                        newCase.image = "res/"+names[mapDesc[mapNumber][i]]+".png"
                    }
                }
            }
            function updateMap(){
                console.log("update "+caseLists.children.length)
                if(caseLists.children.length==0)
                    maps.createMap()
                else{
                    for(var i = 0; i<caseLists.children.length;i++){
                        caseLists.children[i].number=mapDesc[mapNumber][i]
                        if(mapDesc[mapNumber][i]<1){
                            caseLists.children[i].image = "res/empty.png"
                            if(caseLists.children[i].number==-1){
                                caseLists.children[i].broadcasting=true
                            }
                        }
                        else
                            caseLists.children[i].image = "res/"+names[mapDesc[mapNumber][i]]+".png"
                    }
                }
            }

            function endMap(){
                console.log("Done")
                publish("endMap")
                currentId=0
                if(maps.mapNumber!=order){
                    globalstates.state ="end"
                    return
                }
                maps.mapNumber=1-order
                globalstates.state ="midScreen"
            }
        }

        Character {
            id: movingItem
            number: -maps.currentId-1
            name: maps.currentType
            x: parent.width/2-width/2
            y: parent.height/2-height/2
        }
    }
    RosStringPublisher {
        id: interactionEvents
        topic: "sandtray/interaction_events"
    }

    function publish(event){
        var d = new Date()
        console.log(window.startingTime)
        var n = d.getTime() - window.startingTime
        var log=[n,event]
        fileio.write(window.qlogfilename, log.join(","))
        interactionEvents.text=event
    }

    MouseArea {
        width:30
        height:width
        z: 100

        anchors.bottom: parent.bottom
        anchors.right: parent.right

        //Rectangle {
        //    anchors.fill: parent
        //    color: "red"
        //}

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                localising.signal();
                fiducialmarker.visible = true;
                clicks = 0;
                hide_fiducial_markers.start();
            }
        }
    }

    MouseArea {
        width:30
        height:width
        z: 100

        anchors.bottom: parent.bottom
        anchors.left: parent.left

        Rectangle {
            anchors.fill: parent
            color: "red"
        }

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                globalstates.state="start"
                maps.mapNumber=maps.order

                clicks = 0;
            }
        }
    }
}
