package utils.objetos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.phys.Body;
import utils.Callbacks;
import utils.enemigos.BombaMagnet;

/**
 * ...
 * @author s
 */
class Escombro extends ObjetoBase
{
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y);
		
		b = rectangularBody;
		var callback:CbType = new CbType();
		b.cbTypes.add(callback);
		b.space = FlxNapeSpace.space;
	
		
		
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, 
		Callbacks.bolaMagnet, callback,
		function OnBolaConEscombro(e:InteractionCallback):Void {
			
			var b:Body = e.int1.castBody;
			var bomba:BombaMagnet = cast(b.userData.object, BombaMagnet);
			
			bomba.setInfinita(false);
			bomba.destroy();
			destroy();
		});
		
		FlxNapeSpace.space.listeners.add(ic);
		
		tipo = "Escombro";
		setNormalText(20);	

	}
		
}