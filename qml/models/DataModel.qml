import QtQuick
import Felgo

Item {
    id: dataModel
    property alias dispatcher: logicConnection.target

    readonly property var allAlarms: _this.alarms

    // listen to actions from dispatcher
    Connections {
        id: logicConnection


        onGetAllAlarms: {
            // ran from main on init
            _this.alarms = _this.getAllAlarms(app.settings.getValue('alarms'))
        }

        onStoreAlarm:
            newAlarm => {
                newAlarm.id = _this.alarms.length+1
                _this.alarms.push(newAlarm) // add to private list
                app.settings.setValue("alarms", _this.alarms) // and overwrite it in the database
                logic.getAllAlarms() // update the public property so the ListView will have updated values
        }

        onUpdateAlarm:
            (id, updatedAlarm) => {
                // could also be done with forEach, wanted to show another approach
                // also forEach doesn't have break; option
                for (var i = 0; i < _this.alarms.length; i++) {
                    if (_this.alarms[i].id === id) {
                        _this.alarms[i] = updatedAlarm; // overwriting  the alarm in private list
                        break;
                    }
                }
                app.settings.setValue("alarms", _this.alarms);  // overwriting  the list in the db
                logic.getAllAlarms() // update the public property so the ListView will have updated values
            }

        onRemoveAlarm:
            id => {
                for (var i = 0; i < _this.alarms.length; i++) {
                    if (_this.alarms[i].id === id){
                         _this.alarms.splice(i, 1);  // removing from the list
                         break;
                    }
                }
                app.settings.setValue("alarms", _this.alarms) // overwriting  the list in the db
                logic.getAllAlarms() // update the public property so the ListView will have updated values
            }

        onToggleAlarm:
            (id, newState) => {
                for (var i = 0; i < _this.alarms.length; i++) {
                    if (_this.alarms[i].id === id){
                        _this.alarms[i].active = newState; // overwriting the alarm state
                        break;
                    }
                }
                app.settings.setValue("alarms", _this.alarms)
                logic.getAllAlarms() // update the public property so the ListView will have updated values
            }
    }

    function getAlarmDetails(alarmId){
        var alarmData = {}
        _this.alarms.forEach(function(item) {
            if(alarmId === item.id){
                alarmData = item
            }
        })
        return alarmData
    }

    // we use these private properties for working with data and offer readonly alias of this for public access
    Item {
        id: _this

        // data properties
        property var alarms: []

        function getAllAlarms(dataSource){
            // building a list of json objects that represent Alarms
            if(dataSource){
                var dataMap = dataSource.map(function(data){
                    return {
                        id: data.id,
                        title: data.title,
                        center: data.center,
                        radius: data.radius,
                        latitude: data.latitude,
                        longitude: data.longitude,
                        active: data.active
                    }
                })
                return dataMap
            }
            return []
        }

    }
}
