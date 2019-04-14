# Lua-GPS-Widget
Create a Horus Widget to show Plane location on a map that is placed on the screen as an image

First I created 3 images of aerial photos of my flying field. I created these images by taking snapshots from Google Earth at three different altidude levels / zoomlevels.
These images have been resized to fit the Horus Screensize of 480 x 272

These images where then placed back into Google Earth as overlays. after correcting the image to the correct size, you can find the coordinates of the images in the properties menu of the overlay. I stored these coordinates for later use.

When to script starts, it first loads the GPS location with getValue("GPS") and the heading with getValue("Hdg")

Then i fill the parameters of the different maps.

A if then else statement checks if the current location is within the coordinates of the smallest map (map). If so it loads this map. 
If not then the second If statement checks the current location towards the second map (map1). If within the limits it opens. If not it opens map2.

it also sets the coordinates beloning to the map to specific variables for later use to calculate screen position, end it loads the coordinates for the no flight zone in relation to the selected map.

Then i calculate the position of the plane on the screen
x = math.floor(480*((gpsLong - mapWest)/(mapEast - mapWest)))
y = math.floor(272*((mapNorth - gpsLat)/(mapNorth - mapSouth)))

As the max distance in this calculation is 1,7 km i do not take any unliniarity of the coordinate system into account.
i know the longitude is not exactly a straight line but as said on this scale it's no problem.

Then I draw a pointer in the shape of a plane on the map.

I use x and y variables for the location and heading from GPS for the rotation of the plane.

Based on the variables that came with the loaded map I draw a line on the map to represent my No Flight zone border.

With a calculation it is determend on what side of the no flight zone border my plane is located. If it is on one side I change Global Variable GV8 to 1 and on the other side to 0. I use a logical switch to change state based on the GV8.
This then activates a custom function to play a track and to activate my haptic feedback. ( Sometimes other clubmembers complain about my talking transmitter) ;)


<div>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick" />
<input type="hidden" name="hosted_button_id" value="2PG9VKAUJ3VHN" />
<input type="image" src="https://www.paypalobjects.com/en_US/NL/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
<img alt="" border="0" src="https://www.paypal.com/en_NL/i/scr/pixel.gif" width="1" height="1" />
</form>
<div>


