--[[
	Determines when to perform its various actions.
--]]


-- CONSTANTS --
local UPDATE_DELTA	=	.1 ;


local RobotController	=	{};


-- Return distance between characters if there is nothing between them
local function  get_DistanceToCharacter ( Robot , Character )
	
	if not Character or Character.Humanoid.Health <= 0 then  return  nil ;  end
	
	local PlayerPosition	=	Character.Head.Position ;
	local RobotPosition		=	Robot.Head.Position ;
	local TowardsPlayer		=	PlayerPosition - RobotPosition ;
	local ray				=	Ray.new( RobotPosition , TowardsPlayer );
	local HitPart			=	workspace: FindPartOnRay( ray , Robot , false , false );
	
	if HitPart and HitPart: IsDescendantOf( Character )
	then
		return  TowardsPlayer.magnitude ;
	end
	
	return  nil ;
	
end


local function  get_ClosestVisibleCharacter ( Robot )
	
	local closestDistance	=	math.huge ;
	local closestCharacter	=	nil ;
	local allPlayers		=	game.Players: GetPlayers();
	
	for _ , currentPlayer in pairs( allPlayers )
	do
		local distance	=	get_DistanceToCharacter( Robot , currentPlayer.Character );
		
		if distance and distance < closestDistance
		then
			closestDistance		=	distance ;
			closestCharacter	=	currentPlayer.Character ;
		end
	end
	
	
	return  closestCharacter , closestDistance ;
	
end


-- Face player
local function  orientRobot ( Robot , Target )
	
	local Torso				=	Robot.Torso ;
	local TargetPosition	=	Target.HumanoidRootPart.Position ;
	Torso.BodyGyro.CFrame	=	CFrame.new( Torso.Position , TargetPosition );
	
end


function  RobotController: run_AI ( Robot , Configurations )
	
	while wait( UPDATE_DELTA ) and Robot.Humanoid.Health > 0	-- If the robot is knocked out, it doesn’t need to act anymore
	do
		local Target , targetDistance	=	get_ClosestVisibleCharacter( Robot );
		
		--if not Target then  return ;  end
		if Target
		then
			orientRobot( Robot , Target );
			
			if targetDistance <= Configurations.ACTION_DISTANCE then
				
				--takeAction( Target , Configurations );
				local now						=	tick();
				local timeSinceLastActionTick	=	now - Configurations.lastActionTick ;
				
				if timeSinceLastActionTick > Configurations.ACTION_COOLDOWN
				then
					spawn( function ()  Configurations.action( Target )  end );
					Configurations.lastActionTick	=	now ;
				end
				
			elseif targetDistance <= Configurations.AGGRO_DISTANCE then
				
				Configurations.aggro( Target );
				
			end
		end
		-- If the target is outside of either of those ranges, or if there isn’t a visible target at all, the robot will simply not do anything.
	end
	
end


return  RobotController ;
