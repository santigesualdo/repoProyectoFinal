package utils;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import haxe.io.Path;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import states.PlayState;
import utils.enemigos.BombaMagnet;
import utils.enemigos.RuedaSerrada;
import utils.enemigos.RuedaSerradaConMovimientoHorizontal;
import utils.enemigos.RuedaSerradaConMovimientoVertical;
import utils.enemigos.TiraBomba;
import utils.objetos.CheckPoint;
import utils.objetos.CheckPointSensor;
import utils.objetos.PincheViejo;
import utils.objetos.Estrella;
import utils.objetos.FinLevel;
import utils.objetos.MagnetOnOff;
import utils.objetos.OllaPeso;
import utils.objetos.Palanca;
import utils.objetos.Pinches;
import utils.objetos.Plataforma;
import utils.objetos.PlataformaConMovientoVertical;
import utils.objetos.PlataformaConMovimientoHorizontal;
import utils.objetos.SwitchOnOff;
import utils.objetos.SwitchOnOffByInterruptor;
import utils.objetos.SwitchOnOffByTime;
import utils.objetos.SwitchOnOffByTouch;
import utils.objetos.TextoTutorial;


class TiledLevel extends TiledMap
{
	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/levels/";
	
	var actualBodyType:BodyType;
	
	public var foregroundTiles:FlxGroup;
	public var objectsLayer:FlxGroup;
	public var backgroundLayer:FlxGroup;
	public var estrellasGroup:FlxGroup;
	public var backDropPath:String;
	private var collidableTileLayers:Array<FlxTilemap>;	
	
	private static var estrellasCargadas:Bool = false;
	
	public var imagesLayer:FlxGroup;
	
	public function new(tiledLevel:Dynamic, state:PlayState):Void	{
		super(tiledLevel);
		imagesLayer = new FlxGroup();
		foregroundTiles = new FlxGroup();
		objectsLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		estrellasGroup = new FlxGroup();
		
		FlxG.worldBounds.set(0, 0, fullWidth, fullHeight);
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		loadImages();
		
		var tileSize = this.tileWidth;
		var mapH = this.height;
		var mapW = this.width;
		
		// Load Tile Maps
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			
			var layerData:Array<Int> = tileLayer.tileArray;
			var tilesheetName:String = layer.properties.get("tilesheet");
            var tilesheetPath:String = "assets/levels/" + tilesheetName;
			
			// Finally, create the FlxTilemap and get ready to render the map.
            var level:FlxTilemap = new FlxTilemap();

            // If we're passing an array of data, the level needs to know
            // how many columns of data to read before it moves to a new row,
            // as noted in the API page:
            // http://api.haxeflixel.com/flixel/tile/FlxTilemap.html#loadMap
            /*level.widthInTiles = mapW;
            level.heightInTiles = mapH;*/

            // Note: The tilesheet indices are continuous! This means,
            // if there is more than one tilesheet, the 2nd tilesheet's
            // starting index right after the 1st tilesheet's last index.
            // e.g.
            // - tilesheet 1 has 100 tiles (index = 1-100)
            // - tilesheet 2 has 100 tiles (index = 101-200 instead of 1-100)
            //
            // Note2: that the gid "0" is reserved for empty tiles
            var tileGID:Int = getStartGid(this, tilesheetName);

            // Render the map.
            // Note: the StartingIndex is based on the tilesheet's
            // startingGID rather than the default 1.
            level.loadMapFromArray(tileLayer.tileArray, mapW, mapH, tilesheetPath, tileSize, tileSize, null, tileGID);
            level.alpha = 1;
			//add(level);
			
			loadObjects(state);
			
			foregroundTiles.add(level);
			
			
		}
	}
	
	public function loadObjects(state:PlayState){
		var layer:TiledObjectLayer;
		
		var layersPermitted : Array<String> = ["fondoBottom", "fondoMiddle", "fondoTop", "fondoDeco3","fondoDeco2","fondoDeco1"];
		
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			//collection of images layer
			for ( l in layersPermitted ){
				if (l == layer.name){
					for (o in objectLayer.objects)
					{
						FlxG.log.add("layer name: " + layer.name);
						loadImageObject(o);
					}
				}
			}
			
			//objects layer
			if (layer.name == "entities")
			{
				for (o in objectLayer.objects)
				{
					loadObject(state, o, objectLayer, objectsLayer);
				}
				//cargarEstrellas();
				cargarCheckPoints();	
			}
		}
	}
	
	function cargarEstrellas():Void	{
		if (!estrellasCargadas) {
			estrellasCargadas = true;			
		}
		
	}
	
	private function loadImageObject(object:TiledObject){
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
		var tileImagesSource:TiledImageTile = tilesImageCollection.getImageSourceByGid(object.gid);
		
		//decorative sprites
		var levelsDir:String = "assets/levels/";
		
		var decoSprite:FlxSprite = new FlxSprite(0, 0, levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width
		|| decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}
		
		var depthX:Float = 0;
		var depthY:Float = 0;
	
		if (object.properties.contains("depthX"))
		{
			depthX = Std.parseFloat( object.properties.get("depthX"));
		}

		if (object.properties.contains("depthY"))
		{
			depthY = Std.parseFloat( object.properties.get("depthY"));
		}		
		
		if (depthX != 0 && depthY != 0)
			decoSprite.scrollFactor.set(depthX,depthY);

		backgroundLayer.add(decoSprite);
	}
	
	private function loadObject(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup)	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;
			
		if  (o.properties.contains("bodyType")) {
			if (o.properties.get("bodyType") == "dynamic") { actualBodyType = BodyType.DYNAMIC; } else 
			if (o.properties.get("bodyType") == "kinematic") { actualBodyType = BodyType.KINEMATIC; } else
			if (o.properties.get("bodyType") == "static") {	actualBodyType = BodyType.STATIC;}
		}			
			
		switch(o.objectType)
			{	
				case TiledObject.POLYGON:
					crearObjetoPoligonal(state,o,g,objectsLayer);
				case TiledObject.POLYLINE:
					crearObjetoPolilinea(state,o,g,objectsLayer);							
				case TiledObject.RECTANGLE:
					crearObjectoRectangular(state,o,g,objectsLayer);
				case TiledObject.ELLIPSE:
					crearObjetoElipse(state,o,g,objectsLayer);
			}
	}

	public function loadImages():Void{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;				
			if (image.name == "backdrop") {
				backDropPath = c_PATH_LEVEL_TILESHEETS + image.imagePath;
				continue;
			}
			
			/*var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);*/
		}
	}
		
	function crearObjetoPolilinea(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup) {
		
		/* Tienen en comun que no tienen body, predeterminado, sino mas bien es un punto .*/
		
		// Solo llenamos el grupo Checkpoint una vez, es decir, si reiniciamos el nivel, no hace falta nuevos checkpoints.
		if (!Globales.checkPointCargados && o.properties.contains("checkPoint")) {
			var id:String = o.properties.get("checkPoint");
			var cp:CheckPoint = new CheckPoint(id, o.x, o.y);
			Globales.checkPointGroup.add(cp);				
		}
		
		if (o.name == "finLevel") {
			
			var activo:Bool = true;
			if (o.properties.contains("activo")) {
				activo = o.properties.get("activo") == "1";
			}
			var id:String = o.xmlData.att.resolve("id");
			group.add(new FinLevel(new FlxPoint(o.x, o.y), activo, id));			
		}
	}
	
	function getStartGid(tiledLevel:TiledMap, tilesheetName:String) {
		// This function gets the starting GID of a tilesheet

        // Note: "0" is empty tile, so default to a non-empty "1" value.
        var tileGID:Int = 1;

        for (tileset in tiledLevel.tilesets)
        {
            // We need to search the tileset's firstGID -- to do that,
            // we compare the tilesheet paths. If it matches, we
            // extract the firstGID value.
            var tilesheetPath:Path = new Path(tileset.imageSource);
            var thisTilesheetName = tilesheetPath.file + "." + tilesheetPath.ext;
            if (thisTilesheetName == tilesheetName)
            {
                tileGID = tileset.firstGID;
            }
        }

        return tileGID;
	}	
	
	function crearObjetoElipse(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup):Void	{
		
		var shapeCircular:Circle = new Circle(o.width * 0.5);
		
		var bodyCircular:Body = new Body(actualBodyType, new Vec2(o.x , o.y)); //new Vec2(o.x + o.width*.5, o.y+o.height*.5));	
		bodyCircular.shapes.add(shapeCircular);
		bodyCircular.space = FlxNapeSpace.space;	
		
		bodyCircular.userData.id = o.xmlData.att.resolve("id");
		bodyCircular.userData.radius = cast(o.width, Float);

		if (o.properties.contains("magnet")) {
			bodyCircular.userData.magnet = true;
		}
		
		// Asignamos userData desde Tiled
		if  (o.properties.contains("userDataBody")) {
			bodyCircular.userData.nombre = o.properties.get("userDataBody");
		}
		
		if (o.properties.contains("userDataShape")) {
			shapeCircular.userData.nombre = o.properties.get("userDataShape");
		}
		
		if (o.properties.contains("material")) {
			bodyCircular.setShapeMaterials( getMaterial(o.properties.get("material")));
		}
		
		if (o.properties.contains("puedeRotar")) {
			bodyCircular.allowRotation = o.properties.get("puedeRotar") == "1";			
		}
		
		if (o.name == "bola") {
			bodyCircular.userData.sentidoX = Std.parseInt(cast(o.properties.get("sentidoX"), String));

			if (o.properties.contains("infinita")) {
				bodyCircular.userData.infinita = o.properties.get("infinita") == "0";		
			}
			
			bodyCircular.allowMovement = o.properties.get("estatico") == "0";	
			if (o.properties.contains("sentidoFuerza")) {
				bodyCircular.userData.sentidoFuerza = Std.parseInt(cast(o.properties.get("sentidoFuerza"), String));	
			}
			bodyCircular.userData.destroyOnTouch = cast(o.properties.get("destroyOnTouch"), String);
			group.add(new BombaMagnet(o.x,o.y,bodyCircular));
		}	
		else if (o.name == "ruedaSerradaConMovimientoHorizontal") {
			
			var sentidoInicial:Int = Std.parseInt(cast(o.properties.get("sentidoInicial"), String));
			var posFinalX:Float =  Std.parseFloat(cast(o.properties.get("posFinalX"), String)); 
			bodyCircular.userData.velocidad =  Std.parseFloat(cast(o.properties.get("velocidad"), String)); 
			bodyCircular.userData.rotation = Std.parseInt(cast(o.properties.get("puedeRotar"), String));
			group.add(new RuedaSerradaConMovimientoHorizontal(bodyCircular, posFinalX, sentidoInicial));
		}	
		else if(o.name == "ruedaSerradaConMovimientoVertical") {
			
			var sentidoInicial:Int = Std.parseInt(cast(o.properties.get("sentidoInicial"), String));
			var posFinalY:Float =  Std.parseFloat(cast(o.properties.get("posFinalY"), String)); 
			bodyCircular.userData.velocidad =  Std.parseFloat(cast(o.properties.get("velocidad"), String));
			bodyCircular.userData.rotation = Std.parseInt(cast(o.properties.get("puedeRotar"), String));
			group.add(new RuedaSerradaConMovimientoVertical(bodyCircular, posFinalY, sentidoInicial));
		}	
	}
	
	function crearObjectoRectangular(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup):Void {
		
		/* CheckPoints
		 * Se cargan una sola vez cada vez que el playstate fue cargado en memoria.
		 * Osea, si reiniciamos el nivel el ultimo checkpoint será el ultimo que el player toco.
		 * En el nivel tutorial, tenemos 3 checkpoints (ver mapa Tiled).
		 * Los objetos tiled son 2. 
		 * 	Uno un rectangulo que es la colision del checkpoint (rectangulo grande, donde el player si o si deba pasar)
		 *	Dos el punto donde spawnea el player. 
		 * 
		 * */
		
		var linked_id:String = "";
		if (o.properties.contains("linked_id")) {
			linked_id = o.properties.get("linked_id");
		}
		if ( o.properties.contains("checkPointSensor")) {
			//Solo llenamos el grupo CheckpointSensor una vez
			var width:Float = o.width;
			var height:Float = o.height;
			var id: String = o.properties.get("checkPointSensor");
			/*Array de ID de objeto base, con esto el checkpoint activa comportanmiento cuando se toca */ 

			var check:CheckPointSensor = new CheckPointSensor(id, o.x, o.y, width, height, linked_id);
			Globales.checkPointSensorGroup.add(check);
			return;
		}		

				
		//trace("crearRectangulo size: " + o.width + "x" + o.height + "- x e y : " + o.x +","+ o.y);
		var rectangleWidth:Int = cast(o.width, Int);
		var rectangleHeigth:Int = cast(o.height, Int);
		
		var rectangularBody:Body = new Body(actualBodyType, new Vec2(o.x, o.y));
		rectangularBody.userData.id = o.xmlData.att.resolve("id");
				
		if (o.properties.contains("magnet")) {
			rectangularBody.userData.magnet = true;
		}

		
		var rectangularShape:Polygon = new Polygon(Polygon.rect(0, 0, rectangleWidth, rectangleHeigth));
		
		rectangularBody.shapes.add(rectangularShape);
		
		if (o.properties.contains("rotaSentidoReloj")) {
			switch(o.properties.get("rotaSentidoReloj")) {
				case "0": rectangularBody.userData.rotaSentidoReloj = false;
				case "1": rectangularBody.userData.rotaSentidoReloj = true;				
			}
		}
		
		// Asignamos userData desde Tiled
		if  (o.properties.contains("userDataBody")) {
			rectangularBody.userData.nombre = o.properties.get("userDataBody");
		}
		
		if (o.properties.contains("userDataShape")) {
			rectangularShape.userData.nombre = o.properties.get("userDataShape");
		}	
		if (o.properties.contains("material")) {
			rectangularBody.setShapeMaterials( getMaterial(o.properties.get("material")));
		}		
		if (o.properties.contains("puedeRotar")) {
			rectangularBody.allowRotation = o.properties.get("puedeRotar") == "1";
		}		
		if (o.angle != 0) {
			rectangularBody.userData.rotation = o.angle;
		}
		
		
		if (o.properties.contains("linked_id")) {
			// Tarea: dejar estoy igual al checkpoint sensor, que toma un array de linked id
			rectangularBody.userData.linked_id = cast(o.properties.get("linked_id"),String);
		}
		
		if (o.name == "textoTutorial") {
			rectangularBody.userData.texto = o.properties.get("texto");
			rectangularBody.userData.time = o.properties.get("tiempoEnSec");
			rectangularBody.shapes.at(0).sensorEnabled = true;
			group.add(new TextoTutorial(o.x, o.y, rectangularBody));
		}
		if (o.name == "plataforma" ) {
			rectangularBody.userData.nombre = "plataforma";
			if (o.properties.contains("velocidad")) {
				var velocidad:Float = Std.parseFloat(cast(o.properties.get("velocidad"), String));
				if (rectangularBody.isKinematic()){rectangularBody.surfaceVel.x = velocidad; }
			}
			group.add(new Plataforma(o.x, o.y, rectangularBody, o.type)); 
			
		}else if (o.name == "plataformaDiagonal") {
			
			//group.add(new PlataformaDiagonal(o.x,o.y,rectangularBody)); 
		}
		else if (o.name == "plataformaConMovimientoVertical") {
			var sube:String = o.properties.get("subeYBaja");
			var velocityY:String = o.properties.get("velocityY");
			rectangularBody.userData.velocityY = velocityY;
			var recorridoY:String = o.properties.get("recorridoY");
			rectangularBody.userData.recorridoY = recorridoY;			
			var subeYbaja:Bool =  sube == "1";
			if (o.properties.contains("tocaPlayer")) {
				var tocaPlayer:String = o.properties.get("tocaPlayer");
				rectangularBody.userData.tocaPlayer = tocaPlayer;
			};
			var sentidoInicial:Int = Std.parseInt(cast(o.properties.get("sentidoInicial"), String));
			group.add(new PlataformaConMovientoVertical(o.x, o.y, rectangularBody, subeYbaja, sentidoInicial));
		}else if (o.name == "plataformaConMovimientoHorizontal") {
			var sube:String = o.properties.get("subeYBaja");
			var subeYbaja:Bool =  sube == "1";
			rectangularBody.userData.sentido = Std.parseInt(o.properties.get("sentido"));
			group.add(new PlataformaConMovimientoHorizontal(o.x, o.y, rectangularBody, subeYbaja));	
		}else if (o.name == "palanca") {
			if (o.properties.contains("isReady")) {
				var isReady:Int = Std.parseInt(o.properties.get("isReady"));
				rectangularBody.userData.isReady = isReady == 1;	
			}			
			group.add(new Palanca(o.x, o.y, rectangularBody));
		}else if (o.name == "tiraBomba") {
			
			rectangularShape.localCOM.set(new Vec2(0, 0));
			//rectangularBody.position.set(new Vec2(o.x, o.y));
			
			var sentidoX:Int = 0;
			
			if (o.properties.contains("sentidoX")) {
				sentidoX = Std.parseInt(cast(o.properties.get("sentidoX"), String));
			}
			var sentidoBombas:Int = 1;
			if (o.properties.contains("sentidoBombas")) {
				sentidoBombas= Std.parseInt(cast(o.properties.get("sentidoBombas"),String));
			}
			if (o.properties.contains("delayTimer")) {
				rectangularBody.userData.delayTimer = Std.parseInt(o.properties.get("delayTimer"));
			}		
			if (o.properties.contains("timeBombAlive")) {
				rectangularBody.userData.timeBombAlive = Std.parseInt(o.properties.get("timeBombAlive"));
			}			
			if (o.properties.contains("bombaDestroy")) {
				rectangularBody.userData.bombaDestroy = Std.parseInt(o.properties.get("bombaDestroy"));
			}	
			if (o.properties.contains("canMove")) {
				rectangularBody.userData.canMove =  Std.parseInt(cast(o.properties.get("canMove"),String));
			}			
			if (o.properties.contains("maxDistance")) {
				rectangularBody.userData.maxDistance =  Std.parseInt(cast(o.properties.get("maxDistance"),String));
			}					
			group.add(new TiraBomba(o.x, o.y, rectangularBody, sentidoBombas, sentidoX));
		}else if (o.name == "rectAgarreIzq") {
			rectangularBody.shapes.at(0).sensorEnabled = true;
			rectangularBody.cbTypes.add(Callbacks.agarreCallback);
		}else if(o.name == "rectAgarreDer") {
			rectangularBody.shapes.at(0).sensorEnabled = true;
			rectangularBody.cbTypes.add(Callbacks.agarreCallback);
		}else if (o.name == "enemyMagnet") {
			rectangularBody.userData.nombre = "rectMagnet";
			rectangularShape.localCOM.set( new Vec2(0, 0)	);
			rectangularBody.position.set(new Vec2(o.x, o.y));
			rectangularBody.cbTypes.add(Callbacks.magnetObjectCallback);			
			var velX:Float = 0;
			var velY:Float = 0;
			if (o.properties.contains("startVelX")) { 
				velX = Std.parseFloat(cast(o.properties.get("startVelX"),String)); 
			}
			if (o.properties.contains("startVelY")) { 
				velY = Std.parseFloat(cast(o.properties.get("startVelY"),String)); 
			}
			rectangularBody.angularVel = -3;
			Globales.bodyList_typeMagnet.add(rectangularBody);
		}else if (o.name == "pinches") {
			group.add(new Pinches(o.x, o.y, rectangularBody));
		}else if (o.name == "pincheViejo") {
			group.add(new PincheViejo(o.x, o.y, rectangularBody));
		}else if (o.name == "linea") {
			/* Declaramos la linea, que va a tener colgando al objeto linkeado */
			if (o.properties.contains("linked_id")) {
				var linkId:String = cast(o.properties.get("linked_id"),String);
				
				var b:Body = null;
				
				for (body in FlxNapeSpace.space.bodies) {
					if (body.userData.id == linkId) {
						b = body;
					}
				}				
			}	
		}
		else if (o.name == "ollaPeso") {
			if (o.properties.contains("maxTouchs")) {
				rectangularBody.userData.maxTouchs = Std.parseInt(cast(o.properties.get("maxTouchs"),String));	
			}
			
			group.add(new OllaPeso(o.x, o.y, rectangularBody));
		}else if (o.name == "magnetOnOff") {
			if (o.properties.contains("type")) {
				rectangularBody.userData.type = Std.parseInt(o.properties.get("type"));
			}
			group.add(new MagnetOnOff(o.x, o.y, rectangularBody));
		}else if (o.name == "switchOnOff") {
			if (o.properties.contains("type")) {
				var type : Int = Std.parseInt(o.properties.get("type"));
				switch(type)
				{	
					case SwitchOnOff.TYPE_BYTOUCH:
						group.add(new SwitchOnOffByTouch(o.x, o.y, rectangularBody));
					case SwitchOnOff.TYPE_BYTIME:
						if (o.properties.contains("time")) {							
							rectangularBody.userData.time = Std.parseInt(o.properties.get("time"));
							FlxG.log.add("Load time data");
						}
						group.add(new SwitchOnOffByTime(o.x, o.y, rectangularBody));							
					case SwitchOnOff.TYPE_BYINTERRPUTOR:
						group.add(new SwitchOnOffByInterruptor(o.x, o.y, rectangularBody));
					default:
						FlxG.log.add("Switch on off no encontro tipo");
				}
			}
		}else if (o.name == "estrella") {
			rectangularShape.localCOM.set( new Vec2(0, 0)	);
			rectangularBody.position.set(new Vec2(o.x, o.y));
			/*var _x : Int = Std.int(o.x - rectangularBody.bounds.width * 0.5);
			var _y : Int = Std.int(o.y - rectangularBody.bounds.height * 0.5);*/
			
			for ( id in Globales.estrellasAgarradasID) {
				if (id == Std.parseInt(rectangularBody.userData.id) ) {
					return;
				}
			}
			
			estrellasGroup.add(new Estrella(o.x,o.y, rectangularBody));								
		}
		
		if (o.name == "rectAgarreIzq" || o.name == "rectAgarreDer") {
			rectangularBody.space = FlxNapeSpace.space;		
		}	
		
		rectangularBody.cbTypes.add(Callbacks.escenarioCallback);

	}
	
	function crearObjetoPoligonal(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup):Void {
		var polygonBody:Body;
		var polygonVertices = new Array<Vec2>();
		
		for(p in o.points)
		{
			polygonVertices.push(new Vec2(p.x, p.y));
		}
		
		// Declaramos el body Polygono
		polygonBody = new Body(actualBodyType, Vec2.get(o.x, o.y ));
		polygonBody.userData.id = o.xmlData.att.resolve("id");
		// Agregamos la shape que nos trae desde Tiled
		polygonBody.shapes.add(new Polygon(polygonVertices));
			
		if (o.properties.contains("linked_id")) {
			polygonBody.userData.linked_id = cast(o.properties.get("linked_id"),String);
		}
		
		// Asignamos userData desde Tiled
		if ( (o.properties.contains("userDataBody")) && (o.properties.contains("userDataShape")) ) {
			polygonBody.shapes.at(0).userData.nombre = o.properties.get("userDataShape");
			polygonBody.userData.nombre = o.properties.get("userDataBody");
		}
		
		// Le asignamos un material por defecto : STEEL
		polygonBody.setShapeMaterials(nape.phys.Material.steel());
		
		// Si hay material desde Tiled, pisamos el anterior
		if (o.properties.contains("material")) {
			polygonBody.setShapeMaterials( getMaterial(o.properties.get("material")));
		}		
		
		// Si admite rotacion
		if (o.properties.contains("puedeRotar")) {
			polygonBody.allowRotation = o.properties.get("puedeRotar") == "1";
		}
			
		
		// Para los tipos de colision asignamos INTERACTOR AL CBTYPE
		if (o.name == "piso") {
			//CAMBIO
			//polygonBody.cbTypes.add( Callbacks.pisoCallback );
			//CAMBIO
			polygonBody.cbTypes.add( Callbacks.escenarioCallback);
		}
		else if (o.name == "caja") {
			 polygonBody.cbTypes.add( Callbacks.cajaCallback );
		}				
		
		/*// Si tiene la propiedad 'image' le asignamos al cuerpo
			// Asignar imagen crea un FlxNapeSprite, que ya se agrega al espacio
			// Sino, le asignamos manualmente el espacio
		if (o.properties.contains("image")) {
			AsignarImagen(o, polygonBody);
		}
		else {
				
		}*/
		
		polygonBody.space = FlxNapeSpace.space;
		
	}
	
	function cargarCheckPoints() :Void {

		/* Mira la bandera global, si los checkpoints ya fueron cargados en memoria.*/
		if (!Globales.checkPointCargados) {
			var minMember:Int = 0;
			for (ch in Globales.checkPointGroup.members) {
				/* El checkpoint group ya fue cargado, ahora debemos empezar a que funcionen.
				 * En tiled seteamos el orden de los checkpoints. 0-1-2 en la propiedad "checkPoint" */
				var c:CheckPoint = cast(ch, CheckPoint);
				var _min:Int = Std.parseInt(c.getId());
				if (_min <= minMember) {
					/* Tomamos el ID de los objetos tiled, y empezamos guardando el mas chico.
					 * y lo colocamos como 'currentCheckPoint'.*/
					Globales.currentCheckPoint = c;
					minMember = _min;
				}			
			}	
			/* Bandera global cargada. Esta bandera debe pasar a false cuando se supera un nivel
			 * asi se cargan en el proximo.*/
			Globales.checkPointCargados = true;
		}			
	}
	
	function getMaterial(m:String):Dynamic	{
				
		var mat= Material.steel();
		
		// por defecto sino tiene nada, le asigna STEEL
		
		if (m == "madera") {
			mat = Material.wood();
		}else if (m == "arena") {
			mat = Material.sand();
		}else if (m == "goma") {
			mat = Material.rubber();
		}else if (m == "hielo") {
			mat = Material.ice();
		}else if (m == "vidrio") {
			mat = Material.glass();
		}
		
		return mat;
		
	}

	public function destroy():Void {
		estrellasGroup.clear();
		backgroundLayer.clear();
		foregroundTiles.clear();
		objectsLayer.clear();
		estrellasGroup.clear();	
	}
	
	
}