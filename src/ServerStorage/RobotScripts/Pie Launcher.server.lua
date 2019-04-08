--[[
	All of the PiBots have a tool already added that is identical to the one the player uses.
--]]


-- CONSTANTS --
local LAUNCH_TIME	=	.15 ;
local LAUNCH_SPEED	=	20 ;
local RELOAD_SPEED	=	1 ;
local PIE_LIFETIME	=	2 ;
local PIE_DAMAGE	=	20 ;
-- 'Transparency' values for the tool's built-in pie:
local DISAPPEAR	=	1 ;	-- Should disappear when the pie is launched
local REAPPEAR	=	0 ;	-- Should reappear when the pie is reloaded


-- GLOBALS --
local _G_Tool			=	script.Parent ;
local _G_Robot			=	_G_Tool.Parent ;
local _G_BuiltInPie		=	_G_Tool.Pie ;
local _G_AnimationTrack	=	_G_Robot.Humanoid: LoadAnimation( _G_Tool.Animation );
-- Events connections:
local _G_ToolActivated_Connection	=	nil ;


-- FUNCTIONS --
local function  findCharacterRecursive ( Object )
	
	-- Base case:
	if Object == workspace then  return  nil ;  end
	
	-- Base case:
	-- If the Object contains a Humanoid, then it is either an NPC like the robots or a player character
	if Object: FindFirstChild( "Humanoid" ) then  return  Object ;  end
	
	-- Recursive case:
	return  findCharacterRecursive( Object.Parent );
	
end


local function  bind_OnPieTouched ( Pie )
	
	-- Need this inner scope (private) for each 'Pie' passed in. (External local variable)
	--local alreadyDealtDamage	=	false ;	-- If this Pie already dealt its damage to a character
	local PieTouched_Connection	=	nil ;	-- This Pie's event connection
	
	-- Check when the pie hits a robot so we can damage him
	local function  on_PieTouched ( ContactPart )	-- Declared here cause need 'alreadyDealtDamage' outter scope (Upvalue)
		
		--if alreadyDealtDamage then  return ;  end
		--if not ContactPart or not ContactPart.Parent then  return ;  end  (???)		
		local Character	=	findCharacterRecursive( ContactPart );
		
		-- Check if the hit object is a character and make sure the character is a player
		if not Character or not game.Players: GetPlayerFromCharacter( Character ) then  return ;  end
		
		-- If do hit a player
		--alreadyDealtDamage	=	true ;
		-- Damage the player
		Character.Humanoid: TakeDamage( PIE_DAMAGE );
		PieTouched_Connection: Disconnect();
		PieTouched_Connection	=	nil ;	-- Help garbage collector ??
		Pie: Destroy();
		
	end
	
	PieTouched_Connection	=	Pie.Touched: Connect( on_PieTouched );
	
end


local function  launchPie ( Pie )
	
	local Direction	=	_G_Tool.Handle.CFrame.LookVector ;
	Pie.CFrame		=	_G_BuiltInPie.CFrame ;	-- Start position
	Pie.Velocity	=	Direction * LAUNCH_SPEED ;
	Pie.Parent		=	_G_Tool ;
	
	-- Make sure the server owns the physics
	Pie: SetNetworkOwner( nil );
	
end


local function  on_Activate ()
	
	local Pie	=	game.ServerStorage.Models.Pie: Clone();
	
	bind_OnPieTouched( Pie );
	_G_AnimationTrack: Play();
	
	wait( LAUNCH_TIME );
	_G_BuiltInPie.Transparency	=	DISAPPEAR ;	-- (Make it look like it is the one being flung)
	launchPie( Pie );
	
	wait( RELOAD_SPEED );
	_G_BuiltInPie.Transparency	=	REAPPEAR ;	-- (Reload)
	
	wait( PIE_LIFETIME );
	Pie: Destroy();
	
end


_G_ToolActivated_Connection	=	_G_Tool.Activated:  Connect( on_Activate );
