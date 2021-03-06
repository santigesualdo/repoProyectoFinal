package utils.objetos;


import flixel.addons.nape.FlxNapeSpace;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.phys.Body;

/**
 * ...
 * @author s
 */
class PlataformaHorizontal extends ObjetoBase
{
	
	public function new(x:Int, y:Int, rectangularBody:Body) 
	{
		super(x, y);
	
		
		
		b = rectangularBody;
		//b.cbTypes.add( Callbacks.pisoCallback );	
		b.cbTypes.add( Callbacks.plataformaCallback);	
		b.space = FlxNapeSpace.space;		
				
		tipo = "Plataforma";
		setNormalText(18);
		
	}
		
}