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
var earliestHour = 6;
var earliestMinute = 0;
var latestHour = 7;
var latestMinute = 0;
var validLatestTime = true;
var editAlarmId = 0;

// (:background)
class SmartAlarmApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {

        var profile = UserProfile.getProfile();

        //TODO: FOR TESTING PURPOSES ONLY
        var midnight = Time.today(); // A moment object representing midnight of the current day
        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        //Get a duration for the configured sleep time
        profile.sleepTime = timeToDurationHelper(now.hour, now.min, false);
        //END OF TESTING BLOCK

        var sleepTimeDuration = profile.sleepTime;
        sleepTimeDuration = sleepTimeDuration.add(new Time.Duration(300)); //Add 5 minutes to avoid background process errors
        //Create a moment of the sleep time by adding the sleep time duration to the midnight moment
        var sleepTimeMoment = midnight.add(sleepTimeDuration);

        //ALSO FOR TESTING
        //Create a Gregorian info for easy printing
        var sleepTimeInfo = Gregorian.info(sleepTimeMoment, Time.FORMAT_MEDIUM);
        System.println(Lang.format(
            "SleepTime is: $1$:$2$:$3$ $4$ $5$ $6$ $7$",
            [
                sleepTimeInfo.hour,
                sleepTimeInfo.min,
                sleepTimeInfo.sec,
                sleepTimeInfo.day_of_week,
                sleepTimeInfo.day,
                sleepTimeInfo.month,
                sleepTimeInfo.year
            ])
        );

        Background.registerForTemporalEvent(sleepTimeMoment);
    }

    function timeToDurationHelper(hour, min, pm) as Time.Duration {
        if (pm) {
            hour += 12;
        }
        var seconds = ((hour * 60 + min) * 60);
        return new Time.Duration(seconds);
    }

    function getServiceDelegate() as [ ServiceDelegate ]{
        return [ new TemporalServiceDelegate()];
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var delegate = new SmartAlarmDelegate();
        if (delegate.getNumAlarms() > 0) {
            appState = "alarmMenu";
        }
        else {
            appState = "earliestAlarmPrompt";
        }
        var view = new SmartAlarmView(delegate);
        return [ view, delegate ];
    }

}

function getApp() as SmartAlarmApp {
    return Application.getApp() as SmartAlarmApp;
}