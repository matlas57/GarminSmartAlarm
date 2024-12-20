import Toybox.Graphics;
import Toybox.WatchUi;


class SmartAlarmView extends WatchUi.View {

    hidden var promptEarliest;
    hidden var earliestTime;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

        System.println(appState);
        promptEarliest = new WatchUi.Text({
            :text=>"Earliest Alarm:",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SYSTEM_TINY,
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>120
        });
        earliestTime = new WatchUi.Text({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        System.println("updating to " + earliestHour);
        earliestTime.setText(earliestHour.toString());
        promptEarliest.draw(dc);
        earliestTime.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    

}
