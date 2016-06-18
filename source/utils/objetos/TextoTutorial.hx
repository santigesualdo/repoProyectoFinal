package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import utils.TextTimer;

/**
 * ...
 * @author s
 */
class TextoTutorial extends ObjetoBase
{
	
	var textTimer:TextTimer;
	var text:String;
	
	var maxTime:Float;
	
	public function new(x:Int, y:Int, body:Body):Void 
	{
		super(x, y);
		
		b = body.copy();
		b.userData.object = this;
		
		text = b.userData.texto;
		
		maxTime = Std.parseFloat(b.userData.time);
		textTimer = null;
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, 
		Callbacks.bodyInferiorCallback, cb,
		function OnTextoTutorialTouched(e:InteractionCallback):Void {
			if (textTimer == null) {
				textTimer = new TextTimer(new Vec2(FlxG.camera.scroll.x+300, FlxG.camera.scroll.y+300), text, maxTime, 20, FlxColor.GREEN);			
				Globales.currentState.add(textTimer);				
			}			
		});
			
		FlxNapeSpace.space.listeners.add(ic);
		
		b.space = FlxNapeSpace.space;
		
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	
		if (textTimer != null) {
			if (textTimer.getFinished()) {
				destroy();
			}else {
				textTimer.setPosition(FlxG.camera.scroll.x+FlxG.width*0.01, FlxG.camera.scroll.y + FlxG.height-50);	
			}
		}
	}
		
	override public function destroy():Void {
		
		if (textTimer != null) {
			Globales.currentState.remove(textTimer);
		}
		super.destroy();
	}

	
}