
*! version 1.0.0  12jun2006



program  metagen
version 8.0
syntax varlist(min=4 max=4 numeric) [if] [in]

/* 1 var showing case/controls, 2 var showing genotypes, 3 var showing the study id, 4 var counts  */
preserve
local str2 =substr("`2'",1,3)
local str3 =substr("`3'",1,3)

tempvar one
qui egen `one'=sum(`4') if `1'==1
qui sum `one'
local cases=r(mean)

tempvar zero
qui egen `zero'=sum(`4') if `1'==0
qui sum `zero'
local controls=r(mean)
local total=`cases' + `controls'


qui xi:glm `1' i.`2'  i.`3' i.`2'*i.`3' [fw=`4'], fam(binom) link(logit) eform
qui testparm  _I`str2'X`str3'*
local chi_het=r(chi2)
local isqr=max(0,(r(chi2)-r(df))/r(chi2))

local df_het=r(df)
local p_het=r(p)
 
qui xi:glm `1' i.`2'  i.`3' [fw=`4'], fam(binom) link(logit) eform
local for2=exp(_b[_I`2'_2])
local fse2=_se[_I`2'_2]
local fll2=exp(_b[_I`2'_2]-1.96*_se[_I`2'_2])
local ful2=exp(_b[_I`2'_2]+1.96*_se[_I`2'_2])
local fp2=2*min((1-normprob(_b[_I`2'_2]/_se[_I`2'_2])),normprob(_b[_I`2'_2]/_se[_I`2'_2]))

local for3=exp(_b[_I`2'_3])
local fse3=_se[_I`2'_3]
local fll3=exp(_b[_I`2'_3]-1.96*_se[_I`2'_3])
local ful3=exp(_b[_I`2'_3]+1.96*_se[_I`2'_3])
local fp3=2*min((1-normprob(_b[_I`2'_3]/_se[_I`2'_3])),normprob(_b[_I`2'_3]/_se[_I`2'_3]))

qui test  _I`2'_2 = _I`2'_3
local chi_fgen=r(chi2)
local df_fgen=r(df)
local p_fgen=r(p)


capture drop wt1 
qui gen wt1=`4'
qui eq slope2 :_I`2'_2
qui eq slope3 :_I`2'_3

qui gllamm `1' _I`2'_2 _I`2'_3 _I`3'_*, fam(binom) link(logit) i(`3') w(wt) adapt nip(8) eform eqs(slope2 slope3) nrf(2) 

local ror2=exp(_b[_I`2'_2])
local rse2=_se[_I`2'_2]
local rll2=exp(_b[_I`2'_2]-1.96*_se[_I`2'_2])
local rul2=exp(_b[_I`2'_2]+1.96*_se[_I`2'_2])
local rp2=2*min((1-normprob(_b[_I`2'_2]/_se[_I`2'_2])),normprob(_b[_I`2'_2]/_se[_I`2'_2]))


local ror3=exp(_b[_I`2'_3])
local rse3=_se[_I`2'_3]
local rll3=exp(_b[_I`2'_3]-1.96*_se[_I`2'_3])
local rul3=exp(_b[_I`2'_3]+1.96*_se[_I`2'_3])
local rp3=2*min((1-normprob(_b[_I`2'_3]/_se[_I`2'_3])),normprob(_b[_I`2'_3]/_se[_I`2'_3]))

qui test  _I`2'_2 = _I`2'_3
local chi_rgen=r(chi2)
local df_rgen=r(df)
local p_rgen=r(p)





qui xi:glm `1' i.`2'  i.`3' [fw=`4'], fam(binom) link(logit) eform
qui lincom  _I`2'_2- _I`2'_3

tempvar delta
qui gen `delta'=r(estimate)

tempvar deltai
qui gen `deltai'=.

tempvar vari
qui gen `vari'=.

tempvar stat
qui gen `stat'=.

tempvar last
qui bysort `3': gen `last'=_n==_N

qui sum `3' 
local max=r(max)

forvalues i=1(1)`max' {
	qui glm `1' _I`2'_2 _I`2'_3 if `3' ==`i' [fw=`4'], fam(binom) link(logit) eform
	qui lincom  _I`2'_2- _I`2'_3
	qui replace `deltai'=r(estimate) if `3'==`i'
	qui replace `vari'=r(se)* r(se) if `3'==`i'
	qui replace `stat'=((`delta'-`deltai')^2)/`vari' if `last'==1
}
tempvar sum
qui egen `sum'=sum(`stat')
qui sum `sum'
local chi_het_gen=r(mean)
local p_het_gen=chiprob(`max'-1, r(mean))
local df_het_gen=`max'-1



di in gr "Meta-analysis of case-control genetic association studies"
di in gr "---------------------------------------------------------"
di " "
di in gr "Number of studies: " in ye `max'
di in gr "Number of individuals (Cases/Controls): " in ye "`total' (`cases'""/""`controls')"
di " "
di in gr "Fixed-effects method"
di in gr "--------------------"
di in gr "            Odds Ratio       P-value       [95% Conf. Interval]"
di in gr "AB vs. AA" in ye %8.3f `for2' %17.3f  `fp2'   %16.3f `fll2' %8.3f `ful2'
di in gr "BB vs. AA" in ye %8.3f `for3' %17.3f  `fp3'   %16.3f `fll3' %8.3f `ful3' 
di in gr "----------------------------------------------------------------"
di " "
di in gr "Test for the genetic model"
di in gr "Ho: OR(AB vs. AA) = OR(BB vs. AA)"
di in gr "Chi-square ("in ye "1" in gr " df) = "in ye %6.3f `chi_fgen'
di in gr "P-value = " in ye %6.3f `p_fgen'
di " "
di in gr "Random-effects method"
di in gr "---------------------"
di in gr "            Odds Ratio       P-value       [95% Conf. Interval]"
di in gr "AB vs. AA" in ye %8.3f `ror2' %17.3f `rp2'  %16.3f  `rll2' %8.3f `rul2' 
di in gr "BB vs. AA" in ye %8.3f `ror3' %17.3f `rp3'  %16.3f  `rll3' %8.3f `rul3' 
di in gr "----------------------------------------------------------------"
di " "
di in gr "Test for the genetic model"
di in gr "Ho: OR(AB vs. AA) = OR(BB vs. AA)"
di in gr "Chi-square ("in ye "1" in gr " df) = "in ye %6.3f `chi_rgen'
di in gr "P-value = " in ye %6.3f `p_rgen'
di " "
di in gr "Tests for Heterogeneity"
di in gr "-----------------------"
di " "
di in gr "Genotype effect"
di in gr "Chi-square ("in ye "`df_het'" in gr " df)= "in ye %6.3f `chi_het'
di in gr "I-square = " in ye %6.3f `isqr'
di in gr "P-value = " in ye %6.3f `p_het'
di " "
di in gr "Genetic model"
di in gr "Chi-square ("in ye "`df_het_gen'" in gr " df)= "in ye %6.3f `chi_het_gen'
di in gr "P-value = " in ye %6.3f `p_het_gen'


xi
local drop all
restore
end
