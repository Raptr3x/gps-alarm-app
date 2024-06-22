import Felgo
import QtQuick
import QtMultimedia
import QtPositioning
import "./pages"
import "./logic"
import "./models"

App {
    id: app

    Component.onCompleted: {
        logic.getAllAlarms()
//        app.settings.clearAll()
    }

    SoundManager {
        id: soundManager
    }

    AlarmRing {
        id: alarmRingPage
    }

    NavigationBar {
        rightBarItem: NavigationBarRow{
            id: switchButton
        }
    }
    // used to trigger alarm
    PositionSource {
        id: positionSource
        active: true
        onPositionChanged: {
            var currentPosition = positionSource.position.coordinate
        }
    }

    NavigationStack {
        id: mainNavigationStack
        initialPage: AlarmsListPage { }
    }

    DataModel {
        id: dataModel
        dispatcher: logic
    }

    Logic {
        id: logic
    }
}
