# Figure hotkeys
Few useful hotkeys for Matlab figure: zoom, pan, rotate and data-cursor at your fingertips.


![](http://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/57496/versions/6/screenshot.png)

## Main features: 
* Allows to toggle zoom / pan / rotate / datacursor
* Adds "zoom with mousewheel" to "pan" mode
* Said functionality does not disappear when corresponding buttons are clicked on the figure toolbar
  (in contrast with a naive approach) 
* Provides an example of a workaround on how to fix 'KeyPressFcn' beeing overwritten when cursor mode changes

## Hotkeys: 
 * 'z' - toogles zoom mode ( last used of zoom-in and zoom-out - assumes 
         that mouse wheel is used to change the zoom level ) 
 * 'x' - toggles pan mode. Also adds zooming-with-mouse-wheel. 
 * 'c' - toggles rotation mode
 * 'v' - toggles datacursor mode

## Quickstart: 
Try the demo: 
```Matlab
>> figkeys.demo_imshow()
```
or apply the same to your own figure: 
```Matlab
>> imshow('peppers.png'); figkeys.setHotkeys();
```
