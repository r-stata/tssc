*! Version 1.0
*! Chris Nelson 16/May/2008

program strsrcs_mlo
	version 9.0
	args lnf xb s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12
	tempvar ht st  st0
	local p: word count $ML_y
	local q=`p'-1
	local del_entry = 0
	qui summ _t0 , meanonly
	if r(max)>0 local del_entry = 1
	forvalues i = 1/`q' ///
	{
		local ds "`ds' `s`i'' * _d${ML_y`i'}"                      
		if `i' != `q' local ds "`ds' + "
		local sp "`sp' `s`i'' *	${ML_y`i'}"
		if `i' != `q' local sp "`sp' + "
		local sp0 "`sp0' `s`i'' * _s0${ML_y`i'}"
		if `i' != `q' local sp0 "`sp0' + "
	}
	quietly generate double	`st'=1/(1+exp(`sp' + `xb'))
	quietly generate double `ht'=${ML_y`p'} + (1/_t)*(`ds')*exp(`sp' + `xb')*(1/(1+exp(`sp' + `xb')))
	qui replace `lnf' = _d*ln(`ht')+ln(`st')
	if `del_entry' == 1 ///
	{
		quietly generate double `st0' = 1/(1+exp(`sp0' + `xb')) if _t0>0
		qui replace `lnf' = `lnf' - ln(`st0') if _t0>0
	}
end
	
