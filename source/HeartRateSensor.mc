import Toybox.Sensor;
import Toybox.Math;

(:background)
class HeartRateSensor {

    var heartBeatIntervals = [];
    //Array to hold NN sum to be used to compute the NN average for a single recording
    var intraRecordingNNSum = 0;
    var totalIntervalsRecorded = 0;
    var callBackCounter;

    function initialize() {
        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
    }

    function start() {
        callBackCounter = 0;
        intraRecordingNNSum = 0;
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
            sumNNIntervals(heartBeatIntervals);
        }
        callBackCounter++;
        if (callBackCounter == 10) {
            var avg = stop();
            Background.exit(avg);
        }
    }

    function sumNNIntervals(rrIntervals) {
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