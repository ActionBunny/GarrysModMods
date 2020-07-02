--[[]]

--Author information
AddCSLuaFile()
resource.AddFile( "materials/vgui/ttt/icon_traitor_remote.vmt" )
resource.AddFile( "materials/vgui/ttt/icon_traitor_remote.vtf" )

local metaplys = FindMetaTable( "Player" )
AccessorFunc( metaplys, "isremoted", "IsRemoted", FORCE_BOOL)
AccessorFunc( metaplys, "ismuted", "IsMuted", FORCE_BOOL)
AccessorFunc( metaplys, "israndomized", "IsRandomized", FORCE_BOOL)

local metaents= FindMetaTable( "Entity" )
AccessorFunc( metaents, "remotedent", "RemotedEnt" )
AccessorFunc( metaents, "isremoting", "IsRemoting", FORCE_BOOL )

if SERVER then
	util.AddNetworkString( "FSingleAction" )
	util.AddNetworkString( "RSingleAction" )
	util.AddNetworkString( "FRandomize" )
	util.AddNetworkString( "RRandomize" )
	util.AddNetworkString( "CreateRemoteHUD" )
	util.AddNetworkString( "RemoveRemoteHUD" )
	util.AddNetworkString( "UpdateRemoteHUD" )
	
elseif CLIENT then
	LANG.AddToLanguage("english", "traitorremote_name", "Traitor Remote")
	LANG.AddToLanguage("english", "traitorremote_desc", "Remote control your fellow terrorists. Removed when dropped.")
	
	SWEP.PrintName    			= "traitorremote_name"
	SWEP.Slot         			= 7		-- +1
	SWEP.Icon					= "VGUI/ttt/icon_traitor_remote"
	SWEP.EquipMenuData 			= {type = "item_weapon", desc = "traitorremote_desc"}
end

SWEP.Base               		= "weapon_tttbase"
SWEP.DrawCrosshair				= false
SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "AirboatGun"
SWEP.Primary.SoundSuccess		= Sound("garrysmod/ui_click.wav")
SWEP.Primary.SoundFail 			= Sound("garrysmod/ui_hover.wav")
SWEP.Primary.Delay 				= 0 --notwendig?
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"
SWEP.Secondary.Sound 			= Sound("hl1/fvox/beep.wav")
SWEP.Secondary.Delay			= 0.08
SWEP.DrawAmmo					= false
SWEP.Kind						= WEAPON_EQUIP
SWEP.AutoSpawnable				= false
SWEP.CanBuy						= {ROLE_TRAITOR}	-- only traitors can buy
SWEP.LimitedStock				= true				-- only buyable once
SWEP.IsSilent					= false				-- Pull out faster than standard guns
SWEP.AllowDrop					= true			-- UNTIL VIEWMODEL DROPPING ISSUE is fixed
SWEP.NoSights					= true


SWEP.HoldType 					= "pistol"
SWEP.ViewModelFOV 				= 70
SWEP.ViewModelFlip 				= true
SWEP.UseHands 					= false
--SWEP.ViewModel 					= "models/weapons/v_slam.mdl"
--SWEP.WorldModel 				= "models/props/cs_office/projector_remote.mdl"

SWEP.ViewModel			= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"

SWEP.ShowViewModel 				= true
SWEP.ShowWorldModel 			= true
SWEP.ViewModelBoneMods = {
	["Bip01_L_Clavicle"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Hand"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger4"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger22"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Detonator"]				= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger42"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Slam_panel"]				= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger02"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger0"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger11"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Forearm"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Slam_base"]				= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger3"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger1"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger2"]			= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger32"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger31"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger41"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger12"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger01"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_UpperArm"]		= { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-30, -30, -30), angle = Angle(-180, -180, -180) }
}

SWEP.VElements = {
	["remote"] 					= { type = "Model", model = "models/props/cs_office/projector_remote.mdl", bone = "Bip01_R_Finger0", rel = "", pos = Vector(3.635, -1.558, -2.597), angle = Angle(15.194, 22.208, 38.57), size = Vector(1.274, 1.274, 1.274), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["remote"] 					= { type = "Model", model = "models/props/cs_office/projector_remote.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.714, 1.557, -3.636), angle = Angle(-10.521, -115.714, 108.699), size = Vector(1.274, 1.274, 1.274), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

local Actions		= {"PrimAttack", "SecAttack", "Forward", "Back", "Left", "Right", "Jump", "Duck", "Walk", "Scoreboard","ViewPunch", "Mute", "Randomize", "Control"}
local randomKeyTable 			= { "PrimAttack", "Forward", "Back", "Left", "Right", "Jump", "Duck" }
local shuffledKeyTable			= table.Shuffle( randomKeyTable )

SWEP.CurrentAction				= nil
SWEP.CurrentActionCounter		= 0
SWEP.Actions					= Actions
SWEP.NextRemoteAction			= 0
SWEP.NextRemoteActionChange		= 0
SWEP.trEntity					= nil
SWEP.remoting					= false
SWEP.nextpunch 					= 0
SWEP.numActions					= table.Count( Actions )

if CLIENT then --actions
	net.Receive("FSingleAction", function()
		local netKey = net.ReadString()
		--chat.AddText( "REMOTED" )
		hook.Add("CreateMove","ForceSingleAction", function( cmd )
			if netKey == "Forward" then
				cmd:SetForwardMove( 10000 )
			end
			if netKey == "Back" then
				cmd:SetForwardMove( -10000 )
			end
			if netKey == "Left" then
				cmd:SetSideMove( -10000 )
			end
			if netKey == "Right" then
				cmd:SetSideMove( 10000 )
			end
			if netKey == "Jump" then
				cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
			end
			if netKey == "Duck" then
				cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
			end
			if netKey == "Walk" then
				cmd:SetButtons( cmd:GetButtons() + IN_WALK )
			end
			if netKey == "Scoreboard" then
				LocalPlayer():ConCommand( "+showscores" )
			end
			if netKey == "PrimAttack" then
				cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
			end
			if netKey == "SecAttack" then
				cmd:SetButtons( cmd:GetButtons() + IN_ATTACK2 )
			end
		end)
	end)	
	
	net.Receive("RSingleAction", function()
		--chat.AddText( "UNREMOTED" )
		hook.Remove( "CreateMove","ForceSingleAction" )
	end)
	
-----------------------------------------------------	
	
	net.Receive("FRandomize", function()
		--chat.AddText( "RANDOMIZED" )
		local shKey1 = net.ReadString()
		local shKey2 = net.ReadString()
		local shKey3 = net.ReadString()
		local shKey4 = net.ReadString()
		local shKey5 = net.ReadString()
		local shKey6 = net.ReadString()
		local shKey7 = net.ReadString()
		
		hook.Add("CreateMove","ForceRandomize", function( cmd )
			
			if cmd:KeyDown( IN_ATTACK ) then
				cmd:SetButtons( cmd:GetButtons() - IN_ATTACK )
				if shKey1 == "Forward" then
					cmd:SetForwardMove( 10000 )
				elseif shKey1 == "Back" then
					cmd:SetForwardMove( -10000 )
				elseif shKey1 == "Left" then
					cmd:SetSideMove( -10000 )
				elseif shKey1 == "Right" then
					cmd:SetSideMove( 10000 )
				elseif shKey1 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey1 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey1 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end				
			end
			
			if cmd:KeyDown( IN_JUMP ) then
				cmd:SetButtons( cmd:GetButtons() - IN_JUMP )
				if shKey2 == "Forward" then
					cmd:SetForwardMove( 10000 )				
				elseif shKey2 == "Back" then
					cmd:SetForwardMove( -10000 )				
				elseif shKey2 == "Left" then
					cmd:SetSideMove( -10000 )				
				elseif shKey2 == "Right" then
					cmd:SetSideMove( 10000 )				
				elseif shKey2 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey2 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey2 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end		
			end
			
			if cmd:KeyDown( IN_FORWARD ) then
				cmd:SetForwardMove( cmd:GetForwardMove() - 10000 )
				if shKey3 == "Forward" then
					cmd:SetForwardMove( 10000 )				
				elseif shKey3 == "Back" then
					cmd:SetForwardMove( -10000 )				
				elseif shKey3 == "Left" then
					cmd:SetSideMove( -10000 )				
				elseif shKey3 == "Right" then
					cmd:SetSideMove( 10000 )				
				elseif shKey3 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey3 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey3 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end			
			end			
			
			if cmd:KeyDown( IN_BACK ) then
				cmd:SetForwardMove( cmd:GetForwardMove() + 10000 )
				if shKey4 == "Forward" then
					cmd:SetForwardMove( 10000 )				
				elseif shKey4 == "Back" then
					cmd:SetForwardMove( -10000 )				
				elseif shKey4 == "Left" then
					cmd:SetSideMove( -10000 )				
				elseif shKey4 == "Right" then
					cmd:SetSideMove( 10000 )				
				elseif shKey4 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey4 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey4 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end				
			end			
			
			if cmd:KeyDown( IN_MOVELEFT ) then
				cmd:SetSideMove( cmd:GetSideMove() + 10000 )
				if shKey5 == "Forward" then
					cmd:SetForwardMove( 10000 )				
				elseif shKey5 == "Back" then
					cmd:SetForwardMove( -10000 )				
				elseif shKey5 == "Left" then
					cmd:SetSideMove( -10000 )				
				elseif shKey5 == "Right" then
					cmd:SetSideMove( 10000 )				
				elseif shKey5 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey5 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey5 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end	
			end
			
			if cmd:KeyDown( IN_MOVERIGHT ) then
				cmd:SetSideMove( cmd:GetSideMove() - 10000 )
				if shKey6 == "Forward" then
					cmd:SetForwardMove( 10000 )				
				elseif shKey6 == "Back" then
					cmd:SetForwardMove( -10000 )				
				elseif shKey6 == "Left" then
					cmd:SetSideMove( -10000 )				
				elseif shKey6 == "Right" then
					cmd:SetSideMove( 10000 )				
				elseif shKey6 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey6 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey6 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end	
			end
			
			if cmd:KeyDown( IN_DUCK ) then
				cmd:SetButtons( cmd:GetButtons() - IN_DUCK )
				if shKey7 == "Forward" then
					cmd:SetForwardMove( 10000 )				
				elseif shKey7 == "Back" then
					cmd:SetForwardMove( -10000 )				
				elseif shKey7 == "Left" then
					cmd:SetSideMove( -10000 )				
				elseif shKey7 == "Right" then
					cmd:SetSideMove( 10000 )				
				elseif shKey7 == "PrimAttack" then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				elseif shKey7 == "Jump" then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				elseif shKey7 == "Duck" then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end	
			end		
		end)
	end)	
	
	net.Receive("RRandomize", function()
		hook.Remove( "CreateMove","ForceRandomize" )
	end)
end

---------------------------------------------------------------
local function UpdateRemoteHud( WEP )
	if SERVER then
		if IsValid( WEP:GetRemotedEnt() ) then
			netEntity = WEP:GetRemotedEnt():Nick()
		else
			netEntity = "Look at Target and Reload."
		end
		net.Start( "UpdateRemoteHUD" )
		net.WriteString( WEP.CurrentAction )
		net.WriteString( netEntity )
		net.Send( WEP:GetOwner() )
	end
end

local function ForceControl( ent, caller )
	if CLIENT then return end
	
	if caller:KeyDown( IN_FORWARD ) then
		--net.Start( "FSingleAction" )
		--net.WriteString( "Back" )
		--net.Send( caller )
		net.Start( "FSingleAction" )
		net.WriteString( "Forward" )
		net.Send( ent )
		--caller stillstehen
		--ent bewegen
	end
	
	if caller:KeyDown( IN_BACK ) then
		--net.Start( "FSingleAction" )
		--net.WriteString( "Forward" )
		--net.Send( caller )
		net.Start( "FSingleAction" )
		net.WriteString( "Back" )
		net.Send( ent )
	end
	
	if caller:KeyDown( IN_MOVELEFT ) then
		--net.Start( "FSingleAction" )
		--net.WriteString( "Right" )
		--net.Send( caller )
		net.Start( "FSingleAction" )
		net.WriteString( "Left" )
		net.Send( ent )
	end
	
	if caller:KeyDown( IN_MOVERIGHT ) then
		--net.Start( "FSingleAction" )
		--net.WriteString( "Left" )
		--net.Send( caller )
		net.Start( "FSingleAction" )
		net.WriteString( "Right" )
		net.Send( ent )
	end
	
	if caller:KeyDown( IN_JUMP ) then
		--net.Start( "FMirrorAction" )
		--net.WriteString( "Jump" )
		--net.Send( caller )
		net.Start( "FSingleAction" )
		net.WriteString( "Jump" )
		net.Send( ent )
	end
	
	if caller:KeyDown( IN_DUCK ) then
		--net.Start( "FSingleAction" )
		--net.WriteString( "Left" )
		--net.Send( caller )
		net.Start( "FSingleAction" )
		net.WriteString( "Duck" )
		net.Send( ent )
	end
end

local function ForceViewPunch( ent )
	if SERVER then
		--print( "Remote: Forced " .. ent:Nick() .. " to do ViewPunch")
		local eyeang = ent:EyeAngles()

		--local j = 180
		eyeang.pitch = math.Clamp(eyeang.pitch + math.Rand(-90, 90), -90, 90)
		eyeang.yaw = math.Clamp(eyeang.yaw + math.Rand(-180, 180), -90, 90)
		ent:SetEyeAngles(eyeang)
	end	
end

local function ForceRandomize( ent )
	if SERVER then
		--print( "Remote: Forced " .. ent:Nick() .. " to randomize")
		net.Start( "FRandomize" )
		net.WriteString( shuffledKeyTable[1] )
		net.WriteString( shuffledKeyTable[2] )
		net.WriteString( shuffledKeyTable[3] )
		net.WriteString( shuffledKeyTable[4] )
		net.WriteString( shuffledKeyTable[5] )
		net.WriteString( shuffledKeyTable[6] )
		net.WriteString( shuffledKeyTable[7] )
		net.Send( ent )
	end
end

local function ForceSingleAction( action, ent)
	--print( "Remote: Forced " .. ent:Nick() .. " to do " .. action )
	net.Start( "FSingleAction" )
	net.WriteString( action )
	net.Send( ent )
end

local function ForceMute( ent )
	ent:SetNWBool( "RemoteMuted", true ) --aus alive raus und in dead rein
	hook.Run( "RemoteMute", ent )
	--file.Write("dead.txt", "")
	--file.Write("alive.txt", "")
	
	--for k, v in pairs( player.GetAll() ) do
	--	if ( v:Alive() ) and v:GetNWBool( "RemoteMuted", false ) == false then
	--		file.Append("alive.txt",v:SteamID().."\n")
	--	else
	--		file.Append("dead.txt",v:SteamID().."\n")
	--	end
	--end
end

local function UnMute( ent )
	tname = "RemoteUnMute" .. ent:Nick() .. CurTime()
	timer.Create( tname, 1, 1, function()
		ent:SetNWBool( "RemoteMuted", false )
		--file.Write("dead.txt", "")
		--file.Write("alive.txt", "")
		hook.Run( "RemoteUnMute", ent )
		--for k, v in pairs( player.GetAll() ) do
		--	if ( v:Alive() ) and v:GetNWBool( "RemoteMuted", false ) == false then
		--		file.Append("alive.txt",v:SteamID().."\n")
		--	else
		--		file.Append("dead.txt",v:SteamID().."\n")
		--	end
		--end
	end)
end

function SWEP:ForceAction( ent )
	if CLIENT then return end
	if not IsValid( ent ) then return end
	ent.was_pushed = {att=self.Owner, t=CurTime(), infl=self}
	if self.CurrentAction == "PrimAttack" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "SecAttack" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Forward" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Back" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Left" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Right" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Jump" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Duck" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Walk" then
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "Scoreboard" then	
		ForceSingleAction( self.CurrentAction, ent)
	
	elseif self.CurrentAction == "ViewPunch" then
		if CurTime() > self.nextpunch then
			self.nextpunch = CurTime() + 2.5
			ForceViewPunch( ent )
		end
		
	elseif self.CurrentAction == "Mute" then	
		ForceMute( ent )
	
	elseif self.CurrentAction == "Randomize" then	
		ForceRandomize( ent )
	
	elseif self.CurrentAction == "Control" then	
		ForceControl( ent, self.Owner )
	end				
end

local function ResetAction( ent )
	if CLIENT then return end
	if not IsValid( ent ) then return end
	--print( "Remote: Resetaction " .. ent:Nick() )
	net.Start( "RSingleAction" )
	net.Send( ent )

	net.Start( "RRandomize" )
	net.Send( ent )
	
	UnMute( ent )
end

function SWEP:Think()
	
	if self.Owner:KeyDown( IN_ATTACK2 ) then --goes down
		if CurTime() < self.NextRemoteActionChange then return end
		self.NextRemoteActionChange = CurTime() + 0.1
		self:NextThink( CurTime() + 0.15 )
		
		--if self.remoting == true then
			ResetAction( self:GetRemotedEnt() )
			ResetAction( self.Owner )
			--self.remoting = false
		--end
		
		self.CurrentActionCounter = self.CurrentActionCounter or 1
		self.CurrentActionCounter = self.CurrentActionCounter + 1
		if self.CurrentActionCounter > self.numActions then
			self.CurrentActionCounter = 1
		end
		self.CurrentAction = Actions[self.CurrentActionCounter]
	
		UpdateRemoteHud( self )
		
	elseif self.Owner:KeyDown( IN_USE ) then --goes up
		if CurTime() < self.NextRemoteActionChange then return end
		self.NextRemoteActionChange = CurTime() + 0.1
		self:NextThink( CurTime() + 0.15 )
		
		---if self.remoting == true then
			ResetAction( self:GetRemotedEnt() )
			ResetAction( self.Owner )
			--self.remoting = false
		--end
		
		self.CurrentActionCounter = self.CurrentActionCounter or 1
		self.CurrentActionCounter = self.CurrentActionCounter - 1
		if self.CurrentActionCounter < 1 then
			self.CurrentActionCounter = self.numActions
		end
		self.CurrentAction = Actions[self.CurrentActionCounter]
	
		UpdateRemoteHud( self )
	end
	
	if CLIENT then return end
	if not IsValid(self.Owner) then return end
	
	if not self.Owner:IsPlayer() then return end
	
	if not IsValid(self:GetRemotedEnt() ) then return end
	
	if not self:GetRemotedEnt():Alive() then self:SetRemotedEnt( nil ) return end
	
	ent = self:GetRemotedEnt()
	
	if self.Owner:KeyDown(IN_ATTACK) and self.Owner:GetActiveWeapon():GetClass() == 'weapon_ttt_traitor_remote' then
		--print( "Remote: Keydown" )
		self.NextRemoteActionChange = CurTime() + 0.1
		--if self.remoting == false then
			self:ForceAction( ent )
		--	self.remoting = true
		--send
	else
		--print( "Remote: KeyUp" )
		
		--if self.remoting == true then
			ResetAction( ent )
			ResetAction( self.Owner )
			--self.remoting = false
		--end
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()

end

function SWEP:UnRemoteEnt() --Remote ist nichtmehr auf Entity
	if IsValid( self:GetRemotedEnt() ) then
		ResetAction( self:GetRemotedEnt() )
		ResetAction( self.Owner )
		self:GetRemotedEnt():SetIsRemoted( false ) 
		self:SetRemotedEnt( nil )
	end
end

function SWEP:RemoteEnt( trEntity ) --Remote ist auf Entity
	self:SetRemotedEnt( trEntity )
	trEntity:SetIsRemoted( true ) 
end

function SWEP:GetTarget()	
	local trEntity = self.Owner:GetEyeTraceNoCursor().Entity
	if self.Owner:GetEyeTraceNoCursor().HitNonWorld then
		if IsValid(trEntity) and trEntity:IsPlayer() and trEntity:Alive() then
			if trEntity:GetIsRemoted() then 					
			--print( "Remote: GetTarget " .. trEntity:Nick() )
			--print( "Remote: GetTarget " .. tostring( trEntity:GetIsRemoted() ))
			end
			if not trEntity:GetIsRemoted() then
				if self:GetRemotedEnt() ~= trEntity then --neues ziel
				--altes Ziel
					--print( "Remote: GetTarget " .. trEntity:Nick() )
					--print( "Remote: GetTarget " .. tostring( trEntity:GetIsRemoted() ))
					if IsValid ( self:GetRemotedEnt() ) and self:GetRemotedEnt():GetIsRemoted() then
						self:UnRemoteEnt()
					end
				--neues ziel
					self:RemoteEnt( trEntity )
				end
			end
		end
	end
	
	UpdateRemoteHud( self )
end

function SWEP:Reload()
	self:GetTarget()
end

function SWEP:Deploy()
	UpdateRemoteHud( self )
	return true
end

function SWEP:Precache()
	util.PrecacheSound(self.Primary.SoundSuccess)
	util.PrecacheSound(self.Primary.SoundFail)
	util.PrecacheSound(self.Secondary.Sound)
end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:Initialize()	
	if self.CurrentAction == nil then
		self.CurrentActionCounter = 1
	end

	self.CurrentAction = Actions[self.CurrentActionCounter]
	
	if CLIENT then
		self:AddHUDHelp("PrimaryAttack: Use remote", "SecondaryAttack: Change remote action", "Reload: Change Target", false)
	end
	shuffledKeyTable = table.Shuffle( randomKeyTable )
end
	
function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	if IsValid( self:GetRemotedEnt() ) then
		self:GetRemotedEnt():SetIsRemoted( false )
	end
end

function SWEP:OnDrop()
	self:UnRemoteEnt()
end

hook.Add("TTTEndRound", "TTTRemoteEndRound", function()
	for _,v in pairs(player.GetAll()) do
		v:SetIsRemoted( false )
		ResetAction( v )
	end
end)

hook.Add("TTTPrepareRound", "TTTRemotePrepRound", function()
	for _,v in pairs(player.GetAll()) do
		v:SetIsRemoted( false )
		ResetAction( v )
	end
end)

hook.Add("PlayerDeath", "TTTRemotePlayerDeath", function( victim, inflictor, attacker )
	victim:SetIsRemoted( false )
	ResetAction( victim )
end)

if CLIENT then
	local currentAction = "none"
	local currentTarget = "Look at Target and Reload."

	net.Receive( "UpdateRemoteHUD", function()
		currentAction = net.ReadString()
		currentTarget = net.ReadString() --hier schon nickname
	end)
	
	function SWEP:DrawHUD()
		local w = ScrW()
		local h = ScrH()
		local x = 300
		local x_axis = w - x
		local y = 10
		local y_axis = y
		local space = 27
		
		draw.RoundedBox(2, x_axis, y_axis, x, space, Color(10,10,10,200))
		text = " LMT: Force Action - dont have to look at target"
		draw.SimpleText(text, "Trebuchet18", x_axis, y_axis + (space / 2), Color(0,255,0,255), 0, 1)
		
		y_axis = y_axis + space
		
		draw.RoundedBox(2, x_axis, y_axis, x, space, Color(10,10,10,200))
		text = " RMT: Next Action, USE: Prev. Action"
		draw.SimpleText(text, "Trebuchet18", x_axis, y_axis + (space / 2), Color(0,255,0,255), 0, 1)
		
		y_axis = y_axis + space
		
		draw.RoundedBox(2, x_axis, y_axis, x, space, Color(10,10,10,200))
		text = " Reload: Switch Target"
		draw.SimpleText(text, "Trebuchet18", x_axis, y_axis + (space / 2), Color(0,255,0,255), 0, 1)
		
		y_axis = y_axis + space
		
		draw.RoundedBox(2, x_axis, y_axis, x, space, Color(10,10,10,200))
		--text = "▼ Halten •• Klicken"
		text = "•• Klicken, ansonsten Halten "
		draw.SimpleText(text, "Trebuchet18", w, y_axis + (space / 2), Color(0,255,0,255), 2, 1)
		
		y_axis = y_axis + space
		
		for _,action in pairs(Actions) do
			
			draw.RoundedBox(2, x_axis, y_axis, x, space, Color(10,10,10,200))
			if currentAction == action then
				draw.SimpleText(action, "Trebuchet24", x_axis + (x / 2), y_axis + (space / 2), Color(255,0,0,255), 1, 1)
			else
				draw.SimpleText(action, "Trebuchet24", x_axis + (x / 2), y_axis + (space / 2), Color(255,255,255,255), 1, 1)
			end
			
			if action == "Jump" or action == "SecAttack" then
				draw.SimpleText("••", "Trebuchet18", x_axis + x, y_axis + (space / 2), Color(255,255,255,255), 2, 1)
			elseif action == "ViewPunch" then
				draw.SimpleText("2.5s", "Trebuchet24", x_axis + x, y_axis + (space / 2), Color(255,255,255,255), 2, 1)
			else
				draw.SimpleText("", "Trebuchet18", x_axis + x, y_axis + (space / 2), Color(255,255,255,255), 2, 1)
			end
			y_axis = y_axis + space
		end
		
		draw.RoundedBox(2, x_axis, y_axis, x, space, Color(10,10,10,200))

		text = currentTarget
		
		draw.SimpleText(text, "Trebuchet24", x_axis + (x / 2), y_axis + (space / 2), Color(0,255,0,255), 1, 1)
		
		
		
		local xmid = math.floor(ScrW() / 2.0)
		local ymid = math.floor(ScrH() / 2.0)
		
		if LocalPlayer():IsTraitor() then
			surface.SetDrawColor(255, 50, 50, 255)
		else
			surface.SetDrawColor(0, 255, 0, 255)
		end
		
		local r = 1
		if LocalPlayer():IsTraitor() then
			surface.DrawCircle( xmid, ymid, r, 255, 50, 50, 255 )
		else
			surface.DrawCircle( xmid, ymid, r, 0, 255, 0, 255 )
		end
	end
end