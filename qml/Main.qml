import Felgo
import QtQuick
import "pages"
// we had to import new directories
import "models"
import "logic"

App {
    id: app

    // when App loads, we will request all alarms from the database
    Component.onCompleted: {
        logic.getAllAlarms()
//        app.settings.clearAll()

    }

    // Other pages will be displayed by appending them to this stack
    // And closed by removing them as well
    NavigationStack {
        id: mainNavigationStack
        initialPage: AlarmListPage { }
    }

    Component {
        id: alarmMapPage
        AlarmMapPage {

        }
    }

    // add Logic and DataModel components with their ids so they can be referenced later
    Logic {
        id: logic
    }

    DataModel {
        id: dataModel
        dispatcher: logic // used for signal handlers
    }


}
