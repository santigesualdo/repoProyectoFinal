package utils;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;

/**
 * ...
 * @author s
 */
class PauseButton extends FlxSprite
{

	var sprite:FlxSprite;
	private var accion:Void->Void;	
	
	var pathOver:String = "";
	var pathOut:String = "";
	
	var over:Bool = false;
		
	public function new(x,y,_pathOut:String,_pathOver:String,_accion:Void->Void) 	{
		
		super(x,y, null);
		
		accion = _accion;
			
		var path:String = "";
		
		pathOut = _pathOut;	
		pathOver = _pathOver;	
				
		sprite = new FlxSprite(this.x, this.y, pathOut);
		
		loadGraphicFromSprite(sprite);
					
		addMouseEvents();
		
	}
	
	public function addMouseEvents():Void{
		FlxMouseEventManager.add(this, onClick, onClickUp, onMouseOver, onMouseOut);
	}

	function onClickUp(sprite:FlxSprite):Void {
		accion();
	}
	
	function onClick(sprite:FlxSprite):Void	{
		
	}
	
	function onMouseOver(sprite:FlxSprite):Void {
		var _sprite = new FlxSprite(sprite.x, sprite.y, pathOver);
		loadGraphicFromSprite(_sprite);		
	}
	
	function onMouseOut(sprite:FlxSprite) :Void	{
		var _sprite = new FlxSprite(sprite.x, sprite.y, pathOut);
		loadGraphicFromSprite(_sprite);		
	}
	
	override public function destroy():Void {
		
		FlxMouseEventManager.remove(this);
		super.destroy();
		
	}

	
}	
