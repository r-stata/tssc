*! chewfile version 1.0.1 17Aug2009 by roywada@hotmail.com
*! quick and easy way to chew and digest excessive large ASCII file

program define chewfile
version 8.0

syntax using/, [save(string) begin(numlist max=1) end(string) clear parse(string) replace semiclear]

if `"`parse'"'=="" {
	local parse `"`=char(9)'"'
}

if "`begin'"=="" {
	local begin 1
}

if "`end'"=="" {
	local end .
}

if "`clear'"=="" & `"`save'"'=="" {
	if "`semiclear'"=="" {
		noi di in red "must specify {opt clear} or {opt save( )}
		exit 198
	}
}

if "`semiclear'"=="semiclear" {
	qui drop *
	qui set obs 0
}
else if "`clear'"=="clear" {
	clear
	qui set obs 0
}

if `"`save'"'=="" {
	tempfile dump
	local save `dump'
}

tempname fh outout
local linenum = 0
file open `fh' using `"`using'"', read

qui file open `outout' using `"`save'"', write `replace'

file read `fh' line

while r(eof)==0 {
	local linenum = `linenum' + 1
	local addedRow 0
	if `linenum'>=`begin' & `linenum'<=`end' {
		if `addedRow'==0 {
			qui set obs `=`=_N'+1'
		}
		
		*display %4.0f `linenum' _asis `"`macval(line)'"'
		file write `outout' `"`macval(line)'"' _n
		
		if "`clear'"=="clear" | "`semiclear'"=="semiclear" {
			tokenize `"`macval(line)'"', parse(`"`parse'"')
			local num 1
			local colnum 1
			while "``num''"~="" {
				local needOneMore 0
				if `"``num''"'~=`"`parse'"' {
					cap gen str3 var`colnum'=""
					cap replace var`colnum'="``num''" in `linenum'
					if _rc~=0 {
						qui set obs `=`=_N'+1'
						cap replace var`colnum'="``num''" in `linenum'
						local addedRow 1
					}
					*local colnum=`colnum'+1
				}
				else {
					cap gen str3 var`colnum'=""
					local colnum=`colnum'+1
				}
				local num=`num'+1
			}
		}
	}
	file read `fh' line
}

file close `fh'
file close `outout'
end
exit



* version 0.9 Aug2008 : selective partitioning of file
* version 0.9.1 20May2009 : added str import function
* version 0.9.2 20May2009 : fixed the empty cells
* version 1.0.0 20May2009 : changed option names, tightened the codes, debugged, etc., for ssc
version 1.0.1 18Aug2009	: fixed tab parsing
					semiclear option


