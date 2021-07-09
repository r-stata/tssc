program define hangr_graph, sclass
	syntax varname,   ///
	dist(string)      ///
	x(varname)        ///
	floor(varname)    ///
	gr(string)        ///
	level(integer)    /// 
	[                 ///
	w(numlist)        ///
	theor(varname)    ///
	xtitle(passthru)  ///
	ytitle(passthru)  /// 
	legend(passthru)  ///
	mainopt(string)   ///
	theoropt(string)  ///
	ci                ///
	cispike(string)   ///
	cibar(string)     ///
	ciarea(string)    ///
	suspended         ///
	spike             ///
	bar               /// 
	zero(string)      /// 
	plot(string)      ///
	notheoretical     ///
	*                 ///
	]
	if `"`xtitle'"' == "" {
		local xtitle : variable label `varlist'
		if "`xtitle'" == "" {
			local xtitle "`varlist'"
		}
		local xtitle `"xtitle("`xtitle'")"'
	}

	if `"`ytitle'"' == "" {
		if "`theoretical'" != "" {
			local ytitle `"ytitle("sqrt(residuals)")"'
		}
		else{
			local ytitle `"ytitle("sqrt(frequency)")"'
		}
	}

	if `"`legend'"' == "" {
		if "`ci'" != "" {
			if "`suspended'" == "" {
				if "`spike'" != "" {
					local legend `"legend(order(1 "`level'% Conf. Int."))"'
				}
				else {
					local legend `"legend(order(3 "`level'% Conf. Int."))"'
				}
			}
			else if "`dist'" != "theoretical" {
				local legend `"legend(order(1 "`level'% Conf. Int." 3 "residual"))"'
			}
			else {
				local legend `"legend(order(1 "`level'% Conf. Int." 3 "residual" 4 "theoretical" "distribution"))"'
			}
		}
		else {
			local legend "legend(off)"
		}
	}
	
	if "`bar'" != "" {
		local barw "barw(`w')"
	}
	
	if "`suspended'" != "" {
		gen byte `zero' = 0
		if "`spike'" != "" local lstyle "lstyle(p3)"
		local maingr r`spike'`bar' `zero' `floor' `x', `lstyle' `mainopt'
	}
	else {
		if "`spike'" != "" local lstyle "lstyle(p1)"
		local maingr r`spike'`bar' `theor' `floor' `x', `lstyle' `mainopt'
	}
	if "`theoretical'" == "" {
		local theordistgr `"`gr' lstyle(p1)"'
	}
	
	sreturn local graph `"twoway `cispike'`ciarea' || `maingr' `barw' yline(0) `options' `ytitle' `xtitle' `legend' || `theordistgr' `theoropt' || `cibar' || `plot'"'

end
