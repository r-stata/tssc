*! v2.0.0, 2020-04-21, Philippe Van Kerm, module to compute the 'adjusted' fractional rank from any variable
*  alternative, faster calculation (without -cumul-); allow all weights
* v1.3.0, 2010-02-05, Philippe Van Kerm, module to compute the 'adjusted' fractional rank from any variable
*  allow time-series operators
* v1.2.0, 2009-09-14, Philippe Van Kerm, module to compute the 'adjusted' fractional rank from any variable
*  add normalization of aweights
* v1.0.1, 2007-11-19, Philippe Van Kerm, module to compute the 'adjusted' fractional rank from any variable
*  v1.0.0, 2007-02-07, Philippe Van Kerm, module to compute the 'adjusted' fractional rank from any variable
* Alternative to -cumul, gen(p)- when one wants to compute normalized ranks for later usage (e.g. for S-gini or
* concentration coefficient estimation). Adjusted fractional ranks ensure that the average fractional 
* rank is equal to 0.5 and is independent on sort order (all tied values end up with the same rank (averaged)).
program define fracrank , rclass sortpreserve 
  version 8.2
  syntax varname(ts) [if] [in]  [fweight aweight pweight iweight]  , Generate(string) [OLDalgo]
  if ("`generate'"!="") {
    _my_parse_genvar generate `generate'
    if (`:word count `generate'' != 1 ) {
      di as error "option generate() invalid"
      exit 198	
    }
  } 
  loc w "`weight'`exp'"
  marksample touse
  gettoken eq wexp : exp , parse(=)
  if ("`wexp'"=="") loc wexp 1

  // normalize weights to 1
  if ("`weight'"!="") {
    tempvar ww
    qui gen double `ww' = `wexp' if `touse'
    qui su `ww'  if `touse' , meanonly 
    qui replace `ww' = `ww'/r(mean)
    loc wexp `ww'
  }
 
  quietly {
    if ("`oldalgo'"=="") {
		/* FASTER ALTERNATIVE: */
		tempvar wvar svar cusum
		gen double `wvar' = `wexp'  if `touse'  // it needs a variable
		gen double `svar' = `varlist' if `touse'  
		sort `touse' `svar' `wvar'
		gen double `cusum' = sum(`wvar'*`touse') if `touse' 
		loc N = `cusum'[_N]
		by `touse' `svar' : gen double `generate' = 0.5 * (`cusum'[_N] + `cusum'[1] - `wvar'[1])/`N'  if `touse'
    }
	else {
		/* OLDER ALGO: */
		if (inlist("`weight'","pweight","iweight")) {
			di as error "oldalgo is not compatible with pweight or iweight" 
			exit 198
		}
		tempvar svar padj sumw sumwp
		qui gen double `svar' = `varlist' if `touse'  // to deal with ts operators not allowed by cumul
		// 0. get raw cumulative rank
		cumul `svar' [`w'] if `touse' , gen(`generate') 
		// 1. use 'adjusted ranks' padj[i] = sum(w[1]::w[i]) - w[i]/2 
		// to ensure that expected adjusted rank = 0.5
		sort `generate'
		gen `padj' = max(0,`generate'[_n-1]) + ( (( `generate' - max(0,`generate'[_n-1]))/2 ) )  if `touse'
		// 2. take average padj within all tied values of sortvar (relevant for use with concentration indices)
		gen `sumw' = .
		gen `sumwp' = .
		bys `svar' `touse' : replace `sumw' = sum(`wexp') if `touse'
		bys `svar' `touse' : replace `sumwp' = sum(`wexp'*`padj') if `touse'
		bys `svar' `touse' : replace `generate' = `sumwp'[_N]/`sumw'[_N] if `touse'
	}
  }
end


program define _my_parse_genvar
    version 8.2
    gettoken locname 0 : 0
    gettoken genvar genopts : 0 , parse(",")
    gettoken  comma genopts : genopts  , parse(",")
    if (trim("`genopts'")=="")  confirm new variable `genvar'
    else {
      if (trim("`genopts'")=="replace") cap drop `genvar'
      else {
        di as error "`0'  invalid"
        exit 198
      }
    }
    c_local `locname' "`genvar'"
end

exit