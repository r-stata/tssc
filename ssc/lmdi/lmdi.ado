*! version 3.2.3, 2017-12-31
* By Kerry Du
capture program drop lmdi
program define lmdi, rclass 
	version 12.0
	* syntax 
	*       lmdi decom_var = varlist, t(varname) over(varlist) [ADD ///
	*                                     zero(real 1e-20) tol(real 0.01) sav(string) replace]
	*		lmdi decom_var = (factor_1_varlist)..  factor_k_varname ... factor_n_varname, ///
	*                                  t(varname) over(varlist) [ADD zero(real 1e-20) tol(real 0.01) sav(string) replace]
	*		lmdi decom_var =  factor_1_varname ... factor_k_varname...(factor_n_varlist), ///
	*                                   t(varname) over(varlist) [ADD zero(real 1e-20) tol(real 0.01) sav(string) replace]
	*       
	* example
	*       lmdi E= (Es1 Es2 Es3) I Y, t(year) over(region sector) 
	
	
	//disp "`0'"
	
	
	gettoken cmla 0: 0, p(",")

	syntax, t(varname numeric) over(varlist) [ADD zero(real 1e-20) TOLerance(real 0.01) SAVing(string) REPLACE]
	
	
	
	preserve
	gettoken yvar cmla: cmla, p("= ( ),")
	
	if ("`yvar'"=="=" | "`yvar'"=="," | "`yvar'"=="(" | "`yvar'"==")"){
		disp as red "The decomposed variable must be specified!"
		exit 198
	}
	gettoken word cmla: cmla, p("= ( ),")
	
	if !strmatch("`word'","=") {
		disp as red `"Only one variable before "=" is allowed!"'
		exit 198
	
	}
	
	local k=0
	gettoken word cmla:cmla,p("= ( ),")
	local idflag `over'
	//local pjlist 
	while !("`word'"==","| "`word'"=="") {
	//disp "`word'"
		local k=`k'+1
		if ("`word'"=="(" ){
			local pj=0
			gettoken word cmla: cmla,p("= ( ),")
			while !("`word'"==")" | "`word'"==""){
				//tempvar _eff`k'_`t'
				//qui gen _eff`k'_`t'=`word'
				//disp "`word'"
				local pj=`pj'+1
				rename `word' _eff`k'_`pj'
				local eff`k' `eff`k'' `word'
				gettoken word cmla: cmla,p("= ( ),")
			}

			local pjlist `pjlist' `pj'
			local reshvar `reshvar' _eff`k'_
			gettoken word cmla: cmla,p("= ( ),")
			//tempvar _eff`k'
			//tempvar id`k'
			//qui reshape long _eff`k'_, i(`t' `idflag') j(`id`k'')
			//local idflag `idflag' `id`k''
			//disp "`idflag'"
		}
		else {
			//disp "`word'"
			//tempvar  _eff`k'
			//qui gen `_eff`k''=`word'
			rename `word' _eff`k'_
			local eff`k'  `word'
			gettoken word cmla: cmla,p("= ( ),")
		}
		//disp "eff`k'=`eff`k''"
	
	}
	
	gettoken pj1 pjlist: pjlist
	while !("`pjlist'"==""){
		//disp "`pj1'"
		gettoken pj2 pjlist: pjlist
		//disp "`pj2'"
		if !strmatch("`pj1'","`pj2'"){
			disp as red "ERROR: the # of vars in different parenthese ( ) should be equal."
			restore
			exit 198
		}
		local pj1 `pj2'
	}
	
	if !("`pj1'"=="") {
		tempvar _newid
		qui reshape long `reshvar', i(`t' `idflag') j(`_newid')
		local idflag `idflag' `_newid'
	}
	//disp "`0'"
	
	//local 0 ", `0'"
	//syntax, t(varname) over(varlist) [ADD zero(real 1e-20) crtv(real 0.01)]
	
	//syntax varlist, t(varname) over(varlist) [ADD zero(real 1e-20) crtv(real 0.01)]
	
	/*
	qui egen _chsum0=rowtotal(`sum')
	qui egen _chsum1=total(_chsum0), by(`t')
	
	cap assert abs(_chsum/`yvar'-1)<=`crtv'
	if _rc!=0 {
		disp as red "ERROR:The varlist can not form an identity"
		restore
		exit
	}
	*/
	
	//disp "k=" `k'
	
	
	tempvar chprod chsum2 lfun dfun Dtot2
	
	qui gen `chprod'=1
	forvalues i=1/`k' {
		qui replace _eff`i'_=`zero' if missing(_eff`i'_)| _eff`i'_==0
		qui replace `chprod'=`chprod'*_eff`i'_
		
	}
	
	qui egen `chsum2'=total(`chprod'), by(`t')
	
	cap assert abs(`chsum2'/`yvar'-1)<=`tolerance'
	
	if _rc!=0 {
		disp as red "ERROR:The specified variables can not form an identity"
		restore
		exit
	}
	
	
	qui gen `lfun'=0
	
	qui bys `idflag' (`t'): replace `lfun'= ///
		(`chprod'-`chprod'[_n-1])/ln(`chprod'/`chprod'[_n-1]) if `chprod'!=`chprod'[_n-1]
	
	
	tempvar _Dtot
	if !("`add'"==""){
		qui bys `idflag' (`t'): gen `_Dtot'=`yvar'-`yvar'[_n-1]
		qui gen `Dtot2'=0 
		qui gen `dfun'=1
	}
	else {
		qui bys `idflag' (`t'): gen `_Dtot'=`yvar'/`yvar'[_n-1]
		qui gen `dfun'=0
		qui gen `Dtot2'=1 
		qui bys `idflag' (`t'): replace `dfun'= ///
		  (`yvar'-`yvar'[_n-1])/ln(`yvar'/`yvar'[_n-1]) if `yvar'!=`yvar'[_n-1]	
	
	}
	
	
	//disp "k="`k'
	
	qui su `t'
	local mint=r(min)
	
	
	forvalues i=1/`k' {
		tempvar tempEFF`i' _EFF`i'
		qui bys `idflag' (`t'):  gen `tempEFF`i''=`lfun'/`dfun'*ln(_eff`i'_/_eff`i'_[_n-1])
		//qui bys `idflag' (`t'):  gen `tempEFF`i''=`lfun'/`dfun'*ln(`_eff`i''/`_eff`i''[_n-1])
		qui egen `_EFF`i''=total(`tempEFF`i''), by(`t')
		//label var _EFF`i' `"Effecf of change in (`eff`i'')"'
		qui replace `_EFF`i''=. if `t'==`mint'
		if !("`add'"==""){
			qui replace `Dtot2'=`Dtot2'+`_EFF`i''
			
		}
		else {
			qui replace `_EFF`i''=exp(`_EFF`i'')
			qui replace `Dtot2'=`Dtot2'*`_EFF`i''
		
		}
		
		local resmat `resmat' `_EFF`i''
		local matcnames `matcnames' "Eff_`i'"
		//local matcnames `matcnames' _EFF`i'
	}
	
	
		cap assert abs(`_Dtot'/`Dtot2'-1)/`_Dtot'<`tolerance' if ~missing(`_Dtot')
		if _rc!=0 {
			disp as red "Warning: The difference between the real change and the decomposed effects in total is large than `=`crtv'*100'%."
			disp as red "         Please check your data preparation!"
		
		}
		
		qui tab `t', nofreq
		local nt=r(r)
		sort `idflag' `t'
		tempvar From To
		qui bys `idflag' (`t'): gen `From'=`t'[_n-1] if _n>1 
		qui bys `idflag' (`t'): gen `To'  =`t'       if _n>1 
		sort `idflag' `t'
		
		//tempvar t0
		//qui bys `idflag' (`t'): gen `t0'=`t'[_n-1] if _n>1
		//qui cap mkmat `t0' `t' `_Dtot' `resmat' in 2/`nt', mat(mat4prt)
		qui cap mkmat `From' `To' `_Dtot' `resmat' in 2/`nt', mat(mat4prt)
		if _rc!=0 {

			disp _n as red "Warning: Matsize too small to create a `=`nt'-1'x`=`k'+3', results are not displayed."
			disp    as red "         You should improve the matsize, or save the results in filename.dta."
		}
		else {
			//matrix colnames mat4prt = "From" "To" "_Dtot" `matcnames'
			matrix colnames mat4prt = "From" "To" "Dtot" `matcnames'
			//disp _n
			matlist mat4prt, name(c) bor title("LMDI decomposition results:")
			//disp "   The decomposition results are presented as follows."
			//list  _Period _Dtot _EFF* in 2/`nt', c sep(0) t
			disp "Note:"
			disp as yellow "     Dtot  : Change in  `yvar' over times"
			forvalues i=1/`k'{
					disp as yellow "     Eff_`i' : Effect of change in ( `eff`i'' )"
				}

		}

		
		if !("`saving'"==""){
			//qui putmata period=`_Period' in 1/`nt', replace
			//qui putmata result=(`_Dtot' `resmat') in 1/`nt', replace
			sort `idflag' `t'
			qui drop if _n>`nt'
			//list `_Dtot'
			mata: effmat=st_data(.,"`_Dtot' `resmat'")
			qui keep `t'
			sort `t'
			//qui getmata _Period=period ( _Dtot `matcnames')=result, force
			qui gen From=`t'[_n-1] if _n>1
			qui gen To=`t' if _n>1
			qui gen Dtot=.
		    mata: st_view(X2=.,.,"Dtot")
		    mata: X2[1::rows(effmat)]=effmat[.,1]
			label var Dtot "change of `yvar'"
			forvalues i=1/`k'{
				qui gen Eff_`i'=.
				mata: st_view(X3=.,.,"Eff_`i'")
			    mata: X3[1::rows(effmat)]=effmat[.,`=`i'+1']
				label var Eff_`i' "Effect of change in ( `eff`i'' )"
				
			}
			//list From To Dtot Eff_* if _n>2,  t sep(0)
			save `saving', `replace'
			disp _n
			disp as yellow "The results are also saved in `saving'.dta."
		}

		restore
		
	end
	
	
