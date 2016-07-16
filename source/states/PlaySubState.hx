package states;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import lime.system.System;
import nape.geom.Vec2;
import utils.AssetPaths;
import utils.CheckPointButton;
import utils.Globales;
import lime.system.System;
import utils.objetos.CheckPoint;
import utils.PauseButton;

/**
 * ...
 * @author s
 */
class PlaySubState extends FlxSubState
{

	var checkCargados:Bool = false;
	var text:String;
	var allowEsc:Bool;
	
	/* Estructura de menu PAUSA */	
	
	override public function new(BGColor:FlxColor = 0):Void{
		super(BGColor);		
		//text = _text;
		//loadThings(centerPoint);

	}
	
	public function loadThings(centerPoint:FlxPoint):Void 	{
				
		FlxG.camera.flash(FlxColor.GRAY, 2, null, true);
			
		var myText:FlxText = new FlxText(centerPoint.x, centerPoint.y, 200); 
		myText.text = "MenuPausa";
		myText.setFormat(AssetPaths.font_kreon
		, 24, FlxColor.WHITE, "center");
		//myText.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.BLACK, 2);
		myText.x = myText.x - myText.width * 0.5;
		
		add(myText);
			
		var salir:PauseButton = new PauseButton(centerPoint.x, centerPoint.y - 75,
		AssetPaths.butSalirOut, AssetPaths.butSalirOver,
		function():Void {
			var ps : PlayState = cast(Globales.currentState, PlayState);
			ps.EndLevel();
		});
		
		
		var checkPoint:PauseButton = new PauseButton(centerPoint.x, centerPoint.y - 150,
		AssetPaths.butCheckPointOut, AssetPaths.butCheckPointOver,
		function():Void {
			var ps : PlayState = cast(Globales.currentState, PlayState);
			ps.reiniciar();
		});
		
		checkPoint.x = checkPoint.x - checkPoint.width * 0.5;
		
		if (checkCargados == false) {
			var difX:Int = 100;
			var difY:Int = 0;
			for ( check in Globales.checkPointGroup.members) {
			
				var c:CheckPoint = cast(check, CheckPoint);
				var but: CheckPointButton = new CheckPointButton(centerPoint.x + difX, centerPoint.y - 150 + difY,
				Std.parseInt(c.getId()), function():Void {
					var ps : PlayState = cast(Globales.currentState, PlayState);
					ps.checkPointSensorTouched(Std.parseInt(c.getId()));
					ps.reiniciar();
				});
				
				difY += 50;
				
				add(but);
			}	
		}
		
		checkCargados = true;
		
		var restartLevel:PauseButton = new PauseButton(centerPoint.x, centerPoint.y - 225,
		AssetPaths.butRestartLevelOut, AssetPaths.butRestartLevelOver,
		function():Void {
			var ps : PlayState = cast(Globales.currentState, PlayState);
			ps.checkPointSensorTouched(0);
			ps.reiniciar();
		});
		
		restartLevel.x = restartLevel.x -restartLevel.width * 0.5;
		
		salir.x = salir.x - salir.width * 0.5;		
		
		add(restartLevel);
		add(checkPoint);
		add(salir);
	}
	
	public function setPos(point:FlxPoint) {
			
		loadThings(point);
	}
	
	override public function update(elapsed:Float):Void {
		
		super.update(elapsed);
		
		if (allowEsc) {
			if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.P ) {
				close();
			}				
		}

		
	}
	
	public function setAllowEsc(bool:Bool) 
	{
		allowEsc = bool;
	}
	
}