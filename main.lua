---- #########################################################################
---- #                                                                       #
---- # GPS Widget for FrSky Horus 			                                     #
-----#                                                                       #
---- # License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html               #
---- #                                                                       #
---- # This program is free software; you can redistribute it and/or modify  #
---- # it under the terms of the GNU General Public License version 3 as     #
---- # published by the Free Software Foundation.                            #
---- #                                                                       #
---- # Rev 0.1  				                          									         #
---- # Tonnie Oostbeek                     													         #
---- #                                                                       #
---- #########################################################################


local bmp
local options = {
  { "TextColor", COLOR, Black }
}



local function create(zone, options)
  local myZone  = { zone=zone, options=options, counter=0 }
  local mapState = 1
  return myZone, mapState
end

local function background()
end

local function update(myZone, options)
  myZone.options = options
end

function refresh(myZone)
  local plane = model.getInfo()
  local style = SMLSIZE
  local xOffset = 0
  local yOffset = 0
  
 --  ***************  prevent from run in wrong areas ***********************	
 
    if myZone.zone.w  > 450 and myZone.zone.h > 265 then   		-- fullscreen
--  if myZone.zone.w  > 180 and myZone.zone.h > 145  then 		-- halfscreen
--  if myZone.zone.w  > 170 and myZone.zone.h > 65 then 		-- "quater"
--  if myZone.zone.w  > 150 and myZone.zone.h > 28 then 			-- all zones but not TopBar
--  if myZone.zone.w  > 65 and myZone.zone.h > 35 then 			-- TopBar
	
  else
		lcd.setColor(CUSTOM_COLOR, RED)
		lcd.drawText(myZone.zone.x + 2, myZone.zone.y+2,"select single window Widget no top bar",0)
  end

gpsLatLong = getValue("GPS")
if  (type(gpsLatLong) == "table") then 
headingDeg= getValue("Hdg")  
gpsLat = gpsLatLong["lat"]
gpsLong = gpsLatLong["lon"]
model.setGlobalVariable(7,0,1)

-- Part for loading the correct zoomlevel of the map

-- coordinates for the smallest map. These can be found by placing the image back into Google Earth and looking at the overlay
-- parameters
local mapsmallNorth = 52.559801
local mapsmallSouth = 52.554921
local mapsmallWest = 5.867646
local mapsmallEast = 5.879677

-- coordinates for the medium map.
local mapmediumNorth = 52.561551
local mapmediumSouth = 52.554211
local mapmediumWest = 5.864698
local mapmediumEast = 5.882574

--coordinates for the largest map. 
local maplargeNorth = 52.564116
local maplargeSouth = 52.553043
local maplargeWest = 5.859864
local maplargeEast = 5.887011


    if      gpsLat < mapsmallNorth and gpsLat > mapsmallSouth and gpsLong < mapsmallEast and gpsLong > mapsmallWest
    then    mapNorth = mapsmallNorth
            mapSouth = mapsmallSouth
            mapEast = mapsmallEast
            mapWest = mapsmallWest
            wx = 320
            wy = 0
            zx = 479
            zy = 210
	    local mapUpdate = 1
            bmp = Bitmap.open("/Widgets/Image1/map.png")
    elseif  gpsLat < mapmediumNorth and gpsLat > mapmediumSouth and gpsLong < mapmediumEast and gpsLong > mapmediumWest
    then    mapNorth = mapmediumNorth
            mapSouth = mapmediumSouth
            mapEast = mapmediumEast
            mapWest = mapmediumWest
            wx = 246
            wy = 0
            zx = 443
            zy = 271
	    local mapUpdate = 2
            bmp = Bitmap.open("/Widgets/Image1/map1.png")
    else    mapNorth = maplargeNorth
            mapSouth = maplargeSouth
            mapEast = maplargeEast
            mapWest = maplargeWest
            wx = 197
            wy = 0
            zx = 410
            zy = 271
	    local mapUpdate = 3
            bmp = Bitmap.open("/Widgets/Image1/map2.png")


	-- return (bmp, mapWest, mapEast, mapNorth, mapSouth)
  
  end

-- Part for setting the correct zoomlevel ends here.

-- Calculate Position in relation to map. 

x = math.floor(480*((gpsLong - mapWest)/(mapEast - mapWest)))
y = math.floor(272*((mapNorth - gpsLat)/(mapNorth - mapSouth)))

if x < 10 then x = 10 
elseif x > 470 then x = 470
else x = x
end

if y < 10 then y = 10
elseif y > 262 then y = 262
else y = y
end

-- Part for Map position ends here


if not mapState == mapUpdate then
  lcd.drawBitmap(bmp, myZone.zone.x -10, myZone.zone.y -10)
  mapState = mapUpdate
else
end

lcd.setColor(CUSTOM_COLOR, RED)
lcd.drawText(40, 40, GPSSpeed  .. " Km/h ", CUSTOM_COLOR)
-- lcd.setColor(CUSTOM_COLOR, RED)
-- lcd.drawText(40, 40, gpsLat, CUSTOM_COLOR)
-- lcd.setColor(CUSTOM_COLOR, WHITE)
-- lcd.drawText(40, 60, gpsLong , CUSTOM_COLOR)
-- lcd.setColor(CUSTOM_COLOR, BLUE)
-- lcd.drawText(40, 80, math.floor(headingDeg) , CUSTOM_COLOR)
-- lcd.drawText(40, 100, x , CUSTOM_COLOR)
-- lcd.drawText(40, 120, y , CUSTOM_COLOR)

  xvalues = { }
  yvalues = { }

--                     A
--                     |
--                     |
-- C   _________________|___________________  D
--                     |
--                     |
--                     |
--                     |
--                     |
--                     |
--                     |
--                E ---|--- F
--                     B


  xvalues.ax = x + (4 * math.sin(math.rad(headingDeg))) 							-- front of fuselage x position
  yvalues.ay = y - (4 * math.cos(math.rad(headingDeg))) 							-- front of fuselage y position
  xvalues.bx = x - (7 * math.sin(math.rad(headingDeg))) 							-- rear of fuselage x position
  yvalues.by = y + (7 * math.cos(math.rad(headingDeg))) 							-- rear of fuselage y position
  xvalues.cx = x + (10 * math.cos(math.rad(headingDeg))) 							-- left wingtip x position 
  yvalues.cy = y + (10 * math.sin(math.rad(headingDeg)))							-- left wingtip y position
  xvalues.dx = x - (10 * math.cos(math.rad(headingDeg)))							-- right wingtip x position
  yvalues.dy = y - (10 * math.sin(math.rad(headingDeg)))							-- right wingtip y position
  xvalues.ex = x - ((7 * math.sin(math.rad(headingDeg))) + (3 * math.cos(math.rad(headingDeg))))	-- left tailwing tip x position
  yvalues.ey = y + ((7 * math.cos(math.rad(headingDeg))) - (3 * math.sin(math.rad(headingDeg))))	-- left tailwing tip y position
  xvalues.fx = x - ((7 * math.sin(math.rad(headingDeg))) - (3 * math.cos(math.rad(headingDeg))))	-- right tailwing tip x position
  yvalues.fy = y + ((7 * math.cos(math.rad(headingDeg))) + (3 * math.sin(math.rad(headingDeg))))	-- right tailwing tip y position
lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,255,255))
lcd.drawLine(xvalues.ax, yvalues.ay, xvalues.bx, yvalues.by, SOLID, CUSTOM_COLOR)
lcd.drawLine(xvalues.cx, yvalues.cy, xvalues.dx, yvalues.dy, SOLID, CUSTOM_COLOR)
lcd.drawLine(xvalues.ex, yvalues.ey, xvalues.fx, yvalues.fy, SOLID, CUSTOM_COLOR)

--draw noflightzone
lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))
lcd.drawLine(wx, wy, zx, zy, SOLID, CUSTOM_COLOR)
if ((x - wx)*(zy-wy))-((y - wy)*(zx-wx)) < 0 then
      model.setGlobalVariable(8,0,0)
else 
      model.setGlobalVariable(8,0,1)
  
end
else 
  bmp = Bitmap.open("/Widgets/Image1/map2.png")
  lcd.drawBitmap(bmp, myZone.zone.x -10, myZone.zone.y -10)
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))
  lcd.drawText( 100, 130, "No GPS SIGNAL !!! ", DBLSIZE + BLINK + CUSTOM_COLOR)
  model.setGlobalVariable(8,0,0)
  model.setGlobalVariable(7,0,0)
end
return { name="Map", options=options, create=create, update=update, background=background, refresh=refresh }
