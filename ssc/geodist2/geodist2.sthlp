TITLE
       'GEODIST2': module to calculate straight line distance between two coordinates.

*Version June 2015
-----------------
Basic syntax:
distance, from(location1) to(location2)

DESCRIPTION/AUTHOR(S)
Geodist2 module calculates straight line distance between two coordinates using google geocode data.  The module requires json file reader module `insheetjson' written by Erik Lindsley. 

Module sends data request to google server and requires search address in clean alphanumeric (single space) format and without non-alphanumeric characters. It supports reverse coding.  

Haversine formula used for calculating distance:
Distance = 6371 * ACos( Cos( Lat1 ) * Cos( Lat2 ) * Cos( Lon2 - Lon1 ) + Sin( Lat1 ) * Sin( Lat2 ) )

Atn Function
Distance = 6371* Atn( Sqr( ( 1 - ( Sin( Lat1 / 57.29577951 ) * Sin( Lat2 / 57.29577951 ) + Cos( Lat1 / 57.29577951 ) * Cos( Lat2 / 57.29577951 ) * Cos( Lon2 / 57.29577951 - Lon1 / 57.29577951 ) ) ^2 ) ) / (Sin ( Lat1 / 57.29577951 ) * Sin( Lat2 / 57.29577951 ) + Cos( Lat1 / 57.29577951 ) * Cos( Lat2 / 57.29577951 ) * Cos( Lon2 / 57.29577951 - Lon1 / 57.29577951 ) ) ) 


Examples:
geodist2, from(INSEAD Singapore) to(INSEAD France)
geodist2, from(Paraguay) to(Taiwan)
geodist2, from(1.2987212,103.84743) to(1.2991855,103.78766)

--------------------
Geocode: Location 1
--------------------
Type: [point_of_interest, establishment]
Location Type: APPROXIMATE
Formatted Address: INSEAD Asia Campus, Singapore 138676
Latitude: 1.2998091
Longitude: 103.78648
.
--------------------
Geocode: Location 2
--------------------
Type: [point_of_interest, establishment]
Location Type: APPROXIMATE
Formatted Address: INSEAD, Boulevard de Constance, 77300 Fontainebleau, France
Latitude: 48.405279
Longitude: 2.684739
.
-----------------------------------------------------------------------
Straight Distance : 10715.09(Km)/6658.36(Miles)
From              : INSEAD Asia Campus, Singapore 138676
To                : INSEAD, Boulevard de Constance, 77300 Fontainebleau, France
-----------------------------------------------------------------------

Author:
Muhammad Rashid Ansari						
INSEAD Business School						
1 Ayer Rajah Avenue, Singapore 138676

Reference:
https://developers.google.com/maps/documentation/geocoding/
Robusto, C. C. 1957. The cosine-haversine formula. The American Mathematical Monthly, 64(1): 38–40
