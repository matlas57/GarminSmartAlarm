import Toybox.WatchUi;

class AlarmCheckMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var alarmCheckSelectionMenu = new WatchUi.Menu2({:title=>"Alarm Check"});
        var alarmCheck = StorageManager.getAlarmCheckFromStorage(item.getId());
        if (alarmCheck != null) {
            if (alarmCheck.actualResult.equals("")){
                var promptTitle = "Awake at " + alarmCheck.timeString + "?";
                var actualResultPrompt = new WatchUi.Confirmation(promptTitle);
                
                var actualResultMenuItem = buildMenu(alarmCheckSelectionMenu, alarmCheck);
                WatchUi.pushView(alarmCheckSelectionMenu, new Menu2InputDelegate(), WatchUi.SLIDE_LEFT);

                WatchUi.pushView(
                    actualResultPrompt,
                    new ActualResultPromptDelegate(item.getId(), actualResultMenuItem),
                    WatchUi.SLIDE_IMMEDIATE
                );
            }
            else {
                buildMenu(alarmCheckSelectionMenu, alarmCheck);
                WatchUi.pushView(alarmCheckSelectionMenu, new Menu2InputDelegate(), WatchUi.SLIDE_LEFT);
            }
        }
        else {
            SmartAlarmApp.debugLog("Alarm check null");
        }
    }

    function buildMenu(alarmCheckSelectionMenu as Menu2, alarmCheck as AlarmCheck) {
        alarmCheckSelectionMenu.addItem(
            new MenuItem(
                "Time: " + alarmCheck.timeString,
                "",
                "time",
                {}
            )
        );
        alarmCheckSelectionMenu.addItem(
            new MenuItem(
                "SDANN: " + alarmCheck.sdann,
                "",
                "sdann",
                {}
            )
        );
        alarmCheckSelectionMenu.addItem(
            new MenuItem(
                "Before SDNN: " + alarmCheck.beforeSDNN,
                "",
                "before",
                {}
            )
        );
        alarmCheckSelectionMenu.addItem(
            new MenuItem(
                "During SDNN: " + alarmCheck.duringSDNN,
                "",
                "during",
                {}
            )
        );
        alarmCheckSelectionMenu.addItem(
            new MenuItem(
                "After SDNN: " + alarmCheck.afterSDNN,
                "",
                "after",
                {}
            )
        );
        alarmCheckSelectionMenu.addItem(
            new MenuItem(
                "Predicted Result: " + alarmCheck.predictedResult,
                "",
                "predicted",
                {}
            )
        );
        var actualResultMenuItem = new MenuItem(
            "Actual Result: " + alarmCheck.actualResult,
            "",
            "actual",
            {}
        );
        alarmCheckSelectionMenu.addItem(actualResultMenuItem);
        return actualResultMenuItem;
    }
}