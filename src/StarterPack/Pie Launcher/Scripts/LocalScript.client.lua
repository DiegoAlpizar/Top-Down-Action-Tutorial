--[[
	This script will be responsible for listening to the player’s input, playing an animation for the launch, launching the pie, and checking when that pie hits something.
	Technically, some of these tasks (with the exception of input) could be handled by a Script on the server. The problem with that is there will always be a slight delay between when the server performs actions and when a client sees them due to network latency. When working with a Tool, you want feedback and actions to be instantaneous. In this case, we can have the client handle these actions and then tell the server about them which will provide a seamless experience for the player.
--]]


-- SERVICES --


-- MODULES --
local g_ScriptsFolder	=	script.Parent ;
local _G_Tool			=	g_ScriptsFolder.Parent ;
local Configurations	=	require( g_ScriptsFolder: WaitForChild( "Configurations" ) );


-- CONSTANTS --
-- 'LocalTransparencyModifier' values for the tool's built-in pie
local DISAPPEAR	=	1 ;	-- Should disappear when the pie is launched
local REAPPEAR	=	0 ;	-- Should reappear when the pie is reloaded


-- GLOBALS --
local _G_LocalPlayer	=	game.Players.LocalPlayer ;
local _G_PiesFolder		=	workspace.Pies ;
local ACTIVE_PIE_NAME	=	"Pie" .. _G_LocalPlayer.UserId ;	-- Remains constant
--local _G_ActivePie		=	_G_PiesFolder: WaitForChild( ACTIVE_PIE_NAME );	-- Pause while the server creates the pie to be launched next
local _G_ActivePie		=	nil ;	-- Keep track of which pie will be launched next
local _G_BuiltInPie		=	_G_Tool.Pie ;
local _G_AnimationTrack	=	nil ;	-- Launching animation
local _G_debounce		=	false ;
-- Events connections:
local _G_ToolEquipped_Connection	=	nil ;
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
	
	-- Need this inner scope (private) for each 'Pie' passed in.
	local alreadyDealtDamage	=	false ;	-- If this Pie already dealt its damage to a character
	local PieTouched_Connection	=	nil ;	-- This Pie's event connection
	
	-- Check when the pie hits a robot so we can damage him
	local function  on_PieTouched ( ContactPart )	-- Declared here cause need 'alreadyDealtDamage' outter scope
		
		if alreadyDealtDamage then  return ;  end
		
		local Character	=	findCharacterRecursive( ContactPart );
		
		-- Check if the hit object is a character and make sure the character is not a player (and therefore a robot)
		if not Character or game.Players: GetPlayerFromCharacter( Character ) then  return ;  end
		
		-- If do hit a robot then
		alreadyDealtDamage	=	true ;
		-- Damage the robot
		_G_Tool.PieDamage: FireServer( Character , Pie );
		PieTouched_Connection: Disconnect();
		
	end
	
	PieTouched_Connection	=	Pie.Touched: Connect( on_PieTouched );
	
end


--[[
----
local function  get_OnPieTouched_Function ( Pie )
	
	-- Need this inner scope (private) for each 'Pie' passed in.
	local alreadyDealtDamage	=	false ;	-- If this Pie already dealt its damage to a character
	
	return  function ( ContactPart )
		
		if alreadyDealtDamage then  return ;  end
		
		local Character	=	findCharacterRecursive( ContactPart );
		
		-- Check if the hit object is a character and make sure the character is not a player (and therefore a robot)
		if not Character or game.Players: GetPlayerFromCharacter( Character ) then  return ;  end
		
		-- If hit a robot then
		alreadyDealtDamage	=	true ;
		-- Damage the robot
		_G_Tool.PieDamage: FireServer( Character , Pie );
		
	end
	
end


local function  bind_OnPieTouched ( Pie )
	
	local on_PieTouched			=	get_OnPieTouched_Function( Pie );
	local PieTouched_Connection	=	Pie.Touched:  Connect( on_PieTouched );	-- This Pie's event connection
	
end
----
--]]


local function  launchPie ()
	
	local Direction			=	_G_Tool.Handle.CFrame.LookVector ;
	_G_ActivePie.CFrame		=	_G_BuiltInPie.CFrame ;	-- Start position
	_G_ActivePie.Velocity	=	Direction * Configurations.LAUNCH_SPEED ;
	_G_ActivePie.Name		=	"OldPie" ;	-- Avoid reusing the same pie on every launch
	
end


local function  on_Equip ()
	
	local Humanoid		=	_G_LocalPlayer.Character.Humanoid ;
	_G_AnimationTrack	=	Humanoid: LoadAnimation( _G_Tool.Animation );
	_G_ActivePie		=	_G_PiesFolder: WaitForChild( ACTIVE_PIE_NAME );	-- Pause while the server creates the pie to be launched next
	
end


local function  on_Activate ()
	
	if _G_debounce then  return ;  end
	
	_G_debounce	=	true ;
	
	-- Create a new pie so the player can have several pies in the air at once.
	_G_Tool.LaunchPie: FireServer();
	_G_AnimationTrack: Play();
	
	wait( Configurations.LAUNCH_TIME );
	_G_BuiltInPie.LocalTransparencyModifier	=	DISAPPEAR ;
	
	-- Check for this pie's collisions and fire server to deal damage if hit a bot
	bind_OnPieTouched( _G_ActivePie );
	-- Launch the pie during the animation
	launchPie();
	-- Reload (get new pie)
	_G_ActivePie	=	_G_PiesFolder: WaitForChild( ACTIVE_PIE_NAME );
	
	wait( Configurations.COOLDOWN );
	_G_BuiltInPie.LocalTransparencyModifier	=	REAPPEAR ;
	
	_G_debounce	=	false ;
	
end


_G_ToolEquipped_Connection	=	_G_Tool.Equipped:  Connect( on_Equip );
_G_ToolActivated_Connection	=	_G_Tool.Activated:  Connect( on_Activate );
