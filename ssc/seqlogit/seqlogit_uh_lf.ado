*! 1.1.13 MLB 06Sep2010
*! 1.1.8  MLB 08Apr2010
*! 1.1.0  MLB 04Jun2009
program define seqlogit_uh_lf
	version 9.2
	/*count number of equations*/
	forvalues i = 1/$S_eqs {
		local xb "`xb' xb`i'" 
	}
	args lnf `xb' 
	tokenize $S_treelevels
	local N_levs : word count $S_treelevels
	tempvar touse2
	qui gen byte `touse2' = 0
	local start = 0
	local end = $S_drawstart
	forvalues i = 1/`N_levs' {
		qui replace `touse2' = $ML_y1 == ``i'' & $ML_samp == 1
		local start = `start' + `end'
		qui count if `touse2'
		local end = `start' + r(N)
		mata comp_ll(``i'', `start')	
	}
end

mata:
void comp_ll(real scalar lev, real scalar start) {
// get xb
	eqs = strtoreal(st_global("S_eqs"))
	xbnames = J(1,eqs,"")
	for(i=1; i<= eqs; i++) {
		xbnames[1,i] = st_local("xb" + strofreal(i))
	}
	xb = .
	st_view(xb,.,xbnames,st_local("touse2"))

// get y
	y = .
	st_view(y,.,st_global("ML_y1"),st_local("touse2"))

// get sd_var
	if (st_global("S_sd_var") != "") {
		sd_var = .
		st_view(sd_var,.,st_global("S_sd_var"),st_local("touse2"))	
	}
		
// get lnf
	lnf = .
	st_view(lnf,.,st_local("lnf"),st_local("touse2"))

// get other globals
	t = tokens(st_global("S_t" + strofreal(lev)))
	c = strtoreal(tokens(st_global("S_c" + strofreal(lev))))

	draws = strtoreal(st_global("S_draws"))

	eqstr   = J(length(t),1,"")
	Nchoice = J(length(t),1,.)
	for(i=1; i <= length(t); i++) {
		Nchoice[i,1] = strtoreal(st_global("S_Nchoice" + t[i]))
		eqstr[i] = st_global("S_eqstr" + t[i])
	}
	sigma     = strtoreal(tokens(st_global("S_sigma"  )))
	deltasd   = strtoreal(tokens(st_global("S_deltasd")))
	rho       = .
	rho       = strtoreal(       st_global("S_rho"    ) )
	pr        = .
	pr        = strtoreal(tokens(st_global("S_pr"     )))
	mpnts     = strtoreal(tokens(st_global("S_mpnts"  )))
	m_mn      = strtoreal(tokens(st_global("S_m_mn"   )))
	pr_mn     = strtoreal(tokens(st_global("S_pr_mn"  )))
	sd_mn     = strtoreal(tokens(st_global("S_sd_mn"  )))

// create e
	if (st_global("S_pr")!= "") {
		u = halton(draws*rows(xb), 1, start)
		e = J(draws*rows(xb),1,0)
		cumpr = 0
		for (i = 1; i <= length(pr); i++){
			prev_cumpr = cumpr
			cumpr = cumpr + pr[i]
			e = e :+ ( (u:<cumpr):&(u:>=prev_cumpr) ) :* mpnts[i]
		}
	}
	else if (st_global("S_pr_mn") != "" ) {
		u = halton(draws*rows(xb), 2, start)
		e = J(draws*rows(xb),1,0)
		cumpr = 0
		for (i = 1; i <= length(pr_mn); i++){
			prev_cumpr = cumpr
			cumpr = cumpr + pr_mn[i]
			e = e :+ ( (u[.,1]:<cumpr):&(u[.,1]:>=prev_cumpr) ) :* ( ( invnormal(u[.,2]) :* sd_mn[i] ) :+ m_mn[i] )
		}
	}
	else if (st_global("S_uniform") != "") {
		e = (halton(draws*rows(xb), 1, start) :- .5) :/ sqrt(1/12) 
	}
	else {
		e = invnormal(halton(draws*rows(xb), 1, start))
	}

	if (rho == .) { 
		
	} 
	else {
		x = .
		st_view(x,.,st_global("S_ofinterest"),st_local("touse2"))
		e = colshape(e,draws)
		sdx = strtoreal(st_global("S_sdx"))
		mx = strtoreal(st_global("S_mx"))
		e = (rho:*(x :- mx):/sdx :+ sqrt(1-rho^2):*e)
		e = colshape(e,1)
	}

	// compute probabilities
	w = J(rows(e),1,1)
	p = J(rows(xb),1,1)
	for(i = 1; i <= length(t); i++) {
		denom = J(rows(xb),draws,1)
		teqstr = strtoreal(tokens(eqstr[i]))
		for(j = 1; j <= (Nchoice[i,1]-1); j++) {
			if (st_global("S_deltasd") == "") {
				t_sigma = sigma[1,teqstr[j]]
			}
			else {
				t_sigma = sigma[1,teqstr[j]] :+ (deltasd[1,teqstr[j]] :* sd_var)
			}
			denom = denom :+ exp( xb[.,teqstr[j]]:+ (t_sigma:*colshape(e,draws)) )
		}
		if (c[i]==0) {
			temp = colshape(1:/denom, 1)
		}
		else {
			if (st_global("S_deltasd") == "") {
				t_sigma = sigma[1,teqstr[c[i]]]
			}
			else {
				t_sigma = sigma[1,teqstr[c[i]]] :+ (deltasd[1,teqstr[c[i]]] :* sd_var)
			}
			temp = colshape(exp(xb[.,teqstr[c[i]]]:+ (t_sigma:*colshape(e,draws))) :/ denom, 1)
		}
		p = p:* ( rowsum(colshape(w:*temp, draws)):/rowsum(colshape(w,draws)) )
		w = w:*temp
	}
// compute and replace the log-likelihood
	lnf[.,.] = ln(p)
}
end

