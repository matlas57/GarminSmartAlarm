import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
import Toybox.WatchUi;

class EditAlarmMenu extends WatchUi.Menu2 {
    
    var appDelegate;

    function initialize(options, delegate) {
        Menu2.initialize(options);
        appDelegate = delegate;
    }

    function onShow() {
        System.println("EditAlarmMenu onShow " + editAlarmId);
        var timeMenuItem = self.getItem(1);
        if (editAlarmId > 0)
        {
            var alarm = appDelegate.getAlarmFromStorage(editAlarmId);
            timeMenuItem.setSubLabel(appDelegate.makeAlarmString(alarm));
        }
        System.println(timeMenuItem.getSubLabel());
    }
}

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
            editAlarm();
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
        var parentItem = parentMenu.getItem(0);        
        parentItem.setSubLabel(alarm.active ? "On" : "Off");
        parentMenu.updateItem(parentItem, 0);

        var grandParentItem = grandParentMenu.getItem(grandParentMenuItemId - 1);
        grandParentItem.setSubLabel(alarm.active ? "On" : "Off");
        grandParentMenu.updateItem(grandParentItem, grandParentMenuItemId - 1);
    }

    function editAlarm() {
        // Set a global variable in SmartAlarmApp.mc to hold the id of the alarm being edited
        // Change state to "earliestAlarmPrompt"
        // Push layout for creating an alarm prompt
        // in SmartAlarmAppDelegate when confirming the second alarm check if the global var is present and call add or edit
        // Pop view to return to edit alarm menu
        // update menu
        editAlarmId = grandParentMenuItemId;
        
        appState = "earliestAlarmPrompt";

        var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
        earliestHour = alarm.earliestHour;
        earliestMinute = alarm.earliestMinute;
        latestHour = alarm.latestHour;
        latestMinute = alarm.latestMinute;

        WatchUi.pushView(new SmartAlarmView(appDelegate), appDelegate, WatchUi.SLIDE_BLINK);

        // Need to wait until the view is popped to update the view or call the update logic from appDelegate
        // alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
        // var alarmString = appDelegate.makeAlarmString(alarm);

        // var parentItem = parentMenu.getItem(1);        
        // parentItem.setSubLabel(alarmString);
        // parentMenu.updateItem(parentItem, 1);

        // var grandParentItem = grandParentMenu.getItem(grandParentMenuItemId - 1);
        // grandParentItem.setLabel(alarmString);
        // grandParentMenu.updateItem(grandParentItem, grandParentMenuItemId - 1);

        parentMenu.setFocus(1);
        System.println("Editing alarm " + editAlarmId.toString());
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
            System.println("1 alarm deleting it from storage");
            Storage.deleteValue(parentMenuItemId);
            Storage.setValue("numAlarms", 0);
        }
        else {
            System.println("More than 1 alarm, marking alarm for deletion");
            //Get the alarm from storage
            //Change the delete flag to true
            //Delete the record in the menu
            //When the menu is closed update the keys in storage to be sequential
            var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
            alarm.setDelete(true);
            appDelegate.editAlarmInStorage(parentMenuItemId, alarm);
        }
        grandParentMenu.deleteItem(grandParentMenuItemId - 1);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

    function updateAlarmMenu() {
        System.println("Updating menu");
    }
}
