import Toybox.WatchUi;
import Toybox.System;

/**
 * @file        RepeatAlarmMenu.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description RepeatAlarmMenu is a Menu2 object for choosing a repeat setting for an alarm
 *              RepeatAlarmMenuDelegate handles inputs on a RepeatAlarmMenu
 *              CustomRepeatAlarmMenu is a CheckboxMenu if a user wants a custom repeat setting
 *              CustomRepeatAlarmMenuDelegate handles inputs on a CustomRepeatAlarmMenu
 */

class RepeatAlarmMenu extends WatchUi.Menu2 {

    function initialize(options) {
        Menu2.initialize(options);
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

    function initialize(curRepeatSetting, editAlarmMenu, editAlarmMenuItemId, alarmMenu) {
        Menu2InputDelegate.initialize();
        self.curRepeatSetting = curRepeatSetting;
        self.editAlarmMenu = editAlarmMenu;
        self.editAlarmMenuItemId = editAlarmMenuItemId;
        self.alarmMenu = alarmMenu;

        System.println("RepeatAlarmMenuDelegate()");
        System.println(curRepeatSetting);
        System.println(editAlarmMenuItemId);
    }

    function onSelect(item) {
        var alarm = StorageManager.getAlarmFromStorage(editAlarmMenuItemId);
        if (!item.getId().equals("custom")) {
            alarm.setRepeatByLabel(item.getId());
            StorageManager.editAlarmInStorage(editAlarmMenuItemId, alarm);
            System.println(alarm.getRepeatLabel());

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
        else {
            var customRepeatAlarmMenu = new CustomRepeatAlarmMenu({:title=>"Custom"}, alarm.repeatArray);
            WatchUi.pushView(
                customRepeatAlarmMenu,
                new CustomRepeatAlarmMenuDelegate(alarm, customRepeatAlarmMenu, editAlarmMenu, editAlarmMenuItemId, alarmMenu),
                WatchUi.SLIDE_RIGHT);
        }
    }
}

class CustomRepeatAlarmMenu extends WatchUi.CheckboxMenu {

    var repeatArray;

    function initialize(options, repeatArray) {
        CheckboxMenu.initialize(options);
        self.repeatArray = repeatArray;
        buildMenu();
    }

    function buildMenu() {
        System.println("Building menu");
        self.addItem(
            new CheckboxMenuItem(
                "Sunday",
                null,
                "Sun",
                repeatArray.size() == 0 ? false : repeatArray[0],
                {}
            )
        );
        self.addItem(
            new CheckboxMenuItem(
                "Monday",
                null,
                "Mon",
                repeatArray.size() == 0 ? false : repeatArray[1],
                {}
            )
        );
        self.addItem(
            new CheckboxMenuItem(
                "Tuesday",
                null,
                "Tue",
                repeatArray.size() == 0 ? false : repeatArray[2],
                {}
            )
        );
        self.addItem(
            new CheckboxMenuItem(
                "Wednesday",
                null,
                "Wed",
                repeatArray.size() == 0 ? false : repeatArray[3],
                {}
            )
        );
        self.addItem(
            new CheckboxMenuItem(
                "Thursday",
                null,
                "Thu",
                repeatArray.size() == 0 ? false : repeatArray[4],
                {}
            )
        );
        self.addItem(
            new CheckboxMenuItem(
                "Friday",
                null,
                "Fri",
                repeatArray.size() == 0 ? false : repeatArray[5],
                {}
            )
        );
        self.addItem(
            new CheckboxMenuItem(
                "Saturday",
                null,
                "Sat",
                repeatArray.size() == 0 ? false : repeatArray[6],
                {}
            )
        );
    }
}

class CustomRepeatAlarmMenuDelegate extends WatchUi.Menu2InputDelegate {

    var alarm;
    var customRepeatAlarmMenu;
    var editAlarmMenu;
    var editAlarmMenuItemId;
    var alarmMenu;

    function initialize(alarm, customRepeatAlarmMenu, editAlarmMenu, editAlarmMenuItemId, alarmMenu) {
        Menu2InputDelegate.initialize();
        
        self.alarm = alarm;
        self.customRepeatAlarmMenu = customRepeatAlarmMenu;
        self.editAlarmMenu = editAlarmMenu;
        self.editAlarmMenuItemId = editAlarmMenuItemId;
        self.alarmMenu = alarmMenu;

        System.println("CustomRepeatAlarmMenuDelegate()");
        System.println(editAlarmMenuItemId);

    }

    //When done selecting create the repeatArray
    function onBack() {
        var repeatArray = [];
        for (var i = 0; i < 7; i++){
            repeatArray.add(
                customRepeatAlarmMenu.getItem(i).isChecked()
            );
        }
        System.println("Custom repeat selection");
        System.println(repeatArray.toString());

        alarm.setRepeatByArray(repeatArray);
        StorageManager.editAlarmInStorage(editAlarmMenuItemId, alarm);
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