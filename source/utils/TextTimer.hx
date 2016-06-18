package utils ;
import flixel.addons.text.FlxTextField;
import nape.geom.Vec2;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * ...
 * @author Santiago Gesualdo
 */

// Clase que muestra texto en pantalla, por un tiempo determinado y se desvance
 
class TextTimer extends FlxTextField
{
	var timeAcum:Float = 0;	
	var timeMax:Float = 0;
	
	var finished:Bool;
	
	var dissapear:Bool;
	
	public function new( pos:Vec2, _text: String, timeAlive:Float, sizeText:Int, color:UInt ) {
		super(pos.x, pos.y, FlxG.width, _text, sizeText , true);
		this.set_height(150);
		this.color = color;		
		this.timeMax = timeAlive;
		this.setFormat(AssetPaths.font_kreon, sizeText, color, "left");
		this.finished = false;
		this.dissapear = false;
		
	}
	
	public function getFinished():Bool {
		return finished;
	}
	
	override public function update(elapsed:Float):Void {
		
		super.update(FlxG.elapsed);
		
		if (dissapear) {
			if (alpha == 0) {
				this.kill();
				finished = true;
				return;
			}else {
				this.alpha -= 0.01;
			}
		}else {
			
			timer();
		}

		
	}
	
	public function setTimeAlive(timeAlive:Float) {
		timeMax = timeAlive;
		alpha = 1;		
		dissapear = false;
	}
	
	function timer():Void	{
		if (timeAcum < timeMax) {
			timeAcum += FlxG.elapsed;
		}else {
			dissapear = true;
		}
	}
	
	
}