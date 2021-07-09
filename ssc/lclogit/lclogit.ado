*! lclogit version 2.11 - Last update: Aug 11, 2012 
*! Authors: Daniele Pacifico (daniele.pacifico@tesoro.it)
*!			Hong il Yoo 	 (h.yoo@unsw.edu.au)	
*!
*! NOTE
*! -lclogit- uses Maarten Buis's -fmlogit- (http://www.maartenbuis.nl/). 			 
*! Type ssc install fmlogit to install.

program lclogit
	version 11.2
	if replay() {
		if (`"`e(cmd)'"' != "lclogit" & `"`e(cmd)'"' != "lclogitml") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass sortpreserve
		syntax varlist [if] [in],		///
			ID(varname) 				///
			GRoup(varname)				///
			NCLasses(integer) [			///
			CONVergence(real 0.000001)	///
			SEED(numlist max=1)				///
			ITERate(integer 150) 			///
			MEMbership(varlist)			///
			Nolog						///
			CONSTraints(string)			///
			]	
			
	**Define temporary variables**
	tempvar prop N cs cm np bic caic aic ac covc pr _pr betas ncm ///
				 miny maxy obs _p _pr _s _lnden _lndens _depvar coefs ///
				 cm_coefs CMB Cns cm_chk 
	
	**Mark sample** 
	marksample touse
	markout `touse' `group' `id'
	
	gettoken depvar varlist: varlist
	
	**Generate class-varying temporary variables**
	forvalues s=1/`nclasses'{
		tempvar _l`s' b`s' _prob`s' v`s' _kbbb`s' _nums`s' _h`s' _H`s' _const`s'
	}
	
	**Check that group, id and other explanatory variables are numeric **
	foreach v of varlist `group' `id' `varlist' `membership' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}

	**Check that all specified options have elements within the allowed ranges **
	if (`nclasses' < 2) {
		di in r "nclasses(`nclasses') must be >=2."
        exit 197
    }
    if `convergence' < 0 {
        di as error "convergence(`convergence') must be >= 0."
        exit 197
    }
    
	if "`seed'" != "" {
		if (`seed' < 0) | (`seed' > 2147483647) {
			di as error "seed(`seed') must be between 0 and 2^31-1 (2,147,483,647)."
			exit 197
		}
	}
	
    if (`iterate' < 0) {
        di as error "iterate(`iterate') must be >= 0."
        exit 197
    }
	
	**Check that varlist in membership() do not vary within the same agent""
    if "`membership'" != "" {
        sort `id'
        foreach v of varlist `membership' {
			qui by `id' : gen double `cm_chk' = `v'[_n] - `v'[_n-1] if `touse'
            qui tab `cm_chk'
            if r(r) > 1 {
				di as error "invalid variable `v': variables in membership() must not vary within the same id(`id')."
                exit 498
            }
            drop `cm_chk'
        }
     }

	**Check that depvar is a 0/1 indicator of choice**
		sort `group'
		qui by `group': egen `miny' = min(`depvar') if `touse'
		qui by `group': egen `maxy' = max(`depvar') if `touse'
		qui count if ((`miny' !=0 & `miny' !=1) | (`maxy' !=1 & `maxy' !=0)) & `touse' 
		if r(N)>0 {
			di as error "`depvar' is not a 0/1 variable which equals 1 for the chosen alternative."
			exit 450
		}		 
	 
	** Estimate conditional logit model; the estimation is terminated at iteration 0 as the acual results are not needed**  
		qui clogit `depvar' `varlist' if `touse', group(`group') robust tech(nr dfp) iter(0) 
		local np=e(k)
		qui replace `touse' = e(sample)		 	

	**If user pecified option "constraints", parse them to define a set of constraints applicable to each class**
		if "`constraints'" != "" {
			gettoken _cstr _rst : constraints, parse(:)
			local const`=substr("`_cstr'",6,1)' const(`=substr("`_cstr'",8,.)')
			while `=wordcount("`_rst'")' > 0 {
				gettoken _cstr _rst : _rst, parse(:)
				gettoken _cstr _rst : _rst, parse(:)
				local const`=substr("`_cstr'",6,1)' const(`=substr("`_cstr'",8,.)')
			}		
		}
			
	**Obtain inputs for the ereturn results**
		*number of relevant observations:
	 	qui count if `touse'
       	local N=r(N)
		*number of choice situations:
		qui count if `touse'==1 & `depvar'==1
		local cs=r(N)
		*number of estimated parameters in the class membership model:
		local cm_parm : word count _cons `membership' 
			
	**Generate temporary variables & macros to be used for minimising repetitive opertaions in the loop**
		sort `id' `touse' `group' `depvar'
		*ncm: equals 1 for the last in-estimation-sample obs on each choice maker and missing elsewhere
		qui by `id': gen byte `ncm'=1 if _n==_N & `touse'==1
		*_depvar: equals 1 for the chosen alternative and missing elsewhere
		qui gen byte `_depvar'=1 if `touse' == 1 & `depvar' ==1 
		*local _den_rhs : holds the RHS of _den variable
		*local _dens_rhs: holds the RHS of _dens variable
		*local _prob: holds names for variables storing predicted class shares
		*local depvarclass: holds the LHS of fmlogit 
		*local display: determines whether an iteration log is printed or not 
		local _den_rhs 0
		local _dens_rhs 0
		forvalues s=1/`nclasses' {
			local _den_rhs `_den_rhs' + exp(ln(`_prob`s'')+`_kbbb`s'')
			local _dens_rhs `_dens_rhs' + scalar(`_nums`s'') 	
		}
		forvalues s=1/`=`nclasses'-1' {
			local _prob `_prob' `_prob`s''
			local depvarclass `depvarclass' `_h`s''
		}
		local _prob `_prob`nclasses'' `_prob'
		local depvarclass `_h`nclasses'' `depvarclass'
		if ("`nolog'" != "") local display quietly display
		else local display noisily display
			
	**Generate starting values by randomly splitting the sample into nclasses() segements using uniform
	**	random draws. Follow -asmprobit- in terms of how set seed is used during this process. 
 		local o_seed `c(seed)' // Save the current seed so that it can be restored later. 
		if "`seed'" == "" local seed `c(seed)' // Use c(seed) as the starting seed unless the user requested otherwise. 
 		set seed `seed' // Specify the starting seed for runiform().   			
		qui by `id': gen double `_p'=runiform() if `ncm'==1 // Make a random draw for each agent
		qui by `id': egen double `_pr'=sum(`_p') if `touse'
		set seed `o_seed' // Restore the original seed.  
		local prop= 1/`nclasses' // The remainder of this block splits the sample into nclasses() segements 
		qui gen double `_s'=1 if `_pr'<=`prop'  & `touse' // based on the realisations of the random draws.
		forvalues s=2/`nclasses'{
			qui replace `_s'=`s' if `_pr'>(`s'-1)*`prop' & `_pr'<=`s'*`prop' & `touse'
		}

	**Obtain starting values for the choice model by running a separate clogit regression using each ubsample**
		quietly{
			forvalues s=1/`nclasses'{
				clogit `depvar'  `varlist'  if `_s'==`s' & `touse', group(`group') robust tech(nr dfp) `const`s''
				matrix `b`s''=e(b)
				if ("`const`s''" != "" ) capture mat `_const`s'' = e(Cns)
				predict double `_l`s'' if `touse'
				gen double `_prob`s''=`prop'  if `touse'
				by `id': gen double `_kbbb`s'' = sum(ln(`_l`s''*`_depvar'))*`ncm' if `touse'
			}	
			gen double `_lnden'= ln(`_den_rhs') if `touse'
			
	**Get the individual conditional probabilities (`_H')**			
			forvalues s=1/`nclasses'{
				gen double `_h`s''=exp(ln(`_prob`s'')+`_kbbb`s''-`_lnden')  if `touse'
				by `id': gen double `_H`s''=`_h`s''[_N] if `touse'
				count if `_H`s'' < smallestdouble() & `touse'
				if r(N)>0 { 
					levelsof `id' if `_H`s'' < smallestdouble() & `touse', local(_Hzero)
					noisily di as error "Note: The conditional probability of being in Class`s' is zero for the following agents: `_Hzero'"
				}
			}
		
	**Evaluate and display the likelihood function**
			sum `_lnden' if `touse'&`ncm'==1 , meanonly	
			local z=r(sum)
			}
			di ""
			`display' as green "Iteration " 0 ":  log likelihood = " as yellow `z'

	**************
	**Start loop**
	**************
			qui gen double `_lndens'=1  if `touse'
			set more off
			local i= 0
			while `i'< `iterate' {
			quietly{
	**update the choice probability**
			local i=`i' +1
			forvalues s=1/`nclasses'{
				clogit `depvar'  `varlist'  [iw=`_H`s'']  if `touse', group(`group') robust tech(nr dfp) from(`b`s'') `const`s''
				matrix `b`s''=e(b)
				capture drop `_l`s''
				predict double `_l`s'' if `touse' 
				by `id': replace `_kbbb`s''= sum(ln(`_l`s''*`_depvar'))*`ncm' if `touse'
			}
	
	**update the class shares (_prob1,..,_probC)**
			capture drop `_prob'
			if "`membership'" == "" {
				forvalues s=1/`nclasses'{
					sum `_h`s'' if `touse', meanonly
					scalar `_nums`s'' = r(sum) 
				}
				replace `_lndens'=ln(`_dens_rhs')  if `touse'				
				forvalues s=1/`nclasses'{
					gen double `_prob`s''=exp(ln(scalar(`_nums`s''))-`_lndens')  if `touse'			
				}
			}
			else {
				fmlogit `depvarclass' if `touse', eta(`membership') 
				matrix `cm_coefs' = e(b)
				fmlogit_pr `_prob' if `touse' 				 
			}		
			replace `_lnden'= ln(`_den_rhs') if `touse'
			forvalues s=1/`nclasses'{
				replace `_h`s''=exp(ln(`_prob`s'')+`_kbbb`s''-`_lnden') if `touse'							 
				by `id': replace `_H`s''=`_h`s''[_N] if `touse'
				count if `_H`s''< smallestdouble() & `touse'
				if r(N)>0 {
					levelsof `id' if `_H`s'' < smallestdouble() & `touse', local(_Hzero)
					noisily di as error "Note: The conditional probability of being in Class`s' is zero for the following agents: `_Hzero' "
				}
			}
						
	**Update the log likelihood**
			sum `_lnden' if `touse'&`ncm'==1 , meanonly	
			local z=r(sum)
			
	**Stop the loop if the relative change in the log likelihood over the last 5 iterations meet the convergence criterion**
			local _sl`i'=`z'
			if `i'>6 {
				if (-(`_sl`i''-`_sl`=`i'-5'')/`_sl`=`i'-5'')<=`convergence' {
					continue, break
				}
			}		
			}
			`display' as green "Iteration " `i' ":  log likelihood = " as yellow `z'
			}

	************
	**End loop**
	************
	**Warn that EM iterations stopped prematurely**
	if `i' == `iterate' di as txt "The maximum number of iterations has been reached."
	
	**Create table of results**
	quietly	{			
	forvalues s=1/`nclasses' {		
		matrix coleq `b`s''=choice`s'
		matrix rowname `b`s''=Class`s'
		if "`membership'" != "" {	
			if (`s' < `nclasses') matrix `CMB' = nullmat(`CMB') \ `cm_coefs'[1,`=`cm_parm'*(`s'-1) + 1'..`=`cm_parm'*`s''] 
			else matrix `CMB' = `CMB' \ J(1,`cm_parm',0)					
		}
		if "`const`s''" != "" {
			capture mat roweq `_const`s'' = Class`s'
			capture mat `Cns' = nullmat(`Cns') \ `_const`s''
		}
		su `_prob`s'' if `ncm'==1, meanonly
	    matrix `pr' = (nullmat(`pr') \  r(mean))
	}
    mat colname `pr'= "Class Share"	
	}
	forvalues s=1/`=`nclasses'-1'{
		if "`membership'" != "" {
			foreach v of varlist `membership' {
				local shares "`shares' share`s'"
			}
		}
		local classes "`classes' Class`s'"
		local shares "`shares' share`s'"	
	}

	mat rownames `pr'=`classes'	Class`nclasses'
	if ("`membership'" == "") {
		matrix `CMB' = `pr'
		mata: st_replacematrix("`CMB'", ln(st_matrix("`CMB'"):/st_matrix("`CMB'")[`nclasses',1]))
		matrix `cm_coefs' = `CMB'[1..`=`nclasses'-1',1]' 
		matrix colnames `cm_coefs' = _cons
	}
	mat coleq `cm_coefs' = `shares'
	mat coleq   `CMB'    = :
	mat colname `CMB'    = `membership' _cons
	mat rowname `CMB'    = `classes' Class`nclasses'
				
 	**create temporary matrix containing the vectors of coefficients**
	forvalues s=1/`nclasses'{
		matrix `coefs' = (nullmat(`coefs') \  `b`s'')
		matrix `betas' = (nullmat(`betas'), `b`s'')
	}
	matrix `betas' = `betas', `cm_coefs' 
	mat coleq `coefs'="Coefficients of"

	**Create the vector of average coefficients**
	mat `ac' = `pr''*`coefs'
	mat coleq `ac'="Average of"
	mat rowname `ac' = "Coefficients"
	
	**Create the covariance matrix of choice model parameters**
	mat `covc' = `coefs''*`coefs'
	mata: st_replacematrix("`covc'",(st_matrix("`pr'"):*(st_matrix("`coefs'"):-st_matrix("`ac'")))'*(st_matrix("`coefs'"):-st_matrix("`ac'")))
	mat coleq `covc' = : 	
	mat roweq `covc' = :
	
	** Create AIC, CAIC and BIC **
	*get the number of choice makers:
	qui count if `ncm'==1 & `touse'==1
	local cm=r(N)
	*get the number of constraints:
	local ncons = 0 
	if "`constraints'" != "" {
		capture local ncons = rowsof(`Cns')
	}
	
	local bic=-2*`z'+[`np'*`nclasses'+`cm_parm'*(`nclasses'-1)-`ncons']*log(`cm')
	local caic=-2*`z'+[`np'*`nclasses'+`cm_parm'*(`nclasses'-1)-`ncons']*(log(`cm')+1)
	local aic=-2*`z'+2*[`np'*`nclasses'+`cm_parm'*(`nclasses'-1)-`ncons'] 

	**Save the e() results**	
	ereturn post `betas', esample(`touse')
	ereturn local group `group'
	ereturn local id `id'
	ereturn local depvar `depvar'
	ereturn local indepvars `varlist'
	if ("`membership'" != "") ereturn local indepvars2 `membership' 
	ereturn local cmd "lclogit"
	ereturn local title "Model estimated via EM algorithm"
	ereturn local seed `seed' 
	ereturn scalar N = `N' // # of obs
	ereturn scalar ll = `z' // log likelihood
	ereturn scalar nclasses = `nclasses' // # of latent classes
	ereturn scalar N_g = `cs' // # of choice situations as identified by group
	ereturn scalar N_i = `cm' // # of choice makers as identified by id  
	ereturn scalar bic = `bic'			
	ereturn scalar caic = `caic'			
	ereturn scalar aic = `aic'
	if (`ncons'>0) ereturn matrix Cons = `Cns' // binding constraints
	ereturn matrix CMB = `CMB', copy // class membership model parameter estimates
	ereturn matrix CB = `covc', copy // average variance and covariances
	ereturn matrix PB =	`ac', copy // weighted average taste parameter estimates
	ereturn matrix P = `pr', copy // average class shares
	ereturn matrix B = `coefs', copy // choice model parameter estimates
	Replay
end

program Replay
	di as gr ""	
	di as gr "Latent class model with `e(nclasses)' latent classes"
	di as gr ""
	if "`e(indepvars2)'" != "" {
		di as gr "Choice model parameters and average classs shares"
	}
	local _int = int(`e(nclasses)'/5)
	if `e(nclasses)'>20 {
		di as g "Note: Results for models with more than 20 classes can be displayed using the matrices in e(B) and e(P)"
		matlist e(B), format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined) 
		matlist e(P), format(%7.3f) border(top bottom)   
	}
	else {
		tempname B B_5 B_10 B_15 B_20 
		matrix `B' = e(B), e(P)
		matrix coleq `B' = :
		forvalues i = 1/`=`_int'+1' {
			if (`=`i'*5' <= `e(nclasses)') matrix `B_`=`i'*5'' = `B'[`=`i'*5-4'..`=`i'*5',1...]
			else if (`=`i'*5' != `=`e(nclasses)'+5') matrix `B_`=`i'*5'' = `B'[`=`i'*5-4'..`e(nclasses)',1...]		
			if (`=`i'*5' != `=`e(nclasses)'+5') matlist `B_`=`i'*5''', format(%7.3f) rowtitle(Variable) ///
																			border(top bottom) lines(rowtotal) noblank	
		}		
	}
	if "`e(indepvars2)'" != "" {
		di as gr ""
		di as gr "Class membership model parameters : Class`e(nclasses)' = Reference class"
		tempname CMB CMB_5 CMB_10 CMB_15 CMB_20
		matrix `CMB' = e(CMB)
		if `e(nclasses)' > 20 {
			di as g "Note: Results for models with more than 20 classes can be displayed using the matrix in e(CMB)"		
			matlist e(CMB), format(%7.3f) rowtitle(Variable) border(top bottom) 
		}
		else {
			forvalues i = 1/`=`_int'+1' {
				if (`=`i'*5' <= `e(nclasses)') matrix `CMB_`=`i'*5'' = `CMB'[`=`i'*5-4'..`=`i'*5',1...]
				else if (`=`i'*5' != `=`e(nclasses)'+5') matrix `CMB_`=`i'*5'' = `CMB'[`=`i'*5-4'..`e(nclasses)',1...]
				if (`=`i'*5' != `=`e(nclasses)'+5') matlist `CMB_`=`i'*5''', format(%7.3f) rowtitle(Variable) border(top bottom) noblank
			}			 
		}
	}
	di as gr ""
	di as gr "Note: `e(title)'"
end
exit
