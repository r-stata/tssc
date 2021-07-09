*! stkerhaz 2.0.4 EC 28NOV2005
*! Baseline Hazard Estimates via Kernel Smoother and plots

program define stkerhaz, sortpreserve
        version 7.0
	st_is 2 analysis

        syntax [if] [in] , Bwidth(numlist max=4 >0 ascending) [ Kercode(int 2) /*
                 */ NPoint(int 150) BASECHa(varname) STRATA(varname numeric)  /*
                 */ TMAX OUTfile(string) PER(integer 1) CI BY(varname numeric) /*
                 */ Level(integer $S_level) L1title(string) B1title(string) /*
                 */ Connect(string) Symbol(string)  * ]


******* General frame of the command *****************************************
/*
  Command needs a previous estimate of cumulative baseline hazard via stcox
  or sts gen or otherwise. Next increments of this function is computed at
  times where a failure occurs. This quantity is smoothed using a Kernel
  method.
  Bandwidth is the only fundamental parameter the user must specify. The bwidth
  option must contain a number, but can contain up to four numbers. More
  bandwidths look inappropriate because they can blur the plot and are useless.
  Kercode is set at Epanechnicow function because it is a general use.
  Npoint default is 150. Maybe this is the number of points in corresponding
  plot obtained using EGRET. Anyway varying the number of points usually does not
  cause valuable differences in the smoothed curve.
  In Basecha user can specify the variable storing Baseline Cumulative Hazard.
  It is an option because, if not specified, stkerhaz searches for the estimate
  of this function obtained in a previous stcox.
*/
******************************************************************************


*1 - Process options because they cannot be used at the same time
        if "`by'" != "" {
        	local strata `by'
        }
        local bnd: word count `bwidth'
        if `bnd'>1 & "`strata'"!="" {
            di as err "Multiple bandwidths and Strata are alternative options."
                  exit 198
        }
        if `bnd'>1 | "`strata'"!="" {
                if "`ci'"!=""{
                        di as err "CI option is not allowed with" /*
                          */ " Multiple bandwidth or Strata options."
                  exit 198
                }
                local pen /* no pen control if two or more lines */
        }

*2 - Get baseline cumulative hazard
        if "`basecha'" == "" {
                if "`e(cmd2)'" != "stcox" {
                  error 301
                }
                if "`e(cmd2)'" == "stcox" & "`e(basech)'" == ""  {
                        noi di as err "stcox did not save baseline cumulative hazard." _n /*
                        */ "basech(newvar) option must have been specified on the stcox" /*
                        */ " command" _n "prior to using this command"
                        exit 198
                }
                local H  `e(basech)'
	}
        else { local H `basecha' }

*3 - Process further options
        if `kercode' < 1 | `kercode' > 4 {
                di as err "kernel code should be between 1 and 4"
                exit 198 
        }
        if `level'<50 | `level'>99 {
		di in red "level() invalid"
		exit 198
	}

*4 - Put in local macros basic quantities
        local xvar _t   /* xvar = Analysis time */
        local d _d
        local intime _t0
        local kc `kercode'
        local hv `bwidth'
        local np `npoint'
        local by `strata'

*5 - Label for the plot. If e(offset) is defined stkerhaz guesses
*    Baseline SMR is plotted, but it cannot be always appropriate. 
        if `kc' == 1 {
                local kernel "Uniform"
        }
        else if `kc' == 2 {
                local kernel "Epanechnikov" /* It is different from Stata weigths */
        }
        else {
                local kernel "Biweight"
        }
        if "`e(offset)'" != "" { local lbly "Smoothed Baseline SMR" }
        else { local lbly "Smoothed Baseline Hazard" }

        preserve

/* 6 - Keep only records needed for the estimation.
       So records where Baseline Cumulative Hazard is missing will be dropped
       restricting the compute to e(sample), records where no failure occurs
       and records tied are dropped too. One record is added to preserve the lowest _t0.
*/
        marksample touse  
        qui replace `touse' = 0 if _st==0 | `H'==.   
        qui count if `touse'
        if r(N) == 0 { error 2000 }
        tempvar tmin yvar tie gridp dcum
        quietly {
                keep if `touse'
                egen `tmin' = min(`intime'), by(`by' `touse')
                if "`tmax'" == "" {
                        bysort `by' `d' (`xvar') : keep if _n==1 | `d'
                        bysort `by' `touse' :  drop if _N==1 & !`d'
                        replace `xvar' = `tmin' if `d'==0
                        replace `H' = 0 if `d'==0
                }
                else { keep if `d' }
                bysort `by' `xvar': gen long `tie' = (_n==1)
                egen `dcum' = sum(`d'), by(`by' `xvar')
                keep if `tie' /* keep one observation by time */
		if `np' >_N { set obs `np' }

*7 - Define the range of points where estimates will be done.
               	su `xvar', meanonly
               	local maxval = r(max)  
               	local minval = r(min) 
               	local range = `maxval' - `minval'

*8 - Define equally spaced points - gridpoint 
               	local inter = `range' / (`np' - 1)
               	gen double `gridp' = sum(`inter') - `inter' + `minval' if _n <= `np'
               	label var `gridp' "Gridpoint on the Analysis Time"

*9 Compute smoothed hazard if by   
		if "`by'" == "" {
                	foreach X of local hv {
                        	if `range'/ 2 < `X' {
                                	di as err "The time range must be at least " /*
                              		*/ "twice the bandwidth you specify."
                              		exit 121
                        	}
                	}

*10 - Compute increments between successive cumulative hazard - yvar
                	sort `xvar'
                	gen double `yvar' = cond(_n==1,`H',`H'-`H'[_n-1])

*11 - Do estimate when no strata option - More bandwidths can be specified
*   - Initialize variable for standard error(sterh) and baseline hazard(mhX)
                        tempvar sterh
                        gen double `sterh' = 0
                        foreach X of local hv {
                                local x = subinstr("`X'",".","_",.) /* to manage decimal bandwidth */ 
                                tempvar mh`x' hi lo
                                gen double `mh`x''=0
*12 - kerhaz is the subroutine doing the estimates
                               	kerhaz `yvar' `xvar' `gridp' `dcum' `mh`x'' , np(`np') /* 
                                       	*/ ic(`sterh') max(`maxval') hv(`X') kc(`kc') 

/*13 - Confidence bounds are allowed when just one bandwidth and no strata
       option is specified. They are correct if Baseline Cumulative Hazard
       derives from an unadjusted model.
       When baseline hazard estimates approximate 0 standard errors should
       be missing. Unfortunately graph connects points with a straight line,
       even if they are not consecutive in x axis. So missing values are not
       correctly displayed.
       At present when baseline hazard approximates 0 high confidence bound
       can be a trouble to the plot.
*/
                                if "`ci'"!="" {
                                 /* CI are better on log scale */
*                                        replace `sterh' = `sterh'/ `mh`x'' if _n <= `np'
					local level = invnorm((1-`level'/100)/2 + `level'/100)
					gen double `hi' = `per'* (`mh`x'' * exp( `level'*`sterh'/`mh`x'')) if _n <= `np' 
					gen double `lo' = `per'* (`mh`x'' * exp(-`level'*`sterh'/`mh`x'')) if _n <= `np'
				}       
                                replace `mh`x'' = `per'* `mh`x'' if _n <= `np'
                                local n_hv "`n_hv'`x' "
                                local lbl "bw=`X'"
                                label var `mh`x'' "`lbl'"
                                local mh "`mh' `mh`x''"
                                local tograph "`tograph' `mh`x''"
                        }
                }

*14 - Do estimate when strata option is used.
                else {
                        bysort `by' (`xvar') : gen double `yvar' = /*
                                */ cond(_n==1,`H',`H'-`H'[_n-1])
                        local i = 1
			levels7 `by', local(bylist)
                	foreach X of local bylist {
			*7BIS - Define the range for each by
               			su `xvar' if `by'==`X', meanonly
               			local maxval = r(max)  
               			local minval = r(min) 
               			local range = `maxval' - `minval'
                        	if `range'/ 2 < `hv' {
                                	di as err "The time range must be at least " /*
                              		*/ "twice the bandwidth you specify."
                              		exit 121
                        	}
                                tempvar mh`X'
                                gen double `mh`X''= 0 if `by'==float(`X') 
                                kerhaz `yvar' `xvar' `gridp' `dcum' `mh`X'' if !`mh`X'', /*
                                        */ np(`np') max(`maxval') hv(`hv') kc(`kc') 
                                replace `mh`X'' = `per'* `mh`X'' if _n <= `np'
                                local x = subinstr("`X'",".","_",.) /* to manage decimal bandwidth */ 
                                local n_hv "`n_hv'`x' "

 /* Actually in each case of bylist the number of points where the estimates are computed can
    be different from np, but this should not be a practical concern. */
				replace `mh`X'' = . if `gridp' < `minval' 
				replace `mh`X'' = . if `gridp' > `maxval' 
                                
                                count if `mh`X''!= .
                                if r(N) == 0 {
                                        drop `mh`X''
                                }
                                else {
                                        local lbl "`by'=`X'"
                                        label var `mh`X'' "`lbl'"
                                        local mh "`mh' `mh`X''"
                                        if `i' < 5 {
                                                local tograph "`tograph' `mh`X''"
                                        }
                                        local i = `i' + 1
                                 }
                	}
               }
        }

*15 - Do graph
        if "`b1title'" =="" {
               local b1title "Kernel function `kernel'"
        }
        if "`l1title'" =="" {
               local l1title "`lbly'"
        }

        if "`by'"!="" { local hv `bylist' }
                                             /* now hv contents is bandwith
                                              or values of stratavar */
        local bw bw
        if "`by'"!="" { local bw `by' }
                                             /* now bw contents is "bw"
                                              or name of stratavar */
        local i = 0
        local p = 2
        tokenize `mh'
        while "`1'" != "" {
                local i = `i' + 1
                if `i' < 5 {
                        if "`symbol'" =="" { local sym "`sym'." }
                        if "`connect'" == "" { local con "`con'l" }
                        local b: word `i' of `hv'
                        local k`i' key`i'(c(l) p(`p') "`bw'=`b'")
                        local p = `p' + 1
                        mac shift
                }
                else { mac shift }
        }
        if `i' > 4 {
                di as text "Warning: no more than 4 lines are plotted" _n /*
            */  "To plot more lines you must save smoothed estimates and then plot them."
        }
        if "`symbol'" =="" { local symbol "`sym'" }
        if "`connect'" == "" { local connect "`con'" }
        if "`ci'"!="" {
                   local pp "33"
                   if "`symbol'" =="." { local sym  "`sym'ii" }
                        else  { local sym  "`symbol'" }
                   if "`connect'"=="l" { local con "ll[.]l[.]" }
                        else  { local con "`connect'" }
                   if "`pen'"=="" {local pen "2`pp'" }
                   graph `mh' `hi' `lo' `gridp', `options' pen(`pen') /*
                        */ b1("`b1title'") l1("`l1title'") s(`sym') c(`con') 
        }
        else {
        	   graph `tograph' `gridp', `k1' `k2' `k3' `k4' s(`symbol') /* 
                      */ c(`connect') b1("`b1title'") l1("`l1title'") `options' 
        }

*16 - Save results
        if "`outfile'" ~= "" {
                if "`ci'"!="" {
                	keep `mh' `gridp' `sterh' `hi' `lo'
                        rename `sterh' KS_SE_bw_`n_hv'
                        label var KS_SE_bw_`n_hv' "Standard error"
                        qui replace `hi' = `hi' / `per'
                        qui replace `lo' = `lo' / `per'
                        rename `hi' KS_HI_`n_hv'
                        label var KS_HI_`n_hv' "High CI `bw' `n_hv'"
                        rename `lo' KS_LO_`n_hv'
                        label var KS_LO_`n_hv' "Low CI `bw' `n_hv'"
                }
                else { keep `mh' `gridp' }
		qui keep if `gridp' < .
                local i = 1
* thanks to Margaret May ->  foreach X of local mh{    must be substituted in  
                foreach X of varlist `mh'{
                        local l: word `i' of `n_hv'
                        local bw = substr("`bw'",1,6)
                        rename `X' KS_`bw'_`l'
                        qui replace KS_`bw'_`l' = KS_`bw'_`l'/ `per'
                        label var KS_`bw'_`l' "KSm Haz `bw' `l'"
                        local i = `i' + 1
                }
                rename `gridp' Gridpoint
		tokenize "`outfile'", parse(",")
		qui save "`1'" `2' `3'
        }
end


*17 - kerhaz do estimates
program define kerhaz
        version 7.0
*      	kerhaz `yvar' `xvar' `gridp' `dcum' `mh`x'' , np(`np') 
*	       	 ic(`sterh') max(`maxval') hv(`X') kc(`kc') 

        args yvar xvar gridp d mh
        syntax varlist [if] , np(numlist) max(numlist) hv(numlist) kc(numlist) [ ic(varname) ]
        if "`if'" != "" {
                local if "if !`mh'"
        }

*18 - Initialize var to compute estimates
        tempvar z kz kzy rh kse
        gen double `z' = 0
        gen double `kz' = 0
        gen double `kzy' = 0
        gen double `kse' = 0
        gen double `rh' = 0
	
*19 - Local function contains kernel function
        if `kc' == 1 {
                local function "0.5"
        }
        else if `kc' == 2 {
                local function `"0.75*(1-`z'^2)"' 
		
        }
        else {
                local function `".9375*(1-`z'^2)^2"'
        }

        forvalues i = 1(1)`np' {
                local xo = `gridp'[`i']
		local ql  = `xo' / `hv'
		local qr = (`max' - `xo') / `hv'
/*20 - z measures distance between target point (xo) and observed values
       in bandwidth units. kz define wheigths to assign to yvar values
       according to this distance.
*/
                replace `z' = (`xo' - `xvar') / `hv'
                if `ql'<1 {
                	if `kc'==1 { replace `kz' = 4*(1+`ql'^3)/(1+`ql')^4  /*
                		*/ + 6*(1-`ql')* `z' / (1+`ql')^3 if abs(`z')<1 
                	}
			else if `kc'==2 {
				local alpha = 64*(2-4*`ql'+6*`ql'^2-3*`ql'^3) / /*
					*/ ((1+`ql')^4*(19-18*`ql'+3*`ql'^2))
               			local beta = 240*(1-`ql')^2 / ((1+`ql')^4*(19-18*`ql'+3*`ql'^2))
               			replace `kz'= `function'*(`alpha' + `beta'*`z') if abs(`z')<1
               		}
			else {
				local alpha = 64*(8-24*`ql'+48*`ql'^2-45*`ql'^3+15*`ql'^4) / /*
					*/ ((1+`ql')^5*(81-168*`ql'+126*`ql'^2-40*`ql'^3+5*`ql'^4))
               			local beta = 1120*(1-`ql')^3 / ((1+`ql')^5 * /*
               				*/ (81-168*`ql'+126*`ql'^2-40*`ql'^3+5*`ql'^4))
               			replace `kz'= `function'*(`alpha' + `beta'*`z') if abs(`z')<1
               		}
               	}
                else if `qr'<1{
               		if `kc' == 1 { 
               			replace `kz' = 4*(1+`qr'^3) / /*
               			*/ (1+`qr')^4 + 6*(1-`qr')*(-`z')/(1+`qr')^3 if abs(`z')<1
               		}
			else if `kc'==2 {
				local alpha = 64*(2-4*`qr'+6*`qr'^2-3*`qr'^3) / /*
					*/ ((1+`qr')^4*(19-18*`qr'+3*`qr'^2))
               			local beta = 240*(1-`qr')^2 / ((1+`qr')^4*(19-18*`qr'+3*`qr'^2))
               			replace `kz'= `function'*(`alpha' + `beta'*(-`z')) if abs(`z')<1
               		}
               		else {
				local alpha = 64*(8-24*`qr'+48*`qr'^2-45*`qr'^3+15*`qr'^4) / /*
					*/ ((1+`qr')^5*(81-168*`qr'+126*`qr'^2-40*`qr'^3+5*`qr'^4))
               			local beta = 1120*(1-`qr')^3 / ((1+`qr')^5 * /*
               				*/ (81-168*`qr'+126*`qr'^2-40*`qr'^3+5*`qr'^4))
               			replace `kz'= `function'*(`alpha' + `beta'*(-`z')) if abs(`z')<1
               		}
               	}

		else { replace `kz' = `function' if abs(`z')<1 }
               	replace `kzy' = `kz' * `yvar' `if'
                su `kzy', meanonly
                replace `rh' = `r(sum)' in `i'

*21 - Standard error - not if strata option is specified
                replace `kse' = `kz'^2 * `yvar'^2 / `d'
                su `kse', meanonly
                if "`ic'"!= "" {
                        replace `ic' =sqrt(`r(sum)') / `hv' in `i'
                }
                replace `z' = 0
                replace `kz' = 0 
                replace `kzy' = 0 
                replace `kse' = 0 
                local i = `i' + 1
        }

*22 - wheigthed sum has to be divided by bandwidth
        replace `mh' = `rh' / `hv' if _n <= `np'
end
