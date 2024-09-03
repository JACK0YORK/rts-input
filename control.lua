script.on_event(defines.events.on_tick, function(event) 
    if not global.path_players then
        return
    end
    for p, _ in pairs(global.path_players) do 
        if global.path_players[p] and global.path[p] then
            local player = game.get_player(p)
            local pathdelta = dist(player.position, global.path[p][1].position)
            if global.pathdelta[p] and (pathdelta-global.pathdelta[p])>=0 then
                do_path(p, global.path[p][#global.path[p]].position)
            else
                global.pathdelta[p] = pathdelta
                if pathdelta < 0.25 then
                    nextWaypoint(p, player)
                end
                game.print(dump(player.walking_state))
                player.walking_state = {walking = true, direction = global.direction[p]}
            end
        end
    end
end)

script.on_event(defines.events.on_script_path_request_finished, function(event)
    for p, _ in pairs(global.path_players) do 
        if global.path_players[p] then
            if event.id == global.pathids[p] then
                global.path[p] = event.path
            end
        end
    end
end)

function do_path(player_index, cursor_position)
    local player = game.get_player(player_index)
    if player.character then
        local move_to_cursor_cutoff = player.mod_settings["move_to_cursor_cutoff"].value
        if not global.path_players then
            global.pathids = {}
            global.path = {}
            global.path_players = {}
            global.direction = {}
            global.pathdelta = {}
        end
        global.direction[player_index] = angle(player.position, cursor_position)
        global.path_players[player_index] = true
        if dist(player.position, cursor_position) < move_to_cursor_cutoff then
            global.path[player_index] = {{position=cursor_position}}
        else
        global.pathids[player_index] = player.surface.request_path{
            bounding_box = player.character.prototype.collision_box, 
            collision_mask=player.character.prototype.collision_mask, 
            start=player.position, 
            goal=cursor_position, 
            force=player.force, 
            can_open_gates=true,
            entity_to_ignore=player.character,
            path_resolution_modifier=0}
        end
    end
end

script.on_event("move-to-cursor", function(event)
    local player = game.get_player(event.player_index)
    rendering.draw_animation{animation="horizontal_animation", 
        target=event.cursor_position,
        filled = false,
        time_to_live=30,
        x_scale=0.5,
        y_scale=0.4,
        tint = {r = 0, g = 0.5, b = 0, a = 0.5},
        surface = player.surface}
    do_path(event.player_index, event.cursor_position)
end)

function escape(event)
    local player = game.get_player(event.player_index)
    global.pathids[event.player_index] = false
    global.path[event.player_index] = false
    global.path_players[event.player_index] = false
end

script.on_event("escape-w", escape)
script.on_event("escape-a", escape)
script.on_event("escape-s", escape)
script.on_event("escape-d", escape)

function nextWaypoint(idx, player)
    table.remove(global.path[idx], 1)
    local wp = global.path[idx][1]
    global.pathdelta[idx] = false
    if next(global.path[idx]) == nil then
        global.pathids[idx] = false
        global.path[idx] = false
        global.path_players[idx] = false
        return false
    else
        global.direction[idx] = angle(player.position, wp.position)
        return true
    end
end

function angle(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local ratio = -dx / (math.abs(dx)+math.abs(dy))
    if ratio > 0.75 then
        return defines.direction.east
    elseif ratio > 0.25 then
        if a.y < b.y then
            return defines.direction.southeast
        else
            return defines.direction.northeast
        end
    elseif ratio > -0.25 then
        if a.y < b.y then
            return defines.direction.south
        else
            return defines.direction.north
        end
    elseif ratio > -0.75 then
        if a.y < b.y then
            return defines.direction.southwest
        else
            return defines.direction.northwest
        end
    else
        return defines.direction.west
    end
end

function dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end