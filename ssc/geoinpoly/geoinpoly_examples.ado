*! version 1.0.4  15aug2015 Robert Picard, picard@netbox.com
program define geoinpoly_examples

	version 11
	
	set more off
	
	`0'
	
end

program define EchoX, rclass

	di as txt
	
	di as res _asis `". `0'"'
	
	`0'

	return add
	
end


program define Echo

	di as txt
	
	di as res _asis `". `0'"'
	
end



program define ex1

	EchoX set seed 42134123
	EchoX clear
	EchoX set obs 10000
	EchoX gen double _Y = 40 + 8.5 * runiform()
	EchoX gen double _X = -90 + 9 * runiform()
	
	EchoX geoinpoly _Y _X using "geo2xy_us_coor.dta"
	EchoX tab _ID, missing

	EchoX merge m:1 _ID using "geo2xy_us_data.dta", keep(master match) nogen
	EchoX tab NAME


end


program define ex1b

	Echo levelsof _ID, clean sep(",")
	qui levelsof _ID, clean sep(",")
	dis as res _n ". local states \`r(levels)'"
	qui local states `r(levels)'
	
	EchoX rename _ID _IDmatched
	EchoX append using "geo2xy_us_coor.dta"
	EchoX drop if !inlist(_ID , `states') & !mi(_ID)
	
	EchoX geo2xy _Y _X, gen(ycoor xcoor) proj(albers)
		
	EchoX scatter ycoor xcoor if !mi(_IDmatched), msymbol(point) mcolor(green) || ///
		scatter ycoor xcoor if !mi(_IDmatched) & NAME == "Michigan", msymbol(point) mcolor(cranberry) || ///
		scatter ycoor xcoor if mi(_IDmatched) & mi(_ID), msymbol(point) mcolor(sandb) || ///
		line ycoor xcoor if !mi(_ID) , lwidth(thin) lcolor(gray) cmissing(n)  ///
		ylabel(minmax) yscale(off) ///
        xlabel(minmax) xscale(off) ///
        aspectratio(`=r(aspect)') legend(off)
	
end


program define ex2a

	EchoX set seed 34124
	EchoX clear
	EchoX set obs 50
	EchoX gen pointid = _n
	EchoX gen double lat = 36.99908399999999631
	EchoX gen double lon = -109.0452229999999929
	EchoX replace lat = lat + runiform() - .5 if _n > 1
	EchoX replace lon = lon + runiform() - .5 if _n > 1
	
	EchoX geoinpoly lat lon using "geo2xy_us_coor.dta"

	EchoX bysort pointid (_ID):	gen N = _N
	EchoX tab _ID N, missing
	
end


program define ex2b

	EchoX drop _ID
	EchoX bysort pointid: keep if _n == 1
	
	EchoX geoinpoly lat lon using "geo2xy_us_coor.dta", unique
	EchoX rename _ID _IDunique

	EchoX geoinpoly lat lon using "geo2xy_us_coor.dta", inside
	EchoX rename _ID _IDinside

	EchoX geoinpoly lat lon using "geo2xy_us_coor.dta", ring unique
	EchoX rename _ID _IDringuniq
	
	EchoX list in 1/5
	
end


program define ex2c

	EchoX geoinpoly lat lon using "geo2xy_us_coor.dta", ring
	EchoX list in 1/10
	
end


program define ex3a

	EchoX geocircles 42.265864 -83.748694 150, data("data.dta") coor("coor_MI.dta") replace
	EchoX geocircles 40.012308 -83.027586 150, data("data.dta") coor("coor_OH.dta") replace
	EchoX use "coor_MI.dta", clear
	EchoX replace _ID = -1
	EchoX append using "coor_OH.dta"
	EchoX replace _ID = -2 if _ID != -1
	EchoX append using "geo2xy_us_coor.dta"
	EchoX save "states_circles.dta", replace
	
end


program define ex3b

	EchoX set seed 5234523
	EchoX clear
	EchoX set obs 10000
	EchoX gen double _Y = 38 + 8 * runiform()
	EchoX gen double _X = -90 + 9 * runiform()
	
	EchoX geoinpoly _Y _X using "states_circles.dta"

	EchoX bysort _Y _X: gen N_ID = _N
	EchoX tab _ID N_ID, missing
	
	EchoX merge m:1 _ID using "geo2xy_us_data.dta", keep(master match) keepusing(NAME) nogen
	EchoX tab NAME
	
end


program define ex3c

	Echo levelsof _ID if N_ID > 1, clean sep(",")
	qui levelsof _ID if N_ID > 1, clean sep(",")
	dis as res _n ". local states \`r(levels)'"
	qui local states `r(levels)'
	
	EchoX rename _ID _IDmatched
	EchoX append using "states_circles.dta"
	EchoX drop if !inlist(_ID , `states') & !mi(_ID)
	
	EchoX geo2xy _Y _X, gen(ycoor xcoor) proj(albers)
		
	EchoX scatter ycoor xcoor if _IDmatched > 0 & !mi(_IDmatched), msymbol(point) mcolor(gs15) || ///
		scatter ycoor xcoor if N_ID == 2 & NAME == "Michigan", msymbol(point) mcolor("blue") || ///
		scatter ycoor xcoor if N_ID == 2 & NAME == "Ohio", msymbol(point) mcolor("red") || ///
		scatter ycoor xcoor if N_ID == 3, msymbol(point) mcolor(green) || ///
		line ycoor xcoor if !mi(_ID) & _ID > 0, lwidth(thin) lcolor(gray) cmissing(n) || ///
		line ycoor xcoor if !mi(_ID) & _ID < 0, lwidth(vthin) lcolor(gray) cmissing(n)  ///
		ylabel(minmax) yscale(off) ///
        xlabel(minmax) xscale(off) ///
        aspectratio(`=r(aspect)') legend(off)
	
end
