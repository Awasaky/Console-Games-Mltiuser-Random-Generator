local composer = require( "composer" );
local scene = composer.newScene();

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local fontCommon = "Arial Black";

local function gotoMenu()
	composer.gotoScene( "scene.menu", { effect = "fade", time = 800 } );
	print("scene.menu");
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "scene/menu/smb3.png", 1280, 720 );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;

	local buttonMenuText = display.newText( sceneGroup, "to Menu", 1150, 395, fontCommon, 26 );	
	buttonMenu = display.newRoundedRect( sceneGroup, 1150, 395, buttonMenuText.width + 40, 40, 5 );
	buttonMenu.strokeWidth = 3;
	buttonMenu:setFillColor( 0.0, 0.01 );
	buttonMenu:addEventListener( "tap", gotoMenu );


  local overlay = display.newImageRect( sceneGroup, "scene/menu/mask.png", 1280, 720 );
  overlay.x = display.contentCenterX;
  overlay.y = display.contentCenterY;
  overlay.blendMode = "multiply";

end;


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "scene.generator" );
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene