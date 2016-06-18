package utils.enemigos;

import flixel.addons.nape.FlxNapeSpace;
import nape.callbacks.Listener;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import openfl.geom.Rectangle;
import utils.objetos.ObjetoBase;

import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.PreListener;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.InteractionType;
import nape.callbacks.InteractionListener;

/**
 * ...
 * @author yo
 */
class RuedaSerrada extends ObjetoBase
{
	var radius:Float;
	var intradius:Int;
	
	var maxAngleInRadians:Float;
	var centerOfRotation:Vec2;
	var rotateVelocityRadians:Float = 0.5;
	
	var velocidad:Float;
	//var destruirOnTouch:Bool;
	
	public function new(bodyCircular:Body) :Void {
		
		/*
		 * Intentar no usar posiciones en pixeles.
		 * Intentar usar distancias, para poder usar luego lo mismo.
		 * */
		
		b = bodyCircular;		
		radius = cast(b.userData.radius, Float);
		intradius = cast(radius, Int);
		
		if (b.userData.velocidad != null){
			velocidad = Std.parseFloat(b.userData.velocidad);
		}
		
		if (b.userData.rotaSentidoReloj != null)
			rotacionSentidoReloj = b.userData.rotaSentidoReloj;			
		
		if (b.userData.rotation != null) {			
			
			centerOfRotation = b.worldCOM;//centro de masa del body
	
			var angleInRadians: Float = Std.parseFloat(b.userData.rotation) * Math.PI / 180;
			maxAngleInRadians = -angleInRadians;
		}	
		
		b.cbTypes.add(Callbacks.ruedaCallback);
		
		GameListeners.RuedaConPlataforma = new PreListener( InteractionType.COLLISION, Callbacks.plataformaCallback, Callbacks.ruedaCallback,
			function handlePreContact(callback:PreCallback):PreFlag {
				return PreFlag.IGNORE;
			}
		);
		
		GameListeners.PersonajeConRueda = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.ruedaCallback,
			function ruedaConPlayer(e:InteractionCallback):Void {
				
			var b1:Body = e.int1.castBody;
			var b2:Body = e.int2.castBody;
			
			var player:PlayerNape = cast(b1.userData.object, PlayerNape);
			player.agregarCollisionAText(cast(b2.userData.nombre, String));
			player.playerDead(cast(b2.userData.nombre, String));			
		});		
		
		
		FlxNapeSpace.space.listeners.add(GameListeners.RuedaConPlataforma);
		FlxNapeSpace.space.listeners.add(GameListeners.PersonajeConRueda);
		
		b.space = FlxNapeSpace.space;
		
		super(b.position.x, b.position.y);
	}
}