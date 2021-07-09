*! version 1.0.2 dec2011 (SJxx-x: dmxxxx)
program define _gzbmicat
	version 10

	preserve

	noi findfile zbmicat.dta
	local fn "`r(fn)'"

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	gettoken paren 0 : 0, parse("(), ")
	gettoken measure 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}

	syntax [if] [in], Xvar(varname numeric) GENder(varname) GENCode(string) /*
	*/[AGEUnit(string) BY(string)]
	if `"`by'"' != "" {
		_egennoby zbmicat() `"`by'"'
		/* NOTREACHED */
	}



	local 1 `gencode'
	*zap commas to spaces (i.e. commas indulged)
	local 1 : subinstr local 1 "," " ", all
	tokenize "`1'", parse("= ")
	
	if "`1'" == substr("male",1,length("`1'")) {
		*male first
		if "`2'" ~= "=" | "`5'" ~= "=" {
			Badsyntax
		}
		if "`4'" ~= substr("female",1,length("`4'")) {
			Badsyntax
		}
		if "`7'" ~= "" {
			Badsyntax
		}
		local male "`3'"
		local female "`6'"
	}
	else if "`1'" == substr("female",1,length("`1'")) {
		*female first
		if "`2'" ~= "=" | "`5'" ~= "=" {
			Badsyntax
		}
		if "`4'" ~= substr("male",1,length("`4'")) {
			Badsyntax
		}
		if "`7'" ~= "" {
			Badsyntax
		}
		local female "`3'"
		local male "`6'"
	}
	else Badsyntax

	local x : type `gender'
	local y = substr("`x'",1,3)
	if "`y'" == "str" {
		capture assert `gender'=="`male'" | `gender'=="`female'" | `gender'=="" | `gender'==" "
		if _rc {
			di as err "The gender variable takes values other than `male' and `female'"
			exit 
		}
	}
	else {
		capture assert `gender'==`male' | `gender'==`female' | `gender'>=.
		if _rc {
			di as err "The gender variable takes values other than `male' and `female'"
			exit 
		}
	}


	if "`ageunit'"=="" {
		local ageunit year
	}
	else {
		capture assert "`ageunit'"=="day" | "`ageunit'"=="week" | "`ageunit'"=="month" | "`ageunit'"=="year"
		if _rc {
			di as error "The ageunit option must contain the word" as text " day" as error "," /*
			*/ as text " week" as error "," as text " month" as error " or" as text " year"
			exit
		}
	}


	tempvar ageyr dif agefrac __16 __17 __18_5 __25 __30 agefrac2 a0 a1 a2 a3

	foreach x in sex age 16_pre 17_pre 18_5_pre 25_pre 30_pre 16 17 18_5 25 30 ///
		     16_nx 17_nx 18_5_nx 25_nx 30_nx 16_nx2 17_nx2 18_5_nx2 25_nx2 30_nx2 merge {
		capture confirm new var __IOTF`x'
		if _rc {
			di as err "__IOTF`x' is used by zbmicat - rename your variable"
			exit 110
		}
	}

	marksample touse

	quietly { 
		if "`y'" == "str" {
			gen byte __IOTFsex=1 if `gender'=="`male'"
			replace __IOTFsex=2 if `gender'=="`female'"
		}
		else {
			gen byte __IOTFsex=1 if `gender'==`male'
			replace __IOTFsex=2 if `gender'==`female'
		}

		if "`ageunit'"=="year" {
			gen float `ageyr'=`xvar'
		}
		else if "`ageunit'"=="month" {
			gen float `ageyr'=`xvar'/12
		}
		else if "`ageunit'"=="week" {
			gen float `ageyr'=`xvar'/(365.25/7)
		}
		else if "`ageunit'"=="day" {
			gen float `ageyr'=`xvar'/365.25
		}
		gen float __IOTFage=int(`ageyr')
		gen `dif' = `ageyr'-__IOTFage
		replace __IOTFage=__IOTFage+0.5 if `dif'>=0.5 & `dif'<.

		sort __IOTFsex __IOTFage
		merge __IOTFsex __IOTFage using "`fn'", nokeep _merge(__IOTFmerge)

		gen `agefrac' = (`ageyr'-__IOTFage)/0.5 if `ageyr'>2 & `ageyr'<18 & `touse' & __IOTFmerge==3
		gen `agefrac2' = `agefrac'*`agefrac' if `ageyr'>2.5 & `ageyr'<17.5 & `touse' & __IOTFmerge==3

		foreach suf in 16 17 18_5 25 30 {
			gen `__`suf'' = .			

			*No interpolation required if age equals the age on the growth chart
			replace `__`suf'' = __IOTF`suf' if `ageyr'==__IOTFage & `touse' & __IOTFmerge==3
			
			*Linear interpolation for first segment and last segment
			replace `__`suf'' = __IOTF`suf'+`agefrac'*(__IOTF`suf'_nx-__IOTF`suf') ///
				    	if ((`ageyr'>2 & `ageyr'<2.5) | (`ageyr'>17.5 & `ageyr'<18)) & `touse' & __IOTFmerge==3
			
			*Cubic interpolation
			gen `a0' = -__IOTF`suf'_pre/6+__IOTF`suf'/2-__IOTF`suf'_nx/2+__IOTF`suf'_nx2/6 ///
					if `ageyr'>2.5 & `ageyr'<17.5 & `touse' & __IOTFmerge==3
			gen `a1' = __IOTF`suf'_pre/2-__IOTF`suf'+__IOTF`suf'_nx/2 if `ageyr'>2.5 & `ageyr'<17.5 & `touse' & __IOTFmerge==3
			gen `a2' = -__IOTF`suf'_pre/3-__IOTF`suf'/2+__IOTF`suf'_nx -__IOTF`suf'_nx2/6 if `ageyr'>2.5 & `ageyr'<17.5 & `touse' & __IOTFmerge==3
			gen `a3' = __IOTF`suf' if `ageyr'>2.5 & `ageyr'<17.5 & `touse' & __IOTFmerge==3
			replace `__`suf'' = `a0'*`agefrac'*`agefrac2'+`a1'*`agefrac2'+`a2'*`agefrac'+`a3' ///
					if `ageyr'>2.5 & `ageyr'<17.5 & `touse' & __IOTFmerge==3
			drop `a0' `a1' `a2' `a3' 
		}

		gen `type' `g' = -3 if `measure'<`__16' & `ageyr'>=2 & `ageyr'<=18 & `touse' & __IOTFmerge==3
		replace `g' = -2 if `measure'>=`__16' & `measure'<`__17' & `ageyr'>=2 & `ageyr'<=18 & `touse' & __IOTFmerge==3
		replace `g' = -1 if `measure'>=`__17' & `measure'<`__18_5' & `ageyr'>=2 & `ageyr'<=18 & `touse' & __IOTFmerge==3
		replace `g' = 0 if `measure'>=`__18_5' & `measure'<`__25' & `ageyr'>=2 & `ageyr'<=18 & `touse' & __IOTFmerge==3
		replace `g' = 1 if `measure'>=`__25' & `measure'<`__30' & `ageyr'>=2 & `ageyr'<=18 & `touse' & __IOTFmerge==3
		replace `g' = 2 if `measure'>=`__30' & `measure'<. & `ageyr'>=2 & `ageyr'<=18 & `touse' & __IOTFmerge==3
		replace `g'=. if `measure'<=0
		capture lab def bmicat_lab -3 "Grade 3 thinness" -2 "Grade 2 thinness" -1 "Grade 1 thinness" ///
					    0 "Normal wt" 1 "Overweight" 2 "Obese"
		lab val `g' bmicat_lab
		drop __IOTFsex __IOTFage __IOTF16_pre __IOTF17_pre __IOTF18_5_pre __IOTF25_pre __IOTF30_pre ///
		     __IOTF16 __IOTF17 __IOTF18_5 __IOTF25 __IOTF30 ///
		     __IOTF16_nx __IOTF17_nx __IOTF18_5_nx __IOTF25_nx __IOTF30_nx ///
		     __IOTF16_nx2 __IOTF17_nx2 __IOTF18_5_nx2 __IOTF25_nx2 __IOTF30_nx2 __IOTFmerge
	}

	quietly count if `g'<. & `touse'
	if r(N) { 
		local y = cond(r(N)==1,"y","")
		local ies = cond(r(N)>1,"ies","")
		local s = cond(r(N)>1,"s","")
		di as text "(BMI categor`y'`ies' generated for " r(N) " case`s')" 
		di as text "(gender was assumed to be coded male=`male', female=`female')"
		di as text "(age was assumed to be in `ageunit's)"
	}

	quietly count if `g'==. & `touse'
	if r(N) { 
		di as text "(A BMI category can be missing because age<2 years or age>18 years," 
		di as text " the gender variable is missing, or BMI is a nonpositive value)"
	}

	restore, not

end

program Badsyntax
	di as err "gencode() option invalid: see {help zbmicat}"
	exit 198
end

