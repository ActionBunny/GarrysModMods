local function CamActive(target)
	DetectivePlayercamCamFrameOffen = true
	DetectivePlayercamCamFrame = vgui.Create( 'DFrame' )
	DetectivePlayercamCamFrame:SetSize( ScrW() /5, ScrH() /5 )
	DetectivePlayercamCamFrame:SetPos( 0, 0 )
	DetectivePlayercamCamFrame:SetTitle( "View of ".. target:GetName() )
	DetectivePlayercamCamFrame:SetDraggable( true )
	DetectivePlayercamCamFrame:SetSizable( true )
	function DetectivePlayercamCamFrame:Paint( w, h )
	x, y, w, h = DetectivePlayercamCamFrame:GetBounds()
					chat.AddText( target:EyeAngles().y )
		render.RenderView( {
			--origin = target:GetPos() + Vector( 0,0, ( 80 * target:GetModelScale()) ),

					--origin = Vector( target:GetPos().x + math.sin( target:EyeAngles().y ) * 10, target:GetPos().y + math.cos( target:EyeAngles().y ) * 10, target:GetPos().z + 80 * target:GetModelScale() ),
			
					--target:GetPos() + Vector( 0,0, ( 80 * target:GetModelScale()) ),
			--angles = Angle( target:EyeAngles().xaw, target:EyeAngles().yaw, 0 ),
			origin = target:EyePos() + ((target:GetEyeTrace().Normal)*10),
			angles = target:EyeAngles(),
			
			
			x = x,
			y = y,
			w = w,
			h = h,
		 } )

	end
	hook.Add("Think", "Think4Check", function()
		if DetectivePlayercamCamFrameOffen then
			DetectivePlayercamCamFrame.OnClose = Geschlossen
		end
		function Geschlossen()
			DetectivePlayercamCamFrameOffen = false
			net.Start( "CamSchliessenDetePlyCam" )
			net.WriteEntity(LocalPlayer())
			net.SendToServer()
		end
	end)
	
	
end
hook.Add("TTTPrepareRound", "PreparingForTestForAlive", function()
	if DetectivePlayercamCamFrameOffen then
		DetectivePlayercamCamFrame:Remove()
		DetectivePlayercamCamFrameOffen = false
	end
end)
net.Receive("CamFensterDetePlyCam", function()
	ply = net.ReadEntity()
	ply:DrawModel()
	CamActive(ply)
end)
hook.Add("Think", "ThinkForTestAlivePlayerAndTarget", function()
	if DetectivePlayercamCamFrameOffen then
		if (not LocalPlayer():Alive()) or (not ply:Alive()) then
			DetectivePlayercamCamFrame:Remove()
			DetectivePlayercamCamFrameOffen = false
			net.Start( "CamSchliessenDetePlyCam" )
			net.WriteEntity(LocalPlayer())
			net.SendToServer()
		end
	end
end)
