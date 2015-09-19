-- ============================================================================
-- Our gameCore object will store our main game code.  We define the fields of
-- the object here but functions get added later (you could add the fields
-- later as well, but organizationally I prefer this form).
-- ============================================================================
local perspective=require("perspective")


local gameCore = {

  -- The DisplayGroup for the gameScene.
  gameDG = nil,

  -- The DisplayGroup for the current level.  Anything that should be destroyed
  -- when moving to a new level should go here.
  levelDG = nil,
  
  levelMap = {}, --Level Map is a table that holds what block belongs at each coordinate
  
  --Control DG to put out front
  controlDG = nil,
  
  background = nil,
  
  -- Camera
   -- Include and create a view
  camera=perspective.createView();
  
  --Player
  player = {
      sequenceData = {
      { name = "walkRight", start = 1, count = 6, time = 500 },
      { name = "walkLeft", start = 7, count = 6, time = 500 },
      { name = "lookRight", start = 13, count = 1, time = 250 },
      { name = "lookLeft", start = 14, count = 1, time = 250 }
    },
	sprite = nil,
	movingLeft = false,
	movingRight = false,
	isJumping = false,
	prevVelocityX = 0,  -- These two variables are used to determine acceleration
	prevVelocityY = 0,	-- Player can only jump when vertical acceleration is zero 
						-- (zero velocity does not necessarily mean player can jump) 
						-- EX: Players head hit bottom of block, zero velocity, but cant jump because going downwards
	speed = 10 --Pixels/Frame
  },

  -- References to the on screen controls' display objects
  controls = {
    left = nil,
    right = nil,
    jump = nil,
	leftClicked = false,
	rightClicked = false,
	jumpClicked = false
  },

  -- Sound effects used throughout the game.
  sfx = {
  }

};


-- ============================================================================
-- Initialize the game.  We do one-time setup tasks here.  This is called
-- from createScene() in gameScene.
--
-- @param inDisplayGroup The DisplayGroup for the gameScene.
-- ============================================================================
function gameCore:init(inDisplayGroup)

  utils:log("gameCore", "init()");

  -- Save reference to the DisplayGroup for gameScene.
  gc.gameDG = inDisplayGroup;

  -- Start physics engine and turn gravity on.
  physics.start(true);
  physics.setDrawMode("normal");
  physics.setGravity(0, 30);
  
  -- Load graphical resources.
  gc.loadGraphics();

  -- Load sound effects,
  -- None during development mode
  
  -- Draw the current level.
  gc.generateLevel();
  -- gc.camera:add(gc.controlDG, 1, false);
--  gc.camera:add(gc.player.sprite, 2, true);
  gc.camera:add(gc.levelDG, 3, false);
--  gc.camera.damping=10
--  gc.camera:setBounds(false);
--  gc.camera:track();
  gc.gameDG:insert(gc.background);
  gc.gameDG:insert(gc.camera);
  gc.gameDG:insert(gc.controlDG);
  
  
  -- Now reset level state so we're good to go.
  gc.resetLevel();
  

end -- End init().


-- ============================================================================
-- Load all graphical resources for the game.
-- ============================================================================
function gameCore:loadGraphics()

  -- ********** Create the "static" elements on the screen. **********
	--gc.gameDG.x = 300;
  
  -- Background.
    gc.background = display.newRect(
		display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight
	);
	gc.background:setFillColor(
		graphics.newGradient( { 0, .3, 1 }, { 0, .75, 1 }, "down" )
	);
	--gc.gameDG:insert(bgGradient);
	
  --Player Sprite
  --[[gc.player.sprite = display.newSprite(
    graphics.newImageSheet("Images/spelunker_sprite.png",
      { width = 60, height = 87, numFrames = 14 }
    ),
    gc.player.sequenceData
  );	--display.newImage("Images/spelunker.png", true);
  gc.player.sprite.x, gc.player.sprite.y = display.contentCenterX, 100;
  local polyBody = { -20,-43.5,   20,-43.5,   29,-20,   29,20,   20,43.5,   -20,43.5,  -29,20,  -29,-20,}; --Shape of sprite physics body
  physics.addBody(
    gc.player.sprite, "dynamic", 
	{ density = 35, friction = 0.1, bounce = 0 , shape = polyBody}
  );
  gc.player.sprite.objName = "player";
  gc.player.sprite.isFixedRotation = true;
  gc.player.sprite:setSequence("lookRight");
  gc.player.sprite:play();]]--
  
  --gc.gameDG:insert(gc.player.sprite);
  
  --Controls
  gc.controlDG = display.newGroup();
  --Left Arrow
  local scale = .3;
  gc.controls.left = display.newImage("Images/left.png", true);
  gc.controls.left.anchorX, gc.controls.left.anchorY = 0,0;
  gc.controls.left:scale(scale,scale);
  gc.controls.left.x = 0;
  gc.controls.left.y = display.contentHeight - gc.controls.left.height * scale;
  gc.controls.left.alpha = 1;
  gc.controls.left.controlName = "left";
  gc.controlDG:insert(gc.controls.left);
  
  --Right Arrow
  gc.controls.right = display.newImage("Images/right.png", true);
  gc.controls.right.anchorX, gc.controls.right.anchorY = 0,0;
  gc.controls.right:scale(scale,scale);
  gc.controls.right.x = gc.controls.right.width * scale + 5; --5 is buffer between left and right
  gc.controls.right.y = display.contentHeight - gc.controls.right.height * scale;
  gc.controls.right.alpha = 1;
  gc.controls.right.controlName = "right";
  gc.controlDG:insert(gc.controls.right);
  
  --Jump Control
  gc.controls.jump = display.newImage("Images/up.png", true);
  gc.controls.jump.anchorX, gc.controls.jump.anchorY = 0,0;
  gc.controls.jump:scale(scale,scale);
  gc.controls.jump.x = display.contentWidth - gc.controls.jump.width * scale; --5 is buffer between left and jump
  gc.controls.jump.y = display.contentHeight - gc.controls.jump.height * scale;
  gc.controls.jump.alpha = 1;
  gc.controls.jump.controlName = "jump";
  gc.controlDG:insert(gc.controls.jump);

end -- End loadGraphics().


-- ============================================================================
-- Resets the game at the start of a level.
-- ============================================================================
function gameCore:resetLevel()

  utils:log("gameCore", "resetLevel()");

  -- Reset state (aka variables) as needed.
  
  --Bring UI things like left and right arrows to the front (Because they are covered up when drawCurrentLevel is called)
  gc.controls.left:toFront();
  gc.controls.right:toFront();
  gc.controls.jump:toFront();

end -- End resetLevel().


-- ============================================================================
-- Starts the game running.  This is called from enterScene() in gameScene.
-- ============================================================================
function gameCore:start()

  utils:log("gameCore", "start()");

  -- Activate multitouch.
  system.activate("multitouch")

  -- Add listeners for main loop and collision detection.
  Runtime:addEventListener("enterFrame", gc);
  Runtime:addEventListener("collision", gc);
  Runtime:addEventListener("touch", gc);

end -- End start().


-- ============================================================================
-- Stops the game running.  This is called from exitScene() in gameScene.
-- ============================================================================
function gameCore:stop()

  utils:log("gameCore", "stop()");

  -- Dectivate multitouch.
  system.deactivate("multitouch")

  -- Stop the physics engine.
  physics.stop();

  -- Remove listeners for main loop and collision detection.
  Runtime:removeEventListener("enterFrame", gc);
  Runtime:removeEventListener("collision", gc);
  Runtime:removeEventListener("touch", gc);

end -- End stop().


-- ============================================================================
-- Destroy any resources created for the game.
-- ============================================================================
function gameCore:destroy()

  utils:log("gameCore", "destroy()");

  -- Audio.  All must be stopped if playing, disposed of an nil'd.

  -- Graphics.

  -- Display Groups.  Note that gameDG already had removeSelf() called on it
  -- as part of the scene transition so we just need to nil the reference.
  gc.levelDG:removeSelf();
  gc.levelDG = nil;
  gc.gameDG = nil;


end -- End destroy().


-- ============================================================================
--	Generate level; Stores it in levelDG
-- ============================================================================
function gameCore:generateLevel()


  utils:log("gameCore", "drawCurrentLevel()");

  -- If this isn't the first time here we need to clean up the graphics from
  -- the last level drawing.
  if gc.levelDG ~= nil then
    gc.levelDG:removeSelf();
  end

  -- DisplayGroup for the elements of the level.
  gc.levelDG = display.newGroup();
  
  --This will generate play area that is 100 x 100
  local blockSize = 4;
  
  
  --Populate Level Map Table
  
  --Fill it all up with dirt
  for x = 1, 100, 1 do
	 gc.levelMap[x] = {};
	 for y = 1, 100, 1 do
		gc.levelMap[x][y] = "dirt";
	 end
  end
  
  --Carve Up Main Path
  local curY = 2; --These two points indicate where on the map the generator is currently working on
  local curX = 2;
  local direction = "right"; --Which way main path is going
  --Path width of future tunnel in down direction; Determined in direction == right or left blocks b/c it is needed for calculation purposes
  local pathWidth = 0;
  --Variable records height of previous obstacle made in main path. This is to lessen the sharp contrast between obstacle heights
  local prevObstacleHeight = 0; 
  
  local tunnelIncrement;
  local tunnelLength=15;
  local tunnelProb=30;
  
  
  while true do --Infinite loop, but broken whenever path generation calls break (to prevent path from going off bottom of map)
  	tunnelIncrement=0;
  	
  --Main Path
	if direction == "right" then
		
		
		--local tunnelLength=10;
		if math.random(1,100)>tunnelProb and curX>tunnelLength+5 then
			tunnelIncrement=tunnelLength;
		end
		local pathLength = math.random(15,100-curX)+tunnelIncrement; --Length of path segment
		local pathHeight = math.random(5,10); -- Height of path segment
		curX=curX-tunnelIncrement;
		--curX=curX;
		--curX=curX-math.random(0,pathLength/3);
		--print(curX);
		local dif=curX+pathLength-92;
		if dif>0 then
			--curX=curX-dif;
		end
		if curX<2 then
			--print("here");
			--curX=2;
		end
		--print(curX);
		
		--print(curX);
		if curY + pathHeight >= 100 then break end --Do not want to generate path that goes underneath map height of 100
		print("GOING RIGHT ..... pathLength " .. pathLength .. "  pathHeight " .. pathHeight);
		
		--Carving out air path
		  for x = curX, curX + pathLength - 1, 1 do
				if x >= 100 or x <= 1 then break end
				for y = curY, curY + pathHeight - 1, 1 do
					gc.levelMap[x][y] = "air";
					
				end
		  end
		 
		 pathWidth = math.random(3,5); --Of future down path
		--Adding dirt obstacles to air path, depending on path height
		prevObstacleHeight = 0;
		  for x = curX, curX + pathLength - pathWidth - 1, 1 do
				if x >= 100 or x <= 1 then break end
				
				if (math.random(0,10) > 5) then --Less chance of obstacle, easier to navigate path
					local obstacleHeight = math.random(0,pathHeight-2);
					if math.abs(obstacleHeight - prevObstacleHeight) > 2 then obstacleHeight = prevObstacleHeight; end
					prevObstacleHeight = obstacleHeight;
						
					for y = curY + pathHeight - 1, curY - obstacleHeight + pathHeight, -1 do
						gc.levelMap[x][y] = "dirt";		
					end
				else --Remain flat
					for y = curY + pathHeight - 1, curY - prevObstacleHeight + pathHeight, -1 do
						gc.levelMap[x][y] = "dirt";		
					end
				end
		  end
		  
		  --Switch direction to down and prepare curX and curY for this task also
		  --Leaving curY and curX as is gives undesirable effects
		  curX = curX + pathLength - pathWidth; 
		  if curX >= 100 then curX = 100-pathWidth end
		  if curX <= 1 then curX = 2 end
		  curY = curY + pathHeight; 

		  direction = "down";
	
	
	
	
	
	
	
	elseif direction == "down" then
	
		local pathHeight = math.random(4,7);
		if curY + pathHeight >= 100 then break end --Do not want to generate path that goes underneath map height of 100
		print("GOING DOWN ..... pathWidth " .. pathWidth .. "  pathHeight " .. pathHeight);
		
		--Carving out air path
		for x = curX, curX + pathWidth - 1, 1 do
			if x >= 100 or x <= 1 then break end
			for y = curY, curY + pathHeight - 1, 1 do
				gc.levelMap[x][y] = "air";
				end
		end
		
		--Switch direction to right or left, depending on position of curX and prepare curX and curY for this task also
		--Leaving curY and curX as is gives undesirable effects
		if curX > 50 then
		curX = curX + pathWidth - 1;
		curY = curY + pathHeight;
		direction = "left";
		else 
		curY = curY + pathHeight;
		direction = "right";
		end
		
		
		
		
		
		
		
	elseif direction == "left" then
		if math.random(1,100)>tunnelProb and 95-curX>tunnelLength then
			tunnelIncrement=tunnelLength;
		end
		local pathLength = math.random(15,curX-1)+tunnelIncrement; --Length of path segment
		local pathHeight = math.random(5,10); --Height of path segment
		--print("left "..pathLength);
		curX=curX+tunnelIncrement;
		
		if curY + pathHeight >= 100 then break end--Do not want to generate path that goes underneath map height of 100
		print("GOING LEFT ..... pathLength " .. pathLength .. "  pathHeight " .. pathHeight);
		
		--Carving out air path
		  for x = curX, curX - pathLength + 1, -1 do
				if x >= 100 or x <= 1 then break end
				for y = curY, curY + pathHeight - 1, 1 do
					gc.levelMap[x][y] = "air";
					
				end
		  end
		  
	    pathWidth = math.random(3,5); --Of future down path
		prevObstacleHeight = 0;
		--Adding dirt obstacles to air path, depending on path height
		  for x = curX, curX - pathLength + pathWidth + 1 , -1 do
				if x >= 100 or x <= 1 then break end
				
				if (math.random(0,10) > 5) then --Less chance of obstacle, easier to navigate path
					local obstacleHeight = math.random(0,pathHeight-2);
					if math.abs(obstacleHeight - prevObstacleHeight) > 2 then obstacleHeight = prevObstacleHeight; end
					prevObstacleHeight = obstacleHeight;
					
					for y = curY + pathHeight - 1, curY - obstacleHeight + pathHeight, -1 do
						gc.levelMap[x][y] = "dirt";	
					end
				else --Remain flat
					for y = curY + pathHeight - 1, curY - prevObstacleHeight + pathHeight, -1 do
						gc.levelMap[x][y] = "dirt";		
					end
				end
		  end
		  
		  --Switch direction to down and prepare curX and curY for this task also
		  --Leaving curY and curX as is gives undesirable effects
		  curX = curX - pathLength + 1; 
		  if curX >= 100 then curX = 99 end
		  if curX <= 1 then curX = 2 end
		  curY = curY + pathHeight; 

		  direction = "down";
		  
	end
  end
  
  --Shafts that Go Down
  local numShafts = math.random(5,10); --Number of mineshafts
  
  for i = 1, numShafts, 1 do

	local points = {}; --Point where we start mineshaft
	local shaftWidth = math.random(4,6);
	local shaftHeight = math.random(10,30);
	--Variables used to generate ruts
	local leftRutDistance = 2;
	local leftRutHeight = math.random(1,2);
	
	--Find possible points where we can create mineshaft
    for x = 1, 100, 1 do
	 for y = 1, 50, 1 do --All mineshafts start above y = 50
	 
		local isPossiblePoint = true;
		for w = x, x + shaftWidth - 1, 1 do
			if gc.levelMap[w][y] ~= "air" then
				isPossiblePoint = false;
				break;
			end
		end
		
		if isPossiblePoint == true then
			if (x + shaftWidth - 1) < 100 then
			table.insert(points, {x = x, y = y});
			end
		end
	 end
	end
	
	
	--Pick random point to start mineshaft from possible points
	local chosenPoint = points[math.random(1,#points)];
	for x = chosenPoint.x, (chosenPoint.x + shaftWidth - 1), 1 do
	 for y = chosenPoint.y, (chosenPoint.y + shaftHeight - 1), 1 do	
		gc.levelMap[x][y] = "air";
		end
	end
	
	
	for y = chosenPoint.y, (chosenPoint.y + shaftHeight - 1), 1 do	
		local x = chosenPoint.x;
		--Add climbing ruts to left of mineshaft
		if (gc.levelMap[x-1][y] ~= "air" or gc.levelMap[x+1][y] ~= "air") then
			--Adding little climbing ruts in the shaft
			if (leftRutHeight > 0) then
				gc.levelMap[x][y] = "dirt";
				leftRutHeight = leftRutHeight - 1;
			else
				if (leftRutDistance == 2) then
					if (gc.levelMap[x + shaftWidth - 2][y] ~= "air" or gc.levelMap[x + shaftWidth][y] ~= "air") then
					gc.levelMap[x + shaftWidth - 1][y] = "dirt";
					end
				end
				leftRutDistance = leftRutDistance - 1;
			end
			if (leftRutDistance == 0) then
				leftRutDistance = 2;
				leftRutHeight = math.random(1,2);
			end
		end
	end


  
  end

  
  --Add physics bodies based off level map
    for x = 1, 100, 1 do
	 for y = 1, 100, 1 do
		if gc.levelMap[x][y] == "dirt" then
			local pX = blockSize * (x - 1);
			local pY = blockSize * (y - 1);
			local tile;
			tile = display.newImage("Images/dirt.png", true);
			tile.x = pX;
			tile.y = pY;
			tile.anchorX, tile.anchorY = 0,0;
			tile.objName = "dirt";
			physics.addBody(
				tile, "static", { density = 1, friction = 2, bounce = 0 }
			);
			
			gc.levelDG:insert(tile);
		end
	 end
  end
  

end -- End drawCurrentLevel().


-- ============================================================================
-- Show a small, transient, expanding and fading message in the middle
-- of the screen.
--
-- @param inMsg The message to display
-- ============================================================================
function gameCore:showMessage(inMsg)

  utils:log("gameCore", "showMessage(): inMsg = " .. inMsg);

  -- Create message text.
  local msgText = display.newText(inMsg, 0, 0, nil, 20);
  msgText:setTextColor(1, 1, 0);
  msgText.x = display.contentCenterX;
  msgText.y = display.contentCenterY;
  msgText.alpha = 1;
  msgText.xScale = 1.0;
  msgText.yScale = 1.0;

  transition.to(msgText,
    { time = 1000, alpha = 0, xScale = 5.0, yScale = 5.0,
      onComplete = function(inTarget)
        inTarget:removeSelf();
        inTarget = nil;
      end
    }
  );

end -- End showMessage().


-- ============================================================================
-- Stops all in-game activity. 
-- Empty right now
-- ============================================================================
function gameCore:stopAllActivity()

end -- End stopAllActivity().


-- ****************************************************************************
-- All done defining gameCore, return it.
-- ****************************************************************************
return gameCore;
