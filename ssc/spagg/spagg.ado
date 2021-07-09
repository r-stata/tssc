* Creates aggregate source or target contagion spatial effect variable from a directed dyadic dataset
* 6.0 Eric Neumayer and Thomas Plümper 22may2013

* Change to version 5.0: replaced user-written mmerge.ado commands with Stata's official merge command
* Change to version 4.1: fixed bug that affected row-standardization of spatial effect variables

program spagg, sortpreserve

version 11.2

syntax varlist(min=1 max=1)[if][in], form(name) link(string) Weightvar(name) Source(name) Target(name) ///
		[time(name) ///
		noMerge noRowst SEname(name) FILEname(name) LABELname(name)]
	 
if "`form'"!="source" & "`form'"!="target" {
	di as err "form(source) or form(target) required."
	exit 198
}

if "`link'"=="" {
	di as err "User must specify a link function."
	exit 198
}

if "`form'"=="source" {
	if "`link'"=="ik" | "`link'"=="ki" | "`link'"=="im" | "`link'"=="mi" {
	}
	else {
		di as err "Link(`link') not allowed with form(source). See help file for allowed link options."
	exit 198
	}
}

if "`form'"=="target" {
	if "`link'"=="jm" | "`link'"=="mj" | "`link'"=="jk" | "`link'"=="kj" {
	}
	else {
		di as err "Link(`link') not allowed with form(target). See help file for allowed link options."
	exit 198
	}
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
local sourcetype : type `source'
local targettype : type `target'
capture confirm numeric "`time'"


di _newline "User has specified that:"
di _newline "   the generated spatial effect variable will represent aggregate {bf}`form'{sf} contagion."
di _newline "   {bf}`spatialvar'{sf} is the variable to be spatially lagged."
di _newline "   {bf}`source'{sf} is the identifying variable of source unit {it}i{sf}."
di _newline "   {bf}`target'{sf} is the identifying variable of target unit {it}j{sf}."

if "`link'"=="ik" {
	di _newline "   {bf}`weightvar'{sf} will link source unit {it}i{sf} to source units {it}k{sf}."
}
if "`link'"=="jm" {
	di _newline "   {bf}`weightvar'{sf} will link target unit {it}j{sf} to target units {it}m{sf}."
}
if "`link'"=="ki" {
	di _newline "   {bf}`weightvar'{sf} will link source units {it}k{sf} to source unit {it}i{sf}."
}
if "`link'"=="mj" {
	di _newline "   {bf}`weightvar'{sf} will link target units {it}m{sf} to target unit {it}j{sf}."
}
if "`link'"=="im" {
	di _newline "   {bf}`weightvar'{sf} will link source unit {it}i{sf} to target units {it}m{sf}."
}
if "`link'"=="mi" {
	di _newline "   {bf}`weightvar'{sf} will link target units {it}m{sf} to source unit {it}i{sf}."
}
if "`link'"=="jk" {
	di _newline "   {bf}`weightvar'{sf} will link target unit {it}j{sf} to source units {it}k{sf}."
}
if "`link'"=="kj" {
	di _newline "   {bf}`weightvar'{sf} will link source units {it}k{sf} to target unit {it}j{sf}."
}

if "`time'"=="" {
	di _newline "   the spatial effect variable is {bf}time-invariant{sf}."
}
else {
	di _newline "   {bf}`time'{sf} is the numeric time variable."
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
		di _newline "   Warning: file {bf}SE_file_ag_`form'_`rowst'{sf} will be replaced in current working directory, if already existant."
	}
	else {
		di _newline "   Warning: file {bf}`filename'{sf} will be replaced in current working directory, if already existant."
	}
}
else {
	di _newline "The created spatial effect variable will be {bf}automatically merged{sf} into the original dataset."
	if "`sename'"=="" {
		di _newline "   Warning: variable {bf}SE_var_ag_`form'_`rowst'{sf} will be dropped from dataset before merging, if already existant."
		capture drop SE_var_ag_`form'_`rowst'
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
	keep `spatialvar' `weightvar' `sourceidinf' `targetidinf' `time' `source' `target' 
	save "`holder'", replace
	tempvar varholder
	ren `source' `varholder'
	ren `target' `source'
	ren `varholder' `target'
	keep `time' `source' `target' 
	save "`addeddyads'", replace
	use "`holder'", replace
	append using "`addeddyads'"
	capture drop _merge
	capture drop _fillin
	fillin `source' `target' `time'
	collapse `spatialvar' `weightvar' `sourceidinf' `targetidinf', by(`source' `target' `time')
	save "`holder'", replace
}

if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | ///
	"`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
	tempvar sourceid
	quietly egen `sourceid'=group(`source')
}
else {
	tempvar sourceid
	quietly encode `source', ge(`sourceid')
}
if "`targettype'"=="int" | "`targettype'"=="long" | "`targettype'"=="float" | ///
	"`targettype'"=="double"  | "`targettype'"=="byte" {
	tempvar targetid
	quietly egen `targetid'=group(`target')
}
else {
	tempvar targetid
	quietly encode `target', ge(`targetid')
}
quietly su `sourceid'
local source_max=r(max)
quietly su `targetid'
local target_max=r(max)
if `source_max'<2 & `target_max'<2 {
		di as err "Generation of spatial effect variable not possible with fewer than 2 source and 2 target units."
		exit 198
}
else {
	if ("`link'"=="jm" | "`link'"=="jk" | "`link'"=="mj" | "`link'"=="kj") {
		di _newline "Generating spatial effect components for dyads involving `target_max' target units in total - please wait."
	}
	else {
		di _newline "Generating spatial effect components for dyads involving `source_max' source units in total - please wait."
	}	
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

if "`form'"=="target" {
	forvalues i = 1(1)`target_max' {
		if `i'/10==int(`i'/10) {
			di "."
		}
		else {
			di "." _continue
		}
		quietly {	
			use "`spatialvarempty'", replace
			tempfile spatialvardirdyad_`i'
			save "`spatialvardirdyad_`i''", replace
			use "`Wempty'", replace
			tempfile Wsource_`i'
			save "`Wsource_`i''", replace
			tempfile Wtarget_`i'
			save "`Wtarget_`i''", replace
			use "`holder'", replace
			replace `targetidinf'=`i'
			save "`holder'", replace
			keep if  `targetidinf'!=`targetid'
			keep `time' `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
			append using "`spatialvardirdyad_`i''",
			save "`spatialvardirdyad_`i''", replace
			if  "`link'"=="jm" {
				use "`holder'", replace
				keep if  `targetidinf'==`sourceid'
				keep if  `targetidinf'!=`targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}		
			if  "`link'"=="mj" {
				use "`holder'", replace
				keep if  `targetidinf'==`targetid'
				keep if  `targetidinf'!=`sourceid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}
			if  "`link'"=="jk" {
				use "`holder'", replace
				keep if  `targetidinf'==`sourceid'
				keep if  `sourceidinf'!=`targetid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}		
			if  "`link'"=="kj" {
				use "`holder'", replace
				keep if  `targetidinf'==`targetid'
				keep if  `sourceidinf'!=`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}
		}	
	}
}
else {
	forvalues i = 1(1)`source_max' {
		if `i'/10==int(`i'/10) {
			di "."
		}
		else {
			di "." _continue
		}
		quietly {	
			use "`spatialvarempty'", replace
			tempfile spatialvardirdyad_`i'
			save "`spatialvardirdyad_`i''", replace
			use "`Wempty'", replace
			tempfile Wsource_`i'
			save "`Wsource_`i''", replace
			tempfile Wtarget_`i'
			save "`Wtarget_`i''", replace
			use "`holder'", replace
			replace `sourceidinf'=`i'
			save "`holder'", replace
			keep if  `sourceidinf'!=`sourceid'
			keep `time' `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
			append using "`spatialvardirdyad_`i''",
			save "`spatialvardirdyad_`i''", replace
			if  "`link'"=="ik" { 
				use "`holder'", replace
				keep if  `sourceidinf'==`sourceid'			
				keep if  `sourceidinf'!=`targetid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if  "`link'"=="ki" {
				use "`holder'", replace
				keep if  `sourceidinf'==`targetid'			
				keep if  `sourceidinf'!=`sourceid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if  "`link'"=="im" { 
				use "`holder'", replace
				keep if  `sourceidinf'==`sourceid'			
				keep if  `targetidinf'!=`targetid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if  "`link'"=="mi" {
				use "`holder'", replace
				keep if  `sourceidinf'==`targetid'
				keep if  `targetidinf'!=`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
		}
	}
}


		
di _newline(2) "Combining spatial effect components for ``form'_max' `form's in total - please wait."
forvalues i = 1(1)`source_max'{
	if `i'/10==int(`i'/10) {
		di "."
	}
	else {
		di "." _continue
	}
	quietly {	
		use "`spatialvardirdyad_`i''", replace

		if  ("`link'"=="ik" | "`link'"=="ki") {
			merge m:m `sourceidinf'  `sourceid' `time' using `Wsource_`i'', nogenerate
		}
		if  ("`link'"=="im" | "`link'"=="mi") {
			merge m:m `sourceidinf'  `targetid' `time' using `Wsource_`i'', nogenerate
		}
		if  ("`link'"=="jm" | "`link'"=="mj") {
			merge m:m `targetidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
		}
		if  ("`link'"=="jk" | "`link'"=="kj") {
			merge m:m `targetidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
		}

		tempvar agdyadcont
		replace `weightvar'=. if `spatialvar'==.
		ge `agdyadcont'=`spatialvar'*`weightvar' 
		tempvar allmissing
		gen `allmissing'=`agdyadcont'
		collapse (sum) `agdyadcont' `weightvar' (mean) `allmissing', by(``form'idinf' `time')
		replace `agdyadcont'=. if `allmissing'==.
		if "`rowst'"=="norowst" { 
			ge SE_var_ag_`form'_`rowst'= `agdyadcont'
			replace SE_var_ag_`form'_`rowst'=. if `weightvar'==0
		}
		else {
			ge SE_var_ag_`form'_`rowst'= `agdyadcont'/`weightvar'
		}
		keep ``form'idinf' SE_var_ag_`form'_`rowst' `time'
		tempfile SE_file_ag_`form'_`rowst'_`i'
		save "`SE_file_ag_`form'_`rowst'_`i''", replace
	}
}


local appendnumber = ``form'_max'-1
di _newline(2) "Appending spatial effect of `appendnumber' `form's to spatial effect of `form' 1 - please wait."
quietly use "`SE_file_ag_`form'_`rowst'_1'", replace
forvalues i = 2(1)`source_max'{
	quietly append using "`SE_file_ag_`form'_`rowst'_`i''"
	if `i'/10==int(`i'/10) {
		di "."
	}
	else {
		di "." _continue
	}
} 		
ren ``form'idinf' ``form'id' 
if "`sename'"=="" {
	local sename "SE_var_ag_`form'_`rowst'"
}
else {
	ren SE_var_ag_`form'_`rowst' `sename'
}
if "`filename'"=="" {
	local filename "SE_file_ag_`form'_`rowst'"
}
quietly sort ``form'id'  `time'
quietly save "`holder'", replace


quietly {
	use "`datasample'", replace
	merge m:m ``form'id' `time' using `holder', nogenerate
	keep `source' `target' `time' `sename'
	collapse `sename', by(`source' `target' `time')
	if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | "`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
		drop if `source'==.
	}
	else {
		drop if `source'==""
	}
	save `filename', replace
	restore
	preserve
	merge m:m `source' `target' `time' using `filename', keep(match) nogenerate
	keep `source' `target' `time' `sename'
	if "`labelname'"=="" {
		if "`form'"=="source" {
			label var `sename' "Aggregate source contagion spatial effect variable" 
		}
		else {
			label var `sename' "Aggregate target contagion spatial effect variable" 
		}
	}
	else {
		label var `sename' "`labelname'"
	}
	save `filename', replace
}

di _newline(2) "File {bf}`filename'{sf}"
di _newline(1) "  with variables {bf}`source'{sf}, {bf}`target'{sf}, {bf}`time'{sf}"
di _newline(1) "  and SE variable {bf}`sename'{sf} saved in current working directory"
if "`merge'"=="nomerge" { 
	restore
}
else {
	restore
	capture drop _merge
	quietly merge m:m `source' `target' `time' using `filename', keep(match master)
	di _newline(2) "Spatial lag variable {bf}`sename'{sf} merged into the original dataset."
}

end
