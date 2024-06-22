import QtQuick
import Felgo

AppPage {
    id: ringPage
    property int alarmId: 0

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        AppText{
            anchors.horizontalCenter: parent.horizontalCenter
            id: ringingText
            text: "You've reached your destination!"
        }

        AppButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Stop the alarm"

            onClicked: {
                logic.toggleAlarm(alarmId, false)
                soundManager.music.stop()
                ringPage.navigationStack.popAllExceptFirst()
            }
        }
    }

    Component.onCompleted: {
        if(alarmId!== 0){
            var alarmDetails = dataModel.getAlarmDetails()
            ringPage.title = alarmDetails.title
        }
    }

    Timer {
        id: musicPlayback
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if(mainNavigationStack.currentPage != ringPage){
                var userLongitude = positionSource.position.coordinate.longitude
                var userLatitude = positionSource.position.coordinate.latitude
                // get data of all active alarms (lat, long, radius)
                var allAlarms = dataModel.allAlarms
                var activeAlarms = allAlarms.filter(function(alarm) {
                    return alarm.active
                })

                // cool math magic that calculates distance between user and alarm center
                // returns the distance in meters
                function measure(lat1, lon1, lat2, lon2){
                    const R = 6378.137; // Radius of earth in KM
                    var dLat = lat2 * Math.PI / 180 - lat1 * Math.PI / 180;
                    var dLon = lon2 * Math.PI / 180 - lon1 * Math.PI / 180;
                    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                    Math.sin(dLon/2) * Math.sin(dLon/2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                    var d = R * c;
                    return d * 1000; // meters
                }


                activeAlarms.forEach(function(activeAlarm) {
                    if(measure(activeAlarm.latitude, activeAlarm.longitude, userLatitude, userLongitude) < activeAlarm.radius ){
                        mainNavigationStack.push(ringPage, { alarmId: activeAlarm.id, title: activeAlarm.title })
                        soundManager.music.play()
                    }
                })
            }
        }
    }
}
