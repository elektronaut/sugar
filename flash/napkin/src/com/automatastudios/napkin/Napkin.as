﻿package com.automatastudios.napkin {
    import com.adobe.images.JPGEncoder;
    import com.dynamicflash.util.Base64;

    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.BitmapData;
    import flash.display.BlendMode;

    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.ContextMenuBuiltInItems;
    import flash.ui.Mouse;

    import flash.events.*;

    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;

    import flash.external.ExternalInterface;

    import flash.utils.ByteArray;


    public class Napkin extends Sprite {
	private static const IMAGE_QUALITY:uint = 80;
	private const DRAW_MODE:String = "draw_mode";
	private const ERASE_MODE:String = "erase_mode";

	private var _jpgEncoder:JPGEncoder;
	private var _menu:ContextMenu;
	private var _maxX:Number;
	private var _maxY:Number;
	private var _mode:String;
	private var _layers:Array;

	private var _canvas:Sprite;
	private var _background:Loader;
	private var _brushes:Sprite;

	private var _drawBrush:DrawBrush;
	private var _eraseBrush:EraseBrush;


	private var _lastBrush:Sprite;

	public var _help:HelpDisplay;
	public var _status:StatusAnimation;

	public function Napkin() {
	    _canvas = new Sprite();
	    //	_canvas.blendMode = BlendMode.LAYER;
	    addChild(_canvas);

	    _background = new Loader();
	    _canvas.addChild(_background);
	    _background.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadedBackground);
	    _background.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBackgroundError);

	    _brushes = new Sprite();
	    addChild(_brushes);

	    _status = new StatusAnimation();

	    _help = new HelpDisplay();
	    _help.x = 5;
	    _help.y = 5;

	    _maxX = 0;
	    _maxY = 0;

	    _drawBrush = new DrawBrush();
	    _drawBrush.width = _drawBrush.height = 3;

	    _eraseBrush = new EraseBrush();
	    _eraseBrush.blendMode = BlendMode.INVERT;

	    _layers = new Array();

	    _jpgEncoder = new JPGEncoder(IMAGE_QUALITY);
	    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	public function onStatusComplete():void {
	    _status.gotoAndStop(1);
	    removeChild(_status);
	}

	private function onAddedToStage(evt:Event):void {
	    //	stage.scaleMode = StageScaleMode.NO_SCALE;
	    stage.align = StageAlign.TOP_LEFT;
	    stage.addEventListener(MouseEvent.MOUSE_DOWN, onHideHelp);
	    stage.addEventListener(MouseEvent.MOUSE_MOVE, trackBrush);

	    ExternalInterface.addCallback("uploadDrawing", onUploadDrawing);
	    ExternalInterface.addCallback("setBackground", onSetBackground);

	    _status.stop();

	    onShowHelp();
	}

	private function onLoadedBackground(evt:Event):void {
	    _maxX = _background.width;
	    _maxY = _background.height;
	}

	private function onCommand(evt:KeyboardEvent):void {
	    var layer:Sprite = _layers[_layers.length - 1];

	    switch (evt.keyCode) {

		case 191:
		onShowHelp();
		break;
		case 65:
		if (_lastBrush == _drawBrush) {
		    _drawBrush.width = _drawBrush.height -= 1;
		    if (_drawBrush.width < 3) {
			_drawBrush.width = _drawBrush.height = 3;
		    }
		    if (layer != null) {
			layer.graphics.lineStyle(_drawBrush.width - 2, 0);
		    }
		} else {
		    _eraseBrush.width = _eraseBrush.height -= 1;
		    if (_eraseBrush.width < 3) {
			_eraseBrush.width = _eraseBrush.height = 3;
		    }
		    if (layer != null) {
			layer.graphics.lineStyle(_eraseBrush.width - 2, 0xFFFFFF);
		    }
		}
		break;
		case 68:
		if (_lastBrush == _drawBrush) {
		    _drawBrush.width = _drawBrush.height += 1;

		    if (layer != null) {
			layer.graphics.lineStyle(_drawBrush.width - 2, 0);
		    }
		} else {
		    _eraseBrush.width = _eraseBrush.height += 1;

		    if (layer != null) {
			layer.graphics.lineStyle(_eraseBrush.width - 2, 0xFFFFFF);
		    }
		}
		break;
		case 87:
		onDraw();
		break;
		case 83:
		onErase();
		break;
		case 90:
		onUndo();
		break;
		case 67:
		onClear();
		break;
		default:
		// no command
		break;
	    }
	}

	private function onClear(evt:ContextMenuEvent = null):void {
	    var i:uint;
	    var max:uint = _layers.length;

	    for (i=0; i<max; ++i) {
		_canvas.removeChild(_layers[i]);
	    }

	    _layers = new Array();

	    _maxX = 0;
	    _maxY = 0;

	    onDraw();
	}

	private function onUndo(evt:ContextMenuEvent = null):void {
	    var layer:Sprite = _layers.pop();

	    if (layer) {
		_canvas.removeChild(layer);
	    }
	}

	private function onDraw(evt:ContextMenuEvent = null):void {
	    if (_lastBrush != null) {
		while (_brushes.numChildren > 0) {
		    _brushes.removeChildAt(0);
		}
	    }

	    _lastBrush = _drawBrush;

	    _lastBrush.x = this.mouseX;
	    _lastBrush.y = this.mouseY;
	    Mouse.hide();
	    _brushes.addChild(_lastBrush);

	    _mode = DRAW_MODE;

	    _status.statusSprite.statusText.text = "draw mode...";
	    addChild(_status);
	    _status.gotoAndPlay(1);
	}

	private function onErase(evt:ContextMenuEvent = null):void {
	    if (_lastBrush != null) {
		while (_brushes.numChildren > 0) {
		    _brushes.removeChildAt(0);
		}
	    }

	    _lastBrush = _eraseBrush;

	    _lastBrush.x = this.mouseX;
	    _lastBrush.y = this.mouseY;
	    Mouse.hide();
	    _brushes.addChild(_lastBrush);

	    _mode = ERASE_MODE;

	    _status.statusSprite.statusText.text = "erase mode...";
	    addChild(_status);
	    _status.gotoAndPlay(2);
	}

	private function onShowHelp(evt:ContextMenuEvent = null):void {
	    onStopDrawing();

	    stage.addEventListener(MouseEvent.MOUSE_DOWN, onHideHelp);
	    stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrawing);
	    stage.removeEventListener(KeyboardEvent.KEY_DOWN, onCommand);

	    if (_lastBrush != null) {
		while (_brushes.numChildren > 0) {
		    _brushes.removeChildAt(0);
		}
		_lastBrush = null;
	    }

	    Mouse.show();

	    if (!contains(_help)) {
		addChild(_help);
	    }
	    _help.alpha = 0;
	    _help.visible = true;

	    stage.removeEventListener(Event.ENTER_FRAME, onFadeOutHelp);
	    stage.addEventListener(Event.ENTER_FRAME, onFadeInHelp);
	}

	private function onHideHelp(evt:MouseEvent):void {
	    stage.removeEventListener(MouseEvent.MOUSE_DOWN, onHideHelp);
	    stage.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrawing);
	    stage.addEventListener(KeyboardEvent.KEY_DOWN, onCommand);

	    stage.removeEventListener(Event.ENTER_FRAME, onFadeInHelp);
	    stage.addEventListener(Event.ENTER_FRAME, onFadeOutHelp);

	    onDraw();
	}

	private function onFadeOutHelp(evt:Event):void {
	    _help.alpha -= 0.10;

	    if (_help.alpha <= 0) {
		_help.alpha = 0;
		removeChild(_help);
		stage.removeEventListener(Event.ENTER_FRAME, onFadeOutHelp);
	    }
	}

	private function onFadeInHelp(evt:Event):void {
	    _help.alpha += 0.10;

	    if (_help.alpha >= 1) {
		stage.removeEventListener(Event.ENTER_FRAME, onFadeInHelp);
	    }
	}

	private function trackBrush(evt:MouseEvent):void {

	    if (_lastBrush) {
		_lastBrush.x = evt.stageX;
		_lastBrush.y = evt.stageY;

		evt.updateAfterEvent();
	    }
	}

	private function onStartDrawing(evt:MouseEvent):void {
	    var layer:Sprite = new Sprite();
	    _canvas.addChild(layer);
	    _layers.push(layer);

	    switch (_mode) {
		case DRAW_MODE:
		layer.graphics.lineStyle(_drawBrush.width - 2, 0);
		break;

		case ERASE_MODE:
		layer.graphics.lineStyle(_eraseBrush.width - 2, 0xFFFFFF);
		break;
	    }

	    stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrawing);
	    stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrawSegment);
	    stage.addEventListener(MouseEvent.MOUSE_UP, onStopDrawing);
	    stage.addEventListener(Event.MOUSE_LEAVE, onStopDrawing);

	    layer.graphics.moveTo(evt.stageX, evt.stageY);

	    _maxX = Math.max(_maxX, evt.stageX);
	    _maxY = Math.max(_maxY, evt.stageY);
	}

	private function onDrawSegment(evt:MouseEvent):void {
	    var layer:Sprite = _layers[_layers.length - 1];

	    layer.graphics.lineTo(mouseX, mouseY);

	    _maxX = Math.max(_maxX, (_lastBrush.width -2)/2, evt.stageX);
	    _maxY = Math.max(_maxY, (_lastBrush.width -2)/2, evt.stageY);

	    evt.updateAfterEvent();
	}

	private function onStopDrawing(evt:MouseEvent = null):void {
	    if (evt != null) {
		onDrawSegment(evt);
	    }

	    stage.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrawing);
	    stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrawSegment);
	    stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrawing);
	    stage.removeEventListener(Event.MOUSE_LEAVE, onStopDrawing);
	}

	private function onUploadDrawing():void {
	    var loader:URLLoader = new URLLoader();
	    var serviceUrl:String = loaderInfo.parameters["service"];
	    var request:URLRequest = new URLRequest(serviceUrl);
	    var variables:URLVariables = new URLVariables();
	    var jpgData:ByteArray;
	    var jpgString:String;

	    var bitmapData:BitmapData;
	    var p:String;

	    request.method = URLRequestMethod.POST;
	    request.data = new Object();

	    // add flash vars to data sent out
	    /*
	    for (p in loaderInfo.parameters) {
		if (p != "service") {
		    request.data[p] = loaderInfo.parameters[p];
		}
	    }
	    */

	    bitmapData = new BitmapData(_maxX + 15, _maxY + 15);
	    bitmapData.draw(_canvas);

	    jpgData = _jpgEncoder.encode(bitmapData);
	    jpgString = Base64.encodeByteArray(jpgData);

	    variables.drawing = jpgString;
	    request.data = variables;

	    loader.addEventListener(Event.COMPLETE, onUploadComplete);
	    loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
	    loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
	    loader.load(request);

	}

	private function onSetBackground(url:String):void {
	    _background.load(new URLRequest(url));
	}

	private function onBackgroundError(evt:IOErrorEvent):void {
	    // do nothing...
	}

	private function onUploadComplete(evt:Event):void {
	    ExternalInterface.call("onDrawingUploaded", URLLoader(evt.target).data);
	}

	private function onIOError(evt:IOErrorEvent):void {
	    ExternalInterface.call("onDrawingError", "IOError");
	}

	private function onSecurityError(evt:SecurityErrorEvent):void {
	    ExternalInterface.call("onDrawingError", "SecurityError");
	}

    }

}
