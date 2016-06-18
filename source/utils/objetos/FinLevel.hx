package utils.objetos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxPoint;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import states.PlayState;

/**
 * ...
 * @author s
 */
class FinLevel extends ObjetoBase
{

	
	public function new(flxPoint:FlxPoint) 
	{
		super(flxPoint.x, flxPoint.y);
		
		var b = new Body(BodyType.STATIC, new Vec2(flxPoint.x, flxPoint.y));
		var rectangularShape:Polygon = new Polygon(Polygon.rect(0, 0, 10, 10));
		rectangularShape.sensorEnabled = true;
		b.shapes.add(rectangularShape);
		
		b.space = FlxNapeSpace.space;
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		
		var ic:InteractionListener = new InteractionListener(
			CbEvent.BEGIN,
			InteractionType.SENSOR, 
			Callbacks.bodyInferiorCallback,
			cb,
			function OnFinLevel(e:InteractionCallback) {
				var ps:PlayState = cast(Globales.currentState, PlayState);
				
				ps.EndLevel();
			}		
		);
		
		FlxNapeSpace.space.listeners.add(ic);		
	}
	
}