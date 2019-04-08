--[[
	This robot does not attack the player directly, but instead will summon robot summoners (who will in turn summon PiBots) if he sees the player nearby.
--]]


-- MODULES --
local _G_AI_RobotController	=	require( game.ServerStorage.RobotScripts[ "AI Robot Controller" ] );


-- CONSTANTS --
local MAX_SUMMON_DISTANCE		=	10 ;	-- Make sure the summoner isn’t putting a robot on the other side of the map
local SUMMON_ACTIVATION_TIME	=	4 ;		-- The duration of the animation


-- GLOBALS --
local _G_Robot					=	script.Parent ;
local _G_RobotHumanoid			=	_G_Robot.Humanoid ;
local _G_SummonAnimationTrack	=	_G_RobotHumanoid: LoadAnimation( _G_Robot.SummonAnimation );

local _G_Configurations	=	{
	
	AGGRO_DISTANCE	=	30 ,
	ACTION_DISTANCE	=	30 ,
	ACTION_COOLDOWN	=	4 ,
	lastActionTick	=	0
	
};


-- FUNCTIONS --
function  _G_Configurations.aggro ( Target )
	
	
	
end


local function  enable_HandParticleEmitter ( whichHand , enabled )
	
	local Hand				=	_G_Robot: FindFirstChild( whichHand );
	local ParticleEmitter	=	Hand and Hand: FindFirstChild( "ParticleEmitter" );
	
	if not ParticleEmitter then  return ;  end
	
	ParticleEmitter.Enabled	=	enabled ;
	
end


local function  enable_BothHandsParticleEmitter ( enable )
	
	enable_HandParticleEmitter( "Right Hand" , enable );
	enable_HandParticleEmitter( "Left Hand" , enable );
	
end


-- summon a PiBot
function  _G_Configurations.action ( Target )
	
	enable_BothHandsParticleEmitter( true );
	_G_SummonAnimationTrack: Play();
	wait( SUMMON_ACTIVATION_TIME );
	enable_BothHandsParticleEmitter( false );
	
	-- Make sure the SummonerBot hasn’t been knocked out during the animation
	if _G_RobotHumanoid.Health <= 0 then  return ;  end
	
	local SummonedRobot		=	game.ServerStorage.Robots.SummonerBot: Clone();
	local PlayerPosition	=	Target.HumanoidRootPart.Position ;
	local RobotPosition		=	_G_Robot.HumanoidRootPart.Position ;
	local TowardsPlayer		=	PlayerPosition - RobotPosition ;	-- Direction vector
	local midDistance		=	TowardsPlayer.magnitude / 2 ;	-- In the middle of the player and Summoner
	-- Limit summon distance. If the player is closer than 'MAX_SUMMON_DISTANCE' studs though, we want to put the summon in between the player and the Summoner.
	local offsetDistance	=	math.min( MAX_SUMMON_DISTANCE , midDistance );
	local SummonOffset		=	TowardsPlayer.unit * offsetDistance ;
	local SummonPosition	=	_G_Robot.HumanoidRootPart.CFrame + SummonOffset ;
	
	-- Place the summoned robot in the correct position.
	if SummonedRobot.PrimaryPart
	then
		SummonedRobot: SetPrimaryPartCFrame( SummonPosition );
	end
	
	SummonedRobot.Parent	=	workspace.Robots ;	-- Trigger the ChildAdded event in our 'AI Script Giver' Script so the new robot gets its AI scripts.
	
end


_G_AI_RobotController: run_AI( _G_Robot , _G_Configurations );
