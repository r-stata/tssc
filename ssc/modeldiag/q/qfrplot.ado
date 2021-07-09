*! 2.0.0 NJC 4 November 2004 
* 1.2.0 NJC 17 May 2002
* 1.1.0 NJC 12 Apr 2002 
* 1.0.0 NJC 15 Oct 2001
program qfrplot
	version 8   
	syntax [anything(name=plottype)] [ , BY(str) /// 
	super NORMal GAUSSian combine(str asis)      ///
	fplot(str asis) rplot(str asis) * ] 

	// no by()
	if "`by'" != "" { 
		di as err "by() not supported" 
		exit 198 
	}	

	// get model results 
	tempvar fit residual 
	quietly { 
		predict `fit' if e(sample) 
		su `fit' if e(sample), meanonly 
		replace `fit' = `fit' - r(mean) 
		predict `residual' if e(sample), res 
		label var `fit' "Fitted - mean" 
		label var `residual' "Residuals" 
	}	

	// set up graph call 
	if "`normal'`gaussian'" != "" { 
		local trcall "xla(-2(1)2) trscale(invnorm(@))"
		local xti = cond("`gaussian'" != "", "Gaussian", "normal") 
		local xti "quantiles of standard `xti'" 
	}
	else local xti "fraction of data" 
	
	if "`plottype'" == "" local plottype "scatter" 
	
	// graph
	if "`super'" == "" { 
		tempname g1 g2 
		
		quietly { 
		        qplot `plottype' `fit', ///
			t1(fitted - mean) yti(" ") xti(" ") ///
			`trcall' name(`g1') nodraw `fplot' 
		
			qplot `plottype' `residual', ///
			t1(residuals) yti(" ") xti(" ") yla(, nolabels noticks) ///
			`trcall' ysc(noline) name(`g2') nodraw `rplot' 
		}	
		
		graph combine `g1' `g2', ycommon imargin(zero) ///
		b2ti(`xti') l1ti("quantiles") `combine' `options'  	
	}
	else { 
		qplot `plottype' `fit' `residual', ///
		yti(quantiles) xti(`xti') `trcall' `combine' `options' 
	}
end

