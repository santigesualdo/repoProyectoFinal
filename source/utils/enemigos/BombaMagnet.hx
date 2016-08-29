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
	public static inline var FUERA_BAJA:Int = 150;
	/** 500 */
	public static inline var FUERA_MEDIA:Int = 250;
	/** 750 */
	public static inline var FUERA_ALTA:Int = 300;
	
	var fuerzaX : Int;
	var fuerzaY: Int;
	
	var destruirOnTouch:Bool;
	
	/* Puede ser vertical o horizontal */
	var direccion:Int = BOMBA_GONONE;
	
	var delayTime:Float = 0;
	var acumTime:Float = 0;
	
	var destroyOnTime:Bool = false;
	
	var explosionSprite:FlxSprite = null;
	
	var readyToDestroy : Bool ;
	
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
		
		b.userData.magnet = true;
		
		if (b.userData.timeBombAlive != null ) {
			destroyOnTime = true;
			delayTime = b.userData.timeBombAlive;
		}
		
		direccion = bodyCircular.userData.sentidoFuerza;
		
		b.allowRotation = true;
		this.rotar = true;
		
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
		
		this.loadGraphic(AssetPaths.bomba_magnet, false, 20, 20,false);
		
		var sentidoY:Int=1 ;
		
		switch(direccion) {
			case BOMBA_GONONE: 
			case BOMBA_GOHORIZONTAL: b.applyImpulse(new Vec2( fuerzaX*sentidoX, 0));
			case BOMBA_GOVERTICAL: b.applyImpulse(new Vec2(0, fuerzaY/Globales.gravityY));
			default:
		}
				
		
		Globales.bodyList_typeMagnet.add(b);
		tipo = "Bomba";
		setNormalText(15);
		
		readyToDestroy = false;

	}
	
	function cargarListenerOnTouch():InteractionListener
	{
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		return ot = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_BODY, cb,
		function bolaMagnetConCualquierBody(e:InteractionCallback):Void {			
			predestroy();
		});		
	}
	
	function predestroy() :Void
	{
		b.space = null;
		readyToDestroy = true;
		explosionSprite = new FlxSprite(this.x, this.y);
		Globales.currentState.add(explosionSprite);
		explosionSprite.loadGraphic( AssetPaths.explosion_bombaMagnet, true, 30, 30, true);
		explosionSprite.animation.add("explode", [0, 1, 2, 3, 4, 5, 6, 7], 30, false);
		explosionSprite.animation.play("explode", false, false);
	}
	
	
	override public function update(elapsed:Float):Void {
		
		if (readyToDestroy) {
			if (explosionSprite.animation.finished) {
				this.destroy();
			}		
			this.b.allowMovement = false;
			return;
		}
		
		super.update(elapsed);
		
		this.angle = (b.rotation * 180 / Math.PI) % 360;		
		
		if (destroyOnTime) {
			if (acumTime < delayTime) {
				acumTime+= elapsed;
			}else {
				predestroy();		
				destroyOnTime = false;
			}
		}
		
		if (this.y > FlxG.worldBounds.height) {
			predestroy();
		}		
	}
	
	public function setInfinita(flag:Bool):Void {
		esInfinita = flag;
	}
	
	override public function draw():Void {
	
		if (!readyToDestroy) {
			super.draw();
		}
		
	}
	
	override public function destroy():Void {
		
		if (!readyToDestroy) {
			predestroy();
			return;
		}
		
		explosionSprite.destroy();
		
		if (ot != null && FlxNapeSpace.space!= null) {FlxNapeSpace.space.listeners.remove(ot);}
		if (ic != null && FlxNapeSpace.space!=null) FlxNapeSpace.space.listeners.remove(ic);
	
		FlxG.log.add("Bomba destroyed");
		
		super.destroy();
		
	}
	
}