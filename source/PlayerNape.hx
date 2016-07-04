package ;
import flash.events.KeyboardEvent;
import flixel.addons.nape.FlxNapeSpace;
import flixel.animation.FlxAnimation;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.Assets;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.dynamics.Arbiter;
import nape.dynamics.CollisionArbiter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.space.Space;

import states.PlayState;
import states.PlaySubState;
import utils.AssetPaths;
import utils.Callbacks;
import utils.Globales;
import utils.objetos.ObjetoBase;
import utils.SpinePlayer;


class PlayerNape extends FlxObject
{
		// este se usa para chocar contra plataformas (rectangular)
		public var bodyIntermedio:Body;
		
		// este se usa para chocar contra el piso (circular)
		var bodyInferior:Body;	
		
		var sInferior:Shape;
		//var sInferior:Polygon;
		
		var currentSpace:Space;
				
		var tocaPiso:Bool;
		//var tocaPlataforma:Bool;
		var colisionCostadoPlataforma:Bool;
		var frenando:Bool;
		var tierraFirme:Bool;
		var colisionaParedDerecha:Bool;
		var colisionaParedIzquierda:Bool;
		var plataformaVertical:Bool;
		var idPlataformaPiso:Int;
		
		var agarre:Bool;
		var trepar:Bool;
	
		var plataformaAgarrePermitido:Bool;	
		var tocaPlataformaIzq:Bool;
		var topeY:Float;
		var topeX:Float;
		var agarrePos:Vec2;
		
		var sprite:FlxSprite = null;
		var spinePlayer:SpinePlayer = null; 
		var _emitter:FlxEmitter = null;		
		var animationItemEated:FlxSprite = null;
		
		var bodyInferiorCallback:CbType = new CbType();
		var subiendoPlataforma:Bool ;
		
		private static inline var maxJumpVelX:Int = 100;
		private static inline var maxVelX:Int = 285;
		private static inline var jumpForce:Int = 2850;//ESTO
		
		var text :FlxText = null;
		var textObjInteractivo:FlxText = null;
		//var lastVelX:Float;
		var textoColision:String;
		
		var lastState:Int = 0;
		var currentState:Int = 0;
		var estado:String = "";
		static inline var estadoQUIETO:Int = 1;
		static inline var estadoSALTANDO:Int = 2;
		static inline var estadoSALTANDOYCORRIENDO:Int = 3;
		static inline var estadoMOVIENDOENELAIRE:Int = 6;
		static inline var estadoCORRIENDO:Int = 5;
		static inline var estadoAGARRADO:Int = 4;		
		static inline var estadoFRENANDO:Int = 7;	
		static inline var estadoONPLATAFORMAVERTICAL:Int = 8;	
		
		var PersonajePrePiso:PreListener;
		var PersonajeConObjetoInteractivoEnd:InteractionListener;
		var PersonajeConObjetoInteractivo:InteractionListener;
		var PersonajeConPiso:InteractionListener;
		var PersonajeConPisoEnd:InteractionListener;
		var PersonajeConPlataforma:InteractionListener;		
		var PersonajeConAgarre:InteractionListener;
		var PersonajeConAgarreEnd:InteractionListener;		
		var PersonajeConPlataformaEnd:InteractionListener;
		var BulletWithWorld:InteractionListener;
		var BulletMagnetWithBody:InteractionListener;
		var BulletLinearMagnetWithWorld:InteractionListener;
		
		
		var textoColisionTime:Float = 3; /* en segundos */
		var textoColisionAcum:Float;
		var textoColisionOn:Bool;
		
		var colisionaConObjetoInteractivo:Bool;
		var miraIzquierda:Bool;
		var maxVelocityCaida:Float = 800 ;		
		
		var fixedY:Float = -1;
		var fixedPositionY:Float = 0;
		var normalColision:Vec2 = new Vec2(0, 0);
		var normalColision2:Vec2 = new Vec2(0, 0);

	public function new(_x:Float, _y:Float, space : Space ) {
		
		super(_x,_y,35,35);
			
		text = new FlxText(FlxG.width, this.x, this.y, "No Name Game");
		text.setFormat(AssetPaths.font_kreon, 18, FlxColor.YELLOW, "left");
		//text.addFormat(new FlxTextFormat(0xE6E600, false, false, 0xFF8000));	
		Globales.currentState.add(text);	
		text.visible = Globales.verTexto;
				
		textoColisionAcum = 0;
		textoColisionOn = false;
		
		currentState = estadoSALTANDO;
		
		agarrePos = new Vec2(0,0);
		
		currentSpace = space;
		
		var pos:Vec2 = new Vec2(_x,_y);

		createBodyInferior(pos);
		
		frenando = false;
		tierraFirme = false;
		colisionaParedIzquierda = false;
		colisionaParedDerecha = false;
		subiendoPlataforma = false;
		colisionaConObjetoInteractivo = false;
		plataformaAgarrePermitido = false;
		tocaPlataformaIzq = false;
		plataformaVertical = false;
		idPlataformaPiso = -1;
						
		declararCallbacks();
		
		pos.dispose();
		
		bodyInferior.userData.object = this;
		
		crearParticleEmitter();
		
		crearAnimacionSpine();
		//crearAnimacion();
		
	}
	
	/*public function playAnimation():Void {
	
		animationItemEated = new FlxSprite(x, y);
		animationItemEated.loadGraphic(AssetPaths.anim_item_eated, true, 150, 85, true);
		animationItemEated.animation.add("anim", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], 60, false);
		
		Globales.currentState.add(animationItemEated);
		animationItemEated.animation.play("anim", false);
		
	}*/
	
	function crearParticleEmitter():Void
	{
		_emitter= new FlxEmitter(this.x,this.y, 5);
		
		// All we need to do to start using it is give it some particles. makeParticles() makes this easy!
		
		_emitter.loadParticles(AssetPaths.playerParticlesPath, 5);
		
		// Now let's add the emitter to the state.
		_emitter.alpha.set(1, 1, 0, 0);
		
		
		Globales.currentState.add(_emitter);
		
		// Now lets set our emitter free.
		// Params: Explode, Emit rate (in seconds), Quantity (if ignored, means launch continuously)
		
		_emitter.start(false, 0.05);
	}
	
	function crearAnimacion():Void	{
		
		
		sprite = new FlxSprite(x, y);
		sprite.loadGraphic(AssetPaths.PLAYER_ANIM, true, 180, 187, true);
		
		sprite.animation.add("estadoMOVIENDOENELAIRE", [17, 18, 19, 20, 21, 22], 15, true);
		sprite.animation.add("estadoQUIETO", [23,24,25,26,27,28], 15, true);
		sprite.animation.add("estadoSALTANDOYCORRIENDO", [29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65], 3, false);
		sprite.animation.add("estadoCORRIENDO", [66,67, 68, 69, 70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85], 10, true);
			
		Globales.currentState.add(sprite);
	}
	
	function crearAnimacionSpine():Void {
		spinePlayer = new SpinePlayer(bodyInferior.bounds.x, bodyInferior.bounds.y, "playerMagnet", "assets/playerMagnet/");
		Globales.currentState.add(spinePlayer);		
	}
	
	function ChangeAnimation(name:String, ?flipX:Bool):Void {
		
		if (spinePlayer != null) {
			if (flipX != null) {
				AnimacionMiraIzquierda(flipX);
			}
			if (name == "estadoSUBIENDOPLATAFORMA") {
				spinePlayer.setAnimation(name,false);	
			}
			spinePlayer.setAnimation(name,true);
		}
		
		if (sprite!= null) {
			if (flipX != null) {
				AnimacionMiraIzquierda(flipX);
			}
			sprite.animation.play(name,true);
		}
		
		
	}
	
	function AnimacionMiraIzquierda(_flipX:Bool) {

		if (spinePlayer != null) {
			spinePlayer.flipX = _flipX;
			miraIzquierda = _flipX;
		}
		if (sprite != null) {
			sprite.flipX = _flipX;
			miraIzquierda = _flipX;
		}		
		
	}
	
	function createBodyInferior(pos:Vec2):Void{
		
		// Body Circular Inferior		
		bodyInferior = new Body(BodyType.DYNAMIC, pos );
		bodyInferior.userData.nombre = "playerBodyInferior";
		bodyInferior.allowRotation = false;
	
		/*sInferior= new Circle(width * 0.5, null , Material.wood());
		sInferior.userData.nombre = "playerShapeBodyInferior";
		sInferior.material = new Material(0, 0.57, 0.74, 7.5, 0.001);
		bodyInferior.shapes.add(sInferior);*/

		//CAMBIO POSTERIOR
		sInferior = new Polygon(Polygon.rect(0, 0, 20, 60));
		sInferior.userData.nombre = "playerShapeBodyInferior";
		sInferior.material = new Material(0, 0.57, 0.74, 7.5, 0.001);
		bodyInferior.shapes.add(sInferior);
		//CAMBIO POSTERIOR
		
		bodyInferior.cbTypes.add(Callbacks.bodyInferiorCallback);
		Globales.globalPlayerBodyIntermedioPos = bodyInferior.position;
		bodyInferior.space = currentSpace;		
	}
		
	function declararCallbacks():Void {
			
		PersonajeConAgarre = new InteractionListener(
			CbEvent.BEGIN, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, Callbacks.agarreCallback,
			function OnPersonajeConAgarre(e:InteractionCallback):Void {
				
				var bodyAgarre:Body = e.int2.castBody;		
				
				// FlxG.log.add("Toca agarre");
				
				if (!agarre) {	
					
					// FlxG.log.add("Toca agarre");
					 //if (bodyInferior.bounds.y < (bodyAgarre.bounds.y + bodyAgarre.bounds.height * 0.1)) {
					 //if ((bodyInferior.bounds.y + bodyInferior.bounds.height * 0.1) < bodyAgarre.bounds.y){
					 // if((bodyInferior.bounds.y + bodyInferior.bounds.height * 0.95) > bodyAgarre.bounds.y){	 
						 if (bodyAgarre.userData.nombre != null) {
							 
							 /*var puedeseguir:Bool = Math.abs(bodyInferior.velocity.x) != 0 ? true : false;
							 
							 if (puedeseguir) {
								 if (bodyInferior.velocity.x > 0) {
									tocaPlataformaIzq = true;
								 }else {
									tocaPlataformaIzq = false; 
								 }								 
							 }else {
								return; 
							 }*/
							 
							 if (((bodyInferior.bounds.x + bodyInferior.bounds.width) >= bodyAgarre.bounds.x) && !spinePlayer.flipX){
								 if ((bodyInferior.bounds.x + bodyInferior.bounds.width) <= (bodyAgarre.bounds.x + bodyAgarre.bounds.width + 2)){
									 if (bodyInferior.bounds.x < bodyAgarre.bounds.x){
										 
										//plataformaAgarrePermitido = true;
										if (/*plataformaAgarrePermitido && tocaPlataformaIzq &&*/ (bodyAgarre.userData.nombre == "rectAgarreIzq")) {//AGARRE IZQUIERDO DE PERSONAJE	
									
											//lastVelX = bodyInferior.velocity.x;
											agarrePos = new Vec2(bodyAgarre.bounds.x-bodyInferior.bounds.width, bodyAgarre.bounds.y/* + bodyAgarre.bounds.height*0.5*/);
											bodyInferior.position.set(agarrePos);
										
											topeX = bodyInferior.bounds.x + bodyInferior.bounds.width*2.5;
											topeY = bodyAgarre.bounds.y - bodyInferior.bounds.height*1.001; //- bodyInferior.bounds.height;
										
											bodyInferior.velocity.x = bodyInferior.velocity.y = 0; 
											agarre = true;
											//tierraFirme = false;
											tocaPlataformaIzq = true;
											CambiarEstado(estadoAGARRADO);	
										 }
									 }
								 }
							 }
							 else if ((bodyInferior.bounds.x <= (bodyAgarre.bounds.x + bodyAgarre.bounds.width))  && spinePlayer.flipX){
								  if(bodyInferior.bounds.x >= bodyAgarre.bounds.x - 2){
									if ((bodyInferior.bounds.x + bodyInferior.bounds.width) > bodyAgarre.bounds.x){
										
										//plataformaAgarrePermitido = true;
										if (/*plataformaAgarrePermitido && !tocaPlataformaIzq &&*/ (bodyAgarre.userData.nombre == "rectAgarreDer")) {// AGARRE DERECHO DE PERSONAJE
											
											//lastVelX = bodyInferior.velocity.x;			
											agarrePos = new Vec2(bodyAgarre.bounds.x , bodyAgarre.bounds.y);
											bodyInferior.position.set(agarrePos);
											
											topeX = bodyInferior.bounds.x - bodyInferior.bounds.width *1.5;
											topeY = bodyAgarre.bounds.y - bodyInferior.bounds.height*1.001;// * 1.03; //- bodyInferior.bounds.height;
											
											bodyInferior.velocity.x = bodyInferior.velocity.y = 0;
											agarre = true;
											//tierraFirme = false;
											tocaPlataformaIzq = false;
											CambiarEstado(estadoAGARRADO);
										 }
									 }
								 }
							 }
						// }
					  //}
					}
				}
			}
		);
		
		PersonajeConAgarreEnd = new InteractionListener(
			CbEvent.END, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, Callbacks.agarreCallback,
			function OnPersonajeConAgarreEnd(e:InteractionCallback):Void {

				//tocaPlataformaIzq = false;
			}		
		);	
	
		PersonajeConPlataforma = new InteractionListener(
			CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function OnPersonajeConPlataformaCollision(e:InteractionCallback):Void {
			
				if (!agarre && !trepar){

					//normal de la interaccion actual del jugador
					if (bodyInferior.arbiters.length >= 1){
						
						var arb:CollisionArbiter = bodyInferior.arbiters.at(0).collisionArbiter;
						
						if (arb != null){
							
							normalColision = arb.referenceEdge1.localNormal;
							
							if(normalColision.y == -1){
								idPlataformaPiso = arb.body1.id;
							}
						}
					}

					var bodys:BodyList = new BodyList();
					bodyInferior.interactingBodies(InteractionType.COLLISION, 2, bodys);
					
					if(bodys.length == 1){//Si el jugador colisiona con una plataforma que es el piso
						if (normalColision.y == -1){
							tierraFirme = true;
						}
						else if(normalColision.y != -1){
							tierraFirme = false;
						}
					}
					else if (bodys.length == 2){//Si el jugador colisiona con dos plataformas a la vez, y una es piso
						
						//segunda normal de la interaccion actual del jugador
						if (bodyInferior.arbiters.length >= 2){
							
							var arb2:CollisionArbiter = bodyInferior.arbiters.at(1).collisionArbiter;
						
							if (arb2 != null){
								
								normalColision2 = arb2.referenceEdge1.localNormal;
								
								if(normalColision2.y == -1){
									idPlataformaPiso = arb2.body1.id;
								}
							}
						}
						
						if (((Math.abs(normalColision.x) == 1) || (Math.abs(normalColision2.x) == 1)) && (bodyInferior.velocity.y == 0)){
							tierraFirme = true;
						}
						else if ((normalColision.y == -1) || (normalColision2.y == -1)){//La normal de colision es del piso
							tierraFirme = true;
						}
						
						
						if(Math.abs(normalColision.x) == 1){
							if (normalColision.x == -1){
								colisionaParedIzquierda = true; 
							}
							else if (normalColision.x == 1){
								colisionaParedDerecha = true;
							}
						}
						else if(Math.abs(normalColision2.x) == 1){
							if (normalColision2.x == -1){
								colisionaParedIzquierda = true; 
							}
							else if (normalColision2.x == 1){
								colisionaParedDerecha = true;
							}
						}
					}
				}	
			}
		);
		
		PersonajeConPlataformaEnd= new InteractionListener(
			CbEvent.END, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function OnPersonajeConPlataformaCollisionEnd(e:InteractionCallback):Void {
				
				if (!agarre && !trepar){
					
					var bodyPlataforma:Body = e.int2.castBody;
					
					if(bodyPlataforma.id == idPlataformaPiso){
						tierraFirme = false;
					}

					/*var bodys:BodyList = new BodyList();
					bodyInferior.interactingBodies(InteractionType.COLLISION, 2, bodys);
					
					if((bodys.length == 1) && ((normalColision.y == -1) || (normalColision2.y == -1))){//Si el jugador colisionaba con una sola plataforma que es piso
						tierraFirme = false;
					}
					else if ((bodys.length == 2) && ((normalColision.y != -1) || (normalColision2.y != -1))){//Si el jugador colisionaba con dos plataformas, y ninguna era el piso
						tierraFirme = false;
					}*/		
				}		
				
				colisionaParedIzquierda = colisionaParedDerecha = false;
			}
		);
		
		/*PersonajeConPlataforma = new InteractionListener(
			CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function OnPersonajeConPlataformaCollision(e:InteractionCallback):Void {
			
				//normal de la interaccion actual
				normalColision = e.arbiters.at(0).collisionArbiter.referenceEdge1.localNormal;
				//var normalTemp:Vec2 = e.arbiters.at(0).collisionArbiter.referenceEdge1.localNormal;
				
				var bodys:BodyList = new BodyList();
				bodyInferior.interactingBodies(InteractionType.COLLISION, 2, bodys);
				
				if(bodys.length == 1){//Si el jugador colisiona con una plataforma, se actualiza la normal de colision
					if(normalColision.y == -1){
						tierraFirme = true;
					}
				}
				else if (bodys.length == 2){//Si el jugador colisiona con dos plataformas a la vez
					if ((Math.abs(normalColision.x) == 1) && (bodyInferior.velocity.y == 0)){//Se actualiza la normal de colision solo si la anterior normal no fue el piso
						tierraFirme = true;
					}
					else if (normalColision.y == -1){//Se actualiza la normal de colision solo si la anterior normal no fue el piso
						tierraFirme = true;
					}
				}
			}		
		);
		
		PersonajeConPlataformaEnd= new InteractionListener(
			CbEvent.END, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function OnPersonajeConPlataformaCollisionEnd(e:InteractionCallback):Void {
				
				var bodys:BodyList = new BodyList();
				bodyInferior.interactingBodies(InteractionType.COLLISION, 1, bodys);
				
				if(bodys.length == 1){
					tierraFirme = false;
				}
				else if (bodys.length == 2){
					if ((Math.abs(normalColision.x) == 1) && (bodyInferior.velocity.y != 0)){
						tierraFirme = false;
					}
					else if ((normalColision.y == -1) && (bodyInferior.velocity.y != 0)){
						tierraFirme = false;
					}
				}
			}		
		);*/
		
		PersonajePrePiso = new PreListener(
		InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function handlePreContact(callback:PreCallback):PreFlag {
				if (isPlayerFallingHard(bodyInferior.velocity.y)) {
					return PreFlag.IGNORE;
				}else {
					return PreFlag.ACCEPT;					
				}
				
			}
		);
		
		PersonajeConObjetoInteractivo = new InteractionListener(
			CbEvent.ONGOING, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, Callbacks.objetoCallback,
			function onPersonajeConObjeto(e:InteractionCallback):Void {
			
				var bodyPlayer:Body = e.int1.castBody;
				var bodyObjeto:Body = e.int2.castBody;
				
				if (bodyObjeto.userData.object != null) {
					
					var estaListo:Bool = bodyObjeto.userData.isReady;
					if (estaListo) {
						if (textObjInteractivo == null) {
							textObjInteractivo = new FlxText(this.x, this.y - FlxG.height * 0.30, 150, "Presiona E para activar objeto", 15, false);
							textObjInteractivo.setFormat(AssetPaths.font_kreon, textObjInteractivo.size, FlxColor.WHITE, "center");
						}else {
							textObjInteractivo.setPosition(this.x, this.y - FlxG.height * 0.30);
						}
						bodyPlayer.userData.objetoInteractivo = cast(bodyObjeto.userData.object, ObjetoBase);
						colisionaConObjetoInteractivo = true;						
					}
				}
			});
			
		PersonajeConObjetoInteractivoEnd = new InteractionListener(			
			CbEvent.END, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, Callbacks.objetoCallback,
			function onPersonajeConObjetoEnd(e:InteractionCallback):Void {
			
				var bodyPlayer:Body = e.int1.castBody;
				var bodyObjeto:Body = e.int2.castBody;
				
				if (bodyPlayer.userData.objetoInteractivo != null) {
					bodyPlayer.userData.objetoInteractivo = null;
					colisionaConObjetoInteractivo = false;
				}
		});	
				
		
		FlxNapeSpace.space.listeners.add(PersonajePrePiso);
		FlxNapeSpace.space.listeners.add(PersonajeConObjetoInteractivoEnd);
		FlxNapeSpace.space.listeners.add(PersonajeConObjetoInteractivo);
		FlxNapeSpace.space.listeners.add(PersonajeConPlataforma);		
		FlxNapeSpace.space.listeners.add(PersonajeConPlataformaEnd);	
		FlxNapeSpace.space.listeners.add(PersonajeConAgarre);
		FlxNapeSpace.space.listeners.add(PersonajeConAgarreEnd);		
		
	}
	
	function isPlayerFallingHard(lastVelocity:Float):Bool {
		// FlxG.log.add("Velocity y : " + bodyInferior.velocity.y );
		if (lastVelocity > maxVelocityCaida) {
			playerDead("Caida mortal");
			return true;
		}else {
			return false;
		}
	}
	
	function activarObjetoInteractivo():Void {
	
		if (bodyInferior.userData.objetoInteractivo != null){
			var ob:ObjetoBase = cast(bodyInferior.userData.objetoInteractivo, ObjetoBase);
			ob.activar();			
		}		
	}
		
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		actualizarEstados();
	
		textosEnPantalla();
		
		this.x = bodyInferior.position.x;
		this.y = bodyInferior.position.y;
		
		if (spinePlayer != null) {
			spinePlayer.x = this.x +bodyInferior.bounds.width*0.5; 
			spinePlayer.y = this.y + bodyInferior.bounds.height;			
		}
		
		if (sprite!= null) {
			sprite.x = this.x ; 
			sprite.y = this.y +bodyInferior.bounds.height *0.5;			
		}
		
		if (_emitter!= null) {
			_emitter.x = this.x+bodyInferior.bounds.width*0.5 ; 
			_emitter.y = this.y+ bodyInferior.bounds.height*0.5 ;
		}	
		
		/*if (animationItemEated != null) {
			if (animationItemEated.animation.curAnim.finished) {
				Globales.currentState.remove(animationItemEated);
				animationItemEated = null;
			}
		}*/
		

		
		eventos();
		
		checkInWorld();
	}	
	
	function textosEnPantalla() :Void	{

		text.setPosition(FlxG.camera.scroll.x+5, FlxG.camera.scroll.y );
		
		if (textoColisionOn) {
			text.text = 
			"( TECLA V para desactivar texto.)"  +
			"\nPLAYER: "  +
			"\n" + cast(this.getMidpoint().x, Int) +"," + cast(this.getMidpoint().y, Int) + 			
			"\nVELX: " + Std.int(bodyInferior.velocity.x) +
			"\nVELY: " + Std.int(bodyInferior.velocity.y) +
			"\ntierraFirme: " + tierraFirme +
			"\nSubiendoPlataforma: " + subiendoPlataforma +
			"\nNORMALCOLISION: (" + normalColision.x + ","  + normalColision.y + ")" +
			"\nNORMALCOLISION2: (" + normalColision2.x + ","  + normalColision2.y + ")" + 
			"\ncolisionIzquierda: " + colisionaParedIzquierda +
			"\ncolisionDerecha: " + colisionaParedDerecha +
			"\nmirandoIzquierda: " + spinePlayer.flipX +
			"\nESTADO: " + estado.toUpperCase();
			
			if (textoColisionAcum < textoColisionTime) {
				textoColisionAcum += FlxG.elapsed;
			}else {
				textoColisionAcum = 0;
				textoColisionOn = false;
			}			
		}else {
			text.text = 
			"( TECLA V para desactivar texto.)"  +
			"\nPLAYER: "  +
			"\n" + cast(this.getMidpoint().x, Int) +"," + cast(this.getMidpoint().y, Int) + 	
			"\nVELX: " + Std.int(bodyInferior.velocity.x) +
			"\nVELY: " + Std.int(bodyInferior.velocity.y) +
			"\ntierraFirme: " + tierraFirme +
			"\nSubiendoPlataforma: " + subiendoPlataforma +
			"\nNORMALCOLISION: (" + normalColision.x + ","  + normalColision.y + ")" +
			"\nNORMALCOLISION2: (" + normalColision2.x + ","  + normalColision2.y + ")" +
			"\ncolisionIzquierda: " + colisionaParedIzquierda +
			"\ncolisionDerecha: " + colisionaParedDerecha +
			"\nmirandoIzquierda: " + spinePlayer.flipX +
			"\nESTADO: " + estado.toUpperCase();
		}
	
	}
	
	public function agregarCollisionAText(objeto:String):Void {
		
		textoColision ="\nColisionCon:" + objeto;
		textoColisionOn = true;
		
	}
	
	public function playerDead(nombre:String):Void {
		
		var ps:PlayState = cast(Globales.currentState, PlayState);
		var ss:PlaySubState = ps.getSubPlayState(FlxColor.RED);
			
		ps.openSubState( ss );
		ss.setPos(new FlxPoint(FlxG.camera.scroll.x + 300, FlxG.camera.scroll.y + 300));
	}
	
	function actualizarEstados():Void 	{
		
		switch(currentState) {
		
			case estadoQUIETO: estado = "estadoQUIETO";
			case estadoCORRIENDO: estado = "estadoCORRIENDO";
			case estadoSALTANDO: estado = "estadoSALTANDO";
			case estadoMOVIENDOENELAIRE: estado = "estadoMOVIENDOENELAIRE";
			case estadoSALTANDOYCORRIENDO: estado = "estadoSALTANDOYCORRIENDO";
			case estadoAGARRADO: estado = "estadoAGARRADO";
			case estadoFRENANDO: estado = "estadoFRENANDO";
			case estadoONPLATAFORMAVERTICAL: estado = "estadoONPLATAFORMAVERTICAL";
			default: estado = "estadoDESCONOCIDO - error"; return;
		}
	
	}
	
	function eventos():Void {
		
		movimientos();
		
		if (FlxG.keys.justPressed.P) {
			var ps:PlayState = cast(Globales.currentState, PlayState);
			var ss:PlaySubState = ps.getSubPlayState(FlxColor.WHITE);
			
			ps.openSubState( ss );
			ss.setPos(new FlxPoint(FlxG.camera.scroll.x + 300, FlxG.camera.scroll.y + 300));
			//Globales.currentState.openSubState(new PlaySubState("Pausa", new FlxPoint(getMidpoint().x - width * 0.5, getMidpoint().y - height)));
		}
				
		if (FlxG.keys.justReleased.H) {
			spinePlayer.visible = !spinePlayer.visible;
		}
		
		if (FlxG.keys.justReleased.V) {
			Globales.verTexto = !Globales.verTexto;
			text.visible = Globales.verTexto;
		}
		
		if (FlxG.keys.justPressed.E && colisionaConObjetoInteractivo) {
			activarObjetoInteractivo();
		}
	}
		
	function movimientos():Void {
		
		switch(currentState) {
			
			case estadoQUIETO: 
				if (tierraFirme) {
					
					if (plataformaVertical  && (fixedY != 0)){
						
						//FlxNapeSpace.space.gravity.y = 3000;
						//bodyInferior.position.y = fixedPositionY;
						//bodyInferior.velocity.y = fixedY;
					}
					else{FlxNapeSpace.space.gravity.y = 900;}
					
					if ((FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) && !colisionaParedDerecha) {
						ChangeAnimation("estadoCORRIENDO", true);
						CambiarEstado(estadoCORRIENDO);
					}else if ((FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) && !colisionaParedIzquierda)	{
						ChangeAnimation("estadoCORRIENDO", false);
						CambiarEstado(estadoCORRIENDO);
					}else if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)	{
						Saltar();
					}
				}	
				else{
					
					ChangeAnimation("estadoSALTANDO");
					CambiarEstado(estadoSALTANDO);	
				}
					
			case estadoCORRIENDO: 
					if (tierraFirme) {
						
						if (plataformaVertical  && (fixedY != 0)){
						
							//FlxNapeSpace.space.gravity.y = 3000;
							//bodyInferior.position.y = fixedPositionY;
							//bodyInferior.velocity.y = fixedY;
						}
						else{FlxNapeSpace.space.gravity.y = 900;}
						
						if ((FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) && !colisionaParedDerecha) {
							AnimacionMiraIzquierda(true);
							bodyInferior.velocity.x = -maxVelX;
						}else if ((FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) && !colisionaParedIzquierda)	{
							AnimacionMiraIzquierda(false);
							bodyInferior.velocity.x = maxVelX;					
						}
						else{
							bodyInferior.velocity.x = 0;
							ChangeAnimation("estadoQUIETO", null);
							CambiarEstado(estadoQUIETO);		
						}
						
						if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)	{
							Saltar();
							ChangeAnimation("estadoSALTANDO", null);
							CambiarEstado(estadoMOVIENDOENELAIRE);
						}					
						/*if (FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN)	{
							ChangeAnimation("estadoQUIETO", false);
							CambiarEstado(estadoFRENANDO);							
						}*/	
					}else {
						//ChangeAnimation("estadoMOVIENDOENELAIRE", null);
						
						//CambiarEstado(estadoSALTANDOYCORRIENDO);
						Globales.gravityY = 900;
						CambiarEstado(estadoMOVIENDOENELAIRE);
					}

			case estadoSALTANDO: 
					if (tierraFirme) {
						
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);
						//return;
					}
					else{
						if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
							AnimacionMiraIzquierda(true);
							//ChangeAnimation("estadoMOVIENDOENELAIRE", true);
							CambiarEstado(estadoMOVIENDOENELAIRE);
						}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
							AnimacionMiraIzquierda(false);
							//ChangeAnimation("estadoMOVIENDOENELAIRE", false);
							CambiarEstado(estadoMOVIENDOENELAIRE);
						}	
					}
					
			case estadoMOVIENDOENELAIRE:
					if (tierraFirme) {
							
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);
					}
					else{
						if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
							AnimacionMiraIzquierda(true);
							//ChangeAnimation("estadoMOVIENDOENELAIRE", true);
							if (bodyInferior.velocity.x > -maxVelX) {
								bodyInferior.applyImpulse(new Vec2(-70, 0));
							}
						}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)	{
							AnimacionMiraIzquierda(false);
							//ChangeAnimation("estadoMOVIENDOENELAIRE", false);
							if (bodyInferior.velocity.x < maxVelX) {
								bodyInferior.applyImpulse(new Vec2(70, 0));
							}
						}		
						else{bodyInferior.velocity.x = 0; }
					}
					
			/*case estadoSALTANDOYCORRIENDO: 
					if (tierraFirme) {
						ChangeAnimation("estadoQUIETO", false);
						CambiarEstado(estadoQUIETO);
					}
					else{
						if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
							//AnimacionMiraIzquierda(true);
							ChangeAnimation("estadoMOVIENDOENELAIRE", true);
							CambiarEstado(estadoMOVIENDOENELAIRE);								
						}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
							//AnimacionMiraIzquierda(false);
							ChangeAnimation("estadoMOVIENDOENELAIRE", false);
							CambiarEstado(estadoMOVIENDOENELAIRE);								
						}
					}
					
			case estadoFRENANDO:
					if (bodyInferior.velocity.x < 0.5 && bodyInferior.velocity.x > -0.5) {
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);		
					}else {
						bodyInferior.velocity.x = bodyInferior.velocity.x * 0.2;	
					}	*/
					
			case estadoAGARRADO: /* Cuando termina de subir plataforma cambia a estado QUIETO?*/
					manejoAgarres();						
							
			/*case estadoONPLATAFORMAVERTICAL:
					
				if (tierraFirme){
						
					bodyInferior.velocity.y = fixedY;
						
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
						
						ChangeAnimation("estadoCORRIENDO", true);
						//bodyInferior.velocity.x = -maxVelX;	
						CambiarEstado(estadoCORRIENDO);
								
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
						ChangeAnimation("estadoCORRIENDO", false);
						//bodyInferior.velocity.x = maxVelX;
						CambiarEstado(estadoCORRIENDO);
					}
					else{
						ChangeAnimation("estadoQUIETO", null);
						bodyInferior.velocity.x = 0;
					}
						
					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
						bodyInferior.velocity.y = 0;
						Saltar();
						ChangeAnimation("estadoSALTANDO", false);
						CambiarEstado(estadoSALTANDO);
					}	
				}*/

			default: 
		}
	}
	
	function subirPlataforma():Void {

		// para que no se pase cuando sube el punto de agarre
		var offsetTopeY = 10;
		var vel:Int = 120;
		var velImpulse:Float = 200;
				
		/*//// FlxG.log.add("body inf : " + bodyInferior.bounds.y);
		//// FlxG.log.add("tope y : " + topeY );*/
		
		bodyInferior.allowMovement = true;
		subiendoPlataforma = true;
		
		FlxNapeSpace.space.listeners.remove(PersonajeConAgarre);
		
		//// FlxG.log.add("TopeY" + topeY);
		//// FlxG.log.add("Player Y" + bodyInferior.bounds.y);
		
		if  (bodyInferior.bounds.y > topeY ) {
			bodyInferior.applyImpulse(new Vec2(0, -vel));
			//bodyInferior.position.y = bodyInferior.position.y - (vel * FlxG.elapsed);
		}else {
			bodyInferior.velocity.y = 0;
			//bodyInferior.applyImpulse(new Vec2(0, -10));
			// ya subio en Y ahora que se acomode en X
			
			//// FlxG.log.add("bodyInferior x: " + bodyInferior.bounds.x);*/
			if (tocaPlataformaIzq) {
				// FlxG.log.add("Izquierda: " + tocaPlataformaIzq);
				// plataforma a la IZQUIERDA
				if (bodyInferior.bounds.x+bodyInferior.bounds.width < topeX) {
					// FlxG.log.add("suma impulso");
					bodyInferior.applyImpulse(new Vec2(vel, 0));
				}else {
					// FlxG.log.add("llega a tope x");
					subiendoPlataforma = false;
					agarre = trepar = false;
					bodyInferior.velocity.x = bodyInferior.velocity.x * .05;
					
					FlxNapeSpace.space.listeners.add(PersonajeConAgarre);
					ChangeAnimation("estadoQUIETO",null);
					CambiarEstado(estadoQUIETO);
					FlxNapeSpace.space.gravity = new Vec2(Globales.gravityX, Globales.gravityY);
					tierraFirme = true;
				}
			}else {
				// FlxG.log.add("Izquierda: " + tocaPlataformaIzq);
				// plataforma a la DERECHA
				if (bodyInferior.bounds.x > topeX) {
					bodyInferior.applyImpulse(new Vec2(-vel, 0));
				}else {
					subiendoPlataforma = false;
					agarre = trepar = false;
					bodyInferior.velocity.x = bodyInferior.velocity.x * .05;
					FlxNapeSpace.space.listeners.add(PersonajeConAgarre);
					ChangeAnimation("estadoQUIETO",null);
					CambiarEstado(estadoQUIETO);
					FlxNapeSpace.space.gravity = new Vec2(Globales.gravityX, Globales.gravityY);
					tierraFirme = true;
				}
			}	
		}
	}
	
	function manejoAgarres() :Void	{
		
		if (agarre) {
			
			FlxNapeSpace.space.gravity = new Vec2(0, 0);
			
			if (agarrePos.x != 0) {
				// Forzamos que no movimiento fisico , estamos agarrados
				if (bodyInferior.allowMovement) {
					bodyInferior.allowMovement = false;
				}
				
				trepar = true;
				
				if (spinePlayer.getAnimName() != "estadoSUBIENDOPLATAFORMA") {
					ChangeAnimation("estadoSUBIENDOPLATAFORMA", false);
					AnimacionMiraIzquierda(!tocaPlataformaIzq);					
				}

				//agarrePos.x = 0;
				
				/*if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)  ) {
					trepar = true;
				}else if ((FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)) {
					agarrePos.x = 0;
				}
				
				if ((FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)  ) {
					trepar = true;
				}else if ((FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)) {
					agarrePos.x = 0;
				}
				
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
					trepar = true;
				}else if ((FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)) {
					agarrePos.x = 0;
				}	*/
				
			}/*else {
				// Presiono para soltarse del agarre.
				bodyInferior.allowMovement = true;
				subiendoPlataforma = false;
				CambiarEstado(estadoSALTANDO);
			}*/
		}
		if (trepar) { 
			subirPlataforma();
		}
	}
	
	function CambiarEstado(newstate:Int):Void{
		lastState = currentState;
		currentState = newstate;
	}
	
	function Saltar(factor:Float = 1.15) :Void	{
	
		bodyInferior.applyImpulse( new Vec2(bodyInferior.velocity.x, -jumpForce*factor), bodyInferior.position );
	}

	function checkInWorld():Void {
		//// FlxG.log.add("Body y: "+ (bodyInferior.position.y - bodyInferior.bounds.height * 0.5) );
		//// FlxG.log.add("Camera heigth: " +  FlxG.camera.setScrollBounds);
		if (bodyInferior.position.y - bodyInferior.bounds.height*0.5 > FlxG.camera.maxScrollY) {
			playerDead("caida");
		}		
	}
	
	override public function draw():Void {
		
		super.draw();
		
		if (colisionaConObjetoInteractivo) {
			textObjInteractivo.draw();
		}
	}
	
	public function setFixedVelocity(v:Float):Void {
		
		//if (currentState != estadoSALTANDO) {
			fixedY = v;	
		//}
	}
	
	public function setFixedPositionY(pos:Float):Void {
		
		//if (currentState != estadoSALTANDO) {
			fixedPositionY = pos;	
		//}
	}
	
	public function setPlayerOnPlataform():Void {
		//CambiarEstado(estadoONPLATAFORMAVERTICAL);
		//ChangeAnimation("estadoQUIETO", null);
		plataformaVertical = true;
	}
	
	public function setPlayerOffPlataform():Void {
		/*if (currentState == estadoONPLATAFORMAVERTICAL && Math.abs(this.bodyInferior.velocity.x) > 10) {
			CambiarEstado(estadoMOVIENDOENELAIRE);	
		}*/
		
		//CambiarEstado(estadoQUIETO);	
		plataformaVertical = false;
	}
	
	public function playerPesoNormal():Void {
		// FlxG.log.add("cambiaPesoANormal");
		bodyInferior.shapes.at(0).material = new Material(0, 0.57, 0.74, 7.5, 0.001);//Material.steel();
	}
	
	override public function destroy():Void {
		
		super.destroy();
		
	}
	
}