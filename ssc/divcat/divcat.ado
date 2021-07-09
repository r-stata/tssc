*! version 1.3.1  21january2015  Dirk Enzmann
cap program drop divcat
program define divcat, byable(onecall) sortpreserve rclass
version 11.2

  syntax varname [if] [in] [fweight aweight iweight] /*
		*/ [, Tableout Base(string) noLabel Gv Entropy Rq noDetail /*
		*/ gen_gv(string) gen_ngv(string) gen_h(string) gen_nh(string) gen_rq(string) replace ]
  marksample touse, nov
  tempname ftab n tot k dmat0 dmat GV NGV H NH RQ dmatgv dmatent dmatrq
  tempvar grcons cases group categs div_gv div_ngv div_h div_nh div_rq

  qui ds `varlist', has(type string)
  if "`r(varlist)'" != "" qui replace `touse' = 0 if `varlist'==""
  else qui replace `touse' = 0 if missing(`varlist')

		sca `n' = .
		sca `tot' = 0
		sca `k' = .
  sca `GV' = .
		sca `NGV' = .
		sca `H' = .
		sca `NH' = .
		sca `RQ' = .

  if "`label'"=="" local label = "label"
  if "`label'"=="nolabel" {
    local nby : word count `_byvars'
    forvalues byn = 1/`nby' {
       local byvar`byn' : word `byn' of `_byvars'
       local bylab`byn' : value label `byvar`byn''
       label values `byvar`byn'' .
    }
  }
  qui egen `group' = group(`_byvars') if `touse', miss label
  if "`label'"=="nolabel" {
    forvalues byn = 1/`nby' {
       label values `byvar`byn'' `bylab`byn''
    }
  }
		qui gen `cases' = .
		qui gen `categs' = .
		qui gen `div_gv' = .
		qui gen `div_ngv' = .
		qui gen `div_h' = .
		qui gen `div_nh' = .
		qui gen `div_rq' = .

  if "`replace'"=="replace" {
		  if "`gen_gv'" != "" {
      cap confirm new variable `gen_gv'
      if _rc!=0 capture drop `gen_gv'
    }
		  if "`gen_ngv'" != "" {
      cap confirm new variable `gen_ngv'
      if _rc!=0 capture drop `gen_ngv'
    }
		  if "`gen_h'" != "" {
      cap confirm new variable `gen_h'
      if _rc!=0 capture drop `gen_h'
    }
		  if "`gen_nh'" != "" {
      cap confirm new variable `gen_nh'
      if _rc!=0 capture drop `gen_nh'
    }
		  if "`gen_rq'" != "" {
      cap confirm new variable `gen_rq'
      if _rc!=0 capture drop `gen_rq'
    }
		}
  if "`gen_gv'" != "" {
    confirm new variable `gen_gv'
    qui gen `gen_gv' = .
  }
  if "`gen_ngv'" != "" {
    confirm new variable `gen_ngv'
    qui gen `gen_ngv' = .
  }
  if "`gen_h'" != "" {
    confirm new variable `gen_h'
    qui gen `gen_h' = .
  }
  if "`gen_nh'" != "" {
    confirm new variable `gen_nh'
    qui gen `gen_nh' = .
  }
  if "`gen_rq'" != "" {
    confirm new variable `gen_rq'
    qui gen `gen_rq' = .
  }

  qui tab `group' if `touse', mi
		local ng = r(r)
		matrix `dmat0' = J(1,7,.)
  matrix coln `dmat0' = "categs" "GV" "NGV" "H" "NH" "RQ" "n"
  if "`_byvars'"=="" matrix rown `dmat0' = `""(total sample)""'
  qui levelsof `group' if `touse', miss local(Gr_K)
		local mrow = 0
  local rspec = "--"

foreach gr_k of local Gr_K {
  local mrow = `mrow' + 1
  if ("`tableout'"=="") {
		  qui ta `varlist' if `touse' & `group'==`gr_k' [`weight' `exp'], matcell(`ftab')
		}
  else {
		  if ("`_byvars'" == "") {
		    ta `varlist' if `touse' & `group'==`gr_k' [`weight' `exp'], matcell(`ftab')
				}
				else {
    		local gr_lab : label `group' `mrow'
						di _n as text "by `_byvars' = `gr_lab':"
		    ta `varlist' if `touse' & `group'==`gr_k' [`weight' `exp'], matcell(`ftab')
				}
  }
		if ("`gv'"=="") & ("`entropy'"=="") & ("`rq'"=="") & ("`detail'"!="nodetail") ///
		   local detail="detail"
		if "`base'"=="" local base = "2"
  sca `k' = r(r)
		sca `n' = r(N)
  sca `tot' = `tot' + `n'
  mata: divsump()
		sca `GV' = 1-`GV'
		sca `NGV' = `GV'/(1-1/`k')
		if ("`base'"=="2") {
		  sca `H' = -`H'/ln(2)
    sca `NH' = `H'/(ln(`k')/ln(2))
		}
		else if ("`base'"=="10") {
		  sca `H' = -`H'/ln(10)
    sca `NH' = `H'/(ln(`k')/ln(10))
		}
		else if ("`base'"=="e") {
		  sca `H' = -`H'
    sca `NH' = `H'/ln(`k')
		}
		else {
    di as err "no valid specification of option {bf:base}"
    exit 498
		}
		sca `RQ' = 1-`RQ'
		if (`mrow' < `ng') local rspec = "`rspec'&"
		else local rspec = "`rspec'-"
 	local gr_lab : label `group' `mrow'
 	local locl : length loc gr_lab
 	if (`locl' > 32) local gr_lab : piece 1 32 of `"`gr_lab'"'
 	if "`gr_lab'" == "" local gr_lab = "."

		matrix `dmat0'[1,1] = `k'
		matrix `dmat0'[1,2] = `GV'
		matrix `dmat0'[1,3] = `NGV'
		matrix `dmat0'[1,4] = `H'
		matrix `dmat0'[1,5] = `NH'
		matrix `dmat0'[1,6] = `RQ'
		matrix `dmat0'[1,7] = `n'
		if "`_byvars'"!="" matrix rown `dmat0' = `""`gr_lab'""'
		if (`mrow'==1) matrix `dmat' = `dmat0'
		else matrix `dmat' = (`dmat' \ `dmat0')

		qui replace `cases' = `n' if `touse' & `group'==`gr_k'
		qui replace `categs' = `k' if `touse' & `group'==`gr_k'
		qui replace `div_gv' = `GV' if `touse' & `group'==`gr_k'
		qui replace `div_ngv' = `NGV' if `touse' & `group'==`gr_k'
		qui replace `div_h' = `H' if `touse' & `group'==`gr_k'
		qui replace `div_nh' = `NH' if `touse' & `group'==`gr_k'

  if "`gen_gv'" != "" {
    qui replace `gen_gv' = `GV' if `touse' & `group'==`gr_k'
  }
  if "`gen_ngv'" != "" {
    qui replace `gen_ngv' = `NGV' if `touse' & `group'==`gr_k'
  }
  if "`gen_h'" != "" {
    qui replace `gen_h' = `H' if `touse' & `group'==`gr_k'
  }
  if "`gen_nh'" != "" {
    qui replace `gen_nh' = `NH' if `touse' & `group'==`gr_k'
  }
  if "`gen_rq'" != "" {
    qui replace `gen_rq' = `RQ' if `touse' & `group'==`gr_k'
  }
}

		local c0length : label `group' maxlength
  local c0length = min(32,`c0length')
		local c0length = max(16,`c0length')
		if "`_byvars'" == "" local titleby = ""
		else local titleby = " by `_byvars'"
  if "`base'"=="e" local basetxt = "{it:e}"
		else local basetxt = "`base'"

  if "`detail'"=="detail" {
    matlist `dmat', title("Measures of Diversity `titleby'") ///
				  cspec(& %`c0length's| %6.0f & %6.3f & %6.3f & %6.3f & %6.3f & %6.3f & %6.0f &) ///
						rspec(`rspec')
 	  di as text "{it:Note:} Entropy (H) is calculated using the logarithm to base `basetxt'"
  }
		else {
				if ("`gv'"=="gv") {
				  if ("`_byvars'"=="") matrix `dmatgv' = (`dmat'[1,1..3],`dmat'[1,7])
						else matrix `dmatgv' = (`dmat'[1...,1..3],`dmat'[1...,7])
      matlist `dmatgv', title("Measures of Diversity (Generalized Variance) `titleby'") ///
				    cspec(& %`c0length's| %6.0f & %6.3f & %6.3f & %6.0f &) ///
						 	rspec(`rspec')
				}
				if ("`entropy'"=="entropy") {
				  if ("`_byvars'"=="") {
  						matrix `dmatent' = (`dmat'[1,1],`dmat'[1,4..5],`dmat'[1,7])
								matrix rown `dmatent' = `""(total sample)""'
						}
				  else matrix `dmatent' = (`dmat'[1...,1],`dmat'[1...,4..5],`dmat'[1...,7])
      matlist `dmatent', title("Measures of Diversity (Entropy) `titleby'") ///
				    cspec(& %`c0length's| %6.0f & %6.3f & %6.3f & %6.0f &) ///
						 	rspec(`rspec')
				  di as text "{it:Note:} Entropy (H) is calculated using the logarithm to base `basetxt'"
				}
				if ("`rq'"=="rq") {
				  if ("`_byvars'"=="") {
  						matrix `dmatrq' = (`dmat'[1,1],`dmat'[1,6..7])
								matrix rown `dmatrq' = `""(total sample)""'
						}
				  else matrix `dmatrq' = (`dmat'[1...,1],`dmat'[1...,6..7])
      matlist `dmatrq', title("Measures of Diversity (Polarization) `titleby'") ///
				    cspec(& %`c0length's| %6.0f & %6.3f & %6.0f &) ///
						 	rspec(`rspec')
 			}
		}
  return scalar RQ = `RQ'
		return scalar NH = `NH'
  return scalar H = `H'
  return scalar NGV = `NGV'
  return scalar GV = `GV'
  return scalar N = `n'
		return scalar categs = `k'
  return scalar bygroups = `mrow'
  return scalar N_total = `tot'
		return local wgt "`weight'`exp'"
		return local base "`base'"
		return local by "`_byvars'"
		return matrix div = `dmat'
end
