*! lclogitml version 1.21 - Last update: Aug 21, 2012 
*! Authors: Daniele Pacifico (daniele.pacifico@tesoro.it)
*!			Hong il Yoo 	 (h.yoo@unsw.edu.au)	
*!
*! NOTE
*! -lclogitml- uses Sophia Rabe-Hesketh's -gllamm-. 			 
*! Type ssc install gllamm to install.

program lclogitml
	version 11.2
	if ("`e(cmd)'" == "lclogit"|"`e(cmd)'" == "lclogitml") Estimate `0'
	else error 301
end

program Estimate, eclass sortpreserve
	syntax [if] [in] [, ITERate(integer 0) NOPOst SWITch Level(cilevel) * ] 

	**Check options**
	if (`iterate' < 0) {
        di as error "iterate(`iterate') must be >= 0."
        exit 197
    }
	
	** Redisplay output in case e(cmd) is lclogitml and no further iteration is specified **
	if ("`e(cmd)'" == "lclogitml")&(`iterate'==0)&("`switch'" == "") {
		Replay, level(`level')
		exit
	}	
	
	tempname  _lclogit B CMB init gid pid _bb _VV _b _V _B _CMB _P _PB _CB _cm _samp  
	tempvar ncm cm_chk exa mo 
	forvalues s=1/`e(nclasses)'{
		tempvar exa`s' up`s' 
	}
	
	** Mark sample ** 
	marksample touse
	
	** Check that group, id and other explanatory variables are numeric **
	foreach v of varlist `e(group)' `e(id)' `e(indepvars)' `e(indepvars2)' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}	
	
	** Check that depvar is a binary indicator of choice**
		sort `e(group)'
		qui by `e(group)': egen `mo'=sum(`e(depvar)') if `touse'
		qui su `mo' if `touse'
		if r(mean)!=1 {
			di as error "`e(depvar)' is not a 0/1 variable which equals 1 for the chosen alternative. "
			exit 450
		}	
		
	** Check that varlist in membership() do not vary within the same agent ""
    if "`membership'" != "" {
        sort `e(id)'
        foreach v of varlist `membership' {
			qui by `e(id)' : gen double `cm_chk' = `v'[_n] - `v'[_n-1] if `touse'
            qui tab `cm_chk'
            if r(r) > 1 {
				di as error "invalid variable `v': variables in membership() must not vary within the same id(`id')."
                exit 498
            }
            drop `cm_chk'
        }
     }	
	
	**Actual program begins**
	sort `e(id)' `e(group)'
	qui by `e(id)' : gen byte `ncm' = [_n==_N] if `touse'
	
	local ncons = 0
	capture local ncons = rowsof(e(Cons))	

	if (`ncons'>0) & (`iterate'>0) {
		di as gr "Note: -lclogitml- does not pass parametric constraints to -gllamm-." 
		di as gr "Redefine the constraints to follow the -gllamm- syntax and include them"
		di as gr "among gllamm estimation options if you wish to continue imposing them."
		di as gr " "
	}
	
	if ("`nopost'" != "") _estimates hold `_lclogit', copy 

	local k : word count `e(indepvars)'
	local k2 : word count `e(indepvars2)' _cons
	foreach v of varlist `e(indepvars)' {
		eq `v' : `v'
	}
	if ("`switch'" == "") { 
		local nodisp nodisplay
		local nclasses = `e(nclasses)'
		local local group id depvar indepvars
		if (`k2' > 1) local local `local' indepvars2
		foreach l of local local {
			local _`l' "`e(`l')'"
		}
		local coleq_b : coleq e(b)
		local coleq_P  : coleq e(P)
		local rowname_PB : rownames e(PB)
		local rowname_B : rownames e(B)
		local rowname_CMB : rownames e(CMB)
		local rowname_P : rownames e(P)
	}
	matrix `B' = e(B)
	matrix `CMB' = e(CMB)
	if "`e(indepvars2)'" != "" {	
		eq class_share : `e(indepvars2)'
		local peq peq(class_share)
	}

	forvalues s = 1/`=`e(nclasses)'-1' {
		matrix `init' = nullmat(`init'), `B'[`s',1...], `CMB'[`s',1...]
	}
	matrix `init' = `init', `B'[`e(nclasses)',1...]
	
	di as gr "-gllamm- is initializing. This process may take a few minutes." 
	
	gllamm `e(depvar)' `if' `in', nocons i(`e(id)') expand(`e(group)' `e(depvar)' o) /*
	*/ l(mlogit) f(binom) nip(`e(nclasses)') ip(fn) nrf(`k') allc iter(`iterate') `peq' `gllammopt' /*
	*/ eq(`e(indepvars)') from(`init') copy `nodisp' `options'
	if ("`switch'" == "") {
		matrix `_VV' = e(V)
		matrix `_bb' = e(b)	
		
		qui gen double `exa' = 1 if e(sample)
		forvalues c=1/`=`nclasses'-1'{
			qui _predict double `exa`c'' if e(sample), xb equation(p2_`c')
			qui replace `exa`c'' = exp(`exa`c'') if e(sample)
			qui replace `exa' = `exa' + `exa`c'' if e(sample)
		}
		forvalues c=1/`=`nclasses'-1'{
			qui gen double `up`c'' = `exa`c'' / `exa' if e(sample)
		}
		qui gen double `up`nclasses'' = 1 / `exa' if e(sample)
		forvalues c=1/`nclasses' {
			qui sum `up`c'' if `ncm'==1 & e(sample)==1, meanonly
			matrix `_P' = nullmat(`_P') \ r(mean)
		}

		forvalues s = 1/`nclasses' {
			matrix `_b' = nullmat(`_b'), `_bb'[1,`=(`s'-1)*(`k'+`k2')+1'..`=`s'*(`k'+`k2')-`k2'']
			matrix `_B' = nullmat(`_B')\ `_bb'[1,`=(`s'-1)*(`k'+`k2')+1'..`=`s'*(`k'+`k2')-`k2'']
			matrix `_V' = nullmat(`_V'), `_VV'[1...,`=(`s'-1)*(`k'+`k2')+1'..`=`s'*(`k'+`k2')-`k2'']
		}
		forvalues s = 1/`=`nclasses'-1' {
			matrix `_b' = `_b', `_bb'[1,`=`s'*(`k'+`k2')-`k2'+1'..`=`s'*(`k'+`k2')']
			matrix `_CMB' = nullmat(`_CMB')\ `_bb'[1,`=`s'*(`k'+`k2')-`k2'+1'..`=`s'*(`k'+`k2')']
			matrix `_V' = `_V', `_VV'[1...,`=`s'*(`k'+`k2')-`k2'+1'..`=`s'*(`k'+`k2')']
		}
		matrix `_CMB' = `_CMB' \ J(1,`k2',0)
		matrix `_VV' = `_V'
		matrix drop `_V'
		forvalues s = 1/`nclasses' {
			matrix `_V' = nullmat(`_V') \ `_VV'[`=(`s'-1)*(`k'+`k2')+1'..`=`s'*(`k'+`k2')-`k2'', 1...] 
		}
		forvalues s = 1/`=`nclasses'-1' {
			matrix `_V' = `_V' \ `_VV'[`=`s'*(`k'+`k2')-`k2'+1'..`=`s'*(`k'+`k2')',1...] 
		}
		
		matrix `_PB' = `_P''*`_B'
		mat coleq `_b' = `coleq_b'
		mat coleq `_V' = `coleq_b'
		mat roweq `_V' = `coleq_b'
		mat coleq `_B' = "Coefficients of"
		mat coleq `_PB' = "Average of"
		mat coleq `_CMB' = :
		mat coleq `_P' = `coleq_P'
		mat rownames `_PB' = `rowname_PB'
		mat rownames `_B' = `rowname_B'
		mat rownames `_CMB' = `rowname_CMB'
		mat rownames `_P' = `rowname_P'
		mat colnames `_P' = "Class Share"
		
		mat `_CB' = `_B''*`_B'
		mata: st_replacematrix("`_CB'",(st_matrix("`_P'"):*(st_matrix("`_B'"):-st_matrix("`_PB'")))'*(st_matrix("`_B'"):-st_matrix("`_PB'")))
		mat coleq `_CB' = : 	
		mat roweq `_CB' = :
		
		local z = e(ll)		
		local nparm = e(k)
		local N = e(N)
		qui count if e(sample)==1&`e(ind)'==1
		local cs = r(N)
		matrix `_cm' = e(nu)
		local cm = `_cm'[1,2]
		gen byte `_samp' = e(sample)
		ereturn clear
		ereturn post `_b' `_V', esample(`_samp')
		foreach l of local local {
			ereturn local `l' `_`l''
		}
		ereturn local cmd "lclogitml"
		ereturn local title "Model estimated via GLLAMM"
		ereturn scalar N = `N'
		ereturn scalar ll = `z'
		ereturn scalar nclasses = `nclasses' 
		ereturn scalar N_g = `cs'
		ereturn scalar N_i = `cm'
		ereturn scalar bic = -2*`z'+(`nparm')*log(`cm') 
		ereturn scalar caic= -2*`z'+(`nparm')*(log(`cm')+1)
		ereturn scalar aic = -2*`z'+2*(`nparm') 	
		ereturn matrix CMB = `_CMB', copy
		ereturn matrix CB = `_CB', copy
		ereturn matrix PB =	`_PB', copy
		ereturn matrix P = `_P', copy
		ereturn matrix B = `_B', copy
		Replay, level(`level')
	}
	if ("`nopost'" != "") qui _estimates unhold `_lclogit' 
end

program Replay
	syntax [, Level(cilevel)]
	di as gr ""
	di as gr "Latent class model with `e(nclasses)' latent classes"
	ereturn display, level(`level') 
end
