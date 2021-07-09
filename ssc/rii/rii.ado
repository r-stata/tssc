*! rii Version 1.0.1 dan_blanchette@unc.edu 09Oct2009
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
* - made -rii- Stata 11 compatible
*  rii Version 1.0.0 dan.blanchette@duke.edu  27Apr2009
/**************************************************************************
This program is based on the paper:
Montalto, Catherine Phillips & Sung, Jaimie. (1996). Multiple imputation in the 1992 
Survey of Consumer Finances.  Financial Counseling and Planning, Vol. 7, pp. 133-46.

Tested on commands: probit, tobit, cnreg, and regress
**************************************************************************/
program rii, eclass 
version 9.2
local version : di "version " string(_caller()) ":"
capture _on_colon_parse `0'
if c(rc) | `"`s(after)'"' == "" {
  if !c(rc) {
    local 0 `"`s(before)'"'
  }
  if replay() {
    if "`e(prefix)'" != "rii" {
      error 301  // last estimates not found error message
      // error command exits
    }
    else {
      // just re-display e()
      estimates replay
      exit
    }
  }
}

Rii `0'
end

program Rii, eclass
version 9.2

local cmdline `"rii `0'"'
capture _on_colon_parse `0'

// reset 0 before -syntax- so that options of the command submitted to -rii- don't create an invalid option message
local 0 `"`s(before)'"'

syntax [if] [in] , IMPvar(varname numeric) [ r_test their_var ]

local command `"`s(after)'"'
tokenize `"`command'"'
local cmd `1'
//unabreviate command
unabcmd `cmd'
local cmd "`r(cmd)'"
if ! inlist("`cmd'","probit","tobit","cnreg","regress") {
  if "`cmd'" == "dprobit" {
    di as err "{help dprobit:dprobit} cannot be used. Try {help probit:probit} instead"
  }
  else {
    di as err "This program has never been tested on the command {help `cmd':`cmd'}.  BE WARNED!!"
  }
}  

//remove `cmd' from `command'
local R_esample : subinstr local command `"`cmd'"' " " 
// extract the if and in from `command'
R_esample `R_esample'
if `"`r(if)'"' != "" | `"`r(in)'"' != "" {
  di as err "options {cmd:if} and {cmd:in} are not allowed in the command submitted to {help rii:rii}" 
  di as err "since {help rii:rii} subsets the data for each value of the {cmd:imp_var}"
  di as err "{help rii:rii} has {cmd:if} and {cmd:in} options "
  exit 198
}


tempname imp_row
//`impvar' can be any value since the forval loop process the values of the `imp_row' matrix
quietly tabulate `impvar', matrow(`imp_row')
//number of imputations
local imps = r(r)
// perform the relevant statistical calculation...
quietly {
  local nobs = 0
  tempname imp_mat
  local colnames 
  forval imp_rv = 1/`imps' {
    preserve
    if `"`if'"' != "" | `"`in'"' != "" {
      keep `if' `in'
    }

    keep if `impvar' == `imp_row'[`imp_rv',1]
    //run command submitted to -rii-
    `command'
    restore

    if `imp_rv' == 1  {
      matrix `imp_mat'_N = J(1,`imps',.)
      matrix rownames `imp_mat'_N = N
      local depvar = "`e(depvar)'"
    }
    if !missing(`"`e(version)'"') {
      local ereturn_version = `e(version)'
    }
    matrix `imp_mat'_b`imp_rv' = e(b)
    matrix `imp_mat'_V`imp_rv' = e(V)
    matrix `imp_mat'_N[1,`imp_rv'] = `e(N)'
    local nobs = `nobs' + `e(N)'
    // put double quotes around column names since a name will be like: imputation=3
    local colnames `"`colnames' "`impvar'=`=`imp_row'[`imp_rv',1]'" "'

  }  // end of forval 
  matrix colnames `imp_mat'_N = `colnames'

  //construct a missing() out of all vars used in `cmd' 
  // extract the varlist and possible if, in, and weight var from `command'
  R_esample `R_esample'
  local esample_missing
  local count = 0
  foreach var of varlist `impvar' `r(varlist)' `r(weight)' {
    local count = `count' + 1
    if `count' == 1 {
      local esample_missing `"`var'"'
    }
    else {
      local esample_missing `"`esample_missing',`var'"'
    }
  }
  tempvar esample
  quietly gen `esample' = 0 
  if `"`if'"' != "" | `"`in'"' != "" {
    replace `esample' = 1 `if' `in'
    replace `esample' = 0 if missing(`esample_missing') 
  }
  else {
    replace `esample' = 1 
    replace `esample' = 0 if missing(`esample_missing') 
  }
} // end quietly 

// Equation 1 and 2 
// create average for estimates and variances
forval imp_rv=1/`imps' {
  if `imp_rv' == 1  {
    matrix `imp_mat'_b_avg = `imp_mat'_b1
    matrix `imp_mat'_V_avg = `imp_mat'_V1
  }
  else {
    matrix `imp_mat'_b_avg = `imp_mat'_b_avg + `imp_mat'_b`imp_rv'
    matrix `imp_mat'_V_avg = `imp_mat'_V_avg + `imp_mat'_V`imp_rv'
  }
  matrix drop `imp_mat'_V`imp_rv'  
} // end of forval
// End of Equation 1
matrix `imp_mat'_b_avg = `imp_mat'_b_avg / `imps'
// End of Equation 2
matrix `imp_mat'_V_avg = `imp_mat'_V_avg / `imps'


//subtract estimate average 
forval imp_rv=1/`imps' {
  //create one matrix per imputation
  matrix `imp_mat'_bm`imp_rv' = `imp_mat'_b`imp_rv' - `imp_mat'_b_avg 
  matrix drop `imp_mat'_b`imp_rv'
} // end of forval


// Equation 3
// now square the bm matrices
forval imp_rv=1/`imps' {
  matrix `imp_mat'_bm`imp_rv' = `imp_mat'_bm`imp_rv'' * `imp_mat'_bm`imp_rv' 
  // now sum them up
  if `imp_rv' == 1 {  
    matrix `imp_mat'_bm = `imp_mat'_bm`imp_rv'
  }
  else {
    matrix `imp_mat'_bm = `imp_mat'_bm + `imp_mat'_bm`imp_rv'
  }
  matrix drop `imp_mat'_bm`imp_rv'
}

// divide it by: (m-1)
matrix `imp_mat'_bm = `imp_mat'_bm / (`imps' - 1) 

// Equation 4
// multiply it by: 1 + (1/m)
matrix `imp_mat'_tm = `imp_mat'_bm * (1 + 1/`imps')

matrix `imp_mat'_tm = `imp_mat'_V_avg + `imp_mat'_tm  

matrix drop `imp_mat'_V_avg

ereturn post `imp_mat'_b_avg `imp_mat'_tm , obs(`nobs') esample(`esample')
ereturn matrix obs_per_imp `imp_mat'_N
ereturn local cmd "`cmd'"
ereturn local cmdname "`cmd'"
if !missing(`"`ereturn_version'"') {
  ereturn scalar version = `ereturn_version'
}
ereturn local cmdline `"`cmdline'"'
ereturn local command "`command'"
ereturn local prefix "rii"
ereturn local depvar "`depvar'"
ereturn scalar N_imps = `imps'


/*************************
   ereturn notes:
     ereturn post mat1  // creates e(b) by moving mat1 to e(b) (no copy option)
     ereturn post mat1 mat2 //  creates e(b) e(V) by moving mat1 to e(b) and mat2 to e(V) (no copy option)
                            //   the e(V) matrix has to be symetrical or you get "conformability" error message
     ereturn matrix some_name mat1  // creates e(some_name) by moving mat1 to e(some_name)
     ereturn matrix some_name mat1, copy  // creates e(some_name) by copying mat1 to e(some_name)
     ereturn repost b=mat1  //  replaces e(b) by moving mat1 to e(b) (no copy option)
     ereturn repost V=mat2  //  replaces e(V) by moving mat2 to e(V) (no copy option) 
                            //   but not possible after -reg- and some other commands (noted on Statalist)
     // repost requires that the matrices be the same size as the one that is being replaced.
 
*************************/

estimates replay
end 


program R_esample, rclass
version 9.2
syntax varlist [fweight pweight iweight/] [if] [in] [, *]
return local varlist `"`varlist'"'
return local if `"`if'"'
return local in `"`in'"'

capture confirm var `exp'

if _rc == 0 {
  return local weight `"`exp'"'
}
end
