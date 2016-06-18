package utils ;

import nape.callbacks.InteractionListener;
import nape.callbacks.PreListener;
/**
 * ...
 * @author Santiago Gesualdo - Martin Villafañez
 */
class GameListeners
{
	public static var MouseWithBody:InteractionListener;
	public static var MouseWithBodyEnd:InteractionListener;
	
	public static var PersonajePrePiso:PreListener;
	public static var PersonajeConPiso:InteractionListener;
	public static var PersonajeConPisoEnd:InteractionListener;
	public static var PersonajeConPlataforma:InteractionListener;
	public static var PersonajeConPlataformaEnd:InteractionListener;
	public static var PersonajeConPlataformaTrepar:InteractionListener;
	
	//CAMBIO
	public static var RuedaConPlataforma:PreListener;
	public static var CentroRuedaConRueda:PreListener;
	public static var PersonajeConRueda:InteractionListener;
	//CAMBIO
	
	public static var PersonajeConAgarre:InteractionListener;
	public static var PersonajeConAgarreEnd:InteractionListener;
	
	public static var PersonajeConObjetoInteractivo:InteractionListener;
	public static var PersonajeConObjetoInteractivoEnd:InteractionListener;
	
	public static var BulletWithWorld:InteractionListener;
	public static var BulletLinearMagnetWithWorld:InteractionListener;
	public static var BulletMagnetWithBody:InteractionListener;	
	
	public static var MagnetWithObject:InteractionListener;	
	
	
}