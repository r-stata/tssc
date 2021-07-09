*! nbercycles 1.0.5 20sep2010 CFBaum 
*  1.0.1 revise syntax for max=1, minval/maxval
*  1.0.2 require from and to if varname not provided
*  1.0.3 error trap above should ref varlist
*  1.0.4 add current recession, logic to handle
*  1.0.5 add end of 2007-2009 recession

program define nbercycles, rclass
	version 9.2
	syntax [varlist(max=1 default=none)] [if], FILE(string) [FROM(string) TO(string) MINval(real 0) MAXval(real 1) REPLACE ]

	marksample touse
	local tsl 0
* get the current tsset settings and check for M, Q
	qui tsset
	local tv  `r(timevar)'
	local tu  `r(unit1)'
	local tsf `r(tsfmt)'
	tempvar junk1 junk2 range
	tempname nber tminn tmaxx hh
	
	if "`tu'" != "q" & "`tu'" != "m" {
		di as err "Error: nbercycles only defined for monthly, quarterly frequencies."
		error 198
	}
* if varname not provided, from and to must be supplied
	if "`varlist'" == "" & "`from'" == "" & "`to'" == "" { 
		di as err "Error: without a varname, from() and to() must be provided."
		error 198
	}
* if from and to not provided, use current tsset limits (should honor [if])
	if "`from'" == "" & "`to'" == "" {
		local from `r(tmins)'
		local to `r(tmaxs)'
		local tmin `r(tmin)'
		local tmax `r(tmax)'
		local u2min `tu'
	}
	else {
* validate the from and to entries if given
		qui tsmktim `junk1', start(`from')
		scalar `tminn' = `r(tmin)'
		local u1min `r(unit1)'
		qui tsmktim `junk2', start(`to')
		scalar `tmaxx' = `r(tmin)'
		local u2min `r(unit1)'
		if "`u1min'" != "`u2min'" {
			di as err "Error: both from() and to() must refer to same frequency."
* restore orginal tsset
			qui tsset `tv'
			error 198
		}
	}
* check the variable if provided, and get its limits
	if "`varlist'" != "" {
		summ `varlist' if `touse', meanonly
		local minval = 0.99 * `r(min)'
		local maxval = 1.01 * `r(max)'
* 		local minval = floor(`r(min)')
*		local maxval = ceil(`r(max)')
		summ `tv' if `touse', meanonly
		scalar `tminn' = `r(min)'
		scalar `tmaxx' = `r(max)'
		local tsl 1
	}
* generate the selected range of peaks and troughs
// add recession starting in dec2007
// DISABLE assuming it is still ongoing, get current month, quarter using 9.2 syntax for date()
//    loc cdt "`c(current_date)'"
//    loc qqqq = qofd(date("`cdt'", "dmy"))
//    loc mmmm = mofd(date("`cdt'", "dmy"))  
	if "`u2min'" == "m" {
	    mat nber = ( -1231,-1213 \ -1191,-1183 \ -1137,-1105 \ -1087,-1069 \ -1035,-970 \ -934,-896 \ -874,-861 \ -834,-824 \ -804,-787 \ -769,-751 \ -727,-709 \ -688,-665 \ -632,-619 \ -600,-576 \ -564,-541 \ -497,-490 \ -480,-462 \ -440,-426 \ -399,-386 \ -366,-322 \ -272,-259 \ -179,-171 \ -134,-123 \ -78,-68 \ -29,-21 \ 3,13 \ 119,130 \ 166,182 \ 240,246 \ 258,274 \ 366,374 \ 494,502 \ 575,593)
	}
	else {
		mat nber = ( -411,-405 \ -397,-395 \ -379,-369 \ -363,-357 \ -345,-324 \ -312,-299 \ -292,-287 \ -278,-275 \ -268,-263 \ -257,-251 \ -243,-237 \ -230,-222 \ -211,-207 \ -200,-192 \ -188,-181 \ -166,-164 \ -160,-154 \ -147,-142 \ -133,-129 \ -122,-108 \ -91,-87 \ -60,-57 \ -45,-41 \ -26,-23 \ -10,-7 \ 1,4 \ 39,43 \ 55,60 \ 80,82 \ 86,91 \ 122,124 \ 164,167 \ 191,197)
	}
	svmat long nber, names(`nber')
//	l `nber'1 `nber'2 if `nber'1 < .	
//	di as err "`from' `to'"
	qui {
//		replace `nber'1 = . if `nber'1 < `tminn' | `nber'1 > `tmaxx'
//		replace `nber'2 = . if `nber'2 < `tminn' | `nber'2 > `tmaxx'
// 1.0.4: pick up boundaries
		replace `nber'1 = . if  `nber'1 > `tmaxx'
		replace `nber'2 = . if  `nber'2 < `tminn'
		gen byte `range' = (`nber'1 < . & `nber'2 < .) * _n
		replace `range' = . if `range' == 0
	}
	sum `range', meanonly
	if `r(N)' == 0 {
		di as err "Error: no recessions during `from' - `to'"
* restore orginal tsset
		qui tsset `tv'
		error 198
	}
	local fcycle `r(min)'
	local lcycle `r(max)'
	local ncycle = `lcycle'-`fcycle'+1
	local nc1 = `ncycle'+1

	file open `hh' using `file', write `replace' 
	file write `hh' "* append your graph command to this file: e.g." _n
	file write `hh' "* tsline timeseriesvar, xlabel(,format(`tsf')) legend(order(`nc1' 1 " _char(34) "Recession" _char(34) "))" _n
	file write `hh' "twoway "
	forv i=`fcycle'/`lcycle' {
		local fv = `nber'1 in `i'
		local lv = `nber'2 in `i'
		file write `hh' "function y=`maxval',range(`fv' `lv') recast(area) color(gs12) base(`minval') || /// " _n
	}
* if `varlist' provided, write that command and do the graph
		if "`varlist'" != "" {
			file write `hh' "tsline `varlist' `if', xlabel(,format(`tsf')) legend(order(`nc1' 1 " _char(34) "Recession" _char(34) ")) " _n
*		file write `hh' xscale(range(" (`tminn') " " (`tmaxx') "))" _n
		}
	file close `hh'
* restore orginal tsset
	qui tsset `tv'
//	di _n "Code to graph NBER recession dates for `from' - `to' written to `file'" _n
	di _n "Code to graph NBER recession dates written to `file'" _n

	if `tsl' {
		do `file'
	}
	end
	
