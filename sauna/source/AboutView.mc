import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// "About" screen: app name + version. BACK returns to the previous view.
class AboutView extends WatchUi.View {
    public function initialize() {
        View.initialize();
    }

    public function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var appName = WatchUi.loadResource(Rez.Strings.AppName) as String;
        var version = WatchUi.loadResource(Rez.Strings.AppVersion) as String;
        var qr = WatchUi.loadResource(Rez.Drawables.QrGithub);

        var sub = findSubscreen();
        if (sub != null) {
            // Instinct (sub-display lens): app name + version stacked to the
            // LEFT of the lens — same shape as the main dashboard's
            // timer + total — with the QR centered in the area below.
            // The upper-left zone is only ~113 px wide and the semi-octagon
            // shape clips its left edge near the top, so we split the app
            // name on the first space to keep each line short.
            var subX = sub.x as Number;
            var subY = sub.y as Number;
            var subH = sub.height as Number;
            var leftCx = subX / 2;
            var topY = subY + subH;
            var useH = h - topY;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var spaceIdx = appName.find(" ");
            if (spaceIdx != null) {
                var line1 = appName.substring(0, spaceIdx);
                var line2 = appName.substring(spaceIdx + 1, appName.length());
                drawCentered(dc, leftCx, subY + subH * 0.20, Graphics.FONT_XTINY, line1);
                drawCentered(dc, leftCx, subY + subH * 0.50, Graphics.FONT_XTINY, line2);
            } else {
                drawCentered(dc, leftCx, subY + subH * 0.35, Graphics.FONT_XTINY, appName);
            }
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            drawCentered(dc, leftCx, subY + subH * 0.82, Graphics.FONT_XTINY, "v" + version);

            dc.drawBitmap(cx - 40, topY + useH * 0.50 - 40, qr);
            drawCentered(dc, cx, topY + useH * 0.93, Graphics.FONT_XTINY, "scan for source");
        } else {
            // Round watches (Fenix/Epix): stacked lines centered at the top,
            // QR in the middle, scan hint at the bottom.
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            drawCentered(dc, cx, h * 0.18, Graphics.FONT_TINY, appName);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            drawCentered(dc, cx, h * 0.28, Graphics.FONT_XTINY, "v" + version);
            dc.drawBitmap(cx - 40, h * 0.60 - 40, qr);
            drawCentered(dc, cx, h * 0.93, Graphics.FONT_XTINY, "scan for source");
        }
    }

    // Returns the sub-display rectangle, or null on watches without one.
    private function findSubscreen() as Graphics.BoundingBox? {
        if (WatchUi has :getSubscreen) {
            var sub = WatchUi.getSubscreen();
            if (sub != null && sub.x != null && sub.y != null
                    && sub.width != null && sub.height != null) {
                return sub;
            }
        }
        return null;
    }

    private function drawCentered(dc as Dc, x as Numeric, y as Numeric, font as Graphics.FontType, text as String) as Void {
        dc.drawText(x, y, font, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

// BACK pops back to the settings menu.
class AboutDelegate extends WatchUi.BehaviorDelegate {
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
