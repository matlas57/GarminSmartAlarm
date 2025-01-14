import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
        if (item.getId().equals("addAlarmButton")) {
            System.println("Changing appState to earliestAlarmPrompt");
            appState = "earliestAlarmPrompt";
            var delegate = new SmartAlarmDelegate();
            WatchUi.pushView(new SmartAlarmView(delegate), delegate, WatchUi.SLIDE_UP);
        }
    }

}