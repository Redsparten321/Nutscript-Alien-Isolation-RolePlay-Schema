AddCSLuaFile()

SWEP.PrintName				= "Flamethrower"
SWEP.Category 				= 'Alien: Isolation'

SWEP.Author					= "Wheatley"
SWEP.Purpose				= ""

SWEP.Spawnable				= true
SWEP.UseHands				= true
SWEP.DrawAmmo				= true

SWEP.ViewModel				= "models/weapons/c_ai_flamethrower.mdl"
SWEP.WorldModel				= "models/weapons/w_ai_flamethrower.mdl"

SWEP.ViewModelFOV			= 75
SWEP.Slot					= 4
SWEP.SlotPos				= 5

SWEP.Primary.ClipSize		= 2000
SWEP.Primary.DefaultClip	= 450
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ai_flame_fuel"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.FireLoopSound			= nil
SWEP.LastShoot				= nil
SWEP.IsShooting				= false
SWEP.Reloading				= false

if CLIENT then
	game.AddParticles( 'particles/alien_isolation.pcf' )
end

if SERVER then
	resource.AddSingleFile( 'models/weapons/c_ai_flamethrower.mdl' )
	util.AddNetworkString( 'AI_FLAMETHROWER_SHOOT' )
else
	language.Add( 'ai_flame_fuel_ammo', 'Flamethrower Fuel' )
	net.Receive( 'AI_FLAMETHROWER_SHOOT', function()
		local self = net.ReadEntity()
		self.LastShoot = CurTime() + 0.15
	end )
end

game.AddAmmoType( {
	name = 'ai_flame_fuel', 
} )

function SWEP:Initialize()
	self.FireLoopSound = CreateSound( self, 'weapons/flamethrower_loop.wav' )
	self:SetHoldType( 'ar2' )
	timer.Simple( 0, function() if !IsValid( self ) then return end self:SetMoveType( MOVETYPE_NONE ) end )
end

function SWEP:Reload( i )
	if self.Owner:GetAmmoCount( 'ai_flame_fuel' ) <= 0 then return end -- no ammo to reload!
	if self:Clip1() >= self.Primary.ClipSize then return end -- we're already full!
	if self.Reloading then return end
	if self.FireLoopSound then self.FireLoopSound:FadeOut( 0.5 ) timer.Simple( 0.5, function() self.FireLoopSound:Stop() end ) end
	self:SendWeaponAnim( ACT_VM_RELOAD )
	self.Reloading = true
	self:DefaultReload( self.Primary.ClipSize )
	timer.Simple( 0.4, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/flamethrower_reload_01.wav' ) end )
	timer.Simple( 0.6, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/flamethrower_reload_02.wav' ) end )
	timer.Simple( 1.8, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/flamethrower_reload_04.wav' ) end )
	timer.Simple( 2.5, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/flamethrower_reload_05.wav' ) end )
	timer.Simple( 3.4, function() if !IsValid( self ) then return end self:EmitSound( 'weapons/flamethrower_reload_01.wav' ) end )
	timer.Simple( 3.5, function() if !IsValid( self ) then return end self.Reloading = false end )
end

function SWEP:Think()
	if self.LastShoot and self.LastShoot > CurTime() and CLIENT then
		local dlight = DynamicLight( LocalPlayer():EntIndex() )
		if ( dlight ) then
			dlight.pos = self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 40 + self.Owner:EyeAngles():Right() * 4 - self.Owner:EyeAngles():Up() * 5
			dlight.r = 255
			dlight.g = 200
			dlight.b = 0
			dlight.brightness = 2
			dlight.Decay = 2000
			dlight.Size = 800
			dlight.DieTime = CurTime() + 0.6
		end
	end
	
	if self.LastShoot and self.LastShoot > CurTime() and self.IsShooting then
		if SERVER then net.Start( 'AI_FLAMETHROWER_SHOOT' ) net.WriteEntity( self ) net.Send( self.Owner ) end
		if SERVER then
			local tr = {}
			tr.start = self.Owner:GetShootPos()
			tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 250 )
			tr.filter = self.Owner
			tr.mins = Vector( -10, -10, -10 )
			tr.maxs = Vector( 10, 10, 10 )
			tr.mask = MASK_SHOT_HULL
			local _tr = util.TraceHull( tr )
			local v = _tr.Entity
			if IsValid( v ) then 
				if v:IsPlayer() and v != self.Owner or v:IsNPC() or v:GetClass() == 'prop_physics' or v:GetClass() == 'prop_ragdoll' or v:GetClass() == 'alien_xeno_snpc' or v:GetClass() == 'alien_android_snpc' then
					v:Ignite( 3 )
					v:TakeDamage( math.random( 0.6, 1.3 ), self.Owner, self )
					if v:GetClass() == 'alien_xeno_snpc' then
						v:FlameThrowerFearReaction()
					end
				end
			end
		end
	end
	
	if self.LastShoot and self.LastShoot < CurTime() and self.IsShooting then
		if self.FireLoopSound then self.FireLoopSound:FadeOut( 0.5 ) timer.Simple( 0.5, function() self.FireLoopSound:Stop() end ) end
		self.IsShooting = false
		self:EmitSound( 'weapons/flamethrower_end.wav' )
	end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.Owner:WaterLevel() >= 3 then return end
	ParticleEffect( 'alien_flamethrower_fire_start', self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 40 + self.Owner:EyeAngles():Right() * 7 - self.Owner:EyeAngles():Up() * 5, self.Owner:EyeAngles(), self )
	if !self.IsShooting then
		self:EmitSound( 'weapons/flamethrower_start.wav' )
		self.FireLoopSound:Play()
	end
	self.IsShooting = true
	self.LastShoot = CurTime() + 0.15
	self:TakePrimaryAmmo( 5 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.05 )
end

function SWEP:SecondaryAttack()
	-- do nothing
end