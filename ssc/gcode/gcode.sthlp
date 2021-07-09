TITLE
       'GCODE': module to download google geocode data

*Version February 2015
----------------------------------
Basic syntax:
gcode ‘location address’

DESCRIPTION/AUTHOR(S)
Gcode module downloads geocode data from google server (API V3) for location/address typed in stata command window. The module displays search results in stata output window and allows user to check availability of geocode data for a given address and search format. It also supports reverse coding. The module requires json file reader module `insheetjson' written by Erik Lindsley. 

Note: Module sends data request to google server and assumes that search address is in clean alphanumeric (single space) format and without non-alphanumeric characters.  

Address format: street address, city, zip code if available, country 

Examples:
gcode Vivo City Singapore
gcode Gleaneagels Singapore
gcode 1.2988,103.7894

***********************
Google Geocode Response
***********************
Status: OK
Type: [premise]
Location Type: ROOFTOP
Formatted Address: 1 Harbourfront Walk, VivoCity, Singapore 098585
Latitude: 1.2643741
Longitude: 103.82209

Author:
Muhammad Rashid Ansari						
INSEAD Business School						
1 Ayer Rajah Avenue, Singapore 138676

Reference:
https://developers.google.com/maps/documentation/geocoding/
