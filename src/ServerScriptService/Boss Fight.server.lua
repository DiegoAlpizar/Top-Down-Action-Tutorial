--[[
	Manage our boss fight and transition between the two phases.
	This fight will consist of two phases. In the first phase, the player must defeat the robot wizards that are powering the boss’s force field. After the wizards are gone, phase two starts, and the boss starts summoning robot summoners (who will in turn summon PiBots). If the player is able to defeat the boss in phase two, then they have won the game.
--]]


-- CONSTANTS --
local CLEAN_UP_TIMEOUT	=	1 ;


-- GLOBALS --
local _G_BossFightFolder	=	workspace.BossFight ;
local _G_DialogEvent		=	game.ReplicatedStorage.ShowDialog ;


local function  on_MrBossDead ()
	
	_G_DialogEvent: FireAllClients( "Boss" , "Ouch! You have bested me. This souffle has fallen!" , 5 );
	
end


-- Remove the force field that surrounds the boss so he can see the player and act accordingly
local function  startPhase2 ()
	
	local ForceField		=	_G_BossFightFolder.ForceField ;
	ForceField.CanCollide	=	false ;
	ForceField.Anchored		=	false ;
	
	wait( 2 );
	_G_DialogEvent: FireAllClients( "Boss" , "So, you think you have won? Robot wizards, to me!" , 2 );
	
	workspace.Robots.MrBoss.Humanoid.Died:  Connect( on_MrBossDead );
	
end


-- Just wait until all of the bots in '_G_BossFightFolder.ShieldBots' are defeated
local function  startPhase1 ()
	
	local allShieldBots	=	_G_BossFightFolder.ShieldBots: GetChildren();
	local numActiveBots	=	#allShieldBots ;
	
	for _ , currentBot in pairs( allShieldBots )
	do
		local RobotDead_Connection	=	nil ;
		
		local function  on_BotDead ()
			
			numActiveBots	=	numActiveBots - 1 ;
			
			if numActiveBots == 0
			then
				startPhase2();
			end
			
			wait( CLEAN_UP_TIMEOUT );
			RobotDead_Connection: Disconnect();
			RobotDead_Connection	=	nil ;	-- Help garbage collector ??
			currentBot: Destroy();
			
		end
		
		RobotDead_Connection	=	currentBot.Humanoid.Died:  Connect( on_BotDead );
	end
	
end


startPhase1();
