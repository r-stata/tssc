*!version3.0 04Mar2020

/* -----------------------------------------------------------------------------
** PROGRAM NAME: xtgeebcv
** VERSION: 3.0
** DATE: MARCH 4, 2020
** -----------------------------------------------------------------------------
** CREATED BY: JOHN GALLIS, FAN LI, LIZ TURNER
** -----------------------------------------------------------------------------
** PURPOSE: To facilitate the computation of finite-sample corrected standard errors
**			in generalized estimating equations (GEE) models.
** -----------------------------------------------------------------------------
** UPDATES: Sep 10, 2019 - For easier coding and postestimation, require user to 
							dummy code his/her categorical variables; removing
							"categorical" option
			Sep 20, 2019 - std_err option changed to stderr
						 - stderr option arguments changed to lowercase
						 - default family changed to binomial
						 - added esample() to ereturn post to allow for postestimation
						 - subset the regression with touse, rather than the dataset
			Jan 24, 2020 - Bug fix: Added "level" option to _coef_table.
			Mar 02, 2020 - Major update: Program now allows for factor variables in the regression, and also
							allows for postestimation, for example, using the "margins" command.
						   Also, does not require outcome variable to be specified.
			Mar 03, 2020 - Updated to remove missing values in data read into Mata and in the "beginend" matrix.
			Mar 04, 2020 - Finalized code and applied bug fixes; added warning if degrees of freedom for t distribution
							is less than or equal to 0.
**			
** -----------------------------------------------------------------------------
** OPTIONS: SEE HELP FILE
** -----------------------------------------------------------------------------
*/

program define xtgeebcv, eclass
	version 15
	
	#delimit ;
	syntax varlist(fv min=1) [if] [in], 
		cluster(varname) [family(string) link(string) stderr(string) statistic(string) corr(string) eform *]
	;
	#delimit cr
	
	marksample touse
	/* \\\\\\\ SET STRING DEFAULTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	if "`family'" == "" local family "binomial"
	if "`link'" == "" & "`family'"=="binomial"  local link "logit"
	if "`link'" == "" & "`family'"=="poisson" local link "log"
	if "`link'" == "" & "`family'"=="gaussian" local link "identity"
	if "`stderr'" == "" local stderr "kc"
	
	if "`statistic'" == "" local statistic "t"
	if "`corr'" == "" local corr "exch"
	
	/* \\\\\ CREATING TEMPFILE SO THAT THE USER GETS THEIR FULL DATASET BACK AT THE END \\\\
	\\\\\\\\ EVEN IF MISSING VALUES ARE DELETED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	
	/* \\\\\ DROP MISSING VALUES IN THE REGRESSION VARIABLES \\\\\\\\\\ */
	qui count
	local N = r(N)
	
	* working with factor variables
	fvrevar `varlist', stub(_x_)
	local newvarlist = "`r(varlist)'"
	fvexpand `varlist'
	
	*for identifying position of 0's
	local oldvarlist = "`r(varlist)'"
	
	local colnames = ""
	local subtractlist = ""
	local i = 1
	foreach wrd in `r(varlist)' {
		local tmpvar1: word `i' of `newvarlist'
		local tmpvar2: word `i' of `oldvarlist'
		if strpos("`wrd'", "b.") > 0 {
		   local addlist "`tmpvar1'"
		   local add2list "`tmpvar2'"
		   local position: list posof `"`tmpvar2'"' in oldvarlist
		   local position = `position' - 1
		   local subtractlist : list subtractlist | addlist
		   local positionlist : list positionlist | position
		}
		else {
			local colnames `colnames' `wrd'
		}
		local i = `i' + 1
	}
	
	*newvarlist only contains non-zero parameters
	local newvarlist: list newvarlist - subtractlist
	
	/* \\\\\ INFORMATIONAL MESSAGES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	local famlink: list family | link
	di " "
	di as text "Note: Family is `family' and link is `link'"
	if substr("`corr'",1,3) == "exc" {
		di "Using exchangeable working correlation"
	}
	else if substr("`corr'",1,3) == "ind" {
		di "Using independent working correlation"
	}
	else {
		di as error "Invalid working correlation specification.  Only exchangeable (exch) and independent (ind) are supported at this time"
		exit 198
	}
	di as text "with scale parameter divided by K - p"
	
	/* \\\\\ CODE TO ADD _INTERCEPT TO VARLIST \\\\\\\\\\\\\\\\\\\\\\\\\\ */
	capture drop _intercept
	gen _intercept = 1
	local add "_intercept"
	
	/* \\\\\ RUN STANDARD GEE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	xtset `cluster'
	xtgee `varlist' if `touse', family(`family') link(`link') corr(`corr') nmp `eform' `options'
	local level=r(level)
	
	tempname b V noomit
	matrix `b' = e(b)
	matrix `V' = e(V)
	_ms_omit_info `b'
	local cols = colsof(`b')
	matrix `noomit' =  J(1,`cols',1) - r(omit)

	mata: newV = select(st_matrix(st_local("V")),(st_matrix(st_local("noomit"))))
	mata: newV = select(newV, (st_matrix(st_local("noomit")))')
	mata: st_matrix(st_local("V"),newV)
		
	/* reduce matrix b */
	mata: newB = select(st_matrix(st_local("b")),(st_matrix(st_local("noomit"))))
	mata: st_matrix(st_local("b"),newB)
	/* \\\\\\\\\\ WORKING CORRELATION MATRIX AND BETA (REGRESSION ESTIMATES) MATRIX \\\\ */
	matrix R = e(R)
	matrix Beta = `b'
	
	* because of error(?) in Mata, have to pass the unchanged Beta matrix to Mata
	matrix Beta2 = `b'
	
	/* \\\\\\\\\\\ PUT _CONS AT BEGINNING OF BETA MATRIX \\\\\\\\\\\\\\ */
	preserve
		drop _all
		qui svmat Beta
		qui codebook
		loc lastvar: word `c(k)' of `r(cons)'
		order `lastvar'
		qui mkmat _all, matrix(Beta)
	restore

	/* \\\\\\ WORKING CORRELATION AND THE SCALE PARAMETER (PHI) \\\\\\\\ */
	local wcorr = R[2,1]
	local phi = e(phi)
	
	/* \\\\\\\ SPECIFY OUTCOME \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	local outcome: word 1 of `newvarlist'
	
	/* \\\\\\ ADD _INTERCEPT TO THE BEGINNING OF NEWVARLIST \\\\\\\\\\\\\ */
	qui local newvarlist2="`newvarlist'"
	qui local newvarlist : list add | newvarlist
	
	/* \\\\\\ SORT THE CLUSTERS THEN CREATE A NEW CLUSTER ID VARIABLE WHICH IS \\\\\\\\\\\\
	\\\\\\\\\ SEQUENTIAL \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	sort `cluster'
	capture drop _newclustid
	egen _newclustid = group(`cluster')
	
	preserve
	/* \\\\\\\\\\ OBTAIN NUMBER IN EACH CLUSTER \\\\\\\\\\\\\\\\\\\\ */
	* Update 3/3/2020 - remove missing values
	
		local i = 1
		foreach x in `newvarlist2' {
			local tmpvar1: word `i' of `newvarlist2'
			capture confirm numeric variable `tmpvar1'
				if !_rc {
					quietly drop if `tmpvar1' == .
				}
				else {
					quietly drop if `tmpvar1' == ""
				}
			local i = `i'+1
		}
		
		qui tab _newclustid, matcell(clust)

	/* \\\\\\\\\\ OBTAINING LOCATION OF FIRST AND LAST OBSERVATION \\\\\\\\\\\\\\\\\\
	\\\\\\\\\\\\\ WITHIN EACH CLUSTER \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	
		capture {
			drop freq 
			drop cumfreq 
			drop _first 
			drop _last 
			drop tag_cluster
		}
		
		qui bys _newclustid: gen freq = _N
		qui bys _newclustid: gen cumfreq = _N if _n == 1
		qui replace cumfreq = sum(cumfreq)

		qui gen _first=cumfreq-(freq-1)
		qui gen _last=cumfreq
		qui egen tag_cluster = tag(_newclustid)
		qui keep if tag_cluster == 1
		qui mkmat _first _last, matrix(beginend)
	restore
	
	/* \\\\\\\\\\\\\\\\\\\\\\\\\\\ RUN MATA PROGRAM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ */
	mata: gee("`newvarlist'","beginend","clust","Beta","Beta2",`wcorr',`phi',"`famlink'")
	/* \\\\\\\ ADD INTERCEPT TO END OF VARLIST \\\\\\\\\\\\ */
	qui local newvarlist : list newvarlist - add
	qui local add = "_cons"
	qui local newvarlist : list newvarlist | add
	
	/* \\\\\\\\\\\\\\\\\\ OUTPUTTING THE REQUESTED VARIANCE TO E(V) \\\\\\\\\\\\\\\ 
	\\\\\\\\\\\\\\\ AND UPDATING REGRESSION TABLE WITH CORRECTED STANDARD ERRORS \\*/
	
	/* \\\\\\\\\\\ Robust, df, kc, md, fg, AND mbn CORRECTIONS \\\\\\\ */
	local bcvs "rb df kc md fg mbn"
	local names ""Robust" "Degrees-of-Freedom" "Kauermann-Carroll" "Mancl-DeRouen" "Fay-Graubard" "Morel-Bokossa-Neerchal""
	local n: word count `bcvs'
	forvalues i=1/`n' {
		local bcv: word `i' of `bcvs'
		local name: word `i' of `names'
		
		if "`stderr'" == "`bcv'" {
			
			/* \\\\\\\ DEGREES OF FREEDOM FOR THE T DISTRIBUTION \\\\\\\\ */
			local dof=nclust[1,1]-ncoef[1,1]

			/* \\\\\\ UPDATE STANDARD ERRORS WITH BIAS CORRECTION \\\\\\ */
			
			*ADD ONE ROW TO POSITIONLIST FOR THE LAST ROW IN THE MATRIX
			local last = rowsof(e(V))+1
			local positionlist `"`positionlist' `last'"'
			local positionsize: list sizeof positionlist
		
			* check for a position-list length of 1; if 1, then there are no factor variables in the model
			if "`positionsize'" == "1" {
				matrix var`bcv'final2 = var`bcv'
			}
			else {
			
				/* ADDING ZEROS BACK TO ROWS IN VARIANCE MATRIX */
				local i=1
				foreach wrd in `positionlist' {
					local j=`i'-1
					local t: word `i' of `positionlist'
					local t0 = `t' - `i'
					
					if `i' == 1 {
						if `t0' == 0 {
							local cols=colsof(var`bcv')
							matrix var`bcv'0s = J(1,`cols',0)
							matrix var`bcv'final=var`bcv'0s
						}
						else {
							matrix var`bcv'`t0' = var`bcv'[1..`t0',1...]							
							local cols=colsof(var`bcv'`t0')
							matrix var`bcv'0s = J(1,`cols',0)
							matrix var`bcv'final=(var`bcv'`t0'\var`bcv'0s)
						}
					}
					else if `i' < `positionsize' {
						local tminus1: word `j' of `positionlist'
							*If there are multiple sequential numbers in the position list
							*then we must add the same number of zero columns in a row
							if `t' == `tminus1'+1 {
							    local cols=colsof(var`bcv'final)
								matrix var`bcv'0s = J(1,`cols',0)
								matrix var`bcv'final=(var`bcv'final\var`bcv'0s)
							}
							else {
								local j2=`j'-1
								
								local t0minus1 = `tminus1' - `j2'
								
								matrix var`bcv'`t0' = var`bcv'[`t0minus1'..`t0',1...]
								local cols=colsof(var`bcv'`t0')
								matrix var`bcv'0s = J(1,`cols',0)
								matrix var`bcv'final=(var`bcv'final\var`bcv'`t0'\var`bcv'0s)
							}
					}
					else if `i' == `positionsize' {
						local tminus1: word `j' of `positionlist'
						local j2=`j'-1
						
						local t0minus1 = `tminus1' - `j2'
						
						matrix var`bcv'`t0' = var`bcv'[`t0minus1'..`t0',1...]
						local cols=colsof(var`bcv'`t0')
						matrix var`bcv'0s = J(1,`cols',0)
						matrix var`bcv'final=(var`bcv'final\var`bcv'`t0')
					}
					
					local ++i
				}
				
				/* ADDING ZEROS BACK TO COLUMNS IN VARIANCE MATRIX */
				local i=1
				foreach wrd in `positionlist' {
					local j=`i'-1
					local t: word `i' of `positionlist'
					local t0 = `t' - `i'
					
					if `i' == 1 {
						if `t0' == 0 {
							local rows=rowsof(var`bcv'final)
							matrix var`bcv'0s = J(`rows',1,0)
							matrix var`bcv'final2=var`bcv'0s
						}
						else {
							matrix var`bcv'`t0' = var`bcv'final[1...,1..`t0']
							
							local rows=rowsof(var`bcv'`t0')
							matrix var`bcv'0s = J(`rows',1,0)
							matrix var`bcv'final2=(var`bcv'`t0',var`bcv'0s)
						}
					}
					else if `i' < `positionsize' {
						local tminus1: word `j' of `positionlist'
							if `t' == `tminus1'+1 {
							    local rows=rowsof(var`bcv'final)
								matrix var`bcv'0s = J(`rows',1,0)
								matrix var`bcv'final2=(var`bcv'final2,var`bcv'0s)
							}
							else {
								local j2=`j'-1
								
								local t0minus1 = `tminus1' - `j2'
								
								matrix var`bcv'`t0' = var`bcv'final[1...,`t0minus1'..`t0']
								local rows=rowsof(var`bcv'`t0')
								matrix var`bcv'0s = J(`rows',1,0)
								matrix var`bcv'final2=(var`bcv'final2,var`bcv'`t0',var`bcv'0s)
							}
					}
					else if `i' == `positionsize' {
						local tminus1: word `j' of `positionlist'
						local j2=`j'-1
						
						local t0minus1 = `tminus1' - `j2'
						
						matrix var`bcv'`t0' = var`bcv'final[1...,`t0minus1'..`t0']
						local rows=rowsof(var`bcv'`t0')
						matrix var`bcv'0s = J(`rows',1,0)
						matrix var`bcv'final2=(var`bcv'final2,var`bcv'`t0')
					}
					
					local ++i
				}
			}
			matrix bb=e(b)
			/* \\\\\\ UPDATE STANDARD ERRORS WITH BIAS CORRECTION \\\\\\ */
			ereturn repost b=bb V = var`bcv'final2, resize
			
			/* \\\\\\\ OUTPUT P-VALUES USING T-STATISTIC \\\\\\\\\\\\\\\\\\\\\\\\\ */
			if "`statistic'" == "t" {
				matrix b=e(b)
				matrix V=e(V)
				ereturn post b V, dof(`dof') esample(`touse')
				ereturn matrix varNaive = varNaive
				if "`bcv'" != "rb" ereturn matrix varrb = varrb
				if "`bcv'" != "df" ereturn matrix vardf = vardf
				if "`bcv'" != "kc" ereturn matrix varkc = varkc
				if "`bcv'" != "md" ereturn matrix varmd = varmd
				if "`bcv'" != "fg" ereturn matrix varfg = varfg
				if "`bcv'" != "mbn" ereturn matrix varmbn = varmbn
				if "`bcv'" != "rb" {
					di as text " "
					di as text "`name' bias-corrected standard errors"
					di as text "t-statistic with K - p degrees of freedom"
					if `dof' <= 0 {
						di as error "Warning: Degrees of freedom for t distribution ≤ 0"
					}
				}
				else {
					di as text " "
					di as text "Robust standard errors not multiplied by √K/(K-1)"
					di as text "t-statistic with K - p degrees of freedom"
					if `dof' <= 0 {
						di as error "Warning: Degrees of freedom for t distribution ≤ 0"
					}
				}
				_coef_table, `eform' level(`level')
			}
			/* \\\\\\\ OUTPUT P-VALUES USING Z-STATISTIC \\\\\\\\\\\\\\\\\\\\\\\\\ */
			else if "`statistic'"=="z" {
				matrix b=e(b)
				matrix V=e(V)
				ereturn post b V, esample(`touse')
				ereturn matrix varNaive = varNaive
				if "`bcv'" != "rb" ereturn matrix varrb = varrb
				if "`bcv'" != "df" ereturn matrix vardf = vardf
				if "`bcv'" != "kc" ereturn matrix varkc = varkc
				if "`bcv'" != "md" ereturn matrix varmd = varmd
				if "`bcv'" != "fg" ereturn matrix varfg = varfg
				if "`bcv'" != "mbn" ereturn matrix varmbn = varmbn
				if "`bcv'" != "rb" {
					di as text " "
					di as text "`name' bias-corrected standard errors"
				}
				else {
					di as text " "
					di as text "Robust standard errors not multiplied by √K/(K-1)"
				}	
				_coef_table, `eform' level(`level')
			}
		}
	}
	
	if "`stderr'" != "rb" & "`stderr'" != "df" & "`stderr'" != "kc" & "`stderr'" != "md" & "`stderr'" != "fg" & "`stderr'" != "mbn" {
		di as err "Invalid standard error specification.  See help manual for options."
		exit 198
	}
	
end


/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||| MATA PROGRAM ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */

mata:
matrix gee(string scalar newvarlist, string scalar beginend, string scalar cluster, string scalar Beta, string scalar Beta2, scalar wcorr, scalar phi, string scalar famlink) {
	
	// READING DATA WITHOUT MISSING VALUES INTO MATA
	X2=st_data(.,tokens(newvarlist),0)
	// SUBSETTING TO DESIGN MATRIX WITHOUT OUTCOME (WHICH IS ROW 2)
	X=X2[.,(1,3..cols(X2))]
	// SUBSETTING TO OUTCOME COLUMN VECTOR
	y=X2[.,2]
	
	// CLUSTER
	Cnum=st_matrix(cluster)
	// BEGINNING AND END POINT OF EACH CLUSTER
	bend = st_matrix(beginend)

	// BETA COEFFICIENT MATRIX
	B = st_matrix(Beta)'
	
	// NUMBER OF COLUMNS IN x
	p=cols(X)
	// NUMBER OF CLUSTERS
	K=rows(Cnum)
	

	//https://www.stata.com/statalist/archive/2012-01/msg01032.html
	a=(0)
	b=(1..p)

	U=a#b'
	Ustar=J(p,p,0)
	UUtran=J(p,p,0)

// SCORE FUNCTION START ///////////////////////////////////////////////////////////////
	for (i=1; i<=rows(Cnum); i++) {
		// X_c = cluster-specific design matrix
		X_c = X[bend[i,1]..bend[i,2],]
	
		// y_c = cluster-specific column vector of the outcome variable
		y_c = y[bend[i,1]..bend[i,2],]
		U_c=a#b'
		Ustar_c=J(p,p,0)


		// mu_c = cluster-specific marginal mean of y_c
		// D = partial derivative of mu_c with respect to Beta; corresponds to D_i in GEE
		if (famlink=="binomial logit") {
			mu_c =1:/(1 :+ exp(-1*X_c*B))
			D=X_c:*(mu_c:*(1:-mu_c))
		}
		else if (famlink == "binomial log" | famlink == "poisson log") {
			mu_c = exp(X_c*B)
			D=X_c:*mu_c
		}
		else if (famlink == "binomial identity" | famlink == "poisson identity" | famlink == "gaussian identity" | famlink == "normal identity") {
			mu_c = X_c*B
			D=X_c
		}
		
		
		// r = residuals y_c - mu_c
		r=y_c-mu_c
		
		
		M=J(Cnum[i],Cnum[i],wcorr/((1-wcorr)*(1-wcorr+Cnum[i]:*wcorr)))
		N=diag(J(1,Cnum[i],1/(1-wcorr)))
		// INVR = inverse of workin correlation matrix R
		INVR=N-M
		
		
		// INVV = inverse of the working variance matrix V
		// O corresponds to the inverse of A_c^1/2
		// phi is the scale parameter
		// LOGIC FOR A SINGLETON CLUSTER
		if (rows(X_c) == 1) {
			if (famlink=="binomial logit" | famlink == "binomial log" | famlink == "binomial identity") {
				INVV=1/(mu_c*(1-mu_c)*phi)		
			}
			else if (famlink == "poisson log" | famlink == "poisson identity") {
				INVV=1/(mu_c*phi)
			}
			else if (famlink == "gaussian identity" | famlink == "gaussian identity") {
				INVV=1/phi
			}	
		}	
		else {
			if (famlink=="binomial logit" | famlink == "binomial log" | famlink == "binomial identity") {
				O=diag(J(1,Cnum[i],1:/sqrt(mu_c:*(1:-mu_c))))
				INVV = O*INVR*O/phi			
			}
			else if (famlink == "poisson log" | famlink == "poisson identity") {
				O=diag(J(1,Cnum[i],1:/sqrt(mu_c)))
				INVV = O*INVR*O/phi
			}
			else if (famlink == "gaussian identity" | famlink == "gaussian identity") {
				INVV = INVR/phi
			}	
		}
		
		
		
		
		// U_c = corresponds to D_i'V_i^-1(y_c - mu_c) in the estimating equations
		U_c = D'*INVV*r
		
		// UUtran = DVrrVD, the "meat" of the sandwich
		UUtran_c=U_c*U_c'
		
		// Ustar_c = DVD, the "bread" of the sandwich
		Ustar_c=D'*INVV*D
		
		U=U+U_c
		UUtran=UUtran+UUtran_c
		Ustar=Ustar+Ustar_c
	}
// SCORE FUNCTION END ////////////////////////////////////////////////////////////////////////////
	//computations for naive, model-based estimator
	AHALF=cholesky(Ustar)'
	PINV=pinv(AHALF)
	AINV=PINV*PINV'
	
// NAIVE STANDARD ERROR //////////////////////
	naive=AINV
//////////////////////////////////////////////
		
// ROBUST STANDARD ERROR /////////////////////
	robust=naive*UUtran*naive'
//////////////////////////////////////////////

// df BIAS-CORRECTED STANDARD ERROR //////////
	df = (K/(K - p)):*robust
//////////////////////////////////////////////

	dbar = 1/K*U
	
// mbn BIAS-CORRECTED  STANDARD ERROR ///////
	nstar = rows(X)
	correction=(nstar-1)/(nstar-p)*(K/(K-1))*(UUtran-K*dbar*dbar')
	phi2 = rowmax((1,trace(naive*correction)/p))
	delta=rowmin((0.5,p/(K - p)))
	//Sample-size correction for mbn
	
	//correction=(nstar-1)/(nstar-p)*(K/(K-1))
	
	mbn = naive*correction*naive' + delta*phi2*naive
//////////////////////////////////////////////
	
	symeigensystem(naive,evec,eval)

	sqreval=sqrt(eval)
	sqe=evec*diag(sqreval)

	UUtran=UUbc=UUbc2=UUbc3=Ustar=J(p,p,0)
	
// CORRECTIONS FOR kc, md, AND fg BIAS-CORRECTED STANDARD ERRORS, LOOP START ///////////////////////////////
	for (i=1; i<=rows(Cnum); i++) {
		
		X_c = X[bend[i,1]..bend[i,2],]	
		y_c = y[bend[i,1]..bend[i,2],]
		U_c=a#b'
		
		if (famlink=="binomial logit") {
			mu_c =1:/(1 :+ exp(-1*X_c*B))
			//commands for beta
			D=X_c:*(mu_c:*(1:-mu_c))
		}
		else if (famlink == "binomial log" | famlink == "poisson log") {
			mu_c = exp(X_c*B)
			D=X_c:*mu_c
		}
		else if (famlink == "binomial identity" | famlink == "poisson identity" | famlink == "gaussian identity" | famlink == "normal identity") {
			mu_c = X_c*B
			D=X_c
		}
	
		r=y_c-mu_c
		M=J(Cnum[i],Cnum[i],wcorr/((1-wcorr)*(1-wcorr+Cnum[i]:*wcorr)))
		N=diag(J(1,Cnum[i],1/(1-wcorr)))
		INVR=N-M
		
		if (famlink=="binomial logit" | famlink == "binomial log" | famlink == "binomial identity") {
			O=diag(J(1,Cnum[i],1:/sqrt(mu_c:*(1:-mu_c))))
			INVV = O*INVR*O/phi
		}
		else if (famlink == "poisson log" | famlink == "poisson identity") {
			O=diag(J(1,Cnum[i],1:/sqrt(mu_c)))
			INVV = O*INVR*O/phi
		}
		else if (famlink == "gaussian identity" | famlink == "normal identity") {
			INVV = INVR/phi
		}
		
		U_i = D'*INVV*r
	
	//commands for generalized inverse - beta
	// USING WOODBURY FROM PREISSER ET AL. (2008) TO PERFORM A FAST INVERSE //////////////////////////
		ai1=INVV
		mm1=D*sqe
		ai1A=ai1*r
		
		ai1m1=ai1*mm1
	
		  //INVBIG
		 for (j=1; j<=p; j++) {
			b=ai1m1[,j]
			bt=b'
			btm=bt*mm1
			btmi=btm[,j]
			gam=1-btmi
			bg=b/gam
			ai1A=ai1A+bg*(bt*r)
			if (j<p) ai1m1=ai1m1+bg*btm
		  }
	// INVERSE END ///////////////////////////////////////////////////////////////////////////////////
		 
		  
		U_c=D'*ai1A
	  
		  
		Ustar_c=D'*INVV*D
		Ustar=Ustar+Ustar_c
		UUtran_c=U_i*U_i'
		UUtran=UUtran+UUtran_c
		  
		  
		UUbc_c=U_c*U_c'
		UUbc=UUbc+UUbc_c
		UUbc_ic=U_c*U_i'
		UUbc2=UUbc2+UUbc_ic
		 
	// BC3 CORRECTION FOR fg ////////////////////////////////////////////////////////////////////////
		diagmat=diagonal(Ustar_c*naive)
		comparemat=J(1,p,0.75)
		newmat=diagmat'\comparemat
		finalmat=colmin(newmat)
		Hi = diag(1:/sqrt(1:-finalmat))
		UUbc3=UUbc3+Hi*UUtran_c*Hi
	/////////////////////////////////////////////////////////////////////////////////////////////////
	}
// LOOP END ///////////////////////////////////////////////////////////////////////////


// kc BIAS-CORRECTED STANDARD ERRORS /////////////////////////////	
	kc=naive*(UUbc2+UUbc2')*naive':/2
//////////////////////////////////////////////////////////////////

// md BIAS-CORRECTED STANDARD ERRORS /////////////////////////////
	md=naive*UUbc*naive'
//////////////////////////////////////////////////////////////////
	
// fg BIAS-CORRECTED STANDARD ERRORS /////////////////////////////
	fg=naive*UUbc3*naive'
//////////////////////////////////////////////////////////////////

// OUTPUT VARIANCE-COVARIANCE MATRIX OF PARAMETERS BACK TO STATA //////////////////////////////	
	// reverse order since Stata puts _cons (the intercept) last
	// for generalizability, simply put the first last
	
	// reversing naive
	naive2 = naive[(2::cols(naive)),1]'
	naive3 = naive[1,1]
	naive4 = (naive2,naive3)'
	naive5 = naive[2::rows(naive),2::cols(naive)]
	varNaive=(naive5 \ naive2),naive4

	// reversing robust
	robust2 = robust[(2::cols(robust)),1]'
	robust3 = robust[1,1]
	robust4 = (robust2,robust3)'
	robust5 = robust[2::rows(robust),2::cols(robust)]
	varrb = (robust5 \ robust2),robust4
	
	// reversing df
	df2 = df[(2::cols(df)),1]'
	df3 = df[1,1]
	df4 = (df2,df3)'
	df5 = df[2::rows(df),2::cols(df)]
	vardf = (df5 \ df2),df4
	
	// reversing kc
	kc2 = kc[(2::cols(kc)),1]'
	kc3 = kc[1,1]
	kc4 = (kc2,kc3)'
	kc5 = kc[2::rows(kc),2::cols(kc)]
	varkc = (kc5 \ kc2),kc4
	
	// reversing md
	md2 = md[(2::cols(md)),1]'
	md3 = md[1,1]
	md4 = (md2,md3)'
	md5 = md[2::rows(md),2::cols(md)]
	varmd = (md5 \ md2),md4
	
	// reversing fg
	fg2 = fg[(2::cols(fg)),1]'
	fg3 = fg[1,1]
	fg4 = (fg2,fg3)'
	fg5 = fg[2::rows(fg),2::cols(fg)]
	varfg = (fg5 \ fg2),fg4
	
	// reversing mbn
	mbn2 = mbn[(2::cols(mbn)),1]'
	mbn3 = mbn[1,1]
	mbn4 = (mbn2,mbn3)'
	mbn5 = mbn[2::rows(mbn),2::cols(mbn)]
	varmbn = (mbn5 \ mbn2),mbn4

	st_matrix("varNaive",varNaive)
	st_matrix("varrb",varrb)
	st_matrix("vardf",vardf)
	st_matrix("varkc",varkc)
	st_matrix("varmd",varmd)
	st_matrix("varfg",varfg)
	st_matrix("varmbn",varmbn)
////////////////////////////////////////////////////////////////////////////////

// OUTPUT T-TEST INFO BACK TO STATA /////////////////////////////////////////////////	
B2 = st_matrix(Beta2)'
ncoef=length(B2)

/* to compute degrees of freedom for the t-test */
st_matrix("ncoef",ncoef)
st_matrix("nclust",K)

////////////////////////////////////////////////////////////////////////////////
	
}

end
