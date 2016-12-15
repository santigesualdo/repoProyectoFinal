package ;
import flixel.*;
import flash.events.KeyboardEvent;
import flixel.addons.nape.*;
import flixel.effects.particles.*;
import flixel.math.*;
import flixel.text.*;
import flixel.util.*;
import nape.callbacks.*;
import nape.dynamics.*;
import nape.geom.*;
import nape.phys.*;
import nape.shape.*;
import nape.space.*;
import states.*;
import utils.*;
import utils.objetos.*;



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
		
		var startAnimation:FlxSprite = null;
		var startAnimationFinished:Bool;
		
		var bodyInferiorCallback:CbType = new CbType();
		var subiendoPlataforma:Bool ;
		var startAnimationOffset_X: Float = 70;
		var startAnimationOffset_Y: Float = 100;
		
		private static inline var maxJumpVelX:Int = 100;
		private static inline var maxVelX:Int = 285;
		private static inline var jumpForce:Int = 2850;//ESTO
		
		var text :FlxText = null;
		var textObjInteractivo:FlxText = null;
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
		var starsCollected: Int ;
		
		var timeToSpawn:Float = 2;
		var timeToSpawnAcum : Float = 0;
		var isTimeToSpawn: Bool;
		
		var spinePlayerAlphaDelay:Float = 2;
		var spinePlayerAlphaDelayAcum:Float = 0;
		var isAlphaDelayFinish:Bool;

	public function new(_x:Float, _y:Float, space : Space ) {
		
		super(_x,_y,35,35);
			
		text = new FlxText(FlxG.width, this.x, this.y, "No Name Game");
		text.setFormat(AssetPaths.font_kreon, 18, FlxColor.YELLOW, "left");
		Globales.currentState.add(text);	
		text.visible = Globales.verTexto;
				
		textoColisionAcum = 0;
		textoColisionOn = false;
		
		starsCollected = Globales.starsCollected;
		
		currentState = estadoMOVIENDOENELAIRE	;
		
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
		
		isTimeToSpawn = false;
		isAlphaDelayFinish = false;
		
		timeToSpawnAcum = 0;
		spinePlayerAlphaDelayAcum = 0;
		
		crearAnimacionSpine();
		
	}
	
	function crearAnimacionStartPlayer() : Void {
		startAnimation = new FlxSprite(spinePlayer.x -startAnimationOffset_X, spinePlayer.y-startAnimationOffset_Y);
		startAnimation.loadGraphic(AssetPaths.PLAYER_STARTANIM, true, 150, 150, false);
		startAnimation.animation.add("startAnimation", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 , 11 , 12 , 13 , 14] , 30, false);
		Globales.currentState.add(startAnimation);
		startAnimation.animation.play("startAnimation");
	}
	
	public function getStarsCollected():Int {
		return this.starsCollected;
	}
	
	function crearParticleEmitter():Void {
		
		
		_emitter= new FlxEmitter(this.x,this.y, 5);
		
		// All we need to do to start using it is give it some particles. makeParticles() makes this easy!
		
		_emitter.loadParticles(AssetPaths.playerParticlesPath, 5);
		
		// Now let's add the emitter to the state.
		_emitter.alpha.set(1, 1, 0, 0);
		
		
		Globales.currentState.add(_emitter);
		
		//_emitter.scale.set(1, 1, 1, 1, 4, 4, 8, 8);
		
		// Now lets set our emitter free.
		// Params: Explode, Emit rate (in seconds), Quantity (if ignored, means launch continuously)
		
		_emitter.start(false, 0.025);
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
		spinePlayer.alpha = 0;	
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
				
				if (!agarre) {	
						 if (bodyAgarre.userData.nombre != null) {
							 if (((bodyInferior.bounds.x + bodyInferior.bounds.width) >= bodyAgarre.bounds.x) && !spinePlayer.flipX){
								 if ((bodyInferior.bounds.x + bodyInferior.bounds.width) <= (bodyAgarre.bounds.x + bodyAgarre.bounds.width + 2)){
									 if (bodyInferior.bounds.x < bodyAgarre.bounds.x){
										if ((bodyAgarre.userData.nombre == "rectAgarreIzq")) {//AGARRE IZQUIERDO DE PERSONAJE	
											agarrePos = new Vec2(bodyAgarre.bounds.x-bodyInferior.bounds.width, bodyAgarre.bounds.y/* + bodyAgarre.bounds.height*0.5*/);
											bodyInferior.position.set(agarrePos);
										
											topeX = bodyInferior.bounds.x + bodyInferior.bounds.width*2.5;
											topeY = bodyAgarre.bounds.y - bodyInferior.bounds.height*1.001; //- bodyInferior.bounds.height;
										
											bodyInferior.velocity.x = bodyInferior.velocity.y = 0; 
											agarre = true;
											tocaPlataformaIzq = true;
											CambiarEstado(estadoAGARRADO);	
										 }
									 }
								 }
							 }
							 else if ((bodyInferior.bounds.x <= (bodyAgarre.bounds.x + bodyAgarre.bounds.width))  && spinePlayer.flipX){
								  if(bodyInferior.bounds.x >= bodyAgarre.bounds.x - 2){
									if ((bodyInferior.bounds.x + bodyInferior.bounds.width) > bodyAgarre.bounds.x){
										if ((bodyAgarre.userData.nombre == "rectAgarreDer")) {// AGARRE DERECHO DE PERSONAJE
											agarrePos = new Vec2(bodyAgarre.bounds.x , bodyAgarre.bounds.y);
											bodyInferior.position.set(agarrePos);
											
											topeX = bodyInferior.bounds.x - bodyInferior.bounds.width *1.5;
											topeY = bodyAgarre.bounds.y - bodyInferior.bounds.height*1.001;// * 1.03; //- bodyInferior.bounds.height;
											
											bodyInferior.velocity.x = bodyInferior.velocity.y = 0;
											agarre = true;
											tocaPlataformaIzq = false;
											CambiarEstado(estadoAGARRADO);
										 }
									 }
								 }
							 }
					}
				}
			}
		);
	
		PersonajeConPlataforma = new InteractionListener(
			CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function OnPersonajeConPlataformaCollision(e:InteractionCallback):Void {
			
				var b:Body = e.int2.castBody;
				
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
					bodyInferior.interactingBodies(InteractionType.COLLISION, -1, bodys);
					
					for ( b in bodys ) {
						var nombre:String = b.userData.nombre;
						FlxG.log.add("Nombre: " + nombre);
						if (nombre != "plataforma"){
							FlxG.log.add("Removido de colision " + nombre);
							bodys.remove(b);
						}
					}
					
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
					else{
						if(Math.abs(normalColision.x) == 1){
							normalColision = new Vec2(0, 0);
						}
						else if(Math.abs(normalColision2.x) == 1){
							normalColision2 = new Vec2(0, 0);
						}
					}
					colisionaParedIzquierda = colisionaParedDerecha = false;
				}		
			}
		);
				
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
				
		
		activarListeners();
		
	}
	
	function isPlayerFallingHard(lastVelocity:Float):Bool {
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
		
		if (isTimeToSpawn){
			
			controlarStartAnimation();
			
			actualizarEstados();
		
			textosEnPantalla();
			
			this.x = bodyInferior.position.x;
			this.y = bodyInferior.position.y;
			
			if (spinePlayer != null) {
				spinePlayer.x = this.x +bodyInferior.bounds.width*0.5; 
				spinePlayer.y = this.y + bodyInferior.bounds.height;	
			}
			
			if (startAnimation != null){
				startAnimation.x = spinePlayer.x - startAnimationOffset_X;
				startAnimation.y = spinePlayer.y - startAnimationOffset_Y;
				startAnimation.visible = !startAnimation.animation.finished;
			}
			
			if (sprite!= null) {
				sprite.x = this.x ; 
				sprite.y = this.y +bodyInferior.bounds.height *0.5;			
			}
			
			if (_emitter!= null) {
				_emitter.x = this.x+bodyInferior.bounds.width*0.5 ; 
				_emitter.y = this.y + bodyInferior.bounds.height * 0.5 ;
				
			}	
			
			eventos();
			
			checkInWorld();			
			
		}else{
			if (timeToSpawnAcum < timeToSpawn){
				timeToSpawnAcum += elapsed;
			}else{
				FlxG.log.add("IsTimeToSpawn: true");
				isTimeToSpawn = true;
				crearAnimacionStartPlayer();
			}
		}
		

	}	
	
	function controlarStartAnimation() : Void {
		if (!startAnimation.animation.finished){
			if (spinePlayerAlphaDelayAcum < 1){
				spinePlayerAlphaDelayAcum += 0.03;
				spinePlayer.alpha = spinePlayerAlphaDelayAcum;
			}else{
				spinePlayerAlphaDelayAcum = 0;
				spinePlayer.alpha = 1;
			}	
		}else{
			spinePlayer.alpha = 1;
		}
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
		ss.setAllowEsc(false);
		//this.desactivarListeners();	
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
		}
	
	}
	
	function eventos():Void {
		
		movimientos();
		
		if (FlxG.keys.justPressed.P) {
			var ps:PlayState = cast(Globales.currentState, PlayState);
			var ss:PlaySubState = ps.getSubPlayState(FlxColor.WHITE);
			ss.setAllowEsc(true);
			
			ps.openSubState( ss );
			ss.setPos(new FlxPoint(FlxG.camera.scroll.x + 300, FlxG.camera.scroll.y + 300));
			//Globales.currentState.openSubState(new PlaySubState("Pausa", new FlxPoint(getMidpoint().x - width * 0.5, getMidpoint().y - height)));
		}
		
		if (FlxG.keys.justPressed.U) {
			startAnimation.setPosition(bodyInferior.bounds.x + 75, bodyInferior.bounds.y -75);
			startAnimation.animation.play("startAnimation",  false );
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

					}else {
						CambiarEstado(estadoMOVIENDOENELAIRE);
						ChangeAnimation("estadoMOVIENDOENELAIRE", null);
					}

			case estadoSALTANDO: 
					if (tierraFirme) {
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);
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
			case estadoAGARRADO: /* Cuando termina de subir plataforma cambia a estado QUIETO?*/
					manejoAgarres();						
			default: 
		}
	}
	
	function subirPlataforma():Void {

		// para que no se pase cuando sube el punto de agarre
		var offsetTopeY = 10;
		var vel:Int = 120;
		var velImpulse:Float = 200;
						
		bodyInferior.allowMovement = true;
		subiendoPlataforma = true;
		
		FlxNapeSpace.space.listeners.remove(PersonajeConAgarre);
		
		if  (bodyInferior.bounds.y > topeY ) {
			bodyInferior.applyImpulse(new Vec2(0, -vel));
		}else {
			bodyInferior.velocity.y = 0;
			
			if (tocaPlataformaIzq) {
				if (bodyInferior.bounds.x+bodyInferior.bounds.width < topeX) {
					bodyInferior.applyImpulse(new Vec2(vel, 0));
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
			}else {
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
			}
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
		if (bodyInferior.position.y - bodyInferior.bounds.height*0.5 > FlxG.camera.maxScrollY) {
			playerDead("caida");
		}		
	}
	
	function activarListeners():Void 	{
		FlxNapeSpace.space.listeners.add(PersonajePrePiso);
		FlxNapeSpace.space.listeners.add(PersonajeConObjetoInteractivoEnd);
		FlxNapeSpace.space.listeners.add(PersonajeConObjetoInteractivo);
		FlxNapeSpace.space.listeners.add(PersonajeConPlataforma);		
		FlxNapeSpace.space.listeners.add(PersonajeConPlataformaEnd);	
		FlxNapeSpace.space.listeners.add(PersonajeConAgarre);
	}
	
	function desactivarListeners():Void {
		FlxNapeSpace.space.listeners.remove(PersonajePrePiso);
		FlxNapeSpace.space.listeners.remove(PersonajeConObjetoInteractivoEnd);
		FlxNapeSpace.space.listeners.remove(PersonajeConObjetoInteractivo);
		FlxNapeSpace.space.listeners.remove(PersonajeConPlataforma);		
		FlxNapeSpace.space.listeners.remove(PersonajeConPlataformaEnd);	
		FlxNapeSpace.space.listeners.remove(PersonajeConAgarre);
	}
	
	override public function draw():Void {
		
		super.draw();
		
		if (colisionaConObjetoInteractivo) {
			textObjInteractivo.draw();
		}
	}
	
	override public function destroy():Void{
		super.destroy();
	}
	
	public function setFixedVelocity(v:Float):Void {
		fixedY = v;	
	}
	
	public function setFixedPositionY(pos:Float):Void {
		fixedPositionY = pos;	
	}
	
	public function setPlayerOnPlataform():Void {
		plataformaVertical = true;
	}
	
	public function setPlayerOffPlataform():Void {
		plataformaVertical = false;
	}
	
	public function playerPesoNormal():Void {
		bodyInferior.shapes.at(0).material = new Material(0, 0.57, 0.74, 7.5, 0.001);//Material.steel();
	}
	
	public function starCollected() {
		starsCollected++;
	}
	
}