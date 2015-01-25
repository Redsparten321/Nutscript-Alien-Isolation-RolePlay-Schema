AddCSLuaFile()
SWEP.Base = "weapon_base"
SWEP.PrintName		= "Hick's Pulse Rifle"
SWEP.Slot		                   = 3
SWEP.SlotPos		= 1		
SWEP.DrawAmmo		= true				
SWEP.DrawCrosshair		= true		
SWEP.ViewModel		= "MODELS/WEAPONS/v_m41a.mdl"	
SWEP.WorldModel		= "MODELS/WEAPONS/w_m41a.mdl"	
SWEP.ReloadSound		= "M41A-RELOAD"	
SWEP.HoldType		= "ar2"			
-- Other settings
SWEP.Weight		= 5			
SWEP.AutoSwitchTo		= false		
SWEP.Spawnable		= true		
 
-- Weapon info
SWEP.Author		= "Corporal.Hicks"		
SWEP.Contact		= "No Ways"		
SWEP.Purpose		= "Shootin Aliens"	
SWEP.Instructions	= "LETS ROCK!!"		

-- Primary fire settings
SWEP.Primary.Sound			= "M41A-FIRE.wav"	
SWEP.Primary.Damage		= 5
SWEP.Primary.NumShots		= 1	
SWEP.Primary.Recoil			= 0,5			
SWEP.Primary.Cone			= 1		
SWEP.Primary.Delay			= 0,18
SWEP.Primary.ClipSize		= 95		
SWEP.Primary.DefaultClip	                  = 95	
SWEP.Primary.Tracer			= 1			
SWEP.Primary.Force			= 50	
SWEP.Primary.Automatic		= 4	
SWEP.Primary.Ammo		= "SMG1"	
SWEP.Category 			= "Hick's Pulse Rifle"

-- Secondary fire settings
SWEP.Secondary.Sound		= "M41A-FIRE.wav"
SWEP.Secondary.Damage		= 100			
SWEP.Secondary.NumShots		= 1			
SWEP.Secondary.Recoil		= 0,5			
SWEP.Secondary.Cone		= 1			
SWEP.Secondary.Delay		= 1,44			
SWEP.Secondary.ClipSize		= 10		
SWEP.Secondary.DefaultClip	                  = 5			
SWEP.Secondary.Tracer		= 1			
SWEP.Secondary.Force		= 100			
SWEP.Secondary.Automatic	           	= false
SWEP.Secondary.Ammo		= "SMG1_Grenade"		




function SWEP:Initialize()			
end

function SWEP:PrimaryAttack()		
	if ( !self:CanPrimaryAttack() ) then return end		
	local bullet = {}	-- Set up the shot
		bullet.Num = self.Primary.NumShots				
		bullet.Src = self.Owner:GetShootPos()			
		bullet.Dir = self.Owner:GetAimVector()			
		bullet.Spread = Vector( self.Primary.Cone / 90, self.Primary.Cone / 90, 0 )
		bullet.Tracer = self.Primary.Tracer				
		bullet.Force = self.Primary.Force				
		bullet.Damage = self.Primary.Damage				
		bullet.AmmoType = self.Primary.Ammo				
		self.Owner:FireBullets( bullet )				
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )	
	self.Owner:MuzzleFlash()							
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self.Owner:ViewPunch(Angle( -self.Primary.Recoil, 0, 0 ))
	if (self.Primary.TakeAmmoPerBullet) then			
		self:TakePrimaryAmmo(self.Primary.NumShots)
	else
		self:TakePrimaryAmmo(1)
	end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	
end

function SWEP:SecondaryAttack()		
	if ( !self:CanSecondaryAttack() ) then return end	
	local bullet = {}	-- Set up the shot
		bullet.Num = self.Secondary.NumShots			
		bullet.Src = self.Owner:GetShootPos()			
		bullet.Dir = self.Owner:GetAimVector()			
		bullet.Spread = Vector( self.Secondary.Cone / 90, self.Secondary.Cone / 90, 0 )	
		bullet.Tracer = self.Secondary.Tracer			
		bullet.Force = self.Secondary.Force				
		bullet.Damage = self.Secondary.Damage			
		bullet.AmmoType = self.Secondary.Ammo			
		self.Owner:FireBullets( bullet )				
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )	
	self.Owner:MuzzleFlash()										
	self.Weapon:EmitSound(Sound(self.Secondary.Sound))	
	self.Owner:ViewPunch(Angle( -self.Secondary.Recoil, 0, 0 ))
	if (self.Secondary.TakeAmmoPerBullet) then			
		self:TakeSecondaryAmmo(self.Secondary.NumShots)
	else
		self:TakeSecondaryAmmo(1)
	end
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )	
end

function SWEP:Think()				
end

function SWEP:Reload()				
	self:DefaultReload(ACT_VM_RELOAD)
	return true
end

function SWEP:Deploy()				
	return true
end

function SWEP:Holster()				
	return true
end

function SWEP:OnRemove()			
end

function SWEP:OnRestore()			
end

function SWEP:Precache()			
end

function SWEP:OwnerChanged()		
end