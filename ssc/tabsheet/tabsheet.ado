*! 1.0.0 jmendelson 16oct2015
*  topline 3.0.0 (private version) jmendelson 16oct2013
*  topline 2.1.0 (private version) jmendelson 23jan2013
*  topline 2.0.1 (private version) jmendelson 5dec2012
*  topline 2.0.0 (private version) jmendelson 3aug2012
*  topline 1.0.0 (private version) jmendelson 7jul2012
program define tabsheet
	version 12.1
	syntax varlist (numeric) [if] [in], [SUBpops(varlist)] TYPE(string) [SIMPLE] [NOBREAK] [HEADER(string)] [SUPPress(string)] [OVERse] [LINEVAL(string)] [SORT]
	marksample touse, novarlist
	
	if("`subpops'"=="" & "`type'"!="h" & "`type'"!="header") {
		display _n "{error}Option subpops() required" as err
		error 198
	}

	if("`subpops'"!="") {
		foreach v of varlist `subpops' {
			tempvar tv
			qui: recode `v' (1=1) (0=1) (missing=1) (nonmissing=0) if(`touse'), gen(`tv')
			qui: capture assert `tv'==1 if(`touse')
			if(_rc!=0) {
				display _n "{error}Error! Subpop var `v' has nonmissing values other than 0 and 1." as err
				error 450
			}
		}
	}
	
	if("`header'"!="" & "`header'"!="varname" & "`header'"!="varlabel") {
		display _n "{error}Error! Invalid 'header' type. Valid options are header(varname) and header(varlabel)" as err
		error 198
	}
	
	qui: file query
	if(r(N)==0) {
		display _n "{error}Error!" _n "You need to open a file with the filehandle 'outfile' before running tabsheet." _n as err		//error displays if no files are open
		error 601
	}

	local suppstr "`suppress'"														//`suppstr' lists the suppressed values
	if("`suppstr'"!="") local suppstring "suppress((`suppstr'=.))"					//Creates a macro that can be dropped into recode statement
	
	if("`lineval'"=="") local linestring ""
	if("`lineval'"!="") local linestring "lineval(`lineval')"							//create a string that can be used to pass on the optional argument to subroutines

	if("`type'"=="header" | "`type'"=="h") local subpops "`varlist'"					//for type(header), use varlist as the list of subpops (so users don't have to enter it twice)
	if(("`type'"=="header" | "`type'"=="h") & "`header'"=="") local header "varname"	//by default, for type(header), use unlabeled varname
	
	if("`header'"!="") header `subpops', `simple' header(`header')						//If using a header flag, uses subpops; if type(header), then subpops will have been set to varlist
	if("`type'"=="prop" | "`type'"=="p") topfull `varlist' `if' `in', sub(`subpops') `simple' `suppstring' `overse'
	if("`type'"=="mean" | "`type'"=="m") topmean `varlist' `if' `in', sub(`subpops') `simple' `suppstring' `overse'
	if("`type'"=="line" | "`type'"=="l") tline`sort' `varlist' `if' `in', sub(`subpops') `simple' `suppstring' `overse' `linestring'

	if("`nobreak'"=="" & "`type'"!="prop" & "`type'"!="p") file write outfile _n		//by default, adds extra line at end (except for type(prop))
end

**Writes header line(s); two types: header(varname) or header(varlabel)
program define header
syntax varlist, HEADER(string) [SIMPLE] 
file write outfile _tab
foreach var of varlist `varlist' {
	local `var'varlabel: variable label `var'
	if(`"``var'varlabel'"'=="" | "`header'"=="varname") local `var'varlabel "`var'"
	file write outfile `"``var'varlabel'"' _tab
	if("`simple'"!="simple") file write outfile _tab _tab
}
file write outfile _n _tab
foreach var of varlist `varlist' {
	file write outfile "Value/%" _tab
	if("`simple'"!="simple") file write outfile "SE" _tab "n" _tab
}
file write outfile _n
end

**Outputs proportions for every value in a variable
program define topfull
syntax varlist [if] [in] [, SUBpops(varlist) SIMPLE SUPPress(string) OVERse]
marksample touse, novarlist
foreach var of varlist `varlist' {
	local `var'varlabel: variable label `var'
	if(`"``var'varlabel'"'=="") local `var'varlabel "`var'"									//If var not labeled, uses var name
	file write outfile `"``var'varlabel'"' _n												//Display var label on its own line

	tempvar vp`var'
	qui: clonevar `vp`var'' = `var'
	qui: if("`suppress'"!="") recode `vp`var'' `suppress'									//recodes any suppressed values to missing

	qui: levelsof `vp`var'' if(`touse'), local(levels)
	local `var'labels: value label `var'
	local counter = 0

	foreach l of local levels {
		capture local vlabel: label ``var'labels' `l'
		if (_rc!=0) local vlabel "`l'"														//If there is no value label, then simply use the number
		file write outfile `"`vlabel'"' _tab
		tempvar r`counter'_`var'
		qui: recode `vp`var'' (`l'=1) (missing=.) (nonmissing=0) if(`touse'), gen(`r`counter'_`var'')
		topprop `r`counter'_`var'' `if' `in', sub(`subpops') `simple' `overse'
		local counter = `counter'+1
	}

	if("`simple'"=="simple") {
		file write outfile "n"
		foreach spvar of varlist `subpops' {
			qui: count if(`vp`var''<. & `spvar'==1 & `touse')										//var<. means var is non-missing (since there are mult values for missing vals)
			file write outfile _tab (r(N))
		}
		file write outfile _n
	}

	file write outfile _n
}
end

**Outputs a line of stats for a binary variable
program define topprop
syntax varlist [if] [in] [, SUBpops(varlist) SIMPLE OVERse]
marksample touse, novarlist
foreach var of varlist `varlist' {
	tempname tempmat_b tempmat_ev temp_var temp_se count0 count1 countsum tempnmat tempn_over
	foreach spvar of varlist `subpops' {
		qui: count if(`var'==0 & `spvar'==1 & `touse')
		scalar `count0' = r(N)
		qui: count if(`var'==1 & `spvar'==1 & `touse')
		scalar `count1' = r(N)
		scalar `countsum' = `count0' + `count1'

		if(`countsum'==0) {
			file write outfile "n/a" _tab 
			if("`simple'"!="simple") file write outfile "n/a" _tab (`countsum') _tab
		}
		else if(`count0'==0 & `count1'!=0) {
			file write outfile ("100%") _tab
			if("`simple'"!="simple") file write outfile "n/a" _tab (`countsum') _tab
		}
		else if(`count0'!=0 & `count1'==0) {
			file write outfile ("0%") _tab 
			if("`simple'"!="simple") file write outfile "n/a" _tab (`countsum') _tab
		}
		else if(`count0'!=0 & `count1'!=0) {
			if("`overse'"=="") {
				qui: svy linearized: proportion `var' if(`touse'), subpop(`spvar')
				matrix `tempmat_b' = e(b)
				file write outfile (`tempmat_b'[1,2]*100) "%" _tab 
				if("`simple'"!="simple") {
					matrix `tempmat_ev' = e(V)
					scalar `temp_var' = `tempmat_ev'[2,2]
					scalar `temp_se' = `temp_var'^.5
					file write outfile (`temp_se') _tab (e(N_sub)) _tab
				}
			}
			else if("`overse'"=="overse") {
				qui: svy linearized: proportion `var' if(`touse'), over(`spvar')
				matrix `tempmat_b' = e(b)
				file write outfile (`tempmat_b'[1,e(N_over)*2]*100) "%" _tab				//will be in [1,2] or [1,4] depending on whether everyone is in same category or not
				if("`simple'"!="simple") {
					matrix `tempmat_ev' = e(V)
					scalar `temp_var' = `tempmat_ev'[e(N_over)*2,e(N_over)*2]				//will be in [2,2] or [4,4]
					scalar `temp_se' = `temp_var'^.5
					matrix `tempnmat' = e(_N)
					scalar `tempn_over' = `tempnmat'[1,e(N_over)*2]
					file write outfile (`temp_se') _tab (`tempn_over') _tab
				}
			}
		}
	}
	
	file write outfile _n
}
end

**Outputs a line of stats for a binary variable, and also writes the var name
program define tline
syntax varlist [if] [in] [, SUBpops(varlist) SIMPLE SUPPress(string) OVERse LINEVAL(string)]
marksample touse, novarlist

if("`lineval'"!="") file write outfile "% providing the following options: `lineval'" _n

foreach var of varlist `varlist' {
	local `var'varlabel: variable label `var'
	if(`"``var'varlabel'"'=="") local `var'varlabel "`var'"									//If var not labeled, uses var name
	file write outfile `"``var'varlabel'"' _tab
	tempvar bin_`var'
	qui: if("`lineval'"=="") recode `var' `suppress' (1=1) (missing=.) (nonmissing=0) if(`touse'), gen(`bin_`var'')
	qui: if("`lineval'"!="") recode `var' `suppress' (`lineval'=1) (missing=.) (nonmissing=0) if(`touse'), gen(`bin_`var'')
	topprop `bin_`var'' `if' `in', sub(`subpops') `simple' `overse'
	qui: inspect `var' if(`touse')
	if("`lineval'"=="" & r(N_unique)>2) dis "{error}Warning: `var' has more than two unique nonmissing values; please confirm that output is as intended."
}
end

**Determines the ordering for the proportion for the first subpopulation, and then runs the line command on the reordered list
program define tlinesort
syntax varlist [if] [in] , SUBpops(varlist) [SIMPLE SUPPress(string) OVERse LINEVAL(string)]
marksample touse, novarlist

tempname propitem count0 count1 countsum tempmat propstorage vartoadd

tokenize `subpops'
local firstsp `1'																		//We will be sorting only for cases in the first subpopulation

qui: describe `varlist', varlist
local vlist_expanded `r(varlist)'														//Expand any varlists that use wildcards
local sizeof_vlist: word count `vlist_expanded'

matrix `propstorage' = J(`sizeof_vlist',2,.)											//Initialize a matrix for storing %'s

tokenize `vlist_expanded'

forval i=1/`sizeof_vlist' {
	tempvar myvar

	qui: if("`lineval'"=="") recode ``i'' `suppress' (1=1) (missing=.) (nonmissing=0) if(`touse' & `firstsp'==1), gen(`myvar')
	qui: if("`lineval'"!="") recode ``i'' `suppress' (`lineval'=1) (missing=.) (nonmissing=0) if(`touse' & `firstsp'==1), gen(`myvar')
	
	scalar `propitem' = "n/a"						//This line is probably unnecessary and could conceivably cause an error if something else is incorrect, but doesn't do any harm and this potentially calls attention to any issues
	qui: count if `myvar'==0
	scalar `count0' = r(N)
	qui: count if `myvar'==1
	scalar `count1' = r(N)
	scalar `countsum' = `count0' + `count1'
	if(`countsum'==0) scalar `propitem' = 0			//Technically it might be better to add something to deal with items like this, but that complicates things and the user should know better; maybe address later
	if(`count0'==0 & `count1'!=0) scalar `propitem' = 1
	if(`count0'!=0 & `count1'==0) scalar `propitem' = 0
	if(`count0'>0 & `count1'>0) {
		qui: svy linearized: proportion `myvar'
		matrix `tempmat' = e(b)
		scalar `propitem' = `tempmat'[1,2]
	}
	
	matrix `propstorage'[`i',1] = -`propitem'		//Put in the negative proportion since Mata sort is ascending
	matrix `propstorage'[`i',2] = `i'
}

mata: st_matrix("`propstorage'", sort(st_matrix("`propstorage'"), 1))		//Sort the matrix by %

local reorderedvlist ""
tokenize `vlist_expanded'
forval i=1/`sizeof_vlist' {
	local reorderedvlist "`reorderedvlist' ``=`propstorage'[`i',2]''"
}

if("`lineval'"=="") local linestring ""
if("`lineval'"!="") local linestring "lineval(`lineval')"

if("`suppress'"!="") local suppstring "supp(`suppress')"

tline `reorderedvlist' `if' `in', sub(`subpops') `simple' `suppstring' `overse' `linestring'			//Run tline on the reordered variable list
end

**Outputs a line of means
program define topmean
syntax varlist [if] [in] [, SUBpops(varlist) SIMPLE SUPPress(string) OVERse]
marksample touse, novarlist
foreach var of varlist `varlist' {
	tempname countObs tempmat_e tempmat_ev temp_var temp_se temp_b temp_nmat temp_n

	tempvar vp`var'
	qui: clonevar `vp`var'' = `var'
	qui: if("`suppress'"!="") recode `vp`var'' `suppress'									//recodes any suppressed values to missing

	local `var'varlabel: variable label `var'
	if(`"``var'varlabel'"'=="") local `var'varlabel "`var'"									//If var not labeled, uses var name
	file write outfile `"Mean of ``var'varlabel'"' _tab
	foreach spvar of varlist `subpops' {
		qui: count if(`vp`var''<. & `spvar'==1 & `touse')
		scalar `countObs' = r(N)
		if(`countObs'==0) {
			file write outfile "n/a" _tab
			if("`simple'"!="simple") file write outfile "n/a" _tab "0" _tab
		}
		else if(`countObs'>0) {
			if("`overse'"=="") {
				qui: svy linearized: mean `vp`var'' if(`touse'), subpop(`spvar')
				matrix `tempmat_e' = e(b)
	
				file write outfile (`tempmat_e'[1,1]) _tab
				if("`simple'"!="simple") {
					matrix `tempmat_ev' = e(V)
					scalar `temp_var' = `tempmat_ev'[1,1]
					scalar `temp_se' = `temp_var'^.5
					if(`countObs'==1) scalar `temp_se' = "n/a"									//If n=1, there is no standard error
					file write outfile (`temp_se') _tab (e(N_sub)) _tab
				}
			}
			else if("`overse'"=="overse") {
				qui: svy linearized: mean `vp`var'' if(`touse'), over(`spvar')
				matrix `tempmat_e' = e(b)
				scalar `temp_b' = `tempmat_e'[1,e(N_over)]
				
				file write outfile (`temp_b') _tab
				if("`simple'"!="simple") {
					matrix `tempmat_ev' = e(V)
					matrix `temp_nmat' = e(_N)
					scalar `temp_n' = `temp_nmat'[1,e(N_over)]
					scalar `temp_var' = `tempmat_ev'[e(N_over),e(N_over)]
					scalar `temp_se' = `temp_var'^.5
					if(`countObs'==1) scalar `temp_se' = "n/a"									//If n=1, there is no standard error
					file write outfile (`temp_se') _tab (`temp_n') _tab
				}
			}	
		}
	}
	file write outfile _n
}
end
