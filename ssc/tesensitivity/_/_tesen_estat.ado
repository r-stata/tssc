program define _tesen_estat

        if "`e(cmd)'" != "tesensitivity" {
                di as err "tesensitivity estimation " ///
                 "results not found"
                exit 301
        }
        gettoken sub rest: 0, parse(" ,")
        local lsub = length("`sub'")

        if "`sub'" == "vce" {
                estat_default `0'
        }
        else if "`sub'" == bsubstr("summarize",1,max(2,`lsub')) {
                _tesensitivity_estat_summarize `rest'
        }
        else {
                di as err "{bf:estat `sub'} is not allowed"
                exit 321
        }
end

program define _tesensitivity_estat_summarize
        syntax [ varlist(numeric fv default=none) ] , [ * ]
		
		// load the variables used in estimation
		local 0 `e(cmdline)'
		gettoken 0 : 0, parse(",")
		syntax anything [if] [in]
		
		// parse model specification
		_parse expand eqn op: anything
		gettoken ovar omvarlist : eqn_1
		gettoken tvar tmvarlist : eqn_2
					
		estat_default summarize `ovar' `tvar' `omvarlist'

end

