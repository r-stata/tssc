******************************************
**    Sylvain Weber & Martin Péclat     **
**        University of Neuchâtel       **
**    Institute of Economic Research    **
**    This version: January 30, 2020    **
******************************************

*! version 2.5 Sylvain Weber & Martin Péclat 30jan2020
/*
Revision history:
- version 1.1 (2nov2016):
	- Minor changes: miles obtained as 1.609344*km instead of 1.6093, unused temporary variables 
	  dropped, url links created outside the loop and renamed.
- version 2.0 (24feb2017):
	- Check if HERE account is valid
	- cit in route_url if !herepaid
	- Return diagnostic if distance cannot be returned
-version 2.1 (20sep2017):
	- Correction of a bug causing an error (no geocoding) if blank spaces were 
	  inserted between x,y coordinates in startxy() or endxy()
-version 2.2 (20oct2017):
	- Correction of a bug causing an error (no geocoding) if x,y coordinates 
	  in startxy() or endxy() were below 1 (in absolute value) and inserted
	  without leading 0.
- No versions 2.3-2.4, but next revision numbered 2.5 to be in line with georoute
- version 2.5 (30jan2020):
	- Because of a change in HERE accounts, APP ID and APP CODE cannot be created 
	  anymore. From now on, only accounts with API KEY can be created. A new option 
	  "herekey(API KEY)" is added and can be used instead of "hereid(APP ID) herecode(APP CODE)".
*/

program georoutei, rclass
version 10.0

*** Syntax ***
#d ;
syntax, 
	[
		hereid(string) herecode(string) herekey(string)
		STARTADdress(string) startxy(string) 
		ENDADdress(string) endxy(string) 
		km
		herepaid
	]
;
#d cr


*** Checks ***
*insheetjson.ado and libjson.mlib must be installed
cap: which insheetjson.ado
if _rc==111 {
	di as error "insheetjson required; type {stata ssc install insheetjson}"
	exit 111
}
cap: which libjson.mlib
if _rc==111 {
	di as error "libjson required; type {stata ssc install libjson}"
	exit 111
}

*Either hereid and herecode or herekey must be specified, not both
if ("`hereid'"!="" & "`herecode'"=="") | ("`hereid'"=="" & "`herecode'"!="") {
	di as error "HERE credentials must be indicated either with both hereid() and herecode(), or with herekey() alone."
	error 198
}
if ("`hereid'"!="" & "`herecode'"!="") & "`herekey'"!="" {
	di as error "HERE credentials must be indicated either with both hereid() and herecode(), or with herekey() alone."
	error 198
}
if "`herekey'"!="" & !("`hereid'"=="" & "`herecode'"=="") {
	di as error "HERE credentials must be indicated either with both hereid() and herecode(), or with herekey() alone."
	error 198
}

*HERE account must be active valid 
if ("`hereid'"!="" & "`herecode'"!="") {
	local here_check = "http://geocoder.cit.api.here.com/6.2/geocode.json?searchtext=outofearth&app_id=`hereid'&app_code=`herecode'"
	if ("`herepaid'"=="herepaid") local here_check = "http://geocoder.api.here.com/6.2/geocode.json?searchtext=outofearth&app_id=`hereid'&app_code=`herecode'"
}
if "`herekey'"!="" {
	local here_check = "https://geocoder.ls.hereapi.com/6.2/geocode.json?searchtext=outofearth&apiKey=`herekey'"
}
tempvar checkok 
qui: gen str240 `checkok' = ""
qui: insheetjson `checkok' using "`here_check'", columns("Response:MetaInfo:Timestamp") flatten replace
if `checkok'[1]=="" {
	di as error `"There seem to be an issue with your HERE account: {browse "https://developer.here.com"}."'
	exit 198
}

*One of start_add or start_coord and one of end_add or end_coord must be specified (one of each and only one)
foreach p in start end {
	if "``p'address'"=="" & "``p'xy'"=="" {
		di as error "`p'address() or `p'xy() is required."
		error 198
	}
	if "``p'address'"!="" & "``p'xy'"!="" {
		di as error "`p'address() and `p'xy() may not be combined."
		error 184
	}
}

*If specified, coordinates of starting and ending points must be provided as two numbers separated by a comma
foreach p in start end {
	if "``p'xy'"!="" {
		if strpos("``p'xy'",",")==0 | strpos("``p'xy'",",")!=strrpos("``p'xy'",",") { // there is no comma or several
			di as error "option `p'xy() incorrectly specified"
			error 198
		}
		local commapos = strpos("``p'xy'",",")-1
		local `p'_x = substr("``p'xy'",1,`commapos')
		local `p'_x = subinstr("``p'_x'"," ","",.)
		if abs(``p'_x')<1 {
			local dotpos = strpos("``p'_x'",".")+1
			local l = length(substr("``p'_x'",`dotpos',.))
			local `p'_x: di %0`=`l'+2'.`l'f ``p'_x'
		}
		cap: confirm number ``p'_x'
		if _rc {
			di as error "option `p'xy() incorrectly specified"
			error 198
		}
		local commapos = strpos("``p'xy'",",")+1
		local `p'_y = substr("``p'xy'",`commapos',.)
		local `p'_y = subinstr("``p'_y'"," ","",.)
		if abs(``p'_y')<1 {
			local dotpos = strpos("``p'_y'",".")+1
			local l = length(substr("``p'_y'",`dotpos',.))
			local `p'_y: di %0`=`l'+2'.`l'f ``p'_y'
		}
		cap: confirm number ``p'_y'
		if _rc {
			di as error "option `p'xy() incorrectly specified"
			error 198
		}
		if !inrange(``p'_x',-90,90) {
			di as error "Latitudes must be between -90 and 90"
			error 198
		}
		if !inrange(``p'_y',-180,180) {
			di as error "Longitudes must be between -180 and 180"
			error 198
		}
		*Re-construct xy coordinates:
		local `p'xy = `"``p'_x',``p'_y'"'
	}
}


*** Calculate travel distance and time ***
*Prepare url links
if ("`hereid'"!="" & "`herecode'"!="") {
	local xy_url = "http://geocoder.cit.api.here.com/6.2/geocode.json?responseattributes=matchCode&searchtext="
	if ("`herepaid'"=="herepaid") local xy_url = "http://geocoder.api.here.com/6.2/geocode.json?responseattributes=matchCode&searchtext="
	local here_key = "&app_id=" + "`hereid'" + "&app_code=" + "`herecode'"
}
if "`herekey'"!="" {
	local xy_url = "https://geocoder.ls.hereapi.com/6.2/geocode.json?responseattributes=matchCode&searchtext="
	local here_key = "&apiKey=`herekey'"
}

*Addresses to xy-coordinates (only if addresses are provided, skipped if xy-coordinates are provided)
foreach p in start end {
	if "``p'address'"!="" {
		tempvar temp_x temp_y
		qui: gen str240 `temp_x' = ""
		qui: gen str240 `temp_y' = ""

		local coords = "``p'address'"
		local coords = subinstr("`coords'", ".", "", .)
		local xy_request = "`xy_url'" + "`coords'" + "`here_key'"
		local xy_request = subinstr("`xy_request'", " ", "%20", .)

		#d ;
		qui: insheetjson `temp_x' `temp_y' using "`xy_request'", 
			columns("Response:View:1:Result:1:Location:DisplayPosition:Latitude" 
					"Response:View:1:Result:1:Location:DisplayPosition:Longitude"
			) 
			flatten replace
		;
		#d cr

		local temp_xy = `temp_x'[1] + "," + `temp_y'[1]
		local `p'xy = "`temp_xy'"
	}
}

*xy-coordinates to distance
tempvar temp_time temp_distance
qui: gen str240 `temp_distance' = ""
qui: gen str240 `temp_time' = ""
local s = "`startxy'"
local e = "`endxy'"
if ("`hereid'"!="" & "`herecode'"!="") {
	local route_url = "http://route.cit.api.here.com/routing/7.2/calculateroute.json?app_id=" + "`hereid'" + "&app_code=" + "`herecode'"
	if ("`herepaid'"=="herepaid") local route_url = "http://route.api.here.com/routing/7.2/calculateroute.json?app_id=" + "`hereid'" + "&app_code=" + "`herecode'"
}
if "`herekey'"!="" {
	local route_url = "https://route.ls.hereapi.com/routing/7.2/calculateroute.json?apiKey=`herekey'"
}
local route_request = "`route_url'" + "&waypoint0=geo!" + "`s'" + "&waypoint1=geo!" + "`e'" +"&mode=fastest;car;&representation=overview"
#d ;
qui: insheetjson `temp_distance' `temp_time' using "`route_request'", 
	columns("response:route:1:summary:distance" 
			"response:route:1:summary:travelTime"
	) 
	flatten replace
;
#d cr
if "`km'"=="" {
	local distance: di %8.2f real(`temp_distance'[1])/1609.344
}
if "`km'"=="km" {
	local distance: di %8.2f real(`temp_distance'[1])/1000
}
local time: di %8.2f (1/60)*real(`temp_time'[1])


*** Display results ***
local dup = length("From: `=cond("`startaddress'"!="","`startaddress' (`startxy')","(`startxy')")'")
local dup = max(`dup',length("To:   `=cond("`endaddress'"!="","`endaddress' (`endxy')","(`endxy')")'"))
if `distance'!=. {
	di as input _n(1) _dup(`dup') "-"
	di as input "From: `=cond("`startaddress'"!="","`startaddress' (`startxy')","(`startxy')")'"
	di as input "To:   `=cond("`endaddress'"!="","`endaddress' (`endxy')","(`endxy')")'"
	di as input _dup(`dup') "-"

	di as res "Travel distance:" _col(20) "`distance' `=cond("`km'"=="km","kilometers","miles")'"
	di as res "Travel time:" _col(20) "`time' minutes"

	return scalar time = `time'
	return scalar dist = `distance'
	return local end "(`endxy')"
	return local start "(`startxy')"
}
if `distance'==. {
	di as input _n(1) _dup(`dup') "-"
	di as input "From: `=cond("`startaddress'"!="","`startaddress' (`startxy')","(`startxy')")'"
	di as input "To:   `=cond("`endaddress'"!="","`endaddress' (`endxy')","(`endxy')")'"
	di as input _dup(`dup') "-"
	
	di as err "Impossible to calculate a routing distance:"
	if "`startaddress'"!="" & "`startxy'"=="," {
		di as err _col(3) `"- "`startaddress'" could not be geocoded."'
	}
	if "`endaddress'"!="" & "`endxy'"=="," {
		di as err _col(3) `"- `endaddress' could not be geocoded."'
	}
	if "`startxy'"!="," & "`endxy'"!="," {
		di as err _col(3) `"- Check that the two addresses/geographical points you provided can actually be linked by road."'
	}
}

end
