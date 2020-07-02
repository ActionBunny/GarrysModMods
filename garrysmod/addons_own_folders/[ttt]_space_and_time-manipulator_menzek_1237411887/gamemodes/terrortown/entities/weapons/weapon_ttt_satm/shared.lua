local detectiveEnabled = CreateConVar("ttt_satm_detective", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should Detectives be able to buy the SATM?")
local traitorEnabled = CreateConVar("ttt_satm_traitor", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should Traitors be able to buy the SATM?")
local satmduration = CreateConVar("ttt_satm_duration", 25, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How long the duration of the SATM should be?")

local metaPly = FindMetaTable( "Player" )
AccessorFunc( metaPly, "satmswap", "SATMSwap", FORCE_BOOL )
AccessorFunc( metaPly, "satmdev", "SATMDev" )
AccessorFunc( metaPly, "satmuser", "SATMUser" )

--GeneralSettings\\
SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AutoSpawnable = !detectiveEnabled:GetBool() && !traitorEnabled:GetBool()
SWEP.HoldType = "normal"
SWEP.AdminSpawnable = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Kind = !detectiveEnabled:GetBool() && !traitorEnabled:GetBool() && WEAPON_NADE || WEAPON_EQUIP2

--Serverside\\
if SERVER then
	AddCSLuaFile("shared.lua")
	resource.AddFile("materials/VGUI/ttt/icon_satm.vmt")
	resource.AddFile("sound/weapons/satm/sm_enter.wav")
	resource.AddFile("sound/weapons/satm/sm_exit.wav")
	resource.AddWorkshop("671603913")
	util.AddNetworkString("SATMStartSound")
	util.AddNetworkString("SATMEndSound")
	util.AddNetworkString("SATMMessage")
end

--Clientside\\
if CLIENT then
	SWEP.PrintName = "SATM"
	SWEP.Slot = 7
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false
	SWEP.Icon = "VGUI/ttt/icon_satm"

	SWEP.EquipMenuData = {
		type = "weapon",
		desc = "The Space and Time-Manipulator! Short SATM!\nChoose a mode with MOUSE2 \nand active it with MOUSE1."
	}
end

--Damage\\
SWEP.Primary.Recoil = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Damage = 0
SWEP.Primary.Cone = 0.001
SWEP.Primary.ClipSize = 6
SWEP.Primary.ClipMax = 6
SWEP.Primary.DefaultClip = 6
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = ""
--Verschiedenes\\
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = true
SWEP.UseHands = false
SWEP.CanBuy = {}

if (detectiveEnabled:GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_DETECTIVE)
end

if (traitorEnabled:GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_TRAITOR)
end

SWEP.LimitedStock = true
--Sounds/Models\\
SWEP.ViewModel = "models/weapons/gamefreak/v_buddyfinder.mdl"
SWEP.WorldModel = ""
SWEP.Weight = 5

function SWEP:Initialize()
	self.satmmode = 1
	self.timescale = 1.5
	self:SetHoldType("normal")
	if CLIENT then
		self:AddHUDHelp("MOUSE1 to confirm.", "MOUSE2 to select mode.", false)
	end
end

function SWEP:Deploy()
	if SERVER then
		net.Start("SATMMessage")
		net.WriteInt(self.satmmode, 16)
		net.Send(self.Owner)
	end
	return self.BaseClass.Deploy(self)
end

local function ResetTimeScale()
	game.SetTimeScale(1)
	net.Start("SATMEndSound")
	net.Broadcast()
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:DoSATMAnimation(true)

	if SERVER then
		local owner = self.Owner
		if self.satmmode == 1 || self.satmmode == 2 || self.satmmode == 3 then
			timer.Remove("ResetSATM")
			game.SetTimeScale(self.timescale)
			net.Start("SATMStartSound")
			net.Broadcast()

			if self.satmmode != 3 then
				timer.Create("ResetSATM", satmduration:GetInt() * self.timescale, 1, ResetTimeScale)
			end
			
			self:TakePrimaryAmmo(1)
			
		elseif self.satmmode == 4 then
			if self.Owner:GetActiveWeapon():Clip1() < 2 then
				net.Start("SATMMessage")
				net.WriteInt(30, 16)
				net.Send(owner)
				return
			end
			
			if !owner:OnGround() or owner:Crouching() then
				net.Start("SATMMessage")
				net.WriteInt(20, 16)
				net.Send(owner)

				return
			end
			local aliveplayers = {}

			for k, v in pairs(player.GetAll()) do
				if v:IsTerror() and v != owner and !v:Crouching() then
					table.insert(aliveplayers, v)
				end
			end

			if #aliveplayers <= 0 then
				net.Start("SATMMessage")
				net.WriteInt(15, 16)
				net.Send(owner)
				return
			end

			table.Shuffle(aliveplayers)
			local ply = table.Random(aliveplayers)

			if ply:IsInWorld() then
				local plypos = ply:GetPos()
				local selfpos = owner:GetPos()
				local plyang = ply:EyeAngles()
				local selfang = owner:EyeAngles()
				owner:SetPos(plypos)
				owner:SetEyeAngles(plyang)
				ply:SetPos(selfpos)
				ply:SetEyeAngles(selfang)
			end

			net.Start("SATMMessage")
			net.WriteInt(10, 16)
			net.WriteString(ply:Nick())
			net.Send(owner)

			ply:SetSATMSwap( true )
			owner:SetSATMSwap( true )
			ply:SetSATMUser( owner )
			owner:SetSATMUser( owner )

			tname = Format("SATM_%d_%d", ply:EntIndex(), math.ceil(CurTime()))
			
			timer.Create( tname, 4, 1, function() 
				ply:SetSATMSwap( false )
				owner:SetSATMSwap( false )
			end)
			
			self:TakePrimaryAmmo(2)
			
		elseif self.satmmode == 5 then
			if self.Owner:GetActiveWeapon():Clip1() < 4 then
				net.Start("SATMMessage")
				net.WriteInt(40, 16)
				net.Send(owner)
				return
			end
			
			if !owner:OnGround() or owner:Crouching() then
				net.Start("SATMMessage")
				net.WriteInt(20, 16)
				net.Send(owner)

				return
			end
			
			local aliveplayers = {}
			local aliveplayerspositions = {}
			
			for k, v in pairs(player.GetAll()) do
				if v:IsTerror() and !v:Crouching() then -- 
					table.insert(aliveplayers, v)
					table.insert(aliveplayerspositions, v:GetPos())
				end
			end

			if #aliveplayers <= 1 then
				net.Start("SATMMessage")
				net.WriteInt(15, 16)
				net.Send(owner)
				return
			end
			
			table.Shuffle(aliveplayerspositions)
			
			for i=1, #aliveplayers do
				local ply = aliveplayers[i]
				
				if ply:IsInWorld() then
					local pos = aliveplayerspositions[i]
					ply:SetPos(pos)
					ply:SetSATMSwap( true )
					ply:SetSATMUser( owner )
					tname = Format("SATM_%d_%d", ply:EntIndex(), math.ceil(CurTime()))
			
					timer.Create( tname, 4, 1, function() 
						ply:SetSATMSwap( false )
					end)
				end
			end

			net.Start("SATMMessage")
			net.WriteInt(11, 16)
			net.Send(owner)

			self:TakePrimaryAmmo(4)
			
		end
	end
end

function SWEP:SecondaryAttack()
	self:DoSATMAnimation(false)
	self.satmmode = self.satmmode + 1

	if self.satmmode >= 6 then
		self.satmmode = 1
	end

	if self.satmmode == 1 then
		self.timescale = 1.5
	elseif self.satmmode == 2 then
		self.timescale = 0.5
	elseif self.satmmode == 3 then
		self.timescale = 1
	end

	if SERVER then
		net.Start("SATMMessage")
		net.WriteInt(self.satmmode, 16)
		net.Send(self.Owner)
	end
end

function SWEP:DoSATMAnimation(bool)
	local switchweapon = bool
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	timer.Simple(0.3, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_VM_IDLE)
			if switchweapon && CLIENT && IsValid(self.Owner) && self.Owner == LocalPlayer() && self.Owner:Alive() then
				RunConsoleCommand("lastinv")
			end

			if SERVER && self:Clip1() <= 0 then
				self:Remove()
			end
		end
	end)
end

function SWEP:OnRemove()
	if CLIENT && IsValid(self.Owner) && self.Owner == LocalPlayer() && self.Owner:Alive() then
		RunConsoleCommand("lastinv")
	end
end

function SWEP:OnDrop()
	if SERVER then
		if game.GetTimeScale() != 1 then
			net.Start("SATMMessage")
			net.WriteInt(0, 16)
			net.Broadcast()
			game.SetTimeScale(1)
			net.Start("SATMEndSound")
			net.Broadcast()
			timer.Remove("ResetSATM")
		end

		self:Remove()
	end
end

if SERVER then
	hook.Add("TTTPrepareRound", "ResetSATM", function()
		game.SetTimeScale(1)
		timer.Remove("ResetSATM")
	end)
else
	net.Receive("SATMStartSound", function()
		surface.PlaySound("weapons/satm/sm_enter.wav")
	end)

	net.Receive("SATMEndSound", function()
		surface.PlaySound("weapons/satm/sm_exit.wav")
	end)

	net.Receive("SATMMessage", function()
		local mode = net.ReadInt(16)

		if mode == 0 then
			chat.AddText("SATM: ", Color(255, 255, 255), "The Space and Time-Manipulator is now destroyed and the time is reset!")
		elseif mode == 1 then
			chat.AddText("SATM: ", Color(255, 255, 255), "Mode: Faster time.")
		elseif mode == 2 then
			chat.AddText("SATM: ", Color(255, 255, 255), "Mode: Slower time.")
		elseif mode == 3 then
			chat.AddText("SATM: ", Color(255, 255, 255), "Mode: Normal time.")
		elseif mode == 4 then
			chat.AddText("SATM: ", Color(255, 255, 255), "Mode: Swap your position with a random player.")
		elseif mode == 5 then
			chat.AddText("SATM: ", Color(255, 255, 255), "Mode: Swap all players.")	
		elseif mode == 10 then
			local nick = net.ReadString()
			chat.AddText("SATM: ", Color(255, 255, 255), "You swapped your position with ", COLOR_GREEN, nick, COLOR_WHITE, ".")
		elseif mode == 11 then
			local nick = net.ReadString()
			chat.AddText("SATM: ", Color(255, 255, 255), "You swapped all players.")
		elseif mode == 15 then
			chat.AddText("SATM: ", Color(255, 255, 255), "No more players alive or all alive players crouching!")
		elseif mode == 20 then
			chat.AddText("SATM: ", Color(255, 255, 255), "You need to stand on the ground and to not be crouching to switch positions!")
		elseif mode == 30 then
			chat.AddText("SATM: ", Color(255, 20, 20), "You need atleast 2 charges to swap positions!")
		elseif mode == 40 then
			chat.AddText("SATM: ", Color(255, 20, 20), "You need atleast 4 charges to swap all positions!")	
		end

		chat.PlaySound()
	end)
end
--[[
local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "ttt_satm"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
end

function ENT:Draw()
end

function ENT:Think()
end
scripted_ents.Register(ENT, "ttt_satm", true)
]]
--[[
local function SATMGround( player, inWater, onFloater, speed )
	local tname = Format("SATM_%d_%d", player:EntIndex(), math.ceil(CurTime()))
	timer.Create( tname, 1, 1, function() 
		player:SetSATMSwap(false)
	end)
	
end
]]
local function SATMDamage( target, dmg )
	if target:IsPlayer() and target:Alive() then
		if not dmg:IsBulletDamage() or not dmg:IsExplosionDamage() or not dmg:GetDamageType( DMG_CRUSH ) then
			--if IsValid( target:GetSuperPush() ) then
				if target:GetSATMSwap() then
					local ent = ents.Create('weapon_ttt_satm')
					dmg:SetAttacker( target:GetSATMUser() )
					dmg:SetInflictor( ent )
					--print( dmg:GetInflictor():GetClass() )
					ent:Remove()
				end
			--end
		end
	end
end

hook.Add("EntityTakeDamage","SATMDamage", SATMDamage)
--hook.Add("OnPlayerHitGround","SATMGround", SATMGround)