root = getRootElement()
resourceRoot = getRootElement(getThisResource())

local trails = {}

function createTrailObject(player, x, y, z, x2, y2, z2)
    local centerX, centerY, centerZ = calculateMidpoint3D(x, y, z, x2, y2, z2)
    local lowestZ = lowestZ(z, z2) - 1
    local distZ = math.abs(z - z2) + 2
	local cylCol = createColTube(centerX, centerY, lowestZ, getDistanceBetweenPoints2D(x, y, x2, y2), distZ)
	trails[cylCol] = {x, y, z, x2, y2, z2, centerX, centerY, centerZ}
	triggerClientEvent(player, "createTrail", root, cylCol, trails[cylCol])
end

function enteredVehicle()

end

function exitedVehicle()

end

function removeTrailObject()

end

function collideCheck()
	--this should be called on
end

function serverTick()
	triggerEvent("onServerTick", root)
end

function resourceStart()
	setDevelopmentMode(true)
end

function resourceStop()

end

function enterColSphere()
	triggerClientEvent(player, "startRayChecks", resourceRoot, cylCol)
end

function calculateMidpoint2D(x, y, x2, y2)
    return (x+x2)/2, (y+y2)/2
end

function calculateMidpoint3D(x, y, z, x2, y2, z2)
    return (x+x2)/2, (y+y2)/2, (z+z2)/2
end

function lowestZ(z, z2)
    if z > z2 then
        return z2
    else
        return z
    end
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

 function tableFind(table, element)
    for index, value in pairs(table) do
        if value == element then
            return index
        end
    end
 end

addEventHandler("onResourceStart", resourceRoot, resourceStart)
addEventHandler("onResourceStop", resourceRoot, resourceStop)

addCommandHandler("trailTest", function(player, command)
    local x, y, z = getElementPosition(player)
    createTrailObject(player, x, y, z, x + 1, y, z + 1)
    createTrailObject(player, x + 1, y, z + 1, x + 2, y, z + 1.5)
    createTrailObject(player, x + 2, y, z + 1.5, x + 2.5, y + 2, z + 2)
end)
addCommandHandler("devmode", function()setDevelopmentMode(true)end)