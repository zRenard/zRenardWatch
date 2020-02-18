using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Lang;
using Toybox.Application;

class zRenardWatchView extends WatchUi.WatchFace {
    hidden var ico_msg;
    hidden var ico_charge;
	hidden var sleepMode;
	hidden var font_vlarge;

    function initialize() {
        WatchFace.initialize();
        ico_msg = WatchUi.loadResource(Rez.Drawables.id_msg);
        ico_charge = WatchUi.loadResource(Rez.Drawables.id_charge);
        font_vlarge = WatchUi.loadResource( Rez.Fonts.id_font_vlarge );
        sleepMode = false;        
    }

    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	var battery = (System.getSystemStats().battery + 0.5).toNumber();
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	var bgC = Application.getApp().getProperty("BackgroundColor");
    	var fgC = Application.getApp().getProperty("ForegroundColor");
    	var hlC = Application.getApp().getProperty("HighLightColor");
	    var fgHC = Application.getApp().getProperty("ForegroundColorHours");
	    var fgMC = Application.getApp().getProperty("ForegroundColorMinutes");
	    var bigFont = Application.getApp().getProperty("ShowBigFont");
    	var offSetBigFont = 0;
    	var offSetBigFontNotif = 0;
    	
    	if (bigFont) {
    		offSetBigFont = 18;
    		offSetBigFontNotif = 10;
    	}
    	
	    dc.setColor(bgC,bgC);
        dc.clear();
   		if ( !sleepMode ||
    		 ( sleepMode && !Application.getApp().getProperty("UltraSleepMode") ) ||
    		 ( sleepMode && (Application.getApp().getProperty("UltraSleepMode") &&
    		   				 battery>Application.getApp().getProperty("BatteryLevelCritical")
    		 				)
    		 )
    		) {       
			dc.setColor(fgC,Graphics.COLOR_TRANSPARENT);  		
	 		var now = new Time.Moment(Time.today().value());
	 		var nowText = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
			var hours = nowText.hour.toNumber();
	        if (!System.getDeviceSettings().is24Hour) {
				if (hours > 12) {
					hours = hours - 12;
				}
			}
			
			var myHours = Lang.format("$1$",[hours.format("%02d")]);
			var myMinutes = Lang.format("$1$",[nowText.min.format("%02d")]);
			var myDay = Lang.format("$1$",[nowText.day.format("%02d")]);
		
			// Hours
			dc.setColor(fgHC,Graphics.COLOR_TRANSPARENT);
			if (bigFont) {
				dc.drawText( (width / 2)-40, ((height/2)-75)-17-40, font_vlarge,myHours, Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				dc.drawText( (width / 2)-20, ((height/2)-20)-17-40, Graphics.FONT_SYSTEM_NUMBER_THAI_HOT,myHours, Graphics.TEXT_JUSTIFY_CENTER);
			}
			// Minutes
			dc.setColor(fgMC,Graphics.COLOR_TRANSPARENT);
			if (bigFont) {
				dc.drawText( (width / 2)+60, ((height/2)-33)-17-35, font_vlarge, myMinutes, Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				dc.drawText( (width / 2)+20, ((height/2)+20)-17-35, Graphics.FONT_SYSTEM_NUMBER_THAI_HOT, myMinutes, Graphics.TEXT_JUSTIFY_CENTER);
			}
			dc.setColor(hlC ,Graphics.COLOR_TRANSPARENT);
			if (!sleepMode || (sleepMode && !Application.getApp().getProperty("UseSleepMode"))) {
				// Date if not in sleep mode (or sleep mode desactivated)
				dc.drawText( (width / 2), (height /2)+60-20+offSetBigFont, Graphics.FONT_TINY, nowText.day_of_week+" "+myDay+" "+nowText.month+" "+nowText.year, Graphics.TEXT_JUSTIFY_CENTER);
	        	if (!System.getSystemStats().charging && battery <=Application.getApp().getProperty("BatteryLevelCritical")) {
		        	dc.setColor(hlC, hlC);
	    	    	dc.fillRectangle(0, 3*height/4+4+offSetBigFont, width, 20);
	    	    }
		        if (battery <=Application.getApp().getProperty("BatteryLevel") || System.getSystemStats().charging ) {
		        	dc.setColor(fgC, Graphics.COLOR_TRANSPARENT);
		        	dc.drawText(width / 2, 3*height/4+offSetBigFont, Graphics.FONT_TINY, battery.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
		        }
		
		        if (System.getSystemStats().charging ) {
					dc.drawBitmap((width / 2)-20/2, height-20, ico_charge);
		        }
		        
		        if (Application.getApp().getProperty("ShowNotification")) {
					var notification = System.getDeviceSettings().notificationCount;
					if (notification > 0) {
						dc.drawBitmap((width / 2)-(34/2)+50, 34-offSetBigFontNotif, ico_msg);
						dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
						dc.drawText(width / 2+50, 34-offSetBigFontNotif, Graphics.FONT_TINY, notification, Graphics.TEXT_JUSTIFY_CENTER);
					}
				}
			}
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
		sleepMode = false;        
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
		sleepMode = true;
    }
}
