*! version 1.0.1  15aug2015 Robert Picard, picard@netbox.com
program define geocircles_examples

	version 9.2
	
	set more off
	
	`0'
	
end

program define Echo

	di as txt
	
	di as res _asis `". `0'"'
	
	`0'

end


program define geocircles_ex1

	preserve
	
	Echo geocircles 42.276916 -83.738218 50, data("data.dta") coor("coor.dta") replace
		
	Echo use "coor.dta", clear
	
	Echo geodist 42.276916 -83.738218 _Y _X, gen(d) sphere
	Echo gen diff = abs(50 - d)
	Echo summarize
	
	Echo use "data.dta", clear
	Echo spmap using "coor.dta", id(_ID) osize(vthin)

end


program define geocircles_ex1b

	preserve
	
	Echo geocircles 42.276916 -83.738218 50, data("data.dta") coor("coor.dta") replace
		
	Echo use "geo2xy_us_data.dta"
	
	Echo spmap if _ID == 44 using "geo2xy_us_coor.dta", id(_ID) polygon(data("coor.dta") osize(vthin)) osize(vthin)

end


program define geocircles_ex1c

	preserve
	
	Echo geocircles 42.276916 -83.738218 50, data("data.dta") coor("coor.dta") replace
		
	Echo use "coor.dta", clear
	Echo geo2xy _Y _X, replace
	Echo save "coor_xy.dta", replace

	Echo use "geo2xy_us_coor.dta", clear
	Echo geo2xy _Y _X, replace
	Echo save "geo2xy_us_coor_xy.dta", replace
	
	Echo use "geo2xy_us_data.dta"
	
	Echo spmap if _ID == 44 using "geo2xy_us_coor_xy.dta", id(_ID) polygon(data("coor_xy.dta") osize(vthin)) osize(vthin)

end


program define geocircles_ex2

	preserve
	
	Echo geocircles 42.276916 -83.738218 50, data("data.dta") coor("coor.dta") n(20) replace
	
	Echo use "coor.dta", clear
	
	Echo scatter _Y _X if _n <= 5, msymbol(smx) mcolor(red) || ///
		line _Y _X , lwidth(vthin) lcolor(eltblue) cmissing(n) ///
		ylabel(minmax, nogrid) yscale(off) xlabel(minmax, nogrid) xscale(off) ///
		aspectratio(1) legend(off)

end

program define geocircles_ex3

	preserve
	
	qui {
		clear
		set obs 3
		gen attractions = "The Alamo, San Antonio" in 1
		gen double lat = 29.425969 in 1
		gen double lon = -98.486142 in 1
		replace attractions = "Space Center, Houston" in 2
		replace lat = 29.550430 in 2
		replace lon = -95.097066 in 2
		replace attractions = "Texas Air & Space Museum, Amarillo" in 3
		replace lat = 35.213607 in 3
		replace lon = -101.714411 in 3
	}

	Echo gen distance = 30
	Echo expand 2
	Echo bysort attractions: replace distance = 100 if _n == 2
	Echo list, sepby(attractions) noobs

	Echo geocircles lat lon distance, data("data.dta") coor("coor.dta") replace
	
	Echo use "geo2xy_us_coor.dta", clear
	Echo keep if _ID == 51
	Echo replace _ID = -_ID
	Echo append using "coor.dta"
	Echo append using "data.dta"
	
	Echo geo2xy lat lon, gen(y0 x0)
	
	Echo geo2xy _Y _X, gen(y x)
	
	Echo scatter y0 x0, msymbol(smplus) mcolor(red) ///
		|| ///
		line y x if _ID > 0, lwidth(vthin) lcolor(eltblue) cmissing(n) ///
		|| ///
		line y x if _ID < 0, lwidth(vthin) lcolor(gray) cmissing(n) ///
		ylabel(minmax, nogrid) yscale(off) xlabel(minmax, nogrid) xscale(off) ///
		aspectratio(`r(aspect)') legend(off)

end


program define geocircles_ex4

	preserve
	
	qui {
		clear
		set obs 5
		gen attractions = "Anchorage" in 1
		gen double lat = 61.216387 in 1
		gen double lon = -149.894733 in 1
		replace attractions = "Juneau" in 2
		replace lat = 58.302051 in 2
		replace lon = -134.410854 in 2
		replace attractions = "Point Barrow" in 3
		replace lat = 71.385521 in 3
		replace lon = -156.467674 in 3
		replace attractions = "Attu Station" in 4
		replace lat = 52.832532 in 4
		replace lon = 173.179588 in 4
		replace attractions = "Middle of Nowhere" in 5
		replace lat = 61.75 in 5
		replace lon = 180 in 5
	}

	Echo list, noobs

	Echo geocircles lat lon 100, data("data.dta") coor("coor.dta") replace

	Echo use "geo2xy_us_coor.dta", clear
	Echo keep if _ID == 37
	Echo replace _ID = -_ID
	Echo append using "coor.dta"
	Echo append using "data.dta"
	
	Echo replace _Y = lat if !mi(lat)
	Echo replace _X = lon if !mi(lon)
	Echo replace _ID = 0 if !mi(lon)
	Echo gen double _XX = cond(_X > 0, _X - 180, _X + 180)
	
	Echo geo2xy _Y _XX, gen(y x)
	
	Echo scatter y x if _ID == 0, msymbol(smplus) mcolor(red) ///
		|| ///
		line y x if _ID > 0, lwidth(vthin) lcolor(eltblue) cmissing(n) ///
		|| ///
		line y x if _ID < 0, lwidth(vthin) lcolor(gray) cmissing(n) ///
		ylabel(minmax, nogrid) yscale(off) xlabel(minmax, nogrid) xscale(off) ///
		aspectratio(`r(aspect)') legend(off) 
		   
end

program define geocircles_ex4a

	preserve
	
	qui {
		clear
		set obs 5
		gen attractions = "Anchorage" in 1
		gen double lat = 61.216387 in 1
		gen double lon = -149.894733 in 1
		replace attractions = "Juneau" in 2
		replace lat = 58.302051 in 2
		replace lon = -134.410854 in 2
		replace attractions = "Point Barrow" in 3
		replace lat = 71.385521 in 3
		replace lon = -156.467674 in 3
		replace attractions = "Attu Station" in 4
		replace lat = 52.832532 in 4
		replace lon = 173.179588 in 4
		replace attractions = "Middle of Nowhere" in 5
		replace lat = 61.75 in 5
		replace lon = 180 in 5
	}

	Echo list, noobs

	Echo geocircles lat lon 100, data("data.dta") coor("coor.dta") replace

	Echo use "geo2xy_us_coor.dta", clear
	Echo keep if _ID == 37
	Echo replace _ID = -_ID
	Echo append using "coor.dta"
	Echo append using "data.dta"
	
	Echo replace _Y = lat if !mi(lat)
	Echo replace _X = lon if !mi(lon)
	Echo replace _ID = 0 if !mi(lon)
	Echo gen double _XX = cond(_X > 0, _X - 180, _X + 180)
	
	Echo geo2xy _Y _XX, gen(y x) proj(albers)
	
	Echo scatter y x if _ID == 0, msymbol(smplus) mcolor(red) ///
		|| ///
		line y x if _ID > 0, lwidth(vthin) lcolor(eltblue) cmissing(n) ///
		|| ///
		line y x if _ID < 0, lwidth(vthin) lcolor(gray) cmissing(n) ///
		ylabel(minmax, nogrid) yscale(off) xlabel(minmax, nogrid) xscale(off) ///
		aspectratio(`r(aspect)') legend(off)
		   
end
