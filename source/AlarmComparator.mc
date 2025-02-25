class AlarmComparator {
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