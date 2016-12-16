package utils.objetos;

import flixel.FlxSprite;
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
		
		this.loadGraphic("assets/levels/switchType1Off.png", false, 32, 10, true);
		borderSprite = new FlxSprite(this.x, this.y, "assets/levels/switchType1On.png");
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
	
		var icB:InteractionListener = new InteractionListener( CbEvent.BEGIN, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			
			activarObjetos();
			borderSprite.loadGraphic(AssetPaths.switchType1On);
		});		
		
		var icE:InteractionListener = new InteractionListener( CbEvent.END, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			
			desactivarObjetos();	
			borderSprite.loadGraphic(AssetPaths.switchType1Off);
		});		
		
		
		FlxNapeSpace.space.listeners.add(icB);
		FlxNapeSpace.space.listeners.add(icE);
		
	}
	
}