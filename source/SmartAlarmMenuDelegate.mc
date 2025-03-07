import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Sensor;
import Toybox.Background;
import Toybox.Time;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    // var hrSensor;

    var parentMenu;

    var statusButtonId = 0;
    var editButtonId = 1;
    var repeatButtonId = 2;
    var deleteButtonId = 3;

    function initialize(parentMenu) {
        Menu2InputDelegate.initialize();
        self.parentMenu = parentMenu;
    }

    function onSelect(item) {
        System.println(item.getId());
        var delegate = new SmartAlarmDelegate();
        if (item.getId().equals("addAlarmButton")) {
            appState = "earliestAlarmPrompt";
            WatchUi.pushView(new SmartAlarmView(delegate), delegate, WatchUi.SLIDE_UP);
        }
        else if (item.getId().equals("printAppState")) {
            System.println("App state is " + appState);
        }
        else if (item.getId().equals("testVibration")) {
            WatchUi.pushView(new WakeUpView(), new WakeUpViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
        else if (item.getId().equals("getActiveAlarms")) {
            StorageManager.getActiveAlarms();
        }
        else if (item.getId().equals("printActiveInterval")) {
            StorageManager.getEarliestActiveAlarm();
            StorageManager.getLatestActiveAlarm();
            System.println("Global var earliest time: " + earliestActiveHour + ":" + earliestActiveMinute);
            System.println("Global var latest time: " + latestActiveHour + ":" + latestActiveMinute);
        }
        else if (item.getId().equals("getNextTemporalEvent")) {
            System.println("Getting next event time");
            var eventTime = Background.getTemporalEventRegisteredTime();
            if (eventTime == null) {
                System.println("No registered event");
            }
            else {
                if (eventTime instanceof Time.Moment) {
                    var nextEventInfo = Gregorian.info(eventTime, Time.FORMAT_SHORT);
                    System.println(
                        Lang.format(
                        "Temporal event at: $1$:$2$:$3$", 
                        [
                            nextEventInfo.hour,
                            nextEventInfo.min,
                            nextEventInfo.sec,
                        ]
                    ));
                }
                else {
                    System.println("Temporal event in " + eventTime.value() + " seconds");
                }
            }
        }
        else if (item.getId().equals("deleteNextTemporalEvent")) {
            System.println("Deleting temporal events");
            Background.deleteTemporalEvent();
            var eventTime = Background.getTemporalEventRegisteredTime();
            if (eventTime == null) {
                System.println("Event deleted");
            }
            else {
                System.println("Event deletion failed");
            }
        }
        else if (item.getId().equals("getHR")) {
            hrSensor = new HeartRateSensor();
            hrSensor.start();
        }
        else if (item.getId().equals("stopHR")) {
            hrSensor.stop();
        }
        else {
            var id = item.getId() as Number;
            var alarm = StorageManager.getAlarmFromStorage(id);
            var editAlarmMenuTitle = alarm.makeAlarmString();
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
                    alarm.getRepeatLabel(), //TODO: Create sublabel
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
        StorageManager.reorganizeStorage();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}