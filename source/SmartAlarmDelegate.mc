import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;

class SmartAlarmDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SmartAlarmMenuDelegate(), WatchUi.SLIDE_UP);
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
        System.println("Registered button click " + appState);
        if (appState.equals("earliestAlarmPrompt") && step == 0) {
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
        else if (appState.equals("earliestAlarmPrompt") && step == 1) {
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
        else if (appState.equals("earliestAlarmPrompt") && step == 2) {
            appState = "latestAlarmPrompt";
            System.println(earliestHour.toString() + ":" + earliestMinute.toString());
            System.println(appState);
        }

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

}

