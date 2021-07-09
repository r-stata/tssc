*! version 2.3 fv swml abuxton 03Nov2013.
*! cureregr, cure model regression or parametric cure model PCM
*! main program cureregr.ado, called by cureregr_p.ado which is run via predict switch 
* version 2.1 abuxton 23sep2007.

program define cureregr_gen_p
version 13

		syntax [if] [in] , 						///
			[Survival]  ///
			[SEs]		///
			[Ucs]		///
			[Lcs]		///
			[Hazard] 	///
			[FD]		///
			[ALL]		///
			[Gen(string)] ///
			[LEVELopt0(string)]
			tempvar touse
			mark `touse' `if' `in' `e(sample)'
			qui count if `touse'
			if r(N)==0 {
				error 2000 			/* no observations */
				}
			local svopt `"`survival'"'
			local alopt `"`all'"'
			local hzopt `"`hazard'"'
			local fdopt `"`fd'"'
			local sesopt `"`ses'"'
			local ucsopt `"`ucs'"'
			local lcsopt `"`lcs'"'
			local levelopt `"level(`levelopt0')"'
			local genopt  `"`gen'"'

	local gen_n : word count `genopt'
	if `gen_n' == 0 {
	}
	else if `gen_n' == 1 {
	}
	else if `gen_n' == 6 {
	}
	else {
	di `"{err}the number of gen variables must be 1 or 6{txt}"'
	exit
	}

	local level_n : word count `levelopt0'
	if `level_n' == 0 {
		local levelopt `"level(95)"'
	}
	else if `level_n' == 1 {
		local levelopt `"level(`levelopt0')"'
	}

	if lower(substr(`"`svopt'"',1,1))==`"s"'  {
		local fnopt0 `"survival"'
		}
	else if lower(substr(`"`sesopt'"',1,2))==`"se"' {
		local fnopt0 `"ses"'
		}
	else if lower(substr(`"`lcsopt'"',1,1))==`"l"' {
		local fnopt0 `"lcs"'
		}
	else if lower(substr(`"`ucsopt'"',1,1))==`"u"' {
		local fnopt0 `"ucs"'
		}
	else if lower(substr(`"`alopt'"',1,3))==`"all"'  {
		local fnopt0 `"est_all"'
		}
	else if lower(substr(`"`hzopt'"',1,1))==`"h"' {
		local fnopt0 `"hazard"'
		}
	else if lower(substr(`"`fdopt'"',1,2))==`"fd"' {
		local fnopt0 `"faildensity"'
		}
	else {
		di `"{err}please, check cureregr_gen_p {S, ses, lcs, ucs, h, fd, or all} only {txt}"'
		exit
	}
		*di `"display fnopt0:"' `"`fnopt0'"'
		*di `"display gen_n: `gen_n'"'

	if `"`fnopt0'"' == `"est_all"' {
		if `gen_n' == 0 /* default variable names */ {
			foreach Varx in S seS lciS uciS haz fd {
			confirm new var `Varx'
			}
		}
		else if `gen_n' == 6 {
			foreach Varx in `genopt' {
			confirm new var `Varx'
			}
		}
	}
	else if `gen_n' == 1 {
			confirm new var `gen'
	}
	else {
		if `"`fnopt0'"' == `"survival"' {
		confirm new var S
		}
		else if `"`fnopt0'"' == `"ses"' {
		confirm new var ses
		}
		else if `"`fnopt0'"' == `"lcs"' {
		confirm new var lcs
		}
		else if `"`fnopt0'"' == `"ucs"' {
		confirm new var ucs
		}
		else if `"`fnopt0'"' == `"hazard"' {
		confirm new var haz
		}
		else if `"`fnopt0'"' == `"faildensity"' {
		confirm new var fd
		}
	}


/* calculate the fail density */
			local pi `"(exp(-1*exp((xb(#1)))))"'
			local ttfunction `"((exp(xb(#2)) * _t)^exp(xb(#3)))"'
			local dtt = `"((`ttfunction')*exp(xb(#3))/_t)"'

		local lnl  = lower(substr(`"`e(user)'"',4,2))
		local krn = lower(substr(`"`e(user)'"',6,2))
		local cfl  = lower(substr(`"`e(user)'"',8,2))
	*cure fraction link
		if `"`cfl'"' == `"01"' {
			local pi `"(1/(1+exp(-1*(xb(#1)))))"'
			}
		else if `"`cfl'"' == `"02"' {
			local pi `"(exp(-1*exp((xb(#1)))))"'
			}
		else if `"`cfl'"' == `"03"' {
			local pi `"((xb(#1)))"'
			}
	*kernal, distribution function
		if `"`krn'"' == `"01"' {					// weibull, exponential in tt,  dist
			local kr `"(1-exp(-1*(`ttfunction')))"'
			local dk `"((exp(-1*(`ttfunction')))*(`dtt'))"'
			}
		else if `"`krn'"' == `"02"' {				// ln-normal dist
			local kr `"(norm(ln(`ttfunction')))"'
			local dk `"(normden(ln(`ttfunction'))*exp(xb(#3))/_t)"'
			}
		else if `"`krn'"' == `"08"' {				// ln-normal dist scale==1
			local ttfunction `"((exp(xb(#2)) * _t))"'
			local kr `"(norm(ln(`ttfunction')))"'
			local dk `"(normden(ln(`ttfunction'))/_t)"'
			}
		else if `"`krn'"' == `"03"' {				// logistic dist
			local kr `"(`ttfunction'/(1 + `ttfunction'))"'
			local dk `"((1/(1+`ttfunction')^2)*(`dtt'))"'
			}
		else if `"`krn'"' == `"04"' {				// gamma dist
			local tt `"((_t)/exp(xb(#2)))"'
			local kr `"(gammap(exp(xb(#3)),`tt'))"'
			local dk `"(gammaden(exp(xb(#3)),exp(xb(#2)),0,_t))"'
			}
		else if `"`krn'"' == `"05"' {				// exponential dist gamma shape==1
			local tt `"((_t)/exp(xb(#2)))"'
			local kr `"(gammap(1,`tt'))"'
			local dk `"(gammaden(1,exp(xb(#2)),0,_t))"'
			}
		else if `"`krn'"' == `"06"' {				// lognormal dist sigma=x
			local kr `"(normal(((ln(_t)-(xb(#2)))/exp(xb(#3)))))"'
			local dk `"(normden(ln(_t),(xb(#2)),exp(xb(#3)))*(1/_t))"'
			}
		else if `"`krn'"' == `"07"' {				// lognormal dist sigma=1
			local kr `"(normal(((ln(_t)-(xb(#2)))/1)))"'
			local dk `"(normden(ln(_t),(xb(#2)),1)*(1/_t))"'
			}

	*model mixture or non-mixture, survival
		if `"`lnl'"' == `"00"'	{
			local function_s `"(1+((`pi'-1)*`kr'))"'
			}
		else if `"`lnl'"' == `"01"'	{
			local function_s `"((`pi')^(`kr'))"'
			}
	*hazard function
		if `"`lnl'"' == `"00"'	{
			local function_h `"(((1-`pi')*`dk')/(`function_s'))"'
			}
		else if `"`lnl'"' == `"01"'	{
			local function_h `"(-ln(`pi')*(`dk'))"'
			}
	*failure density
			local function_fd `"`dk'"'

*set trace on
tempvar S seS lciS uciS haz fd
*if `"`fnopt0'"' == `"est_all"' {
			local function `"`function_s'"'
			local lmlfunction `"ln(-1*ln(`function_s'))"'
			tempvar lmlS lmllci lmluci
			qui predictnl double `S' = `function' if `touse', se(`seS') `levelopt' force iter(100)
			qui predictnl double `lmlS' = `lmlfunction' if `touse', ci(`lmllci' `lmluci') `levelopt' force iter(100)
			qui gen double `lciS'  = exp(-exp(`lmluci')) if `touse'
			qui gen double `uciS'  = exp(-exp(`lmllci')) if `touse'
		*this is code for the text dfn of function for hazard
			local function `"`function_h'"'
			qui predictnl double `haz' = `function' if `touse', force iter(100)
		*this is the fail density
			local function `"`function_fd'"'
			qui predictnl double `fd' = `function' if `touse', force iter(100)
*}

	if `"`fnopt0'"' == `"est_all"' {
		if `gen_n' == 0 		/* default variable names */ {
			tokenize `"S seS lciS uciS haz fd"'
			forvalues i = 1/6 {
				local tname`i' ``i''
				gen double `tname`i'' = ``tname`i'''
			}
			}
		else if `gen_n' == 6 { 	/* six command given names in order */
			tokenize `"S seS lciS uciS haz fd"'
			*set trace on
			forvalues i = 1/6 {
				local tname`i' ``i''
			}
			tokenize `"`genopt'"'
			forvalues i = 1/6 {
				local gname`i' ``i''
			}
			forvalues i = 1/6 {
			gen double `gname`i'' = ``tname`i'''
			}
			*set trace off
		}
	}
	else if `gen_n' == 1 {		/* one of six command given names */
		if `"`fnopt0'"' == `"survival"' {
		gen double `genopt'=`S'
		}
		else if `"`fnopt0'"' == `"ses"' {
		gen double `genopt'=`seS'
		}
		else if `"`fnopt0'"' == `"lcs"' {
		gen double `genopt'=`lciS'
		}
		else if `"`fnopt0'"' == `"ucs"' {
		gen double `genopt'=`uciS'
		}
		else if `"`fnopt0'"' == `"hazard"' {
		gen double `genopt'=`haz'
		}
		else if `"`fnopt0'"' == `"faildensity"' {
		gen double `genopt'=`fd'
		}
	}
	else {
		if `"`fnopt0'"' == `"survival"' {
		gen double S=`S'
		}
		else if `"`fnopt0'"' == `"ses"' {
		gen double seS=`ses'
		}
		else if `"`fnopt0'"' == `"lcs"' {
		gen double lciS=`lciS'
		}
		else if `"`fnopt0'"' == `"ucs"' {
		gen double uciS=`uciS'
		}
		else if `"`fnopt0'"' == `"hazard"' {
		gen double haz=`haz'
		}
		else if `"`fnopt0'"' == `"faildensity"' {
		gen double fd=`fd'
		}
	}

end /* cureregr_gen_p */
