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
var am = true;
var validLatestTime = true;
var editAlarmId = 0;
var threshold = 1.5;

//Below store the earliestActive alarm time across all stored alarms in the application
var earliestActiveHour as Lang.Number?;
var earliestActiveMinute as Lang.Number?;
var earliestActiveMoment as Time.Moment?;
var latestActiveHour as Lang.Number?;
var latestActiveMinute as Lang.Number?;
var latestActiveMoment as Time.Moment?;

var backgroundData as Lang.Dictionary?;
var overnightAverages as Lang.Array<Lang.String>?;


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
        $.triggeredAlarmTimes = StorageManager.getTriggeredAlarmTimes();
        $.overnightAverages = StorageManager.getOvernightAverages();
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
        // var overnightAvginfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        StorageManager.addOvernightAverage(avg);
        // $.overnightAverages.add(Lang.format(
        //     "$1$:$2$ | $3$",
        //     [
        //         overnightAvginfo.hour,
        //         overnightAvginfo.min,
        //         avg.toString()
        //     ])
        // );
        // $.overnightAverages.add(avg);

        // var nowMoment = earliestActiveMoment;
        var nowMoment = new Time.Moment(Time.now().value());
        
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
            var sdannn = sdannManager.computeSDANN();
            System.println("Current recording:");
            var sdnn = sdannManager.computeCurrentSDNN(backgroundData.values()[1]);
            var triggerAlarm = sdannManager.isAwake();
            var resultString;
            if (triggerAlarm) {
                resultString = "Awake";
            }
            else {
                resultString = "Asleep";
            }
            if (triggerAlarm) {
                System.println("Triggering alarm");
                var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
                StorageManager.addTriggeredAlarmTime(Lang.format(
                    "$1$:$2$",
                    [
                        info.hour,
                        info.min,
                    ])
                );

                //Check for 'Once' alarms. If one is triggered set it to be off
                var activeAlarms = StorageManager.getActiveAlarms();
                var n = activeAlarms.size();
                for (var i = 0; i < n; i++) {
                    if (activeAlarms[i].getRepeatLabel().equals("Once")) {
                        var earliestMoment = timeToMomentHelper(activeAlarms[i].earliestHour, activeAlarms[i].earliestMinute, false);
                        var latestMoment = timeToMomentHelper(activeAlarms[i].latestHour, activeAlarms[i].latestMinute, false);
                        if (nowMoment.compare(earliestMoment) >= 0 && nowMoment.compare(latestMoment) <= 0) {
                            activeAlarms[i].toggleActive();
                            break;
                        }
                    }
                }
            }
            else {
                System.println("Still alseep");
            }

            var timeInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var timeString = Lang.format(
                "$1$:$2$",
                [
                    timeInfo.hour,
                    timeInfo.min,
                ]
            );

            var alarmCheck = new AlarmCheck(timeString, sdannn, sdnn[0], sdnn[1], sdnn[2], resultString);
            StorageManager.addAlarmCheckToStorage(alarmCheck);
        }

       

        //register for a new event in 5 minutes
        nowMoment = Time.now();
        var nextEventMoment = nowMoment.add(new Time.Duration(300));
        System.println("Registering for next HRV reading event");
        Background.registerForTemporalEvent(nextEventMoment);
    }

    static function timeToDurationHelper(hour, min, pm) as Time.Duration {
        if (pm) {
            hour += 12;
        }
        var seconds = ((hour * 60 + min) * 60);
        return new Time.Duration(seconds);
    }

    function timeToMomentHelper(hour, min, pm) as Time.Moment {
        var today = Time.today();
        var duration = timeToDurationHelper(hour, min, pm);
        return today.add(duration);
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