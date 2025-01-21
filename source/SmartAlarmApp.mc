import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var appState = "alarmMenu";
var step = 0;
var earliestHour = 6;
var earliestMinute = 0;
var latestHour = 7;
var latestMinute = 0;
var validLatestTime = true;
var editAlarmId = 0;

class SmartAlarmApp extends Application.AppBase {

    function initialize() {
        System.println("SmartAlarmApp initialize");
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("SmartAlarmApp onStart");

        // var myTime = System.getClockTime(); // ClockTime object
        // System.println(
        // myTime.hour.format("%02d") + ":" +
        // myTime.min.format("%02d") + ":" +
        // myTime.sec.format("%02d")
        // );
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        System.println("SmartAlarmApp getInitialView");

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