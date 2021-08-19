* LogitToRiski version 1.0 - 01 December 2020
* Authors: Luis Furuya-Kanamori (luis.furuya-kanamori@anu.edu.au) & Suhail AR Doi

program define logittoriski, rclass
version 14

syntax anything ///
[, r0(numlist max=1) noGraph] 

tokenize `anything'

preserve

quietly {

*Data entry
	cap set obs 1
		cap gen __a = `1' 
		cap gen __b = `2' 
		cap gen __c = `3' 


*Error/warning messages
	*Baseline 
	quietly gen __r0_mis = .
	
	if "`r0'"=="" {
	local r0 0.5
	quietly replace __r0_mis = 1
	}
	
	if "`r0'"!="" {
	local r0 `r0'
		cap assert `r0'>=0 & `r0'<=1
		if _rc {
		di as error "r0 outside the range (0 to 1)"
		exit 198
		}
	}
		
	*Negative values
	cap assert `1'>0 & `2'>=0 & `3'>0 	
		if _rc {
		di as err "OR, LCI, UCI contain negative values"
		exit 198
		}
	
	*OR within CI (OR LCI UCI)
	cap assert `1'>=`2' & `1'<=`3'
		if _rc {
		di as err "OR outside the confidence interval"
		exit 198
		}

	
*Generate input for analysis
	if "`r0'"=="" {
	gen __r0 = 0.5
	gen __odds0 = __r0/(1-__r0)
	}
	
	if "`r0'"!="" {
	local r0 `r0'
	gen __r0 = `r0'
	gen __odds0 = __r0/(1-__r0)
	}
		
	gen __odds1 = (__a) * __odds0
	gen __odds1_lci = (__b) * __odds0
	gen __odds1_uci = (__c) * __odds0
	
	gen __r1 = __odds1/(1+__odds1)
	gen __r1_lci = __odds1_lci/(1+__odds1_lci)
	gen __r1_uci = __odds1_uci/(1+__odds1_uci)
	
	gen __rr = __r1/__r0
	gen __rr_lci = __r1_lci/__r0
	gen __rr_uci = __r1_uci/__r0
	
	gen __rd = __r1-__r0
	gen __rd_lci = __r1_lci-__r0
	gen __rd_uci = __r1_uci-__r0
	
	gen __nnt = 1/__rd
	gen __nnt_lci = 1/__rd_uci
	gen __nnt_uci = 1/__rd_lci
		cap quietly gen __nnt_di=.	
			cap quietly replace __nnt_di = ceil(__nnt) if __nnt>=0
			cap quietly replace __nnt_di = floor(__nnt) if __nnt<0
		cap quietly gen __nnt_lci_di=.
			cap quietly replace __nnt_lci_di = ceil(__nnt_lci) if __nnt_lci>=0
			cap quietly replace __nnt_lci_di = floor(__nnt_lci) if __nnt_lci<0
		cap quietly gen __nnt_uci_di=.
			cap quietly replace __nnt_uci_di = ceil(__nnt_uci) if __nnt_uci>=0
			cap quietly replace __nnt_uci_di = floor(__nnt_uci) if __nnt_uci<0
}

		
*Display results
di ""
	if __r0_mis == 1 {
	di as text "r0 = 0.5 (assumed)"
	}
di in smcl as txt "{hline 9}{c TT}{hline 40}"
di in smcl as txt "{col 10}{c |}      Estimate      95% Conf. Interval"
di in smcl as txt "{hline 9}{c +}{hline 40}"
di as text "r1" as txt "{col 10}{c |}" ///
	"{col 20}" round(__r1[1],0.001)
di as text "r0" as txt "{col 10}{c |}" ///
	"{col 20}" round(__r0[1],0.001)
di in smcl as txt "{hline 9}{c +}{hline 40}"
di as text "RR" as txt "{col 10}{c |}" ///
	"{col 20}" round(__rr[1],0.001) ///
	"{col 32}" round(__rr_lci[1],0.001) ///
	"{col 42}" round(__rr_uci[1],0.001) 
di as text "RD" as txt "{col 10}{c |}" ///
	"{col 20}" round(__rd[1],0.001) ///
	"{col 32}" round(__rd_lci[1],0.001) ///
	"{col 42}" round(__rd_uci[1],0.001) 
di as text "NNT" as txt "{col 10}{c |}" ///
	"{col 20}" (__nnt_di[1]) ///
	"{col 32}" (__nnt_lci_di[1]) ///
	"{col 42}" (__nnt_uci_di[1]) 
di in smcl as txt "{hline 9}{c BT}{hline 40}"
	
	
*Scalars
	return scalar nnt_uci = __nnt_uci[1]
	return scalar nnt_lci = __nnt_lci[1]
	return scalar nnt = __nnt[1]
	return scalar rd_uci = __rd_uci[1]
	return scalar rd_lci = __rd_lci[1]
	return scalar rd = __rd[1]
	return scalar rr_uci = __rr_uci[1]
	return scalar rr_lci = __rr_lci[1]
	return scalar rr = __rr[1]
	return scalar r0 = __r0[1]
	return scalar r1 = __r1[1]
	

*Restore data and exit
restore 
end
exit

