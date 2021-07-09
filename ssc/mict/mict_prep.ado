// Program mictprep
// Prepares a categorical time-series file (in long format, ID T STATE) for mict_gen_impute.ado
// Copyright Brendan Halpin 2015 (brendan.halpin@ul.ie)
version 12.0

program define mict_prep
syntax namelist (min=1), ID(varname)

di "Preparing data for mict_impute"
local statevar : word 1 of `namelist'
di "State variable: `statevar'; ID variable `id'"

reshape long `namelist', i(`id') j(_mct_t)


qui {
  char _dta[statevar] `statevar'
  char _dta[idvar] `id'
  rename `statevar' _mct_state 
  rename `id' _mct_id
  
  qui su _mct_state
  local nstates `r(max)'

  // Spell sequence number: index number of consecutive spells in
  // the same state within the individual trajectory
  gen _mct_spno = 1
  sort _mct_id _mct_t
  by _mct_id: replace _mct_spno = _mct_spno[_n-1] + (_mct_state!=_mct_state[_n-1]) if _n>1
  sort _mct_id _mct_spno _mct_t

  // Total number of spells per individual
  by _mct_id: egen _mct_nspells = max(_mct_spno)

  // Calculate gap length and maximum gap length
  gen _mct_lg = 0
  by _mct_id _mct_spno: replace _mct_lg = _N if missing(_mct_state)
  by _mct_id: egen _mct_mlg = max(_mct_lg)

  // count months within spells: this is needed to identify which
  // missing months to impute
  gen _mct_tw=1
  by _mct_id _mct_spno: replace _mct_tw = _mct_tw[_n-1] + (_mct_state==_mct_state[_n-1]) if _n>1


  // identify gaps at beginning or end
  by _mct_id: gen _mct_initgap = missing(_mct_state[1])
  by _mct_id: gen _mct_termgap = missing(_mct_state[_N])

  gen _mct_igapspell = _mct_initgap & _mct_spno==1
  gen _mct_tgapspell = _mct_termgap & _mct_spno==_mct_nspells

  gen _mct_igl = 0
  by _mct_id _mct_spno: replace _mct_igl = _N if _mct_igapspell
  gen _mct_tgl = 0
  by _mct_id _mct_spno: replace _mct_tgl = _N if _mct_tgapspell


  sort _mct_id _mct_t

  // Prior and subsequent cumulated duration
  // Note that where state is missing the variable has valid values
  // depending on what went beofre
  forvalues i=1/`nstates' {
    tempvar tb`i'
    by _mct_id: gen `tb`i''=_mct_state[1]==`i'
    by _mct_id: replace `tb`i'' = `tb`i''[_n-1] + (_mct_state==`i') if _n>1
  }
  // Map between a count of months to a proportion of time

  // reverse-sort to look to the future
  gsort _mct_id -_mct_t

  forvalues i=1/`nstates' {
    tempvar ta`i'
    by _mct_id: gen `ta`i''=_mct_state[1]==`i'
    by _mct_id: replace `ta`i'' = `ta`i''[_n-1] + (_mct_state==`i') if _n>1
  }

  sort _mct_id _mct_t

  tempvar tatot tbtot
  gen `tatot'=0
  gen `tbtot'=0
  forvalues i=1/`nstates' {
    replace `tatot' = `tatot' + `ta`i''
    replace `tbtot' = `tbtot' + `tb`i''
  }

  forvalues i=1/`nstates' {
    gen _mct_before`i' = `tb`i''/`tbtot'
    gen _mct_after`i' = `ta`i''/`tatot'
  }

  // Drop unnecessary variables
  drop _mct_spno _mct_nspells _mct_mlg _mct_igapspell _mct_tgapspell 
}
end
