import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SmartAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    var appDelegate;

    var parentMenu;

    var statusButtonId = 0;
    var editButtonId = 1;
    var deleteButtonId = 2;

    function initialize(parentMenu, delegate) {
        Menu2InputDelegate.initialize();
        self.parentMenu = parentMenu;
        appDelegate = delegate;
    }

    function onSelect(item) {
        System.println(item.getId());
        var delegate = new SmartAlarmDelegate();
        if (item.getId().equals("addAlarmButton")) {
            System.println("Changing appState to earliestAlarmPrompt");
            appState = "earliestAlarmPrompt";
            WatchUi.pushView(new SmartAlarmView(delegate), delegate, WatchUi.SLIDE_UP);
        }
        else {
            var id = item.getId() as Number;
            var alarm = delegate.getAlarmFromStorage(id);
            var editAlarmMenuTitle = alarm.earliestHour.toString() + ":" + delegate.padMinuteString(alarm.earliestMinute) + " - " + alarm.latestHour.toString() + ":" + delegate.padMinuteString(alarm.latestMinute);
            System.println("Creating menu with title " + editAlarmMenuTitle);
            var editAlarmMenu = new WatchUi.Menu2({:title=>editAlarmMenuTitle});
            editAlarmMenu.addItem(
                new ToggleMenuItem(
                    "Status",
                    alarm.active ? "On" : "Off",
                    statusButtonId,
                    alarm.active,
                    {} //Place to add on off switch icon
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Time",
                    editAlarmMenuTitle,
                    editButtonId,
                    {} //Place to add on off switch icon
            ));
            editAlarmMenu.addItem(
                new MenuItem(
                    "Delete",
                    "",
                    deleteButtonId,
                    {} //Place to add on off switch icon
            ));
            WatchUi.pushView(editAlarmMenu, new EditAlarmMenuDelegate(editAlarmMenu, parentMenu, id), WatchUi.SLIDE_RIGHT);
            // Slide right to a new menu with options for the current alarm 
                //Create new alarm class EditAlarmMenuDelegate
                //Create menu layout in menus.xml
                //Add functions for onSelect for the buttons 
                //Pass parent menu to update the parent menu
                //Pop the menu when done
            // alarm.toggleActive();
            //Need to update the menu view somehow to reflect the change
        }
    }

    function onBack() {
        System.println("Pressed back to exit menu");
        appDelegate.reorganizeStorage();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}