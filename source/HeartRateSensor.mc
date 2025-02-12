import Toybox.Sensor;
import Toybox.Math;

(:background)
class HeartRateSensor {

    var heartBeatIntervals = [];
    var sdnnArray = [];
    var callBackCounter;

    function initialize() {
        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
    }

    function start() {
        callBackCounter = 0;
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
            computeSDNN(heartBeatIntervals);
        }
        callBackCounter++;
        if (callBackCounter == 10) {
            var avg = stop();
            Background.exit(avg);
        }
    }

    function computeSDNN(rrIntervals) {
        var n = rrIntervals.size();
        if (n < 2) {
            return null; // Not enough data
        }

        // Compute mean RR interval
        var sum = 0;
        for (var i = 0; i < n; i++) {
            sum += rrIntervals[i];
        }
        var meanRR = sum / n;

        // Compute squared differences from mean
        var sumSquaredDiff = 0;
        for (var i = 0; i < n; i++) {
            sumSquaredDiff += Math.pow(rrIntervals[i] - meanRR, 2);
        }

        // Compute SDNN (standard deviation)
        var sdnn = Math.sqrt(sumSquaredDiff / n);
        sdnnArray.add(sdnn);
        System.println("HRV Reading: " + sdnn);
        return sdnn;
    }

    function stop() {
        Sensor.unregisterSensorDataListener();
        var sdnnSum = 0.0;
        var n = sdnnArray.size();
        for (var i = 0; i < n; i++) {
            sdnnSum += sdnnArray[i];
        }
        var sdnnAvg = sdnnSum / n;
        if (n > 0) {
            System.println("Average HRV is " + (sdnnAvg).toString() + "ms");
        }
        else {
            System.println("array is null");
        }
        return sdnnAvg;
    }
}