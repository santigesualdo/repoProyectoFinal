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
class SwitchOnOffByTouch extends SwitchOnOff
{

	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y, rectangularBody);
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
	
		var icB:InteractionListener = new InteractionListener( CbEvent.BEGIN, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			
			activarObjetos();
			borderSprite.loadGraphic("assets/levels/switch_on.png");
		});		
		
		var icE:InteractionListener = new InteractionListener( CbEvent.END, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			
			desactivarObjetos();	
			borderSprite.loadGraphic("assets/levels/switch_off.png");
		});		
		
		
		FlxNapeSpace.space.listeners.add(icB);
		FlxNapeSpace.space.listeners.add(icE);
		
	}
	
}