local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )

composer.gotoScene( "scene.menu" );