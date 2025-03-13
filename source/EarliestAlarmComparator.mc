/**
 * @file        EarliestAlarmComparator.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description EarliestAlarmComparator provides a function used by sorting functions to sort alarm objects by their earliest alarm
 */

(:background)
class EarliestAlarmComparator {
    function compare(a as Alarm, b as Alarm) {
        var aNextMoment = a.getNextEarliestTimeMoment();
        var bNextMoment = b.getNextEarliestTimeMoment();

        var comparison = aNextMoment.compare(bNextMoment);
        if (comparison < 0) {
            return -1;
        }
        else if (comparison > 0) {
            return 1;
        }
        else {
            return 0;
        }
    }
}