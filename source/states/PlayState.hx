package states;

import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.nape.FlxNapeSpace;
import flixel.input.mouse.FlxMouseEventManager;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import haxe.xml.Check;
import lime.Assets;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Mat23;
import nape.shape.Circle;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.addons.editors.tiled.TiledMap;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.nape.FlxNapeSprite;
import nape.space.Space;
import nape.util.ShapeDebug;
import openfl.display.DisplayObject;
import openfl.display.FPS;
import openfl.display.Tilesheet;
import utils.Callbacks;
import utils.enemigos.BombaMagnet;
import utils.enemigos.TiraBomba;
import utils.enemigos.RuedaSerrada;
import utils.objetos.CheckPoint;
import utils.objetos.CheckPointSensor;
import utils.objetos.PincheViejo;
import utils.objetos.FinLevel;
import utils.objetos.ObjetoBase;
import utils.objetos.Palanca;
import utils.objetos.Pinches;
import utils.objetos.PlataformaConMovientoVertical;
import utils.objetos.PlataformaConMovimientoHorizontal;
import utils.objetos.Plataforma;
import utils.objetos.TextoTutorial;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.shape.Circle;
import nape.geom.Vec2;
import nape.phys.Material;
import nape.shape.ShapeList;
import openfl.display.BitmapData;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;
import flixel.system.debug.log.LogStyle;
import nape.phys.BodyList;
import utils.*;
import haxe.io.Path;


class PlayState extends FlxState
{
	  
	 var char: FlxNapeSprite;
	 var terreno: FlxNapeSprite;
	 var polygonBody :Body;
	 var offsetNapeBody:Int = 80;
	 var playerNape:PlayerNape;
	
	 var tocaPiso:Bool = false;
	
	 var clearTraceMax:Float = 10.0;
	 var clearTraceAcum:Float = 0.0;
	 
	 var actualBodyType:BodyType;	
	 
	 var dibujarMagnet:Bool;

	 var level:TiledMap;
	 
	 /* Sensores para checkpoint y posiciones */
	 /*var checkPointGroup:FlxGroup = new FlxGroup();
	 var checkPointSensorGroup:FlxGroup = new FlxGroup();*/
	 
	 var currentCheckPoint:CheckPoint = null;
	 
	 var playSubState:PlaySubState;
	 
	 var eliminarEventosMouse:Bool;
	 
	 /*
	  * En el repositorio, en la carpeta principal de 'source' dejo un zip, con el archivo 'FlxTilemap.hx'. Lo tuve que modificar para que funcionen los tiles.
	  * */
	 
	/* assets */
	
	var levelObj: Level;
	var _hud:HUD = null;	 
		 
	public var paused = false;
	
	override public function create():Void	{
		
		super.create();		
		
		Globales.currentState = this;

		
		// Declaracion body list, de bodyes magnet y bodyes objetos
		var bodyList_Magnet:BodyList = new BodyList();
		Globales.bodyList_typeMagnet = bodyList_Magnet;
		var bodyList_Objetos:BodyList = new BodyList();
		Globales.bodyList_typeObjectos = bodyList_Objetos;
		var bodyList_Magnetizados:BodyList = new BodyList();
		Globales.bodyList_toMagnetize = bodyList_Magnetizados;
		
		FlxNapeSpace.init();
		FlxNapeSpace.drawDebug = true;
		FlxNapeSpace.space.gravity.setxy(Globales.gravityX, Globales.gravityY);
		FlxNapeSpace.shapeDebug.thickness = 2.5;
		FlxNapeSpace.shapeDebug.drawConstraints = true;
		FlxNapeSpace.drawDebug = Globales.verNape;
		
		levelObj = loadLevel(Globales.currentLevel);
			
		playerNape = new PlayerNape(Globales.currentCheckPoint.x, Globales.currentCheckPoint.y, FlxNapeSpace.space);
		Globales.globalPlayer = playerNape;
		add(playerNape);		
		
		FlxG.camera.follow(playerNape);
		FlxG.camera.flash(FlxColor.BLACK, 2, null, true);
		
		FlxG.addChildBelowMouse(new FPS(FlxG.width - 60, 0, FlxColor.WHITE));
	
		_hud = new HUD();
		_hud.updateHUD(Globales.estrellasAgarradasID.length);
		add(_hud);
		
		eliminarEventosMouse = true;
		
	}
	
	function loadLevel(currentLevel:String):Level 
	{
		var level:Level = new Level(0, 0, currentLevel,this);
		return level;
	}
	
	public function updateHud(starsColected:Int):Void {
		_hud.updateHUD(starsColected);		
	}	
	
	override public function update(elapsed:Float):Void	{
		
		super.update(elapsed);	

		controlarEventos();		
		
		//LimpiarLog();
				
		if (FlxG.keys.justPressed.P) {
			paused = !paused;		
		}
		
		if (eliminarEventosMouse) {
			checkMouseEventManager();
		}

	}	
	
	function checkMouseEventManager():Void
	{
		FlxMouseEventManager.removeAll();
		eliminarEventosMouse = false;
	}
	
	public function checkPointSensorTouched(id:Int):Void {
		for (ch in Globales.checkPointGroup.members) {
			var c:CheckPoint = cast(ch, CheckPoint);
			var _id:Int = Std.parseInt(c.getId());
			
			if (id == _id) {
				Globales.currentCheckPoint = c;	
			}
		}	
	}

	
	public function getSubPlayState(color:FlxColor):PlaySubState {
		return new PlaySubState(color);
	}
	
	function controlarEventos() {
		
		if (FlxG.keys.justPressed.R) {
			// Resetea el state
			reiniciar(); 
		}
		
		if (FlxG.keys.justPressed.N) {
			Globales.verNape = !Globales.verNape;
			FlxNapeSpace.drawDebug = Globales.verNape;
		}
		
		if (FlxG.keys.justPressed.L) {
			LimpiarLog();
		}	
		
	}
	
	public function reiniciar() {
		limpiarCosas();
		FlxG.resetState();
		
	}
	
	function limpiarCosas():Void{
		
		FlxG.log.add("Limpiando PlayState");
		
		
		playerNape.destroy();
		
		Globales.currentState = null;
		Globales.globalPlayer = null;

		levelObj.destroy();
		
		this.clear();
		
		//this.remove(Globales.estrellasGroup);
		/*checkPointGroup.clear();
		checkPointSensorGroup.clear();	 */
		currentCheckPoint = null;
		
		
		if (Globales.bodyList_typeMagnet != null)
			Globales.bodyList_typeMagnet.clear();
			
		
		if (Globales.bodyList_typeObjectos != null)
			Globales.bodyList_typeObjectos.clear();			

		if (Globales.bodyList_toMagnetize!= null)
			Globales.bodyList_toMagnetize.clear();		
			
			
		
	}
	
	function LimpiarLog():Void {
		if (clearTraceAcum < clearTraceMax) {
			clearTraceAcum += FlxG.elapsed;
		}else {
			//// FlxG.log.add("limpiar");
			clearTraceAcum = 0;
			FlxG.log.clear();
		}
	}
			
	public function EndLevel():Void	{
		//restartCheckPoints();
		Globales.checkPointGroup.clear();
		Globales.checkPointCargados = false;
		Globales.estrellasCargadas = false;
		FlxG.switchState(new MenuState());
	}	

}