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

	/* Por sensor, cuando toca se prende, se va y se apaga*/
	public static inline var TYPE_BYTOUCH : Int = 1;
	public static inline var TYPE_BYTIME : Int = 2;
	public static inline var TYPE_BYINTERRPUTOR : Int = 3;
	
	// tipos de switch
	// 1 byTouch .. cuando 
	
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
		
		b.shapes.at(0).sensorEnabled = true;
		b.space = FlxNapeSpace.space;
		
		desactivar();

		
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
	
	public function activarObjetos():Void{
		for (str in linkedID) {
			var linked_id:Int = Std.parseInt(str);	
			var bo:Body = ObjetoBase.buscarBody(linked_id);
			if (bo != null) {
				var ob:ObjetoBase = cast(bo.userData.object, ObjetoBase);
				ob.activar();	
			}
		}	
	}
	
	public function desactivarObjetos():Void{
		for (str in linkedID) {
			var linked_id:Int = Std.parseInt(str);	
			var bo:Body = ObjetoBase.buscarBody(linked_id);
			if (bo != null) {
				var ob:ObjetoBase = cast(bo.userData.object, ObjetoBase);
				ob.desactivar();		
			}
		}			
	}
}
