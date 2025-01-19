import Toybox.Lang;

class Alarm {
    var earliestHour as Lang.Number;
    var earliestMinute as Lang.Number;
    var latestHour as Lang.Number;
    var latestMinute as Lang.Number;

    var active as Lang.Boolean;

    var delete as Lang.Boolean;

    function initialize(eh, em, lh, lm, a, d) {
        earliestHour = eh;
        earliestMinute = em;
        latestHour = lh;
        latestMinute = lm;
        active = a;
        delete = d;
    }

    function toggleActive() {
        active = !active;
        System.println("active set to " + active);
    }

    function setDelete(d) {
        delete = d;
    }

    function isValid() as Boolean{
        if (
            earliestHour != null 
            && earliestMinute != null
            && latestHour != null 
            && latestMinute != null
        ) {
            return true;
        }
        return false;
    }


}