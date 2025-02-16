import Toybox.Graphics;
import Toybox.WatchUi;

class WakeUpView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.alarm(dc));
         var buttonHint = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.LauncherIcon,
            :locX=>50,
            :locY=>30
        });
        buttonHint.draw(dc);
    }
}

class WakeUpViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize(){
        BehaviorDelegate.initialize();
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == 4) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}