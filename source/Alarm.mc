import Toybox.Lang;

class Alarm {
    var earliestHour as Lang.Number;
    var earliestMinute as Lang.Number;
    var latestHour as Lang.Number;
    var latestMinute as Lang.Number;

    function initialize(eh, em, lh, lm) {
        earliestHour = eh;
        earliestMinute = em;
        latestHour = lh;
        latestMinute = lm;
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