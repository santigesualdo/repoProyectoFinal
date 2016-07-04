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
	
	override public function create()
	{
		super.create();
						
		/*var background:FlxSprite = new FlxSprite(0, 0, AssetPaths.MENU_BACK_PATH);
		add(background);*/
		
		botones = new FlxGroup();
		add(botones);
		
		var centroX = FlxG.width * 0.5; 
		var centroY = FlxG.height * 0.5;
		
		var textField:FlxText = new FlxText(0, 100, FlxG.width, "Menu State", 0, false);
		textField.setFormat( AssetPaths.font_kreon, 50, FlxColor.WHITE, FlxTextAlign.CENTER);
		add(textField);
		
		butL1 = new ButtonLevel(centroX, centroY-50, "level1");
		butL2 = new ButtonLevel(centroX, centroY + 50, "level2");
		butL3 = new ButtonLevel(centroX, centroY + 150, "level3");
		butL4 = new ButtonLevel(centroX + 200, centroY-50, "testPlayerSpine");
		
		botones.add(butL1);
		botones.add(butL2);
		botones.add(butL3);
		botones.add(butL4);
		
	}
	
	public function changeLevel(name:String ) {
		
		Globales.currentLevel = name;
		var ps: PlayState = new PlayState();
		FlxG.switchState(ps);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);	
		
		for ( b in botones.members ) {
			var boton: ButtonLevel = cast(b, ButtonLevel);
			if (boton.getClicked()) {
				if (boton.getLevelName() == "testPlayerSpine") {
					FlxG.switchState(new PlayerDesignState());
				}else {
					changeLevel(boton.getLevelName());	
				}
				
			}			
		}
		
	}
	
		
}