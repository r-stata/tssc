*******************************************************
*Human Opportunity Index (hoishapley)
*Alejandro Hoyos
*v1.1 - June 2013 - I modified the function to find the constant of the logit.
*******************************************************
capture program drop hoishapley
program define hoishapley, rclass
	
	version 10.1

	syntax 	varlist(max=1)				///
			[in] [if]					///
			[aweight fweight iweight]	///
			[,							///
			eliminate					///
			fix							///
			filehoi(string)				///
			fileshapley(string)			///
			format(string)				///
			shapleyc(string)			///
			shapley(string)				///
			globals						///
			adjust1(string)				///
			controls(string)			///
			simulated					///
			]

	quietly{
	tokenize `varlist'
	local vardep `1'

	tempfile originaldata
	save `originaldata', replace

	*** Limited the sample ***
	marksample touse
	markout `touse' `vardep'

	
	if("`shapleyc'"!=""){
		markout `touse' `shapleyc'
	}

	if("`shapley'"!=""){
		if("`globals'"!=""){
			gen set_cc="`shapley'"
			local indepcat = "`shapley'"

			foreach x of local indepcat{
				replace set_cc=subinword(set_cc,"`x'","$"+"`x'",1)
			}

			local set_cc = set_cc[1]

			drop set_cc
			markout `touse' `set_cc'
		}
		if("`globals'"==""){
			markout `touse' `shapley'
		}
	}
	if("`controls'"!=""){
		markout `touse' `controls'
	}

	if("`weight'" == "") {
		tempname wtg
		gen `wtg' = 1
		loc weight "fw"
		loc exp    "=`wtg'"
	}
	
	local exp2 = subinstr("`exp'","=","",.)

	if("`shapleyc'"!=""){
		local setcat = "`shapleyc'"

		foreach x in `shapleyc'{
			tab `x' if `touse', g(_`x'_)
			drop _`x'_1
			local setcat= subinword("`setcat'","`x'","_`x'_*",1)
		}
	}

	if("`shapley'"!="" & "`shapleyc'"==""){
		local indepvar "`shapley'"
		local indepcat "`shapley'"
	}

	if("`shapley'"!="" & "`shapleyc'"!=""){
		local indepvar "`shapley' `setcat'"
		local indepcat "`shapley' `shapleyc'"
	}

	if("`shapley'"=="" & "`shapleyc'"!=""){
		local indepvar "`setcat'"
		local indepcat "`shapleyc'"
	}

	sum `vardep' [`weight'`exp'] if `touse'
	local _realcoverage = r(mean)

	preserve
	if("`globals'"!=""){
		cap drop set_b
		gen set_b="`indepvar'"
		foreach x of local indepcat{
			replace set_b=subinword(set_b,"`x'","$"+"`x'",1)
		}
		local set_b = set_b[1]

		logit `vardep' `set_b' `controls' [pw=`exp2'] if `touse', asis
	}
	
	if("`globals'"==""){
		logit `vardep' `indepvar' `controls' [pw=`exp2'] if `touse', asis
	}

	if("`simulated'"!="" | "`adjust1'"==""){
		cap drop _predprob
		cap drop _reldev
	
		adjust `adjust1' if e(sample), pr gen(_predprob)
	}

	if("`simulated'"=="" & "`adjust1'"!=""){
		noisily display in green "Note: You chose to adjust the intercept of the logit, it will take some time, be patient!"
		cap drop _predprob
		cap drop _reldev
		cap drop _predprob_a
		cap drop _cov_fix
		cap drop z_adj
	
		gen cov_fix=`_realcoverage' if `touse'

		adjust `adjust1' if e(sample), pr gen(_predprob_a)

		sort _predprob_a
		
		constant_logit cov_fix _predprob_a [`weight'`exp'] if `touse'

		gen z_adj = ln((1- _predprob_a)/_predprob_a)  if `touse'
		
		local _calpha =r(alpha)

		gen _predprob=1/(1+exp(z_adj+`_calpha'))  if `touse'
	}

	
	sum _predprob [`weight'`exp'] if `touse'
	local _pcove= r(mean)

	gen _reldev=abs(_predprob-`_pcove') if `touse'

	sum _reldev [`weight'`exp'] if `touse'
	local _penaltyhoi = r(mean)
	local _penaltyhoi = `_penaltyhoi'/2
	local _hoi = `_pcove' - `_penaltyhoi'
	local _Dindex = `_penaltyhoi'/`_pcove'
	restore

	local kk = wordcount("`indepcat'")
	tokenize "`indepcat'"

	preserve
	clear
	set obs `kk'
	gen circum=""

	tempfile circumstances
	forvalues i=1(1)`kk'{
		replace circum="``i''" in `i'
	}
	save "`circumstances'", replace

	forvalues i=1(1)`kk'{
		tempfile circumstances`i'
		clear
		use `circumstances'
		rename circum circum`i'
		save "`circumstances`i''", replace
	}

	clear
	use "`circumstances1'"
	forvalues i=2(1)`kk'{
		cross using `circumstances`i''
		local aux=`i'-1
		forvalues j=1(1)`aux'{
			replace circum`i'="" if circum`i'==circum`j'
		}
		duplicates drop

		catenate set = circum1 - circum`i'
		replace set=itrim(set)
		replace set=trim(set)
		replace set=" " + set + " "
		
		foreach x of local indepcat{
			gen `x'_a=strpos(set," `x' ")
			gen `x'=(`x'_a>0) if `x'_a!=.
			drop `x'_a
		}
	
		egen id=group(`indepcat')
		bys id: gen times=_n
		keep if times==1
		drop set `indepcat' times id
	}

	count
	local ncomb=r(N)

	catenate set = circum1 - circum`kk'
	replace set=itrim(set)
	replace set=trim(set)
	replace set=" " + set + " "

	foreach x of local indepcat{
		gen `x'_a=strpos(set," `x' ")
		gen `x'=(`x'_a>0) if `x'_a!=.
		drop `x'_a
	}
	drop set
	catenate set = circum1 - circum`kk'
	replace set=itrim(set)
	replace set=trim(set)
	
	local h = `ncomb'+1
	set obs `h'

	foreach x of local indepcat{
		replace `x' = 0 if set==""
	}

	forvalues i=1(1)`h'{
		if("`shapleyc'"!=""){
			foreach x in `shapleyc'{
				replace set = subinword(set,"`x'","_`x'_*",1)
			}
		}
		local set`i' = set[`i']

	}
	
	drop circum*
	sort set

	save "`circumstances'", replace
	restore

	if("`globals'"!=""){
		cap drop set_b
		gen set_b="`indepvar'"
		foreach x of local indepcat{
			replace set_b=subinword(set_b,"`x'","$"+"`x'",1)
		}
		local set_b = set_b[1]

		logit `vardep' `set_b' `controls' [pw=`exp2'] if `touse', asis
	}
	
	if("`globals'"==""){
		logit `vardep' `indepvar' `controls' [pw=`exp2'] if `touse', asis
	}

	forvalues i=1(1)`h'{
		tempfile dindexset`i'
		preserve

		if("`eliminate'"!="" & "`fix'"!=""){
			noisily display in red "You must choose only one decomposition method (either eliminate or fix)"
		}
		
		if(("`eliminate'"=="" & "`fix'"=="") | ("`eliminate'"!="" & "`fix'"=="")){											// Starts option ELIMINATE
			if("`globals'"!=""){
				gen set_a="`set`i''"
				foreach x of local indepcat{
					replace set_a=subinword(set_a,"`x'","$"+"`x'",1)
				}
				local set_a = set_a[1]

				logit `vardep' `set_a' `controls' [pw=`exp2'] if `touse', asis
			}

			if("`globals'"==""){
				local setcat_aux = "`set`i''"

				if("`shapleyc'"!=""){
					foreach x in `shapleyc'{
						local setcat_aux= subinword("`setcat_aux'","`x'","_`x'_*",1)
					}
				}
				logit `vardep' `setcat_aux' `controls' [pw=`exp2'] if `touse', asis
			}
			
			if("`adjust1'"==""){
				cap drop _predprob
				cap drop _reldev
	
				adjust `adjust1' if e(sample), pr gen(_predprob)
			}

			if("`adjust1'"!=""){
				cap drop _predprob
				cap drop _reldev
				cap drop _predprob_a
				cap drop _cov_fix
				cap drop z_adj
	
				gen cov_fix=`_pcove' if `touse'

				adjust `adjust1' if e(sample), pr gen(_predprob_a)

				sort _predprob_a

				constant_logit cov_fix _predprob_a [`weight'`exp'] if `touse'

				gen z_adj = ln((1- _predprob_a)/_predprob_a)  if `touse'
		
				local _calpha =r(alpha)

				gen _predprob=1/(1+exp(z_adj+`_calpha'))  if `touse'
			}
		}																									// Ends Option ELIMINATE

		if("`eliminate'"=="" & "`fix'"!=""){																// Starts Option FIX
			if("`globals'"!=""){
				gen set_a="`indepcat'"
				foreach x of local set`i'{
					replace set_a=subinword(set_a,"`x'"," ",1)
				}
				local set_a = set_a[1]

				foreach x of local set_a{
					replace set_a=subinword(set_a,"`x'","$"+"`x'",1)
				}
				local set_a = set_a[1]

				cap drop _predprob_a
				cap drop _predprob
				cap drop _reldev
				cap drop _cov_fix
				cap drop z_adj
				gen cov_fix=`_pcove' if `touse'

				cap drop set_b
				gen set_b="`indepvar'"
				foreach x of local indepcat{
					replace set_b=subinword(set_b,"`x'","$"+"`x'",1)
				}
				local set_b = set_b[1]

				logit `vardep' `set_b' `controls' [pw=`exp2'] if `touse', asis

				adjust `set_a' `adjust1' if e(sample), pr gen(_predprob_a)
				sort _predprob_a

				constant_logit cov_fix _predprob_a [`weight'`exp'] if `touse'

				gen z_adj = ln((1- _predprob_a)/_predprob_a)  if `touse'
		
				local _calpha =r(alpha)

				gen _predprob=1/(1+exp(z_adj+`_calpha'))  if `touse'
			}

			if("`globals'"==""){
				gen set_a="`indepvar'"

				if("`shapleyc'"!=""){
					local setcat_aux = "`set`i''"

					foreach x in `shapleyc'{
						local setcat_aux= subinword("`setcat_aux'","`x'","_`x'_*",1)
					}
					foreach x of local setcat_aux{
						replace set_a=subinword(set_a,"`x'"," ",1)
					}
				}

				if("`shapleyc'"==""){
					foreach x of local set`i'{
						replace set_a=subinword(set_a,"`x'"," ",1)
					}
				}
				local set_a = set_a[1]

				cap drop _predprob2
				cap drop _predprob_a
				cap drop _predprob
				cap drop _reldev
				cap drop _cov_fix
				cap drop z_adj
				gen cov_fix=`_pcove' if `touse'

				logit `vardep' `indepvar' `controls' [pw=`exp2'] if `touse', asis

				adjust `set_a'  `adjust1' if e(sample), pr gen(_predprob_a)
				sort _predprob_a

				constant_logit cov_fix _predprob_a [`weight'`exp'] if `touse'

				gen z_adj = ln((1- _predprob_a)/_predprob_a)  if `touse'
		
				local _calpha =r(alpha)

				gen _predprob=1/(1+exp(z_adj+`_calpha'))  if `touse'
			}
		}																									// Ends Option FIX
			
		sum _predprob [`weight'`exp'] if `touse'
		local _pcove_`i'= r(mean)
		local _nobs = r(N)

		gen _reldev=abs(_predprob-`_pcove_`i'') if `touse'

		sum _reldev [`weight'`exp'] if `touse'
		local _penaltyhoi_a = r(mean)
		local _penaltyhoi_a = `_penaltyhoi_a'/2
		
		local _hoi_a = `_pcove_`i'' - `_penaltyhoi_a'
		local _Dindex_a = `_penaltyhoi_a'/`_pcove_`i''

		clear
		set obs 1
		gen set="`set`i''"
		gen dindex=`_Dindex_a'
		gen coverage=`_pcove_`i''
		gen observations=`_nobs'
		save `dindexset`i'', replace
		restore
	}
	clear
	set obs 1
	gen a = 1
	forvalues i=1(1)`h'{
		append using `dindexset`i''
	}
	drop if a==1
	drop a
	sort set
	merge set using "`circumstances'"
	drop _merge
	sort `indepcat'
	if("`fileshapley'"!=""){
		save "`fileshapley'.dta", replace
	}
	drop coverage
	foreach x of local indepcat{
		preserve
		local idcircum =  subinword("`indepcat'","`x'"," ",1)
		drop set
		egen byid = group(`idcircum')
		egen sizes=rowtotal(`idcircum')
		reshape wide dindex , i(byid) j(`x')
		replace dindex0 = 0 if dindex0==. & sizes==0
		sum dindex0 if sizes==0
		local _baseD = r(mean)
		gen contr = ((exp(lnfactorial(sizes)))*(exp(lnfactorial(`kk'-sizes-1)))/(exp(lnfactorial(`kk'))))*(dindex1-dindex0)
		sum contr
		local percentage_`x' = 100*r(sum)/(`_Dindex'-`_baseD')
		restore
	}
	
		if ("`filehoi'"!=""){
			tempfile temp
			save `temp', replace
			if ("`format'"=="xls" | "`format'"==""){
				clear
				set obs 5
				gen variable = "Variable" 		in 1
				replace variable = "HOI" 		in 2
				replace variable = "D-index" 		in 3
				replace variable = "Penalty" 		in 4
				replace variable = "Coverage" 	in 5
				gen value = "`vardep'" 			in 1
				replace value = "`_hoi'"		in 2
				replace value = "`_Dindex'"		in 3
				replace value = "`_penaltyhoi'"	in 4
				replace value = "`_pcove'"		in 5
				if ("`shapley'"!="" | "`shapleyc'"!=""){
					local aux = 5+`kk'
					local j=5
					set obs `aux'
					foreach x of local indepcat{
						local j=`j'+1
						replace variable 	= "`x'" 			in `j'
						replace value	= "`percentage_`x''"	in `j'
					}
				}
				outsheet using "`filehoi'.xls", replace
			}

			if ("`format'"=="dta"){
				clear
				set obs 1
				gen variable= "`vardep'"
				gen hoi    	= `_hoi'
				gen dindex 	= `_Dindex'
				gen penalty	= `_penaltyhoi'
				gen coverage= `_pcove'
				if ("`shapley'"!="" | "`shapleyc'"!=""){
					foreach x of local indepcat{
						gen perc`x' = `percentage_`x''
					}
				}
				save "`filehoi'.dta", replace
			}
			if ("`format'"!="dta" & "`format'"!="xls" & "`format'"!=""){
				noisily display in red "Error: you specified an invalid format for the HOI file."
				noisily display in red "Your results have not been saved"
			}
			use `temp', clear
		}

	cap drop _predprob
	cap drop _predprob*
	cap drop _reldev
	cap drop _reldev*
	return scalar hoi 	= `_hoi'
	return scalar dindex 	= `_Dindex'
	return scalar penalty	= `_penaltyhoi'
	return scalar coverage	= `_pcove'
	if ("`shapley'"!="" | "`shapleyc'"!=""){
		foreach x of local indepcat{
			return scalar c_`x'	= `percentage_`x''
		}
	}	
	noisily display in green  "________________________________________________"
	noisily display in yellow "     Human Opportunity Index - `vardep'      "
	noisily display in green  "________________________________________________"
	noisily display in green  "HOI        =" in yellow"`_hoi'"
	noisily display in green  "D-index    =" in yellow"`_Dindex'"
	noisily display in green  "Penalty    =" in yellow"`_penaltyhoi'"
	noisily display in green  "Coverage   =" in yellow"`_pcove'"
	noisily display in green  "________________________________________________"
	if ("`shapley'"!="" | "`shapleyc'"!=""){
		noisily display in yellow "     Shapley decomposition of the D-Index   (Percentage explained by each variable) "
		foreach x of local indepcat{
			noisily display in green  "`x'  = " in yellow"`percentage_`x''"
		}
		noisily display in green  "__________________________________________________________________________________"
	}
	use `originaldata', clear
	}
end

capture program drop constant_logit
program define constant_logit, rclass
    version 10.1
    
    syntax varlist(min=2 max=2) [aweight fweight iweight] [if]
    local _coverage:			word 1 of `varlist'
    local _prob_desadj: 		word 2 of `varlist'

	gen _z_desadj 	= ln((1- `_prob_desadj')/`_prob_desadj')  `if'
	gen _z_adj 		= ln((1- `_coverage')/`_coverage')  		`if'


	sum _z_adj [`weight'`exp']  `if'
	local _z_objective=r(mean)
	
	sum _z_desadj [`weight'`exp'] `if'
	local _z_current=r(mean)
		
	local _alpha=`_z_objective'-`_z_current'
		
	gen _prob_adj=1/(1+exp(_z_desadj+`_alpha')) `if'
		
	sum _prob_adj [`weight'`exp'] `if'
	local _cov_current = r(mean)
	sum `_coverage'	[`weight'`exp'] `if'
	local _cov_objective = r(mean)
	
	local _agap=abs(`_cov_objective'-`_cov_current')
	local _gap=`_cov_objective'-`_cov_current'
	
	local _increment=0.0005
	while `_agap'>0.001 & `_increment'!=1/1000000{
		cap drop _prob_adj
		local _increment=max(1/1000000,`_increment'-uniform()/100000)
		
		if `_gap'>0 {
			local _alpha=`_alpha'-`_increment'
		}
		
		if `_gap'<0 {
			local _alpha=`_alpha'+`_increment'
		}
		
		gen _prob_adj=1/(1+exp(_z_desadj+`_alpha')) `if'
				
		sum _prob_adj [`weight'`exp'] `if'
		local _cov_current = r(mean)
		sum `_coverage'	[`weight'`exp'] `if'
		local _cov_objective = r(mean)
	
		local _agap=abs(`_cov_objective'-`_cov_current') 
		local _gap=`_cov_objective'-`_cov_current'
	}
	return scalar alpha 	= `_alpha'
end
