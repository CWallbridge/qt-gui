import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import Box2D 2.0

import Ros 1.0

Window {

    id: window

    visible: true
    visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:800
    height: 600

    property int prevWidth:800
    property int prevHeight:600

    onWidthChanged: {
        robot.x = robot.x * width/prevWidth;
        prevWidth=width;
    }
    onHeightChanged: {
        robot.y = robot.y * height/prevHeight;
        prevHeight=height;

    }

    color: "black"
    title: qsTr("Free-play sandbox")

    StateGroup {
        id: globalstates

        states: [
            // default state ("") is a blank, black, screen

            State {
                name: "visualtracking"
                PropertyChanges {
                    target: visualtracking
                    visible: true
                }
                StateChangeScript {
                    script: visualtracking.start();

                }
            },

            State {
                name: "tutorial"
                PropertyChanges {
                    target: sandbox
                    visible: true
                }
                StateChangeScript {
                    script: interactiveitems.startTutorial();

                }

            },
            State {
                name: "items-placement"
                PropertyChanges {
                    target: interactiveitems
                    collisionCategories: Box.Category2 // disable collisions between items
                }
                 PropertyChanges {
                    target: stash
                    color: "transparent"
                }
                PropertyChanges {
                    target: drawingarea
                    drawEnabled: false
                }
                PropertyChanges {
                    target: sandbox
                    visible: true
                }
               StateChangeScript {
                    script: interactiveitems.startItemsPlacement();
                }
            },

            State {
                name: "prod-quiz"
                PropertyChanges {
                   target: stash
                   color: "transparent"
                }
                PropertyChanges {
                    target: drawingarea
                    drawEnabled: false
                }
                PropertyChanges {
                    target: sandbox
                    visible: true
                }
                StateChangeScript {
					script: interactiveitems.startProdQuiz();
                }
			},

            State {
                name: "freeplay-sandbox"
                 PropertyChanges {
                    target: sandbox
                    visible: true
                }
               StateChangeScript {
                    script: interactiveitems.startFreeplay();
                }
            }

        ]
    }

    RosSignal {
        topic: "sandtray/signals/start_visual_tracking"
        onTriggered: globalstates.state = "visualtracking";
    }

    RosSignal {
        topic: "sandtray/signals/start_tutorial"
        onTriggered: globalstates.state = "tutorial";
    }

    RosSignal {
        topic: "sandtray/signals/start_items_placement"
        onTriggered: globalstates.state = "items-placement";
    }

    RosSignal {
		topic: "sandtray/signals/start_prod_quiz"
        onTriggered: globalstates.state = "prod-quiz";
    }

    RosSignal {
        topic: "sandtray/signals/start_freeplay"
        onTriggered: globalstates.state = "freeplay-sandbox";
    }

    RosSignal {
        topic: "sandtray/signals/blank_interface"
        onTriggered: globalstates.state = "";
    }


    Item {
        id: sandbox
        anchors.fill:parent
        visible: false

        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        //property double pixel2meter: (physicalMapWidth / 1000) / drawingarea.paintedWidth
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width

        DrawingArea {
            id: drawingarea
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top

            fgColor: colorpicker.paintbrushColor
            bgImage: "res/tutorial_bg.svg"

            touchs: touchArea

            pixelscale: sandbox.pixel2meter

            Item {
                // this item sticks to the 'visual' origin of the map, taking into account
                // possible margins appearing when resizing
                id: mapOrigin
                property string name: "sandtray"
                rotation: parent.rotation
                x: parent.x // + (parent.width - parent.paintedWidth)/2
                y: parent.y //+ (parent.height - parent.paintedHeight)/2
            }

            RosSignal {
                id: backgrounddrawing
                topic: "sandtray/signals/background_drawing"
            }
            onDrawEnabledChanged: backgrounddrawing.signal()
        }

        Rectangle {
            id: stash
            color: "#111"
            height: parent.height
            width: parent.width * 0.12
            anchors.right: parent.right
            anchors.top: parent.top

            Rectangle {
               height: parent.height
                width: 5
                anchors.left: parent.left
                anchors.top: parent.top
                color: Qt.lighter(parent.color,5)

            }
        }

        Item {
            id: interactiveitems

            anchors.fill: parent

            visible: false

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

            Item {
                id:robot
                z:100
                rotation: 90+180/Math.PI * (-Math.PI/2 + Math.atan2(-robot.y+robotFocus.y, -robot.x+robotFocus.x))
                Image {
                    id: robotImg
                    source: "res/nao_head.svg"
                    anchors.centerIn: parent
                    width: 100
                    fillMode: Image.PreserveAspectFit

                    Drag.active: robotDragArea.drag.active

                    MouseArea {
                        id: robotDragArea
                        anchors.fill: parent
                        drag.target: robot
                    }
                    visible:interactiveitems.publishRobotChild
                }

                TFBroadcaster {
                    active: interactiveitems.publishRobotChild
                    target: parent
                    frame: "odom"

                    origin: mapOrigin
                    parentframe: mapOrigin.name

                    //zoffset: -0.15 // on boxes, next to sandtray
                    zoffset: -0.25 // on the ground, next to sandtray

                    pixelscale: sandbox.pixel2meter
                }




            }
            TFListener {
                id: robotArmReach
                x: window.width/2
                y: window.height/2
                z:100

                visible: interactiveitems.showRobotChild

                frame: "arm_reach"
                origin: mapOrigin
                parentframe: mapOrigin.name
                pixelscale: sandbox.pixel2meter

                Rectangle {
                    anchors.centerIn: parent
                    width: 10
                    height: width
                    radius: width/2
                    color: "red"
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.zvalue * 2 / sandbox.pixel2meter
                    height: width
                    radius: width/2
                    color: "#55FFAA44"
                }
            }
            Item {
                id: robotFocus
                x: window.width/2
                y: window.height/2
                z:100

                Rectangle {
                    anchors.centerIn: parent
                    width:30
                    height: width
                    radius: width/2
                    color: "#FF3333"

                    Drag.active: robotFocusDragArea.drag.active

                    MouseArea {
                        id: robotFocusDragArea
                        anchors.fill: parent
                        drag.target: robotFocus
                    }

                    visible: interactiveitems.showRobotChild

                    TFBroadcaster {
                        active: parent.visible
                        target: parent
                        frame: "robot_focus"

                        origin: mapOrigin
                        parentframe: mapOrigin.name

                        pixelscale: sandbox.pixel2meter
                    }
                }
            }

            Item {
                id: childFocus
                x: window.width/2
                y: window.height/2
                z:100

                Rectangle {
                    anchors.centerIn: parent
                    width:30
                    height: width
                    radius: width/2
                    color: "#995500"

                    Drag.active: childFocusDragArea.drag.active

                    MouseArea {
                        id: childFocusDragArea
                        anchors.fill: parent
                        drag.target: childFocus
                    }
                    visible: interactiveitems.publishRobotChild

                }
            }

            RosPoseSubscriber {
                id: gazeFocus
                x: window.width/2
                y: window.height/2
                z:100

                visible: false

                topic: "/gazepose_0"
                origin: mapOrigin
                pixelscale: sandbox.pixel2meter

                Rectangle {
                    anchors.centerIn: parent
                    width: 10
                    height: width
                    radius: width/2
                    color: "red"
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.zvalue * 2 / sandbox.pixel2meter
                    height: width
                    radius: width/2
                    color: "transparent"
                    border.color: "orange"
                }
            }

            Item {
                id:child
                z:100
                rotation: 90+180/Math.PI * (-Math.PI/2 + Math.atan2(-child.y+childFocus.y, -child.x+childFocus.x))
                Image {
                    id: childImg
                    source: "res/child_head.svg"
                    anchors.centerIn: parent
                    width: 100
                    fillMode: Image.PreserveAspectFit

                    Drag.active: childDragArea.drag.active

                    MouseArea {
                        id: childDragArea
                        anchors.fill: parent
                        drag.target: child
                    }
                    visible: interactiveitems.publishRobotChild
                }

                TFBroadcaster {
                    active: interactiveitems.publishRobotChild
                    target: parent
                    frame: "child"

                    origin: mapOrigin
                    parentframe: mapOrigin.name

                    pixelscale: sandbox.pixel2meter
                }


                x: window.width/2 - childImg.width /2
                y: window.height - childImg.height
            }

            RosPoseSubscriber {
                id: rostouch

                x: childFocus.x
                y: childFocus.y

                topic: "poses"

                Image {
                    id:robot_hand
                    source: "res/nao_hand.svg"
                    y: - 10
                    x: - 30
                    width: 120
                    fillMode: Image.PreserveAspectFit
                    // tracks the position of the robot
                    transform: Rotation {origin.x: 15;origin.y: 5;angle: 180/Math.PI * (-Math.PI/2 + Math.atan2(robotArmReach.y-rostouch.y, robotArmReach.x-rostouch.x))}
                    visible: false

                }

                //Rectangle {
                //    anchors.centerIn: parent
                //    width: 5
                //    height: width
                //    radius: width/2
                //    color: "red"
                //    z:1
                //}

                z:5000
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
                        interactionEvents.text = "releasing_" + parent.draggedObject;
                        parent.draggedObject = "";
                        parent.target = null;
                        externalJoint.bodyB = null;
                        robot_hand.visible=false;
                    }
                }
                RosStringPublisher {
                    id: interactionEvents
                    topic: "sandtray/interaction_events"
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

            Character {
                id: zebra
                name: "zebra"
                image: "res/sprite-zebra.png"
                boundingbox: Polygon {
                    vertices: [
                        Qt.point(zebra.origin.x + 0,                 zebra.origin.y + 60*zebra.bbratio),
                        Qt.point(zebra.origin.x + 100*zebra.bbratio, zebra.origin.y + 0),
                        Qt.point(zebra.origin.x + 180*zebra.bbratio, zebra.origin.y + 100*zebra.bbratio),
                        Qt.point(zebra.origin.x + 260*zebra.bbratio, zebra.origin.y + 150*zebra.bbratio),
                        Qt.point(zebra.origin.x + 235*zebra.bbratio, zebra.origin.y + 280*zebra.bbratio),
                        Qt.point(zebra.origin.x + 100*zebra.bbratio, zebra.origin.y + 280*zebra.bbratio)
                    ]
                    density: 1
                    friction: 1
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }
                stash: stash
            }
            Character {
                id: elephant
                name: "elephant"
                scale: 1.5
                image: "res/sprite-elephant.png"
                boundingbox: Polygon {
                    vertices: [
                        Qt.point(elephant.origin.x +  23*elephant.bbratio, elephant.origin.y + 24*elephant.bbratio),
                        Qt.point(elephant.origin.x + 216*elephant.bbratio, elephant.origin.y + 0),
                        Qt.point(elephant.origin.x + 300*elephant.bbratio, elephant.origin.y + 90*elephant.bbratio),
                        Qt.point(elephant.origin.x + 270*elephant.bbratio, elephant.origin.y + 200*elephant.bbratio),
                        Qt.point(elephant.origin.x + 135*elephant.bbratio, elephant.origin.y + 200*elephant.bbratio),
                        Qt.point(elephant.origin.x + 0,                    elephant.origin.y + 107*elephant.bbratio)
                    ]
                    density: 1
                    friction: 1
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }
                stash: stash
            }
            Character {
                id: giraffe
                name: "giraffe"
                scale: 1.5
                image: "res/sprite-giraffe.png"
                boundingbox: Polygon {
                    vertices: [
                        Qt.point(giraffe.origin.x + 88*giraffe.bbratio, giraffe.origin.y + 0),
                        Qt.point(giraffe.origin.x + 200*giraffe.bbratio, giraffe.origin.y + 190*giraffe.bbratio),
                        Qt.point(giraffe.origin.x + 188*giraffe.bbratio, giraffe.origin.y + 324*giraffe.bbratio),
                        Qt.point(giraffe.origin.x + 85*giraffe.bbratio, giraffe.origin.y + 321*giraffe.bbratio),
                        Qt.point(giraffe.origin.x + 0,                    giraffe.origin.y + 55*giraffe.bbratio)
                    ]
                    density: 1
                    friction: 1
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }
                stash: stash
            }
            Character {
                id: hippo
                name: "hippo"
                scale: 1.5
                image: "res/sprite-hippo.png"
                boundingbox: Polygon {
                    vertices: [
                        Qt.point(hippo.origin.x + 133*hippo.bbratio, hippo.origin.y + 0),
                        Qt.point(hippo.origin.x + 321*hippo.bbratio, hippo.origin.y + 71*hippo.bbratio),
                        Qt.point(hippo.origin.x + 305*hippo.bbratio, hippo.origin.y + 200*hippo.bbratio),
                        Qt.point(hippo.origin.x + 133*hippo.bbratio, hippo.origin.y + 200*hippo.bbratio),
                        Qt.point(hippo.origin.x + 37*hippo.bbratio, hippo.origin.y + 138*hippo.bbratio),
                        Qt.point(hippo.origin.x + 0,                 hippo.origin.y + 40*hippo.bbratio)
                    ]
                    density: 1
                    friction: 1
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }
                stash: stash
            }
            Character {
                id: lion
                name: "lion"
                image: "res/sprite-lion.png"
                boundingbox: Polygon {
                    vertices: [
                        Qt.point(lion.origin.x + 90*lion.bbratio, lion.origin.y + 0),
                        Qt.point(lion.origin.x + 184*lion.bbratio, lion.origin.y + 47*lion.bbratio),
                        Qt.point(lion.origin.x + 224*lion.bbratio, lion.origin.y + 161*lion.bbratio),
                        Qt.point(lion.origin.x + 133*lion.bbratio, lion.origin.y + 263*lion.bbratio),
                        Qt.point(lion.origin.x + 38*lion.bbratio, lion.origin.y + 240*lion.bbratio),
                        Qt.point(lion.origin.x + 0,                 lion.origin.y + 87*lion.bbratio),
                        Qt.point(lion.origin.x + 23*lion.bbratio, lion.origin.y + 27*lion.bbratio)
                    ]
                    density: 1
                    friction: 1
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }
                stash: stash
            }
            Character {
                id: crocodile
                name: "crocodile"
                image: "res/sprite-crocodile.png"
                boundingbox: Polygon {
                    vertices: [
                        Qt.point(crocodile.origin.x + 76*crocodile.bbratio, crocodile.origin.y + 37*crocodile.bbratio),
                        Qt.point(crocodile.origin.x + 127*crocodile.bbratio, crocodile.origin.y + 7*crocodile.bbratio),
                        Qt.point(crocodile.origin.x + 213*crocodile.bbratio, crocodile.origin.y + 5*crocodile.bbratio),
                        Qt.point(crocodile.origin.x + 221*crocodile.bbratio, crocodile.origin.y + 221*crocodile.bbratio),
                        Qt.point(crocodile.origin.x + 43*crocodile.bbratio, crocodile.origin.y + 241*crocodile.bbratio),
                        Qt.point(crocodile.origin.x + 0,                 crocodile.origin.y + 213*crocodile.bbratio),
                        Qt.point(crocodile.origin.x + 5*crocodile.bbratio, crocodile.origin.y + 185*crocodile.bbratio)
                    ]
                    density: 1
                    friction: 1
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }
                stash: stash
            }

            Character {
                id: caravan
                name: "caravan"
                image: "res/caravan.png"
                scale: 2.5
                stash: stash

                boundingbox: Polygon {
                    vertices: [
                        Qt.point(caravan.origin.x +  55*caravan.bbratio, caravan.origin.y),
                        Qt.point(caravan.origin.x + 377*caravan.bbratio, caravan.origin.y +  46*caravan.bbratio),
                        Qt.point(caravan.origin.x + 495*caravan.bbratio, caravan.origin.y + 133*caravan.bbratio),
                        Qt.point(caravan.origin.x + 440*caravan.bbratio, caravan.origin.y + 175*caravan.bbratio),
                        Qt.point(caravan.origin.x + 55*caravan.bbratio, caravan.origin.y + 175*caravan.bbratio),
                        Qt.point(caravan.origin.x +  0*caravan.bbratio, caravan.origin.y +  94*caravan.bbratio)
                    ]
                    density: 2
                    friction: 2
                    restitution: 0.1
                    collidesWith: interactiveitems.collisionCategories
                }

            }
            Character {
                id: ball
                name: "ball"
                image: "res/ball.svg"
                scale: 0.7
                stash: stash
                friction:0.1
                restitution: 0.7
                density: 0.5
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: boy
                name: "boy"
                image: "res/child-face-boy.svg"
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: girl
                name: "girl"
                image: "res/child-face-girl.svg"
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }



            FootprintsPublisher {
                id:footprints
                pixelscale: sandbox.pixel2meter

                // wait a bit before publishing the footprints to leave Box2D the time to settle
                Timer {
                    interval: 1000; running: true; repeat: false
                    onTriggered: parent.targets=interactiveitems.getActiveItems()
                }
            }

            function getActiveItems() {
                return [zebra,elephant,ball,lion,giraffe,caravan,crocodile,hippo,boy, girl];
            }

            function hideItems(items) {
                for (var i = 0; i < items.length; i++) {
                    items[i].visible = false;
                }
            }

            function restoreAllItems() {
                var items = getActiveItems();
                for (var i = 0; i < items.length; i++) {
                    items[i].visible = true;
                }
            }

            function shuffleItems() {
                var items = getActiveItems();
                for(var i = 0; i < items.length; i++) {
                    var item = items[i]
                    item.x = interactiveitems.x + interactiveitems.width * 0.1 + Math.random() * 0.8 * interactiveitems.width;
                    item.y = interactiveitems.y + interactiveitems.height * 0.1 + Math.random() * 0.8 * interactiveitems.height;
                    item.rotation = Math.random() * 360;
                 }
            }

            RosSignal {
                topic: "sandtray/signals/shuffle_items"
                onTriggered: interactiveitems.shuffleItems();
            }


            function itemsToStash() {
                var items = getActiveItems();
                for(var i = 0; i < items.length; i++) {
                    var item = items[i]
                    item.x = item.stash.x + 10 + Math.random() * 0.5 * item.stash.width;
                    item.y = item.stash.y + 10 + Math.random() * 0.9 * item.stash.height;
                    item.rotation = Math.random() * 360;
               }
            }

            function startTutorial() {
                console.log("Starting task 'tutorial'");
                interactiveitems.visible = true;
                drawingarea.clearDrawing();
                drawingarea.bgImage = "res/tutorial_bg.svg";
                itemsToStash();
                interactiveitems.restoreAllItems();
                interactiveitems.hideItems([hippo, giraffe, ball, elephant, zebra, caravan, lion, crocodile]);
            }

            function startProdQuiz() {
				console.log("Starting task 'production quiz'");
                interactiveitems.visible = false;
                drawingarea.clearDrawing();
                console.log("Draw Quiz");
                drawingarea.bgImage = "res/quiz1.svg";
                userScore.visible = true;
                agentScore.visible = true;
                userScoreChange("0")
                agentScoreChange("0")

            }

            function startItemsPlacement() {
                console.log("Starting task 'items placement'");
                interactiveitems.visible = true;
                drawingarea.clearDrawing();
                drawingarea.bgImage = "res/map.svg";
                itemsToStash();
                interactiveitems.restoreAllItems();
                interactiveitems.hideItems([girl, caravan]);
                userScore.visible = false;
                agentScore.visible = false;
            }

            function startFreeplay() {
                console.log("Starting task 'freeplay'");
                interactiveitems.visible = true;

                drawingarea.clearDrawing();
                drawingarea.bgImage = "res/map.svg";
                itemsToStash();

                interactiveitems.restoreAllItems();
            }

            RosSignal {
                topic: "sandtray/signals/items_to_stash"
                onTriggered: interactiveitems.itemsToStash();
            }



        }

        ColorPicker {
            id: colorpicker
            //anchors.right: stash.left
            //anchors.rightMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            opacity: drawingarea.drawEnabled ? 1 : 0
        }

/*
        Image {
            id: drawModeButton
            source: "res/paint-brush.svg"
            width: 100
            height: width
            rotation: -90
            anchors.verticalCenter: parent.verticalCenter
            x: 30
            visible: opacity === 0 ? false : true

            Behavior on opacity {
                NumberAnimation {
                    duration:300
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    interactiveitems.opacity = 0.4;
                    drawModeButton.opacity = 0;
                    drawingarea.drawEnabled = true;

                }
            }

        }
*/


        function screenshot(path) {
            sandbox.grabToImage(function(result) {
                console.log("Screenshot saved to " + path)
                result.saveToFile(path);
                });

        }

        RosStringSubscriber {
            topic: "sandtray/screenshot"
            onTextChanged: {
                sandbox.screenshot(text)
            }
        }

        function quizChange(img){
            console.log("Changing quiz image to " + img)
            if(globalstates.state == "prod-quiz"){
                drawingarea.bgImage = "res/" + img;
            }
        }

        RosStringSubscriber {
            topic: "sandtray/quiz/question"
            onTextChanged: {
                sandbox.quizChange(text)
            }
        }

        Rectangle {
            id: quiz_correct
            color:"white"
            opacity:0.7
            visible: false
            anchors.fill:parent

            Image {
                // set the actual size of the SVG page
                width: 0.60 / sandbox.pixel2meter
                height: 0.33 / sandbox.pixel2meter
                // make sure the image is in the corner ie, the sandtray origin
                x: 0
                y: 0
                fillMode: Image.PreserveAspectCrop
                source: "res/correct_answer.svg"
            }

            Timer {
                id: hide_quiz_correct
                interval: 5000; running: false; repeat: false
                onTriggered: {
                    quiz_correct.visible = false;
                }

            }

        }

        Rectangle {
            id: quiz_incorrect
            color:"white"
            opacity:0.7
            visible: false
            anchors.fill:parent

            Image {
                // set the actual size of the SVG page
                width: 0.60 / sandbox.pixel2meter
                height: 0.33 / sandbox.pixel2meter
                // make sure the image is in the corner ie, the sandtray origin
                x: 0
                y: 0
                fillMode: Image.PreserveAspectCrop
                source: "res/incorrect_answer.svg"

            }

            Timer {
                id: hide_quiz_incorrect
                interval: 3000; running: false; repeat: false
                onTriggered: {
                    quiz_incorrect.visible = false;
                }

            }

        }


        RosStringSubscriber {
            topic: "sandtray/quiz/result"
            onTextChanged: {
                sandbox.quizShowResult(text)
            }
        }

        function quizShowResult(text){
            console.log("Changing quiz result to " + text)
            if(globalstates.state == "prod-quiz"){
                if (text==="correct"){
                  quiz_correct.visible=true;
                  hide_quiz_correct.start();
                }
                if (text==="incorrect"){
                  quiz_incorrect.visible=true;
                  hide_quiz_incorrect.start();
                }
            }
        }

        Item {
            id: userScore            
            visible:false

            TextEdit{
                id: uscore
                x: 100
                y: 300
                font.pointSize: 128
                text: "0"
            }
            TextEdit{
                id: uname
                x: 100
                y: 100
                font.pointSize: 128
                text: "Name"
            }
        }

        Item {
            id: agentScore            
            visible:false


            TextEdit{
                id: ascore
                x: window.width - 200
                y: 300
                font.pointSize: 128
                text: "0"
            }
            TextEdit{
                id: aname
                x: window.width - 200
                y: 100
                font.pointSize: 128
                text: "Name"
            }
        }

        function userScoreChange(newScore){
            console.log("Changing userScore to " + newScore)
            uscore.text = newScore;
        }

        RosStringSubscriber {
            topic: "sandtray/quiz/userScore"
            onTextChanged: {
                sandbox.userScoreChange(text)
            }
        }

        function agentScoreChange(newScore){
            console.log("Changing agentScore to " + newScore)
            ascore.text = newScore;
        }

        RosStringSubscriber {
            topic: "sandtray/quiz/agentScore"
            onTextChanged: {
                sandbox.agentScoreChange(text)
            }
        }

        function userNameChange(text){
            console.log("Changing user Name to " + text)
            uname.text = text;
        }

        RosStringSubscriber {
            topic: "nao/prod_quiz/childname"
            onTextChanged: {
                sandbox.userNameChange(text)
            }
        }

        function agentNameChange(text){
            console.log("Changing agent Name to " + text)
            aname.text = text;
        }

        RosStringSubscriber {
            topic: "sandtray/quiz/agentname"
            onTextChanged: {
                sandbox.agentNameChange(text)
            }
        }
    }

    Item {
        id: debugToolbar
        x:0
        y:0
        visible:false

        Rectangle {
            id: fullscreenButton
            x: 50
            y: 50
            width: 180
            height: 30
            Text {
                text:  "Toggle fullscreen"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: (window.visibility === Window.FullScreen) ? window.visibility = Window.Windowed : window.visibility = Window.FullScreen;
            }
        }
        Rectangle {
            id: visualAttentionButton
            x: 250
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start visual target tracking"
                anchors.centerIn: parent
            }
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "visualtracking";
                }
            }
        }
        Rectangle {
            id: itemsPlacementButton
            x: 550
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start items placement"
                anchors.centerIn: parent
            }
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "items-placement";
                }
            }

        }
        Rectangle {
            id: tutorialButton
            x: 850
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start tutorial"
                anchors.centerIn: parent
            }
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "tutorial";
                }
            }

        }
        Rectangle {
            id: freeplayButton
            x: 1150
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start freeplay"
                anchors.centerIn: parent
            }
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "freeplay-sandbox";
                }
            }

        }
        Rectangle {
            id: debugButton
            x: 50
            y: 100
            width: 180
            height: 30
            Text {
                text: debugDraw.visible ? "Physics debug: on" : "Physics debug: off"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugDraw.visible = !debugDraw.visible;
                }
            }
        }
        Rectangle {
            id: toggleCollisionsButton
            x: 250
            y: 100
            width: 180
            height: 30
            Text {
                text: interactiveitems.collisionCategories == Box.Category2 ? "Items collisions: off" : "Items collisions: on"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(interactiveitems.collisionCategories == Box.Category2) {
                        interactiveitems.collisionCategories = Box.All;
                    }
                    else {
                        interactiveitems.collisionCategories = Box.Category2;
                    }
                }
            }
        }
        Rectangle {
            id: robotButton
            x: 50
            y: 150
            width: 180
            height: 30
            Text {
                text: interactiveitems.showRobotChild ? "Hide robot/child" : "Control robot/child"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    interactiveitems.showRobotChild = !interactiveitems.showRobotChild;
                    if (interactiveitems.showRobotChild) {
                        robot.x=window.width - robotImg.width;
                        robot.y=window.height / 2 - robotImg.height / 2;
                    }
                }
            }
        }
        Rectangle {
            id: robotPublisherButton
            x: 50
            y: 200
            width: 180
            height: 30
            Text {
                text: interactiveitems.publishRobotChild ? "Stop publishing robot/child frames" : "Publish robot/child frames"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {interactiveitems.publishRobotChild = !interactiveitems.publishRobotChild;}
            }
        }
        Rectangle {
            id: gazeButton
            x: 50
            y: 250
            width: 180
            height: 30
            Text {
                text: gazeFocus.visible ? "Hide gaze" : "Show gaze"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    gazeFocus.visible = !gazeFocus.visible;
                }
            }
        }
        Rectangle {
            id: screenshotButton
            x: 350
            y: 250
            width: 180
            height: 30
            Text {
                text: "Take screenshot"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    sandbox.screenshot("/tmp/screenshot.png");
                       }
            }
        }
    }

    DebugDraw {
        id: debugDraw
        world: physicsWorld
        opacity: 0.75
        visible: false
    }

    Rectangle {
        id: fiducialmarker
        color:"white"
        opacity:0.8
        visible: false
        anchors.fill:parent

        Image {
            // set the actual size of the SVG page
            width: 0.60 / sandbox.pixel2meter
            height: 0.33 / sandbox.pixel2meter
            // make sure the image is in the corner ie, the sandtray origin
            x: 0
            y: 0
            fillMode: Image.PreserveAspectCrop
            source: "res/tags/markers.svg"

        }

        RosSignal {
            id: localising
            topic: "sandtray/signals/robot_localising"
            onTriggered: {
                    fiducialmarker.visible=true;
                    hide_fiducial_markers.start();
            }
        }

        Timer {
            id: hide_fiducial_markers
            interval: 5000; running: false; repeat: false
            onTriggered: {
                fiducialmarker.visible = false;
            }

        }

    }

    VisualAttentionCalibration {
        id: visualtracking
        visible: false
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

        //Rectangle {
        //    anchors.fill: parent
        //    color: "red"
        //}

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                debugToolbar.visible=true;
                clicks = 0;
                timerHideDebug.start();
            }
        }

        Timer {
            id: timerHideDebug
            interval: 5000; running: false; repeat: false
            onTriggered: {
                debugToolbar.visible = false;
            }

        }
    }

}
