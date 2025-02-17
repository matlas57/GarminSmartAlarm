import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Attention;

class WakeUpView extends WatchUi.View {

    var vibeData = [
        new Attention.VibeProfile(100, 2000),  // On for two seconds
    ];

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

    function onShow() {
        
        Attention.vibrate(vibeData);
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