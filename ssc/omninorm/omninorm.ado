*! 2.0.0 31 August 2007 NJC 
*! 1.0.3 2328 cfb 
* omnibus normality test, Doornik and Hansen 1994
program omninorm, rclass byable(recall)
	version 9.2 
	syntax varlist(numeric ts) [if] [in] ///
	[, BY(varname) MARGinals ALLobs MISSing ]

	quietly { 
		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse
		if "`by'" != "" & "`missing'" == "" markout `touse' `by', strok 
		count if `touse' 
		if r(N) == 0 error 2000

		local nv : word count `varlist'

		if "`by'" != "" { 
			if `nv' > 1  & "`marginals'" != "" { 
				di as err ///
			"{p}by() cannot be combined with marginals for " ///
			"`nv' variables; use by:{p_end}"
				exit 198 
			}

			tempvar group 
			egen `group' = group(`by') if `touse', label  
			su `group', meanonly 
			local I = r(max)
			forval i = 1/`I' { 
				local `i' "`varlist'" 
			}
		} 
		else { 		
			if "`marginals'" != "" { 
				tokenize `varlist' 
				local I = `nv' 
			}
			else { 
				local 1 "`varlist'" 
				local I = 1 
			}
		}
		
		if "`by'`allobs'" == "" {
			local header "(n = `r(N)')"
		}	
		else if "`by'" != "" { 
			local header : var label `by' 
			if `"`header'"' == "" local header "`by'" 
		}
		else local header "variable" 
			
		tempvar which s1 s2 p1 p2 thisuse  
		tempname whichlabel 
		gen `which' = _n 
		label var `which' `"`header'"' 
		gen `s1' = "" 
		gen `s2' = "" 
		gen `p1' = "" 
		gen `p2' = "" 
		label var `s1' "D-H"
		label var `p1' "P-value"
		label var `s2' "asy."
		label var `p2' "P-value" 
		
		if "`by'`allobs'" != "" { 
			tempvar n 
			gen `n' = "" 
			label var `n' "n" 
		}

		gen byte `thisuse' = . 

		// loop over variables or groups                        
		forval i = 1/`I' { 
			if "`by'" != "" { 
				local lbl : label (`group') `i' 
				replace `thisuse' = `touse' & `group' == `i' 
			} 
			else { 
				if `nv' > 1 & "`marginals'" == "" { 
					local lbl "(all variables)" 
				}
				else { 
					local lbl : var label ``i'' 
					if `"`lbl'"' == "" local lbl "``i''" 
				} 
				local v : subinstr local `i' " " ",", all 
				replace `thisuse' = `touse' & !missing(`v') 
			} 
							
			label def `whichlabel' `i' `"`lbl'"', add  
			count if `thisuse' 

			if "`by'`allobs'" != "" { 
				replace `n' = "`r(N)'" in `i' 
			} 
			
			// leaves only last-calculated scalars in memory 
			if r(N) > 7 { 
				mata : omni_norm("``i''", "`thisuse'") 

				replace `s1' = string(r(s1), "%9.4f") in `i'  
				replace `s2' = string(r(s2), "%9.4f") in `i'  
				replace `p1' = string(r(p1), "%5.4f") in `i'  
				replace `p2' = string(r(p2), "%5.4f") in `i'  

				return scalar p_asy     = r(p2) 
				return scalar asy       = r(s2) 
				return scalar p_dhansen = r(p1) 
				return scalar dhansen   = r(s1)
			} 
			else { 
				local flag "(note: results not computable if 7 or fewer values)" 
				foreach v in s1 s2 p1 p2 { 
					replace ``v'' = "." in `i' 
				} 
				foreach s in p_asy asy p_dhansen dhansen { 
					return scalar `s' = . 
				}
			} 
		}
	}	
	
	return scalar k = cond("`marginals'" != "", 1, `nv') 
	return scalar df = 2*return(k) 

	label val `which' `whichlabel' 
	tabdisp `which' in 1/`I', cellvar(`n' `s1' `p1' `s2' `p2') 
	if "`flag'" != "" di _n as text "`flag'" 
end 

mata : 
void omni_norm(string scalar varnames, string scalar tousename) 
{ 
	real matrix Y, X, std
	real vector eval, skew, kurt, y, z1, alpha, chi, z2   
	real scalar n, p, nsq, beta, w2, delta, a, c, k, omni, omnia   

        Y = st_data(., tokens(varnames), tousename)    
	n = rows(Y); p = cols(Y) 
	Y = Y :- mean(Y) 
	Y = Y :/ sqrt(mean(Y:^2))
	symeigensystem((correlation(Y)), X, eval)
//	eval = ((eval :<= 1e-12) :* 0) + ((eval :> 1e-12) :* (1 :/ sqrt(eval)))
    eval = editmissing(1:/sqrt(edittozerotol(eval, 1e-12)), 0)
	std = Y*X*diag(eval)*X' 
	skew = mean(std:^3)
	kurt = mean(std:^4)
	nsq = n^2
	beta = 3*(nsq + 27*n - 70)*(n + 1)*(n + 3) / 
		((n - 2)*(n + 5)*(n + 7)*(n + 9)) 
	w2 = -1 + sqrt(2*(beta - 1))
	delta = 1 / sqrt(log(sqrt(w2)))
	y = skew*sqrt((w2 - 1)*(n + 1)*(n + 3)/(12*(n - 2)))
	z1 = delta*log(y + sqrt(y:^2 :+ 1))
	delta = (n - 3)*(n + 1)*(nsq + 15*n - 4)
	a = (n - 2)*(n + 5)*(n + 7)*(nsq + 27*n - 70) / (6*delta)     
	c = (n - 7)*(n + 5)*(n + 7)*(nsq + 2*n - 5) / (6*delta)       
	k = (n + 5)*(n + 7)*(n*nsq + 37*nsq + 11*n - 313) / (12*delta)  
	alpha = a :+ skew:^2*c 
	chi = (kurt :- 1 :- skew:^2)*k*2
	z2 = (((chi :/ (2*alpha)):^(1/3)) :- 1 :+ 1 :/ (9*alpha)) :* 
		sqrt(9*alpha)
   	kurt = kurt :- 3 

    	omni = z1*z1' + z2*z2'
	omnia = n/6*skew*skew' + n/24*kurt*kurt' 

	st_numscalar("r(s1)", omni) 
	st_numscalar("r(s2)", omnia) 
	st_numscalar("r(p1)", chi2tail(2*p, omni)) 
	st_numscalar("r(p2)", chi2tail(2*p, omnia)) 
}  	
end
