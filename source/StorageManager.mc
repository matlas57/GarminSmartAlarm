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
        SmartAlarmApp.debugLog("Reached module");
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
            SmartAlarmApp.debugLog("Invalid parameter alarmNum");
            return null;
        }
        else if (alarmNum > getNumAlarms()) {
            // TODO: Throw exception here
            SmartAlarmApp.debugLog("Attempting to retrieve non-existing alarm");
            return null;
        }
        var alarmArray = Storage.getValue(alarmNum);
        SmartAlarmApp.debugLog("Retrieved alarm " + alarmArray);

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
        SmartAlarmApp.debugLog("There are " + activeAlarms.size() + " active alarms");
        return activeAlarms;
    }

    static function getEarliestActiveAlarm() {
        var activeAlarms = getActiveAlarms();
        var n = activeAlarms.size();
        if (n == 0) {
            return [];
        }
        else if (n == 1) {
            SmartAlarmApp.debugLog("Earliest alarm: " + activeAlarms[0].earliestHour + ":" + activeAlarms[0].earliestMinute);
            return activeAlarms[0];
        }
        else {
            activeAlarms.sort(new EarliestAlarmComparator() as Lang.Comparator);
            SmartAlarmApp.debugLog("Earliest active time is " + activeAlarms[0].earliestHour + ":" + activeAlarms[0].earliestMinute);
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
            SmartAlarmApp.debugLog("Latest active time is " + activeAlarms[activeAlarms.size() - 1].latestHour + ":" + activeAlarms[activeAlarms.size() - 1].latestMinute);
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
        SmartAlarmApp.debugLog("Adding new alarmArray to storage :" + alarmArray.toString());
        try {
            Storage.setValue(curAlarm, alarmArray);
            Storage.setValue("numAlarms", curAlarm);
            setActiveAlarmInterval();
        } catch (e instanceof Lang.Exception) {
            SmartAlarmApp.debugLog(e.getErrorMessage());
            // TODO: Add window here to indicate that alarms need to be deleted before more can be added
        }
    }

    static function editAlarmInStorage(alarmId, alarm) {
        var numAlarms = getNumAlarms();
        if (alarmId > numAlarms) {
            // TODO: Throw exception here
            SmartAlarmApp.debugLog("Invalid id");
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
                    SmartAlarmApp.debugLog("Deleting alarm " + i.toString());
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

    static function addOvernightAverage(avg) {
        var overnightAveragesArray = Storage.getValue("overnightAverages");
        if (overnightAveragesArray == null) {
            overnightAveragesArray = [];  
        }
        overnightAveragesArray.add(avg);
        Storage.setValue("overnightAverages", overnightAveragesArray);
    }

    static function getOvernightAverages() {
        return Storage.getValue("overnightAverages");
    }

    static function addTriggeredAlarmTime(time) {
        var triggeredAlarmTimesArray = Storage.getValue("triggeredAlarms");
        if (triggeredAlarmTimesArray == null) {
            triggeredAlarmTimesArray = [];  
        }
        triggeredAlarmTimesArray.add(time);
        Storage.setValue("triggeredAlarms", triggeredAlarmTimesArray);
    }

    static function getTriggeredAlarmTimes() {
        return Storage.getValue("triggeredAlarms");
    }

    static function getNumAlarmChecks() {
        var numAlarmChecks = Storage.getValue("numAlarmChecks");
        if (numAlarmChecks == null) {
            SmartAlarmApp.debugLog("0 Alarm checks in storage");
            return 0;
        }
        else {
            SmartAlarmApp.debugLog(numAlarmChecks + " Alarm checks in storage");
            return numAlarmChecks;
        }
    }

    static function addAlarmCheckToStorage(alarmCheck) {
        var numAlarmChecks = getNumAlarmChecks();
        var curAlarmCheck = numAlarmChecks + 1;
        
        var alarmCheckArray = [
            alarmCheck.timeString,
            alarmCheck.sdann,
            alarmCheck.beforeSDNN,
            alarmCheck.duringSDNN,
            alarmCheck.afterSDNN,
            alarmCheck.predictedResult,
            alarmCheck.actualResult
        ];
        try {
            var id = "alarmCheck" + curAlarmCheck.toString();
            Storage.setValue(id, alarmCheckArray);
            Storage.setValue("numAlarmChecks", curAlarmCheck);
            SmartAlarmApp.debugLog("Added alarm check " + id + " to storage");
        } catch (e instanceof Lang.Exception) {
            SmartAlarmApp.debugLog(e.getErrorMessage());
        }
    }

    static function getAlarmCheckFromStorage(alarmCheckNum) {
        if (!(alarmCheckNum instanceof Number)) {
            SmartAlarmApp.debugLog("Invalid parameter alarmCheckNum");
            return null;
        }
        else if (alarmCheckNum > getNumAlarmChecks()) {
            SmartAlarmApp.debugLog("Attempting to retrieve non-existing alarm");
            return null;
        }
        var id = "alarmCheck" + alarmCheckNum.toString();
        var alarmCheckArray = Storage.getValue(id);
        SmartAlarmApp.debugLog("Retrieved alarmCheck " + alarmCheckArray);

        if (alarmCheckArray != null) {
            return new AlarmCheck(alarmCheckArray[0], alarmCheckArray[1], alarmCheckArray[2], alarmCheckArray[3], alarmCheckArray[4], alarmCheckArray[5], alarmCheckArray[6]);
        }
        return null;
    }

    static function addActualResultToAlarmCheck(alarmCheckNum, actualResult) {
        if (!(alarmCheckNum instanceof Number)) {
            SmartAlarmApp.debugLog("Invalid parameter alarmCheckNum");
            return;
        }
        else if (alarmCheckNum > getNumAlarmChecks()) {
            SmartAlarmApp.debugLog("Attempting to retrieve non-existing alarm");
            return;
        }

        var id = "alarmCheck" + alarmCheckNum.toString();
        var alarmCheckArray = Storage.getValue(id);
        SmartAlarmApp.debugLog("Retrieved alarmCheck " + alarmCheckArray);

        if (alarmCheckArray != null) {
            alarmCheckArray[6] = actualResult;
            Storage.setValue(id, alarmCheckArray);
        }
    }

    static function clearAlarmChecks() {
        var n = getNumAlarmChecks();
        for (var i = 1; i <= n; i++) {
            var id = "alarmCheck" + i.toString();
            Storage.deleteValue(id);
        }
        Storage.deleteValue("numAlarmChecks");
        n = getNumAlarmChecks();
        SmartAlarmApp.debugLog("There are now " + n + " alarm checks in storage");
    }

    static function getThreshold() {
        return Storage.getValue("threshold");
    }

    static function setThreshold(threshold) {
        Storage.setValue("threshold", threshold);
    }

    static function getTolerance() {
        return Storage.getValue("tolerance");
    }

    static function setTolerance(tolerance) {
        Storage.setValue("tolerance", tolerance);
    }
}