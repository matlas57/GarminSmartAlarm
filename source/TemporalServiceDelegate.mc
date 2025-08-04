import Toybox.System;
import Toybox.Background;
import Toybox.Time;
import Toybox.UserProfile;
import Toybox.Timer;

/**
 * @file        TemporalServiceDelegate.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description TemporalServiceDelegate manages handling background events
 */

(:background)
class TemporalServiceDelegate extends System.ServiceDelegate {


    function initialize () {
        SmartAlarmApp.debugLog("Temporal Service delegate");
        System.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        System.println("Temporal event triggered");
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
            "$1$:$2$:$3$",
            [
                today.hour,
                today.min,
                today.sec,
            ]
        );
        SmartAlarmApp.debugLog("Temporal event triggered at " + dateString);
        if ($.appState.equals("TriggerAlarm")) {
            System.println("Triggering alarm");
            WatchUi.pushView(new WakeUpView(), new WakeUpViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
            $.appState = "trackSleep";
        }
        else {
            $.hrSensor.start();
        }
    }

    function onSleepTime() {
        SmartAlarmApp.debugLog("Sleep event triggered: setting active interval");

        //if current time is after the earliest alarm time then check if an alarm should be triggered
        var earliestActiveAlarm = StorageManager.getEarliestActiveAlarm();
        var latestActiveAlarm = StorageManager.getLatestActiveAlarm();

        // // Create a moment of the current day at the earliest alarm time
        var earliestActiveAlarmMomentValue = Time.today().value() + (earliestActiveAlarm.earliestHour * 60 * 60) + (earliestActiveAlarm.earliestMinute * 60);
        $.earliestActiveMoment = new Time.Moment(earliestActiveAlarmMomentValue);

        var latestActiveAlarmMomentValue = Time.today().value() + (latestActiveAlarm.latestHour * 60 * 60) + (latestActiveAlarm.latestMinute * 60);
        $.latestActiveMoment = new Time.Moment(latestActiveAlarmMomentValue);

        //Register for temporal events
        //register for a new event in 5 minutes
        var nowMoment = Time.now();
        var nextEventMoment = nowMoment.add(new Time.Duration(300));
        SmartAlarmApp.debugLog("Registering for next HRV reading event");
        Background.registerForTemporalEvent(nextEventMoment);
    }

    function onWakeTime() as Void {
        Background.deleteTemporalEvent();
    }

    function printMoment(moment) {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        SmartAlarmApp.debugLog(Lang.format(
            "Moment: $1$:$2$:$3$ $4$/$5$/$6$",
            [
                info.hour,
                info.min,
                info.sec,
                info.month,
                info.day,
                info.year
            ])
        );
    }

    function timeToDurationHelper(hour, min, pm) as Time.Duration {
        if (pm) {
            hour += 12;
        }
        var seconds = ((hour * 60 + min) * 60);
        return new Time.Duration(seconds);
    }
}