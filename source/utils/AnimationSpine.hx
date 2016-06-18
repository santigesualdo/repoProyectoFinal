package utils;
import flixel.FlxG;
import flixel.FlxSprite;
import lime.Assets;
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

/**
 * ...
 * @author s
 */
class AnimationSpine extends FlxSprite
{
	
	var renderer:SkeletonAnimation;
	var atlas:Atlas;
	var skeleton:Skeleton;
	var root_:Bone;
	var state:AnimationState;
	var lastTime:Float = 0.0;

	var mode:Int = 1;

	public function new(x:Float, y:Float, pathAssets:String, projectName:String, scale:Float) 
	{
		super(x, y, null);
		
		visible = false;
		
		atlas = new Atlas(Assets.getText(pathAssets + projectName+".atlas"), new BitmapDataTextureLoader(pathAssets));
		var json = new SkeletonJson(new AtlasAttachmentLoader(atlas));
		json.scale =scale;
		var skeletonData:SkeletonData = json.readSkeletonData(Assets.getText(pathAssets + projectName+".json"), projectName);

		// Define mixing between animations.
		var stateData = new AnimationStateData(skeletonData);
		stateData.setMixByName("walk", "jump", 0.2);
		stateData.setMixByName("jump", "walk", 0.4);
		stateData.setMixByName("jump", "jump", 0.2);

		state = new AnimationState(stateData);
		state.setAnimationByName(0, "walk", true);

		renderer = new SkeletonAnimation(skeletonData);
		skeleton = renderer.skeleton;
		//skeleton.flipX = true;
		renderer.x = x;
		renderer.y = y;

		skeleton.updateWorldTransform();

		lastTime = FlxG.elapsed;

		FlxG.stage.addChild(renderer);
	}
	
	override public function update(elapsed:Float):Void {
	
		super.update(elapsed);
		
		var delta = haxe.Timer.stamp() - lastTime;
		lastTime = haxe.Timer.stamp();
		state.update(delta);
		state.apply(skeleton);
		var anim = state.getCurrent(0);
		if (anim.toString() == "walk") {
			// After one second, change the current animation. Mixing is done by AnimationState for you.
			if (anim.time > 2) state.setAnimationByName(0, "jump", false);
		} else {
			if (anim.time > 1) state.setAnimationByName(0, "walk", true);
		}

		skeleton.updateWorldTransform();

		renderer.visible = true;
		
		
	}
}