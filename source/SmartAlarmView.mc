import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;


class SmartAlarmView extends WatchUi.View {

    //Ui elements
    hidden var prompt;
    hidden var currentStep;
    hidden var warning;
    hidden var hour;
    hidden var semicolon;
    hidden var minute;
    hidden var nextHour;
    hidden var prevHour;

    hidden var buttonHint;
    var screenHeight as Lang.Number?;
    var screenWidth as Lang.Number?;

    //instances of other classes
    hidden var appDelegate;

    function initialize(delegate) {
        View.initialize();
        appDelegate = delegate; 
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        if (appState.equals("alarmMenu")) {
            appDelegate.onMenu();
        } 
        else if (appState.equals("earliestAlarmPrompt")) {
            setLayout(Rez.Layouts.promptAlarm(dc));
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        prompt = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>40
        });
        currentStep = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>80
        });
        nextHour = new WatchUi.Text({
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
        });
        prevHour = new WatchUi.Text({
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
        });
        hour = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
        });
        semicolon = new WatchUi.Text({
            :text=>":",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
        minute = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
        warning = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>255
        });
        // buttonHint = new WatchUi.Bitmap({
        //     :rezId=>Rez.Drawables.xButtonHint,
        //     :locX=>10,
        //     :locY=>30
        // });
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        minute.setLocation(screenWidth/2 + 20, WatchUi.LAYOUT_VALIGN_CENTER);
        if (appState.equals("earliestAlarmPrompt")) {
            //Compute the value of the next and prev hour 
            var nextHourInt;
            var prevHourInt;
            if (earliestHour == 12) {
                nextHourInt = 1;
            }
            else {
                nextHourInt = earliestHour + 1;
            }

            if (earliestHour == 1) {
                prevHourInt = 12;
            }
            else {
                prevHourInt = earliestHour - 1;
            }

            //Set nextHour UI element position
            if (nextHourInt.toString().length() == 1){
                nextHour.setLocation(screenWidth/2 - 55, screenHeight/2 - 70);
            }
            else {
                nextHour.setLocation(screenWidth/2 - 65, screenHeight/2 - 70);
            }

            //Set hour UI element position 
            if (earliestHour.toString().length() == 1){
                var xLoc = screenWidth/2 - 63; 
                hour.setLocation(xLoc, WatchUi.LAYOUT_VALIGN_CENTER);
            }
            else {
                hour.setLocation(screenWidth/2 - 80, WatchUi.LAYOUT_VALIGN_CENTER);
            }

            //Set prevHour UI element position
            if (prevHourInt.toString().length() == 1){
                prevHour.setLocation(screenWidth/2 - 55, screenHeight/2 + 40);
            }
            else {
                prevHour.setLocation(screenWidth/2 - 65, screenHeight/2 + 40);
            }

            if (step == 0) {
                currentStep.setText("Set Hour");
                nextHour.setVisible(true);
                prevHour.setVisible(true);
            } 
            else if (step == 1) {
                currentStep.setText("Set Minutes");
                nextHour.setVisible(false);
                prevHour.setVisible(false);
            }
            else {
                currentStep.setText("Confirm");
            }

            var paddedMinuteString = "";
            if (earliestMinute < 10) {
                paddedMinuteString = "0" + earliestMinute.toString();
            }
            else {
                paddedMinuteString = earliestMinute.toString();
            }
            nextHour.setText(nextHourInt.toString());
            hour.setText(earliestHour.toString());
            prevHour.setText(prevHourInt.toString());
            minute.setText(paddedMinuteString);
            prompt.setText("Earliest Alarm");
            warning.setText("");
        } 
        else if (appState.equals("latestAlarmPrompt")) {
            if (latestHour.toString().length() == 1){
                hour.setLocation(screenWidth/2 - 50, WatchUi.LAYOUT_VALIGN_CENTER);
            }
            else {
                hour.setLocation(screenWidth/2 - 80, WatchUi.LAYOUT_VALIGN_CENTER);
            }
            if (step == 0) {
                currentStep.setText("Set Hour");
            } 
            else if (step == 1) {
                currentStep.setText("Set Minutes");
            }
            else {
                currentStep.setText("Confirm");
            }

            var paddedMinuteString = "";
            if (latestMinute < 10) {
                paddedMinuteString = "0" + latestMinute.toString();
            }
            else {
                paddedMinuteString = latestMinute.toString();
            }
            hour.setText(latestHour.toString());
            minute.setText(paddedMinuteString);

            var warningText = appDelegate.getLatestAlarmWarning();
            if (!warningText.equals("No warning")) {
                warning.setText(warningText);
                validLatestTime = false;
            } else {
                warning.setText("");
                validLatestTime = true;
            }

            prompt.setText("Latest Alarm");
        }
        prompt.draw(dc);
        currentStep.draw(dc);
        warning.draw(dc);
        nextHour.draw(dc);
        hour.draw(dc);
        prevHour.draw(dc);
        semicolon.draw(dc);
        minute.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
