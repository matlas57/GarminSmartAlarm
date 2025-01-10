import Toybox.Graphics;
import Toybox.WatchUi;


class SmartAlarmView extends WatchUi.View {

    hidden var prompt;
    hidden var currentStep;
    hidden var time;
    hidden var warning;

    hidden var appDelegate;

    function initialize(delegate) {
        View.initialize();
        appDelegate = delegate; 
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
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
            :locY=>50
        });
        currentStep = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_XTINY,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>115
        });
        time = new WatchUi.Text({
            :text=>"",
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
            :locY=>255
        });
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (appState.equals("earliestAlarmPrompt")) {
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
            if (earliestMinute < 10) {
                paddedMinuteString = "0" + earliestMinute.toString();
            }
            else {
                paddedMinuteString = earliestMinute.toString();
            }
            time.setText(earliestHour.toString() + ":" + paddedMinuteString);
            prompt.setText("Earliest Alarm");
            warning.setText("");
        } 
        else if (appState.equals("latestAlarmPrompt")) {
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
            time.setText(latestHour.toString() + ":" + paddedMinuteString);

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
        time.draw(dc);
        warning.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
