local simple_antilag_change_time = 0
local simple_antilag_change = 0 -- Сможет ли антилаг менять время (задержка для изменений)
local simple_antilag_last   = 1
local simple_antilag = {}

local simple_antilag_should_collide = 0

local simple_antilag_debug_messages = false

simple_antilag[0] = {
	['simulation'] = 0,
	['timescale'] = 1
}

simple_antilag[1] = {
	['simulation'] = 12,
	['timescale'] = 0.86
}

simple_antilag[2] = {
	['simulation'] = 17,
	['timescale'] = 0.65
}

simple_antilag[3] = {
	['simulation'] = 25,
	['timescale'] = 0.5
}

simple_antilag[4] = {
	['simulation'] = 33,
	['timescale'] = 0.3
}

simple_antilag[5] = {
	['simulation'] = 40,
	['timescale'] = 0.2
}

simple_antilag[6] = {
	['simulation'] = 60,
	['timescale'] = 0.1
}

simple_antilag[7] = {
	['simulation'] = 100,
	['timescale'] = 0.001
}

local simple_antilag_changes = 0
timer.Create("simple_antilag_checks",10,0,function()
	simple_antilag_changes = 0
end)

hook.Add("Think", "esrv_simpleantilag", function ()
	--if physenv.GetLastSimulationTime() * 1000 > 25 then
		--Entity(1):PrintMessage(4,physenv.GetLastSimulationTime()*1000)
	--end

	if simple_antilag_changes > 12 and not (simple_antilag_changes == -1) then

		if simple_antilag_debug_messages then
			local ply = player.GetAll()
			for i=1,#ply do
				ply[i]:PrintMessage(3,"Возможно, сервер лагает, все пропы заморожены")
			end
		end

		for _, ent in pairs(ents.GetAll()) do
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
				phys:Sleep()
			end
		end
		simple_antilag_changes = -1

	end



	local new_time = nil
	local var_simulation = 0
	local var_key = 0
	local lst = physenv.GetLastSimulationTime() * 1000

	--if not (lst > 7) then return end
	simple_antilag_should_collide = lst


	for key, tbl in pairs(simple_antilag) do
		if lst > tbl['simulation'] then
			new_time = tbl['timescale']
			var_simulation = tbl['simulation']
			var_key = key
			if not (tbl['simulation'] == 0) then
				simple_antilag_change_time = CurTime() + 4
			else
				simple_antilag_change_time = 0
			end
		end
	end

	--if true then return end

	if new_time == nil then return end

	local curtime = CurTime()
	if (var_key == 0 or (simple_antilag_change < curtime)) and not (simple_antilag_last == new_time) then
		simple_antilag_change = curtime + 1 - (var_key/50)
		simple_antilag_last = new_time
		game.SetTimeScale( new_time )
		simple_antilag_changes = simple_antilag_changes + 1


		if simple_antilag_debug_messages == true then

			local str = ""
			if lst >= 37 or (simple_antilag_change_time < CurTime() and not (simple_antilag_change_time == 0) )  then

				for _, ent in pairs(ents.GetAll()) do
					local phys = ent:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
						phys:Sleep()
					end
				end

				str = str .. "Так же заморожены пропы"

			end

			local ply = player.GetAll()
			for i=1,#ply do
				ply[i]:PrintMessage(3,"Изменение времени антилагом: "..tostring(new_time).."\n"..str)
			end

		end


	end

end)


hook.Add( "PlayerSpawnedProp", "esrv_simpleantilag", function(ply,mdl,ent)
	ent:SetCustomCollisionCheck(true)
end)


hook.Add( "ShouldCollide", "esrv_simpleantilag", function( ent1, ent2 )

	if simple_antilag_should_collide > 60 then 
		return false
	end

end )
game.SetTimeScale( 1 )
