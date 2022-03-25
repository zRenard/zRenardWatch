import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class zRenardWatchApp extends Application.AppBase {

    public function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    public function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    public function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    public function getInitialView() as Array<Views or InputDelegates>? {
        return [ new $.zRenardWatchView() ] as Array<Views>;
    }

    // New app settings have been received so trigger a UI update
    public function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

}