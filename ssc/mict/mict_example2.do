// More complex example, defining more realistic imputation models

// Define models where prior and next state have a time-dependent effect
// However, allow fallback to a simpler model in the case of non convergence
capture program drop mict_model_gap
program define mict_model_gap
di "Attempt first gap model"
capture mi impute mlogit _mct_state i._mct_next##c._mct_t i._mct_last##c._mct_t, add(1) force augment iterate(40)
if (_rc==430) {
  di as error "NO CONVERGENCE, fitting simplest gap model"
  mi impute mlogit _mct_state i._mct_next i._mct_last, add(1) force augment
}
else if _rc {
  exit _rc
}
end

capture program drop mict_model_initial
program define mict_model_initial
capture mi impute mlogit _mct_state i._mct_next##c._mct_t, add(1) force augment iterate(40)
if (_rc==430) {
  di as error "NO CONVERGENCE, fitting simplest gap model"
  mi impute mlogit _mct_state i._mct_next, add(1) force augment
}
else if _rc {
  exit _rc
}
end

capture program drop mict_model_terminal
program define mict_model_terminal
capture mi impute mlogit _mct_state i._mct_last##c._mct_t, add(1) force augment iterate(40)
if (_rc==430) {
  di as error "NO CONVERGENCE, fitting simplest gap model"
  mi impute mlogit _mct_state i._mct_last, add(1) force augment
}
else if _rc {
  exit _rc
}
end

use mvadmar
mict_prep state, id(id)
mict_impute, nimp(10)

save mict_example2, replace
