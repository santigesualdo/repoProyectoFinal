package utils.objetos;


import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.phys.Body;

/**
 * ...
 * @author s
 */
class SensorBall extends ObjetoBase
{

	public function new(x:Int, y:Int, bodyCircular:Body) 
	{
		
		super(x , y);
		
		b = bodyCircular;
		var callback:CbType = new CbType();
		b.cbTypes.add(callback);
		b.space = FlxNapeSpace.space;
		b.allowMovement = false;
		
		var ic:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, 
		Callbacks.bolaMagnet, callback,
		function OnBolaConEscombro(e:InteractionCallback):Void {
			var linked_id: Int ;
			if (b.userData.linked_id != null) {
				linked_id = b.userData.linked_id;	
				var bo:Body = ObjetoBase.buscarBody(linked_id);
				var ob:ObjetoBase = cast(bo.userData.object, ObjetoBase);
				ob.activar();					
			}
		});
		
		FlxNapeSpace.space.listeners.add(ic);
		
		tipo = "sensorBall";
		setNormalText(20);	
		
	}
	
}