local texture = dxCreateTexture("lightcycle_trail.png")
local points = {}
local rendering = true
local inVehicle = false
local debug = true

function clientRender()
    if rendering then
        for vehicle in pairs(points) do
            for i=1,#points[vehicle]-1,1 do
                local point1 = points[vehicle][i]
                local point2 = points[vehicle][i+1]
                local x, y, z = calculateMidpoint3D(point1[1], point1[2], point1[3], point2[1], point2[2], point2[3])
                local rx, ry, rz = findRotation3D(point1[1], point1[2], point1[3], point2[1], point2[2], point2[3])
                local matrix = Matrix(Vector3(x, y, z), Vector3(rx, ry, rz))
                local facing = matrix:getPosition() + matrix:getRight()
                local color = tocolor(255, 0, 0, 255)--Temporary, need to alter points array and store the color per vehicle
                local point1Matrix = Matrix(Vector3(point1[1], point1[2], point1[3]), Vector3(rx, ry, rz))
                local point2Matrix = Matrix(Vector3(point2[1], point2[2], point2[3]), Vector3(rx, ry, rz))
                local point1Above = point1Matrix:transformPosition(Vector3(0, 0, 1))
                local point1Below = point1Matrix:transformPosition(Vector3(0, 0, -1))
                local point2Above = point2Matrix:transformPosition(Vector3(0, 0, 1))
                local point2Below = point2Matrix:transformPosition(Vector3(0, 0, -1))
                local hitAbove, hitXAbove, hitYAbove, hitZAbove, hitElementAbove = processLineOfSight(point1Above, point2Above)
                local hitMiddle, hitXMiddle, hitYMiddle, hitZMiddle, hitElementMiddle = processLineOfSight(point1Matrix:getPosition(), point2Matrix:getPosition())
                local hitBelow, hitXBelow, hitYBelow, hitZBelow, hitElementBelow = processLineOfSight(point1Below, point2Below)
                dxDrawMaterialLine3D(point1[1], point1[2], point1[3], point2[1], point2[2], point2[3], texture, 2, color, false, facing.x, facing.y, facing.z)
                if debug then
                    local hitAboveColor = tocolor(0, 0, 255, 255)
                    local hitMiddleColor = tocolor(0, 0, 255, 255)
                    local hitBelowColor = tocolor(0, 0, 255, 255)
                    if hitAbove then
                        hitAboveColor = tocolor(0, 255, 0, 255)
                    end
                    if hitMiddle then
                        hitMiddleColor = tocolor(0, 255, 0, 255)
                    end
                    if hitBelow then
                        hitBelowColor = tocolor(0, 255, 0, 255)
                    end
                    dxDrawLine3D(point1Above.x, point1Above.y, point1Above.z, point2Above.x, point2Above.y, point2Above.z, hitAboveColor)
                    dxDrawLine3D(point1Matrix:getPosition(), point2Matrix:getPosition(), hitMiddleColor)
                    dxDrawLine3D(point1Below.x, point1Below.y, point1Below.z, point2Below.x, point2Below.y, point2Below.z, hitBelowColor)
                end
            end
        end
    end
    if inVehicle and points[inVehicle] then
        local pointData = points[inVehicle][#points[inVehicle]]
        local x1, y1, z1 = pointData[1], pointData[2], pointData[3]
        local x2, y2, z2 = getElementPosition(inVehicle)
        local dist = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
        if dist > 0.1 and dist < 4 then
            storeLine(inVehicle, {x2, y2, z2})
        end
    elseif inVehicle and not points[inVehicle] then
        local x2, y2, z2 = getElementPosition(inVehicle)
        points[inVehicle] = {{x2, y2, z2}}
    end
end

function storeLine(vehicle, pointData)
    if #points[vehicle] == 200 then
        table.remove(points[vehicle], 1)
        table.insert(points[vehicle], pointData)
    else
        table.insert(points[vehicle], pointData)
    end
end

function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

function calculateMidpoint2D(x, y, x2, y2)
    return (x+x2)/2, (y+y2)/2
end

function calculateMidpoint3D(x, y, z, x2, y2, z2)
    return (x+x2)/2, (y+y2)/2, (z+z2)/2
end

addEventHandler("onClientVehicleEnter", root, function(player, seat)if player == localPlayer then inVehicle = getPedOccupiedVehicle(localPlayer)end end)
addEventHandler("onClientVehicleExit", root, function()inVehicle = false end)

addEventHandler("onClientRender", root, clientRender)
addCommandHandler("devmode",function()setDevelopmentMode(true)end)