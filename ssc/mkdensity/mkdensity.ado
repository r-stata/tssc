*! mkdensity 1.02 Szabolcs Lorincz 22Aug2016
* plots kernel densities of several variables (wrapper of the kdensity command)
* author Szabolcs Lorincz
* version history
* version 1.0	14Apr2016
* version 1.02	22Aug2016	fixed: bandwidth scalar (bwidth) saved properly in r() and put on plotted graph

capture program drop mkdensity

program mkdensity, rclass sortpreserve

	* Version of Stata to use for interpreting the command(s)
	version 8.0, missing

	* Syntax used to call program
 	syntax varlist [if] [in] [aweight fweight iweight] ,/*
			kdensity options
		*/	[Kernel(passthru)] [Bwidth(passthru)] [N(passthru)] [NOGRaph]	/*
		*/	[Generate(namelist)]	/*
			line options
		*/	[TItle(string)] [XLINE(numlist)] [SAVE(string)]	/*
			group options
		*/	[Over(varname)] [BY(varname)] [YCOMmon] [XCOMmon] [Rows(passthru)] [Cols(passthru)]

	* sample marker
	marksample touse

	* collecting inputs
	local nvars=wordcount("`varlist'")
	if ("`xline'"!="") {
		local xline_option xline(`xline')
	}
	if ("`title'"!="") {
		if ("`by'"=="") {
			if (`nvars'==1) {
				local title_option title("`title'") xtitle("`varlist'") 
			}
			if (`nvars'>1) {
				local title_option title("`title'") xtitle("") 
			}
		}
		if ("`by'"!="") {
			local title_option title("`title'")
		}
	}
	if ("`title'"=="") {
		if ("`by'"=="") {
			if (`nvars'==1) {
				local title_option title("Kernel density estimate") xtitle("`varlist'") 
			}
			if (`nvars'>1) {
				local title_option title("Kernel density estimates") xtitle("") 
			}
		}
		if ("`by'"!="") {
			local title_option title("Kernel density estimate")
		}
	}
	if ("`generate'"!="") {
		local xname=word("`generate'",1)
		local dname=word("`generate'",2)
	}
	local wtexp
	if ("`weight'"!="") {
		local wtexp "[`weight'`exp']"
	}
	local olevels "1"
	if ("`over'"!="") {
		tempvar _over
		local overtype: type `over'
		if (substr("`overtype'",1,3)=="str") {
			quietly generate `_over'=`over'
		}
		if (substr("`overtype'",1,3)!="str") {
			quietly capture decode `over', generate(`_over')
			if (_rc!=0) {
				quietly capture tostring `over', generate(`_over') force usedisplayformat
			}
		}
		quietly levelsof `_over' if `touse'
		local olevels "`r(levels)'"
	}
	local blevels "1"
	if ("`by'"!="") {
		tempvar _by
		local bytype: type `by'
		if (substr("`bytype'",1,3)=="str") {
			quietly generate `_by'=`by'
		}
		if (substr("`bytype'",1,3)!="str") {
			quietly capture decode `by', generate(`_by')
			if (_rc!=0) {
				quietly capture tostring `by', generate(`_by') force usedisplayformat
			}
		}
		quietly levelsof `_by' if `touse'
		local blevels "`r(levels)'"
	}

	* calculating individual densities and storing/saving them
	local b=0
	if ("`by'"=="") {
		local b
	}
	foreach blevel in `blevels' {
		if ("`by'"!="") {
			local b=`b'+1
		}
		local lines`b'
		local blabel0
		local blabel
		local o=0
		if ("`over'"=="") {
			local o
		}
		foreach olevel in `olevels' {
			if ("`over'"!="") {
				local o=`o'+1
			}
			local olabel0
			local olabel
			foreach v of varlist `varlist' {
				if ("`by'"!="") {
					local blabel0 "`blevel'"
					local blabel ", `by'==`blevel'"
					local bsample & `_by'=="`blevel'"
				}
				if ("`over'"!="") {
					local olabel0 "`olevel'"
					local olabel ", `over'==`olevel'"
					local osample & `_over'=="`olevel'"
				}
				tempvar _x_`v'`b'`o' _d_`v'`b'`o'
				kdensity `v' if `touse' `bsample' `osample' `wtexp', generate(`_x_`v'`b'`o'' `_d_`v'`b'`o'') nograph `n' `kernel' `bwidth'
				capture label variable `_d_`v'`b'`o'' "`v' `olabel0'"
				local lines`b' `lines`b'' (line `_d_`v'`b'`o'' `_x_`v'`b'`o'')
				if ("`generate'"!="") {
					capture drop `dname'`v'`b'`o'
					quietly capture generate `dname'`v'`b'`o'=`_d_`v'`b'`o''
					capture label variable `dname'`v'`b'`o' "density: `v'`blabel'`olabel'"
					capture drop `xname'`v'`b'`o'
					quietly capture generate `xname'`v'`b'`o'=`_x_`v'`b'`o''
					capture label variable `xname'`v'`b'`o' "`v'`blabel'`olabel'"
				}
			}
		}
	}

	* infos to be added to r()
	local bwidth=r(width)
	if (strpos("`bwidth'",".")!=0) {
		local bwidth=substr("`bwidth'",1,strpos("`bwidth'",".")-1)+"."+substr("`bwidth'",strpos("`bwidth'",".")+1,4)
	}
	local kernel="`r(kernel)'"
	local note "kernel=`kernel', bandwidth=`bwidth'"

	* storing results in r()
	return scalar n = r(n)
	return scalar scale = r(scale)
	return scalar bwidth = r(width)
	return local kernel = "`r(kernel)'"

	* plotting/saving combined graph of densities
	if ("`nograph'"=="") {
		if ("`by'"=="") {
			twoway `lines', ytitle("density") note("`note'") `title_option' `xline_option'
		}
		if ("`by'"!="") {
			local bgraphs
			local b=0
			foreach blevel in `blevels' {
				local b=`b'+1
				quietly twoway `lines`b'', legend(size(small)) ytitle("density", size(small)) title("`blevel'") `xline_option' name(graph_`b') nodraw
				local bgraphs `bgraphs' graph_`b'
			}
			graph combine `bgraphs', `ycommon' `xcommon' `rows' `cols' note("`note'") `title_option'
			graph drop `bgraphs'
		}
		if ("`save'"!="") {
			quietly graph export "`save'.png", width(1100) height(825) replace
		}
	}

end
