AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Propane Tank"
ENT.Author			= "Wheatley"
ENT.Information		= "A propane for flamethrower"
ENT.Category		= "Alien: Isolation"

ENT.Spawnable		= true
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_OPAQUE
ENT.HP				= 5

if AI_CRAFT_RECIPES then
	table.insert( AI_CRAFT_RECIPES, { ['injector'] = 1, ['ethanol'] = 2, ['scrap'] = 25, ['printname'] = 'PROPANE TANK', ['item'] = 'item_ai_propane_tank' } )
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 1;
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:SetHealth( hp )
	self.HP = hp
end

function ENT:GetHealth( hp )
	return self.HP
end

function ENT:TakeDamage( dmg )
	self.HP = self.HP - dmg
end

--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()
	if ( SERVER ) then
		self:SetModel( "models/weapons/item_ai_flamethrower_tank.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self:SetHealth( 15 )
		
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
		end
	end
end

--[[---------------------------------------------------------
   Name: OnTakeDamage
-----------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )

	-- React physically when shot/getting blown
	self:TakePhysicsDamage( dmginfo )
end

--[[---------------------------------------------------------
   Name: Think
-----------------------------------------------------------]]
function ENT:Think()
	if self:GetHealth() <= 0 and SERVER then
		local ed = EffectData()
		ed:SetOrigin( self:GetPos() )
		util.Effect( 'HelicopterMegaBomb', ed )
		for i, v in pairs( ents.FindInSphere( self:GetPos(), 75 ) ) do
			v:TakeDamage( math.random( 2, 8 ), self, self )
		end
		SafeRemoveEntity( self )
		return
	end
	
	for i, v in pairs( ents.FindInSphere( self:GetPos(), 25 ) ) do
		if v:IsPlayer() and v:GetAmmoCount( 'ai_flame_fuel' ) < 1000 then
			if SERVER then
				v:EmitSound( 'weapons/flamethrower_takeammo.wav' )
				SafeRemoveEntity( self )
				v:GiveAmmo( 25, 'ai_flame_fuel' )
			end
		end
	end
end
