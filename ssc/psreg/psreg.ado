capture program drop psreg
* version 1.0 M.Bazzoli, S. De Poli, D.Piazzalunga

program define psreg, rclass
	version 15
	syntax varlist(min=1 fv) [if] [in] [, QUIetly LOGIT GROUPS(string) COMmon ATE]

	quietly{
	gettoken y zvars: varlist
	display "y contains: " "`y'"
	display "zvars contains: " "`zvars'"
	display "varlist contains: " "`varlist'"
	gettoken t xvars: zvars
	display "y contains: " "`y'"
	display "t contains: " "`t'"
	display "xvars contains: " "`xvars'"


	tempvar _pscore comune lor n ltot lm diff2 totdiff s2 f_yn baseline baseline0 block var5 nblocktr meth _order
	local out `y'
	global variabili `xvars'
	global t_i `t'

	// clean up data
	foreach v in  _blockgroup _common _treated {
		cap drop `v'
	}	

	// record sort order
	gen long `_order'= _n

	preserve
       	tempvar sample
	if ("`ate'"=="") gen `sample'=$t_i
	if ("`ate'"!="") gen `sample'=1

	if ("`logit'"=="") probit  $t_i $variabili
	if ("`logit'"!="") logit $t_i $variabili
	predict `_pscore'

	// determine subset we work on 
	marksample touse
	qui keep if `touse'  
	
	
	drop `_pscore' `sample'
	tempvar sample
	if ("`ate'"=="") gen `sample'=$t_i
	if ("`ate'"!="") gen `sample'=1

	if ("`logit'"=="") probit  $t_i $variabili
	if ("`logit'"!="") logit $t_i $variabili
	predict `_pscore'
	
	sum `_pscore' if $t_i==0
	if ("`common'"!="") drop if `_pscore'<r(min) & $t_i==1 
	sum `_pscore' if $t_i==0
	if ("`common'"!="") drop if `_pscore'>r(max) & $t_i==1
	sum `_pscore' if $t_i==1
	if ("`ate'"!="") & ("`common'"!="") drop if `_pscore'<r(min) & $t_i==0
	sum `_pscore' if $t_i==1
	if ("`ate'"!="") & ("`common'"!="") drop if `_pscore'>r(max) & $t_i==0
	gen  `comune'=1
	
	}
	quietly if ("`groups'"=="") {  
	global ncova=e(rank)-1

	

	//common support
		


	//estimate log odds ratio
	gen `lor'=ln(`_pscore'/(1 - `_pscore'))                                                                                        

	// create vars we will need
	bys $t_i: gen `n'=_N
	bys $t_i: egen `ltot'=total(`lor')
	gen `lm'=`ltot'/`n'
	gen `diff2'=(`lor'-`lm')^2
	bys $t_i:egen `totdiff'=total(`diff2')
	gen `s2'=(1/(`n'-1))*`totdiff'

	sum `lm' if $t_i==0
	scalar _lcm=r(mean)
	sum `lm' if $t_i==1
	scalar _ltm=r(mean)

	sum `s2' if $t_i==0
	scalar sc2=r(mean)
	sum `s2' if $t_i==1
	scalar st2=r(mean)

	sum `n' if $t_i==1
	scalar nt=r(mean)
	sum `n' if $t_i==0
	scalar nc=r(mean)

	// t statistic
	scalar test=(_ltm-_lcm)/(sqrt(st2/nt+sc2/nc))

	// number of treated and controls in each block
	sum `_pscore' if `sample'==1,d
	scalar median=r(p50)
	sum `_pscore' if `_pscore'<median & $t_i==1
	scalar nt1=r(N)
	sum `_pscore' if `_pscore'>=median & $t_i==1
	scalar nt2=r(N)
	sum `_pscore' if `_pscore'<median & $t_i==0
	scalar nc1=r(N)
	sum `_pscore' if `_pscore'>=median & $t_i==0
	scalar nc2=r(N)

	scalar minn=min(nc1, nc2, nt1, nt2)
	scalar mingroup=min(nc1+nt1, nc2+nt2)	

	// 3 tests
	gen `f_yn'=1 if   test>1.96 & minn>3 & mingroup>($ncova+2) 
	gen `baseline'=1

	drop   `n' `ltot' `lm' `diff2' `totdiff' `s2'
	scalar drop _all

	
	********************************
	*	Loop
	********************************
	local conta=0
	forvalues c=1(1)10000{
		sum `f_yn' 
		if r(mean)!=. {
				egen `block'=group(`baseline') if `f_yn'!=.
				gen `var5'=.
				sum `block'
				local max=r(max)
				forvalues i=1(1)`max'{
				sum `_pscore' if `block'==`i' & `sample'==1,d
				replace `var5'=1 if `_pscore'<r(p50) &  `block'==`i'
				replace `var5'=2 if `_pscore'>=r(p50) &  `block'==`i'
				}
			rename `baseline' `baseline0'
			egen `baseline'=group( `baseline0' `var5'),miss
			drop `baseline0' `var5' `block'
			egen `block'=group( `baseline' ) if `f_yn'!=.

			bys $t_i `block': gen `n'=_N
			bys $t_i `block': egen `ltot'=total(`lor')
			gen `lm'=`ltot'/`n'
			gen `diff2'=(`lor'-`lm')^2
			bys $t_i `block':egen `totdiff'=total(`diff2')
			gen `s2'=(1/(`n'-1))*`totdiff'

			sum `block'
			local max=r(max)
			forvalues i=1(1)`max'{
				sum `lm' if $t_i==0 & `block'==`i'
				scalar _lcm`i'=r(mean)
				sum `lm' if $t_i==1 & `block'==`i'
				scalar _ltm`i'=r(mean)

				sum `s2' if $t_i==0 & `block'==`i'
				scalar sc2`i'=r(mean)
				sum `s2' if $t_i==1 & `block'==`i'
				scalar st2`i'=r(mean)

				sum `n' if $t_i==1 & `block'==`i'
				scalar nc`i'=r(mean)
				sum `n' if $t_i==0 & `block'==`i'
				scalar nt`i'=r(mean)

				// t statistic
				scalar test`i'=(_ltm`i'-_lcm`i')/(sqrt(st2`i'/nt`i'+sc2`i'/nc`i'))
				di test`i'
				replace `f_yn'=. if abs(test`i')<=1.96  &  `block'==`i'
				
				// number of treated and controls in each block
				sum `_pscore' if $t_i==1 & `block'==`i',d
				scalar median=r(p50)
				sum `_pscore' if `_pscore'<median & $t_i==1 & `block'==`i'
				scalar nt_1=r(N)
				sum `_pscore' if `_pscore'>=median & $t_i==1 & `block'==`i'
				scalar nt_2=r(N)
				sum `_pscore' if `_pscore'<median & $t_i==0 & `block'==`i'
				scalar nc_1=r(N)
				sum `_pscore' if `_pscore'>=median & $t_i==0 & `block'==`i'
				scalar nc_2=r(N)
				scalar minn`i'=min(nc_1, nc_2, nt_1, nt_2)
				scalar mingroup`i'=min(nc_1+nt_1, nc_2+nt_2)

				//3 tests
				replace `f_yn'=. if   (minn`i'<3 | mingroup`i'<($ncova+2)) &  `block'==`i'
				scalar drop nc_1 nc_2 nt_1 nt_2 median nc`i' nt`i' st2`i'  sc2`i' _ltm`i' _lcm`i'
			}

			scalar list 
			di $ncova
			scalar drop _all
			drop `block'  `n' `ltot' `lm' `diff2' `totdiff' `s2'
			local conta=`conta'+1

		}
			else continue,break  
	}

	sum `sample' if `sample'==1
	scalar nden=r(N)

	bys $t_i: gen `n'=_N
	sum `n' if $t_i==1
	local nt=r(mean)
	sum `n' if $t_i==0
	local nc=r(mean)


	bys `baseline': egen `nblocktr'=total(`sample')

	sum `baseline'
	local maxbas=r(max)
		forvalues i= 1(1)`maxbas' {
		sum `nblocktr' if `baseline'==`i'
		scalar weight_`i'=r(mean)/nden
		}
		

	if ("`ate'"=="") gen `meth'="ATT" in 1
	if ("`ate'"!="") gen `meth'="ATE" in 1

		tempvar b v z alfa
		gen `b'=0
		gen `v'=0
		forvalues i= 1(1)`maxbas' {
			tempvar b_`i' v_`i'
			regress `out' $t_i $variabili if `baseline'==`i'
			capt matrix b = e(b) 
			gen `b_`i''= b[1,1] 
			replace  `b'= `b'+`b_`i''*weight_`i' 
			capt matrix v = e(V) 
			gen `v_`i''= v[1,1] 
			replace  `v'= `v'+`v_`i''*(weight_`i')^2  
			drop `b_`i'' `v_`i''
		}
		
	replace `v'=sqrt(`v')

	gen `z'=`b'/`v'
	gen `alfa'=(1-normal(abs(`z')))*2
	replace `alfa'=round(`alfa',0.001)

	lab var `meth' "`out'"
	label var `b' "Coef."
	label var `v' "St. error"
	label var `z' "t"
	label var `alfa' "P(|t|>0)"
	replace `z'=round(`z',0.01)
	}

	******************************************
	// BRA if number of groups defined
	******************************************
	quietly if ("`groups'"!=""){
	capt	xtile `baseline'=`_pscore', n(`groups')
	capt gen	`baseline'=1
	sum `sample' if `sample'==1
	scalar nden=r(N)

		bys $t_i: gen `n'=_N
		sum `n' if $t_i==1
		local nt=r(mean)
		sum `n' if $t_i==0
		local nc=r(mean)

		bys `baseline': egen `nblocktr'=total(`sample')

		sum `baseline'
		local maxbas=r(max)
			forvalues i= 1(1)`maxbas' {
			sum `nblocktr' if `baseline'==`i'
			scalar weight_`i'=r(mean)/nden
			}
		

		if ("`ate'"=="") gen `meth'="ATT" in 1
		if ("`ate'"!="") gen `meth'="ATE" in 1
		
		tempvar b v z alfa
		gen `b'=0
		gen `v'=0
		forvalues i= 1(1)`maxbas' {
			tempvar b_`i' v_`i'
			regress `out' $t_i $variabili if `baseline'==`i'
			capt matrix b = e(b) 
			gen `b_`i''= b[1,1] 
			replace  `b'= `b'+`b_`i''*weight_`i' 
			capt matrix v = e(V) 
			gen `v_`i''= v[1,1] 
			replace  `v'= `v'+`v_`i''*(weight_`i')^2 
			drop `b_`i'' `v_`i''
		}
		
		replace `v'=sqrt(`v')
	
		gen `z'=`b'/`v'
		gen `alfa'=(1-normal(abs(`z')))*2
		replace `alfa'=round(`alfa',0.001)

		lab var `meth' "`out'"
		label var `b' "Coef."
		label var `v' "St. error"
		label var `z' "t"
		label var `alfa' "P(|t|>0)"
		replace `z'=round(`z',0.01)
	}


	//Store results
	qui  sum `v' in 1
	if ("`ate'"=="") return scalar seatt=r(mean)
	if ("`ate'"!="") return scalar seate=r(mean)
	qui  sum `b' in 1
	if ("`ate'"=="") return scalar att=r(mean)
	if ("`ate'"!="") return scalar ate=r(mean)
	return scalar n_t=`nt'
	return scalar n_c=`nc'
	qui sum `baseline'
	return scalar blocks=r(max)

	qui gen _bragroup=`baseline'


	// show regressions for each group
	if ("`quietly'"=="") qui sum `baseline'
	if ("`quietly'"=="") local maxbas=r(max)
	if ("`quietly'"=="") forvalues i= 1(1)`maxbas' {
		qui noi di as text "{hline 28}"
		qui noi di as text "Group `i'"
		qui noi di as text "{hline 28}"
		regress `out' $t_i $variabili if `baseline'==`i'
}


       

	// clean
	keep `meth' `b' `v' `z' `alfa' `_order' `baseline' `comune' 

	// Output table
	tabdisp `meth' if _n==1, cell(`b' `v' `z' `alfa') 
	noi di "Number of treated  =  `nt'"
	noi di "Number of controls  =  `nc'"
	noi di "Number of intervals =  `maxbas'"

quietly{ 
	tempfile formerge
	gen _blockgroup=`baseline'
	*DP: modificate le due righe successive
	gen _common=`comune'
 	keep `_order' _blockgroup _common 
	save `formerge', replace
}
	ereturn clear
	restore

quietly{
	merge 1:1 `_order' using `formerge'
        drop _merge
	marksample touse
	if ("`logit'"=="") probit  $t_i $variabili if `touse'==1
	if ("`logit'"!="") logit $t_i $variabili if `touse'==1
	predict `_pscore'
	replace `_pscore'=. if `touse'!=1 
	if ("`common'"!="") replace _common=0 if _common==. & `_pscore'!=.
	if ("`common'"!="") replace _common=. if `out'==.
	capt label drop _common  
	capt label drop _treated 
	capt label drop _blockgroup
	label var _common "psreg: Common support"
	label def _common 1 "On support" 0"Off support"
	label val _common _common
	gen _treated=$t_i 
	replace _treated=. if `out'==. 
	label var _treated "psreg: Treatment assignment"
	label def _treated 1 "Treated" 0"Untreated"
	label val _treated _treated
	label var _blockgroup "psreg: Blocks"	
}
if ("`common'"!="") tab  _treated _common
end
