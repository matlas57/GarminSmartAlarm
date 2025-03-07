import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;

class SmartAlarmDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var alarmsMenu = new WatchUi.Menu2({:title=>"Alarms"});
        var numAlarms = getNumAlarms();
        for (var i = 1; i <= numAlarms; i++ ) {
            var alarm = getAlarmFromStorage(i);
            var alarmString = makeAlarmString(alarm);
            System.println(alarmString);
            // alarm.getNextEarliestTimeMoment();
            alarmsMenu.addItem(
                new ToggleMenuItem(
                    alarmString,                          //labal
                    alarm.getRepeatLabel(),           //sublabel   
                    i,                                    //id   
                    alarm.active,          //is toggle enabled  
                    {}                                    //dictionary of options: can include text alignment, icon   
                )
            );
        }
        alarmsMenu.addItem(
            new MenuItem (
                "Add Alarm",
                "",
                "addAlarmButton",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Get Active Alarms",
                "",
                "getActiveAlarms",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Print Active Interval",
                "",
                "printActiveInterval",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Test Vibration",
                "",
                "testVibration",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Print next event",
                "",
                "getNextTemporalEvent",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Delete next event",
                "",
                "deleteNextTemporalEvent",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Get Heart Rate",
                "",
                "getHR",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem (
                "Stop Recording",
                "",
                "stopHR",
                {}
            )
        );

        WatchUi.pushView(alarmsMenu, new SmartAlarmMenuDelegate(alarmsMenu), WatchUi.SLIDE_UP);
        return true;
    }

    /*
    Keycodes
    4: Start/Stop
    5: Back
    8: Down
    13: Up
    */
    function onKey(keyEvent) {
        if (appState.equals("earliestAlarmPrompt")) {
            if (step == 0) {
                if (keyEvent.getKey() == 13) {
                    earliestHour++;
                    if (earliestHour > 12) {
                        earliestHour = 1;
                    }
                }
                else if (keyEvent.getKey() == 8) {
                    earliestHour--;
                    if (earliestHour < 1) { 
                        earliestHour = 12;
                    }
                }
                else if (keyEvent.getKey() == 4) {
                    step++;
                }
                else if (keyEvent.getKey() == 5) {
                    WatchUi.popView(WatchUi.SLIDE_LEFT);
                }
            }
            else if (step == 1) {
                if (keyEvent.getKey() == 13) {
                    earliestMinute++;
                    if (earliestMinute > 59) {
                        earliestMinute = 0;
                    }
                }
                else if (keyEvent.getKey() == 8) {
                    earliestMinute--;
                    if (earliestMinute < 1) {
                        earliestMinute = 59;
                    }
                }
                else if (keyEvent.getKey() == 4) {
                    step++;
                }
            }
            else if (step == 2 && keyEvent.getKey() == 4) {
                appState = "latestAlarmPrompt";
                step = 0;
            }

            if (keyEvent.getKey() == 5 && step > 0) {
                step--;
            }    
        }
        else if (appState.equals("latestAlarmPrompt")) {
            if (step == 0) {
                if (keyEvent.getKey() == 13) {
                    latestHour++;
                    if (latestHour > 12) {
                        latestHour = 1;
                    }
                }
                else if (keyEvent.getKey() == 8) {
                    latestHour--;
                    if (latestHour < 1) { 
                        latestHour = 12;
                    }
                }
                else if (keyEvent.getKey() == 4) {
                    step++;
                }
                else if (keyEvent.getKey() == 5) {
                    appState = "earliestAlarmPrompt";
                    step = 2;
                }
            }
            else if (step == 1) {
                if (keyEvent.getKey() == 13) {
                    latestMinute++;
                    if (latestMinute > 59) {
                        latestMinute = 0;
                    }
                }
                else if (keyEvent.getKey() == 8) {
                    latestMinute--;
                    if (latestMinute < 1) {
                        latestMinute = 59;
                    }
                }
                else if (keyEvent.getKey() == 4 && validLatestTime) {
                    step++;
                }
                else if (keyEvent.getKey() == 5) {
                    step--;
                }
            }
            else if (step == 2) {
                if (keyEvent.getKey() == 4) {
                    var alarm = new Alarm(earliestHour, earliestMinute, latestHour, latestMinute, true, false, []);

                    if (editAlarmId == 0) {
                        addNewAlarmToStorage(alarm);
                        onMenu();
                    } 
                    else if (editAlarmId > 0) {
                        editAlarmInStorage(editAlarmId, alarm);
                        WatchUi.popView(WatchUi.SLIDE_LEFT);
                    }

                    appState = "trackSleep";
                    step = 0;
                    earliestHour = 6;
                    earliestMinute = 0;
                    latestHour = 7;
                    latestMinute = 0;
                }
                else if (keyEvent.getKey() == 5) {
                    step--;
                }
            }
        }

        WatchUi.requestUpdate();

        return true;
    }

    function onHold(clickEvent) {
        Storage.clearValues();
        System.println("Cleared storage");

        WatchUi.requestUpdate();

        return true;
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType() + appState);      // e.g. CLICK_TYPE_TAP = 0
        return true;
    }

    function onSwipe(swipeEvent) {
        System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
        return true;
    }

    function getNumAlarms() {
        var numAlarms = Storage.getValue("numAlarms");
        if (numAlarms == null) {
            return 0;
        }
        else {
            return numAlarms;
        }
    }

    function getAlarmFromStorage(alarmNum) {
        if (!(alarmNum instanceof Number)){
            System.println("Invalid parameter alarmNum");
            return null;
        }
        else if (alarmNum > getNumAlarms()) {
            // TODO: Throw exception here
            System.println("Attempting to retrieve non-existing alarm");
            return null;
        }
        var alarmArray = Storage.getValue(alarmNum);
        System.println("Retrieved alarm " + alarmArray);

        if (alarmArray != null) {
            return new Alarm(alarmArray[0], alarmArray[1], alarmArray[2], alarmArray[3], alarmArray[4], alarmArray[5], alarmArray[6]);
        }
        // TODO: Throw exception here
        return null;
    }

    function getActiveAlarms() {
        var numAlarms = getNumAlarms();
        if (numAlarms == 0) {
            return [];
        }
        var activeAlarms = [];
        for (var i = 0; i < numAlarms; i++) {
            var curAlarm = getAlarmFromStorage(i + 1);
            if (curAlarm.getActive()) {
                activeAlarms.add(curAlarm);
            }
        }
        // System.println("There are " + activeAlarms.size() + " active alarms");
        return activeAlarms;
    }

    function getEarliestActiveAlarm() {
        var activeAlarms = getActiveAlarms();
        var n = activeAlarms.size();
        if (n == 0) {
            return [];
        }
        else if (n == 1) {
            System.println("Earliest alarm: " + activeAlarms[0].earliestHour + ":" + activeAlarms[0].earliestMinute);
            return activeAlarms[0];
        }
        else {
            // var joinedArray = [] as Lang.Array;
            // for (var i = 0; i < n; i++) {
            //     var joined = [activeAlarms[i].earliestHour * 100 + activeAlarms[i].earliestMinute, i];
            //     joinedArray.add(joined);
            // }
            // joinedArray.sort(null);
            // if (joinedArray.size() > 0) {
            //     System.println("earliest active alarm time is " + joinedArray[0][0] + " at index " + joinedArray[0][1]);
            //     //Convert back to an array for hour and minute to return
            //     // return [joinedArray[0] / 100, joinedArray[0] % 100];
            // }
            activeAlarms.sort(new EarliestAlarmComparator() as Lang.Comparator);
            System.println("Earliest active time is " + activeAlarms[0].earliestHour + ":" + activeAlarms[0].earliestMinute);
            return activeAlarms[0];
        }
    }

    function getLatestActiveAlarm() {
        var activeAlarms = getActiveAlarms();
        var n = activeAlarms.size();
        if (n == 0) {
            return [];
        }
        else if (n == 1) {
            return activeAlarms[0];
        }
        else {
            activeAlarms.sort(new LatestAlarmComparator() as Lang.Comparator);
            System.println("Latest active time is " + activeAlarms[activeAlarms.size() - 1].latestHour + ":" + activeAlarms[activeAlarms.size() - 1].latestMinute);
            return activeAlarms[activeAlarms.size() - 1];
        }
    }

    function addNewAlarmToStorage(alarm) {
        var numAlarms = getNumAlarms();
        var curAlarm = numAlarms + 1;
        
        var alarmArray = [
            alarm.earliestHour,
            alarm.earliestMinute,
            alarm.latestHour,
            alarm.latestMinute,
            alarm.active,
            alarm.delete
        ];
        alarmArray.add(alarm.repeatArray);
        System.println("Adding new alarmArray to storage :" + alarmArray.toString());
        try {
            Storage.setValue(curAlarm, alarmArray);
            Storage.setValue("numAlarms", curAlarm);
            var earliestActiveAlarm = getEarliestActiveAlarm();
            if (earliestActiveAlarm != null){
                $.earliestActiveHour = earliestActiveAlarm.earliestHour;
                $.earliestActiveMinute = earliestActiveAlarm.earliestMinute;
            }
            var latestActiveAlarm = getLatestActiveAlarm();
            if (latestActiveAlarm != null){
                $.latestActiveHour = latestActiveAlarm.latestHour;
                $.latestActiveMinute = latestActiveAlarm.latestMinute;
            }
        } catch (e instanceof Lang.Exception) {
            System.println(e.getErrorMessage());
            // TODO: Add window here to indicate that alarms need to be deleted before more can be added
        }
    }

    function editAlarmInStorage(alarmId, alarm) {
        var numAlarms = getNumAlarms();
        if (alarmId > numAlarms) {
            // TODO: Throw exception here
            System.println("Invalid id");
            return;
        }
        var alarmArray = [
            alarm.earliestHour,
            alarm.earliestMinute,
            alarm.latestHour,
            alarm.latestMinute,
            alarm.active,
            alarm.delete
        ];
        alarmArray.add(alarm.repeatArray);
        Storage.setValue(alarmId, alarmArray);
        var earliestActiveAlarm = getEarliestActiveAlarm();
        if (earliestActiveAlarm != null){
            $.earliestActiveHour = earliestActiveAlarm.earliestHour;
            $.earliestActiveMinute = earliestActiveAlarm.earliestMinute;
        }
        var latestActiveAlarm = getLatestActiveAlarm();
        if (latestActiveAlarm != null){
            $.latestActiveHour = latestActiveAlarm.latestHour;
            $.latestActiveMinute = latestActiveAlarm.latestMinute;
        }
        return;
    }

    function reorganizeStorage() {
        var numAlarms = getNumAlarms();
        if (numAlarms  == 0) {
            return;
        }
        else {
            var newKey = 1;
            var alarmsDeleted = 0;
            for (var i = 1; i <= numAlarms; i++) {
                var alarm = getAlarmFromStorage(i);
                if (alarm.delete) {
                    System.println("Deleting alarm " + i.toString());
                    Storage.deleteValue(i);
                    alarmsDeleted++;
                } 
                else {
                    if (i != newKey) {
                        editAlarmInStorage(newKey, alarm);
                        Storage.deleteValue(i);
                    }
                    newKey++;
                }
            }
            Storage.setValue("numAlarms", numAlarms - alarmsDeleted);
        }
        return;
    }

    function getLatestAlarmWarning() {
        if (latestHour < earliestHour || (latestHour == earliestHour && latestMinute < earliestMinute)) {
            return "Latest alarm can not be\nearlier than earliest alarm";
        }
        var thirtyMinAfterEarliest_Hour;
        var thirtyMinAfterEarliest_Minute = (earliestMinute + 30) % 60;
        if (earliestMinute >= 30) {
            thirtyMinAfterEarliest_Hour = earliestHour + 1;
        }
        else {
            thirtyMinAfterEarliest_Hour = earliestHour;
        }
        if (latestHour < thirtyMinAfterEarliest_Hour || (latestHour == thirtyMinAfterEarliest_Hour && latestMinute < thirtyMinAfterEarliest_Minute)) {
            return "Alarm interval must\nbe at least 30 minutes";
        }
        return "No warning";
    }

    function makeAlarmString(alarm) {
        return alarm.earliestHour.toString() + ":" + padMinuteString(alarm.earliestMinute) + " - " + alarm.latestHour.toString() + ":" + padMinuteString(alarm.latestMinute);
    }

    function padMinuteString(minute) {
        if (minute < 10) {
            return "0" + minute.toString();
        } 
        else {
            return minute.toString();
        }
    }

}

