import Toybox.System;
import Toybox.Background;
import Toybox.Time;
import Toybox.UserProfile;
import Toybox.Timer;

(:background)
class TemporalServiceDelegate extends System.ServiceDelegate {


    function initialize () {
        System.println("Temporal Service delegate");
        System.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
            "$1$:$2$:$3$",
            [
                today.hour,
                today.min,
                today.sec,
            ]
        );
        System.println("Temporal event triggered at " + dateString);
        $.hrSensor.start();
    }

    function onSleepTime() {
        System.println("Sleep event triggered: setting active interval");

        BackgroundStorageManager.TestStatic();
        //if current time is after the earliest alarm time then check if an alarm should be triggered
        var earliestActiveAlarm = BackgroundStorageManager.getEarliestActiveAlarm();
        var latestActiveAlarm = BackgroundStorageManager.getLatestActiveAlarm();

        // // Create a moment of the current day at the earliest alarm time
        var earliestActiveAlarmMomentValue = Time.today().value() + (earliestActiveAlarm.earliestHour * 60 * 60) + (earliestActiveAlarm.earliestMinute * 60);
        var earliestActiveAlarmMoment = new Time.Moment(earliestActiveAlarmMomentValue);

        var nowMomentValue = Time.today().value() + ((earliestActiveAlarm.earliestHour + 1) * 60 * 60) + (earliestActiveAlarm.earliestMinute * 60);
        var nowMoment = new Time.Moment(nowMomentValue);

        var latestActiveAlarmMomentValue = Time.today().value() + (latestActiveAlarm.latestHour * 60 * 60) + (latestActiveAlarm.latestMinute * 60);
        var latestActiveAlarmMoment = new Time.Moment(latestActiveAlarmMomentValue);

        System.println("Current date time is:");
        printMoment(Time.now());
        System.println("Active alarm interval is:");
        printMoment(earliestActiveAlarmMoment);
        System.println("-");
        printMoment(latestActiveAlarmMoment);
    }

    function printMoment(moment) {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        System.println(Lang.format(
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