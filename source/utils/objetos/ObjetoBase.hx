package utils.objetos;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxSprite;
import flixel.FlxG;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;

/**
 * ...
 * @author ...
 */
class ObjetoBase extends FlxSprite
{
	// En el objeto base no se define nada que tenga que ver con Nape.
	// Excepto actualizar la posicion del Sprite con la del body.
	
	var id:Int;
	
	/* Cuerpo */
	var b:Body ; 
	
	/* Si esta activo, ejecuta comportamiento  */
	/* Si no esta activo, no hace nada  */
	/* Si queda desactivado, luego de estar activo, se detiene donde quedo , no vuelve al principio */
	var activo:Bool;
	
	/* Puede rotar */
	var rota:Bool;
	
	/* Rota en sentido de reloj */
	/* En caso de querer usar rotacion, mirar clase Palanca*/
	var rotacionSentidoReloj:Bool;
	
	/* Tipo */
	var tipo:String;
	
	/* Texto de cada clase. Modificar visible o no visible en clase hija. */
	var texto:FlxText;
	var tfont:String = AssetPaths.font_kreon;
	var tsize:Int = 0;
	var tcolor:UInt = FlxColor.BLACK;
	var tallignment: String = "center";
	
	public function new(x:Float, y:Float) :Void
	{
		super(x, y, null);
		activo = false;		
	}
	
	public function activar():Void 
	{
		activo = true;
	}
	
	public function desactivar():Void 
	{
		activo = false;
	}
	
	override public function update(elapsed:Float):Void {
		
		if (this.exists) {
			super.update(elapsed);
			
			if (b != null) {
				this.x = b.position.x - this._halfSize.x ;
				this.y = b.position.y - this._halfSize.y;
			}
			
			if (activo) {
				comportamiento();
			}	
		}	
		
	}
	
	override public function destroy():Void
	{
		if (texto != null) {
			texto.destroy();	
		}
		
		if (b != null && FlxNapeSpace.space != null) {
			FlxNapeSpace.space.bodies.remove(b);	
		}
		
		super.destroy();
	}
	
	/* Clase declarada para sobre escribirla en clase hija */
	/* Comportamiento para update*/
	public function comportamiento():Void {
			
	}
	
	/* Clase declarada para sobreescribirla en clase hija */
	/* Definimos activar efecto para declarar todo lo necesario al finalizar comportamiento */
	public function activarEfecto():Void {
		
	}
	
	/* Setea formato de texto predeterminado para el Objeto base */
	public function setNormalText(_size:Int):Void {
	
		tsize = _size;
		
		if (tipo != null) {
			
			var ancho:Float = 100;
			if (b.bounds.width > 100) {
				ancho = b.bounds.width;		
			}
			
			texto = new FlxText(b.bounds.x, b.bounds.y+b.bounds.height*0.45, ancho , tipo, tsize, false);
			texto.setFormat(AssetPaths.font_kreon, tsize, tcolor, tallignment);
		}

		
	}
	
	/* En caso de que la plataforma se mueva updatea */
	public function updateTextPos():Void {
		if (texto != null) {
			texto.setPosition(b.bounds.x, b.bounds.y + b.bounds.height * 0.45);
			texto.setFormat(tfont, tsize, tcolor, tallignment);
		}
	}
	
	override public function draw():Void {
		if (this.exists) {
			super.draw();
			if (texto != null) {
				texto.draw();
			}
		}

	}
	
	/* Para que un body sea magnetizable debe ser de tipo Dynamic 
	 * - Si es kinematic lo convertimos a dynamic
	 * - Sino no hacemos nada. 
	 * */
	
	 // TAREA: Corregir este nombre.
	
	public function checkBodyType():Void
	{
		if (!b.allowMovement) {
			b.allowMovement = true;
		}
	}
	
	public static function buscarBody(id:Int):Body {
	
		for (body in FlxNapeSpace.space.bodies) {
			var b:Body = cast(body, Body);
			if (b.userData.id == id) {
				return b;
			}
		}
		return null;		
	}

}