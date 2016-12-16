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
class SwitchOnOffByTime extends SwitchOnOff
{

	var timeOn: Float;
	var timeAcum : Float;
	
	var timeRunning :Bool;
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y, rectangularBody);
		
		this.loadGraphic("assets/levels/switchType2Off.png", false, 32, 10, true);
		borderSprite = new FlxSprite(this.x, this.y, "assets/levels/switchType2On.png");
		
		timeRunning = false;
		
		if (rectangularBody.userData.time != null){
			
			timeOn = rectangularBody.userData.time;
			FlxG.log.add("timeOn: " +timeOn);
		}
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
	
		var icB:InteractionListener = new InteractionListener( CbEvent.ONGOING, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitchOn(e:InteractionCallback) {
			
			if (!timeRunning){
				FlxG.log.add("Activa SwitchTime"); 
				activarObjetos();
				timeRunning = true;
				borderSprite.loadGraphic(AssetPaths.switchType2On);
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
		FlxG.log.add("Desactiva SwitchTime");
		borderSprite.loadGraphic(AssetPaths.switchType2Off);
		super.desactivarObjetos();

		
	}
	
}