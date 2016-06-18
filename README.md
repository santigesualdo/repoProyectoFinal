# Proyecto Final "Sin nombre" (StarColector, StarHero, SaveTheStars, STARS NOT DEAD )

Cambios de Librerias:
Estos cambios los hice por que no andaban las ultimas librerias de Spine. Y me resulta muy necesario que si anden.
Los cambios parecen muchos, pero es mejor asi, confia en mi que salio andando de toque en otras compus que probe instalar de cero.

Migre todo a las ultimas librerias. Es decir, este proyecto compila con:
- Bajar Haxe 3.3.0.
- Instalar en C:\HaxeToolKit2 
- Ultimo lime (haxelib install lime) (el que mas tiempo dura)
- Ultimo openfl (haxelib install openfl)
- Ultimo flixel (haxelib install flixel)
- Ultimo flixel-addons (haxelib install flixel-addons)
- Ultimo nape (haxelib install nape)
- spinehaxe (el mismo que teniamos antes, copiar a pata de carpeta a carpeta).
- Luego de instalar todo las librerias en Haxe, ir a FlashDevelop y setear como SDK Haxe 3.3.0.
- Tambien lo que funciona es ir CMD o simbolo de sistema (como hizo el profe el otro dia). Posicionarse 
en la carpeta del proyecto por ej : ..Escritorio/santiBranch/trunk y tipear "haxelib run lime test flash" 
y compila sin necesidad de flashDevelop que por ahi anda mal.

Ultimos cambios de tincho:
- rueda serrada + horizontal y vertical.
- player nape colisiones y listeners modifcados. (tambien texto)
- levels modificados

Ultimos cambios santi:
- player con un sprite de Spine (openfl ya no es parte de todo esto).
- Se cambio la manera de cargar los levels y la sacamos del playState. Pasa a estar en "TiledLevel" donde carga todo por defecto. PlayState ahora esta mas limpio.
- Codigo que no se usaba, recortado (aun no esta todo recortado).




