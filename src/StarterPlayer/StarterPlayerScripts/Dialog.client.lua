--[[
	Some of the keys in our level are far away from the door they open and won’t be on the screen when the player finds them. To give more feedback to the player, we'll use an animated dialog when a player steps on a key so they know that a door opened.
--]]


-- CONSTANTS --
-- Animation parameters
-- How long the animation will take.
local ANIM_SPEED_SHOW	=	.5 ;
local ANIM_SPEED_HIDE	=	.5 ;
-- Where we want the DialogFrame to be when it is shown and hidden.
local POSITION_SHOW		=	UDim2.new( .1 , 0 , 0 , 0 ) ;
local POSITION_HIDE		=	UDim2.new( .1 , 0 , -0.3 , 0 ) ;


-- GLOBALS --
local _G_LocalPlayer		=	game.Players.LocalPlayer ;
local _G_LP_GUI				=	_G_LocalPlayer: WaitForChild( "PlayerGui" );
local _G_DialogFrame		=	_G_LP_GUI: WaitForChild( "Dialog GUI" ).Frame ;
local _G_ShowDialogEvent	=	game.ReplicatedStorage.ShowDialog ;


-- FUNCTIONS --
-- param@	duration	how long the dialog should show up for
local function  on_ShowDialog ( thumbnailName , message , duration )
	
	local ThumbnailPicture			=	_G_DialogFrame: FindFirstChild( thumbnailName ) ;
	ThumbnailPicture.Visible		=	true ;
	_G_DialogFrame.TextLabel.Text	=	message ;
	
	-- Show dialog
	_G_DialogFrame: TweenPosition( POSITION_SHOW , Enum.EasingDirection.Out , Enum.EasingStyle.Quint , ANIM_SPEED_SHOW );
	wait( duration );
	-- Hide dialog
	_G_DialogFrame: TweenPosition( POSITION_HIDE , Enum.EasingDirection.Out , Enum.EasingStyle.Quint , ANIM_SPEED_HIDE );
	
	wait( ANIM_SPEED_HIDE );
	ThumbnailPicture.Visible	=	false ;
	
end


local ShowDialog_Connection	=	_G_ShowDialogEvent.OnClientEvent:  Connect( on_ShowDialog );


--_G_LP_GUI: SetTopbarTransparency( 0 );	-- Opaque
