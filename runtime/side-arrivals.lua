-- Optional higher-difficulty asteroid approach lanes.
-- Work in platform-local hub coordinates; do not scan every tick.
local SideArrivals = {}

local WRECK_NAME = "used-rocket-asteroid"
local FOUNDATION = "space-platform-foundation"
local HALF_WRECK = 10
local SIDE_SPEED = 0.045

-- Scan only the part of the hull near the intended side approach line.
-- Narrow vertical bounds keep the cost bounded even for very long ships.
-- If a ship extends beyond this scan, do not risk a hull-overlap spawn:
-- the caller can fall back to the established front approach instead.
local SCAN_HALF_WIDTH = 512
local SCAN_TOP = 64
local SCAN_BOTTOM = 24
local EDGE_LIMIT = 500

function SideArrivals.try_spawn(platform, distance)
    local hub, surface = platform.hub, platform.surface
    if not hub or not hub.valid or not surface then return false end

    local center = hub.position
    local foundations = surface.find_tiles_filtered({
        name = FOUNDATION,
        area = {
            {center.x - SCAN_HALF_WIDTH, center.y - SCAN_TOP},
            {center.x + SCAN_HALF_WIDTH, center.y + SCAN_BOTTOM},
        },
    })
    if #foundations == 0 then return false end

    local min_x, max_x = center.x, center.x
    for _, tile in pairs(foundations) do
        min_x = math.min(min_x, tile.position.x)
        max_x = math.max(max_x, tile.position.x)
    end
    if min_x <= center.x - EDGE_LIMIT or max_x >= center.x + EDGE_LIMIT then
        return false -- Too broad to confidently assess the sides of this hull.
    end

    -- Two real approach directions, chosen fairly on each recovery. Try the
    -- other side before abandoning an eligible launch to front-only fallback.
    local first_side = math.random(2) == 1 and "left" or "right"
    local second_side = first_side == "left" and "right" or "left"
    local lead = math.max(32, distance)

    for _, side in ipairs({first_side, second_side}) do
        local edge = side == "left" and min_x or max_x
        local sign = side == "left" and -1 or 1
        for _ = 1, 6 do
            local position = {
                x = edge + sign * (lead + math.random(0, 10)),
                y = center.y - math.random(8, 20),
            }
            -- The actual 18x18 wreck must not materialize on the platform.
            local overlap = surface.find_tiles_filtered({
                name = FOUNDATION,
                area = {
                    {position.x - HALF_WRECK, position.y - HALF_WRECK},
                    {position.x + HALF_WRECK, position.y + HALF_WRECK},
                },
                limit = 1,
            })
            if #overlap == 0 and surface.can_place_entity({
                name = WRECK_NAME, position = position,
            }) then
                -- Aim for the hub area, not directly east/west into empty
                -- space: short and wide platforms must still see the wreck.
                local dx = center.x - position.x
                local dy = center.y - 2 - position.y
                local magnitude = math.sqrt(dx * dx + dy * dy)
                if magnitude > 0 then
                    local wreck = surface.create_entity({
                        name = WRECK_NAME,
                        position = position,
                        velocity = {
                            x = SIDE_SPEED * dx / magnitude,
                            y = SIDE_SPEED * dy / magnitude,
                        },
                    })
                    if wreck then return true, side end
                end
            end
        end
    end
    return false
end

return SideArrivals
