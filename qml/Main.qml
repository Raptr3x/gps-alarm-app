import Felgo
import QtQuick
import "pages"

App {
    id: app

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
}
