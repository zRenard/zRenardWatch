import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class zRenardWatchMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(menuitem as WatchUi.MenuItem) as Void {
       if ( menuitem.getId().equals(:RedShiftItem) ) {
            Application.Properties.setValue("ForceRedShift", !Application.Properties.getValue("ForceRedShift"));
            if (Application.Properties.getValue("ForceRedShift")) {
                Application.Properties.setValue("Mode", 2);
            } else {
                Application.Properties.setValue("Mode", 0);
            }
            Application.getApp().onSettingsChanged();
        }
        if ( menuitem.getId().equals(:NightVisionItem) ) {
            Application.Properties.setValue("ForceNightVision", !Application.Properties.getValue("ForceNightVision"));
            if (Application.Properties.getValue("ForceNightVision")) {
                Application.Properties.setValue("Mode", 1);
            } else {
                Application.Properties.setValue("Mode", 0);
            }
            Application.getApp().onSettingsChanged();
        }
        WatchUi.requestUpdate();
         WatchUi.popView(WatchUi.SLIDE_UP);
    }

}