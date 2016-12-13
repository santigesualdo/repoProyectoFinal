package utils.objetos;
import flixel.addons.nape.FlxNapeSpace;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.phys.Body;

/**
 * ...
 * @author ...
 */
class SwitchOnOffByTime extends SwitchOnOff
{

	var timeOn: Float;
	var timeAcum : Float;
	
	var timeRunning :Bool;
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y, rectangularBody);
		
		timeRunning = false;
		
		if (rectangularBody.userData.time != null){
			timeOn = rectangularBody.userData.time;
		}
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
	
		var icB:InteractionListener = new InteractionListener( CbEvent.BEGIN, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitchOn(e:InteractionCallback) {
			
			if (!timeRunning){
				activarObjetos();
				timeRunning = true;
				borderSprite.loadGraphic("assets/levels/switch_on.png");
			}
		});		
		
		FlxNapeSpace.space.listeners.add(icB);	
		
	}
	
	override public function update(dt:Float){
		super.update(dt);
		
		if (timeRunning){
			if (timeAcum < timeOn){
				timeAcum += dt;
			}else{
				timeAcum = 0;
				timeRunning = false;
				desactivarObjetos();
				desactivar();
			}
		}
		
	}
	
	override public function desactivarObjetos() : Void
	{
		super.desactivarObjetos();

		borderSprite.loadGraphic("assets/levels/switch_off.png");
	}
	
}