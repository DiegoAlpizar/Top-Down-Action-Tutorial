--[[
	Exploration is a big part of the top-down action genre. One mechanic we can add to the game are health packs that the player has to find in the environment. The level already has some health pack models included inside the HealthPacks Folder inside the Workspace. To get these health packs to work we need to do two things: disable the default health regeneration of characters and bind a function to the health packs’ touched events to heal players on contact.
--]]


local HEAL_AMOUNT	=	30 ;


local _G_PlayerAdded_Connection	=	nil ;


local function  bind_OnHealthPackTouched ( HealthPack )
	
	local HealthPackTouched_Connection	=	nil ;
	
	local function  on_HealthPackTouched ( ContactPart )
		
		local Character	=	ContactPart.Parent ;
		
		if not Character or not game.Players: GetPlayerFromCharacter( Character ) then  return ;  end
		
		local Humanoid		=	Character: FindFirstChild( "Humanoid" );
		local currentHealth	=	Humanoid.Health ;
		local maxHealth		=	Humanoid.MaxHealth ;
		
		if not Humanoid or currentHealth <= 0 or currentHealth >= maxHealth then  return ;  end
		
		Humanoid.Health		=	math.min( currentHealth + HEAL_AMOUNT , maxHealth );
		
		HealthPackTouched_Connection: Disconnect();
		HealthPack: Destroy();
		HealthPackTouched_Connection	=	nil ;	-- Help garbage collector ??
		
	end
	
	HealthPackTouched_Connection	=	HealthPack.Touched:  Connect( on_HealthPackTouched );
	
end


local function  initial_HealthPacksTouched_Binding ()
	
	local allHealthPacks	=	workspace.HealthPacks: GetChildren();
	
	for _ , currentHealthPack in pairs( allHealthPacks )
	do
		bind_OnHealthPackTouched( currentHealthPack );
	end
	
end


--[[
	Disable Health Regen
	
	When a player’s character is added to the game a Script is inserted automatically to regenerate the character’s health over time. This works for many game types, but for our game we want our player to only get healed if they find a health pack.
--]]
local function  on_CharacterAdded ( Character )
	
	local HealthScript	=	Character: WaitForChild( "Health" );
	-- Remove this regeneration script after it is added
	HealthScript: Destroy();
	
end


local function  on_PlayerAdded ( Player )
	
	Player.CharacterAdded:  Connect( on_CharacterAdded );
	
end


_G_PlayerAdded_Connection	=	game.Players.PlayerAdded:  Connect( on_PlayerAdded );

initial_HealthPacksTouched_Binding();
