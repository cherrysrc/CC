os.loadAPI("Stack.lua")
print("tunnel count? ")
local tunnelCount = tonumber(read())
print("tunnel length? ")
local tunnelLength = tonumber(read())

-- Performs a persistent dig in the given direction
-- Returns whether or not an ore was found
function dig(dig_fn, inspect_fn)
    local prev_has_block, prev_data = false, nil
    local has_block, data = inspect_fn()

    while has_block do
        dig_fn()

        prev_has_block, prev_data = has_block, data
        has_block, data = inspect_fn()
    end

    if prev_has_block then return is_ore(prev_data) end

    return false
end

function is_ore(data) return string.find(data["name"], "ore") ~= nil end

-- Returns a map of the surrounding blocks
local order = {"front", "right", "back", "left"}
function scan_position()
    local map = {["contains_ore"] = false}

    local has_block, data = turtle.inspectUp()
    if has_block then map["top"] = is_ore(data) end

    has_block, data = turtle.inspectDown()
    if has_block then map["down"] = is_ore(data) end

    for i = 1, 4, 1 do
        has_block, data = turtle.inspect()
        if has_block then map[order[i]] = is_ore(data) end
        turtle.turnRight()
    end

    map.contains_ore =
        map.front or map.back or map.left or map.right or map.top or map.down

    return map
end

function move_back_turn_left()
    turtle.back()
    turtle.turnLeft()
end

function move_back_turn_right()
    turtle.back()
    turtle.turnRight()
end

function move_back_turn_twice()
    turtle.back()
    turtle.turnRight()
    turtle.turnRight()
end

-- Digs one step of the tunnel
function dig_step()
    local scan = scan_position()
    local move_stack = Stack.new()

    while true do
        if scan.contains_ore then
            continue = false

            if scan.front then
                dig(turtle.dig, turtle.inspect)
                turtle.forward()

                scan.front = false
                scan.contains_ore = scan.front or scan.back or scan.left or
                                        scan.right or scan.top or scan.down

                Stack.push(move_stack,
                           {["action"] = turtle.back, ["scan"] = scan})
                continue = true
            end

            if not continue and scan.top then
                dig(turtle.digUp, turtle.inspectUp)
                turtle.up()

                scan.top = false
                scan.contains_ore = scan.front or scan.back or scan.left or
                                        scan.right or scan.top or scan.down

                Stack.push(move_stack,
                           {["action"] = turtle.down, ["scan"] = scan})
                continue = true
            end

            if not continue and scan.down then
                turtle.digDown()
                turtle.down()

                scan.down = false
                scan.contains_ore = scan.front or scan.back or scan.left or
                                        scan.right or scan.top or scan.down

                Stack.push(move_stack, {["action"] = turtle.up, ["scan"] = scan})
                continue = true
            end

            if not continue and scan.right then
                turtle.turnRight()
                dig(turtle.dig, turtle.inspect)
                turtle.forward()

                scan.right = false
                scan.contains_ore = scan.front or scan.back or scan.left or
                                        scan.right or scan.top or scan.down

                Stack.push(move_stack,
                           {["action"] = move_back_turn_left, ["scan"] = scan})
                continue = true
            end

            if not continue and scan.left then
                turtle.turnLeft()
                dig(turtle.dig, turtle.inspect)
                turtle.forward()

                scan.left = false
                scan.contains_ore = scan.front or scan.back or scan.left or
                                        scan.right or scan.top or scan.down

                Stack.push(move_stack,
                           {["action"] = move_back_turn_right, ["scan"] = scan})
                continue = true
            end

            if not continue and scan.back then
                turtle.turnLeft()
                turtle.turnLeft()
                dig(turtle.dig, turtle.inspect)
                turtle.forward()

                scan.back = false
                scan.contains_ore = scan.front or scan.back or scan.left or
                                        scan.right or scan.top or scan.down

                Stack.push(move_stack,
                           {["action"] = move_back_turn_twice, ["scan"] = scan})
                continue = true
            end

            scan = scan_position()
        else
            local previous = Stack.pop(move_stack)
            if previous == nil then break end

            previous.action()

            scan = previous.scan
        end
    end

    dig(turtle.dig, turtle.inspect)
    turtle.forward()
    dig(turtle.digDown, turtle.inspectDown)
end

-- Digs a side tunnel, perpendicular to the main tunnel
function dig_tunnel()
    for i = 1, tunnelLength, 1 do dig_step() end

    for i = 1, tunnelLength, 1 do turtle.back() end
end

-- Returns true if the last slot of the turtle contains atleast one item
function is_full() return turtle.getItemCount(16) > 0 end

-- Places a chest and dumps all items into it
function dump_items()
    turtle.placeDown()

    for i = 2, 16, 1 do
        turtle.select(i)
        turtle.dropDown()
    end

    turtle.select(1)
end

for i = 1, tunnelCount, 1 do
    dig_step()
    dig_step()
    dig_step()

    turtle.turnRight()
    dig_tunnel()
    turtle.turnLeft()
    turtle.turnLeft()
    dig_tunnel()
    turtle.turnRight()

    if is_full() then dump_items() end
end

for i = 1, tunnelCount * 3, 1 do turtle.back() end
