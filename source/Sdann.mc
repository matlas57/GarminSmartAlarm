import Toybox.Lang;

(:background)
class Sdann {

    //Stores the meanNNInterval returned from each background HR recording
    var meanNNIntervalArray as Lang.Array;

    function initialize(){
        meanNNIntervalArray = [];
    }

    function addNewMeanNNInterval(meanNNInterval) {
        System.println("Adding new interval to array: " + meanNNInterval);
        meanNNIntervalArray.add(meanNNInterval);
    }

}