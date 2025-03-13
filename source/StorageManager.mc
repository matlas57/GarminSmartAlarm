import Toybox.System;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

/**
 * @file        StorageManager.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description StorageManager provides functions for fetching data from system storage
 */

(:background)
class StorageManager 
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

    static function getActiveAlarms() as Lang.Array<Alarm>{
        var numAlarms = getNumAlarms();
        if (numAlarms == 0) {
            return [];
        }
        var activeAlarms = [];
        for (var i = 0; i < numAlarms; i++) {
            var curAlarm = getAlarmFromStorage(i + 1);
            if (curAlarm.getActive() && curAlarm.isActiveToday()) {
                activeAlarms.add(curAlarm);
            }
        }
        System.println("There are " + activeAlarms.size() + " active alarms");
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

    static function setActiveAlarmInterval() {
        var earliestActiveAlarm = getEarliestActiveAlarm();
        if (earliestActiveAlarm != null){
            $.earliestActiveHour = earliestActiveAlarm.earliestHour;
            $.earliestActiveMinute = earliestActiveAlarm.earliestMinute;
            var earliestActiveAlarmMomentValue = Time.today().value() + (earliestActiveAlarm.earliestHour * 60 * 60) + (earliestActiveAlarm.earliestMinute * 60);
            $.earliestActiveMoment = new Time.Moment(earliestActiveAlarmMomentValue);
        }
        var latestActiveAlarm = getLatestActiveAlarm();
        if (latestActiveAlarm != null){
            $.latestActiveHour = latestActiveAlarm.latestHour;
            $.latestActiveMinute = latestActiveAlarm.latestMinute;
            var latestActiveAlarmMomentValue = Time.today().value() + (latestActiveAlarm.latestHour * 60 * 60) + (latestActiveAlarm.latestMinute * 60);
            $.latestActiveMoment = new Time.Moment(latestActiveAlarmMomentValue);
        }
    }

    static function addNewAlarmToStorage(alarm) {
        var numAlarms = getNumAlarms();
        var curAlarm = numAlarms + 1;
        
        var alarmArray = [
            alarm.earliestHour,
            alarm.earliestMinute,
            alarm.latestHour,
            alarm.latestMinute,
            alarm.active,
            alarm.delete
        ];
        alarmArray.add(alarm.repeatArray);
        System.println("Adding new alarmArray to storage :" + alarmArray.toString());
        try {
            Storage.setValue(curAlarm, alarmArray);
            Storage.setValue("numAlarms", curAlarm);
            setActiveAlarmInterval();
        } catch (e instanceof Lang.Exception) {
            System.println(e.getErrorMessage());
            // TODO: Add window here to indicate that alarms need to be deleted before more can be added
        }
    }

    static function editAlarmInStorage(alarmId, alarm) {
        var numAlarms = getNumAlarms();
        if (alarmId > numAlarms) {
            // TODO: Throw exception here
            System.println("Invalid id");
            return;
        }
        var alarmArray = [
            alarm.earliestHour,
            alarm.earliestMinute,
            alarm.latestHour,
            alarm.latestMinute,
            alarm.active,
            alarm.delete
        ];
        alarmArray.add(alarm.repeatArray);
        Storage.setValue(alarmId, alarmArray);
        setActiveAlarmInterval();
        return;
    }

    static function reorganizeStorage() {
        var numAlarms = getNumAlarms();
        if (numAlarms  == 0) {
            return;
        }
        else {
            var newKey = 1;
            var alarmsDeleted = 0;
            for (var i = 1; i <= numAlarms; i++) {
                var alarm = getAlarmFromStorage(i);
                if (alarm.delete) {
                    System.println("Deleting alarm " + i.toString());
                    Storage.deleteValue(i);
                    alarmsDeleted++;
                } 
                else {
                    if (i != newKey) {
                        editAlarmInStorage(newKey, alarm);
                        Storage.deleteValue(i);
                    }
                    newKey++;
                }
            }
            Storage.setValue("numAlarms", numAlarms - alarmsDeleted);
        }
        return;
    }
}