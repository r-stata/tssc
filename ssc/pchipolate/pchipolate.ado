*! 1.0.0 NJC 28 Nov 2012 
program pchipolate, byable(onecall) sort
	version 10
	syntax varlist(min=2 max=2) [if] [in], Generate(string) [ BY(varlist) ]
	
	if _by() {
		if "`by'" != "" {
			di as err ///
			"option by() may not be combined with by prefix"
			exit 190
		}
		local by "`_byvars'"
	}

	confirm new var `generate'
	tokenize `varlist'
	args usery x 

	if "`by'" == "" { 
		tempvar by 
		gen byte `by' = 1
	} 

	tempvar group y z guse zmiss 
	
	quietly {
		// don't mark out missing y: that's the whole point! 
		marksample touse, novarlist 
		markout `touse' `x' 

		// average multiple y for repeated x 
		bysort `touse' `by' `x': ///
		gen `y' = sum(`usery') / sum(`usery' < .) if `touse'
		by `touse' `by' `x': replace `y' = `y'[_N]

		// only use one of any repeated x 
		by `touse' `by' `x': gen byte `guse' = `touse' & (_n == 1)

		sort `guse' `by' `x' 
		egen `group' = group(`by') if `guse' 
		su `group', meanonly 
		local ng = r(max) 
		gen `z' = `y' if `touse'
		gen byte `zmiss' = 0 

		local flag = 0 

		forval g = 1/`ng' { 
			replace `guse' = `group' == `g' 
			replace `zmiss' = `guse' & missing(`z') 
			count if `guse' & !missing(`z') 
			if r(N) > 2 { 
				mata : ///
				pchipolate("`y'", "`x'", "`guse'", "`z'", "`zmiss'") 
			}
			else local flag = 1 
		} 
	
		// copy interpolated y to repeated x 	
		bysort `touse' `by' `x' (`z') : ///
			replace `z' = `z'[1] if `touse' & `z' == .  

		rename `z' `generate'
		count if `generate' == .
	}

	if `flag' { 
		di as txt "note: at least 3 values needed in any interpolation" 
	} 
	
	if r(N) > 0 {
		if r(N) != 1 local pl "s" 
		di as txt "(" r(N) `" missing value`pl' generated)"'
	}
end

mata: 

void pchipolate(string scalar yvarname, 
                string scalar xvarname, 
	        string scalar tousename, 
	        string scalar zvarname, 
	        string scalar zmissname
	) { 

real matrix xyvar    
real colvector x, y, where 

st_view(xyvar, ., (xvarname, yvarname), tousename) 
x = select(xyvar[,1], (xyvar[,2] :< .)) 
where = select(xyvar[,1], (xyvar[,2] :== .)) 
y = select(xyvar[,2], (xyvar[,2] :< .)) 
st_store(., zvarname, zmissname, pchip(x, y, where))   

}

real colvector pchip(real colvector x, real colvector y, real colvector u)
{ 
	real scalar n, nu, k, j
	real colvector h, delta, d, c, b, which, s  

	n = length(x) 
	h = x[2::n] - x[1::n-1] 
	delta = (y[2::n] - y[1::n-1]) :/ h
	d = pchipslopes(h, delta)

	c = (3*delta - 2*d[1::n-1] - d[2::n]) :/ h
	b = (d[1::n-1] - 2*delta + d[2::n]) :/ (h:^2)

	nu = length(u) 
        k = J(nu, 1, 1)
	for (j = 2; j <= n-1; j++) { 
		which = select((1::nu), x[j] :<= u)		
		k[which] = J(length(which), 1, j)
	}

	s = u - x[k]
	return(y[k] + s :* (d[k] + s :* (c[k] + s :* b[k]))) 
}

real colvector function pchipslopes(real colvector h, real colvector delta) {
	real scalar n 
	real colvector d, k, w1, w2
	n = length(h) + 1
	d = J(n, 1, 0)
	k = 1 :+ select((1::n-2), sign(delta[1::n-2]) :* sign(delta[2::n-1]) :> 0) 
	w1 = 2*h[k] + h[k:-1]
	w2 = h[k] + 2*h[k:-1]
	d[k] = (w1 + w2) :/ (w1 :/ delta[k:-1] + w2 :/ delta[k])
	d[1] = pchipend(h[1], h[2], delta[1], delta[2])
	d[n] = pchipend(h[n-1], h[n-2], delta[n-1], delta[n-2])

	return(d)
}

real scalar function pchipend(h1, h2, del1, del2) { 
	real scalar d 
	d = ((2*h1 + h2)*del1 - h1*del2) / (h1 + h2)
	if (sign(d) != sign(del1)) d = 0
        else {
		if (sign(del1) != sign(del2) & (abs(d) > abs(3*del1))) {
			d = 3*del1
		}
	}

	return(d) 	
}

end 
        	
