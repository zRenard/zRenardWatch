using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Lang;
using Toybox.Application;
using Toybox.ActivityMonitor;
using Toybox.Weather;

var weatherIcons = {};

class zRenardWatchView extends WatchUi.WatchFace {
    hidden var ico_msg = WatchUi.loadResource(Rez.Drawables.id_msg);
    hidden var ico_charge = WatchUi.loadResource(Rez.Drawables.id_charge);
	hidden var ico_move = WatchUi.loadResource(Rez.Drawables.id_move);
	hidden var sleepMode = false;
	hidden var font_vlarge = WatchUi.loadResource(Rez.Fonts.id_font_vlarge);
	hidden var font_medium = WatchUi.loadResource(Rez.Fonts.id_font_medium);
	hidden var delayedUpdate = 0; // First time we run, we get weather
	hidden var weatherCondition = -1;       

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
    	var battery = (System.getSystemStats().battery + 0.5).toNumber();
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	var bgC = Application.Properties.getValue("BackgroundColor");
    	if (bgC == -1) {  bgC = Application.Properties.getValue("FreeBackgroundColor").toLongWithBase(16); }
    	var fgC = Application.Properties.getValue("ForegroundColor");
    	if (fgC == -1) {  fgC = Application.Properties.getValue("FreeForegroundColor").toLongWithBase(16); }
	    var fgHC = Application.Properties.getValue("ForegroundColorHours");
    	if (fgHC == -1) {  fgHC = Application.Properties.getValue("FreeForegroundColorHours").toLongWithBase(16); }
	    var fgMC = Application.Properties.getValue("ForegroundColorMinutes");
    	if (fgMC == -1) {  fgMC = Application.Properties.getValue("FreeForegroundColorMinutes").toLongWithBase(16); }
    	var hlC = Application.Properties.getValue("HighLightColor");
    	if (hlC == -1) {  hlC = Application.Properties.getValue("FreeHighLightColor").toLongWithBase(16); }
	    var fontSize = Application.Properties.getValue("FontSize");
		var sleepMode = Application.Properties.getValue("UseSleepMode");
		var ultraSleepMode = Application.Properties.getValue("UltraSleepMode");
		var batteryLevel = Application.Properties.getValue("BatteryLevel");
		var batteryLevelCritical = Application.Properties.getValue("BatteryLevelCritical");
	    var showMove = Application.Properties.getValue("ShowMove");
	    var moveDisplayType = Application.Properties.getValue("MoveDisplayType");
		var moveCircleColor = Application.Properties.getValue("MoveCircleColor");
    	if (moveCircleColor == -1) {  moveCircleColor = Application.Properties.getValue("FreeMoveCircleColor").toLongWithBase(16); }
		var moveCircleWidth = Application.Properties.getValue("MoveCircleWidth");
		var redShiftFlag = Application.Properties.getValue("RedShiftFlag");

    	var offSetBigFont = 0;
    	var offSetBigFontNotif = 0;
    	var moveLevel = ActivityMonitor.getInfo().moveBarLevel;
		
		var redShift = false;
		var redShiftColor = 0xAA0000;
		var showWeather = Application.Properties.getValue("ShowWeather");
        var weatherIconColor = Application.Properties.getValue("WeatherIconColor");
        var notificationIconColor = 0xFFFFFF;
        
        // Update weather every X minutes
        var delayedUpdateMax = Application.Properties.getValue("WeatherRefreshRateMinutes")*60;
      	// Ensure that we reduce current delay
      	// On reverse, it's not necessary, we will update 1 time more quicker, not a big deal
      	if (delayedUpdate>delayedUpdateMax) { delayedUpdate=delayedUpdateMax; }
        var weatherConditionDay = Application.Properties.getValue("WeatherDay");
 		var nowText = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

		var hours = nowText.hour.toNumber();
		// var minutes = nowText.min.toNumber();
		
		if (!(Toybox has :Weather)) {
			showWeather=false;
			Application.Properties.setValue("ShowWeather",false);
		}

        if (!System.getDeviceSettings().is24Hour) {
			if (hours > 12) {
				hours = hours - 12;
			}
		}
		var myHours = Lang.format("$1$",[hours.format("%02d")]);
		var myMinutes = Lang.format("$1$",[nowText.min.format("%02d")]);
		var myDay = Lang.format("$1$",[nowText.day.format("%02d")]);
		
		var position=null;
		var sunSet=null;
		var sunRise=null;

		if (Weather.getCurrentConditions()!=null) {
			// If you use Simulator, don't forget to set the position in weather part
			position = Weather.getCurrentConditions().observationLocationPosition;
			if (position!=null) {
				sunRise = Weather.getSunrise(position,Time.now());
				sunSet =  Weather.getSunset(position,Time.now());
			}
		}

		// Sunset and Sunrise change after midnight, before it's the previous sunrise, after it's the next sunrise.
		// It's data for the day.
		// if before midnight
		//   if sunset <= now -> night shift
		// else after midnight
		//   if now <= sunrise -> night shift


		if (redShiftFlag) {
			// if (midnight.value()<=Time.now().value()) {
			if (sunSet!=null && sunSet.value()<=Time.now().value()) {
					redShift=true;
				// }
			} else {
				if (sunRise!=null && Time.now().value()<=sunRise.value()) {
					redShift=true;
				}
			}
		} else {
			redShift=false;
		}
		
 		if (redShift ) { // Red shift mode
 			bgC = 0x000000;
 			fgC = redShiftColor;
 			fgHC = redShiftColor;
 			fgMC = redShiftColor;
 			hlC = redShiftColor;
 			moveCircleColor = redShiftColor;
 		}
 		
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
    	
    	if (showWeather) { // compute weather only if needed
        	if (delayedUpdate==0 || weatherCondition==-1) {
		        var weather = Weather.getDailyForecast();
		        if (weather!= null) {	
		        	if (weatherConditionDay==3) { // Smart way to get weather
		        	 if (nowText.hour.toNumber()<12) { // Before noon
		        	 	weatherCondition=weather[1].condition; // Today weather
		        	 } else {
		        	 	weatherCondition=weather[2].condition; // Tomorrow weather
		        	 }
		        	} else { // Otherwise we rely on settings (Today or Tomorrow)
		        		weatherCondition=weather[weatherConditionDay].condition;
		        	}
		        }
		        delayedUpdate=delayedUpdateMax;
	        } else { // Used to reduce the update rate of the weather
	         	delayedUpdate=delayedUpdate-1;
		    }
		}
		
        if (dc has :setAntiAlias ) { dc.setAntiAlias(true); }
	    dc.setColor(bgC,bgC);
        dc.clear();
   		if ( !sleepMode ||
    		 ( sleepMode && !ultraSleepMode ) ||
    		 ( sleepMode && (ultraSleepMode && battery>batteryLevelCritical))) {       
			dc.setColor(fgC,Graphics.COLOR_TRANSPARENT);
					
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
				// Date if not in sleep mode (or sleep mode deactivated)
				if (Application.Properties.getValue("ShowYear")) {
					dc.drawText( (width / 2), (height /2)+60-20+offSetBigFont, Graphics.FONT_TINY, nowText.day_of_week+" "+myDay+" "+nowText.month+" "+nowText.year, Graphics.TEXT_JUSTIFY_CENTER);
				} else { 
					dc.drawText( (width / 2), (height /2)+60-20+offSetBigFont, Graphics.FONT_TINY, nowText.day_of_week+" "+myDay+" "+nowText.month, Graphics.TEXT_JUSTIFY_CENTER);
				}
	        	if (!System.getSystemStats().charging && battery <=batteryLevelCritical) {
		        	dc.setColor(hlC, hlC);
	    	    	dc.fillRectangle(0, 3*height/4+4+offSetBigFont, width, 20);
	    	    }
		        if (battery <=batteryLevel || System.getSystemStats().charging ) {
					if (redShift) {
		        		dc.setColor(bgC, Graphics.COLOR_TRANSPARENT);
					} else {
						dc.setColor(fgC, Graphics.COLOR_TRANSPARENT);
					}
		        	dc.drawText(width / 2, 3*height/4+offSetBigFont, Graphics.FONT_TINY, battery.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
		        }
		
		        if (System.getSystemStats().charging ) {
					if (redShift) { // Red shift mode
						dc.drawBitmap2((width / 2)-20/2, height-23, ico_charge, {:tintColor => redShiftColor });
					} else {
						// TODO: Change to chargingIconColor (white by default)
						dc.drawBitmap2((width / 2)-20/2, height-23, ico_charge, {:tintColor => weatherIconColor });
					}
		        } 
				if (showWeather) {
					var defaultConditionIcon = 53; // default icon ? for unknown weather
					var conditionIcon = weatherCondition;weatherCondition>=0?weatherCondition:defaultConditionIcon; // Avoid -1 as conditionIcon
					var ico_weather = weatherIcons.get(conditionIcon);
					if (ico_weather==null) {
						ico_weather = weatherIcons.get(defaultConditionIcon);
					}
					//dc.drawBitmap((width / 2)-20/2, height-20-3, ico_weather);
					var ico_size=20*Application.Properties.getValue("WeatherIconFactor");
					var icoFactor=Application.Properties.getValue("WeatherIconFactor");
					var transform = new Graphics.AffineTransform();
					//transform.rotate(angle);
					//transform.translate(-10, -180);
					transform.scale(icoFactor.toFloat(),icoFactor.toFloat());					
					if (Application.Properties.getValue("WeatherIconLocation")==0) {							         
						if (redShift) { // Red shift mode
							dc.drawBitmap2((width / 2)-ico_size/2, height-ico_size/2-13, ico_weather, { :transform => transform, :tintColor => redShiftColor });
						} else {
							dc.drawBitmap2((width / 2)-ico_size/2, height-ico_size/2-13, ico_weather, { :transform => transform, :tintColor => weatherIconColor });
						}
					} else {
						var weatherOffset=0;
						if (fontSize==3) { weatherOffset = 20; } // Big font
						if (fontSize==2) { weatherOffset = 17; } // Medium
						if (fontSize==1) { weatherOffset = 3; } // Small
						if (redShift) { // Red shift mode
							dc.drawBitmap2((width / 2)-50-ico_size/2, (height/2)+weatherOffset-ico_size/2+20, ico_weather, { :transform => transform, :tintColor => redShiftColor });
						} else {
							dc.drawBitmap2((width / 2)-50-ico_size/2, (height/2)+weatherOffset-ico_size/2+20, ico_weather, { :transform => transform, :tintColor => weatherIconColor });
						}
					}
				}
		        

				if (showMove && moveLevel>0) {
					// TODO: Change to moveIconColor (white by default)
					var moveIconOptions =  {:tintColor => weatherIconColor };
					if (redShift) { // Red shift mode
						moveIconOptions =  {:tintColor => redShiftColor };
					}

					if (moveDisplayType==1) {
						dc.setPenWidth(moveCircleWidth);
						dc.setColor(moveCircleColor, Graphics.COLOR_TRANSPARENT);
						dc.drawArc(width / 2, height / 2, (width / 2)-1-Math.floor(moveCircleWidth/2),Graphics.ARC_CLOCKWISE,90,90-72*moveLevel);
						dc.setColor(fgC, Graphics.COLOR_TRANSPARENT);
						dc.setPenWidth(2);
					} else if (moveDisplayType==2) {
				        if (moveLevel==1||moveLevel==3||moveLevel==5) {
				        	dc.drawBitmap2((width / 2)-11, 3, ico_move,moveIconOptions); /*3*/
				        }
				        if (moveLevel==2||moveLevel==4) {
				        	dc.drawBitmap2((width / 2)-11-5, 3, ico_move,moveIconOptions);
				        	dc.drawBitmap2((width / 2)-11+5, 3, ico_move,moveIconOptions);
				        }
				        if (moveLevel==3||moveLevel==5) {
				        	dc.drawBitmap2((width / 2)-11*2, 3, ico_move,moveIconOptions); /*2*/
				        	dc.drawBitmap2((width / 2), 3, ico_move,moveIconOptions); /*4*/
				        }
				        if (moveLevel==4) {
				        	dc.drawBitmap2((width / 2)-11-15, 3, ico_move,moveIconOptions);
				        	dc.drawBitmap2((width / 2)-11+15, 3, ico_move,moveIconOptions);
				        }
				        if (moveLevel==5) {
				        	dc.drawBitmap2((width / 2)-11*3, 3, ico_move,moveIconOptions); /*1*/ 
				        	dc.drawBitmap2((width / 2)+11, 3, ico_move,moveIconOptions); /*5*/
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
						if (moveLevel>=1) { dc.drawBitmap2((width / 6), offsetMove, ico_move,moveIconOptions); }
				        if (moveLevel>=2) { dc.drawBitmap2((width / 6)+10, offsetMove, ico_move,moveIconOptions); }
				        if (moveLevel>=3) { dc.drawBitmap2((width / 6)+10*2, offsetMove, ico_move,moveIconOptions); }
				        if (moveLevel>=4) { dc.drawBitmap2((width / 6)+10*3, offsetMove, ico_move,moveIconOptions); }
				        if (moveLevel>=5) { dc.drawBitmap2((width / 6)+10*4, offsetMove, ico_move,moveIconOptions); }
					}
				}		        
		        
		        if (Application.Properties.getValue("ShowNotification")) {
					var notification = System.getDeviceSettings().notificationCount;
					if (notification > 0) {						
						if (redShift) { // Red shift mode						
							dc.drawBitmap2((width / 2)-(34/2)+50, 34-offSetBigFontNotif, ico_msg, { :tintColor => redShiftColor });
						} else {
							dc.drawBitmap2((width / 2)-(34/2)+50, 34-offSetBigFontNotif, ico_msg, { :tintColor => notificationIconColor });
						}
						dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
						dc.drawText(width / 2+50, 34-offSetBigFontNotif, Graphics.FONT_TINY, notification.toString(), Graphics.TEXT_JUSTIFY_CENTER);
//						dc.drawAngledText(width / 2+50, 34-offSetBigFontNotif, Graphics.getVectorFont( { :face => "BionicBold", :size => 20} ), notification.toString(), Graphics.TEXT_JUSTIFY_CENTER,45);
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