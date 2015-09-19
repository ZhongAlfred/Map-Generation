-- ============================================================================
-- Handle touch events during gameplay.
--
-- @param inEvent The event object describing the event.
-- ============================================================================
local fingers = {};
local points = {}; --Point that each finger is currently touching

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function gc:touch(inEvent)

	--Testing multitouch --Multitouch seems to work good
	if inEvent.phase == "began" then
		if table.contains(fingers, inEvent.id) == false then
			table.insert(fingers, inEvent.id);
			table.insert(points, {x = inEvent.x, y = inEvent.y});
		end
	elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
		for i = 0, #fingers, 1 do
			if fingers[i] == inEvent.id then
				table.remove(fingers, i);
				table.remove(points, i);
			end
		end
	else
		for i = 0, #fingers, 1 do
			if fingers[i] == inEvent.id then
				points[i] = {x = inEvent.x, y = inEvent.y};
			end
		end
	end
	
	--print("----------------------");
	--print("Number of fingers: " .. #fingers);
	for i = 1, #fingers, 1 do
		--print("Finger# " .. i .. ":    X: " .. points[i].x .. "   Y: " .. points[i].y);
	end
	
	local button = gc.controls.left;
	local button2 = gc.controls.right;
	local button3 = gc.controls.jump;
	
	--Boolean flags
	gc.controls.leftClicked = false;
	gc.controls.rightClicked = false;
	gc.controls.jumpClicked= false;
	
	for i = 1, #points, 1 do
		if points[i].x >= button.x and points[i].x <= button.x + button.width * .3 
			and points[i].y >= button.y and points[i].y <= button.y + button.height * .3 then
			gc.controls.leftClicked = true;
			break;
		end
	end
	for i = 1, #points, 1 do
		if points[i].x >= button2.x and points[i].x <= button2.x + button2.width * .3 
			and points[i].y >= button2.y and points[i].y <= button2.y + button2.height * .3 then
			gc.controls.rightClicked = true;
			break;
		end
	end
	for i = 1, #points, 1 do
		if points[i].x >= button3.x and points[i].x <= button3.x + button3.width * .3 
			and points[i].y >= button3.y and points[i].y <= button3.y + button3.height * .3 then
			gc.controls.jumpClicked = true;
			break;
		end
	end
end -- End touch().

