package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.phys.Body;
import states.PlayState;

/**
 * ...
 * @author s
 */
class Estrella extends ObjetoBase
{

	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x , y );
		
		b = rectangularBody;
		b.shapes.at(0).sensorEnabled = true;		
		b.space = FlxNapeSpace.space;
		b.userData.object = this;
		
		
		this.loadGraphic(AssetPaths.estrella_spritesheet,  true, 96, 96, true);
		this.animation.add("anim", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], 30, true);
		this.animation.play("anim");
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		var ic:InteractionListener= new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, cb,
		function onPlayerEstrella(e:InteractionCallback) {
			this.animation.finish();
			
			var bodyPlayer:Body = e.int1.castBody;
			var playerNape:PlayerNape = cast(bodyPlayer.userData.object, PlayerNape);
			playerNape.starCollected();
			var ps:PlayState = cast(Globales.currentState, PlayState);
			Globales.estrellasAgarradasID.push(Std.parseInt(b.userData.id));
			ps.updateHud(Globales.estrellasAgarradasID.length);
			this.destroy();
		});
		
		FlxNapeSpace.space.listeners.add(ic);
		
	}
	
}