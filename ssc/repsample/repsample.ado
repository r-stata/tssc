/*  Representative sample greedy algorithm module by Evangelos Kontopantelis
    created in STATA v12.1
    v1.0, 12 June 2012
    ***
    v1.1, 03 May 2013
    - Added early stopping rule option based on overall chi-square test p-value
    - Added weight option
    v1.2, 15 Aug 2014
    - Added second stopping rule option based on random sampling from pool rather than going through all cases
    - Corrected seednum to work across all scenarios (same seed # returned different samples if repsample called sequentially since the dataset order was changed between calls)
*/

/*Provides a sample that is as representative as possible, on selected key variables*/
program define repsample, rclass
    /*stata version define*/
    version 12.1
    /*command syntax*/
    syntax anything(name=samplesize id="Sample size") [if] [in], [cont(varlist min=1 numeric) bincat(varlist min=1 numeric) /*
    */ mean(numlist) sd(numlist) perc(numlist) seednum(real 7) randomperc(real 10) srule(real -127.5) rrule(real -127.5) wght(numlist) /*
    */ retain(varlist min=1 max=1 numeric) exact force]
    /*temp variables used in all methods*/
    tempvar selvar id sample tvar1 tvar2 tvar3 oldsample tempv1
    tempfile temporig temp
    preserve
    //set seed number
    set seed `seednum'
    set sortseed `seednum'

    /*INITIAL STUFF*/
    /*make sure 'anything' is a single integer*/
    if `=wordcount("`samplesize'")'>1 {
        di in red "A single integer is required as the desired sample size"
        error 197
    }
    local ssize = word("`samplesize'",1)
    confirm integer number `ssize'

    /*continuous variables*/
    scalar ccnt = 0
    local allcvar=""
    local allvar=""
    forvalues i=1(1)`=wordcount("`cont'")' {
        scalar ccnt = ccnt + 1
        local cvar`=ccnt' = word("`cont'",`i')
        local allcvar = "`allcvar' `cvar`=ccnt''"
        local allvar = "`allvar' `cvar`=ccnt''"
        /*orginal weights*/
        scalar wc_`i'=1
    }
    /*binary and categorical variables*/
    scalar bcnt = 0
    local allbcvar=""
    forvalues i=1(1)`=wordcount("`bincat'")' {
        scalar bcnt = bcnt + 1
        local bvar`=bcnt' = word("`bincat'",`i')
        local allbvar = "`allbvar' `bvar`=bcnt''"
        local allvar = "`allvar' `bvar`=bcnt''"
        /*orginal weights*/
        scalar wb_`i'=1
    }
    /*theoretical means*/
    scalar mcnt = 0
    forvalues i=1(1)`=wordcount("`mean'")' {
        scalar mcnt = mcnt + 1
        scalar mean`=mcnt' = real(word("`mean'",`i'))
    }
    /*theoretical sds*/
    scalar sdcnt = 0
    forvalues i=1(1)`=wordcount("`sd'")' {
        scalar sdcnt = sdcnt + 1
        scalar sd`=sdcnt' = real(word("`sd'",`i'))
    }
    /*theoretical percentages*/
    scalar pcnt = 0
    forvalues i=1(1)`=wordcount("`perc'")' {
        scalar pcnt = pcnt + 1
        scalar p`=pcnt' = real(word("`perc'",`i'))
        /*easier to issue an error here if outside the (0,100) range*/
        if p`=pcnt'<=0 | p`=pcnt'>=100 {
            di in red "Percentages must be in the (0,100) range!"
            error 110
        }
    }
    /*weights*/
    scalar wcnt=0
    scalar wsum=0
    forvalues i=1(1)`=wordcount("`wght'")' {
        scalar wcnt = wcnt + 1
        scalar wght`=wcnt' = real(word("`wght'",`i'))
        scalar wsum = wsum + wght`=wcnt'
    }
    /*if weights do not much with the number of variables or do not add up to 100, issue error*/
    if wcnt>0 {
        if wcnt!=ccnt+bcnt {
            di in red "Number of weights provided must match number of variables!"
        }
        if wsum!=100 {
            di in red "Weight scores must add up to 100!"
        }
        if wcnt!=ccnt+bcnt | wsum!=100 {
            di in red "Note that continuous variables always precede binary/categorical in weighting"
            di in red "e.g. for 50% c1, 30% c2 and 20% b1: cont(c1 c2) bincat(b1) wght(50 30 20)"
            error 110
        }
        /*assign to continuous and binary variables*/
        local i=1
        /*continuous*/
        if ccnt>0 {
            forvalues j=1(1)`=ccnt' {
                scalar wc_`j'=wght`i'/100
                local i=`i'+1
            }
        }
        /*binary*/
        if bcnt>0 {
            forvalues j=1(1)`=bcnt' {
                scalar wb_`j'=wght`i'/100
                local i=`i'+1
            }
        }
    }

    /*see if sampling against theoretical distributions or using a population*/
    if mcnt>0 | sdcnt>0 | pcnt>0 {
        scalar mtype=0
        local strtype = "sampling using theoretical distributions"
    }
    else {
        scalar mtype=1
        local strtype = "sampling using a population"
    }

    /*if no variables provided issue error*/
    if ccnt==0 & bcnt==0 {
        di in red "No variables provided on which the sample will be drawn"
        di in red "Use the cont and bincat options for continuous and binary/categorical vars respectively"
        error 197
    }
    /*if the theoretical dist info does not match the given variables issue error*/
    if mtype==0 & (ccnt!=mcnt | ccnt!=sdcnt | bcnt!=pcnt) {
        di in red "Details for theoretical distributions do not agree with the variables provided"
        di in red "For continuous vars, mean and sd are required; for binary a percentage"
        error 197
    }
    /*double-check the types of the given variables and issue errors*/
    /*warnings for continuous vars*/
    forvalues i=1(1)`=ccnt'{
        capture tab `cvar`i''
        if _rc==0 {
            if r(r)<7 {
                di in red "Warning:" _col(12) in yellow "Only `=r(r)' distinct values observed for 'continuous' variable `cvar`i''"
            }
        }
    }
    /*warnings and errors for binary/categorical vars*/
    forvalues i=1(1)`=bcnt'{
        capture tab `bvar`i''
        if _rc==0 {
            /*can't have categorical with theoretical sampling*/
            if r(r)>2 & mtype==0 {
                di in red "Theoretical sampling cannot work with categorical variable `bvar`i''"
                di in red "Convert into one (or more?) binary variables and provide theoretical percentages"
                error 197
            }
            if r(r)>7 {
                di in red "Warning:" _col(12) in yellow "`=r(r)' distinct values observed for 'categorical' variable `cvar`i''"
                di in yellow "Consider reducing the number of categories for better results"
            }
        }
        else {
            di in red "Too many categories for categorical variable `bvar`i'' - probably continuous?"
            error 197
        }
    }
    /*make sure a user doesn't give the same variable names*/
    forvalues i=1(1)`=wordcount("`allvar'")-1' {
        forvalues j=`=`i'+1'(1)`=wordcount("`allvar'")' {
            if "`=word("`allvar'",`i')'"=="`=word("`allvar'",`j')'" {
                di in red "Variables provided need to be unique!"
                error 197
            }
        }
    }
    /*retain issues*/
    if "`retain'"!="" {
        /*must be a binary variable*/
        qui tab `retain'
        scalar t1 = r(r)
        qui sum `retain'
        if t1>2 | r(min)<0 | r(max)>1 {
            di in red "Variable used to continue sampling must be a 0-1 binary, with cases assigned to the sample (=1)"
            error 197
        }
        /*can't have both force and retain options since it becomes confusing*/
        if "`retain'"=="repsample" & "`force'"!="" {
            di in red "You cannot force drop variable repsample and update it through retain simultaneously"
            error 197
        }
        scalar sreplace=1
    }
    else {
        scalar sreplace=0
    }
    /*random percentage*/
    if "`randomperc'"!="10" {
        if `randomperc'<0 | `randomperc'>100 {
            di as error "Random percentage parameter must be in the [0,100] range"
            error 110
        }
    }
    /*early stopping rule - based on p-value*/
    if `srule'==-127.5 {
        scalar prlbool=0
        local srule=0
    }
    else {
        if `srule'<0.5 | `srule'>=1 {
            di as error "Early stop matching rule must be in the [0.5,1) range"
            error 110
        }
        scalar prlbool=1
    }
    /*early stopping rule - based on random sample*/
    if `rrule'==-127.5 {
        scalar rrlbool=0
        local rrule=0
    }
    else {
        if `rrule'<10 {
            di as error "Random sampling early stopping rule must sample at least 10 cases"
            error 110
        }
        scalar rrlbool=1
    }
    /*exact test requested*/
    if "`exact'"!="" {
        local strks = "exact"
        local strksp = "p_exact"
        local strtab = "exact"
        local strtabp = "p_exact"
        local strinfo = "Exact tests selected"
    }
    else {
        local strks = ""
        local strksp = "p_cor"
        local strtab = "chi2"
        local strtabp = "p"
        local strinfo = "Asymptotic approximations selected."
    }
    /*force option*/
    if "`force'"!="" {
        capture drop repsample
    }
    /*error if there's already a repsample variable in the dataset - ask to rename or drop*/
    capture confirm variable repsample
    if _rc==0 & "`retain'"!="repsample" {
        di in red "Variable repsample already exists. Use option force to drop and replace or retain to update"
        error 197
    }

    /*save file before cases are potentially dropped*/
    /*if repsample has been kept it will be updated at the last merge*/
    qui egen `id' = seq()
    qui save `temporig', replace
    /*use if and in*/
    qui gen `selvar' = 0
    qui replace `selvar' = 1 `if' `in'
    qui keep if `selvar'==1
    qui drop `selvar'
    /*drop cases with missing values in any of the used variables*/
    forvalues i=1(1)`=wordcount("`allvar'")' {
        qui drop if `=word("`allvar'",`i')'==.
    }

    /*make sure the number requested is not smaller than what is carried forward though 'retain'*/
    scalar prevsel=0
    qui gen `oldsample'=0
    if "`retain'"!="" {
        qui replace `oldsample' = `retain'
        qui count if `oldsample'==1
        scalar prevsel = r(N)
        if prevsel>`ssize' {
            di in red "Continuation variable `retain' holds more cases than the requested sample size"
            error 197
        }
        else if prevsel==`ssize' {
            di in red "Continuation variable `retain' holds as many cases as in the requested sample size"
            error 197
        }
    }
    /*make sure that the sample size is adequate*/
    qui count if `oldsample'==0
    if r(N)<`ssize'-prevsel {
        di in red "Not enough cases to provide the requested sample"
        error 197
    }
    else if r(N)==`ssize'-prevsel {
        di in red "Requested sample matches the available number of cases"
        error 197
    }

    /*command display*/
    di _newline _continue in green "Representative sample of `ssize' cases requested, `strtype'.
    if prevsel!=0 {
        di _continue in green " `=prevsel' cases carried forward."
    }
    di _newline _continue in green "`strinfo'"
    /*exact tests only affect binary vars in the theoretical dist sampling*/
    if mtype==0 & "`exact'"!="" & "`allbvar'"=="" {
        di _continue in green "; no effect since only relevant to binary vars in theoretical sampling."
    }
    else if mtype==0 & "`exact'"!="" & "`allbvar'"!="" {
        di _continue in green "; only binary variables affected in theoretical sampling."
    }
    di _newline _continue

    /*start of process*/
    /*number of cases to be selected*/
    scalar samplenum = `ssize'-prevsel
    /*how many random practices at first*/
    scalar randsel = round(samplenum*`randomperc'/100)
    /*need to save the sample and append - for population sampling but using in both types for convenience*/
    qui save `temp', replace
    /*generate the temp sample variable*/
    qui gen `sample'=0
    if sreplace==1 {
        qui replace `sample'=1 if `oldsample'==1
    }
    qui append using `temp'
    /*we want the 'id' var to be missing in the 'comparison' sample*/
    qui replace `id'=. if `sample'==.
    /*now we need the eligibles not selected to be missing, 1=already selected, 0=the comparison sample (the whole population)*/
    qui replace `sample'=0 if `sample'==. & `id'==.
    qui replace `sample'=. if `sample'==0 & `id'!=.
    sort `sample' `id'
    qui save `temp', replace
    /*randomly select the first X*/
    if sreplace==1 {
        qui keep if `sample'==. & `oldsample'!=.
    }
    else {
        qui keep if `sample'==.
    }
    qui count
    scalar tnum = r(N)
    forvalues i=1(1)`=randsel' {
        scalar posx = floor(runiform()*tnum)+1
        while `sample'[posx]!=. {
            scalar posx = floor(runiform()*tnum)+1
        }
        qui replace `sample' = 1 in `=posx'
		di in yellow "." _continue
    }
    qui keep `id' `sample'
    qui merge 1:m `id' using `temp', nogenerate
    /*if it is a theoretical sample generation, drop the comparison sample*/
    if mtype==0 {
        qui drop if `sample'==0
    }

    /*now go through a loop and add practices based on test results (summed)*/
    scalar scount = randsel
    while scount < samplenum {
        /*try to speed up code by only going through the eligible practices*/
        //if no early stopping rule based on random sample
        if rrlbool==0 {
            if sreplace==1 {
                qui egen `tvar1' = seq() if `sample'==. & `oldsample'!=.
            }
            else {
                qui egen `tvar1' = seq() if `sample'==.
            }
        }
        //if early stopping rule based on random sample
        else {
            if sreplace==1 {
                qui gen `tempv1'=runiform() if `sample'==. & `oldsample'!=.
            }
            else {
                qui gen `tempv1'=runiform() if `sample'==.
            }
            qui count if `tempv1'!=.
            //ensure not observations out of range
            if `rrule'<r(N) {
                qui sort `tempv1'
                qui egen `tvar1' = seq() in 1/`rrule'
            }
            else {
                qui egen `tvar1' = seq() if `tempv1'!=.
            }
            qui drop `tempv1'
        }
        /*count how many are the eligible cases in this loop*/
        qui count if `tvar1'!=.
        scalar elpnum = r(N)
        /*calculate the test scores if each of the practices is included*/
        qui gen `tvar2'=.
        local i=0
        scalar stoprule=0
        while `i'<`=elpnum' & stoprule==0 {
            local i=`i'+1
            qui replace `sample' = 1 if `tvar1'==`i'
            /*combine tests using Fisher's method -  http://en.wikipedia.org/wiki/Fisher's_method*/
            /*we are assuming that the p-values are independent*/
            /*continuous variables - KS test*/
            //scalar tsum=0
            scalar tsumw=0
            if ccnt>0 {
                local vcnt = 0
                foreach x of varlist `allcvar' {
                    local vcnt = `vcnt'+1
                    /*sampling against population*/
                    if mtype==1 {
                        qui ksmirnov `x', by(`sample') `strks'
                        //scalar tsum=tsum-2*ln(r(`strksp'))
                        scalar tsumw=tsumw-wc_`vcnt'*2*ln(r(`strksp'))
                        scalar KSp`vcnt'_`i' = r(`strksp')
                    }
                    /*sampling against theoretical distribution*/
                    else {
                        qui ksmirnov `x' = normal((`x'-mean`vcnt')/sd`vcnt') if `sample'==1
                        //scalar tsum=tsum-2*ln(r(p_cor))
                        scalar tsumw=tsumw-wc_`vcnt'*2*ln(r(p_cor))
                        scalar KSp`vcnt'_`i' = r(p_cor)
                    }
                    scalar KSD`vcnt'_`i' = r(D)
                }
            }
            /*binary and categorical - chi2 or Fisher's exact test for */
            if bcnt>0 {
                local vcnt = 0
                foreach x of varlist `allbvar' {
                    local vcnt = `vcnt'+1
                    /*sampling against population*/
                    if mtype==1 {
                        qui tab `x' `sample', `strtab'
                        //scalar tsum=tsum-2*ln(r(`strtabp'))
                        scalar tsumw=tsumw-wb_`vcnt'*2*ln(r(`strtabp'))
                        scalar tabp`vcnt'_`i'=r(`strtabp')
                        scalar tabX2`vcnt'_`i'=r(chi2)
                    }
                    /*sampling against theoretical distribution*/
                    else {
                        if "`exact'"!="" {
                            qui bitest `bvar`vcnt''==`=p`vcnt'/100' if `sample'==1
                            //scalar tsum=tsum-2*ln(r(p))
                            scalar tsumw=tsumw-wb_`vcnt'*2*ln(r(p))
                            scalar prtestp`vcnt'_`i' = r(p)
                            scalar prtestZ`vcnt'_`i' = .
                        }
                        else {
                            qui prtest `bvar`vcnt''==`=p`vcnt'/100' if `sample'==1
                            scalar prtestp`vcnt'_`i' = 2*(1-normal(abs(r(z))))
                            //scalar tsum=tsum-2*ln(prtestp`vcnt'_`i')
                            scalar tsumw=tsumw-wb_`vcnt'*2*ln(prtestp`vcnt'_`i')
                            scalar prtestZ`vcnt'_`i' = r(z)
                        }
                    }
                }
            }
            /*rescale the weighted score*/
            if wcnt>0 {
                scalar tsumw=tsumw*wcnt
            }
            /*save the overall score for each of the cases - i.e. % difference from the 'ideal' if this case was added*/
            qui replace `tvar2' = tsumw if `tvar1'==`i'
            /*calculate p-value for early stopping rule*/
            if prlbool==1 {
                qui sum `tvar2' if `sample'==1
                scalar x2val = r(mean)
                scalar ndf = 2*(bcnt+ccnt)
                scalar pval = chi2tail(ndf,x2val)
                if pval>=`srule' {
                    scalar stoprule=1
                }
            }
            if stoprule==0 {
                /*if no stopping rule, reset and keep going*/
                qui replace `sample'=. if `tvar1'==`i'
            }
        }
        /*rank the scores and try to get the one with lowest*/
        qui egen `tvar3' = rank(`tvar2')
        sort `tvar3'
        scalar tietmp=`tvar3' in 1
        /*if there is no "tie" in rank 1, assign the practice to the sample and we are done*/
        if tietmp==1 {
            qui replace `sample' = 1 if `tvar3'==1
        }
        /*if there is a "tie" gets more complicated...*/
        else if tietmp>1 {
            /*add a very small random number in each case*/
            qui replace `tvar3' = `tvar3' + runiform()/10
            sort `tvar3'
            qui replace `sample' = 1 in 1
        }
        else {
            di in red "Something gone wrong - no case has been selected"
            error 101
        }
        /*get the test data for returning*/
        qui sum `tvar2' if `sample'==1
        scalar x2val = r(mean)
        scalar ndf = 2*(bcnt+ccnt)
        scalar pval = chi2tail(ndf,x2val)
        /*note the scalars for the individual tests - we want to get the seq num for the returned case to pick the relevant scalars later*/
        scalar tmp = `tvar1' in 1
        qui drop `tvar1' `tvar2' `tvar3'
        scalar scount = scount + 1
		di in yellow "." _continue
    }
    /*generate final var and merge with the original dataset*/
    qui keep if `sample'==1
    capture drop repsample
    qui gen repsample=1
    qui keep `id' repsample
    qui merge 1:1 `id' using `temporig', nogenerate
    sort `id'
    qui drop `id'
    qui replace repsample=0 if repsample==.
    label var repsample "Representative sample (repsample command)"
    order repsample, last

    /*return list - only if at least one case is deterministically samples (i.e. not all random)*/
    if randsel<samplenum {
        return scalar p = pval
        return scalar chi2 = x2val
        return scalar df = ndf
        /*continuous variables*/
        forvalues i=`=ccnt'(-1)1 {
            return scalar `cvar`i''_D = KSD`i'_`=tmp'
            return scalar `cvar`i''_p = KSp`i'_`=tmp'
        }
        /*binary/categorical variables*/
        forvalues i=`=bcnt'(-1)1 {
            if mtype==1 {
                if "`exact'"=="" {
                    return scalar `bvar`i''_chi2 = tabX2`i'_`=tmp'
                }
                return scalar `bvar`i''_p = tabp`i'_`=tmp'
            }
            else {
                if "`exact'"=="" {
                    return scalar `bvar`i''_z = prtestZ`i'_`=tmp'
                }
                return scalar `bvar`i''_p = prtestp`i'_`=tmp'
            }
        }
    }
    /*after this point we are in the clear so cancelling preserve-restore command*/
    restore, not
end







