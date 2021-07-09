*! cospectdens computes cross-periodogram and cross-spectral density estimate (co-spectrum)
*! v.1.0 Apr 1, 2016 Huseyin Tastan (tastan@yildiz.edu.tr)
*! v.1.1 May 25, 2016 Fixed the problem with saving output dta file
 
cap program drop cospectdens
program define cospectdens, rclass
	version 12
	syntax varlist(ts) [if] [in] [, 								///
									Meanadj 						/// 
									DETrend 						///
									Weights(string) 				///
									Kernel(string) 					///
									Bandwidth(integer 0) 			///
									CONVdaniell(numlist >0 integer) /// 
									out(string) 					///
									noGRAPH                         ///
									Replace ]
	marksample touse
	qui count if `touse'
	local n = r(N)
	local m = floor(`n'/2)
	local mm = `m' + 1
	if `mm'>400 {
		set matsize `mm'
		}
	if `n' == 0 {
		error 2000
	}
	_ts timevar, sort
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "Sample may not contain gaps"
		exit
	}
	local nogr "`graph'"  // default is graph
	local ww "`weights'"

	if "`ww'" != "" & "`kernel'" != "" & "`convdaniell'" != ""{
		di in red "Choose only one: weights or kernel type-bandwidth or convolution"
		error 184
	}
	if "`ww'" != "" & "`kernel'" != "" {
		di in red "Choose only one: weights or kernel type-bandwidth or convolution"
		error 184
	}
	if "`kernel'" != "" & "`convdaniell'" != ""{
		di in red "kernel type-bandwidth cannot be used with convolution"
		error 184
	}
	if "`ww'" != "" & "`convdaniell'" != ""{
		di in red "Weights and convdaniell cannot be used together"
		error 184
	}
	if "`ww'" == "" & "`kernel'" == "" & "`convdaniell'" == "" {
		local kernel "daniell" // default is Daniell kernel if no option input
		di "Using default Daniell (uniform) kernel"
	}
	if "`ww'" != "" & "`kernel'" == "" & "`convdaniell'" == ""{
	* check if weights supplied by the user include < or >
		if regexm("`ww'","<")==0 {
			di as err "missing < in weights()"
			di as err "weights(`weights') invalid"
			error 198
		}
		if regexm("`ww'",">")==0 {
			di as err "missing > in weights()"
			di as err "weights(`weights') invalid"
			error 198
		}
		if regexm("`ww'","/")==1 {
			di as err "Do not use / in weights()"
			di as err "weights(`weights') invalid"
			error 198
		}
		local nw = wordcount("`ww'")
		if mod(`nw',2)!=1 {
			di as err "Total window length in weights() should be an odd number"
			di as err "weights(`weights') invalid"
			error 198
		}

		local wei = regexr(regexr("`ww'", "<", " "), ">", " ") 
		tempname wvec
		mat `wvec' = J(`nw',1,0) 
		local bw = (`nw'-1)/2 
		local ind=0
		foreach v of local wei {
			local ind = `ind'+1 
			mat `wvec'[`ind',1] = `v'
		}  
	local nte "Weigths = `ww'"	
	}

// convolution of uniform weights
	if "`convdaniell'" != "" & "`ww'" == "" & "`kernel'" == "" {
		tempname conv wvec
		local bw ""
		local np: word count `convdaniell'
		tokenize `convdaniell' 
			if `np'<1 {
			di in red "Convolution incorrectly specified"
			error 198
			}
			if `np'==1 {
			// di "Using Daniell kernel with half-window `1'" 
			_convdaniell `1' 0
			mat `conv' = c
			}
			if `np'==2 { 
			_convdaniell `1' `2'
			mat `conv' = c
			}
			if `np'>2 {  
				forv k=1(1)`np' {
					tempname u`k' v`k'
					_convdaniell ``k'' 0
					mat `u`k'' = c  
				}
				_convvector `u1' `u2'  
				mat `v1' = c  
				forv k=3(1)`np' { 
					local kk = `k'-1
					local kkk = `k'-2 
					_convvector `v`kkk'' `u`k'' 
					mat `v`kk'' = c 
				}
			mat `conv' = `v`kk'' 
			}

	mat `wvec' = `conv'
	local nte "Convolution of Daniell kernel, lags = `convdaniell'"
	return local kernel `"convdaniell"' 
	return local lags = `"`convdaniell'"'
	local bw = (rowsof(`wvec')-1)/2
	}

	if "`kernel'"!="" & "`ww'" == "" & "`convdaniell'" == ""{
		if "`kernel'"=="daniell" {
			local bw = ceil(0.5*`mm'^(1/3)) 
			if `bandwidth' !=0 {
				local bw = `bandwidth'
			}
			
			tempname wvec
			mat `wvec' = J((2*`bw'+1),1,0) 
			local ind=0
			forv q =-`bw'(1)`bw' {
					local bb = 1/(2*`bw'+1)
					local ind = `ind'+1 
					mat `wvec'[`ind',1] = `bb'
			}
		}
		if "`kernel'"=="mdaniell" {
			local bw = ceil(0.5*`mm'^(1/3))
			if `bandwidth' !=0 {
				local bw = `bandwidth'
			}
			tempname wvec
			mat `wvec' = J((2*`bw'+1),1,0) 
			local ind=0 
			forv q =-`bw'(1)`bw' {
				local ind = `ind'+1 
				if `q'==-`bw'{ 
					mat `wvec'[`ind',1] = 1/(4*`bw')
				}
				if `q'>-`bw' & `q'<0{ 
					mat `wvec'[`ind',1] = 1/(2*`bw')
				}
				if `q'==0{ 
					mat `wvec'[`ind',1] = 1/(2*`bw')
				}
				if `q'<`bw' & `q'>0{ 
					mat `wvec'[`ind',1] = 1/(2*`bw')
				}
				if `q'==`bw'{ 
					mat `wvec'[`ind',1] = 1/(4*`bw')
				} 		
			}
		}	
		if "`kernel'"=="bartlett" {
			local bw = ceil(0.5*`mm'^(1/3))
			if `bandwidth' !=0 {
				local bw = `bandwidth'
			}
			tempname wvec
			mat `wvec' = J((2*`bw'+1),1,0) 
			local ind=0 
			forv q =-`bw'(1)`bw' { 
				local ind = `ind'+1
				mat `wvec'[`ind',1] = 1-abs(`q'/(`bw'+1))
			} 
		}
		if "`kernel'"=="parzen" {
			local bw = ceil(`mm'^(1/5))
			if `bandwidth' !=0 {
				local bw = `bandwidth'
			}
			tempname wvec
			mat `wvec' = J((2*`bw'+1),1,0) 
			local ind=0 
			forv q =-`bw'(1)`bw' {
				local ind = `ind'+1
				local c = abs(`q'/(`bw'+1))
					if `c'>=0 & `c'<0.5 {
						local bb = 1-6*`c'^2+6*`c'^3
					} 
					else if `c'>=0.5 & `c'<=1 {
						local bb = 2*(1-`c')^3
					}
					else {
						local bb = 0
					}
				mat `wvec'[`ind',1] =  `bb'
			}
		}
		if "`kernel'"=="tukey" {
			local bw = ceil((2/3)*`mm'^(1/5))
			if `bandwidth' !=0 {
				local bw = `bandwidth'
			}
			tempname wvec
			mat `wvec' = J((2*`bw'+1),1,0) 
			local ind=0 
			forv q =-`bw'(1)`bw' {
				local ind = `ind'+1
				local c = `q'/(`bw'+1)
					if `c'<=1 {
						local bb = (1+cos(_pi*`c'))/2
					} 
					else {
						local bb = 0
					}
				
				mat `wvec'[`ind',1] =  `bb'			
			}
		}
		if "`kernel'"=="qs" {
			local bw = ceil((1/2)*`mm'^(1/5))
			if `bandwidth' !=0 {
				local bw = `bandwidth'
			}
			tempname wvec
			mat `wvec' = J((2*`bw'+1),1,0) 
			local ind=0 
			forv q =-`bw'(1)`bw' {
				local ind = `ind'+1
				local c = abs(`q'/`bw')
					if `c'!=0 {
						local bb = (25/(12*_pi^2*`c'^2))*((sin(6*_pi*`c'/5)/(6*_pi*`c'/5)) - cos(6*_pi*`c'/5))
					} 
					else {
						local bb = 1
					} 
				mat `wvec'[`ind',1] =  `bb'
			}
		}
	local nte "kernel(lag) = `kernel'(`bw')"
	return local kernel `"`kernel'"' 
	return scalar halfbw = `bw'
	}

	// change row names of the weight vector 
	local rnames = "" 
	local rr=(rowsof(`wvec')-1)/2
	forv q =-`rr'(1)`rr' {
		local rnames = "`rnames' `q'"
	}
	mat rownames `wvec' = `rnames'

	preserve 
		
	tempvar x xvar y yvar trend freq omega wave k xa xb ya yb ///
			Pxreal Pximaginary Px Pyreal Pyimaginary Py ///
			Sx Sy Jreal Jimaginary Cospect Quadspect Amp K2 ///
			phase phasedif gain critKsq ///
	tempname Pmat Pmat2 Smat

	local nvars  : word count `varlist'
		if `nvars'<2{
			di in red "At least 2 variables needed"
			error 198
			exit
		}
		else if `nvars'==2{
			tokenize `varlist'
			local y `1'
			local x `2' 
		}
		else if `nvars'>2{
			di in red "At most 2 variables needed"
			error 198
			exit
	}		

qui{ 
		keep if `touse'	

		if "`meanadj'" == "" & "`detrend'" == "" {
			gen double `xvar' = `x' if `touse'
			gen double `yvar' = `y' if `touse'
		}
		if "`meanadj'" != "" & "`detrend'" == "" {
			sum `x' if `touse', meanonly
			gen double `xvar' = `x'-r(mean) if `touse'
			sum `y' if `touse', meanonly
			gen double `yvar' = `y'-r(mean) if `touse'
		}
		if "`detrend'" != "" {
			gen double `trend' = _n if `touse'
			reg `x' `trend' if `touse'
			predict `xvar' if `touse', resid 
			reg `y' `trend' if `touse'
			predict `yvar' if `touse', resid
		}
	
	gen double `k' = _n - 1 in 1/`mm'
	gen double `freq' = `k'/`n'
	gen double `omega' = 2*_pi*`freq'
	gen double `wave' = 1/`freq'
	label var `omega' "Frequency"
	label var `wave' "Wavelength (Period)"
	label var `k' "k=0,1,2,...,floor(N/2)"
	label var `freq' "Natural frequency"

	fft `xvar' if `touse', gen(`xa' `xb')
	gen double `Pxreal' = (2/`n')*`xa' in 1/`mm'
	gen double `Pximaginary' = -(2/`n')*`xb' in 1/`mm'
	gen double `Px' = (`n'/2)*(`Pxreal'^2 + `Pximaginary'^2) 
	label var `Pxreal' "Real part of periodogram of `x'"
	label var `Pximaginary' "Imaginary part of peridogram of `x'"
	label var `Px' "Periodogram of `x'"

	fft `yvar' if `touse', gen(`ya' `yb')
	gen double `Pyreal' = (2/`n')*`ya' in 1/`mm'
	gen double `Pyimaginary' = -(2/`n')*`yb' in 1/`mm'
	gen double `Py' = (`n'/2)*(`Pyreal'^2 + `Pyimaginary'^2) 
	label var `Pyreal' "Real part of periodogram of `y'"
	label var `Pyimaginary' "Imaginary part of peridogram of `y'"
	label var `Py' "Periodogram of `y'"

	gen double `Jreal' =  (`n'/2)*(`Pxreal'*`Pyreal' + `Pximaginary'*`Pyimaginary')  
	gen double `Jimaginary' =  (`n'/2)*(`Pxreal'*`Pyimaginary' - `Pximaginary'*`Pyreal')  
	label var `Jreal' "Real part of cross-periodogram"
	label var `Jimaginary' "Imaginary part of cross-periodogram"

	// use second pergram ordinate in place of first (omega=0) for smoothing
	local Px1 = `Px'[1] 
	replace `Px' = `Px'[2] in 1  
	local Py1 = `Py'[1] 
	replace `Py' = `Py'[2] in 1  
	local Jreal1 = `Jreal'[1]  
	replace `Jreal' = `Jreal'[2] in 1    

	keep in 1/`mm'
	gen double `Sx' = . 
	gen double `Sy' = . 
	gen double `Cospect' = . 
	gen double `Quadspect' = . 
	* use cyclical endpoints
	mata: smoothdens("`Px'", "`Sx'")
	local wssq = r(wssq)
	local dof = 2/`wssq'
	mata: smoothdens("`Py'", "`Sy'")
	mata: smoothdens("`Jreal'", "`Cospect'")
	mata: smoothdens2("`Jimaginary'", "`Quadspect'")

	gen double `Amp' = sqrt(`Cospect'^2 + `Quadspect'^2)
	gen double `K2' = `Amp'^2 / (`Sx'*`Sy')
	gen double `phase' = atan(`Quadspect'/`Cospect')
	gen double `phasedif' = `phase'/`omega'
	gen double `gain' = abs(`Amp')/`Sx'
	label var  `Sx' "Spectral density of `x'"
	label var  `Sy' "Spectral density of `y'"
	label var `Cospect' "Co-spectrum between `x' and `y'"
	label var `Quadspect' "Quadrature Spectrum"
	label var `Amp' "Amplitude of cross-spectrum"
	label var `K2' "Coherency-Squared"
	label var `phase' "Phase spectrum"
	label var `phasedif' "Phase difference in time units" // if phasedif>0 then x is leading y and vice versa
	label var `gain' "Gain spectrum" // slope from spectral reg of y on x 

	replace `Px' = `Px1' in 1 // re-replace periodogram at freq 0
	replace `Py' = `Py1' in 1
	replace `Jreal' = `Jreal1' in 1  

	mkmat `k' `freq' `omega' `wave' `Jreal' `Jimaginary' `Cospect' `Quadspect' `Amp' `K2' `phase', matrix(`Pmat') //nomissing
	matname `Pmat' k freq omega wave Jreal Jimaginary Cospect Quadspect Amp K2 phase, c(.) e
	ret mat P = `Pmat'

	matname `wvec' weights, c(.) e
	ret mat W = `wvec'
	ret scalar N = `n'
	ret scalar dof = `dof' 

	// confidence interval for phase spectrum 
	tempvar phase_ phase_L phase_U
	// Formula on p.219 Bloomfield  (eq.10.11)
	// gen double `phase_' = (1.96/2*_pi)*sqrt((`wssq'/2)*((1/`K2')-1))
	// Formula on p.219 Bloomfield (eq.10.12) (better approx.) 
	gen double `phase_' = (1/(2*_pi))*asin(invttail(`dof'-2,0.05)*sqrt((`wssq'/(2*(1-`wssq')))*(1/`K2'-1))) 
	gen double `phase_L' = `phase' - `phase_'
	gen double `phase_U' = `phase' + `phase_'
	label var `phase_L' "Lower bound of the 95% CI for phase spectrum"
	label var `phase_U' "Upper bound of the 95% CI for phase spectrum"
	// Note that phase should be interpreted at the frequencies where K2 is significant


	// the following is valid if weights are equal 
	// local Fcv = invF(2,4*`bw',0.95)
	// gen double `critKsq' = `Fcv'/(2*`bw'+`Fcv')

	// 5% threshold value for the significance of Cohsq for general weight function (Bloomfield, 2000, p.221) 
	gen double `critKsq' = 1-20^(-(`wssq'/(1-`wssq')))
	label var `critKsq' "5% Threshold value"
		
	// graph
	if "`nogr'" == ""{
		cap graph drop _all
		tw (connected  `K2' `freq') (line `critKsq' `freq'), ylabel(0(0.1)1) ///
				note("Note: Values of coherency-squared above threshold are significant at 5% level" ///
				"`nte'")
	} 

}

	if "`out'" != ""{
		keep `k' `freq' `omega' `wave' `Pxreal' `Pximaginary' `Pyreal' `Pyimaginary' /// 
			 `Px' `Py' `Sx' `Sy' `Jreal' `Jimaginary' `Cospect' `Quadspect'  `K2'   ///
			 `critKsq' `Amp' `phase' `phase_L' `phase_U' `phasedif' `gain'
		rename `k' kindex 
		rename `freq' naturalfreq 
		rename `omega' Fourierfreq 
		rename `wave' period 
		rename `Pxreal' Pxreal 
		rename `Pximaginary' Pximag 
		rename `Pyreal' Pyreal
		rename `Pyimaginary' Pyimag 
		rename `Px' Pgramx 
		rename `Py' Pgramy 
		rename `Sx' Spdensx
		rename `Sy' Spdensy 
		rename `Jreal' Jreal
		rename `Jimaginary' Jimag 
		rename `Cospect' Cospect 
		rename `Quadspect' Quadspect 
		rename `K2' Cohsq
		rename `critKsq' Cohsq_threshold 
		rename `Amp' Amplitude
		rename `phase' Phase 
		rename `phasedif' PhaseDiff
		rename `gain' Gain 
		rename `phase_L' phase_L
		rename `phase_U' phase_U 
		
		capture confirm file "`out'.dta"  
		if _rc==0 {
			if "`replace'" != "" {
				qui save `"`out'"', replace
			}
			else {
				di as error "File `out'.dta already exists"
				exit
			}	
		}
		else {
			qui save `"`out'"'
		}
	}

restore 
end

// sub-programs

	program define _convdaniell 
		args c1 c2
		local m = 2*`c1'+1
		local n = 2*`c2'+1
		tempname a b c 
		mat `a' = J(`m',1,1/`m')
		mat `b' = J(`n',1,1/`n')
		local h = max(`m'+`n'-1,`m',`n')
		mat c = J(`h',1,0)
		forv k=1(1)`h' {
			local sum = 0
			forv j=1(1)`m' {
				if `k'>=`j' & (`k'-`j'+1)<=`n' {
				local sum = `sum' + `a'[`j',1]*`b'[`k'-`j'+1,1] 
				}
			}
			mat c[`k',1] = `sum'
		}

	end

	program define _convvector
		args u v 
		local m = rowsof(`u')
		local n = rowsof(`v') 
		local h = max(`m'+`n'-1,`m',`n') 
		mat c = J(`h',1,0)
		forv k=1(1)`h' {
			local sum = 0
			forv j=1(1)`m' {
				if `k'>=`j' & (`k'-`j'+1)<=`n' {
				local sum = `sum' + `u'[`j',1]*`v'[`k'-`j'+1,1] 
				}
			}
			mat c[`k',1] = `sum'
		}
	end

	version 12
	mata:
	void smoothdens(string scalar varname1, string scalar varname2)
		{ 
		 w = st_matrix(st_local("wvec"))
		 w = w/colsum(w)
		 q = rows(w)
		 b = (q-1)/2 
		 Pmat = st_data(., varname1) 
		 real matrix S
		 st_view(S=.,., varname2)
		 m = rows(Pmat)
		 P = Pmat[(1..m),.]
		 P = (P[(b+1..2),.]\P\P[(m-1..m-b),.])
		  
		 for(i=1+b; i<=m+b; i++) { 
			S[i-b,.] = w'*P[(i-b..i+b),.] :/(4*pi()) 
		 }
		 st_numscalar("r(wssq)",w'*w)
		 st_replacematrix(st_local("wvec"),w) 
		 }
	end

	version 12
	mata:
	void smoothdens2(string scalar varname1, string scalar varname2)
		{ 
		 w = st_matrix(st_local("wvec"))
		 w = w/colsum(w)
		 q = rows(w)
		 b = (q-1)/2 
		 Pmat = st_data(., varname1) 
		 real matrix S
		 st_view(S=.,., varname2)
		 m = rows(Pmat)
		 P = Pmat[(1..m),.]
		 P = (-1*P[(b+1..2),.]\P\-1*P[(m-1..m-b),.])
		  
		 for(i=1+b; i<=m+b; i++) { 
			S[i-b,.] = w'*P[(i-b..i+b),.] :/(4*pi()) 
		 }
		 st_numscalar("r(wssq)",w'*w)
		 st_replacematrix(st_local("wvec"),w)
		 }
	end

