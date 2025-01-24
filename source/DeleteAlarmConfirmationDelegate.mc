using Toybox.WatchUi;
using Toybox.System;

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