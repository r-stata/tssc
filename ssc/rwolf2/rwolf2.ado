*! rwolf2: Romano Wolf stepdown hypothesis testing algorithm, alternative syntax
*! Version 1.0.0 july 5, 2021 @ 23:56:11
*! Author: Damian Clarke
*! Department of Economics
*! University of Chile
*! dclarke@fen.uchile.cl

/*
version highlights:
1.0.0:[05/07/2021]: 
*/


cap program drop rwolf2
program rwolf2, eclass
vers 11.0

*-------------------------------------------------------------------------------
*--- (0) Parsing of equations 
*-------------------------------------------------------------------------------    
local stop 0
local i = 0
while !`stop' {
    gettoken eqn 0 : 0,  parse(" ,[") match(paren)    
    if `"`paren'"'=="(" {
        local ++i
        local eqn`i' `eqn'
    }
    else {
        local stop 1
    }
}
local 0 ", `0'"
local numeqns = `i'

*-------------------------------------------------------------------------------
*--- (1) Syntax
*-------------------------------------------------------------------------------
#delimit ;
syntax , indepvars(string)
[
  reps(integer 100)
  Verbose
  seed(numlist integer >0 max=1)
  holm
  graph
  onesided(name)
  varlabels
  nodots
  nulls(numlist)
  strata(varlist)
  CLuster(varlist)
  idcluster(string)
  usevalid
  noplusone
];
#delimit cr

*-------------------------------------------------------------------------------
*--- (2) Unpacking baseline options and error check
*-------------------------------------------------------------------------------
if length(`"`verbose'"')==0 local q qui
cap set seed `seed'

local jj=1
foreach rdvar in RD_Estimate Conventional Bias-corrected Robust {
    cap gen `rdvar' = .
    if _rc==0 local DROP`jj' = 1
    else      local DROP`jj' = 0    
    local ++jj
}



if length(`"`onesided'"')!=0 {
    if `"`onesided'"'!="positive"&`"`onesided'"'!="negative" {
        local W1 "When specifying onesided(), only onesided(positive)"
        dis as error "`W1' or onesided(negative) are permissible"
        exit 200
    }
}

if length(`"`nulls'"')!=0 {
    local j = 0
    foreach null of numlist `nulls' {
        local ++j
        local beta0`j' = `null'
    }
    local nnulls = `j'
}

tempname nullvals
tempfile nullfile
file open `nullvals' using "`nullfile'", write all

tokenize `"`indepvars'"', parse(",")
local NVARS = 0 
foreach equation of numlist 1(1)`numeqns' {
    foreach var of varlist ``equation'' {
        local ++NVARS
    }
    macro shift
}


local nsets=0
tokenize `"`indepvars'"', parse(",")
while length("`1'")!=0 {
    macro shift
    local ++nsets
}
if `numeqns'*2-1!=`nsets' {
    local NEff = (`nsets'+1)/2
    dis as error "`numeqns' equations are specified, and `NEff' set(s) of indepdent variables are specified."
    dis as error "Ensure that indepvars includes a list of variables of interest for each equation."
    error 200
}

local bopts
if length(`"`strata'"')!=0  local bopts `bopts' strata(`strata')
if length(`"`cluster'"')!=0 local bopts `bopts' cluster(`cluster')
if length(`"`idcluster'"')!=0 {
    if length(`"`cluster'"')==0 {
        dis as error "The idcluster option requires that cluster is also specified"
        exit 200
    }
    local bopts `bopts' idcluster(`idcluster')
    foreach equation of numlist 1(1)`numeqns' {
        local RE1 = "cluster\(.*\)"
        local RE2 = "vce\( *[cluster].*\)"
        local beqn`equation' = regexr("`eqn`equation''" ,"`RE1'","cluster(`idcluster')")
        local beqn`equation' = regexr("`beqn`equation''","`RE2'","vce(cluster `idcluster')")
    }
}

*-------------------------------------------------------------------------------
*--- (3) Parsing of independent variables and estimating models
*-------------------------------------------------------------------------------
tokenize `"`indepvars'"', parse(",")

local inft = 0
local j    = 0
local diswidth = 15

local allvars
foreach equation of numlist 1(1)`numeqns' {
    `q' dis "Equation `equation' is `eqn`equation''"
    `q' dis "Variables to correct are ``equation''"
    `q' `eqn`equation''

    local y`equation' `e(depvar)'    
    local y`equation'length = length("`y`equation''")
    local diswidth = max(`diswidth',`y`equation'length')
    local xvar`equation'
    foreach var of varlist ``equation'' {
        local xvar`equation' `xvar`equation'' `var'
        local allvars `allvars' "(`y`equation''-`var')"
        
        local ++j
        if length(`"`nulls'"')==0 local beta0`j' = 0

        if length(`"`onesided'"')==0 {
            local t`j' = abs((_b[`var']-`beta0`j'')/_se[`var'])
        }
        else {
            local t`j' = (_b[`var']-`beta0`j'')/_se[`var']
            local inft = min(`inft',`t`j'')
        }
        local beta`j' = _b[`var']
        qui test _b[`var'] = `beta0`j''
        local pv`j' = string(r(p), "%6.4f")
        local pv`j's= r(p)
        local label`j' `: var label `var' '


        if `"`onesided'"'=="positive" {
            qui test `var'=`beta0`j''
            local sgn = sign(_b[`var'])
            if length(`"`r(F)'"')!=0 {
                local pv`j'  = string(1-ttail(r(df_r),`sgn'*sqrt(r(F))), "%6.4f")
                local pv`j's = (1-ttail(r(df_r),`sgn'*sqrt(r(F))))
            }
            else {
                local pv`j's=normal(`sgn'*sqrt(r(chi2)))
            }
        }
        if `"`onesided'"'=="negative" {
            qui test `var'=`beta0`j''
            local sgn = sign(_b[`var'])
            if length(`"`r(F)'"')!=0 {
                local pv`j'  = string(ttail(r(df_r),`sgn'*sqrt(r(F))), "%6.4f")
                local pv`j's = (ttail(r(df_r),`sgn'*sqrt(r(F))))
            }
            else {
                local pv`j's= 1-normal(`sgn'*sqrt(r(chi2)))
            }
        }
        local cand `cand' `j'
        file write `nullvals' "b`j'; se`j';"
    }
    macro shift
}



*-------------------------------------------------------------------------------
*--- (4) Bootstrap replications
*-------------------------------------------------------------------------------
dis "Bootstrap replications (`reps'). This may take some time."
if length(`"`dots'"')==0 {
    dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
}
forvalues i=1/`reps' {
    local bmess1 "There has been an issue with a bootstrap replicate"
    local bmess2 "in bootstrap `i'.  Taking next bootstrap sample..."
    local j=0
    preserve
    bsample, `bopts'
    if length(`"`dots'"')==0 {
        display in smcl "." _continue
        if mod(`i',50)==0 dis "     `i'"
    }

    foreach equation of numlist 1(1)`numeqns' {
        if length(`"`usevalid'"')==0 {
            if length(`"`idcluster'"')!=0 qui `beqn`equation''
            else qui `eqn`equation''
            local k=1
            foreach var of varlist `xvar`equation'' {
                local ++j
                if `j'==1&`k'==1 file write `nullvals' _n "`= _b[`var']';`= _se[`var']'"
                else file write `nullvals' ";`= _b[`var']';`= _se[`var']'"
                local ++k
            }
        }
        if length(`"`usevalid'"')!=0 {
            if length(`"`idcluster'"')!=0 cap `beqn`equation''
            else cap `eqn`equation''
            
            local RET = _rc
            local k=1
            foreach var of varlist `xvar`equation'' {
                if `RET'!=0 {
                    local Bbeta = .
                    local Bstde = .
                }
                else {
                    local Bbeta = _b[`var']
                    local Bstde = _se[`var']
                }
                local ++j
                if `j'==1&`k'==1 file write `nullvals' _n "`Bbeta';`Bstde'"
                else file write `nullvals' ";`Bbeta';`Bstde'"
                local ++k
            }
        }
    }
    restore
}


preserve
file close `nullvals'
qui insheet using `nullfile', delim(";") names clear case

matrix pvalues = J(`j',3,.)
if length(`"`holm'"')!=0 matrix pvalues = J(`j',4,.)


*-------------------------------------------------------------------------------
*--- (5) Create null t-distribution
*-------------------------------------------------------------------------------
local P=0
foreach num of numlist 1(1)`j' {    
    qui gen     t`num'=(b`num'-`beta`num'')/se`num'
    qui replace b`num'=abs((b`num'-`beta`num'')/se`num')
    
    qui count if t`num'!=.
    if r(N)!=`reps' local ++P
}
if length(`"`usevalid'"')!=0 {
    egen NMISS = rowmiss(t*)
    qui drop if NMISS!=0
    qui count
    local reps = r(N)
}
else {
    if `P'!=0 {
        dis as error "Not all bootstrap replicates have produced defined t-statistics for each variable"
        dis as error "It is suggested that the usevalid option should be specified to discard invalid bootstrap replicates"
    }
}

*-------------------------------------------------------------------------------
*--- (6) Create stepdown value in descending order based on t-stats
*-------------------------------------------------------------------------------
local maxt = `inft'-10
local pval = 0
local rank
local Holm = `j'
local prmsm1

tempvar empiricalDist
tokenize `allvars'
local ii=0
while length("`cand'")!=0 {
    local ++ii
    local donor_tvals
    
    if length(`"`onesided'"')==0|`"`onesided'"'=="negative" {
        foreach var of local cand {
            if `t`var''>`maxt' {
                local maxt = `t`var''
                local maxv `var'
                if length(`"`onesided'"')==0  local ovar  b`var'
                if `"`onesided'"'=="negative" local ovar  t`var'
            }
            *dis "Maximum t among remaining candidates is `maxt' (variable `maxv')"
            if length(`"`onesided'"')==0  {
                local donor_tvals `donor_tvals' b`var'
            }
            if `"`onesided'"'=="negative" {
                local donor_tvals `donor_tvals' t`var'
            }
        }
        qui egen `empiricalDist' = rowmax(`donor_tvals')    
        qui count if `empiricalDist'>=`maxt'  & `empiricalDist' != .
        local cnum = r(N)

        if length(`"`plusone'"')!=0      local pval = (`cnum')/(`reps')
        else if length(`"`plusone'"')==0 local pval = (`cnum'+1)/(`reps'+1)
        
        qui count if `ovar'>=`maxt' & `ovar'!=.
        local cnum = r(N)

        if length(`"`plusone'"')!=0      local pvalBS = `cnum'/`reps'
        else if length(`"`plusone'"')==0 local pvalBS = (`cnum'+1)/(`reps'+1)
    
        local pbs`maxv's= `pvalBS'
        local prm`maxv's= `pval'
        local prh`maxv's= min(`pvalBS'*`Holm',1)
        
        if length(`"`prmsm1'"')!=0 {
            local prm`maxv's=max(`prm`maxv's',`prmsm1')
        }
    
        local prmsm1 = `prm`maxv's'
        if length(`"`graph'"')!=0 {
            gen tDist`ii' = `empiricalDist'
            local tt`ii' = `t`maxv''
            local ll`ii' "`label`maxv''"
            local yy`ii' ``maxv''
            local pp`ii' = string(`prm`maxv's',"%6.4f")
        }         
    }
    else {
        local mint = .
        foreach var of local cand {
            if `t`var''<`mint' {
                local mint = `t`var''
                local minv `var'
                local ovar t`var'
            }
            *dis "Minimum t among remaining candidates is `mint' (variable `minv')"
            local donor_tvals `donor_tvals' t`var'
        }
        qui egen `empiricalDist' = rowmin(`donor_tvals')
        qui count if `empiricalDist' <= `mint' & `empiricalDist' != .
        local cnum = r(N)

        if length(`"`plusone'"')!=0  local pval = (`cnum')/(`reps')
        else  local pval = (`cnum'+1)/(`reps'+1)
        qui count if `ovar'<=`mint' & `ovar'!=.
        local cnum = r(N)
        if length(`"`plusone'"')!=0  local pvalBS = (`cnum')/(`reps')
        else local pvalBS = (`cnum'+1)/(`reps'+1)

        local pbs`minv's = `pvalBS'
        local prm`minv's = `pval'
        local prh`minv's = min(`pvalBS'*`Holm',1)
            
        if length(`"`prmsm1'"')!=0 {
            local prm`minv's = max(`prm`minv's',`prmsm1')
        }
            
        local prmsm1 = `prm`minv's'
        if length(`"`graph'"')!= 0 {
            gen tDist`ii' = `empiricalDist'
            local tt`ii' = `t`minv''
            local ll`ii' "`label`minv''"
            local yy`ii' ``minv''
            local pp`ii' = string(`prm`minv's',"%6.4f")
        }
    }
    drop `empiricalDist'
    local rank `rank' `maxv' `minv'
    local candnew
    foreach c of local cand {
        local match = 0
        foreach r of local rank {
            if `r'==`c' local match = 1
        }
        if `match'==0 local candnew `candnew' `c'
    }
    local cand `candnew'
    local maxt = `inft'-10
    local maxv = 0
    local --Holm    
}


*-------------------------------------------------------------------------------
*--- (7) Graphing null distributions
*-------------------------------------------------------------------------------
if length(`"`graph'"')!= 0 {
    local graphs
    if length(`"`onesided'"')==0 {
        foreach num of numlist 1(1)`ii' {
            local title "Combination `yy`num''"
            if length(`"`varlabels'"')!=0 local title "`ll`num''"
            
            #delimit ;
            twoway hist tDist`num', bcolor(gs12) ||
            function y=sqrt(2)/sqrt(c(pi))*exp(-x^2/2), range(0 6)
            xline(`tt`num'', lcolor(red)) name(g`num', replace)
            scheme(sj) nodraw legend(off) title(`title')
            note("p-value = `pp`num''");
            #delimit cr
            local graphs `graphs' g`num'
        }
    }
    else {
        foreach num of numlist 1(1)`ii' {
            local title "Combination `yy`num''" 
            if length(`"`varlabels'"')!=0 local title "`ll`num''"
            #delimit ;
            twoway hist tDist`num', bcolor(gs12) ||
            function y=1/sqrt(2*c(pi))*exp(-x^2/2), range(-4 4)
            xline(`tt`num'', lcolor(red)) name(g`num', replace)
            scheme(sj) nodraw legend(off) title(`title')
            note("p-value = `pp`num''");
            #delimit cr
            local graphs `graphs' g`num'
        }
    }
    graph combine `graphs', scheme(sj)
}
restore


*-------------------------------------------------------------------------------
*--- (8) Report and export p-values
*-------------------------------------------------------------------------------
ereturn clear
local vardisplay
local linelength=0

foreach equation of numlist 1(1)`numeqns' {
    foreach var of varlist `xvar`equation'' {
        local linelength=`linelength'+length("`var'")
        if `linelength'>57 {
            local vardisplay "`vardisplay'" _newline _col(22) "`var'"
            local linelength=length("`var'")
        }
        else local vardisplay "`vardisplay' `var'"
    }
}
local crit = (100-c(level))/100
local lev  = c(level)
if length(`"`usevalid'"')!=0 {
    local NREP "Number of valid resamples: `reps'"
}
else local NREP "Number of resamples: `reps'"

dis _newline
dis "Romano-Wolf step-down adjusted p-values"
dis "`NREP'"
dis _newline
dis "{hline 78}"


if length(`"`holm'"')==0 {
    dis "{dup `diswidth': } | Model p-value    Resample p-value    Romano-Wolf p-value"
    dis "{hline `=`diswidth'+1'}+{hline `=76-`diswidth''}"
}
else {
    dis "{dup `diswidth': } |  Model        Resample       Romano-Wolf        Holm"
    dis "{dup `diswidth': } | p-value       p-value         p-value         p-value"
    dis "{hline `=`diswidth'+1'}+{hline `=76-`diswidth''}"
}

local j = 0
foreach equation of numlist 1(1)`numeqns' {
    local DUP = `diswidth' - `y`equation'length'
    display as text "`y`equation'' {dup `DUP': }{c |}     "
    if length(`"`holm'"')==0 {
        foreach var of varlist `xvar`equation'' {
            local ++j
            display as text %`diswidth's abbrev("`var'",19) " {c |}     "   /*
            */  as result %6.4f `pv`j's' "             "                    /*
            */  as result %6.4f `pbs`j's' "              "                  /*
            */  as result %6.4f `prm`j's'
            ereturn scalar rw_`y`equation''_`var'=`prm`j's'
            matrix pvalues[`j',1]=`pv`j's'
            matrix pvalues[`j',2]=`pbs`j's'
            matrix pvalues[`j',3]=`prm`j's'            
        }
    }    
    else {
        foreach var of varlist `xvar`equation'' {
            local ++j
            display as text %`diswidth's abbrev("`var'",19) " {c |}  "   /*
            */  as result %6.4f `pv`j's' "        "                    /*
            */  as result %6.4f `pbs`j's' "          "                  /*
            */  as result %6.4f `prm`j's' "          "                  /*
            */  as result %6.4f `prh`j's'
            ereturn scalar rw_`y`equation''_`var'=`prm`j's'
            matrix pvalues[`j',1]=`pv`j's'
            matrix pvalues[`j',2]=`pbs`j's'
            matrix pvalues[`j',3]=`prm`j's'
            matrix pvalues[`j',4]=`prh`j's'
        }
    }
    dis "{hline 78}"
}
dis _newline

*-------------------------------------------------------------------------------
*--- (9) Clean up and Return
*-------------------------------------------------------------------------------
local jj=1
foreach rdvar in RD_Estimate Conventional Bias-corrected Robust {
    if `DROP`jj''==1 {
        drop `rdvar'
    }
    local ++jj
}


ereturn matrix RW=pvalues
end
