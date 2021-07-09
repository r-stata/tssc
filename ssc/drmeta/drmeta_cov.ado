version 13
mata 

function avcov(string scalar covmat)
{
	cov  = st_matrix(covmat)
	
	nc = rows(cov)
	covvector = J( (nc*(nc+1)/2)-nc,1,.)
	
	s = 1
    k = 1
	
	tag = J(nc,nc,0)
	
	for (j=1; j<=rows(cov); j++) {
	
	   for (k=1; k<=rows(cov); k++) {		
	
				if (s <= rows(covvector)) {
			
						 if ( (j!=k) & (tag[k,j]!= 1) ) { 
									tag[j,k] = 1 
									covvector[s,1] = cov[j,k] 
									s++	
						  }		
				}					
		}
	}
	meancov = mean(covvector)
    st_numscalar("avcov", meancov)	
}

 
void greenland_fn(string scalar rr1, string scalar v1, string scalar tot, string scalar cases, string  scalar studytype1)
{
	real colvector  b, dose, se, n, A,  V, cx , ex, sx, sx_1, fitcontrols, SE
	real scalar i, m1, N, n0, api, a0i, SINCR, DCA, NUMCOR  
	real matrix H1 , H2, AP, INCR, A1, C, X, PASSA, PASSN, R

    st_view(rr=., .,rr1)
    st_view(v=., ., v1)  
	st_view(n=., ., tot, .)
	A = st_data(., cases)
    study = st_numscalar(studytype1)
	study
	if (study==1|study==3) {  
		n = A + n
	}
	
	
	b = log(rr)
	se = sqrt(v)
	tag0  = (se:==0)
	tag1  = (se:!=0)
	
	tagh = (1::rows(A))
	rh = select(tagh, tag1)'

	m1 = colsum(A)
	N = colsum(n)
	n0 = select(n, tag0)
	
	rg = select(tagh,tag0) 

	// Loop until converence (no more changes of fitted cases) 

	maxiter = 1000
	SINCR = 1
converged = 1
countiter = 0

while (abs(SINCR)>1e-5) {

	api = colsum(select(A, tag1))
	a0i = m1 - api
 	ex = J(rows(A), 1,.)
  
	if (study==1) {      
		cx = (1:/A) + 1:/(n:-A)	
  		for (i=1; i<=rows(A); i++) {
			ex[i] = b[i] + log(a0i)+log(n[i]-A[i])-log(A[i])-log(n0-a0i)
		}
	}

	if (study==2|study==3) {      
		cx = (1:/A)  
  		for (i=1; i<=rows(A); i++) {
			ex[i] = b[i] + log(a0i)+log(n[i])-log(A[i])-log(n0)
		}
	}

	H = J(rows(A),rows(A),cx[rg]) + diag(cx) 
	H = H[(rh),(rh)]
    AP = select(A, tag1) + invsym(H)*select(ex, tag1)
    INCR = invsym(H)*select(ex, tag1)
	SINCR = colsum(INCR)
	DCA = m1-sum(AP) 

	countap = (1::rows(AP))
	
	x = 1
	for (i=1; i<=rows(A); i++) {		
			if (se[i]==0) {
							A[i] = DCA
			}
			if (se[i]!=0) {
							A[i] = AP[x]
							x++
			}	 
	}
	
	countiter++		
	if(countiter>=maxiter) {
				    printf("{err:not converged}")
					displayflush()
					converged = 0
	}
	
}
     // Variances  
 
    sx = J(rows(A), 1,.)
	
	// case-control data 

	if (study==1) {  
			fitcontrols = n :- A 	
			sx_1  = sqrt(1:/A :+ 1:/fitcontrols :+ 1/A[rg] :+ 1/fitcontrols[rg]) 
 	}

	// cohort data (cumulative incidence data) 

	if (study==3) {   
      		sx_1  = sqrt(1:/A :- 1:/n :+ 1/A[rg] :- 1/n0) 
			fitcontrols = n :- A 	
	}	
	
	// cohort data (incidence rate data) 
	
	if (study==2) {   
      		sx_1  = sqrt(1:/A :+  1/A[rg]) 
			fitcontrols = n  	
	}
 
	sx = select(sx_1, tag1)
	SE = select(se,  tag1)
 
	//  Covariances  
		
	if (study==1) {   
      		NUMCOR  = (1/A[rg] + 1/fitcontrols[rg])
	}
	
	if (study==3) {   
      		NUMCOR  = (1/A[rg] - 1/n0) 
	}
	
	if (study==2) {   
      		NUMCOR  = (1/A[rg]) 
	}

// fill in the variance-covariance matrix

	_C = diag(select(v,tag1))
	SE = diagonal(sqrt(_C))	
 
	for (j =1; j<=rows(_C); j++) {
	 		for (i =1; i<=rows(_C); i++) {	
		  		if  (i != j)  _C[i,j] =  ( NUMCOR / ( sx[j]*sx[i]) ) * (SE[j]*SE[i])   
   			}
	}
 
// average covariance (mean of out of diagonal elements of C)

	nc = rows(_C)
	covvector = J((nc*(nc+1)/2)-nc,1,.)
	s = 1
 
	tag = J(nc,nc,0)
	
	for (j=1; j<=rows(_C); j++) {
	
	   for (k=1; k<=rows(_C); k++) {		
	
				if (s <= rows(covvector)) {

						 if ( (j!=k) & (tag[k,j]!= 1) ) { 

									tag[j,k] = 1 
									covvector[s,1] = _C[j,k] 
									s++	

						  }		
				}					
		}
	}
	

	_avcov = mean(covvector)

// correlation matrix

     _R = corr(_C)
	
	pA = A
	pN = fitcontrols
	
	st_matrix("cases", pA)
	st_matrix("noncases", pN)
	st_matrix("C", _C)
	st_matrix("R", _R)
	st_numscalar("avcov", _avcov)
	st_numscalar("niters", countiter)
	st_numscalar("converged",  converged)		
}


void hamling_fn(todo, p, rr, v, p0, z0, st, lf, g, H)
	{       
     a0 = p[1,1]
     b0 = p[1,2]

     rrs = J(rows(rr)-1,1,.)
     vs  =  J(rows(rr)-1,1,.)
	 
	 j = 1
	 for (i =1; i<=rows(rr); i++) {	
		  		if  (rr[i] != 1)  {
									rrs[j] = rr[i]
									vs[j] = v[i]
									j = j+1
				}
	}	
		 
	if (st == 1) {
		vexs = (vs:-1/a0:-1/b0) 
		ai  = (rrs:*(a0/b0):+1):/vexs
	    bi  = (b0:/(a0:*rrs):+1):/vexs
	}
	
	if (st == 3)  {
		vexs = (vs:-1/a0:+1/b0) 
		ai  = (1:-rrs:*(a0/b0)):/vexs  
		bi  = (b0:/(a0:*rrs):-1):/vexs
	}
	
	if (st == 2)  {
		vexs = (vs:-1/a0) 
		ai  = 1:/vexs  
		bi  = (b0:/(a0:*rrs)):/vexs
	}	
	
	 p1 = b0 / sum((b0\bi)) 
	 z1 = sum(bi) / sum(ai)
	
    lf = ((p0-p1))^2 + ((z0-z1))^2   

	// Create vectors of cases and noncases 
		
	 cases 	   = J(rows(rr),1,.)
     noncases  =  J(rows(rr),1,.)

	j=1
	
	for (i =1; i<=rows(rr); i++) {	
	 
	 	  		if  (rr[i] == 1)  {
	 							   cases[i] = a0
								   noncases[i] = b0
				}
				
		  		if  (rr[i] != 1)  {
									cases[i] = ai[j]
									noncases[i] = bi[j]
								    j = j + 1			
				}
				
	}	

    st_matrix("cases", cases)
    st_matrix("noncase", noncases)
}

function min_hamling_fn(string scalar rr1, string scalar v1 , string scalar p1, string  scalar z1, string  scalar a01, string  scalar b01, string  scalar studytype1, string  scalar refgroup)
{

    st_view(rr=., .,rr1)
    st_view(v=., ., v1)  
    p0 = st_numscalar(p1)
    z0 = st_numscalar(z1)
    a0 = st_numscalar(a01)
    b0 = st_numscalar(b01)
    st = st_numscalar(studytype1)
    rg = st_numscalar(refgroup)   
	
    // Initial values. This is important with Nelder-Mead. 

     initp = (a0,b0)
     delta = (a0 /10, b0/10)

        S = optimize_init()
        optimize_init_evaluator(S, &hamling_fn())
        optimize_init_evaluatortype(S, "d0")
        optimize_init_argument(S, 1, rr)
        optimize_init_argument(S, 2, v)
        optimize_init_argument(S, 3, p0)
        optimize_init_argument(S, 4, z0)
        optimize_init_argument(S, 5, st)
        optimize_init_params(S, initp)
        optimize_init_technique(S, "nm")   
        optimize_init_nmsimplexdeltas(S,delta)       
        optimize_init_which(S,"min") 
        optimize_init_conv_ptol(S, 1e-10)
	    optimize_init_conv_vtol(S, 1e-12)
        optimize_init_conv_nrtol(S, 1e-10)

        p = optimize(S)

        result = optimize_result_params(S)
        niters = optimize_result_iterations(S)
        converged = optimize_result_converged(S)
		S = .
        a0f = p[1,1]
        b0f = p[1,2]
                
		rrs = J(rows(rr)-1,1,.)
		vs  =  J(rows(rr)-1,1,.)
	 
	 j = 1
	 for (i =1; i<=rows(rr); i++) {	
		  		if  (rr[i] != 1)  {
									rrs[j] = rr[i]
									vs[j] = v[i]
									j = j+1
				}
	}	
          
	if (st == 1) {
		vexs = (vs:-1/a0f:-1/b0f) 
		ai  = (rrs:*(a0f/b0f):+1):/vexs
	    bi  = (b0f:/(a0f:*rrs):+1):/vexs
	}
	
	if (st == 3)  {
		vexs = (vs:-1/a0f:+1/b0f) 
		ai  = (1:-rrs:*(a0f/b0f)):/vexs  
		bi  = (b0f:/(a0f:*rrs):-1):/vexs
	}	
	
	if (st == 2)  {
		vexs = (vs:-1/a0f) 
		ai  = (1:/vexs)  
		bi  = (b0f:/(a0f:*rrs)):/vexs
	}	
	
		
	 cases 	   = J(rows(rr),1,.)
     noncases  =  J(rows(rr),1,.)
	 
	j=1

	for (i =1; i<=rows(rr); i++) {	
	 
	 	  		if  (rr[i] == 1)  {
	 							   cases[i] = a0f
								   noncases[i] = b0f
				}
				
		  		if  (rr[i] != 1)  {
									cases[i] = ai[j]
									noncases[i] = bi[j]
								    j = j + 1			
				}
				
	}	
	
	// create the variance-covariance matrix
	
	if (st == 1) {
	    _cov  =  1/a0f+1/b0f
		_se  = sqrt(1:/ai :+ 1:/bi :+ 1/a0f :+ 1/b0f) 
		st_numscalar("cov", 1/a0f+1/b0f)
	}
	
	if (st == 3)  {
		_cov  =  1/a0f-1/b0f
		_se  = sqrt(1:/ai :- 1:/bi :+ 1/a0f :- 1/b0f) 
		st_numscalar("cov", 1/a0f-1/b0f)
	}	
	
	if (st == 2)  {
		_cov  =  1/a0f
		_se  = sqrt(1:/ai :+ 1/a0f) 
		st_numscalar("cov", 1/a0f)
	}	
	
    _C = diag(vs)
	SE = sqrt(vs)
  
	for (j =1; j<=rows(_C); j++) {
	 		for (i =1; i<=rows(_C); i++) {	
		  		if  (i != j)  _C[i,j] =  ( _cov / ( _se[j]*_se[i]) ) * (SE[j]*SE[i])   
   			}
	}
	
	// create the correlation matrix
	
	_R = corr(_C)
	
	// Return results
	
        st_numscalar("niters", niters)
        st_numscalar("converged",  converged)
        st_matrix("cases", cases)
	    st_matrix("noncases", noncases)
	    st_matrix("C", _C)
	    st_matrix("R", _R)
		st_numscalar("avcov", _cov)
}

function glsest(string scalar y, string scalar x, string scalar cov)
{
	real matrix Y, X, C, BC, VB
	real scalar Q, LL 
	Y = st_matrix(y)
	X = st_matrix(x)
	C = st_matrix(cov)
 
// Variance and betas

	VB = invsym(X'*invsym(C)*X)
	BC = invsym(X'*invsym(C)*X)*X'*invsym(C)*Y
 
// Q goodness of fit

 	Q = (Y-X*BC)'*invsym(C)*(Y-X*BC)
	C2 = diag(C)

// log-likelihood

	LL =  -.5*rows(Y)*log(2*pi())-.5*log(det(C))-.5*Q

	st_matrix("r(BC)", BC)
	st_matrix("r(VB)", VB)
	st_numscalar("r(Q)", Q)
	st_numscalar("r(LL)", LL)
	st_matrix("r(COVAR)", C)
}

function crudest(string scalar logrr, string scalar cases, string scalar tot, real scalar study)
{
	real colvector n, A, EXPB, B, OT, COVBV 
	real scalar M_DIFF_C_A_RR
	real matrix C, R

	st_view(n=., ., tot, .)
	st_view(A=., ., cases, .)
	st_view(LRR=., ., logrr, .)
	
	RR = exp(LRR)

	OT = n - A

	// estimate crude beta coefficients

	if (study==1) {  
      		EXPB = (A:*OT[1]):/(A[1]:*OT) 
	}

	if (study==2|study==3) {    
      		EXPB = (A:*n[1]):/(A[1]:*n) 
	}

	B = log(EXPB)

	// estimate covariances of the crude beta coefficients
	
	if (study==1) {   
      		COVB  = (1/A[1] + 1/OT[1])
	}

	if (study==2) {   
      		COVB  = (1/A[1]) 
	}

	if (study==3) {   
      		COVB  = (1/A[1] - 1/n[1]) 
	}
	
	COVBV = J(rows(A)-1,rows(A)-1,COVB)
	COVBV = COVBV -  diag(COVBV)

	// estimate variances of the crude beta coefficients
     
	sx = J(rows(A), 1,.)

	if (study==1) {   
      		sx_1  =  (1:/A :+ 1:/OT :+ 1/A[1] :+ 1/OT[1] )
	}

	if (study==2) {   
      		sx_1  =  (1:/A :+  1/A[1])  
	}

	if (study==3) {   
      		sx_1  =   (1:/A :- 1:/n :+ 1/A[1] :- 1/n[1])
	}
      
	sx = sx_1[|2,1 \ ., .|]

      C = diag(sx[|1,1 \ ., .|])
 
	C = C + COVBV

	// estimate correlation matrix of the crude beta coefficients

      R = J(rows(C), cols(C),1)
 
	for (j =1; j<=rows(R); j++) {
	 		for (i=1; i<=rows(R); i++) {	
		  	 	// if  (i != j)  R[i,j] = COVB / sqrt(C[i,j]*C[j,i]) 
				if  (i != j)  R[i,j] = COVB / sqrt(sx[j]*sx[i])  
  			}
	}
	
	// relative comparison between crude and adjusted relative risks (check assumption 1)
	// (crude RR - adjusted RR)/ crude RR * 100

	DIFF_C_A_RR =   (EXPB :- RR):/(EXPB) * 100

	// this provides the percentage of the crude relative risks to be added or subtracted, depending on its
      //  positive or negative sign to the crude relative risks to get the adjusted relative risks 

	// calculate the average relative change (from crude to adjusted)  
      // of the relative risks at different exposure level  

	M_DIFF_C_A_RR = mean( abs(DIFF_C_A_RR[|2,1 \ ., .|] ) )

	// I'll also get the maximum and minimum relative change (excluding the referent relative risk)

	st_matrix("r(RD_C_A)", DIFF_C_A_RR)
	st_numscalar("r(M_RD_C_A)", M_DIFF_C_A_RR)
	st_matrix("r(CR_C)", C)
	st_matrix("r(CR_R)", R)
	st_matrix("r(CR_B)", B)
	st_matrix("r(CR_EXPB)", EXPB)
	st_matrix("r(ADJ_EXPB)", RR)
	st_numscalar("r(RD_max)", max(DIFF_C_A_RR[|2,1\.,1|]) )
	st_numscalar("r(RD_min)", min(DIFF_C_A_RR[|2,1\.,1|]) )
}


function blockaccum(string scalar a, string scalar b) 
{	
	real matrix A, B, GA
	A = st_matrix(a)
	B = st_matrix(b)
	GA = blockdiag(A,B)
	st_matrix("r(CACC)", GA)
}
end

*! N.Orsini v.1.0.0 10sep18

capture program drop drmeta_cov
program drmeta_cov, eclass
version 13
syntax varlist [if] [in] [ , s(varname numeric) tot(varname numeric) c(varname numeric) ecovmethod(string) ///
CRudes  pecohort  ptcohort casecontrol meandiff stdmeandiff ts(varname numeric)  vwls  meancov(varname numeric) matrixcov(string) varlistcov(varlist) detail ]

	tempvar  b dose se n case control v  rr
	tempname studytype C  R 
	
	tokenize `varlist'
	local depname  "`1'"
      mac shift
      local xname `*'

	// to use the option if/in  
	
	marksample touse, strok novarlist

	preserve
	qui keep if  `touse' &  `depname' != .

	// check observation
 
     qui count if `touse'
     local nobs = r(N)-1
		
	// get the arguments

	parse "`varlist'" , parse(" ")

	qui gen double `b' = `1'
	qui gen double `rr' = exp(`b')
	
	// get the type of study (either single study or multiple study)
		
		if `ts'[1] == 1  scalar `studytype' = 1 
		if `ts'[1] == 2  scalar `studytype' = 2
		if `ts'[1] == 3  scalar `studytype' = 3
		if `ts'[1] == 4  scalar `studytype' = 4
		if `ts'[1] == 5  scalar `studytype' = 5
	 
	if "`ts'"  == ""   {
		if "`casecontrol'"    != ""  scalar `studytype' = 1 
		if "`ptcohort'" 	  != ""  scalar `studytype' = 2
		if "`pecohort'" 	  != ""  scalar `studytype' = 3 
		if "`meandiff'" 	  != ""  scalar `studytype' = 4
		if "`stdmeandiff'" 	  != ""  scalar `studytype' = 5
	}
	
	if "`s'" != "" {
		qui gen double `se' = `s'
		qui gen double `v' = `se'^2
	}
	else {
		tempvar se v 
		qui gen `se' = .
		qui gen `v' = . 
	}

	tempname vcopy
	mkmat `v' if `b' != 0, matrix(`vcopy')
	qui count if `v' == .
	if r(N) != 0 local var = 0
	else local var = 1
		
if (`studytype'==4) {
    tempvar sd spi v_md cov_md se_md tag_ref
	qui gen double `n' = `tot'
	qui gen double `sd' = `c'
	qui gen `tag_ref' = `b' != 0 // identify the referent as Mean Difference = 0
	sort `tag_ref'
	qui gen double `spi' = cond(_n==_N,sum( (`n'-1)*`sd'^2)/sum(`n'-1),.)
    qui  replace `spi' = `spi'[_N]
	qui replace `v' = ((`n'+`n'[1])/(`n'*`n'[1]))*`spi'
	qui gen double `cov_md' = `sd'[1]^2/(`n'[1])
	qui replace `v' = 0 if _n == 1
	qui replace `se' = sqrt(`v')
	tempname mcov C R C1 C2 V1 V2 
	scalar `mcov' = `cov_md'[1]
	mat `C1' = J(`c(N)'-1, `c(N)'-1, `mcov')
	mat `C2' = `C1' - diag(vecdiag(`C1'))
	mkmat `v' if `b' != 0 , matrix(`V1')
	mat `V2' = diag(`V1')
	mat `C' = `C2' + `V2'
	mata: R = corr(st_matrix("`C'"))
	mata: st_matrix("_COR", R)
	mat `R' = _COR
	mat drop _COR
}

if (`studytype'==5) {
    tempvar smd sd spi v_smd se_smd tag_ref seq
	tempname n0 sumn
	qui gen double `n' = `tot'
	qui gen double `sd' = `c'
	qui gen `tag_ref' = `b' != 0 
	qui su `n' if `b' == 0 
	scalar `n0' = r(mean)
	qui su `n' 
	scalar `sumn' = r(sum)
	sort `tag_ref'
	qui gen double `spi' = cond(_n==_N,sum( (`n'-1)*`sd'^2)/sum(`n'-1),.)
    qui  replace `spi' = `spi'[_N]

    qui gen double `v_smd' = 1/`n'+1/`n0' + (`b'^2/(2*`sumn'))
	qui replace `v_smd' = 0 if `b' == 0
    qui gen `se_smd' = sqrt(`v_smd')
	
	tempname  V1 covij
	mkmat `v_smd' if `b' != 0 , matrix(`V1')
	mat `C' =  diag(`V1')
 
	qui gen `seq' = _n
	qui levelsof `seq' if `b' != 0, local(levels)
		
	tokenize `levels'
	forv i = 1/`nobs' {
		forv j = 1/`nobs' {
			 scalar `covij' = 1/`n0' + ((`b'[``i'']*`b'[``j''])/(2*`sumn'))
		  	if (`i' != `j')   mat `C'[`i', `j'] = `covij'
	
		}
	}
	mata: R = corr(st_matrix("`C'"))
	mata: st_matrix("_COR", R)
	mat `R' = _COR
	mat drop _COR
}


if "`meancov'" == "" & "`matrixcov'" == "" & "`varlistcov'" == "" & inlist(`studytype',4,5)!=1 {
	qui gen double `n' = `tot'
	qui gen double `case' = `c'
	
	if (`studytype'==1) qui replace `n' = `tot'-`c'

	*list `n' `tot' `c' `xname'
	
		tempname p z
		tempname a0 b0 a1 b1 tc tnc  
	
	    // Get K X 2 Table of Summarized Data (entry as variables)

		qui su `case' if `se' != 0  
		scalar `a1' =  r(sum)
		qui su `case' if `se' == 0  
		scalar `a0' =  r(sum)
        qui su `n' if `se' != 0  
		scalar `b1' =  r(sum)
		qui su `n' if `se' == 0  
		scalar `b0' =  r(sum)
		scalar `tc' = `a0' + `a1'
		scalar `tnc' = `b0' + `b1'
		scalar `p' =  `b0' / `tnc'
		scalar `z' = `tnc' / `tc'
		
		tempname crefg
		scalar `crefg'  =  1
}

tempname  FCASE FNCASE 

// Unless one specify directly the average covariance 
// Call mata function to calculate covariances using the Greenland and Longnecker method

	if "`meancov'" == "" & "`matrixcov'" == "" & "`varlistcov'" == "" & inlist(`studytype',4,5)!=1 {
	
	if "`ecovmethod'" == "GL" qui mata: greenland_fn("`rr'", "`v'", "`n'", "`case'",  "`studytype'")
		else qui mata: min_hamling_fn("`rr'", "`v'", "`p'", "`z'","`a0'","`b0'", "`studytype'", "`crefg'")  

			mat `C' =  C 
 			mat `R' = r(R)
			*mat `FCASE' = r(fitA)
			*mat `FNCASE' = r(fitB)
			*svmat  `FCASE', name(_A) 
			*svmat `FNCASE' , name(_B)
			
			*qui gen NT = _A + _B
			*eret matrix psc = `FCASE'
			*eret matrix psnc = `FNCASE'
			 
	}

	if "`meancov'" != "" {

			// Create the var/cov and correlation matrix		
			tempname mcov C1 C2 V1 V2 
			scalar `mcov' = `meancov'[1]
			mat `C1' = J(`c(N)'-1, `c(N)'-1, `mcov')
			mat `C2' = `C1' - diag(vecdiag(`C1'))
			mkmat `v' if `b' != 0 , matrix(`V1')
			mat `V2' = diag(`V1')
			mat `C' = `C2' + `V2'
			mata: R= corr(st_matrix("`C'"))
			mata: st_matrix("_COR", R)
			mat `R' = _COR
			mat drop _COR
	}

	if "`matrixcov'" != "" {
			// Create the var/cov and correlation matrix	
			mat `C' = `matrixcov'
			mata: R= corr(st_matrix("`C'"))
			mata: st_matrix("_COR", R)
			mat `R' = _COR
			mat drop _COR
	}
	
    if "`varlistcov'" != "" {
			// get only variable names corresponding to non-referent exposure levels 
			local nvariables = `c(N)'-1			
			forv i=1/`nvariables' {
				local subsetv = "`subsetv' `:word `i' of `varlistcov''"
			}
			mkmat `subsetv' if `b' != 0  , mat(`C') 
			mata: R= corr(st_matrix("`C'"))
			mata: st_matrix("_COR", R)
			mat `R' = _COR
			mat drop _COR
	}
	
tempname VB BC PASS X XP B bc vb pval ll Q fitcases

qui mkmat `xname' if `b' != 0, matrix(`X')
qui mkmat `b' if `b' != 0, matrix(`B') 

tempname ZC   
mat `ZC' = `X'

/*
if "`meancov'" == "" & "`matrixcov'" == "" & "`varlistcov'" == "" {
		svmat `FCASE', name(`fitcases') 
	}
*/
	
// Estimate beta corrected using weighted least squares for correlated outcomes
// Generalized Least Squares

* noisily di _n in w "Call Mata glsest()"

// Zero-covariance options (replaced 0 off-diagonal)

* In case of missing covariance, the out of diagonal matrix is set to zero.

tempname missingcovariance
scalar `missingcovariance' = 0
mata: st_numscalar("`missingcovariance'", hasmissing(st_matrix("`C'")))

if `missingcovariance' != 0 {
	tempname CZ  
	if (`var'==1) {
		mat `CZ' = diag(`vcopy')
		mat `C' = `CZ'
	}
	else {
		di as err "missing information to reconstruct the variance/covariance matrix"
		exit 198
	}
} 

if "`vwls'" != "" {
	* Replace the previous C with a diagonal matrix (0 off-diagonal elements) 
	tempname CZ  
	mat `CZ' = diag(vecdiag(`C'))
	mat `C' = `CZ'
}
 
mata: glsest("`B'", "`X'", "`C'")

mat `VB' = r(VB)
mat `BC' = r(BC)
scalar `Q' = r(Q)
scalar `ll' = r(LL)

		tempname b V  
		mat `V' = r(VB)
		mat `b' = r(BC)'

		mat rownames `b' = `depname'
		mat colnames `b' = `xname'

		mat rownames `V' = `xname'
		mat colnames `V' = `xname'

		ereturn post `b' `V' , dep(`depname') obs(`nobs') 
		
if "`detail'" != ""		ereturn display

// Get crude (un-adjusted) estimates of the betas and var-cov matrix

if "`crudes'" != ""   { 

	* noisily di in w _n "Call Mata crudest()"
	mata: crudest("`b'", "`case'", "`n'", `typestudy')

	tempname RD_min RD_max CR_C CR_EXPB CR_B  RD_C_A M_RD_C_A CR_R ADJ_EXPB MEANDIFF_C_A DIFF_C_A
	mat `CR_C' = r(CR_C)
	mat `CR_R' = r(CR_R)
	mat `CR_EXPB' = r(CR_EXPB)
	mat `ADJ_EXPB' = r(ADJ_EXPB)
	mat `CR_B' = r(CR_B)
	mat `RD_C_A' = r(RD_C_A)
	scalar `M_RD_C_A' = r(M_RD_C_A)
	scalar `RD_min' = r(RD_min)
	scalar `RD_max' = r(RD_max)

	// Compare crude and adjusted correlation matrix 

	mata: checklowhigh("`CR_R'", "`R'")
	scalar `MEANDIFF_C_A' = r(meandiffca)
	mat `DIFF_C_A' = r(diffca)
}

matrix colnames `X' = doses
matrix colnames `B' = betas
 
ereturn matrix x = `X'
ereturn matrix B = `B'
ereturn matrix R = `R'  

ereturn scalar N = c(N)- 1
 
if "`crudes'" != "" { 
 
	ereturn mat CR_C = `CR_C'
	ereturn mat CR_EXPB = `CR_EXPB'
	ereturn mat ADJ_EXPB = `ADJ_EXPB'
	ereturn mat CR_B = `CR_B'
	ereturn matrix RD_C_A  = `RD_C_A'
	ereturn scalar M_RD_C_A = `M_RD_C_A'
	ereturn scalar RD_min = `RD_min'
	ereturn scalar RD_max =  `RD_max'
	ereturn mat CR_R = `CR_R'
	ereturn scalar MEANDIFF_C_A = `MEANDIFF_C_A'
	ereturn matrix DIFF_C_A  = `DIFF_C_A'
}

// saved results

	ereturn scalar ll = `ll'
	ereturn matrix BC =  `BC'
	ereturn matrix VB =  `VB'
	ereturn matrix C =  `C'  
	ereturn matrix Z = `ZC'
	eret scalar chi2_gf2 = `Q'

end  
