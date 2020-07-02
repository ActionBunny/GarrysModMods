if SERVER then
  AddCSLuaFile( "shared.lua" )
  AddCSLuaFile( "cl_menu.lua" )
  AddCSLuaFile( "hooks.lua" )
  resource.AddFile("materials/vgui/ttt/icon_deathfaker.png")
  resource.AddWorkshop("922007616")
end

include("hooks.lua")

if CLIENT then

   SWEP.PrintName = "Death Faker"
   SWEP.Slot				= 6

   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Death Faker",
      desc  = [[
Left-Click: Spawns a dead body
Right-Click to place blood]]
   };

   SWEP.Icon = "vgui/ttt/icon_deathfaker.png"
   
	include("cl_menu.lua")
end

SWEP.HoldType = "slam"
SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.WeaponID = AMMO_BODYSPAWNER

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel  = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 0.1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 0.1

SWEP.NoSights = true

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

function SWEP:PrimaryAttack()	
	self.Owner:deathfaker()
end

function SWEP:SecondaryAttack()

end

local plymeta = FindMetaTable( "Player" );

function plymeta:deathfaker()

self:SetNWBool("Dead", true)
self:SetNWBool("CanAttack", false)
self:SetNWBool("Status", 3)




---------------------------
--------"corpse"-------
---------------------------
-- this is time to make our corpse

	local weapons = {"weapon_zm_pistol","weapon_ttt_m16","weapon_zm_revolver","weapon_zm_shotgun","weapon_ttt_glock","weapon_zm_mac10","weapon_zm_revolver","weapon_zm_sledge"}
	local fakedply = table.Random(player.GetAll())
	local fakerole = math.random(0,2)
	local dmginfo = DamageInfo()  
	dmginfo:SetDamage( math.random(10,100) )
	dmginfo:SetDamageType( DMG_BULLET )

-- create the ragdoll
	local rag = ents.Create("prop_ragdoll", dmginfo)

	rag:SetPos(self:GetPos())
	rag:SetModel(self:GetModel())
	self:SetModel("models/invisible/inv2.mdl")
	rag:SetAngles(self:GetAngles())
	rag:SetColor(self:GetColor())
	--rag.SetOwner(self)
	rag.SetOwner(self)

	--rag:Spawn(self)
	rag:Spawn()
	--rag:Activate(self)
	rag:Activate()

	-- flag this ragdoll as being a player's
	rag.player_ragdoll = self
	rag.sid = self:SteamID()
	rag.uqid = self:UniqueID()
  
	self:SetNWBool("is_pretending", true)
	self:SetNWString("nick", self:Nick())

	-- network data
	CORPSE.SetPlayerNick(rag, self)
	CORPSE.SetCredits(rag, 0)

	-- if someone searches this body they can find info on the victim and the
	-- death circumstances
	rag.equipment = self:GetEquipmentItems()
 	rag.was_role = ROLE_INNOCENT
	rag.bomb_wire = false
	rag.dmgtype = ( DMG_BULLET )

	rag.dmgwep  = table.Random(weapons)

	rag.was_headshot = true
	rag.time = CurTime()
	rag.kills = table.Copy(self.kills)

	rag.killer_sample = nil

	-- position the bones
	local num = rag:GetPhysicsObjectCount()-1
	local v = self:GetVelocity()

	for i=0, num do
	local bone = rag:GetPhysicsObjectNum(i)
		
		if IsValid(bone) then
		local bp, ba = self:GetBonePosition(rag:TranslatePhysBoneToBone(i))
			if bp and ba then
				bone:SetPos(bp)
				bone:SetAngles(ba)
			end
		end
	end
end