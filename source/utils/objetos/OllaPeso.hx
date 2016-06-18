package utils.objetos;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import openfl.display.BitmapData;
import utils.Callbacks;
import utils.objetos.ObjetoBase;
import utils.NapeSpr_Body;

/**
 * ...
 * @author s
 */

@:bitmap("assets/images/ollapeso.png") class Cog extends BitmapData {}

class OllaPeso extends ObjetoBase
{
	
	/* Pasamos desde Tiled la cantidad de veces que la olla tiene que ser tocada para activarse 
	 * Entonces decimos que si la olla entra en colision con tres objetos diferentes, se activa
	 * */
	var maxTouchs:Int;
	
	var touchesBodyId:Array<Int>;
	
	var posFinalY:Float;
	
	var ic:InteractionListener;
	var napeSprite:NapeSpr_Body;
	
	var linkId:Int;
	
	public function new(x:Int, y:Int, body:Body) 
	{
		super(x, y);
		
		var centerX:Float = body.bounds.x + body.bounds.width * 0.5;
		var centerY:Float = body.bounds.y + body.bounds.height * 0.5;
		
		if (body.userData.maxTouchs != null) {
			maxTouchs = body.userData.maxTouchs;	
		}		
		
		if (body.userData.linked_id != null) {
			this.linkId = Std.parseInt(body.userData.linked_id);
		}	
		
		touchesBodyId = new Array<Int>();
		
		var _width:Int = cast(body.bounds.width,Int);
		var _height:Int = cast(body.bounds.height,Int);
		
		var bitmapdata = new Cog(_width,_height,false,FlxColor.WHITE);
		var cogIso:BitmapDataIso = new BitmapDataIso( bitmapdata , 0x80);
		napeSprite = new NapeSpr_Body(centerX, centerY, cogIso, "assets/images/ollapeso.png", BodyType.DYNAMIC, Material.wood(), "hola", false);
		b = napeSprite.body;
		b.allowMovement = false;
	
		
		var cb:CbType = new CbType();
		
		b.cbTypes.add(cb);
		
		ic = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, cb, Callbacks.bolaMagnet,
		function onOllaBola(e:InteractionCallback) {
			
			var bola: Body = e.int2.castBody;
			
			var idBola:Int = bola.userData.id;
			
			
			
			if (touchesBodyId.length== 0) {
				touchesBodyId.push(idBola);
			}else { 
				var agregarId:Bool = false;
				for (i in 0...touchesBodyId.length) {
					if (touchesBodyId[i] != idBola) {
						agregarId = true;
					}else {
						agregarId = false;
						break;
					}
				}
				
				if (agregarId) {
					touchesBodyId.push(idBola);
					if (touchesBodyId.length == maxTouchs) {
						b.allowMovement = true;
						FlxNapeSpace.space.listeners.remove(ic);
					
						for (body in FlxNapeSpace.space.bodies) {
							if (body.userData.id == linkId) {
								if (body.userData.isReady != null) {
									body.userData.isReady = true;
								}
							}
						}
					}
				}
			}
		});
		
		
		
		this.loadGraphicFromSprite(cast(napeSprite, FlxSprite));
		FlxNapeSpace.space.listeners.add(ic);
	}

	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		napeSprite.postUpdate();
	}
	
}