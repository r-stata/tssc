program stpm2_ml_lf_log
	version 11.0
	args lnf xb dxb xb0
	tempvar ht st st0 

	local del_entry = 0
	qui summ _t0 , meanonly
	if r(max)>0 local del_entry = 1

	qui replace `lnf' = _d*(ln(`dxb') + `xb' - ln(1-exp(`xb'))) + ln(1-exp(`xb'))

	if `del_entry' == 1 {
		qui replace `lnf' = `lnf' - ln(1-exp(`xb0')) if _t0>0
	}
end

