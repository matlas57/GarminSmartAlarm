using Toybox.WatchUi;
using Toybox.System;

/**
 * @file        DeleteAlarmConfirmationDelegate.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description DeleteAlarmConfirmationDelegate manages inputs on the delete confirmation appears
 */

class DeleteAlarmConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    var parentMenuDelegate;
    
    function initialize(pmd) {
        ConfirmationDelegate.initialize();
        parentMenuDelegate = pmd;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            parentMenuDelegate.deleteAlarm();
            return true;
        } else {
            return false;
        }
    }
}