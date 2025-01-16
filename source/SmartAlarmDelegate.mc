import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;

class SmartAlarmDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        System.println("SmartAlarmDelegate initialize");

        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var alarmsMenu = new WatchUi.Menu2({:title=>"Alarms"});
        var numAlarms = getNumAlarms();
        for (var i = 1; i <= numAlarms; i++ ) {
            var alarm = getAlarmFromStorage(i);
            // var alarmString = alarmArray[0].toString() + ":" + padMinuteString(alarmArray[1]) + " - " + alarmArray[2] + ":" + padMinuteString(alarmArray[3].toString());
            var alarmString = alarm.earliestHour.toString() + ":" + padMinuteString(alarm.earliestMinute) + " - " + alarm.latestHour.toString() + ":" + padMinuteString(alarm.latestMinute);
            System.println(alarmString);
            alarmsMenu.addItem(
                new MenuItem(
                    alarmString,                          //labal
                    alarm.active ? "On" : "Off",          //sublabel   
                    i,                                    //id   
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

        WatchUi.pushView(alarmsMenu, new SmartAlarmMenuDelegate(self), WatchUi.SLIDE_UP);
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
                // setEarliestAlarmInStorage(earliestHour, earliestMinute);
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
                    var alarm = new Alarm(earliestHour, earliestMinute, latestHour, latestMinute, true);
                    setAlarmInStorage(alarm);
                    appState = "trackSleep";
                    step = 0;
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
        if (alarmNum > getNumAlarms()) {
            System.println("Attempting to retrieve non-existing alarm");
            return null;
        }
        var alarmArray = Storage.getValue(alarmNum);
        System.println("Retrieved alarm " + alarmArray);
        // var earliestHour = alarm[0];

        if (alarmArray != null) {
            return new Alarm(alarmArray[0], alarmArray[1], alarmArray[2], alarmArray[3], alarmArray[4]);
        }
        return null;
    }

    function setAlarmInStorage(alarm) {
        var numAlarms = getNumAlarms();
        var curAlarm = numAlarms + 1;
        // var alarmDict = {
        //     "earliestHour" =>  alarm.earliestHour,
        //     "earliestMinute" => alarm.earliestMinute,
        //     "latestHour" => alarm.latestHour,
        //     "latestMinute" =>  alarm.latestMinute
        // };
        var alarmArray = [
            alarm.earliestHour,
            alarm.earliestMinute,
            alarm.latestHour,
            alarm.latestMinute,
            alarm.active
        ];
        Storage.setValue(curAlarm, alarmArray);
        Storage.setValue("numAlarms", curAlarm);

        // System.println("Set alarm in storage");
        // System.println(alarmArray);
        // System.println(curAlarm);
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

    function padMinuteString(minute) {
        if (minute < 10) {
            return "0" + minute.toString();
        } 
        else {
            return minute.toString();
        }
    }

}

