import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
        var delegate = new SmartAlarmDelegate();
        if (item.getId().equals("addAlarmButton")) {
            System.println("Changing appState to earliestAlarmPrompt");
            appState = "earliestAlarmPrompt";
            WatchUi.pushView(new SmartAlarmView(delegate), delegate, WatchUi.SLIDE_UP);
        }
        else{
            var id = item.getId() as Number;
            var alarm = delegate.getAlarmFromStorage(id);
            alarm.toggleActive();
            //Need to update the menu view somehow to reflect the change
        }
    }

}