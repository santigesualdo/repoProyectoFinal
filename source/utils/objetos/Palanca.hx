package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.Body;

/**
 * ...
 * @author ...
 */
class Palanca extends ObjetoBase
{
	var linkedID: Array<String>;
	var increment:Float = 0;
	var maxAngleInRadians:Float;
	var centerOfRotation:Vec2;
	var yOffset:Float;
	var rotateVelocityRadians:Float = 0.02;
	
	public function new(x:Float, y: Float, _b:Body) :Void
	{
		super(x, y);
		
		/* Declaramos body en clase hija*/ 
		this.b = _b;
		this.b.shapes.at(0).sensorEnabled = true;
		this.b.cbTypes.add(Callbacks.objetoCallback);
		
		if (b.allowRotation)
			rota = true;		

		if (b.userData.rotaSentidoReloj!=null)
			rotacionSentidoReloj = b.userData.rotaSentidoReloj;			
		
		/* Si tiene cargado rotation en el user data, tomamos el dato desde la clase */
		/* Y */
		if (b.userData.rotation != null) {			
			
			b.position.x -= b.bounds.width;
			
			centerOfRotation = new Vec2(b.position.x + b.bounds.width * 0.5 , b.position.y + b.bounds.height * 0.9);		
			
			var angleInRadians: Float = Std.parseFloat(b.userData.rotation) * Math.PI / 180;
			maxAngleInRadians = -angleInRadians;
			b.rotate(centerOfRotation, angleInRadians);
		}	
		
		/* Si en el user data tiene Linked ID significa que activa comportamiento de otra clase */
		linkedID = new Array<String>();
		var linkIdStr:String = _b.userData.linked_id;		
		/* Si en el user data tiene Linked ID significa que activa comportamiento de otro ObjetoBase */
		if (linkIdStr != "") {
			var str:String = linkIdStr;
			linkedID = str.split(" ");					
		}
		
		
		this.b.userData.object = this;
		
		/* Lista global de objetos */
		Globales.bodyList_typeObjectos.add(this.b);
		b.space = FlxNapeSpace.space;	
		
		tipo = "Palanca";
		setNormalText(20);
	}
	
	override public function comportamiento():Void {
	/* Comportamiento de la palanca, es moverse, cuando termina ejecuta "activarEfecto" */
		
		if (!rotacionSentidoReloj) {
			if (b.rotation > maxAngleInRadians) {
				b.rotate(centerOfRotation, -rotateVelocityRadians);			
			}else {
				activarEfecto();
			}			
		}
		
	}
	
	override public function activarEfecto():Void 
	{
		for (body in Globales.bodyList_typeObjectos) {
			if (body.userData.id != null) {
				for (str in linkedID) {
					if (body.userData.id == str) {
						var o:ObjetoBase = body.userData.object;
						o.activar();
					}						
				}	
			}
		}
	}
	
}