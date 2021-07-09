*! version 1.0.2  05aug2010
program define spreg, eclass
	version 11.1
	
	if replay() {
		if `"`e(cmd)'"' != "spreg" {
			error 301
		}
		Replay `0'
		exit
	}
	Estimate `0'
	
	ereturn local cmdline `"spreg `0'"'

end

program define Estimate, eclass
	version 11.1
	
	gettoken method 0 : 0
	
	syntax varlist(numeric) [if] [in] [,		///
		id(varname numeric) HETeroskedastic * ]
	
	if "`method'" == "ml" {
		
		if "`heteroskedastic'" != "" {
			di "{err}option {inp}heteroskedastic {err}not "	///
				"allowed with {inp}ml {err}estimator"
			exit 198
		}
		
		cap noi _spreg_ml `0'
		local rc = c(rc)
		
		// drop tempnames used by Mata
		foreach m of local matanames {
			cap mata: mata drop `m'
		}
		
		if `rc' exit `rc'
	}
	else if "`method'" == "gs2sls" {
		// _spreg_gs2sls calls spivreg, which drops tempnames
		_spreg_gs2sls `0'
	}
	else {
		di "{err}estimator {cmd:`method'} invalid"
		exit 498
	}
	
end

program define Replay
	version 11.1
	
	syntax [, * ]
	
	_get_diopts diopts, `options'
	
	_coef_table_header
	_coef_table, `options'
	
end

exit
