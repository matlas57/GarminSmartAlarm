import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Sensor;
import Toybox.Background;
import Toybox.Time;
import Toybox.Application;

/**
 * @file        SmartAlarmMenuDelegate.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description SmartAlarmMenuDelegate is the input handler for the alarm menu
 */

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
            WatchUi.switchToView(new SmartAlarmView(delegate), delegate, WatchUi.SLIDE_UP);
        }
        else if (item.getId().equals("showTriggeredAlarms")) {
            var triggeredAlarmTimesMenu = new WatchUi.Menu2({:title=>"Triggered Alarms"});
            $.triggeredAlarmTimes = StorageManager.getTriggeredAlarmTimes();
            var n = 0;
            if (triggeredAlarmTimes != null){
                n = $.triggeredAlarmTimes.size();
                for (var i = 0; i < n; i++) {
                    triggeredAlarmTimesMenu.addItem(
                        new MenuItem(
                            $.triggeredAlarmTimes[i],
                            "",
                            "",
                            {}
                        )
                    );
                }
            }
            else {
                triggeredAlarmTimesMenu.addItem(
                    new MenuItem(
                        "No triggered alarms",
                        "",
                        "",
                        {}
                    )
                );
            }
            WatchUi.pushView(triggeredAlarmTimesMenu, new Menu2InputDelegate(), WatchUi.SLIDE_LEFT);
        }
        else if (item.getId().equals("clearTriggeredAlarms")) {
            $.triggeredAlarmTimes = [];
            Storage.deleteValue("triggeredAlarms");
        }
        else if (item.getId().equals("showOvernightsAvgs")) {
            var overnightAveragesMenu = new WatchUi.Menu2({:title=>"Overnight Averages"});
            overnightAverages = StorageManager.getOvernightAverages();
            var n = 0;
            if (overnightAverages != null){
                n = $.overnightAverages.size();
                for (var i = 0; i < n; i++) {
                    overnightAveragesMenu.addItem(
                        new MenuItem(
                            overnightAverages[i].toString(),
                            "",
                            "",
                            {}
                        )
                    );
                }
            }
            else {
                overnightAveragesMenu.addItem(
                    new MenuItem(
                        "No recordings"
                        ,
                        "",
                        "",
                        {}
                    )
                );
            }
            WatchUi.pushView(overnightAveragesMenu, new Menu2InputDelegate(), WatchUi.SLIDE_LEFT);
        }
        else if (item.getId().equals("clearOvernightsAvgs")){
            $.overnightAverages = [];
            Storage.deleteValue("overnightAverages");
        }
        else if (item.getId().equals("alarmChecks")){
            var alarmChecksMenu = new WatchUi.Menu2({:title=>"Alarm checks"});
            var n = StorageManager.getNumAlarmChecks();
            if (n > 0) {
                for (var i = 1; i <= n; i++) {
                    var alarkCheck = StorageManager.getAlarmCheckFromStorage(i);
                    alarmChecksMenu.addItem(
                        new MenuItem(
                            alarkCheck.timeString,
                            "",
                            i,
                            {}
                        )
                    );
                }
            }
            else {
                alarmChecksMenu.addItem(
                    new MenuItem(
                        "No alarm checks",
                        "",
                        "",
                        {}
                    )
                );
            }
            WatchUi.pushView(alarmChecksMenu, new AlarmCheckMenuDelegate(), WatchUi.SLIDE_LEFT);
        }
        else if (item.getId().equals("clearAlarmChecks")){
            StorageManager.clearAlarmChecks();
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
            var time = "";
            if (eventTime == null) {
                // System.println("No registered event");
                time = "No Registered event";
            }
            else {
                if (eventTime instanceof Time.Moment) {
                    var nextEventInfo = Gregorian.info(eventTime, Time.FORMAT_SHORT);
                    // System.println(
                    //     Lang.format(
                    //     "Temporal event at: $1$:$2$:$3$", 
                    //     [
                    //         nextEventInfo.hour,
                    //         nextEventInfo.min,
                    //         nextEventInfo.sec,
                    //     ]
                    // ));
                    time = Lang.format(
                        "Temporal event at: $1$:$2$:$3$", 
                        [
                            nextEventInfo.hour,
                            nextEventInfo.min,
                            nextEventInfo.sec,
                        ]
                    );
                }
                else {
                    // System.println("Temporal event in " + eventTime.value() + " seconds");
                    time = "In " + eventTime.value() + " seconds";
                }
            }
            var nextEventTimeMenu = new WatchUi.Menu2({:title=>"Next event"});
            nextEventTimeMenu.addItem(new MenuItem(
                time,
                "",
                "",
                {}
            ));
            WatchUi.pushView(nextEventTimeMenu, new Menu2InputDelegate(), WatchUi.SLIDE_LEFT);
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
            parentMenu.getItem(id - 1).setEnabled(alarm.getActive());
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
            WatchUi.pushView(editAlarmMenu, new EditAlarmMenuDelegate(editAlarmMenu, parentMenu, id), WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() {
        StorageManager.reorganizeStorage();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}