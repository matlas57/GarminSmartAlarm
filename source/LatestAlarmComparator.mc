/**
 * @file        LatestAlarmComparator.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description LatestAlarmComparator provides a function used by sorting functions to sort alarm objects by their latest alarm
 */

(:background)
class LatestAlarmComparator {
    function compare(a as Alarm, b as Alarm) {
        var aNextMoment = a.getNextLatestTimeMoment();
        var bNextMoment = b.getNextLatestTimeMoment();

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