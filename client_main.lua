local texture = dxCreateTexture("lightcycle_trail.png")
local points = {}
local rendering = true
local inVehicle = false

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
                dxDrawMaterialLine3D(point1[1], point1[2], point1[3], point2[1], point2[2], point2[3], texture, 2, color, false, facing.x, facing.y, facing.z)
            end
        end
    end
    if inVehicle and points[inVehicle] then
        local pointData = points[inVehicle][#points[inVehicle]]
        local x1, y1, z1 = pointData[1], pointData[2], pointData[3]
        local x2, y2, z2 = getElementPosition(inVehicle)
        local dist = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
        if dist > 2 and dist < 5 then
            storeLine(inVehicle, {x2, y2, z2})
        end
    elseif inVehicle and not points[inVehicle] then
        local x2, y2, z2 = getElementPosition(inVehicle)
        points[inVehicle] = {{x2, y2, z2}}
    end
end

function storeLine(vehicle, pointData)
    if #points[vehicle] == 25 then
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