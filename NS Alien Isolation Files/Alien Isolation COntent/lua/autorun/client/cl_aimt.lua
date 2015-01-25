if CLIENT then
	local radar = nil
	local radar_p = nil
	local radar_d = nil
	local lastuse = 0
	local ison = false
	local nextbleep = 0
	local ambient_sound = nil
	local MT_MAX_DIST = 1300

	local function IsOffLane( x, y )
		local prec = y / ( ScrH() / 1.5 )
		local size = ScrW() / 1.5
		local xb = size * prec / 1.5
		local xba = ScrW() - xb

		if xb > x or xba < x then return false end
		return true
	end
	
	local function GetOffLaneDir( x, y )
		local prec = y / ( ScrH() / 1.5 )
		local size = ScrW() / 1.5
		local xb = size * prec
		local xba = ScrW() - xb
		
		if xba < x and y < ScrH() - 220 then 
			return 1 
		elseif xba < x and xb > x then
			return 2
		else
			return 0
		end
	end
	
	local ofsidedir = 0
	local rt = GetRenderTarget( '__rtAIScannerScreen', 512, 512, true )
	local target = NULL
	local view = render.GetRenderTarget()
	surface.CreateFont( 'AI_MotionTrackerLarge', {
		font		= 'Trebuchet18',
		size		= 60,
		weight		= 1000,
		additive 	= false,
		antialias 	= true,
		bold		= true,
	} )
	
	local params = { [ '$basetexture' ] = 'sprites/glow02' }
	params[ '$vertexalpha' ] = 1
	params[ '$vertexcolor' ] = 1
	params[ '$additive' ] = 1
		
	local smat = CreateMaterial( 'mt_point_glow', "UnlitGeneric", params )
	
	local point = Material( 'icon16/stop.png' )
	local point_glow = smat
	local side = Material( 'hud/aiscanner_side.png' )
	
	local nextsignchanges = 0
	local text = ''
	local entscount = 0
	local blackscreen = true
	local greenscreen = false
	local offsideents = {}
	local enabled = false
	local entsfound = 0
	local entsfnd = {}
	hook.Add( 'Think', 'ThinkingOnMotionTrakerEvents', function()
		if lastuse > CurTime() and !ison then
			ison = true
			surface.PlaySound( 'weapons/motiontracker_turnon0' .. math.random( 1, 3 ) .. '.wav' )
			ambient_sound = CreateSound( LocalPlayer(), 'weapons/motiontracker_ambient_noise.wav' )
			timer.Simple( 0.6, function() surface.PlaySound( 'weapons/motiontracker_blep.wav' ) if ambient_sound then ambient_sound:Play() end blackscreen = false greenscreen = true enabled = true end )
			timer.Simple( 0.7, function() greenscreen = false end )
		elseif lastuse < CurTime() and ison then
			ison = false
			surface.PlaySound( 'weapons/motiontracker_turnoff0' .. math.random( 1, 2 ) .. '.wav' )
			if ambient_sound then ambient_sound:Stop() ambient_sound = nil end
			blackscreen = true
			greenscreen = false
			enabled = false
		end
		
		//if LocalPlayer():Team() != 1 then return end
		
		for _, e in pairs( ents.FindInSphere( LocalPlayer():GetPos(), MT_MAX_DIST ) ) do
			if IsValid( e ) and e:IsNPC() or e:IsPlayer() or e:GetClass() == 'alien_android_snpc' or e:GetClass() == 'alien_xeno_snpc' then
				if e != LocalPlayer() and not ( e:GetClass() == 'npc_turret_floor' or e:GetClass() == 'npc_turret_ceiling' or e:GetClass() == 'npc_turret_ground' ) then
					if !table.HasValue( entsfnd, e ) then table.insert( entsfnd, e ) end
				end
			end
		end

		for i, v in pairs( entsfnd ) do
			if !IsValid( v ) or v:GetPos():Distance( LocalPlayer():GetPos() ) > MT_MAX_DIST or v:GetVelocity():Length() <= 10 then entsfnd[ i ] = nil end
		end
		
		if !enabled then return end
		
		if lastuse > CurTime() then
			if entscount > 0 then
				if nextbleep < CurTime() then
					nextbleep = CurTime() + ( 0.6 - ( 0.4 * ( math.Clamp( entscount / 6, 0, 1 ) ) ) )
					surface.PlaySound( 'weapons/motiontracker_blep02.wav' )
				end
			end
		end
		
		if entscount != #entsfnd then
			if entscount < #entsfnd then
				surface.PlaySound( 'weapons/motiontracker_blep.wav' )
			end
			entscount = #entsfnd
		end
	end )
	
	function MOTIONTRACKER_RenderScreen()
		lastuse = CurTime() + 0.1
		render.SetRenderTarget( rt )
			render.Clear( 0, 0, 0, 255 )
			render.ClearDepth()
			render.ClearStencil()
			
			local bg_clr = Color( 0, 50 * math.Clamp( math.sin( CurTime() * math.random( 1, 2 ) ), 0.9, 1 ), 0, 255 )
		
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )
			if blackscreen then surface.SetDrawColor( 0, 0, 0, 255 ) else surface.SetDrawColor( bg_clr ) end
			if greenscreen then surface.SetDrawColor( 0, 255, 0, 255 ) end
			surface.DrawRect( 45, 45, ScrW() - 90, ScrH() - 90 )
			
			surface.SetDrawColor( 200, 100, 0, 255 )
			for i = 1, ScrW() / ( 15 + 65 ) do
				surface.DrawRect( 5, 65 * i - 11, 35, 15 )
				surface.DrawRect( ScrW() - 40, 65 * i - 11, 35, 15 )
			end
			
			surface.SetFont( 'AI_MotionTrackerLarge' )
			surface.SetTextPos( ScrW() / 4, ScrH() - 55 )
			surface.SetTextColor( 200, 100, 0, 255 )
			surface.DrawText( '7-772' )
			surface.SetTextPos( ScrW() / 1.8, ScrH() - 55 )
			surface.DrawText( '47-CLN' )
			surface.SetTextPos( ScrW() / 4, -ScrH() / 90 )
			surface.DrawText( '-ON' )
			surface.SetDrawColor( 0, 200, 0, 255 * math.Clamp( math.sin( CurTime() * math.random( 2, 3 ) ), 0.2, 1 ) )
			
			if blackscreen or greenscreen then return end

			local lovery = ScrH() / 1.4

			local x, y = ScrW() / 2.5, ScrH() / 1.5
			local ply = LocalPlayer()
			for _, e in pairs( ents.FindInSphere( LocalPlayer():GetPos(), MT_MAX_DIST ) ) do
				if IsValid( e ) and e:IsNPC() or e:IsPlayer() or e:GetClass() == 'alien_android_snpc' or e:GetClass() == 'alien_xeno_snpc' then
					if e != LocalPlayer() and not ( e:GetClass() == 'npc_turret_floor' or e:GetClass() == 'npc_turret_ceiling' or e:GetClass() == 'npc_turret_ground' ) and
					e:GetPos():Distance( LocalPlayer():GetPos() ) < MT_MAX_DIST then
					local pos = ( e:GetPos() - ply:GetPos() ) / 2.1
						pos:Rotate( Angle( 0, -ply:EyeAngles().y + 90, 0 ) )
						
					pos.x = math.Clamp( pos.x * 1.4 + x + 137, 75, ScrW() - 150 )
					pos.y = math.Clamp( -pos.y + y + 81, 75, ScrH() )
					
					if ( IsOffLane( pos.x, pos.y ) ) then
						local vprec = e:GetVelocity():Length() / 50
						vprec = math.Clamp( vprec, 0, 1 )
						surface.SetDrawColor( 0, 200, 0, 255 * vprec )
						local w, h = ScrW() / 35 + 15 * vprec, ScrH() / 35 + 15 * vprec
						surface.SetMaterial( point )
						surface.DrawTexturedRect( pos.x - w / 2, pos.y - h / 2, w, h )
						surface.SetMaterial( point_glow )
						surface.DrawTexturedRect( pos.x - w * 3, pos.y - h * 3, w * 6, h * 6 )
						//surface.DrawRect( pos.x - w / 2, pos.y - h / 2, w, h )
						ofsidedir = 3
						if table.HasValue( offsideents, e ) then table.RemoveByValue( offsideents, e ) end
					else
						if !table.HasValue( offsideents, e ) then table.insert( offsideents, e ) end
						ofsidedir = GetOffLaneDir( pos.x, pos.y )
					end
					end
				end
			end
			
			local blocker1 = {
				{ x = ScrW() / 13.5, y = ScrH() / 4 }, 
				{ x = ScrW() / 2, y = lovery }, 
				{ x = 65, y = ScrH() - 65 }
			}
			
			local blocker2 = {
				{ x = ScrW() / 2, y = lovery }, 
				{ x = ScrW() - ScrW() / 13.5, y = ScrH() / 4 }, 
				{ x = ScrW() - 65, y = ScrH() - 65 }
			}
			
			local blocker3 = {
				{ x = 65, y = ScrH() - 65 },
				{ x = ScrW() / 2, y = lovery }, 
				{ x = ScrW() - 65, y = ScrH() - 65 }
			}
			
			surface.SetDrawColor( bg_clr )
			draw.NoTexture()
			surface.DrawPoly( blocker1 )
			surface.DrawPoly( blocker2 )
			surface.DrawPoly( blocker3 )
			
			surface.SetTextPos( ScrW() / 1.13, ScrH() / 1.4 )
			surface.SetTextColor( 0, 100, 0, 255 )
			surface.DrawText( 'ATT' )
			surface.SetTextPos( ScrW() / 1.13, ScrH() / 1.31 )
			surface.DrawText( 'SUS' )
			surface.SetTextPos( ScrW() / 1.13, ScrH() / 1.23 )
			surface.DrawText( 'DEC' )
			
			local nums = { 0.31, 0.42, 0.62, 0.67, 0.81, 0.91, 0.71, 0.37, 0.53 }

			if nextsignchanges < CurTime() then
				nextsignchanges = CurTime() + math.random( 0.3, 0.7 )
				text = nums[math.random( 1, #nums )]
			end
			
			surface.SetDrawColor( 0, 200, 0, 100 )
			surface.SetTextPos( ScrW() / 18.13, ScrH() / 1.23 )
			surface.SetTextColor( 0, 0, 0, 255 )
			surface.DrawRect( ScrW() / 31, ScrH() / 1.22, ScrW() / 8, 53 )
			surface.DrawText( text )
			
			for i = 1, 3 do
				surface.DrawLine( ScrW() / 13.5 - i * 2, ScrH() / 4, ScrW() / 2 - i * 2, lovery )
				surface.DrawLine( ScrW() - ScrW() / 13.5 + i * 2, ScrH() / 4, ScrW() / 2 + i * 2, lovery )
			end
			
			if true then
				local x0, y0 = 0, 0
				local px, py = ScrW() / 2, ScrH() / 2.5
				for i = 116, 245, math.pi do
					local sizex, sizey = ScrW() / 2.1, ScrH() / 3
					local x1 = math.sin( math.rad( i ) ) * sizex
					local y1 = math.cos( math.rad( i ) ) * sizey
					
					surface.SetDrawColor( 0, 200, 0, 100 * math.Clamp( math.sin( CurTime() * math.random( 1, 2 ) ), 0.5, 1 ) )
					if i > 116 then
						surface.DrawLine( x0 + px, y0 + py, x1 + px, y1 + py )
						surface.DrawLine( x0 + px + 2, y0 + py - 2, x1 + px + 2, y1 + py - 2 )
						surface.DrawLine( x0 + px + 4, y0 + py - 4, x1 + px + 4, y1 + py - 4 )
					end
					
					surface.SetDrawColor( 0, 150, 0, 100 * math.Clamp( math.sin( CurTime() * math.random( 1, 2 ) ), 0.2, 1 ) )
					if i > 153 and i < 155 then
						surface.DrawLine( x1 + px, y1 + py, ScrW() / 2, lovery )
					elseif i > 204 and i < 208 then
						surface.DrawLine( x1 + px, y1 + py, ScrW() / 2, lovery )
					end

					x0 = x1
					y0 = y1
				end
			end
			
			surface.DrawLine( ScrW() / 2, 75, ScrW() / 2, lovery )
			
			for i, v in pairs( offsideents ) do
				if IsValid( v ) and v:GetPos():Distance( LocalPlayer():GetPos() ) > MT_MAX_DIST then
					offsideents[ i ] = nil
				end
				if !IsValid( v ) then offsideents[ i ] = nil end
			end

			local radiusx, radiusy = 240, 180
			local centerx, centery = ScrW() / 2, ScrH() / 1.5
			local esize = 15
			for i, v in pairs( offsideents ) do
				local pos = ( v:GetPos() - ply:GetPos() ) / 2.6 pos:Rotate( Angle( 0, -ply:EyeAngles().y + 90, 0 ) )
				pos.x = math.Clamp( pos.x * 1.4 + x + 137, 75, ScrW() - 150 )
				pos.y = math.Clamp( -pos.y + y + 81, 75, ScrH() )
				local ofsidedir = GetOffLaneDir( pos.x, pos.y )
				if ofsidedir == 2 then surface.SetDrawColor( 0, 150, 0, 50 ) else surface.SetDrawColor( 0, 150, 0, 0 ) end
				for i = math.pi * -0.2, math.pi * 0.2, 1 / math.max( radiusx, radiusy ) do
					surface.DrawRect( centerx + math.sin( i ) * radiusx, centery + math.cos( i ) * radiusy, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.05, centery + math.cos( i ) * radiusy * 1.05, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.1, centery + math.cos( i ) * radiusy * 1.1, esize, esize )
				end
				if ofsidedir == 0 then surface.SetDrawColor( 0, 150, 0, 50 ) else surface.SetDrawColor( 0, 150, 0, 0 ) end
				for i = math.pi * -0.6, math.pi * -0.3, 1 / math.max( radiusx, radiusy ) do
					surface.DrawRect( centerx + math.sin( i ) * radiusx, centery + math.cos( i ) * radiusy, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.05, centery + math.cos( i ) * radiusy * 1.05, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.1, centery + math.cos( i ) * radiusy * 1.1, esize, esize )
				end
				if ofsidedir == 1 then surface.SetDrawColor( 0, 150, 0, 50 ) else surface.SetDrawColor( 0, 150, 0, 0 ) end
				for i = math.pi * 0.3, math.pi * 0.6, 1 / math.max( radiusx, radiusy ) do
					surface.DrawRect( centerx + math.sin( i ) * radiusx, centery + math.cos( i ) * radiusy, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.05, centery + math.cos( i ) * radiusy * 1.05, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.1, centery + math.cos( i ) * radiusy * 1.1, esize, esize )
				end
			end
			
			do
				surface.SetDrawColor( 0, 150, 0, 5 )
				for i = math.pi * -0.2, math.pi * 0.2, 1 / math.max( radiusx, radiusy ) do
					surface.DrawRect( centerx + math.sin( i ) * radiusx, centery + math.cos( i ) * radiusy, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.05, centery + math.cos( i ) * radiusy * 1.05, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.1, centery + math.cos( i ) * radiusy * 1.1, esize, esize )
				end
				surface.SetDrawColor( 0, 150, 0, 5 )
				for i = math.pi * -0.6, math.pi * -0.3, 1 / math.max( radiusx, radiusy ) do
					surface.DrawRect( centerx + math.sin( i ) * radiusx, centery + math.cos( i ) * radiusy, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.05, centery + math.cos( i ) * radiusy * 1.05, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.1, centery + math.cos( i ) * radiusy * 1.1, esize, esize )
				end
				surface.SetDrawColor( 0, 150, 0, 5 )
				for i = math.pi * 0.3, math.pi * 0.6, 1 / math.max( radiusx, radiusy ) do
					surface.DrawRect( centerx + math.sin( i ) * radiusx, centery + math.cos( i ) * radiusy, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.05, centery + math.cos( i ) * radiusy * 1.05, esize, esize )
					surface.DrawRect( centerx + math.sin( i ) * radiusx * 1.1, centery + math.cos( i ) * radiusy * 1.1, esize, esize )
				end
			end
			
			render.UpdateScreenEffectTexture()
		render.SetRenderTarget( view )
	end
	//hook.Add( 'HUDPaint', 'RenderAI_Screen', Render )
end