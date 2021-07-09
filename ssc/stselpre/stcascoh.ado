*! version 1.2.2  --- 18nov2008
program define stcascoh
*! Case Cohort Sampling
*! Syntax: [varlist] (var to keep) [if ] [in],
*!         Alpha(numlist max=1 >=0 <100) (sampling fraction)
*!         [ GRoup(groupvarlist)(to preserve proportions by groupvarlist)
*!         GENerate(string)(to specify up to three var marking subcohort
*!             member, Barlow and Self-Prentice weights. Default
*!             names are _subco _wBarlow _wSelPre )
*!         EPs(real 0.001)(default click of time if fail happens)
*!         SEed(numlist integer max=1) ]
*  Enzo Coviello (enzo.coviello@tin.it)
        
        version 6.0
        st_is 2 analysis
        syntax [varlist(default=none)] [if] [in], Alpha(numlist max=1 >=0 <100) /*
                */ [ GRoup(varlist) GENerate(string) EPs(real 0.001) /*
                */ SEed(numlist integer max=1) noSHow ]
        tempvar touse
        st_smpl `touse' `"`if'"' `"`in'"' `"`group'"'  `""'
        st_show `show'
        local id : char _dta[st_id]
        if "`id'" == "" {
                di in re _n "stcascoh" /*
                */ " requires you have previously stset an id() variable"
		exit 198
	}
        local event _d
        local timeto _t
        local id : char _dta[st_id]
	local w  : char _dta[st_w]
	local wt : char _dta[st_wt]
        if "`w'" ~=  "" | "`wt'" ~= ""{
                di in re _n "st weights not allowed"
                exit 198
        }
        preserve

        /* warning for exclusions */

        quietly {
                count if _st==0
                if r(N) > 0 {
                        noi di _n in bl r(N) " records with _st==0 are dropped"
                        keep if _st==1
                }
                if `"`if'"' != "" | "`in'" != "" {
                        local n = _N
                        keep `if' `in'
                        if `n' > _N {
                                noi di _n in bl `n'-_N `" records dropped via if/in clauses"'
                        }
                }
                if `"`group'"' != "" {
                        count if `touse' == 0 
                        if r(N) > 0 {
                                noi di _n in bl r(N) " records dropped" /*
                                */ " with missings in variables (`group')"
			        keep if `touse'
                        }
                }
        }

        if "`generate'" == "" {
                cap confirm new var _subco _wBarlow _wSelPre
                if _rc {
                   di in re _n "Some of default new variables exists." /*
                    */ " gen() must be defined"
                   exit
                }
                local gen "_subco _wBarlow _wSelPre"
        }
           else {
                local i : word count `generate'
                if `i' > 3 {
                        di in re "more than 3 variables specified in generate()" _n /*
                        */ " only 3 variables are generated"
                        exit 198
                }
                if `i'==2 {
                        local gen `"`generate' _wSelPre"'
                }
                if `i'==1 {
                        local gen `"`generate' _wBarlow _wSelPre"'
                }
                else local gen `generate'
        }

        if `alpha' >= 1 {
                local alpha = `alpha' / 100
        }
        /* if alpha = 0 only failures are sampled */

        gettoken _subco gen : gen
        gen byte `_subco' = 0
        label var `_subco' "Subcohort member"
        gettoken wBarl gen : gen

        /* if no seed, time adds randomness to seed */

        if "`seed'" == "" {
                tempname in
                sca `in' = 1 + int(10^9 *uniform())
                local a = substr("$S_TIME",1,2)
                local b = substr("$S_TIME",4,2)
                local c = substr("$S_TIME",7,2)
                local seed = `in' + (`a' + 1) * (`b' + 1) * (`c' + 1)
        }
        set seed `seed'

        quietly {
                if "`group'" != "" {
                        tempvar grp subuse
                        egen `grp' = group(`group')
                        su `grp'
                        local n_gr = r(max)
                        local i = 1

                        /* sampling by groups */
                        while `i' <= `n_gr' {
                                gen byte `subuse' = `grp'==`i'
                                DoSam `id' `subuse' `_subco' `alpha' 
                                local i = `i' + 1
                                drop `subuse'
                        }
                }

                /* random sampling */
                else  DoSam `id' `touse' `_subco' `alpha'
        }

        /* Sample description */

        di in gr _n(2) "Sample composition" _n
        DiSam `_subco' `id' `event' `timeto' 

        /* Expand if event */
           
        quietly {
                expand 2 if `event'
                sort `id' `event'
                by `id': replace `timeto' = `timeto' - `eps' if `event' & _n == _N - 1
                by `id': replace _t0 = `timeto' - `eps' if `event' & _n == _N 

        /* adjust user variables - copied from stsplit */

                IsVar `_dta[st_bd]'
                if `s(exists)' {
                        local old_ev : char _dta[st_bd]
                        by `id': replace `old_ev' = . if /*
                                */ `event' & _n == _N-1
                        char _dta[Oldev] `old_ev'
                }
                IsVar `_dta[st_bt]'
                if `s(exists)' {
                        local old_ti : char _dta[st_bt]
                        by `id': replace `old_ti' = `_dta[st_bt]' - `eps' /*
                                */ if `event' & _n == _N - 1
                        char _dta[Oldti] `old_ti'
                }
                IsVar `_dta[st_bt0]'
                if `s(exists)' {
                        by `id': replace `_dta[st_bt0]' = `_dta[st_bt0]' - `eps' /*
                                */ if `event' & _n == _N
                }

        /* adjust event */

                by `id': replace `event' = 0 if `event' & _n==_N-1

        /* Now I can keep subcohort members and failures */

                keep  if `_subco' | `event'

        /* Barlow weights */
                gen `wBarl' = ln(1 / `alpha')
                replace `wBarl' = 0 if `event' 
                label var `wBarl' "Barlow weight"

        /* Self and Prentice weights */
                gen byte `gen' = 0
                replace `gen' = -100 if ~`_subco' & `event'
                label var `gen' "Self Prentice weight"

        /* recoding _subco */
                replace `_subco' = 2 if ~`_subco'
                by `id': replace `_subco' = 0 if `_subco'==1 & ~`event'[_N]
                label define sublbl 0 "sub-member with no failure" /*
                                 */ 1 "sub-member who failed" /*
                                 */ 2 "non subcohort cases", modify
        }
        /* saving if varlist */

        if `"`varlist'"' != "" {
                local need "_st _t _t0 _d `id' `_subco' `wBarl' `gen'"
                qui keep `varlist' `need'
        }

        restore,not

        nobreak {
                /* Displaying risk sets with few controls */

                DiFew `alpha'

       /*  Non sub-cohort cases can no more rely on previous stset.
           Entry time and exit time must correspond to the current _t0 and _t. */

                di in gr _n(3) "New stset definition" _n
                stset _t,f(_d) enter(_t0) time0(_t0) id(`id')
        }
        /* char for stselpre */
        char _dta[Alpha] `alpha'
        char _dta[wBarlow] `wBarl'
        char _dta[wSelPre] `gen'
        char _dta[Subco] `_subco'
end

program define DoSam
        args id subuse subco alfa 
        tempvar subj u subcu
        gsort `id' -`subuse'
        by `id': gen `subj' = (_n==1 & `subuse')
        gen `u' = uniform() if `subj'
	gen `subcu' = 1 - `subco' if `u'!=.
        sort `subcu' `u'
        count if `subj'
        local N_sam = round(r(N)*`alfa',1)
        if `N_sam' == 0 { exit }
        replace `subco' = 1 in 1/`N_sam'
        sort `id' `subco'
        by `id': replace `subco' = 1 if `subco'[_N] == 1
end

program define DiSam
	args _subco id event timeto
        tempvar ever_ev subj
        tempname evlbl 
        label define `evlbl' 0 "Censored" 1 "Failure"
        label values `event' `evlbl'
        label define sublbl 0 "No" 1 "Yes"
        label values `_subco' sublbl
        sort `id' `timeto'
        qui by `id': gen byte `ever_ev' = (`event'[_N] == 1)
        label var `ever_ev' " "
        label values `ever_ev' `evlbl'
        qui by `id' : gen byte `subj' = (_n==_N)
        tabulate `_subco' `ever_ev' if `subj'
        qui count if `ever_ev' & `subj'
        local N_ev = r(N)
        qui count if `_subco' & ~`ever_ev' & `subj'
        di _n(2) in gr "Total sample =  " in ye r(N) + `N_ev'
end

program define IsVar, sclass
	nobreak {
		capture confirm new var `1'
		if _rc {
			capture confirm var `1'
			if _rc==0 { 
				sret local exists 1
				exit 
			}
		}
	}
	sret local exists 0
end

program define DiFew
        preserve
        tempvar t pop die control order
        st_ct "" -> `t' `pop' `die'
        gen long `control' = `pop' - `die'
        label var `t' "failure time"
        label var `pop' "Total"
        label var `die' "failure"
        label var `control' "controls"
        qui keep if `die' > 0
        gen long `order' = _n
        label var `order' "risk set"
        qui count if `control' < 4
        if r(N) >0 {
                if `1'>0 {   /* if the file consists of only non-subcohort cases this check is meaningless */
			di _n(2) in gr "Risk set with less than 4 controls" _n
				tabdisp `t' if `control' < 4, c(`order' `die' `control' `pop') /*
					*/ center cellw(9)
		}
	}
        else di in bl _n(2) "No risk set with less than 4 controls"
end
exit


. stcascoh, alpha(20) group(race)

         failure _d:  tumnas
   analysis time _t:  (dataout-origin)
             origin:  time dataass
  enter on or after:  time datain
                 id:  id


Sample composition


 Subcohort |           
    member |  Censored    Failure |     Total
-----------+----------------------+----------
        No |        51          5 |        56 
       Yes |        13          1 |        14 
-----------+----------------------+----------
     Total |        64          6 |        70 



Total sample =  19


Risk set with less than 4 controls


----------+---------------------------------------
failure   |
time      | risk set   failure  controls    Total 
----------+---------------------------------------
  15.2245 |    1         1         3         4    
----------+---------------------------------------



New stset definition


                id:  id
     failure event:  _d ~= 0 & _d ~= .
obs. time interval:  (_t0, _t]
 enter on or after:  time _t0
 exit on or before:  failure

------------------------------------------------------------------------------
       20  total obs.
        0  exclusions
------------------------------------------------------------------------------
       20  obs. remaining, representing
       19  subjects
        6  failures in single failure-per-subject data
 337.8655  total analysis time at risk, at risk from t =         0
                             earliest observed entry t =  9.849487
                                  last observed exit t =  75.50708
