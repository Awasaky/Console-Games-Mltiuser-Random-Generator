local composer = require( "composer" );
local scene = composer.newScene();

local json = require( "json" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Common Code

local fontCommon = "Arial Black";
local mainLayer, overlayLayer;

local gamesTable = {};
local players = {
	ptable = {}, team = {}, left = {},
	games = {}, played = {},
	platformChoice = 1 };

local function gotoGenerator()
	composer.setVariable( "gamesTable", gamesTable );
	composer.setVariable( "players", players );
	composer.gotoScene( "scene.generator", { effect = "fade", time = 800 } );
end;

-- Common Code

local textGames;
local buttonsGamesMenu = {};
local buttonAddPlayer, buttonRemovePlayer;

local function platformSelect( platformNumber )
	return function()
		players.platformChoice = platformNumber;
		for i = 1, #gamesTable[1] do
			buttonsGamesMenu[1][i].strokeWidth = 3;
		end;
		textGames.text = "Games: " .. #gamesTable[players.platformChoice+1];
		buttonsGamesMenu[1][platformNumber].strokeWidth = 7;
	end;
end;

local function addKeysFromList( buttonStartX, buttonStartY, listOfKeys, callback )
	local keysList = {{},{}};
	local buttonStartX = buttonStartX or 800;
	local buttonStartY = buttonStartY or 100;
	local buttonNowY = buttonStartY;
  for i = 1, #listOfKeys do --gamesTable[1]
		local newButton = display.newRoundedRect( mainLayer, buttonStartX, buttonNowY, 280, 40, 5 );
		newButton.strokeWidth = 3;
		newButton:setFillColor( 0.0, 0.01 );
		local newButtonText = display.newText( mainLayer, listOfKeys[i], buttonStartX, buttonNowY, fontCommon, 26 );	  
	  buttonNowY = buttonNowY + 55 ;
	  if buttonNowY > buttonStartY + 225 then
	  	buttonStartX = buttonStartX + 300;
	  	buttonNowY = buttonStartY;
	  end;
	  newButton:addEventListener( "tap", callback( i ) );
	  table.insert( keysList[1], newButton );
	  table.insert( keysList[2], newButtonText );
  end;
  return keysList;
 end;

local function removeKeysFromList( listOfKeys, callback )
	for i = #listOfKeys[1], 1, -1 do
		listOfKeys[1][i]:removeEventListener( "tap", callback(i) );
		listOfKeys[1][i]:removeSelf();
		listOfKeys[2][i]:removeSelf();
		table.remove( listOfKeys[1] );
		table.remove( listOfKeys[2] );
	end;
end;

local function rebuildPlayersList()
	print("rebuildPlayersList");
	--remove all 3 players buttons lists
	--build all 3 players button lists
end;

local function addPlayer( scrGroup )
	return function()
		local enterNameButton = display.newRoundedRect( scrGroup, display.contentCenterX, display.contentCenterY, 1000, 120, 5 );
		enterNameButton.strokeWidth = 3;
		enterNameButton:setFillColor( 0.77734375, 0.08203125, 0.51953125, 0.7 );
		local enterNameText = display.newText( scrGroup, "Enter New Player Name",
			display.contentCenterX, display.contentCenterY - 40, fontCommon, 30 );
		local nameField;
		local function nameListener( event )
			if ( event.phase == "ended" or event.phase == "submitted" ) then
				if event.target.text ~= "" then
					local pos = #players.ptable + 1; --players - Initplayer
					local playerName = event.target.text;
					table.insert( players.ptable, playerName );
					table.insert( players.games, {} );
					table.insert( players.played, {} );
					for i = 1, #gamesTable-1 do -- create in player personal table games table = #platforms
						table.insert( players.games[pos], {} );
						table.insert( players.played[pos], {} );
						for k = 1, #gamesTable[i+1] do --create zero filled table to every game in games table
							table.insert( players.games[pos][i], 0 );
							table.insert( players.played[pos][i], 0 );
						end;
					end;
				end;
		  	nameField:removeEventListener( "userInput", nameListener );
		  	nameField:removeSelf();
		  	enterNameButton:removeSelf();
		  	enterNameText:removeSelf();
		  	rebuildPlayersList();
		  end;
		end;
		nameField = native.newTextField( display.contentCenterX, display.contentCenterY + 20, 960, 60 );
		nameField:addEventListener( "userInput", nameListener );
	end;
end;

local function removePlayer()
	print("removePlayer");
end;

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view;
	-- Code here runs when the scene is first created but has not yet appeared on screen

	mainLayer = display.newGroup();
	sceneGroup:insert( mainLayer );
	overlayLayer = display.newGroup();
	sceneGroup:insert( overlayLayer );

  local background = display.newImageRect( mainLayer, "scene/menu/smb3.png", 1280, 720 );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;

  local horizontalLine = display.newLine( mainLayer, 0, 360, 1280, 360 );
  horizontalLine:setStrokeColor( 1, 1, 1, 1 );
  horizontalLine.strokeWidth = 3;

  local verticalLine = display.newLine( mainLayer, 640, 0, 640, 720 );
  verticalLine:setStrokeColor( 1, 1, 1, 1 );
  verticalLine.strokeWidth = 3;

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
	players.Table = loadBase( playersPath );

  local makeText = function( textOut, xPlace, yPlace )
  	local newText = display.newText( mainLayer, textOut, xPlace, yPlace, fontCommon, 30 );
  	newText.anchorX, newText.anchorY = 0.0, 0.0;
  	return newText;
	end

	textGames = makeText( "Games: " .. #gamesTable[players.platformChoice+1], 645, 0 );
  local textPlayers = makeText( "Players", 5, 0 );
  local textTeam = makeText( "Team", 5, 360 );
  local textPlanLeft = makeText( "Plan Left", 645, 360 );

	local overlay = display.newImageRect( overlayLayer, "scene/menu/mask.png", 1280, 720 );
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
		--Platform Keys
		buttonsGamesMenu = addKeysFromList( 800, 100, gamesTable[1], platformSelect );
		platformSelect( players.platformChoice )();
		print( players.platformChoice );

  --Player add and remove keys
	 	local buttonAddPlayerX, buttonAddPlayerY = 550, 30;

	  buttonAddPlayer = display.newRoundedRect( mainLayer, buttonAddPlayerX, buttonAddPlayerY, 40, 40, 5 );
		buttonAddPlayer.strokeWidth = 3;
		buttonAddPlayer:setFillColor( 0.0, 0.01 );
		buttonAddPlayer:addEventListener( "tap", addPlayer( mainLayer) );
		local buttonAddPlayerText = display.newText( mainLayer, "+", buttonAddPlayerX+2, buttonAddPlayerY, fontCommon, 26 );	

	  buttonRemovePlayer = display.newRoundedRect( mainLayer, buttonAddPlayerX+50, buttonAddPlayerY, 40, 40, 5 );
		buttonRemovePlayer.strokeWidth = 3;
		buttonRemovePlayer:setFillColor( 0.0, 0.01 );
		buttonRemovePlayer:addEventListener( "tap", removePlayer );
		local buttonRemovePlayerText = display.newText( mainLayer, "-", buttonAddPlayerX+52, buttonAddPlayerY, fontCommon, 26 );

		buttonGenerator = display.newRoundedRect( mainLayer, 1170, 25, 200, 40, 5 );
		buttonGenerator.strokeWidth = 3;
		buttonGenerator:setFillColor( 0.0, 0.01 );
		buttonGenerator:addEventListener( "tap", gotoGenerator );
		local buttonGeneratorText = display.newText( mainLayer, "to Generator", 1170, 25, fontCommon, 26 );

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- add scene update here
	end;
end;

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		removeKeysFromList( buttonsGamesMenu, platformSelect );

		buttonAddPlayer:removeEventListener( "tap", addPlayer(mainLayer) );
		buttonAddPlayer:removeSelf();

		buttonRemovePlayer:removeEventListener( "tap", removePlayer );
		buttonRemovePlayer:removeSelf();

		buttonGenerator:removeEventListener( "tap", gotoGenerator );
		buttonGenerator:removeSelf();

	end;
end;


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
