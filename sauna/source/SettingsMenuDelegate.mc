import Toybox.Lang;
import Toybox.WatchUi;

// Handles selections from the Settings menu (Vibration toggle, About).
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _activity as SaunaActivity;

    public function initialize(activity as SaunaActivity) {
        Menu2InputDelegate.initialize();
        _activity = activity;
    }

    public function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :vibrate && item instanceof WatchUi.ToggleMenuItem) {
            _activity.setVibrateEnabled((item as WatchUi.ToggleMenuItem).isEnabled());
        } else if (id == :about) {
            WatchUi.pushView(new AboutView(), new AboutDelegate(), WatchUi.SLIDE_LEFT);
        }
    }
}
