*! 1.0.0 NJC 8 November 2012 
program nnipolate, byable(onecall) sort
	version 8.2  
	syntax varlist(min=2 max=2) [if] [in], /// 
	Generate(string) [ BY(varlist) ties(str) ]
	
	if _by() {
		if "`by'" != "" {
			di as err /*
			*/ "option by() may not be combined with by prefix"
			exit 190
		}
		local by "`_byvars'"
	}

	* indulge upper case, any abbreviations of next, previous, minimum, maximum 
	if "`ties'" != "" { 
		local ties = lower("`ties'") 
		local nchar = length("`ties'") 
		local OK = 0 

		if "`ties'" == substr("next", 1, `nchar') { 
			local ties "next" 
			local OK 1 
		} 
		else if "`ties'" == substr("previous", 1, `nchar') { 
			local ties "prev" 
			local OK 1 
		}
		else if `nchar' == 1 & "`ties'" == "m" { 
			di as err "m ambiguous for ties() option" 
			exit 198
		}
		else if "`ties'" == substr("minimum", 1, `nchar') { 
			local ties "min" 
			local OK 1 
		}
		else if "`ties'" == substr("maximum", 1, `nchar') { 
			local ties "max" 
			local OK 1 
		}

		if !`OK' { 
			di as err "invalid ties() option: see help" 
			exit 198 
		}
	} 

	confirm new var `generate'
	tokenize `varlist'
	args usery x 
	tempvar touse negx prevy prevx nexty nextx y z 
	
	quietly {
		mark `touse' `if' `in'
		replace `touse' = 0 if missing(`x') 
		count if `touse' 
		if r(N) == 0 error 2000 
	
		* average y when different y for same x 	
		bysort `touse' `by' `x': gen `y' = sum(`usery') / sum(`usery' < .) 
		by `touse' `by' `x': replace `y' = `y'[_N]
		
		* previous values 
		gen `prevy' = `y' if `touse' & `y' < .   
		gen `prevx' = `x' if `touse' & `y' < . 
		gen `nexty' = `prevy' 
		gen `nextx' = `prevx' 
		bysort `touse' `by' (`x'): replace `prevy' = `prevy'[_n - 1] if `prevy' == .  
		by `touse' `by': replace `prevx' = `prevx'[_n - 1] if `prevx' == .  

		* next values 
		gen `negx' = -`x'
		bysort `touse' `by' (`negx') : replace `nexty' = `nexty'[_n - 1] if `nexty' == .  
		by `touse' `by' : replace `nextx' = `nextx'[_n - 1] if `nextx' == . 
	
		* interpolation 
		gen `z' = `y' if `touse' 
		replace `z' = `nexty' if (`nextx' - `x') < (`x' - `prevx') & `z' == . & `touse' 
		replace `z' = `prevy' if (`x' - `prevx') < (`nextx' - `x') & `z' == . & `touse' 

		if "`ties'" != "" { 
			if "`ties'" == "next" { 
				replace `z' = `nexty' if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
			} 
			else if "`ties'" == "prev" {
				replace `z' = `prevy' if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
			}
			else if "`ties'" == "min" {
				replace `z' = min(`nexty', `prevy') if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
			}
			else if "`ties'" == "max" {
				replace `z' = max(`nexty', `prevy') if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
			}
		}
		else replace `z' = (`nexty' + `prevy')/2 if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
		
		rename `z' `generate'
		count if `generate' == .
	}
	
	if r(N) > 0 {
		if r(N) != 1 local pl "s" 
		di as txt "(" r(N) `" missing value`pl' generated)"'
	}
end

