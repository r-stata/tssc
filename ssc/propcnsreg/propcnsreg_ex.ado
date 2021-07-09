*! version 1.7.2 07Feb2013 MLB
*! version 1.7.0 31Okt2012 MLB
program define propcnsreg_ex
	if `1' == 1 {
		Msg preserve
		preserve

		Xeq sysuse nlsw88, clear

		Xeq gen hs = grade == 12 if grade < .
		Xeq gen sc = grade > 12 & grade < 16 if grade < .
		Xeq gen c = grade >= 16 if grade < .

		Xeq gen tenure2 = tenure^2
		Xeq gen tenureXunion = tenure*union
		Xeq gen tenure2Xunion = tenure2*union

		Xeq gen hours2 = ( hours - 40 ) / 5
		
		Xeq gen white = race == 1 if race < .

		Xeq propcnsreg wage tenure* union white hours2, /*
		*/ lambda(tenure tenureXunion union) /*
		*/ constrained(hs sc c) unit(c) poisson vce(bootstrap) irr

		Xeq predict double effect, effect
		Xeq predict double se_effect, stdp eq(lambda)
		Xeq gen double lb = effect - invnormal(.975)*se_effect
		Xeq gen double ub = effect + invnormal(.975)*se_effect
		
		Xeq replace effect = exp(effect)
		Xeq replace lb = exp(lb)
		Xeq replace ub = exp(ub)
		
		Xeq sort tenure

		Xeq twoway rarea lb ub tenure if union == 1 || /* 
		*/ rarea lb ub tenure if union== 0, /*
		*/ astyle(ci ci) || /*
		*/ line effect tenure if union == 1 || /* 
		*/ line effect tenure if union == 0, /*
		*/ yline(1) clpattern(longdash shortdash) /*
		*/ legend(label(1 "95% conf. int.") /*
			   */ label(2 "95% conf. int.") /*
			   */ label(3 "union")          /*
			   */ label(4 "non-union")      /*
			   */ order(3 4 1 2))           /*
		*/ ytitle("effect of education on wage")

		Msg restore 
		restore
	}
	if `1' == 2 {
		Msg preserve
		preserve
		
		Xeq sysuse nlsw88, clear
		Xeq gen byte high = occupation < 3 if !missing(occupation)
		Xeq gen byte white = race == 1 if !missing(race)

		Xeq gen byte hs = grade == 12 if !missing(grade)
		Xeq gen byte sc = grade > 12 & grade < 16 if !missing(grade)
		Xeq gen byte c = grade >= 16 if !missing(grade)

		Xeq propcnsreg high white ttl_exp married never_married age, ///
                       lambda(ttl_exp white) ///
                       constrained(hs sc c) unit(c) logit or 
		Msg restore
		restore
	}
	if `1' == 3 {
		Msg preserve
		preserve

	    Xeq sysuse nlsw88, clear
        Xeq gen hs = grade == 12 if grade < .
        Xeq gen sc = grade > 12 & grade < 16 if grade < .
        Xeq gen c = grade >= 16 if grade < .
        Xeq gen tenure2 = tenure^2
        Xeq gen tenureXunion = tenure*union
        Xeq gen tenure2Xunion = tenure2*union
        Xeq gen hours2 = ( hours - 40 ) / 5
        Xeq gen white = race == 1 if race < .

        Xeq propcnsreg wage tenure* union white hours2 , ///
            lambda(tenure tenureXunion union)            ///
            constrained(hs sc c) unit(c)                 ///
            poisson irr vce(bootstrap)
		
        Xeq propcnsasl
		restore
	}
	if `1' == 4 {
		capture {
			which qplot
			which qenvchi2
			which simpplot
		}
		if _rc {
			di as err ///
"{p}this example requires the qplot, qenv, and simpplot packages; type " as input "findit qplot" as err ", " as input "ssc install qenv" as err ", and " as input "ssc install simpplot" as err " to get these {p_end}"
			exit
		}
		Msg preserve
		preserve

	    Xeq sysuse nlsw88, clear
        Xeq gen hs = grade == 12 if grade < .
        Xeq gen sc = grade > 12 & grade < 16 if grade < .
        Xeq gen c = grade >= 16 if grade < .
        Xeq gen tenure2 = tenure^2
        Xeq gen tenureXunion = tenure*union
        Xeq gen tenure2Xunion = tenure2*union
        Xeq gen hours2 = ( hours - 40 ) / 5
        Xeq gen white = race == 1 if race < .

        Xeq propcnsreg wage tenure* union white hours2 , ///
            lambda(tenure tenureXunion union)            ///
            constrained(hs sc c) unit(c)                 ///
            poisson irr vce(robust)
		
		Msg tempfile sims 
		tempfile sims
		Xeq set seed 12345
        Msg propcnsasl, saving(\`sims') reps(10000)
		propcnsasl, saving(`sims') reps(10000)
		Msg use \`sims', clear
		use `sims', clear
		
		Xeq qenvchi2 Wald_stat, gen(lb ub) df(6) overall reps(20000)
		
		if c(stata_version) < 11 {
			Xeq qplot Wald_stat lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistic") trscale(invchi2(6,@)) xtitle("chi-square(6) quantiles") plot(function reference=x, range(0 31)) name(__qq)
		}
		else {
			Xeq qplot Wald_stat lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistic") trscale(invchi2(6,@)) xtitle("{&chi}{sup:2}(6) quantiles")	plot(function reference=x, range(0 31)) name(__qq) 
		}

		Xeq simpplot p, overall reps(20000)
		
		Msg restore
		restore
	}
end

program Msg
        di as txt
        di as txt "-> " as res `"`macval(0)'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
