import QtQuick
import Felgo

Item {

    signal getAllAlarms()

    signal storeAlarm(var alarm)

    signal toggleAlarm(int id, bool state)

    signal updateAlarm(int id, var alarm)

    signal removeAlarm(int id)

}
