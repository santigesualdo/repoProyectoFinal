package utils.objetos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxColor;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import utils.Callbacks;
import utils.Globales;

/**
 * ...
 * @author s
 */
class Pinches extends ObjetoBase
{
	
	public function new(x:Int, y:Int, _b:Body) 
	{
		super(x, y);
			
		b = _b;
		
		var callback:CbType = new CbType();
		b.cbTypes.add(callback);
		b.space = FlxNapeSpace.space;
	
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, 
		Callbacks.bodyInferiorCallback, callback,
		function OnPlayerConPinche(e:InteractionCallback):Void {
			
			var b1:Body = e.int1.castBody;
						
			var player:PlayerNape = cast(b1.userData.object, PlayerNape);
			player.agregarCollisionAText("Pinches");
			player.playerDead("Pinches");						
			
		});
		
		FlxNapeSpace.space.listeners.add(ic);
		
		tipo = "Pinches";
		setNormalText(25);
		
	}
	
}