import Toybox.WatchUi;

class EditThresholdMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    var thresholdItem as WatchUi.MenuItem;

    function initialize(item) {
        Menu2InputDelegate.initialize();
        
        thresholdItem = item;
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId().equals("increase")) {
            $.threshold += 0.1;
        }
        else if (item.getId().equals("decrease")) {
            $.threshold -= 0.1;
        }
        thresholdItem.setLabel("Threshold: " + $.threshold);
    }
}