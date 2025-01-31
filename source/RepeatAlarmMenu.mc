import Toybox.WatchUi;
import Toybox.System;

class RepeatAlarmMenu extends WatchUi.Menu2 {

    var appDelegate;

    function initialize(options, delegate) {
        Menu2.initialize(options);
        appDelegate = delegate;
        buildMenu();
    }

    function buildMenu() {
        self.addItem(
            new MenuItem(
                "Once",
                null,
                "once",
                {}
        ));
        self.addItem(
            new MenuItem(
                "Daily",
                null,
                "daily",
                {}
        ));
        self.addItem(
            new MenuItem(
                "Weekday",
                null,
                "weekday",
                {}
        ));
        self.addItem(
            new MenuItem(
                "Weekend",
                null,
                "weekend",
                {}
        ));
        self.addItem(
            new MenuItem(
                "Custom",
                null,
                "custom",
                {}
        ));
    }
}

class RepeatAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    /*
    Needed data
    1. Current repeat setting - to set focus on the menu after opening
    2. Parent menu (editAlarmMenu) to update the repeat menuItem sublabel
    3. grandparent menu (alarmMenu) to update the alarm menuItem sublabel
    */
    var curRepeatSetting;
    var editAlarmMenu;
    var editAlarmMenuItemId;
    var alarmMenu;

    var appDelegate;

    function initialize(curRepeatSetting, editAlarmMenu, editAlarmMenuItemId, alarmMenu) {
        Menu2InputDelegate.initialize();
        self.curRepeatSetting = curRepeatSetting;
        self.editAlarmMenu = editAlarmMenu;
        self.editAlarmMenuItemId = editAlarmMenuItemId;
        self.alarmMenu = alarmMenu;

        System.println("RepeatAlarmMenuDelegate()");
        System.println(curRepeatSetting);
        System.println(editAlarmMenuItemId);

        appDelegate = new SmartAlarmDelegate();
    }

    function onSelect(item) {
        var alarm = appDelegate.getAlarmFromStorage(editAlarmMenuItemId);
        if (!item.getId().equals("custom")) {
            alarm.setRepeatByLabel(item.getId());
            appDelegate.editAlarmInStorage(editAlarmMenuItemId, alarm);
            System.println(alarm.getRepeatLabel());
        }

        var repeatLabel = alarm.getRepeatLabel();

        var editAlarmMenuItem = editAlarmMenu.getItem(2);        
        editAlarmMenuItem.setSubLabel(repeatLabel);
        editAlarmMenu.updateItem(editAlarmMenuItem, 2);

        var alarmMenuItem = alarmMenu.getItem(editAlarmMenuItemId - 1);
        alarmMenuItem.setEnabled(alarm.active);
        alarmMenuItem.setSubLabel(repeatLabel);
        alarmMenu.updateItem(alarmMenuItem, editAlarmMenuItemId - 1);

        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }
}