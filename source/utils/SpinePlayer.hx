package utils;

import flixel.FlxG;
import flixel.addons.editors.spine.FlxSpine;
import openfl.Assets;
import spinehaxe.animation.AnimationState;
import spinehaxe.atlas.Atlas;
import spinehaxe.attachments.AtlasAttachmentLoader;
import spinehaxe.platform.openfl.BitmapDataTextureLoader;
import spinehaxe.SkeletonData;
import spinehaxe.SkeletonJson;
import states.PlayState;

/**
 * ...
 * @author Kris
 */
class SpinePlayer extends FlxSpine
{
	
	static var sd:SkeletonData = null;
	
	public function new(x:Float = 0, y:Float = 0, projectName:String, assetsPath:String, animationScale:Float = 0.25) 
	{
		if (sd == null) {
			sd = FlxSpine.readSkeletonData(projectName, projectName , assetsPath, animationScale);
		}		
		super(sd, x, y);
		
		stateData.setMixByName("corriendo", "jump", 0.2);
		stateData.setMixByName("jump", "corriendo", 0.4);
		stateData.setMixByName("jump", "jump", 0.2);
		
		setAnimation("estadoSALTANDO", true);
	}
	
	public function setAnimation(name:String, loop:Bool) {
	
		/* Aca utilizamos nombres de animacion de Spine y lo adaptamos con la maquina de estados */
		
		switch(name) {
			case "estadoQUIETO": 
				state.setAnimationByName(0, "quieto", loop);
			case "estadoCORRIENDO": 	
				state.setAnimationByName(0, "corriendo", loop);
			case "estadoMOVIENDOENELAIRE":
				state.setAnimationByName(0, "falling", loop);
			case "estadoSALTANDO": 
				state.setAnimationByName(0, "jump", loop);
			default: 
		}
		
		
	}
	
	public function setAnimationState(as:AnimationState) 
	{
		this.state = as;
	}
}