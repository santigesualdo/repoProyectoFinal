package utils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
 using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author s
 */
class HUD extends FlxTypedGroup<FlxSprite>
{
     private var _sprBack:FlxSprite;
     private var _txtMoney:FlxText;
     private var _sprMoney:FlxSprite;

     public function new()
     {
         super();
         _sprBack = new FlxSprite().makeGraphic(50, 30, FlxColor.BLACK);
         _sprBack.drawRect(0, 30, 50, 1, FlxColor.WHITE);
		 _sprBack.alpha = 0.5;
         _txtMoney = new FlxText(0, 2, 0, "0", 0, false);
		 _txtMoney.setFormat(AssetPaths.font_kreon,14);
         _txtMoney.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
         _sprMoney = new FlxSprite( 20, _txtMoney.y, AssetPaths.estrella_hud);
         _txtMoney.alignment = CENTER;
         //_txtMoney.x = _sprMoney.x - _txtMoney.width - 4;
         add(_sprBack);
         add(_sprMoney);
         add(_txtMoney);
         forEach(function(spr:FlxSprite)
         {
             spr.scrollFactor.set(0, 0);
         });
     }

     public function updateHUD(Money:Int = 0):Void
     {
         _txtMoney.text = "x"+Std.string(Money);
         _txtMoney.x = _sprMoney.x - _txtMoney.width - 4;
     }
}