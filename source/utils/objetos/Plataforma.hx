package utils.objetos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import nape.phys.Body;

/**
 * ...
 * @author s
 */
class Plataforma extends ObjetoBase
{
	
	public function new(x:Int, y:Int, rectangularBody:Body, tipo:String) 
	{
		super(x, y);
	
		b = rectangularBody;
		//b.cbTypes.add( Callbacks.pisoCallback );	
		b.cbTypes.add( Callbacks.plataformaCallback);	
		b.space = FlxNapeSpace.space;		
				
		tipo = "Plataforma";
		setNormalText(18);
		
		set_visible(false);
		
	}
		
}