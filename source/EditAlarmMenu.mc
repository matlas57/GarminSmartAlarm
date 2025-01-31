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

    //Parent menu refers to the alarmMenu
    var parentMenu;
    var parentMenuItemId;

    //Grandparent menu is then alarms menu
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
            toggleStatus();
        } 
        else if (item.getId() == 1) {
            editAlarm();
        } 
        else if (item.getId() == 2) {
            openRepeatAlarmMenu();
        }
        else if (item.getId() == 3) {
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
        grandParentItem.setEnabled(alarm.active);
        grandParentMenu.updateItem(grandParentItem, grandParentMenuItemId - 1);
    }

    function editAlarm() {
        editAlarmId = grandParentMenuItemId;

        appState = "earliestAlarmPrompt";

        var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
        earliestHour = alarm.earliestHour;
        earliestMinute = alarm.earliestMinute;
        latestHour = alarm.latestHour;
        latestMinute = alarm.latestMinute;

        WatchUi.pushView(new SmartAlarmView(appDelegate), appDelegate, WatchUi.SLIDE_BLINK);

        parentMenu.setFocus(1);
        System.println("Editing alarm " + editAlarmId.toString());
    }

    function openRepeatAlarmMenu() {
        //TODO: create and open menu
        var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
        var repeatAlarmMenu = new RepeatAlarmMenu({:title=>"Repeat"}, appDelegate);
        WatchUi.pushView(
            repeatAlarmMenu,
            new RepeatAlarmMenuDelegate(
                alarm.getRepeatLabel(),
                parentMenu,
                parentMenuItemId,
                grandParentMenu
            ),
            WatchUi.SLIDE_RIGHT);
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
        
        var numAlarms = appDelegate.getNumAlarms();
        //If one alarm delete the entry and return to the alarmMenu
        if (numAlarms == 1) {
            Storage.deleteValue(parentMenuItemId);
            Storage.setValue("numAlarms", 0);
        }
        else {
            var alarm = appDelegate.getAlarmFromStorage(parentMenuItemId);
            alarm.setDelete(true);
            appDelegate.editAlarmInStorage(parentMenuItemId, alarm);
        }
        grandParentMenu.deleteItem(grandParentMenuItemId - 1);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }
}
