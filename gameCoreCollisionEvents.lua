-- ============================================================================
-- Handle collision events during gameplay.
--
-- @param inEvent The event object describing the event.
-- ============================================================================
function gc:collision(inEvent)

  -- Following are references to object names involved in collision
  --  inEvent.object1.objName;
  --  inEvent.object2.objName;


  -- Handle the beginning of collision events only.
  if inEvent.phase == "began" then

  end -- End began.

end -- End touch().

