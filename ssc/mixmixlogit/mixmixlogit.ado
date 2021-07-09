*! mixmixlogit: Latent Class Mixed Logit Models ("MM-MNL") for Stata by Timothy Neal
*! 
*! This is the first version of the mixmixlogit stata command which is capable of estimating a mixed-mixed multinomial logit model (MM-MNL) for cross-section and panel datasets with a limited dependend variable and alternative-varying covariates.
*! Please see the help file for details on how to do this and for using the command more generally.
*! If there are any questions or issues with using this command after having already consulted the help file please contact me at timothy.neal@unsw.edu.au
*! 

program define mixmixlogit, eclass
	version 11
	syntax varlist [if] [in][, GRoup(varname) ID(varname) CLasses(integer 2) CCOV(string) CORR  NREP(integer 50) BURN(integer 15) LOGnormal(string) GRADpick(string) FRom(string) TRace GRADient HESSian SHOWSTEP ITERate(passthru) TOLerance(passthru) LTOLerance(passthru) GTOLerance(passthru) NRTOLerance(passthru) CONSTraints(passthru) TECHnique(passthru) DIFficult COLL]
	
qui{

marksample touse //Mark the estimation sample

*! Split the left hand side with the right hand side variables
tokenize `varlist'
local lhs `1'
mac shift
local rhs `*'

*! Pass through ML options 
local mlopts `trace' `gradient' `hessian' `showstep' `iterate' `tolerance' `ltolerance' `gtolerance' `nrtolerance' `technique' `difficult' `constraints'

*! Calc statistics depending on whether it's panel or cross section data
if ("`id'" != "") {
	tempvar nchoice pid
	sort `group'
	by `group': gen `nchoice' = cond(_n==_N,1,0)
	sort `id'
	by `id': egen `pid' = sum(`nchoice')		
	qui duplicates report `id'
	local np = r(unique_value)
	mata: macro_np = st_numscalar("r(unique_value)")
	mata: macro_T = st_data(., st_local("pid"))
}
else {
	qui duplicates report `group'
	mata: macro_np = st_numscalar("r(unique_value)")
	local np = r(unique_value)
	mata: macro_T = J(st_nobs(),1,1)
}

*! Pass through options on the simulation of ML
mata: macro_burn = strtoreal(st_local("burn"))
mata: macro_nrep = strtoreal(st_local("nrep"))
tempvar csid
bysort `group': egen `csid' = sum(1)
sort `id' `group'

*! Calculate other relevant statistics for the data
mata: data_CSID = st_data(., st_local("csid"))
local k = wordcount("`rhs'")
mata: macro_k = strtoreal(st_local("k"))
local kclass = `k'*`classes'
mata: macro_class = strtoreal(st_local("classes"))
mata: macro_kclass = strtoreal(st_local("kclass"))
mata: data_X = st_data(., ("`rhs'"))
mata: data_Y = st_data(., "`lhs'") 
if "`ccov'" != "" {
	mata: data_ccov = st_data(., ("`ccov'"))
	local ccovnum = wordcount("`ccov'")
}
else {
	local ccovnum = 0
	mata: data_ccov = strtoreal(st_local("ccovnum"))
} 
mata: macro_ccovnum = strtoreal(st_local("ccovnum"))
local classesp = `classes' - 1

*! If a lognormal vector is specified, pass it through to mata, otherwise fill it with zeroes and then pass it through.
if "`lognormal'" == "" {
	mata: lognormal = J(1,strtoreal(st_local("kclass")),0)
}
else {
	mata: lognormal = strtoreal(tokens(st_local("lognormal")))
}

*! Specify the structure of equations for the ML routine
forvalues i = 1/`classes' {
	local mean`i' (Mean`i': `rhs', noconst)
	local max "`max' `mean`i''"
}
if ("`corr'" == "") {
	mata: macro_corr = 0
	forvalues i = 1/`classes' {
		local sd`i' (SD`i': `rhs', noconst)
		local max "`max' `sd`i''"
	}
}
else {
	mata: macro_corr = 1
	local cho = (`k'*(`k'+1)/2)*`classes' 
	mata: macro_cho = strtoreal(st_local("cho"))
	forvalues j = 1/`classes' {
		forvalues i = 1(1)`k' {
			forvalues s = `i'(1)`k' {
				local max `max' /var`j'_`s'`i'
			}
		}
	}
}
if "`ccov'" != "" {
	forvalues i = 1/`ccovnum' {
		local gammalist "`gammalist' /gamma`i'"
	}
}
else {
	local gammalist = ""
}

local cutlist = ""
local cutnum = `classes' - 1
mata: macro_cutnum = strtoreal(st_local("cutnum"))
if `classes' > 1 {
	local j = 1
	forvalues i = 2/`classes' {
		local cutlist "`cutlist' /cut`j'"
		local j = `j' + 1
	}
}

*! If the gradient vector is restricted for optimisation purposes, convert it to mata, otherwise fill it with 1s
local totz = `cutnum' + `ccovnum' + `classesp' + `classes'*2
if "`gradpick'" == "" {
	mata: gradpick = J(1,strtoreal(st_local("totz")),1)
}
else {
	mata: gradpick = strtoreal(tokens(st_local("gradpick")))
}

*! Form initial values matrix
if ("`from'" == "") {
	*! Use lclogit to obtain starting values for the beta coefficients and the class probabilities
	if ("`id'" == "") lclogit `lhs' `rhs', group(`group') id(`group') nclasses(`classes')
	else lclogit `lhs' `rhs', group(`group') id(`id') nclasses(`classes')
	matrix LCp = e(P)'
	matrix LCb = e(b)
	matrix from = LCb[1,1..`kclass'] // Beta coefficients
	if ("`corr'" == "") matrix from = from, J(1,`kclass',0.1) // SD starting values
	else matrix from = from, J(1,`cho',0.1)
	if ("`ccov'" != "") matrix from = from, J(1,`ccovnum',0.1)
	forvalues p = 1/`classesp' { // Class probabilities (transform them first)
		matrix from = from, ln(LCp[1,`p'])-ln(LCp[1,`classes'])
	}
	tempvar b
	matrix `b' = from
}
local copy , copy
}	

*! ML routine
if ("`from'" == "") ml model d1 mixmixlogit_d1 `max' `gammalist' `cutlist', maximize search(off) init(from `copy') missing nopreserve `mlopts'
else ml model d1 mixmixlogit_d1 `max' `gammalist' `cutlist', maximize search(off) init(`from' `copy') missing nopreserve `mlopts'

if ("`corr'" == "") local disptot = `classes' * 2 + `classesp' + `ccovnum' + `cutnum'
else local disptot = `classes' + `cho'  + `ccovnum' + `cutnum' 
ml display, neq(`disptot')
matrix mlresults = e(b)'


*! Calculate posterior probabilities
forvalues j = 1/`classes' {
	qui gen PostProb_`j' = .
}

mata: crexternal("PostP")
mata: postprob()

tempvar nvals
bysort id: gen `nvals' = _n == 1
count if `nvals'
local inds = r(N)

forvalues j = 1/`classes' {
	forvalues i = 1/`inds' {
		mata: probtrans(`i',`j')
		local valval = probval
		qui replace PostProb_`j' = `valval' if id == `i'
	}
}

*! Summarise the posterior probabilities
su PostProb*

end

*! The mata command lcmixl_ll has the main function of calculating the log likelihood and gradient vector at each iteration.
version 12
mata: 
void postprob()
{
/* Import necessary mata stuff */
external data_X
external data_Y
external data_CSID
external data_ccov
external macro_nrep
external macro_np
external macro_k
external macro_burn
external macro_class
external macro_kclass
external lognormal
external macro_corr
external macro_T
external macro_ccovnum
external macro_cutnum

nrep = macro_nrep
np = macro_np
k = macro_k
burn = macro_burn
ccovnum = macro_ccovnum
cutnum = macro_cutnum
classes = macro_class
kclass = macro_kclass
classesp = classes - 1
B = st_matrix("mlresults")
corr = macro_corr

external PostP

/* Create empty matrix to hold the posterior class probabilities */ 
CP = J(np,classes,0)
sumCP = J(np,1,0)
PostP = J(np,classes,0)
p = J(np,classes,0)

/* Split up the passed B matrix into the mean coefficients, standard errors, and class probabilities */
MRND = B[|1,1\kclass,1|]

if (corr == 1) {
	external macro_cho
	cho = macro_cho 
	SRND = J(kclass,kclass,0)
	for(j=1; j<=classes; j++) {
		SRND[|(((j-1)*k)+1),(((j-1)*k)+1)\(j*k),(j*k)|] = invvech(B[|(kclass+(((j-1)*(cho/classes))+1)),1\(kclass+(j*(cho/classes))),1|]) :* lowertriangle(J(k,k,1))
	}
	if (ccovnum > 0) gammas = B[|(kclass+cho+1),1\(kclass+cho+ccovnum),1|]
	cuts = B[|(kclass+cho+ccovnum+1),1\(kclass+cho+ccovnum+cutnum),1|]
}
else {
	SRND = diag(B[|kclass+1,1\(kclass*2),1|])
	if (ccovnum > 0) gammas = B[|(kclass*2)+1,1\(kclass*2)+ccovnum,1|]
	cuts =   B[|(kclass*2)+ccovnum+1,1\(kclass*2)+ccovnum+cutnum,1|]
}
	
/* Initial Halton sequence for later shuffling */
rseed(1234567)
firstrow = invnormal(halton(nrep,1,(1+burn)))
ERR = firstrow'
for (z=2; z<=kclass; z++) {
	if (MRND[z,1] == MRND[z-1,1] & SRND[z,1] == SRND[z-1,1]) {
		addz = ERR[|z-1,1\z-1,nrep|]
		ERR = ERR \ addz
	}
	else {
		addz = jumble(firstrow)
		ERR = ERR \ addz'
	}
}

	
i = 1
/* Calculate the posterior probabilities */
for (n=1; n<=np; n++) { 

	/* Shuffle the Halton sequence */ 
	ERR[|1,1\1,nrep|] = jumble(ERR[|1,1\1,nrep|]')'
	for (z=2; z<=kclass; z++) {
		if (MRND[z,1] == MRND[z-1,1] & SRND[z,1] == SRND[z-1,1]) {
			ERR[|z,1\z,nrep|] = ERR[|z-1,1\z-1,nrep|]
		}
		else {
			ERR[|z,1\z,nrep|] = jumble(ERR[|z,1\z,nrep|]')'
		}
	}
		
	/* Calculate the simulated beta vector using the halton series, the means, and the standard errors of the coefficients. */
	BETA = MRND :+ (SRND*ERR)
		
	/* If some beta distributions are specified by the user to be positive or negative log-normal, transform them here. */
	for (j=1; j<=kclass; j++) {
		if (lognormal[1,j] != 0) {
			BETA[j,.] = lognormal[1,j]:*exp(BETA[j,.])
		}
	}
	/* Calculate some more stuff */
	R = J(1,nrep,0)
	nc = macro_T[i,1]
	istart = i
	/* Loop for each class */ 
	for(j=1; j<=classes; j++) {
		RJ = J(1,nrep,1)
		i = istart
		for (t=1; t<=nc; t++) {
			/* Grab the data */
			YMAT = data_Y[|i,1\(i+data_CSID[i,1]-1),cols(data_Y)|]
			XMAT = data_X[|i,1\(i+data_CSID[i,1]-1),cols(data_X)|]

			/* Choice probability for that class, time period, and individual */
			EV = exp(XMAT*BETA[|(((j-1)*k)+1),1\(j*k),nrep|])
			EV = (EV :/ colsum(EV))
				
			/* Multiply with other time periods for that specific class and individual */
			RJ = RJ :* colsum(YMAT :* EV) 

			i = i + data_CSID[i,1]
		}
		
		/* Calculate the predicted probability that the choice would have been made for this class */
		CP[n,j] = colsum(RJ')
		
		/* Calculate the prior class probabilitiy */
		if (ccovnum > 0) {
			CCOVMAT = mean(data_ccov[|istart,1\(i-1),cols(data_ccov)|],1)
			if (j == 1) {
				COMP4 = exp(cuts[1,1] - CCOVMAT*gammas)
				p[n,j] = COMP4 / (1 + COMP4)
			}
			else if (j == classes) {
				COMP5 = exp(cuts[classesp,1] - CCOVMAT*gammas)
				p[n,j] = 1 - COMP5 / (1 +COMP5)
			}	
			else {
				COMP4 = exp(cuts[j-1,1] - CCOVMAT*gammas)
				COMP5 = exp(cuts[j,1] - CCOVMAT*gammas)
				p[n,j] = COMP5 / (1 + COMP5) - COMP4 / (1 + COMP4)		
			}
		}
		else {
			if (j == 1) {
				COMP4 = exp(cuts[1,1])
				p[n,j] = COMP4 / (1 + COMP4)
			}
			else if (j == classes) {
				COMP5 = exp(cuts[classesp,1])
				p[n,j] = 1 - COMP5 / (1 +COMP5)
			}	
			else {
				COMP4 = exp(cuts[j-1,1])
				COMP5 = exp(cuts[j,1])
				p[n,j] = COMP5 / (1 + COMP5) - COMP4 / (1 + COMP4)		
			}
		}
	}

	
	
	/* Calculate the posterior probability */
	for(j=1; j<=classes; j++) {
		sumCP[n,1] = sumCP[n,1] + CP[n,j]*p[n,j]
	}
	for(j=1; j<=classes; j++) {
		PostP[n,j] = (CP[n,j]*p[n,j]) / sumCP[n,1]
	}
}


}

void probtrans(real scalar i, real scalar j)
{
	external real matrix PostP

	value = PostP[i,j]
	
	st_numscalar("probval", value)
}


end
