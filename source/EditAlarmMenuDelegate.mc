import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class EditAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    var parentMenu;
    var parentMenuItemId;

    function initialize(parentMenu, parentMenuItemId) {
        Menu2InputDelegate.initialize();
        self.parentMenu = parentMenu;
        self.parentMenuItemId = parentMenuItemId;
    }

    function onSelect(item) {
        System.println(item.getId());
    }
}