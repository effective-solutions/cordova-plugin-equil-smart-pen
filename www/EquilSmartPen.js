var exec = require('cordova/exec');

function EquilSmartPen() {}

EquilSmartPen.prototype.onEvent = function( callback, success, error ){
    EquilSmartPen.prototype.onEventReceived = callback;
    exec(success, error, "EquilSmartPen", "start", []);
};

EquilSmartPen.prototype.onEventReceived = function(payload){
    console.log("Pen event received");
};

EquilSmartPen.prototype.onData = function( callback, success, error ){
    EquilSmartPen.prototype.onDataReceived = callback;
    exec(success, error, "EquilSmartPen", "start", []);
};

EquilSmartPen.prototype.onDataReceived = function(payload){
    console.log("Pen data received");
};

var equilSmartPen = new EquilSmartPen();
module.exports = equilSmartPen;

EquilSmartPen.install = function () {
    if (!window.plugins) {
        window.plugins = {};
    }
    window.plugins.EquilSmartPen = new EquilSmartPen();
    return window.plugins.EquilSmartPen;
};
cordova.addConstructor(EquilSmartPen.install);
