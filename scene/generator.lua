local composer = require( "composer" );
local scene = composer.newScene();

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local fontCommon = "Arial Black";
local mainLayer, overlayLayer;

local gamesTable = composer.getVariable( "gamesTable" );
local players =	composer.getVariable( "players" );
local genTable = {};

local buttonStartX, buttonStartY = 50, 50;
local buttonNextX, buttonNextY = buttonStartX, buttonStartY;
local buttonNextText;

local function genTableClear( retValue )
	for i = #genTable, 1, -1 do
		genTable[i]:removeSelf();
		genTable[i] = nil;
	end;
	return retValue;
end;

local function generateGame( scrGroup )
	return function()
		if buttonNextY > 680 then
		  buttonNextY = genTableClear( buttonStartY );
		end;
		local randomGame = gamesTable[players.platformChoice + 1][ math.random( #gamesTable[players.platformChoice + 1] ) ];
		print(#randomGame);
		randomGame = #randomGame < 65 and randomGame or string.sub( randomGame, 1, 65 ) .. "...";
		local newButtonText = display.newText( scrGroup, randomGame, buttonNextX, buttonNextY, fontCommon, 26 );
		newButtonText.anchorX = 0.0;
		newButtonText.anchorY = 0.0;
		local oldSizle = newButtonText.size;
		newButtonText.size = 1;
		transition.to( newButtonText, { time = 1000, size = oldSizle } );
		buttonNextY = buttonNextY + 35 ;
		table.insert( genTable, newButtonText );
	end;
end;

local function gotoMenu()
	composer.gotoScene( "scene.menu", { effect = "fade", time = 800 } );
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	mainLayer = display.newGroup();
	sceneGroup:insert( mainLayer );
	overlayLayer = display.newGroup();
	sceneGroup:insert( overlayLayer );

	local background = display.newImageRect( mainLayer, "scene/menu/smb3.png", 1280, 720 );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;

  local overlay = display.newImageRect( overlayLayer, "scene/menu/mask.png", 1280, 720 );
	overlay.x = display.contentCenterX;
	overlay.y = display.contentCenterY;
	overlay.blendMode = "multiply";
	
end;


-- show()
function scene:show( event )

	local sceneGroup = self.view;
	local phase = event.phase;

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		buttonMenu = display.newRoundedRect( mainLayer, 1170, 25, 200, 40, 5 );
		buttonMenu.strokeWidth = 3;
		buttonMenu:setFillColor( 0.0, 0.01 );
		buttonMenu:addEventListener( "tap", gotoMenu );
		local buttonMenuText = display.newText( mainLayer, "to Menu", 1170, 25, fontCommon, 26 );

		buttonNextText = display.newText( mainLayer, gamesTable[1][players.platformChoice] .. " ?", 1250, 70, fontCommon, 26 );
		buttonNextText.anchorX = 1.0;
		buttonNextPosY = buttonNextText.width + 40 < 200 and 200 or buttonNextText.width + 40 
		buttonNext = display.newRoundedRect( mainLayer, 1270, 70, buttonNextPosY, 40, 5 );
		buttonNext.anchorX = 1.0;
		buttonNext.strokeWidth = 3;
		buttonNext:setFillColor( 0.0, 0.01 );
		buttonNext:addEventListener( "tap", generateGame( mainLayer ) );

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end;
end;


-- hide()
function scene:hide( event )

	local sceneGroup = self.view;
	local phase = event.phase;

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		buttonNextY = genTableClear( buttonStartY );
		
		buttonMenu:removeEventListener( "tap", gotoMenu );
		buttonMenu:removeSelf();
		buttonMenu = nil;
		
		buttonNext:removeEventListener( "tap", generateGame );
		buttonNext:removeSelf();
		buttonNext = nil;

		buttonNextText:removeSelf();
		buttonNextText = nil;
	end;
end;


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view;
	-- Code here runs prior to the removal of scene's view

end;


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene