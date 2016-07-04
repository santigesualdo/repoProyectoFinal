package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Vec2;
import nape.phys.Body;

/**
 * ...
 * @author s
 */
class PlataformaConMovimientoHorizontal extends PlataformaConMovimiento
{
	
	var minX : Float;
	var maxX : Float;

	var vaYViene: Bool;
	
	var currentState = 0;
	static inline var estado_derecha:Int = 1;
	static inline var estado_izquierda:Int= 2;
	static inline var estado_detenido:Int = 3;
	
	public function new(x:Float, y:Float, _b:Body, va_viene:Bool) {
		super(x, y);
		_b.position.set(new Vec2(_b.position.x + _b.bounds.width*0.5, _b.position.y + _b.bounds.height*0.5));
		this.b = _b;
		
		b.shapes.at(0).localCOM.set( new Vec2(0, 0));			
		
		this.b.cbTypes.add(Callbacks.objetoCallback);
		this.b.cbTypes.add(Callbacks.plataformaCallback);
		this.b.userData.object = this;	
		
		loadGraphic(AssetPaths.plataforma_horizontal_path, false, 320, 32);
		
		vaYViene = va_viene;
		
		var sentido:Int = b.userData.sentido;
		
		
		
		if (sentido == 1) {
			currentState = 1;		
			minX = _b.position.x;
			maxX = _b.position.x + _b.bounds.width;
		}else {
			currentState = 2;	
			maxX = _b.position.x;
			minX = _b.position.x - _b.bounds.width;
		}
		
		
		Globales.bodyList_typeObjectos.add(this.b);
		b.space = FlxNapeSpace.space;		
	
		tipo = "PlataformaMovHor";
		setNormalText(18);		
		
		
		
	}
	
	override public function comportamiento():Void 	{			

		
		updateTextPos();
		
		switch(currentState) {
		
			case estado_derecha: 
				b.velocity.x = 200;
			case estado_izquierda: 
				b.velocity.x = -200;
			case estado_detenido:
				b.velocity.x = 0;
			
		}
		
		
		checkEjeX();
	}
	
	function checkEjeX():Void {

		/* Controla la posicion en Y de la plataforma */
			
		if ( currentState == 1) {
			// Estado derecha
			if  (b.position.x > maxX) {
				if (vaYViene) {
					currentState = estado_izquierda;	
				}else {
					currentState = estado_detenido;	
				}
			}
		}else 
		if (currentState == 2) {
			// Estado bajando
			if ( b.position.x  < minX) {
				if (vaYViene) {
					currentState = estado_derecha;	
				}else {
					currentState = estado_detenido;	
				}
			}
		}
	
		
	}
	
	
}