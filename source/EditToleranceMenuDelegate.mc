import Toybox.WatchUi;

class EditToleranceMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    var toleranceItem as WatchUi.MenuItem;

    function initialize(item) {
        Menu2InputDelegate.initialize();
        
        toleranceItem = item;
    }

    function onSelect(item as MenuItem) as Void {
        var tolerance = StorageManager.getTolerance();
        if (item.getId().equals("increase")) {
            StorageManager.setTolerance(tolerance + 0.1f);
            toleranceItem.setLabel("Tolerance: " + (tolerance + 0.1));
        }
        else if (item.getId().equals("decrease")) {
            StorageManager.setTolerance(tolerance - 0.1f);
            toleranceItem.setLabel("Tolerance: " + (tolerance - 0.1));
        }
    }
}