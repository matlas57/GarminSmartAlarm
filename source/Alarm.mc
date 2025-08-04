import Toybox.Lang;
import Toybox.Time;

/**
 * @file        Alarm.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description Alarm class represents an interval of time where an alarm is permissible
 *
 *  The earliest hour and minute represent the earliest possible time an alarm can be triggered
 *  The latest hour and minute represent the time an alarm was triggered if the app did not detect wakefulness throughout the entire interval
 *  The active flag represents if the alarm is on or off
 *  The repeatArray represents the repeat setting as an array of seven booleans. If the array is empty the setting is set to once
 *  The delete flag marks an alarm for deletion when StorageManager.reorganizeStorage is called  
 */

(:background)
class Alarm {
    var earliestHour as Lang.Number;
    var earliestMinute as Lang.Number;
    var earliestAm as Lang.Boolean;
    var latestHour as Lang.Number;
    var latestMinute as Lang.Number;
    var latestAm as Lang.Boolean;

    var active as Lang.Boolean;

    var repeatArray as Lang.Array<Lang.Boolean>;

    var delete as Lang.Boolean;

    function initialize(eh, em, eam, lh, lm, lam, a, d, ra) {
        earliestHour = eh;
        earliestMinute = em;
        earliestAm = eam;
        latestHour = lh;
        latestMinute = lm;
        latestAm = lam;
        active = a;
        delete = d;
        repeatArray = ra;
    }

    function getActive() {
        return active;
    }

    function toggleActive() {
        active = !active;
        SmartAlarmApp.debugLog("active set to " + active);
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

    function isActiveToday() {
        if (repeatArray.size() == 0) {
            return true;
        }
        var today = Time.Gregorian.info(new Time.Moment(Time.today().value()), Time.FORMAT_SHORT);
        var dayOfWeek = today.day_of_week - 1;
        if (repeatArray[dayOfWeek]) {
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
            if (!earliestAm && earliestHour != 12) {
                tomorrow.hour = earliestHour + 12;
            }
            else {
                tomorrow.hour = earliestHour;
            }
            tomorrow.min = earliestMinute;
            info = tomorrow;
        }
        else {
            var today = Time.Gregorian.info(new Time.Moment(Time.today().value()), Time.FORMAT_SHORT);
            if (!earliestAm && earliestHour != 12) {
                today.hour = earliestHour + 12;
            }
            else {
                today.hour = earliestHour;
            }
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
            if (!latestAm && latestHour != 12) {
                tomorrow.hour = latestHour + 12;
            }
            else {
                tomorrow.hour = latestHour;
            }
            tomorrow.min = latestMinute;
            info = tomorrow;
        }
        else {
            var today = Time.Gregorian.info(new Time.Moment(Time.today().value()), Time.FORMAT_SHORT);
            if (!latestAm && latestHour != 12) {
                today.hour = latestHour + 12;
            }
            else {
                today.hour = latestHour;
            }
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
        SmartAlarmApp.debugLog(Lang.format(
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
        SmartAlarmApp.debugLog(repeatArray.toString());
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
            SmartAlarmApp.debugLog("Making custom repeat string");
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
        SmartAlarmApp.debugLog("Setting repeat label");
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

    function makeAlarmString() {
        return earliestHour.toString() + ":" + padMinuteString(earliestMinute) + " - " + latestHour.toString() + ":" + padMinuteString(latestMinute);
    }

    static function padMinuteString(minute) {
        if (minute < 10) {
            return "0" + minute.toString();
        } 
        else {
            return minute.toString();
        }
    }
}