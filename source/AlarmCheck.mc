import Toybox.Lang;

class AlarmCheck {
    var timeString as Lang.string;
    var sdann as Lang.Float;
    var sdnn as Lang.Float;
    var result as Lang.string;

    function initialize (time, sdann, sdnn, res) {
        self.timeString = time;
        self.sdann = sdann;
        self.sdnn = sdnn;
        self.result = res;
    }
}