*! 1.1.0 MLB 06 March 2013
*! 1.0.0 MLB 05 March 2013
program define qenv_ex
	if c(stata_version) < 11 {
		version 9
	}
	else {
		version 11
	}
if "`1'" == "normal" {
	Msg preserve
	preserve
	Xeq sysuse auto, clear
	Msg tempname graph1 graph2 graph3 mean sd
	tempname graph1 graph2 graph3 mean sd
	Xeq qenvnormal weight, gen(lower upper)
	Msg scalar \`mean' = r(mean)
	Msg scalar \`sd' = r(sd)
	scalar `mean' = r(mean)
	scalar `sd' = r(sd)
	Msg qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") name(\`graph1')
	qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") name(`graph1')
	Msg qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(\`mean' + \`sd' * invnormal(@)) xtitle(Normal quantiles) name(\`graph2')
	qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`mean' + `sd' * invnormal(@)) xtitle(Normal quantiles) name(`graph2')
	Xeq qenvnormal weight, overall reps(2000) gen(lower2 upper2)
	Msg qplot weight lower2 upper2, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(\`mean' + \`sd' * invnormal(@)) xtitle(Normal quantiles) name(\`graph3')
	qplot weight lower2 upper2, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`mean' + `sd' * invnormal(@)) xtitle(Normal quantiles) name(`graph3')
	Msg restore
	restore
}
else if "`1'" == "gamma" {
	Msg preserve
	preserve
	Xeq sysuse auto, clear
	Msg tempname graph1 graph2 graph3 alpha beta
	tempname graph1 graph2 graph3 alpha beta
	Xeq qenvgamma weight, gen(lower upper)
	Msg scalar \`alpha' = r(alpha)
	Msg scalar \`beta' = r(beta)
	scalar `alpha' = r(alpha)
	scalar `beta' = r(beta)
	Msg qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") name(\`graph1')
	qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") name(`graph1')
	Msg qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(\`beta' * invgammap(\`alpha', @)) xtitle(Gamma quantiles) name(\`graph2')
	qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`beta' * invgammap(`alpha', @)) xtitle(Gamma quantiles) name(`graph2')
	Xeq qenvgamma weight, overall reps(5000) gen(lower2 upper2)
	Msg qplot weight lower2 upper2, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(\`beta' * invgammap(\`alpha', @)) xtitle(Gamma quantiles) name(\`graph3')
	qplot weight lower2 upper2, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`beta' * invgammap(`alpha', @)) xtitle(Gamma quantiles) name(`graph3')
	Msg restore
	restore
}
else if "`1'" == "chi2" {
	Msg preserve
	preserve
	Xeq sysuse nlsw88, clear
	Xeq gen byte black = race == 2 if race <= 2
	Xeq keep wage union grade ttl_exp black
	if c(stata_version) < 11 {
		Xeq gen ttl_exp2 = ttl_exp^2
	}
	Xeq keep if !missing(wage, union, grade, black, ttl_exp)
	Xeq glm  wage union grade black , link(log) vce(robust) family(poisson)
	Xeq predict double mu1
	if c(stata_version) < 11 {
		Xeq glm wage union grade black ttl_exp ttl_exp2 , link(log) family(poisson) vce(robust)
	}
	else {
		Xeq glm wage union grade black c.ttl_exp##c.ttl_exp , link(log) family(poisson) vce(robust)
	}
	Xeq predict double mu2
	Xeq gen double ysim = wage - mu2 + mu1
	Msg tempfile temp
	Msg save \`temp'
	tempfile temp
	save `temp'
	Msg program define qenv_sim_chi2
	Msg     use \`1', clear
	Msg     bsample
		if c(stata_version) < 11 {
		Msg     glm ysim union grade black ttl_exp ttl_exp2, link(log) vce(robust) family(poisson)
		Msg     test ttl_exp ttl_exp2
	}
	else {
		Msg     glm ysim union grade black c.ttl_exp##c.ttl_exp, link(log) vce(robust) family(poisson)
		Msg     test ttl_exp c.ttl_exp#c.ttl_exp
	}
	Msg end
	Msg simulate chi2=r(chi2) , reps(1000): qenv_sim_chi2 \`temp'
	simulate chi2=r(chi2) , reps(1000): qenv_sim_chi2 `temp'
	Xeq qenvchi2 chi2, gen(lb ub) df(2)  overall reps(5000)
	if c(stata_version) < 11 {
		Xeq qplot chi2 lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistic") trscale(invchi2(2,@)) xtitle("chi-square(2) quantiles")
	}
	else {
		Xeq qplot chi2 lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistic") trscale(invchi2(2,@)) xtitle("{&chi}{sup:2}(2) quantiles")	
	}
	Msg restore
	restore
}
else if "`1'" == "F" {
	Msg preserve
	preserve 
	Xeq sysuse auto, clear
	Xeq gen lnprice = ln(price)
	if c(stata_version) < 11 {
		Xeq xi: reg turn mpg i.rep78 foreign
	}
	else {
		Xeq reg turn mpg i.rep78 foreign
	}
	Xeq predict double mu1
	if c(stata_version) < 11 {
		Xeq xi: reg turn mpg i.rep78 foreign weight lnprice
	}
	else {
		Xeq reg turn mpg i.rep78 foreign weight lnprice
	}
	Xeq predict double mu2
	Xeq gen double ysim = turn - mu2 + mu1
	Xeq keep ysim mpg rep78 foreign weight lnprice
	Xeq keep if !missing(ysim,  lnprice, mpg, rep78, foreign, weight)
	Msg tempfile temp
	Msg save \`temp'
	tempfile temp
	save `temp'
	Msg program define qenv_sim_F
	Msg     use \`1', clear
	Msg     bsample
	if c(stata_version) < 11 {
		Msg     xi: reg ysim mpg i.rep78 foreign weight lnprice
	}
	else {
		Msg     reg ysim mpg i.rep78 foreign weight lnprice
	}
	Msg     test weight lnprice
	Msg end
	Msg simulate F=r(F), reps(1000): qenv_sim_F \`temp'
	simulate F=r(F), reps(1000): qenv_sim_F `temp'
	Xeq qenvF F, gen(lb ub) dfnum(2) dfdenom(60) overall reps(5000)
	Xeq qplot F lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistics") trscale(invF(2,60,@)) xtitle(F(2,60) quantiles)
	Msg restore
	restore
}
else if "`1'" == "beta" {
	Msg preserve
	preserve
	Msg program define qenv_sim_beta, rclass
	Msg 	drop _all
	Msg 	set obs 10
	if c(stata_version) < 10.1 {
		Msg 	gen x = uniform()
	}
	else {
		Msg 	gen x = runiform()
	}
	Msg 	sort x
	Msg 	return scalar x = x[2]
	Msg end
	Xeq simulate x=r(x), reps(1000) : qenv_sim_beta
	Xeq qenvbeta x, gen(lb ub) alpha(2) beta(9) overall reps(5000)
	if c(stata_version) < 11 {
		Xeq qplot x lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("2nd smallest value out of 10 random draws" "from a continuous standard uniform distribution") trscale(invibeta(2,9,@)) xtitle("beta(2,9) quantiles")
	}
	else {
		Xeq qplot x lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("2{sup:nd} smallest value out of 10 random draws" "from a continuous standard uniform distribution") trscale(invibeta(2,9,@)) xtitle("beta(2,9) quantiles")
	}
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
