import Toybox.Lang;
import Toybox.Time;

class Alarm {
    var earliestHour as Lang.Number;
    var earliestMinute as Lang.Number;
    var latestHour as Lang.Number;
    var latestMinute as Lang.Number;

    var active as Lang.Boolean;

    var repeatArray = [];

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

    function getNextEarliestTimeMoment(){
        var curTime = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var info;

        if (curTime.hour > earliestHour) {
            var tomorrow = Time.Gregorian.info(
                (new Time.Moment(Time.today().value()).add(new Time.Duration(Gregorian.SECONDS_PER_DAY))),
                Time.FORMAT_SHORT
            );
            tomorrow.hour = earliestHour;
            tomorrow.min = earliestMinute;
            info = tomorrow;
        }
        else {
            var today = Time.Gregorian.info(new Time.Moment(Time.today().value()), Time.FORMAT_SHORT);
            today.hour = earliestHour;
            today.hour = earliestMinute;
            info = today;
        }
        printGregorianInfo(info);
        return Time.Gregorian.moment({
            :year => info.year,
            :month => info.month,
            :day => info.day,
            :hour => info.hour,
            :minute => info.min,
            :second => info.sec
        });
    }

    function getNextLatestTimeMoment(){
        var curTime = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var info;

        if (curTime.hour > latestHour) {
            var tomorrow = Time.Gregorian.info(
                (new Time.Moment(Time.today().value()).add(new Time.Duration(Gregorian.SECONDS_PER_DAY))),
                Time.FORMAT_SHORT
            );
            tomorrow.hour = latestHour;
            tomorrow.min = latestMinute;
            info = tomorrow;
        }
        else {
            var today = Time.Gregorian.info(new Time.Moment(Time.today().value()), Time.FORMAT_SHORT);
            today.hour = latestHour;
            today.hour = latestMinute;
            info = today;
        }
        printGregorianInfo(info);
        return Time.Gregorian.moment({
            :year => info.year,
            :month => info.month,
            :day => info.day,
            :hour => info.hour,
            :minute => info.min,
            :second => info.sec
        });
    }
    
    function printGregorianInfo(info){
        System.println(Lang.format(
            "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
            [
                info.hour,
                info.min,
                info.sec,
                info.day_of_week,
                info.day,
                info.month,
                info.year
            ])
        );
    }

}