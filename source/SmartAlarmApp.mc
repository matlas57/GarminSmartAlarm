import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Background;
import Toybox.UserProfile;
import Toybox.Time;

/**
 * @file        SmartAlarmApp.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description SmartAlarmApp is the entrance point of the application, handles high level flow, and contains global variables
 */

//TODO: Create a separate class to store global data
var appState = "alarmMenu";
var step = 0;
//earliest/latest hour/min here are holders for current selections when adding/editing an alarm
var earliestHour = 6;
var earliestMinute = 0;
var latestHour = 7;
var latestMinute = 0;
var validLatestTime = true;
var editAlarmId = 0;

//Below store the earliestActive alarm time across all stored alarms in the application
var earliestActiveHour as Lang.Number?;
var earliestActiveMinute as Lang.Number?;
var earliestActiveMoment as Time.Moment?;
var latestActiveHour as Lang.Number?;
var latestActiveMinute as Lang.Number?;
var latestActiveMoment as Time.Moment?;

var backgroundData as Lang.Dictionary?;

(:background)
var hrSensor = null;

var triggeredAlarmTimes as Lang.Array<Lang.String>?;

(:background)
class SmartAlarmApp extends Application.AppBase {

    var sdannManager;
    var appDelegate;

    function initialize() {
        System.println("SmartAlarmApp Init");
        AppBase.initialize();
        initializeHrSensor();
        $.triggeredAlarmTimes = [];
        $.triggeredAlarmTimes.add("5:15 (test)");
        $.triggeredAlarmTimes.add("5:30 (test)");
    }

    (:background)
    function initializeHrSensor() {
        System.println("initializeHrSensor");
        $.hrSensor = new HeartRateSensor();
        sdannManager = new Sdann();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {

        Background.registerForSleepEvent();

        StorageManager.setActiveAlarmInterval();
    }

    function getServiceDelegate() as [ ServiceDelegate ]{
        return [ new TemporalServiceDelegate()];
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        StorageManager.reorganizeStorage();
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        appDelegate = new SmartAlarmDelegate();
        appState = "alarmMenu";
        var view = new SmartAlarmView(appDelegate);
        return [ view, appDelegate ];
    }

    function onBackgroundData(data) {
        backgroundData = data;
        var avg = backgroundData.values()[0];
        sdannManager.addNewMeanNNInterval(avg);

        var nowMoment = earliestActiveMoment;
        // var nowMoment = new Time.Moment(Time.now().value());
        
        if (!appState.equals("alarmAllowed")) {
            if ($.earliestActiveMoment == null || $.latestActiveMoment == null){
                System.println("Moments have not been set");
            }
            else {
                if (nowMoment.compare($.earliestActiveMoment) >= 0 && nowMoment.compare($.latestActiveMoment) <= 0) {
                    System.println("Checking for alarm");
                    $.appState = "alarmAllowed";
                }
            }
        }
        if (appState.equals("alarmAllowed")) {
            sdannManager.computeSDANN();
            System.println("Current recording:");
            sdannManager.computeCurrentSDNN(backgroundData.values()[1]);
            var triggerAlarm = sdannManager.isAwake();
            if (triggerAlarm) {
                System.println("Triggering alarm");
                var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
                $.triggeredAlarmTimes.add(Lang.format(
                    "$1$:$2$",
                    [
                        info.hour,
                        info.min,
                    ])
                );
            }
            else {
                System.println("Still alseep");
            }
        }

        //register for a new event in 5 minutes
        nowMoment = Time.now();
        var nextEventMoment = nowMoment.add(new Time.Duration(300));
        System.println("Registering for next HRV reading event");
        Background.registerForTemporalEvent(nextEventMoment);
    }

    function timeToDurationHelper(hour, min, pm) as Time.Duration {
        if (pm) {
            hour += 12;
        }
        var seconds = ((hour * 60 + min) * 60);
        return new Time.Duration(seconds);
    }

    function printMoment(moment) {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        System.println(Lang.format(
            "Moment: $1$:$2$:$3$ $4$/$5$/$6$",
            [
                info.hour,
                info.min,
                info.sec,
                info.month,
                info.day,
                info.year
            ])
        );
    }

    function clearTriggeredAlarmTimes() {
        triggeredAlarmTimes = [];
    }
}

function getApp() as SmartAlarmApp {
    return Application.getApp() as SmartAlarmApp;
}