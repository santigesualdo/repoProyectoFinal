package utils;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxSprite;
import states.PlayState;

/**
 * ...
 * @author s
 */
class Level extends FlxSprite
{

	var tiledmap(default, set): TiledMap;
	
	var backgroundPath:String;
	var terrainPath:String;
	var tilesetPath:String;
	
	var name:String;
	
	var gravityX:Int;
	var gravityY:Int;
	
	var tl:TiledLevel = null;
	
	public function new(X:Float=0, Y:Float=0, levelName:String, state:PlayState ){
		super(0, 0, null);
		
		name = levelName;
		
		switch(name) {
			case "level1": 
				
				tl = new TiledLevel(AssetPaths.LEVEL1_TMX_PATH, state);				

				
			case "level2":
				
				tl = new TiledLevel(AssetPaths.LEVEL2_TMX_PATH,state);
				//backgroundPath = AssetPaths.LEVEL2_BACKGROUND_PATH;
				//terrainPath = AssetPaths.LEVEL2_TERRAIN_PATH;
				//tilesetPath = AssetPaths.LEVEL2_TILESET;
				//gravityX = Globales.gravityX;
				//gravityY = Globales.gravityY;

			case "level3":
				
				tl = new TiledLevel(AssetPaths.LEVEL3_TMX_PATH,state);
				//backgroundPath = AssetPaths.LEVEL3_BACKGROUND_PATH;
				//terrainPath = AssetPaths.LEVEL3_TERRAIN_PATH;
				//tilesetPath = AssetPaths.LEVEL3_TILESET;
				//gravityX = Globales.gravityX;
				//gravityY = Globales.gravityY;

			case "exit":
			
			default:
	
		}		
		
		var backdrop:FlxBackdrop = new FlxBackdrop(tl.backDropPath);
		state.add(backdrop);
		//state.add(tl.backgroundLayer);
		// Add static images
		state.add(tl.imagesLayer);
		// Load player objects
		state.add(tl.objectsLayer);
		// Add foreground tiles after adding level objects, so these tiles render on top of player
		state.add(tl.foregroundTiles);
		//backgroundPath = AssetPaths.LEVEL1_BACKGROUND_PATH;
		
		/*tiledmap = new TiledMap(AssetPaths.LEVEL1_TMX_PATH);
		backgroundPath = AssetPaths.LEVEL1_BACKGROUND_PATH;
		terrainPath = AssetPaths.LEVEL1_TERRAIN_PATH;
		tilesetPath = AssetPaths.LEVEL1_TILESET;
		gravityX = Globales.gravityX;
		gravityY = Globales.gravityY;*/
	}
	
	public function getFullWidth():Float {
		
		if (tl != null) {
			return tl.fullWidth;
		}
		return 0.0;
	}
	
	public function getFullHeight():Float {
		if (tl != null) {
			return tl.fullHeight;
		}
		return 0.0;
	}
	
	public function getTerrainPath():String{
		return this.terrainPath;
	}
	
	
	public function getTilesetImgPath():String{
		return this.tilesetPath;
	}
	
	public function getLevel():TiledMap {
		return this.tiledmap;
	}
	
	public function getName():String	{
		return this.name;
	}
	
	public  function getBackgroundPath():String {
		return this.backgroundPath;
	}
		
	public function getGravityX():Int {
		return this.gravityX;
	}
	
	public  function getGravityY():Int {
		return this.gravityY;
	}		
	
	function set_tiledmap(value:TiledMap):TiledMap 
	{
		return tiledmap = value;
	}
	
}