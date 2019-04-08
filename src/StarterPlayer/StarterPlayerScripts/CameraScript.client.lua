--[[
	The custom camera in our game will track the player from above, but at an angle, similar to an isometric camera.
	To keep things simple, we will keep the angle fixed and not allow the player to rotate it.
--]]


--[[  SERVICES  ]]--
local RunService		=	game: GetService( "RunService" ) ;
local PlayersService	=	game: GetService( "Players" ) ;


--[[  CONSTANTS  ]]--
local BINDING_NAME	=	"Camera" ;	-- RenderStep label
local OFFSET		=	Vector3.new( 40 , 40 , 40 ) ;	-- Fixed distance from the character
--[[
	Reduce the field of view which will both constrain how much of the level the player will see, as well as giving the illusion of the level being “flatter” and closer to an isometric view.
	If you shrink the field of view in order to flatten the world, make sure that you move the camera back further so that more of the scene fits into the shot. On the other hand if you increase the field of view, you may find you will want to move the camera in closer. 
--]]
local FIELD_OF_VIEW	=	30 ;


--[[  GLOBALS  ]]--
local _G_LocalPlayer	=	PlayersService.LocalPlayer ;
local _G_Camera			=	workspace.CurrentCamera ;


--[[  FUNCTIONS  ]]--

--  We want the camera to follow the player. To make sure that this tracking is smooth, we need to make sure the camera’s position is updated every time the render refresh occurs.
local function  onRenderStep ()
	
	local Character			=	_G_LocalPlayer.Character ;
	local HumanoidRootPart	=	Character and Character: FindFirstChild( "HumanoidRootPart" ) ;
	
	if not HumanoidRootPart then  return ;  end
	
	-- Get the player’s position based on their Character’s Humanoid.RootPart
	local PlayerPosition		=	HumanoidRootPart.Position ;
	local NewCameraPosition		=	PlayerPosition + OFFSET ;
	_G_Camera.CoordinateFrame	=	CFrame.new( NewCameraPosition , PlayerPosition ) ;
	
end


_G_Camera.FieldOfView	=	FIELD_OF_VIEW ;

RunService: BindToRenderStep( BINDING_NAME , Enum.RenderPriority.Camera.Value , onRenderStep );
