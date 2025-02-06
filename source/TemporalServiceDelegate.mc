import Toybox.System;
import Toybox.Background;
import Toybox.Time;
import Toybox.UserProfile;

(:background)
class TemporalServiceDelegate extends System.ServiceDelegate {

    var hrSensor;

    function initialize () {
        System.println("Temporal Service delegate");
        var profile = UserProfile.getProfile();
        var midnight = Time.today();
        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        profile.sleepTime = timeToDurationHelper(now.hour, now.min + 2, false);
        var sleepTimeDuration = profile.sleepTime;
        var sleepTimeMoment = midnight.add(sleepTimeDuration);
        var sleepTimeInfo = Gregorian.info(sleepTimeMoment, Time.FORMAT_MEDIUM);
        System.println(Lang.format(
            "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
            [
                sleepTimeInfo.hour,
                sleepTimeInfo.min,
                sleepTimeInfo.sec,
                sleepTimeInfo.day_of_week,
                sleepTimeInfo.day,
                sleepTimeInfo.month,
                sleepTimeInfo.year
            ])
        );
        Background.registerForSleepEvent();

        if (Background.getSleepEventRegistered()) {
            System.println("Sleep event registered at " + profile.sleepTime.value());
        }
        else {
            System.println("Sleep event not registered");
        }

        System.ServiceDelegate.initialize();
        self.hrSensor = new HeartRateSensor();
    }

    function onTemporalEvent() {
        hrSensor.start();
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
    }

    function timeToDurationHelper(hour, min, pm) as Time.Duration {
        if (pm) {
            hour += 12;
        }
        var seconds = ((hour * 60 + min) * 60);
        System.println("Seconds: " + seconds);
        return new Time.Duration(seconds);
    }

    function onSleepTime() {
        System.println("Sleep time");
    }

}