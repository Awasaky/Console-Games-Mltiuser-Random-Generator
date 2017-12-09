local composer = require( "composer" );
local scene = composer.newScene();

local json = require( "json" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local fontCommon = "Arial Black";
local mainLayer, overlayLayer; -- 
local gamesTable = {}; -- Table to loading gamebase
-- All information about players
local players = { ptable = {}, noteam = {}, team = {}, left = {}, games = {}, views = {}, platformChoice = 1 };
local textGames; -- information about selected platform and games quantity
-- Buttons to edit Players list
local buttonAddPlayer, buttonRemovePlayer, buttonAddPlayerText, buttonRemovePlayerText;
local playersRemoveActive = false; -- if false, then click move Players to Team, else to Left
-- Dynamic Menu Buttons tables
local buttonsGamesMenu, buttonsNoteamMenu, buttonsTeamMenu, buttonsLeftMenu = {}, {}, {}, {};

-- -------------------------------------------------------
-- Platform calls
-- -------------------------------------------------------
-- Callback closure to buttonsGamesMenu - makes bold selected button,
-- update players.platformChoice and platform information
local function platformSelect( platformNumber )
	return function()
		players.platformChoice = platformNumber;
		for i = 1, #gamesTable[1] do
			buttonsGamesMenu[1][i].strokeWidth = 3;
		end;
		buttonsGamesMenu[1][platformNumber].strokeWidth = 7;
		textGames.text = "Games: " .. #gamesTable[players.platformChoice + 1];
	end;
end;

-- Make max 10 buttons, with names of keys taken from list and assign everyone different callback closure
local function addKeysFromList( buttonStartX, buttonStartY, listOfKeys, callback )
	local keysList = {{},{}}; -- list of buttons with keys to return
	local buttonNowY = buttonStartY; -- assign staring positon
  for i = 1, #listOfKeys do -- making cycle
		-- adding button
		local newButton = display.newRoundedRect( mainLayer, buttonStartX, buttonNowY, 280, 40, 5 );
		newButton.strokeWidth = 3;
		newButton:setFillColor( 0.0, 0.01 );
		newButton:addEventListener( "tap", callback( i ) );
	  table.insert( keysList[1], newButton );
	  -- adding button text
		local newButtonText = display.newText( mainLayer, listOfKeys[i], buttonStartX, buttonNowY, fontCommon, 26 );
		table.insert( keysList[2], newButtonText );
	  buttonNowY = buttonNowY + 55 ; -- update positon
	  -- update row
	  if buttonNowY > buttonStartY + 225 then
	  	buttonStartX = buttonStartX + 300;
	  	buttonNowY = buttonStartY;
	  end;
  end;
  return keysList;
end;

-- Taken list with buttons + buttons texts, to clear it and remove callback
local function removeKeysFromList( listOfKeys, callback )
	if #listOfKeys < 1 then -- empty list check
		return;
	end;
	for i = #listOfKeys[1], 1, -1 do
		listOfKeys[1][i]:removeEventListener( "tap", callback(i) );
		listOfKeys[1][i]:removeSelf();
		table.remove( listOfKeys[1] ); -- remove button
		listOfKeys[2][i]:removeSelf();
		table.remove( listOfKeys[2] ); -- remove text
	end;
end;

-- -------------------------------------------------------
-- Selection Players Callbacks 
-- -------------------------------------------------------
local playersUpdateButtons = function() end; --empty function to exchange later
-- every callback use this function, but this function also call all of them

--Callback closure to buttonsNoteamMenu - move selected name to Team list, update all 3 players buttons
--or moves players to Left list if playersRemoveActive is true;
local function playersNoteamSelect( keyNumber )
	return function()
		local playerToMove = table.remove( players.noteam, keyNumber );
		if not playersRemoveActive then
			table.insert( players.team, playerToMove );
		else
			table.insert( players.left, playerToMove );
		end;
		playersUpdateButtons();
	end;
end;

--Callback closure to buttonsTeamMenu - move selected name to Players list, update all 3 players buttons
local function playersTeamSelect( keyNumber )
	return function()
		local playerToMove = table.remove( players.team, keyNumber );
		table.insert( players.noteam, playerToMove );
		playersUpdateButtons();
	end;
end;

--Callback closure to buttonsLeftMenu - move selected name to Players list, update all 3 players buttons
local function playersLeftSelect( keyNumber )
	return function()
		local playerToMove = table.remove( players.left, keyNumber );
		table.insert( players.noteam, playerToMove );
		playersUpdateButtons();
	end;
end;

--function to Update all 3 players buttons list
playersUpdateButtons = function()
	-- takes any numerical players list and return list of players names from ptable
	local function listOfNames( numbersList )
		local namesList = {};
		for i = 1, #numbersList do
			table.insert( namesList, players.ptable[ numbersList[ i ] ] );
		end;
		return namesList;
	end;
	removeKeysFromList( buttonsNoteamMenu, playersNoteamSelect );
	removeKeysFromList( buttonsTeamMenu, playersTeamSelect );
	removeKeysFromList( buttonsLeftMenu, playersLeftSelect );
	buttonsNoteamMenu = addKeysFromList( 160, 100, listOfNames( players.noteam ), playersNoteamSelect );
	buttonsTeamMenu = addKeysFromList( 160, 440, listOfNames( players.team ), playersTeamSelect );
	buttonsLeftMenu = addKeysFromList( 800, 440, listOfNames( players.left ), playersLeftSelect );
end;

-- -------------------------------------------------------
-- Special Events
-- -------------------------------------------------------

-- Callback to enter name of new player
local function playersAdd( scrGroup )
	return function()
		local enterNameButton = display.newRoundedRect( scrGroup, display.contentCenterX, display.contentCenterY, 1000, 120, 5 );
		enterNameButton.strokeWidth = 3;
		enterNameButton:setFillColor( 0.77734375, 0.08203125, 0.51953125, 0.7 );
		local enterNameText = display.newText( scrGroup, "Enter New Player Name",
			display.contentCenterX, display.contentCenterY - 40, fontCommon, 30 );
		local nameField; -- text field to input, also call on userinput nameListener function
		-- event to name input
		local function nameListener( event )
			if ( event.phase == "ended" or event.phase == "submitted" ) then
				-- check input text is not empty and players table have less 10 places
				if event.target.text ~= "" and #players.ptable < 10 then
					local pos = #players.ptable + 1; -- position of new player
					table.insert( players.ptable, event.target.text ); -- insert name in ptable
					table.insert( players.noteam, #players.ptable ); -- insert number of new player
					-- make new players database of games
					table.insert( players.games, {} );
					table.insert( players.views, {} );
					for i = 1, #gamesTable-1 do -- create in player personal table games table = #platforms
						table.insert( players.games[pos], {} );
						table.insert( players.views[pos], {} );
						for k = 1, #gamesTable[i+1] do --create zero filled table to every game in games table
							table.insert( players.games[pos][i], 0 );
							table.insert( players.views[pos][i], 0 );
						end;
					end;
				end;
				-- after creation of new player, clear all listeners and remove all objects, update players lists
		  	nameField:removeEventListener( "userInput", nameListener );
		  	nameField:removeSelf();
		  	enterNameButton:removeSelf();
		  	enterNameText:removeSelf();
		  	playersUpdateButtons();
		  end;
		end;
		-- create of name input
		nameField = native.newTextField( display.contentCenterX, display.contentCenterY + 20, 960, 60 );
		nameField:addEventListener( "userInput", nameListener );
	end;
end;

-- Callback switch to send player to Team of Left list
local function playersRemove()
	playersRemoveActive = not playersRemoveActive;
	buttonRemovePlayer.strokeWidth = playersRemoveActive and 7 or 3;
end;

-- Take every record in left list and remove this player from players base
local function removeLeftPlayers()
	if #players.left < 1 then -- empty players.left check
		return;
	end;
	for i = #players.left, 1, -1 do
		local playerToLeft = table.remove( players.left ); -- save number to remove from all 3 tables
		-- remove this player from all 3 tables
		table.remove( players.ptable, playerToLeft );
		table.remove( players.games, playerToLeft );
		table.remove( players.views, playerToLeft );
		-- update lists noteam and team to new indexation in ptable
		for k = 1, #players.noteam do
			if players.noteam[k] > playerToLeft then
				players.noteam[k] = players.noteam[i]-1;
			end;
		end;
		for k = 1, #players.team do
			if players.team[k] > playerToLeft then
				players.team[k] = players.team[i]-1;
			end;
		end;
	end;
	players.left = {}; -- clear left list
end;

--Open next scene function
local function gotoGenerator()
	removeLeftPlayers();
	if playersRemoveActive then -- check to activity of removal key
		playersRemove();
	end;
	-- record players table to Documents
	local baseFile = io.open( system.pathForFile( "players.json", system.DocumentsDirectory ), "w" );
	if baseFile then
	 	baseFile:write( json.encode( players ) );
	  io.close( baseFile );
	end;
	-- send data to generator
	composer.setVariable( "gamesTable", gamesTable );
	composer.setVariable( "players", players );
	-- switch scene to generator
	composer.gotoScene( "scene.generator", { effect = "fade", time = 300 } );
end;

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view;
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- create screen layers
	mainLayer = display.newGroup();
	sceneGroup:insert( mainLayer );
	overlayLayer = display.newGroup();
	sceneGroup:insert( overlayLayer );

	-- create background and lines to split screen
  local background = display.newImageRect( mainLayer, "scene/menu/smb3.png", 1280, 720 );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;
  local horizontalLine = display.newLine( mainLayer, 0, 360, 1280, 360 );
  horizontalLine.strokeWidth = 3;
  local verticalLine = display.newLine( mainLayer, 640, 0, 640, 720 );
  verticalLine.strokeWidth = 3;

  -- load json to base table
  local function loadBase( basePath, initialBase )
		local baseFile = io.open( basePath, "r" );
	  if baseFile then
	    local contents = baseFile:read( "*a" );
	    io.close( baseFile );
	    initialBase = json.decode( contents );
	  end;
	  return initialBase;
	end;

	local gamesPath = system.pathForFile( "scene/games.json", system.ResoursesDirectory );
	local playersPath = system.pathForFile( "players.json", system.DocumentsDirectory );
	gamesTable = loadBase( gamesPath, gamesTable ); -- load games
	players = loadBase( playersPath, players ); -- load players

	-- function to make header texts objects of all part of screen
  local function makeText( textOut, xPlace, yPlace )
  	local newText = display.newText( mainLayer, textOut, xPlace, yPlace, fontCommon, 30 );
  	newText.anchorX, newText.anchorY = 0.0, 0.0;
  	return newText;
	end;

	-- headers of parts of screen
	textGames = makeText( "Games: " .. #gamesTable[players.platformChoice + 1], 645, 0 );
  local textPlayers = makeText( "Players", 5, 0 );
  local textTeam = makeText( "Team", 5, 360 );
  local textPlanLeft = makeText( "Plan Left", 645, 360 );
  local buttonGeneratorText = display.newText( mainLayer, "to Generator", 1170, 25, fontCommon, 26 );

  -- scanlines overlay
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
		-- Platform Keys
		buttonsGamesMenu = addKeysFromList( 800, 100, gamesTable[1], platformSelect );
		platformSelect( players.platformChoice )();

	 	local buttonAddPlayerX, buttonAddPlayerY = 550, 30;
  
  	-- Player add and remove keys
	  buttonAddPlayer = display.newRoundedRect( mainLayer, buttonAddPlayerX, buttonAddPlayerY, 40, 40, 5 );
		buttonAddPlayer.strokeWidth = 3;
		buttonAddPlayer:setFillColor( 0.0, 0.01 );
		buttonAddPlayer:addEventListener( "tap", playersAdd( mainLayer) );
		buttonAddPlayerText = display.newText( mainLayer, "+", buttonAddPlayerX+2, buttonAddPlayerY, fontCommon, 26 );

	  buttonRemovePlayer = display.newRoundedRect( mainLayer, buttonAddPlayerX+50, buttonAddPlayerY, 40, 40, 5 );
		buttonRemovePlayer.strokeWidth = 3;
		buttonRemovePlayer:setFillColor( 0.0, 0.01 );
		buttonRemovePlayer:addEventListener( "tap", playersRemove );
		buttonRemovePlayerText = display.newText( mainLayer, "-", buttonAddPlayerX+52, buttonAddPlayerY, fontCommon, 26 );

		-- button to start generation
		buttonGenerator = display.newRoundedRect( mainLayer, 1170, 25, 200, 40, 5 );
		buttonGenerator.strokeWidth = 3;
		buttonGenerator:setFillColor( 0.0, 0.01 );
		buttonGenerator:addEventListener( "tap", gotoGenerator );

		playersUpdateButtons();

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
		-- remove all buttons list
		removeKeysFromList( buttonsGamesMenu, platformSelect );
		removeKeysFromList( buttonsNoteamMenu, playersNoteamSelect );
		removeKeysFromList( buttonsTeamMenu, playersTeamSelect );
		removeKeysFromList( buttonsLeftMenu, playersLeftSelect );

		-- remove interface buttons and texts
		buttonAddPlayer:removeEventListener( "tap", playersAdd(mainLayer) );
		buttonAddPlayer:removeSelf();
		buttonAddPlayerText:removeSelf();

		buttonRemovePlayer:removeEventListener( "tap", playersRemove );
		buttonRemovePlayer:removeSelf();
		buttonRemovePlayerText:removeSelf();

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
