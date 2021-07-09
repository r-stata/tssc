program define frameappend

	version 16.0

	syntax namelist(name=frame_name max=1) [, drop]

	** get lists of variables to be combined
	quietly ds
	local to_varlist "`r(varlist)'"

	quietly frame `frame_name': ds
	local from_varlist "`r(varlist)'"

	local shared_varlist : list from_varlist & to_varlist
	local new_varlist : list from_varlist - shared_varlist

	* get size of new dataframe
	frame `frame_name' : local from_N = _N
	local to_N = _N
	local from_start = `to_N' + 1
	local new_N = `to_N' + `from_N'

	qui set obs `new_N'
	qui gen _temp_n = _n
	frame `frame_name' {
		qui gen _temp_n = _n + `to_N'
	}

	qui frlink 1:1 _temp_n, frame(`frame_name')

	if "`shared_varlist'" != "" {
		qui frget `shared_varlist', from(`frame_name') prefix(_f_)

		foreach var of varlist `shared_varlist' {
			qui replace `var' = _f_`var' in `from_start' / `new_N'
			qui drop _f_`var'
		}
	}

	if "`new_varlist'" != "" {
		qui frget `new_varlist', from(`frame_name')
	}

	qui drop _temp_n
	frame `frame_name': drop _temp_n
	qui drop `frame_name'
	if "`drop'" == "drop" {
		qui frame drop `frame_name'
	}

end
