import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.ActivityMonitor;

class zRenardWatchView extends WatchUi.WatchFace {
    var ico_msg = Application.loadResource(Rez.Drawables.id_msg);
    var ico_charge = Application.loadResource(Rez.Drawables.id_charge);
	var ico_move = Application.loadResource(Rez.Drawables.id_move);
	var sleepMode = false;
	var font_vlarge = Application.loadResource(Rez.Fonts.id_font_vlarge);
	var font_medium = Application.loadResource(Rez.Fonts.id_font_medium);

    public function initialize() {
        WatchFace.initialize();    	
        sleepMode = false;      
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }
    
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	var myApp = Application.getApp();
    	var battery = (System.getSystemStats().battery + 0.5).toNumber();
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	var bgC = readKeyInt(myApp,"BackgroundColor",0x000000);
    	var fgC = readKeyInt(myApp,"ForegroundColor",0xFFFFFF);
	    var fgHC = readKeyInt(myApp,"ForegroundColorHours",0xFFFFFF);
	    var fgMC = readKeyInt(myApp,"ForegroundColorMinutes",0xFFFFFF);
    	var hlC = readKeyInt(myApp,"HighLightColor",0xFF5500);
	    var fontSize = readKeyInt(myApp,"FontSize",1);
		var showNotification = readKeyBoolean(myApp,"ShowNotification",true);
		var sleepMode = readKeyBoolean(myApp,"UseSleepMode",false);
		var ultraSleepMode = readKeyBoolean(myApp,"UltraSleepMode",false);
		var batteryLevel = readKeyInt(myApp,"BatteryLevel",30);
		var batteryLevelCritical = readKeyInt(myApp,"BatteryLevelCritical",15);
	    var showMove = readKeyBoolean(myApp,"ShowMove",true);
	    var moveDisplayType = readKeyInt(myApp,"MoveDisplayType",1);
		var moveCircleColor = readKeyInt(myApp,"MoveCircleColor",0xFFFFFF);
		var moveCircleWidth = readKeyInt(myApp,"MoveCircleWidth",2);
		
    	var offSetBigFont = 0;
    	var offSetBigFontNotif = 0;
    	var moveLevel = ActivityMonitor.getInfo().moveBarLevel;
    	
    	if (fontSize==3) { // Big
    		offSetBigFont = 18;
    		offSetBigFontNotif = 10;
    	} else if (fontSize==2) { // Medium
    		offSetBigFont = 10;
    		offSetBigFontNotif = 0;
    	} else {
    		offSetBigFont = 0;
    		offSetBigFontNotif = 0;
    	}
    	
        if (dc has :setAntiAlias ) { dc.setAntiAlias(true); }
	    dc.setColor(bgC,bgC);
        dc.clear();
   		if ( !sleepMode ||
    		 ( sleepMode && !ultraSleepMode ) ||
    		 ( sleepMode && (ultraSleepMode && battery>batteryLevelCritical))) {       
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
			if (fontSize==3) { // Big
	    		dc.drawText( (width / 2)-40, ((height/2)-75)-17-40, font_vlarge,myHours, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else if (fontSize==2) { // Medium
	    		dc.drawText( (width / 2)-30, ((height/2)-35)-17-40, font_medium,myHours, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else { // Small
	    		dc.drawText( (width / 2)-20, ((height/2)-20)-17-40, Graphics.FONT_SYSTEM_NUMBER_THAI_HOT,myHours, Graphics.TEXT_JUSTIFY_CENTER);
	    	}

			// Minutes
			dc.setColor(fgMC,Graphics.COLOR_TRANSPARENT);
			if (fontSize==3) { // Big
	    		dc.drawText( (width / 2)+60, ((height/2)-33)-17-35, font_vlarge, myMinutes, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else if (fontSize==2) { // Medium
	    		dc.drawText( (width / 2)+45, ((height/2)-15)-17-35, font_medium, myMinutes, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else { // Small
	    		dc.drawText( (width / 2)+20, ((height/2)+20)-17-35, Graphics.FONT_SYSTEM_NUMBER_THAI_HOT, myMinutes, Graphics.TEXT_JUSTIFY_CENTER);
	    	}

			dc.setColor(hlC ,Graphics.COLOR_TRANSPARENT);
			if (!sleepMode || (sleepMode && !sleepMode)) {
				// Date if not in sleep mode (or sleep mode desactivated)
				dc.drawText( (width / 2), (height /2)+60-20+offSetBigFont, Graphics.FONT_TINY, nowText.day_of_week+" "+myDay+" "+nowText.month+" "+nowText.year, Graphics.TEXT_JUSTIFY_CENTER);
	        	if (!System.getSystemStats().charging && battery <=batteryLevelCritical) {
		        	dc.setColor(hlC, hlC);
	    	    	dc.fillRectangle(0, 3*height/4+4+offSetBigFont, width, 20);
	    	    }
		        if (battery <=batteryLevel || System.getSystemStats().charging ) {
		        	dc.setColor(fgC, Graphics.COLOR_TRANSPARENT);
		        	dc.drawText(width / 2, 3*height/4+offSetBigFont, Graphics.FONT_TINY, battery.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
		        }
		
		        if (System.getSystemStats().charging ) {
					dc.drawBitmap((width / 2)-20/2, height-20, ico_charge);
		        }

				if (showMove && moveLevel>0) {
					if (moveDisplayType==1) {
						dc.setPenWidth(moveCircleWidth);
						dc.setColor(moveCircleColor, Graphics.COLOR_TRANSPARENT);
						dc.drawArc(width / 2, height / 2, (width / 2)-1-Math.floor(moveCircleWidth/2),Graphics.ARC_CLOCKWISE,90,90-72*moveLevel);
						dc.setColor(fgC, Graphics.COLOR_TRANSPARENT);
						dc.setPenWidth(2);
					} else if (moveDisplayType==2) {
				        if (moveLevel==1||moveLevel==3||moveLevel==5) {
				        	dc.drawBitmap((width / 2)-11, 3, ico_move); /*3*/
				        }
				        if (moveLevel==2||moveLevel==4) {
				        	dc.drawBitmap((width / 2)-11-5, 3, ico_move);
				        	dc.drawBitmap((width / 2)-11+5, 3, ico_move);
				        }
				        if (moveLevel==3||moveLevel==5) {
				        	dc.drawBitmap((width / 2)-11*2, 3, ico_move); /*2*/
				        	dc.drawBitmap((width / 2), 3, ico_move); /*4*/
				        }
				        if (moveLevel==4) {
				        	dc.drawBitmap((width / 2)-11-15, 3, ico_move);
				        	dc.drawBitmap((width / 2)-11+15, 3, ico_move);
				        }
				        if (moveLevel==5) {
				        	dc.drawBitmap((width / 2)-11*3, 3, ico_move); /*1*/ 
				        	dc.drawBitmap((width / 2)+11, 3, ico_move); /*5*/
				        }
				    } else { //moveDisplayType==3
				    	var offsetMove;
				    	if (fontSize==3) { // Big
	    					offsetMove=(height/6)*4;
				    	} else if (fontSize==2) { // Medium
				    		offsetMove=(height/7)*4+15;
				    	} else { // Small
				    		offsetMove = (height/7)*4;
				    	}
						if (moveLevel>=1) { dc.drawBitmap((width / 6), offsetMove, ico_move); }
				        if (moveLevel>=2) { dc.drawBitmap((width / 6)+10, offsetMove, ico_move); }
				        if (moveLevel>=3) { dc.drawBitmap((width / 6)+10*2, offsetMove, ico_move); }
				        if (moveLevel>=4) { dc.drawBitmap((width / 6)+10*3, offsetMove, ico_move); }
				        if (moveLevel>=5) { dc.drawBitmap((width / 6)+10*4, offsetMove, ico_move); }
					}
				}		        
		        
		        if (showNotification) {
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
    
    function readKeyInt(myApp,key,thisDefault) {
	    var value = myApp.getProperty(key);
	    if(value == null || !(value instanceof Number)) {
	        if(value != null) {
	            value = value.toNumber();
	        } else {
	            value = thisDefault;
	        }
	    }
	    return value;
   }
    function readKeyBoolean(myApp,key,thisDefault) {
	    var value = myApp.getProperty(key);
	    if(value == null || !(value instanceof Boolean)) {
	        if(value != null) {
	            value = true;
	        } else {
	            value = thisDefault;
	        }
	    }
	    return value;
   }
}