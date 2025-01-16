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
        //Status is successfully updated, now need to update the UI in real time
    }

    function editAlarm() {

    }

    function deleteAlarm() {

    }
}