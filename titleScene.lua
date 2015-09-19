local scene = storyboard.newScene();

-- Create a scene object to tie functions to.
local scene = storyboard.newScene();
local titleText;

-- ============================================================================
-- Called when the scene's view does not exist.
-- ============================================================================
function scene:createScene(inEvent)

  utils:log("titleScene", "createScene()");
  
  --Physics Warrior Text & Tween
  
    titleText =
    display.newText("Spelunky-Rim", display.contentCenterX, -200, "Times New Roman", 52);
	
	transition.to(titleText, { y = display.contentCenterY, 
		transition = easing.inOutQuad, time = 2000,
		onComplete = function()
		end
    });
	
	self.view:insert(titleText);

end -- End createScene().


-- ============================================================================
-- Called BEFORE scene has moved on screen.
-- ============================================================================
function scene:willEnterScene(inEvent)

  utils:log("titleScene", "willEnterScene()");

end -- End willEnterScene().


-- ============================================================================
-- Called AFTER scene has moved on screen.
-- ============================================================================
function scene:enterScene(inEvent)

  utils:log("titleScene", "enterScene()");

  -- Add event listener (not tied to a specific object).
  Runtime:addEventListener("touch", scene);

end -- End enterScene().


-- ============================================================================
-- Called BEFORE scene moves off screen.
-- ============================================================================
function scene:exitScene(inEvent)

  utils:log("titleScene", "exitScene()");

  -- Remove event listener (not tied to a specific object).
  Runtime:removeEventListener("touch", scene);

end -- End exitScene().


-- ============================================================================
-- Called AFTER scene has moved off screen.
-- ============================================================================
function scene:didExitScene(inEvent)

  utils:log("titleScene", "didExitScene()");

end -- End didExitScene().


-- ============================================================================
-- Called prior to the removal of scene's "view" (display group).
-- ============================================================================
function scene:destroyScene(inEvent)

  utils:log("titleScene", "destroyScene()");
  
  titleText:removeSelf();
  titleText = nil;
end -- End destroyScene().


-- ============================================================================
-- Handle touch events for this scene.
-- ============================================================================
function scene:touch(inEvent)

  utils:log("titleScene", "touch()");

  -- Only trigger when a finger is lifted.
    if inEvent.phase == "ended" then
		storyboard.gotoScene("gameScene", "slideLeft", 500);
	end
  return true;

end -- End touch().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("titleScene", "Beginning execution");

-- Add scene lifecycle event handlers.
scene:addEventListener("createScene", scene);
scene:addEventListener("willEnterScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("didExitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;