*! rwolf: Romano Wolf stepdown hypothesis testing algorithm
*! Version 3.0.1 february 1, 2020 @ 22:58:19
*! Author: Damian Clarke
*! Department of Economics
*! Universidad de Santiago de Chile
*! damian.clarke@usach.cl

/*
version highlights:
1.0.0 [01/12/2016]: Romano Wolf Procedure exporting p-values
1.1.0:[23/07/2017]: Experimental weighting procedure within bootstrap to allow weights
2.0.0:[16/10/2017]: bsample exclusively.  Add cluster and strata for bsample
2.1.0:[15/12/2017]: Adding ivregress as permitted method.
2.2.0:[29/05/2018]: Correcting estimate of standard error in studentized t-value
3.0.0:[18/12/2019]: All additional options indicated in Clarke, Romano & Wolf paper
3.0.1:[18/12/2019]: Bug fix for variable names containing upper case letters
*/

cap program drop rwolf
program rwolf, eclass
vers 11.0
#delimit ;
syntax varlist(min=1 fv ts numeric) [if] [in] [pweight fweight aweight iweight],
[
 indepvar(varlist min=1)
 method(name)
 NOBOOTstraps           
 pointestimates(numlist)
 stderrs(numlist)
 stdests(varlist min=1)
 controls(varlist fv ts)
 seed(numlist integer >0 max=1)
 reps(integer 100)
 Verbose
 strata(varlist)
 otherendog(varlist)
 cluster(varlist)
 iv(varlist fv ts) 
 indepexog
 bl(name)
 onesided(name)
 noplusone
 graph
 nullimposed
 varlabels
 nodots
 holm
 nulls(numlist)
 *
 ]
;

#delimit cr
cap set seed `seed'
if `"`method'"'=="" local method regress
if `"`method'"'=="ivreg2"|`"`method'"'=="ivreg" {
    dis as error "To estimate IV regression models, specify method(ivregress)"
    exit 200
}
if `"`method'"'!="ivregress"&length(`"`indepexog'"')>0 {
    dis as error "indepexog argument can only be specified with method(ivregress)"
    exit 200
}
if `"`method'"'=="ivregress" {
    local ivr1 "("
    local ivr2 "=`iv')"
    local method ivregress 2sls
    if length(`"`iv'"')==0 {
        dis as error "Instrumental variable(s) must be included when specifying ivregress"
        dis as error "Specify the IVs using iv(varlist)"
        exit 200
    }    
}
else {
    local ivr1
    local ivr2
    local otherendog
}
if length(`"`onesided'"')!=0 {
    if `"`onesided'"'!="positive"&`"`onesided'"'!="negative" {
        local W1 "When specifying onesided(), only onesided(positive)"
        dis as error "`W1' or onesided(negative) are permissible"
        exit 200
    }
}

local nivars : word count `indepvar'
local nivarsc = `nivars'
if length(`"`nobootstraps'"')!=0 local nivarsc = 1

if length(`"`nulls'"')!=0 {
    local nnull : word count `nulls'
    local nvars : word count `varlist'
    if `nnull'!=(`nvars'*`nivarsc') {
        local e1 "The number of values in the nulls() option is different"
        local e2 "When using the nulls() option,"
        dis as error "`e1' to the number of dependent variables indicated."
        dis as error "`e2' ensure that one null value is given for each hypothesis."
        exit 200
    }

    tokenize `nulls'
    foreach ivar of varlist `indepvar' {
        local j=1
        foreach dvar of varlist `varlist' { 
            local beta0`j'_`ivar'=`1'
            local ++j
            macro shift
        }
    }
}

local bopts
if length(`"`strata'"')!=0  local bopts `bopts' strata(`strata')
if length(`"`cluster'"')!=0 local bopts `bopts' cluster(`cluster')
if length(`"`verbose'"')==0 local q qui


*-------------------------------------------------------------------------------
*--- Run bootstrap reps to create null Studentized distribution
*-------------------------------------------------------------------------------
local inft = 0
if length(`"`nobootstraps'"')==0 {
    local j=0
    local wt [`weight' `exp']
    foreach ivar of varlist `indepvar' {
        local cand_`ivar'
    }
    
    tempname nullvals
    tempfile nullfile
    file open `nullvals' using "`nullfile'", write all
    
    `q' dis "Displaying original (uncorrected) models:"
    foreach var of varlist `varlist' {
        local ++j
        local Xv `controls'
        if length(`"`bl'"')!=0 local Xv `controls' `var'`bl' 
        if length(`"`indepexog'"')==0 {
            #delimit ;
            `q' `method' `var' `ivr1'`indepvar' `otherendog'`ivr2' `Xv'
                         `if' `in' `wt', `options';
            #delimit cr
        }
        else {
            #delimit ;
            `q' `method' `var' `ivr1'`otherendog'`ivr2' `indepvar' `Xv'
                         `if' `in' `wt', `options';
            #delimit cr
        }
        if _rc!=0 {
            dis as error "Your original `method' does not work."
            dis as error "Please test the `method' and try again."
            exit _rc
        }
        local label`j' `: var label `var' '

        foreach ivar of varlist `indepvar' {
            if length(`"`nulls'"')==0    local beta0`j'_`ivar'=0 
            if length(`"`onesided'"')==0 {
                local t`j'_`ivar' = abs((_b[`ivar']-`beta0`j'_`ivar'')/_se[`ivar'])
            }
            else {
                local t`j'_`ivar' =     (_b[`ivar']-`beta0`j'_`ivar'')/_se[`ivar']
                local inft = min(`inft',`t`j'_`ivar'')
            }
            local beta`j'_`ivar' = _b[`ivar']

            qui test _b[`ivar'] = `beta0`j'_`ivar''
            local pv`var'_`ivar' = string(r(p), "%6.4f")
            local pv`var's_`ivar'= r(p)
        
            if `"`onesided'"'=="positive" {
                qui test `ivar'=0
                local sgn = sign(_b[`ivar'])
                if length(`"`r(F)'"')!=0 {
                    local pv`var'_`ivar' = string(1-ttail(r(df_r),`sgn'*sqrt(r(F))), "%6.4f")
                    local pv`var's_`ivar'=(1-ttail(r(df_r),`sgn'*sqrt(r(F))))
                }
                else {
                    local pv`var's_`ivar'=normal(`sgn'*sqrt(r(chi2)))
                }
            }
            if `"`onesided'"'=="negative" {
                qui test `ivar'=0
                local sgn = sign(_b[`ivar'])
                if length(`"`r(F)'"')!=0 {
                    local pv`var'_`ivar' = string(ttail(r(df_r),`sgn'*sqrt(r(F))), "%6.4f")
                    local pv`var's_`ivar'= (ttail(r(df_r),`sgn'*sqrt(r(F))))
                }
                else {
                    local pv`var's_`ivar'= 1-normal(`sgn'*sqrt(r(chi2)))
                }
            }
            local cand_`ivar' `cand_`ivar'' `j'    
            file write `nullvals' "b`j'_`ivar'; se`j'_`ivar';"
        }        
    }
    
    dis "Bootstrap replications (`reps'). This may take some time."
    if length(`"`dots'"')==0 {
        dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
    }
    forvalues i=1/`reps' {
        local j=0
        preserve
        bsample `if' `in', `bopts'
        if length(`"`dots'"')==0 {
            display in smcl "." _continue
            if mod(`i',50)==0 dis "     `i'"
        }
        foreach var of varlist `varlist' {
            local ++j
            local Xv `controls'
            if length(`"`bl'"')!=0 local Xv `controls' `var'`bl' 
            if length(`"`indepexog'"')==0 {
                #delimit ;
                qui `method' `var' `ivr1'`indepvar'  `otherendog'`ivr2' `Xv'
                             `if' `in' `wt', `options';
                #delimit cr
            }
            else {
                #delimit ;
                qui `method' `var' `ivr1'`otherendog'`ivr2' `indepvar' `Xv'
                             `if' `in' `wt', `options';
                #delimit cr
            }
            local k=1
            foreach ivar of varlist `indepvar' {
                if `j'==1&`k'==1 file write `nullvals' _n "`= _b[`ivar']';`= _se[`ivar']'"
                else file write `nullvals' ";`= _b[`ivar']';`= _se[`ivar']'"
                local ++k
            }
        }
        restore
    }
    
    preserve
    file close `nullvals'
    qui insheet using `nullfile', delim(";") names clear case
}
else {
    local indepvar nobs

    preserve
    local cand_`indepvar'
    local j=0
    tokenize `varlist' 
    foreach beta of numlist `pointestimates' {
        local ++j
        qui count if ``j''!=.
        local reps=r(N)
        
        gen b`j'_`ivar'=``j''
        qui sum b`j'_`ivar'
        local beta`j'_`indepvar' = `beta' 
        local cand_`indepvar' `cand_`indepvar'' `j'
        local label`j' `: var label ``j'' '
        
        local pv``j''s_`indepvar'=.
    }
    local j=0
    tokenize `stdests'
    foreach se of numlist `stderrs' {
        local ++j
        gen se`j'_`ivar'=``j''
        if length(`"`nulls'"')==0    local beta0`j'_`indepvar'=0 
        
        local se`j' = `se'
        if length(`"`onesided'"')==0 {
            local t`j'_`indepvar' = abs((`beta`j'_`indepvar''-`beta0`j'_`indepvar'')/`se`j'')
        }
        else {
            local t`j'_`indepvar' =     (`beta`j'_`indepvar''-`beta0`j'_`indepvar'')/`se`j''
            local inft = min(`inft',`t`j'_`indepvar'')
        }

        if length(`"`nullimposed'"')!=0 local beta`j'_`indepvar'=0
    }
}

if `nivars' > 1 {
    foreach ivar in `indepvar' {
        matrix pvalues_`ivar' = J(`j',3,.)
        if length(`"`holm'"')!=0 matrix pvalues_`ivar' = J(`j',4,.)
    }
}
else {
    matrix pvalues = J(`j',3,.)
    if length(`"`holm'"')!=0 matrix pvalues = J(`j',4,.)
}
*-------------------------------------------------------------------------------
*--- Create null t-distribution
*-------------------------------------------------------------------------------
foreach num of numlist 1(1)`j' {    
    foreach i in `indepvar' {
        qui gen     t`num'_`i'=(b`num'_`i'-`beta`num'_`i'')/se`num'_`i'
        qui replace b`num'_`i'=abs((b`num'_`i'-`beta`num'_`i'')/se`num'_`i')
    }
}

*-------------------------------------------------------------------------------
*--- Create stepdown value in descending order based on t-stats
*-------------------------------------------------------------------------------
foreach ivar in `indepvar' {
    local maxt = `inft'-10
    local pval = 0
    local rank
    local Holm = `j'
    local prmsm1

    tokenize `varlist'
    local ii=0
    while length("`cand_`ivar''")!=0 {
        local ++ii
        local donor_tvals

        if length(`"`onesided'"')==0|`"`onesided'"'=="negative" {
            foreach var of local cand_`ivar' {
                if `t`var'_`ivar''>`maxt' {
                    local maxt = `t`var'_`ivar''
                    local maxv `var'
                    if length(`"`onesided'"')==0  local ovar  b`var'_`ivar'
                    if `"`onesided'"'=="negative" local ovar  t`var'_`ivar'
                }
                *dis "Maximum t among remaining candidates is `maxt' (variable `maxv')"
                if length(`"`onesided'"')==0  {
                    local donor_tvals `donor_tvals' b`var'_`ivar'
                }
                if `"`onesided'"'=="negative" {
                    local donor_tvals `donor_tvals' t`var'_`ivar'
                }
            }
            qui egen empiricalDist = rowmax(`donor_tvals')    
            qui count if empiricalDist>=`maxt'  & empiricalDist != .
            local cnum = r(N)
            if length(`"`plusone'"')!=0      local pval = (`cnum')/(`reps')
            else if length(`"`plusone'"')==0 local pval = (`cnum'+1)/(`reps'+1)
            
            qui count if `ovar'>=`maxt' & `maxt'!=.
            local cnum = r(N)
            if length(`"`plusone'"')!=0      local pvalBS = `cnum'/`reps'
            else if length(`"`plusone'"')==0 local pvalBS = (`cnum'+1)/(`reps'+1)
        
            local pbs`maxv's_`ivar'= `pvalBS'
            local prm`maxv's_`ivar'= `pval'
            local prh`maxv's_`ivar'= min(`pvalBS'*`Holm',1)

            if length(`"`prmsm1'"')!=0 {
                local prm`maxv's_`ivar'=max(`prm`maxv's_`ivar'',`prmsm1')
            }
            
            local prmsm1 = `prm`maxv's_`ivar''
            if length(`"`graph'"')!=0 {
                gen tDist`ii'_`ivar'=empiricalDist
                local tt`ii'_`ivar' = `t`maxv'_`ivar''
                local ll`ii'_`ivar' "`label`maxv''"
                local yy`ii'_`ivar' ``maxv''
                local pp`ii'_`ivar' = string(`prm`maxv's_`ivar'',"%6.4f")
            }            
        }
        else {
            local mint = .
            foreach var of local cand_`ivar' {
                if `t`var'_`ivar''<`mint' {
                    local mint = `t`var'_`ivar''
                    local minv `var'
                    local ovar t`var'_`ivar'
                }
                *dis "Minimum t among remaining candidates is `mint' (variable `minv')"
                local donor_tvals `donor_tvals' t`var'_`ivar'
            }
            qui egen empiricalDist = rowmin(`donor_tvals')
            qui count if empiricalDist <= `mint' & empiricalDist != .
            local cnum = r(N)
            if length(`"`plusone'"')!=0  local pval = (`cnum')/(`reps')
            else  local pval = (`cnum'+1)/(`reps'+1)
            qui count if `ovar'<=`mint' & `mint'!=.
            local cnum = r(N)
            if length(`"`plusone'"')!=0  local pvalBS = (`cnum')/(`reps')
            else local pvalBS = (`cnum'+1)/(`reps'+1)

            local pbs`minv's_`ivar'= `pvalBS'
            local prm`minv's_`ivar'= `pval'
            local prh`minv's_`ivar'= min(`pvalBS'*`Holm',1)
            
            if length(`"`prmsm1'"')!=0 {
                local prm`minv's_`ivar'=max(`prm`minv's_`ivar'',`prmsm1')
            }
            
            local prmsm1 = `prm`minv's_`ivar''
            if length(`"`graph'"')!= 0 {
                gen tDist`ii'_`ivar'=empiricalDist
                local tt`ii'_`ivar' = `t`minv'_`ivar''
                local ll`ii'_`ivar' "`label`minv''"
                local yy`ii'_`ivar' ``minv''
                local pp`ii'_`ivar' = string(`prm`minv's_`ivar'',"%6.4f")
            }
        }
        drop empiricalDist 
        local rank `rank' `maxv' `minv'
        local candnew
        foreach c of local cand_`ivar' {
            local match = 0
            foreach r of local rank {
                if `r'==`c' local match = 1
            }
            if `match'==0 local candnew `candnew' `c'
        }
        local cand_`ivar' `candnew'
        local maxt = `inft'-10
        local maxv = 0
        local --Holm    
    }
    
    if length(`"`graph'"')!= 0 {
        local graphs
        if length(`"`onesided'"')==0 {
            foreach num of numlist 1(1)`ii' {
                local title "Variable `yy`num'_`ivar''"
                if length(`"`varlabels'"')!=0 local title "`ll`num'_`ivar''"
                
                #delimit ;
                twoway hist tDist`num'_`ivar', bcolor(gs12) ||
                 function y=sqrt(2)/sqrt(c(pi))*exp(-x^2/2), range(0 6)
                 xline(`tt`num'_`ivar'', lcolor(red)) name(g`num', replace)
                 scheme(sj) nodraw legend(off) title(`title')
                 note("p-value = `pp`num'_`ivar''");
                #delimit cr
                local graphs `graphs' g`num'
            }
        }
        else {
            foreach num of numlist 1(1)`ii' {
                local title "Variable `yy`num'_`ivar''" 
                if length(`"`varlabels'"')!=0 local title "`ll`num'_`ivar''"
                #delimit ;
                twoway hist tDist`num'_`ivar', bcolor(gs12) ||
                 function y=1/sqrt(2*c(pi))*exp(-x^2/2), range(-4 4)
                 xline(`tt`num'_`ivar'', lcolor(red)) name(g`num', replace)
                 scheme(sj) nodraw legend(off) title(`title')
                 note("p-value = `pp`num'_`ivar''");
                #delimit cr
                local graphs `graphs' g`num'
            }
        }
        graph combine `graphs', scheme(sj)
    }
}
restore

*-------------------------------------------------------------------------------
*--- Report and export p-values
*-------------------------------------------------------------------------------
local vardisplay
local linelength=0
foreach var of varlist `varlist' {
    local linelength=`linelength'+length("`var'")
    if `linelength'>57 {
        local vardisplay "`vardisplay'" _newline _col(22) "`var'"
        local linelength=length("`var'")
    }
    else local vardisplay "`vardisplay' `var'"
}

if `nivars' > 1 {
    dis _newline
    dis _newline
    dis "Romano-Wolf step-down adjusted p-values"
    dis _newline
    foreach ivar of varlist `indepvar' {
        local j=0
        dis "Independent variable:  `ivar'"
        dis "Outcome variables:  `vardisplay'"
        dis "Number of resamples: `reps'"
        dis _newline
        dis "{hline 78}"
        dis "Outcome Variable    | Model p-value    Resample p-value    Romano-Wolf p-value"
        dis "{hline 20}+{hline 57}"
        foreach var of varlist `varlist' {
            local ++j
            display as text %19s abbrev("`var'",19) " {c |}     "       /*
                */  as result %6.4f `pv`var's_`ivar'' "             "   /*
                */  as result %6.4f `pbs`j's_`ivar'' "              "   /*
                */  as result %6.4f `prm`j's_`ivar''
            ereturn scalar rw_`var'_`ivar'=`prm`j's_`ivar''
            matrix pvalues_`ivar'[`j',1]=`pv`var's_`ivar''
            matrix pvalues_`ivar'[`j',2]=`pbs`j's_`ivar''
            matrix pvalues_`ivar'[`j',3]=`prm`j's_`ivar''
            if length(`"`holm'"')!=0 matrix pvalues_`ivar'[`j',4]=`prh`j's_`ivar''
        }
        dis "{hline 78}"
        dis _newline
        ereturn matrix RW_`ivar'=pvalues_`ivar'
    }
}
else {
    local ivar `indepvar'
    local j=0
    dis _newline
    dis _newline
    dis "Romano-Wolf step-down adjusted p-values"
    dis _newline
    if length(`"`nobootstraps'"')==0 dis "Independent variable:  `indepvar'"
    dis "Outcome variables:  `vardisplay'"
    dis "Number of resamples: `reps'"
    dis _newline
    dis "{hline 78}"
    dis "Outcome Variable    | Model p-value    Resample p-value    Romano-Wolf p-value"
    dis "{hline 20}+{hline 57}"
    foreach var of varlist `varlist' {
        local ++j
        display as text %19s abbrev("`var'",19) " {c |}    "        /*
            */  as result %6.4f `pv`var's_`ivar'' "             "   /*
            */  as result %6.4f `pbs`j's_`ivar'' "              "   /*
            */  as result %6.4f `prm`j's_`ivar''
        ereturn scalar rw_`var'=`prm`j's_`ivar''
        matrix pvalues[`j',1]=`pv`var's_`ivar''
        matrix pvalues[`j',2]=`pbs`j's_`ivar''
        matrix pvalues[`j',3]=`prm`j's_`ivar''
        if length(`"`holm'"')!=0 matrix pvalues[`j',4]=`prh`j's_`ivar''
    }
    dis "{hline 78}"
    ereturn matrix RW=pvalues
}

end
