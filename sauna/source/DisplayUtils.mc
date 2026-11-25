import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Shared display helpers for saunaView and AboutView.
module DisplayUtils {
    // Returns the sub-display rectangle on Instinct-class watches, or null.
    function findSubscreen() as Graphics.BoundingBox? {
        if (WatchUi has :getSubscreen) {
            var sub = WatchUi.getSubscreen();
            if (sub != null && sub.x != null && sub.y != null
                    && sub.width != null && sub.height != null) {
                return sub;
            }
        }
        return null;
    }

    function drawCentered(
        dc as Graphics.Dc, x as Numeric, y as Numeric,
        font as Graphics.FontType, text as String
    ) as Void {
        dc.drawText(x, y, font, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Maps an accent color for the current display. On 1-bit monochrome
    // watches, low-luminance colors like blue or red can quantize to black
    // against a black background, so force all foreground accents to white.
    (:color)
    function fgColor(color as Graphics.ColorType) as Graphics.ColorType {
        return color;
    }

    (:mono)
    function fgColor(color as Graphics.ColorType) as Graphics.ColorType {
        return Graphics.COLOR_WHITE;
    }
}
