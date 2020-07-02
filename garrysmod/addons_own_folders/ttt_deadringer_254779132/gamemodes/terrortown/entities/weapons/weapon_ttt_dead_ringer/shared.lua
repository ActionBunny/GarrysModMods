////////////////////
//Dead Ringer Swep//
///////Update///////
////by NECROSSIN////
////////////////////
///TTT Convert by///
///////PORTER///////
////////////////////

--Updated: 24 January 2010
--Converted : 01 May 2014

----------------------------
--////////////////////////--
local REDUCEDAMAGE = 0.2
--////////////////////////--
----------------------------

--was -- this SWEP uses models, textures and sounds from TF2, so be sure that you have it if you dont want to see an ERROR instead of swep model and etc...
--now -- included models, textures and sounds from TF2, so u don't need to install TeamFortress2...

resource.AddFile( "materials/vgui/ttt/weapon_dead_ringer.vmt" )
resource.AddFile( "materials/vgui/ttt/weapon_dead_ringer.vtf" )
resource.AddFile( "sound/ttt/recharged.wav" )
resource.AddFile( "sound/ttt/spy_uncloak_feigndeath.wav" )
resource.AddFile( "models/ttt/v_models/v_watch_pocket_spy.mdl" )
resource.AddFile( "models/ttt/v_models/v_watch_pocket_spy.sw.vtx" )
resource.AddFile( "models/ttt/c_models/c_pocket_watch.mdl" )
resource.AddFile( "models/ttt/c_models/c_pocket_watch.sw.vtx" )
resource.AddFile( "materials/vgui/ttt/misc_ammo_area_red.vmt" )
resource.AddFile( "materials/vgui/ttt/gradient_red.vtf" )
resource.AddFile( "materials/vgui/ttt/misc_ammo_area_mask.vtf" )
resource.AddFile( "materials/models/ttt/c_pocket_watch/c_pocket_watch.vtf" )
resource.AddFile( "materials/models/ttt/c_pocket_watch/c_pocket_watch.vmt" )
resource.AddFile( "materials/models/player/pyro/pyro_lightwarp.vtf" )
resource.AddFile( "materials/models/player/spy/spy_exponent.vtf" )
resource.AddFile( "materials/models/player/spy/spy_hands_blue.vmt" )
resource.AddFile( "materials/models/player/spy/spy_hands_blue.vtf" )
resource.AddFile( "materials/models/player/spy/spy_hands_normal.vtf" )
resource.AddFile( "materials/models/player/spy/spy_hands_red.vmt" )
resource.AddFile( "materials/models/player/spy/spy_hands_red.vtf" )
resource.AddFile( "materials/models/weapons/c_items/c_pocket_watch.vmt" )
resource.AddFile( "materials/models/weapons/c_items/c_pocket_watch.vtf" )
resource.AddFile( "materials/models/weapons/c_items/c_pocket_watch_lightwarp" )
resource.AddFile( "materials/models/weapons/c_items/c_pocket_watch_phongwarp.vtf" )
resource.AddFile( "models/invisible/inv2.dx80.vtx" )
resource.AddFile( "models/invisible/inv2.dx90.vtx" )
resource.AddFile( "models/invisible/inv2.mdl" )
resource.AddFile( "models/invisible/inv2.sw.vtx" )
resource.AddFile( "models/invisible/inv2.vvd" )

--------------------------------------------------------------------------
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo			= false
	SWEP.AutoSwitchFrom		= false
	SWEP.HoldType			= "normal"
	
end

--------------------------------------------------------------------------

if ( CLIENT ) then
	SWEP.PrintName			= "Dead Ringer"	
	SWEP.Slot = 6

	SWEP.EquipMenuData = {
   	   type = "item_weapon",
           desc = "Fake your death!"
        };


	SWEP.Icon = "vgui/ttt/weapon_dead_ringer"

	SWEP.Author				= "NECROSSIN (fixed by Niandra Lades / Converted by Porter)"
	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV			= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes		= false
	SWEP.WepSelectIcon = surface.GetTextureID("models/ttt/c_pocket_watch/c_pocket_watch.vtf") -- texture from TF2
	
	SWEP.IconLetter			= "G"
	
	surface.CreateFont( "DRfont", {
	font = "coolvertica",
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
} )

function drawdr()
--here goes the new HUD
if LocalPlayer():GetNWBool("Status") == 1 or LocalPlayer():GetNWBool("Status") == 3 or LocalPlayer():GetNWBool("Status") == 4 and LocalPlayer():Alive() then
local background = surface.GetTextureID("vgui/ttt/misc_ammo_area_red")
local w,h = surface.GetTextureSize(surface.GetTextureID("vgui/ttt/misc_ammo_area_red"))
	surface.SetTexture(background)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(13, ScrH() - h - 200, w*5, h*5 )

local energy = math.max(LocalPlayer():GetNWInt("drcharge"), 0)
draw.RoundedBox(2,44, ScrH() - h - 168, (energy / 8) * 77, 15, Color(255,222,255,255))
surface.SetDrawColor(255,255,255,255)
surface.DrawOutlinedRect(44, ScrH() - h - 168, 77, 15)
draw.DrawText("CLOAK", "DRfont",65, ScrH() - h - 150, Color(255,255,255,255))
end

end
hook.Add("HUDPaint", "drawdr", drawdr)

local function DRReady(um)
surface.PlaySound( "ttt/recharged.wav" )
end
usermessage.Hook("DRReady", DRReady)
end 

-------------------------------------------------------------------

SWEP.Category				= "Spy"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= true

SWEP.Purpose        	= "Fake your death!"

SWEP.Instructions   	= "Primary - turn on.\nSecondary - turn off or drop cloak."

SWEP.ViewModel 				= "models/ttt/v_models/v_watch_pocket_spy.mdl"
SWEP.WorldModel 			= "" 

SWEP.Weight					= 5 
SWEP.AutoSwitchTo				= false
SWEP.AutoSwitchFrom			= false
SWEP.Category = "Dead Ringer"
SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.WeaponID = AMMO_DEADRING
SWEP.LimitedStock = true
SWEP.Base = "weapon_tttbase"
SWEP.AllowDrop = false

SWEP.NoSights = true

SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Ammo				= ""

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Ammo			= "none" 
------------------------------------------
NPCs = { -- if you have custom NPC-enemies, you can add them here
"npc_zombie",
"npc_fastzombie",
"npc_zombie_torso",
"npc_poisonzombie",
"npc_antlion",
"npc_antlionguard",
"npc_hunter",
"npc_antlion_worker",
"npc_headcrab_black",
"npc_headcrab",
"npc_headcrab_fast",
"npc_combine_s",
"npc_zombine",
"npc_fastzombie_torso",
"npc_rollermine",
"npc_turret_floor",
"npc_cscanner",
"npc_clawscanner",
"npc_manhack",
"npc_tripmine",
"npc_barnacle",
"npc_strider",
"npc_metropolice",
}

-----------------------------------------------------------------------

-- disable dead rnger on spawn
if SERVER then
	function dringerspawn( p )
if p:GetNWBool("Dead") == true then
p:SetNWBool(	"Status",			0)
p:GetViewModel():SetMaterial("")
p:SetMaterial("")
p:SetColor(255,255,255,255)
end
p:SetNWBool(	"Status",			0)
p:SetNWBool(	"Dead",			false)
p:SetNWBool(	"CanAttack",			true)
p:SetNWInt("drcharge", 8 )

	end
	hook.Add( "PlayerSpawn", "DRingerspawn", dringerspawn );
end
-----------------------------------
function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end
-----------------------------------
function SWEP:Deploy()
if SERVER then
		self.Owner:DrawWorldModel(false)
		self.Owner:DrawWorldModel(false)

local ent = ents.Create("deadringer")			
ent:SetOwner(self.Owner) 
ent:SetParent(self.Owner)
ent:SetPos(self.Owner:GetPos())
ent:SetColor(self.Owner:GetColor())
ent:SetMaterial(self.Owner:GetMaterial())
ent:Spawn()	
end

self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
if !self.Owner:GetNWBool("Status") == 3 or !self.Owner:GetNWBool("Status") == 4 or !self.Owner:GetNWBool("Status") == 1 then
self.Owner:SetNWBool(	"Status",			2)
end
return true
end
-----------------------------------
function SWEP:Think()
end

function SWEP:Holster()
	local worldmodel = ents.FindInSphere(self.Owner:GetPos(),0.6)
	for k, v in pairs(worldmodel) do 
if v:GetClass() == "deadringer" and v:GetOwner() == self.Owner then
v:Remove()
end
end
return true
end

-----------------------------------
--------View Model material--------
-----------------------------------

if CLIENT then
function drvm()

if LocalPlayer():GetNWBool("Dead") == true and LocalPlayer():Alive() then 
LocalPlayer():GetViewModel():SetMaterial( "models/props_c17/fisheyelens")

elseif LocalPlayer():GetNWBool("Dead") == false and LocalPlayer():Alive() then
LocalPlayer():GetViewModel():SetMaterial("models/weapons/v_crowbar.mdl")
end
end
hook.Add( "Think", "DRVM", drvm )
end


-----------------------------------------------------------

---------------------------------
---------hooks--------
---------------------------------
if SERVER then

function checkifwehaveourdr(ent,dmginfo)
local attacker = dmginfo:GetAttacker()
local getdmg = dmginfo:GetDamage()
local reducedmg = getdmg * REDUCEDAMAGE
	if ent:IsPlayer() then
	local p = ent
	local infl
		if attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
			if p:GetNWBool("CanAttack") == true and p:GetNWBool("Dead") == false and p:GetNWBool("Status") == 1 then
			dmginfo:SetDamage(math.random(5,15))
			p:fakedeath()
			elseif p:GetNWBool("CanAttack") == false and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then
			dmginfo:SetDamage(math.random(0,1))
			end
		elseif attacker:IsPlayer() then
			if p:GetNWBool("CanAttack") == true and p:GetNWBool("Dead") == false and p:GetNWBool("Status") == 1 then
			dmginfo:SetDamage(getdmg - reducedmg )
			p:fakedeath()
			elseif p:GetNWBool("CanAttack") == false and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then
			dmginfo:SetDamage(getdmg - reducedmg )
			end
		elseif attacker:IsNPC() then
			if p:GetNWBool("CanAttack") == true and p:GetNWBool("Dead") == false and p:GetNWBool("Status") == 1 then
			dmginfo:SetDamage(getdmg - reducedmg )
			p:fakedeath()
			-- if npc has weapon (eg: metrocop with stunstick) then inflictor = npc's weapon
			if IsValid(attacker:GetActiveWeapon()) then
			infl = attacker:GetActiveWeapon():GetClass()
			-- else  (eg: zombie or hunter) then inflictor = attacker
			else
			infl = attacker:GetClass()
			end
			elseif p:GetNWBool("CanAttack") == false and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then
			dmginfo:SetDamage(getdmg - reducedmg )
			end
		else
			if p:GetNWBool("CanAttack") == true and p:GetNWBool("Dead") == false and p:GetNWBool("Status") == 1 then
			dmginfo:SetDamage(getdmg - reducedmg )
			p:fakedeath()
			elseif p:GetNWBool("CanAttack") == false and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then
			dmginfo:SetDamage(getdmg - reducedmg )
			end
		end
	end
end
hook.Add("EntityTakeDamage", "CheckIfWeHaveDeadRinger", checkifwehaveourdr)
end
if SERVER then
function disablefakecorpseondeath(p, attacker)
if p:IsValid() and p:GetNWBool("CanAttack") == false and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then
p:uncloak()
end
end
hook.Add("DoPlayerDeath", "RemoveFakeCorpse", disablefakecorpseondeath)

-- here goes the dead ringer charge/regenerating system
function drthink()
	for _, p in pairs(player.GetAll()) do
		if p:IsValid() and p:GetNWBool("Dead") == false and p:GetNWBool("Status") == 4 then
			if p:GetNWInt("drcharge") < 8 then
			p.drtimer = p.drtimer or CurTime() + 0.1
				if CurTime() > p.drtimer then
				p.drtimer = CurTime() + 4
				p:SetNWInt("drcharge", p:GetNWInt("drcharge") + 1)
				end
			elseif 	p:GetNWInt("drcharge") == 8 then
			p:SetNWBool("Status", 1)
			umsg.Start( "DRReady", p )
			umsg.End()
			end
		elseif p:IsValid() and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then
			for _, v in pairs(p:GetWeapons()) do
			v:SetNextPrimaryFire(CurTime() + 0.2)
			v:SetNextSecondaryFire(CurTime() +0.2)
			end
			p:DrawWorldModel(false)
			for _,npc in pairs(ents.GetAll()) do 
				if npc:IsNPC() then 
					for _,v in pairs(NPCs) do
						if npc:GetClass() == v then
						npc:AddEntityRelationship(p,D_NU,99)
						end
					end
				end
			end
			if p:KeyPressed( IN_ATTACK2 ) then
			p:uncloak()
			p:SetNWInt("drcharge", 2 )
			end
			if p:GetNWInt("drcharge") <= 8 and p:GetNWInt("drcharge") > 0 then
			p.cltimer = p.cltimer or CurTime() + 2
				if CurTime() > p.cltimer then
				p.cltimer = CurTime() + 2
				p:SetNWInt("drcharge", p:GetNWInt("drcharge") - 1)
				end
			elseif p:GetNWInt("drcharge") == 0 then
				p:uncloak()
			end
		end
	end
end
hook.Add( "Think", "DR_ENERGY", drthink )



end

function DRFootsteps( p, vPos, iFoot, strSoundName, fVolume, pFilter )

if p:Alive() and p:IsValid() then

if p:GetNWBool("CanAttack") == false and p:GetNWBool("Dead") == true and p:GetNWBool("Status") == 3 then

if CLIENT then
return true
end
end
end
end

hook.Add("PlayerFootstep","DeadRingerFootsteps",DRFootsteps)


-------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

if self.Owner:GetNWBool("CanAttack") == true and self.Owner:GetNWBool("Dead") == false and self.Owner:GetNWBool("Status") != 4 then

self.Owner:SetNWBool(	"Status",			1)

self.Weapon:EmitSound("buttons/blip1.wav")

else
return
end
end

function SWEP:SecondaryAttack()
if self.Owner:GetNWBool("CanAttack") == true and self.Owner:GetNWBool("Dead") == false and self.Owner:GetNWBool("Status") != 4 then
self.Owner:SetNWBool(	"Status",			2)
self.Weapon:EmitSound("buttons/blip1.wav", 100, 73)
else
return
end
end
-------------------------------------------------------------------------------------


local plymeta = FindMetaTable( "Player" );

function plymeta:fakedeath()

self:SetNWBool("Dead", true)
self:SetNWBool("CanAttack", false)
self:SetNWBool("Status", 3)




---------------------------
--------"corpse"-------
---------------------------
-- this is time to make our corpse

	local weapons = {"weapon_zm_pistol","weapon_ttt_m16","weapon_zm_revolver","weapon_zm_shotgun","weapon_ttt_glock","weapon_zm_mac10","weapon_zm_revolver","weapon_zm_sledge"}

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
	rag.SetOwner(self)

	rag:Spawn(self)
	rag:Activate(self)

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

-- here goes the uncloak function
function plymeta:uncloak()

	for _, rag in pairs(ents.GetAll()) do
		if rag:GetClass() == "prop_ragdoll" and rag.player_ragdoll == self then
		rag:Remove()
		end
	end
	
	for _,npc in pairs(ents.GetAll()) do 
		if npc:IsNPC() then 
			for k,v in pairs(NPCs) do 
				if npc:GetClass() == v then
				npc:AddEntityRelationship(self,D_HT,99) 
				end
			end
		end
	end
	
	self:SetNWBool(	"Dead", false)
	self:SetNWBool(	"CanAttack", true)
	self:SetNWBool(	"Status", 4)
	self:SetNWBool("is_pretending", false)

	local mdl = GAMEMODE.playermodel or "models/player/phoenix.mdl"
	util.PrecacheModel(mdl)
	self:SetModel(mdl)

	self:DrawWorldModel(true)

	self:EmitSound(Sound( "ttt/spy_uncloak_feigndeath.wav" ))

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetEntity( self )
	util.Effect( "uncloak", effectdata )
end

