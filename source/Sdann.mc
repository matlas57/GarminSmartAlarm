import Toybox.Lang;

(:background)
class Sdann {

    //Stores the meanNNInterval returned from each background HR recording
    var meanNNIntervalArray as Lang.Array;
    var overnightHRV as Lang.Float;

    function initialize(){
        meanNNIntervalArray = [];
    }

    function addNewMeanNNInterval(meanNNInterval) {
        System.println("Adding new interval to array: " + meanNNInterval);
        meanNNIntervalArray.add(meanNNInterval);
    }

    function computeSDANN() {
        // Compute squared differences from mean
        var sumSquaredDiff = 0;
        var meanNNIntervals = computeMean(meanNNIntervalArray);
        var n = meanNNIntervalArray.size();
        for (var i = 0; i < n; i++) {
            sumSquaredDiff += Math.pow(meanNNIntervalArray[i] - meanNNIntervals, 2);
        }

        // Compute SDANN (standard deviation)
        var sdann = Math.sqrt(sumSquaredDiff / n);
        System.println("HRV Reading: " + sdann);
        overnightHRV = sdann;
        return sdann;
    }

    function computeMean(array) as Lang.Number {
        var n = array.size();
        if (n == 0){
            return 0;
        }
        var sum = 0;
        for (var i = 0; i < n; i++) {
            sum += array[i];
        }
        return sum / n;
    }

}