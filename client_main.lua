local cycle_trail = dxCreateTexture("lightcycle_trail.png")
local renderLines = {}
local renderPoints = {}
local rayCasts = {}
local font = 'default'
local fontHeight = dxGetFontHeight(1, font)

function clientRender()
    for colShape, trailData in pairs(renderLines) do
        dxDrawLine3D(trailData[1], trailData[2], trailData[3], trailData[4], trailData[5], trailData[6])
    end
    for key, positionMatrix in ipairs(renderPoints) do
        local sx, sy = getScreenFromWorldPosition(positionMatrix)
        if sx then
            dxDrawCircle(sx, sy, 5, 0, 360, tocolor(255, 0, 0, 255))
        end
    end
end


function createTrail(colShape, trailData)
    local x, y, z = calculateMidpoint3D(trailData[1], trailData[2], trailData[3], trailData[4], trailData[5], trailData[6])
    local rx, ry, rz = findRotation3D(trailData[1], trailData[2], trailData[3], trailData[4], trailData[5], trailData[6])
    local lineLength = getDistanceBetweenPoints3D(trailData[1], trailData[2], trailData[3], trailData[4], trailData[5], trailData[6])
    local startPointMatrix = Matrix(Vector3(trailData[1], trailData[2], trailData[3]), Vector3(rx, ry, rz))
    local belowStart = startPointMatrix:transformPosition(Vector3(0, 0, -1))
    local aboveStart = startPointMatrix:transformPosition(Vector3(0, 0, 1))
    local endPointMatrix = Matrix(Vector3(trailData[4], trailData[5], trailData[6]), Vector3(rx, ry, rz))
    local belowEnd = endPointMatrix:transformPosition(Vector3(0, 0, -1))
    local aboveEnd = endPointMatrix:transformPosition(Vector3(0, 0, 1))
    local slopeMatrix = Matrix(Vector3(x, y, z), Vector3(rx, ry, rz))
    local belowSlope = slopeMatrix:transformPosition(Vector3(0, 0, -1))
    local aboveSlope = slopeMatrix:transformPosition(Vector3(0, 0, 1))
    --Lines
    table.insert(renderLines, trailData)
    table.insert(renderLines, {aboveStart.x, aboveStart.y, aboveStart.z, aboveEnd.x, aboveEnd.y, aboveEnd.z})
    table.insert(renderLines, {belowStart.x, belowStart.y, belowStart.z, belowEnd.x, belowEnd.y, belowEnd.z})
    --Points
    table.insert(renderPoints, belowSlope)
    table.insert(renderPoints, aboveSlope)
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


addEvent("createTrail", true)

addEventHandler("onClientRender", root, clientRender)
addEventHandler("createTrail", root, createTrail)

addCommandHandler("devmode",function()setDevelopmentMode(true)end)

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