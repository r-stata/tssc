*! version 1.0.1 Januar 6, 2011 @ 15:59:35 UK
*! g to ounce conversion


// Main Program
// ------------

// This pares user input into pieces for converter
program g2oz, rclass
version 11.1
	syntax [anything] [, Unit(string) ]
	if "`anything'" == "" local anything 1g
	if "`unit'" == "" local unit g

	display _n "{txt}" ///
	  "{ralign 9:g}{c |}" ///
	  "{ralign 9:kg}{c |}" ///
	  "{ralign 9:ounce}{c |}" ///
	  "{ralign 9:pound}{c |}" ///
	  "{ralign 9:stone}{c |}" ///
	  "{ralign 9:long ton}{c |}" ///
	  "{ralign 9:short ton}{c |}" ///
	  "{ralign 9:grain}{c |}" _n ///
	  "{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c RT}" ///
	  
	local result 1
	foreach piece of local anything {
		macro drop _format

		// Number without unit -> g implied
		capture confirm number `piece'
		if !_rc local format "`piece'`unit'"

		// Number with unit -> use asis
		local check = regexm("`piece'","([0-9.]+)([A-za-z]+)")
		if `check' local format "`piece'"

		// Call converter
		foreach part of local format {
			conversion `part'
			foreach res in g kg oz lb st tnl tns gr {
				return scalar `res'`result' = r(`res')
				}
			local result = `result' + 1
			}
		}
end
	
program conversion, rclass
	args format
	local u = regexm("`format'","[a-zA-Z]+")
	local unit = regexs(0)
	local number = subinstr("`format'","`unit'","",.)
	
	local known g kg oz lb st tnl tnsh gr
	if !`: list posof "`unit'" in known' {
		di as error "unit `unit' invalid
		exit 198
	}
		
	if "`unit'"=="g" local g `number'
	else if "`unit'"=="kg" local g=`number'*1000
	else if "`unit'"=="oz" local g=`number'*28.349523125
	else if "`unit'"=="lb" local g=`number'*453.592370
    else if "`unit'"=="st" local g=`number'*6.350293180*1000
	else if "`unit'"=="tnl" local g=`number'*1016.0469088*1000
	else if "`unit'"=="tnsh" local g=`number'*907.18474*1000
	else if "`unit'"=="gr" local g=`number'*0.064798910
		
		
	local kg = `g'/1000
	local oz = `g'/28.349523125
	local lb = `g'/453.592370
	local st = `g'/(6.350293180*1000)
	local tnl = `g'/(1016.0469088*1000)
	local tnsh = `g'/(907.18474*1000)
	local gr = `g'/(0.064798910)
		
	display ///
	  "{result}" %9.0g `g' "{txt}{c |}" ///
	  "{result}" %9.0g `kg' "{txt}{c |}" ///
	  "{result}" %9.0g `oz' "{txt}{c |}" ///
	  "{result}" %9.0g `lb' "{txt}{c |}" ///
	  "{result}" %9.0g `st' "{txt}{c |}" ///
	  "{result}" %9.0g `tnl' "{txt}{c |}" ///
	  "{result}" %9.0g `tnsh' "{txt}{c |}" ///
	  "{result}" %9.0g `gr' "{txt}{c |}" ///

	return scalar g = `g'
	return scalar kg = `kg'
	return scalar oz = `oz'
	return scalar lb = `lb'
	return scalar st = `st'
	return scalar tnsh = `tnsh'
	return scalar tnl = `tnl'
	return scalar gr = `gr'
end
