--[[
	The first type of enemy the player will encounter in the game is the PiBot. These robots will attack the player on sight and will give chase if the player tries to run away.
	Each robot will need a script to control its actions. There are a fair number of robots in the game, so instead of manually inserting a script into each one, let’s write a script to insert scripts automatically.
	The scripts have the same name as the robot models.
--]]


local _G_RobotScriptsFolder	=	game.ServerStorage.RobotScripts ;
local _G_RobotsFolder		=	workspace.Robots ;
--local _G_AllRobotScripts	=	_G_RobotScriptsFolder: GetChildren();
--local _G_RobotScriptsDictionary	=	{} ;
-- Events connections:
local _G_ChildAddedToRobotsFolder_Connection	=	nil ;


-- FUNCTIONS --
--[[
local function  map ()
	
	print( "MAP" )
	for _ , currentRobotScript in pairs( _G_AllRobotScripts )
	do
		_G_RobotScriptsDictionary[ currentRobotScript.Name ]	=	currentRobotScript ;
	end
	
end


local function  insert_AI_Scriptx ( ToRobot )
	
	local AI_Script	=	_G_RobotScriptsDictionary[ ToRobot.Name ]
	
	if not AI_Script
	then
		warn( "Bad script name" );
		return ;
	end
	
	AI_Script			=	AI_Script: Clone();
	AI_Script.Parent	=	ToRobot ;
	
end
--]]

local function  insert_AI_Script ( ToRobot )
	
	local AI_Script	=	_G_RobotScriptsFolder: FindFirstChild( ToRobot.Name );
	
	if not AI_Script
	then
		warn( "Bad script name" );
		return ;
	end
	
	AI_Script			=	AI_Script: Clone();
	AI_Script.Parent	=	ToRobot ;
	
	if ToRobot.Name == "PiBot"
	then
		local LauncherScript	=	_G_RobotScriptsFolder[ "Pie Launcher" ]: Clone();
		LauncherScript.Parent	=	ToRobot.Tool ;
	end
	
end


-- Inserts scripts into any new robots that get added to the game
local function  on_RobotAdded ( Robot )
	
	insert_AI_Script( Robot );
	
end


-- Inserts scripts into all of the robots already in the game.
local function  initial_AI_Insertion ()
	
	local allRobots	=	_G_RobotsFolder: GetChildren();
	
	for _ , currentRobot in pairs( allRobots )
	do
		insert_AI_Script( currentRobot );
	end
	
end


initial_AI_Insertion();

_G_ChildAddedToRobotsFolder_Connection	=	_G_RobotsFolder.ChildAdded:  Connect( on_RobotAdded );
