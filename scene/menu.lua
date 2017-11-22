local composer = require( "composer" );
local scene = composer.newScene();

local json = require( "json" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local fontCommon = "Arial Black";

local gamesButtons, gamesTable, playersTable = {}, {}, {};
local platformChoice;
local buttonAddPlayer, buttonRemovePlayer;

local gotoGenerator = function()
	composer.gotoScene( "scene.generator" );
end;

local addPlayer = function()
  print("addPlayer");
end;

local removePlayer = function()
	print("removePlayer");
	composer.removeScene( "scene.menu" );
	composer.gotoScene( "scene.menu" );
end;

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view;
	-- Code here runs when the scene is first created but has not yet appeared on screen

  local background = display.newImageRect( sceneGroup, "scene/menu/background.png", 1280, 720 );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;
--[[
  local horizontalLine = display.newLine( sceneGroup, 0, 360, 1280, 360 );
  horizontalLine:setStrokeColor( 1, 1, 1, 1 );
  horizontalLine.strokeWidth = 3;
--]]
  local verticalLine = display.newLine( sceneGroup, 640, 0, 640, 720 );
  verticalLine:setStrokeColor( 1, 1, 1, 1 );
  verticalLine.strokeWidth = 3;

  local makeText = function( textOut, xPlace, yPlace )
  	local newText = display.newText( sceneGroup, textOut, xPlace, yPlace, fontCommon, 30 );
  	newText.anchorX, newText.anchorY = 0.0, 0.0;
  	return newText;
	end

  local textPlayers = makeText( "Players", 5, 0 );
  local textSystems = makeText( "Systems", 645, 0 );
  --local textTeam = makeText( "Team", 5, 360 );
  --local textPlanLeft = makeText( "Plan Left", 645, 360 );

  local loadBase = function( basePath )
		local baseTable = {};
		local baseFile = io.open( basePath, "r" );
	  if baseFile then
	    local contents = baseFile:read( "*a" );
	    io.close( baseFile );
	    baseTable = json.decode( contents );
	  end;
	  return baseTable;
	end;

	local gamesPath = system.pathForFile( "scene/games.json", system.ResoursesDirectory );
	local playersPath = system.pathForFile( "players.json", system.DocumentsDirectory );
	gamesTable = loadBase( gamesPath );
	playersTable = loadBase( playersPath );

	--Platform Keys
		local platformSelect = function( platformNumber )
			
			local buttonStartX, buttonStartY = 350, 75;

			return function()
			  platformChoice = gamesTable[1][platformNumber];
			  for i = 1, #gamesButtons do
					gamesButtons[i].strokeWidth = 3;
				end;
				gamesButtons[platformNumber].strokeWidth = 7;

				randomGame = math.random( #gamesTable[platformNumber+1] );
				local newButtonText = display.newText( sceneGroup, gamesTable[platformNumber+1][randomGame], buttonStartX - 300, buttonStartY, fontCommon, 26 );	  
		  	newButtonText.anchorX = 0.0
		  	buttonStartY = buttonStartY + 40 ;
		  end;

		end;

		local buttonStartX, buttonStartY = 800, 75;
	  for i = 1, #gamesTable[1] do
			local newButton = display.newRoundedRect( sceneGroup, buttonStartX, buttonStartY, 280, 50, 5 );
			newButton.strokeWidth = 3;
			newButton:setFillColor( 0.0, 0.01 );
			local newButtonText = display.newText( sceneGroup, gamesTable[1][i], buttonStartX, buttonStartY, fontCommon, 26 );	  
		  buttonStartY = buttonStartY + 60 ;
		  if buttonStartY > 315 then
		  	buttonStartX = 1100;
		  	buttonStartY = 75;
		  end;
		  newButton:addEventListener( "tap", platformSelect(i) )
		  table.insert( gamesButtons, newButton );
	  end;

  --Player add and remove keys
	  local buttonAddPlayerX, buttonAddPlayery = 580, 20;
	  local buttonAddPlayerText = display.newText( sceneGroup, "+", buttonAddPlayerX+2, buttonAddPlayery, fontCommon, 26 );	
		local buttonRemovePlayerText = display.newText( sceneGroup, "-", buttonAddPlayerX+37, buttonAddPlayery, fontCommon, 26 );	
	  buttonAddPlayer = display.newRoundedRect( sceneGroup, buttonAddPlayerX, buttonAddPlayery, 30, 30, 5 );
		buttonAddPlayer.strokeWidth = 3;
		buttonAddPlayer:setFillColor( 0.0, 0.01 );
		buttonAddPlayer:addEventListener( "tap", addPlayer );
	  buttonRemovePlayer = display.newRoundedRect( sceneGroup, buttonAddPlayerX+35, buttonAddPlayery, 30, 30, 5 );
		buttonRemovePlayer.strokeWidth = 3;
		buttonRemovePlayer:setFillColor( 0.0, 0.01 );
		buttonRemovePlayer:addEventListener( "tap", removePlayer );

end;

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

		-- add scene update here

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
		composer.removeScene( "menu" );
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
