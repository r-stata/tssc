version 12.0
program define mict_model_terminal
mi impute mlogit _mct_state             i._mct_last, add(1) force augment iterate(40)
end
