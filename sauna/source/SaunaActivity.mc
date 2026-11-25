import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Application.Storage;
import Toybox.Attention;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Timer;

// Recording state machine for a sauna session.
enum SaunaState {
    STATE_STOPPED, // no open session (initial state, or after save/discard)
    STATE_RUNNING, // timer active, recording
    STATE_PAUSED   // session open but timer stopped
}

// The two kinds of phase a sauna session alternates between.
enum RoundType {
    ROUND_SAUNA, // in the hot room
    ROUND_RELAX  // cool down / rest
}

// Wraps an ActivityRecording.Session and exposes a tiny state machine.
// A sauna is recorded as a generic "Cardio" training activity (no GPS),
// so it shows up in Garmin Connect with duration, heart rate and calories.
class SaunaActivity {
    private var _session as ActivityRecording.Session?;
    private var _state as SaunaState;
    private var _roundType as RoundType; // current phase: sauna or relax
    private var _saunaCount as Number;
    private var _relaxCount as Number;
    private var _roundStartMs as Number; // timerTime when the current phase began
    private var _tempField as FitContributor.Field?; // records temperature into the FIT
    private var _sampleTimer as Timer.Timer?;
    private var _currentTempC as Float?;
    private var _vibrateEnabled as Boolean;

    public function initialize() {
        _session = null;
        _state = STATE_STOPPED;
        _roundType = ROUND_SAUNA;
        _saunaCount = 0;
        _relaxCount = 0;
        _roundStartMs = 0;
        _tempField = null;
        _sampleTimer = null;
        _currentTempC = null;
        _vibrateEnabled = loadVibrateSetting();

        enableSensors();
        refreshTemperature();
    }

    public function getState() as SaunaState {
        return _state;
    }

    public function getRoundType() as RoundType {
        return _roundType;
    }

    public function getSaunaCount() as Number {
        return _saunaCount;
    }

    public function getRelaxCount() as Number {
        return _relaxCount;
    }

    // Latest ambient temperature in Celsius, or null if unavailable.
    public function getCurrentTempC() as Float? {
        return _currentTempC;
    }

    // Current heart rate from the activity or live sensor, or null if unavailable.
    public function getCurrentHeartRate(info as Activity.Info?) as Number? {
        var hr = (info != null) ? info.currentHeartRate : null;
        if (hr != null) {
            return hr;
        }
        if ((Toybox has :Sensor) && (Sensor has :getInfo)) {
            var sensorInfo = Sensor.getInfo();
            var sensorHr = (sensorInfo != null) ? sensorInfo.heartRate : null;
            if (sensorHr != null) {
                return sensorHr;
            }
        }
        return null;
    }

    // timerTime (moving ms) at which the current phase started.
    public function getRoundStartMs() as Number {
        return _roundStartMs;
    }

    public function isActive() as Boolean {
        return _state != STATE_STOPPED;
    }

    public function isVibrateEnabled() as Boolean {
        return _vibrateEnabled;
    }

    public function setVibrateEnabled(enabled as Boolean) as Void {
        _vibrateEnabled = enabled;
        Storage.setValue("vibrate", enabled);
    }

    // Start a brand-new session, or resume a paused one.
    public function startOrResume() as Void {
        var s = _session;
        if (s == null) {
            s = ActivityRecording.createSession({
                :name => "Sauna",
                :sport => Activity.SPORT_TRAINING,
                :subSport => Activity.SUB_SPORT_CARDIO_TRAINING
            });
            _tempField = s.createField(
                "temperature", 0, FitContributor.DATA_TYPE_FLOAT,
                { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "C" }
            );
            _session = s;
            _roundType = ROUND_SAUNA;
            _saunaCount = 1;
            _relaxCount = 0;
            _roundStartMs = 0;
        }
        if (!s.isRecording()) {
            s.start();
        }
        _state = STATE_RUNNING;
        startSampling();
        vibe(50, 200);
    }

    // Pause the timer but keep the session open.
    public function pause() as Void {
        var s = _session;
        if (s == null) {
            return;
        }
        if (s.isRecording()) {
            s.stop();
        }
        stopSampling();
        _state = STATE_PAUSED;
        vibe(50, 100);
    }

    // Switch between the sauna and relax phases. Each switch closes the
    // current lap and opens a new one. Returns true if it happened.
    public function switchPhase() as Boolean {
        var s = _session;
        if (s != null && s.isRecording()) {
            s.addLap();
            if (_roundType == ROUND_SAUNA) {
                _roundType = ROUND_RELAX;
                _relaxCount += 1;
            } else {
                _roundType = ROUND_SAUNA;
                _saunaCount += 1;
            }
            var info = Activity.getActivityInfo();
            var timerTime = (info != null) ? info.timerTime : null;
            _roundStartMs = (timerTime != null) ? timerTime : 0;
            vibe(75, 150);
            return true;
        }
        return false;
    }

    // Stop the timer (if needed) and write the activity to history.
    public function save() as Void {
        stopSampling();
        var s = _session;
        if (s != null) {
            if (s.isRecording()) {
                s.stop();
            }
            s.save();
        }
        resetSessionState();
        vibe(100, 400);
    }

    // Throw the session away without saving.
    public function discard() as Void {
        stopSampling();
        var s = _session;
        if (s != null) {
            if (s.isRecording()) {
                s.stop();
            }
            s.discard();
        }
        resetSessionState();
    }

    // Release timers and sensors when the app shuts down.
    public function shutdown() as Void {
        stopSampling();
        disableSensors();
    }

    // Refresh the cached temperature reading (without writing to FIT).
    public function refreshTemperature() as Void {
        _currentTempC = readTemperatureC();
    }

    // Read the current temperature and attach it to the FIT record stream.
    public function sampleTemperature() as Void {
        var c = readTemperatureC();
        _currentTempC = c;
        if (_state == STATE_RUNNING && c != null && _tempField != null) {
            (_tempField as FitContributor.Field).setData(c);
        }
    }

    private function resetSessionState() as Void {
        _session = null;
        _tempField = null;
        _state = STATE_STOPPED;
        _roundType = ROUND_SAUNA;
        _saunaCount = 0;
        _relaxCount = 0;
        _roundStartMs = 0;
    }

    private function enableSensors() as Void {
        if ((Toybox has :Sensor) && (Sensor has :setEnabledSensors)) {
            Sensor.setEnabledSensors([
                Sensor.SENSOR_HEARTRATE,
                Sensor.SENSOR_TEMPERATURE
            ] as Array<Sensor.SensorType>);
        }
    }

    private function disableSensors() as Void {
        if ((Toybox has :Sensor) && (Sensor has :setEnabledSensors)) {
            Sensor.setEnabledSensors([] as Array<Sensor.SensorType>);
        }
    }

    private function startSampling() as Void {
        if (_sampleTimer == null) {
            _sampleTimer = new Timer.Timer();
        }
        (_sampleTimer as Timer.Timer).start(method(:sampleTemperature), 1000, true);
        sampleTemperature(); // capture one reading immediately
    }

    private function stopSampling() as Void {
        if (_sampleTimer != null) {
            (_sampleTimer as Timer.Timer).stop();
        }
    }

    private function readTemperatureC() as Float? {
        // Prefer live ambient temperature from a paired external Garmin tempe sensor.
        if ((Toybox has :Sensor) && (Sensor has :getInfo)) {
            var sensorInfo = Sensor.getInfo();
            var temp = (sensorInfo != null) ? sensorInfo.temperature : null;
            if (temp != null) {
                return temp.toFloat();
            }
        }
        // Fall back to the watch's built-in thermometer history.
        if ((Toybox has :SensorHistory) && (SensorHistory has :getTemperatureHistory)) {
            var iter = SensorHistory.getTemperatureHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
            if (iter != null) {
                var sample = iter.next();
                var data = (sample != null) ? sample.data : null;
                if (data != null) {
                    return data.toFloat();
                }
            }
        }
        return null;
    }

    private function loadVibrateSetting() as Boolean {
        var stored = Storage.getValue("vibrate");
        if (stored instanceof Boolean) {
            return stored;
        }
        return true;
    }

    private function vibe(intensity as Number, durationMs as Number) as Void {
        if (!_vibrateEnabled) {
            return;
        }
        var settings = System.getDeviceSettings();
        if ((settings has :vibrateOn) && !settings.vibrateOn) {
            return;
        }
        if (Attention has :vibrate) {
            Attention.vibrate(
                [new Attention.VibeProfile(intensity, durationMs)] as Array<Attention.VibeProfile>
            );
        }
    }
}
