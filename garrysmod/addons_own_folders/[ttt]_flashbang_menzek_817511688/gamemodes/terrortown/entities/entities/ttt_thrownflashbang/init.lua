AddCSLuaFile("shared.lua")
include("shared.lua")

local function simplifyangle(angle)
	while(angle>=180) do
		angle = angle - 360;
	end
	while(angle <= -180) do
		angle = angle + 360;
	end
	return angle;
end

function ENT:Explode()
	self.Entity:EmitSound(Sound("weapons/flashbang/flashbang_explode"..math.random(1,2)..".wav"));
	--self:SetNWBool("Flashbang_exploding", true )
	for _,pl in pairs(player.GetAll()) do
	
	--wenn trace zwischen spieler und granate wand trifft, dann keine blendung -> nwfloat nicht gesetzt
		
		--trace zwischen granate und spieler
		local tracedata = {};
		tracedata.start = pl:GetShootPos()
		tracedata.endpos = self:GetPos()
		tracedata.filter = pl;
		local tr = util.TraceLine(tracedata);
		
		--Spieler eyetrace
		local plEyeTrace = pl:GetEyeTrace()
		
		if plEyeTrace.HitWorld and !tr.HitWorld then
			--distance
			local dist = pl:GetShootPos():Distance( self:GetPos() )
				--print( dist ) --1000 max
			--kleinster winkel
			local dot = tr.Normal:Dot( plEyeTrace.Normal) -- genau drauf 0grad genau weg 180 grad
			dot = math.deg( math.acos( dot ) )
				--print( "Degrees", math.deg( math.acos( dot ) ) )
			
			local alpha = 255
			alpha = alpha * math.Clamp( (( 1 - ( dot/180 ) ) * 2),0 , 1 )
			
			local endtime
			local distcoeff
			local maxDuration = 5
			local maxDist = 1000
			distcoeff = math.Clamp( ( dist / maxDist ), 0.1, 1 )
			
			if distcoeff == 0.1 then
				endtime = CurTime() + maxDuration
				
				pl:SetNWFloat("RCS_flashed_time_start", CurTime())
				pl:SetNWFloat("RCS_flashed_time", endtime)
				pl:SetNWInt("RCS_Alpha", alpha)
			elseif distcoeff == 1 then --nichts

			else
				endtime = CurTime() + maxDuration * ( 1 - distcoeff )
				alpha = alpha * (( 1 - distcoeff )*2)
				pl:SetNWFloat("RCS_flashed_time_start", CurTime())
				pl:SetNWFloat("RCS_flashed_time", endtime)
				pl:SetNWInt("RCS_Alpha", alpha)
			end
		end
	
	--endzeit abhängig von distanz und winkel
	--alpha abhängig von distanz und winkel
	--alpha
	--endzeit
	--[[	
		
		
		
		
		
		
		
		local ang = (self.Entity:GetPos() - pl:GetShootPos()):GetNormalized():Angle()
		
		
		local tracedata = {};
		tracedata.start = pl:GetShootPos();
		tracedata.endpos = self.Entity:GetPos();
		tracedata.filter = pl;
		local traceRes = pl:GetEyeTrace()
		local tr = util.TraceLine(tracedata);

		local pitch = simplifyangle(ang.p - pl:EyeAngles().p);
		local yaw = simplifyangle(ang.y - pl:EyeAngles().y);
		local dist = pl:GetShootPos():Distance( self.Entity:GetPos() )
		local endtime = FLASH_INTENSITY/dist;

		if traceRes.HitWorld and !tr.HitWorld then
			local endtime = FLASH_INTENSITY/dist;
			if (endtime > 6) then
				endtime = 6;
			elseif(endtime < 0) then
				endtime = 0;
			end
			simpendtime = math.floor(endtime);
			tenthendtime = math.floor((endtime-simpendtime)*10);
			if (  pitch > -45 && pitch < 45 && yaw > -45 && yaw < 45 ) || (pl:GetEyeTrace().Entity && pl:GetEyeTrace().Entity == self.Entity )then --in FOV
				--pl:PrintMessage(HUD_PRINTTALK, "In FOV");
			else
				--pl:PrintMessage(HUD_PRINTTALK, "Not in FOV");
				endtime = endtime/2;
			end
			if (pl:GetNetworkedFloat("RCS_flashed_time") > CurTime()) then --if you're already flashed
				pl:SetNetworkedFloat("RCS_flashed_time", endtime+pl:GetNetworkedFloat("RCS_flashed_time")+CurTime()-pl:GetNetworkedFloat("RCS_flashed_time_start")); --add more to it
			else --not flashed
				pl:SetNetworkedFloat("RCS_flashed_time", endtime+CurTime());
			end
			pl:SetNetworkedFloat("RCS_flashed_time_start", CurTime());
		end
		]]
		
	end
	self.Entity:Remove();
end

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	if self:GetOwner():KeyDown(IN_ATTACK2) == true then
		self.ExplodeOnCollision = true
	else
		timer.Simple(2,
		function()
			if self.Entity then self:Explode() end
		end )
	end
end


function ENT:Think()
end

function ENT:SetDetonateTimer(length)
   self:SetDetonateExact( CurTime() + length )
end

function ENT:SetDetonateExact()
end

function ENT:OnTakeDamage()
	self:Explode()
end

function ENT:SetThrower()
end

function ENT:Use()
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch()
end

function ENT:PhysicsCollide()
	if self.ExplodeOnCollision == true then
		self:Explode()
	end
end