* Creates spatial effect variable from a monadic dataset
* 6.0 Eric Neumayer and Thomas Plümper 22may2013

* Change to version 3.1: replaced user-written mmerge.ado commands with Stata's official merge command

program spmon, sortpreserve

version 11.2

syntax varlist(min=1 max=1)[if][in], Weightvar(name) i(name) k(name) ///
		[time(name) REVerse_W ///
		noMerge noRowst SEname(name) FILEname(name) LABELname(name)]

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
local targettype : type `k'
capture confirm numeric "`time'"

di _newline "User has specified that:"
di _newline "   {bf}`spatialvar'{sf} is the variable of unit {it}k{sf} to be spatially lagged. It must be the same 
di "      for all dyads of a specific unit {it}k{sf} with all combinations of unit {it}i{sf} (for any given time period)."
if "`reverse_W'"=="" {
	di _newline "   {bf}`weightvar'{sf} will link unit {it}i{sf} to other units {it}k{sf}."
}
if "`reverse_W'"=="reverse_W" {
	di _newline "   {bf}`weightvar'{sf} will link other units {it}k{sf} to unit {it}i{sf}."
}
di _newline "   {bf}`i'{sf} is the identifying variable of unit {it}i{sf}."
di _newline "   {bf}`k'{sf} is the identifying variable of unit {it}k{sf}."
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
}
else {
	di _newline "The created spatial effect variable will be {bf}automatically merged{sf} into the original dataset."
	di _newline "However, user must {bf}merge{sf} the created spatial effect variable into the estimation dataset {bf}by hand{sf}."
	if "`sename'"=="" {
		di _newline "   Warning: variable {bf}SE_var_monadic_`rowst'{sf} will be dropped from dataset before merging, if already existant."
		capture drop SE_var_monadic_`rowst'
	}
	else {
		di _newline "   Warning: variable {bf}`sename'{sf} will be dropped from dataset before merging, if already existant."
		capture drop `sename'
	}
}

if "`filename'"=="" {
	di _newline "   Warning: file {bf}SE_file_monadic_`rowst'{sf} will be replaced in current working directory, if already existant."
}
else {
	di _newline "   Warning: file {bf}`filename'{sf} will be replaced in current working directory, if already existant."
}


set more on
di _newline(2) "{bf}*** Check the above. ***{sf}  --  Press q to break, press any other button to continue."
more

di _newline(2) "Please wait. Creation of spatial effect variable in progress..."

preserve
quietly keep if `touse'

quietly {
	tempfile datasample holder addeddyads
	quietly compress
	save "`datasample'", replace
	keep `spatialvar' `weightvar' `time' `i' `k' 
	save "`holder'", replace
	tempvar varholder
	ren `i' `varholder'
	ren `k' `i'
	ren `varholder' `k'
	keep `time' `i' `k' 
	save "`addeddyads'", replace
	use "`holder'", replace
	append using "`addeddyads'"
	capture drop _merge
	capture drop _fillin
	fillin `i' `k' `time'
	collapse `spatialvar' `weightvar' , by(`i' `k' `time')
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
	quietly egen `targetid'=group(`k')
}
else {
	tempvar targetid
	quietly encode `k', ge(`targetid')
}
quietly save "`holder'", replace
quietly save "`datasample'", replace



quietly su `sourceid'
local source_max=r(max)
quietly su `targetid'
local target_max=r(max)

if `source_max'<2 | `target_max'<2 {
		di as err "Generation of spatial effect not possible with fewer than 2 units of i or 2 units of k."
		exit 198
}


if "`reverse_W'"=="" {
	quietly {
		tempvar monadiccont 
		ge `monadiccont'=`spatialvar'*`weightvar' 
		replace `monadiccont'=. if `sourceid'==`targetid'
		tempvar allmissing
		gen `allmissing'=`monadiccont'
		collapse (sum) `monadiccont' `weightvar' (mean) `allmissing', by(`sourceid' `time') 
		replace `monadiccont'=. if `allmissing'==.
		if "`rowst'"=="norowst" { 
			ge SE_var_monadic_`rowst'= `monadiccont'
			replace SE_var_monadic_`rowst'=. if `weightvar'==0
		}
		else {
			ge SE_var_monadic_`rowst'= `monadiccont'/`weightvar'
		}
		tempfile SE_file_monadic_`rowst'
		save "`SE_file_monadic_`rowst''", replace
	}
}

if "`reverse_W'"=="reverse_W" {
	quietly {
		tempfile yholder Wholder
		use "`holder'", replace
		keep `spatialvar' `sourceid' `targetid' `time' 
		save "`yholder'", replace
		use "`holder'", replace
		keep `weightvar' `sourceid' `targetid' `time' 
		tempvar varholder
		ge 	`varholder'=`sourceid'
		drop `sourceid'
		ren `targetid' `sourceid'
		ren `varholder' `targetid'
		save "`Wholder'", replace
		use "`yholder'", replace
		merge m:m `sourceid' `targetid' `time' using "`Wholder'", nogenerate
		save "`holder'", replace
		tempvar monadiccont 
		ge `monadiccont'=`spatialvar'*`weightvar' 
		replace `monadiccont'=. if `sourceid'==`targetid'
		tempvar allmissing
		gen `allmissing'=`monadiccont'
		collapse (sum) `monadiccont' `weightvar' (mean) `allmissing', by(`sourceid' `time') 
		replace `monadiccont'=. if `allmissing'==.
		if "`rowst'"=="norowst" { 
			ge SE_var_monadic_`rowst'= `monadiccont'
			replace SE_var_monadic_`rowst'=. if `weightvar'==0
		}
		else {
			ge SE_var_monadic_`rowst'= `monadiccont'/`weightvar'
		}
		tempfile SE_file_monadic_`rowst'
		save "`SE_file_monadic_`rowst''", replace
	}
}



quietly {
	use "`datasample'", replace
	merge m:m `sourceid' `time' using `SE_file_monadic_`rowst'', nogenerate
	keep `i' `time' SE_var_monadic_`rowst'
	collapse SE_var_monadic_`rowst', by(`i' `time')
	if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | "`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
		drop if `i'==.
	}
	else {
		drop if `i'==""
	}
	if "`sename'"=="" {
		local sename "SE_var_monadic_`rowst'"
	}
	else {
		ren SE_var_monadic_`rowst' `sename'
	}
	if "`filename'"=="" {
		local filename "SE_file_monadic_`rowst'"
	}
	save `filename', replace
	restore
	preserve
	if "`targettype'"=="int" | "`targettype'"=="long" | "`targettype'"=="float" | "`targettype'"=="double"  | "`targettype'"=="byte" {
		tempvar targetid
		quietly egen `targetid'=group(`k')
	}
	else {
		tempvar targetid
		quietly encode `k', ge(`targetid')
	}
	collapse `targetid', by(`i' `time')
	merge m:m `i' `time' using `filename', keep(match) nogenerate
	keep `i'  `time' `sename'
	collapse `sename', by(`i' `time')
	if "`labelname'"=="" {
		label var `sename' "Monadic spatial effect variable" 
	}
	else {
		label var `sename' "`labelname'"
	}
	save `filename', replace
}

di _newline(2) "File {bf}`filename'{sf}"
di _newline(1) "  with variables {bf}`i'{sf}, {bf}`time'{sf}"
di _newline(1) "  and SE variable {bf}`sename'{sf} saved in current working directory."

if "`merge'"=="nomerge" { 
	restore
}
else {
	restore
	capture drop _merge
	quietly merge m:m `i' `time' using `filename', keep(match master)
	di _newline(2) "Spatial lag variable {bf}`sename'{sf} merged into the original dataset."
}

end
