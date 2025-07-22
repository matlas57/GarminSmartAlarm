import Toybox.WatchUi;

class EditThresholdMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    var thresholdItem as WatchUi.MenuItem;

    function initialize(item) {
        Menu2InputDelegate.initialize();
        
        thresholdItem = item;
    }

    function onSelect(item as MenuItem) as Void {
        var threshold = StorageManager.getThreshold();
        if (item.getId().equals("increase")) {
            StorageManager.setThreshold(threshold + 0.1f);
            thresholdItem.setLabel("Threshold: " + (threshold + 0.1));
        }
        else if (item.getId().equals("decrease")) {
            StorageManager.setThreshold(threshold - 0.1f);
            thresholdItem.setLabel("Threshold: " + (threshold - 0.1));
        }
    }
}