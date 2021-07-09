* respondent driven sampling 
* Matthias Schonlau

**************************************************************************************
* output and error for keyvar
program keyvar_output, rclass
    version 10.1 
    syntax , keyvar(str) 
    
	* missing values for keyvar not allowed
    qui count if (missing(`keyvar'))
	if (r(N)>0) {
		di as error "Variable `keyvar' contains missing values."
		error 999
		exit
	}
	
	* warning if key var 
	qui tab `keyvar'
	di as res "Number of categories of (`keyvar'): " r(r) "
	if (r(r) > 30 ) {
		di as res "The number of categories is very large."
		di as res "If any of the variables in <varlist> is continuous you should recode the variables and rerun the program."
	}
	return scalar n_group=r(r)
end
**************************************************************************************
* Compute number of seeds and recruits by group
program count_seed_by_group, rclass
	version 10.1
	syntax , p_id(varname) keyvar(varname)
	
	tempvar seed
	qui gen `seed' = `p_id'==.
	qui tab `keyvar' `seed'  , matcell(SEED)
	
	* on rare occasions during bootstrapping the sample contains not a single seed 
	* then matcell has only one column leading to a conformability error later on
	* add a column of zeroes to reflect zero seeds
	if colsof(SEED)==1 {
		matrix SEED=SEED,(0\0) 
	}

end 
**************************************************************************************
* compute weights
* weights are computed for the entire sample including seeds (Heckathorn, Extension paper, p.194)
program compute_weights, eclass
	version 10.1
	syntax , degree(str) n_group(int) tmat(str) 

	* compute sample probabilities
 	matrix P = J(`n_group',1,.)
	mata: compute_p("DEGREE","P","`tmat'")
	ereturn matrix P=P, copy
	
    * compute weights by standardizing with sample probabilities
    matrix G = GROUPSIZE 
    matrix W = J(`n_group',1,.)
    mata: compute_w("W","G","P") 
	
end
//--------------------------------------------------------------------------------------
* Solve Ap=c equation subject to constraint sum_i(p_i)=1
* 	where A contains the reversability equations (first row is 1)
* 	where c is a vector of zeroes (except first row is 1)
capture mata mata drop compute_p
version 10.1
mata:
mata set matastrict on
// 
void compute_p(string scalar degreemat, string scalar pmat,string scalar tmat)
{ 
	real matrix   one , A

	// import matrices into mata
	DEG=st_matrix(degreemat)
	P=st_matrix(pmat)
	TT=st_matrix(tmat)
	
	// DEG and TT have the same number of rows; TT is square, DEG is not
	if (rows(DEG)!=rows(TT)) {
		"Coding Error: Number of rows of DD and TT differ."
	    exit(error(503))
	}

	// compute A
	r=rows(DEG)
	one=J(1,r,1)
	A=J(r-1,r,0)
	A= one \ A
	
	// ensure that categories in TT and rows in DD are in the same order
	// keyvar takes values from 1..n_combinations.
	// transition matrix TT is derived from tab  p_keyvar keyvar
	//	 tab uses ascending categories in both dimensions
	// DD[,"keyvar"] is ascending because it was sorted in compute_group_degree()
	
	//start with second row
	for(i=2;i<=r;i++) {
		// first column only
		A[i,1] = DEG[1,1]  :* TT[1,i]
		// diagonal
		A[i,i]= (-1) :* DEG[i,1] :*  TT[i,1]
	}
	
	// compute c 
	c=J(r,1,0)
	c[1,1]=1

	// solve Ap=c; where p are the probabilities  
    P = lusolve(A,c)
    
	// return matrix to stata
	st_matrix(pmat,P)
}
//---------------------------------------------------------------------------------------
// attach column of weights to matrix 
void  compute_w(string scalar w, string scalar groupsize , string scalar p) 
{
	real matrix WW, GG, PP

	// import matrices into mata
	GG=st_matrix(groupsize)
	PP=st_matrix(p)
	WW=st_matrix(w)
	
	// subtract seeds
	//GG= GG :-1 
	
	// weight=  needed proportion / current proportion 
	WW= PP :/ (GG / sum(GG)) 
	
	// return matrix to stata
	st_matrix(w,WW) 
	st_matrix(groupsize,GG/sum(GG)) 
}

end

***************************************************************************************
* compute transition probabilities from  p_keyvar , keyvar
* based on the smoothing algorithm
program compute_T, eclass
	version 10.1
	syntax varlist (min=2 max=2) , tmat(str) algorithm(str)
	
	tokenize `varlist' 
	qui tab  `1' `2', matcell(obs)
	if (r(c)!=r(r)) {
		di as err "There are too few observations relative to the number of categories of <varlist>."
		di as err "It is also possible different analysis variables were specified in rds_network and rds."
		error 999
		 
	}

	if ("`algorithm'"=="smoothing") {
		* compute transition probs by dividing each elem by rowsum
		mata: st_matrix("`tmat'",convert_count_probability("obs"))
		matrix T1=T

		* compute equilibrium for p satisfying p T= p I
		mata: st_matrix("E",compute_E("`tmat'"))

		* compute demographically adjusted matrix R
		mata: st_matrix("R",compute_R("obs","E","`tmat'"))

		* compute "smooth" observation matrix and overwrite obs
		mata: st_matrix("smoothR",smooth("R"))
	
		* re-compute transition probs by dividing each elem by rowsum 
		mata: st_matrix("`tmat'",convert_count_probability("smoothR"))

		* re-compute equilibrium for p satisfying p T= p I
		mata: st_matrix("E",compute_E("`tmat'"))
	}
	else {
		di as err "Unknown Algorithm"
	 	error 999
	}
	
	ereturn matrix T=`tmat'
end
//--------------------------------------------------------------------------------------
* divide matrix elementwise through rowsum
* set matrix T
capture mata mata drop standardize_T
version 10.1
mata:
mata set matastrict on
//
//---------------------------------------------------------------
// compute equilibrium for p satisfying p T= p I subject to sum(p)=1  , hence p(T-I)=0
real matrix compute_E(string scalar mymat)
{ 

	real matrix p, A, c , T
	real scalar r
	
	// acquire data , keep a copy , T, around for error message
	A= st_matrix(mymat)
	T=A
	A=A'
	
	
	// compute A=(T'-I) , but set first row to 1
	r=rows(A)
	A= A-I(r)
	for(i=1;i<=r;i++) {
		A[1,i]=1
	}
	
	// compute c 
	c=J(r,1,0)
	c[1,1]=1
		
	// solve Ap=c; where p are the probabilities  
	p = lusolve(A,c)
	
	// if one or more probabilities are zero, equilibrium is degenerate 
	if (sum(p:==0)>0) {
		errprintf("Transition Matrix\n")
		T
		errprintf("Equilibrium Distribution.\n")
		p
		errprintf("Error: One or more groups recruit only among themselves.\n") 
		errprintf("       (Degenerate Equilibrium Distribution.)\n")
		exit(999)
	}
	
	return(p)

}
//---------------------------------------------------------------
// compute demographically adjusted matrix R
real matrix compute_R(string scalar omat,string scalar evec, string scalar tmat)
{ 

	real matrix RR, EE, OBS, TT
	real scalar n

	// acquire data 
	OBS= st_matrix(omat)
	EE= st_matrix(evec)
	TT= st_matrix(tmat)

	if (cols(TT)!=rows(EE)) {
		TT
		EE
		exit(error(503)) // conformability error
	}

	// compute the total recruiting sample size
	n=sum(OBS)

	// compute R by elementwise multiplying vector EE
	RR= n * TT :* EE

	return(RR)
}
//---------------------------------------------------------------
void standardize_T(string scalar mymat)
{ 
	real matrix TT

	TT= st_matrix(mymat)
	
	r=rowsum(TT)
	TT = TT :/ r
	st_matrix("T",TT)
}
//---------------------------------------------------------------
// this function does not require the name "T" inside of it
real matrix convert_count_probability(string scalar mymat)
{ 
	real matrix TT

	TT= st_matrix(mymat)
	r=rowsum(TT)

	if ((sum(r:==0))>0) {
			errprintf("Error: (row) sum of probabilities was 0. \n")
			exit(999)
	}
	TT = TT :/ r
	return(TT)
}
//----------------------------------------------------------------
// "smoothing", i.e. make matrix symmetrical by taking averages
real matrix smooth(string scalar mymat)
{ 
	real matrix  SM
	real scalar  x

	SM= st_matrix(mymat)
	
	if (cols(SM)==rows(SM)) {
		r=rows(SM)
		for(i=1;i<=r;i++) {
			for(j=1;j<=r;j++) {
				x= (SM[i,j]+ SM[j,i])/2
			 	SM[i,j]= x
			 	SM[j,i]= x
			 }
		}
	}
	else {
		SM
		exit(error(503)) //conformability error
	}
	return(SM)
}

end
***************************************************************************************
* purpose: evalute argument "detail"
program convergence
	version 10.1
	syntax ,  convtol(real)  [ detail ]
	
	if ("`detail'"!="") {
		assess_convergence , convtol(`convtol') 
	}
	else {
		qui	assess_convergence , convtol(`convtol')  
	}

end
***************************************************************************************
* how fast does transition matrix T converge to a stable distribution?
* passes on matrix T to mata 
program assess_convergence, eclass
	version 10.1
	syntax , convtol(real) 
	
	if (`convtol'<=0 | `convtol'>1) {
	 	di as err  "Convergence Tolerance convtol=`convtol' must be between 0 and 1."
	}
	di "Computing how fast transition matrix converges."
	mata: conv_T("T",`convtol')	 


end 
//--------------------------------------------------------------------------------------
// 
capture mata mata drop conv_T()
version 10.1
mata:
mata set matastrict on
void conv_T(string scalar mymat, real scalar myconvtol)
{ 	
	TT= st_matrix(mymat)
	printf("Convergence Tolerance= %f\n", myconvtol)
	Mnew = I(rows(TT))

	i=0
	printf("Iteration %f\n", i)	
	Mnew
	
	do {
		i=i+1
		printf("Iteration %f\n",i)
		Mold=Mnew
		Mnew=TT'*Mold
		Mnew
	} while (max(Mnew-Mold)>myconvtol)	
	st_numscalar("e(conv_iter)", i)
}
end
***************************************************************************************
* convergence output
* requires (conv_iter) and (max_depth) 
program convergence_output
		version 10.1
		syntax , max_depth(numlist int max=1 missingokay) 
		
		di as res "Required referral length until convergence: " e(conv_iter)
		if (`max_depth'!=.) {
			di as res "Greatest Chain length: " `max_depth'
			if (e(conv_iter)<=`max_depth') {
				di as res "Convergence achieved. (Greatest chain length is sufficiently large)"
			}
			else {
				di as err "Convergence NOT achieved. Inference is not valid." 
			}
		}
end
***************************************************************************************
* compute group degree ("average" network size in the group)
* creates matrix D
program compute_group_degree
	version 10.1
	syntax , degree(str) keyvar(str) net(str)  parent_id(str)
	tempvar groupsize degree_group_av degree_group_mult n_noseed VHestimator
	tempname dmat

	qui count if (`degree'<=0 & `degree'!=.)
	if (r(N)>0) {
		di as error "Variable `degree' contains zeros or negative values."
		error 999
		exit
	}

	* groupsize including seeds
	qui gen `groupsize'=.
	qui bysort `keyvar': replace `groupsize'=_N
	
	* groupsize without seeds 
 	*  qui bysort `keyvar': egen `n_noseed'=count(`parent_id')

	qui gen `degree_group_av'=.
	qui gen `degree_group_mult'=.
	qui gen `VHestimator'=.
	compute_group_degree_av, degree(`degree') keyvar(`keyvar') group(`degree_group_av') pid(`parent_id')
	compute_group_degree_multi, degree(`degree') keyvar(`keyvar') group(`degree_group_mult') vhvar(`VHestimator') pid(`parent_id')

	* save results into dmat
	* sort `keyvar' ensures that the rows of dmat have the same order as the categories in T
	preserve
	contract `keyvar' `groupsize' `degree_group_av' `degree_group_mult' `VHestimator'
	sort `keyvar'
	mkmat `keyvar' `groupsize' `degree_group_av' `degree_group_mult' `VHestimator', matrix(`dmat')
	mat colnames  `dmat'= keyvar groupsize degree_av degree_mult VHestimator
	restore

	matrix DEG_AV = `dmat'[1..rowsof(`dmat'),"degree_av"]
	matrix DEG_MULT = `dmat'[1..rowsof(`dmat'),"degree_mult"]
	matrix GROUPSIZE = `dmat'[1..rowsof(`dmat'),"groupsize"]
	matrix VHVAR = `dmat'[1..rowsof(`dmat'),"VHestimator"]
	matrix KEYVAR = `dmat'[1..rowsof(`dmat'),"keyvar"]
	
	* matrix DEGREE is used for estimation
	matrix DEGREE=DEG_MULT
	if ("`net'"=="average" | "`net'"=="a") {
			di as res "Method to compute Av. Network Size = average"
			matrix DEGREE=DEG_AV
	}
	else {
			di as res "Method to compute Av. Network Size Method = multiplicity"
	}
 
end
******************************************************************************************
* compute average group degree
* generates: degree_av
program compute_group_degree_av
	version 10.1
	syntax , degree(str) keyvar(str) group(str) pid(str)
	tempvar groupsize degree_sum included
	
	* only include observations with non-missing degrees; exclude seeds
	qui gen `included'=1
	qui replace `included'=. if `pid'==. | `degree'==.   // exclude seeds
	qui bysort `keyvar': egen `groupsize'=count(`included')
	
	* exclude undesired obs by multiplying with an indicator
	qui bysort `keyvar': egen `degree_sum'=sum(`degree' * (`included'!=.) )
	qui replace `group'= `degree_sum' / `groupsize'
end
***************************************************************************************
* compute group degree multiplicity
* generates: degree_mult, VHestimator
program compute_group_degree_multi
	version 10.1
	syntax , degree(str) keyvar(str) group(str) vhvar(str)  pid(str)
	tempvar suminvdegree sumtotal included groupsize
	
	* only include observations with non-missing degrees; exclude seeds
	qui gen `included'=1
 	qui replace `included'=. if `pid'==. | `degree'==.   // exclude seeds
	qui bysort `keyvar': egen `groupsize'=count(`included')
	
	* exclude undesired obs by multiplying with an indicator
	qui bysort `keyvar': egen `suminvdegree'=sum(1/`degree' * (`included'!=.)) 
	qui replace `group'= `groupsize'/ `suminvdegree'

	// compute Volz Heckathorn estimator
	qui egen `sumtotal'=sum(1/`degree' * (`included'!=.)) 
	qui replace `vhvar'= `suminvdegree' / `sumtotal'

end
***************************************************************************************
* Formula for group a:   Ha = (Saa - Pa )/ (1- Pa)
* requires  matrices T and P
program compute_homophily
	version 10.1
	syntax , n_group(int)
	
	matrix H = J(`n_group',1,.)
	foreach a of numlist 1/`n_group' {
		matrix H[`a',1] = (T[`a',`a'] - P[`a',1] ) / (1- P[`a',1])
	}
end 
***************************************************************************************
* degree and recruitment components
program compute_components
	version 10.1
	syntax, n_group(int)
	
	matrix RC = J(`n_group',1,.)
	matrix DC = J(`n_group',1,.)
	
	foreach a of numlist 1/`n_group' {
		* recruitment component: E/G
		matrix RC[`a',1] = E[`a',1] / G[`a',1] 
		* degree component P/E
		matrix DC[`a',1] = P[`a',1] / E[`a',1] 
	}
	
end
***************************************************************************************
program output
	version 10.1
	syntax , n_group(int) keyvar(str)
	
	local lab : value label `keyvar'
	local name = ""
	if ("`lab'"=="") {
		local fill="Group"
	}
	
	qui levelsof `keyvar', local(levels)
	foreach i of local levels {
		* get labels up to length 12
		local l : label (`keyvar') `i' 12
		* substitute white spaces with _ to avoid conformability error for matrix rownames
		local l = subinstr("`l'"," ","_",.)
		local name="`name' `fill'`l'"

	}
	
	matrix rownames obs = `name'
	matrix colnames obs = `name'
	di
	di "Observation matrix"
	matrix list obs, noblank nohalf noheader title("Observation matrix")
	di 
	
	matrix rownames T1 = `name'
	matrix colnames T1 = `name'
	di "Transition Matrix (Before Smoothing)"
	matrix list T1, noblank nohalf noheader title("Transition Matrix (Before Smoothing)")
	di
	
	matrix rownames R = `name'
	matrix colnames R = `name'
	di "Demographically adjusted matrix
	matrix list R, noblank nohalf noheader title("Demographically adjusted matrix")
	di 
	
	matrix rownames smoothR = `name'
	matrix colnames smoothR = `name'
	di "Data-Smoothed Recruitments"
	matrix list smoothR , noblank nohalf noheader title("Data-Smoothed Recruitments")
	di
	
	matrix rownames T = `name'
	matrix colnames T = `name'
	di "Transition Matrix"
	matrix list T, noblank nohalf noheader  title("Transition Matrix")
	di 
	
	* SEED is a matrix containing sample size AND recruits
	matrix  ALL = KEYVAR'  \ GROUPSIZE' \ SEED' \ G' \ E'  \ DEG_AV' \ DEG_MULT' \ H' \ W' \  RC' \ DC' \ P' \ VHVAR'
	matrix rownames ALL = Categories  SampleSize Recruits Seeds SampleProportion Equilibrium   AverageDegree MultiplicityDegree Homophily Weight RecruitmentComponent DegreeComponent PopulationProportion VolzHeckathornProp
	matrix colnames ALL = `name'
	matrix list ALL , noblank title("Estimates") noheader
	matrix drop ALL
	
end
***************************************************************************************
*  add rownames to VHVAR and P (need unique rows for bootstrapping)
program assemble_rownames
	version 10.1
	syntax, 
	
	local nrows=rowsof(P)
	local myname=""
	forval i=1/`nrows' {
		local el=el(KEYVAR,`i',1) 
		local myname= "`myname' P`el'" 
	}
	matrix rownames P = `myname'

	local myname=""
	forval i=1/`nrows' {
		local el=el(KEYVAR,`i',1) 
		local myname= "`myname' VH`el'" 
	}
	matrix rownames VHVAR= `myname'
	
end
***************************************************************************************
* Note : "numlist int max=1 missingokay" means "int" where missing is okay
program ereturn_objects, eclass
	version 10.1
	syntax , n_group(int) n_seed(numlist int max=1 missingokay) max_depth(numlist int max=1 missingokay) touse(varname)


	* set esample after "restore"  
	* stata's bootstrap workes for scalars. By posting to e(b) a vector can be bootstrapped.
	tempname b 

	assemble_rownames
	matrix b=P' , VHVAR'

	gen esample=`touse'
	if (!matmissing(b)) {
		ereturn post b, esample(esample)
	}
	else {
		di as error "Error: Cannot solve for P with estimated transition matrix."
		drop esample 
		* not using "exit" to enable posting of information below 
	}
	
	* scalars  (cmd="bootstrap", otherwise bootstrap does not work)
	ereturn local cmd="bootstrap"
	ereturn scalar n_group=`n_group'
	
	* in bootstrap mode n_seed and max_depth are not set (remain ".")
	if (`n_seed'!=.) {
		ereturn scalar n_seed=`n_seed'
	}
	if (`max_depth'!=.) {
		ereturn scalar max_depth=`max_depth'
	}
	
	* square matrices
 	ereturn matrix obs =obs
 	ereturn matrix T1=T1
 	ereturn matrix R=R
 	ereturn matrix smoothR= smoothR
 	ereturn matrix T =T
 	
 	* vectors
 	ereturn matrix H=H
 	ereturn matrix CATEGORIES=KEYVAR
 	ereturn matrix E=E
 	ereturn matrix DEGREE=DEGREE
 	ereturn matrix GROUPSIZE=GROUPSIZE
 	ereturn matrix P=P
 	ereturn matrix W=W
 	ereturn matrix SampleP=G
	ereturn matrix VH=VHVAR

end
***************************************************************************************
* if desired, copy weights from matrix into a new weight variable  
* population weight: weightp ;  individual weight : weight
program create_wgtvar
	version 10.1
	syntax, keyvar(str) n_group(int) touse(str) degree(varname) [ weight(str) weightp(str) ]
	* if desired, copy weights from matrix to individuals 
	if ("`weightp'"!="") {
	    qui gen `weightp' = .
	    foreach row of numlist 1/`n_group' {
			qui replace `weightp'= el("W",`row',1)  if `touse' & `keyvar'== KEYVAR[`row',1] 
		}
	}
	if ("`weight'"!="") {
		qui gen `weight' = .
		foreach row of numlist 1/`n_group' {
			* individualized weight (use group degree if missing degree)
			qui replace `weight'= el("RC",`row',1)/`degree'  if `touse' & `keyvar'== KEYVAR[`row',1]
			qui replace `weight'= el("RC",`row',1)/el("DEGREE",`row',1)  if `touse' & `keyvar'== KEYVAR[`row',1] & missing(`weight'[_n])
		}
		*standardization
		qui sum `weight' 
		qui replace `weight'=`weight'/r(mean)
	}
end
***************************************************************************************
***************************************************************************************
program rds , eclass sortpreserve
*! 0.0.1 June 11, 2010, Matthias Schonlau
*! 0.0.2 July 2, 2010, graceful exit when lusolve fails
*! 0.0.3 July 12, 2010, fixed bug related to names (recruiter_id and recruiter_var), degree=0 disallowed  
*! 0.0.4 July 28, 2010 individual weights, added degree components
*! 0.0.5 November 10, 2010  Improved error message for degenerate equilibrium
*! 0.0.6 November 24, 2010 Improved error message for compute_T 
*! 0.0.7 December 1, 2010 fixed bug related to creating a weight variable (matrix names must be passed as strings into el())
*! 0.0.8 March 10, 2011 fixed bug for rare conformability error when sample contained no seed (e.g. during bootstrap)
*! 0.0.9 March 18, 2011 fixed bug in computation of how fast convergence is reached
*! 0.1.0 April 19, 2011 slight change in output order (population proportion last)
*! 1.0.0 November 4, 2011 ; no updates
*! 1.0.1 Mar 20, 2012; fixed bug that arose when varname contained labels with spaces (conformability error)
*! 1.0.2 Apr 20,2012; fixed bug: reset esample after "Error: Cannot solve for P with estimated transition matrix."
*! 1.1.0 Sep 25, 2013 add Volz-Heckathorn estimator
	version 10.1
	syntax varname (numeric) [if] [in], id(varname) degree(varname) recruiter_id(varname) recruiter_var(varname) [ wgt(str) wgt_pop(str) detail convtol(real 0.02) NETwork_size_method(str) ]

	marksample touse, novarlist
	preserve 
	qui drop if !`touse'

	tempvar keyvar p_id p_keyvar

	* Use recruiter data
	if ("`recruiter_id'"=="" | "`recruiter_var'"=="" ) {
			di as error "Both rcruiter_id and recruiter_var need be specified."
			error 999
			exit 
	}

	* calculate keyvar 
	local keyvar "`varlist'"
	keyvar_output, keyvar(`keyvar') 
	local n_group= r(n_group)

	* network info 
	qui gen `p_keyvar'= `recruiter_var'
	qui gen `p_id' = `recruiter_id'
	label var `p_keyvar' "recruiter var"
	label var `p_id' "recruiter id"
	qui count if `p_id'==.
	local n_seed=r(N)
	local max_depth=.
 	
	* compute transition probabilities 
	compute_T `p_keyvar' `keyvar', algorithm("smoothing") tmat("T") 
	matrix T=e(T)
	
	* assess convergence 
	convergence, `detail' convtol(`convtol') 
	convergence_output, max_depth(`max_depth')

	* compute network size (degree at the group level)
	if ("`network_size_method'"=="") {
		* set default method to estimate av network size
		local network_size_method  "multiplicity"
	}
	compute_group_degree, degree(`degree') keyvar("`keyvar'") parent_id("`p_id'") net("`network_size_method'") 

	* compute weight variable
	compute_weights,  degree(`degree') tmat("T") n_group(`n_group') 
	
	* compute homophily
	compute_homophily, n_group(`n_group') 
	
	* compute degree and recruitment component of population estimate
	compute_components, n_group(`n_group')

	* output 
	count_seed_by_group, keyvar(`keyvar') p_id(`recruiter_id')
	output , n_group(`n_group') keyvar(`keyvar')
 
	restore 	

	* create variable (after restore, otherwise changes deleted on restore)
	create_wgtvar, weight("`wgt'") weightp("`wgt_pop'")  degree("`degree'") keyvar("`keyvar'") n_group(`n_group') touse(`touse')
	
	* ereturn 
	ereturn_objects  , n_group(`n_group') n_seed(`n_seed') max_depth(`max_depth') touse(`touse')
	matrix drop DEG_MULT
	matrix drop DEG_AV
	matrix drop SEED
	matrix drop DC
	matrix drop RC

end 
**************************************************************************************
