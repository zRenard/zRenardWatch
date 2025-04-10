# zRenardWatch

Garmin Watch Face

Simple digital watch with notifications and battery %.
Settings available for colors, threshold to display battery level, notifications display, and big font for time display.
Sleep mode is supported and can be deactivated via settings.

Available on Garmin ConnectIQ : <https://apps.garmin.com/fr-FR/apps/4c058f81-a930-4527-9fc8-fa65d69d4ef4>

## Settings

### Colors

* Background
* Foreground
* Date color
* Inactivity circle
* Weather icons color

### Display

* Show Notifications (On/Off)
* Weather (On/Off)
* Use sleep mode (On/Off). In sleep mode, display only clock.
* Option to select fond for hour (small, medium, big)
* Redshift based sunrise and sunset of the location provided by the weather

### Battery level show

* Minimum value to display %
* Minimum value to show highlight/warning

### Display inactivity status

* Show inactivity (On/Off)
* Display as circle, icons on top, or icons on bottom/left
* Set inactivity circle color

#### History

* 1.9.3
  * (*fix*) Minor fix if there's more than 100 notifications <https://github.com/zRenard/zRenardWatch/issues/18>
* 1.9.2
  * (*fix*) Fix crash in cas of unavailable weather data <https://github.com/zRenard/zRenardWatch/issues/16>
* 1.9.1
  * (*fix*) In RedShift mode, critical battery % is not visible <https://github.com/zRenard/zRenardWatch/issues/15>
* 1.9.0
  * (**new**) RedShift mode based sunrise and sunset of the location provided by the weather
  * (**new**) Add colors options for weather icons
  * (*fix*) Fix a bug while connection fail to retrieve weather
* 1.7.1
  * (**new**) Free colors (you can define your own colors) <https://github.com/zRenard/zRenardWatch/issues/12>
  * (**new**) Add position of the weather icons
  * (**new**) Add zoom/size of the weather icons
  * (**new**) Add option to remove year of the date <https://github.com/zRenard/zRenardWatch/issues/13>
* 1.7.0
  * (**new**) Add weather icons
* 1.6.1
  * (**new**) Add new devices 955/Solar, 7X, 255, 745
  * (**new**) Add support to the new SDK
* 1.6.0
  * (**new**) New medium size font option. <https://github.com/zRenard/zRenardWatch/issues/6>
  * (**new**) New yellow color. <https://github.com/zRenard/zRenardWatch/issues/10>
  * (*fix*) Properties handling with new SDK. <https://github.com/zRenard/zRenardWatch/issues/9>
* 1.5.0
  * (*fix*) Rewrite properties handling to fix settings transfer issue. <https://github.com/zRenard/zRenardWatch/issues/9>
* 1.4.4
  * (*fix*) Fix issue that cause watch to crash <https://github.com/zRenard/zRenardWatch/issues/7>
  * (**new**) Add option to change inactivity circle size <https://github.com/zRenard/zRenardWatch/issues/8>
* 1.4.3
  * (**new**) Add Fenix 7 support and news models
* 1.4.2
  * (*fix*) Fix compatibility issue with antialiasing on Fenix 5
* 1.4.1
  * (**new**) Add new colors
