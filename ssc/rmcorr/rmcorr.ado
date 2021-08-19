*! 1.0.1 Ariel Linden 07 July 2021 | switched from N to e(df_r) for computing CIs 
*! 1.0.0 Ariel Linden 07 July 2021 

capture program drop rmcorr
program rmcorr, rclass byable(recall)

	version 11
	syntax varlist(min=3 max=3 numeric) [if] [in] [, Level(real `c(level)') FIGure FIGure2(str asis) ]

		tokenize `varlist'
		local var1 `1'
		local var2 `2'
		local id `3'
		
		// get length of Y and X for table formatting
		local len1 = length("`var1'")
		local len2 = length("`var2'")
		local len = max(`len1',`len2') + 6

		marksample touse 
		qui count if `touse'
		if r(N) < 5 error 2001 
		local n = r(N) 
		
		if `level' <= 0 | `level' >= 100 { 
			di as err "invalid confidence level"
			error 499
		}

		// estimate ANOVA model
		qui anova `var1' c.`var2' i.`id' if `touse'

		// compute r and p values 
		tempvar pval rho z d lb ub n_df
		scalar `n_df' = e(df_r)
		scalar `pval' = Ftail(e(df_1),e(df_r),e(F_1))
		scalar `rho' = sign(_b[`var2']) * sqrt( e(ss_1)/(e(ss_1)+e(rss)))
	
		// compute confidence levels based on Z transformation
		scalar `z' = atanh(`rho')
		scalar `d' = invnorm(.5 + `level'/200) / sqrt(`n_df' - 3)
		scalar `lb' = tanh(`z' - `d') 
		scalar `ub' = tanh(`z' + `d') 

		// Display output table
		tempname mytab
		.`mytab' = ._tab.new, col(5) lmargin(0)
		.`mytab'.width    `len'   |7  14  12    12
		.`mytab'.titlefmt  .     .   . %24s   .
		.`mytab'.pad       .     1   1  3     3
		.`mytab'.numfmt    . %9.0g %9.4f %9.0g %9.0g
		.`mytab'.strcolor result  .  .  .  .
		.`mytab'.strfmt    %19s  .  .  .  .
		.`mytab'.strcolor   text  .  .  .  .
		.`mytab'.sep, top
		.`mytab'.titles "`var1'"								/// 1
						"rho "									/// 2
						"Prob>F"								/// 3
						"[`level'% conf. interval]" ""          //  4 5
		.`mytab'.sep, middle
		.`mytab'.strfmt    %`len's  .  .  .  .
		.`mytab'.row    "`var2' "  		    		///
				`rho' 	                      		///
				`pval'								///
				`lb'                 				///
				`ub'
		.`mytab'.sep, bottom
			
		// return variables	
		return scalar pval = `pval'
		return scalar ub = `ub'
		return scalar lb = `lb'
		return scalar rho = `rho'
		return scalar obs = `n'
		
		if `"`figure'`figure2'"' != ""{
			qui levelsof `id' if `touse', local(ids)
			
			// get Y and X labels if they exist
			local ydesc : var label `var1'
			if `"`ydesc'"' == "" local ydesc "`var1'"
			local xdesc : var label `var2'
			if `"`xdesc'"' == "" local xdesc "`var2'"
		
			forval x = 1/`:word count `ids''{
				local color  `=runiformint(0,255)' `=runiformint(0,255)' `=runiformint(0,255)'
				local graph `graph'scatter `var1' `var2' if `id'==`:word `x' of `ids'', mcolor("`color'")|| lfit `var1' `var2' if `id'==`:word `x' of `ids'', lcolor("`color'") ||
			}
			twoway `graph', ytitle(`var1') legend(off) ytitle("`ydesc'") xtitle("`xdesc'") `figure2'
		}	
			
end