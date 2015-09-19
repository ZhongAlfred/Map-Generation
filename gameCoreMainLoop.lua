-- ============================================================================
-- Our main game loop, executed each frame.
--
-- @param inEvent The event object describing the event.
-- ============================================================================
function gc:enterFrame(inEvent)

	--gc:processPlayer(inEvent);

end -- End enterFrame().

function gc:processPlayer(inEvent)
	
	--Calculate acceleration of player
	local vx, vy = gc.player.sprite:getLinearVelocity();
	local ax = (vx - gc.player.prevVelocityX) / .0333;
	local ay = (vy - gc.player.prevVelocityY) / .0333;
	
	--print("Acceleration: " .. ax .. ", " .. ay);
	--print("Velocity: " .. vx .. ", " .. vy);
	
	gc.player.prevVelocityX = vx;
	gc.player.prevVelocityY = vy;
	
	if ay == 0 then
		gc.player.isJumping = false;
	end
	
	--Moving player based on button user is currently clicking
	if gc.controls.jumpClicked and ay == 0 and gc.player.isJumping == false then --Jump only when acceleration is 0
		print("Jumping");
		gc.player.sprite:applyLinearImpulse(
			0, -5000, gc.player.sprite.x, gc.player.sprite.y
		); 
		gc.player.isTouchingGround = false;
	end
	
	if gc.controls.leftClicked and gc.controls.rightClicked == false then
		gc.player.sprite.x = gc.player.sprite.x - gc.player.speed;
		--gc.player.sprite:setLinearVelocity(-300,vy); --Change x velocity, but not y velocity
		if gc.player.sprite.sequence ~= "walkLeft" then
			 gc.player.sprite:setSequence("walkLeft");
			 gc.player.sprite:play();
		end
	elseif gc.controls.rightClicked and gc.controls.leftClicked == false then
		--gc.player.sprite:applyForce(10000, 0, gc.player.sprite.x, gc.player.sprite.y);
		gc.player.sprite.x = gc.player.sprite.x + gc.player.speed;
		--gc.player.sprite:setLinearVelocity(300,vy); --Change x velocity, but not y velocity
		if gc.player.sprite.sequence ~= "walkRight" then
			 gc.player.sprite:setSequence("walkRight");
			 gc.player.sprite:play();
		end	
	else
	    --gc.player.sprite:setLinearVelocity(0); --Change x velocity, but not y velocity
		if gc.player.sprite.sequence == "walkRight" then
			 gc.player.sprite:setSequence("lookRight");
			 gc.player.sprite:play();
		elseif gc.player.sprite.sequence == "walkLeft" then
			 gc.player.sprite:setSequence("lookLeft");
			 gc.player.sprite:play();
		end
	end

end -- End enterFrame().

