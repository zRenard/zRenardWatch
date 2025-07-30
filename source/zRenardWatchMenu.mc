import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class zRenardWatchMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Paramètres"});
        addItem(new WatchUi.ToggleMenuItem(
            WatchUi.loadResource(Rez.Strings.ForceRedShiftTitle),
             {:enabled=>"On", :disabled=>"Off"},
            :RedShiftItem,
            Application.Properties.getValue("ForceRedShift"),
            null
        ));
        addItem(new WatchUi.ToggleMenuItem(
            WatchUi.loadResource(Rez.Strings.ForceNightVisionTitle),
             {:enabled=>"On", :disabled=>"Off"},
            :NightVisionItem,
            Application.Properties.getValue("ForceNightVision"),
            null
        ));
    }
}