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
        if (keyEvent.getKey() == 13) {
            earliestHour = earliestHour + 1;
            if (earliestHour > 12) {
                earliestHour = 1;
            }
        }
        else if (keyEvent.getKey() == 8) {
            earliestHour = earliestHour - 1;
            if (earliestHour < 1) { 
                earliestHour = 12;
            }
        }

        WatchUi.requestUpdate();

        return true;
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
        return true;
    }

    function onSwipe(swipeEvent) {
        System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
        return true;
    }

}

