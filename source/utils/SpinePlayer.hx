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
	var currentAnimName:String = "";
	
	public function new(x:Float = 0, y:Float = 0, projectName:String, assetsPath:String, animationScale:Float = 0.25) 
	{
		if (sd == null) {
			sd = FlxSpine.readSkeletonData(projectName, projectName , assetsPath, animationScale);
		}		
		super(sd, x, y);
		
		stateData.setMixByName("corriendo", "jump", 0.2);
		stateData.setMixByName("jump", "corriendo", 0.4);
		stateData.setMixByName("jump", "jump", 0.2);
		stateData.setMixByName("corriendo", "falling", 0.25);
		
		setAnimation("estadoSALTANDO", true);
		
		
	}
	
	public function getAnimName():String {
		return currentAnimName;
	}
	
	public function setAnimation(name:String, loop:Bool) {
	
		
		/* Aca utilizamos nombres de animacion de Spine y lo adaptamos con la maquina de estados */
		switch(name) {
			case "estadoQUIETO": 
				state.setAnimationByName(0, "quieto", loop);
				currentAnimName = "estadoQUIETO";		
			case "estadoCORRIENDO": 	
				state.setAnimationByName(0, "corriendo", loop);
				currentAnimName = "estadoCORRIENDO";		
			case "estadoMOVIENDOENELAIRE":
				state.setAnimationByName(0, "falling", loop);
				currentAnimName = "estadoMOVIENDOENELAIRE";
			case "estadoSALTANDO": 
				state.setAnimationByName(0, "jump", loop);
				currentAnimName = "estadoSALTANDO";
			case "estadoSUBIENDOPLATAFORMA": 
				state.setAnimationByName(0, "subiendoplataforma", loop);		
				currentAnimName = "estadoSUBIENDOPLATAFORMA";
			default: 
		}
		
		
		
	}
}