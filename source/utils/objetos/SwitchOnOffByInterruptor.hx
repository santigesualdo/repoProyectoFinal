package utils.objetos;
import flixel.FlxG;
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
class SwitchOnOffByInterruptor extends SwitchOnOff
{

	var tocandoSwitch : Bool ;
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y, rectangularBody);
		
		
		this.loadGraphic("assets/levels/switchType3Off.png", false, 32, 10, true);
		borderSprite = new FlxSprite(this.x, this.y, "assets/levels/switchType3On.png");
		
		tocandoSwitch = false;
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
	
		var icB:InteractionListener = new InteractionListener( CbEvent.ONGOING, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			tocandoSwitch = true;
		});	
		
		var icE:InteractionListener = new InteractionListener( CbEvent.END, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			tocandoSwitch = false;
		});		
				
		
		FlxNapeSpace.space.listeners.add(icB);
		FlxNapeSpace.space.listeners.add(icE);
		
	}
	
	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		
		if (tocandoSwitch && FlxG.keys.justPressed.E ){
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

	}
	

}