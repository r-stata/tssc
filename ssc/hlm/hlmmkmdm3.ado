*! version 2.0, sean f. reardon, 30dec2005

/****************************************************
 This program creates a HLM3 .mdmt file
 for HLM to read stata data files into HLM. 
 Data cleaning and management should be all
 done in STATA, such as creating dummy variables
 for categorical variables, missing values and 
 weighting variables.
*****************************************************/
 
capture program drop hlmmkmdm3
program define hlmmkmdm3
version 8.2
	syntax using/ [if], id2(varname) id3(varname) ///
		[l1(varlist) l2(varlist) l3(varlist) miss(string) ///
		NOMDMT NODTA NOSTS REPLACE noRUN]

marksample touse

if "`run'"=="norun" {
	local nomdmt ""
	local nodta ""
	local nosts ""
}

if "`nodta'"=="" {
	capture confirm file `using'.dta
	if _rc == 0 & "`replace'"=="" {
		display in yellow "File `using'.dta already exists. Use Replace option."
		exit
	}
}

if "`nomdmt'"=="" {
	capture confirm file `using'.mdmt
	if _rc == 0 & "`replace'"=="" {
		display in yellow "File `using'.mdmt already exists. Use Replace option."
		exit 
	}
}

capture confirm file `using'.mdm
if _rc == 0 & "`replace'"=="" {
	display in yellow "File `using'.mdm already exists. Use Replace option."
	exit 
}

if "`nosts'"=="" {
	capture confirm file `using'.sts
	if _rc == 0 & "`replace'"=="" {
		display in yellow "File `using'.sts already exists. Use Replace option."
		exit 
	}
}

/****************************************
  sort and save the current data as `using'.dta
  unless nodta option specified; then give
  unique name to dta file to be deleted later
****************************************/ 

preserve
qui keep if `touse'
qui drop `touse'
quietly sort `id3' `id2'
quietly compress
if "`nodta'"=="" {
	foreach var of varlist * {
		local varlngth : length local var
		if `varlngth' > 8  {
			drop `var'
	   		di in ye "Varname `var' > 8 characters: dropped from `using'.dta"
		}
	}
	quietly sort `id3' `id2'
	save `using'.dta, `replace' 
}
else {
	local d = 1
	capture confirm file `using'`d'.dta
	while _rc == 0 {
		local d = `d' + 1
		capture confirm file `using'`d'.dta 
  	}
  	foreach var of varlist * {
		local varlngth : length local var
		if `varlngth' > 8  drop `var'
	}
	quietly save `using'`d'.dta
}
restore

/****************************************
  open text file `using'.mdmt
  unless nomdmt option specified; then give
  unique name to mdmt file to be deleted later
****************************************/ 

tempname mdmt
capture file close `mdmt' /*need to close the file if it exists already*/

if "`nomdmt'"=="" {
	quietly file open `mdmt' using "`using'.mdmt", write text `replace' 
}
else {
	local r = 1
  	capture confirm file `using'`r'.mdmt
	while _rc == 0 {
		local r = `r' + 1
		capture confirm file `using'`r'.mdmt 
  	}
	quietly file open `mdmt' using "`using'`r'.mdmt", write text `replace'
}
  
/****************************************
  write response file
****************************************/ 
        
file write `mdmt' "#HLM3 MDM CREATION TEMPLATE" _newline
file write `mdmt' "rawdattype:stata" _newline
file write `mdmt' "l1fname:`using'`d'.dta" _newline
file write `mdmt' "l2fname:`using'`d'.dta" _newline
file write `mdmt' "l3fname:`using'`d'.dta" _newline
if "`miss'"=="" {
	file write `mdmt' "l1missing:n" _newline 
	file write `mdmt' "timeofdeletion:now" _newline 
}
else {
	file write `mdmt' "l1missing:y" _newline 
	file write `mdmt' "timeofdeletion:`miss'" _newline 
}
file write `mdmt' "mdmname:`using'.mdm" _newline
file write `mdmt' "*begin l1vars" _newline
file write `mdmt' "level3id:`id3'" _newline
file write `mdmt' "level2id:`id2'" _newline

unab l1 : `l1'
foreach var of local l1 {
	file write `mdmt' "`var'" _newline 
}
file write `mdmt' "*end l1vars" _newline
file write `mdmt' "*begin l2vars" _newline
file write `mdmt' "level3id:`id3'" _newline
file write `mdmt' "level2id:`id2'" _newline
unab l2 : `l2'
foreach var of local l2 {
	file write `mdmt' "`var'" _newline 
}
file write `mdmt' "*end l2vars" _newline
file write `mdmt' "*begin l3vars" _newline
file write `mdmt' "level3id:`id3'" _newline
unab l3 : `l3'
foreach var of local l3 {
	file write `mdmt' "`var'" _newline 
}
file write `mdmt' "*end l3vars" _newline


capture file close `mdmt'

*the following makes a small file to save the variable names used in the mdm file
preserve
qui keep `id3' `id2' `l1' `l2' `l3'
qui keep in 1
qui drop in 1/1
order `id3' `id2' `l1' `l2' `l3'
quietly save `using'_mdmvars.dta, `replace'
restore


/****************************************
  invoke HLM to create MDM file and then 
  view output, clean up files and write output
****************************************/ 

if "`run'"~="norun" {
	!hlm3 -r `using'`r'.mdmt
	
	if "`nosts'"=="" {
		copy HLM3MDM.STS `using'.sts, replace 
		view `using'.sts
	}
	else view HLM3MDM.STS 
	capture erase HLM3MDM.STS
	
	if "`nodta'"~="" capture erase `using'`d'.dta 	
	if "`nomdmt'"~="" capture erase `using'`r'.mdmt 
	
	capture confirm file `using'.mdmt
	if _rc == 0 & "`nomdmt'"=="" {
	  	display in green "HLM .mdmt file `using'.mdmt saved." 
	}	
	capture confirm file `using'.mdm 
	if _rc == 0 {
	  	display in green "HLM .mdm file `using'.mdm saved." 
	}
	else {
		display "Error: .mdm file not created."
	  	error 
	}
	capture confirm file `using'.sts
	if _rc == 0 & "`nosts'"=="" {
	  	display in green "HLM .sts file `using'.sts saved." 
	}
}
 
end  
