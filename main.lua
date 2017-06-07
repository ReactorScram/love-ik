local root = {400, 300}
local radius = 20

local arm_lengths = {
	300,
	200,
	120,
}

local arm_angles = {
	0,
	45,
	90,
}

local target-- = {0, 0}

local function get_radius (i)
	local t = (i - 1) / (#arm_angles)
	return radius * (1 - t) + radius * 0.5 * t
end

local radii = {}
for i = 1, #arm_angles + 1 do
	radii [i] = get_radius (i)
end

local function radians (degrees)
	return degrees * math.pi / 180.0
end

local function forward_kinematics (root, arm_lengths, arm_angles)
	local t = {
		{root [1], root [2]},
	}
	
	local derivatives = {
		
	}
	
	local pos = {root [1], root [2]}
	
	for i = 1, #arm_lengths do
		local length = arm_lengths [i]
		local angle = arm_angles [i]
		
		local rads = radians (angle)
		
		pos [1] = pos [1] + length * math.cos (rads)
		pos [2] = pos [2] + length * math.sin (rads)
		
		table.insert (t, {pos [1], pos [2]})
	end
	
	for i = 1, #arm_lengths do
		local center = t [i]
		local end_affector = t [#t]
		
		local derivative = {
			-(end_affector [2] - center [2]),
			end_affector [1] - center [1],
		}
		
		table.insert (derivatives, derivative)
	end
	
	return t, derivatives
end

function love.load ()
	-- Yep
end

local function dot (a, b)
	local sum = 0
	
	for i = 1, #a do
		sum = sum + a [i] * b [i]
	end
	
	return sum
end

local function length (v)
	return math.sqrt (dot (v, v))
end

local function solve (ratio)
	if not target then
		return
	end
	
	local positions, derivatives = forward_kinematics (root, arm_lengths, arm_angles)
	
	local end_affector = positions [#positions]
	
	local diff = {
		target [1] - end_affector [1],
		target [2] - end_affector [2],
	}
	
	local diff_dist = length (diff)
	
	local epsilon = 0.5
	if diff_dist < epsilon then
		return
	end
	
	local diff_unit = {
		diff [1] / diff_dist,
		diff [2] / diff_dist,
	}
	
	local weights = {}
	
	for i = 1, #derivatives do
		weights [i] = dot (derivatives [i], diff_unit)
	end
	
	local weight_length = length (weights)
	
	local max_speed = 5
	local speed = math.min (max_speed, diff_dist * 0.25)
	
	local weight_scale = speed
	if weight_length > 1 then
		weight_scale = speed / weight_length
	end
	
	for i = 1, #arm_angles do
		local theta = arm_angles [i]
		theta = theta + weight_scale * ratio * weights [i]
		if theta > 180 then
			theta = theta - 360
		elseif theta < -180 then
			theta = theta + 360
		end
		arm_angles [i] = theta
	end
	
	--print (arm_angles [1], arm_angles [2])
end

function love.update (dt)
	solve (1.0)
	solve (0.5)
	solve (0.25)
end

function love.draw ()
	-- h0000
	
	local joints = forward_kinematics (root, arm_lengths, arm_angles)
	
	love.graphics.setColor (255, 255, 255)
	
	for i, joint in ipairs (joints) do
		love.graphics.circle ("line", joint [1], joint [2], radii [i])
	end
	
	for i = 1, #joints - 1 do
		local a, b = joints [i], joints [i + 1]
		local direction = {
			(b [1] - a [1]) / arm_lengths [i], 
			(b [2] - a [2]) / arm_lengths [i],
		}
		
		local radius_a = radii [i]
		local radius_b = radii [i + 1]
		
		love.graphics.line (
			a [1] + direction [1] * radius_a, 
			a [2] + direction [2] * radius_a, 
			b [1] - direction [1] * radius_b, 
			b [2] - direction [2] * radius_b)
	end
	
	love.graphics.setColor (0, 255, 0)
	if target then
		love.graphics.circle ("line", target [1], target [2], radius * 0.25)
	end
	
	love.graphics.setColor (0, 212, 0)
	
	love.graphics.print ("Click / drag the mouse", 20, 20)
end

function love.mousepressed (x, y, button)
	if button == 1 then
		target = {x, y}
	end
end

function love.mousemoved (x, y, button)
	if love.mouse.isDown (1) then
		target = {x, y}
	end
end
