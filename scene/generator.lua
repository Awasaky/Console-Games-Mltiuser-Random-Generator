local composer = require( "composer" );
local scene = composer.newScene();

local json = require( "json" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local fontCommon = "Arial Black";
local mainLayer, overlayLayer; -- screen layers

local players =	composer.getVariable( "players" ); -- data from menu
local gamesTable = composer.getVariable( "gamesTable" );

-- Generated games
local genTable = {
	games = {},
	buttons = {}
};
-- session data
local session = {
	isActive = false,
	pause = false,
	blink = true, -- when true - show timer digits, else - hide
	colonCheck = {}, -- timer object to update blinking
	startTime = 0, -- usage to check delta time = system.timer - startTime
	initial = 0, -- temporal variable to save starting timer value
	timer = 15 * 60000 -- session time
};
local subsTime = 5 * 60000; -- step of timer change with buttons

local bTimeX, bTimeY = 580, 25; -- info to position timer button, time+/time/break/finish keys

local buttonNext, buttonNextText; -- button to call next game generator
local buttonClearList, buttonClearListText; -- button to clear list of generated games
-- buttons of timer and change sesson length
local buttonTime, buttonTimeText, buttonTimeMoreText, buttonTimeMore, buttonTimeLessText, buttonTimeLess;
-- buttons to cancel and finish session
local buttonCancel, buttonCancelText, buttonFinish, buttonFinishText;

local platformInfo; -- text object about selected platform games
local buttonsTeam; -- buttons of players in session
local playerSelected = 0; -- that player selected to start session

-- fill platformInfo text
local function platformText()
	local platformName = gamesTable[1][players.platformChoice]
	local platformGamesNumber = #gamesTable[players.platformChoice + 1];
	local platformGamesNotPlayed = #gamesTable[players.platformChoice + 1];
	local platformGamesNotViewed = #gamesTable[players.platformChoice + 1];
	
	for k = #gamesTable[players.platformChoice + 1], 1, -1 do
		for i = #players.team, 1, -1 do
			if players.games[ players.team[i] ][ players.platformChoice ][ k ] > 0 then
				platformGamesNotPlayed = platformGamesNotPlayed - 1;
				break;
			end;
		end;

		for i = #players.team, 1, -1 do
			if players.views[ players.team[i] ][ players.platformChoice ][ k ] > 0 then
				platformGamesNotViewed = platformGamesNotViewed - 1;
				break;
			end;
		end;
	end;

	local ptext = platformName .. "\ntotal games "  .. platformGamesNumber ..
		"\nnot played " .. platformGamesNotPlayed ..
		"\nnot seen " .. platformGamesNotViewed;
	return ptext;
end;

-- -------------------------------------------------------
-- Generating game
-- -------------------------------------------------------

-- return random game information = remove button, how much players played, how much plays total,
-- how much viewed, how much views total, name of game, player is played or does'not
local function generateGame()
	local rndg = {};
	-- repeat random, while number = any exist game in table.
	repeat
		local generateAgain = true;
		rndg.number = math.random( #gamesTable[players.platformChoice + 1] );
		if #genTable.games < 1 then break; end; --if not generated any game, check useless
		for i = #genTable.games, 1, -1 do
			if genTable.games[i].number == rndg.number then
				generateAgain = false;
				break;
			end;
		end;
	until generateAgain;
	local name = gamesTable[players.platformChoice + 1][rndg.number];
	rndg.name = #name < 45 and name or string.sub( name, 1, 42 ) .. "...";
	rndg.played = false;
	return rndg;
end;

local updateGames = function() end; -- empty function to exchange later

-- function to remove game if it not played
local function removeGame( position )
	return function()
		if not genTable.games[position].played then
			table.remove( genTable.games, position );
			updateGames();
		end;
	end;
end;

-- set played or not of generated game
local function gamePlayed( position )
	return function()
		genTable.games[position].played = not genTable.games[position].played;
		updateGames();
	end;
end;

-- Build buttons of genTable
local function makeGamesList( btnStartX, btnStartY, listOfKeys, callbackRemove, callbackPlayed )
	-- returns how much players played / total plays / viewed / total views
	local function counts( numberOfGame )
		local plyCount, plays, viewers, views = 0, 0, 0, 0;
		-- Need count players, who played this game
		local platform = players.platformChoice;
		for i = 1, #players.team do
			local playerNum = players.team[i];
			plyCount = players.games[playerNum][platform][numberOfGame] > 0 and plyCount + 1 or plyCount;
			plays = plays + players.games[playerNum][platform][numberOfGame];
			viewers = players.views[playerNum][platform][numberOfGame] > 0 and viewers + 1 or viewers;
			views = views + players.views[playerNum][platform][numberOfGame];
		end;
		return plyCount .. "/" .. plays .. "/" .. viewers .. "/" .. views .. ": ";
	end;

	local gamesList = {};
	local buttonNowY = btnStartY;
  for i = 1, #listOfKeys do
  	table.insert( gamesList, {} );
		-- add played button
		local playedButton = display.newRoundedRect( mainLayer, btnStartX, buttonNowY, 40, 40, 5 );
		playedButton.strokeWidth = 3;
		playedButton:setFillColor( 0.0, 0.01 );
		local playedButtonText = display.newText( mainLayer,
			genTable.games[i].played == false and "-" or "+",
			btnStartX, buttonNowY, fontCommon, 26 );
		-- generate text Players/Plays/Viewers/Views: Game
		local gameRect = display.newRoundedRect( mainLayer, 25 + btnStartX, buttonNowY, 850, 40, 5 );
		gameRect.anchorX = 0.0;
		gameRect.strokeWidth = 3;
		gameRect:setFillColor( 0.0, 0.01 );
		local gameRectText = display.newText( mainLayer, counts( listOfKeys[i].number ) .. listOfKeys[i].name,
			35 + btnStartX, buttonNowY, fontCommon, 26 );
		gameRectText.anchorX = 0.0;
		-- add remove button
		local removeButton = display.newRoundedRect( mainLayer, 905 + btnStartX, buttonNowY, 40, 40, 5 );
		removeButton.strokeWidth = 3;
		removeButton:setFillColor( 0.0, 0.01 );
		local removeButtonText = display.newText( mainLayer, "X", 905 + btnStartX, buttonNowY, fontCommon, 26 );
	  
	  gamesList[i].playedButton = playedButton;
	  gamesList[i].playedButtonText = playedButtonText;
		gamesList[i].gameRect = gameRect;
		gamesList[i].gameRectText = gameRectText;
		gamesList[i].removeButton = removeButton;
	  gamesList[i].removeButtonText = removeButtonText;

	  gamesList[i].playedButton:addEventListener( "tap", callbackPlayed( i ) );
	  gamesList[i].removeButton:addEventListener( "tap", callbackRemove( i ) );
	  
	  buttonNowY = buttonNowY + 55 ;
  end;
  return gamesList;
end;

-- Remove buttons of genTable
local function removeGamesList( listOfKeys, callbackRemove, callbackPlayed )
	if #listOfKeys < 1 then
		return;
	end;
	for i = #listOfKeys, 1, -1 do
		listOfKeys[i].removeButton:removeEventListener( "tap", callbackRemove );
		listOfKeys[i].playedButton:removeEventListener( "tap", callbackPlayed );
		listOfKeys[i].removeButton:removeSelf();
	  listOfKeys[i].removeButtonText:removeSelf();
		listOfKeys[i].gameRect:removeSelf();
		listOfKeys[i].gameRectText:removeSelf();
	  listOfKeys[i].playedButton:removeSelf();
	  listOfKeys[i].playedButtonText:removeSelf();
	  table.remove( listOfKeys );
	end;
end;

-- Call back to key "Next Game?" Add to genTable new generated game
local function nextGame()
	return function()
		if #genTable.games > 10 then
			return;
		end;
		table.insert( genTable.games, generateGame() );
		updateGames();
	end;
end;

-- Update generated games list
updateGames = function ()
	removeGamesList( genTable.buttons, removeGame, gamePlayed );
	genTable.buttons = makeGamesList( 25, 130, genTable.games, removeGame, gamePlayed );
end;

-- Remove not played games
local function clearGamesTable()
	removeGamesList( genTable.buttons, removeGame, gamePlayed );
	for i = #genTable.games, 1, -1 do
		if not genTable.games[i].played then
				table.remove( genTable.games, i );
		end;
	end;
	genTable.buttons = makeGamesList( 25, 130, genTable.games, removeGame, gamePlayed );
end;

-- -------------------------------------------------------
-- Players actions
-- -------------------------------------------------------

-- Return list of Players Names from numbers
local function listOfNames( numbersList )
	local namesList = {};
	for i = 1, #numbersList do
		table.insert( namesList, players.ptable[ numbersList[i] ] );
	end;
	return namesList;
end;

-- Build buttons of players. If player selected his shows at top bar
local function addPlayersList( btnStartX, btnStartY, listOfKeys, callback )
	local keysList = {{},{}};
	local buttonNowY = btnStartY;
	local fixedX = 370;
	local fixedY = 25;
  for i = 1, #listOfKeys do
		local newButton = display.newRoundedRect( mainLayer,
			i == playerSelected and fixedX or btnStartX,
			i == playerSelected and fixedY or buttonNowY,
			300, 40, 5 );
		newButton.strokeWidth = 3;
		newButton:setFillColor( 0.0, 0.01 );
		newButton:addEventListener( "tap", callback( i ) );
		local newButtonText = display.newText( mainLayer, i .. ": " .. listOfKeys[i],
			i == playerSelected and fixedX or btnStartX,
			i == playerSelected and fixedY or buttonNowY,
			fontCommon, 26 );
	  table.insert( keysList[1], newButton );
	  table.insert( keysList[2], newButtonText );
	  buttonNowY = i == playerSelected and buttonNowY or buttonNowY + 55;
  end;
  return keysList;
end;

-- Remove buttons of players
local function removePlayersList( listOfKeys, callback )
	if #listOfKeys < 1 then
		return;
	end;
	for i = #listOfKeys[1], 1, -1 do
		listOfKeys[1][i]:removeEventListener( "tap", callback(i) );
		listOfKeys[1][i]:removeSelf();
		listOfKeys[2][i]:removeSelf();
		table.remove( listOfKeys[1] );
		table.remove( listOfKeys[2] );
	end;
end;

-- callback of players buttons
local function playerSelect( pos )
	return function()
		if session.isActive then
			return;
		end;
		playerSelected = playerSelected == pos and 0 or pos;
		removePlayersList( buttonsTeam, playerSelect);
		buttonsTeam = addPlayersList( 1120, 250, listOfNames( players.team ), playerSelect );
	end;
end;

-- -------------------------------------------------------
-- Timer Events
-- -------------------------------------------------------

-- return mins and seconds to screen clock
local function returnMinSec()
	local string = "";
	local mins = string.format( "%02d", math.floor( session.timer/60000 ) );
	local secs = string.format( "%02d",  math.floor( ( session.timer - mins * 60000 ) / 1000 ) );
	string = mins .. ( session.blink and ":" or " " ) .. secs;
	if session.pause and not session.blink then
		return ":";
	end;
	return string;
end;

-- add to timer 5 mins
local function moreTime()
	session.timer = session.timer + subsTime;
	buttonTimeText.text = returnMinSec();
end;

-- remove 5 mins from timer
local function lessTime()
	session.timer = session.timer > subsTime and session.timer - subsTime or subsTime;
	buttonTimeText.text = returnMinSec();
end;

-- add keys to time+ and time-
local function addTimerKeys()
	buttonTimeMoreText = display.newText( mainLayer, "time+" , 105 + bTimeX, bTimeY, fontCommon, 26 );
	buttonTimeMore = display.newRoundedRect( mainLayer, 105 + bTimeX, bTimeY, 100, 40, 5 );
	buttonTimeMore.strokeWidth = 3;
	buttonTimeMore:setFillColor( 0.0, 0.01 );
	buttonTimeMore:addEventListener( "tap", moreTime );

	buttonTimeLessText = display.newText( mainLayer, "time-" , 210 + bTimeX, bTimeY, fontCommon, 26 );
	buttonTimeLess = display.newRoundedRect( mainLayer, 210 + bTimeX, bTimeY, 100, 40, 5 );
	buttonTimeLess.strokeWidth = 3;
	buttonTimeLess:setFillColor( 0.0, 0.01 );
	buttonTimeLess:addEventListener( "tap", lessTime );
end;

-- remove keys from time+ and time-
local function removeTimerKeys()
	buttonTimeMore:removeEventListener( "tap", moreTime );
	buttonTimeMore:removeSelf();
	buttonTimeMoreText:removeSelf();
	buttonTimeLess:removeEventListener( "tap", lessTime );
	buttonTimeLess:removeSelf();
	buttonTimeLessText:removeSelf();
end;

-- -------------------------------------------------------
-- Session Events
-- -------------------------------------------------------

local removeSessionKeys = function() end;  -- empty function to exchange later

-- cancel session, reset timer, return timer controls
local function cancelSession()
	session.isActive = false;
	session.pause = false;
	session.blink = true;
	timer.cancel( session.colonCheck );
	session.timer = session.initial;
	removeSessionKeys();
	addTimerKeys();
	buttonTimeText.text = returnMinSec();
end;

-- finish session, reset timer, save played and viewed games, remove all games
local function finishSession()
	if #players.team > 0 then -- check any player exist
		for i = #genTable.games, 1, -1 do -- viewed and played update cycle
			local plNum = players.team[playerSelected];
			local pfNum = players.platformChoice;
			local gmNum = genTable.games[i].number;
			if playerSelected > 0 then -- played update cycle
				players.games[ plNum ][ pfNum ][ gmNum ] = players.games[ plNum ][ pfNum ][ gmNum ] + 1;
			end;
			for k = #players.team, 1, -1 do -- viewed update cycle
				players.views[ players.team[k] ][ pfNum ][ gmNum ] = players.views[ players.team[k] ][ pfNum ][ gmNum ] + 1;
			end;
		end;
	end;
	cancelSession(); -- canceliing session, does same - reset timer and return controls
	-- complete remove generated games table
	for i = #genTable.games, 1, -1 do
		genTable.games[i].played = false;
	end;
	clearGamesTable();
	platformInfo.text = platformText();

	-- save players changes
	local baseFile = io.open( system.pathForFile( "players.json", system.DocumentsDirectory ), "w" );
	if baseFile then
	 	baseFile:write( json.encode( players ) );
	  io.close( baseFile );
	end;

end;

-- add keys cancel and finish session
local function addSessionKeys()
	buttonCancelText = display.newText( mainLayer, "break" , 105 + bTimeX, bTimeY, fontCommon, 26 );
	buttonCancel = display.newRoundedRect( mainLayer, 105 + bTimeX, bTimeY, 100, 40, 5 );
	buttonCancel.strokeWidth = 3;
	buttonCancel:setFillColor( 0.0, 0.01 );
	buttonCancel:addEventListener( "tap", cancelSession );

	buttonFinishText = display.newText( mainLayer, "finish" , 210 + bTimeX, bTimeY, fontCommon, 26 );
	buttonFinish = display.newRoundedRect( mainLayer, 210 + bTimeX, bTimeY, 100, 40, 5 );
	buttonFinish.strokeWidth = 3;
	buttonFinish:setFillColor( 0.0, 0.01 );
	buttonFinish:addEventListener( "tap", finishSession );
end;

-- remove keys cancel and finish session
removeSessionKeys = function()
	buttonCancel:removeEventListener( "tap", cancelSession );
	buttonCancel:removeSelf();
	buttonCancelText:removeSelf();
	buttonFinish:removeEventListener( "tap", finishSession );
	buttonFinish:removeSelf();
	buttonFinishText:removeSelf();
end;

-- Update timer look every 1000 sec
local function checkColon()
	session.blink = not session.blink;
	local refreshTimerRule = session.isActive and session.timer > 0 and not session.pause
	if refreshTimerRule then
		session.timer = session.timer - (system.getTimer() - session.startTime);
		session.startTime = system.getTimer();
	end;
	if session.timer <= 0 then
		session.timer = 0;
		session.pause = true;
	end;
	buttonTimeText.text = returnMinSec();
end;

-- start session or pause / resume timer logic
local function pressTime()
	if not session.isActive then
		session.isActive = true; -- up flag timer is active
		session.startTime = system.getTimer(); -- save time of start session
		session.initial = session.timer; -- value to save
		removeTimerKeys();
		addSessionKeys();
		session.colonCheck = timer.performWithDelay( 1000, checkColon, 0 );
	elseif not session.pause then
		session.pause = true;
	else
		session.pause = false;
		session.startTime = system.getTimer();
	end;
end;

-- -------------------------------------------------------
-- Special Events
-- -------------------------------------------------------

-- function to return to main menu
local function gotoMenu()
	removeGamesList( genTable.buttons, removeGame, gamePlayed );
	genTable.games = {};
	composer.gotoScene( "scene.menu", { effect = "fade", time = 300 } );
end;

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- initialize screen layers
	mainLayer = display.newGroup();
	sceneGroup:insert( mainLayer );
	overlayLayer = display.newGroup();
	sceneGroup:insert( overlayLayer );

	local background = display.newImageRect( mainLayer, "scene/menu/smb3.png", 1280, 720 );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;
  local nowplayingText = display.newText( mainLayer, "Now playing ", 110, 25, fontCommon, 30 );
  local buttonMenuText = display.newText( mainLayer, "to Main Menu", 1170, 25, fontCommon, 26 );

  local platformRect = display.newRoundedRect( mainLayer, 1270, 130, 280, 150, 5 );
	platformRect.strokeWidth = 3;
	platformRect:setFillColor( 0.0, 0.01 );
	platformRect.anchorX = 1.0;

	local gamesHead = display.newRoundedRect( mainLayer, 50, 80, 700, 40, 5 );
	gamesHead.strokeWidth = 3;
	gamesHead:setFillColor( 0.0, 0.01 );
	local gamesHeadText = display.newText( mainLayer, "Players/Plays/Viewers/Views: Game", 10 + 50, 80, fontCommon, 26 );
	gamesHead.anchorX = 0.0;
	gamesHeadText.anchorX = 0.0;

	-- visual overlay with scanlines
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

		buttonNextText = display.newText( mainLayer, "Next Game ?", 960, 25, fontCommon, 26 );
		buttonNext = display.newRoundedRect( mainLayer, 960, 25, 200, 40, 5 );
		buttonNext.strokeWidth = 3;
		buttonNext:setFillColor( 0.0, 0.01 );
		buttonNext:addEventListener( "tap", nextGame() );

		buttonTimeText = display.newText( mainLayer, returnMinSec() , bTimeX, bTimeY, fontCommon, 26 );
		buttonTime = display.newRoundedRect( mainLayer, bTimeX, bTimeY, 100, 40, 5 );
		buttonTime.strokeWidth = 3;
		buttonTime:setFillColor( 0.0, 0.01 );
		buttonTime:addEventListener( "tap", pressTime );

		buttonClearListText = display.newText( mainLayer, "clear games", 860, 80, fontCommon, 26 );
		buttonClearList = display.newRoundedRect( mainLayer, 860, 80, 200, 40, 5 );
		buttonClearList.strokeWidth = 3;
		buttonClearList:setFillColor( 0.0, 0.01 );
		buttonClearList:addEventListener( "tap", clearGamesTable );

		session.startTime = system.getTimer();
		addTimerKeys();
		
		platformInfo = display.newText( {
			x = 1260,
			y = 130,
			parent = mainLayer,
			text =  platformText(),
			font = fontCommon,
			fontSize = 26,
			align = "right"
		} );
		platformInfo.anchorX = 1.0;

		playerSelected = #players.team < 1 and 0 or playerSelected;
		buttonsTeam = addPlayersList( 1120, 250, listOfNames( players.team ), playerSelect );

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
		buttonMenu:removeEventListener( "tap", gotoMenu );
		buttonMenu:removeSelf();

		buttonNextText:removeSelf();		
		buttonNext:removeEventListener( "tap", nextGame );
		buttonNext:removeSelf();

		buttonTimeText:removeSelf();
		buttonTime:removeEventListener( "tap", pressTime );
		buttonTime:removeSelf();

		buttonClearListText:removeSelf();
		buttonClearList:removeEventListener( "tap", clearGamesTable );
		buttonClearList:removeSelf();

		if not session.isActive then
			removeTimerKeys();
		else
			cancelSession();
			removeSessionKeys();
		end;

		platformInfo:removeSelf();

		removePlayersList( buttonsTeam, playerSelect);
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