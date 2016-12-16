package states;

import flixel.addons.text.FlxTextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import utils.AssetPaths;
import utils.ButtonLevel;
import utils.Globales;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author s
 */
class MenuState extends FlxState
{	
	var butLevel:FlxSprite;

	var butL1:ButtonLevel;
	var butL2:ButtonLevel;
	var butL3:ButtonLevel;
	var butL4:ButtonLevel;
	
	var botones:FlxGroup;
	
	var limpiarGrupo:Bool;
	
	override public function create()
	{
		super.create();
						
		 //var _sprBack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
         //_sprBack.drawRect(0, 0, FlxG.width, FlxG.height, FlxColor.GRAY);
		 //add(_sprBack);
		
		var background:FlxSprite = new FlxSprite(0, 0, AssetPaths.MENU_BACK_PATH);
		add(background);
		
		limpiarGrupo = false;
		
		botones = new FlxGroup();
		add(botones);
		
		var centroX = FlxG.width * 0.5; 
		var centroY = FlxG.height * 0.5;
		
		//var textField:FlxText = new FlxText(0, 100, FlxG.width, "Menu State", 0, false);
		//textField.setFormat( AssetPaths.font_kreon, 50, FlxColor.WHITE, FlxTextAlign.CENTER);
		//add(textField);
		
		butL1 = new ButtonLevel(centroX, centroY + 50, "JUGAR");
		butL2 = new ButtonLevel(centroX, centroY + 125, "OPCIONES");
		butL3 = new ButtonLevel(centroX, centroY + 200, "SALIR");
		
		botones.add(butL1);
		botones.add(butL2);
		botones.add(butL3);
		
	}
	
	public function changeState(name:String ) {
		
		switch(name){
			case "JUGAR": 
				Globales.currentLevel = "level1";
				var ps: PlayState = new PlayState();
				FlxG.switchState(ps);
			case "OPCIONES": 
				FlxG.switchState(this);
			case "SALIR": 
				FlxG.switchState(this);
		}

	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);	
		
		for ( b in botones.members ) {
			var boton: ButtonLevel = cast(b, ButtonLevel);
				if (boton.getClicked()) {
					limpiarGrupo = true;
					changeState(boton.getStateName());	
				}		
		}

		if (limpiarGrupo) {
			for ( b in botones.members ) {
				var boton: ButtonLevel = cast(b, ButtonLevel);
				botones.remove(boton);
				boton.destroy();
			}	
		}
	}
	
		
}