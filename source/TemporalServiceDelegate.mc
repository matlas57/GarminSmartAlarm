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
        System.println("Sleep event triggered");
    }

    function timeToDurationHelper(hour, min, pm) as Time.Duration {
        if (pm) {
            hour += 12;
        }
        var seconds = ((hour * 60 + min) * 60);
        return new Time.Duration(seconds);
    }
}