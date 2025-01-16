import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class EditAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    var parentMenu;
    var parentMenuItemId;

    var appDelegate;

    function initialize(parentMenu, parentMenuItemId) {
        Menu2InputDelegate.initialize();
        self.parentMenu = parentMenu;
        self.parentMenuItemId = parentMenuItemId;
        appDelegate = new SmartAlarmDelegate();
    }

    function onSelect(item) {
        if (item.getId() == 0) {
            System.println("Status button");
            toggleStatus();
        } 
        else if (item.getId() == 1) {
            System.println("Edit button");
        } 
        else if (item.getId() == 2) {
            System.println("Delete button");
        } 
    }

    function toggleStatus() {
        var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
        alarm.toggleActive();
        System.println("alarm active is " + alarm.active);
        appDelegate.editAlarmInStorage(parentMenuItemId, alarm);
        var parentItem = parentMenu.getItem(parentMenuItemId - 1);
        System.println("Parent item info: label = " + parentItem.getLabel() + " sublabel = " + parentItem.getSubLabel());
        //Add delegate toggle status function to call which will retreive the alarm toggle status and edit the entry 
    }

    function editAlarm() {

    }

    function deleteAlarm() {

    }
}