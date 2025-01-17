import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
import Toybox.WatchUi;

class EditAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    //Parent menu refers to the EditAlarmMenu
    var parentMenu;
    var parentMenuItemId;

    var grandParentMenu;
    var grandParentMenuItemId;

    var appDelegate;

    function initialize(parentMenu, grandParentMenu, parentMenuItemId) {
        Menu2InputDelegate.initialize();
        self.parentMenu = parentMenu;
        self.parentMenuItemId = parentMenuItemId;
        self.grandParentMenu = grandParentMenu;
        self.grandParentMenuItemId = parentMenuItemId;
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
            deleteAlarmConfirmation();
        } 
    }

    function toggleStatus() {
        var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
        alarm.toggleActive();
        System.println("alarm active is " + alarm.active);
        appDelegate.editAlarmInStorage(parentMenuItemId, alarm);
        //Get the menu item for the status button in this menu and request it be updated
        var parentItem = parentMenu.getItem(parentMenuItemId - 1);        
        parentItem.setSubLabel(alarm.active ? "On" : "Off");
        parentMenu.updateItem(parentItem, parentMenuItemId - 1);

        var grandParentItem = grandParentMenu.getItem(grandParentMenuItemId - 1);
        grandParentItem.setSubLabel(alarm.active ? "On" : "Off");
        grandParentMenu.updateItem(grandParentItem, grandParentMenuItemId - 1);
    }

    function editAlarm() {

    }

    function deleteAlarmConfirmation() {
        var confirmationMessage = "Delete Alarm?";
        var confirmationView = new WatchUi.Confirmation(confirmationMessage);
        WatchUi.pushView(
            confirmationView,
            new DeleteAlarmConfirmationDelegate(self),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function deleteAlarm() {
        //Take the deleted alarm id 
        //Go through the alarm storage from the current index to numAlarms - 1
        //Swap i and i + 1
        //delete max alarm
        //decrement number of alarms 
        System.println("Reached delete alarm function");
        var numAlarms = appDelegate.getNumAlarms();
        //If one alarm delete the entry and return to the alarmMenu
        if (numAlarms == 1) {
            Storage.deleteValue(parentMenuItemId);
            Storage.setValue("numAlarms", 0);
            grandParentMenu.deleteItem(grandParentMenuItemId - 1);
            WatchUi.popView(WatchUi.SLIDE_LEFT);
        }
    }

    function updateAlarmMenu() {

    }
}