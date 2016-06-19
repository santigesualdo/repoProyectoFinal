package utils.enemigos;

import nape.phys.Body;
import nape.phys.Material;

/**
 * ...
 * @author yo
 */
class RuedaSerradaConMovimientoHorizontal extends RuedaSerrada
{
	var posInicialX:Float;
	var posFinalX:Float;
	var sentidoInicial:Int;

	public function new(bodyCircular:Body, posFinalX:Float, sentidoInicial:Int) 
	{
		super(bodyCircular);
		
		this.posInicialX = b.position.x + b.bounds.width / 2;
		this.posFinalX = posFinalX;
		
		b.position.x = posInicialX;
		b.position.y = b.position.y + b.bounds.height / 2;
		b.setShapeMaterials(Material.steel());
		
		this.sentidoInicial = sentidoInicial;
			
		//Si es una rueda con movimiento
		if (posFinalX != -1){
			if(sentidoInicial == 0){b.velocity.x = velocidad; }//Izq a Der
			else if(sentidoInicial == 1){b.velocity.x = -velocidad;}//Der a Izq
		}
		
		this.activar();
	}
	
	override public function comportamiento():Void {
		
		if (!rotacionSentidoReloj) {
			b.rotate(centerOfRotation, -rotateVelocityRadians);
		}
		
		if (posFinalX != -1){
			
			if(sentidoInicial == 0){
				if(b.position.x >= posFinalX){ 
					this.b.velocity.x  = -velocidad;
				}else if(b.position.x <= posInicialX){
					this.b.velocity.x  = velocidad;
				} 
			}
			else{
				if(b.position.x <= posFinalX){ 
					this.b.velocity.x  = velocidad;
				}else if(b.position.x >= posInicialX){
					this.b.velocity.x  = -velocidad;
				} 
			}
		}
	}
}