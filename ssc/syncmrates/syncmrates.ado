
*! version 1.2 May 2015 E. Masset

/*syncmrates is the mother programme with 3 sub-routines:
	- syncmrates_1: child mortality rates with bootstrap standard errors
	- syncmrates_2: test differences in mortality rates between groups
	- syncmrates_3: mortality trends with CIs over time*/

program syncmrates
version 13
syntax varlist(min=3 max=3) [iw pw] [if] [, testby(varlist max=1) trend(string) t1(integer 1) t0(integer 61) plot(string) *]
if "`testby'"~="" {										/*error messages for option testby*/
	if "`trend'"~="" | "`plot'"~="" {
	di as error "options testby and trend/plot cannot be specified together"
	exit 198
	}
	quietly summ `testby' `if' 						
	if r(min)==r(max) {
	di as error "`testby' is a constant"
	exit 198
	}
	capture assert `testby'==r(min) | `testby'==r(max) | `testby'==. `if'	
	if _rc ~=0 {
	di as error "`testby' must take on two values"
	exit 198
	} /*call test subroutine*/
	bootstrap dnmr=(r(nmra)-r(nmrb)) dpmr=(r(pmra)-r(pmrb)) dimr=(r(imra)-r(imrb)) dcmr=(r(cmra)-r(cmrb)) du5mr=(r(u5mra)-r(u5mrb)), `options' seed(220307) force nowarn nodots noheader: syncmrates_2 `0'
	}
	else {
			if "`trend'"~="" {							/*error messages for option trend*/
			capture confirm number `trend'
			if _rc~=0 {
			di as error "trend must be a number: number of trend months"
			exit 198
			}
			syncmrates_3 `0'								/*call trend subroutine*/	
			di in blue "(data are saved as mrdata.dta in current directory)"					
			}
			else {
				if "`plot'"~="" {
				di as error "options plot cannot be specified without option trend"
				exit 198
				}
														/*call syntetic proabability rates subroutine*/
					bootstrap nmr=r(nmr) pmr=r(pmr) imr=r(imr) cmr=r(cmr) u5mr=r(u5mr), `options' seed(220307) force nowarn nodots noheader: syncmrates_1 `0'
					}
			
	}
end






