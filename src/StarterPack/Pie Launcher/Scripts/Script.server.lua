--[[
	Create a pie for the player when the tool is equipped.
--]]


-- SERVICES --


-- MODULES --
local g_ScriptsFolder	=	script.Parent ;
local _G_Tool			=	g_ScriptsFolder.Parent ;
local Configurations	=	require( g_ScriptsFolder.Configurations );


-- CONSTANTS --
-- 'Transparency' values for the tool's built-in pie
local DISAPPEAR	=	1 ;	-- Should disappear when the pie is launched
local REAPPEAR	=	0 ;	-- Should reappear when the pie is reloaded


-- GLOBALS --
local _G_ActivePie	=	nil ;	-- Keep track of which pie will be launched next
local _G_BuiltInPie	=	_G_Tool.Pie ;
-- Events connections
local _G_ToolEquipped_Connection	=	nil ;
local _G_ToolUnequipped_Connection	=	nil ;
local _G_LaunchPie_Connection		=	nil ;
local _G_PieDamage_Connection		=	nil ;


-- FUNCTIONS --
local function  createPie ( Player )
	
	_G_ActivePie		=	game.ServerStorage.Models.Pie: Clone();
	_G_ActivePie.Name	=	"Pie" .. Player.UserId ;	-- Later need to directly reference this pie in the LocalScript
	_G_ActivePie.Parent	=	workspace.Pies ;
	
	_G_ActivePie: SetNetworkOwner( Player );	-- Need the LocalScript to manipulate physical properties of the pie
	
end


local function  on_Launch ( Player )
	
	wait( Configurations.LAUNCH_TIME );
	_G_BuiltInPie.Transparency	=	DISAPPEAR ;
	
	local OldPie	=	_G_ActivePie ;
	OldPie.Name		=	"OldPie" ;
	createPie( Player );
	
	wait( Configurations.COOLDOWN );
	_G_BuiltInPie.Transparency	=	REAPPEAR ;
	
	wait( Configurations.PIE_LIFETIME );
	OldPie: Destroy();	-- Clean up
	
end


local function  on_PieHitRobot ( Player , RobotCharacter , Pie )
	
	local RobotHumanoid	=	RobotCharacter: FindFirstChild( "Humanoid" );
	
	if RobotHumanoid
	then
		RobotHumanoid: TakeDamage( Configurations.DAMAGE );
	end
	
	Pie: Destroy();
	
end


local function  on_Equip ()
	
	local Character	=	_G_Tool.Parent ;
	local Player	=	game.Players: GetPlayerFromCharacter( Character );
	
	createPie( Player );
	
end


local function  on_Unequip ()
	
	-- Clean up
	if _G_ActivePie then  _G_ActivePie: Destroy();  end
	
end


_G_ToolEquipped_Connection		=	_G_Tool.Equipped:  Connect( on_Equip );
_G_ToolUnequipped_Connection	=	_G_Tool.Unequipped:  Connect( on_Unequip );
_G_LaunchPie_Connection			=	_G_Tool.LaunchPie.OnServerEvent:  Connect( on_Launch );
_G_PieDamage_Connection			=	_G_Tool.PieDamage.OnServerEvent:  Connect( on_PieHitRobot );
