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
import utils.PlayerSpine;

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

	var playerSpine:PlayerSpine;
	
	
	override public function create() {
		super.create();

		//add(new AnimationSpine(100, 400, "assets/player/", "spineboy",0.25));
		//add(new AnimationSpine(350, 400, "assets/player2/", "spineboy2", 0.6));
		
		crearBody(350, 450);
		playerSpine = new PlayerSpine(body, "assets/playerMagnet/", "playerMagnet", 1, "estadoSALTANDO");
		add(playerSpine);

	}
	
	function crearBody(x:Float, y:Float):Void {
		body = new Body(BodyType.DYNAMIC, new Vec2(x,y));
		body.userData.nombre = "playerBodyInferior";
		body.allowRotation = false;
		
		var circleRadio:Float = 20;
		
		//sInferior= new Polygon(Polygon.rect(0, 0, 40, 80), Material.wood() , null);
		var sInferior:Circle= new Circle(circleRadio * 0.5, null , Material.wood());
		sInferior.userData.nombre = "playerShapeBodyInferior";
		sInferior.material = new Material(0, 0.57, 0.74, 7.5, 0.001);//Material.steel();
		body.shapes.add(sInferior);
		
		body.cbTypes.add(Callbacks.bodyInferiorCallback);
		//Globales.globalPlayerBodyIntermedioPos = bodyInferior.position;
		body.space = FlxNapeSpace.space;	
		
		
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		
		if (FlxG.keys.justReleased.NUMPADONE) {
			playerSpine.setAnimation("estadoSALTANDO",true);
		}else if (FlxG.keys.justReleased.NUMPADTWO) {
			playerSpine.setAnimation("estadoCORRIENDO",true);
		}else if (FlxG.keys.justReleased.NUMPADTHREE) {
			playerSpine.setAnimation("estadoQUIETO",true);
		}else if (FlxG.keys.justReleased.NUMPADFOUR) {
			playerSpine.setAnimation("estadoMOVIENDOENELAIRE",true);
		}

	}
	
	
	
	
}