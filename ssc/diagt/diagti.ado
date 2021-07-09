*! diagti 2.053, 7 April 2004
*! by PT Seed (paul.seed@kcl.ac.uk)
*! Immediate version of diagt,
*! based on diagtest.ado (Aurelio Tobias, STB-56: sbe36)
*
* Likelihood ratios added
* Odds ratios and ROC areas added
* CI based on csi, or

* add 0.5 when zeros appear of with -sf- option when calculating LRs
* bugfix to preserve matrices.

program define diagti , rclass
version 8.0

set trace off

	tokenize "`*'", parse(" ,")
	local i= 1
	while `i' <= 4 {
		confirm integer number ``i'' 
		local i = `i' + 1
	}
	local a = `1'
	local b = `2'
	local c = `3' 
	local d = `4'

	local n1_ = `a' + `b'
	local n2_ = `c' + `d'
	local n_1 = `a' + `c'
	local n_2 = `b' + `d'

	local n = `n_1' + `n_2'
	mac shift 4
	local options "Prev(string)  Level(real $S_level) noTable sf sf0 tb Woolf Bamber Hanley Odds Star dp(integer 1)"
	parse "`*'" 

	if "`prev'" ~= "" {
		local _prev_ "(lr)"
	}

	if "`star'" == "star" {
		local star "di ""
	}
	else {
		local star "*"
	}

	local dp2 = `dp' + 1
	local dp3 = `dp' + 2

`star' tb affects the quantities based on risk ratios: 

	if  index("`prev'", "%") { 
		local prev = real(subinstr("`prev'","%","",1))
		cap assert `prev' >=0 & `prev' < 100
		if _rc {
			di in red "Prevalence must be between 0 and 100%
			exit _rc
		}
	}
	else if "`prev'" ~= ""{
		local prev = `prev'*100
		cap assert `prev' >=0 & `prev' < 100
		if _rc {
			di in red "Prevalence must be between 0 and 100%
			di in red "Percentages must be indicated by ''%'' sign
			exit _rc
		}
	}


	if ((`a'*`b'* `c'*`d' == 0) & ("`sf0'" ~= "")) | ("`sf'" ~= "") {
		local sf "(sf)"
		local sk_sf = 1
		local tb 
		local woolf
* NOTE: sf overrides tb and woolf
	}
	else {
		local sk_sf = 0
		if "`tb'" ~= "" {
			local _tb_ "(tb)"
			local _woolf_ "(tb)"
		}

		if "`woolf'" ~= "" {
			local _woolf_ "(Woolf)"
		}
	}

* set trace on 

`star' Prevalence
	if "`_prev_'" == ""{
		qui cii `n' `n1_', level(`level')
		local prev = 100*r(mean)
		local prev_lb = 100*r(lb)
		local prev_ub = 100*r(ub)
	}

`star' Sensitivity
	qui cii `n1_' `a' , level(`level')
	local sens = 100*r(mean)
	local sens_lb = 100*r(lb)
	local sens_ub = 100*r(ub)

`star' Specificity
	qui cii `n2_' `d', level(`level')
	local spec = 100*r(mean)
	local spec_lb = 100*r(lb)
	local spec_ub = 100*r(ub)

`star' Without substitution formula
	if "`sf'" == "" {
		qui csi `a' `c' `b' `d' , or `tb' `woolf' level(`level')
`star' Likelihood ratios
		local lrp = r(rr)
		local lrp_ub = r(ub_rr)
		local lrp_lb = r(lb_rr)

`star' Odds ratio
		local or = r(or)
		local or_lb = r(lb_or)
		local or_ub = r(ub_or)

		qui csi `b' `d' `a' `c' , `tb' `woolf' level(`level')
		local lrn = r(rr)
		local lrn_ub = r(ub_rr)
		local lrn_lb = r(lb_rr)

* If prevalence not given, PVs and CIs worked out directly. 
		if "`_prev_'" == "" {
`star' PPV
			qui cii `n_1' `a', level(`level')
			local ppv = 100*r(mean)
			local ppv_lb = 100*r(lb)
			local ppv_ub = 100*r(ub)
`star' NPV
			qui cii `n_2' `d', level(`level')
			local npv = 100*r(mean)
			local npv_lb = 100*r(lb)
			local npv_ub = 100*r(ub)
		}

`star' If prevalence given, PVs and CIs worked out from LRs.
		if "`_prev_'" ~= "" {
`star' Give CI for PVs
			local odds = `prev'/(100-`prev')
			local ppv = (`sens'*`prev') / ((`sens'*`prev')+((100-`spec')*(100-`prev')))*100	  
			local ppv_lb = `lrp_lb'*`odds'
			local ppv_ub = `lrp_ub'*`odds'

			local npv = ((`spec'*(100-`prev')) / (((100-`sens')*`prev')+(`spec'*(100-`prev'))))*100 
			local npv_lb = `lrn_ub'*`odds'
			local npv_ub = `lrn_lb'*`odds'
			foreach v in ppv_lb ppv_ub {
				local `v' = 100*``v''/(1+``v'')
			}
			foreach v in npv_lb npv_ub {
				local `v' = 100/(1+``v'')
			}
		}
	}

`star' With substitution formula
	else { 
		local zval = invnorm(1-(1-`level'/100)/2)
		local a0 = `a' + .5
		local b0 = `b' + .5
		local c0 = `c' + .5
		local d0 = `d' + .5

`star' NOTE: Likelihood ratios depend on sensitivity & specificity
`star' They are not affected by prevalences
		local lrp   = (`a0'/(`a0'+`b0'))/(`c0'/(`c0'+`d0'))
		local lrp_v = `b0'/(`a0'*(`a0'+`b0')) + `d0'/(`c0'*(`c0'+`d0'))
		local lrp_lb = exp(ln(`lrp')-`zval'*sqrt(`lrp_v'))
		local lrp_ub = exp(ln(`lrp')+`zval'*sqrt(`lrp_v'))

		local lrn   = (`b0'/(`a0'+`b0'))/(`d0'/(`c0'+`d0'))
		local lrn_v = `a0'/(`b0'*(`a0'+`b0')) + `c0'/(`d0'*(`c0'+`d0'))
		local lrn_lb = exp(ln(`lrn')-`zval'*sqrt(`lrn_v'))
		local lrn_ub = exp(ln(`lrn')+`zval'*sqrt(`lrn_v'))

		local or    = (`a0'/(`b0'))/(`c0'/(`d0'))
		local or_v = 1/`a0' + 1/`b0' + 1/`c0' + 1/`d0'
		local or_lb = exp(ln(`or')-`zval'*sqrt(`or_v'))
		local or_ub = exp(ln(`or')+`zval'*sqrt(`or_v'))

`star' If prevalence not given, PVs and CIs worked out directly. 
		if "`_prev_'" == "" {
`star' PPV
			qui cii `n_1' `a', level(`level')
			local ppv = 100*r(mean)
			local ppv_lb = 100*r(lb)
			local ppv_ub = 100*r(ub)
`star' NPV
			qui cii `n_2' `d', level(`level')
			local npv = 100*r(mean)
			local npv_lb = 100*r(lb)
			local npv_ub = 100*r(ub)
		}

`star' If prevalence given, PVs and CIs worked out from LRs.
		if "`_prev_'" ~= "" {
`star' Give CI for PVs
			local odds = `prev'/(100-`prev')
			local ppv_lb = `lrp_lb'*`odds'
			local ppv = ((`sens'*`prev') / ((`sens'*`prev')+((100-`spec')*(100-`prev'))))*100	  
			local npv = ((`spec'*(100-`prev')) / (((100-`sens')*`prev')+(`spec'*(100-`prev'))))*100 
			local ppv_ub = `lrp_ub'*`odds'
			local npv_lb = `lrn_ub'*`odds'
			local npv_ub = `lrn_lb'*`odds'
			foreach v in ppv_lb ppv_ub {
				local `v' = 100*``v''/(1+``v'')
			}
			foreach v in npv_lb npv_ub {
				local `v' = 100/(1+``v'')
			}
		}
	}

`star' ROC area 
	if _N >0 { 
		preserve 
		drop _all
		label drop _all
	}
	qui {
		tabi `a' `b' \ `c' `d'
		expand pop
		drop if pop == 0
		drop pop

		rename col test
		label var test "Test result"
		label define test 1 "Pos." 2 "Neg." 0 "Neg." 
		label values test test

		rename row true
		label var true "True disease status"
		label define true 1 "Abnormal" 2 "Normal" 0 "Normal"
		label values true true

		recode true 2 = 0
		recode test 2 = 0

		roctab true test , `bamber' `hanley' level(`level')
		local roc = r(area)
		local roc_lb = r(lb)
		local roc_ub = r(ub)
		if "`bamber'" ~= "" { 
			local roc_opt = "(Bamber)"
		}
		if "`hanley'" ~= "" { 
			local roc_opt = "(Hanley)"
		}
	}


`star' Table
	if "`table'" == "" {
		tabulate true test,  `options'
	}



     	di _n in gr _col(51) "[`level'% Confidence Interval]"
	di in gr "---------------------------------------------------------------------------"                              
	if "`_prev_'" == "" {
		di in gr "Prevalence                         Pr(A)" _col(44) in ye %6.`dp'f `prev' "%" _col(54) %6.`dp'f `prev_lb' "%" _col(65) %6.`dp'f `prev_ub' "%"
	}
	else {
		di in gr "Prevalence                         Pr(A)" _col(44) in ye %6.`dp'f `prev' "%" in gr _col(54) "----- (given) -----"
	}
	di in gr "---------------------------------------------------------------------------"  
	di in gr "Sensitivity                      Pr(+|A)" _col(44) in ye %6.`dp'f `sens' "%" _col(54) %6.`dp'f `sens_lb' "%" _col(64) %6.`dp'f `sens_ub' "%" 
	di in gr "Specificity                      Pr(-|N)" _col(44) in ye %6.`dp'f `spec' "%" _col(54) %6.`dp'f `spec_lb' "%" _col(64) %6.`dp'f `spec_ub' "%"
	di in gr "ROC area               (Sens. + Spec.)/2" _col(46) in ye %5.`dp2'f `roc' _col(56) %5.`dp2'f `roc_lb' _col(66) %5.`dp2'f `roc_ub'  _skip(1) in gr "`roc_opt'"

	di in gr "---------------------------------------------------------------------------"
	di in gr "Likelihood ratio (+)     Pr(+|A)/Pr(+|N)" _col(45) in ye %6.`dp2'f `lrp' _col(55) %6.`dp2'f `lrp_lb' _col(65) %6.`dp2'f `lrp_ub' in gr _skip(`sk_sf') "`sf'" _skip(1) "`_tb_'"
	di in gr "Likelihood ratio (-)     Pr(-|A)/Pr(-|N)" _col(45) in ye %6.`dp2'f `lrn' _col(55) %6.`dp2'f `lrn_lb' _col(65) %6.`dp2'f `lrn_ub' in gr _skip(`sk_sf') "`sf'" _skip(1) "`_tb_'"
	di in gr "Odds ratio                   LR(+)/LR(-)" _col(44) in ye %7.`dp2'f `or'  _col(55) %6.`dp2'f `or_lb'  _col(63) %8.`dp2'f `or_ub' in gr _skip(`sk_sf') "`sf'" _skip(1) "`_woolf_'"
	di in gr "Positive predictive value        Pr(A|+)" _col(44) in ye %6.`dp'f `ppv' "%" _col(54) %6.`dp'f `ppv_lb' "%" _col(64) %6.`dp'f `ppv_ub' "%" in gr _skip(1) "`_prev_'" 
	di in gr "Negative predictive value        Pr(N|-)" _col(44) in ye %6.`dp'f `npv' "%" _col(54) %6.`dp'f `npv_lb' "%" _col(64) %6.`dp'f `npv_ub' "%" in gr _skip(1) "`_prev_'" 
	di in gr "---------------------------------------------------------------------------"

* set trace on
	if "`odds'" ~= "" {
		local oprev = `prev'/(100-`prev')
		if "`_prev_'" == "" {
			local oprev_lb = `prev_lb'/(100-`prev_lb')
			local oprev_ub = `prev_ub'/(100-`prev_ub')
		}
		local opos = `ppv'/(100-`ppv')
		local opos_lb = `ppv_lb'/(100-`ppv_lb')
		local opos_ub = `ppv_ub'/(100-`ppv_ub')

		local oneg = (100-`npv')/`npv'
		local oneg_lb = (100-`npv_lb')/`npv_lb'
		local oneg_ub = (100-`npv_ub')/`npv_ub'

		if "`_prev_'" == "" {
			di in gr "Pre-test odds              prev/(1-prev)" _col(45) in ye %6.`dp2'f `oprev' _col(55) %6.`dp2'f `oprev_lb' _col(65) %6.`dp2'f `oprev_ub' in gr _skip(1) "`_prev_'" 
		}
		else {
			di in gr "Pre-test odds              prev/(1-prev)" _col(45) in ye %6.`dp2'f `oprev' in gr _col(54) "----- (given) -----"
		}
			di in gr "Post-test odds (+)   Pr(A|+)/(1-Pr(A|+))" _col(45) in ye %6.`dp2'f `opos' _col(55) %6.`dp2'f `opos_lb'  _col(65) %6.`dp2'f `opos_ub' in gr _skip(2) "`_prev_'" 
			di in gr "Post-test odds (-)   Pr(A|-)/(1-Pr(A|-))" _col(45) in ye %7.`dp3'f `oneg' _col(55) %7.`dp3'f `oneg_lb'  _col(65) %7.`dp3'f `oneg_ub' in gr _skip(1) "`_prev_'" 
		di in gr "---------------------------------------------------------------------------"

		local retlist "oneg opos oprev "
		foreach ret in `retlist' {
			cap ret scalar `ret'_ub = ``ret'_ub'
			cap ret scalar `ret'_lb = ``ret'_lb'
			cap ret scalar `ret' = ``ret''
		}
	}

	if "`sf'" ~= "" {	
		di in gr _n "(sf) Likelihood ratios are estimated using the substitution formula.
		di in gr    "     0.5 is added to all cell frequencies before calculation."
	}


	if "`_prev_'" ~= "" {
		di in gr _n "(lr) Values and confidence intervals are based on likelihood 
		di in gr    "     ratios" _skip(`sk_sf') "`sf', assuming that the prevalence is known exactly."
	}
	if (`a'*`b'* `c'*`d' == 0) & ("`sf'" == "") {
		di _n in gr "  Missing values or confidence intervals may be estimated 
		di in gr "  using the -sf- or -sf0- options."
	}

	local retlist "`retlist' roc or lrn lrp npv ppv prev spec sens "


	foreach ret in `retlist' {
		cap ret scalar `ret'_ub = ``ret'_ub'
		cap ret scalar `ret'_lb = ``ret'_lb'
		cap ret scalar `ret' = ``ret''
	}


end

exit
