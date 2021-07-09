*1.2 GHR Sept 16, 2009
capture program drop stata2pajek
program define stata2pajek
	version 10
	set more off
	syntax varlist(min=2 max=2) [ , tiestrength(string asis) filename(string asis) EDGEs]

	tempfile dataset
	quietly save `dataset'
	
	gettoken ego alter : varlist
	
	local starchar="*"
	if "`filename'"=="" {
		local pajeknetfile "mypajekfile"
	}
	else {
		local pajeknetfile "`filename'"
	}
	capture file close pajeknetfile
	file open pajeknetfile using `pajeknetfile'.net, write text replace
	use `dataset', clear
	drop `ego'
	ren `alter' `ego'
	append using `dataset'
	keep `ego'
	contract `ego'
	ren `ego' verticelabel
	drop _freq
	sort verticelabel
	gen number=[_n]
	order number verticelabel
	tempfile verticelabels
	quietly save `verticelabels', replace
	local nvertices=[_N]
	file write pajeknetfile "`starchar'Vertices `nvertices'" _n
	forvalues x=1/`nvertices' {
		local c2=verticelabel in `x'
		file write pajeknetfile `"`x' "`c2'""' _n
	}
	use `dataset', clear
	ren `ego' verticelabel
	sort verticelabel
	quietly merge verticelabel using `verticelabels'
	quietly keep if _merge==3
	drop _merge verticelabel
	ren number `ego'
	ren `alter' verticelabel
	sort verticelabel
	quietly merge verticelabel using `verticelabels'
	quietly keep if _merge==3
	drop _merge verticelabel
	ren number `alter'
	order `ego' `alter' `tiestrength'
	keep  `ego' `alter' `tiestrength'
	local narcs=[_N]
	if "`edges'"=="edges" {
		file write pajeknetfile `"`starchar'Edges"' _n
	}
	else {
		file write pajeknetfile `"`starchar'Arcs"' _n
	}
	sort `ego' `alter'	
	if "`tiestrength'"~="" {
		forvalues x=1/`narcs' {
			local c1=`ego' in `x'
			local c2=`alter' in `x'
			local c3=`tiestrength' in `x'			
			file write pajeknetfile "`c1' `c2' `c3'" _n
		}
	}
	else {
		forvalues x=1/`narcs' {
			local c1=`ego' in `x'
			local c2=`alter' in `x'
			file write pajeknetfile "`c1' `c2'" _n
		}	
	}
	file close pajeknetfile
	*ensure that it's windows (CRLF) text format
	if "$S_OS"~="Windows" {
		filefilter `pajeknetfile'.net tmp, from(\M) to(\W) replace
		shell mv tmp `pajeknetfile'.net
		filefilter `pajeknetfile'.net tmp, from(\U) to(\W) replace
		shell mv tmp `pajeknetfile'.net
	}
	use `dataset', clear
	disp "Your output is saved as"
	disp "`c(pwd)'`c(dirsep)'`pajeknetfile'.net"
end


