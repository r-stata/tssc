clear
set more off
*
* Motivation:  instance in which conventional Wald CI (includes zero) is inconsistent with hypothesis test (P = 0.02)
*
use http://www.stata-press.com/data/r9/downs.dta
cs case expose [fweight = pop]
rdci case expose [fweight = pop]
*
* Some worked examples from the literature
*
* From Newcombe (1998), Table II
rdcii 56 48 `=70-56' `=80-48'
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn) // The table reports results to four decimal places
display in smcl as input "0.0528", "0.3382"              // Miettenan-Nurminen results from the table
rdcii 9 3 1 7
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn)
display in smcl as input "0.1700", "0.8406"
rdcii 6 2 1 5
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn)
display in smcl as input "0.0342", "0.8534"
rdcii 5 0 51 29
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn)
display in smcl as input "-0.0326", "0.1933"
rdcii 0 0 10 20
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn) // This is also in the original Miettinen & Nurminen article
display in smcl as input "-0.1658", "0.2844"
rdcii 0 0 10 10
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn)
display in smcl as input "-0.2879", "0.2879"
rdcii 10 0 0 20
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn)
display in smcl as input "0.7156", "1.0000"
rdcii 10 0 0 10
display in smcl as result %6.4f r(lb_mn), %6.4f r(ub_mn)
display in smcl as input "0.6636", "1.0000"
* From Wallenstein (1997), Section 4 (Examples)
rdcii 4 0 12 15
rdcii 379 1 0 5, cc
*
* Tolerance for root finding is not synonymous with tolerance for confidence limit
*
rdcii 3 3 2 2, verbose
* Note that the first evaluation's function return for lower and upper bounds were very large, so
* relative tolerance of 1e-6 was easily satisfied on the zeroeth iteration
rdcii 3 3 2 2, verbose tolerance(1e-10)
rdcii 3 3 2 2, verbose ltolerance(1e-6)
* Again
rdcii 6 6 0 0, verbose
rdcii 6 6 0 0, ltol(1e-6)
exit
