import Toybox.Lang;
import Toybox.Time;

class Alarm {
    var earliestHour as Lang.Number;
    var earliestMinute as Lang.Number;
    var latestHour as Lang.Number;
    var latestMinute as Lang.Number;

    var active as Lang.Boolean;

    var repeatArray;

    var delete as Lang.Boolean;

    function initialize(eh, em, lh, lm, a, d, ra) {
        earliestHour = eh;
        earliestMinute = em;
        latestHour = lh;
        latestMinute = lm;
        active = a;
        delete = d;
        repeatArray = ra;
    }

    function getActive() {
        return active;
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
            today.min = earliestMinute;
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

    //TODO: Find a better way for array comparison
    function getRepeatLabel() {
        System.println(repeatArray.toString());
        if (repeatArray.size() == 0) {
            return "Once";
        }
        else if (repeatArray.toString().equals("[true, true, true, true, true, true, true]")) {
            return "Daily";
        }
        else if (repeatArray.toString().equals("[false, true, true, true, true, true, false]")) {
            return "Weekday";
        } 
        else if (repeatArray.toString().equals("[true, false, false, false, false, false, true]")) {
            return "Weekend";
        } 
        else {
            System.println("Making custom repeat string");
            var indexToDayPrefixDict = {
                0 => "Sun",
                1 => "Mon",
                2 => "Tue",
                3 => "Wed",
                4 => "Thu",
                5 => "Fri",
                6 => "Sat"
            };
            var label = "";
            for (var i = 0; i < repeatArray.size(); i++) {
                if (repeatArray[i] == true){
                    label += indexToDayPrefixDict.get(i);
                    label += ", ";
                }
            }
            label = label.substring(0, label.length() - 2);
            return label;
        } 
        
    }

    function setRepeatByLabel(label) {
        System.println("Setting repeat label");
        if (label.equals("once")) {
            repeatArray = [];
        }
        else if (label.equals("daily")) {
            repeatArray = [true, true, true, true, true, true, true];
        }
        else if (label.equals("weekday")) {
            repeatArray = [false, true, true, true, true, true, false];
        }
        else if (label.equals("weekend")) {
            repeatArray = [true, false, false, false, false, false, true];
        }
    }

    function setRepeatByArray(repeatArray) {
        self.repeatArray = repeatArray;
    }

}