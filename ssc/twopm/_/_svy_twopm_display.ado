prog define _svy_twopm_display, eclass
syntax[, level(string) * ]

_twopm_coef_display, level(`level') `options'
		             
end

program _twopm_coef_display
        syntax [, level(string) * ]

		*** Parsing equation names
		local eqnames "`e(eqnames)'"
		forvalues i = 1/2 {	
			local eq`i': word `i' of `eqnames'
			if `i'==2 {
				local eq`i': word `i' of `eqnames'
				local eq`i' = trim(regexr("`eq`i''", "_log", ""))
			}
		}
		
        tempname mytab t p ll ul
        .`mytab' = ._tab.new, col(7) lmargin(0)
        .`mytab'.width    13   |12    12     8     8    12    12
        .`mytab'.titlefmt  .     .     .   %6s     .  %24s     .
        .`mytab'.pad       .     2     1     0     2     3     3
        .`mytab'.numfmt    . %9.0g %9.0g %7.2f %5.3f %9.0g %9.0g

        if "`e(df_r_`eq1')'" != "" {
                local stat t
				tempname z_`eq1'
                scalar `z_`eq1'' = invttail(`e(df_r_`eq1')',(100-`level')/200)
        }
        if "`e(df_r_`eq2')'" != "" {
                local stat t
				tempname z_`eq2'
                scalar `z_`eq2'' = invttail(`e(df_r_`eq2')',(100-`level')/200)
        }
        if "`e(df_r_`eq1')'" == "" {
                local stat z
				tempname z
                scalar `z' = invnorm((100+`level')/200)
        }

        local namelist : colname e(b)
        local eqlist : coleq e(b)
        local k : word count `namelist'
		local k2 = `k'/2
        .`mytab'.sep, top
        if `:word count `e(depvar)'' == 1 {
                local depvar "`e(depvar)'"
        }
		if "`e(vcetype)'" != "" {
	    .`mytab'.titles     ""                      		/// 1
	                        ""                         		/// 2
	                        "`e(vcetype)'"     				/// 3
	                        ""                        		/// 4
	                        ""                    			/// 5
	                        "" "" 							//  6 7			
		}
        .`mytab'.titles "`depvar'"                      	/// 1
                        "Coef."                         	/// 2
                        "Std. Err."     					/// 3
                        "`stat'"                        	/// 4
                        "P>|`stat'|"                    	/// 5
                        "[`level'% Conf. Interval]" ""  	//  6 7
        forvalues i = 1/`k' {
                local name : word `i' of `namelist'
				if regexm("`name'","b.") continue
                local eq   : word `i' of `eqlist'
                if "`eq'" != "_" {
                        if "`eq'" != "`eq0'" {
                                .`mytab'.sep
                                local eq0 `"`eq'"'
                                .`mytab'.strcolor result  .  .  .  .  .  .
                                .`mytab'.strfmt    %-12s  .  .  .  .  .  .
                                .`mytab'.row      "`eq'" "" "" "" "" "" ""
                                .`mytab'.strcolor   text  .  .  .  .  .  .
                                .`mytab'.strfmt     %12s  .  .  .  .  .  .
                        }
                        local beq "[`eq']"
                }
                else if `i' == 1 {
                        local eq
                        .`mytab'.sep
                }
                scalar `t' = `beq'_b[`name']/`beq'_se[`name']

                if "`e(df_r_`eq1')'" != "" & `i'<= `k2' {
                        scalar `p' = 2*ttail(`e(df_r_`eq1')',abs(`t'))
						scalar `ll' = `beq'_b[`name']-`beq'_se[`name']* `z_`eq1''
		                scalar `ul' = `beq'_b[`name']+`beq'_se[`name']* `z_`eq1''
                }
                if "`e(df_r_`eq2')'" != "" & `i' > `k2' {
                        scalar `p' = 2*ttail(`e(df_r_`eq2')',abs(`t'))
						scalar `ll' = `beq'_b[`name']-`beq'_se[`name']* `z_`eq2''
		                scalar `ul' = `beq'_b[`name']+`beq'_se[`name']* `z_`eq2''
                }
                if "`e(df_r_`eq1')'" == "" {
						scalar `p' = 2*normal(-abs(`t'))
						scalar `ll' = `beq'_b[`name']-`beq'_se[`name']* `z'
		                scalar `ul' = `beq'_b[`name']+`beq'_se[`name']* `z'
				}
				
                .`mytab'.row    "`name'"                ///
                                `beq'_b[`name']         ///
                                `beq'_se[`name']        ///
                                `t'                     ///
                                `p'                     ///
                                `ll' `ul'
        }
        .`mytab'.sep, bottom
end

