--[[
	Make the player’s character always face the mouse cursor.
	We will use a BodyGyro to make the character face the mouse. A BodyGyro will attempt to keep its parent at a set orientation.
	Prevent the character from jumping and climbing. We don’t have any ladders or pits in our game, so these two actions are unnecessary.
--]]


-- SERVICES --
local RunService	=	game: GetService( "RunService" ) ;


-- MODULES --



-- CONSTANTS --
local BINDING_NAME		=	"TrackMouse" ;	-- RenderStep label
local GYRO_POWER		=	50000 ;	-- How aggressively turn the character, make sure it is quick and responsive
local GYRO_MAX_TORQUE	=	Vector3.new( 0 , 10000 , 0 ) ;	-- Only rotate in the Y axis


-- GLOBALS --
local _G_LocalPlayer	=	game.Players.LocalPlayer ;
local _G_Gyro			=	nil ;
local _G_Mouse			=	_G_LocalPlayer: GetMouse() ;
_G_Mouse.TargetFilter	=	workspace.LevelGeometry ;	-- Make sure the mouse ignores all of the objects in the level (except for the terrain beneath)


-- FUNCTIONS --

-- Create a BodyGyro in a player’s character.
local function  onCharacterAdded ( Character )
	
	local Torso			=	Character: WaitForChild( "Torso" , 5 ) or Character: WaitForChild( "UpperTorso" ) ;
	_G_Gyro				=	Instance.new( "BodyGyro" , Torso ) ;
	_G_Gyro.P			=	GYRO_POWER ;
	_G_Gyro.MaxTorque	=	GYRO_MAX_TORQUE ;
	--_G_Gyro.Parent		=	Torso ;
	
	-- Prevent the character from being able to jump or climb.
	local Humanoid	=	Character: WaitForChild( "Humanoid" ) ;
	Humanoid: SetStateEnabled( Enum.HumanoidStateType.Jumping , false );
	Humanoid: SetStateEnabled( Enum.HumanoidStateType.Climbing , false );
	
end


-- Check if a number is actually a number. A simple Lua trick is to compare something to itself. Bad numbers will actually return false
local function  is_NaN ( number )  return  number ~= number ;  end


local function  is_Vector3_NaN ( vector3 )
	
	return  (is_NaN( vector3.X ) or is_NaN( vector3.Y ) or is_NaN( vector3.Z ));
	
end


-- Orient the BodyGyro to face the mouse.
local function  on_RenderStep ()
	
	local mousePos	=	_G_Mouse.Hit.p ;	-- Where the mouse is pointing
	
	-- Check if the mouse is actually pointing somewhere on the level
	-- This is particularly concerned when the game first launches when the level has not finished loading. In such cases, it’s possible for the mouse to be pointing at something off of the level which will make the position values of the mouse not a number.
	if not _G_Gyro or is_Vector3_NaN( mousePos ) then  return ;  end	-- Cover cases where the player’s character hasn’t spawned in yet, or mouse is positioned in a bad spot
	
	local Character	=	_G_LocalPlayer.Character ;
	local Torso_Or_UpperTorso	=	Character: WaitForChild( "UpperTorso" );
	local playerPos	=	Torso_Or_UpperTorso.Position ;
	_G_Gyro.CFrame	=	CFrame.new( playerPos , mousePos ) ;
	
end


--[[
	When a player joins the game for the first time, a character will automatically spawn. This script will run at the same time, so there is no guarantee whether this script will run before the character finishes loading. So, we add a small loop to wait until the player’s Character exists before we bind the onCharacterAdded function.
	
	We cannot use WaitForChild to delay the script until the character exists. WaitForChild is used when we are waiting for a descendant to be added to an instance (like with the Torso and character). In this case, Character is a property of the player and is not a child, so we cannot use WaitForChild.
--]]
while not _G_LocalPlayer.Character do  wait();  end
onCharacterAdded( _G_LocalPlayer.Character );

local LocalPlayerCharacterAdded_Connection	=	_G_LocalPlayer.CharacterAdded:  Connect( onCharacterAdded );

RunService: BindToRenderStep( BINDING_NAME , Enum.RenderPriority.Input.Value , on_RenderStep );
