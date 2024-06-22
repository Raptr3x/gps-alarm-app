import QtQuick
import Felgo

AppPage {
    id: mainPage
    title: "GPS Alarm App"


    // specific model for json data
    JsonListModel {
        id: listModel
        // instead of dummy data, now we call them from the database
        source: dataModel.allAlarms
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
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "No alarms yet. Create a new alarm!"
        visible: !dataModel.allAlarms.length // if allAlarms is empty, we don't display this element
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
