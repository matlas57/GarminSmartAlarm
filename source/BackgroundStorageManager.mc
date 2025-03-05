import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

(:background)
class BackgroundStorageManager 
{

    static function TestStatic() {
        System.println("Reached module");
    }

    static function getNumAlarms() {
        var numAlarms = Storage.getValue("numAlarms");
        if (numAlarms == null) {
            return 0;
        }
        else {
            return numAlarms;
        }
    }

    static function getAlarmFromStorage(alarmNum) {
        if (!(alarmNum instanceof Number)){
            System.println("Invalid parameter alarmNum");
            return null;
        }
        else if (alarmNum > getNumAlarms()) {
            // TODO: Throw exception here
            System.println("Attempting to retrieve non-existing alarm");
            return null;
        }
        var alarmArray = Storage.getValue(alarmNum);
        System.println("Retrieved alarm " + alarmArray);

        if (alarmArray != null) {
            return new Alarm(alarmArray[0], alarmArray[1], alarmArray[2], alarmArray[3], alarmArray[4], alarmArray[5], alarmArray[6]);
        }
        // TODO: Throw exception here
        return null;
    }

    static function getActiveAlarms() {
        var numAlarms = getNumAlarms();
        if (numAlarms == 0) {
            return [];
        }
        var activeAlarms = [];
        for (var i = 0; i < numAlarms; i++) {
            var curAlarm = getAlarmFromStorage(i + 1);
            if (curAlarm.getActive()) {
                activeAlarms.add(curAlarm);
            }
        }
        // System.println("There are " + activeAlarms.size() + " active alarms");
        return activeAlarms;
    }

    static function getEarliestActiveAlarm() {
        var activeAlarms = getActiveAlarms();
        var n = activeAlarms.size();
        if (n == 0) {
            return [];
        }
        else if (n == 1) {
            System.println("Earliest alarm: " + activeAlarms[0].earliestHour + ":" + activeAlarms[0].earliestMinute);
            return activeAlarms[0];
        }
        else {
            // var joinedArray = [] as Lang.Array;
            // for (var i = 0; i < n; i++) {
            //     var joined = [activeAlarms[i].earliestHour * 100 + activeAlarms[i].earliestMinute, i];
            //     joinedArray.add(joined);
            // }
            // joinedArray.sort(null);
            // if (joinedArray.size() > 0) {
            //     System.println("earliest active alarm time is " + joinedArray[0][0] + " at index " + joinedArray[0][1]);
            //     //Convert back to an array for hour and minute to return
            //     // return [joinedArray[0] / 100, joinedArray[0] % 100];
            // }
            activeAlarms.sort(new EarliestAlarmComparator() as Lang.Comparator);
            System.println("Earliest active time is " + activeAlarms[0].earliestHour + ":" + activeAlarms[0].earliestMinute);
            return activeAlarms[0];
        }
    }

    static function getLatestActiveAlarm() {
        var activeAlarms = getActiveAlarms();
        var n = activeAlarms.size();
        if (n == 0) {
            return [];
        }
        else if (n == 1) {
            return activeAlarms[0];
        }
        else {
            activeAlarms.sort(new LatestAlarmComparator() as Lang.Comparator);
            System.println("Latest active time is " + activeAlarms[activeAlarms.size() - 1].latestHour + ":" + activeAlarms[activeAlarms.size() - 1].latestMinute);
            return activeAlarms[activeAlarms.size() - 1];
        }
    }
}