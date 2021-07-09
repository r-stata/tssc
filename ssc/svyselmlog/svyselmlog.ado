/* Modified programme to incorporate svy features in the original -selmlog- (23/May/05)
R.E. De Hoyos, University of Cambridge */

*Programme to identify strata with single PSU 
cap program drop singleton
program define singleton, sort
version 8
	syntax [varlist(numeric default=none)] [if] [in], ///
	STRata(varname) gen(name) [ PSU(varname) ]
	confirm new var `gen'
	marksample touse
	if "`psu'" == "" {
	tempvar psu
	gen `psu' = _n
	}
	tempvar u
	sort `touse' `strata' `psu'
	quietly by `touse' `strata' `psu': gen `u' = _n == 1
	quietly by `touse' `strata': replace `u' = sum(`u')
	quietly by `touse' `strata': replace `u' = cond(`u'[_N] == 1, 1, 0)
	
	quietly replace `u' = . if !`touse'
	rename `u' `gen'
	end


program define svyselmlog, eclass sortpreserve
version 8
	
	tempvar id
	qui gen `id' = _n 
 	
	_svy_newrule , `weight' `strata' `psu' `fpc'
	
	syntax varlist [if] [in], SELect(string) [METHod(string asis) SHOWmlogit BOOTstrap(string) MLOPtions(string) Gen(string) Force Quiet]
	
	if "`showmlogit'" != "" & "`bootstrap'" != "" {
	noi di in red "Bootstrap and showmlogit options cannot be used at the same time"
	exit 198
	}
	if "`gen'" != "" & "`bootstrap'" != "" {
	noi di in red "Bootstrap and generate options cannot be used at the same time"
	exit 198
	} 
	
	tokenize `varlist'
	local y `1'
	
	tokenize `bootstrap'
	local K `1'
	
	tempvar st psu
	qui svyset
	if "`r(strata)'"=="" {
		qui g `st' = 1
	}
	else {
		qui g `st' = `r(strata)'
	}
	if "`r(psu)'"=="" {
		qui g `psu' = _n
	}
	else {
		qui g `psu' = `r(psu)'
	}

	tempvar singleton singleton1 singleton2 singleton_all stsin exstr grid grid2 gr
	qui singleton `varlist', strata(`st') psu(`psu') gen(`singleton1')
	qui singleton `select', strata(`st') psu(`psu') gen(`singleton2')
	qui g `singleton' = `singleton1'==1 | `singleton2'==1
	qui bys `st': egen `stsin' = max(`singleton')
	qui bys `st': g `exstr'=cond(`stsin'==1 & _n==1, 1, 0)  
	qui sum `exstr'
	local stc `r(sum)'
	 
	qui bys `st' `psu': g long `grid'=1 if _n==1
	qui sum `grid'
	qui replace `grid'= `r(sum)'
	qui bys `psu': g long `grid2'=1 if _n==1
	qui replace `grid2'= `r(sum)'
	qui g `gr'=`grid'==`grid2'
	
	if "`bootstrap'"=="" {
		if "`force'"!="" {
			qui sum `singleton'
			local s `r(sum)'
			if `r(max)' == 0 {
				base `varlist' `if' `in', select(`select') method(`method') `showmlogit' mloptions(`mloptions') gen(`gen') `force' 
				di in gr "`method' method used for selectivity correction"
				di in yellow "Warning: Standard Errors are not accouting for the two-step procedure"
			}
			else {
				preserve
				qui drop if `stsin'==1
				noi di in ye "Warning: `stc' strata (`s' observations) excluded from the estimation due to single PSU restrictions"
				base `varlist' `if' `in', select(`select') method(`method') `showmlogit' mloptions(`mloptions') `force'
				di in gr "`method' method used for selectivity correction"
				di in yellow "Warning: Standard Errors are not accouting for the two-step procedure"
				restore 
			}
		}
		else {
			base `varlist' `if' `in', select(`select') method(`method') `showmlogit' mloptions(`mloptions') gen(`gen') `force' 
			di in gr "`method' method used for selectivity correction"
			di in yellow "Warning: Standard Errors are not accouting for the two-step procedure"
		}
	}
	else {
		if `gr'==0 {
			di in red "PSU values repeated for two or more different Strata"
			exit 198
		} 
		if "`force'"!="" {
			tempname b bstrv
			local k=1
			singleton , strata(`st') psu(`psu') gen(`singleton_all')
			preserve
			while `k'<=`K' {
				svybsamp2								
				tempvar singleton`k' singleton1`k' singleton2`k' stsin`k'					
				singleton `varlist', strata(`st') psu(`psu') gen(`singleton1`k'')
				singleton `select', strata(`st') psu(`psu') gen(`singleton2`k'')
				qui g `singleton`k'' = `singleton1`k''==1 | `singleton2`k''==1
				qui bys `st': egen `stsin`k'' = max(`singleton`k'')
				qui drop if `stsin`k'' == 1
				base `varlist' `if' `in', select(`select') method(`method') bootstrap mloptions(`mloptions') `force'
				if "`quiet'" == "" {
					noi di in gr "Resampling `k' in progress"
				}
				tempname b`k'
				matrix `b`k''=e(b)
				if `k'==1 {
					matrix `b'=`b`k''
				}
				if `k'>1 {
					matrix `b'=`b'+`b`k''
				}	
				restore, preserve 
				local k=`k'+1
			}
		}
		else {			
			tempname b bstrv
			local k=1
			preserve
			while `k'<=`K' {
				svybsamp2				
				base `varlist' `if' `in', select(`select') method(`method') bootstrap mloptions(`mloptions') `force'
				if "`quiet'" == "" {
					noi di in gr "Resampling `k' in progress"
				}
				tempname b`k'
				matrix `b`k''=e(b)
				if `k'==1 {
					matrix `b'=`b`k''
				}
				if `k'>1 {
					matrix `b'=`b'+`b`k''
				}	
				restore, preserve 
				local k=`k'+1
			}
		}
	
		local k=1
		while `k'<=`K' {
			if `k'==1 {
				matrix `bstrv'=(`b`k'' - (`b'/`K'))'*(`b`k'' - (`b'/`K'))
			}
			if `k'>1 {
				matrix `bstrv'=`bstrv'+(`b`k'' - (`b'/`K'))'*(`b`k'' - (`b'/`K'))
			}
			local k=`k'+1
		}
		matrix `bstrv'=`bstrv'/(`K'-1)
		
		restore, preserve
		tempvar singletonf singletonf1 singletonf2 stsinf
		singleton `varlist', strata(`st') psu(`psu') gen(`singletonf1')
		singleton `select', strata(`st') psu(`psu') gen(`singletonf2')
		qui g `singletonf' = `singletonf1'==1 | `singletonf2'==1
		qui bys `st': egen `stsinf' = max(`singletonf')
		if "`force'"!="" {
			qui drop if `stsinf' == 1
		}
		base `varlist' `if' `in', select(`select') method(`method') `showmlogit' bootstrap mloptions(`mloptions') gen(`gen') `force' 
		di in gr "`method' method used for selectivity correction"
		matrix `b'=e(b)
		ereturn post `b' `bstrv', depname("`y'")
		di _newline
		di in gr "Selectivity correction based on multinomial logit"
		di in gr "Second step svy regression"
		di in gr "Bootstrapped standard errors (`K' replications)"
		ereturn display
		restore
	}
	
	qui cap drop _m*
end

capture program drop glquad
program define glquad
version 6.0

	local mp="`1'"
	local vp="`2'"
	local p="`3'"
	
	local x1=.093307812017
	local x2=.492691740302
	local x3=.1215595412071*10
	local x4=.2269949526204*10
	local x5=.3667622721751*10
	local x6=.5425336627414*10
	local x7=.7565916226613*10
	local x8=.101220228568019*100
	local x9=.13130282482176*100
	local x10=.16654407708330*100
	local x11=.20776478899449*100
	local x12=.25623894226729*100
	local x13=.31407519169754*100
	local x14=.38530683306486*100
	local x15=.48026085572686*100
	
	local w1=.218234885940
	local w2=.342210177923
	local w3=.263027577942
	local w4=.126425818106
	local w5=.402068649210*1e-1
	local w6=.856387780361*1e-2
	local w7=.121243614721*1e-2
	local w8=.111674392344*1e-3
	local w9=.645992676202*1e-5
	local w10=.222631690710*1e-6
	local w11=.422743038498*1e-8
	local w12=.392189726704*1e-10
	local w13=.145651526407*1e-12
	local w14=.148302705111*1e-15
	local w15=.160059490621*1e-19
	
	qui gen `mp'=0
	qui gen `vp'=0
	local i=1
	while `i'<=15 {		
		qui replace `mp'=`mp'+`w`i''*invnorm(exp(-`p'*`x`i''))
		qui replace `vp'=`vp'+`w`i''*(invnorm(exp(-`p'*`x`i'')))^2
		local i=`i'+1
	}

end

capture program drop base
program define base
version 6.0

	syntax varlist [if] [in], SELect(string) [METHod(string asis) SHOWmlogit BOOTstrap MLOPtions(string) Gen(string) Force]
	
	tempvar smpl
	gen `smpl'=1
	
	tokenize `dhl', parse(" ")
	local order `1'
	local prnb `2'
		
	tokenize `select', parse(" ")
	local m `1'
	
	tokenize `varlist'
	local y `1'
	macro shift
	while "`1'"~="" {
		qui replace `smpl'=0 if `1'==. & `y'~=.
		macro shift
	}
	
	qui sum `smpl'
	if r(mean)~=1 {
		di in red "Beware: the svymlogit step uses observations that have missing values in the main equation"
	}
	
	if "`showmlogit'"=="showmlogit" {
		svymlogit `select' `if' `in', `mloptions' 
	}
	else {
		qui svymlogit `select' `if' `in', `mloptions'
	}		
	
	local nselcat=0
	global m
	local n=colsof(e(cat))
	
	local i=1
	while `i'<=`n' {
		local cat`i'=el(e(cat),1,`i')
		tempname P`cat`i''
		qui predict `P`cat`i''' if e(sample), outcome(`cat`i'')
		qui sum `y' if `m'==`cat`i''
		if r(mean)~=. {
			local selcat=`cat`i''
			local nselcat=`nselcat'+1
		}
		if `nselcat'>1 {
			di in red "Non-missing values of dependent variable for more than one outcome" 
			exit 198
		}
		local i=`i'+1
	}
	
	
	gettoken cstr rubbish: method, bind
	gettoken meth odhlp: cstr, parse(" (")
	gettoken opt rubbish2: odhlp, match(par)
	tokenize `opt'
	local order `1'
	local prnb `2'
	global methn `meth'
	global scat
	
	local i=1
	while `i'<=`n' {
		capture drop _m`cat`i''

		****LEE*******
		
		if "`meth'"=="lee" {
			if `cat`i''==`selcat' {
				qui gen _m`cat`i''=normd(invnorm(`P`selcat''))/(`P`selcat'')
				global scat $scat `cat`i''
				global m "$m _m`cat`i''"
			}
		}
		
		
		****DMF****
		
		if "`meth'"=="dmf" {
			if `cat`i''~=`selcat' {
				qui gen _m`cat`i''=`P`cat`i'''*ln(`P`cat`i''')/(1-`P`cat`i''')+ln(`P`cat`i''')
				global scat $scat `cat`i''
				global m "$m _m`cat`i''"
			}
		}
		
		
		****DMF2******
		
		if "`meth'"=="dmf2" | "`meth'"=="" {
			tempvar v`i'
			qui glquad _m`cat`i'' `v`i'' `P`cat`i'''
			
			if `cat`i''~=`selcat' {
				qui replace _m`cat`i''=_m`cat`i''*`P`cat`i'''/(`P`cat`i'''-1)
			}
			global scat $scat `cat`i''
			global m "$m _m`cat`i''"
			global methn dmf2
		} 
		
		
		****DHL*****
		
		if "`meth'"=="dhl" {
			if "`opt'"=="" {
				di in red "Options needed when method DHL is specified"
				error 198
			}
			if "`odhlp'"~="" {	
				if `cat`i''==`selcat' {	
					if `order'==. {
						local order=1
					}
					if "`prnb'"=="one" | "`prnb'"=="" { 
						local o=1
						while `o'<=`order' {
						qui gen _m`cat`i''`o'=(`P`selcat'')^`o'
						global scat $scat `cat`i''
						global m "$m _m`cat`i''`o'"
						local o=`o'+1
						}
					}
					if "`prnb'"=="all" { 
						local w=0
						while `w'<`n' {
						local o=1
						while `o'<=`order' {
						qui cap gen _m_`w'`o'=(`P`w'')^`o'
						global m "$m _m_`w'`o'"
						local o=`o'+1
						}
						local w=`w'+1
						}
					}
				}
			}
		}
	local i=`i'+1
	}
	

	if "`bootstrap'"~="" {
		qui svyregress `varlist' $m `if' `in'
	}
	else {
		if "`force'"!="" {
			tempvar st psu stsinr singletonr
			qui svyset
			if "`r(strata)'"=="" {
				qui g `st' = 1
			}
			else {
				qui g `st' = `r(strata)'
			}
			if "`r(psu)'"=="" {
				qui g `psu' = _n
			}
			else {
				qui g `psu' = `r(psu)'
			}
			qui singleton `varlist' $m, strata(`st') psu(`psu') gen(singletonr)
			qui bys `st': egen `stsinr' = max(singletonr)
			preserve
			qui drop if `stsinr'==1
			svyregress `varlist' $m `if' `in'
			restore
		}
		else {
			svyregress `varlist' $m `if' `in'
		}
	}
	
	global cat
	if "`gen'" != "" {
	local scat $scat
	foreach s of local scat {
		qui gen `gen'`s' = _m`s'
		global cat $cat `gen'`s' 
	} 
	}

end
