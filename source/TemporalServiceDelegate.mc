import Toybox.System;
import Toybox.Background;

(:background)
class TemporalServiceDelegate extends System.ServiceDelegate {

    function initialize () {
        System.println("Event handler created");
        System.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        System.println("Temporal event triggered");
    }
}