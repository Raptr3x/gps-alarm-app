import QtQuick
import Felgo

AppPage {
    id: mainPage
    title: "GPS Alarm App"

    // Dummy data for the list
    property var allAlarms: [
        {"id":1, "title":"Test 1", "center":"CenterObj", "radius":100, "latitude": 50.123, "longitude": -22.51, "active": true},
        {"id":2, "title":"Test 2", "center":"CenterObj", "radius":100, "latitude": 50.123, "longitude": -22.51, "active": false}
    ]

    // specific model for json data
    JsonListModel {
        id: listModel
        source: mainPage.allAlarms // list of json objects which we will iterate later
        keyField: "id"
        // all fields we're giving access to in the source json
        fields: ["id", "title", "center", "radius", "latitude", "longitude", "active"]
    }

    AppListView {
        id: listView
        anchors.fill: parent
        model: listModel // we're taking the json model
        // and using "delegate" we iterate it
        delegate: SimpleRow { // each iterated object is displayed using SimpleRow
            text: model.title // we can access the json object using "model" keyword
            detailText: "Alarm is ".concat(model.active ? "on" : "off")
        }
    }

    AppText {
        text: "No alarms yet. Create a new alarm!"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        visible: !allAlarms // if allAlarms is empty, we don't display this element
    }

    AppButton {
        text: "Create a new alarm"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin:10
        anchors.rightMargin: 10
        onClicked: mainPage.navigationStack.push(alarmMapPage)
    }
}
