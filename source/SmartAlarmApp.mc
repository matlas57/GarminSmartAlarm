import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Background;
import Toybox.UserProfile;
import Toybox.Time;


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
var latestActiveHour as Lang.Number?;
var latestActiveMinute as Lang.Number?;

(:background)
var hrSensor = null;

(:background)
class SmartAlarmApp extends Application.AppBase {

    var sdannManager;
    var appDelegate;

    function initialize() {
        System.println("SmartAlarmApp Init");
        AppBase.initialize();
        initializeHrSensor();
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

        // var profile = UserProfile.getProfile();

        // //TODO: FOR TESTING PURPOSES ONLY
        // var midnight = Time.today(); // A moment object representing midnight of the current day
        // var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        // //Get a duration for the configured sleep time
        // profile.sleepTime = timeToDurationHelper(now.hour, now.min, false);
        // //END OF TESTING BLOCK

        // var sleepTimeDuration = profile.sleepTime;
        // sleepTimeDuration = sleepTimeDuration.add(new Time.Duration(300)); //Add 5 minutes to avoid background process errors
        // //Create a moment of the sleep time by adding the sleep time duration to the midnight moment
        // var sleepTimeMoment = midnight.add(sleepTimeDuration);

        // //ALSO FOR TESTING
        // //Create a Gregorian info for easy printing
        // var sleepTimeInfo = Gregorian.info(sleepTimeMoment, Time.FORMAT_MEDIUM);
        // System.println(Lang.format(
        //     "SleepTime is: $1$:$2$:$3$ $4$ $5$ $6$ $7$",
        //     [
        //         sleepTimeInfo.hour,
        //         sleepTimeInfo.min,
        //         sleepTimeInfo.sec,
        //         sleepTimeInfo.day_of_week,
        //         sleepTimeInfo.day,
        //         sleepTimeInfo.month,
        //         sleepTimeInfo.year
        //     ])
        // );

        // Background.registerForTemporalEvent(sleepTimeMoment);
    }

    function getServiceDelegate() as [ ServiceDelegate ]{
        return [ new TemporalServiceDelegate()];
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        appDelegate = new SmartAlarmDelegate();
        appState = "alarmMenu";
        var view = new SmartAlarmView(appDelegate);
        return [ view, appDelegate ];
    }

    function onBackgroundData(data) {
        System.println("Received background data: " + data);
        sdannManager.addNewMeanNNInterval(data);
        //register for a new event in 5 minutes
        var nowMoment = Time.now();
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

}

function getApp() as SmartAlarmApp {
    return Application.getApp() as SmartAlarmApp;
}