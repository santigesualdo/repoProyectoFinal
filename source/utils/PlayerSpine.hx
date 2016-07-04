package utils;
import flash.geom.Point;
import flash.sampler.NewObjectSample;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import lime.Assets;
import nape.geom.Vec2;
import nape.phys.Body;
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
class PlayerSpine extends FlxSprite
{
	
	var renderer:SkeletonAnimation;
	var atlas:Atlas;
	var skeleton:Skeleton;
	var root_:Bone;
	var state:AnimationState;
	var lastTime:Float = 0.0;

	var posicionPlayer:Vec2;
	
	var rWidth:Float=0;
	var rHeight:Float=0;
	
	var mode:Int = 1;
	var primeraVuelta:Bool;
	var spineScale: Float;
	
	var body:Body;

	public function new(b:Body, pathAssets:String, projectName:String, _scale:Float, currentState:String) 
	{
		body = b;
		
		super(body.bounds.x, body.bounds.y, null);
		
		visible = false;
		
		spineScale  = _scale;
		
		atlas = new Atlas(Assets.getText(pathAssets + projectName+".atlas"), new BitmapDataTextureLoader(pathAssets));
		var json = new SkeletonJson(new AtlasAttachmentLoader(atlas));
		json.scale =spineScale;
		var skeletonData:SkeletonData = json.readSkeletonData(Assets.getText(pathAssets + projectName+".json"), projectName);

		// Define mixing between animations.
		var stateData = new AnimationStateData(skeletonData);
		stateData.setMixByName("walk", "jump", 0.2);
		stateData.setMixByName("jump", "walk", 0.4);
		stateData.setMixByName("jump", "jump", 0.2);

		state = new AnimationState(stateData);
		
		setAnimation("estadoSALTANDO", true);

		renderer = new SkeletonAnimation(skeletonData);
		renderer.visible = true;
		skeleton = renderer.skeleton;
		renderer.x = x;
		renderer.y = y;
		
		posicionPlayer = new Vec2(0, 0);

		skeleton.updateWorldTransform();

		lastTime = FlxG.elapsed;

		FlxG.stage.addChild(renderer);
		primeraVuelta = false;
		
	}
	
	public function setFlipX(flag:Bool):Void {
		skeleton.flipX = flag;
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
	
	public function getSpritePos(): Vec2 {
		return posicionPlayer;
	}
	
	public function setRendererVisible(b:Bool) {
			
		this.visible = b;
		renderer.visible = b;
		
		/*if (b) {
			FlxG.stage.addChild(renderer);			
		}else {
			FlxG.stage.removeChild(renderer);
			renderer.graphics.clear();	
		}*/
		
	}
	
	public function updateSpritePos() :Void
	{
		var bodyWeigth:Float = body.bounds.width;
		var bodyHeight:Float = body.bounds.height;
	
		var bodyX :Float = body.bounds.x;
		var bodyY :Float = body.bounds.y;
		
		var newX: Float = 0;
		var newY: Float = 0;
		
		var sw: Int = FlxG.stage.stageWidth;
		var sh: Int = FlxG.stage.stageHeight;
		
		if (FlxG.camera.scroll.x == 0) {
			newX = bodyX+ bodyWeigth * 0.5 ;
		}else {
			newX = sw * 0.5 - bodyWeigth * 0.5;			
		}
		
		if (FlxG.camera.scroll.y == 0) {
			newY = bodyY+ bodyHeight;
		}else {
			newY = sh * 0.5 - bodyHeight * 0.25;	
		}
		

		
		/*if (FlxG.camera.scroll.x != 0 && FlxG.camera.scroll.y != 0) {
			newX = sw * 0.5 - bodyWeigth * 0.5;
			newY = sh * 0.5 - bodyHeight * 0.25;
			
		}*/
		
		if (FlxG.camera.scroll.y == FlxG.worldBounds.height - sh ){
			// borde de abajo
			newY = bodyY - FlxG.camera.scroll.y + bodyHeight;
		}
		if (FlxG.camera.scroll.x == FlxG.worldBounds.width - sw ) {
			newX = bodyX - FlxG.camera.scroll.x + bodyWeigth*0.5;	
		}
		
		posicionPlayer.setxy(newX, newY);
	}
	
	override public function update(elapsed:Float):Void {
	
		super.update(elapsed);
		
		updateSpritePos();
		
		var delta = haxe.Timer.stamp() - lastTime;
		lastTime = haxe.Timer.stamp();
		state.update(delta);
		state.apply(skeleton);
		var anim = state.getCurrent(0);
		/*if (anim.toString() == "walk") {
			// After one second, change the current animation. Mixing is done by AnimationState for you.
			if (anim.time > 2) state.setAnimationByName(0, "jump", false);
		} else {
			if (anim.time > 1) state.setAnimationByName(0, "walk", true);
		}*/

		skeleton.updateWorldTransform();
		renderer.visible = true;	
		
		/*
		// FlxG.log.add("\nX: " + renderer.x + "\n - Y: " + renderer.y + "\n - ancho : " + renderer.width + "\n alto: " + renderer.height + "\n alto fijo : " + altoFijo) ;
		*/
	
		
		
		/*if ((renderer.height != 0) && (renderer.width!=0)) {
			if (!primeraVuelta) {
				primeraVuelta = true;
				rWidth = renderer.width;
				rHeight = renderer.height;
			}	
		}			*/
		
		renderer.x = posicionPlayer.x;
		renderer.y = posicionPlayer.y ;
	}
	
	override public function draw():Void {

		super.draw();
	}
	
	override public function destroy():Void {
	
		FlxG.stage.removeChild(renderer);
		renderer.graphics.clear();
		super.destroy();
		
	}

}