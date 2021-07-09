*! 1.0.1 NJC 13 June 2005    
* 1.0.0 NJC 25 May 2005    
* symbols are bounded y +/- e vertically, x +/- u horizontally 
* or with -limits- option by y1 y2 x1 x2 
program diplot
	version 9
	gettoken what 0 : 0 

	local OKlist "rectangle plus capplus diamond barrow" 
	foreach w of local OKlist { 
		if "`what'" == substr("`w'",1,length("`what'")) { 
			local shp "`w'"
		}
	}
	if "`shp'" == "" { 
		di as err "invalid shape? possibilities are `OKlist'" 
		exit 198 
	}	
	
	syntax varlist(min=4 max=4) [if] [in] ///
	[ , limits shape(str asis) addplot(str asis) *] 

	quietly { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 

		tokenize `varlist'
		local Y "`1'" 
		local X "`3'" 
		
		if "`limits'" != "" { 
			args y1 y2 x1 x2
			if "`shp'" != "rectangle" { 
				tempvar y x 
				gen `y' = (`y1' + `y2')/2
				gen `x' = (`x1' + `x2')/2
			}
		}	
		else { 
			args y e x u 
			capture assert `e' >= 0 & `u' >= 0 if `touse' 
			if _rc { 
				di as err "negative dimensions for symbols"
				exit 498 
			}	
			
			tempvar y1 y2 x1 x2 
			gen `y1' = `y' - `e' if `touse' 
			gen `y2' = `y' + `e' if `touse' 
			gen `x1' = `x' - `u' if `touse' 
			gen `x2' = `x' + `u' if `touse' 
		} 	
	}	

	local yttl : variable label `Y' 
	if `"`yttl'"' == "" local yttl "`Y'" 

	local xttl : variable label `X' 
	if `"`xttl'"' == "" local xttl "`X'" 

	if "`shp'" == "rectangle" { 
		twoway pcspike `y1' `x1' `y2' `x1', col(black) `shape' ///
		    || pcspike `y1' `x2' `y2' `x2', col(black) `shape' ///
		    || pcspike `y1' `x1' `y1' `x2', col(black) `shape' ///
		    || pcspike `y2' `x1' `y2' `x2', col(black) `shape' ///
		    yti(`yttl') xti(`xttl') legend(off) `options' ///
		    || `addplot' 
	} 
	else if "`shp'" == "plus" { 
		twoway pcspike `y' `x1' `y' `x2', col(black) `shape' ///
		    || pcspike `y2' `x' `y1' `x', col(black) `shape' ///
		    yti(`yttl') xti(`xttl') legend(off) `options' ///
		    || `addplot' 
	} 
	else if "`shp'" == "capplus" { 
		twoway pcbarrow `y' `x1' `y' `x2', mang(90) col(black) `shape' ///
		    || pcbarrow `y2' `x' `y1' `x', mang(90) col(black) `shape' ///
		    yti(`yttl') xti(`xttl') legend(off) `options' ///
		    || `addplot' 
	}
	else if "`shp'" == "diamond" { 
		twoway pcspike `y' `x1' `y1' `x', col(black) `shape' ///
		    || pcspike `y1' `x' `y' `x2', col(black) `shape' ///
		    || pcspike `y' `x2' `y2' `x', col(black) `shape' ///
		    || pcspike `y2' `x' `y' `x1', col(black) `shape' ///
		    yti(`yttl') xti(`xttl') legend(off) `options' ///
	            || `addplot' 
	}	
	else if "`shp'" == "barrow" { 
		twoway pcbarrow `y' `x1' `y' `x2', col(black) `shape' ///
		    || pcbarrow `y2' `x' `y1' `x', col(black) `shape' ///
		    yti(`yttl') xti(`xttl') legend(off) `options' ///
		    || `addplot' 
	}
end

