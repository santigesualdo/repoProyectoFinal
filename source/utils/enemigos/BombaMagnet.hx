package utils.enemigos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;
import haxe.ds.Vector;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import nape.phys.Material;
import states.PlayState;
import utils.Globales;
import utils.objetos.ObjetoBase;

/**
 * ...
 * @author s
 */
class BombaMagnet extends ObjetoBase
{
	var radius:Float;
	var intradius:Int;
	
	var sentidoX:Int;
	var ic:InteractionListener;
	var ot:InteractionListener;
	
	var XInicial:Float ;
	var YInicial:Float ;
	var bodyInicial:Body;
	
	var esInfinita:Bool;
	
	public static inline var BOMBA_GONONE:Int = 0 ;
	public static inline var BOMBA_GOVERTICAL:Int = 1;
	public static inline var BOMBA_GOHORIZONTAL:Int = 2;
	
	/** 250 */
	public static inline var FUERA_BAJA:Int = 250;
	/** 500 */
	public static inline var FUERA_MEDIA:Int = 500;
	/** 750 */
	public static inline var FUERA_ALTA:Int = 750;
	
	var fuerzaX : Int;
	var fuerzaY: Int;
	
	var destruirOnTouch:Bool;
	
	/* Puede ser vertical o horizontal */
	var direccion:Int = BOMBA_GONONE;
	
	/* TAREA: Cerrar tema de gravedad, asi podemos parametrizar las velocidades y hacer todo mas facil. */
	
	/**
	 * Enemigo tipo Bomba Magnet
	 * @param	x.
	 * @param	y.
	 * @param	bodyBomba.
	 * @param	tipo: BombaMagnet.BOMBA_GOVERTICAL=0 o BombaMagnet.BOMBA_GOHORIZONTAL.
	 */	 
	public function new(x:Float, y:Float, bodyCircular:Body) :Void {
		
		b = bodyCircular;		
		
		XInicial = x;
		YInicial = y;
		bodyInicial = bodyCircular.copy();
		
		b.setShapeMaterials(Material.steel());
		
		b.userData.magnet = true;
		
		direccion = bodyCircular.userData.sentidoFuerza;
		
		if (bodyCircular.userData.fuerzaX != null) {
			fuerzaX = bodyCircular.userData.fuerzaX;
		}
		
		if (bodyCircular.userData.fuerzaY != null) {
			fuerzaY = bodyCircular.userData.fuerzaY;
		}
		
		radius = cast(b.userData.radius, Float);
		intradius = cast(radius, Int);	
		
		/* Sentido en X del enemigo, ni bien arranca*/		
		if (b.userData.sentidoX != null) {
			sentidoX = b.userData.sentidoX;	
		}else {
			sentidoX = 0;
		}		
		
		b.cbTypes.add(Callbacks.bolaMagnet);
		b.cbTypes.add(Callbacks.magnetObjectCallback);
		
		/* Listener */		
		ic = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.bolaMagnet,
		function bolaMagnetConPlayer(e:InteractionCallback):Void {
				
			var b1:Body = e.int1.castBody;
			var b2:Body = e.int2.castBody;
			
			var player:PlayerNape = cast(b1.userData.object, PlayerNape);
			player.agregarCollisionAText(cast(b2.userData.nombre, String));
			player.playerDead(cast(b2.userData.nombre, String));			
		});		
				
		b.userData.object = this;
		
		/* Todo este codigo, es para setear si se destruye al toque la bombaMagnet*/		
		if (b.userData.destroyOnTouch != null ) {
			if (b.userData.destroyOnTouch == "1") {
				destruirOnTouch = true;
			}else {
				destruirOnTouch = false;
			}			
		}
		ot = null;
		
		if (destruirOnTouch) {
			ot = cargarListenerOnTouch();
			FlxNapeSpace.space.listeners.add(ot);
		}
		
		if (b.userData.infinita != null) {
			esInfinita = b.userData.infinita;
		}
		
		FlxNapeSpace.space.listeners.add(ic);
		b.space = FlxNapeSpace.space;
		
		super(b.position.x - radius * 0.5, b.position.y - radius * 0.5);	
		
		this.loadGraphic(AssetPaths.bomba_magnet, false, 20, 20);
		
		var sentidoY:Int=1 ;
		/*
		if (gravedad < 0) {
			sentidoY = -1 ;
		}
		*/
		/* Siempre actua segun la gravedad en Eje X*/
		
		/* Para que sea liviano */
		b.shapes.at(0).material = Material.sand();
		
		switch(direccion) {
			case BOMBA_GONONE: 
			case BOMBA_GOHORIZONTAL: b.applyImpulse(new Vec2( fuerzaX*sentidoX, 0));
			case BOMBA_GOVERTICAL: b.applyImpulse(new Vec2(0, fuerzaY/Globales.gravityY));
			default:
		}
				
		
		Globales.bodyList_typeMagnet.add(b);
		tipo = "Bomba";
		setNormalText(15);

	}
	
	function cargarListenerOnTouch():InteractionListener
	{
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		return ot = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_BODY, cb,
		function bolaMagnetConCualquierBody(e:InteractionCallback):Void {
			destroy();
		});		
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		updateTextPos();
	}
	
	public function setInfinita(flag:Bool):Void {
		esInfinita = flag;
	}
	
	override public function destroy():Void {
		
		if (ot != null && FlxNapeSpace.space!= null) {FlxNapeSpace.space.listeners.remove(ot);}
		if (ic != null && FlxNapeSpace.space!=null) FlxNapeSpace.space.listeners.remove(ic);

		//FlxG.camera.shake(0.01);
		
		super.destroy();
		
	}
	
	/*function preDestroy():Void {

		this.destroy();
	}*/
		
}