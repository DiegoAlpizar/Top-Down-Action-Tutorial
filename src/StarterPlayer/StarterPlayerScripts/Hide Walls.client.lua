--[[
	Since the camera is at a fixed angle from the character, sometimes walls will get in the way.
	Check to see if a player is in a room by seeing what part is underneath the character. If the player is in a room, then it will hide the walls closest to the camera.
--]]


-- CONSTANTS --
local DOWNWARDS			=	Vector3.new( 0 , -10 , 0 );	-- Direction for raycasting
local OPAQUE_ROOM		=	0 ;		-- Normal room transparency
local SEE_THROUGH_ROOM	=	.5 ;	-- See-through room transparency
local NUM				=	nil ;	-- Update room interval


-- GLOBALS --
local _G_LocalPlayer	=	game.Players.LocalPlayer ;
local _G_CurrentRoom	=	nil ;	-- Keep track of which room the player is in


-- FUNCTIONS --
--[[
	Since we only want to hide parts for the player who owns the LocalScript, we can use the 'LocalTransparencyModifier' property of BasePart.
	Hide Models, Folders, or anything else that may have nested children.
--]]
local function  setLocalTransparency_Recursive ( Object , transparency )
	
	local allObjectChildren	=	Object: GetChildren();
	
	if Object: IsA( "BasePart" )
	then
		Object.LocalTransparencyModifier	=	transparency ;
	end
	
	for _ , currentChild in ipairs( allObjectChildren )
	do
		setLocalTransparency_Recursive( currentChild , transparency );
	end
	
end


--[[
	Each room folder in the game has a folder called 'Hide'.
	'Hide' contains all of the elements of a room that should be hidden if the player is inside of it.
--]]
local function  setRoomTransparency ( RoomFolder , transparency )
	
	local HideFolder	=	RoomFolder: FindFirstChild( "Hide" );
	
	if not HideFolder then  return ;  end
	
	setLocalTransparency_Recursive( HideFolder , transparency );
	
end


--[[
	If the player is standing on a random object in our game, such as a pie, the raycast will hit that object, and we won’t know if the player is standing over the floor of a room or not.
	Anything outside of 'LevelGeometry' folder will be some other part of the game that we don’t really need.
	When we perform the raycast, everything not in 'LevelGeometry' will be ignored.
--]]
local function  get_BlackList ()
	
	local blackList				=	{} ;
	local allWorkspaceChildren	=	workspace: GetChildren();
	
	for _ , currentChild in pairs( allWorkspaceChildren )
	do
		-- Blacklist everything outside 'LevelGeometry' folder
		if currentChild.Name ~= "LevelGeometry"
		then
			table.insert( blackList , currentChild );
		end
	end
	
	
	return  blackList ;
	
end


local function  resetCurrentRoom ()
	
	if not _G_CurrentRoom then  return ;  end
	
	setRoomTransparency( _G_CurrentRoom , OPAQUE_ROOM );
	_G_CurrentRoom	=	nil ;
	
end


--[[
	Inside of 'LevelGeometry' each room in the game has its own folder. Inside a room’s folder is a series of parts called "Floor". If the raycast reveals that a player is over a part called "Floor", then we just need to check the part’s parent to find out what room we’re in.
--]]
local function  updateCurrentRoom ( Part )
	
	-- If the player is in a room
	if Part and Part.Name == "Floor"
	then
		-- If he is in a different room now 
		if Part.Parent ~= _G_CurrentRoom
		then
			-- Set the last room the player was in back to normal
			resetCurrentRoom();
			-- Update '_G_CurrentRoom' to the new one
			_G_CurrentRoom	=	Part.Parent ;
			-- And make it see-through
			setRoomTransparency( _G_CurrentRoom , SEE_THROUGH_ROOM );
		end
		-- Else he's in the same current room. It is not necessary to do anything.
	else
		-- The player is not in a room
		resetCurrentRoom();
	end
	
end


local function  trackCurrentRoom ()
	
	while wait( NUM )
	do
		--if not _G_LocalPlayer.Character then  return ;  end
		if _G_LocalPlayer.Character
		then
			local Torso			=	_G_LocalPlayer.Character: WaitForChild( "LowerTorso" );
			local ray			=	Ray.new( Torso.Position , DOWNWARDS );	-- Pointing 10 studs down
			local ignoreList	=	get_BlackList();	-- Fill ignoreList with everything in the Workspace that isn’t LevelGeometry
			local HitPart		=	workspace:FindPartOnRayWithIgnoreList( ray , ignoreList );	-- Return a part underneath the character.
			updateCurrentRoom( HitPart );
		end
	end
	
end


trackCurrentRoom();
