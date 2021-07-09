*! v.2 		04/18/2013		Estimation of the Standard Error of Delta 0 much more efficient		By: Alejandro Hoyos

****weights
capture program drop weights
program define weights
version 10.1
	{
	syntax varlist(min=1) [if], by(string) [fact(string)] 
	
	tempvar _fexp 
	quietly gen `_fexp' = 1


	if "`fact'"!="" {
		quietly replace `_fexp' = `fact'
	}

	tempvar _sample
	if "`if'"!=""{

	quietly gen `_sample' = 1 `if' 
	}

	if "`if'"==""{
	quietly gen `_sample' = 1
	}

	*generate cells
	tempvar _celda
	quietly egen `_celda'=group(`varlist')

	quietly replace `_celda' = .  if `_sample'!=1

	*generate supports
	tempvar _nopomin _nopomax
	quietly gen _supp=. 
	quietly bys `_celda': egen `_nopomax' = max(`by')  
	quietly bys `_celda': egen `_nopomin' = min(`by')
  	quietly replace _supp = 0 if `_nopomax' == 0 & `_sample'==1 
  	quietly replace _supp = 1 if `_nopomin' == 1 & `_sample'==1
  	quietly replace _supp = 2 if `_nopomin' == 0 & `_nopomax' == 1 & `_sample'==1

	*generate matching weight
	tempvar _prevfm _fm _prevfh _fh
	quietly bys `_celda' `by': egen `_prevfm' = total(`_fexp')
	quietly replace `_prevfm' = . if `_sample'!=1
	quietly replace `_prevfm' = . if `by'==1 
	quietly bys `_celda': egen `_fm' = mean(`_prevfm')
	quietly replace `_fm' = . if `_sample'!=1

	quietly bys `_celda' `by': egen `_prevfh' = total(`_fexp')
	quietly replace `_prevfh' = . if `_sample'!=1
	quietly replace `_prevfh' = . if `by'==0 
	quietly bys `_celda': egen `_fh' = mean(`_prevfh')
	quietly replace `_fh' = . if `_sample'!=1

	quietly gen _match = .
	quietly replace _match = `_fexp' if `by'==0 & _supp==2 & `_sample'==1
	quietly replace _match = `_fexp'*`_fm'/`_fh' if `by'==1 & _supp==2 & `_sample'==1
	quietly replace _match = 0 if _supp==0 | _supp==1 & `_sample'==1
	lab var _supp  "Support"
	lab var _match "Weight after matching"

	cap label define _supplabel 0 "Category by-variable=0 out of the common support"
	cap label define _supplabel 1 "Category by-variable=1 out of the common support", add
	cap label define _supplabel 2 "In the common support", add
	cap label values _supp _supplabel
	}
end


**Deltas
capture program drop deltas
program define deltas
version 10.1
	{
	syntax varlist [if], match(string) outcome(string) supp(string) by(string) [fact(string)] [filename(string)]

	tempfile main
	quietly save `main', replace
	
	tempvar _sample
	if "`if'"!=""{
	quietly gen `_sample' = 1 `if' 
	}
	if "`if'"==""{
	quietly gen `_sample' = 1
	}

	tempvar _fexp 
	quietly gen `_fexp' = 1

	if "`fact'"!="" {
	quietly replace `_fexp' = `fact'
	}

	
	*******************
	*Compute Deltas
	********************
	*generate rwage
	cap drop _rwage
	quietly sum `outcome' if `by'==0 & `_sample'==1 [iw =`_fexp']
	quietly gen _rwage=`outcome'/ r(mean) if `_sample'==1 
	quietly drop if _rwage==. & `_sample'==1
	lab var _rwage "Outcome - normalized"
	
	quietly summ `by' if `by'==0 & `_sample'==1 [iw= `_fexp']
	local _TF=r(sum_w)
	quietly summ `by' if `by'==1 & `_sample'==1 [iw= `_fexp']
	local _TM=r(sum_w)
	quietly summ `supp' if `supp'==0 & `_sample'==1 [iw=`_fexp']
	local _outF=r(sum_w)
	quietly summ `supp' if `supp'==1 & `_sample'==1 [iw=`_fexp']
	local _outM=r(sum_w)
	quietly summ `supp' if `supp'==2 & `by'==0 & `_sample'==1 [iw=`_fexp'] 
	local _commF=r(sum_w)
	quietly summ `supp' if `supp'==2 & `by'==1 & `_sample'==1 [iw=`_fexp'] 
	local _commM=r(sum_w)

	local _percM=`_commM' / `_TM'  
	local _percF=`_commF' / `_TF' 
		
	local _ratio1=`_outM' / `_TM'  
	local _ratio0=`_outF' / `_TF' 
	
	*** DELTA
	qui su _rwage if `by'==1 & `_sample'==1 [iw = `_fexp']
	local _rwage1=r(mean)
	qui su _rwage if `by'==0 & `_sample'==1 [iw = `_fexp']
	local _rwage0=r(mean) 
	local _D = `_rwage1'-`_rwage0'
	
	*** DELTA 0
	qui su _rwage [iw=`match'] if `by'==1 & `_sample'==1
	local _rwage1=r(mean)
	qui su _rwage [iw=`match'] if `by'==0 & `_sample'==1
	local _rwage0=r(mean) 
	local _D0 = `_rwage1'-`_rwage0'
	
	*** DELTA M
	qui su _rwage [iw=`_fexp'] if `by'==1 & `supp'==1 & `_sample'==1
	local _rwage1=r(mean)
	qui su _rwage [iw=`_fexp'] if `by'==1 & `supp'==2 & `_sample'==1
	local _rwage0=r(mean) 
	local _DM = (`_rwage1'-`_rwage0')*`_ratio1'
	
	*** DELTA F
	qui su _rwage [iw=`_fexp'] if `by'==0 & `supp'==2 & `_sample'==1
	local _rwage1=r(mean)
	qui su _rwage [iw=`_fexp'] if `by'==0 & `supp'==0 & `_sample'==1
	local _rwage0=r(mean) 
	local _DF = (`_rwage1'-`_rwage0')*`_ratio0'
	
	*** DELTA X
	qui su _rwage [iw=`match'] if `by'==1 & `supp'==2 & `_sample'==1
	local _rwage1=r(mean)
	qui su _rwage [iw=`_fexp'] if `by'==1 & `supp'==2 & `_sample'==1
	local _rwage0=r(mean) 
	local _DX = `_rwage0'-`_rwage1'

		
	display in green "*****************************************************************"	
	display in green "*****  Gap in `varlist' decomposition"
	display in green "*****************************************************************"	
	display in yellow "D  =" `_D'
	display in yellow "D0 =" `_D0'
	display in yellow "DM =" `_DM'
	display in yellow "DF =" `_DF'
	display in yellow "DX =" `_DX'
	display in green "*****************************************************************"	
	display in yellow "percM =" `_percM'
	display in yellow "percF =" `_percF'
	display in green "*****************************************************************"

	use `main', clear

	if "`filename'"!="" {
	tempfile main
	quietly save `main', replace
	quietly clear
	quietly set obs 1
	quietly gen controls = "`varlist'"
	quietly gen D = `_D'
	quietly gen D0 = `_D0'
	quietly gen DM = `_DM'
	quietly gen DF = `_DF'
	quietly gen DX = `_DX'
	quietly gen percM = `_percM'
	quietly gen percF = `_percF'
	quietly save "`filename'.dta", replace
	quietly use `main', clear
	}
	}
end
	
**Standard Errors
capture program drop sderrors2
program define sderrors2, rclass
version 10.1
	{
	syntax varlist(min=1) [if], outcome(string) supp(string) by(string) [fact(string)]

	tempfile main 
	quietly save `main', replace
	if "`if'"!=""{
	quietly keep `if'
	}
	
	tempvar _fexp 
	quietly gen `_fexp' = 1

	if "`fact'"!="" {
	quietly replace `_fexp' = `fact'
	}


	**gen rwage
	cap drop _rwage
	quietly sum `outcome' if `by'==0  [iw =`_fexp']
	quietly gen _rwage=`outcome'/ r(mean) 
	quietly drop if _rwage==. 
	lab var _rwage "Outcome - normalized"


	quietly keep if `supp'==2
	
	quietly count
	if (r(N)==0){
		display in yellow "Std.error can not be calculated by lack of common support"
		return scalar _dev=.
	}

	if (r(N)!=0){
	/*alfa = Nf/Nm*/
	quietly summ `_fexp' if `by'==1
	local _Nm = r(sum)
	quietly summ `_fexp' if `by'==0
	local _Nf = r(sum)
	local _alpha = `_Nf'/`_Nm'
	

	/*tamanios sin factores de expansion*/
	quietly count if `by'==1
	local _nm = _result(1)
	quietly count if `by'==0
	local _nf = _result(1)
		
	/*Variance of the second term of the right hand side of equation 9*/
	quietly summ _rwage if `by'==0 [iw=`_fexp']
	local _total0 = _result(4)/`_nf'
		
	/*Now I construct the first term*/
	/*1. The sample proportion of females that exhibit the set of caracteristics*/
	
	preserve
	quietly keep if `by'==0
	collapse (sum) `_fexp', by(`varlist')
	rename `_fexp' _nfcelda
	quietly gen _wf = _nfcelda/`_Nf'
	sort `varlist'
	tempfile tempo
	quietly save `tempo', replace
	restore
		
	/*2. The sample average of earnings for males that exhibit the set of characteristics*/
		
	preserve
	quietly keep if `by'==1 
	collapse (mean) _rwage [iw=`_fexp'], by (`varlist')
	rename _rwage _ym
	sort `varlist'
	quietly merge `varlist' using `tempo'
	quietly tab _merge
	quietly keep if _merge==3
	drop _merge
	sort `varlist'
	quietly count
	quietly save `tempo', replace
	restore
	
	/*the population variance of male wages that exhibit the set of characteristics*/
	
	preserve
	quietly keep if `by'==1 
	collapse (sd) _rwage [iw=`_fexp'], by (`varlist')
	quietly gen _varym = (_rwage)^2
	drop _rwage
	sort `varlist'
	quietly merge `varlist' using `tempo'
	quietly tab _merge
	quietly keep if _merge==3
	drop _merge
	sort `varlist'
	quietly count
	tempfile collapsed
	quietly save `collapsed', replace
	
	quietly gen _part1=(_wf*(1-_wf)*(_ym^2))/((`_alpha')^2)+_varym*(_wf^2)
	quietly summ _part1
	local _total1=(r(sum))/`_nm'
	
	quietly count
	local _K=_result(1) /*numero de celdas*/
	local _total2=0
	local _j=1
	quietly gen _wfym=_wf*_ym
	quietly egen _sumwfym1 = sum(_wfym)
	quietly gen _sumwfym2 = _sumwfym1 - _wfym
	quietly gen _sumwfym3 = _sumwfym2*_wfym
	
	quietly sum _sumwfym3
	local _total2 = r(sum)/2

	quietly drop _wfym _sumwfym1 _sumwfym2 _sumwfym3


	local _total2 = 2*(`_total2')/((`_nm')*((`_alpha')^2))

	local _dev = sqrt(`_total0'+`_total1'-`_total2')
	display in yellow "Std.error DO = " `_dev'
	return scalar _dev= `_dev'
	
	restore
	}
	
u `main', clear
}
end
	

***nopomatch
capture program drop nopomatch
program define nopomatch
version 10.1
{
	syntax varlist(min=1) [if], outcome(string) by(string) [sd] [replace] [reportby(string)] [fact(string)] [filename(string)]	
	if "`replace'"!=""{
		cap drop _match
		cap drop _supp
	}
		
	quietly drop if `outcome'==.

	weights `varlist' `if', by(`by') fact(`fact')	

	tempfile mainfile
	quietly save `mainfile', replace
	
	if "`reportby'"=="" {
		deltas `varlist' `if', outcome(`outcome') match(_match) supp(_supp) by(`by') fact(`fact') filename(`filename')
		if "`sd'"!="" {
			display in green "Calculating Standard Error"
			sderrors2 `varlist' `if', outcome(`outcome') supp(_supp) by(`by') fact(`fact')
			local _sd =r(_dev)	
			if "`filename'"!=""{
					tempfile temp
					quietly save `temp', replace
					u "`filename'", clear
					quietly gen sdev = `_sd'
					quietly save "`filename'", replace
 					u `temp', clear
 			}
		}		
						
	}
		
	if "`reportby'"!="" {
		tempfile mainfile
		quietly save `mainfile', replace
		
		tempfile temp
		quietly tostring `reportby', replace force
		quietly save `temp', replace		
		levelsof `reportby', local(_levels)
		local _i = 1

		foreach x of local _levels{
			display in green "`reportby' = `x'"
			if "`filename'"==""{
				if "`if'"!=""{
					deltas `varlist' `if' & `reportby'=="`x'", outcome(`outcome') match(_match) supp(_supp) by(`by') fact(`fact')
				}
				if "`if'"==""{
					deltas `varlist' if `reportby'=="`x'", outcome(`outcome') match(_match) supp(_supp) by(`by') fact(`fact')
				}
			}
			if "`filename'"!=""{

				if "`if'"!=""{
					deltas `varlist' `if' & `reportby'=="`x'", outcome(`outcome') match(_match) supp(_supp) by(`by') fact(`fact') filename(`filename'_`x')
				}
				if "`if'"==""{
					deltas `varlist' if `reportby'=="`x'", outcome(`outcome') match(_match) supp(_supp) by(`by') fact(`fact') filename(`filename'_`x')
				}
				u "`filename'_`x'", clear
				quietly gen category="`x'"
				quietly save "`filename'_`x'", replace
				#delimit ;
				if `_i'==1 {; qui save "`filename'", replace; quietly erase "`filename'_`x'.dta"; };
				if `_i'!=1 {; quietly append using "`filename'"; sort category; qui save "`filename'", replace; quietly erase "`filename'_`x'.dta";};
				#delimit cr
				label var category "Category of `reportby'"
				u `temp', clear	
			}
	
			tempfile temp
			quietly save `temp', replace		
	
			if "`sd'"!=""{
				display in green "Calculating Standard Error"
				if "`if'"!=""{
					sderrors2 `varlist' `if' & `reportby'=="`x'", outcome(`outcome') supp(_supp) by(`by') fact(`fact') 	
				}				
				if "`if'"==""{
					sderrors2 `varlist' if `reportby'=="`x'", outcome(`outcome') supp(_supp) by(`by') fact(`fact') 	
				}
				local _sd  =r(_dev)	

				if "`filename'"!=""{
					#delimit ;
					if `_i'==1 {; clear; quietly set obs 1; quietly gen category = "`x'"; quietly gen sdev = `_sd'; tempfile sderrors2; sort category; quietly save `sderrors2', replace;};
					if `_i'!=1 {; clear; quietly set obs 1; quietly gen category = "`x'"; quietly gen sdev = `_sd'; append using `sderrors2'; sort category; quietly save `sderrors2', replace;};
					#delimit cr
					u `temp', clear
				}				
			}
		local _i = `_i'+1
		}

		**merge gaps with standard errors
		if "`filename'"!=""  &  "`sd'"!="" {
			quietly u "`filename'", clear
			sort category
			quietly merge category using `sderrors2'
			sort category
			quietly drop _merge
			quietly save "`filename'", replace
		}	
		quietly u `mainfile', clear	
	}	
}

end
