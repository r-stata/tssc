*! Do-file to replicate the results for the Keane & Runkle (1992) estimator in Table 8.1 of Chapter 8
*! in Baltagi, B. 2005. Econometric Analysis of Panel Data. 3rd ed. West Sussex, England: John Wiley and Sons. 

use cigar.dta
gen logc = log(c/popgt16*pop)
gen logp = log(price/cpi)
gen logpn = log(pimin/cpi)
gen logy = log(ndi/cpi)

*! Without Time Dummies
*! In Level Form
xtkr logc logp logpn logy (l.logc = l.logp l.logpn l.logy)
*! In First Difference Form
xtkr d.logc d.logp d.logpn d.logy (d.l.logc = l.logp l.logpn l.logy)

*! With Time Dummies
*! In Level Form
xtkr logc logp logpn logy (l.logc = l.logp l.logpn l.logy), tdum
*! In First Difference Form
xtkr d.logc d.logp d.logpn d.logy (d.l.logc = l.logp l.logpn l.logy), tdum
