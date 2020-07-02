--// TTT Death Faker //--
-- Author: Exho with fixes by Zerf
-- Version: 9/7/15

if SERVER then
	AddCSLuaFile() 
end

local explode = CreateConVar( "df_explodeondeath", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If fake bodies explode on real player death" )
local editrole = CreateConVar( "df_editrole", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If Traitors can edit their body's role, defaults to T" )
local editdeath = CreateConVar( "df_editdeathtype", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If Traitors can edit their death type, defaults Crush" )
local identify = CreateConVar( "df_identifybody", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If the fake body is automatically identified by a random player after being dropped" )
local traitoronly = CreateConVar( "df_traitoronly", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should innocents be allowed to use this weapon?" )

if CLIENT then
	SWEP.PrintName		= "Death Faker"
	SWEP.Slot			= 6
	SWEP.DrawAmmo		= true
	SWEP.DrawCrosshair	= false
	SWEP.Author			= "Exho"

	SWEP.Icon = "vgui/ttt/icon_rock"

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = [[Fool the innocents into thinking you are dead!
		Left Mouse button to create the body.
		-Change role with Right Mouse.
		-Change death type with Reload.
]]
	}
end
 
SWEP.Base			= "weapon_tttbase"

SWEP.HoldType		= "normal"

SWEP.Kind			= WEAPON_EQUIP
SWEP.CanBuy			= {ROLE_TRAITOR}
SWEP.LimitedStock	= true
SWEP.AllowDrop 		= false

SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 2
SWEP.Primary.ClipSize		= -1
SWEP.Primary.ClipMax		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false

SWEP.Secondary.Delay = 1

SWEP.UseHands		= true
SWEP.ViewModel		= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFlip	= false

SWEP.NextReload		= 1
SWEP.NextRoleChange	= 1
SWEP.ReloadDelay	= 0.5
SWEP.Weps			= {"weapon_ttt_m16", "weapon_ttt_glock", "weapon_zm_pistol", "weapon_zm_rifle"}
SWEP.CurrentRole	= {ROLE_TRAITOR, "Traitor", Color(250, 20, 20)}
SWEP.Roles			= {
	{ROLE_INNOCENT, "Innocent", Color(20, 250, 20)}, 
	{ROLE_TRAITOR, "Traitor", Color(250, 20, 20)}
}
SWEP.CurrentDType	= {DMG_BLAST, "BLAST"}
SWEP.DeathTypes		= {
	{DMG_BULLET, "BULLET"},
	{DMG_BURN, "BURN"},
	{DMG_CRUSH, "CRUSH"},
	{DMG_SLASH, "SLASH"},
	{DMG_BLAST, "BLAST"},
	{DMG_GENERIC, "GENERIC"},
}

function SWEP:PrimaryAttack()
	local ply = self.Owner
	
	-- Innocents don't need to fake their deaths!
	if ply:GetRole() != ROLE_TRAITOR and traitoronly:GetBool() == true then
		if SERVER then
			util.EquipmentDestroyed(self:GetPos())
			self:Remove()
		end
		return
	end
	
	if SERVER then
		if not IsValid(ply) then return end

		local dmginfo = DamageInfo()
		dmginfo:SetDamageType( self.CurrentDType[1] ) 
		dmginfo:SetAttacker( ply ) 

		body = CORPSE.Create(ply, ply, dmginfo)
		CORPSE.SetCredits(body, 0) -- Prevents the use of the ragdoll to farm credits
		CORPSE.SetPlayerNick(body, ply)
		body.was_role = self.CurrentRole[1]
		body.killer_sample = nil
		if self.CurrentDType[1] == DMG_BULLET then
			body.was_headshot = table.Random({true, false}) -- Random chance of dying from a headshot
			body.dmgwep = table.Random(self.Weps) -- Random weapon to die from
		end
		body:EmitSound("vo/npc/male01/pain07.wav")
		body:SetDTBool(CORPSE.dti.BOOL_FOUND, false)

		ply.fake_corpse = body -- Tie the body to the player
		ply:SetNWBool("FakedDeath", true)
		self:Remove() 
		
		if identify:GetBool() then -- Automatically identify the body after dropping it
			CORPSE.SetFound(body, true)
			ply:SetNWBool("body_found", true)
			
			-- We are going to use a random player to identify this fake body. 
			local finder = table.Random( player.GetAll() )
			if finder == ply or finder:IsSpec() or not finder:Alive() then
				finder = table.Random( player.GetAll() )
			end
			
			for k, v in pairs(player.GetAll()) do -- Tell the other player's that this body has been 'found'
				CustomMsg(v,  finder:Nick().." found the body of "..ply:Nick()..". He was a Traitor!", color_white)
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self.NextRoleChange then return end
	self.NextRoleChange = CurTime() + self.Secondary.Delay

	if not editrole:GetBool() then return end

	self.CurrentRole = table.FindNext(self.Roles, self.CurrentRole)

	if CLIENT then
		chat.AddText( Color( 200, 20, 20 ), "[Death Faker] ", Color( 250, 250, 250 ), 
		"Your body's role will be ", self.CurrentRole[3], self.CurrentRole[2])
	end
end

function SWEP:Reload()
	if CurTime() < self.NextReload then return end
	self.NextReload = CurTime() + self.ReloadDelay

	if not editdeath:GetBool() then return end

	self.CurrentDType = table.FindNext(self.DeathTypes, self.CurrentDType)

	if CLIENT then
		chat.AddText( Color( 200, 20, 20 ), "[Death Faker] ", Color( 250, 250, 250 ), "Changed Death Type to ",
		Color(237, 177, 12), self.CurrentDType[2])
	end
end

hook.Add("TTTScoreGroup", "TTTDeathFakerScoreboard", function(ply)
    if ply:GetNWBool("FakedDeath") and ply:GetNWBool("body_found", false) then
        return GROUP_FOUND
    end
end)

hook.Add( "PlayerDeath", "ExplodeTheNonBeliever", function(ply)
	local body = ply.fake_corpse
	if IsValid( body ) then
		if not explode:GetBool() then ply.fake_corpse:Remove() return end

		body:Ignite(5, 5) -- Replicate the burning of a body
		util.PaintDown(body:GetPos(), "Scorch", body) -- TTT specific function

		timer.Simple(5, function()
			for k, v in pairs(player.GetAll()) do -- Tell our Traitor friends that someone's body exploded
				if v:GetRole() == ROLE_TRAITOR then
					CustomMsg(v, ply:Nick() .. "'s fake body has been detonated!", Color(200,0,0))
				end
			end
			local expl = ents.Create( "env_explosion" ) -- Create a tiny explosion for effect
			expl:SetPos( body:GetPos() ) -- Put it where our body currently is
			expl:SetOwner( ply ) -- The body owner takes credit it anyone gets damaged...
			expl:Spawn()
			expl:SetKeyValue( "iMagnitude", "10" )
			expl:Fire( "Explode", 0, 0 ) -- Kablam
			expl:EmitSound( "siege/big_explosion.wav", 200, 200 )
			body:Remove()
			ply.fake_corpse = nil
			ply:SetNWBool("FakedDeath", false)
		end)
	end
end)

hook.Add("TTTPrepareRound", "RemoveDeathFakers", function()
	for k, v in pairs(player.GetAll()) do
		v:SetNWBool("FakedDeath", false)
	end
end)

hook.Add("PlayerDeath", "RemoveDeathFaker", function( vic )
	vic:SetNWBool("FakedDeath", false)
end)