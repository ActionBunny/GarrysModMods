local DIETIMER = 1.5; --time in seconds, for the grenade to transition from full white to clear
local EFFECT_DELAY = 0.5; --time, in seconds when the effects still are going on, even when the whiteness of the flash is gone (set to -1 for no effects at all =]).
local pos, endflash, endflash2;

if (CLIENT) then
	function ENT:Initialize()
		self:CallOnRemove("CreateLightning", CreateLightning, n)
	end
	
	function ENT:Draw()
		self.Entity:DrawModel()
	end

	function ENT:IsTranslucent()
		return true
	end
	
	function SimulateFlash_REALCS_NOT_ANYTHINGELSE() 
	
		--if LocalPlayer():IsTraitor() and LocalPlayer():GetNetworkedFloat("RCS_flashed_time") > CurTime() then
		local pl = LocalPlayer();
		--Distanzabhängiges und richtungsabhängiges verhalten gewünscht
		if pl:GetNWFloat("RCS_flashed_time") > CurTime() then
			
			
			local alpha = pl:GetNWInt("RCS_Alpha" )
			
			surface.SetDrawColor(255,255,255,math.Round(alpha));
			surface.DrawRect(0,0,surface.ScreenWidth(),surface.ScreenHeight());
			
		end
	end
	hook.Add("HUDPaint", "SimulateFlash_REALCS_NOT_ANYTHINGELSE", SimulateFlash_REALCS_NOT_ANYTHINGELSE);
	
	--motion blur and other junk
	local function SimulateBlur_REALCS_NOT_ANYTHINGELSE()
		local pl = LocalPlayer();
		local e = pl:GetNWFloat("RCS_flashed_time")
		local s = pl:GetNWFloat("RCS_flashed_time_start") 

		--if e < CurTime() then return end
		
		local eMotionBlur = (e - s)*1.5 + e --h#lt 1.5 mal solange wie Flash
		if eMotionBlur > CurTime() then
			local alpha = pl:GetNWInt( "RCS_Alpha" )
			local cMB = alpha / 255
			local fMB = eMotionBlur - CurTime()
			fMB = math.Clamp(fMB,0.1, 1 )
			--abhngigkeit ähnlihc alpha + fading out
			DrawMotionBlur( 0.1 * cMB * fMB, 0.7 * cMB * fMB, 0.1 )
		end
	end
	hook.Add( "RenderScreenspaceEffects", "SimulateBlur_REALCS_NOT_ANYTHINGELSE", SimulateBlur_REALCS_NOT_ANYTHINGELSE )
	
end

function CreateLightning(ent, n)
	pos = ent:GetPos()
		local beeplight = DynamicLight( ent:EntIndex() )
		if ( beeplight ) then
			beeplight.Pos = pos
			beeplight.r = 255
			beeplight.g = 255
			beeplight.b = 255
			beeplight.Brightness = 8
			beeplight.Size = 600
			beeplight.Decay = 2000
			beeplight.DieTime = CurTime() + 0.5
		end
end
	
ENT.Type = "anim"