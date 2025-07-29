import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

/**
 * @file        SmartAlarmView.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description SmartAlarmView configures the UI for alarm prompts
 */

class SmartAlarmView extends WatchUi.View {

    //Ui elements
    hidden var prompt;
    hidden var currentStep;

    hidden var nextHour;
    hidden var hour;
    hidden var prevHour;

    hidden var semicolon;

    hidden var nextMinute;
    hidden var minute;
    hidden var prevMinute;

    hidden var nextAmPm;
    hidden var amPm;
    hidden var prevAmPm;

    hidden var confirm; 

    hidden var warning;

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
        // else if (appState.equals("earliestAlarmPrompt")) {
        //     setLayout(Rez.Layouts.promptAlarm(dc));
        // }
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
        nextMinute = new WatchUi.Text({
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
        });
        prevMinute = new WatchUi.Text({
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
        });
        nextAmPm = new WatchUi.Text({
            :text=>"AM",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
        });
        amPm = new WatchUi.Text({
            :text=>"AM",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
        });
        prevAmPm = new WatchUi.Text({
            :text=>"PM",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
        });
        minute = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
        confirm = new WatchUi.Text({
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
        warning = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>290
        });
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        minute.setLocation(screenWidth/2 + 20, WatchUi.LAYOUT_VALIGN_CENTER);
        var nextHourInt = 0;
        var prevHourInt = 0;
        var nextMinuteInt = 0;
        var prevMinuteInt = 0;

        //next and prev minute location doesn't depend on its value
        nextMinute.setLocation(screenWidth/2 + 35, screenHeight/2 - 70);
        prevMinute.setLocation(screenWidth/2 + 35, screenHeight/2 + 40);

        amPm.setLocation(screenWidth/2 + 95, WatchUi.LAYOUT_VALIGN_CENTER);
        nextAmPm.setLocation(screenWidth/2 + 115, screenHeight/2 - 70);
        prevAmPm.setLocation(screenWidth/2 + 115, screenHeight/2 + 40);

        if (appState.equals("earliestAlarmPrompt")) {
            //Compute the value of the next and prev hour 
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

            if (earliestMinute == 59){
                nextMinuteInt = 0;
            }
            else {
                nextMinuteInt = earliestMinute + 1;
            }

            if (earliestMinute == 0){
                prevMinuteInt = 59;
            }
            else {
                prevMinuteInt = earliestMinute - 1;
            }

            //Set hour UI element position 
            if (earliestHour.toString().length() == 1){
                hour.setLocation(screenWidth/2 - 63, WatchUi.LAYOUT_VALIGN_CENTER);
            }
            else {
                hour.setLocation(screenWidth/2 - 80, WatchUi.LAYOUT_VALIGN_CENTER);
            }
            
            hour.setText(earliestHour.toString());
            
            minute.setText(padMinuteString(earliestMinute));

            amPm.setText($.earliestAm ? "AM" : "PM");

            prompt.setText("Earliest Alarm");
            warning.setText("");

            confirm.setText(earliestHour.toString() + ":" + padMinuteString(earliestMinute) + " " + ($.earliestAm ? "AM" : "PM"));
        } 
        else if (appState.equals("latestAlarmPrompt")) {
            //Compute the value of the next and prev hour 
            if (latestHour == 12) {
                nextHourInt = 1;
            }
            else {
                nextHourInt = latestHour + 1;
            }

            if (latestHour == 1) {
                prevHourInt = 12;
            }
            else {
                prevHourInt = latestHour - 1;
            }

            if (latestMinute == 59){
                nextMinuteInt = 0;
            }
            else {
                nextMinuteInt = latestMinute + 1;
            }

            if (latestMinute == 0){
                prevMinuteInt = 59;
            }
            else {
                prevMinuteInt = latestMinute - 1;
            }

            //Set hour UI element position 
            if (latestHour.toString().length() == 1){
                hour.setLocation(screenWidth/2 - 63, WatchUi.LAYOUT_VALIGN_CENTER);
            }
            else {
                hour.setLocation(screenWidth/2 - 80, WatchUi.LAYOUT_VALIGN_CENTER);
            }

            hour.setText(latestHour.toString());
            minute.setText(padMinuteString(latestMinute));
            amPm.setText($.latestAm ? "AM" : "PM");

            var warningText = appDelegate.getLatestAlarmWarning();
            if (!warningText.equals("No warning")) {
                warning.setText(warningText);
                validLatestTime = false;
            } else {
                warning.setText("");
                validLatestTime = true;
            }

            prompt.setText("Latest Alarm");

            confirm.setText(latestHour.toString() + ":" + padMinuteString(latestMinute) + " " + ($.latestAm ? "AM" : "PM"));
        }

        //Set nextHour UI element position
        if (nextHourInt.toString().length() == 1){
            nextHour.setLocation(screenWidth/2 - 55, screenHeight/2 - 70);
        }
        else {
            nextHour.setLocation(screenWidth/2 - 65, screenHeight/2 - 70);
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
            hour.setVisible(true);
            prevHour.setVisible(true);
            semicolon.setVisible(true);
            nextMinute.setVisible(false);
            minute.setVisible(true);
            prevMinute.setVisible(false);
            nextAmPm.setVisible(false);
            amPm.setVisible(true);
            prevAmPm.setVisible(false);
            confirm.setVisible(false);
        } 
        else if (step == 1) {
            currentStep.setText("Set Minutes");
            nextHour.setVisible(false);
            prevHour.setVisible(false);
            nextMinute.setVisible(true);
            prevMinute.setVisible(true);
        }
        else if (step == 2) {
            currentStep.setText("AM or PM");
            nextMinute.setVisible(false);
            prevMinute.setVisible(false);

            if ((appState.equals("earliestAlarmPrompt") && $.earliestAm) || (appState.equals("latestAlarmPrompt") && $.latestAm)) {
                amPm.setText("AM");
                nextAmPm.setVisible(false);
                prevAmPm.setVisible(true);
            }
            else {
                amPm.setText("PM");
                nextAmPm.setVisible(true);
                prevAmPm.setVisible(false);
            }

        }
        else {
            currentStep.setText("Confirm");
            confirm.setVisible(true);
            hour.setVisible(false);
            semicolon.setVisible(false);
            minute.setVisible(false);
            amPm.setVisible(false);
            nextAmPm.setVisible(false);
            prevAmPm.setVisible(false);
        }

        nextHour.setText(nextHourInt.toString());
        prevHour.setText(prevHourInt.toString());

        nextMinute.setText(padMinuteString(nextMinuteInt));
        prevMinute.setText(padMinuteString(prevMinuteInt));

        prompt.draw(dc);
        currentStep.draw(dc);

        nextHour.draw(dc);
        hour.draw(dc);
        prevHour.draw(dc);

        semicolon.draw(dc);

        nextMinute.draw(dc);
        minute.draw(dc);
        prevMinute.draw(dc);

        nextAmPm.draw(dc);
        amPm.draw(dc);
        prevAmPm.draw(dc);

        confirm.draw(dc);

        warning.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    static function padMinuteString(minute) as Lang.string{
        if (minute < 10){
            return "0" + minute.toString();
        }
        return minute.toString();
    }

}
