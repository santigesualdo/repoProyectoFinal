package utils.objetos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxObject;
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
import utils.Callbacks;

/**
 * ...
 * @author s
 */
class CheckPointSensor extends FlxObject
{
	
	var b:Body;
	var id:String;
	var linkedID: Array<String>;

	public function new(checkPointID:String, x:Float, y:Float, width:Float, height:Float, _linked_id:String ) 
	{
		super(x, y);
		id = checkPointID;
		b = new Body(BodyType.STATIC, new Vec2(x, y));
		var rectangularShape:Polygon = new Polygon(Polygon.rect(0, 0, width, height));
		rectangularShape.sensorEnabled = true;
		b.shapes.add(rectangularShape);
		
		linkedID = new Array<String>();
		
		/* Si en el user data tiene Linked ID significa que activa comportamiento de otro ObjetoBase */
		if (_linked_id != "") {
			var str:String = _linked_id;
			linkedID = str.split(" ");					
		}
		
		var callback:CbType = new CbType();
		b.cbTypes.add(callback);
		
		b.space= FlxNapeSpace.space;
		
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, callback,
		function OnSensorCheckPointTouched(e:InteractionCallback):Void {
			var playerBody:Body = e.int1.castBody;
			var sensor:Body = e.int2.castBody;			
			
			/*var player:PlayerNape = cast(playerBody.userData.object, PlayerNape);
			player.playAnimation();*/
			
			var p: PlayState = cast(Globales.currentState, PlayState);
			p.checkPointSensorTouched(Std.parseInt(id));		
			
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
			
		});
		
		FlxNapeSpace.space.listeners.add(ic);
		
		set_visible(false);
		
	}
		
}