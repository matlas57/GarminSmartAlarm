import Toybox.Sensor;
import Toybox.Math;
import Toybox.Lang;

/**
 * @file        HeartRateSensor.mc
 * @author      Matan Atlas
 * @date        2025-03-13
 * @version     1.0
 * @description HeartRateSensor handles collecting data from the heart rate sensor
 */  

(:background)
class HeartRateSensor {

    var heartBeatIntervals as Lang.Array<Lang.Number>;
    var currentReadingArray as Lang.Array<Lang.Array<Lang.Number>>;
    //Array to hold NN sum to be used to compute the NN average for a single recording
    var intraRecordingNNSum as Lang.Number;
    var totalIntervalsRecorded = 0;
    var callBackCounter;

    function initialize() {
        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
        heartBeatIntervals = [];
        currentReadingArray = [];
        intraRecordingNNSum = 0;
    }

    function start() {
        currentReadingArray = [];
        callBackCounter = 0;
        // intraRecordingNNSum = 0;
        totalIntervalsRecorded = 0;
        var options = {
            :period => 1,
             :heartBeatIntervals => {
                :enabled => true
            }};
        try {
            Sensor.registerSensorDataListener(method(:heartBeatIntervalsCallback), options);
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    function heartBeatIntervalsCallback(sensorData as SensorData) as Void {
        if (sensorData has :heartRateData && sensorData.heartRateData != null) {
            heartBeatIntervals = sensorData.heartRateData.heartBeatIntervals;
            currentReadingArray.add(heartBeatIntervals);
            sumNNIntervals(heartBeatIntervals);
        }
        callBackCounter++;
        if (callBackCounter == 30) {
            var avg = stop();
            var backgroundData = {
                "avg" => avg,
                "currentReadingArray" => currentReadingArray
            };
            Background.exit(backgroundData);
        }
    }

    function sumNNIntervals(rrIntervals as Lang.Array<Lang.Number>) {
        System.println(rrIntervals.toString());
        var n = rrIntervals.size();
        if (n <= 0) {
            return;
        }
        for (var i = 0; i < n; i++){
            intraRecordingNNSum += rrIntervals[i];
        }
        totalIntervalsRecorded += n;
    }

    function stop() {
        Sensor.unregisterSensorDataListener();
        if (totalIntervalsRecorded == 0) {
            System.println("No intervals recorded");
            return null;
        }
        var meanNNInterval = intraRecordingNNSum / totalIntervalsRecorded;
        System.println("Recorded " + totalIntervalsRecorded + " intervals with average " + meanNNInterval);
        return meanNNInterval;
    }
}