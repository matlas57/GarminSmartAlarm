import Toybox.System;
import Toybox.Background;
import Toybox.Time;

(:background)
class TemporalServiceDelegate extends System.ServiceDelegate {

    var hrSensor;

    function initialize () {
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

}