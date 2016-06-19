package ;
import flixel.addons.nape.FlxNapeSpace;
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
		
		var agarre:Bool;
		var trepar:Bool;
	
		var tocaPlataformaIzq:Bool;	
		var topeY:Float;
		var topeX:Float;
		var agarrePos:Vec2;
		
		var sprite:FlxSprite = null;
		var spinePlayer:SpinePlayer=null;
	
		
		var bodyInferiorCallback:CbType = new CbType();
		var subiendoPlataforma:Bool ;
		
		private static inline var maxJumpVelX:Int = 100;
		private static inline var maxVelX:Int = 285;
		private static inline var jumpForce:Int = 2850;//ESTO
		
		var text :FlxText = null;
		var textObjInteractivo:FlxText = null;
		var lastVelX:Float;
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
		
		var fixedY:Float;
		var normalUltimaColision:Vec2 = new Vec2(0,0);

	public function new(_x:Float, _y:Float, space : Space ) {
		
		super(_x,_y,35,35);
			
		text = new FlxText(200, this.x, this.y, "No Name Game");
		text.setFormat(AssetPaths.font_kreon, 18, FlxColor.BLACK, "left");
		//text.addFormat(new FlxTextFormat(0xE6E600, false, false, 0xFF8000));	
		Globales.currentState.add(text);	
				
		textoColisionAcum = 0;
		textoColisionOn = false;
		
		currentState = estadoSALTANDO;
		
		agarrePos = new Vec2(0,0);
		
		currentSpace = space;
		
		var pos:Vec2 = new Vec2(_x,_y);

		createBodyInferior(pos);
		
		frenando = false;
		
		tierraFirme = false;
						
		declararCallbacks();
		
		pos.dispose();
		
		bodyInferior.userData.object = this;

		subiendoPlataforma = false;
		
		colisionaConObjetoInteractivo = false;
		
		crearAnimacionSpine();
		//crearAnimacion();
		
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
				AnimacionMiraDerecha(flipX);
			}
			if (name == "estadoSUBIENDOPLATAFORMA") {
				spinePlayer.setAnimation(name,false);	
			}
			spinePlayer.setAnimation(name,true);
		}
		
		if (sprite!= null) {
			if (flipX != null) {
				AnimacionMiraDerecha(flipX);
			}
			sprite.animation.play(name,true);
		}
		
		
	}
	
	function AnimacionMiraDerecha(_flipX:Bool) {

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
				
				var bodyPlataforma:Body = e.int2.castBody;		
				
				FlxG.log.add("Toca agarre");
				
				if (!agarre) {	
					 if (bodyInferior.bounds.y < (bodyPlataforma.bounds.y + bodyPlataforma.bounds.height * 0.1)) {
						 if (bodyPlataforma.userData.nombre != null) {
							 var puedeseguir:Bool = Math.abs(bodyInferior.velocity.x) != 0 ? true : false;
							 if (puedeseguir) {
								 if (bodyInferior.velocity.x>0) {
									tocaPlataformaIzq = true;
								 }else {
									tocaPlataformaIzq = false; 
								 }								 
							 }else {
								return; 
							 }
							 
							 if (bodyPlataforma.userData.nombre == "rectAgarreIzq" && Math.abs(bodyInferior.velocity.x)!=0) {
								//AGARRE IZQUIERDO DE PERSONAJE		
								agarre = true;
								CambiarEstado(estadoAGARRADO);
								lastVelX = bodyInferior.velocity.x;
							
								agarrePos = new Vec2(bodyPlataforma.bounds.x-bodyInferior.bounds.width, bodyPlataforma.bounds.y + bodyPlataforma.bounds.height*0.5);
								bodyInferior.position.set(agarrePos);
							
								topeX = bodyInferior.bounds.x + bodyInferior.bounds.width*2;
								topeY = bodyPlataforma.bounds.y - bodyInferior.bounds.height*1.0001; //- bodyInferior.bounds.height;
							
								bodyInferior.velocity.x = bodyInferior.velocity.y = 0; 
								
							 }else if (bodyPlataforma.userData.nombre == "rectAgarreDer" && Math.abs(bodyInferior.velocity.x)!=0) {
								// AGARRE DERECHO DE PERSONAJE
								agarre = true;
								CambiarEstado(estadoAGARRADO);
								lastVelX = bodyInferior.velocity.x;
								
								agarrePos = new Vec2(bodyPlataforma.bounds.x , bodyPlataforma.bounds.y  );
								
								topeX = bodyInferior.bounds.x - bodyInferior.bounds.width;
								
								bodyInferior.position.set(agarrePos);
								
								topeY = bodyPlataforma.bounds.y - bodyInferior.bounds.height*1.0001;// * 1.03; //- bodyInferior.bounds.height;
								
								bodyInferior.velocity.x = bodyInferior.velocity.y = 0;
							 }			 
							 
						 }
					}
				}
			}
		);
		
		PersonajeConAgarreEnd = new InteractionListener(
			CbEvent.END, InteractionType.SENSOR, Callbacks.bodyInferiorCallback, Callbacks.agarreCallback,
			function OnPersonajeConAgarreEnd(e:InteractionCallback):Void {
				agarre = false;
			}		
		);	
	
		PersonajeConPlataforma = new InteractionListener(
			CbEvent.BEGIN, InteractionType.COLLISION, Callbacks.bodyInferiorCallback, Callbacks.plataformaCallback,
			function OnPersonajeConPlataformaCollision(e:InteractionCallback):Void {
			
				/*normal de la interaccion actual*/
				normalUltimaColision = e.arbiters.at(0).collisionArbiter.referenceEdge1.localNormal;
				//var normalTemp:Vec2 = e.arbiters.at(0).collisionArbiter.referenceEdge1.localNormal;
				
				var bodys:BodyList = new BodyList();
				bodyInferior.interactingBodies(InteractionType.COLLISION, 2, bodys);
				
				if(bodys.length == 1){//Si el jugador colisiona con una plataforma, se actualiza la normal de colision
					if(normalUltimaColision.y == -1){
						tierraFirme = true;
					}
				}
				else if (bodys.length == 2){//Si el jugador colisiona con dos plataformas a la vez
					if ((Math.abs(normalUltimaColision.x) == 1) && (bodyInferior.velocity.y == 0)){//Se actualiza la normal de colision solo si la anterior normal no fue el piso
						tierraFirme = true;
					}
					else if (normalUltimaColision.y == -1){//Se actualiza la normal de colision solo si la anterior normal no fue el piso
						tierraFirme = true;
					}
				}
				/*if(bodys.length == 1){//Si el jugador colisiona con una plataforma, se actualiza la normal de colision
					normalUltimaColision = normalTemp;
				}
				else if (bodys.length == 2){//Si el jugador colisiona con dos plataformas a la vez
					if(normalUltimaColision.y != -1){//Se actualiza la normal de colision solo si la anterior normal no fue el piso
						normalUltimaColision = normalTemp;
					}
				}
				
				if(normalUltimaColision.y <= -1){//Si la normal de colision es (0,-1) se esta en tierra firme
					tierraFirme = true;
				}*/
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
					if ((Math.abs(normalUltimaColision.x) == 1) && (bodyInferior.velocity.y != 0)){


						tierraFirme = false;
					}
					else if ((normalUltimaColision.y == -1) && (bodyInferior.velocity.y != 0)){
						tierraFirme = false;
					}
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
							textObjInteractivo = new FlxText(this.x, this.y - FlxG.height * 0.30, 150, "Presiona E para activar objeto", 16, false);
							textObjInteractivo.setFormat(AssetPaths.font_kreon, textObjInteractivo.size, FlxColor.GREEN, "center");
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
		FlxG.log.add("Velocity y : " + bodyInferior.velocity.y );
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
		
		if (FlxG.keys.justReleased.H) {
			spinePlayer.visible = !spinePlayer.visible;
		}
		
		eventos();
		
		checkInWorld();
	}	
	
	function textosEnPantalla() :Void	{

		text.setPosition(FlxG.camera.scroll.x+5, FlxG.camera.scroll.y );
		
		if (textoColisionOn) {
			text.text = 
			"\nPLAYER: "  +
			"\n" + cast(this.getMidpoint().x, Int) +"," + cast(this.getMidpoint().y, Int) + 			
			"\nVELX: " + Std.int(bodyInferior.velocity.x) +
			"\nVELY: " + Std.int(bodyInferior.velocity.y) +
			"\ntierraFirme: " + tierraFirme +
			"\nSubiendoPlataforma: " + subiendoPlataforma +
			"\nNORMALCOLISION: (" + normalUltimaColision.x + ","  + normalUltimaColision.y + ")" +
			"\nESTADO: " + estado.toUpperCase();
			
			
			if (textoColisionAcum < textoColisionTime) {
				textoColisionAcum += FlxG.elapsed;
			}else {
				textoColisionAcum = 0;
				textoColisionOn = false;
			}			
		}else {
			text.text = 
			"\nPLAYER: "  +
			"\n" + cast(this.getMidpoint().x, Int) +"," + cast(this.getMidpoint().y, Int) + 	
			"\nVELX: " + Std.int(bodyInferior.velocity.x) +
			"\nVELY: " + Std.int(bodyInferior.velocity.y) +
			"\ntierraFirme: " + tierraFirme +
			"\nSubiendoPlataforma: " + subiendoPlataforma +
			"\nNORMALCOLISION: (" + normalUltimaColision.x + ","  + normalUltimaColision.y + ")" +
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
			case estadoONPLATAFORMAVERTICAL: estado = "estadoOnPlataformaVertical";
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
		
		if (FlxG.keys.justPressed.T) {
			if (spinePlayer != null) {
				spinePlayer.visible = !spinePlayer.visible;
			}
		}
		
		if (FlxG.keys.justPressed.E && colisionaConObjetoInteractivo) {
			activarObjetoInteractivo();
		}
	}
	
	function subirPlataforma():Void {

		// para que no se pase cuando sube el punto de agarre
		var offsetTopeY = 10;
		var vel:Int = 120;
		var velImpulse:Float = 200;
				
		/*//FlxG.log.add("body inf : " + bodyInferior.bounds.y);
		//FlxG.log.add("tope y : " + topeY );*/
		
		bodyInferior.allowMovement = true;
		
		subiendoPlataforma = true;
		
		FlxNapeSpace.space.listeners.remove(PersonajeConAgarre);
		
		//FlxG.log.add("TopeY" + topeY);
		//FlxG.log.add("Player Y" + bodyInferior.bounds.y);
		
		if  (bodyInferior.bounds.y > topeY ) {
			bodyInferior.applyImpulse(new Vec2(0, -vel));
			//bodyInferior.position.y = bodyInferior.position.y - (vel * FlxG.elapsed);
		}else {
			bodyInferior.velocity.y = 0;
			//bodyInferior.applyImpulse(new Vec2(0, -10));
			// ya subio en Y ahora que se acomode en X
			
			//FlxG.log.add("bodyInferior x: " + bodyInferior.bounds.x);*/
			if (tocaPlataformaIzq) {
				FlxG.log.add("Izquierda: " + tocaPlataformaIzq);
				// plataforma a la IZQUIERDA
				if (bodyInferior.bounds.x+bodyInferior.bounds.width < topeX) {
					FlxG.log.add("suma impulso");
					bodyInferior.applyImpulse(new Vec2(vel, 0));
				}else {
					FlxG.log.add("llega a tope x");
					subiendoPlataforma = false;
					trepar = false;
					bodyInferior.velocity.x = bodyInferior.velocity.x * .05;
					
					FlxNapeSpace.space.listeners.add(PersonajeConAgarre);
					ChangeAnimation("estadoQUIETO",null);
					CambiarEstado(estadoQUIETO);
					FlxNapeSpace.space.gravity = new Vec2(Globales.gravityX, Globales.gravityY);
				}
			}else {
				FlxG.log.add("Izquierda: " + tocaPlataformaIzq);
				// plataforma a la DERECHA
				if (bodyInferior.bounds.x > topeX) {
					bodyInferior.applyImpulse(new Vec2(-vel, 0));
				}else {
					subiendoPlataforma = false;
					trepar = false;
					bodyInferior.velocity.x = bodyInferior.velocity.x * .05;
					FlxNapeSpace.space.listeners.add(PersonajeConAgarre);
					ChangeAnimation("estadoQUIETO",null);
					CambiarEstado(estadoQUIETO);
					FlxNapeSpace.space.gravity = new Vec2(Globales.gravityX, Globales.gravityY);
				}
			}	
		}
	
	}
		
	function movimientos():Void {
		
		switch(currentState) {
			
			case estadoQUIETO: 
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
						ChangeAnimation("estadoCORRIENDO", true);
						CambiarEstado(estadoCORRIENDO);
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)	{
						ChangeAnimation("estadoCORRIENDO", false);
						CambiarEstado(estadoCORRIENDO);
					}else if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)	{
						Saltar();
					}
					
					if (!tierraFirme) {
						ChangeAnimation("estadoSALTANDO");
						CambiarEstado(estadoSALTANDO);	
						return;
					}
					
			case estadoCORRIENDO: 
					if (tierraFirme) {
						if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
							AnimacionMiraDerecha(true);
							bodyInferior.velocity.x = -maxVelX;
						}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)	{
							AnimacionMiraDerecha(false);
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
							CambiarEstado(estadoSALTANDOYCORRIENDO);
						}					
						if (FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN)	{
							ChangeAnimation("estadoQUIETO", false);
							CambiarEstado(estadoFRENANDO);							
						}	
					}else {
						ChangeAnimation("estadoMOVIENDOENELAIRE", null);
						//CAMBIO
						//CambiarEstado(estadoSALTANDOYCORRIENDO);
						CambiarEstado(estadoMOVIENDOENELAIRE);
						//CAMBIO
					}

			case estadoSALTANDO: 
					if (tierraFirme) {
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);
						return;
					}
					
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
						AnimacionMiraDerecha(true);
						CambiarEstado(estadoMOVIENDOENELAIRE);
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)	{
						AnimacionMiraDerecha(false);
						CambiarEstado(estadoMOVIENDOENELAIRE);
					}	
					
			case estadoMOVIENDOENELAIRE:
					if (tierraFirme) {
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);
						return;
					}
					
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
						AnimacionMiraDerecha(true);
						if (bodyInferior.velocity.x > -maxVelX) {
							bodyInferior.applyImpulse(new Vec2(-70, 0));
						}
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)	{
						AnimacionMiraDerecha(false);
						if (bodyInferior.velocity.x < maxVelX) {
							bodyInferior.applyImpulse(new Vec2(70, 0));
						}
					}		
					//CAMBIO
					else{bodyInferior.velocity.x = 0; }
					//CAMBIO	
					
			case estadoSALTANDOYCORRIENDO: 
					if (tierraFirme) {
						ChangeAnimation("estadoQUIETO", false);
						CambiarEstado(estadoQUIETO);
						return;
					}
					
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
						AnimacionMiraDerecha(true);
						//ChangeAnimation("estadoSALTANDO", true);
						CambiarEstado(estadoMOVIENDOENELAIRE);								
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
						AnimacionMiraDerecha(false);
						//ChangeAnimation("estadoSALTANDO", false);
						CambiarEstado(estadoMOVIENDOENELAIRE);								
					}
					
			case estadoFRENANDO:
					if (bodyInferior.velocity.x < 0.5 && bodyInferior.velocity.x > -0.5) {
						ChangeAnimation("estadoQUIETO", null);
						CambiarEstado(estadoQUIETO);		
					}else {
						bodyInferior.velocity.x = bodyInferior.velocity.x * 0.2;	
					}	
					
			case estadoAGARRADO: 
					manejoAgarres();						
					/* Cuando termina de subir plataforma cambia a estado CORRIENDO*/		
			case estadoONPLATAFORMAVERTICAL:
					
				//CAMBIO 31-05
				if (tierraFirme){/*Si esta encima de la plataforma*/
						
					bodyInferior.velocity.y = fixedY;
					
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
							ChangeAnimation("estadoCORRIENDO", true);
							bodyInferior.velocity.x = -maxVelX;							
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
							ChangeAnimation("estadoCORRIENDO", false);	
							bodyInferior.velocity.x = maxVelX;											
					}
					else{bodyInferior.velocity.x = 0;}
					
					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
						bodyInferior.velocity.y = 0;
						Saltar(1.5);
						ChangeAnimation("estadoSALTANDO", false);
						CambiarEstado(estadoSALTANDOYCORRIENDO);
					}		
				}
				else if (colisionCostadoPlataforma && (bodyInferior.velocity.y == 0)){/*Si no esta encima de la plataforma, pero la toca de costado y esta sobre otra plataforma*/
					
					if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
							ChangeAnimation("estadoCORRIENDO", true);
							CambiarEstado(estadoCORRIENDO);
							//bodyInferior.velocity.x = -maxVelX;							
					}else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
							ChangeAnimation("estadoCORRIENDO", false);	
							CambiarEstado(estadoCORRIENDO);
							//bodyInferior.velocity.x = maxVelX;											
					}
					else{bodyInferior.velocity.x = 0;}
					
					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP) {
						bodyInferior.velocity.y = 0;
						Saltar(1.5);
						ChangeAnimation("estadoSALTANDO", false);
						CambiarEstado(estadoSALTANDOYCORRIENDO);
					}		
				}
				//else if (colisionCostadoPlataforma){CambiarEstado(estadoMOVIENDOENELAIRE);}
				//CAMBIO 31-05
			default: 

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
					AnimacionMiraDerecha(!tocaPlataformaIzq);					
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
		//FlxG.log.add("Body y: "+ (bodyInferior.position.y - bodyInferior.bounds.height * 0.5) );
		//FlxG.log.add("Camera heigth: " +  FlxG.camera.setScrollBounds);
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
		
		if (currentState != estadoSALTANDO) {
			fixedY = v;	
		}
	}
	
	public function setPlayerOnPlataform():Void {
		CambiarEstado(estadoONPLATAFORMAVERTICAL);
		ChangeAnimation("estadoQUIETO", null);
	}
	
	public function setPlayerOffPlataform():Void {
		/*if (currentState == estadoONPLATAFORMAVERTICAL && Math.abs(this.bodyInferior.velocity.x) > 10) {
			CambiarEstado(estadoMOVIENDOENELAIRE);	
		}*/
		
		CambiarEstado(estadoQUIETO);	
	}
	
	public function playerPesoNormal():Void {
		FlxG.log.add("cambiaPesoANormal");
		bodyInferior.shapes.at(0).material = new Material(0, 0.57, 0.74, 7.5, 0.001);//Material.steel();
	}
	
	override public function destroy():Void {
		
		super.destroy();
		
	}
	
}