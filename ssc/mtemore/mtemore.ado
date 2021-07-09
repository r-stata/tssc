
/*--------------------------------------------------------------------------*/
* PROGRAM: mtebinary.ado												
* AUTHORS: Amanda E. Kowalski, Yen Tran, Ljubica Ristovska											
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
* - 	der_MUO: uses the polynomial component of AUO([x,]p) to compute the	
* 	polynomial component muo(p) in MUO([x,]p)							
* - 	der_MTO: uses the polynomial component of ATO([x,]p) to compute the	
*	polynomial component mto(p) in MTO([x,]p)							
* - 	calc_treat_eff: Computes treated/untreated outcomes and treatment 
*	effects for different groups								
* - 	der_RMSD: computes the unexplained treatment effect heterogeneity
*	remaining after including covariates (and returns an RMSD)											
* Main .ado code:														
* - Compute summary statistics for different groups	
* - (Optional) Run the tests for internal and external validity			
* - Calculate MTE/MTO/MUO and TE/TO/UO for different groups (no covariates)		
*	* Calculate MTE(p), MTO(p), MUO(p)								
*	* Calculate treated and untreated outcomes and treatment effects
*	* (Optional) Selection vs. Treatment effect decomposition												
*	* (Optional) OLS decomposition												
*	* Graph MTE(p) and bounds										
* - Calculate SMTE/SMTO/SMUO and TE/TO/UO (with covariates)
*	* Estimate propensity scores							
*	* Estimate ATO(x,p) and AUO(x,p)									
*	* Derive mte(x,p), muo(x,p), and mto(x,p)						
*	* Estimate SMTE(p), SMTO(p), and SMUO(p)						
*	* Graph SMTE(p)													
*	* Calculate treated and untreated outcomes and treatment effects 																					
/*--------------------------------------------------------------------------*/

*********************************************
* MATA FUNCTION FOR DERIVING muo([x,]p)
*********************************************
* Recall that MUO(x,p) = X*beta_U + muo(p). This Mata function takes as 
* input the polynomial component of AUO(x,p) to compute muo(x,p). 
* In the case without covariates, the polynomial component of  
* AUO(x,p) = AUO(p), and therefore this function derives the MUO(p).

clear mata
mata:
function der_MUO(AUO_matrix)
{
	cm = st_matrix(AUO_matrix)
	
	/* Multiply AUO([x,]p) by (1-p) */
	for_der_MUO = polymult(cm, (1, -1)) 
	
	/* Take the derivative of (1-p)AUO([x,]p) with respect to p */ 
	muo_neg = polyderiv(for_der_MUO, 1) 
	
	/* Multiply the derivative by -1 (because we took the derivative*/
	/* with respect to p instead of 1-p)	*/
	muo = polymult(muo_neg, (-1))  
	
	/* Return matrix */     
	st_matrix("muo_matrix", muo)        
}
end

*********************************************
* MATA FUNCTION FOR DERIVING mto([x,]p)
*********************************************
* Recall that MTO(x,p) = X*beta_T + mto(p). This function takes as 
* input only the polynomial component of ATO(x,p) to compute mto(x,p). 
* In the case without covariates, the polynomial component of  
* ATO(x,p) = ATO(p), and therefore this function derives the MTO(p).

mata:
function der_MTO(ATO_matrix)
{
	cm = st_matrix(ATO_matrix)
	
	/* Multiply ATO([x,]p) by p */
	for_der_ATO = polymult(cm,(0,1)) 
	
	/* Take the derivative of pATO([x,]p) with respect to p */
	MTO = polyderiv(for_der_ATO, 1) 
	
	/* Export the matrix*/ 
	st_matrix("mto_matrix", MTO)     
	}
end


*********************************************
* MATA FUNCTION FOR DERIVING TREATED AND 
* UNTREATED OUTCOMES AND TREATMENT EFFECTS
* FOR EACH GROUP OF INTEREST 
*********************************************
* This program takes as inputs the covariate component and the polynomial 
* component of a marginal function (which could be MTE([x,]p), MTO([x,]p) or 
* MUO([x,]p)), pB, and pI. The function returns the treated outcome, untreated
* outcome, and treatment effect for different groups. For example, recall that 
* MTO(x,p) = (beta_T - beta_U)X + mto(p). mto(p) is the polynomial component
* of MTO(x,p), (beta_T - beta_U)X is the covariate component of MTO(x,p). In the
* case without covariates, (beta_T - beta_U)X = 0 and mto(p) = MTO(x,p). pBx is 
* the baseline probability and pIx is the intervention probability for an 
* individual with characteristics X=x. In the case without covariates, pBx and 
* pIx are scalars. In the case with covariates, pBx and pIx are vectors.
* For example, to calculate the treated outcome for the baseline treated (BTTO) 
* in the case with covariates, we can write: 
* BTTO = integral(1/pB*MTO(x,p)) from 0 to pB (see Kowalski 2016 for derivation)
* The code below follows this formula. For different groups, the weights and the
* integral limits vary. The integrals are computed via matrix multiplication
* for efficiency.

* Inputs:
* m_outc_name: 	name of matrix containing the polynomial component of the 
* 		desired marginal function
* mu_outc_name: name of variable in data  containing the covariate component
*		of the desired marginal function 
* pB_name: name of variable in data containing the value of pB
* pI_name: name of variable in data containing the value of pI
* s_pI: local macro variable containing value of s(pI) = P(Z=1)
* cov: 	Indicator for whether to compute treatment effects with or without 
*	covariates. Input "cov" for covariates, anything else for no covars
mata: 
function calc_treat_eff(string scalar m_outc_name, string scalar mu_outc_name, string scalar pB_name, string scalar pI_name, string scalar sp_I_name, string scalar cov)
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
		pB = st_data(.,pB_name)	
		
		/* Intervention probability of treatment; a vector */ 
		/* Input should be a variable in data */  
		pI = st_data(.,pI_name)
		
		/* Fraction of randomized in individuals*/
		/* Input should be a variable in data */		
		sp_I = st_data(., sp_I_name)
	}
	
	/* In the case without covariates */
	else {
		
		/* The covariate component*/
		/* Input should be a matrix with all values = 0*/
		mu_outc = st_matrix(mu_outc_name)
		
		/* Baseline probability of treatment; a scalar */
		/* Input should be a matrix with all values = pB*/
		pB = st_matrix(pB_name)  	  
		
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
	pBI = pI - pB
	
	/* Columns of ones */
	pBmat = J(obs,1,1) 		
	pImat = J(obs,1,1)
	
	/* Create matrix of powers of pB and pI */
	for( m=1 ; m<=poly ; m++) {
		poly_m_B = pB :^ m
		poly_m_I = pI :^ m
		
		/* Create a matrix of powers of pB */
		pBmat = pBmat,poly_m_B 
		
		/* Create a matrix of powers of pI*/
		pImat = pImat,poly_m_I 
	}
	
	/* Store the limits 0 and 1 of the integral in the matrix for conformability*/
	b0mat = J(obs,poly+1,0)        
	b1mat = J(obs,poly+1,1)
	bound1 = J(obs, 1,1)
	
	/* Use the sample estimate sp_B = P(Z=0) for both cases with and */
	/* without observables, not sp_Bx for the case with observables  */
	sp_B = 1 :- sp_I 
	
	/* Take an indefinite integral of the polynomial component to obtain */
	/* coefficients of marginal functions				     */
	c_outc = polyinteg(m_outc,1) 
	c_outc = c_outc'
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for baseline treated (BT). The weight for BT is 1/pB, and the */
	/* limits of integration are 0 to pB */
	BToutc = mu_outc + (pBmat * c_outc - b0mat * c_outc) :/ pB  
	if (min(pB) == 0){
		minindex(pB,1,i,w) 
		numb = rows(i)
		for(j=1;j<=numb; j++){
			/* if pB =0, BToutc = Moutc evaluated at pB = 0 */
			BToutc[i[j]] = mu_outc[i[j]] + m_outc[1,1] 
		} 
	}	
	st_matrix("BT",BToutc)
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for baseline untreated (BU). The weight for BU is 1/(1-pB), and the */
	/* limits of integration are pB to 1 */ 
	BUoutc = mu_outc + (b1mat * c_outc - pBmat * c_outc) :/ (1:-pB)
	st_matrix("BU", BUoutc)
	if (max(pB) ==1) { 	
		/* Obtain an index of the observations with pB == 1 */
		maxindex(pB,1,i,w) 
		numb = rows(i)
		for (j=1; j<=numb; j++) {
			/* if pB =1 , BUoutc = Moutc evaluated at pB = 1*/
			BUoutc[i[j]] = mu_outc[i[j]] + sum(m_outc) 
		} 
	}	
	st_matrix("BU",BUoutc)
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for intervention treated (IT). The weight for IT is 1/pI, and the */
	/* limits of integration are 0 to pI */ 
	IToutc = mu_outc + (pImat * c_outc -  b0mat * c_outc) :/ pI
	if (min(pI) ==0) {
		minindex(pI,1,i,w)
		numb = rows(i)
		for (j=1; j<=numb ; j++) {
			/* if pI = 0, IToutc = Moutc evaluated at pI = 0*/
			IToutc[i[j]] = mu_outc[i[j]] + m_outc[1,1] 
		}
	}	
	st_matrix("IT",IToutc)
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for intervention untreated (IU). The weight for IU is 1/(1-pI), and */
	/* the limits of integration are pI to 1 */ 
	IUoutc = mu_outc + (b1mat * c_outc - pImat * c_outc) :/ (1:- pI)
	if (max(pI) ==1){
		maxindex(pI,1,i,w)
		numb = rows(i)
		for (j=1; j<=numb; j++) {
			/*  if pI = 1, IToutc = Moutc evaluated at pI = 1 */
			IUoutc[i[j]] = mu_outc[i[j]] + sum(m_outc)
		}
	}	
	st_matrix("IU", IUoutc)
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for the Randomized Intervention Sample Treated (RIST) */
	
	/* Weight for RIST from 0 to pB*/
	w1 =     1:/ (pB + (sp_I :* (pI - pB))) 
	/* Weight for RIST from pB to pI */
	w2 = sp_I :/ (pB + (sp_I :* (pI - pB))) 
	RIST1 = (mu_outc :* w1 :* pB ) + w1 :* (pBmat * c_outc - b0mat * c_outc) 
	RIST2 = (mu_outc :* w2 :* (pI - pB)) + w2:* (pImat * c_outc - pBmat * c_outc) 
	RIST = RIST1 + RIST2
	st_matrix("RIST", RIST)

	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for the Randomized Intervention Sample Untreated (RISU) */
	
	/* Weight for RISU from pB to pI */
	w1 = sp_B :/ (1 :- (sp_I :* pI  +  sp_B :* pB)) 
	/* Weight for RISU from pI to 1 */
	w2 =     1:/ (1 :- (sp_I :* pI  +  sp_B :* pB)) 
	RISU1 = (mu_outc :* w1 :* (pI - pB)) + w1 :* (pImat * c_outc  - pBmat * c_outc) 
	RISU2 = (mu_outc :* w2 :* (bound1 - pI)) + w2 :* (b1mat * c_outc - pImat * c_outc) 
	RISU = RISU1 + RISU2
	st_matrix("RISU", RISU)

	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for local average (LA). The weight for LA is 1/(pI-pB), and */
	/* the limits of integration are pB to pI */ 
	LA = mu_outc + (pImat * c_outc - pBmat * c_outc) :/ (pI-pB)
	if(min(abs(pBI)) ==0){
		minindex(pBI,1,i,w) // obtain the min
		numb = rows(i)
		for(j=1; j<numb+1; j++){
			/* if pB = pI, Aoutc = Moutc evaluated at pI or pB */
			LA[i[j]] = mu_outc[i[j]] + polyeval(m_outc,pI[i[j]]) 
		}
	}	
	st_matrix("LA",LA)
	
	/* Computing treated outcome, untreated outcome, and treatment effect */
	/* for average (A). The weight for A is 1, and */
	/* the limits of integration are 0 to 1 */ 
	Aoutc = mu_outc + b1mat * c_outc  - b0mat * c_outc
	st_matrix("A",Aoutc)
}
end

*********************************************
* MATA FUNCTION FOR DERIVING RMSD(X)
**********************************************
* The input is a matrix representing the difference between the ATE and the 
* MTE(p) in the case without covariates, or the SATE and SMTE(p) in the case
* with covariates. Since this difference is a function, the input matrix 
* represents a function. The matrix should be of the form 1 x (M+1) (one row and 
* (M+1) columns), where M is the order of the MTE(p) or SMTE(p) polynomial

mata
function der_RMSD(arg_diff_matrix)
{
	dm = st_matrix(arg_diff_matrix)
	
	/* Multiply the difference matrix by itself (i.e., square it) */
	for_int = polymult(dm, dm) 	
	
	/* Take the integral of the square from 0 to 1*/
	MSD = polyeval(polyinteg(for_int,1),1) - polyeval(polyinteg(for_int,1),0) 
	
	/* Take the square root*/
	RMSD = sqrt(MSD)	  	
	
	/* Export to Stata*/
	st_numscalar("sc_RMSD", RMSD)	
}

end

*********************************************
* START THE MTEBINARY.ADO MAIN PROGRAM
**********************************************

capture program drop mtemore
program mtemore, eclass
version 13
set scheme s2mono
syntax anything(name=0) [, poly(integer 1) reps(integer 200) 		///
			seed(integer 6574357) BOOTsample(namelist)	///
			weightvar(name) noINTeract GRAPHsave(name) 	///
			SUMmarize(varlist) DIDtest(varlist) noDEComp ]	///

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

/* -------------ERROR CHECKING--------------*/

* Check if there is only one instrument specified
local ninst: word count `IV'
if `ninst'!=1 {
	di as error "Please specify only one instrument."
	exit,clear
}

* Check if the instrument is binary
	
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

* Check that the number of reps is at least two
if `reps'<2 {
	di as error "The number of bootstrap replications must be 2 or higher."
	exit, clear
}
	
/* -------------SUMMARIZE THE ESTIMATION PROCESS FOR THE USER--------------*/

di ""
di ""
di as result "Beginning Estimation of Marginal Treatment Effects (MTE) with a Binary Instrument."
di in gr "MTE has been specified as a polynomial of order `poly'."
di in gr "Number of bootstrap replications: `reps'."
if "`bootsample'" != "" di in gr "Bootstrapping using: `btype' with variable `bvar'."
if "`weightvar'" != "" di in gr "Weighting using variable `weightvar'."

* Checking for missing values and dropping missing values
if "`indepvars'" == "" local checkvars "`depvar' `IV' `treatment'"
else local checkvars "`depvar' `IV' `treatment' `indepvars'"

foreach var of varlist `checkvars' {
	qui count if `var'==.
	if `r(N)'!=0 {
		di ""
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

/* ---------------------------COMPUTE SUMMARY STATISTICS----------------------*/

* Generate the weight variable
if "`weightvar'"=="" {
	gen wt = 1
	local weightvar "wt"
}

* If covariates are specified, predict the outcome and include it in the 
* summary statistics
if "`indepvars'" != "" {
	qui reg `depvar' `indepvars' [pweight=`weightvar'] if `IV'==0
	qui predict pred_`depvar'
	local summarize "N `depvar' `summarize' pred_`depvar'"
}
else local summarize "N `depvar' `summarize'"

* Generate a variable to help compute the sample counts
gen N = 1

* Initializing setup
tempfile temporigin  
quietly save "`temporigin'"
local rowname ""
local count = 1 

* Start loop for summary statistics variable
foreach v of varlist `summarize' {
	
	use "`temporigin'", clear
	
	* Determine whether to output mean or N 
	if "`v'" == "N" local statistic = "sum"
	else local statistic = "mean"

	local rowname "`rowname' `v'"
	
	* Create matrix for storing summary statistics
	matrix Stat = J(1,12,.) 	
	
	* Drop all missing values for the we are computing statistics for
	qui keep if `v' != .	
	
	* Compute the Randomized Intervention Sample (RIS) statistic
	* Full sample
	qui su `v' [aweight=`weightvar']		
	local RIS = `r(`statistic')' 
	matrix Stat[1,1] = `RIS'

	* Compute the Intervention statistic (lottery winners)
	* Sample with Z=1
	qui su `v' if `IV'==1 [aweight=`weightvar']	
	matrix Stat[1,2] = `r(`statistic')'

	* Compute the Baseline statistic (lottery losers)
	* Sample with Z=0
	qui su `v' if `IV'==0  [aweight=`weightvar']
	matrix Stat[1,3] = `r(`statistic')'
	
	* Compute the Randomized Intervention Sample Untreated (RISU) statistic
	* Sample with D=0
	qui su `v' if `treatment'==0 [aweight=`weightvar']
	matrix Stat[1,5] = `r(`statistic')'

	* Compute the Randomized Intervention Sample Treated (RIST) statistic
	* Sample with D=1
	qui su `v' if `treatment'==1  [aweight=`weightvar']
	matrix Stat[1,4] = `r(`statistic')'

	* Compute the Baseline Treated (BT) statistic
	* Sample with D=1 & Z=0
	qui su `v' if `treatment'==1 & `IV'==0 [aweight=`weightvar']
	local BTTO = `r(`statistic')'
	matrix Stat[1,6] = `r(`statistic')'

	* Compute the Intervention Treated (IT) statistic
	* Sample with D=1 & Z=1
	qui su `v' if `treatment'==1 & `IV'==1 [aweight=`weightvar']
	local ITTO = `r(`statistic')'
	matrix Stat[1,8] = `r(`statistic')'

	* Compute the Baseline Untreated (BU) statistic
	* Sample with D=0 & Z=0
	qui su `v' if `treatment'==0 & `IV'==0 [aweight=`weightvar']
	local BUUO = `r(`statistic')'
	matrix Stat[1,7] = `r(`statistic')'

	* Compute the Intervention Untreated (IU) statistic
	* Sample with D=0 & Z=1
	qui su `v' if `treatment'==0 & `IV'==1 [aweight=`weightvar']
	local IUUO = `r(`statistic')'
	matrix Stat[1,9] = `r(`statistic')'

	* Compute s(pI) = P(Z=1)
	qui su `IV' [aweight=`weightvar']       
	local sp_I = `r(mean)'					

	* Compute the intervention treatment probability (pI)
	* pI = Prob(D=1|Z=1)
	qui su `treatment' if `IV'==1 	[aweight=`weightvar']
	local pI = `r(mean)'
	
	* Compute the baseline treatment probability (pB)
	* pB = Prob(D=1|Z=0)
	qui su `treatment' if `IV'==0 	[aweight=`weightvar']
	local pB = `r(mean)'
	
	* Compute the Local Average Treated (LAT):treated compliers
	* Different calculations for N vs. mean
	if "`v'" == "N" {
		local LATO = ((`BTTO'+`ITTO')-(`pB'*`RIS'))
		matrix Stat[1,10] = `LATO'
	}
	else {
		local LATO = (`pI'*`ITTO'-`pB'*`BTTO')/(`pI'-`pB') 	
		matrix Stat[1,10] = `LATO'
	}
	
	* Compute the Local Average Untreated (LAU):untreated compliers
	* Different calculations for N vs. mean
	if "`v'" == "N" {
		local LAUO = ((`IUUO'+`BUUO')-((1-`pI')*`RIS'))
		matrix Stat[1,11] = `LAUO'
	}
	else {	
		local LAUO = ((1-`pB')*`BUUO'-(1-`pI')*`IUUO')/(`pI'-`pB')
		matrix Stat[1,11] = `LAUO'
	}

	* Compute the Local Average (LA): all compliers
	* Different calculations for N vs. mean
	if "`v'" == "N" {	
		local LA = `LAUO' + `LATO'
		matrix Stat[1,12] = `LA'
	}
	else {
		local LA = `sp_I' * `LATO' + (1-`sp_I') * `LAUO' 	
		matrix Stat[1,12] = `LA'
	}

	if `count' == 1 matrix Statmat = Stat
	if `count' > 1  matrix Statmat = [Statmat \ Stat]
	local ++count
		
} // close loop for summary statistics variables

* Display summary statistics output
di ""
di ""
di as result "Summary Statistics (Averages) for Characteristics and Outcomes"          
local colname = "RIS I B RIST RISU BT BU IT IU LAT LAU LA"      	                   
matrix rownames Statmat = `rowname' 
matrix colnames Statmat = `colname'
matlist Statmat, format(%8.2f) aligncolnames(center) 


/* -------------INTERNAL AND EXTERNAL VALIDITY TESTS--------------*/

* If covariates are specified, predict the outcome and include it in the 
* internal and external validity tests

local numvar = 1

if "`indepvars'" != "" local didtest "`depvar' pred_`depvar' `didtest'"
else local didtest "`depvar' `didtest'"

* Issue a note
di ""
di ""
di as result "Starting boostrapping for tests of internal and external validity"
di in gr "NOTE: Bootstrapping may take some time because each variable is bootstrapped separately."

* Begin loop for variables for validity tests
foreach v of local didtest { 

	* Set the seed up
	set seed `seed'
	
	* Begin bootstrap loop
	* Each variable is bootstrapped separately so that we can drop 
	* missing values for each variable
	forval rep = 1/`reps' {
	
		* Issue a note that bootstrapping is about to begin
		if `rep' == 1 {
			di ""
			di ""
			di in gr "Variable: `v'"
		}
		
		* Load data	
		use "`temporigin'", clear	
	
		* Issue a note that missing values will be dropped
		if `rep'==1 {
			qui count if `v'==.
			if `r(N)'!= 0 {	
				di "There are `r(N)' observations with missing values for `v'."
				di "These observations are excluded from the tests for internal and external validity."
			}
		}
		
		* Drop observations where the variable for which we are
		* computing the tests is missing
		qui keep if `v'!=.

		* Re-sample for bootstrapping, keep the first bootstrap 
		* sample as the original sample
		quietly if `rep' > 1 	{
			if "`bootsample'" == "" bsample
			if "`bootsample'" != "" bsample, `btype'(`bvar')
		}
				
		* Predict the outcome, if necessary
		if "`indepvars'" != "" {
			drop pred_`depvar'
			qui reg `depvar' `indepvars' [pweight=`weightvar'] if `IV'==0
			qui predict pred_`depvar'
		}
		
		* Indicate the bootstrap replication number
		local K = int(`reps' /50)
		forvalues k = 1/ `K'{
			if `rep' == 50 * `k' ///
			di in gr "...Bootstrap replication # `rep'"
		}
			
		* Internal validity test (Difference between Intervention
		* and Baseline groups). The internal validity test regresses W,
		* which can be a covariate, an outcome, or a predicted 
		* outcome on Z. Coefficient of Z is the same as the difference 
		* between average of W of the Intervention group and that 
		* of the Baseline group

		qui reg `v' `IV' [pweight=`weightvar']
		matrix int_`v'_`rep'= _b[`IV']
		
		* Calculate the difference between treated and untreated compliers
		
		* BT average
		quietly su `v' if `treatment'==1 & `IV'==0 [aweight=`weightvar']
		local mean_BT = `r(mean)'
		
		* IT average
		quietly su `v' if `treatment'==1 & `IV'==1 [aweight=`weightvar']
		local mean_IT = `r(mean)'	
		
		* BU average
		quietly su `v' if `treatment'==0 & `IV'==0 [aweight=`weightvar']
		local mean_BU = `r(mean)'
		
		* IU average
		quietly su `v' if `treatment'==0 & `IV'==1 [aweight=`weightvar']
		local mean_IU = `r(mean)'
		
		* Baseline treatment probability
		quietly su `treatment' if `IV' == 0 [aweight=`weightvar']
		local pB = `r(mean)'
		
		* Intervention treatment probability
		quietly su `treatment' if `IV' == 1 [aweight=`weightvar']
		local pI = `r(mean)'
		
		* Treated compliers average
		local mean_TC = (1/(`pI' - `pB'))* ///
			(`pI'*`mean_IT' - `pB'*`mean_BT') 
			
		* Untreated compliers average
		local mean_UC = (1/(`pI' - `pB'))* ///
			((1-`pB')*`mean_BU' - (1-`pI')*`mean_IU') 
		
		* Difference between treated and untreated   compliers
		matrix int_`v'_`rep' =  ///
			[int_`v'_`rep' , `mean_TC' - `mean_UC'] 
	
		if `rep' == 1 ///
			matrix int_`v' = int_`v'_`rep'
		if `rep' > 1  ///
			matrix int_`v' = [int_`v' \ int_`v'_`rep']

		* Run the difference-in-difference regression
		gen D_Z  = `treatment' * `IV'
			
		qui reg `v' `treatment' `IV' D_Z [pweight=`weightvar']
			
		* Output regression estimates 
		matrix did_`v'_`rep' = _b[D_Z]
				
		matrix did_`v'_`rep' = [did_`v'_`rep' , _b[`treatment']]
		
		matrix did_`v'_`rep' = [did_`v'_`rep' , _b[`IV']]
	
		* Save the diff-in-diff results in matrix			
		if `rep' == 1 ///
			matrix did_`v' = did_`v'_`rep'
		if `rep' > 1  ///
			matrix did_`v' = [did_`v' \ did_`v'_`rep']
			
		drop D_Z
		
	} // end bootstrapping loop
			
	local ++numvar
			
} // end loop for validity test variables
	
* Format results for internal validity	
local rowname ""
local numvar = 1
foreach v of local didtest {
	local rowname "`rowname' `v'"
	svmat double int_`v'
	forvalues  c = 1/ 2 { 
		if `c' == 1 matrix intl_`v' = int_`v'[1,`c']
		if `c' == 2 matrix intl_`v' = [intl_`v', int_`v'[1,`c']]
		_pctile int_`v'`c' if _n!=1, p(2.5)
		matrix intl_`v' = [intl_`v', `r(r1)'] 
		_pctile int_`v'`c' if _n!=1, p(97.5)
		matrix intl_`v' = [intl_`v', `r(r1)']
	}
	
	if `numvar' == 1 matrix intvalid = intl_`v'
	if `numvar' > 1  matrix intvalid = [intvalid \ intl_`v'] 
	local ++numvar
}

* Format results for external validity	
local rowname ""
local numvar = 1
foreach v of local didtest {
	local rowname "`rowname' `v'"
	svmat double did_`v'
	forvalues  c = 1/ 3 { 
		if `c' == 1 matrix didl_`v' = did_`v'[1,`c']
		if `c' == 2 matrix didl_`v' = [didl_`v', did_`v'[1,`c']]
		if `c' == 3 matrix didl_`v' = [didl_`v', did_`v'[1,`c']]
		_pctile did_`v'`c' if _n!=1, p(2.5)
		matrix didl_`v' = [didl_`v', `r(r1)'] 
		_pctile did_`v'`c' if _n!=1, p(97.5)
		matrix didl_`v' = [didl_`v', `r(r1)']
	}
	
	if `numvar' == 1 matrix did = didl_`v'
	if `numvar' > 1  matrix did = [did \ didl_`v'] 
	local ++numvar
}

* Display internal validity test results
di ""
di ""
di as result "Tests of Internal Validity"
matrix coleq intvalid = mean_I-mean_B mean_I-mean_B mean_I-mean_B ///
	mean_LAT-mean_LAU mean_LAT-mean_LAU mean_LAT-mean_LAU
matrix colnames intvalid = Estimate 95%CI_lb 95%CI_ub Estimate ///
	95%CI_lb 95%CI_ub
matrix rownames intvalid = `rowname'
matlist intvalid, format (%8.3f) showcoleq(combined) ///
		aligncolnames(center) 
	
* Display external validity tests
di""
di""
di as result "Difference-in-Difference regressions"
di "D: treatment variable, Z: instrument variable"
matrix coleq did = lambda_DZ lambda_DZ lambda_DZ lambda_D lambda_D lambda_D lambda_Z lambda_Z lambda_Z
matrix colnames did = Estimate 95%CI_lb 95%CI_ub Estimate ///
	95%CI_lb 95%CI_ub Estimate 95%CI_lb 95%CI_ub
matrix rownames did = `rowname'
matlist did, format (%8.3f) showcoleq(combined) ///
	aligncolnames(center) 

/* -------------MTE ESTIMATION--------------*/

* Set the seed up
set seed `seed'

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
	
	/* -------------MTE WITHOUT COVARIATES--------------*/
  
	if "`indepvars'" == "" {
	
		* Issue a note that bootstrapping is about to begin
		if `rep' == 1 {
			di ""
			di ""
			di in gr "Starting boostrapping for the linear MTE without covariates"
		}
		
		* Indicate the bootstrap replication number
		local K = int(`reps' /50)
		forvalues k = 1/ `K'{
			if `rep' == 50 * `k' ///
			di in gr "...Bootstrap replication # `rep'"
		}
	
		* Define matrices for storing results
		if `rep' ==  1 {
			matrix TO = J(`reps',8,.)
			matrix UO = J(`reps',8,.)
			matrix TE = J(`reps',8,.)
			
			if "`decomp'"==""{
				matrix selection = J(`reps', 8 , .)
				matrix treatment = J(`reps', 8 , .)
			}	
		}		
		
		* We derive the MTE(p) in this code by deriving the 
		* ATO(p) and AUO(p) functions first (similarly to Brinch 
		* et al 2015) and then taking their appropriate 
		* derivatives (see paper for details) to obtain the 
		* MTO(p) and MUO(p) functions. We take the difference 
		* between MTO(p) and MUO(p) to get the MTE(p).

		* Compute ATO(p) and AUO(p) functions						
		* We derive ATO(p) and AUO(p) using their closed form  
		* expressions (see paper for derivations) 
		
		* Calculate pB = P(D=1|Z=0)
		qui su `treatment' if `IV'==0 [aweight=`weightvar']
		local pB = `r(mean)'
		
		* Calculate pI = P(D=1|Z=1)
		qui su `treatment' if `IV'==1 [aweight=`weightvar']
		local pI = `r(mean)'
		
		* Calculate s(pI) = P(Z=1)
		qui su `IV' [aweight=`weightvar']
		local sp_I = `r(mean)'

		* Calculate the BTTO = E[Y|D=1,Z=0]
		qui su `depvar' if `treatment'== 1 & `IV'== 0 [aweight=`weightvar']	
		local BTTO = `r(mean)'

		* Calculate the ITTO = E[Y|D=1,Z=1]
		qui su `depvar' if `treatment'== 1 & `IV'== 1 [aweight=`weightvar']	
		local ITTO = `r(mean)'
		
		* Calculate the IUUO = E[Y|D=0, Z=1]
		qui su `depvar' if `treatment'== 0 & `IV'== 1 [aweight=`weightvar']	
		local IUUO = `r(mean)'
			
		* Calculate the BUUO = E[Y|D=0,Z=0]		
		qui su `depvar' if `treatment'== 0 & `IV'== 0 [aweight=`weightvar']	
		local BUUO = `r(mean)'
		
		* Calculate ATO(p)
		local ATO_slope = (`ITTO' - `BTTO')/(`pI' - `pB')
		local ATO_int = `BTTO' - `ATO_slope'*`pB'
		matrix ATO_matrix = [`ATO_int',`ATO_slope']
	
		* Calculate AUO(p)
		local AUO_slope = (`IUUO' - `BUUO')/(`pI' - `pB')
		local AUO_int = `BUUO' - `AUO_slope'*`pB'
		matrix AUO_matrix = [`AUO_int',`AUO_slope']  

		* Calculate MTO(p)
		mata: der_MTO("ATO_matrix")
		matrix mTO_matrix = mto_matrix

		* Calculate MUO(p)
		mata: der_MUO("AUO_matrix")
		matrix mUO_matrix = muo_matrix
		
		* Compute MTE(p)= MTO(p) - MUO(p)
		matrix mTE_matrix = mto_matrix - muo_matrix 
	
		* Save the MTE(p), MUO(p), MTE(p) slopes and intercepts 
		* in the function coefficient matrix
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
	

	/* -------------TO, UO, TE WITHOUT COVARIATES--------------*/

		matrix mu_outc = (0)
		matrix pB = (`pB')
		matrix pI = (`pI')
		matrix sp_I = (`sp_I')
		local groups "BT BU IT IU RIST RISU LA A"
		local outcomes "TO UO TE"
		
		foreach o of local outcomes {
			* Calculate treated outcome, untreated outcome, and 
			* treatment effects for all groups of interest 
			mata: calc_treat_eff("m`o'_matrix","mu_outc", "pB", "pI", "sp_I","")
			local iter = 1
			foreach g of local groups {
				matrix define `g'`o' = `g'
				matrix `o'[`rep', `iter'] = `g'
				local ++iter
			}
			
		}
	
	/* -------------DECOMPOSE TREATED OUTCOME--------------*/

		* Begin decomposition clause
		if "`decomp'" == ""{

			local groups "BT BU IT IU RIST RISU LA A"
			local iter = 1
			foreach g of local groups {
				* Calculate selection effect proportion
				matrix selection[`rep',`iter'] = ///
					`g'UO * inv(`g'TO) 
				* Calculate treatment effect proportion
				matrix treatment[`rep',`iter'] = ///
					`g'TE * inv(`g'TO)
				local ++iter
			}

			* Calculate the BOLS, IOLS, RISOLS via differences
			* We can also calculate the BOLS, IOLS, and RISOLS via 
			* regressions of Y on D on the subsamples with `IV' ==1 , 
			* `IV' ==0 and the whole sample, respectively. They 
			* should give the same result as calculating it via 
			* differences.		
			matrix define BOLS = BTTO - BUUO 
			matrix define IOLS = ITTO - IUUO  
			matrix define RISOLS = RISTTO - RISUUO  
			
			if `rep' ==1 matrix OLS_est = [BOLS, IOLS, RISOLS]
			if `rep' > 1 matrix OLS_est = [OLS_est\ [BOLS, IOLS, RISOLS]]
	
			* Calculate OLS Decomposition
			* For each of BOLS, IOLS, and RISOLS we can decompose 
			* the OLS  estimate into a selection and treatment  
			* effect in two different ways - using the treated or  
			* the untreated within each OLS estimate. 
		
			* BOLS Decomposition using BTTE
			matrix OLS_sel_BT = (BOLS-BTTE) * inv(BOLS) // Selection 
			matrix OLS_tre_BT =  BTTE * inv(BOLS)       // Treatment 
												
			* BOLS Decomposition using BUTE
			matrix OLS_sel_BU = (BOLS-BUTE) * inv(BOLS) // Selection  
			matrix OLS_tre_BU =  BUTE * inv(BOLS)       // Treatment  
									
			* IOLS Decomposition using ITTE
			matrix OLS_sel_IT = (IOLS-ITTE) * inv(IOLS) // Selection 
			matrix OLS_tre_IT = ITTE * inv(IOLS)        // Treatment  
							
			* IOLS Decomposition using IUTE
			matrix OLS_sel_IU = (IOLS-IUTE) * inv(IOLS) // Selection  
			matrix OLS_tre_IU = IUTE * inv(IOLS)        // Treatment 
							
			* RISOLS Decomposition using RISTTE
			matrix OLS_sel_RIST = (RISOLS-RISTTE) * inv(RISOLS)	// Selection effect
			matrix OLS_tre_RIST = RISTTE * inv(RISOLS) 		// Treatment effect 
									
			* RISOLS Decomposition using RISUTE
			matrix OLS_sel_RISU = (RISOLS-RISUTE) * inv(RISOLS) 	// Selection effect
			matrix OLS_tre_RISU = RISUTE * inv(RISOLS) 		// Treatment effect
			
			* Output 
			if `rep' == 1 {
				matrix OLS_sel = [OLS_sel_BT, OLS_sel_BU, OLS_sel_IT, OLS_sel_IU, OLS_sel_RIST, OLS_sel_RISU]					
				matrix OLS_tre = [OLS_tre_BT, OLS_tre_BU, OLS_tre_IT, OLS_tre_IU, OLS_tre_RIST, OLS_tre_RISU]
			}
			if `rep' > 1 {
				matrix OLS_sel = [OLS_sel \ [OLS_sel_BT, OLS_sel_BU, OLS_sel_IT, OLS_sel_IU, OLS_sel_RIST, OLS_sel_RISU]]
				matrix OLS_tre = [OLS_tre \ [OLS_tre_BT, OLS_tre_BU, OLS_tre_IT, OLS_tre_IU, OLS_tre_RIST, OLS_tre_RISU]]
			}
			
	
		} // end decomposition clause
	
	} // end no covariates clause
	
	/* -------------MTE WITH COVARIATES--------------*/

	if "`indepvars'" != "" {

		* Issue a warning that bootstrapping will take a while
		if `rep'==1 {
			di ""
			di ""
			di as result "Starting estimation of the MTE with covariates"
			di as result "NOTE: Bootstrapping for the MTE with covariates will require some time."
		}
		
		* Indicate the bootstrap replication number
		local K = int(`reps' /50)
		forvalues k = 1/ `K'{
			if `rep' == 50 * `k' ///
			di in gr "...Bootstrap replication # `rep'"
		}
		
		/* -------------ESTIMATE THE MTE WITHOUT COVARIATES--------------*/
		* We need this for estimating the RMSD
		
		* Calculate pB = P(D=1|Z=0)
		qui su `treatment' if `IV'==0 [aweight=`weightvar']
		local pB = `r(mean)'
		
		* Calculate pI = P(D=1|Z=1)
		qui su `treatment' if `IV'==1 [aweight=`weightvar']
		local pI = `r(mean)'
	
		* Calculate the BTTO = E[Y|D=1,Z=0]
		qui su `depvar' if `treatment'== 1 & `IV'== 0 [aweight=`weightvar']	
		local BTTO = `r(mean)'

		* Calculate the ITTO = E[Y|D=1,Z=1]
		qui su `depvar' if `treatment'== 1 & `IV'== 1 [aweight=`weightvar']	
		local ITTO = `r(mean)'
		
		* Calculate the IUUO = E[Y|D=0, Z=1]
		qui su `depvar' if `treatment'== 0 & `IV'== 1 [aweight=`weightvar']	
		local IUUO = `r(mean)'
			
		* Calculate the BUUO = E[Y|D=0,Z=0]		
		qui su `depvar' if `treatment'== 0 & `IV'== 0 [aweight=`weightvar']	
		local BUUO = `r(mean)'
		
		* Calculate ATO(p)
		local ATO_slope_nocovars = (`ITTO' - `BTTO')/(`pI' - `pB')
		local ATO_int_nocovars = `BTTO' - `ATO_slope_nocovars'*`pB'
		matrix ATO_matrix_nocovars = [`ATO_int_nocovars',`ATO_slope_nocovars']
	
		* Calculate AUO(p)
		local AUO_slope_nocovars = (`IUUO' - `BUUO')/(`pI' - `pB')
		local AUO_int_nocovars = `BUUO' - `AUO_slope_nocovars'*`pB'
		matrix AUO_matrix_nocovars = [`AUO_int_nocovars',`AUO_slope_nocovars']  

		* Calculate MTO(p)
		mata: der_MTO("ATO_matrix_nocovars")
		matrix mTO_matrix_nocovars = mto_matrix

		* Calculate MUO(p)
		mata: der_MUO("AUO_matrix_nocovars")
		matrix mUO_matrix_nocovars = muo_matrix
		
		* Compute MTE(p)= MTO(p) - MUO(p)
		matrix mTE_matrix_nocovars = mto_matrix - muo_matrix

		/* -------------CALCULATE PROPENSITY SCORE--------------*/
				
		* Create an alternative instrument, with the value opposite 
		* of the observed value
		gen IV_alt = ~`IV'
		
		* Estimate the propensity scores if interactions with the instrument are specified
		if "`interact'" != "nointeract" {
		
			* Create the interaction terms
			foreach x of varlist `indepvars' {				
				gen _int_`x' = `IV'*`x'										
			}
		
			* Estimate propensity scores using Z, Xs, and the
			* interactions between Z and the Xs as the covariates
			* and D as the dependent variable. 
			* We use a linear regression to predict the propensity
			* scores.  Please note that we do not censor the
			* propensity scores here. We keep the uncensored
			* propensity scores for the MTE estimation, however,
			* we do censor them for estimating any treatment effects
			* from an MTE with covariates. Propensity scores are 
			* also not censored when estimating the linear MTE
			* without covariates.	
		
			qui reg `treatment' `IV' `indepvars' _int* [pweight=`weightvar']
		
			qui predict p_Z
			
			* Print diagnostics on propensity score		
			if `rep' ==1 {	
				di ""
				di ""		
				di in gr "Number of observations with predicted propensity scores >1"
				count if p_Z>1 & p_Z !=.
				di ""
				di ""						
				di in gr "Number of observations with predicted propensity scores <0"
				count if p_Z<0 & p_Z !=.
			}
		
			* Drop individuals with missing propensity scores 
			qui drop if p_Z==.
		
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
					gen old_int_`x'=_int_`x'
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
		} 
		
		* Estimate the propensity scores if no interactions are specified
		else {
		
			* Estimate propensity scores using Z and Xs (as covariates)
			* and D as dependent variable
			* We use a linear regression to predict the propensity
			* scores.  Please note that we do not censor the
			* propensity scores here. We keep the uncensored
			* propensity scores for the MTE estimation, however,
			* we do censor them for estimating any treatment effects
			* from an MTE with covariates. Propensity scores are 
			* also not censored when estimating the linear MTE
			* without covariates.	
		
			qui reg `treatment' `IV' `indepvars' [pweight=`weightvar']
		
			qui predict p_Z
			
			* Print diagnostics on propensity score
			if `rep' == 1 {
				di ""
				di ""		
				di in gr "Number of observations with predicted propensity scores >1"
				count if p_Z>1 & p_Z !=.
				di ""
				di ""						
				di in gr "Number of observations with predicted propensity scores <0"
				count if p_Z<0 & p_Z !=.
			}
		
			* Drop individuals with missing propensity scores 
			qui drop if p_Z==.
		
			* Estimate the alternative propensity score, which we
			* define as having Z equal to the opposite of whatever
			* is observed for each individual
			
			quietly {
			
				* Generate an alternative Z that is the opposite of
				* whatever each individual has and predict the
				* propensity score with that
				gen old_IV = `IV'
				drop `IV'
				rename IV_alt `IV'
					
				* Predict the alternative propensity score
				predict p_Z_alt
				
				* Revert back to the old names
				drop `IV'
				rename old_IV `IV'
			}
		} 
		
		* Generate pB and pI for each individual
				
		* Determine each individual's pB
			
		* For randomized out individuals, the propensity score 
		* estimated in the above regression is their pB
		qui gen pB = p_Z if `IV'==0
		
		* For randomized in individuals, the propensity score
		* estimated in the above regression ASSUMING THEIR Z=0
		* is their pB
		qui replace pB = p_Z_alt if `IV'==1
			
		* Determine each individual's pI
		
		* For randomized out individuals, the propensity score
		* estimated in the above regression ASSUMING THEIR Z=1
		* is their pI
		qui gen pI = p_Z_alt if `IV'==0
		
		* For randomized in individuals, the propensity score
		* estimated in the above regression is their pI
		qui replace pI = p_Z if `IV'==1
			
		* Censor pB and pI 
		* If pB or pI is less than 0, censor them at 0. If pB 
		* or pI is greater than 1, censor them at 1.
		quietly {
			gen pB_cens = pB
			replace pB_cens = 0 if pB_cens<0
			replace pB_cens = 1 if pB_cens>1
			
			gen pI_cens = pI
			replace pI_cens = 0 if pI_cens<0
			replace pI_cens = 1 if pI_cens>1 
		}		
			
		/* -------------ESTIMATE ATO(x,p) AND AUO(x,p)--------------*/

		* Loop over treatment values (D = 0, D = 1)
		forval d = 0/1 {
		
			preserve
			
			* Restrict sample (e.g., conditional on D=1, 
			* conditional on D=0)
			qui keep if `treatment' == `d'
			
			* Based on the pre-specified functional form of g(p), 
			* generate the polynomial as a function of p
			local p_poly_`d' ""   
			forvalues _n=1/`poly' {
				qui gen p_Z_`_n'_`d' = p_Z^(`_n')
				local p_poly_`d' "`p_poly_`d'' p_Z_`_n'_`d'"
			}
						
			* Estimate betas and ATO(x,p) and AUO(x,p)
							
			* Create a matrix that contains the coefficient of the 
			* polynomial components, i.e., K0 and K1 (+1 is for the 
			* constant)
			matrix K_`d' = J(1, `poly' +1, .) 
									
			* Regress Y on Xs and specified functional form of p 
			* (e.g., linear, quadratic etc.)
			qui reg `depvar' `indepvars' `p_poly_`d'' [pweight=`weightvar']
		
			* Save regression results							
			if _rc == 0 {
										
				* Save the betas for the covariates in macro variables
				* The coefficients on the covariates from the above 
				* regression reflect the beta_1 or beta_0, depending
				* on whether we are running the regression on the 
				* treated or the untreated.
				matrix beta`rep'_`d' = J(1,1,.)
			
				foreach _var of varlist `indepvars' {
					scalar define _b_`d'_`_var' = _b[`_var']
					matrix beta`rep'_`d'= ///
						[beta`rep'_`d',  _b_`d'_`_var']
				}
				
				matrix beta`rep'_`d' = beta`rep'_`d'[1,2...]
			
				if `rep' == 1 matrix beta_`d'_mat = beta`rep'_`d'
				if `rep' > 1  matrix beta_`d'_mat = [beta_`d'_mat \ beta`rep'_`d']
			
				* Save the  coefficients for graphing			
				if `rep' == 1{
					foreach _var of varlist `indepvars' {
						scalar define _b1_`d'_`_var' = _b[`_var']
					}
				}
								
				* Save the gammas in macro variables and add them to the 
				* matrix. The coefficients on the g(p) components, which 
				* we  call gammas, from the above regression reflect the 
				* components of ATO(x,p) or AUO(x,p), depending on  
				* whether we are running the regression on the treated 
				* or the  untreated.
				local _m = 2
				foreach _var of local p_poly_`d' {
					matrix K_`d'[1,`_m'] = _b[`_var']
					local ++_m
				}				
								
				matrix K_`d'[1,1] = _b[_cons]
			}
			
			restore
		}

		/* -------------ESTIMATE mto(x,p) AND muo(x,p)--------------*/

		* The function der_MTO carries out these calculations and returns mto(p). 
		* Similar for muo(p) below
		mata: der_MTO("K_1")
		
		* This change in notation from lowercase to capital letters is only for 
		* notational convenience later
		matrix mTO_matrix = mto_matrix 
		if `rep' == 1 matrix mto_mat = mto_matrix
		if `rep' > 1  matrix mto_mat = [mto_mat \ mto_matrix]
							
		mata: der_MUO("K_0")
		
		matrix mUO_matrix = muo_matrix
		if `rep' == 1 matrix muo_mat = muo_matrix
		if `rep' > 1  matrix muo_mat = [muo_mat \ muo_matrix] 
		
		* Compute mte(p) as the difference between mto(p) and muo(p) 
		matrix mTE_matrix = mto_matrix - muo_matrix
		if `rep' == 1 matrix mte_mat = mTE_matrix 
		if `rep' > 1  matrix mte_mat = [mte_mat \ mTE_matrix]
		
		* Keep the mte, mto, muo of the original sample for graphing later 
		if `rep' == 1 	matrix mte1_matrix = mTE_matrix
		
		* Calculate the min and max
		qui gen double mu_TE_1 = 0
		foreach x of varlist `indepvars' {
			qui replace mu_TE_1 = mu_TE_1 + (_b_1_`x'-_b_0_`x')*`x'
		}
		
		qui sum mu_TE_1	
		local avg_mu_te = `r(mean)'
		local min_mu_te = `r(min)'
		local max_mu_te = `r(max)'
		
		matrix minMTE_matrix = mTE_matrix
		matrix minMTE_matrix[1,1] = minMTE_matrix[1,1]+`min_mu_te'
		
		matrix maxMTE_matrix = mTE_matrix
		matrix maxMTE_matrix[1,1] = maxMTE_matrix[1,1]+`max_mu_te'
		
		if `rep' == 1 matrix minmte_mat = minMTE_matrix 
		if `rep' > 1  matrix minmte_mat = [minmte_mat \ minMTE_matrix]
		
		if `rep' == 1 matrix maxmte_mat = maxMTE_matrix 
		if `rep' > 1  matrix maxmte_mat = [maxmte_mat \ maxMTE_matrix]
		
		
		/* -------------CALCULATE TO, UO, and TE ON INDIVIDUAL LEVEL AND AVERAGE --------------*/

		* Calculate (beta_1)*X, beta_0*X and (beta_1-beta_0)*X
		quietly gen double mu_TE = 0
		quietly gen double mu_TO = 0
		quietly gen double mu_UO = 0
		
		quietly foreach x of varlist `indepvars' {
			replace mu_TE = mu_TE + (_b_1_`x'-_b_0_`x')*`x'
			replace mu_TO = mu_TO + (_b_1_`x')*`x'
			replace mu_UO = mu_UO + (_b_0_`x')*`x'
		}
		
		* Calculate the values of sp_I for each subgroup
		* Need to loop through in order to incorporate weights
			
		* The tag we generate is for the subgroups without Z: 
		* to get the s(pI) values
		quietly reg `treatment' `indepvars'
		qui predict subgroup_IV
		
		* Sum up the number of randomized in individuals within
		* each subgroup
		qui bysort subgroup_IV: egen Z_count = sum(`IV')
		qui bysort subgroup_IV: egen N_count = sum(N)
		
		* Replace missing values with zeroes
		qui replace Z_count=0 if Z_count==.
		qui replace N_count=0 if N_count==.
		
		qui gen s_pI = Z_count/N_count
				
		qui drop subgroup_IV
			
		* Calculate the probability of being a complier for each individual
						
		* We use the closed form expression for the probability of 
		* being a complier
		
		qui gen prob_IT = 0
		qui gen prob_BU = 0
				
		qui replace prob_IT = 1 if `treatment'==1 & `IV'==1
		qui replace prob_BU = 1 if `treatment'==0 & `IV'==0
			
		qui gen prob_C = ((pI_cens - pB_cens)/pI_cens)*prob_IT + ///
			((pI_cens - pB_cens)/(1-pB_cens))*prob_BU
		qui replace prob_C=0 if prob_C==.
			
		* Calculate the treated and untreated outcome, and treatment effects on
		* an individual level and then average across individuals

		local groups "BT BU IT IU RIST RISU LA A"
		local outcomes "TO UO TE"

		foreach o of local outcomes {
			mata: calc_treat_eff("m`o'_matrix", "mu_`o'","pB_cens", "pI_cens", "s_pI", "cov")

			* Transform mata vectors into Stata variables
			foreach g of local groups {
				svmat double `g', names(`g'`o')
			}
			
			* Calculate the weighted averages
			local iter =1 
			
			* Average BTTO, BTUO, BTTE across individuals with D=1 and Z=0 
			qui su BT`o' if `treatment'== 1 & `IV'==0 [aweight=`weightvar']
			matrix SBT`o' = `r(mean)'
			
			* Average BUTO, BUUO, BUTE across individuals with D=0 and Z=0
			qui su BU`o' if `treatment'== 0 & `IV'==0 [aweight=`weightvar']
			matrix SBU`o' = `r(mean)'
			
			* Average ITTO, ITUO, ITTE across individuals with D=1 and Z=1 
			qui su IT`o' if `treatment'== 1 & `IV'==1 [aweight=`weightvar']
			matrix SIT`o' = `r(mean)'
			
			* Average IUTO, IUUO, IUTE across individuals with D=0 and Z=1
			qui su IU`o' if `treatment'== 0 & `IV'==1 [aweight=`weightvar']
			matrix SIU`o' = `r(mean)'
			
			* Average RISTTO,RISTUO, and RISTTE across individuals with D=1
			qui su RIST`o' if `treatment'== 1 [aweight=`weightvar']
			matrix SRIST`o' = `r(mean)'
			
			* Average RISUTO, RISUUO, and RISUTE across individuals with D=1		
			qui su RISU`o' if `treatment'==0 [aweight=`weightvar']
			matrix SRISU`o' = `r(mean)'
			
			* Average ATO, AUO, ATE across all individuals
			qui su A`o'	[aweight=`weightvar']			
			matrix SA`o' = `r(mean)'
				
			* For SLATE, SLATO, SLAUO
			* In order to calculate the SLATE, we multiply each individual's 
			* LATE by his/her probability of being a complier. We take the 
			* sum of this product and divide it by the sum of the 
			* probabilities of being a complier across the entire sample. 
			* We use a similar approach for the SLATO and the SLAUO, except 
			* that instead of using the overall probability of being a 
			* complier, we use the probabilities of being a treated or 
			* untreated complier for the SLATO and SLAUO, respectively.
				
			qui gen prob_LA`o' = LA`o' * prob_C
			
			quietly su prob_LA`o' [aweight=`weightvar']
			local sum_LA`o' = `r(sum)'
						
			quietly su prob_C [aweight=`weightvar']
			local sum_probs = `r(sum)'
						
			local SLA`o' = `sum_LA`o''/`sum_probs'
			matrix SLA`o' = `SLA`o''
			
			* Output 
			if `rep' == 1 matrix S`o'_mat = [SBT`o', SBU`o', SIT`o', ///
				SIU`o', SRIST`o', SRISU`o', SLA`o', SA`o']
			if `rep' > 1  matrix S`o'_mat = [S`o'_mat \ [SBT`o', SBU`o', /// 
				SIT`o', SIU`o', SRIST`o', SRISU`o', SLA`o', SA`o']]
		}
				
		* Calculate the coefficients of SMTE(p), SMTO(p), SMTO(p) for 
		* displaying results)
		* MTE(TO/UO) = mu_TE(TO/UO) + mTE(/TO/UO) and 
		* SMTE(/TO/UO) =  average_mu_TE(/TO/UO) + mTE(/TO/UO)
			
		local os "TO UO TE"	
		qui foreach o of local os {
		
			qui su mu_`o' [aweight=`weightvar']
			local avg_mu_`o' = `r(mean)'
			matrix SM`o' = m`o'_matrix
			matrix SM`o'[1,1] = SM`o'[1,1] + `avg_mu_`o''
			if `rep' == 1 matrix SM`o'_mat = SM`o'
			if `rep' > 1  matrix SM`o'_mat = [SM`o'_mat \ SM`o']
		}
		
		
		* Calculate RMSD(X_c)
		matrix diff_SMTE_SATE = SMTE
		
		matrix diff_SMTE_SATE[1,1] = SMTE[1,1]-STE_mat[`rep',8] 
	
		mata: der_RMSD("diff_SMTE_SATE")
		local RMSD = sc_RMSD
				
		* Calculate RMSD(X_0) where X_0 is the null set of covariates 
		* and MTE(p) is linear
		
		* Calculate ATE. 
		* We use the closed form expression of the ATE 
		* (which is integral of MTE from 0 to 1)					
		local ATE = mTE_matrix_nocovars[1,1] + mTE_matrix_nocovars[1,2]/2
		
		* Calculate the difference between MTE(p) and ATE
		matrix diff_MTE_ATE = mTE_matrix_nocovars
		matrix diff_MTE_ATE[1,1] = mTE_matrix_nocovars[1,1]-`ATE'
		
		* Calculate the RMSD
		mata: der_RMSD("diff_MTE_ATE")
		local RMSD0 = sc_RMSD
		
		* Calculate the heterogeneity explained by covariates
		local exp_hetero = (`RMSD0'-`RMSD')/`RMSD0'
				
		* Calculate the remaining unexplained heterogeneity
		local unexp_hetero = `RMSD'/`RMSD0'
		
		* Store results
		if `rep' == 1 matrix RMSD_mat = ///
			[`RMSD0',`RMSD',`exp_hetero',`unexp_hetero']
		if `rep' >1   matrix RMSD_mat = ///
			[RMSD_mat \ [`RMSD0',`RMSD',`exp_hetero',`unexp_hetero']]
	
	} // close clause on case with covariates
	
} //end bootstrapping loop

ereturn post

* Store the number of observations in e()
qui count
ereturn scalar N = `r(N)'

* Store the number of bootstrap replications in e()
ereturn scalar reps = `reps'-1

* Store the polynomial number in e()
ereturn scalar poly = `poly'

* Store internal and external validity results in e()
ereturn matrix internal_valid = intvalid
ereturn matrix did_reg = did	


if "`indepvars'" == "" {
				
	/* -------------DISPLAY RESULT FOR THE CASE WITHOUT COVARIATES--------------*/

	* Results for the slope and intercept of MTO(p), MUO(p), MTE(p)
	local matr "MTE MTO MUO TO TE UO"
	foreach m of local matr {
		matrix `m'_dis = `m'[1..3,1...]
		svmat double `m' 
				
		local col = colsof(`m')
		forvalues  c = 1/ `col'{
			_pctile `m'`c' if _n!=1, p(2.5) 
			matrix `m'_dis [2,`c'] = `r(r1)'
			_pctile `m'`c' if _n!=1, p(97.5)
			matrix `m'_dis [3,`c'] = `r(r1)'
		}

	}
	

	local rowname "Estimate 95%CI_lower 95%CI_upper"

	di ""
	di ""
	di as result "Marginal Treated Outcome (MTO), Marginal Untreated Outcome (MUO), Marginal Treatment Effect (MTE)" 
	matrix fn_coeff_di = [MTO_dis,MUO_dis,MTE_dis]
	matrix coleq fn_coeff_di = MTO MTO MUO MUO MTE MTE
	matrix colnames fn_coeff_di = Intercept Slope Intercept Slope Intercept Slope
	matrix rownames fn_coeff_di = `rowname'
	matlist fn_coeff_di , showcoleq(combined)
	
	* Return results
	matrix  rownames MTO_dis = `rowname'
	matrix  colnames MTO_dis = intercept slope 
	ereturn matrix MTO = MTO_dis
	matrix  rownames MUO_dis = `rowname'
	matrix  colnames MUO_dis = intercept slope 
	ereturn matrix MUO = MUO_dis
	matrix  rownames MTE_dis = `rowname'
	matrix  colnames MTE_dis = intercept slope  
	ereturn matrix MTE = MTE_dis
	di ""
	di ""
	di as result "Treated Outcomes (TO), without covariates" 
	matrix colnames TO_dis =  BT BU IT IU RIST RISU LA A
	matrix rownames TO_dis = `rowname'
	matlist TO_dis ,  showcoleq(combined) aligncolnames(center) 
	di ""
	di ""
	di as result "Untreated Outcomes (UO), without covariates" 
	matrix colnames UO_dis =  BT BU IT IU RIST RISU LA A
	matrix rownames UO_dis = `rowname'
	matlist UO_dis ,  showcoleq(combined) aligncolnames(center) 
	di ""
	di ""
	di as result "Treatment Effects (TE), without covariates"
	matrix colnames TE_dis =  BT BU IT IU RIST RISU LA A
	matrix rownames TE_dis = `rowname'
	matlist TE_dis ,  showcoleq(combined) aligncolnames(center) 
	
	* Return results
	ereturn matrix TE = TE_dis
	ereturn matrix TO = TO_dis
	ereturn matrix UO = UO_dis	

	* Results for decomposition of treated outcomes and OLS estimates into 
	* selection and treatment effects, if specified
	if "`decomp'" == ""{
		local matr "selection treatment OLS_est OLS_sel OLS_tre"
		foreach m of local matr {
			matrix `m'_dis = `m'[1..3,1...]
			svmat double `m' 
			local col = colsof(`m')
			forvalues  c = 1/ `col'{
				_pctile `m'`c' if _n!=1, p(2.5)
				matrix `m'_dis [2,`c'] = `r(r1)'
				_pctile `m'`c' if _n!=1, p(97.5)
				matrix `m'_dis [3,`c'] = `r(r1)'
			}
		}
	
		di ""
		di ""
		di as result "Decomposition of Treated Outcomes into Selection and Treatment Effects"
		di ""
		di as result "Treated Outcome Selection Effects"
		matrix colnames selection_dis = BT BU IT IU RIST RISU LA A
		matrix rownames selection_dis = Estimate 95%CI_lower 95%CI_upper
		matlist selection_dis,   showcoleq(combined) ///
			aligncolnames(center) 
		di ""
		di as result "Treated Outcome Treatment Effects"
		matrix colnames treatment_dis = BT BU IT IU RIST RISU LA A
		matrix rownames treatment_dis = Estimate 95%CI_lower 95%CI_upper
		matlist treatment_dis,   showcoleq(combined) ///
			aligncolnames(center) 
		di ""
		di ""
		di as result "OLS Estimates"
		local col "BOLS IOLS RISOLS"
		local row "Estimate 95%CI_lower 95%CI_upper"
		matrix colnames OLS_est_dis = `col'
		matrix rownames OLS_est_dis = `row'
		matlist OLS_est_dis,  showcoleq(combined) ///
			aligncolnames(center) 
		di ""
		di ""
		di as result "Decomposition of OLS into Selection and Treatment Effects"
		di as result "OLS Selection Effect"
		matrix coleq OLS_sel_dis = BOLS BOLS IOLS IOLS RISOLS RISOLS 
		matrix colnames OLS_sel_dis = via_BT via_BU ///
			via_IT via_IU via_RIST via_RISU
		matrix rownames OLS_sel_dis = Estimate 95%CI_lower 95%CI_upper
		matlist OLS_sel_dis,  showcoleq(combined) ///
			aligncolnames(center) 
		di""
		di as result "OLS Treatment Effect"
		matrix coleq OLS_tre_dis = BOLS BOLS IOLS IOLS RISOLS RISOLS
		matrix colnames OLS_tre_dis = via_BT  via_BU ///
			via_IT via_IU via_RIST via_RISU
		matrix rownames OLS_tre_dis = Estimate 95%CI_lower 95%CI_upper
		matlist OLS_tre_dis, showcoleq(combined) ///
			aligncolnames(center) 
		* Return results
		ereturn matrix selection = selection_dis
		ereturn matrix treatment = treatment_dis
		ereturn matrix OLS_est = OLS_est_dis
		ereturn matrix OLS_selection = OLS_sel_dis
		ereturn matrix OLS_treatment = OLS_tre_dis
	}

	/* -------------GRAPHICAL PRESENTATION --------------*/
	

	local BTTO = Statmat[2,6]
	local IUUO = Statmat[2,9]
	local LATO = Statmat[2,10]
	local LAUO = Statmat[2,11]
	local LATE = `LATO' - `LAUO'
	
	* Only post the Statmat into e() now because once posted, data 
	* stored in e() will be lost, and thus the above codes to get 
	* BTTO, etc. will not work
	ereturn matrix averages = Statmat  	
	
	* Graph bounds (i.e., assuming monotonicity)
	qui {
		des `depvar'
		di `r(N)'
		range t 1 `r(N)' `r(N)'  

		gen btto = . 
		replace btto = `BTTO' if t<=2 
		gen iuuo = . 
		replace iuuo = `IUUO' if t<=2
		gen lato = .
		replace lato = `LATO' if t<=2
		gen lauo = .
		replace lauo = `LAUO' if t<=2
		
		gen late = lato - lauo
		gen up_late_a = btto - lauo
		gen up_late_n = lato - iuuo
			
		gen pb=.
		replace pb = 0 if t==1
		replace pb =`pB' if t==2
		
		gen pbi=.
		replace pbi=`pB' if t==1
		replace pbi=`pI' if t==2
		
		gen pi=.
		replace pi=`pI' if t==1
		replace pi= 1 if t==2
		
		local midpI = (1+`pI')/2
		local midp = (`pI'+`pB')/2
		local midpB = `pB'/2
		
		gen b_to =. 
		replace b_to = `LATO' if t<=2
		
		gen b_uo =.
		replace b_uo = `LAUO' if t<=2 
	}

	if `BTTO' >= `LATO' local lab_to "MTO(p) upper bound"
	if `BTTO' <= `LATO' local lab_to "MTO(p) lower bound"
	if `LAUO' >= `IUUO' local lab_uo "MUO(p) lower bound"
	if `LAUO' <= `IUUO' local lab_uo "MUO(p) upper bound"
	local lab_late "MTE(p) upper bound"

	qui graph twoway (line btto pb, lwidth(medium) ylabel(#6) xlabel(0 `pB' "p{sub:B}" 0.25 `pI' "p{sub:I}" 0.50  0.75 1.00) /*
	*/    lpattern(shortdash) lcolor(green) text(`BTTO' `midpB' "BTTO", place (n))) /*
	*/   (line lato pbi, lwidth(medium) lpattern(shortdash) lcolor(green) text(`LATO' `midp' "LATO", place(n)))/*
	*/   (line lauo pbi, lpattern(longdash) lcolor(blue) text(`LAUO' `midp' "LAUO", place(n)))/*	
	*/   (line iuuo pi, lpattern(longdash) lcolor(blue) text(`IUUO' `midpI' "IUUO", place(n)))/*
	*/   (line late pbi, lpattern(solid) lcolor(red) text(`LATE' `midp' "LATE", place(n)))   /*
	*/   (line b_to pi, lwidth(thick) lpattern(shortdash) lcolor(green))/*
	*/   (line b_uo pb, lwidth(thick) lpattern(longdash) lcolor(blue)) /*
	*/   (line up_late_a pb, lpattern(solid) lwidth(thick) lcolor(red)) /*
	*/   (line up_late_n pi, lpattern(solid) lwidth(thick) lcolor(red)), /*
	*/    yline(0, lcolor(black)) /*
	*/    xscale(r(0 1)) /*
	*/    xtitle("p: potential fraction treated" "U{sub:D}: net unobserved cost of treatment") /*
	*/    legend(order (1 "MTO(p)" 6 "`lab_to'"  3 "MUO(p)" 7 "`lab_uo'"  5 "MTE(p)" 8 "`lab_late'") cols(2) colgap(3) symxsize(10)) /*
	*/    title("A. Monotonicity")/*
	*/   nodraw name(mte_bounds, replace)
		
	*qui graph save mte_bounds, replace

	* Graph MTE(p) (assuming linearity)
	qui{
		gen to = .
		replace to = `BTTO' if t==1
		replace to = `LATO' if t==2
		
		gen pto = .
		replace pto = `midpB' if t==1
		replace pto = `midp' if t==2
		
		gen uo = .
		replace uo = `LAUO' if t==1
		replace uo = `IUUO' if t==2
		
		gen puo =.
		replace puo = `midp' if t==1
		replace puo = `midpI' if t==2
		
		gen te = .
		replace te = MTE[1,1] if t==1 /* intercept of MTE(p) */
		replace te = `LATE' if t==2
		
		gen pte = .
		replace pte = 0 if t==1
		replace pte = `midp' if t==2
		
		gen te_late = .
		replace te_late = `LATE' if t==2
	}	

	qui graph twoway (scatter to pto, msymbol(O) mcolor(green)) /*
	*/   (lfit to pto,range(0 1) ylabel(#6) xlabel(0 `pB'"p{sub:B}" 0.25 `pI'"p{sub:I}" 0.50  0.75 1.00) /*
	*/   	lwidth(medium) lpattern(shortdash) lcolor(green) text(`BTTO' `midpB' "BTTO", place(n)) text(`LATO' `midp' "LATO", place (n))) /*
	*/   (scatter uo puo, msymbol(O) mcolor(blue)) 	/*
	*/   (lfit uo puo, range(0 1) lpattern(longdash) lcolor(blue) /* 
	*/  	 text(`LAUO' `midp' "LAUO", place (n)) text(`IUUO' `midpI' "IUUO", place(n)))/*
	*/   (scatter te_late pte, msymbol(O) mcolor(red)) /*
	*/   (lfit te pte, range(0 1) lpattern(solid) lcolor(red) text(`LATE' `midp' "LATE" , place(n))), /*
	*/   	 yline(0, lcolor(black)) /*
	*/  	 xscale(r(0 1)) /*
	*/   	 xtitle("p: potential fraction treated" "U{sub:D}: net unobserved cost of treatment") /*
	*/    title("B. Linearity")/*
	*/   	 nodraw   name(mte_linear, replace) /*
	*/   	 legend(order (2 "MTO(p): marginal treated outcome" 4 "MUO(p): marginal untreated outcome"  6 "MTE(p): marginal treatment effect") cols(1))

	*qui graph save mte_linear, replace

	qui gr combine mte_bounds mte_linear, ycommon 
	qui gr export `graphsave'.eps, logo(off) replace
	qui ! epstopdf `graphsave'.eps 

} // close indep vars clause
	
else {

	* Only post the Statmat into e() now because once posted, data 
	* stored in e() will be lost, and thus the above codes to get 
	* BTTO, etc. will not work
	ereturn matrix averages = Statmat  
	
	matrix beta_mat = beta_1_mat - beta_0_mat
	
	/* -------------DISPLAY RESULTS --------------*/

	local matrices "SMTO SMTE SMUO SUO STO STE mto mte muo beta_1 beta_0 beta minmte maxmte"

	foreach mat of local matrices {

		svmat double `mat'_mat  
		matrix define `mat'_dis = `mat'_mat[1..3,1...] 
		
		* Calculate 95% CI 
		local col = colsof(`mat'_mat) 
		forvalues c = 1/`col' {
			_pctile `mat'_mat`c' if _n!=1, p(2.5)
			matrix `mat'_dis[2,`c'] = `r(r1)'
			_pctile `mat'_mat`c' if _n!=1, p(97.5)
			matrix `mat'_dis[3,`c'] = `r(r1)'
		}
	}

	local rowname "Estimate 95%CI_lower 95%CI_upper"

	* Display results for the coefficients of SMTO(p), SMUO(p), SMTE(p)
	di ""
	di ""
	di as result "Coefficients of the Sample Marginal Treated Outcome (SMTO), Sample Marginal Untreated Outcome (SMUO), and Sample Marginal Treatment Effect (SMTE)"
	di "(_# denotes the coefficient associated with power # in the polynomial)"
	local colname ""
	local os "TO UO TE"
	foreach o of local os{
		forval n=0/`poly'{
			if `n' == 0 {
				local colname "`colname' const_SM`o'"
			}
			else {
				local colname "`colname' SM`o'_`n'"
			}
		}
	}

	matrix glpl_dis = [SMTO_dis, SMUO_dis, SMTE_dis]
	matrix colnames glpl_dis  = `colname'
	matrix rownames glpl_dis  = `rowname'
	matlist glpl_dis

	* Display treated outcomes, untreated outcomes 
	di ""
	di ""
	di "Sample Treated Outcomes (TO), with covariates"
	matrix colnames STO_dis =  BT BU IT IU RIST RISU LA A
	matrix rownames STO_dis = `rowname'
	matlist STO_dis , aligncolnames(center) showcoleq(combined)  
	di ""
	di ""
	di "Sample Untreated Outcomes (UO), with covariates"
	matrix colnames SUO_dis =  BT BU IT IU RIST RISU LA A
	matrix rownames SUO_dis = `rowname'
	matlist SUO_dis , aligncolnames(center) showcoleq(combined)  
	di ""
	di ""
	di "Sample Treatment Effects (TE), with covariates"
	matrix colnames STE_dis =  BT BU IT IU RIST RISU LA A
	matrix rownames STE_dis = `rowname'
	matlist STE_dis , aligncolnames(center) showcoleq(combined)  
	
	* Generate column names for matrices in ereturn
	local colname_min ""
	local colname_max ""
	local colname_SMUO "" 
	local colname_SMTO ""
	local colname_SMTE ""
	forval n=0/`poly'{
		if `n' == 0 {
			local colname_min "`colname_min' const"
			local colname_max "`colname_max' const"
			local colname_SMUO "`colname_SMUO' const"
			local colname_SMTO "`colname_SMTO' const"
			local colname_SMTE "`colname_SMTE' const"
		}
		else {
			local colname_min "`colname_min' min_`n'"
			local colname_max "`colname_max' max_`n'"
			local colname_SMUO "`colname_SMUO' SMUO_`n'"
			local colname_SMTO "`colname_SMTO' SMTO_`n'"
			local colname_SMTE "`colname_SMTE' SMTE_`n'"
		}
	}
	
	* minMTE
	matrix colnames minmte_dis = `colname_min'
	matrix rownames minmte_dis = `rowname'
	
	* maxMTE
	matrix colnames maxmte_dis = `colname_max'	
	matrix rownames maxmte_dis = `rowname'
	
	* SMUO
	matrix colnames SMUO_dis = `colname_SMUO'
	matrix rownames minmte_dis = `rowname'
	
	* Generate row and column names for the coefficient matrices
	matrix colnames beta_1_dis = `indepvars'
	matrix colnames beta_0_dis = `indepvars'
	matrix rownames beta_1_dis = `rowname'
	matrix rownames beta_0_dis = `rowname'

	* Return results
		
	ereturn matrix SMTE = SMTE_dis
	ereturn matrix SMTO = SMTO_dis
	ereturn matrix SMUO = SMUO_dis
	ereturn matrix beta_to = beta_1_dis
	ereturn matrix beta_uo = beta_0_dis
	ereturn matrix STE = STE_dis
	ereturn matrix STO = STO_dis
	ereturn matrix SUO = SUO_dis
	ereturn matrix minMTE = minmte_dis
	ereturn matrix maxMTE = maxmte_dis
		
	* Output the RMSD and fraction explained/unexplained heterogeneity
	svmat double RMSD_mat 
	matrix define RMSD_dis = RMSD_mat[1..3,1...]
	
	local col = colsof(RMSD_mat) 
	forvalues c = 1/`col' {
		_pctile RMSD_mat`c' if _n!=1, p(2.5)
		matrix RMSD_dis[2,`c'] = `r(r1)'
		_pctile RMSD_mat`c' if _n!=1, p(97.5)
		matrix RMSD_dis[3,`c'] = `r(r1)'
		}
	di ""
	di ""
	di "RMSD, Explained, and Unexplained Heterogeneity in the Treatment Effect"
	matrix coleq RMSD_dis = MTE(p) MTE(x,p) Explained  Unexplained
	matrix colnames RMSD_dis =  RMSD0 RMSD Heterog Heterog
	matrix rownames RMSD_dis = `rowname'
	matlist RMSD_dis , aligncolnames(center) showcoleq(combined)  
	ereturn matrix RMSD = RMSD_dis	
		

	/* -------------GRAPH SMTE(p), minMTE(x,p), and maxMTE(x,p) --------------*/

	* Calculate the covariate component in MTE(x,p) and its 
	* average, min, max 

	* Use the original  data set, instead of the bootstrap data set
	use "`temporigin'" ,clear  
	qui gen double mu_TE_1 = 0
	foreach x of varlist `indepvars' {
		qui replace mu_TE_1 = mu_TE_1 + (_b1_1_`x'-_b1_0_`x')*`x'
	}
	qui sum mu_TE_1	
	local avg_mu_te = `r(mean)'
	local min_mu_te = `r(min)'
	local max_mu_te = `r(max)'
	
	* Calculate coefficient vectors of the average, min, and max MTE(p)
	* Recall that MTE(p)=(beta_0-beta_1)*x+mte(p), so 
	* avg_MTE(p) = avg(beta_0*X-beta_1*X) + mte(p), and so are for min, 
	* max_MTE(p)
 
	qui sum `depvar'
	local obs = `r(N)'
	range p 0 1 `r(N)'
	
	qui gen mtep = 0 
	forvalues n = 0/`poly'{
		qui replace mtep = mtep + mte1_matrix[1,1+`n'] * p^`n'
	}
	
	qui gen MTE_avg = mtep + `avg_mu_te'
	qui sum MTE_avg
	qui gen MTE_max = mtep + `max_mu_te'
	qui gen MTE_min = mtep + `min_mu_te'

	if `poly' == 1 {	
		* Calculate MTE(p) to include in the graph of MTE(x,p) for comparison 
		* if the specified MTE is linear
	
		quietly su `depvar' if `treatment'==1 & `IV'==0
		local BTTO = `r(mean)'
		quietly su `depvar' if `treatment'==1 & `IV'==1
		local ITTO = `r(mean)'
		quietly su `depvar' if `treatment'==0 & `IV'==0
		local BUUO = `r(mean)'
		quietly su `depvar' if `treatment'==0 & `IV'==1
		local IUUO = `r(mean)'
		quietly su `IV'        
		local sp_I = `r(mean)'			
		quietly su `treatment'  
		local p = `r(mean)'			
		quietly su `treatment' if `IV'==1 
		local pI = `r(mean)'					
		quietly su `treatment' if `IV'==0 
		local pB = `r(mean)'
		local LATO = (`pI'*`ITTO'-`pB'*`BTTO')/(`pI'-`pB')         
		local LAUO = ((1-`pB')*`BUUO'-(1-`pI')*`IUUO')/(`pI'-`pB')
		local int_MTE = (`pI'* (`BTTO'-`BUUO')+`pB'*(`IUUO'-`ITTO')+(`IUUO'-`BUUO'))/(`pI'-`pB') 
		local LATE = `LATO' - `LAUO'   
		range t 1 `obs' `obs'
		qui gen te = .
		qui replace te = `int_MTE' if t==1 
		qui replace te = `LATE' if t==2
		qui gen pte = .
		qui replace pte = 0 if t==1
		qui replace pte = (`pI'+`pB')/2 if t==2
	

		qui graph twoway (line MTE_avg p, ylabel(#6) lwidth(medium) lcolor(red))	/*
		*/   (line MTE_min p, lwidth(medium) lpattern(longdash) lcolor(orange_red)) 	/*
		*/   (line MTE_max p, lwidth(medium) lpattern(longdash) lcolor(sienna)) 	/*
		*/   (lfit te pte,range(0 1) lpattern(shortdash) lcolor(red)),	/* 
		*/    yline(0, lcolor(black)) /*
		*/    xscale(r(0 1)) /*
		*/    ytitle("`depvar'") /*
		*/    xtitle("p: potential fraction treated" "U{sub:D}: net unobserved cost of treatment") /*
		*/    legend(order (1 "SMTE(p)" 2 "minMTE(x,p)" 3 "maxMTE(x,p)" 4 "MTE(p)")  cols(1))
		qui gr export `graphsave'.eps, logo(off) replace
		qui ! epstopdf `graphsave'.eps 
	}
	
	* If the specified MTE is not linear, no MTE(p) without covariate is  
	* added into the graph. 
	else{
	
		qui graph twoway (line MTE_avg p, ylabel(#6) lwidth(medium) lcolor(red)) 	/*
		*/   (line MTE_min p, lwidth(medium) lpattern(longdash) lcolor(orange_red)) 	/*
		*/   (line MTE_max p, lwidth(medium) lpattern(longdash) lcolor(sienna)),	/* 
		*/    yline(0, lcolor(black)) /*
		*/    xscale(r(0 1)) /*
		*/    ytitle("`depvar'") /*
		*/    xtitle("p: potential fraction treated" "U{sub:D}: net unobserved cost of treatment") /*
		*/    legend(order (1 "SMTE(p)" 2 "minMTE(x,p)" 3 "maxMTE(x,p)") cols(1))
		qui gr export `graphsave'.eps, logo(off) replace
		qui ! epstopdf `graphsave'.eps 
	}
} // close clause for case with covariates


* Output legend
di ""
di ""
di "------------------------------------------------------------------"
di "***************************** LEGEND *****************************"
di ""
di "	RIS:	Randomized Intervention Sample (Full Sample)"
di "	I:	Intervention (Lotteried In)"
di "	B:	Baseline (Lotteried Out)"
di "	RIST: 	Randomized Intervention Sample Treated (Treated)"
di "	RISU:	Randomized Intervention Sample Untreated (Untreated)"
di "	BT:	Baseline Treated (Always Takers)"
di "	BU:	Baseline Untreated (Never Takers and Untreated Compliers)"
di "	IT:	Intervention Treated (Always Takers and Treated Compliers)"
di "	IU:	Intervention Untreated (Never Takers)"
di "	LAT:	Local Average Treated (Treated Compliers)"
di "	LAU:	Local Average Untreated (Untreated Compliers)"
di "	LA:	Local Average (All Compliers)"
di "	A:	Average"
di ""
di "	BOLS:	Baseline OLS"
di "	IOLS:	Intervention OLS"
di "	RISOLS: Randomized Intervention Sample OLS"
di ""
di "******************************************************************"
di "------------------------------------------------------------------"
di ""
di ""

* Reload data	
use "`temporigin'", clear
qui cap drop pred_`depvar'
qui cap drop wt
qui cap drop N
end


