*! version 1.0.2 dec2011 (SJxx-x: dmxxxx)
program define _gzanthro
	version 8

	preserve

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	gettoken paren 0 : 0, parse("(), ")

	gettoken measure 0 : 0, parse("(), ")
	gettoken chart  0 : 0, parse("(), ")
	if `"`chart'"' == "," {
		gettoken chart  0 : 0, parse("(), ")
	}
	gettoken version  0 : 0, parse("(), ")
	if `"`version'"' == "," {
		gettoken version  0 : 0, parse("(), ")
	}

	gettoken paren 0 : 0, parse("(), ")
	if `"`paren'"' != ")" {
		error 198
	}

	capture assert "`version'"=="US" | "`version'"=="UK" | "`version'"=="WHO" | /*
	*/"`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm"
	if _rc {
		di as text "`version'" as error " is an invalid version.  The only valid choices are " /*
		*/as text "US, UK, WHO, UKWHOpreterm" as error " and " as text "UKWHOterm" as error"."
		exit 198
	}

	capture assert "`chart'"=="la" | "`chart'"=="ha" | "`chart'"=="wa" | "`chart'"=="ba" | /*
	*/"`chart'"=="hca" | "`chart'"=="wh" | "`chart'"=="wl" | "`chart'"=="sha" | "`chart'"=="lla" /*
	*/| "`chart'"=="wsa" | "`chart'"=="aca" | "`chart'"=="ssa" | "`chart'"=="tsa" | "`chart'"=="bfa"
	if _rc {
		di as text "`chart'" as error " is an invalid chart code."
		exit 198
	}


	if "`chart'"=="wh" | "`chart'"=="wl" {
		syntax [if] [in], Xvar(varname numeric) GENder(varname) GENCode(string) /*
		*/[NOCutoff BY(string)]
	}
	else if "`chart'"!="wh" &  "`chart'"!="wl" {
		syntax [if] [in], Xvar(varname numeric) GENder(varname) GENCode(string) /*
		*/[AGEUnit(string) GESTage(varname numeric) NOCutoff BY(string)]
		local forage 1
	}
	else {
		di as text "`chart'" as error " is an invalid chart code. See " /*
		*/as text "{help zanthro}" as error " for valid chart codes."
		exit 198
	}

	if `"`by'"' != "" {
		_egennoby zanthro() `"`by'"'
		/* NOTREACHED */
	}

	capture assert "`version'"=="UK" if "`chart'"=="sha"
	if _rc {
		di as error "For chart code " as text "sha" as error ", " as text "UK" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="UK" if "`chart'"=="lla"
	if _rc {
		di as error "For chart code " as text "lla" as error ", " as text "UK" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="UK" if "`chart'"=="wsa"
	if _rc {
		di as error "For chart code " as text "wsa" as error ", " as text "UK" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="UK" if "`chart'"=="bfa"
	if _rc {
		di as error "For chart code " as text "bfa" as error ", " as text "UK" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="US" | "`version'"=="WHO" if "`chart'"=="wl"
	if _rc {
		di as error "For chart code " as text "wl" as error ", " as text "US and WHO" as error " are the only valid versions"
		exit 198
	}
	capture assert "`version'"=="US" | "`version'"=="WHO" if "`chart'"=="wh"
	if _rc {
		di as error "For chart code " as text "wh" as error ", " as text "US and WHO" as error " are the only valid versions"
		exit 198
	}
	capture assert "`version'"=="WHO" if "`chart'"=="aca"
	if _rc {
		di as error "For chart code " as text "aca" as error ", " as text "WHO" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="WHO" if "`chart'"=="ssa"
	if _rc {
		di as error "For chart code " as text "ssa" as error ", " as text "WHO" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="WHO" if "`chart'"=="tsa"
	if _rc {
		di as error "For chart code " as text "tsa" as error ", " as text "WHO" as error " is the only valid version"
		exit 198
	}
	capture assert "`version'"=="US" if "`chart'"=="la"
	if _rc {
		di as error "For chart code " as text "la" as error ", " as text "US" as error " is the only valid version"
		exit 198
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


	if "`forage'"=="1" {
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
	}

	if "`chart'"=="lla" {
		local lmsfile zllageuk.dta
	}
	else if "`chart'"=="sha" {
		local lmsfile zshtageuk.dta
	}
	else if "`chart'"=="wsa" {
		local lmsfile zwsageuk.dta
	}
	else if "`chart'"=="bfa" {
		local lmsfile zbfageuk.dta
	}
	else if "`chart'"=="aca" {
		local lmsfile zacagewho.dta
	}
	else if "`chart'"=="ssa" {
		local lmsfile zssagewho.dta
	}
	else if "`chart'"=="tsa" {
		local lmsfile ztsagewho.dta
	}
	else if "`chart'"=="la" {
		local lmsfile zlenageius.dta
	}
	else if "`chart'"=="hca" & "`version'"=="UK" {
		local lmsfile zhcageuk.dta
	}
	else if "`chart'"=="hca" & "`version'"=="US" {
		local lmsfile zhcageius.dta
	}
	else if "`chart'"=="hca" & "`version'"=="WHO" {
		local lmsfile zhcagewho.dta
	}
	else if "`chart'"=="hca" & "`version'"=="UKWHOpreterm" {
		local lmsfile zhcageukwhopreterm.dta
	}
	else if "`chart'"=="hca" & "`version'"=="UKWHOterm" {
		local lmsfile zhcageukwhoterm.dta
	}
	else if "`chart'"=="ba" & "`version'"=="UK" {
		local lmsfile zbmiageuk.dta
	}	
	else if "`chart'"=="ba" & "`version'"=="US" {
		local lmsfile zbmiageus.dta
	}	
	else if "`chart'"=="ba" & "`version'"=="WHO" {
		local lmsfile zbmiagewho.dta
	}
	else if "`chart'"=="ba" & "`version'"=="UKWHOpreterm" {
		local lmsfile zbmiageukwhopreterm.dta
	}
	else if "`chart'"=="ba" & "`version'"=="UKWHOterm" {
		local lmsfile zbmiageukwhoterm.dta
	}
	else if "`chart'"=="wa" & "`version'"=="UK" {
		local lmsfile zwtageuk.dta
	}
	else if "`chart'"=="wa" & "`version'"=="US" {
		local lmsfile zwtagecomus.dta
	}
	else if "`chart'"=="wa" & "`version'"=="WHO" {
		local lmsfile zwtagewho.dta
	}
	else if "`chart'"=="wa" & "`version'"=="UKWHOpreterm" {
		local lmsfile zwtageukwhopreterm.dta
	}
	else if "`chart'"=="wa" & "`version'"=="UKWHOterm" {
		local lmsfile zwtageukwhoterm.dta
	}
	else if "`chart'"=="ha" & "`version'"=="UK" {
		local lmsfile zhtageuk.dta
	}
	else if "`chart'"=="ha" & "`version'"=="US" {
		local lmsfile zhtageus.dta
	}
	else if "`chart'"=="ha" & "`version'"=="WHO" {
		local lmsfile zlhagewho.dta
	}
	else if "`chart'"=="ha" & "`version'"=="UKWHOpreterm" {
		local lmsfile zlhtageukwhopreterm.dta
	}
	else if "`chart'"=="ha" & "`version'"=="UKWHOterm" {
		local lmsfile zlhtageukwhoterm.dta
	}
	else if "`chart'"=="wh" & "`version'"=="US" {
		local lmsfile zwthtus.dta
	}
	else if "`chart'"=="wh" & "`version'"=="WHO" {
		local lmsfile zwthtwho.dta
	}
	else if "`chart'"=="wl" & "`version'"=="US" {
		local lmsfile zwtlenius.dta
	}
	else if "`chart'"=="wl" & "`version'"=="WHO" {
		local lmsfile zwtlenwho.dta
	}

	qui findfile `lmsfile'
	local fn "`r(fn)'"
	use "`fn'",clear
	qui levelsof __SVJCKHxmrg, local(levels)
	restore, preserve

	tempvar t tday xvarfrac l m s y0 y1 y2 y3 t0 t1 t2 t3

	foreach x in sex agegp xmrg xvar_pre l_pre m_pre s_pre xvar l m s xvar_nx l_nx m_nx s_nx /*
	*/xvar_nx2 l_nx2 m_nx2 s_nx2 merge {
		capture confirm new var __SVJCKH`x'
		if _rc {
			di as error "__SVJCKH`x' is used by zanthro - rename your variable"
			exit 110
		}
	}

	marksample touse

	quietly { 
		if "`y'" == "str" {
			gen byte __SVJCKHsex=1 if `gender'=="`male'"
			replace __SVJCKHsex=2 if `gender'=="`female'"
		}
		else {
			gen byte __SVJCKHsex=1 if `gender'==`male'
			replace __SVJCKHsex=2 if `gender'==`female'
		}
		
		if "`ageunit'"=="month" {
			gen float `t'=`xvar'/12
			gen float `tday'=`xvar'*(365.25/12)*10000
		}
		else if "`ageunit'"=="week" {
			gen float `t'=`xvar'/(365.25/7)
			gen float `tday'=`xvar'*7*10000
		}
		else if "`ageunit'"=="day" {
			gen float `t'=`xvar'/365.25
			gen float `tday'=`xvar'*10000
		}
		else {
			gen float `t'=`xvar'
			gen float `tday'=`xvar'*365.25*10000
		}

		if "`gestage'"~="" {
			su `gestage'
			local gestmax=r(max)
			if `gestmax'>42 {
				noi di as err "WARNING: Maximum value in your gestational age variable is `gestmax' weeks."
			}
			replace `t'=`t'+(`gestage'-40)*7/365.25
			replace `tday'=`tday'+(`gestage'-40)*7*10000
		}

		gen float __SVJCKHxmrg=.
		local levs : word count `levels'
		local levsminus1 = `levs' - 1
		forvalues i = 1/`levsminus1' {
			local j = `i' + 1
			local current : word `i' of `levels'
			local next : word `j' of `levels'
			replace __SVJCKHxmrg=`current' if `tday'>=`current' & `tday'<`next'
			*Separate command required for the maximum value in growth chart.
			replace __SVJCKHxmrg=`next' if `tday'==`next'
		}

		*The length/height-for-age and BMI-for-age WHO charts have parameters for age 2 from 
		*the 0-2 and 2-5 year charts. Where age=2 years, using the parameters from the 2-5 year 
		*chart. 
		if ("`chart'"=="ha" | "`chart'"=="ba") & "`version'"=="WHO" {
		    gen byte __SVJCKHagegp=1 if `t'<2
			replace __SVJCKHagegp=2 if `t'>=2
			sort __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg
			merge __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg using "`fn'", _merge(__SVJCKHmerge)
		}
		*The UK-WHO charts have duplicated parameters for ages 2 weeks, 2 years and 4 years. 
		*These were copied from LMSgrowth. When sorted by __SVJCKHsex, __SVJCKHagegp and __SVJCKHage,
		*the chart is sorted in the LMSgrowth order. For the duplicated ages, when a child is exactly
		*that age, the parameters of the older age group are used.
		else if "`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm" {
		    gen byte __SVJCKHagegp=1 if `tday'<140000
			replace __SVJCKHagegp=2 if `tday'>=140000 & `t'<2
			replace __SVJCKHagegp=3 if `t'>=2 & `t'<4
			replace __SVJCKHagegp=4 if `t'>=4	
			sort __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg		
			merge __SVJCKHsex __SVJCKHagegp __SVJCKHxmrg using "`fn'", _merge(__SVJCKHmerge)
		}
		else  {
			sort __SVJCKHsex __SVJCKHxmrg
			merge __SVJCKHsex __SVJCKHxmrg using "`fn'", _merge(__SVJCKHmerge)
		}

		su __SVJCKHxvar if __SVJCKHmerge~=1, meanonly
		local minyr=r(min)
		local maxyr=r(max)
		su __SVJCKHxmrg if __SVJCKHmerge~=1, meanonly
		local min=r(min)
		local max=r(max)
		su __SVJCKHxmrg if __SVJCKHmerge~=1 & __SVJCKHxmrg>`min' & __SVJCKHxmrg<`max', meanonly
		local min2=r(min)
		local max2=r(max)
		drop if __SVJCKHmerge==2

		gen `xvarfrac' = (`t'-__SVJCKHxvar)/(__SVJCKHxvar_nx-__SVJCKHxvar) if `touse' & __SVJCKHmerge==3 & /*
				*/`tday'>`min' & `tday'<`max'

		*Generating variables with short names to condense the interpolation formulae.
		gen `t0'=__SVJCKHxvar_pre
		gen `t1'=__SVJCKHxvar
		gen `t2'=__SVJCKHxvar_nx
		gen `t3'=__SVJCKHxvar_nx2
		forval i=0/3 {
			gen `y`i''=.
		}

		foreach y in l m s {
			gen ``y''=.

			*Cubic interpolation
			replace `y0'=__SVJCKH`y'_pre if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace `y1'=__SVJCKH`y' if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace `y2'=__SVJCKH`y'_nx if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace `y3'=__SVJCKH`y'_nx2 if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3
			replace ``y'' = (`y0'*(`t'-`t1')*(`t'-`t2')*(`t'-`t3'))/((`t0'-`t1')*(`t0'-`t2')*(`t0'-`t3')) + /*
					    */(`y1'*(`t'-`t0')*(`t'-`t2')*(`t'-`t3'))/((`t1'-`t0')*(`t1'-`t2')*(`t1'-`t3')) + /*
					    */(`y2'*(`t'-`t0')*(`t'-`t1')*(`t'-`t3'))/((`t2'-`t0')*(`t2'-`t1')*(`t2'-`t3')) + /*
					    */(`y3'*(`t'-`t0')*(`t'-`t1')*(`t'-`t2'))/((`t3'-`t0')*(`t3'-`t1')*(`t3'-`t2')) /*
					    */if `tday'>`min2' & `tday'<`max2' & `touse' & __SVJCKHmerge==3

			*Linear interpolation for first segment and last segment.
			replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
					*/((`tday'>`min' & `tday'<`min2') | (`tday'>`max2' & `tday'<`max'))
			
			*Some head circumference charts end at 18 years for males and 17 years for females. For these
			*charts extra code is required so that a linear rather than cubic interpolation is done on the
			*last segment for females: 16 years, 11 months to 17 years.
			if "`chart'"=="hca" & ("`version'"=="UK" | "`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm") {
				su __SVJCKHxmrg if __SVJCKHxvar==17
				assert r(min)==r(max)
				local age17y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<17
				local age16y11m=r(max)
				replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
				*/`tday'>`age16y11m' & `tday'<`age17y' & __SVJCKHsex==2
			}
			
			*Linear interpolation for the length/height-for-age and BMI-for-age WHO charts at the segments
			*around age=2. There are parameters for age=2 from the 0-2 and 2-5 year charts, which need to be
			*split. Using linear interpolation because these are the last segment of the 0-2 year chart and 
			*the first segment of the 2-5 year chart.
			if ("`chart'"=="ha" | "`chart'"=="ba") & "`version'"=="WHO" {
				su __SVJCKHxmrg if __SVJCKHxvar==2
				assert r(min)==r(max)
				local age2y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<2
				local age1y11m=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>2
				local age2y1m=r(min)		
				replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
				*/`tday'>`age1y11m' & `tday'<`age2y1m' & `tday'!=`age2y'
			}
			
			*Linear interpolation for the UK-WHO charts at the segments around ages 2 weeks, 2 years and
			*4 years. Using linear interpolation because the last segment of one chart and the first segment
			*of another occur at these ages.
			if "`version'"=="UKWHOpreterm" | "`version'"=="UKWHOterm" {
				*Around 2 weeks:
				su __SVJCKHxmrg if __SVJCKHxvar>0.03 & __SVJCKHxvar<0.04
				assert r(min)==r(max)
				local age2w=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<0.03
				local age1w=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>0.04
				local age3w=r(min)
				*Around 2 years:
				su __SVJCKHxmrg if __SVJCKHxvar==2
				assert r(min)==r(max)
				local age2y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<2
				local age1y11m=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>2
				local age2y1m=r(min)		
				*Around 4 years:
				su __SVJCKHxmrg if __SVJCKHxvar==4
				assert r(min)==r(max)
				local age4y=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar<4
				local age3y11m=r(max)
				su __SVJCKHxmrg if __SVJCKHxvar>4
				local age4y1m=r(min)
				replace ``y'' = __SVJCKH`y'+`xvarfrac'*(__SVJCKH`y'_nx-__SVJCKH`y') if `touse' & __SVJCKHmerge==3 & /*
				*/((`tday'>`age1w' & `tday'<`age3w' & `tday'!=`age2w') | /*
				*/(`tday'>`age1y11m' & `tday'<`age2y1m' & `tday'!=`age2y') | /*
				*/(`tday'>`age3y11m' & `tday'<`age4y1m'& `tday'!=`age4y'))
			}
			
			*No interpolation required if age equals the age on the growth chart.
			replace ``y'' = __SVJCKH`y' if `tday'==__SVJCKHxmrg & `touse' & __SVJCKHmerge==3
		}

		gen `type' `g' = (((`measure'/`m')^`l')-1)/(`l'*`s') if `t'>=`minyr'-0.00000001 & `t'<=`maxyr'+0.00000001 & `touse'
		replace `g'=. if `measure'<=0
		if "`nocutoff'"=="" {
			replace `g'=. if abs(`g')>=5 & `g'<.
		}

		drop __SVJCKHsex __SVJCKHxmrg __SVJCKHxvar_pre __SVJCKHxvar  __SVJCKHxvar_nx __SVJCKHxvar_nx2 __SVJCKHl_pre /*
		*/__SVJCKHl __SVJCKHl_nx __SVJCKHl_nx2 __SVJCKHm_pre __SVJCKHm __SVJCKHm_nx __SVJCKHm_nx2 /*
		*/__SVJCKHs_pre  __SVJCKHs __SVJCKHs_nx __SVJCKHs_nx2 __SVJCKHmerge
		if (("`chart'"=="ha" | "`chart'"=="ba") & "`version'"=="WHO") | "`version'"=="UKWHOpreterm" | /*
		*/"`version'"=="UKWHOterm" {
		    drop __SVJCKHagegp
		}
	}

	quietly count if `g'<. & `touse'
	if r(N) { 
		local s = cond(r(N)>1,"s","")
		di as text "(Z value`s' generated for " r(N) " case`s') " 
		di as text "(gender was assumed to be coded male=`male', female=`female')"
		if "`forage'"=="1" {
			di as text "(age was assumed to be in `ageunit's)"
		}
	}

	quietly count if `g'==. & `touse'
	if r(N) { 
		if "`gestage'"~="" {
			if "`nocutoff'"=="" {
				di as text "(Z values can be missing because age is nonpositive or otherwise" 
				di as text " out of range for the chart code, the gender variable is missing,"
				di as text " gestation age is missing or places corrected age out of range"
				di as text " for the chart code, or the Z value has an absolute value >=5)"
			}
			else {
				di as text "(Z values can be missing because age is nonpositive or otherwise"
				di as text " out of range for the chart code, the gender variable is missing," 
				di as text " or gestation age is missing or places corrected age out of range"
				di as text " for the chart code)"
			}
		}
		else {
			if "`nocutoff'"=="" {
				di as text "(Z values can be missing because xvar is nonpositive or otherwise" 
				di as text " out of range for the chart code, the gender variable is missing,"
				di as text " or the Z value has an absolute value >=5)"
			}
			else {
				di as text "(Z values can be missing because xvar is nonpositive or otherwise"
				di as text " out of range for the chart code, or the gender variable is missing)" 
			}
		}
	}

	restore,not

end

program Badsyntax
	di as err "gencode() option invalid: see {help zanthro}"
	exit 198
end
