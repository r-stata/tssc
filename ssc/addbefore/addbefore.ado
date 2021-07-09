
program define addbefore
	version 13.0    
	syntax varlist [if] [in] ,Digits(integer) [Char(str)] [Generate(string) replace]


	if "`generate'" != "" & "`replace'" != "" {
		di as err "you may not specify both gen and replace"
		exit 198
	}

	if "`generate'" == "" & "`replace'" == "" {
		di as err "must specify either generate or replace option"
		exit 198
	}

	if "`generate'" != "" {
		local ct1: word count `varlist'
		local save "`varlist'"
		local 0 "`generate'"   
		capture syntax newvarlist
		if _rc {
			di as err "generate() contains existing variable(s) and/or illegal variable name(s)"
			exit _rc
		}
		local generate "`varlist'"
		local varlist "`save'"
		local ct2: word count `generate'
		if `ct1' != `ct2' {
			di as err "number of variables in varlist must equal" 
			exit 198
		}
	}

	if "`char'" ~= "" {
		local version : disp c(stata_version)
		if `version' >= 14.0 {
			if ustrlen("`char'") ~= 1{
				di as err "The number of unicode character must be 1  " 
				exit 198
			}
		}
		else {
			if length("`char'") ~= 1{
				di as err "The length of char must be 1  " 
				exit 198
			}
		}
		foreach var of local varlist {
			local  my_type : type `var'
			if regexm("`my_type'","float|byte|int|long|double"){
				if length("`char'") == 1 & regexm("`char'", "[^0-9]") {
					disp as error `"`char' is an invalid char, you must specify the Numbers 0 to 9"'
					exit 601
				}
			}
		}
	}
	foreach var of local varlist {
		local  my_type : type `var'
		if regexm("`my_type'","float|byte|int|long|double"){
			if `digits' > 9 {
				disp as error `"The digits must less than 10"'
				exit 601
			}
		}
	}
	local version : disp c(stata_version)
	if `version' >= 14.0 {
		foreach var of local varlist {
			tempvar `var'_temp1 `var'_temp2
			local my_type : type `var'
			if strpos("`my_type'","str"){
				qui gen ``var'_temp1'  = `var'
			}
			else{
				qui tostring `var', gen(``var'_temp1')
			}	
			qui gen ``var'_temp2' = ustrlen(``var'_temp1')
			qui sum ``var'_temp2'
			if `r(max)' > `digits' {
				disp as error `"`var' contains length more than `digits' Numbers or strings"'
				exit 601
			}
		}
	}
	else {
		foreach var of local varlist {
			tempvar `var'_temp1 `var'_temp2
			local my_type : type `var'
			if strpos("`my_type'","str"){
				qui gen ``var'_temp1'  = `var'
			}
			else{
				qui tostring `var', gen(``var'_temp1')
			}	
			qui gen ``var'_temp2' = strlen(``var'_temp1')
			qui sum ``var'_temp2'
			if `r(max)' > `digits' {
				disp as error `"`var' contains length more than `digits' Numbers or strings"'
				exit 601
			}
		}
	}
	
	***********************************************************************************************
	
	if "`char'" == "" {
		local char 0
	} 
	if "`generate'" ~= "" {

		local ng = wordcount("`generate'")
		
		forvalue jj = 1(1)`ng'{
			local ggg = word("`generate'", `jj')
			local kkk = word("`varlist'", `jj')
			quietly clonevar `ggg' = `kkk'
		}
		foreach var of local generate {
		
			local my_type : type `var'
		 
			if strpos("`my_type'","str"){
				local version : disp c(stata_version)
				if `version' >=  14.0 {
					forvalues i = 1/`digits' {
						qui	replace `var' = "`char'" + `var' if ustrlen(`var') < `digits'
					}
				}
				else {
					forvalues i = 1/`digits' {
						qui	replace `var' = "`char'" + `var' if strlen(`var') < `digits'
					}
				}
			}
			else {
				if `char' == 0{
					format `var' %0`digits'.0f
				}
				else {
					if `digits' > 7 {
						format %`=`digits'+2'.0g `var'
						recast long `var'
					}
					tempvar `var'_string
					qui tostring `var', gen(``var'_string')
					forvalues j = 1/`digits' {
						qui replace `var' = `char'*10^(length(``var'_string')+`j'-1) + `var' if length(``var'_string') + `j' - 1 < `digits'
					}
				}
			}
		}
	}
	**************************************************************************************************
	else {
		foreach var of local varlist {
			
			local  my_type : type `var'
			
			if strpos("`my_type'","str"){
				local version : disp c(stata_version)
				if `version' >= 14.0 {
					forvalues i = 1/`digits' {
						qui	replace `var' = "`char'" + `var' if ustrlen(`var') < `digits'
					}
				}
				else {
					forvalues i = 1/`digits' {
						qui	replace `var' = "`char'" + `var' if strlen(`var') < `digits'
					}
				}
			}
		
			else {
				if `char' == 0{
					format `var' %0`digits'.0f
				}
				else {
					if `digits' > 7 {
						format %`=`digits'+2'.0g `var'
						recast long `var'
					}
					tempvar `var'_string
					qui tostring `var', gen(``var'_string')
					forvalues j = 1/`digits' {
						qui replace `var' = `char'*10^(length(``var'_string')+`j'-1) + `var' if length(``var'_string') + `j' - 1 < `digits'
					}
				}
			}
		}
	}		
end
