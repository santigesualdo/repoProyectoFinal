package utils.objetos;
import flixel.FlxG;
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
class SwitchOnOffByInterruptor extends SwitchOnOff
{

	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y, rectangularBody);
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
	
		var icB:InteractionListener = new InteractionListener( CbEvent.ONGOING, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			FlxG.log.add("Toca toca");
			if (FlxG.keys.justPressed.E){
				FlxG.log.add("presiona toca");
				if (!this.activo){
					activar();
					activarObjetos();
					borderSprite.loadGraphic(AssetPaths.switchType3On);
				}else{
					desactivar();
					desactivarObjetos();
					borderSprite.loadGraphic(AssetPaths.switchType3Off);
				}
			}
		});		
		
		FlxNapeSpace.space.listeners.add(icB);
		
	}
	

}