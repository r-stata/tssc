*! 1.1.0 NJC 25 November 2016 
*! 1.0.0 NJC 2 February 2009 
program diptest, sort rclass 
	version 9 
	syntax varname(numeric) [if] [in] [, by(varlist) Reps(int 10000) * ] 

	quietly { 
		marksample touse
		if "`by'" != "" markout `touse' `by', strok 
		count if `touse' 
		if r(N) == 0 error 2000

		tempvar group guse runif 
		tempname dip P low high mean sim 

		if "`by'" == "" { 
			tempvar by 
			gen byte `by' = 1 
		} 

		egen `group' = group(`by') if `touse' 
		su `group' if `touse', meanonly 
		local ng = r(max) 

		gen byte `guse' = . 
		gen double `runif' = . 
		sort `touse' `group' `varlist' 

		tokenize n dip P low high mean 
		forval j = 1/6 { 
			tempvar show`j' 
  			gen `show`j'' = . 
			char `show`j''[varname] "``j''" 
			local showlist `showlist' `show`j''
		}

		format %6.4f `show2' `show3' 
 
		forval g = 1/`ng' { 
			replace `guse' = `touse' & (`group' == `g') 
	        count if `guse' 
			return scalar n_`g' = r(N) 		
			replace `show1' = r(N) if `group' == `g'	

			mata: ///
		diptest("`varlist'", "`guse'", "`dip'", "`low'", "`high'", "`mean'" )    
			return scalar dip_`g' = scalar(`dip') 
			return scalar low_`g' = scalar(`low') 
			return scalar high_`g' = scalar(`high') 
			return scalar mean_`g' = scalar(`mean') 
			replace `show2' = scalar(`dip') if `group' == `g'
			replace `show4' = scalar(`low') if `group' == `g'
			replace `show5' = scalar(`high') if `group' == `g'
			replace `show6' = scalar(`mean') if `group' == `g'

			local freq = 0 
			forval i = 1/`reps' { 
				replace `runif' = uniform() 
				mata: ///
		diptest("`runif'", "`guse'", "`sim'", "`low'", "`high'", "`mean'")
				local freq = `freq' + (scalar(`sim') > scalar(`dip')) 
			} 

			scalar `P' = `freq'/`reps' 
			return scalar P_`g' = scalar(`P') 
			replace `show3' = scalar(`P') if `group' == `g'
		} // loop over groups 
	
		bysort `touse' `group': replace `touse' = `touse' & (_n == _N) 
	}

	if `ng' == 1 list `showlist' if `touse', subvarname noobs `options' 
	else list `by' `showlist' if `touse', subvarname noobs `options' 

end 	

// diptest NJC 2 February 2009 
// based on Fortran code in 
// Hartigan, P.M. 1985. Algorithm AS 217: Computation of the dip 
// statistic to test for unimodality. Applied Statistics 34: 320-325. 
// and C code in 
// Maechler, Martin. 2003. diptest 0.25-1. http://www.r-project.org/ 

mata: 

void diptest(string scalar varname, 
	     string scalar tousename,   	
	     string scalar dipname, 
	     string scalar lowname,
	     string scalar highname, 
	     string scalar meanname
	) { 

	real colvector x, mn, mj, lcm, gcm 
	real scalar n, high, low, gcmi, gcmi1, gcmix, 
		ic, icx, icv, ig, ih, iv, ix, j, jb, je, jr, 
		k, kb, ke, kr, lcm1, lcmiv, lcmiv1, mjk, mjmjk, mnj, mnmnj 
	real scalar dx, dip, d, dl, du, dipnew   
	real scalar temp, C, t  

	x = st_data(., varname, tousename) 
      
	if (rows(x) == 0 | cols(x) == 0) { 
		errprintf("no data") 
		return
	}

	_sort(x, 1) 
	n = rows(x) 

	if (n <= 3 | x[1] == x[n]) { 
		st_numscalar(dipname, 0) 
		st_numscalar(lowname, x[1])
		st_numscalar(highname, x[n])
		st_numscalar(meanname, mean(x))
		return 
	} 

	low = 1 ; high = n ; dip = 1 / n 

	mn = 1 \ (1 :: n - 1) 
	for(j = 2; j <= n; j++) { 
		while (1) { 
	        	mnj = mn[j] 
			mnmnj = mn[mnj] 
			if (mnj == 1 | 
(mnj - mnmnj) * (x[j] - x[mnj]) < (j - mnj) * (x[mnj] - x[mnmnj])) break    
			mn[j] = mnmnj 
		}          
	} 

	mj = mn; mj[n] = n 
	for(j = 1; j < n; j++) { 
		k = n - j 
		mj[k] = k + 1 
		while (1) { 
                	mjk = mj[k] 
			mjmjk = mj[mjk] 
			if (mjk == n | 
(mjk - mjmjk) * (x[k] - x[mjk]) < (k - mjk) * (x[mjk] - x[mjmjk])) break    
			mj[k] = mjmjk 
		}        
	}
	
    p1: gcm = mn; gcm[1] = high 
	for(ic = 1; gcm[ic] > low; ic++) { 
		gcm[ic + 1] = mn[gcm[ic]] 
	}
	icx = ic 

	lcm = mn; lcm[1] = low 
	for(ic = 1; lcm[ic] < high; ic++) { 
		lcm[ic + 1] = mj[lcm[ic]] 
	}
	icv = ic 

	ig = icx; ih = icv ; ix = icx - 1; iv = 2 

	d = 0 
	if (icx != 2 | icv != 2) goto p2 
	d = 1/n 
	goto p3 

    p2: gcmix = gcm[ix] 
	lcmiv = lcm[iv] 
	if (gcmix <= lcmiv) { 
		lcmiv1 = lcm[iv - 1] 
			dx = (x[gcmix] - x[lcmiv1]) * (lcmiv - lcmiv1) / 
            (n * (x[lcmiv] - x[lcmiv1])) - (gcmix - lcmiv1 - 1) / n 

			// bug fix 25 Nov 2016: was 
		    // dx = (x[gcmix] - x[lcmiv1] * (lcmiv - lcmiv1)) / 
			// (n * (x[lcmiv] - x[lcmiv1])) - (gcmix - lcmiv1 - 1) / n 
		ix--           
		if (dx >= d) { 
			d = dx 
			ig = ix + 1 
			ih = iv 
		}
	} 
	else { 
		lcmiv = lcm[iv] 
		gcmi = gcm[ix] 
		gcmi1 = gcm[ix + 1] 
		dx = (lcmiv - gcmi1 + 1) / n - 
			(x[lcmiv] - x[gcmi1]) * (gcmi - gcmi1) / (n * (x[gcmi] - x[gcmi1]))  
		iv++          
		if (dx >= d) { 
			d = dx 
			ig = ix + 1 
			ih = iv - 1
		}
	} 

	if (ix < 1) ix = 1 
	if (iv > icv) iv = icv 
	if (gcm[ix] != lcm[iv]) goto p2 

    p3:	if (d < dip) goto done 

	dl = 0 
	if (ig != icx) {        
		for(j = ig; j < icx; j++) { 
			temp = 1/n 
			jb = gcm[j + 1] 
			je = gcm[j] 
			if ((je - jb > 1) & (x[je] != x[jb])) { 
				C = (je - jb) / (n * (x[je] - x[jb]))

				for(jr = jb; jr <= je; jr++) { 
					t = (jr - jb + 1) / n - (x[jr] - x[jb]) * C  
					if (t > temp) temp = t 
				}
			} 
	                if (dl < temp) dl = temp 
		} 	 
	}
       
        du = 0 
        if (ih != icv) {       
		for(k = ih; k < icv; k++) { 
			temp = 1/n 
			kb = lcm[k] 
			ke = lcm[k + 1] 
			if ((ke - kb > 1) & (x[ke] != x[kb])) {       
				C = (ke - kb) / (n * (x[ke] - x[kb]))
				for (kr = kb; kr <= ke; kr++) { 
					t = (x[kr] - x[kb]) * C - (kr - kb - 1) / n 
					if (t > temp) temp = t 
				}
			}			
            	        if (du < temp) du = temp 
		}
	}
	
        dipnew = du > dl ? du : dl 
	if (dip < dipnew) dip = dipnew 

	if (low == gcm[ig] & high == lcm[ih]) {
		// do nothing 
	} 
	else {
		low  = gcm[ig]; high = lcm[ih]
		goto p1 
	}

  done: st_numscalar(dipname, dip / 2) 
        st_numscalar(lowname, x[low])
	st_numscalar(highname, x[high])
	st_numscalar(meanname, mean(x[low::high]))

}

end 

