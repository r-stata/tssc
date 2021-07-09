program define hangroot_ex
	Msg preserve
	preserve
	if "`1'" == "1" {
		Xeq sysuse nlsw88, clear
		Xeq gen ln_w = ln(wage)
		Xeq reg ln_w grade age ttl_exp tenure
		Xeq predict resid, resid
		Xeq hangroot resid
	}
	if "`1'" == "2a" {
		Xeq sysuse nlsw88, clear
		Xeq gen ln_w = ln(wage)
		Xeq reg ln_w grade age ttl_exp tenure union
		Xeq predict resid2, resid
		Xeq hangroot resid2
	}

	if "`1'" == "2b" {
		qui sysuse nlsw88, clear
		qui gen ln_w = ln(wage)
		qui reg ln_w grade age ttl_exp tenure union
		qui predict resid2, resid
		Xeq hangroot resid2, ci susp theoropt(lpattern(-))
	}
	if "`1'" == "2c" {
		qui sysuse nlsw88, clear
		qui gen ln_w = ln(wage)
		qui reg ln_w grade age ttl_exp tenure union
		qui predict resid2, resid
		Xeq hangroot resid2, ci susp notheor
	}

	if "`1'" == "3a" {
		Xeq sysuse nlsw88, clear
		capture lognfit wage
		if _rc {
			di as error "this example can only be run when lognfit is installed from SSC"
			exit 198
		}
		Xeq lognfit wage
		Xeq hangroot, ci
	}
	if "`1'" == "3b" {
		Xeq sysuse nlsw88, clear
		Xeq hangroot wage, dist(lognormal) ci
	}
	if "`1'" == "4" {
		Xeq sysuse nlsw88, clear
		Xeq hangroot wage, dist(theoretical collgrad)
	}
	if "`1'" == "5a" {
		Xeq set seed 1234
		Xeq drop _all
		Xeq set obs 1000
		Xeq gen byte x = _n <= 250
		Xeq gen y = -3 + 3*x + invnormal(uniform())
		Xeq hangroot y, dist(normal) ci
	}
	if "`1'" == "5b" {
		qui set seed 1234
		qui drop _all
		qui set obs 1000
		qui gen byte x = _n <= 250
		qui gen y = -3 + 3*x + invnormal(uniform())
		Xeq reg y x
		Xeq hangroot, ci 
	}
	if "`1'" == "5c" {
		qui set seed 1234
		qui drop _all
		qui set obs 1000
		qui gen byte x = _n <= 250
		qui gen y = -3 + 3*x + invnormal(uniform())
		qui reg y x
		Xeq predict double mu , xb
		Xeq scalar sd = e(rmse)
		Msg forvalues i = 1/20 {
		Msg     gen sim\`i' = invnormal(uniform())*sd + mu
		Msg }
		forvalues i=1/20 {
		    gen sim`i' = invnormal(uniform())*sd + mu
		}
		Xeq hangroot, sims(sim*) jitter(5) xlab(-6(3)3) 
	}
	Msg restore 
	restore
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
