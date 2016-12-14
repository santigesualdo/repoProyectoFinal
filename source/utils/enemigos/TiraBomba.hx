package utils.enemigos;

import flixel.addons.effects.FlxTrail;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Shape;
import utils.objetos.ObjetoBase;

/**
 * ...
 * @author s
 */
class TiraBomba extends ObjetoBase
{

	var delayMax : Float = 0.5;
	var delayAcum : Float = 0;
	
	var puedeDisparar:Bool ;
	
	var bomba: BombaMagnet;
	var bodyBomba: Body;
	
	var group:FlxGroup;
	
	var sentidoBombas:Int = 1;
	var sentidoX:Int = 0;
	
	var bombaDestroy:Int = 1;
	
	var bombaOnTime:Int = 0;
	
	var canMove:Bool ;
	var maxMoveDistance:Int ;
	var posInicial:Int;
	
	var currentState:Int = 3;
	static inline var estado_yendo:Int = 1;
	static inline var estado_viniendo:Int= 2;
	static inline var estado_quieto:Int = 3;
	
	var explosion:FlxSprite = null;
	
	var trail:FlxTrail = null;
	
	var linkedsID: Array<String> = null;
	
	/* Por defecto el sentido que tira bombas es vertical */
	/* Solo se usa sentidoX si se dispara Horizontal */
	public function new(x:Float, y:Float, rectangularBody:Body, ?_sentidoBombas:Int=1, ?_sentidoX=0) 	{
		super(x + rectangularBody.bounds.width*0.5, y + rectangularBody.bounds.height*0.5 );
		
		sentidoBombas = _sentidoBombas;
		sentidoX = _sentidoX;
		
		b = rectangularBody;	
		tipo = "TiraBomba";
		setNormalText(25);
		
		if (b.userData.delayTimer != null) {
			delayMax = b.userData.delayTimer;
		}
		
		if (b.userData.bombaDestroy != null) {
			this.bombaDestroy = b.userData.bombaDestroy;
		}		
		
		if (b.userData.timeBombAlive != null) {
			this.bombaOnTime = b.userData.timeBombAlive;
		}
		
		if (b.userData.canMove != null) {
			b.allowMovement =  b.userData.canMove;	
			FlxG.log.add("puede moverse: " + b.allowMovement);
		}
		
		if (b.userData.linked_id != null) {
			var cadena:String =  cast(b.userData.linked_id, String);	
			linkedsID = parseLinkedID(cadena);
		}
		
		b.allowRotation = false;
		
		if (b.userData.maxDistance != null) {
			if (sentidoBombas == 1) {
				this.maxMoveDistance = cast(b.userData.maxDistance + b.position.x + b.bounds.width*0.5,Int);	
				this.posInicial = cast(b.position.x+b.bounds.width*0.5,Int);
			}else 
			if (sentidoBombas == 2){
				this.maxMoveDistance = cast(b.position.y - b.bounds.height*0.5 + b.userData.maxDistance  ,Int);
				this.posInicial = cast(b.position.y- b.bounds.height*0.5,Int);
			}
		}				
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, cb, Callbacks.bolaMagnet, 
		function(e:InteractionCallback):Void {
			var body:Body = e.int2.castBody;
			var ob:ObjetoBase = cast(body.userData.object, ObjetoBase);
			
			explosion = new FlxSprite(this.x, this.y);
			explosion.loadGraphic(AssetPaths.explosion_tiraBomba, true, 64, 64, true);
			explosion.animation.add("anim", [0, 1, 2, 3, 4, 5,6,7],30,  false);
			Globales.currentState.add(explosion);
			explosion.animation.play("anim");
					
			if (this.linkedsID != null) {
				activarObjetoBase(this.linkedsID);
				FlxG.log.add("linked_ id  " + linkedsID);
			}
			
			ob.destroy();
			this.destroy();
			FlxG.log.add("Tira bomba destruido");
		});
		
		FlxNapeSpace.space.listeners.add(ic);
		
		Globales.bodyList_typeObjectos.add(b);
		
		this.loadGraphic(AssetPaths.tiraBomba_spritesheet,  true, 128, 128, true);
		this.animation.add("anim", [0, 1, 2, 3, 4, 5, 4, 3, 2, 1], 10 ,  true);
		this.animation.play("anim");
		
		trail = new FlxTrail(this, AssetPaths.trail_tiraBomba,10,3,0.2,0.01);		

		group = new FlxGroup();
		
		puedeDisparar = true;
		
		b.userData.object = this;	
		b.space = FlxNapeSpace.space;

	}
	
	override public function activar():Void {
		super.activar();
		currentState = estado_yendo;
	}
	
	override public function comportamiento():Void {
		
		if (b.allowMovement) {		
			updateEstadoTiraBomba();
			moverTiraBomba();	
		}
		
		
		if (puedeDisparar) {
			// aca random y seteamos la posicion en BodyBomba	
			/*
			 * sentidoBombas 
			 * 1 = Vertical
			 * 2 = Horizontal
			 *  
			 * */
			if (sentidoBombas == 1) {
				cargarBombasDisparoVertical();
			}else if (sentidoBombas == 2){
				cargarBombasDisparoHorizontal(); 
			}
			

		}else {
			if (delayAcum < delayMax) {
				delayAcum += FlxG.elapsed;
			}else {
				delayAcum = 0;
				puedeDisparar = true;
			}			
		}	
		
		for ( bo in group.members) {
			var bomba: BombaMagnet = cast(bo, BombaMagnet);
			
			
			if (bomba.y > FlxG.worldBounds.height) {
				group.members.remove(bomba);
				bomba.destroy();
			}	
			
			if (bomba.exists) {
				bomba.update(FlxG.elapsed);
			}else {
				group.members.remove(bomba);
				bomba.destroy();
			}

		}
		
		if (trail != null) {
			trail.update(FlxG.elapsed);	
		}

	}
	
	function cargarBombasDisparoHorizontal() :Void	{
		var randomY: Float = Std.random(Std.int(b.bounds.height)) + Std.int(b.position.y);
		var posx:Float;
		if (sentidoX == 1) {
			posx= b.position.x + b.bounds.width;
		}else {
			posx= b.position.x - b.bounds.width;	
		}
		//var posy:Float = b.bounds.y + b.bounds.height *2 ;
		bodyBomba = new Body(BodyType.DYNAMIC, new Vec2(posx,randomY));
		var circle:Circle = new Circle(15);
		bodyBomba.shapes.add(circle);
		bodyBomba.userData.nombre = "bola";
		bodyBomba.userData.sentidoX = sentidoX;
		if (bombaOnTime!=0) {
			bodyBomba.userData.timeBombAlive = bombaOnTime;
		}
		
		var randFuerza = Std.random(3);
		if (randFuerza == 0 ) bodyBomba.userData.fuerzaX = BombaMagnet.FUERA_BAJA;
		else if (randFuerza == 1 ) bodyBomba.userData.fuerzaX = BombaMagnet.FUERA_MEDIA;
		else if(randFuerza == 2 ) bodyBomba.userData.fuerzaX = BombaMagnet.FUERA_ALTA;
		bodyBomba.userData.destroyOnTouch = Std.string(this.bombaDestroy);
		bodyBomba.userData.radius = cast(15, Float);
		bodyBomba.userData.sentidoFuerza = BombaMagnet.BOMBA_GOHORIZONTAL;
		group.add(new BombaMagnet( posx  , randomY, bodyBomba ));	
		puedeDisparar = false;
	}
	
	function cargarBombasDisparoVertical():Void	{
		
		var posx:Float = b.position.x;
		var posy:Float = b.position.y + b.bounds.height; 
		FlxG.log.add("Bomba drop: " + posx + " - " + posy);
		bodyBomba = new Body(BodyType.DYNAMIC, new Vec2(posx,posy));
		var circle:Circle = new Circle(15);
		bodyBomba.shapes.add(circle);
		bodyBomba.userData.nombre = "bola";
		if (bombaOnTime!=0) {
			bodyBomba.userData.timeBombAlive = bombaOnTime;
		}
		bodyBomba.userData.destroyOnTouch = Std.string(this.bombaDestroy);
		
		var randFuerza = Std.random(3);
		if (randFuerza == 0 ) bodyBomba.userData.fuerzaY = BombaMagnet.FUERA_BAJA;
		else if (randFuerza == 1 ) bodyBomba.userData.fuerzaY = BombaMagnet.FUERA_MEDIA;
		else if (randFuerza == 2 ) bodyBomba.userData.fuerzaY = BombaMagnet.FUERA_ALTA;
		
		bodyBomba.userData.radius = cast(15, Float);
		bodyBomba.userData.sentidoFuerza = BombaMagnet.BOMBA_GOVERTICAL;
		group.add(new BombaMagnet(posx,posy, bodyBomba));	
		puedeDisparar = false;
	}
	
	function moverTiraBomba():Void 	{
		switch (currentState) {
		
			case estado_yendo:
				if (sentidoBombas == 1) {
					b.position.x += FlxG.elapsed  * 100;
				}else
				if (sentidoBombas == 2) {
					b.position.y += FlxG.elapsed * 100;
				}				
			case estado_viniendo:
				if (sentidoBombas == 1) {
					b.position.x -= FlxG.elapsed  * 100;
				}else
				if (sentidoBombas == 2) {
					b.position.y -= FlxG.elapsed  * 100;
				}				
			case estado_quieto: return;
				
			
		}

	}
	
	function updateEstadoTiraBomba():Void 	{
		if (sentidoBombas == 1) {
			switch (currentState) {
				case estado_yendo:
					if (b.position.x > maxMoveDistance) {
						currentState = estado_viniendo;
					}
				case estado_viniendo:
					if (b.position.x < posInicial) {
						currentState = estado_yendo;
					}
			}		
		}else 
		if (sentidoBombas == 2) {
			switch (currentState) {
				case estado_yendo:
					if (b.position.y > maxMoveDistance) {
						currentState = estado_viniendo;
					}
				case estado_viniendo:
					if (b.position.y < posInicial) {
						currentState = estado_yendo;
					}
			}					
		}
	}
	
	override public function draw():Void {
	
		super.draw();

		/*if (trail != null) {
			trail.draw();		
		}*/
		
		for ( bo in group.members) {
			var bomba: BombaMagnet = cast(bo, BombaMagnet);
			bomba.draw();
		}
		
	}
	
	override public function destroy():Void {
		trail.destroy();
		group.destroy();
		super.destroy();
	}
	
}