import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Sensor;
import Toybox.Background;
import Toybox.Time;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    var appDelegate;
    var hrSensor;

    var parentMenu;

    var statusButtonId = 0;
    var editButtonId = 1;
    var repeatButtonId = 2;
    var deleteButtonId = 3;

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
        else if (item.getId().equals("getNextTemporalEvent")) {
            System.println("Getting next event time");
            var eventTime = Background.getTemporalEventRegisteredTime();
            if (eventTime == null) {
                System.println("No registered event");
            }
            else {
                System.println("Temporal event in " + eventTime.value() " seconds");
            }
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
                    {}
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Time",
                    editAlarmMenuTitle,
                    editButtonId,
                    {} 
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Repeat",
                    "_____", //TODO: Create sublabel
                    repeatButtonId,
                    {}
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Delete",
                    "",
                    deleteButtonId,
                    {}
            ));
            WatchUi.pushView(editAlarmMenu, new EditAlarmMenuDelegate(editAlarmMenu, parentMenu, id), WatchUi.SLIDE_RIGHT);
        }
    }

    function onBack() {
        appDelegate.reorganizeStorage();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}