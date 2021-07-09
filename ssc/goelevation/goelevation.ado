*! version 1.1, 17th August 2014
*Written by Chamara Anuranga (kcanuranga@gmail.com) and Janaki Jayanthan
*Progarm to download google elevation
version 8.0

**************Practice syntax***************
capture program drop goelevation
program define goelevation
syntax,[lat(varname) lng(varname) SAving(string) path(string) samples(integer 100) map(string) REPLACE nograph example]

	local totobsbase=_N
	if `totobsbase'>0 {
		preserve
	}
	
	if ("`lat'"=="") & ("`path'"=="") & ("`example'"=="") {
		display as error "Please specify latitude variable or path"
		exit
	}

	if ("`lng'"=="") & ("`path'"=="")  & ("`example'"=="") {
		display as error "Please specify longitude variable or path"
		exit
	}
	
	if ("`saving'"=="") & ("`replace'"=="") & (`totobsbase'>0)  & ("`example'"=="") {
		display as error "Please specify new file name to save or replace option"
		exit
	}
	
	if ("`saving'"!="") & ("`replace'"!="")  & (`totobsbase'>0)  & ("`example'"=="") {
		display as error "Please specify only one option saving or replace"
		exit
	}

qui {
	if ("`lat'"!="") & ("`lng'"!="") & ("`path'"=="") {	
		tempfile temp1 temp2 results orgfile
		tempvar seno
		tempname memhold
		gen `seno'=_n
		save "`orgfile'.dta",replace
	*Post result to Stata data file
		postfile `memhold'  elevation  `lat' lng resolution status using "`results'",replace
		sum `seno'
		foreach num of numlist 1/`r(max)' {
			use "`orgfile'.dta",clear
			levelsof `lat' in `num'
			local latitude =r(levels)			
			levelsof `lng' in `num'
			local longitude =r(levels)
			copy "http://maps.googleapis.com/maps/api/elevation/json?locations=`latitude',`longitude'"  "`temp1'.txt",replace
			filefilter "`temp1'.txt" "`temp2'.txt", from("{") to("") replace			
			filefilter "`temp2'.txt" "`temp1'.txt", from("}") to("") replace
			filefilter "`temp1'.txt" "`temp2'.txt", from(",") to("") replace
			filefilter "`temp2'.txt" "`temp1'.txt", from("[") to("") replace	
			filefilter "`temp1'.txt" "`temp2'.txt", from("]") to("") replace	
			
	*Loading text tile for each location
			clear
			insheet using "`temp2'.txt",delimit(" ") 
			rename v1 _varname
			drop v2

			replace v3="1" if v3=="OK"
			replace v3="2" if v3=="INVALID_REQUEST"	
			replace v3="3" if v3=="OVER_QUERY_LIMIT"	
			replace v3="4" if v3=="REQUEST_DENIED"	
			replace v3="5" if v3=="UNKNOWN_ERROR"	
			destring v3,replace force
			
	*Reshape data
			xpose,clear varname 
			drop _varname
			sleep 100			
	*Push data to Stata data file
			post `memhold' (elevation) (lat) (lng) (resolution) (status) 
		}
	
		postclose `memhold'
	
		use "`results'",clear
		gen seno=_n
		order seno lat lng elevation resolution status
		
		label var status "Elevation response "
		label var lat "latitude"
		label var lng "longitude"
		label var resolution "distance from elevation was interpolated, in meters"
		label var elevation "Elevation"
		label define status 1 "OK" 2 "INVALID_REQUEST" 3 "OVER_QUERY_LIMIT" 4 "REQUEST_DENIED" 5 "UNKNOWN_ERROR"
		label val status status
		save "`results'",replace
		
		
		local cond1=regexm("`saving'",",replace")
		local confname=subinstr("`saving'",",replace","",1)
		
		if ("`saving'"!="") & (`cond1'==1) {			
			noisily save "`confname'",replace			
		}
		
		if ("`saving'"!="") & (`cond1'==0) {			
			noisily save "`confname'"			
		}
		
		if `totobsbase'>0 {
			restore
		}
		
		if ("`replace'"!="") {                  
           use "`results'",clear
        }
	
		exit

	}	
}
		
		if ("`lat'"=="") & ("`lng'"=="") & ("`path'"!="") {	
		display as result "elevation profile for `samples' points"
	qui {		
			if ("`map'"=="") {
				local map="terrain"			
			}
			tempfile graph1 graph2 graph3 temp temp1 temp2 results image myfile
	
			copy "http://maps.googleapis.com/maps/api/elevation/json?path=`path'&samples=`samples'" "`temp'.txt",replace	 
		
			filefilter "`temp'.txt" "`temp2'.txt", from("{") to("") replace	
			filefilter "`temp2'.txt" "`temp1'.txt", from("}") to("") replace		
			filefilter "`temp1'.txt" "`temp2'.txt", from(",") to("") replace	
			filefilter "`temp2'.txt" "`temp1'.txt", from("]") to("") replace	
			filefilter "`temp1'.txt" "`temp2'.txt", from("[") to("") replace
			
			insheet using "`temp2'.txt",delimit(" ")  clear
			drop v2
			drop in 1
			drop in l
			gen seno=_n
			sort v1 seno
			bys v1: gen obs=_n
			drop seno
			reshape wide v3,i(obs) j(v1)string
			rename v3* ggl_*
			destring ggl_elevation ggl_lat ggl_lng,replace
		
	*Labeling variables
			label var  ggl_elevation "Elevation of the location in meters"
			label var ggl_lat "Latitude"
			label var ggl_lng "Longitude"
			label var ggl_location "Location"
			label var ggl_resolution "Maximum distance between data points from which the elevation was interpolated, in meters"
		
		
		gen lat1=ggl_lat	
		gen lat2=ggl_lat[_n-1]	
		gen lon1=ggl_lng
		gen lon2=ggl_lng[_n-1]
		local conval=atan(1)/45
		gen temp=acos(cos(`conval'*(90-lat1)) *cos(`conval'*(90-lat2))+sin(`conval'*(90-lat1))*sin(`conval'*(90-lat2))*cos(`conval'*(lon1-lon2)))*6371	
		gen distance=sum(temp)		
		drop lat1 lat2 lon1 lon2 temp
		label var distance "Distance in KM (along the path)"
		save "`myfile'.dta",replace	
	
		if ("`nograph'"=="") {                  
 		graph twoway area ggl_elevation ggl_lat,ytitle("Elevation" "meters",orientation(horizontal)margin(top)) ylabel(, angle(horizontal)) fcolor(green) sort aspectratio(.2) graphregion(color(white))  saving(`graph1'.gph,replace)
		graph twoway area ggl_elevation ggl_lng,ytitle("Elevation" "meters",orientation(horizontal)margin(top)) ylabel(, angle(horizontal)) fcolor(green) sort aspectratio(.2) graphregion(color(white)) saving(`graph2'.gph,replace)
		graph twoway area ggl_elevation distance,ytitle("Elevation" "meters",orientation(horizontal)margin(top)) ylabel(, angle(horizontal)) fcolor(red) sort aspectratio(.2) graphregion(color(white)) saving(`graph3'.gph,replace)
		graph combine `graph1'.gph `graph2'.gph `graph3'.gph, col(1) graphregion(color(white)) plotregion(color(white)) plotregion(margin(zero))
		}
		
copy  "http://maps.googleapis.com/maps/api/staticmap?size=600x600&path=color:0xff0000ff|weight:5|`path'&maptype=`map'" "`image'.jpg",replace
capture confirm file `image'.jpg
if !_rc {
       capture shell `image'.jpg
   }
	else {
	 view browse "http://maps.googleapis.com/maps/api/staticmap?size=600x600&path=color:0xff0000ff|weight:5|`path'&maptype=`map'"
}




	}
		local cond1=regexm("`saving'",",replace")
		local confname=subinstr("`saving'",",replace","",1)
		
		if ("`saving'"!="") & (`cond1'==1) {			
			noisily save "`confname'",replace			
		}
		
		if ("`saving'"!="") & (`cond1'==0) {			
			noisily save "`confname'"			
		}
		
		if (`totobsbase'>0) {
			restore
		}
		
		if ("`replace'"!="") {
		use "`myfile'.dta",clear
	}
}
*Example 1 for help file	
	if ("`example'"!="") {
		clear
		set obs 3
		gen latitude =. 
		gen longitude=.
		replace latitude=6.925928 in 1
		replace longitude=79.902935 in 1
		replace latitude=7.307487 in 2
		replace longitude=80.603313 in 2
		replace latitude=7.292503 in 3
		replace longitude=80.229778 in 3
		list
		goelevation, lat(latitude) lng(longitude) replace
		list	
	}
end
