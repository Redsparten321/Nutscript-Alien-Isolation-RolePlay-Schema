AddCSLuaFile()

SWEP.PrintName				= "Motion Tracker"
SWEP.Category 				= 'Alien: Isolation'

SWEP.Author					= "Wheatley"
SWEP.Purpose				= ""

SWEP.Spawnable				= true
SWEP.UseHands				= true
SWEP.DrawAmmo				= false

SWEP.ViewModel				= "models/weapons/c_ai_scaner.mdl"
SWEP.WorldModel				= ""

SWEP.ViewModelFOV			= 75
SWEP.Slot					= 0
SWEP.SlotPos				= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

if SERVER then
	resource.AddSingleFile( 'models/weapons/c_ai_scaner.mdl' )
end

function SWEP:Initialize()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawHUD()
	MOTIONTRACKER_RenderScreen()
end