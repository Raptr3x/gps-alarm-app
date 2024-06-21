import QtLocation
import QtQuick
import Felgo
import QtPositioning
import QtQuick.Controls

AppPage {
    id: alarmMapPage

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

}
