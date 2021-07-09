
/*--------------------------------------------------------------------------*/
* PROGRAM: mtebinary.ado												
* AUTHORS: Amanda E. Kowalski, Yen Tran, Ljubica Ristovska
* Date: July 2018											
*																		
* PURPOSE: 															
* Estimate the marginal treatment effects (MTE) function and associated
* treatment effects using a binary instrument and a binary endogenous 
* variable. Options for with and without covariates are available, as 
* well as certain fnctionalities for summarizing the data prior to 
* estimating the MTE.												
*																		
* STRUCTURE:															
* Defined Mata programs:														
* - 	calc_treat_eff: Computes treated/untreated outcomes and treatment 
*	    effects for different groups								
* Main .ado code:														
* - Compute summary statistics for different groups	
* - Calculate MTE/MTO/MUO and TE/TO/UO for different groups (no covariates)		
*	* Calculate MTE(p), MTO(p), MUO(p)								
*	* Calculate treated and untreated outcomes and treatment effects
*	* Graph MTE(p) and bounds										
* - Calculate SMTE/SMTO/SMUO and TE/TO/UO (with covariates)
*	* Estimate propensity scores							
*	* Derive mte(x,p), muo(x,p), and mto(x,p)						
*	* Estimate SMTE(p), SMTO(p), and SMUO(p)						
*	* Graph SMTE(p)													
*	* Calculate treated and untreated outcomes and treatment effects 																					
/*--------------------------------------------------------------------------*/


* MATA FUNCTIONS 

********************************************************************************
* MATA FUNCTION FOR DERIVING TREATED AND UNTREATED OUTCOMES AND TREATMENT EFFECTS
* FOR EACH GROUP OF INTEREST 
********************************************************************************
* This program takes as inputs the covariate component and the polynomial 
* component of a marginal function (which could be MTE([x,]p), MTO([x,]p) or 
* MUO([x,]p)), pB, and pI. The function returns the treated outcome, untreated
* outcome, and treatment effect for different groups. For example, recall that 
* MTO(x,p) = (beta_T - beta_U)X + mto(p). mto(p) is the polynomial component
* of MTO(x,p), (beta_T - beta_U)X is the covariate component of MTO(x,p). In the
* case without covariates, (beta_T - beta_U)X = 0 and mto(p) = MTO(x,p). pCx is 
* the baseline probability and pIx is the intervention probability for an 
* individual with characteristics X=x. In the case without covariates, pCx and 
* pIx are scalars. In the case with covariates, pBx and pIx are vectors.
* For example, to calculate the treated outcome for the always takers in the case
* with covariates, we can write
* E[Y_T|0<U_D<p_C] = integral(1/p_C*MTO(x,p)) (see Kowalski 2018 for derivation)
* The code below follows this formula. For different groups, the weights and the
* integral limits vary. The integrals are computed via matrix multiplication
* for efficiency.

* Inputs:
* m_outc_name: 	name of matrix containing the polynomial component of the 
* 		desired marginal function
* mu_outc_name: name of variable in data  containing the covariate component
*		of the desired marginal function 
* pC_name: name of variable in data containing the value of pC
* pI_name: name of variable in data containing the value of pI
* s_pI: local macro variable containing value of s(pI) = P(Z=1)
* cov: 	Indicator for whether to compute treatment effects with or without 
*	    covariates. Input "cov" for covariates, anything else for no covars

// ssc install outreg 

mata: 
function calc_treat_eff(string scalar m_outc_name, string scalar mu_outc_name, ///
						string scalar pC_name, string scalar pI_name, ///
						string scalar sp_I_name, string scalar treatment_name, ///
						string scalar IV_name, string scalar probC_name, ///
						string scalar weightvar_name, string scalar cov)
{	
	/* The polynomial component */
	m_outc = st_matrix(m_outc_name)   
		
	/* Number of columns in m_outc matrix */
	poly = cols(m_outc)	
	
	/* In the case with covariates */
	if (cov=="cov") {

		/* The covariate component*/
		/* Input should be a variable in data */
		mu_outc = st_data(.,mu_outc_name) 
		
		/* Baseline probability of treatment; a vector */
		/* Input should be a variable in data */
		pC = st_data(.,pC_name)	
		
		/* Intervention probability of treatment; a vector */ 
		/* Input should be a variable in data */  
		pI = st_data(.,pI_name)
		
		/* Fraction of randomized in individuals*/
		/* Input should be a variable in data */		
		sp_I = st_data(., sp_I_name)
		
		/* Treatment variable */ 
		treatment = st_data(.,treatment_name)
		
		/* IV */ 
		IV = st_data(.,IV_name)
		
		/* weightvar */ 
		weightvar = st_data(.,weightvar_name)
		
		/* Probability of being a complier */ 
		prob_C = st_data(.,probC_name) 
	
	}
	
	/* In the case without covariates */
	else {
		
		/* The covariate component*/
		/* Input should be a matrix with all values = 0*/
		mu_outc = st_matrix(mu_outc_name)
			
		/* Baseline probability of treatment; a scalar */
		/* Input should be a matrix with all values = pB*/
		pC = st_matrix(pC_name)  
	
		/* Intervention probability of treatment; a scalar */
		/* Input should be a matrix with all values = pI*/
		pI = st_matrix(pI_name)
		
		/* Fraction of randomized in individuals*/
		/* Input should be a matrix with all values = sp_I */
		sp_I = st_matrix(sp_I_name)
		
	}	
	
	/* Number of observations */
	obs = rows(mu_outc)
	
	/* First stage */
	pCI = pI - pC
	
	/* Columns of ones */
	pCmat = J(obs,1,1) 		
	pImat = J(obs,1,1)
	
	/* Create matrix of powers of pC and pI */
	for( m=1 ; m<=poly ; m++) {
		poly_m_C = pC :^ m
		poly_m_I = pI :^ m
		
		/* Create a matrix of powers of pC */
		pCmat = pCmat,poly_m_C 
		
		/* Create a matrix of powers of pI*/
		pImat = pImat,poly_m_I 
	}
	
	/* Store the limits 0 and 1 of the integral in the matrix for conformability*/
	b0mat = J(obs,poly+1,0)        
	b1mat = J(obs,poly+1,1)
	bound1 = J(obs, 1,1)
	
	/* Use the sample estimate sp_C = P(Z=0) for both cases with and */
	/* without observables, not sp_Bx for the case with observables  */
	sp_C = 1 :- sp_I 
	
	/* Take an indefinite integral of the polynomial component to obtain */
	/* coefficients of marginal functions				     */
	c_outc = polyinteg(m_outc,1) 
	c_outc = c_outc'	
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for Always Takers (AT). The weight for is 1/pC, and the limits of integration are 0 to pC */
	AToutc = mu_outc + (pCmat * c_outc - b0mat * c_outc) :/ pC  
	if (min(pC) == 0){
		minindex(pC,1,i,w) 
		numb = rows(i)
		for(j=1;j<=numb; j++){
			/* if pB =0, BToutc = Moutc evaluated at pB = 0 */
			AToutc[i[j]] = mu_outc[i[j]] + m_outc[1,1] 
		} 
	}

	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for Never Takers (NT). The weight for IU is 1/(1-pI), and the limits of integration are pI to 1 */ 
	NToutc = mu_outc + (b1mat * c_outc - pImat * c_outc) :/ (1:- pI)
	if (max(pI) ==1){
		maxindex(pI,1,i,w)
		numb = rows(i)
		for (j=1; j<=numb; j++) {
			/*  if pI = 1, IToutc = Moutc evaluated at pI = 1 */
			NToutc[i[j]] = mu_outc[i[j]] + sum(m_outc)
		}
	}
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for Compliers (C). The weight for LA is 1/(pI-pB), and the limits of integration are pB to pI */ 
	Coutc = mu_outc + (pImat * c_outc - pCmat * c_outc) :/ (pI-pC)
	if(min(abs(pCI)) ==0){
		minindex(pCI,1,i,w) // obtain the min
		numb = rows(i)
		for(j=1; j<numb+1; j++){
			/* if pC = pI, Aoutc = Moutc evaluated at pI or pC */
			Coutc[i[j]] = mu_outc[i[j]] +  pImat[i[j],1...] * c_outc
		}
	}	
	
	if (cov=="cov") {
		// compute the average SAT`o', SC`o', SNT`o'
	
		/* Average TO, UO, TE across Always takers with D=1 and Z= 0 */
			pos  = (treatment :== 1)
			AToutc1     = select(AToutc,pos)
			IV1         = select(IV,pos)
			weightvar1  = select(weightvar,pos)
			pos1 = (IV1 :== 0)
			AToutc2    = select(AToutc1,pos1)
			weightvar2 = select(weightvar1,pos1)
			AToutc     = mean(AToutc2,weightvar2)  // infact it is SAT, named as AT to simplify the code
			
		/* Average TO, UO, TE across Never takers with D=0 and Z=1 */
			pos  = (treatment :== 0)
			NToutc1 = select(NToutc,pos)
			IV1     = select(IV,pos)
			weightvar1     = select(weightvar,pos)
			pos1 = IV1 :== 1
			NToutc2 = select(NToutc1,pos1)
			weightvar2     = select(weightvar1,pos1)
			NToutc         = mean(NToutc2,weightvar2) 
		
		/* Average TO, UO, TE across compliers */
			prob_Coutc = Coutc :* prob_C
			sum_Coutc  = mean(prob_Coutc,weightvar) :* sum(weightvar) // sum of outcomes for all compliers
			sum_probs  = mean(prob_C,weightvar) :* sum(weightvar) // sum of probability of being all compliers for all compliers
			Coutc     = sum_Coutc :/ sum_probs
	}
	
	// Return results
	st_matrix("AT",AToutc)
	st_matrix("NT", NToutc)
	st_matrix("C",Coutc)
		
}
end

*********************************************
* START THE MTEBINARY.ADO MAIN PROGRAM
**********************************************

capture program drop mtebinary
program mtebinary, eclass
version 13
set scheme s2mono
syntax anything(name=0) [, poly(integer 1) reps(integer 200) ///
						seed(integer 6574358) BOOTsample(namelist) ///
						WEIGHTvar(name) GRAPHsave(name)  SUMmarize(varlist)]  

/* -------------OBTAINING INPUT VARIABLES--------------*/

gettoken depvar 0 : 0, parse ("(")
gettoken 0 weg : 0, parse ("(")
gettoken weg indepvars : weg, parse (")")
gettoken 0 indepvars : indepvars, parse(" ")
gettoken treatment 0 : weg, parse ("=")
gettoken 0 IV : 0, parse ("=") 
			
marksample touse
quietly summarize `touse'
local obs = `r(sum)'

gettoken btype bvar : bootsample, parse (" ")

/* -----------------ERROR CHECKING---------------------*/

* Check if there is only one instrument specified
local ninst: word count `IV'
if `ninst'!=1 {
	di as error "Please specify only one instrument."
	exit,clear
}

* Check if there is enough variations in covariates to estimate high order polynomial
local ncov: word count `indepvars'
if `ncov' < `poly' & `poly' > 1{
	di as error "Not enough variation in covariates to estimate a polynomial of order 2"
}
	
* Get number of distinct values for instrument
qui tabulate `IV'
local rows = `r(r)' 

* Get min and max of instrument
qui sum `IV'
local min = `r(min)'
local max = `r(max)'

* Issue the error if the specified instrument is not binary
if `rows'!=2 |`min'!=0 |`max' !=1 {
	di as error "Instrument is not binary. Please specify a binary instrument."
	exit, clear
}	
	
* Check if there is only one treatment variable specified
local nv: word count `treatment'
if `nv'!=1 {
	di as error "Please specify only one endogenous variable."
	exit, clear
}

* Check whether the treatment variable is binary

* Get number of distinct values of endogenous variable
qui tabulate `treatment'
local rows = `r(r)' 

* Get min and max of the endogenous variable
qui sum `treatment'
local min = `r(min)'
local max = `r(max)'

* Issue the error if the specified endogenous variable is not binary
if `rows'!=2 |`min'!=0 |`max' !=1 {
	di as error "Endogenous variable is not binary. Please specify a binary endogenous variable."
	exit, clear
}

* Polynomial can only be of order higher than 1 if when covariates are specified
if "`indepvars'" == ""  & `poly' > 1 {
	di as error "Non-linear polynomial MTE(x,p) must include covariates."
	di as error "Please specify covariates in indepvars(varlist) if estimating a non-linear MTE." 		
	exit, clear
}

	
/* -------------SUMMARIZE THE ESTIMATION PROCESS FOR THE USER--------------*/

di ""
di ""
di as result "Beginning Estimation of Marginal Treatment Effects (MTE) with a Binary Instrument."
di in gr "MTE has been specified as a polynomial of order `poly'."
di in gr "The number of bootstrap replication is `reps'"
if "`bootsample'" != "" di in gr "Bootstrapping using: `btype' with variable `bvar'."
if "`weightvar'" != "" di in gr "Weighting using variable `weightvar'."

* Checking if the standard errors would be calculated 
if `reps' == 0{
	di in gr "NOTE: You have specified zero bootstrap replication. No standard error will be computed"

}

* Checking for missing values and dropping missing values
if "`indepvars'" == "" local checkvars "`depvar' `IV' `treatment'"
else local checkvars "`depvar' `IV' `treatment' `indepvars'"

foreach var of varlist `checkvars' {
	qui count if `var'==.
	if `r(N)'!=0 {
		di ""
		di in gr "NOTE: There are observations with missing values for `var'."
		di in gr "These observations will be dropped entirely from ALL subsequent analyses."
	}
	qui drop if `var'==.
}

* Checking if the nointeract option is specified for the no-covariates case
if "`indepvars'"=="" & "`interact'" == "nointeract" {
	di "" 
	di ""
	di in gr "NOTE: You have specified the 'nointeract' option but no covariates are specified for the estimation of the MTE."
	di in gr "The MTE without covariates does not require interaction terms. The 'nointeract' option will be ignored."
}


* Increment the reps by 1
local reps = `reps' + 1

tempvar N wt

* Generate the weight variable
if "`weightvar'"=="" {
	gen `wt' = 1
	local weightvar "`wt'"
}

* Initializing setup
tempfile temporigin  
gen `N' = 1
label var `N' Count
quietly save "`temporigin'"
local count = 1 
local varnum = 1

/* ------------------------ COMPUTE SUMMARY STATISTICS ------------------------*/
if "`summarize'" != "" {
	
	local summarize "`summarize' `N'"
	local nsum: word count `summarize'

	foreach v of varlist `summarize' {
		if `reps' != 1{
			if `varnum' == 1 local rowname ""`v'" \ "" "
			if `varnum' > 1 & `varnum' < `nsum' local rowname "`rowname' \ "`v'" \ "" "
			if `varnum' == `nsum' local rowname "`rowname' \ "Count" \ "" "
		}
		else{
			if `varnum' == 1 local rowname ""`v'""
			if `varnum' > 1 & `varnum' < `nsum' local rowname "`rowname' \ "`v'" "		
			if `varnum' == `nsum' local rowname "`rowname' \ "Count" "
		}
		
		if `varnum' == 1 local rowname1 "`v'"
		if `varnum' >  1 & `varnum' < `=`nsum'-1' local rowname1 "`rowname1' `v'"
		if `varnum' == `nsum' local rowname1 "`rowname1' count"
	
		matrix Stat = J(`reps',6,.)
	
		* Set the seed uphere
		set seed `seed'
	
		* Begin bootstrap loop 
		* Each variable is bootstrapped separately so that we can drop 
		* missing values for each variable
		forval rep = 1/`reps' {
		
			* Load data
			use "`temporigin'", clear
			
			* Determine whether to output mean or N
			if "`v'" == "`N'" local statistic = "sum"
			else local statistic = "mean"
		
			* Issue a note that missing values will be dropped
			if `rep'==1 {
				qui count if `v'==.
				if `r(N)'!= 0 {	
					di "There are `r(N)' observations with missing values for `v'."
				}
			}
		
			* Drop all missing values for the we are computing statistics for
			qui keep if `v' != . 
	
			* Re-sample for bootstrapping, keep the first bootstrap 
			* sample as the original sample
			quietly if `rep' > 1 	{
				if "`bootsample'" == "" bsample
				if "`bootsample'" != "" bsample, `btype'(`bvar')
			}
	
			* Compute statistics for the full sample
			qui su `v' [aweight=`weightvar']	
			local RIS = `r(`statistic')'
			matrix Stat[`rep',1] = `r(`statistic')'
		
			* Compute statistics for the Always Takers, Sample with D = 1 & Z = 0
			qui su `v' if `treatment' == 1 & `IV'== 0 [aweight=`weightvar']	
			local Z0_D1 = `r(`statistic')'
			matrix Stat[`rep',2] = `Z0_D1'
	
			* Compute statistics for Never Takers, Sample with D = 0 & Z = 1
			qui su `v' if `treatment' == 0 & `IV' == 1 [aweight=`weightvar']	
			local Z1_D0  = `r(`statistic')'
			matrix Stat[`rep',4] = `Z1_D0'
	
			* Compute statistics for lottery winners enrolled in Medicaid, Sample D = 1 & Z = 1
			qui su `v' if `treatment' == 1 & `IV' == 1 [aweight=`weightvar']	
			local Z1_D1 = `r(`statistic')'
	
			* Compute statistics for lottery loser not enrolled in Medicaid, Sample D = 0 & Z = 0
			qui su `v' if `treatment' == 0 & `IV' == 0  [aweight=`weightvar']	
			local Z0_D0 = `r(`statistic')'

			* Compute probability of wining a lottery (Z=1)
			qui su `IV'   [aweight=`weightvar']	  
			local sp_I = `r(mean)'
		
			* Compute the probability of compliers among lottery losers (pC), pC = Prob(D=1|Z=0)
			qui su  `treatment' if `IV' == 0 [aweight=`weightvar']	
			local pC = `r(mean)'
			
			* Compute the probabily of compliers among lottery winners (pI), pI = Prob(D=1|Z=1)
			qui su `treatment' if `IV'== 1	[aweight=`weightvar']	
			local pI = `r(mean)'
	
			* Compute the statistics for compliers who enrolled 
			* Different calculation for N vs. men
			if "`v'" == "`N'"{
				local compD1 = ((`Z0_D1' + `Z1_D1') - (`pC' * `RIS'))
			}
			else{
				local compD1 = (`pI'*`Z1_D1'-`pC'*`Z0_D1')/(`pI'-`pC') 
			}
			
			* Compute statistics for Compliers who not enrolled
			if "`v'" == "`N'"{
				local compD0 = (`Z1_D0'+`Z0_D0'- (1-`pI')*`RIS')
			}
			else{
				local compD0 = ((1-`pC')*`Z0_D0'-(1-`pI')*`Z1_D0')/(`pI'-`pC')

			}
			* Compute statistic for Complier troups: all compliers
			* Different calculations for N vs. mean
			if "`v'" == "`N'"{
				local comp = round(`compD0' + `compD1')
			}
			else{
				* It is the weghted average of CompD1 and CompD0 by the probability of winning and losing lottery
				local comp = round(`sp_I'* `compD1' + (1-`sp_I') * `compD0')
			}
			matrix Stat[`rep',3] = `comp'
			
			if "`v'" == "`N'"{
				qui sum `v' if `IV' == 0 & `treatment' == 0
				local BU = r(sum)
				qui sum `v' if `IV' == 1 & `treatment' == 1
				local IT = r(sum)
				local Z0_D1_N  = `Z0_D1' +  `IT' - `compD1'
				local Z1_D0_N  = `Z1_D0' +  `BU' - `compD0'
				matrix Stat[`rep',2] = round(`Z0_D1_N')
				matrix Stat[`rep',4] = round(`Z1_D0_N')
	
			}
			
			* Compute the count for the 
			* Compute the difference between column (2) and (3):
			local diff1 = `Z0_D1' - `comp'
			matrix Stat[`rep',5] = `diff1'
		
			* Compute the difference between column (3) and (4):
			local diff2 = `comp' - `Z1_D0'
			matrix Stat[`rep',6] = `diff2'
		
		
		} // end the bootstrap loop
		
		local col = colsof(Stat)
		svmat Stat
		forval c = 1/`col' { 
			qui sum Stat`c'
			scalar est_`c' =  Stat[1,`c']
			scalar sd_`c'   = r(sd)
			if `reps' == 1{
				if `c' == 1 matrix sum_mat_`x' = [est_`c']
				if `c' > 1  matrix sum_mat_`x' = [sum_mat_`x',est_`c']
			}
			else{
				if `c' == 1 matrix sum_mat_`x' = [est_`c',sd_`c']
				if `c' > 1  matrix sum_mat_`x' = [sum_mat_`x',est_`c',sd_`c']
			}
		}
		
		if `varnum' == 1 matrix sum_mat = [sum_mat_`x']
		if `varnum' > 1  matrix sum_mat = [sum_mat \ sum_mat_`x'] 
		local varnum = `varnum'+1		
	
	} // end loops over list of covariates 	
	if `reps' == 1{
		local numrow = rowsof(sum_mat)
		matrix sum_mat[`numrow',5] = .
		matrix sum_mat[`numrow',6] = .
		frmttable, statmat(sum_mat) sdec(2) ///
			rtitles(`rowname') ///
			ctitles("", "All", "(1)", "(2)", "(3)", "Differences", "" \ "", "","Always","Compliers","Never","(1)-(2)","(2)-(3)"\"","","Takers","","Takers","","") ///
			title("Average Characteristics of Always Takers, Compliers and Never Takers")
		matrix colnames sum_mat = All Always_Takers Compliers Never_Takers (1)-(2) (2)-(3)
		matrix rownames sum_mat = `rowname1'
		ereturn matrix averages = sum_mat		
		
	}
	else{
		local numrow = rowsof(sum_mat)
		matrix sum_mat[`numrow',9] = .
		matrix sum_mat[`numrow',10] = .
		matrix sum_mat[`numrow',11] = .
		matrix sum_mat[`numrow',12] = .
		frmttable, statmat(sum_mat) sdec(2) substat(1) ///
			rtitles(`rowname') ///
			ctitles("", "All", "(1)", "(2)", "(3)", "Differences", "" \ "", "","Always","Compliers","Never","(1)-(2)","(2)-(3)"\"","","Takers","","Takers","","") ///
			title("Average Characteristics of Always Takers, Compliers and Never Takers")
		local colname = "All:Est All:Std_error Always_Takers:Est Always_Takers:Std_error Compliers:Est Compliers:Std_error Never_Takers:Est Never_Takers:Std_error"
		local colname = "`colname' (1)-(2):Mean (1)-(2):Std_error (2)-(3):Mean (2)-(3):Std_error"
		matrix colnames sum_mat = `colname'
		matrix rownames sum_mat = `rowname1'
		ereturn matrix averages = sum_mat

	}
	
}		

/* -------------------MTO, MUO, MTE, TO, UO, TE ESTIMATION--------------------*/

* Set the seed up
set seed `seed'

* Define matrix for Treated Outcome, Untreated Outcome and Treatment Effects		
matrix TO = J(`reps',3,.)
matrix UO = J(`reps',3,.)
matrix TE = J(`reps',3,.)

* Set the default graph name (if other is not specified by user)
if "`graphsave'" == "" {
	local graphsave "mtegraph"
	di ""
	di ""
	di in gr "NOTE: You have not specified a filename for the graph. The graph will be saved as mtegraph.pdf"
}
	
* Begin bootstrap loop
forval rep = 1/`reps' {
	
	* Load data	
	use "`temporigin'", clear		

	* Drop observations where the outcome is missing before 
	* re-sampling for the bootstrapping. The reason to drop 
	* observations with a missing outcome before re-sampling 
	* is twofold:
	* (a) By dropping missing outcomes, we cannot oversample 
	* individuals with missing values when bootstrapping
	* (b) By dropping missing outcomes, we ensure that every  
	* bootstrap sample is of equal size
	qui keep if `depvar' != . 
	
	* Re-sample for bootstrapping, keep the first bootstrap 
	* sample as the original sample
	
	quietly if `rep' > 1 	{
		if "`bootsample'" == "" bsample
		if "`bootsample'" != "" bsample, `btype'(`bvar')
	}
	
	/* --------------- MTE, MTO, MUO WITHOUT COVARIATES-----------------------*/ 
	if "`indepvars'" == "" { 				                  

		* Issue a note that bootstrapping is about to begin
		if `reps' != 1 & `rep' == 1{
			di ""
			di in gr "Starting boostrapping for the linear MTE without covariates"
			}
		
		* Indicate the bootstrap replication number
		local K = int(`reps' /50)
		forvalues k = 1/ `K'{
			if `rep' == 50 * `k' ///
			di in gr "...Bootstrap replication # `rep'"
		}
	
		* Calculate Propensity Score
		qui reg `treatment' `IV' [pweight=`weightvar']	
		qui predict pZ
		tempvar p_Z
		gen `p_Z' = pZ
		drop pZ
		* OLS Regression of Y on function of p_Z 
		* Loop over treatment values (D = 0, D = 1)
	
		forval d = 0/1 {
		
			preserve
			
			* Restrict sample (e.g., conditional on D=1, conditional on D=0)
			qui keep if `treatment' == `d'
			
			* Regress Y on Xs and specified functional form of p (e.g., linear, quadratic etc.)
			if `d' == 1 gen h_pZ = `p_Z'/2
			if `d' == 0 gen h_pZ = (1-`p_Z'^2) / (2*(1-`p_Z'))
			
			qui reg `depvar' h_pZ [pweight=`weightvar']	
			
			* Save regression results a vector of coefficients of each MUO/ MTO function					
												
			* Save the constant (coefficient of the polynomial of order 0)
			matrix M`d'O_matrix = [_b[_cons]]
				
			* Save the lambdas
			matrix M`d'O_matrix = [M`d'O_matrix,_b[h_pZ]]
			restore
			
		}
			* Rename 
			matrix mTO_matrix = M1O_matrix
			matrix mUO_matrix = M0O_matrix
			
			* compute MTE(p) = MTO(p) - MUO(p)
			matrix mTE_matrix = mTO_matrix - mUO_matrix
			
			* save coefficients of MTO, MUO, MTE of each replication in a matrix
			if `rep' == 1 {
				matrix MTO = mTO_matrix
				matrix MUO = mUO_matrix
				matrix MTE = mTE_matrix
			}
			if `rep' > 1 {
				matrix MTO = [MTO \ mTO_matrix]
				matrix MUO = [MUO \ mUO_matrix]
				matrix MTE = [MTE \ mTE_matrix]
			}
			
		/*------------------- TE, TO, UO WITHOUT COVARIATES -----------------------*/
		
		matrix mu_outc = (0)
		qui su `IV'   [aweight=`weightvar']	  
		local sp_I = `r(mean)'
		qui su  `treatment' if `IV' == 0 [aweight=`weightvar']	
		local pC = `r(mean)'
		qui su `treatment' if `IV'== 1	[aweight=`weightvar']	
		local pI = `r(mean)'
		matrix pC      = (`pC')
		matrix pI      = (`pI')
		matrix sp_I    = (`sp_I')
		local outcomes "TO UO TE"
		local groups   "AT C NT"
		foreach o of local outcomes {
			* Calculate treated outcome, untreated outcome, and 
			* treatment effects for all groups of interest 
			mata: calc_treat_eff("m`o'_matrix","mu_outc", "pC", "pI", "sp_I","","","","","")
			local iter = 1
			foreach g of local groups {
				matrix `o'[`rep', `iter'] = `g'
				local ++iter
			}
		}
	} // end the no independent variable case
	
	/* ---------------------------MTE WITH COVARIATES--------------------------*/ 
	
	if "`indepvars'" != "" {
	
		* Issue a warning that bootstrapping will take a while
		if `reps'!=1 & `rep' == 1{
			di ""
			di as result "Starting estimation of the MTE with covariates"
			di as result "NOTE: Bootstrapping for the MTE with covariates will require some time."
		}
		
		* Indicate the bootstrap replication number
		local K = int(`reps' /5)
		forvalues k = 1/ `K'{
			if `rep' == 5 * `k' ///
			di in gr "...Bootstrap replication # `rep'"
		}
		
		/* ------------ Calculate Propensity score -------------------*/
		
		* Create an alternative instrument, with the value opposite 
		* of the observed value
		gen IV_alt = ~`IV'
		
		* Estimate the propensity scores if interactions with the instrument are specified
		* Create the interaction terms
		foreach x of varlist `indepvars' {				
				qui gen _int_`x' = `IV'*`x'										
		}
		
		* Estimate propensity scores using Z, Xs and the interactions
		* between Z and Xs as the covariates and D as the dependent variable
		* We use a linear regression to predict the propensity scores. 
		* Please note that we do not censor the propensity scores here.
		* We keep the uncensored propensity scores for the MTE estimation,
		* however, we do censor them for estimating any treatment effects from
		* an MTE covariates. Propensity scores are also not censored when estimating
		* the linear MTE without covariates
			
		qui reg `treatment' `IV' `indepvars' _int* [pweight=`weightvar']
	
		qui predict pZ
		tempvar p_Z
		gen `p_Z' = pZ
		drop pZ
		* Drop individuals with missing propensity scores 
		qui drop if `p_Z' == .
		
		* Estimate the alternative propensity score, which we
		* define as having Z equal to the opposite of whatever
		* is observed for each individual. The coefficients
		* are the ones estimated in the previous regression
		
		quietly {
			
			* Generate an alternative Z that is the opposite of
			* whatever each individual has and predict the
			* propensity score with that
			gen old_IV = `IV'
			drop `IV'
			rename IV_alt `IV'
			
			* Generate alternative interactions of Z with 
			* the covariates
			foreach x of varlist `indepvars' {		
				gen alt_`x' = `IV'*`x'
				gen old_int_`x' = _int_`x'
				drop _int_`x'
				rename alt_`x' _int_`x'
				
			}
						
			* Predict the alternative propensity score
			predict p_Z_alt
			
			* Revert back to the old names
			drop `IV'
			rename old_IV `IV'
				
			foreach x of varlist `indepvars' {			
				drop _int_`x'
				rename old_int_`x' _int_`x'
			}
		}
		
		
		
		* Generate pB and pI for each individual
				
		* Determine each individual's pC
		quietly {
			
		* For randomized out individuals, the propensity score 
		* estimated in the above regression is their pC
		gen pC = `p_Z' if `IV' == 0
		
		* For randomized in individuals, the propensity score
		* estimated in the above regression ASSUMING THEIR Z=0
		* is their pC
		replace pC = p_Z_alt if `IV'==1
			
		* Determine each individual's pI
		
		* For randomized out individuals, the propensity score
		* estimated in the above regression ASSUMING THEIR Z=1
		* is their pI
		gen pI = p_Z_alt if `IV'==0
		
		* For randomized in individuals, the propensity score
		* estimated in the above regression is their pI
		replace pI = `p_Z' if `IV'==1
	
		* Censor pC and pI 
		* If pB or pI is less than 0, censor them at 0. If pC
		* or pI is greater than 1, censor them at 1.
		
		gen pC_cens = pC
		replace pC_cens = 0 if pC_cens<0
		replace pC_cens = 1 if pC_cens>1
			
		gen pI_cens = pI
		replace pI_cens = 0 if pI_cens<0
		replace pI_cens = 1 if pI_cens>1 
		
		}

		/* --------------- Estimate MTO, MUO, MTE(x,p) ----------------*/
		
		* OLS Regression of Y on function of p_Z 
		* Loop over treatment values (D = 0, D = 1)
		forval d = 0/1 {
		
			preserve
			
			* Restrict sample (e.g., conditional on D=1, conditional on D=0)
			qui keep if `treatment' == `d'
			
			* Based on the pre-specified order of polynomial of the marginal functions 
			* i.e., (MTO, MUO, MTE(x,p)), generate the polynomial as a function of p
			local p_poly_`d' ""
			forval n = 1/ `poly'{
				if `d' == 1 qui gen h_pZ_`n'_`d' = (`p_Z'^`n')/(1+`n')
				if `d' == 0 qui gen h_pZ_`n'_`d' = (1-`p_Z'^(`n'+1))/((1+`n')*(1-`p_Z'))
				local p_poly_`d' "`p_poly_`d'' h_pZ_`n'_`d'"
			}

			* Regress Y on Xs and specified functional form of p (e.g., linear, quadratic etc.)
			
			qui reg `depvar' `indepvars' `p_poly_`d'' [pweight=`weightvar']
			
					
			* Save the betas for the covariates in macro variables. The coefficients on the 
			* covariates from the above regression reflects the beta_T and beta_U, depending
			* on whether we are running the regression on the treated or the untreated
			
			matrix beta`rep'_`d' = J(1,1,.)
			
			foreach _var of varlist `indepvars' {
				scalar _b_`d'_`_var' = _b[`_var']
				matrix beta`rep'_`d'= [beta`rep'_`d',  _b_`d'_`_var']
			}
			matrix beta`rep'_`d' = beta`rep'_`d'[1,2...]
			
			if `rep' == 1 matrix beta_`d'_mat = beta`rep'_`d'
			if `rep' > 1  matrix beta_`d'_mat = [beta_`d'_mat \ beta`rep'_`d']
			
		
			* Save the  coefficients for graphing			
			if `rep' == 1 {
				foreach _var of varlist `indepvars' {
					scalar define _b1_`d'_`_var' = _b[`_var']
				}
			}

			* Save the lammas in macro variables and add them to the matrix 
			* The coefficients on the g(p) components, which we call lambdas,
			* from the above regression reflect that coefficient of polynomials
			* of the marginal functions				
			
			* Save the constant (coefficient of the polynomial of order 0)
			matrix lambda`d'O_matrix = [_b[_cons]]			
				
			* Save the lambdas
			foreach var of local p_poly_`d'{
				matrix lambda`d'O_matrix = [lambda`d'O_matrix,_b[`var']]
			}

			restore
		}
			
			
		* Rename 
		matrix lambdaTO_matrix = lambda1O_matrix
		matrix lambdaUO_matrix = lambda0O_matrix
			
		* Compute lambdaTE(p) =lambdaTO(p) - lambdaUO(p)
		matrix lambdaTE_matrix = lambdaTO_matrix - lambdaUO_matrix
			
		* save coefficients of MTO, MUO, MTE of each replication in a matrix
		if `rep' == 1 {
			matrix lambdaTO = lambdaTO_matrix
			matrix lambdaUO = lambdaUO_matrix
			matrix lambdaTE = lambdaTE_matrix
		}
		if `rep' > 1 {
			matrix lambdaTO = [lambdaTO \ lambdaTO_matrix]
			matrix lambdaUO = [lambdaUO \ lambdaUO_matrix]
			matrix lambdaTE = [lambdaTE \ lambdaTE_matrix]
		}
		
		* keep the lambda matrix of the original sample for graphing later
		if `rep' == 1 {
			matrix lambdaTE_1_matrix = lambdaTE_matrix
			matrix lambdaTO_1_matrix = lambdaTO_matrix
			matrix lambdaUO_1_matrix = lambdaUO_matrix
		}

		/*------------------- TE, TO, UO COVARIATES -----------------------*/
		* Calculate (beta_T) *X, (beta_U)*X and (beta_T - beta_U) * X
	 qui {
		gen double mu_TE = 0
		gen double mu_TO = 0
		gen double mu_UO = 0
		foreach x of varlist `indepvars'{
			replace mu_TE = mu_TE + (_b_1_`x'-_b_0_`x')*`x'
			replace mu_TO = mu_TO + (_b_1_`x')*`x'
			replace mu_UO = mu_UO + (_b_0_`x')*`x'			
		} 

		* Calculate the values of sp_I for each subgroup
		* Need to loop through in order to incorporate weights
			
		* The tag we generate is for the subgroups without Z: 
		* to get the s(pI) values
		reg `treatment' `indepvars'
		predict subgroup_IV
		
		* Sum up the number of randomized in individuals within each subgroup
		bysort subgroup_IV: egen Z_count = sum(`IV')
		bysort subgroup_IV: egen N_count = sum(`N')
		
		* Replace missing values with zeroes
		replace Z_count=0 if Z_count==.
		replace N_count=0 if N_count==.
		
		gen s_pI = Z_count/N_count
				
		drop subgroup_IV
				
		* Calculate the probability of being a complier for each individual
						
		* We use the closed form expression for the probability of 
		* being a complier
		
		gen prob_I = 0
		gen prob_1C = 0
				
		replace prob_I = 1  if `treatment'==1 & `IV'==1
		replace prob_1C = 1 if `treatment'==0 & `IV'==0
			
		gen prob_C = ((pI_cens - pC_cens)/pI_cens)*prob_I + ///
					 ((pI_cens - pC_cens)/(1-pC_cens))*prob_1C
		replace prob_C=0 if prob_C==.
		}
		
		* Calculate the treated, untreated outcome and treatement effects
		* on an individual level and then average across individuals
		
		local groups   "AT C NT"
		local outcomes "TO UO TE"
		foreach o of local outcomes {
			mata: calc_treat_eff("lambda`o'_matrix", "mu_`o'","pC_cens", "pI_cens", ///
								"s_pI","`treatment'", "`IV'","prob_C","`weightvar'","cov")
			matrix SAT`o' = AT
			matrix SC`o'  = C
			matrix SNT`o' = NT
			* output
			if `rep' == 1 matrix S`o'_mat = [SAT`o', SC`o', SNT`o']
			if `rep' >  1 matrix S`o'_mat = [S`o'_mat \ [SAT`o', SC`o', SNT`o']]
		}
			
		* Calculate the coefficients of SMTE(p), SMTO(p), SMTO(p) for 
		* displaying results)
		* MTE(TO/UO) = mu_TE(TO/UO) + mTE(/TO/UO) where the first term
		* have beta coefficients and the second term has lambda coefficients
		* SMTE(/TO/UO) =  average_mu_TE(/TO/UO) + mTE(/TO/UO)
		
		local os "TO UO TE"	
		qui foreach o of local os {
		
			qui su mu_`o' [aweight=`weightvar']
			local avg_mu_`o' = `r(mean)'
			matrix SM`o' = lambda`o'_matrix
			matrix SM`o'[1,1] = SM`o'[1,1] + `avg_mu_`o''
			if `rep' == 1 matrix SM`o'_mat = SM`o'
			if `rep' > 1  matrix SM`o'_mat = [SM`o'_mat \ SM`o']
			
		}
	} // end the independent variable case
			
	
} // end bootstrapping loop


if "`indepvars'" == "" {

	/* --------------DISPLAY RESULT FOR THE CASE WITHOUT COVARIATE -------------*/
	
	* Results for the slope and intercept of MTO(p), MUO(p), MTE(p) 	
	local matr "MTE MTO MUO"
	foreach m of local matr{
		local col = colsof(`m')
		matrix est_m = `m'[1,1...]
		svmat double `m'
		forval c  = 1/`col'{
			qui sum `m'`c' 
			scalar std_err = r(sd)
			scalar est     = est_m[1,`c']
			if `reps' != 1 matrix sum`c'  = [est,std_err]
			if `reps' == 1 matrix sum`c'  = [est]
			if `c' == 1 matrix `m'_dis = sum`c'
			if `c' >  1 matrix `m'_dis = [`m'_dis,sum`c']
			}		
	}	
	
	mat mfncs = [MTO_dis\MUO_dis\MTE_dis]
	if `reps' != 1 {
	frmttable, statmat(mfncs) substat(1) ///
             rtitles("MTO"\"" \ "MUO"\"" \ "MTE"\ "") ///
             ctitles("", "Intercept", "Slope") ///
             title("Marginal Treated Outcome, Untreated Outcome, and Treatment Effect")
	local colname "Intercept Std_err Slope Std_error"
	}
	else {
	frmttable, statmat(mfncs) ///
             rtitles("MTO" \ "MUO"\ "MTE") ///
             ctitles("", "Intercept", "Slope") ///
             title("Marginal Treated Outcome, Untreated Outcome, and Treatment Effect")
	local colname "Intercept Slope"

	}
	* Return results
	matrix  colnames MTO_dis = `colname' 
	ereturn matrix MTO = MTO_dis
	
	matrix  colnames MUO_dis = `colname' 
	ereturn matrix MUO = MUO_dis
	
	matrix  colnames MTE_dis = `colname' 
	ereturn matrix MTE = MTE_dis
	
	* Results for TO, UO, TE for Never Takers, Always Takers, and Compliers	
	* Create statistics for Untreated Outcome Test (UOT) and Treated Outcome Test (TOT)
	matrix TOT = TO[1...,1] - TO[1...,2]
	matrix UOT = UO[1...,2] - UO[1...,3]
	

	local matr "TE TO UO UOT TOT"
	foreach m of local matr {
		local col = colsof(`m')
		svmat double `m'
		forval c  = 1/`col'{
			scalar mean_`m'`c' = `m'[1,`c']
			qui sum `m'`c'
			scalar sd_`m'`c' = r(sd)
			if `reps' == 1 matrix est_`m'`c' = [mean_`m'`c']
			if `reps' != 1 matrix est_`m'`c' = [mean_`m'`c', sd_`m'`c']
			if `c' == 1 matrix est_`m' = est_`m'`c'
			if `c' > 1  matrix est_`m' = [est_`m',est_`m'`c']
			}	
	}	

	if `reps' == 1{
		matrix out_dis = [est_TO,.,est_TOT\est_UO,est_UOT,.\est_TE,.,.]
		frmttable, statmat(out_dis) varlabels  ///
             rtitles("Treated Outcome"  \ "Untreated Outcome"  \ "Treatment Effect" ) ///
             ctitles("","Always","Compliers","Never","Untreated","Treated" \"", "Takers", "", "Takers", "Outcome Test", "Outcome Test"\"","(1)","(2)","(3)","(2)-(3)","(1)-(2)") ///
             title("Average Outcome of Always Takers, Compliers, and Never Takers")
	}
	else{
		matrix out_dis = [est_TO,.,.,est_TOT\est_UO,est_UOT,.,.\est_TE,.,.,.,.]
		frmttable, statmat(out_dis) substat(1) varlabels  ///
             rtitles("Treated Outcome" \ "" \ "Untreated Outcome" \ "" \ "Treatment Effect" \ "") ///
             ctitles("","Always","Compliers","Never","Untreated","Treated" \"", "Takers", "", "Takers", "Outcome Test", "Outcome Test"\"","(1)","(2)","(3)","(2)-(3)","(1)-(2)") ///
             title("Average Outcome of Always Takers, Compliers, and Never Takers")

	}
	* Return results
	if `reps' != 1 {
		local colname "Always_Takers:est Always_Takers:std_error"
		local colname "`colname' Compliers:est Compliers:std_error"
		local colname "`colname' Never_Takers:est Compliers:std_error"
	} 
	else{
		local colname "Always_Takers:est"
		local colname "`colname' Compliers:est"
		local colname "`colname' Never_Takers:est"
	}
	matrix colnames est_TO = `colname'
	ereturn matrix Treated_Outcome = est_TO
	
	matrix colnames est_UO = `colname'
	ereturn matrix Untreated_Outcome = est_UO
	
	matrix colnames est_TE = `colname'
	ereturn matrix Treatment_Effect = est_TE

	
	// ------------------------ GRAPHICAL PRESENTATION -------------------------
	
	* Graph mte bounds
	
	/* -------------- GRAPH AVERAGES OF THE OUTCOME FOR EACH GROUP ----------------*/ 

	
	use "`temporigin'", clear
	
	qui su `depvar' if `treatment' == 1 & `IV'== 0
	local Z0_D1 = r(mean)
	
	qui su `depvar' if `treatment' == 0 & `IV' == 1 
	local Z1_D0  = r(mean)
		
	qui su `depvar' if `treatment' == 1 & `IV' == 1
	local Z1_D1 = r(mean)
	
	qui su `depvar' if `treatment' == 0 & `IV' == 0 
	local Z0_D0 = r(mean)	

	qui su `IV'     
	local sp_I = `r(mean)'
		
	qui su  `treatment' if `IV' == 0
	local pC = r(mean)					
		
	qui su `treatment' if `IV'== 1	
	local pI = `r(mean)'

	local compD1 = (`pI'*`Z1_D1'-`pC'*`Z0_D1')/(`pI'-`pC') 	
		
	local compD0 = ((1-`pC')*`Z0_D0'-(1-`pI')*`Z1_D0')/(`pI'-`pC')
	qui{
		des `depvar'
		di `r(N)'
		range t 1 `r(N)' `r(N)'  // create r(N) observation from 1 to r(N)

		gen z0_d1 = . 
		replace z0_d1 = `Z0_D1' if t <= 2  // Z0_D1
		gen z1_d0 = . 
		replace z1_d0 = `Z1_D0' if t <= 2  // Z1_D0
		gen compd1 = .
		replace compd1 = `compD1' if t <= 2		
		gen compd0 = .
		replace compd0 = `compD0' if t <= 2
		
		gen pc=.
		replace pc = 0 if t==1
		replace pc =`pC' if t==2
		
		gen pbi=.
		replace pbi=`pC' if t==1
		replace pbi=`pI' if t==2
		
		gen pi=.
		replace pi=`pI' if t==1
		replace pi= 1 if t==2
		
		local midpI = (1+`pI')/2
		local midp = (`pI'+`pC')/2
		local midpC = `pC'/2
		
		gen b_to =. 
		replace b_to = `compD1' if t<=2
		
		gen b_uo =.
		replace b_uo = `compD0' if t<=2 
	}

	graph twoway (line z0_d1 pc, lwidth(thick) ylabel(#6)lpattern(shortdash) /* 
	*/    lcolor(green) xlabel(0 `pC' "p{sub:C}" 0.25 `pI' "p{sub:I}" 0.50  0.75 1.00) )/*
	*/   (line compd1 pbi, lwidth(thick) lpattern(shortdash) lcolor(green)) /*
	*/   (line compd0 pbi, lwidth(thick) lpattern(longdash) lcolor(blue))/*	
	*/   (line z1_d0 pi, lwidth(thick) lpattern(longdash) lcolor(blue) ylabel(0 `Z0_D1' `Z1_D0' `compD1' `compD0', format(%8.2f) angle(horizontal))), /*
	*/    xscale(r(0 1)) yline(0, lcolor(black))  /*
	*/    title("Average outcomes") /*
	*/    xtitle("U{sub:D}: net unobserved cost of treatment")	/*
	*/    ytitle(`depvar') /*
	*/    legend(order (1 "Treated" 3 "Untreated") cols(2) colgap(3) symxsize(10)) /*
	*/    name(mte_average_outcomes, replace)
	
	* Graphs linear mto, muo, mte functions
	
	use "`temporigin'", clear
	qui su `depvar' if `treatment' == 1 & `IV'== 0
	local Z0_D1 = r(mean)	
	qui su `depvar' if `treatment' == 0 & `IV' == 1 
	local Z1_D0  = r(mean)		
	qui su `depvar' if `treatment' == 1 & `IV' == 1
	local Z1_D1 = r(mean)	
	qui su `depvar' if `treatment' == 0 & `IV' == 0 
	local Z0_D0 = r(mean)	
	qui su `IV'     
	local sp_I = `r(mean)'		
	qui su  `treatment' if `IV' == 0
	local pC = r(mean)				
	qui su `treatment' if `IV'== 1	
	local pI = `r(mean)'
	local compD1 = (`pI'*`Z1_D1'-`pC'*`Z0_D1')/(`pI'-`pC') 			
	local compD0 = ((1-`pC')*`Z0_D0'-(1-`pI')*`Z1_D0')/(`pI'-`pC')

	qui {
	des `depvar'
	di `r(N)'
	range t 1 `r(N)' `r(N)'  // create r(N) observation from 1 to r(N)
	
	gen to = .
	replace to = `Z0_D1' if  t==1
	replace to = `compD1' if t==2
		
	gen pto = .
	replace pto = `pC'/2 if t==1
	replace pto = (`pI'+`pC')/2 if t==2
		
	gen uo = .
	replace uo = `compD0' if t==1
	replace uo = `Z1_D0' if t==2
		
	gen puo =.
	replace puo = (`pI'+`pC')/2 if t==1
	replace puo = (1+`pI')/2 if t==2
		
	gen te = .
	replace te = MTE[1,1] if t==1 /* intercept of MTE(p) */
	replace te = `compD1' - `compD0'  if t==2 // `LATE'
		
	gen pte = .
	replace pte = 0 if t==1
	replace pte = (`pI'+`pC')/2 if t==2
		
	gen te_late = .
	replace te_late = `compD1' - `compD0' if t==2
	}	

	qui graph twoway (scatter to pto, msymbol(O) mcolor(green)) /*
	*/   (lfit to pto,range(0 1) ylabel(#6)xlabel(0 `pC'"p{sub:C}" 0.25 `pI'"p{sub:I}" 0.50  0.75 1.00) /*
	*/   ylabel(0 `Z0_D1' `Z1_D0' `compD1' `compD0' `late', format(%8.2f) angle(horizontal)) /*
	*/   lwidth(medium) lpattern(shortdash) lcolor(green)) /*
	*/   (scatter uo puo, msymbol(O) mcolor(blue)) 	/*
	*/   (lfit uo puo, range(0 1) lpattern(longdash) lcolor(blue)) /* 
	*/   (scatter te_late pte, msymbol(O) mcolor(red)) /*
	*/   (lfit te pte, range(0 1) lpattern(solid) lcolor(red)), /*
	*/   yline(0, lcolor(black)) xscale(r(0 1)) /*
	*/   xtitle("U{sub:D}: unobserved net cost of treatment") ytitle(`depvar')/*
	*/   title("MTO(p), MUO(p), MTE(p)") name(mte_linear, replace) /*
	*/   legend(order (2 "MTO(p)" 4 "MUO(p)"  6 "MTE(p)") cols(3))
	
	qui gr combine mte_average_outcomes mte_linear, ycommon 
	qui gr export `graphsave'.eps, logo(off) replace
	qui ! epstopdf `graphsave'.eps 
	
	
}
else{ /*------------ Display results for the with covariate case --------------*/
	* Return the beta cofficients
	forval d = 0/1 {
		matrix beta_`d' = beta_`d'_mat[1,1...]
		svmat beta_`d'_mat
		forval j = 1/`=colsof(beta_`d'_mat)'{
			qui sum beta_`d'_mat`j'
			if `j' == 1 matrix sd_beta_`d' = [r(sd)]
			if `j' >  1 matrix sd_beta_`d' = [sd_beta_`d',r(sd)]
		}
		matrix beta_`d' = [beta_`d' \ sd_beta_`d']
	}
	matrix colnames beta_1 = `indepvars'
	matrix rownames beta_1 = est std_error
	ereturn matrix beta_to = beta_1
	matrix colnames beta_0 = `indepvars'
	matrix rownames beta_0 = est std_error
	ereturn matrix beta_uo = beta_0
	
	
	* Display the SMTE, SMTO, SMUO coefficients
	local outc "TO UO TE"
	foreach x of local outc {	
		matrix SM`x'_est = SM`x'_mat[1,1...]
		svmat SM`x'_mat
		forval j = 1/`=colsof(SM`x'_mat)'{
			if `j' == 1  local colname1 "Intercept"
			if `j' > 1   local colname1 "`colname1', "Polynomial order `=`j'-1'"  "

			if `j' == 1 & `reps' == 1 local colname2 "Intercept"
			if `j' == 1 & `reps' != 1 local colname2 "Intercept Std_error"
			if `j' > 1  & `reps' == 1 local colname2 "`colname2' Polynomial_order_`=`j'-1' "
			if `j' > 1  & `reps' != 1 local colname2 "`colname2' Polynomial_order_`=`j'-1' Std_error"
			qui sum SM`x'_mat`j', detail
			scalar SM`x'`j'_std = r(sd)
			scalar SM`x'`j'_est = SM`x'_est[1,`j']
			if `reps' != 1 matrix SM`x'`j' = [SM`x'`j'_est, SM`x'`j'_std]
			if `reps' == 1 matrix SM`x'`j' = [SM`x'`j'_est]
			if `j'  == 1 matrix SM`x' = SM`x'`j'
			if `j'  >  1 matrix SM`x' = [SM`x',SM`x'`j']
		}	
	}
	
	matrix SM_mat = [SMTO \ SMUO \ SMTE]
	if `reps' != 1{
		frmttable, statmat(SM_mat) substat(1) ///
			rtitles("E[MTO(X,p)]" \ "" \ "E[MUO(X,p)]" \ "" \ "E[MTE(X,p)]" \ "") ///
			ctitles("", `colname1') ///
			title("Marginal Treated Outcome (E[MTO(X,p)]), Untreated Outcome (E[MUO(X,p)])," " and Treatment Effect (E[MTE(X,p)]) Coefficients")
	}
	else{
		frmttable, statmat(SM_mat) ///
			rtitles("E[MTO(X,p)]" \ "E[MUO(X,p)]" \ "E[MTE(X,p)]") ///
			ctitles("", `colname1') ///
			title("Marginal Treated Outcome (E[MTO(X,p)]), Untreated Outcome (E[MUO(X,p)])," " and Treatment Effect (E[MTE(X,p)]) Coefficients")
	
	}

	* Display TE, TO, UO for Compliers, Always Takers and Never Takers
	local outc "TO UO TE"
	
	* Return results SMTO
	matrix colnames SMTO = `colname2'
	ereturn matrix EMTO = SMTO
	* Return results SMUO
	matrix colnames SMUO = `colname2'
	ereturn matrix EMUO = SMUO
	* Return results SMTE
	matrix colnames SMTE = `colname2'
	ereturn matrix EMTE = SMTE

	foreach o of local outc{
		matrix S`o' = J(1,6,.)
		svmat S`o'_mat 
		forval j = 1/`=colsof(S`o'_mat)'{
			qui sum S`o'_mat`j'
			matrix S`o'[1,2*`j'-1] = S`o'_mat[1,`j']
			matrix S`o'[1,2*`j']   = r(sd)
		}
	}
	matrix SO_mat = [STO \ SUO \ STE]
	frmttable, statmat(SO_mat) substat(1) sdec(2) ///
		rtitles("Treated Outcome" \ "" \"Untreated Outcome"\""\ "Treatment Effect") ///
		ctitles("","Alway Takers","Compliers", "Never Takers") ///
		title("Treated Outcome, Untreated Outcome, and Treatment Effect")
		
	* Return results STO
	matrix STO = [STO[1,1],STO[1,3],STO[1,5]\STO[1,2],STO[1,4],STO[1,6]]
	matrix colnames STO = Always_Takers Compliers Never_Takers
	matrix rownames STO = Estimate Std_error
	ereturn matrix Treated_outcome = STO
	
	* Return results SUO
	matrix SUO = [SUO[1,1],SUO[1,3],SUO[1,5]\SUO[1,2],SUO[1,4],SUO[1,6]]
	matrix colnames SUO = Always_Takers Compliers Never_Takers
	matrix rownames SUO = Estimate Std_error
	ereturn matrix Untreated_outcome = SUO
	
	* Return results SUO
	matrix STE = [STE[1,1],STE[1,3],STE[1,5]\STE[1,2],STE[1,4],STE[1,6]]
	matrix colnames STE = Always_Takers Compliers Never_Takers
	matrix rownames STE = Estimate Std_error
	ereturn matrix Treatment_Effects = STE
	
	// Graph MTE(x,p), MTO(x,p), MUO(x,p) 
	* Use the original  data set, instead of the bootstrap data set
	use "`temporigin'", clear  
	
	* Calculate coefficient vectors of the average, min, and max MTE(p)
	* Recall that MTE(p)=(beta_0-beta_1)*x+mte(p), where small mte(p) is the polynomial
	* of p_Z with coefficients lambda. Therefore avg_MTE(p) = avg(beta_0*X-beta_1*X)
	* + mte(p), and so are for min, max_MTE(p)
	qui gen double mu_TE_1 = 0
	qui gen double mu_TO_1 = 0 
	qui gen double mu_UO_1 = 0
	foreach x of varlist `indepvars' {
		qui replace mu_TE_1 = mu_TE_1 + (_b1_1_`x'-_b1_0_`x')*`x' 
		qui replace mu_TO_1 = mu_TO_1 + _b1_1_`x' * `x'
		qui replace mu_UO_1 = mu_UO_1 + _b1_0_`x' * `x'
		}
	
	local outcome "TE TO UO"
	foreach o of local outcome{
		qui sum mu_`o'_1
		local avg_mu_`o' = `r(mean)'
		local min_mu_`o' = `r(min)'
		local max_mu_`o' = `r(max)'
	}
	
	qui sum `depvar'
	local obs = `r(N)'
	range p 0 1 `r(N)' // generate the propensity score for graphing
	
	foreach o of local outcome{
		qui gen m`o'p = 0 
		forvalues n = 0/`poly'{
			qui replace m`o'p = m`o'p + lambda`o'_1_matrix[1,1+`n'] * p^`n'
		}
		qui gen M`o'_avg = m`o'p + `avg_mu_`o'' // generate average MTO, MUO, MTE
	}
	// generate MTEmax and MTEmin	
	qui gen MTE_max = mTEp + `max_mu_TE'
	qui gen MTE_min = mTEp + `min_mu_TE'

	// create x list
	local covar ""
	local i = 1
	foreach x of local indepvars {
		if `i' == 1 local covar "`x'"
		if `i' > 1  local covar "`covar', `x'"
		local i = `i'+ 1
	}
	
	// Graph MTOavg, MUOavg, MTEavg
	qui graph twoway (line MTE_avg p , ylabel(#6) lwidth(medium) lcolor(red)) 	/*
		*/   (line MUO_avg p, lwidth(medium) lpattern(longdash) lcolor(blue)) 	/*
		*/   (line MTO_avg p, lwidth(medium) lpattern(shortdash) lcolor(green)),	/* 
		*/    yline(0, lcolor(black)) /*
		*/    xscale(r(0 1)) name(average_fncs, replace) title("Average MTO, MUO, MTE") /*
		*/    ytitle("`depvar'") /*
		*/    xtitle("U{sub:D}: net unobserved cost of treatment") /*
		*/    legend(order (1 "E[MTE(X,p)]:`covar'" 2 "E[MUO(X,p)]" 3 "E[MTE(X,p)]") cols(1))


	// Graph MTEmax, MTEmin, MTEavg
	qui graph twoway (line MTE_avg p, ylabel(#6) lwidth(medium) lcolor(red)) 	/*
		*/   (line MTE_min p, lwidth(medium) lpattern(longdash) lcolor(orange_red)) 	/*
		*/   (line MTE_max p, lwidth(medium) lpattern(longdash) lcolor(sienna)),	/* 
		*/    yline(0, lcolor(black)) /*
		*/    xscale(r(0 1)) name(MTE_fncs, replace) title("Bounds for MTE(X,p)")/*
		*/    ytitle("`depvar'") /*
		*/    xtitle("U{sub:D}: net unobserved cost of treatment") /*
		*/    legend(order (1 "E[MTE(X,p)]:`covar'" 2 "minMTE(x,p)" 3 "maxMTE(x,p)") cols(1))

	qui graph combine average_fncs MTE_fncs, ycommon
	qui gr export `graphsave'.eps, logo(off) replace
	qui ! epstopdf `graphsave'.eps

}

// ereturn post

* Store the number of observations in e()
qui count
ereturn scalar N = `r(N)'

* Store the number of bootstrap replications in e()
ereturn scalar reps = `reps'-1

* Store the polynomial number in e()
ereturn scalar poly = `poly'

* Reload data
	
use "`temporigin'", clear
qui cap drop pred_`depvar'
qui cap drop wt
qui cap drop N
end



