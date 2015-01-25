--The Super Awesome Ultimate SWep Base Code
--Original base Code by Bummiehead
--SCK base code by Clavus
--Stuff done by Lain.
include("autorun/sauce_shared_falcon2.lua")
//General Settings \\
SWEP.AdminSpawnable = true                          // Is the swep spawnable for admin 
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 80
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_falcon2silenced.mdl"
SWEP.WorldModel = "models/weapons/w_falcon2silenced.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}


SWEP.VElements = {}

SWEP.WElements = {}

SWEP.AutoSwitchTo = true                           // when someone walks over the swep, should I automatically equip your swep ?
SWEP.Slot = 2                                       // Decide which slot you want your swep do be in 1 2 3 4 5 6
SWEP.HoldType = "pistol"                            // How the swep is held: pistol, smg, grenade, melee
SWEP.PrintName = "Falcon 2 (Silenced)"                         // your sweps name
SWEP.Author = "Carrington Institute"                            // Your name
SWEP.Spawnable = true                               //  Can everybody spawn this swep ? - If you want only admin keep this false and adminsapwnable true.
SWEP.AutoSwitchFrom = false                         // Does the weapon get changed by other sweps if you pick them up ?
SWEP.FiresUnderwater = false                        // Does your swep fire under water ?
SWEP.Weight = 3                                     // Chose the weight of the Swep
SWEP.DrawCrosshair = true                           // Do you want it to have a crosshair ?
SWEP.Category = "Carrington Institute"                      // Make your own category for the swep
SWEP.SlotPos = 1                                    // Decide wich slot you want your swep do be in 1 2 3 4 5 6
SWEP.DrawAmmo = true                                // Does the ammo show up when you are using it ? True / False
SWEP.ReloadSound = "weapons/falcon2/reload.wav"         // Reload sound, you can use the default ones, or you can use your one; Example; "sound/myswepreload.waw"
SWEP.Instructions = "'At the Institute, we've always got your back with our top of the range weapons!'"              // How do pepole use your swep ?
SWEP.Contact = " n/a "                     // How People should contact you if they find bugs, errors, etc
SWEP.Purpose = " n/a "          // What is the purpose of this swep ?
SWEP.base = "weapon_base"
SWEP.IronSightsPos = Vector(-5.151, -0.202, 2.813)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.CSMuzzleFlashes = true
SWEP.MuzzleAttachment = "1"
SWEP.NextFireSelect = CurTime() + 0.5
//General settings\\

//PrimaryFire Settings\\
SWEP.Primary.Sound = "Weapon_falcon.Fire"        // The sound that plays when you shoot :]
SWEP.Primary.Damage = 4                           // How much damage the swep is doing
SWEP.Primary.TakeAmmo = 1                          // How much ammo does it take for each shot ?
SWEP.Primary.ClipSize = 12                         // The clipsize
SWEP.Primary.Ammo = "pistol"                       // ammo type pistol/ smg1 
SWEP.Primary.DefaultClip = 12                      // How much ammo does the swep come with `?
SWEP.Primary.Spread = 0.17                          //  Do the bullets spread all over? If you want it to fire exactly where you are aiming leave it at 0.1
SWEP.Primary.NumberofShots = 1                     // How many bullets you are firing each shot.
SWEP.Primary.Automatic = false
SWEP.Primary.KickUp = 0.3                          //  How much we should punch the view
SWEP.Primary.KickSides = 1
SWEP.Primary.Delay = 0.105                           // How long time before you can fire again
SWEP.Primary.Force = 12.5                            // The force of the shot
//PrimaryFire settings\\

//Secondary Fire Variables\\
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.SecondaryIronFOV = 40
SWEP.Secondary.Sound = "none"                      //Definitely keep at "none" for now
SWEP.Secondary.Delay = 0.1                         // Probably pointless, but keep it here just 'cuz
//Secondary Fire Variables\\

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378




	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.


		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.


		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/


function SWEP:Initialize()


	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)
	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end

	if CLIENT then


		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )


		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels


		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)


				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end


	end


end


function SWEP:Holster()


	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end


	return true
end

function SWEP:FireMode()
	if self.Primary.Automatic then
	self.Primary.Automatic = false
	self.NextFireSelect = CurTime() + 0.5
	self.Weapon:EmitSound(Sound("Weapon_pistol.Empty"))
		if CLIENT then
		self.Owner:PrintMessage(HUD_PRINTTALK, "Aaaand you're going semi-auto. Trust me, full auto is much more fun.")
		end
	elseif !self.Primary.Automatic then
	self.Primary.Automatic = true
	self.NextFireSelect = CurTime() + 0.5
	self.Weapon:EmitSound(Sound("Weapon_pistol.Empty"))
		if CLIENT then
		self.Owner:PrintMessage(HUD_PRINTTALK, "Time to rock and roll!")
		end
	end
end

function SWEP:OnRemove()
	self:Holster()
end

//SWEP:PrimaryFire()\\
function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	local bullet = {}
		bullet.Num = self.Primary.NumberofShots
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
		bullet.Tracer = 0
		bullet.Force = self.Primary.Force
		bullet.Damage = self.Primary.Damage
		bullet.AmmoType = self.Primary.Ammo
	local rnda = self.Primary.KickUp * -1
	local rndb = self.Primary.KickSides * math.random(-0.5, 0.5)
	self:ShootEffects()
	self.Owner:FireBullets( bullet )
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self.Owner:ViewPunch( Angle( rnda,rndb,rndb ) )
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
end
//SWEP:PrimaryFire()\\

function SWEP:Think()
	if self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) and self.NextFireSelect < CurTime() then
	self:FireMode()
	end
	
end

function SWEP:Deploy()
self.Weapon:SetNetworkedBool("Ironsights", false)
end

SWEP.NextSecondaryAttack = 0

function SWEP:SetIronsights(b)
	self.Weapon:SetNetworkedBool("Ironsights", b)
end

local IRONSIGHT_TIME = 0.1

function SWEP:GetViewModelPosition(pos, ang)

	if (!self.IronSightsPos) then return pos, ang end

	local bmIron = self.Weapon:GetNetworkedBool("Ironsights")
	
	if (bmIron != self.bmLastIron) then
	
		self.bmLastIron = bmIron 
		self.fmIronTime = CurTime()
		
		if (bmIron) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fmIronTime = self.fmIronTime or 0

	if (!bmIron and fmIronTime < CurTime() - IRONSIGHT_TIME) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if (fmIronTime > CurTime() - IRONSIGHT_TIME) then
	
		Mul = math.Clamp((CurTime() - fmIronTime) / IRONSIGHT_TIME, 0, 1)
		
		if (!bmIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if (self.IronSightsAng) then
	
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

//SWEP:SecondaryFire()\\
function SWEP:SecondaryAttack()

	if (!self.IronSightsPos) then return end
	if (self.NextSecondaryAttack > CurTime()) then return end
	
	bmIronsights = !self.Weapon:GetNetworkedBool("Ironsights", false)
	
	self:SetIronsights(bmIronsights)
	
	self.NextSecondaryAttack = CurTime() + 0.3
end
//SWEP:SecondaryFire()\\

function SWEP:Reload()
 
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
 
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
 
		self:DefaultReload( ACT_VM_RELOAD )
                local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime)
                self:SetNextSecondaryFire(CurTime() + AnimationTime)
				self:SetNetworkedBool ("Ironsights", false)
	end
 
end

/*-------------
SCK Base Code
-----------*/
if CLIENT then


	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()


		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end


		if (!self.VElements) then return end


		self:UpdateBonePositions(vm)


		if (!self.vRenderOrder) then


			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}


			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end


		end


		for k, name in ipairs( self.vRenderOrder ) do


			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end


			local model = v.modelEnt
			local sprite = v.spriteMaterial


			if (!v.bone) then continue end


			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )


			if (!pos) then continue end


			if (v.type == "Model" and IsValid(model)) then


				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)


				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )


				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end


				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end


				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end


				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end


				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)


				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end


			elseif (v.type == "Sprite" and sprite) then


				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)


			elseif (v.type == "Quad" and v.draw_func) then


				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)


				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()


			end


		end


	end


	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()


		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end


		if (!self.WElements) then return end


		if (!self.wRenderOrder) then


			self.wRenderOrder = {}


			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end


		end


		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end


		for k, name in pairs( self.wRenderOrder ) do


			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end


			local pos, ang


			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end


			if (!pos) then continue end


			local model = v.modelEnt
			local sprite = v.spriteMaterial


			if (v.type == "Model" and IsValid(model)) then


				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)


				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )


				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end


				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end


				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end


				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end


				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)


				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end


			elseif (v.type == "Sprite" and sprite) then


				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)


			elseif (v.type == "Quad" and v.draw_func) then


				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)


				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()


			end


		end


	end


	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )


		local bone, pos, ang
		if (tab.rel and tab.rel != "") then


			local v = basetab[tab.rel]


			if (!v) then return end


			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )


			if (!pos) then return end


			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)


		else


			bone = ent:LookupBone(bone_override or tab.bone)


			if (!bone) then return end


			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end


			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end


		end


		return pos, ang
	end


	function SWEP:CreateModels( tab )


		if (!tab) then return end


		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then


				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end


			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then


				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end


				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)


			end
		end


	end


	local allbones
	local hasGarryFixedBoneScalingYet = false


	function SWEP:UpdateBonePositions(vm)


		if self.ViewModelBoneMods then


			if (!vm:GetBoneCount()) then return end


			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end


				loopthrough = allbones
			end
			// !! ----------- !! //


			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end


				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end


				s = s * ms
				// !! ----------- !! //


				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end


	end


	function SWEP:ResetBonePositions(vm)


		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end


	end


	/**************************
		Global utility code
	**************************/


	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )


		if (!tab) then return nil end


		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end


		return res


	end


end
