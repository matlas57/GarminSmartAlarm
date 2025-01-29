import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Sensor;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    var appDelegate;
    var hrSensor;

    var parentMenu;

    var statusButtonId = 0;
    var editButtonId = 1;
    var deleteButtonId = 2;

    function initialize(parentMenu, delegate) {
        Menu2InputDelegate.initialize();
        self.parentMenu = parentMenu;
        appDelegate = delegate;
    }

    function onSelect(item) {
        System.println(item.getId());
        var delegate = new SmartAlarmDelegate();
        if (item.getId().equals("addAlarmButton")) {
            appState = "earliestAlarmPrompt";
            WatchUi.pushView(new SmartAlarmView(delegate), delegate, WatchUi.SLIDE_UP);
        }
        else if (item.getId().equals("testVibration")) {
            var vibeData = [
                new Attention.VibeProfile(100, 2000),  // Off for two seconds
            ];
            Attention.vibrate(vibeData);
        }
        else if (item.getId().equals("getHR")) {
            hrSensor = new HeartRateSensor();
        }
        else if (item.getId().equals("stopHR")) {
            hrSensor.stop();
        }
        else {
            var id = item.getId() as Number;
            var alarm = delegate.getAlarmFromStorage(id);
            var editAlarmMenuTitle = alarm.earliestHour.toString() + ":" + delegate.padMinuteString(alarm.earliestMinute) + " - " + alarm.latestHour.toString() + ":" + delegate.padMinuteString(alarm.latestMinute);
            var editAlarmMenu = new EditAlarmMenu({:title=>editAlarmMenuTitle}, delegate);
            editAlarmMenu.addItem(
                new ToggleMenuItem(
                    "Status",
                    alarm.active ? "On" : "Off",
                    statusButtonId,
                    alarm.active,
                    {} //Place to add on off switch icon
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Time",
                    editAlarmMenuTitle,
                    editButtonId,
                    {} //Place to add on off switch icon
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Delete",
                    "",
                    deleteButtonId,
                    {} //Place to add on off switch icon
            ));
            WatchUi.pushView(editAlarmMenu, new EditAlarmMenuDelegate(editAlarmMenu, parentMenu, id), WatchUi.SLIDE_RIGHT);
        }
    }

    function onBack() {
        appDelegate.reorganizeStorage();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}