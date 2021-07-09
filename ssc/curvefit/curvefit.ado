/*---------------------------
10Apr2010 - version 4.0

Curve Estimation

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
capture prog drop curvefit
prog define curvefit
	version 10.0
	syntax varlist(numeric max=2) [if] [in] [fw aw iw], Function(string) [Nograph Initial(string) Count(integer 4) Vce(string) SCHEme(string) SAVing(string)]
	preserve
	marksample touse
	tokenize `varlist'
	qui sort `2'
	if "`vce'"!="" & strpos("gnr r robust boot bootstrap jack jackknife hac hc2 hc3 cluster",word("`vce'",1))==0 {
		di _n as erro "Note: " as txt "vcetype " as erro "'`vce''" as txt " not allowed "
		exit 198
	}
	if "`weight'" != "" & "`vce'" != "" {
		local vcelen = length("`vce'")
		if "`vce'" != substr("robust", 1, `vcelen') {
			di as error "'weights' not allowed with 'vce()'"
			exit 101
		}
	}
	if "`nograph'" != "" & "`scheme'" != "" {
		di as error "'nograph' not allowed with 'scheme()'"
		exit 101
	}
	if "`nograph'" != "" & "`saving'" != "" {
		di as error "'nograph' not allowed with 'saving()'"
		exit 101
	}
	local x="1 2 3 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y"
	foreach i of local x {
		tempvar yhat_`i'
	}
	tempvar y_1
	local fit_num=0
	local notfit_num=0
	local notfit=""
	local linename=""
	local estname=""
	qui {	
		if regexm("`function'","1") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} + ({b1} * (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} + ({b1} * (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Linear
				gen `yhat_1'=_coef[/b0]+(_coef[/b1]*(`2'))
				label var `yhat_1' "Linear"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_1'"
				local estname "`estname' Linear"
			}
			else {
				local notfit="`notfit'"+"Linear "
				local notfit_num=`notfit_num'+1
			}
		}		
		if regexm("`function'","2") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} + ({b1} * ln((`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} + ({b1} * ln((`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Logarithmic
				gen `yhat_2'=_coef[/b0]+(_coef[/b1]*ln((`2')))
				label var `yhat_2' "Logarithmic"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_2'"
				local estname "`estname' Logarithmic"
			}
			else {
				local notfit="`notfit'"+"Logarithmic "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","3") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} + ({b1} / (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} + ({b1} / (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Inverse
				gen `yhat_3'=_coef[/b0]+(_coef[/b1]/(`2'))
				label var `yhat_3' "Inverse"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_3'"
				local estname "`estname' Inverse"
			}
			else {
				local notfit="`notfit'"+"Inverse "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","4") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} + ({b1} * (`2')) + ({b2} * (`2')^2)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} + ({b1} * (`2')) + ({b2} * (`2')^2)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Quadratic
				gen `yhat_4'=_coef[/b0]+(_coef[/b1]*(`2'))+(_coef[/b2]*(`2')^2)
				label var `yhat_4' "Quadratic"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_4'"
				local estname "`estname' Quadratic"
			}
			else {
				local notfit="`notfit'"+"Quadratic "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","5") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} + ({b1} * (`2')) + ({b2} * (`2')^2) + ({b3} * (`2')^3)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} + ({b1} * (`2')) + ({b2} * (`2')^2) + ({b3} * (`2')^3)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Cubic
				gen `yhat_5'=_coef[/b0]+(_coef[/b1]*(`2'))+(_coef[/b2]*(`2')^2)+(_coef[/b3]*(`2')^3)
				label var `yhat_5' "Cubic"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_5'"
				local estname "`estname' Cubic"
			}
			else {
				local notfit="`notfit'"+"Cubic "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","6") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * ((`2')^{b1})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * ((`2')^{b1})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Power
				gen `yhat_6'=_coef[/b0]*((`2')^_coef[/b1])
				label var `yhat_6' "Power"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_6'"
				local estname "`estname' Power"
			}
			else {
				local notfit="`notfit'"+"Power "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","7") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * ({b1}^(`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * ({b1}^(`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Compound
				gen `yhat_7'=_coef[/b0]*(_coef[/b1]^(`2'))
				label var `yhat_7' "Compound"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_7'"
				local estname "`estname' Compound"
			}
			else {
				local notfit="`notfit'"+"Compound "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","8") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= exp({b0} + ({b1}/(`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= exp({b0} + ({b1}/(`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto S_curve
				gen `yhat_8'=exp(_coef[/b0]+(_coef[/b1]/(`2')))
				label var `yhat_8' "S-curve"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_8'"
				local estname "`estname' S_curve"
			}
			else {
				local notfit="`notfit'"+"S_curve "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","9") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} / (1 + {b1} * exp(-{b2} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} / (1 + {b1} * exp(-{b2} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Logistic
				gen `yhat_9'= _coef[/b0] / (1 + _coef[/b1] * exp(-_coef[/b2] * (`2')))
				label var `yhat_9' "Logistic"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_9'"
				local estname "`estname' Logistic"
			}
			else {
				local notfit="`notfit'"+"Logistic "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","0") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= exp({b0} + ({b1} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= exp({b0} + ({b1} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Growth
				gen `yhat_0' = exp(_coef[/b0]+(_coef[/b1]*(`2')))
				label var `yhat_0' "Growth"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_0'"
				local estname "`estname' Growth"
			}
			else {
				local notfit="`notfit'"+"Growth "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","a") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * (exp({b1} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * (exp({b1} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Exponential
				gen `yhat_a'=_coef[/b0]*(exp(_coef[/b1]*(`2')))
				label var `yhat_a' "Exponential"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_a'"
				local estname "`estname' Exponential"
			}
			else {
				local notfit="`notfit'"+"Exponential "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","b") | "`function'"=="ALL" {			
			if "`initial'"=="" {
				cap nl (`1' = exp({b0} + {b1}/(`2')+{b2} * ln((`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1' = exp({b0} + {b1}/(`2')+{b2} * ln((`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Vapor_Pressure
				gen `yhat_b'=exp(_coef[/b0] + _coef[/b1]/(`2')+_coef[/b2] * ln((`2')))
				label var `yhat_b' "Vapor Pressure"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_b'"
				local estname "`estname' Vapor_Pressure"
			}
			else {
				local notfit="`notfit'"+"Vapor_Pressure "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","c") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'=1/ ({b0} + ({b1} * ln((`2'))))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'=1/ ({b0} + ({b1} * ln((`2'))))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto R_Logarithmic
				gen `yhat_c'=1/(_coef[/b0]+(_coef[/b1]*ln((`2'))))
				label var `yhat_c' "R_Logarithmic"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_c'"
				local estname "`estname' R_Logarithmic"
			}
			else {
				local notfit="`notfit'"+"R_Logarithmic "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","d") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'={b0} * {b1}^(`2')) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'={b0} * {b1}^(`2')) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto M_Power
				gen `yhat_d'=_coef[/b0] * _coef[/b1]^(`2')
				label var `yhat_d' "Modified Power"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_d'"
				local estname "`estname' M_Power"
			}
			else {
				local notfit="`notfit'"+"M_Power "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","e") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * ((`2') - {b1})^{b2}) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * ((`2') - {b1})^{b2}) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto S_Power
				gen `yhat_e'=_coef[/b0] * ((`2') - _coef[/b1])^_coef[/b2]
				label var `yhat_e' "Shifted Power"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_e'"
				local estname "`estname' S_Power"
			}
			else {
				local notfit="`notfit'"+"Shifted_Power "
				local notfit_num=`notfit_num'+1
			}
		}		
		if regexm("`function'","f") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * (`2')^({b1} * (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * (`2')^({b1} * (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Geometric
				gen `yhat_f'= _coef[/b0] * (`2')^(_coef[/b1] * (`2'))
				label var `yhat_f' "Geometric"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_f'"
				local estname "`estname' Geometric"
			}
			else {
				local notfit="`notfit'"+"Geometric "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","g") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * (`2')^({b1}/(`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * (`2')^({b1}/(`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto M_Geometric
				gen `yhat_g'=_coef[/b0] * (`2')^(_coef[/b1]/(`2'))
				label var `yhat_g' "Modified Geometric"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_g'"
				local estname "`estname' M_Geometric"
			}
			else {
				local notfit="`notfit'"+"M_Geometric "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","h") | "`function'"=="ALL" {
			local equa1="{b0}"
			local equa2="_coef[/b0]"
			forv i=1/`count' {
				local equa1="`equa1'"+"+"+"{b`i'}"+"*"+"(`2')^`i'"
				local equa2="`equa2'"+"+"+"_coef[/b`i']"+"*"+"(`2')^`i'"
			}
			if "`initial'"=="" {
				nl (`1'= `equa1') if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= `equa1') if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Polynomial
				gen `yhat_h'=`equa2'
				label var `yhat_h' "`count' order Polynomial"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_h'"
				local estname "`estname' Polynomial"
			}
			else {
				local notfit="`notfit'"+"Polynomial "
				local notfit_num=`notfit_num'+1
			}
		}			
		if regexm("`function'","i") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * ({b1}^(`2')) * ((`2')^{b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * ({b1}^(`2')) * ((`2')^{b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Hoerl
				gen `yhat_i'=_coef[/b0] * (_coef[/b1]^(`2')) * ((`2')^_coef[/b2])
				label var `yhat_i' "Hoerl"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_i'"
				local estname "`estname' Hoerl"
			}
			else {
				local notfit="`notfit'"+"Hoerl "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","j") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * {b1}^(1/(`2')) * ((`2')^{b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * {b1}^(1/(`2')) * ((`2')^{b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto M_Hoerl
				gen `yhat_j'=_coef[/b0] * _coef[/b1]^(1/(`2')) * ((`2')^_coef[/b2])
				label var `yhat_j' "Modified Hoerl"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_j'"
				local estname "`estname' M_Hoerl"
			}
			else {
				local notfit="`notfit'"+"M_Hoerl "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","k") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= 1 / ({b0} + {b1} * (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= 1 / ({b0} + {b1} * (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Reciprocal
				gen `yhat_k'=1 / (_coef[/b0] + _coef[/b1] * (`2'))
				label var `yhat_k' "Reciprocal"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_k'"
				local estname "`estname' Reciprocal"
			}
			else {
				local notfit="`notfit'"+"Reciprocal "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","l") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= 1 / ({b0} + {b1} * (`2') + {b2} * (`2')^2)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= 1 / ({b0} + {b1} * (`2') + {b2} * (`2')^2)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto R_Quadratic
				gen `yhat_l'=1 / (_coef[/b0] + _coef[/b1] * (`2') + _coef[/b2] * (`2')^2)
				label var `yhat_l' "R_Quadratic"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_l'"
				local estname "`estname' R_Quadratic"
			}
			else {
				local notfit="`notfit'"+"R_Quadratic "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","m") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= ({b0} + {b1} * (`2'))^(-1 / {b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= ({b0} + {b1} * (`2'))^(-1 / {b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Bleasdale
				gen `yhat_m'=(_coef[/b0] + _coef[/b1] * (`2'))^(-1 / _coef[/b2])
				label var `yhat_m' "Bleasdale"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_m'"
				local estname "`estname' Bleasdale"
			}
			else {
				local notfit="`notfit'"+"Bleasdale "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","n") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= 1 / ({b0} + {b1} * (`2')^{b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= 1 / ({b0} + {b1} * (`2')^{b2})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Harris
				gen `yhat_n'=1 / (_coef[/b0] + _coef[/b1] * (`2')^_coef[/b2])
				label var `yhat_n' "Harris"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_n'"
				local estname "`estname' Harris"
			}
			else {
				local notfit="`notfit'"+"Harris "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","o") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * (1 - exp(-{b1} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * (1 - exp(-{b1} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Exp_Association
				gen `yhat_o'=_coef[/b0] * (1 - exp(-_coef[/b1] * (`2')))
				label var `yhat_o' "Exp_Association"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_o'"
				local estname "`estname' Exp_Association"
			}
			else {
				local notfit="`notfit'"+"Exp_Association "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","p") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * ({b1} - exp(-{b2} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * ({b1} - exp(-{b2} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Thr_P_Exp_Association
				gen `yhat_p'=_coef[/b0] * (_coef[/b1] - exp(-_coef[/b2] * (`2')))
				label var `yhat_p' "3P Exp_Association"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_p'"
				local estname "`estname' Thr_P_Exp_Association"
			}
			else {
				local notfit="`notfit'"+"Thr_Para_Exp_Association "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","q") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * (`2')/({b1} + (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * (`2')/({b1} + (`2'))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto S_Growth_Rate
				gen `yhat_q'=_coef[/b0] * (`2')/(_coef[/b1] + (`2'))
				label var `yhat_q' "S-Growth Rate"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_q'"
				local estname "`estname' S_Growth_Rate"
			}
			else {
				local notfit="`notfit'"+"Saturation_Growth_Rate "
				local notfit_num=`notfit_num'+1
			}
		}		
		if regexm("`function'","r") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * exp(-exp({b1} - {b2} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * exp(-exp({b1} - {b2} * (`2')))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Gompertz_Relation
				gen `yhat_r'=_coef[/b0] * exp(-exp(_coef[/b1] - _coef[/b2] * (`2')))
				label var `yhat_r' "Gompertz Relation"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_r'"
				local estname "`estname' Gompertz_Relation"
			}
			else {
				local notfit="`notfit'"+"Gompertz_Relation "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","s") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} / (1 + exp({b1} - {b2} * (`2')))^(1/{b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} / (1 + exp({b1} - {b2} * (`2')))^(1/{b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Richards
				gen `yhat_s'=_coef[/b0] / (1 + exp(_coef[/b1] - _coef[/b2] * (`2')))^(1/_coef[/b3])
				label var `yhat_s' "Richards"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_s'"
				local estname "`estname' Richards"
			}
			else {
				local notfit="`notfit'"+"Richards "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","t") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= ({b0} * {b1}+{b2} * (`2')^{b3})/({b1} + (`2')^{b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= ({b0} * {b1}+{b2} * (`2')^{b3})/({b1} + (`2')^{b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto MMF
				gen `yhat_t'=(_coef[/b0] * _coef[/b1]+_coef[/b2] * (`2')^_coef[/b3])/(_coef[/b1] + (`2')^_coef[/b3])
				label var `yhat_t' "MMF"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_t'"
				local estname "`estname' MMF"
			}
			else {
				local notfit="`notfit'"+"MMF "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","u") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} - {b1}*exp(-{b2} * (`2')^{b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} - {b1}*exp(-{b2} * (`2')^{b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Weibull
				gen `yhat_u'=_coef[/b0] - _coef[/b1]*exp(-_coef[/b2] * (`2')^_coef[/b3])
				label var `yhat_u' "Weibull"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_u'"
				local estname "`estname' Weibull"
			}
			else {
				local notfit="`notfit'"+"Weibull "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","v") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0}+{b1} * {b2} * cos({b2} * (`2') + {b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0}+{b1} * {b2} * cos({b2} * (`2') + {b3})) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Sinusoida
				gen `yhat_v'=_coef[/b0]+_coef[/b1] * _coef[/b2] * cos(_coef[/b2] * (`2') + _coef[/b3])
				label var `yhat_v' "Sinusoida"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_v'"
				local estname "`estname' Sinusoida"
			}
			else {
				local notfit="`notfit'"+"Sinusoida "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","w") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} * exp((-({b1} - (`2'))^2)/(2 * {b2}^2))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} * exp((-({b1} - (`2'))^2)/(2 * {b2}^2))) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Gaussian
				gen `yhat_w'=_coef[/b0] * exp((-(_coef[/b1] - (`2'))^2)/(2 * _coef[/b2]^2))
				label var `yhat_w' "Gaussian"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_w'"
				local estname "`estname' Gaussian"
			}
			else {
				local notfit="`notfit'"+"Gaussian "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","x") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= {b0} + {b1} * (`2') + {b2}/(`2')^2) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= {b0} + {b1} * (`2') + {b2}/(`2')^2) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Heat_Capacity
				gen `yhat_x'=_coef[/b0] + _coef[/b1] * (`2') + _coef[/b2]/(`2')^2
				label var `yhat_x' "Heat Capacity"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_x'"
				local estname "`estname' Heat_Capacity"
			}
			else {
				local notfit="`notfit'"+"Heat_Capacity "
				local notfit_num=`notfit_num'+1
			}
		}
		if regexm("`function'","y") | "`function'"=="ALL" {
			if "`initial'"=="" {
				cap nl (`1'= ({b0} + {b1} * (`2'))/(1 + {b2} * (`2') + {b3} * (`2')^2)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce')
			}
			else {
				cap nl (`1'= ({b0} + {b1} * (`2'))/(1 + {b2} * (`2') + {b3} * (`2')^2)) if `touse' [`weight'`exp'], variables(`2') nolog vce(`vce') initial("`initial'")
			}
			if _rc==0 & e(r2_a)>0 & e(r2)>0 {
				est sto Rational
				gen `yhat_y'=(_coef[/b0] + _coef[/b1] * (`2'))/(1 + _coef[/b2] * (`2') + _coef[/b3] * (`2')^2)
				label var `yhat_y' "Rational"
				local fit_num=`fit_num'+1
				local linename "`linename' `yhat_y'"
				local estname "`estname' Rational"
			}
			else {
				local notfit="`notfit'"+"Rational "
				local notfit_num=`notfit_num'+1
			}
		}
	}
	
	if `fit_num'>0 {
		estimates table `estname',  stats(N r2_a) t p modelwidth(11) title(Curve Estimation between "`1'" and "`2'")
		if "`nograph'"=="" {
			gen `y_1'=`1'
			label var `y_1' "Observed"
			twoway (scatter `y_1' `2') (line `linename' `2'), ytitle("") xtitle("") title(Curve fit for `1') legend(cols(1) colgap(tiny) size(small) region(lcolor(none)) position(3)) scheme(`scheme') saving(`saving')
		}
	}
	if `notfit_num'>0 {
		di _n as erro "Note: " as txt "Models of " as result "`notfit'" as txt "erro setting or not fit the data!"
	}
	
end
