*! 1.0.0 Ariel Linden 16June2014
*! code based on cquantile 1.0.0 01Nov2005 and qqplot 3.3.3 07Mar2005
program qqplot3, sort rclass
	version 13.0 
        
	capture syntax varlist(numeric min=2 max=2) [if] [in] [aw pw fw] ///
		, [ Generate(str asis) ]
	if _rc syntax varname(numeric) [if] [in] [aw pw fw] ///
		, BY(varname) [ Generate(str asis) ]

	capt which fixsort
	if _rc > 0 {
	di as err "`please download -fixsort- from SSC (ssc install fixsort)"
            exit 199 
	} 	
		
	if "`generate'" != "" {
	
	local nv : word count `generate' 
	if `nv' != 2 { 
		di as err "need two variable names in generate()" 
		exit 198 
	}       
	confirm new var `generate' 
	tokenize `generate' 
	args g1 g2 
	}
	
	marksample touse, novarlist 
	
	qui if "`by'" != "" { 
		tempname stub 
		tab `by' if `touse' 
		if r(r) != 2 { 
            di as err "`r(r)' groups found, 2 required"
            exit 420 
		}       
		separate `varlist' if `touse', ///
		gen(`stub') by(`by') shortlabel 
		local varlist "`r(varlist)'" 
	}       

	tokenize `varlist'
        
    quietly {
		count if `1' < . & `touse' 
		local cntx = r(N) 
		ret scalar cnt1 = `cntx'
		count if `2' < . & `touse' 
        local cnty = r(N)
		ret scalar cnt2 = `cnty'
		if `cntx' == 0 | `cnty' == 0 error 2000
	}

	if `cnty' >= `cntx' {
		local NQ = `cntx' + 1
	}
	else {
		local NQ = `cnty' + 1
	}
	ret scalar nq = `NQ'

	if "`generate'" != "" tempvar temp1 temp2
	else tempvar temp1 temp2 g1 g2 

	pctile `temp1' = `1' [`weight' `exp']  if `touse', nq(`NQ')
	pctile `temp2' = `2' [`weight' `exp'] if `touse', nq(`NQ') 
	
	fixsort `temp1' `temp2', gen(`g1' `g2')  

	_crcslbl `g1' `1'
    _crcslbl `g2' `2'
	
	local yttl : var label `g1'
	local xttl : var label `g2'
	if "`exp'" != "" {
	local yttl  `"`yttl' (weighted)"'  
	local xttl  `"`xttl' (weighted)"'  
	}

	local grttl `"Quantile-Quantile Plot"'
	if "`exp'" != "" {
	local grttl `"Weighted Quantile-Quantile Plot"'
	}
	
*
	twoway(scatter `g1' `g2',     		            	///
                sort                                    ///
                title(`grttl')         					///
                ytitle(`"`yttl'"')                      ///
                xtitle(`"`xttl'"')                      ///
        )                                               ///
        (function y=x,                                  ///
                range(`g2')          	                ///
                lstyle(refline)                         ///
				legend(off)								///
        )                                               
	
end

