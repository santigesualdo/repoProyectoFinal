package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import lime.math.Vector2;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;

/**
 * ...
 * @author ...
 */
class PlataformaConMovientoVertical extends PlataformaConMovimiento
{
	var minLimitY : Float; 
	var maxLimitY : Float;
	
	var subeYBaja:Bool;
	
	var currentState = 0;
	static inline var estado_subiendo:Int = 1;
	static inline var estado_bajando:Int= 2;
	static inline var estado_detenido:Int = 3;
	
	var velocityY: Float ;
	var recorridoY: Float;
	
	/* Plataforma Vertical 
	 * 
	 * Cuando es activada, baja y sube. Puede ser desactivada.
	 * De tiled trae la variable: "subeYBaja". Si es true, la plataforma nunca deja de subir y bajar.
	 * Analizar si hace daño o no.
	 * 
	 * */
	
	public function new(x:Float, y:Float, _b:Body, _sube_baja:Bool , sentidoInicial:Int) 	{
		
		super(x, y);
		_b.position.set(new Vec2(_b.position.x + _b.bounds.width*0.5, _b.position.y + _b.bounds.height*0.5));
		this.b = _b;				
		
		subeYBaja = _sube_baja;
		
		b.shapes.at(0).localCOM.set( new Vec2(0, 0));
		
		this.b.cbTypes.add(Callbacks.objetoCallback);
		this.b.cbTypes.add(Callbacks.plataformaCallback);
		this.b.userData.object = this;		
	
		if (b.userData.velocityY != null){
			velocityY = Std.parseFloat(  b.userData.velocityY);
		}
		
		if (b.userData.recorridoY != null){
			recorridoY = Std.parseFloat(  b.userData.recorridoY);
		}
		
		if (b.userData.tocaPlayer != null) {
		/* Esta plataforma es posible recorrido del Player*/
		
			var cb:CbType = new CbType();
			b.cbTypes.add(cb);
			
			var icB:InteractionListener = new InteractionListener( 
				CbEvent.BEGIN,
				InteractionType.COLLISION,
				Callbacks.bodyInferiorCallback,
				cb,
				function playerBPlataformaVertical(e:InteractionCallback) {
					
					var playerBody:Body = e.int1.castBody;
					var player:PlayerNape = cast(playerBody.userData.object, PlayerNape);
					
					player.setPlayerOnPlataform();					
				}
			);
			
						
			var icO:InteractionListener = new InteractionListener( 
				CbEvent.ONGOING,
				InteractionType.COLLISION,
				Callbacks.bodyInferiorCallback,
				cb,
				function playerOnPlataformaVertical(e:InteractionCallback) {
					
					var playerBody:Body = e.int1.castBody;
					var platBody:Body = e.int2.castBody;
					var player:PlayerNape = cast(playerBody.userData.object, PlayerNape);
					
					player.setFixedVelocity(platBody.velocity.y);	
					player.setFixedPositionY(platBody.position.y - playerBody.bounds.height);
				}
			);
			
			
			var icE:InteractionListener = new InteractionListener( 
				CbEvent.END,
				InteractionType.COLLISION,
				Callbacks.bodyInferiorCallback,
				cb,
				function playerOnPlataformaVerticallEnd(e:InteractionCallback) {
					var playerBody:Body = e.int1.castBody;
					//var platBody:Body = e.int2.castBody;
					var player:PlayerNape = cast(playerBody.userData.object, PlayerNape);
					
					player.setPlayerOffPlataform();
				}
			);
			
			FlxNapeSpace.space.listeners.add(icB);
			FlxNapeSpace.space.listeners.add(icO);			
			FlxNapeSpace.space.listeners.add(icE);	
		}
		
		if(sentidoInicial == estado_subiendo){
			minLimitY = _b.position.y - recorridoY ;
			maxLimitY = _b.position.y;
		}
		else{
			minLimitY = _b.position.y ;
			maxLimitY = _b.position.y + recorridoY;
		}
		
		currentState = sentidoInicial;//1;	
		Globales.bodyList_typeObjectos.add(this.b);
		b.space = FlxNapeSpace.space;	
		
		tipo = "PlataformaMovVertical";
		setNormalText(18);		
	}
	
	override public function comportamiento():Void 	{			

		
		updateTextPos();
		
		switch(currentState) {
		
			case estado_subiendo: 
				b.velocity.y = -velocityY;
			case estado_bajando: 
				b.velocity.y = velocityY;
			case estado_detenido:
				b.velocity.y = 0;
			
		}
		
		checkEjeY();
	}
	
	function checkEjeY():Void {

		/* Controla la posicion en Y de la plataforma */
			
		if ( currentState == 1) {
			// Estado subiendo
			if  (b.position.y < minLimitY) {
				if (subeYBaja) {
					currentState = estado_bajando;	
				}else {
					currentState = estado_detenido;	
				}
			}
		}else 
		if (currentState == 2) {
			// Estado bajando
			if ( b.position.y  > maxLimitY) {
				if (subeYBaja) {
					currentState = estado_subiendo;	
				}else {
					currentState = estado_detenido;	
				}
			}
		}
	
		
	}

}