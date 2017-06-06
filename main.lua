local root = {400, 300}
local radius = 20

local arm_lengths = {
	150,
	120,
}

local arm_angles = {
	0, 
	90,
}

local function radians (degrees)
	return degrees * math.pi / 180.0
end

local function forward_kinematics (root, arm_lengths, arm_angles)
	local t = {
		{root [1], root [2]},
	}
	
	local pos = {root [1], root [2]}
	
	for i = 1, #arm_lengths do
		local length = arm_lengths [i]
		local angle = arm_angles [i]
		
		pos [1] = pos [1] + length * math.cos (radians (angle))
		pos [2] = pos [2] + length * math.sin (radians (angle))
		
		table.insert (t, {pos [1], pos [2]})
	end
	
	return t
end

function love.load ()
	-- Yep
end

function love.update (dt)
	
end

function love.draw ()
	-- h0000
	
	local joints = forward_kinematics (root, arm_lengths, arm_angles)
	
	for i, joint in ipairs (joints) do
		local t = (i - 1) / (#joints - 1)
		love.graphics.circle ("line", joint [1], joint [2], radius * (1 - t) + radius * 0.5 * t)
	end
end
