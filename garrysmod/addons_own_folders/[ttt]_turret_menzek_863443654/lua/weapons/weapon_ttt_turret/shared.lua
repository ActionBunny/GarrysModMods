CreateConVar( "ttt_turret_innodamage", "10", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damage to innocents." )
CreateConVar( "ttt_turret_traitordamage", "3", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damage to traitors." )
CreateConVar( "ttt_turret_amount", "3", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the amount of turrets." )
CreateConVar( "ttt_turret_weight", "2000", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the weight of turrets." )

local metaEnts = FindMetaTable( "Entity" )
AccessorFunc( metaEnts, "isturret", "IsTurret", FORCE_BOOL )
AccessorFunc( metaEnts, "spawner", "Spawner" )
AccessorFunc( metaEnts, "thrower", "Thrower" )

if SERVER then
   --AddCSLuaFile( "weapon_ttt_turret.lua" )
   resource.AddFile("materials/vgui/ttt/icon_wd_turret.vmt")
end
  
SWEP.HoldType = "grenade"
SWEP.ViewModelFOV = 74
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModel = "models/weapons/v_Grenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_smokegrenade.mdl"
SWEP.IronSightsPos = Vector(7.212, -5.41, 1.148)
SWEP.IronSightsAng = Vector(-4.016, -0.575, 28.114)

SWEP.VElements = {
	["VTurret"] = { type = "Model", model = "models/Combine_turrets/Floor_turret.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.519, 1.417, 16.611), angle = Angle(-175.362, -44.231, 7.531), size = Vector(0.416, 0.416, 0.416), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["WTurret"] = { type = "Model", model = "models/Combine_turrets/Floor_turret.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-2.806, 7.787, 19.087), angle = Angle(0, -39.237, -156.344), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

if CLIENT then

   SWEP.PrintName    = "Turret"
   SWEP.Slot         = 6
   SWEP.ViewModelFlip = false
   SWEP.Icon = "vgui/ttt/icon_wd_turret"
end



SWEP.Base               = "weapon_tttbase"

primammo = GetConVar("ttt_turret_amount"):GetFloat()

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = primammo
SWEP.Primary.DefaultClip    = primammo
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo       = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 0

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true
SWEP.WeaponID = AMMO_TURRET
SWEP.AllowDrop = false

SWEP.DeploySpeed = 2


if SERVER then

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	if SERVER then self:SpawnTurret() end

end

function SWEP:SpawnTurret()
	
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
    if !tr.HitWorld then return end
	if tr.HitPos:Distance(ply:GetPos()) > 128 then return end
	self:TakePrimaryAmmo( 1 )
	--placeholder = ents.Create( "ttt_turret" )
	--placeholder:SetPos( tr.HitPos + tr.HitNormal )
	--placeholder:Spawn()
	--placeholder:DrawShadow( false )
	
	local Views = self.Owner:EyeAngles().y
   	local ent = ents.Create("npc_turret_floor")
        --ent:SetOwner(ply)
  	ent:SetPos(tr.HitPos + tr.HitNormal) 
	ent:SetAngles(Angle(0, Views, 0))
   	ent:Spawn()
    ent:Activate()
	ent:SetDamageOwner(ply)
	ent:SetIsTurret( true )
	--ent:SetSpawner( placeholder )
	ent:SetThrower( ply )
	
    local entphys = ent:GetPhysicsObject();
    if entphys:IsValid() then
        entphys:SetMass( GetConVar("ttt_turret_weight"):GetFloat() )
    end
	ent.IsTurret = true
	ent:SetPhysicsAttacker(self.Owner)
	ent:SetTrigger(true)
       ent.IsTurret = true
	if self.Weapon:Clip1() == 0 then 
		self.Owner:StripWeapon("weapon_ttt_turret")
	end
	
	-- ent:OnTipped(function(ent)
		-- print("Turret tipped")
		-- ent:Remove()
	-- end)
end

end
function SWEP:Deploy()
	self:SecondaryAttack()
end

function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

hook.Add("ShouldCollide", "TurretCollides", function(ent1, ent2)
	if ent1.IsTurret then
		if (ent2:IsPlayer() and ent2:GetRole() == ROLE_TRAITOR)  then
			return true
		end
	end
	
	if ent2.IsTurret then
		if (ent1:IsPlayer() and ent1:GetRole() == ROLE_TRAITOR) then
			return true
		end
	end
	
end)

hook.Add( "EntityTakeDamage", "TurretDamage", function( ent, dmginfo )
	if ent:IsPlayer() and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "npc_turret_floor" and dmginfo:GetInflictor():GetIsTurret() then
		if ent:IsTraitor() then 
		    dmginfo:SetDamage( GetConVar("ttt_turret_traitordamage"):GetFloat() )  
		else
			dmginfo:SetDamage( GetConVar("ttt_turret_innodamage"):GetFloat() )
		end
		
		dmginfo:SetDamageType( DMG_AIRBOAT )
		dmginfo:SetAttacker( dmginfo:GetInflictor():GetThrower() )
		dmginfo:SetInflictor( ent )
		
		ent:Remove()
	end
end
)

function SWEP:OnDrop()
    self:Remove()
end

if SERVER then
  -- AddCSLuaFile("weapon_ttt_turret.lua")
end

SWEP.EquipMenuData = {
      type = "item_weapon",
	  name = "Turret",
      desc = [[
Spawn a turret to shoot enemy innocents]]
   };
 --[[ 
local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "ttt_turret"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
end

function ENT:Draw()
end

function ENT:Think()
end
scripted_ents.Register(ENT, "ttt_turret", true)
]] 