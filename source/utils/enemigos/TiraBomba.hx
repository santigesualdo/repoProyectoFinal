package utils.enemigos;

import flixel.FlxG;
import flixel.group.FlxGroup;
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
	
	/* Por defecto el sentido que tira bombas es vertical */
	/* Solo se usa sentidoX si se dispara Horizontal */
	public function new(x:Float, y:Float, rectangularBody:Body, ?_sentidoBombas:Int=1, ?_sentidoX=0) 
	{
		super(x, y);
		
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
		
		
		Globales.bodyList_typeObjectos.add(b);
		
		group = new FlxGroup();
		
		puedeDisparar = true;
		
		b.userData.object = this;	
		
		
	}
	
	override public function comportamiento():Void {
		
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
				FlxG.log.add("Cantidad miembros: " + group.members.length);
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

	}
	
	function cargarBombasDisparoHorizontal() :Void
	{
		var randomY: Float = Std.random(Std.int(b.bounds.height)) + Std.int(b.bounds.y);
		//var randomX: Float = Std.random(Std.int(b.bounds.width)) + Std.int(b.bounds.x);
		var posx:Float;
		if (sentidoX == 1) {
			posx= b.bounds.x + b.bounds.width * 2;
		}else {
			posx= b.bounds.x - b.bounds.width ;	
		}
		//var posy:Float = b.bounds.y + b.bounds.height *2 ;
		bodyBomba = new Body(BodyType.DYNAMIC, new Vec2(posx,randomY));
		var circle:Circle = new Circle(15);
		bodyBomba.shapes.add(circle);
		bodyBomba.userData.nombre = "bola";
		bodyBomba.userData.sentidoX = sentidoX;
		bodyBomba.userData.fuerzaX = BombaMagnet.FUERA_BAJA;
		bodyBomba.userData.destroyOnTouch = Std.string(this.bombaDestroy);
		bodyBomba.userData.radius = cast(15, Float);
		bodyBomba.userData.sentidoFuerza = BombaMagnet.BOMBA_GOHORIZONTAL;
		group.add(new BombaMagnet( posx  , randomY, bodyBomba ));	
		puedeDisparar = false;
	}
	
	function cargarBombasDisparoVertical():Void
	{
		var randomX:Float =Std.random(Std.int(b.bounds.width)) + Std.int(b.bounds.x);
		var posy:Float = b.bounds.y + b.bounds.height *2 ;
		bodyBomba = new Body(BodyType.DYNAMIC, new Vec2(randomX,posy));
		var circle:Circle = new Circle(15);
		bodyBomba.shapes.add(circle);
		bodyBomba.userData.nombre = "bola";
		bodyBomba.userData.destroyOnTouch = Std.string(this.bombaDestroy);
		bodyBomba.userData.fuerzaY = BombaMagnet.FUERA_ALTA;
		bodyBomba.userData.radius = cast(15, Float);
		bodyBomba.userData.sentidoFuerza = BombaMagnet.BOMBA_GOVERTICAL;
		group.add(new BombaMagnet( randomX  , posy, bodyBomba));	
		puedeDisparar = false;
	}
	
	override public function draw():Void {
	
		super.draw();

		for ( bo in group.members) {
			var bomba: BombaMagnet = cast(bo, BombaMagnet);
			bomba.draw();
		}
		
	}
	
	override public function destroy():Void {
		
		group.destroy();
		super.destroy();
	}
	
}