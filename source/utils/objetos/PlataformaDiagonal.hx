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
		this.b.space = FlxNapeSpace.space;	
			
		this.b.cbTypes.add( Callbacks.plataformaCallback);	
		rotar = true;
		
		this.loadGraphic(AssetPaths.platDiagonal, false, 1024, 64);	
		
		if (this.b.userData.rotation != null) {			
			var centerOfRotation:Vec2 = this.b.shapes.at(0).localCOM;			
		
			angleInRadians= Std.parseFloat(this.b.userData.rotation) * Math.PI / 180;
			this.b.rotate(centerOfRotation, angleInRadians);
		}	

		//this.setPosition(x - this.width , y + this.height*0.5);
		this.set_angle((b.rotation * 180 / Math.PI) % 360);
		
		this.b.position.set(new Vec2(x, y));		
		
		this.x = b.position.x ;
		this.y = b.position.y;		
		
    	
		// this.centerOrigin();		
		
		tipo = "PlataformaDiagonal";
		setNormalText(25);
		
		noActualizar = true;
		
		/*this.x = b.position.x - this.width *0.9 ;
		this.y = b.position.y + this.height *2.5;*/
	}

	
}