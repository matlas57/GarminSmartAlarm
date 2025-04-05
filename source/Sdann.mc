import Toybox.Lang;

/**
 * @file        Sdann.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description Sdann is responsible for computations on heart rate data for detecting wakefullness and triggering alarms
 */

(:background)
class Sdann {

    //Stores the meanNNInterval returned from each background HR recording
    var meanNNIntervalArray as Lang.Array;
    var overnightHRV as Lang.Float?;
    var beforeSDNN as Lang.Float?;
    var duringSDNN as Lang.Float?;
    var afterSDNN as Lang.Float?;

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
        if (n == 0) {
            overnightHRV = 0.0;
            return 0.0;
        }
        for (var i = 0; i < n; i++) {
            sumSquaredDiff += Math.pow(meanNNIntervalArray[i] - meanNNIntervals, 2);
        }

        // Compute SDANN (standard deviation)
        var sdann = Math.sqrt(sumSquaredDiff / n);
        System.println("HRV Reading: " + sdann);
        overnightHRV = sdann;
        return sdann;
    }

    function computeCurrentSDNN(currentReadingArray as Lang.Array<Lang.Array<Lang.Number>>) {
        var beforeIntervalArray = [];
        var duringIntervalArray = [];
        var afterIntervalArray = [];
        for (var i = 0; i < 3; i++) {
            for (var j = 0; j < 10; j++) {
                if (i == 0) {
                    beforeIntervalArray.addAll(currentReadingArray[j]);
                }
                else if (i == 1) {
                    duringIntervalArray.addAll(currentReadingArray[10 + j]);
                }
                else if (i == 2) {
                    afterIntervalArray.addAll(currentReadingArray[20 + j]);
                }
            }
        }
        
        var beforeIntervalMean = computeMean(beforeIntervalArray);
        var duringIntervalMean = computeMean(duringIntervalArray);
        var afterIntervalMean = computeMean(afterIntervalArray);

        beforeSDNN = sdnnFormula(beforeIntervalArray, beforeIntervalMean);
        duringSDNN = sdnnFormula(duringIntervalArray, duringIntervalMean);
        afterSDNN = sdnnFormula(afterIntervalArray, afterIntervalMean);

        return [beforeSDNN, duringSDNN, afterSDNN];
    }

    function sdnnFormula(intervals as Lang.Array<Lang.Number>, mean) {
        var sumSquaredDiff = 0;
        var n = intervals.size();
        if (n == 0) {
            return 0;
        }
        for (var i = 0; i < n; i++) {
            sumSquaredDiff += Math.pow(intervals[i] - mean, 2);
        }
        return Math.sqrt(sumSquaredDiff / n);
    }

    function isAwake(){
        var threshold = 1.5;
        var tolerance = 0.1;
        var lowerBound = overnightHRV * (1 - tolerance);
        var upperBound = overnightHRV * (1 + tolerance);
        if (duringSDNN > threshold * overnightHRV
            && (lowerBound <= beforeSDNN && beforeSDNN <= upperBound)
            && (lowerBound <= afterSDNN && afterSDNN <= upperBound)) {
            return true;
        }
        return false;
    }

    function computeMean(array as Lang.Array) as Lang.Number {
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