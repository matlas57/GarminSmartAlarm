import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
    }

}