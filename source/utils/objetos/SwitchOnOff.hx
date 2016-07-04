package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxSprite;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.phys.Body;
import utils.objetos.ObjetoBase;

/**
 * ...
 * @author s
 */
class SwitchOnOff extends ObjetoBase
{

	var linkedID: Array<String>;
	var borderSprite:FlxSprite = null;
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y);
		b = rectangularBody;
		tipo = "SwitchOnOff";
		
		if (b.userData.linked_id != null) {
			var lid:String = b.userData.linked_id;
			/* Si en el user data tiene Linked ID significa que activa comportamiento de otro ObjetoBase */
			if (lid != "") {
				var str:String = lid;
				linkedID = str.split(" ");					
			}
		}	
		
		var cb:CbType = new CbType();
		b.cbTypes.add(cb);
		
		b.shapes.at(0).sensorEnabled = true;
		
		var icB:InteractionListener = new InteractionListener( CbEvent.BEGIN, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			
			for (str in linkedID) {
				var linked_id:Int = Std.parseInt(str);	
				var bo:Body = ObjetoBase.buscarBody(linked_id);
				if (bo != null) {
					var ob:ObjetoBase = cast(bo.userData.object, ObjetoBase);
					ob.activar();	
					borderSprite.loadGraphic("assets/levels/switch_on.png");
				}
			}
		});		
		
		var icE:InteractionListener = new InteractionListener( CbEvent.END, InteractionType.SENSOR, cb, Callbacks.bodyInferiorCallback,
		function onPlayerSwitch(e:InteractionCallback) {
			
			for (str in linkedID) {
				var linked_id:Int = Std.parseInt(str);	
				var bo:Body = ObjetoBase.buscarBody(linked_id);
				if (bo != null) {
					var ob:ObjetoBase = cast(bo.userData.object, ObjetoBase);
					ob.desactivar();		
					borderSprite.loadGraphic("assets/levels/switch_off.png");
				}
			}
		});		
		
		this.b.space = FlxNapeSpace.space;
		FlxNapeSpace.space.listeners.add(icB);
		FlxNapeSpace.space.listeners.add(icE);
		
		this.loadGraphic("assets/levels/switch.png", false, 32, 10, true);
		borderSprite = new FlxSprite(this.x, this.y, "assets/levels/switch_off.png");
		
	}
	
	override public function draw():Void {
	
		super.draw();
		
		borderSprite.draw();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);	
		
		this.x = b.position.x ;
		this.y = b.position.y ;
	}
}
