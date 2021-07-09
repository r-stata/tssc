program mbsens
version 12.1
args treated strata outcomevar g1 g2 g3
//drop if `strata' == "NA"
qui bysort `strata': gen cnt_control = 1 if `treated' == 1 & `outcomevar' == 1
qui gsort `strata' -cnt_control
qui bysort `strata': carryforward(cnt_control), gen (cc)
qui bysort `strata': gen cnt_treated = 1 if `treated' == 0 & `outcomevar' == 1
qui gsort `strata' -cnt_treated
qui bysort `strata': carryforward(cnt_treated), gen(ct)
qui gsort `strata' -`outcomevar'
qui bysort `strata' : gen count_arbitrage = sum(`outcomevar')
qui bysort `strata': egen maxcount_arbitrage  = max(count_arbitrage)
qui bysort `strata': gen countInStrata = _N
qui bysort `strata':gen arbitrage_weight = maxcount_arbitrage / countInStrata
qui gen final_arb_weight = arbitrage_weight * 2
qui by `strata': gen tocountin = 1 if _n == 1
qui sum(final_arb_weight) if cc == 1 & ct == . & tocountin == 1
qui sum(final_arb_weight) if cc == . & ct == 1  & tocountin == 1
qui sum(final_arb_weight) if cc == . & ct == . & tocountin  == 1
qui sum(final_arb_weight) if cc == 1 & ct == 1 & tocountin == 1
***Note that to adjust for counts you have to multiply observation by mean which results from sum

***get k2kcount
qui count if cc == 1 & ct == . & tocountin == 1 & countInStrata == 2
qui local dc1 = r(N) 
qui count if cc == . & ct == 1 & tocountin == 1 & countInStrata == 2
qui local dc2 = r(N)
qui count if cc == . & ct == . & tocountin == 1 & countInStrata == 2
qui local dc3 = r(N)
qui count if cc == 1 & ct == 1 & tocountin == 1 & countInStrata == 2
qui local dc4 = r(N)
qui local lower = `dc1'
qui local higher = `dc2'
qui if (`dc1' > `dc2'){
 local lower = `dc2'
local higher = `dc1'
}

bsens `lower' `higher' `g1' `g2' `g3'
end
