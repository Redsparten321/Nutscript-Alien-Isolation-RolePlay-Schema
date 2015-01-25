AddCSLuaFile()

SWEP.PrintName				= "Revolver"
SWEP.Category 				= 'Alien: Isolation'

SWEP.Author					= "Wheatley"
SWEP.Purpose				= ""

SWEP.Spawnable				= true
SWEP.UseHands				= true
SWEP.DrawAmmo				= true

SWEP.ViewModel				= "models/weapons/c_ai_revolver.mdl"
SWEP.WorldModel				= "models/weapons/w_ai_revolver.mdl"

SWEP.ViewModelFOV			= 65
SWEP.Slot					= 4
SWEP.SlotPos				= 5

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 16
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "ai_revolver_ammo"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.FireLoopSound			= nil
SWEP.LastShoot				= nil
SWEP.Reloading				= false

if SERVER then
	resource.AddSingleFile( 'models/weapons/c_ai_revolver.mdl' )
	util.AddNetworkString( 'AI_REVOLVER_FIRED' )
	util.AddNetworkString( 'AI_REVOLVER_SETVMCYCLE' )
else
	language.Add( 'ai_revolver_ammo_ammo', 'Revolver Ammo' )
	net.Receive( 'AI_REVOLVER_FIRED', function()
	local self = net.ReadEntity()
		local dlight = DynamicLight( LocalPlayer():EntIndex() )
		if ( dlight and self ) then
			dlight.pos = self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 40 + self.Owner:EyeAngles():Right() * 4 - self.Owner:EyeAngles():Up() * 5
			dlight.r = 255
			dlight.g = 200
			dlight.b = 0
			dlight.brightness = 1
			dlight.Decay = 2000
			dlight.Size = 800
			dlight.DieTime = CurTime() + 0.6
		end
	end )
	
	net.Receive( 'AI_REVOLVER_SETVMCYCLE', function()
		local c = net.ReadFloat()
		local vm = LocalPlayer():GetViewModel()
		local seq = vm:LookupSequence( 'reload' )
		if !IsValid( vm ) then return end
		vm:SetBodygroup( 1, c )
		//print( vm, c )
	end )
end

game.AddAmmoType( {
	name = 'ai_revolver_ammo', 
} )

function SWEP:Initialize()
	self:SetHoldType( 'pistol' )
end


function SWEP:Reload( i )
	if self.Owner:GetAmmoCount( 'ai_revolver_ammo' ) <= 0 then return false end -- no ammo to reload!
	if self:Clip1() >= self.Primary.ClipSize then return false end -- we're already full!
	if self.Reloading then return false end
	self:SendWeaponAnim( ACT_VM_RELOAD )
	self.Reloading = true
	//self:DefaultReload( self.Primary.ClipSize )
	self:EmitSound( 'weapons/ai_revolver_clip_open.wav' )
	timer.Simple( 0.2, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/ai_revolver_clip_open.wav' ) end )
	
	local function UnLoadBullet()
		if self:Clip1() > 0 then 
			self:SetClip1( self:Clip1() - 1 ) 
		end
	end
	
	for i = 1, 6 do
		timer.Simple( 0.4 + 0.15 * i, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/ai_revolver_shell_0' .. math.random( 1, 3 ) .. '.wav' ) UnLoadBullet() end )
	end
	
	local function LoadBullet()
		if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( 'ai_revolver_ammo' ) > 0 then 
			self:SetClip1( self:Clip1() + 1 ) 
			self.Owner:SetAmmo( self.Owner:GetAmmoCount( 'ai_revolver_ammo' ) - 1, 'ai_revolver_ammo' ) 
		end
	end
	
	local function CanReload()
		if self.Owner:GetAmmoCount( 'ai_revolver_ammo' ) > 0 then return true end
		return false
	end
	
	local abort = false
	
	local function AbortReloading()
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) 
		self:EmitSound( 'weapons/ai_revolver_clip_close.wav' ) 
		abort = true
		self.Reloading = false
	end
	
	timer.Simple( 1.6, function() if abort then return end if !IsValid( self ) or !CanReload() then AbortReloading() return end self:EmitSound( 'weapons/ai_revolver_clip_insert.wav' ) LoadBullet() end )
	timer.Simple( 2.6, function() if abort then return end if !IsValid( self ) or !CanReload() then AbortReloading() return end self:EmitSound( 'weapons/ai_revolver_clip_insert.wav' ) LoadBullet() end )
	timer.Simple( 3.5, function() if abort then return end if !IsValid( self ) or !CanReload() then AbortReloading() return end self:EmitSound( 'weapons/ai_revolver_clip_insert.wav' ) LoadBullet() end )
	timer.Simple( 4.2, function() if abort then return end if !IsValid( self ) or !CanReload() then AbortReloading() return end self:EmitSound( 'weapons/ai_revolver_clip_insert.wav' ) LoadBullet() end )
	timer.Simple( 5.2, function() if abort then return end if !IsValid( self ) or !CanReload() then AbortReloading() return end self:EmitSound( 'weapons/ai_revolver_clip_insert.wav' ) LoadBullet() end )
	timer.Simple( 5.7, function() if abort then return end if !IsValid( self ) or !CanReload() then AbortReloading() return end self:EmitSound( 'weapons/ai_revolver_clip_insert.wav' ) LoadBullet() end )
	timer.Simple( 6.3, function() if abort then return end if !IsValid( self ) or abort then return end self:EmitSound( 'weapons/ai_revolver_clip_close.wav' ) end )
	timer.Simple( 6.5, function() if abort then return end if !IsValid( self ) or abort then return end self.Reloading = false end )
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if SERVER then
		net.Start( 'AI_REVOLVER_FIRED' )
			net.WriteEntity( self )
		net.Send( player.GetAll() )
	end
	
	self.Owner:FireBullets( {
		Num  		= 1,
		Src 		= self.Owner:GetShootPos(),
		Dir 		= ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() + ( Angle() ) ):Forward(),
		Spread 		= Vector(),
		Tracer 		= 1,
		Force 		= 35,
		Damage 		= math.random( 25, 55 )
	} )
	
	self.Owner:ViewPunch( Angle( -25, 0, 0 ) )
	timer.Simple( 0.6, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/ai_revolver_clip_rotate.wav' ) end )
	self:EmitSound( 'weapons/ai_revolver_fire_0' .. math.random( 1, 3 ) .. '.wav' )
	self:TakePrimaryAmmo( 1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 1 )
end

function SWEP:SecondaryAttack()
	-- do nothing
end