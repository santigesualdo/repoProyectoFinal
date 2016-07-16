package states;


import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxState;
import lime.Assets;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import spinehaxe.animation.AnimationState;
import spinehaxe.animation.AnimationStateData;
import spinehaxe.atlas.Atlas;
import spinehaxe.attachments.AtlasAttachmentLoader;
import spinehaxe.Bone;
import spinehaxe.platform.openfl.BitmapDataTextureLoader;
import spinehaxe.platform.openfl.SkeletonAnimation;
import spinehaxe.Skeleton;
import spinehaxe.SkeletonData;
import spinehaxe.SkeletonJson;
import utils.AnimationSpine;
import utils.Callbacks;
import utils.Globales;

import utils.SpinePlayer;

/**
 * ...
 * @author s
 */
class PlayerDesignState extends FlxState
{

	var renderer:SkeletonAnimation;
	var atlas:Atlas;
	var skeleton:Skeleton;
	var root_:Bone;
	var state:AnimationState;
	var lastTime:Float = 0.0;

	var mode:Int = 1;
	
	var body:Body;

	var playerSpine:SpinePlayer;
	
	
	override public function create() {
		super.create();

		//add(new AnimationSpine(100, 400, "assets/player/", "spineboy",0.25));
		//add(new AnimationSpine(350, 400, "assets/player2/", "spineboy2", 0.6));
		
		playerSpine = new SpinePlayer(350,400, "playerMagnet", "assets/playerMagnet/",1);
		add(playerSpine);

	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		
		if (FlxG.keys.justReleased.ONE) {
			playerSpine.setAnimation("estadoQUIETO",true);
		}else if (FlxG.keys.justReleased.TWO) {
			playerSpine.setAnimation("estadoCORRIENDO",true);
		}else if (FlxG.keys.justReleased.THREE) {
			playerSpine.setAnimation("estadoMOVIENDOENELAIRE",true);
		}else if (FlxG.keys.justReleased.FOUR) {
			playerSpine.setAnimation("estadoSALTANDO",true);
		}else if (FlxG.keys.justReleased.FIVE) {
			playerSpine.setAnimation("estadoSUBIENDOPLATAFORMA",true);
		}		

	}

	
}