*! version 1.0.0 Januar 6, 2011 @ 16:01:28 UK
*! g to ounce conversion


// Main Program
// ------------

// This pares user input into pieces for converter
program msq2ftsq, rclass
version 11.1
	syntax [anything] [, Unit(string) ]
	if "`anything'" == "" local anything 1msq
	if "`unit'" == "" local unit msq

	display _n "{txt}" ///
	  "{ralign 9: m^2}{c |}" ///
	  "{ralign 9: Ar}{c |}" ///
	  "{ralign 9: Hektar}{c |}" ///
	  "{ralign 9: km^2}{c |}" ///
	  "{ralign 9: feet^2}{c |}" ///
	  "{ralign 9: yard^2}{c |}" ///
	  "{ralign 9: acre}{c |}" ///
	  "{ralign 9: mile^2}{c |}"	_n ///
	  "{hline 9}{c +}{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c +}{hline 9}{c RT}" 
	  
	local result 1
	foreach piece of local anything {
		macro drop _format

		// Number without unit -> msq implied
		capture confirm number `piece'
		if !_rc local format "`piece'`unit'"

		// Number with unit -> use asis
		local check = regexm("`piece'","([0-9.]+)([A-Za-z]+)")
		if `check' local format "`piece'"

		// Call converter
		foreach part of local format {
			conversion `part'
			foreach res in msq a ha kmsq ftsq acre misq {
				return scalar `res'`result' = r(`res')
				}
			local result = `result' + 1
			}
		}
end
	
program conversion, rclass
	args format
	local u = regexm("`format'","[a-z]+")
	local unit = regexs(0)
	local number = subinstr("`format'","`unit'","",.)

	local known msq a ha kmsq ftsq ydsq acre misq
	if !`: list posof "`unit'" in known' {
		di as error "unit `unit' invalid
		exit 198
	}
	
	if "`unit'"=="msq" local msq `number'
	else if "`unit'"=="a" local msq=`number'*100
	else if "`unit'"=="ha" local msq=`number'*10000
	else if "`unit'"=="kmsq" local msq=`number'*1000000
	else if "`unit'"=="ftsq" local msq=`number'*0.09290304
	else if "`unit'"=="ydsq" local msq=`number'*0.83612736
 	else if "`unit'"=="acre" local msq=`number'*40.468564224*100
	else if "`unit'"=="misq" local msq=`number'*25899.88110336*100

	local a = `msq'/100
	local ha = `msq'/10000
	local kmsq = `msq'/1000000
	local ftsq = `msq'/0.09290304
	local ydsq = `msq'/0.83612736
	local acre = `msq'/(40.468564224*100)
	local misq = `msq'/(25899.88110336*100)
		
	display ///
	  "{result}" %9.0g `msq' "{txt}{c |}" ///
	  "{result}" %9.0g `a' "{txt}{c |}" ///
	  "{result}" %9.0g `ha' "{txt}{c |}" ///
	  "{result}" %9.0g `kmsq' "{txt}{c |}" ///
	  "{result}" %9.0g `ftsq' "{txt}{c |}" ///
	  "{result}" %9.0g `ydsq' "{txt}{c |}" ///
 	  "{result}" %9.0g `acre' "{txt}{c |}" ///
 	  "{result}" %9.0g `misq' "{txt}{c |}" 

	return scalar msq = `msq'
	return scalar a = `a'
	return scalar ha = `ha'
	return scalar kmsq = `kmsq'
	return scalar ftsq = `ftsq'
	return scalar ydsq = `ydsq'
	return scalar acre = `acre'
	return scalar misq = `misq'
end
