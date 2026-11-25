import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// "About" screen: app name, version, and GitHub QR code. BACK returns to the previous view.
class AboutView extends WatchUi.View {
    private var _appName as String?;
    private var _version as String?;
    private var _qr as WatchUi.BitmapResource?;

    public function initialize() {
        View.initialize();
        _appName = null;
        _version = null;
        _qr = null;
    }

    public function onShow() as Void {
        if (_appName == null) {
            _appName = WatchUi.loadResource(Rez.Strings.AppName) as String;
        }
        if (_version == null) {
            _version = WatchUi.loadResource(Rez.Strings.AppVersion) as String;
        }
        if (_qr == null) {
            _qr = WatchUi.loadResource(Rez.Drawables.QrGithub) as WatchUi.BitmapResource;
        }
    }

    public function onHide() as Void {
        _qr = null;
    }

    public function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var appName = (_appName != null) ? (_appName as String) : "";
        var version = (_version != null) ? (_version as String) : "";
        var qr = _qr;

        var sub = DisplayUtils.findSubscreen();
        if (sub != null) {
            // Instinct (sub-display lens): app name + version stacked to the
            // LEFT of the lens — same shape as the main dashboard's
            // timer + total — with the QR + caption centered in the area below.
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
                if (line1 != null) {
                    DisplayUtils.drawCentered(dc, leftCx, subY + subH * 0.20, Graphics.FONT_XTINY, line1);
                }
                if (line2 != null) {
                    DisplayUtils.drawCentered(dc, leftCx, subY + subH * 0.50, Graphics.FONT_XTINY, line2);
                }
            } else {
                DisplayUtils.drawCentered(dc, leftCx, subY + subH * 0.35, Graphics.FONT_XTINY, appName);
            }
            dc.setColor(DisplayUtils.fgColor(Graphics.COLOR_LT_GRAY), Graphics.COLOR_TRANSPARENT);
            DisplayUtils.drawCentered(dc, leftCx, subY + subH * 0.82, Graphics.FONT_XTINY, "v" + version);

            if (qr != null) {
                drawQrAndHint(dc, cx, topY, useH, h, qr, 2);
            }
        } else {
            // Round / rectangular watches: stacked title + version at top,
            // QR + scan hint vertically centered in the space below.
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            DisplayUtils.drawCentered(dc, cx, h * 0.16, Graphics.FONT_TINY, appName);
            dc.setColor(DisplayUtils.fgColor(Graphics.COLOR_LT_GRAY), Graphics.COLOR_TRANSPARENT);
            var verY = (h * 26) / 100;
            DisplayUtils.drawCentered(dc, cx, verY, Graphics.FONT_XTINY, "v" + version);

            if (qr != null) {
                var contentTop = verY + dc.getFontHeight(Graphics.FONT_XTINY) / 2 + 4;
                var contentBottom = h - (h * 6) / 100;
                drawQrAndHint(dc, cx, contentTop, contentBottom - contentTop, h, qr, 4);
            }
        }
    }

    private function drawQrAndHint(
        dc as Dc, cx as Number, topY as Number, availH as Number,
        screenH as Number, qr as WatchUi.BitmapResource, gap as Number
    ) as Void {
        var qrW = qr.getWidth();
        var qrH = qr.getHeight();
        var hintH = dc.getFontHeight(Graphics.FONT_XTINY);
        var blockH = qrH + gap + hintH;
        var qrY = topY + (availH - blockH) / 2;
        if (qrY < topY) {
            qrY = topY;
        }
        dc.drawBitmap(cx - qrW / 2, qrY, qr);
        var hintY = qrY + qrH + gap + hintH / 2;
        if (hintY + hintH / 2 <= screenH) {
            dc.setColor(DisplayUtils.fgColor(Graphics.COLOR_LT_GRAY), Graphics.COLOR_TRANSPARENT);
            DisplayUtils.drawCentered(dc, cx, hintY, Graphics.FONT_XTINY, "scan for source");
        }
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
