*! 1.0.2 MLB 31 Jul 2007 by default not returning dropped variables and added dropped option
*! 1.0.1 MLB 23 Apr 2007 added the local and constant option
*! 1.0.0 MLB 18 Apr 2007
program define indeplist, rclass
	version 7
	syntax [, EQuation(string asis) LOcal CONStant DROPped]
	capture confirm matrix e(b)
	if _rc == 111 {
		di as error "Matrix e(b) not found."
		di as error "Indeplist requires that the active estimation command"
		di as error "stores its estimates in e(b)."
		exit 198
	}
	tempname b
	local eqns : coleq e(b), quoted
	local eqns : list uniq eqns
	local k : word count `eqns'
	
	if `"`equation'"' != "" {
		local ok : list equation in eqns
		if !`ok' {
			di as error `"Equation `equation' not found in e(b)."'
			exit 198
		}
		
		foreach eq of local equation {
			matrix `b' = e(b)
			matrix `b' = `b'[1,"`eq':"]
			local eqname: subinstr local eq " " "", all
			local names : colnames `b'
			if "`constant'" == "" {
				local cons "_cons"
				local names : list names - cons
			}
			if "`dropped'" == "" {
				local dropped ""
				foreach var of local names {
					if _b[`var'] == 0 & _se[`var'] == 0 {
						local dropped "`dropped'`var' "
					}
				}
				local dropped : list retokenize dropped
				if "`dropped'" != "" {
					local names : list names - dropped
				}
			}
			if "`names'" != "" {
				if `k' > 1 {
					di as txt "Independent variables in equation `eq': " as result "`names'"
					return local X`eqname' "`names'"
					if "`local'" != ""{
						c_local X`eqname' `"`names'"'
						local locnames "`locnames' X`eqname'"
					}
				}
				else {
					di as txt "Independent variables: " as result "`names'"
					return local X "`names'"
					if "`local'" != "" {
						c_local X `"`names'"'
						local locnames "`locnames' X"
					}
				}
			}
		}
	}		
	else {
		foreach eq of local eqns {
			matrix `b' = e(b)
			matrix `b' = `b'[1,"`eq':"]
			local eqname: subinstr local eq " " "", all
			local names : colnames `b'
			if "`constant'" == "" {
				local cons "_cons"
				local names : list names - cons
			}
			if "`dropped'" == "" {
				local dropped ""
				foreach var of local names {
					if _b[`var'] == 0 & _se[`var'] == 0 {
						local dropped "`dropped'`var' "
					}
				}
				local dropped : list retokenize dropped
				if "`dropped'" != "" {
					local names : list names - dropped
				}
			}
			if "`names'" != "" {
				if `k' > 1 {
					di as txt "Independent variables in equation `eq': " as result "`names'"
					return local X`eqname' "`names'"
					if "`local'" != "" {
						c_local X`eqname' `"`names'"' 
						local locnames "`locnames' X`eqname'"
					}
				}
				else {
					di as txt "Independent variables: " as result "`names'"
					return local X "`names'"
					if "`local'" != "" {
						c_local X `"`names'"'
						local locnames "`locnames' X"
					}
				}
			}
		}
	}
	if "`local'" != "" {
		local locnames : list retokenize locnames
		c_local locnames `"`locnames'"'
	}
end
