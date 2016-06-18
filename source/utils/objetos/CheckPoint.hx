package utils.objetos;
import flixel.FlxObject;
import flixel.math.FlxPoint;

/**
 * ...
 * @author s
 */
class CheckPoint extends FlxObject
{
	var id:String;
	
	/* Esta clase tiene ID y la posicion guardada en el FlxObject*/
	public function new(_id:String, x:Int, y:Int) 
	{
		super(x, y);
		id = _id;
	}
	
	public function getId():String {
		return this.id;
	}

	
}