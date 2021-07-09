// Apr 10 2015 10:02:45
// Based on mict_gen_impute.do
version 12.0

program define mict_impute
syntax, [MAXGap(integer 12) MAXITgap(integer 6) NIMP(integer 5) OFFset(integer 0)]

tempfile datafile

qui save `datafile'

// Main loop for multiple imputations
forvalues iter = 1/`nimp' {

  use `datafile', clear

  sort _mct_id _mct_t

  qui by _mct_id: su _mct_t
  local totlen `r(max)'

  qui gen _mct_last = .
  qui gen _mct_next = .
  
  // For internal gaps:
    forvalues i = 1/`maxgap' {
      sort _mct_id _mct_t // needed beccause MI affects sort status (but not sort order)
      timer clear 1
      timer on 1
      mict_do_imputations `i' `maxgap'
      timer off 1
      timer list 1
    }
  
  // For initial/terminal gaps:
    forvalues i = 1/`maxitgap' {
      sort _mct_id _mct_t
      timer clear 1
      timer on 1
      mict_do_imputations_it "i" `i' `maxitgap' `totlen'
      timer off 1
      timer list 1
      timer clear 1
      timer on 1
      sort _mct_id _mct_t
      mict_do_imputations_it "t" `i' `maxitgap' `totlen'
      timer off 1
      timer list 1
    }
  
  qui gen _mct_iter = `iter' + `offset'

  capture drop _mct_lg
  capture drop _mct_tw
  capture drop _mct_initgap
  capture drop _mct_termgap
  capture drop _mct_igl
  capture drop _mct_tgl
  capture drop _mct_before*
  capture drop _mct_after*
  capture drop _mct_last
  capture drop _mct_next
  capture drop mi_miss*
  capture drop _mct_n2
  capture drop _mct_l2
  capture drop _mct_state_*


  local statevarname : char _dta[statevar]
  rename _mct_state `statevarname'
  
  local idvarname : char _dta[idvar]
  rename _mct_id `idvarname'
  
  reshape wide `statevarname', i(`idvarname') j(_mct_t)
  
  tempfile mibo`iter'
  save `mibo`iter'',replace
}

// Now assemble the multiple imputations into a single file
use          `mibo1'
forvalues i = 2/`nimp' {
  append using `mibo`i''
}

sort `idvarname' _mct_iter

end
// End of main mict_impute definition


// /////////////////////////////////
// Supplementary program definition
// /////////////////////////////////

program define mict_do_imputations
args i maxgap

if mod(`i',2) == 1 {
  // i is odd: imputing at the end of the gap
  qui by _mct_id: replace _mct_last = _mct_state[_n - `maxgap' - 1 + `i']
  qui by _mct_id: replace _mct_next = _mct_state[_n + 1]
  local seqno = `maxgap' + 1 - int((`i'+1)/2)
}
else {
  // i is even: imputing at the start of the gap
  qui by _mct_id: replace _mct_last = _mct_state[_n - 1]
  qui by _mct_id: replace _mct_next = _mct_state[_n + `maxgap' +1 - `i']
  local seqno = int(`i'/2)
}

di "Imputing for seqno: `seqno'"
mi set wide
mi register imputed _mct_state


// Invoke the imputation models chain as a program defined in the calling file
mict_model_gap

// We can assign this imputation to the correct elements only
gen _mct_canassign = `seqno' - int((`maxgap' - _mct_lg)/2) == _mct_tw
// Test whether any imputations were made (if not _1__mct_state doesn't exist)
if ("`r(M_add)'"!="0") {
  di "Putting imputed values in place in internal gap"
  replace _mct_state = _1__mct_state if missing(_mct_state) & _mct_canassign
}
// drop irrelevant variables and unset mi status
drop _mct_canassign
capture drop _*__mct_state
capture drop _mct_state_*_

qui mi unset

end

// Predict initial and terminal gaps
program define mict_do_imputations_it
args it i maxitgap totlen

if ("`it'"=="i") {
local gaptype "initial"
}
if ("`it'"=="t") {
local gaptype "terminal"
}

di "replacing next and last"
qui by _mct_id: replace _mct_next = _mct_state[_n+1] if missing(_mct_next)
qui by _mct_id: replace _mct_last = _mct_state[_n-1] if missing(_mct_last)
capture drop _mct_n2 _mct_l2
qui recode _mct_next 3=2, generate(_mct_n2)
qui recode _mct_last 3=2, generate(_mct_l2)


di "Imputing for `gaptype' gap: `i'"

mi set wide
mi register imputed _mct_state

if ("`it'"=="i") {
mict_model_initial
}

if ("`it'"=="t") {
mict_model_terminal
}

di "Imputation done" 
// We can assign this imputation to the correct elements only
// Initial gap:  assign to state if t = _mct_igl+1-i
// Terminal gap: assign to state if t = totlen - _mct_tgl + i
if ("`it'"=="i") {
  gen _mct_canassign = _mct_t ==           _mct_igl + 1 - `i' & _mct_initgap & _mct_igl<=`maxitgap'
}
else if ("`it'"=="t") {
  gen _mct_canassign = _mct_t == `totlen' -_mct_tgl     + `i' & _mct_termgap & _mct_tgl<=`maxitgap'
}

// Test whether any imputations were made (if not _1__mct_state doesn't exist)
if ("`r(M_add)'"!="0") {
  di "Replacing missing state: `gaptype'"
  replace _mct_state = _1__mct_state if missing(_mct_state) & _mct_canassign
}
// drop irrelevant variables and unset mi status
drop _mct_canassign
capture drop _1__mct_state
capture drop _mct_state_*_
mi unset

di "Finished `gaptype'"
end
