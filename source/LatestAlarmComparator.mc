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