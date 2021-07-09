*! spectdens computes periodogram and spectral density estimate
*! v.1.0 Jan 8, 2016 Huseyin Tastan (tastan@yildiz.edu.tr)
*! v.1.1 May 25, 2016 Fixed the problem with saving output dta file

cap program drop spectdens
program define spectdens, rclass
	version 12
	syntax varname(ts) [if] [in] [, 								///
									Meanadj 						/// 
									DETrend 						///
									Weights(string) 				///
									Kernel(string) 					///
									Bandwidth(integer 0) 			///
									CONVdaniell(numlist >0 integer) ///
									CInterval 						///
									log 							///
									out(string) 					///
									noGRAPH                         ///
									replace ]
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
	}
	if regexm("`ww'",">")==0 {
		di as err "missing > in weights()"
		di as err "weights(`weights') invalid"
	}
	if regexm("`ww'","/")==1 {
		di as err "Do not use / in weights()"
		di as err "weights(`weights') invalid"
		error 184
	}
	local nw = wordcount("`ww'")
	if mod(`nw',2)!=1 {
		di as err "Total window length in weights() should be an odd number"
		di as err "weights(`weights') invalid"
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


if "`convdaniell'" != "" & "`ww'" == "" & "`kernel'" == "" {
	tempname conv wvec
	local np: word count `convdaniell'
	tokenize `convdaniell' 
		if `np'<1 {
		di in red "Convolution incorrectly specified"
		error 184
		}
		if `np'==1 {
		di "Using Daniell kernel with window `1'" 
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

}

if "`kernel'"!="" & "`ww'" == "" & "`convdaniell'" == ""{
	if "`kernel'"=="daniell" {
		local bw = ceil(0.25*`mm'^(1/5)) 
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
		local bw = ceil(0.25*`mm'^(1/5))
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

tempvar x xvar trend freq omega wave k xa xb Preal Pimaginary P Pgraph P1 S ///
		S1 SL SU logS logP CI
tempname Pmat Smat

qui{
	keep if `touse'	
	gen double `x' = `varlist'

	if "`meanadj'" == "" & "`detrend'" == "" {
		gen double `xvar' = `x' if `touse'
	}
	if "`meanadj'" != "" & "`detrend'" == "" {
		sum `x' if `touse', meanonly
		gen double `xvar' = `x'-r(mean) if `touse'
	}
	if "`detrend'" != "" {
		gen double `trend' = _n if `touse'
		reg `x' `trend' if `touse'
		predict `xvar' if `touse', resid 
	}
	gen double `k' = _n - 1 in 1/`mm'
	gen double `freq' = `k'/`n'
	gen double `omega' = 2*_pi*`freq'
	gen double `wave' = 1/`freq'
	label var `omega' "Frequency"
	label var `wave' "Wavelength (Period)"
	label var `k' "k=0,1,2,...,floor(N/2)"
    label var `omega' "Fourier Frequencies"
	label var `freq' "Natural Frequencies"
	
	fft `xvar' if `touse', gen(`xa' `xb') 
	gen double `Preal' = (2/`n')*`xa' in 1/`mm'
	gen double `Pimaginary' = -(2/`n')*`xb' in 1/`mm'
	label var `Preal' "Real part of periodogram"
	label var `Pimaginary' "Imaginary part of peridogram"

	gen double `P' = (`n'/2)*(`Preal'^2 + `Pimaginary'^2) 
	local P1 = `P'[1] 
	replace `P' = `P'[2] in 1 /* use second pergram ordinate in place of first*/
	                          /* (omega=0) for smoothing */
	tsset `k'
	keep in 1/`mm'
	gen double `S' = . 
	* use cyclical endpoints
	mata: smoothdens("`P'", "`S'")
	local wssq = r(wssq)
	local dof = 2/`wssq'

	replace `P' = `P1' in 1 // re-replace periodogram at freq 0
	gen double `Pgraph' = `P'/(4*_pi) // scale periodogram ordinate for graphing
	replace `Pgraph' = . in 1 // re-replace a missing value at freq 0 for graphing
	label var `P' "Periodogram"
	label var `S' "Spectral Density"
	label var `Pgraph' "Periodogram"

	* in logs
	if "`log'" == ""{
		gen double `SL' = `dof'*`S'/invchi2(`dof',0.975)  
		gen double `SU' = `dof'*`S'/invchi2(`dof',0.025) 
	}
	else { 
		gen double `logS' = log(`S')
		gen double `SL' = `logS'+ log(`dof'/invchi2(`dof',0.975))  
		gen double `SU' = `logS'+ log(`dof'/invchi2(`dof',0.025)) 
		gen double `logP' = log(`P')
	}
}

if "`nogr'" == ""{
	if "`cinterval'" == "" & "`log'" == ""{
		graph twoway  (scatter `Pgraph' `freq',         		  ///
									    msymbol(smcircle)         /// 
										mcolor(maroon)            /// 
										xaxis(1 2) yaxis(1 2))    ///
					   (line `S' `freq', 						  /// 
										lwidth(medthick) 		  ///	
										lcolor(blue)   			  ///
										xaxis(1 2) yaxis(1 2))    ///
                   , xmtick(#25) scale(0.9)                       ///
				     xtitle("Natural Frequencies", axis(1))       /// 
				     xtitle("", axis(2)) legend(order(2 1))		  ///
					 ytitle("Spectral Density", axis(1))          ///
					 graphregion(color(white)) 					  ///
					 title("Spectral Density of `varlist'")       ///
					 note("`nte'") 
	}
	else if "`cinterval'" == "" & "`log'" != ""{
		graph twoway (line `logS' `freq', xaxis(1 2)	 		     ///
							lcolor(blue) 					 		 /// 
							yaxis(1 2)						 		 ///
							lwidth(medthick) 				 		 ///
							xtick(#25) 						 		 /// 
							ytitle("Log Spectral Density")   		 ///
							ytitle("", axis(2))              		 ///
						, scale(0.9) xtitle("", axis(2)) 		     ///
						  legend(cols(3))                  		     ///
						  graphregion(color(white)) 		 	     ///
						  xmtick(#25)                      		     ///
						  title("Log-Spectral Density of `varlist'") ///
						  note("`nte'"))               	
	}
	else if "`cinterval'" != "" & "`log'" != ""{
		graph twoway (rarea `SL' `SU' `freq', 							 /// 
							astyle(ci) 							    	 /// 
							lcolor(black) 						    	 /// 
							legend(label(1 "95% CI"))       	    	 ///
							legend(label(2 "Log Spectral Density"))		 ///
							xaxis(1 2) yaxis(1 2))    				  	 ///
					 (line `logS' `freq', 								 /// 
							lcolor(blue) 								 /// 
							lwidth(medthick) 						     ///
							xaxis(1 2) yaxis(1 2)    					 ///
							ytitle("Log of Smoothed Spectral Density"))  ///
				     , legend(order(2 1)) legend(cols(3)) 				 ///
						xtick(#25) scale(0.9)							 ///
						note("`nte'")		 							 ///
						graphregion(color(white)) 						 ///
						xtitle("", axis(2)) 							 ///
						title("Log-Spectral Density of `varlist'") 
	}
	else {
		graph twoway (rarea `SL' `SU' `freq', xaxis(1 2) yaxis(1 2)	   	 ///
											  astyle(ci) 		 		 ///
											  lcolor(black) 	 		 ///
											  legend(label(1 "95% CI"))) ///
					 (scatter `Pgraph' `freq',         		  		     ///
											   msymbol(smcircle)  		 /// 
											   mcolor(maroon)    		 /// 
											   xaxis(1 2) yaxis(1 2))    ///
					 (line  `S' `freq', 						  		 /// 
										lwidth(medthick) 		  		 ///	
										lcolor(blue)   			  		 ///
										xaxis(1 2) yaxis(1 2))        	 ///
                     , scale(0.9) xtitle("Natural Frequencies", axis(1)) ///
					   xtitle("", axis(2)) 								 ///
					   ytitle("Spectral Density", axis(1)) 			     /// 
					   xtick(#25)										 ///	
				       graphregion(color(white)) 						 ///
					   legend(order(3 2 1)) legend(cols(3)) 			 ///
					   note("`nte'")		 							 ///
					   title("Spectral Density of `varlist'")
	}
}
else if "`nogr'" != ""{
	di "No graphical output" 
	di as text "{hline 72}"
}



if "`log'" == ""{
	mkmat `freq' `S', matrix(`Smat') 
	matname `Smat' naturalfreq Spectrum, c(.) e
	ret mat S = `Smat'
	mkmat `omega' `wave' `P', matrix(`Pmat') 
	matname `Pmat' FourierFreq Period Periodogram, c(.) e
	ret mat P = `Pmat'
	if "`cinterval'" != ""{
		mkmat `freq' `SL' `SU', matrix(`CI') 
		matname `CI' naturalfreq Lower Upper, c(.) e
		ret mat CI = `CI'
	}
}
else if "`log'" != ""{
	mkmat `freq' `S' `logS', matrix(`Smat') 
	matname `Smat' naturalfreq Spectrum LogSpectrum, c(.) e
	ret mat S = `Smat'
	mkmat `omega' `wave' `P' `logP', matrix(`Pmat') 
	matname `Pmat' FourierFreq Period Periodogram LogPergram, c(.) e
	ret mat P = `Pmat'
	if "`cinterval'" != ""{
		mkmat `freq' `SL' `SU', matrix(`CI') 
		matname `CI' naturalfreq Lower Upper, c(.) e
		ret mat CI = `CI'
	}
}
matname `wvec' weights, c(.) e
ret mat W = `wvec'
ret scalar N = `n'
ret scalar dof = `dof' 


if "`out'" != ""{
	keep `k' `freq' `omega' `wave' `Preal' `Pimaginary' `P' `S'
	rename `k' _k
	rename `freq' naturalfreq 
	rename `omega' FourierFreq 
	rename `wave' Period 
	rename `Preal' Preal 
	rename `Pimaginary' Pimaginary 
	rename `P' Periodogram 
	rename `S' Spectrum 
	
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


