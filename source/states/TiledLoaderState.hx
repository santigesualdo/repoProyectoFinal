package states;

import flixel.FlxState;
import flixel.FlxG;
import haxe.io.Path;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;

class TiledLoaderState extends FlxState
{
    override public function create():Void
    {
        super.create();

        // Load the TMX data
        var tiledLevel:TiledMap = new TiledMap("assets/data/my-map-2.tmx");

        // Get map variables
        var tileSize = tiledLevel.tileWidth;
        var mapW = tiledLevel.width;
        var mapH = tiledLevel.height;

        // Loop through each tile layer and render tile map
        for (layer in tiledLevel.layers)
        {
            // Remember:
            // TiledMap can only load data of type "String" or an "Array<Int>"
            // types, so there is no need load or parse XML data.

            // There are two ways to load layer data:
            // 1) If the TMX is saved in CSV format, then use this:
            // var layerData:String = layer.csvData;

            // 2) If the TMX is saved in base64, then use this:
            // (we shall assume our TMX is base64 format for now)
            var layerData:Array<Int> = layer.tileArray;

            // IMPORTANT:
            // If you used the wrong method to load the data,
            // the game will crash. :(

            // By default, the tilesheet used for this layer is not included in
            // the layer's data. As such, we had to add a custom property "tilesheet"
            // and include the tilesheet's name manually.
            var tilesheetName:String = layer.properties.get("tilesheet");
            var tilesheetPath:String = "assets/images/" + tilesheetName;

            // Finally, create the FlxTilemap and get ready to render the map.
            var level:FlxTilemap = new FlxTilemap();

            // If we're passing an array of data, the level needs to know
            // how many columns of data to read before it moves to a new row,
            // as noted in the API page:
            // http://api.haxeflixel.com/flixel/tile/FlxTilemap.html#loadMap
            level.widthInTiles = mapW;
            level.heightInTiles = mapH;

            // Note: The tilesheet indices are continuous! This means,
            // if there is more than one tilesheet, the 2nd tilesheet's
            // starting index right after the 1st tilesheet's last index.
            // e.g.
            // - tilesheet 1 has 100 tiles (index = 1-100)
            // - tilesheet 2 has 100 tiles (index = 101-200 instead of 1-100)
            //
            // Note2: that the gid "0" is reserved for empty tiles
            var tileGID:Int = getStartGid(tiledLevel, tilesheetName);

            // Render the map.
            // Note: the StartingIndex is based on the tilesheet's
            // startingGID rather than the default 1.
            level.loadMap(layer.tileArray, tilesheetPath, tileSize, tileSize, FlxTilemap.OFF, tileGID);
            add(level);
        }
    }

    function getStartGid (tiledLevel:TiledMap, tilesheetName:String):Int
    {
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

    override public function update():Void
    {
        super.update();
    }

    override public function destroy():Void
    {
        super.destroy();
    }
}