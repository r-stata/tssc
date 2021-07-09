*! version 1.0, Neal Caren, 05jan2011

capture program drop weathr
program weathr
	 version 10 
	 syntax  [anything(name=lookup)]



tempfile weather
tempname fh current forecast  weathrzipcode


if `"`lookup'"'=="" {
	capture confirm e $weathrzipcode
	if _rc {
		display as error _n  "You didn't enter a zip code and I couldn't find the global weathrzipcode. Sorry."
		exit
		}
	else {
	local lookup $weathrzipcode
	}
	 }

set tracedepth 1
set trace off
foreach `weathrzipcode' in `lookup' {

 capture if ``weathrzipcode''<10000 {
		}
		if _rc {
		display as error _  "You seem to have included something that isn't a US zipcode."
		exit
	 }
	 
local `forecast' ""
capture copy "http://weather.yahooapis.com/forecastrss?p=``weathrzipcode''" `weather', replace


set trace off
 if _rc {
		display as error _n "Can't seem to connect with yahoo.com for ``weathrzipcode''. Perhaps it is too stormy or you entered a bad zip code."
		exit
	 }
*doedit `weather'

local `current' 0
local `forecast' ""
file open `fh' using `weather', read
file read `fh' line
                while r(eof)==0 {
                        
              
						
						if regexm(`"`line'"',"Conditions ") {
						local place: subinstr local line "<title>Conditions for " "", all
						local place: subinstr local place "</title>" "", all
						display as result _n `"`place'"'
						}
						
						if regexm(`"`line'"',`"Current Conditions:"') local `current' 1
						
						if regexm(`"`line'"',`"Full Forecast at Yahoo!"')==1 local `current' 0
						if ``current''==1 {
						local `forecast' "``forecast'' `line'"
						}
						
				file read `fh' line
				
                }
				local `forecast': subinstr local `forecast' " <b>" "", all
				local `forecast': subinstr local `forecast' "</b><br />" "", all
				local `forecast': subinstr local `forecast' "<BR /> <BR /><b>" ". ", all
				local `forecast': subinstr local `forecast' "</b><BR />" "", all
				local `forecast': subinstr local `forecast' "<br />" ".", all
				local `forecast': subinstr local `forecast' ". ." ".", all
				local `forecast': subinstr local `forecast' " - " "-", all
				local `forecast': subinstr local `forecast' "Current Conditions: " "", all
				
				
				
				display as text   `"``forecast''"'
                file close `fh'
				if `"``forecast''"'=="" {
				display as error _n "Can't seem to connect with yahoo.com for ``weathrzipcode''. Perhaps it is too stormy or you didn't enter a valid US zip code."
				exit
				}
				}
end
