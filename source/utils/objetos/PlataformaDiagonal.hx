package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.Body;

/**
 * ...
 * @author s
 */
class PlataformaDiagonal extends ObjetoBase
{

	var angleInRadians: Float;
	
	public function new(x:Float, y:Float, _b:Body) :Void{
	
		super(x, y);
				
		this.b = _b;
			
		this.b.cbTypes.add( Callbacks.plataformaCallback);	
		
		if (b.userData.rotation != null) {			
			var centerOfRotation:Vec2 = b.shapes.at(0).localCOM;			
		
			angleInRadians= Std.parseFloat(b.userData.rotation) * Math.PI / 180;
			b.rotate(centerOfRotation, angleInRadians);
		}	
		
		b.position.set(new Vec2(x, y));
		
		this.b.space = FlxNapeSpace.space;	
		
		tipo = "PlataformaDiagonal";
		setNormalText(25);
	}

	
}