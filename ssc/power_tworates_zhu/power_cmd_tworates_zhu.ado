*! version 1.0  2019-03-14 Mark Chatfield

program power_cmd_tworates_zhu, rclass

version 15
                                        
syntax,  r1(real)             /// Rate in group 1
		 irr(real)  		  /// Incidence Rate Ratio
		[n(integer 0)]        /// total sample size
		[n1(integer 0)]       /// group 1 sample size 
		[n2(integer 0)]       /// group 2 sample size
		[NRATio(real 1)]      /// theta, sample allocation ratio (N2/N1)
		[DISPersion(real 0)]  /// negative binomial dispersion parameter		
        [DURation(real 1)]    /// mu_t, average treatment duration
		[VARMethod(integer 3)] /// method for variance under null hypothesis in Zhu and Lakkis (2014)
        [Alpha(real 0.05)]    /// significance level
		[Power(real 0)]	      /// default for sample size calc is actually 0.8, see line 38
		[Beta(real 0)]        //  default for sample size calc is actually 0.2, see line 39	 

		
*(r0 and r1 used in the equations in Zhu 2014, I have switched to r1 and r2. Same with n0 and n1.) 	
tempname theta mu r2 k v1 v0
scalar `theta' = `nratio' 
scalar `mu' = `duration'
scalar `r2' = `r1'*`irr'
scalar `k' = `dispersion'		 
scalar `v1' = (1/`mu') * (1/`r1' + 1/(`theta'*`r2'))  +  (1 + `theta')*`k'/`theta'		 
scalar `v0' = (1 + `theta')^2 / (`mu' * `theta' * (`r1' + `theta'*`r2'))  +  (1 + `theta')*`k'/`theta'
if "`varmethod'" == "2" scalar `v0' = `v1'

		 

if "`n'" == "0" & "`n1'" == "0" & "`n2'" == "0" {
	/* compute sample size */
	if "`beta'" == "0" & "`power'" == "0" {
		local power = 0.8
		local beta = 1 - `power'
	}	
	if "`beta'" != "0" & "`power'" == "0" {
		local power = 1 - `beta'
	}
	if "`beta'" == "0" & "`power'" != "0" {
		local beta = 1 - `power'
	}

	local n1 = ( invnormal(1-`alpha'/2)*sqrt(`v0') + invnormal(1-`beta')*sqrt(`v1') )^2 / (log(`r2'/`r1'))^2
	local n2 = `theta'*`n1'
	local n1 = ceil(`n1') 
	local n2 = ceil(`n2') 
	local n = `n1' + `n2'
}
else {
	/* compute power */
	if "`beta'" != "0" | "`power'" != "0" {
		di as err "This program cannot compute effect size for a specific N and a specific power"
		exit 198
	}

	if "`n'" != "0" & "`n1'" != "0" {
		local n2 = `n' - `n1'
		local nratio = `n2'/`n1'
	}
	if "`n'" != "0" & "`n2'" != "0" {
		local n1 = `n' - `n2'
		local nratio = `n2'/`n1'
	}
	if "`n1'" != "0" & "`n2'" != "0" {
		local n = `n1' + `n2'
		local nratio = `n2'/`n1'
	}
	if "`n'" != "0" & "`n1'" == "0" & "`n2'" == "0" {
		local n1 = `n' / (1+`theta')
		local n1 = ceil(`n1')
		local n2 = `n' - `n1'
	}
	if "`n'" == "0" & "`n1'" != "0" & "`n2'" == "0" {
		local n2 = `theta'*`n1'
		local n2 = ceil(`n2')
		local n = `n1' + `n2'	
	}
	if "`n'" == "0" & "`n1'" == "0" & "`n2'" != "0" {
		local n1 = `n2'/`theta'
		local n1 = ceil(`n1')	
		local n = `n1' + `n2'	
	}	

	local power = normal( (sqrt(`n1')*abs(log(`r2'/`r1')) - invnormal(1-`alpha'/2)*sqrt(`v0'))/sqrt(`v1') )
	*n1 is right 
	local beta = 1 - `power'
}


/* return results */
return scalar varmethod = `varmethod'
return scalar duration = `duration'
return scalar dispersion = `k'
return scalar nratio = `nratio'
return scalar N2 = `n2'
return scalar N1 = `n1'
return scalar N = `n'
return scalar r2 = `r2'
return scalar r1 = `r1'
return scalar IRR = `irr'
return scalar alpha = `alpha'
return scalar beta = `beta'
return scalar power = `power'

end
	