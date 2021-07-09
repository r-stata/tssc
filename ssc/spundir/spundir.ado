* Creates undirected dyad contagion spatial effect variable from a dyadic dataset
* 6.0 Eric Neumayer and Thomas Plümper 22may2013

* Change to version 5.0: replaced user-written mmerge.ado commands with Stata's official merge command
* Change to version 4.1: fixed bug that affected row-standardization and spatial effect with additive link functions

program spundir, sortpreserve

version 11.2

syntax varlist(min=1 max=1)[if][in], link(string) Weightvar(name) i(name) j(name) ///
		[time(name) REVerse_W EXCLusive ///
		noMerge noRowst SEname(name) FILEname(name) LABELname(name)]

if "`link'"=="" {
	di as err "User must specify a link function."
	exit 198
}
if "`link'"!="ik" & "`link'"!="ki" & "`link'"!="jm" & "`link'"!="mj" & "`link'"!="ik+jm" & "`link'"!="ki+mj" & "`link'"!="ik*jm" & "`link'"!="ki*mj" {
	di as err "Link(`link') not allowed. See help file for allowed link options."
	exit 198
}

marksample touse, novarlist strok
tokenize `varlist'
local spatialvar "`1'"
capture confirm numeric "`spatialvar'"
capture confirm numeric "`weightvar'"
quietly su `weightvar'
local W_min=r(min)
if `W_min'<0 {
	di as err _newline "The weighting variable must not contain negative values."
	exit 601
}
local sourcetype : type `i'
local targettype : type `j'
capture confirm numeric "`time'"

di _newline "User has specified that:"
di _newline "   {bf}`spatialvar'{sf} is the variable to be spatially lagged."
if "`link'"=="ik" {
	di _newline "   {bf}`weightvar'{sf} will link unit {it}i{sf} to other units {it}k{sf}."
}
if "`link'"=="jm" {
	di _newline "   {bf}`weightvar'{sf} will link unit {it}j{sf} to other units {it}m{sf}."
}
if "`link'"=="ki" {
	di _newline "   {bf}`weightvar'{sf} will link other units {it}k{sf} to unit {it}i{sf}."
}
if "`link'"=="mj" {
	di _newline "   {bf}`weightvar'{sf} will link other units {it}m{sf} to unit {it}j{sf}."
}
if "`link'"=="ik+jm" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of unit {it}i{sf} to other units {it}k{sf} and link of unit {it}j{sf} to other units {it}m{sf}."
}
if "`link'"=="ki+mj" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of other units {it}k{sf} to unit {it}i{sf} and link of other units {it}m{sf} to unit {it}j{sf}."
}
if "`link'"=="ik*jm" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of unit {it}i{sf} to other units {it}k{sf} and link of unit {it}j{sf} to other units {it}m{sf}."
}
if "`link'"=="ki*mj" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of other units {it}k{sf} to unit {it}i{sf} and link of other units {it}m{sf} to unit {it}j{sf}."
}

di _newline "   {bf}`i'{sf} is the identifying variable of unit {it}i{sf}."
di _newline "   {bf}`j'{sf} is the identifying variable of unit {it}j{sf}."
if "`time'"=="" {
	di _newline "   the spatial effect variable is {bf}time-invariant{sf}."
}
else {
	di _newline "   {bf}`time'{sf} is the numeric time variable."
}
if "`exclusive'"=="exclusive" { 
	di _newline "   Dyads containing either unit {it}i{sf} or {it}j{sf} are {bf}excluded{sf} from having a spatial effect on dyad {it}ij{sf}."
}
if "`rowst'"=="norowst" { 
	di _newline "   the spatial effect is {bf}not{sf} to be {bf}row-standardized{sf}."
}
else {
	di _newline "   the spatial effect is to be {bf}row-standardized{sf}."
	local rowst "rowst"
}
di _newline "If these assumptions are incorrect, the generated spatial effect variable will be incorrect."

if "`merge'"=="nomerge" { 
	di _newline "User must {bf}merge{sf} the created spatial effect variable into the estimation dataset {bf}by hand{sf}."
	if "`filename'"=="" {
		di _newline "   Warning: file {bf}SE_file_undir_`rowst'{sf} will be replaced in current working directory, if already existant."
	}
	else {
		di _newline "   Warning: file {bf}`filename'{sf} will be replaced in current working directory, if already existant."
	}
}
else {
	di _newline "The created spatial effect variable will be {bf}automatically merged{sf} into the original dataset."
	if "`sename'"=="" {
		di _newline "   Warning: variable {bf}SE_var_undir_`rowst'{sf} will be dropped from dataset before merging, if already existant."
		capture drop SE_var_undir_`rowst'
	}
	else {
		di _newline "   Warning: variable {bf}`sename'{sf} will be dropped from dataset before merging, if already existant."
		capture drop `sename'
	}
	if "`filename'"!="" {
		di _newline "   Warning: file {bf}`filename'{sf} will be replaced in current working directory, if already existant."
	}
}

set more on
di _newline(2) "{bf}*** Check the above. ***{sf}  --  Press q to break, press any other button to continue."
more

preserve
quietly keep if `touse'

quietly {
	tempfile datasample holder addeddyads
	tempvar sourceidinf
	ge `sourceidinf'=.
	tempvar targetidinf
	ge `targetidinf'=.
	quietly compress
	save "`datasample'", replace
	capture drop _merge
	capture drop _fillin
	fillin `i' `j'
	collapse (sum) _fillin, by(`i')
	tempvar nonsymmetric
	su _fillin
	gen `nonsymmetric'=0 if r(max)==0
	if `nonsymmetric'==0 {
		use "`datasample'", replace
		keep `spatialvar' `weightvar' `sourceidinf' `targetidinf' `time' `i' `j' 
		save "`holder'", replace
		tempvar varholder
		ren `i' `varholder'
		ren `j' `i'
		ren `varholder' `j'
		keep `time' `i' `j' 
		save "`addeddyads'", replace
	}
	else {
		use "`datasample'", replace
		keep `spatialvar' `weightvar' `sourceidinf' `targetidinf' `time' `i' `j' 
		save "`holder'", replace
		tempvar varholder
		ren `i' `varholder'
		ren `j' `i'
		ren `varholder' `j'
		save "`addeddyads'", replace
	}
	use "`holder'", replace
	append using "`addeddyads'"
	capture drop _merge
	capture drop _fillin
	fillin `i' `j' `time'
	collapse `spatialvar' `weightvar' `sourceidinf' `targetidinf', by(`i' `j' `time')
	save "`holder'", replace
}


if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | "`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
	tempvar sourceid
	quietly egen `sourceid'=group(`i')
}
else {
	tempvar sourceid
	quietly encode `i', ge(`sourceid')
}
if "`targettype'"=="int" | "`targettype'"=="long" | "`targettype'"=="float" | "`targettype'"=="double"  | "`targettype'"=="byte" {
	tempvar targetid
	quietly egen `targetid'=group(`j')
}
else {
	tempvar targetid
	quietly encode `j', ge(`targetid')
}
quietly su `sourceid'
local source_max=r(max)
quietly su `targetid'
local target_max=r(max)
local target_min=r(min)
if `source_max'<2 & `target_max'<2 {
		di as err "Generation of spatial effect variable not possible with fewer than 2 units of i and 2 units of j."
		exit 198
}
else {
	di _newline "Generating spatial effect components for dyads involving `source_max' units of i in total - please wait."
}

quietly {
	tempfile spatialvarempty Wempty 
	tempvar sourceidinf
	ge `sourceidinf'=.
	tempvar targetidinf
	ge `targetidinf'=.
	quietly compress
	save "`datasample'", replace
	keep `spatialvar' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' `time' 
	save "`holder'", replace
	use "`holder'", replace
	keep if `sourceidinf'==0
	keep `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' `time' 
	save "`spatialvarempty'", replace
	use "`holder'", replace
	keep if `sourceidinf'==0
	keep `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' `time' 
	save "`Wempty'", replace
}

forvalues m = 1(1)`source_max' {
	if `m'/10==int(`m'/10) {
		di "."
	}
	else {
		di "." _continue
	}
	quietly {	
		use "`spatialvarempty'", replace
		tempfile spatialvarundirdyad_`m'
		save "`spatialvarundirdyad_`m''", replace
		use "`Wempty'", replace
		tempfile Wsource_`m'
		save "`Wsource_`m''", replace
		tempfile Wtarget_`m'
		save "`Wtarget_`m''", replace
		use "`holder'", replace
		replace `sourceidinf'=`m'
		save "`holder'", replace
	}
	forvalues n = 1(1)`target_max' {
		quietly {
			use "`holder'", replace
			replace `targetidinf'=`n'
			drop if `sourceid'>`targetid'
			if "`exclusive'"=="" {
				drop if  (`targetidinf'==`targetid' & `sourceidinf'==`sourceid')
				drop if  (`targetidinf'==`sourceid' & `sourceidinf'==`targetid')
			}
			if "`exclusive'"=="exclusive" {
				drop if  (`targetidinf'==`targetid' | `sourceidinf'==`sourceid')
				drop if  (`targetidinf'==`sourceid' | `sourceidinf'==`targetid')
			}
			keep `time' `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
			append using "`spatialvarundirdyad_`m''",
			save "`spatialvarundirdyad_`m''", replace
			if "`exclusive'"=="" & "`link'"=="ik" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'==`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
			}
			if "`exclusive'"=="" & "`link'"=="ki" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'==`targetid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
			}
			if "`exclusive'"=="" & "`link'"=="jm" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'==`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}		
			if "`exclusive'"=="" & "`link'"=="mj" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'==`targetid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}
			if "`exclusive'"=="" & ("`link'"=="ik+jm" | "`link'"=="ik*jm") {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'==`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'==`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}
			if "`exclusive'"=="" & ("`link'"=="ki+mj" | "`link'"=="ki*mj") {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'==`targetid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'==`targetid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="ik" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'!=`targetid'
				keep if  `sourceidinf'==`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="ki" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'==`targetid'
				keep if  `sourceidinf'!=`sourceid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="jm" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'!=`targetid'
				keep if  `targetidinf'==`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}		
			if "`exclusive'"=="exclusive" & "`link'"=="mj" {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'==`targetid'
				keep if  `targetidinf'!=`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}
			if "`exclusive'"=="exclusive" & ("`link'"=="ik+jm" | "`link'"=="ik*jm") {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'!=`targetid'
				keep if  `sourceidinf'==`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'!=`targetid'
				keep if  `targetidinf'==`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}
			if "`exclusive'"=="exclusive" & ("`link'"=="ki+mj" | "`link'"=="ki*mj") {
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `sourceidinf'==`targetid'
				keep if  `sourceidinf'!=`sourceid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`m''"
				save "`Wsource_`m''", replace
				use "`holder'", replace
				replace `targetidinf'=`n'
				keep if  `targetidinf'==`targetid'
				keep if  `targetidinf'!=`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`m''"
				save "`Wtarget_`m''", replace
			}
		}
	}		
}

		
di _newline(2) "Combining spatial effect components for dyads involving `source_max' units of i in total - please wait."
forvalues m = 1(1)`source_max'{
	if `m'/10==int(`m'/10) {
		di "."
	}
	else {
		di "." _continue
	}
	quietly {	
		use "`spatialvarundirdyad_`m''", replace
		if "`link'"=="ik" | "`link'"=="ki" {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`m'', nogenerate
		}
		if "`link'"=="jm" | "`link'"=="mj" {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`m'', nogenerate
		}
		if "`link'"=="ik+jm" | "`link'"=="ik*jm" | "`link'"=="ki+mj" | "`link'"=="ki*mj" {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`m'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`m'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+jm" | "`link'"=="ki+mj" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*jm" | "`link'"=="ki*mj" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}
		drop if `sourceidinf'>`targetidinf'
		tempvar undirdyadcont
		replace `weightvar'=. if `spatialvar'==.
		ge `undirdyadcont'=`spatialvar'*`weightvar' 
		tempvar allmissing
		gen `allmissing'=`undirdyadcont'
		collapse (sum) `undirdyadcont' `weightvar' (mean) `allmissing', by(`sourceidinf' `targetidinf' `time')
		replace `undirdyadcont'=. if `allmissing'==.
		if "`rowst'"=="norowst" { 
			ge SE_var_undir_`rowst'= `undirdyadcont'
			replace SE_var_undir_`rowst'=. if `weightvar'==0
		}
		else {
			ge SE_var_undir_`rowst'= `undirdyadcont'/`weightvar'
		}
		keep `sourceidinf' `targetidinf' SE_var_undir_`rowst' `time'
		tempfile SE_file_undir_`rowst'_`m'
		save "`SE_file_undir_`rowst'_`m''", replace
	}
}
local appendnumber = `source_max'-1
di _newline(2) "Appending spatial effects for `appendnumber' times in total - please wait."
quietly use "`SE_file_undir_`rowst'_1'", replace
forvalues m = 2(1)`source_max'{
	quietly append using "`SE_file_undir_`rowst'_`m''"
	if `m'/10==int(`m'/10) {
		di "."
	}
	else {
		di "." _continue
	}
} 		
ren `sourceidinf' `sourceid'
ren `targetidinf' `targetid'
if "`sename'"=="" {
	local sename "SE_var_undir_`rowst'"
}
else {
	ren SE_var_undir_`rowst' `sename'
}
if "`filename'"=="" {
	local filename "SE_file_undir_`rowst'"
}
quietly save "`holder'", replace


quietly {
	use "`datasample'", replace
	merge m:m `sourceid' `targetid' `time' using `holder', nogenerate
	keep `i' `j' `time' `sename'
	collapse `sename', by(`i' `j' `time')
	if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | "`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
		drop if `i'==.
	}
	else {
		drop if `i'==""
	}
	save `filename', replace
	restore
	preserve
	merge m:m `i' `j' `time' using `filename', keep(match) nogenerate
	keep `i' `j' `time' `sename'
	if "`labelname'"=="" {
		label var `sename' "Undirected dyad contagion spatial effect variable" 
	}
	else {
		label var `sename' "`labelname'"
	}
	save `filename', replace
}
 
di _newline(2) "File {bf}`filename'{sf}"
di _newline(1) "  with variables {bf}`i'{sf}, {bf}`j'{sf}, {bf}`time'{sf}"
di _newline(1) "  and SE variable {bf}`sename'{sf} saved in current working directory"
if "`merge'"=="nomerge" { 
	restore
}
else {
	restore
	capture drop _merge
	quietly merge m:m `i' `j' `time' using `filename', keep(match master)
	di _newline(2) "Spatial lag variable {bf}`sename'{sf} merged into the original dataset."
}

end
