import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;

/**
 * @file        SmartAlarmDelegate.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description SmartAlarmDelegate is the input handler for the general application
 */

class SmartAlarmDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var alarmsMenu = new WatchUi.Menu2({:title=>"Alarms"});
        var numAlarms = StorageManager.getNumAlarms();
        for (var i = 1; i <= numAlarms; i++ ) {
            var alarm = StorageManager.getAlarmFromStorage(i);
            var alarmString = alarm.makeAlarmString();
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
            new MenuItem(
                "Show triggered alarms",
                "",
                "showTriggeredAlarms",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem(
                "Clear triggered alarms",
                "",
                "clearTriggeredAlarms",
                {}
            )
        );
        alarmsMenu.addItem(
            new MenuItem(
                "Show overnights avgs",
                "",
                "showOvernightsAvgs",
                {}
            )
        );
        // alarmsMenu.addItem(
        //     new MenuItem (
        //         "Print App State",
        //         "",
        //         "printAppState",
        //         {}
        //     )
        // );
        // alarmsMenu.addItem(
        //     new MenuItem (
        //         "Get Active Alarms",
        //         "",
        //         "getActiveAlarms",
        //         {}
        //     )
        // );
        // alarmsMenu.addItem(
        //     new MenuItem (
        //         "Print Active Interval",
        //         "",
        //         "printActiveInterval",
        //         {}
        //     )
        // );
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
        // alarmsMenu.addItem(
        //     new MenuItem (
        //         "Get Heart Rate",
        //         "",
        //         "getHR",
        //         {}
        //     )
        // );
        // alarmsMenu.addItem(
        //     new MenuItem (
        //         "Stop Recording",
        //         "",
        //         "stopHR",
        //         {}
        //     )
        // );

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
                    WatchUi.popView(WatchUi.SLIDE_UP);
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
                        StorageManager.addNewAlarmToStorage(alarm);
                        onMenu();
                    } 
                    else if (editAlarmId > 0) {
                        StorageManager.editAlarmInStorage(editAlarmId, alarm);
                        WatchUi.popView(WatchUi.SLIDE_UP);
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

    (:debug)
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
}

