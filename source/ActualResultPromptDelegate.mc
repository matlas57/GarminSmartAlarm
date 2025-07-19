using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application;

/**
 * @file        ActualResultPromptDelegate.mc
 * @author      Matan Atlas
 * @date        2025-07-18
 * @version     1.0
 * @description ActualResultPromptDelegate manages inputs as the prompt for the actual result of a alarm check
 */

class ActualResultPromptDelegate extends WatchUi.ConfirmationDelegate {

    var alarmCheckId;
    var actualResultMenuItem;
    
    function initialize(id, menuItem) {
        ConfirmationDelegate.initialize();
        alarmCheckId = id;
        actualResultMenuItem = menuItem;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            StorageManager.addActualResultToAlarmCheck(alarmCheckId, "Awake");
            actualResultMenuItem.setLabel("Actual Result: Awake");
        } else {
            StorageManager.addActualResultToAlarmCheck(alarmCheckId, "Asleep");
            actualResultMenuItem.setLabel("Actual Result: Asleep");
        }
        SmartAlarmApp.writeAlarmCheckToLogFile(alarmCheckId);
        return true;
    }
}