*! version 1, 4/27/01
*! version 1.1, 4/28/01
*! version 2, 9/19/01

program define idonepsu

/* Written by:                                                                                     
   Joshua H. Sarver                                                                                
   sarver@po.cwru.edu                                                                              
   Program code enhancements and suggestions are welcome at the above address.   
   This program calls ado files:                                                                    
        None                                                                                               
   STATA version: 7.0   */

version 7

syntax [varlist(default=none)] [if] [in] [, Strata(varname) Psu(varname) Generate(string) SWitch]

/* Make sure that generate is selected if switch is selected */
if "`switch'"~="" & "`generate'"=="" {
        di as result "You cannot select {it:switch} without having {bf:idonepsu} generate new variables"
        di as result "to switch to. You must select {it:generate} as well if you want {it:switch}."
        exit
        }
/* Get strata and psu. */

if "`psu'"=="" {
        local psu : char _dta[psu]
        }	
if "`strata'"=="" {
        local strata : char _dta[strata]
        }	

/* Mark/markout. */

        tempvar _doit
        mark `_doit' `if' `in'
        if "`varlist'"~="" {
                markout `_doit' `varlist' `strata' `psu', strok
                }	
        if "`varlist'"=="" {
                markout `_doit' `strata' `psu', strok
                }

di as text "Examining the strata `strata'" 
di as text "with the PSU `psu'."

/* Identify strata with singleton PSUs. */

        sort `_doit' `strata' `psu'
        quietly {
                tempvar _one
                gen `_one'=.
                by `_doit' `strata' `psu': replace `_one' = (_n==1) if `_doit'==1
                by `_doit' `strata': replace `_one' = cond(_n==_N,sum(`_one'),.) /*
                */ if `_doit'==1
                tempvar _tag
                gen `_tag'=`_one'
                gsort `strata' -`_one'
                by `strata': replace `_one'=`_one'[1] if `_doit'==1 
        }

di as result %~59s "These are the strata that have only 1 PSU"
di as result %~59s "and the number of observations in those strata"
tab `strata' if `_one'==1, nolab

if "`generate'"~=""{
        /*identify the strata with the most PSUs   */
        sort `strata' `psu'
        quietly{
                tempvar _size
                gen `_size'=.
                by `strata' `psu': replace `_size' = _N if `_doit'==1
        }
        gsort -`_size'
        tempvar _bigstrata
        gen `_bigstrata'=`strata'[1]
        local bigstrata=`_bigstrata'

        /*merge the strata with singleton PSUs into the largest strata  */

        quietly {
        gen `generate'str=`strata'
        gen `generate'psu=`psu'
        tempvar _psuhi
        gen `_psuhi'=.
        label variable `generate'str "strata based on `strata': strata with singleton PSUs merged into `bigstrata', see notes"
        label variable `generate'psu "PSU based on `psu': strata with singleton PSUs merged into `bigstrata' have reassigned PSUs, see notes"
        sort `_tag'
        tempvar _index
        gen `_index'=.
        by `_tag': replace `_index'=_n if `_tag'==1
        gsort -`_index'
        tempvar _indexhi
        gen `_indexhi'=`_index'[1]
        local indexhi=`_indexhi'
        gsort `strata' -`psu'
        by `strata': replace `_psuhi'=`psu'[1] if `strata'==`bigstrata'
        sort `_psuhi'
        local psuhi=`_psuhi'[1]
	
        foreach x of numlist 1/`indexhi' {
                tempvar _stratnum
                gen `_stratnum'=`strata' if `_index'==`x'
                sort `_stratnum'
                local stratnum=`_stratnum'[1]
                drop `_stratnum'
                replace `generate'str=`bigstrata' if `strata'==`stratnum'
                replace `generate'psu=`psuhi'+`x' if `strata'==`stratnum'
                notes `generate'str: old strata `strata' `stratnum' merged into `generate'str `bigstrata'
                local psunew=`psuhi'+`x'
                tempvar _oldpsu
                gen `_oldpsu'=`psu' if `strata'==`stratnum'
                sort `_oldpsu'
                local oldpsu=`_oldpsu'[1]
                drop `_oldpsu'
                notes `generate'psu: old PSU `psu' `oldpsu' of strata `strata' `stratnum',/*
                        */ now `generate'psu `psunew' in `generate'str `bigstrata'
                }
        }
        di in green ""
        di "The new strata variable `generate'str was created that contains the strata with "
        di "singleton PSUs merged into the largest strata, strata number `bigstrata'."
        di "These changes were documented in the notes for the new strata variable,"
        di "`generate'str, as shown here:"
        notes `generate'str
        di ""
        di as result %~59s "To view these notes again now or at a later time,"
        di as result %~59s "simply type -notes `generate'str-"
        di in green ""
        di "The new PSU variable `generate'psu was created that contains the PSU with "
        di "the PSU's renamed when they were merged into the strata.  These changes "
        di "were documented in the notes for the new psu variable,"
        di "`generate'psu, as shown here:"
        notes `generate'psu
        di ""
        di as result %~59s "To view these notes again now or at a later time,"
        di as result %~59s "simply type -notes `generate'psu-"
        di in green ""

/* Switch the settings of the strata and psu automatically if selected */
        if "`switch'"~="" {
                qui {
                        svyset strata `generate'str
                        svyset psu `generate'psu
                        }
                di ""
                di "{hline}"
                di "{txt}{res: strata} is now set to {res:`generate'str} and {res:psu} is now set to {res:`generate'psu}"
                }
	
        }

end
