import Toybox.WatchUi;

class AlarmCheckMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var alarmCheckSelectionMenu = new WatchUi.Menu2({:title=>"Alarm Check"});
        var alarmCheck = StorageManager.getAlarmCheckFromStorage(item.getId());
        if (alarmCheck != null) {
            alarmCheckSelectionMenu.addItem(
                new MenuItem(
                    "Time: " + alarmCheck.timeString,
                    "",
                    "",
                    {}
                )
            );
            alarmCheckSelectionMenu.addItem(
                new MenuItem(
                    "SDANN: " + alarmCheck.sdann,
                    "",
                    "",
                    {}
                )
            );
            alarmCheckSelectionMenu.addItem(
                new MenuItem(
                    "Before SDNN: " + alarmCheck.beforeSDNN,
                    "",
                    "",
                    {}
                )
            );
            alarmCheckSelectionMenu.addItem(
                new MenuItem(
                    "During SDNN: " + alarmCheck.duringSDNN,
                    "",
                    "",
                    {}
                )
            );
            alarmCheckSelectionMenu.addItem(
                new MenuItem(
                    "After SDNN: " + alarmCheck.afterSDNN,
                    "",
                    "",
                    {}
                )
            );
            alarmCheckSelectionMenu.addItem(
                new MenuItem(
                    "Result: " + alarmCheck.result,
                    "",
                    "",
                    {}
                )
            );
            WatchUi.pushView(alarmCheckSelectionMenu, new Menu2InputDelegate(), WatchUi.SLIDE_LEFT);
        }
        else {
            System.println("Alarm check null");
        }
    }
}