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
class PincheViejo extends ObjetoBase
{
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y);
		
		b = rectangularBody;
		var callback:CbType = new CbType();
		b.cbTypes.add(callback);
		b.cbTypes.add(Callbacks.plataformaCallback);
		b.space = FlxNapeSpace.space;
		//b.userData.nombre = "plataforma";
		
		this.loadGraphic(AssetPaths.pincheViejo, false, 196, 76, true, "escombro");
		
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, 
		Callbacks.bolaMagnet, callback,
		function OnBolaConEscombro(e:InteractionCallback):Void {
			
			var b:Body = e.int1.castBody;
			var bomba:BombaMagnet = cast(b.userData.object, BombaMagnet);
			
			bomba.setInfinita(false);
			bomba.destroy();
			destroy();
		});
		
		var ic2 = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, callback,
		function pincheViejoConPlayer(e:InteractionCallback):Void {
				
			var b1:Body = e.int1.castBody;
			var b2:Body = e.int2.castBody;
			
			var player:PlayerNape = cast(b1.userData.object, PlayerNape);
			player.agregarCollisionAText(cast(b2.userData.nombre, String));
			player.playerDead(cast(b2.userData.nombre, String));			
		});	
		
		FlxNapeSpace.space.listeners.add(ic);
		FlxNapeSpace.space.listeners.add(ic2);
		
		tipo = "PincheViejo";
		setNormalText(20);	

	}
	
	override public function update(dt:Float){
		super.update(dt);
		this.x = this.x + this.width * 0.5;
		this.y = this.y - 10;
	}
}