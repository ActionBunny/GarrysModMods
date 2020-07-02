if SERVER then
	AddCSLuaFile()
	resource.AddFile("sound/weapons/r_bull/baam.wav")
	resource.AddFile("sound/wtf.wav")
end

local metaEnt = FindMetaTable("Entity")
AccessorFunc( metaEnt, "fassinator", "Fassinator")

local ShootSound = Sound( "wtf.wav" )

SWEP.HoldType			= "pistol"

SWEP.PrintName			= "Fassinator"			  
SWEP.Author				= "TheBroomer"  
SWEP.Instructions			= "Place 5 Explosive Barrels around your enemies and enjoy the desaster!"
SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.Icon = "vgui/ttt/Fassinator/Explosive.png"

SWEP.Base				= "weapon_tttbase"

SWEP.Spawnable = false
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }

SWEP.Primary.Ammo       = "Barrel" 
--SWEP.Primary.Recoil			= 8
--SWEP.Primary.Damage = 24
SWEP.Primary.Delay = 0.3
SWEP.Primary.Cone = 0.000002
SWEP.Primary.ClipSize = 5
SWEP.Primary.ClipMax = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false

SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = "models/props_c17/oildrum001_explosive.mdl"

SWEP.UseHands			= false
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 65
SWEP.ViewModel			= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"
SWEP.IronSightsPos = Vector(2.773, 0, 0.846)
SWEP.IronSightsAng = Vector(-0.157, 0, 0)

SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = [[
	
	Place 5 Explosive Barrels around your enemies and enjoy the desaster!
	
	]]
}

function SWEP:PrimaryAttack(worldsnd)
	
	local tr = self.Owner:GetEyeTrace()
    local tracedata = {}
	
    tracedata.pos = tr.HitPos + Vector(0,0,2)
    
    // The rest is only done on the server
    if (!SERVER) then return end
	
	if self:Clip1() > 0 then
		
		self:TakePrimaryAmmo(1)
		
		local myPosition = self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 )
		local data = EffectData()
		data:SetOrigin( myPosition )

		util.Effect("MuzzleFlash", data)

       	 	place( "models/props_c17/oildrum001_explosive.mdl", tracedata, self)

	else
		self:EmitSound( "Weapon_AR2.Empty" )
	end
end

function SWEP:SecondaryAttack(worldsnd)

	--self:EmitSound( ShootSound )


end

function place( model_file, tracedata, weapon )
	
	if ( CLIENT ) then return end

	local ent = ents.Create( "prop_physics" )

	if ( !IsValid( ent ) ) then return end

	ent:SetModel( model_file )
	
	ent:SetPos( tracedata.pos )
	--ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()
	ent:SetFassinator( weapon )
	local phys = ent:GetPhysicsObject()
	if ( !IsValid( phys ) ) then ent:Remove() return end
	
end

local function FassinatorPlayerDamage(target, dmginfo)	
	if target:IsPlayer() then
		--if dmginfo:GetInflictor():GetClass() == "prop_physics" then
		if IsValid( dmginfo:GetInflictor():GetFassinator() ) then
			--if IsValid( dmginfo:GetInflictor():GetOrigin() ) then
				
				dmginfo:SetInflictor( dmginfo:GetInflictor():GetFassinator() )
				--local manhackThrower = dmginfo:GetInflictor():GetOrigin()

				--if IsValid(manhackThrower) then
				--	if manhackThrower:IsPlayer() then
				--		dmginfo:SetAttacker( manhackThrower )
				--	else
				--		dmginfo:SetAttacker( game.GetWorld() )
				--	end
				--else
				--	dmginfo:SetAttacker( game.GetWorld() )
				--end
			--end
		end
	end
end

hook.Add("EntityTakeDamage","FassinatorPlayerDamage",FassinatorPlayerDamage)