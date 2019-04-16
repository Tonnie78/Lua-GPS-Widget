---- #########################################################################
---- #                                                                       #
---- # GPS Widget for FrSky Horus 			                     #
-----#                                                                       #
---- # License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html               #
---- #                                                                       #
---- # This program is free software; you can redistribute it and/or modify  #
---- # it under the terms of the GNU General Public License version 3 as     #
---- # published by the Free Software Foundation.                            #
---- #                                                                       #
---- # Rev 0.1  				                             #									         #
---- # Author Tonnie Oostbeek  						     #
---- # Thanks To LShems for assisting me in my first trail to write a Widget #
---- #########################################################################



local options = {
  { "TextColor", COLOR, Black }
}



local function create(zone, options)
  local myWidget  = { zone=zone, options=options, counter=0 }
  local bmp = {}
  local map = {North={},South={},West={},East={}}
  local wx = {}
  local wy = {}
  local zx = {}
  local zy = {}
	
  -- coordinates for the small map.
  map.North.small = 52.559801
  map.South.small = 52.554921
  map.West.small = 5.867646
  map.East.small = 5.879677
  bmp.small = Bitmap.open("/Widgets/Image1/map.png")
  wx.small = 320
  wy.small = 0
  zx.small = 479
  zy.small = 210


  -- coordinates for the medium map.
  map.North.medium = 52.561551
  map.South.medium = 52.554211
  map.West.medium = 5.864698
  map.East.medium = 5.882574
  bmp.medium = Bitmap.open("/Widgets/Image1/map1.png")
  wx.medium = 246
  wy.medium = 0
  zx.medium = 443
  zy.medium = 271


  --coordinates for the largest map. 
  map.North.large = 52.564116
  map.South.large = 52.553043
  map.West.large = 5.859864
  map.East.large = 5.887011
  bmp.large = Bitmap.open("/Widgets/Image1/map2.png")
  wx.large = 197
  wy.large = 0
  zx.large = 410
  zy.large = 271
		
  map.current = "large"

  myWidget.map = map
  myWidget.bmp = bmp
  myWidget.wx = wx
  myWidget.wy = wy
  myWidget.zx = zx
  myWidget.zy = zy
	
  return myWidget
end

local function background()
end

local function update(myWidget, options)
  myWidget.options = options
end

function refresh(myWidget)
  local plane = model.getInfo()
  local style = SMLSIZE
  local xOffset = 0
  local yOffset = 0
  
 --  ***************  prevent from run in wrong areas ***********************	
 
  if myWidget.zone.w  > 380 and myWidget.zone.h > 165 then   		-- fullscreen
--  if myWidget.zone.w  > 180 and myWidget.zone.h > 145  then 		-- halfscreen
--  if myWidget.zone.w  > 170 and myWidget.zone.h > 65 then 		-- "quater"
--  if myWidget.zone.w  > 150 and myWidget.zone.h > 28 then 			-- all zones but not TopBar
--  if myWidget.zone.w  > 65 and myWidget.zone.h > 35 then 			-- TopBar
	
  else
	lcd.setColor(CUSTOM_COLOR, RED)
	lcd.drawText(myWidget.zone.x + 2, myWidget.zone.y+2,"not here!",0)
	return
  end

  gpsLatLong = getValue("GPS")
  if  (type(gpsLatLong) =~ "table") then
    lcd.drawBitmap(myWidget.bmp[myWidget.map.current], myWidget.zone.x -10, myWidget.zone.y -10)
    lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))
    lcd.drawText( 20, 130, "No GPS SIGNAL !!!", DBLSIZE, CUSTOM_COLOR)
    model.setGlobalVariable(8,0,0)
    return
  end		
  
  local headingDeg = getValue("Hdg")  
  local gpsLat = gpsLatLong["lat"]
  local gpsLong = gpsLatLong["lon"]

-- Part for loading the correct zoomlevel of the map

-- coordinates for the smallest map. These can be found by placing the image back into Google Earth and looking at the overlay
-- parameters


  if      gpsLat < myWidget.map.North.small and gpsLat > myWidget.map.South.small and gpsLong < myWidget.map.East.small and gpsLong > myWidget.map.West.small then    
      myZone.map.current = "small"
  elseif      gpsLat < myWidget.map.North.medium and gpsLat > myWidget.map.South.medium and gpsLong < myWidget.map.East.medium and gpsLong > myWidget.map.West.medium then    
      myWidget.map.current = "medium"
  else    
      myWidget.map.current = "large"
  end

  local wx = myWidget.wx[myWidget.map.current]
  local wy = myWidget.wy[myWidget.map.current]
  local zx = myWidget.zx[myWidget.map.current]
  local zy = myWidget.zy[myWidget.map.current]
  local North = myWidget.map.North[myWidget.map.current]
  local South = myWidget.map.South[myWidget.map.current]
  local East = myWidget.map.East[myWidget.map.current]
  local West = myWidget.map.West[myWidget.map.current]
  local bmp = myWidget.bmp[myWidget.map.current]
-- Part for setting the correct zoomlevel ends here.

-- Calculate Position in relation to map. 

  local x = math.floor(480*((gpsLong - West)/(East - West)))
  local y = math.floor(272*((North - gpsLat)/(North - South)))

  x=math.max(10,x)
  x=math.min(470,x)
	
  y=math.max(10,y)
  y=math.min(262,y)

-- Part for Map position ends here


  lcd.drawBitmap(bmp, myWidget.zone.x -10, myWidget.zone.y -10)

  lcd.setColor(CUSTOM_COLOR, RED)
  lcd.drawText(40, 40, gpsLat, CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR, WHITE)
  lcd.drawText(40, 60, gpsLong , CUSTOM_COLOR) 
  lcd.setColor(CUSTOM_COLOR, BLUE)
  lcd.drawText(40, 80, math.floor(headingDeg) , CUSTOM_COLOR)
  lcd.drawText(40, 100, x , CUSTOM_COLOR)
  lcd.drawText(40, 120, y , CUSTOM_COLOR)

  local xvalues = { }
  local yvalues = { }

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
 

end

return { name="Map", options=options, create=create, update=update, background=background, refresh=refresh }
