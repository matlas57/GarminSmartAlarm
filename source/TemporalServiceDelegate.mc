import Toybox.System;
import Toybox.Background;
import Toybox.Time;
import Toybox.UserProfile;

(:background)
class TemporalServiceDelegate extends System.ServiceDelegate {

    var hrSensor;

    function initialize () {
        System.println("Temporal Service delegate");
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
        return new Time.Duration(seconds);
    }
}