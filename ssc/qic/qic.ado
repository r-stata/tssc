*******************************************************************************
*! Version 1.1.9, 19 September 2008
*! Author: Jisheng Cui, Deakin University
*! Calculate QIC and QIC_u proposed by Pan (2001)
*! Update 30Sep06: include if, in and weight
*! Update 10Oct06: include rclass
*! Update 18Jan07: change to scalar
*! Update 25Apr 2007: change scalar p to par
*! Update 27Nov 2007: extend to general negative binomial
*! Update 04Jan 2008: Parameter in negative binomial consistent with Stata
*! Update 19Mar 2008: Restore to version 9.0 and add a trick for nodisplay
*! Update 19Sep 2008: Remove constant terms for Poisson and negative binomial
*******************************************************************************

capture program drop qic
program qic, rclass
version 9.0

	syntax varlist(ts) [if] [in] [iw fw pw] 							///
		[, I(varname) T(varname) Family(string) Link(string) Corr(string) 	///
		Exposure(varname numeric) OFFset(varname numeric) 				///
		FORCE NOCONstant ITERate(int 100) TOLerance(real 1e-6)			///
		EFORM LEVel(cilevel) NODISplay NOLOg TRace					///
		Robust NMP RGF Scale(string) ]

	tokenize `varlist'
	local dep `1'
	mac shift
	local ind `*'

	tempvar q mu1 mu2
	tempvar A Ai V T s
	local fam1 = substr("`family'", 1, 1)
	local fam2 = substr("`family'", 1, 2)
	local fam3 = substr("`family'", 1, 3)

*---------------------------------------------------------------
* 1. Gaussian
*---------------------------------------------------------------

	if ("`fam3'" == "gau" | "`fam3'" == "nor" | "`fam1'" == "") {

		if ("`fam1'" == "") {
			local family = "gau"
		}
		if ("`link'" == "") {
			local link = "iden"
		} 
		if ("`corr'" == "") {
			local corr = "exc"
		}

		local opt_f = "family(gau) "
		local opt_i = "corr(ind) "
		local opt_r = "robust "
		local opt_c = "corr(`corr') "	
		local opt_g = "i(`i') t(`t') link(`link') "
		local opt_p = "exposure(`exposure') offset(`offset') "
		local opt_v = "`nmp' `rgf' scale(`scale') "
		local opt_n = "`nodisplay' "

		#delimit ;
		local opt_d = "`force' `noconstant' iterate(`iterate') 
			tolerance(`tolerance') `eform' level(`level') 
			`nolog' `trace' " ;
		#delimi cr

		*------- in case nodisplay option suppresses non-convergence error message
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_v' `opt_d' `opt_n'
		matrix `A' = e(V)
		matrix `Ai' = syminv(`A')
		
		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_v' `opt_d' `opt_n'
		scalar par = e(df_m) + 1

		matrix `V' = e(V)
		matrix `T' = `Ai' * `V'
		matrix `s' = trace(`T')
		scalar off = `s'[1,1]

		qui predict double `mu1', mu
      		qui gen double `q' = - 0.5 * (`dep' - `mu1')^2

		sum `q', meanonly
		scalar qic = -2 * r(sum) + 2 * off
		scalar qicu = -2 * r(sum) + 2 * par

	}


*---------------------------------------------------------------
* 2. Inverse Gaussian 
*---------------------------------------------------------------

	if ("`fam2'" == "ig" ) { 
	
	if ("`link'" == "") {
			local link = "log"
		} 
		if ("`corr'" == "") {
			local corr = "exc"
		}

		local opt_f = "family(iga) "
		local opt_i = "corr(ind) "
		local opt_r = "robust "
		local opt_c = "corr(`corr') "	
		local opt_g = "i(`i') t(`t') link(`link') "
		local opt_p = "exposure(`exposure') offset(`offset') "
		local opt_v = "`nmp' `rgf' scale(`scale') "
		local opt_n = "`nodisplay' "

		#delimit ;
		local opt_d = "`force' `noconstant' iterate(`iterate') 
			tolerance(`tolerance') `eform' level(`level') 
			`nolog' `trace' " ;
		#delimi cr

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		matrix `A' = e(V)
		matrix `Ai' = syminv(`A')
	
		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
 		scalar par = e(df_m) + 1

		matrix `V' = e(V)
		matrix `T' = `Ai' * `V'
		matrix `s' = trace(`T')
		scalar off = `s'[1,1]

		qui predict double `mu1', mu
		qui gen double `q' = - `dep' / 2 / `mu1'^2 + 1 / `mu1'

		sum `q', meanonly
		scalar qic = -2 * r(sum) + 2 * off
		scalar qicu = -2 * r(sum) + 2 * par

	}


*---------------------------------------------------------------
* 3. Bernoulli/Binomial
*---------------------------------------------------------------

	if ("`fam1'" == "b" ) { 
	
		if ("`link'" == "") {
			local link = "logit"
		} 
		if ("`corr'" == "") {
			local corr = "exc"
		}

		local opt_f = "family(bin) "
		local opt_i = "corr(ind) "
		local opt_r = "robust "
		local opt_c = "corr(`corr') "	
		local opt_g = "i(`i') t(`t') link(`link') "
		local opt_p = "exposure(`exposure') offset(`offset') "
		local opt_v = "`nmp' `rgf' scale(`scale') "
		local opt_n = "`nodisplay' "

		#delimit ;
		local opt_d = "`force' `noconstant' iterate(`iterate') 
			tolerance(`tolerance') `eform' level(`level') 
			`nolog' `trace' " ;
		#delimi cr

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_v' `opt_d' `opt_n'
		matrix `A' = e(V)
		matrix `Ai' = syminv(`A')

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_v' `opt_d' `opt_n'
		scalar par = e(df_m) + 1

		matrix `V' = e(V)
		matrix `T' = `Ai' * `V'
		matrix `s' = trace(`T')
		scalar off = `s'[1,1]

		qui predict double `mu1', mu
		qui gen double `q' = `dep' * log(`mu1' / (1 - `mu1')) + log(1 - `mu1') 

		sum `q', meanonly
		scalar qic = -2 * r(sum) + 2 * off
		scalar qicu = -2 * r(sum) + 2 * par

	}


*---------------------------------------------------------------
* 4. Poisson 
*---------------------------------------------------------------

	if ("`fam2'" == "po" ) { 
	
		if ("`link'" == "") {
			local link = "log"
		} 
		if ("`corr'" == "") {
			local corr = "exc"
		}

		local opt_f = "family(poi) "
		local opt_i = "corr(ind) "
		local opt_r = "robust "
		local opt_c = "corr(`corr') "	
		local opt_g = "i(`i') t(`t') link(`link') "
		local opt_p = "exposure(`exposure') offset(`offset') "
		local opt_v = "`nmp' `rgf' scale(`scale') "
		local opt_n = "`nodisplay' "

		#delimit ;
		local opt_d = "`force' `noconstant' iterate(`iterate') 
			tolerance(`tolerance') `eform' level(`level')
			`nolog' `trace' " ;
		#delimi cr

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		matrix `A' = e(V)
		matrix `Ai' = syminv(`A')

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		scalar par = e(df_m) + 1

		matrix `V' = e(V)
		matrix `T' = `Ai' * `V'
		matrix `s' = trace(`T')
		scalar off = `s'[1,1]

		qui predict double `mu1', mu
		qui gen double `q' = `dep' * log(`mu1') - `mu1' 

		sum `q', meanonly
		scalar qic = -2 * r(sum) + 2 * off
		scalar qicu = -2 * r(sum) + 2 * par
	}

*---------------------------------------------------------------
* 5. Negative Binomial 
*---------------------------------------------------------------

	if ("`fam2'" == "nb" ) { 

		tokenize `family'			/* dispersion parameter */
		local nbpara "`2'"
		if (substr("`nbpara'",1,1) == "") {		
			local nbpara = 1		/* default = 1 */
		}

		if ("`link'" == "") {
			local link = "log"
		} 
		if ("`corr'" == "") {
			local corr = "exc"
		}

		local opt_f = "family(nbi `nbpara') "
		local opt_i = "corr(ind) "
		local opt_r = "robust "
		local opt_c = "corr(`corr') "	
		local opt_g = "i(`i') t(`t') link(`link') "
		local opt_p = "exposure(`exposure') offset(`offset') "
		local opt_v = "`nmp' `rgf' scale(`scale') "
		local opt_n = "`nodisplay' "

		#delimit ;
		local opt_d = "`force' `noconstant' iterate(`iterate') 
			tolerance(`tolerance') `eform' level(`level')
			`nolog' `trace' " ;
		#delimi cr

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		matrix `A' = e(V)
		matrix `Ai' = syminv(`A')
	
		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		scalar par = e(df_m) + 1

		matrix `V' = e(V)
		matrix `T' = `Ai' * `V'
		matrix `s' = trace(`T')
		scalar off = `s'[1,1]

		qui predict double `mu1', mu
		qui gen double `q' = `dep' * log((`nbpara' * `mu1') / (1 + `nbpara' * `mu1')) 		///
			- 1 / `nbpara' * log(1 + `nbpara' * `mu1')

		sum `q', meanonly
		scalar qic = -2 * r(sum) + 2 * off
		scalar qicu = -2 * r(sum) + 2 * par

	}

*---------------------------------------------------------------
* 6. Gamma 
*---------------------------------------------------------------

	if ("`fam3'" == "gam" ) { 
	
		if ("`link'" == "") {
			local link = "log"
		} 
		if ("`corr'" == "") {
			local corr = "exc"
		}

		local opt_f = "family(gam) "
		local opt_i = "corr(ind) "
		local opt_r = "robust "
		local opt_c = "corr(`corr') "	
		local opt_g = "i(`i') t(`t') link(`link') "
		local opt_p = "exposure(`exposure') offset(`offset') "
		local opt_v = "`nmp' `rgf' scale(`scale') "
		local opt_n = "`nodisplay' "

		#delimit ;
		local opt_d = "`force' `noconstant' iterate(`iterate') 
			tolerance(`tolerance') `eform' level(`level') 
			`nolog' `trace' " ;
		#delimi cr

		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_i' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		matrix `A' = e(V)
		matrix `Ai' = syminv(`A')
	
		*------- in case nodisplay option suppresses non-convergence error message 
		qui xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' 
		    xtgee `dep' `ind' `if' `in', `opt_f' `opt_r' `opt_c' `opt_g' `opt_p' `opt_v' `opt_d' `opt_n'
		scalar par = e(df_m) + 1

		matrix `V' = e(V)
		matrix `T' = `Ai' * `V'
		matrix `s' = trace(`T')
		scalar off = `s'[1,1]

		qui predict double `mu1', mu
		qui gen double `q' = - (`dep' / `mu1' + log(`mu1'))

		sum `q', meanonly
		scalar qic = -2 * r(sum) + 2 * off
		scalar qicu = -2 * r(sum) + 2 * par

	}


*---------------------------------------------------------------
* Display output
*---------------------------------------------------------------

		di _newline
		di in green _col(15) "QIC and QIC_u"
		di in green "___________________________________________"
		di in green _col(1) "Corr =      " in yellow %15s "`corr'" 
		di in green _col(1) "Family =    " in yellow %15s "`family'"
		di in green _col(1) "Link =      " in yellow %15s "`link'"
		di in green _col(1) "p =         " in yellow %15.0f par 
		di in green _col(1) "Trace =     " in yellow %15.3f off
		di in green _col(1) "QIC =       " in yellow %15.3f qic
		di in green _col(1) "QIC_u =     " in yellow %15.3f qicu
		di in green "___________________________________________"

*---------------------------------------------------------------
* Return values
*---------------------------------------------------------------

		return scalar qic = qic
		return scalar qicu = qicu
		return scalar trace = off
		return scalar p = par

		return local link = "`link'"
		return local family = "`family'"
		return local corr = "`corr'"

	
end
