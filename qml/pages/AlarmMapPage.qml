import QtLocation
import QtQuick
import Felgo
import QtPositioning
import QtQuick.Controls

AppPage {
    id: alarmMapPage
    property int alarmId: 0

    rightBarItem: NavigationBarRow {
        Switch {
            id: alarmSwitch
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                logic.toggleAlarm(alarmId, alarmSwitch.checked)
            }
        }
        // we add a trash can button with a prompt if user wants to delete it
        IconButtonBarItem {
            iconType: IconType.trash
            iconSize: 25
            onClicked: {
                NativeUtils.displayMessageBox("Are you sure you want to delete this alarm?", "", 2)
            }
        }
    }

    // When page is loaded, we run a script to populate the page with needed data
    Component.onCompleted: {
        // could also be set in private var and then moved to the UI. this was just faster
        if(alarmMapPage.alarmId !== 0) {
            // populate UI if user is updating existing alarm
            var alarmDetails = dataModel.getAlarmDetails(alarmMapPage.alarmId)
            alarmMapPage.title = alarmDetails.title
            radiusSlider.value = alarmDetails.radius
            alarmSwitch.checked = alarmDetails.active
            circle.center = QtPositioning.coordinate(alarmDetails.latitude, alarmDetails.longitude)
            map.center = circle.center
            map.zoomLevel = (16 - Math.log(alarmDetails.radius/300)/Math.log(2))
        } else{
            alarmMapPage.title = "New Alarm"
            alarmSwitch.checked = true
        }

        // Fix the ugly translucent background on IOS button
        if(Theme.isIos){
            useThisLocBtn.flat = false
            useThisLocBtn.backgroundColor = "white"
        }
    }

    // creating the map over the whole page
    AppMap {
        id: map
        // to use maps, we need a map provider plugin
        // different plugins can be found in the documentation
        plugin: Plugin { name: "osm" }
        zoomLevel: 10
        showUserPosition: true
        // centering the map on user position
        center: QtPositioning.coordinate(
                    positionSource.position.coordinate.latitude,
                    positionSource.position.coordinate.longitude)
        anchors.fill: parent

        // We use Position source to get the user position which is used to center the map
        PositionSource {
            id: positionSource
            active: true
            onPositionChanged: {  // tracking the user movement
                var currentPosition = positionSource.position.coordinate
            }
        }
        MapCircle {
            id: circle
            // Won't be seeable untill center value set, taken from mouse click
            // circle radius comes from the slider (when slider value is taken from existing alarm)
            radius: radiusSlider.value
            color: "#aaa8eab2"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {  // setting radius circle position using mouse click
                var mouseCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                circle.center = mouseCoordinate
            }
        }
    }

    // adding white background for the settings
    Rectangle {
        id: newAlarmSettingsBackground
        color: "white"
        width: Window.width
        // making it a bit higher than it's content
        height: newAlarmSettings.height + 10
        border.color: "black"
        border.width: 1

        // workaround so clicks on the rectangle don't move the circle on the map
        MouseArea {
            anchors.fill: newAlarmSettingsBackground
            onClicked: {}
        }

        // using Column to keep subelements from coliding
        Column {
            id: newAlarmSettings
            padding: 5

            AppText {
                text: "Select the location at which the alarm will be triggered by clicking on the map"
                font.bold: true
                font.pixelSize: 16
                width: Window.width * 0.9
                wrapMode: Text.Wrap
                bottomPadding: 20
                leftPadding: 10
                topPadding: 5
            }

            AppText {
                // we divide by 1000 to get km from meters
                text: "Current radius: "+radiusSlider.value/1000+" km"
                font.pixelSize: 15
                width: Window.width * 0.9
                wrapMode: Text.Wrap
                leftPadding: 10
            }

            AppSlider {
                id: radiusSlider
                from: 0
                to: 100000
                value: 1000
                stepSize: 500
                bottomPadding: 0
                width: Window.width * 0.9
                onValueChanged: {
                    circle.radius = value
                }
            }
        }
    }

    // buttom right of the map, button to create the alarm with set values
    AppButton {
        id: useThisLocBtn
        text: "Use this location"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin:10
        anchors.rightMargin: 10
        onClicked: { // using javascript to display propmpts to the user
            if(circle.center.toString()){ // making sure center has been set
                var alarmName = "Creative Alarm Name"
                if(alarmMapPage.title != "New Alarm"){
                    alarmName = alarmMapPage.title
                }
                // text input and ok/cancel buttons
                NativeUtils.displayTextInput("Name your new alarm",
                                             "It's best to use a location name",
                                             "Creative Alarm Name", alarmName)
            } else {
                // basic information with "ok" button
                NativeUtils.displayAlertDialog("Alarm radius missing",
                                               "Please click on the map to select a radius from where you want the alarm to ring")
            }
        }
    }

    Connections {

        // We use connections component to handle signals from NativeUtils
        target: NativeUtils


        onMessageBoxFinished:
            accepted => {
                // when deleting an alarm and prompt is accepted, this send signals to remove and update the view list
                if(accepted){
                    logic.removeAlarm(alarmId)
                }
                logic.getAllAlarms()
                // move back to listView by removing everything from the navigation stack except first page
                alarmMapPage.navigationStack.popAllExceptFirst()
        }

        // After we enter a name for the alarm, we need to gather all data, build a json obj and store it by sending signal
        onTextInputFinished:
            (accepted, alarmName) => {
                if(accepted) {
                    var newAlarm = {
                        id: '', //will be assigend later when latest id is known
                        title: alarmName,
                        center: circle.center,
                        radius: radiusSlider.value,
                        latitude: circle.center.latitude,
                        longitude: circle.center.longitude,
                        active: alarmSwitch.checked
                    }
                    // send signals to store and update the view list
                    if(alarmId > 0){
                        newAlarm.id = alarmId
                        logic.updateAlarm(alarmId, newAlarm)
                    } else {
                        logic.storeAlarm(newAlarm)
                    }

                    logic.getAllAlarms()
                    // move back to listView by removing everything from the navigation stack except first page
                    alarmMapPage.navigationStack.popAllExceptFirst()
                }
        }
    }

}
