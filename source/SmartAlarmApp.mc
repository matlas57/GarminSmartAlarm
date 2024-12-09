import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SmartAlarmApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        var myTime = System.getClockTime(); // ClockTime object
        System.println(
        myTime.hour.format("%02d") + ":" +
        myTime.min.format("%02d") + ":" +
        myTime.sec.format("%02d")
        );
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SmartAlarmView(), new SmartAlarmDelegate() ];
    }

}

function getApp() as SmartAlarmApp {
    return Application.getApp() as SmartAlarmApp;
}