version 12.0
program define mict_model_initial
mi impute mlogit _mct_state i._mct_next            , add(1) force augment iterate(40)
end
