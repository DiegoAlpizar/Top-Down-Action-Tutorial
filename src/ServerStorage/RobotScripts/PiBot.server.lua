--[[
	The PiBot is the basic opponent in the game and is the first robot players will face. When they see a player, they move closer to that player and launch pies.
--]]


-- MODULES --
local _G_AI_RobotController	=	require( game.ServerStorage.RobotScripts[ "AI Robot Controller" ] );


-- CONSTANTS --
local CLEAN_UP_TIMEOUT	=	2 ;


-- GLOBALS --
local _G_Robot				=	script.Parent ;
local _G_Humanoid			=	_G_Robot.Humanoid ;
local _G_WalkAnimationTrack	=	_G_Humanoid: LoadAnimation( _G_Robot.WalkAnimation );
-- Events connections
local _G_RobotDead_Connection	=	nil ;


-- Behavior of the robot. This table will later be passed into a generic AI controller which will help our robot operate.
local Configurations	=	{
	
	AGGRO_DISTANCE	=	50 ,
	ACTION_DISTANCE	=	20 ,
	ACTION_COOLDOWN	=	2 ,
	lastActionTick	=	0
	
};


-- What will do when it first sees the player
function  Configurations.aggro ( Target )
	
	local PlayerPosition	=	Target: WaitForChild( "HumanoidRootPart" ).Position ;
	
	_G_Humanoid: MoveTo( PlayerPosition );
	
	if not _G_WalkAnimationTrack.IsPlaying
	then
		_G_WalkAnimationTrack: Play();
	end
	
end


local function  stopMoving ()
	
	local RobotPosition	=	_G_Robot.HumanoidRootPart.Position ;
	
	_G_Humanoid: MoveTo( RobotPosition );
	
end


-- What will do when it gets close to the player
function  Configurations.action ()
	
	local RobotPosition	=	_G_Robot.HumanoidRootPart.Position ;
	
	_G_Humanoid: MoveTo( RobotPosition );
	_G_WalkAnimationTrack: Stop();
	_G_Robot.Tool: Activate();
	
end


-- Cleanup
local function  on_Dead ()
	
	wait( CLEAN_UP_TIMEOUT );
	_G_Robot: Destroy();
	
end


_G_RobotDead_Connection	=	_G_Robot.Humanoid.Died:  Connect( on_Dead );

_G_AI_RobotController: run_AI( _G_Robot , Configurations );
