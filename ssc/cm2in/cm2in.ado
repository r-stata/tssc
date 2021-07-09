*! version 1.0.0 Januar 6, 2011 @ 15:39:34 UK
*! cm to inch conversion


// Main Program
// ------------

// This pares user input into pieces for converter
program define cm2in, rclass
version 11.1
	syntax [anything] [, Unit(string) ]
	if "`anything'" == "" local anything 1cm
	if "`unit'" == "" local unit cm

	display _n "{txt}" ///
	  "{ralign 9: cm}{c |}" ///
	  "{ralign 9: m}{c |}" ///
	  "{ralign 9: inch}{c |}" ///
	  "{ralign 9: feet}{c |}" ///
	  "{ralign 9: yard}{c |}" ///
	  "{ralign 9: chain}{c |}" ///
	  "{ralign 9: mile}{c |}" ///
	  "{ralign 9: pt}{c |}" ///
	  "{ralign 9: pica}{c |}" _n ///
	  "{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c +}{hline 9}{c +}" ///
	  "{hline 9}{c +}{hline 9}{c RT}" 
	  
	local result 1
	foreach piece of local anything {
		macro drop _format

		// Number without unit -> cm implied
		capture confirm number `piece'
		if !_rc local format "`piece'`unit'"

		// Number with unit -> use asis
		local check = regexm("`piece'","([0-9.]+)([A-za-z]+)")
		if `check' local format "`piece'"

		// Paper and other formats
		if "`format'" == "" {
			
			// American paper formats
			if "`piece'" == "letter" local format 11in 8.5in
			else if "`piece'" == "legal" local format 14in 8.5in 
			else if "`piece'" == "executive" local format 10.5in 7.25in 
			else if "`piece'" == "invoice" local format 8.5in 5.5in
			else if "`piece'" == "tabloid" local format 17in 11in
			else if "`piece'" == "ledger" local format 17in 11in
			else if "`piece'" == "broadsheet" local format 22in 17in

			// Stata Graph format
			else if "`piece'" == "Graph" {
				if "`.Graph._scheme.graphsize.x'" == "" {
					tw function y=1, nodraw
				}
				local x  `.Graph._scheme.graphsize.x'
				local y  `.Graph._scheme.graphsize.y'
				if `"`x'"' == `""' {
					di as error "graph size not found"
					exit 198
				}
				local format `x'in `y'in
			}

			// German Paper formats
			else {
				local series `"`=upper(`"`=substr(`"`piece'"',1,1)'"')'"'
				if "`series'" == "A" local format 1189 841
				else if "`series'" == "B" local format 1414 1000
				else if "`series'" == "C" local format 1297 917
				else if "`series'" == "D" local format 1091 771

				local y: word 1 of `format'
				local x: word 2 of `format'

				if `=substr(`"`piece'"',2,.)' > 10 {
					di as error "Format `piece' not exist"
					exit 198
				}
					
				local i 0
				while `"`i'"' != `"`=substr(`"`piece'"',2,.)'"'  {
					local nx = `y'/2
					local ny = `x'
					local x = `nx'
					local y = `ny'
					local i = `i'+1
				}
				local format `=floor(`y')/10'cm `=floor(`x')/10'cm
			}

		}

		// Call converter
		foreach part of local format {
			conversion `part'
			foreach res in cm m in ft yd ch sm pt pica {
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

	local known cm m in ft yd ch mi pt pica
	if !`: list posof "`unit'" in known' {
		di as error "unit `unit' invalid
		exit 198
	}
	
	if "`unit'"=="cm" local cm `number'
	else if "`unit'"=="m" local cm=`number'*100
	else if "`unit'"=="in" local cm=`number'*2.54
	else if "`unit'"=="ft" local cm=`number'*2.54*12
	else if "`unit'"=="yd" local cm=`number'*2.54*12*3
	else if "`unit'"=="ch" local cm=`number'*2.54*12*3*22
	else if "`unit'"=="mi" local cm=`number'*2.54*12*3*1760
	else if "`unit'"=="pt" local cm=`number'/72 *2.54
	else if "`unit'"=="pica" local cm=`number'*(12/72) * 2.54

	local m = `cm'/100
	local inch = `cm'/2.54
	local feet = `inch'/12
	local yard = `feet'/3
	local chain = `yard'/22
	local mile = `yard'/1760
	local pt = `inch'*72
	local pica = `pt'/12
		
	display ///
	  "{result}" %9.0g `cm' "{txt}{c |}" ///
	  "{result}" %9.0g `m' "{txt}{c |}" ///
	  "{result}" %9.0g `inch' "{txt}{c |}" ///
	  "{result}" %9.0g `feet' "{txt}{c |}" ///
	  "{result}" %9.0g `yard' "{txt}{c |}" ///
	  "{result}" %9.0g `chain' "{txt}{c |}" ///
	  "{result}" %9.0g `mile' "{txt}{c |}" ///
	  "{result}" %9.0g `pt' "{txt}{c |}" ///
	  "{result}" %9.0g `pica' "{txt}{c |}" ///

	return scalar cm = `cm'
	return scalar m = `m'
	return scalar in = `inch'
	return scalar ft = `feet'
	return scalar yd = `yard'
	return scalar ch = `chain'
	return scalar sm = `mile'
	return scalar pt = `pt'
	return scalar pica = `pica'
end
