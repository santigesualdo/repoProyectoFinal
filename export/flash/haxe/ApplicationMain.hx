#if !macro


@:access(lime.app.Application)
@:access(lime.Assets)
@:access(openfl.display.Stage)


class ApplicationMain {
	
	
	public static var config:lime.app.Config;
	public static var preloader:openfl.display.Preloader;
	
	
	public static function create ():Void {
		
		var app = new openfl.display.Application ();
		app.create (config);
		
		var display = new flixel.system.FlxPreloader ();
		
		preloader = new openfl.display.Preloader (display);
		app.setPreloader (preloader);
		preloader.onComplete.add (init);
		preloader.create (config);
		
		#if (js && html5)
		var urls = [];
		var types = [];
		
		
		urls.push ("Kreon Regular");
		types.push (lime.Assets.AssetType.FONT);
		
		
		urls.push ("assets/images/Botones/botonArmaLinearMagnet.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaLinearMagnetOn.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaMagnet.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaMagnetNo.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaMagnetOn.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaNormal.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaNormalOn.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaNoWeapon.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaNoWeaponNo.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/botonArmaNoWeaponOn.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/menuButtonOut.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/menuButtonOver.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/pausa_checkPoint_out.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/pausa_checkPoint_over.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/pausa_salir_out.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/pausa_salir_over.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/restartLevel_out.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/restartLevel_over.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/Botones/trailArea.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/bullet_test.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/level1_capas.psd");
		types.push (lime.Assets.AssetType.BINARY);
		
		
		urls.push ("assets/images/magnet-vector-illustration-1774151.jpg");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/magnet.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/mapa_tutorial_prueba.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/menuBackground.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/mira.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/ollapeso.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/playerSpriteSheet.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/stickman-anim.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/images/wolverine_sprites.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/levels/level0.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/level0_.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/level0_background.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/levels/level0_haxenuevo.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/level2.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/level3.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/test.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/test2.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/test3.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/test4.tmx");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/levels/tileset.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/playerMagnet/playerMagnet.atlas");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/playerMagnet/playerMagnet.json");
		types.push (lime.Assets.AssetType.TEXT);
		
		
		urls.push ("assets/playerMagnet/playerMagnet.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		urls.push ("assets/playerMagnet/playerMagnet.skel");
		types.push (lime.Assets.AssetType.BINARY);
		
		
		urls.push ("flixel/sounds/beep.mp3");
		types.push (lime.Assets.AssetType.MUSIC);
		
		
		urls.push ("flixel/sounds/flixel.mp3");
		types.push (lime.Assets.AssetType.MUSIC);
		
		
		urls.push ("Nokia Cellphone FC Small");
		types.push (lime.Assets.AssetType.FONT);
		
		
		urls.push ("Monsterrat");
		types.push (lime.Assets.AssetType.FONT);
		
		
		urls.push ("flixel/images/ui/button.png");
		types.push (lime.Assets.AssetType.IMAGE);
		
		
		
		if (config.assetsPrefix != null) {
			
			for (i in 0...urls.length) {
				
				if (types[i] != lime.Assets.AssetType.FONT) {
					
					urls[i] = config.assetsPrefix + urls[i];
					
				}
				
			}
			
		}
		
		preloader.load (urls, types);
		#end
		
		var result = app.exec ();
		
		#if (sys && !nodejs && !emscripten)
		Sys.exit (result);
		#end
		
	}
	
	
	public static function init ():Void {
		
		var loaded = 0;
		var total = 0;
		var library_onLoad = function (__) {
			
			loaded++;
			
			if (loaded == total) {
				
				start ();
				
			}
			
		}
		
		preloader = null;
		
		
		
		
		if (total == 0) {
			
			start ();
			
		}
		
	}
	
	
	public static function main () {
		
		config = {
			
			build: "291",
			company: "HaxeFlixel",
			file: "tiledNape",
			fps: 60,
			name: "tiledNape",
			orientation: "portrait",
			packageName: "com.example.myapp",
			version: "0.0.1",
			windows: [
				
				{
					antialiasing: 0,
					background: 0,
					borderless: false,
					depthBuffer: false,
					display: 0,
					fullscreen: false,
					hardware: true,
					height: 600,
					parameters: "{}",
					resizable: true,
					stencilBuffer: true,
					title: "tiledNape",
					vsync: true,
					width: 800,
					x: null,
					y: null
				},
			]
			
		};
		
		#if hxtelemetry
		var telemetry = new hxtelemetry.HxTelemetry.Config ();
		telemetry.allocations = true;
		telemetry.host = "localhost";
		telemetry.app_name = config.name;
		Reflect.setField (config, "telemetry", telemetry);
		#end
		
		#if (js && html5)
		#if (munit || utest)
		openfl.Lib.embed (null, 800, 600, "000000");
		#end
		#else
		create ();
		#end
		
	}
	
	
	public static function start ():Void {
		
		var hasMain = false;
		var entryPoint = Type.resolveClass ("Main");
		
		for (methodName in Type.getClassFields (entryPoint)) {
			
			if (methodName == "main") {
				
				hasMain = true;
				break;
				
			}
			
		}
		
		lime.Assets.initialize ();
		
		if (hasMain) {
			
			Reflect.callMethod (entryPoint, Reflect.field (entryPoint, "main"), []);
			
		} else {
			
			var instance:DocumentClass = Type.createInstance (DocumentClass, []);
			
			/*if (Std.is (instance, openfl.display.DisplayObject)) {
				
				openfl.Lib.current.addChild (cast instance);
				
			}*/
			
		}
		
		#if !flash
		if (openfl.Lib.current.stage.window.fullscreen) {
			
			openfl.Lib.current.stage.dispatchEvent (new openfl.events.FullScreenEvent (openfl.events.FullScreenEvent.FULL_SCREEN, false, false, true, true));
			
		}
		
		openfl.Lib.current.stage.dispatchEvent (new openfl.events.Event (openfl.events.Event.RESIZE, false, false));
		#end
		
	}
	
	
	#if neko
	@:noCompletion @:dox(hide) public static function __init__ () {
		
		var loader = new neko.vm.Loader (untyped $loader);
		loader.addPath (haxe.io.Path.directory (Sys.executablePath ()));
		loader.addPath ("./");
		loader.addPath ("@executable_path/");
		
	}
	#end
	
	
}


@:build(DocumentClass.build())
@:keep class DocumentClass extends Main {}


#else


import haxe.macro.Context;
import haxe.macro.Expr;


class DocumentClass {
	
	
	macro public static function build ():Array<Field> {
		
		var classType = Context.getLocalClass ().get ();
		var searchTypes = classType;
		
		while (searchTypes.superClass != null) {
			
			if (searchTypes.pack.length == 2 && searchTypes.pack[1] == "display" && searchTypes.name == "DisplayObject") {
				
				var fields = Context.getBuildFields ();
				
				var method = macro {
					
					openfl.Lib.current.addChild (this);
					super ();
					dispatchEvent (new openfl.events.Event (openfl.events.Event.ADDED_TO_STAGE, false, false));
					
				}
				
				fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: [], expr: method, params: [], ret: macro :Void }), pos: Context.currentPos () });
				
				return fields;
				
			}
			
			searchTypes = searchTypes.superClass.t.get ();
			
		}
		
		return null;
		
	}
	
	
}


#end
