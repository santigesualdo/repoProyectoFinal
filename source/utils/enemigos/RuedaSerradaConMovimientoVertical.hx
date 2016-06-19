package utils.enemigos;

import nape.phys.Body;
import nape.phys.Material;

/**
 * ...
 * @author yo
 */
class RuedaSerradaConMovimientoVertical extends RuedaSerrada
{
	var posInicialY:Float;
	var posFinalY:Float;
	var sentidoInicial:Int;

	public function new(bodyCircular:Body, posFinalY:Float, sentidoInicial:Int) 
	{
		super(bodyCircular);
		
		this.posInicialY = bodyCircular.position.y + bodyCircular.bounds.height / 2;
		this.posFinalY = posFinalY;
		
		b.position.x = bodyCircular.position.x + bodyCircular.bounds.width / 2;
		b.position.y = posInicialY;
		b.setShapeMaterials(Material.steel());
		
		this.sentidoInicial = sentidoInicial;
		
		//Si es una rueda con movimiento
		if (posFinalY != -1){
			if(sentidoInicial == 0){this.b.velocity.y = -velocidad;}//Abajo hacia Arriba
			else if(sentidoInicial == 1){this.b.velocity.y = velocidad;}//Arriba hacia Abajo
		}
		
		this.activar();
	}
	
	override public function comportamiento():Void {
		
		if (!rotacionSentidoReloj) {
			b.rotate(centerOfRotation, -rotateVelocityRadians);
		}
		
		if (posFinalY != -1){
			
			if(sentidoInicial == 0){
				if(b.position.y <= posFinalY){ 
					this.b.velocity.y  = velocidad;
				}else if(b.position.y >= posInicialY){
					this.b.velocity.y  = -velocidad;
				} 
			}
			else{
				if(b.position.y >= posFinalY){ 
					this.b.velocity.y  = -velocidad;
				}else if(b.position.y <= posInicialY){
					this.b.velocity.y  = velocidad;
				} 
			}
		}
	}
}