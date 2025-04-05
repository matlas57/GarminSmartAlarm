import Toybox.Lang;

class AlarmCheck {
    var timeString as Lang.string;
    var sdann as Lang.Float;
    var beforeSDNN as Lang.Float;
    var duringSDNN as Lang.Float;
    var afterSDNN as Lang.Float;
    var result as Lang.string;

    function initialize (time, sdann, bsdnn, dsdnn, asdnn, res) {
        self.timeString = time;
        self.sdann = sdann;
        self.beforeSDNN = bsdnn;
        self.duringSDNN = dsdnn;
        self.afterSDNN = asdnn;
        self.result = res;
    }
}