package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Geom;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import openfl.display.BitmapData;
import utils.NapeSpr_Body.BitmapDataIso;
import utils.objetos.ObjetoBase;

/**
 * ...
 * @author s
 */

/*@:bitmap("assets/levels/magnet1.png") class BMD_MAGNET_UP extends BitmapData { } 
@:bitmap("assets/levels/magnet2.png") class BMD_MAGNET_RIGHT extends BitmapData {} */
 
class MagnetOnOff extends ObjetoBase
{	
	
	var napeSprite:NapeSpr_Body;
	var magnet_type:Int = 0;
	var magnetSprite:FlxSprite = null;
	
	var pathOn:String; 
	var pathOff:String; 
	var pathSprite:String;
	
	
	/* La parte superior del magnet toca plataforma */
	static inline var tipo_magnet_violeta:Int = 1;
	/* La parte derecha del magnet toca plataforma */
	static inline var tipo_magnet_naranja:Int = 2;
	/* La parte inferior del magnet toca plataforma */
	static inline var tipo_magnet_azul:Int = 3;


	public function new(x:Int, y:Int, body:Body) 
	{
		super(x, y);

 		magnet_type = body.userData.type;
		
		var centerX:Float = body.bounds.x + body.bounds.width * 0.5;
		var centerY:Float = body.bounds.y + body.bounds.height * 0.5;
		var _width:Int = cast(body.bounds.width,Int);
		var _height:Int = cast(body.bounds.height,Int);
		
		switch(magnet_type) {
			case tipo_magnet_violeta:
				//pathSprite = "assets/levels/magnet1.png";
				pathOff = "assets/levels/magnet1_off.png";
				pathOn = "assets/levels/magnet1_on.png";
				loadGraphic(pathOff);
			case tipo_magnet_naranja: 
				//pathSprite = "assets/levels/magnet2.png";
				pathOff = "assets/levels/magnet2_off.png";
				pathOn = "assets/levels/magnet2_on.png";
				loadGraphic(pathOff);
			case tipo_magnet_azul: 
				//pathSprite = "assets/levels/magnet2.png";
				pathOff = "assets/levels/magnet3_off.png";
				pathOn = "assets/levels/magnet3_on.png";
				loadGraphic(pathOff);				
			default: return;
		}
		
		body.allowMovement = false;
	
		tipo = "magnetOnOff";
		//setNormalText(15);	

		var cogIso:BitmapDataIso = new BitmapDataIso( this.framePixels );
		napeSprite = new NapeSpr_Body(centerX, centerY, cogIso, pathOff, BodyType.KINEMATIC, Material.wood(), "asd", false);
		napeSprite.body.allowMovement = false;
		napeSprite.body.userData.id = body.userData.id;
		b = napeSprite.body;	
		
		this.loadGraphicFromSprite(napeSprite);
		
		b.userData.object = this;
		
		this.setPosition(centerX - this._halfSize.x , centerY - this._halfSize.y );
		magnetSprite = new FlxSprite(centerX - this._halfSize.x , centerY - this._halfSize.y , pathOff);		
		
		 //Ajuste a pata para magnet up 
		//if (magnet_type == tipo_magnet_up) {
			//this.setPosition(centerX - this._halfSize.x, centerY - this._halfSize.y );
			//borderMagnetSprite = new FlxSprite(centerX - this._halfSize.x , centerY - this._halfSize.y , pathOff);
		//}
		//
		 //Ajuste a pata para magnnet right 
		//if (magnet_type == tipo_magnet_right) {
			//this.setPosition(centerX - this._halfSize.x , centerY - this._halfSize.y );
			//borderMagnetSprite = new FlxSprite(centerX - this._halfSize.x , centerY - this._halfSize.y , pathOff);
		//}
	}
	
	override public function activar():Void {
		FlxG.log.add("Activa magnet:: " + magnet_type);
		super.activar();
		magnetSprite.loadGraphic(pathOn);

	}
	
	override public function desactivar():Void {
		FlxG.log.add("Desactiva magnet:: " + magnet_type);
		super.desactivar();
		magnetSprite.loadGraphic(pathOff);
	}
	
	override public function comportamiento():Void {
	
		for ( bo in Globales.bodyList_typeMagnet ) {
			var _bo:Body = cast(bo, Body);
			
			singleMagnet(b, _bo, FlxG.elapsed);
		}
	}
	
	/* SingleMagnet ejerce la fuerza del magnet posicionado sobre el body seleccionado */
	function singleMagnet(planet:Body, body:Body,  dt:Float) 	{	
	
		var closestA = Vec2.get();
		var closestB = Vec2.get();
		
		var gravityPoint:Body = new Body();
		gravityPoint.shapes.add(new Circle(1));

		
		gravityPoint.position.set(body.position);
		var distance = Geom.distanceBody(planet, gravityPoint, closestA, closestB);

		body.allowMovement = true;
				
/*		// Cut gravity off, well before distance threshold.
		if (distance > 150) {
			return;
		}*/
		
		/*var agarre:Float = 2000;
		
		if (distance < 75 ) {
			agarre = 2500;
		}*/
		
		// Gravitational force.
		var force:Vec2 = closestA.sub(body.position, true);

		// We don't use a true description of gravity, as it doesn't 'play' as nice.
		force.length = body.mass * 2000 ;

		////FlxG.log.add("force : " + cast(force.length,Int));
		
		
		// Impulse to be applied = force * deltaTime
		body.applyImpulse(
			/*impulse*/ force.muleq(dt),
			/*position*/ null, // implies body.position
			/*sleepable*/ false
		);

		closestA.dispose();
		closestB.dispose();	
			
	}
	
	override public function draw():Void {
		
		super.draw();
		magnetSprite.draw();
		
	}
	
}