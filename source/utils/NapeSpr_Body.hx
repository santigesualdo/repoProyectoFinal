package utils;

import flixel.addons.nape.FlxNapeSprite;
import nape.geom.IsoFunction;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.addons.nape.FlxNapeSprite;
import nape.geom.IsoFunction;
import flixel.FlxCamera;
import flixel.FlxSprite;
import nape.geom.Vec2;
import nape.space.Space;
import flixel.FlxG;
import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.StageQuality;
import flixel.util.FlxColor;
import openfl.display.FPS;

/**
 * ...
 * @author santi ge
 */

 class DisplayObjectIso implements IsoFunction {
    public var displayObject:DisplayObject;
    public var bounds:AABB;
    public function new(displayObject:DisplayObject) {
        this.displayObject = displayObject;
        this.bounds = AABB.fromRect(displayObject.getBounds(displayObject));
    }
    public function iso(x:Float, y:Float) {
        // Best we can really do with a generic DisplayObject
        // is to return a binary value {-1, 1} depending on
        // if the sample point is in or out side.
        return (displayObject.hitTestPoint(x, y, true) ? -1.0 : 1.0);
    }
}

class IsoBody {
    public static function run(iso:IsoFunctionDef, bounds:AABB, granularity:Vec2=null, quality:Int=2, simplification:Float=1.5) {
        var body = new Body();
        if (granularity==null) granularity = Vec2.weak(8, 8);
        var polys = MarchingSquares.run(iso, bounds, granularity, quality);
        for (p in polys) {
            var qolys = p.simplify(simplification).convexDecomposition(true);
            for (q in qolys) {
                body.shapes.add(new Polygon(q));
                // Recycle GeomPoly and its vertices
                q.dispose();
            }
            // Recycle list nodes
            qolys.clear();
            // Recycle GeomPoly and its vertices
            p.dispose();
        }
        // Recycle list nodes
        polys.clear();
        // Align body with its centre of mass.
        // Keeping track of our required graphic offset.
        var pivot = body.localCOM.mul(-1);
        body.translateShapes(pivot);
        body.userData.graphicOffset = pivot;
        return body;
    }
}

class BitmapDataIso implements IsoFunction {
    public var bitmap:BitmapData;
    public var alphaThreshold:Float;
    public var bounds:AABB;
    public function new(bitmap:BitmapData, alphaThreshold:Float = 0x80) {
        this.bitmap = bitmap;
        this.alphaThreshold = alphaThreshold;
        bounds = new AABB(0, 0, bitmap.width, bitmap.height);
    }
    public function graphic() {
        return new Bitmap(bitmap);
    }
    public function iso(x:Float, y:Float) {
        // Take 4 nearest pixels to interpolate linearly.
        // This gives us a smooth iso-function for which
        // we can use a lower quality in MarchingSquares for
        // the root finding.
        var ix = Std.int(x); var iy = Std.int(y);
        //clamp in-case of numerical inaccuracies
        if(ix<0) ix = 0; if(iy<0) iy = 0;
        if(ix>=bitmap.width)  ix = bitmap.width-1;
        if(iy>=bitmap.height) iy = bitmap.height-1;
        // iso-function values at each pixel centre.
        var a11 = alphaThreshold - (bitmap.getPixel32(ix,iy)>>>24);
        var a12 = alphaThreshold - (bitmap.getPixel32(ix+1,iy)>>>24);
        var a21 = alphaThreshold - (bitmap.getPixel32(ix,iy+1)>>>24);
        var a22 = alphaThreshold - (bitmap.getPixel32(ix+1,iy+1)>>>24);
        // Bilinear interpolation for sample point (x,y)
        var fx = x - ix; var fy = y - iy;
        return a11*(1-fx)*(1-fy) + a12*fx*(1-fy) + a21*(1-fx)*fy + a22*fx*fy;
    }
}


class NapeSpr_Body extends FlxNapeSprite
{
	public function new( x:Float, y:Float, graphic_bitmap:BitmapDataIso, graphic: Dynamic, body_type:BodyType, _material:Material , name:String, allowRotation:Bool ):Void
	{
		super(x, y, graphic);
				
		var cog_body = IsoBody.run(graphic_bitmap, graphic_bitmap.bounds);
		
		var _body  = cog_body.copy();
			
		_body.type = body_type;
		
		_body.userData.name = name;
		
		_body.allowRotation = allowRotation;
		
		_body.setShapeMaterials(_material);
		
		_body.position.setxy(x, y);
	
		loadGraphic(graphic);
		antialiasing = true;
		addPremadeBody(_body);
		
		/*origin.x = 0;
		origin.y = 0;*/
		
	}
	
	public function postUpdate():Void 
	{
		var _body:Body = body;	
		var graphicOffset:Vec2 = _body.userData.graphicOffset;
		var position:Vec2 = _body.localPointToWorld(graphicOffset) ;
				
		setPosition(position.x, position.y);
		angle = (_body.rotation * 180 / Math.PI) % 360;
		
		position.dispose();	
	}
	
	
}



   