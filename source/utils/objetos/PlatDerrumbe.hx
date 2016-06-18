package utils.objetos;


import flixel.FlxG;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;

/**
 * ...
 * @author s
 */
class PlatDerrumbe extends ObjetoBase
{

	var timeToFall:Float;
	var acumToFall:Float;
	
	var ic:InteractionListener;
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y);
		
		b = rectangularBody;
		
		b.shapes.at(0).localCOM.set( new Vec2(0, 0)	);
		
		
		acumToFall = 0;
		timeToFall = 0;
		
		if (b.userData.timeToFall != null) {
			timeToFall = b.userData.timeToFall;	
		}
		
		b.allowMovement = false;
		b.space = FlxNapeSpace.space;
		
		this.desactivar();
				
		var cb:CbType = new CbType();		
		
		b.cbTypes.add(cb);
		b.cbTypes.add(Callbacks.plataformaCallback);
		
		ic= new InteractionListener(
			CbEvent.BEGIN, InteractionType.COLLISION, cb, Callbacks.bodyInferiorCallback, 
			function onPlatDerrumbeWithPlayer(e:InteractionCallback) {
				this.activar();
			}
		);
		
		FlxNapeSpace.space.listeners.add(ic);
	}
	
	override public function comportamiento():Void {
	
		if (acumToFall < timeToFall) {
			acumToFall += FlxG.elapsed;
		}else {
			FlxNapeSpace.space.listeners.remove(ic);
			var body:Body = new Body(BodyType.DYNAMIC, b.position);
			var shape:Polygon = new Polygon(Polygon.rect(0, 0, b.bounds.width, b.bounds.height));
			shape.localCOM.set( new Vec2(0, 0)	);
			body.shapes.add(shape);
			FlxNapeSpace.space.bodies.remove(b);
			b = body;
			b.space = FlxNapeSpace.space;
			this.desactivar();
		}
		
	}
	
}