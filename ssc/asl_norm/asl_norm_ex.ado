*! version 1.0.3 MLB 04Feb2013
*! version 1.0.2 MLB 22Jan2013
program define asl_norm_ex
	version 11
    if "`1'" == "1" {
        Msg preserve
        preserve
        Xeq sysuse auto, clear
		Xeq set seed 123456
        Xeq asl_norm trunk, dh reps(19999)
        Msg restore 
        restore
    }
    if "`1'" == "2" {
        Msg preserve
        preserve
        Xeq sysuse nlsw88, clear
		Xeq gen lnwage = ln(wage)
        Xeq set seed 123456
		Xeq asl_norm lnwage if union < ., dh reps(19999)
		Xeq qnorm lnwage if union < .
        Msg restore 
        restore
    }
	if "`1'" == "3" {
		capture which qplot
		local noqplot = ( _rc > 0 )
		capture which qenvchi2
		local noqenv = ( _rc > 0 )
		capture which simpplot
		local nosimpplot = ( _rc > 0 )
		if `noqplot' & !`noqenv' & !`nosimpplot' {
			di as err ///
"{p}this example requires the qplot package; type " as input "findit qplot" as err " to get this {p_end}"
			exit 199
		}
		if !`noqplot' & `noqenv' & !`nosimpplot' {
			di as err ///
"{p}this example requires the qenv package; type " as input "ssc install qenv" as err " to get this {p_end}"
			exit 199		
		}
		if `noqplot' & `noqenv' & !`nosimpplot'{
			di as err ///
"{p}this example requires the qplot and qenv package; type " as input "findit qplot" as err " and " as input "ssc install qenv" as err " to get these {p_end}"
			exit 199
		}
		if !`noqplot' & !`noqenv' & `nosimpplot'{
			di as err ///
"{p}this example requires the simpplot package; type " as input "ssc install simpplot" as err " to get this {p_end}"
			exit 199
		}		
		if `noqplot' & !`noqenv' & `nosimpplot'{
			di as err ///
"{p}this example requires the qplot and simpplot package; type " as input "findit qplot" as err " and " as input "ssc install simpplot" as err " to get these {p_end}"
			exit 199
		}
		if `noqplot' & `noqenv' & `nosimpplot'{
			di as err ///
"{p}this example requires the qplot, qenv and simpplot package; type " as input "findit qplot" as err ", " as input "ssc install qenv" as err " and " as input "ssc install simpplot" as err " to get these {p_end}"
			exit 199
		}
		Msg preserve
		preserve
		Xeq set seed 12345
		Xeq sysuse auto, clear

		Msg tempfile res
		tempfile res
		Msg asl_norm trunk, jb sktest reps(1999) saving("\`res'", replace)
		asl_norm trunk, jb sktest reps(1999) saving("`res'", replace)
		Msg use "\`res'"
		use "`res'"
		Xeq qenvchi2 sktest, gen(lb ub) df(2) overall reps(5000)

		Msg tempname qplot
		tempname qplot 
		
		Msg qplot sktest jbtest lb ub, trscale(invchi2(2,@)) ///
			ms(o o none ..) c(. . l l)  lc(gs10 ..)    ///
			scheme(s2color) ylab(,angle(horizontal))   ///
			legend(order( 1 "sktest"                   ///
						  2 "Jarque-Bera"              ///
						  3 "95% simultaneaous"        ///
					        "Monte Carlo CI"))         ///
			name(\`qplot')
							
        qplot sktest jbtest lb ub, trscale(invchi2(2,@)) ///
			ms(o o none ..) c(. . l l)  lc(gs10 ..)    ///
			scheme(s2color) ylab(,angle(horizontal))   ///
			legend(order( 1 "sktest"                   ///
						  2 "Jarque-Bera"              ///
						  3 "95% simultaneaous"        ///
					        "Monte Carlo CI"))         ///
			name(`qplot')

		Xeq gen p_sk = chi2tail(2,sktest)
		Xeq label var p_sk "sktest"
		Xeq gen p_jb = chi2tail(2,jbtest)
		Xeq label var p_jb "Jarque-Bera"
		
		Xeq simpplot p_sk p_jb, overall reps(19999)          ///
				scheme(s2color) ylab(,angle(horizontal))
		Msg restore
		restore
	}
	
	if "`1'" == "4" {
        Msg preserve
        preserve
        Xeq sysuse nlsw88, clear
		Xeq gen lnwage = ln(wage)
		Xeq set seed 123456
        Xeq asl_norm lnwage  
		Xeq qnorm lnwage
        Msg restore 
        restore
    }
	if "`1'" == "5" {
		capture which qplot
		local noqplot = ( _rc > 0 )
		capture which qenvnormal
		local noqenv = ( _rc > 0 )
		if `noqplot' & !`noqenv' {
			di as err ///
"{p}this example requires the qplot package; type " as input "findit qplot" as err " to get this {p_end}"
			exit 199
		}
		if !`noqplot' & `noqenv' {
			di as err ///
"{p}this example requires the qenv package; type " as input "ssc install qenv" as err " to get this {p_end}"
			exit 199		
		}
		if `noqplot' & `noqenv' {
			di as err ///
"{p}this example requires the qplot and qenv package; type " as input "findit qplot" as err " and " as input "ssc install qenv" as err " to get these {p_end}"
			exit 199
		}
		
		Msg preserve
		preserve
		Xeq sysuse nlsw88, clear
		Xeq gen lnwage = ln(wage)
		Xeq qenvnormal lnwage, gen(lb ub) overall reps(19999)
		Xeq sum lnwage
		Msg qplot lnwage lb ub, ms(oh none ..) c(. l l) lc(gs10 ..)        ///
				  legend(off) ytitle("ln(wage)") xtitle(Normal quantiles)  ///
				  trscale(\`r(mean)' + \`r(sd)' * invnormal(@)) 
				  
		qplot lnwage lb ub, ms(oh none ..) c(. l l) lc(gs10 ..)       ///
		      legend(off) ytitle("ln(wage)") xtitle(Normal quantiles) ///
			  trscale(`r(mean)' + `r(sd)' * invnormal(@))
		Msg restore
		restore
	}
end

program Msg
    di as txt
    di as txt "-> " as res `"`macval(0)'"'
end

program Xeq
    di as txt
    di as txt `"-> "' as res `"`0'"'
    `0'
end
