package utils  ;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.BodyList;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import utils.objetos.CheckPoint;

/**
 * ...
 * @author ...
 */
class Globales
{
	public static var currentState:FlxState = null;
	
	public static var gravityX : Int =  0;
	public static var gravityY : Int =  900;
	
	public static var canvas:FlxSprite = null;

	public static var globalPlayer:PlayerNape = null;
	public static var globalPlayerBodyIntermedioPos:Vec2 = null;
	public static var globalTimeScale:Float = 1;
	
	public static var checkPointGroup:FlxGroup = new FlxGroup();
	public static var checkPointSensorGroup:FlxGroup = new FlxGroup();
	 
	public static var currentCheckPoint:CheckPoint = null;
	public static var checkPointCargados:Bool = false;
	
	public static var bodyList_typeMagnet:BodyList = null;
	public static var bodyList_toMagnetize:BodyList = null;
	public static var bodyList_typeObjectos:BodyList = null;
	static public var currentLevel:String = "";
	
	public static var spinePlayer:SpinePlayer=null;
	
	public static inline function clear(arr:Array<Dynamic>){
        #if (cpp||php)
        arr.splice(0,arr.length);           
		#else
        untyped arr.length = 0;
        #end
    }
		
}