--[[
	Our game has several locked doors to encourage exploration and to pace the player's progression. These doors will open when their associated key-cards are found by a player.	
--]]


local _G_Door					=	script.Parent.Door ;
local _G_Key					=	script.Parent.Key ;
local _G_ShowDialogEvent		=	game.ReplicatedStorage.ShowDialog ;
local _G_KeyTouched_Connection	=	nil ;


local function  on_KeyTouched( ContactPart )
	
	local Character	=	ContactPart.Parent ;
	if not game.Players: GetPlayerFromCharacter( Character ) then  return ;  end
	
	_G_Key: Destroy();
	
	_G_Door.CanCollide				=	false ;
	_G_Door.Anchored				=	false ;
	_G_Door.BodyPosition.Position	=	_G_Door.Position + Vector3.new( 0 , 10 , 0 ) ;
	_G_Door.Transparency			=	0.5 ;
	_G_Door.Sound: Play();
	
	_G_ShowDialogEvent: FireAllClients( "Key Image" , "Key found, door unlocked!" , 2 );
	
end


_G_KeyTouched_Connection	=	_G_Key.Touched:  Connect( on_KeyTouched );
