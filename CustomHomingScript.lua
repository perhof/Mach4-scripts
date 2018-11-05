---------------------------------------------------------------
-- Ref All Home() function.

-- Custom homing routine by perhof. Version 18.11.05
---------------------------------------------------------------
function RefAllHome()
	
	local BACKOFF_DISTANCE = 0.5  	--How far to back off before homing againM. Modify distance according to your units and to suite your home switches
	
	local SPEED_FACTOR = 0.05 		--Multiply first homing speed with this value to get the second homing speed.
									--0.05 means 1/20th of the first homing speed which is specified in control configuration.
	
	-- Perform a first standard homing at speed according to control configuration
	-- Set a higher speed than you normally would in control configuration to speed up
	-- the first homing round.
	mc.mcAxisDerefAll(inst)
	mc.mcAxisHomeAll(inst)
	coroutine.yield()

	-- Now prepare back-off and second homing at slower speed

	-- Loop through axis 0 to 5 and gather axis parameters
	AxisNames = {"X","Y","Z","A","B","C"}
	AxisHomeOrder = {}
	AxisHomeInPlace = {}
	AxisHomeSpeed = {}
	AxisHomeDir = {}
	for AxisId=0, 5 do
		AxisHomeOrder[AxisId], rc = mc.mcAxisGetHomeOrder(inst, AxisId)
		AxisHomeInPlace[AxisId], rc = mc.mcAxisGetHomeInPlace(inst, AxisId)
		AxisHomeSpeed[AxisId], rc = mc.mcAxisGetHomeSpeed(inst, AxisId)
		AxisHomeDir[AxisId],rc = mc.mcAxisGetHomeDir(inst, AxisId)
	end
	
	-- Find axes that should be backed off in reverse homing order starting with order 6, then 5 and so on.
	-- Not configured axes should have a HomeOrder of 0
	for HomeOrder=6, 1, -1 do
		
		-- check each axis to find out if any axes should be homed at this order	
		local BackoffGcode = "G53 G0"
		local OrderAxes = 0
		for AxisId=0, 5 do
			-- Only touch an axis that should be homed at this order and is not set to 'Home In Place'
			if (AxisHomeOrder[AxisId]==HomeOrder) and (AxisHomeInPlace[AxisId]==0) then
				
				-- Build Gcode command for back off
				-- If the value for axis homing direction is positive we add a minus to the back-off distance
				-- to move the opposite way
				local HomeDir = ""
				if AxisHomeDir[AxisId]>0 then
					HomeDir = "-"
				end
				BackoffGcode = BackoffGcode.." "..AxisNames[AxisId+1]..HomeDir..tostring(BACKOFF_DISTANCE)
				
				-- Set slow homing speed for current axis
				mc.mcAxisSetHomeSpeed(inst, AxisId,  AxisHomeSpeed[AxisId]*SPEED_FACTOR)
				
				-- Increase number of axes to back off
				OrderAxes = OrderAxes + 1
			end
		end
		
		-- Back off axes for this homing order if any were found
		if OrderAxes>0 then 
			mc.mcCntlGcodeExecute(inst, BackoffGcode)
			coroutine.yield()
		end
	end
	
	-- Perform second homing at slow speed
	mc.mcAxisDerefAll(inst)
	mc.mcAxisHomeAll(inst)
	coroutine.yield()
	
	-- Restore homing speeds to previous values
	for AxisId = 0, 5 do
		mc.mcAxisSetHomeSpeed(inst, AxisId, AxisHomeSpeed[AxisId]);
	end
	coroutine.yield()
	
	wx.wxMessageBox('Referencing is complete')
end
