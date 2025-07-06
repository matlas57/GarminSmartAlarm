using Toybox.WatchUi;
using Toybox.System;
import Toybox.Application;

/**
 * @file        ClearDataConfirmationDelegate.mc
 * @author      Matan Atlas
 * @date        2025-07-6
 * @version     1.0
 * @description ClearDataConfirmationDelegate manages inputs as the delete confirmation appears
 */

class ClearDataConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    var storageKey;
    
    function initialize(key) {
        ConfirmationDelegate.initialize();
        storageKey = key;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            if (storageKey.equals("overnightAverages")) {
                $.overnightAverages = [];
                Storage.deleteValue("overnightAverages");
            }
            return true;
        } else {
            return false;
        }
    }
}