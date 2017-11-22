# Equil Smart Pen Cordova Plugin  

> Extremely easy plug and play plugin for equil smart pen. SDK's for android and iosa are already available and the intension of this project was to available functionalities of the equil smart pen for cross-platform app developers.

## Usage

#### Receiving Pen Cordinates

```javascript
  window.plugins.EquilSmartPen.onData(function (data) {
    let state = data[0];
    let x = data[1];
    let y = data[2];
  })

```
##### States of the pen
State | Description
------------ | -------------
 1 | PEN_DOWN
 2 | PEN_MOVE
 3 | PEN_UP
 4 | PEN_HOVER
 5 | PEN_HOVER_DOWN
 6 | PEN_HOVER_MOVE
 
#### Recieving Pen Events

```javascript
  window.plugins.EquilSmartPen.onEvent(function (event) {
    let state = event;
  })

```

##### Events of the pen
State | Description
------------ | -------------
 11 | PNF_MSG_INVALID_PROTOCOL
 12 | PNF_MSG_FAIL_LISTENING
 15 | PNF_MSG_CONNECTED
 16 | PNF_MSG_PEN_RMD_ERROR
 17 | PNF_MSG_FIRST_DATA_RECV
 32 | PNF_MSG_SESSION_CLOSED
102 | GESTURE_CIRCLE_CLOCKWISE
103 | GESTURE_CIRCLE_COUNTERCLOCKWISE
105 | GESTURE_CLICK
106 | GESTURE_DOUBLECLICK

