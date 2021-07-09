*! mixlpred 1.3.0 29Mar2016
*! author arh

program define mixlpred
	version 9.2

	syntax newvarname [if] [in], [NREP(integer 50) BURN(integer 15)]

	if ("`e(cmd)'" != "mixlogit" & "`e(cmd)'" != "mixlogitwtp") error 301

	local cmd `e(cmd)'
	
	** Mark the prediction sample **
	marksample touse, novarlist
	markout `touse' `e(indepvars)' `e(group)' `e(id)'

	** Generate variables used to sort data **
	tempvar sorder altid
	gen `sorder' = _n
	sort `touse' `e(id)' `e(group)'
	by `touse' `e(id)' `e(group)': gen `altid' = _n 
	
	** Drop data not in prediction sample **
	preserve
	qui keep if `touse'

	** Generate individual id **
	if ("`e(id)'" != "") {
		tempvar nchoice pid
		sort `e(group)'
		by `e(group)': gen `nchoice' = cond(_n==_N,1,0)
		sort `e(id)'
		by `e(id)': egen `pid' = sum(`nchoice')		
		qui duplicates report `e(id)'
		mata: mixl_np = st_numscalar("r(unique_value)")
		mata: mixl_T = st_data(., ("`pid'"))
	}
	else {
		qui duplicates report `e(group)'
		mata: mixl_np = st_numscalar("r(unique_value)")
		mata: mixl_T = J(st_nobs(),1,1)
	}

	** Generate choice occacion id **
	tempvar csid
	sort `e(group)'
	by `e(group)': egen `csid' = sum(1)
	qui duplicates report `e(group)'
	local nobs = r(unique_value)

	** Sort data **
	sort `e(id)' `e(group)' `altid'

	** Set Mata matrices to be used in prediction routine **
	local rhs `e(indepvars)'
	mata: mixl_X = st_data(., tokens(st_local("rhs")))
	mata: mixl_CSID = st_data(., ("`csid'"))
	local totobs = _N	

	** Restore data **
	restore
	
	tempname b
	matrix `b' = e(b)
	
	qui gen double `varlist' = .

	mata: mixl_pred("`b'", "`varlist'", "`touse'")

	** Restore sort order **
	sort `sorder'	
end

version 9.2
mata: 
void mixl_pred(string scalar B_s, string scalar P_s, string scalar TOUSE_s)
{
	external mixl_X
	external mixl_T
	external mixl_CSID
	external mixl_np

	np = mixl_np
	command = st_local("cmd")
	nrep = strtoreal(st_local("nrep"))
	totobs = strtoreal(st_local("totobs"))
	kfix = st_numscalar("e(kfix)")
	krnd = st_numscalar("e(krnd)")
	krln = st_numscalar("e(krln)")
	burn = strtoreal(st_local("burn"))
	corr = st_numscalar("e(corr)")
	user = st_numscalar("e(userdraws)")

	B = st_matrix(B_s)'

	kall = kfix + krnd

	if (kfix > 0) {
		MFIX = B[|1,1\kfix,1|]
		MFIX = MFIX :* J(kfix,nrep,1)	
	}

	MRND = B[|(kfix+1),1\kall,1|]

	if (corr == 1) {
		ncho = st_numscalar("e(k_aux)")
		SRND = invvech(B[|(kall+1),1\(kall+ncho),1|]) :* lowertriangle(J(krnd,krnd,1))
	}
	else {
		SRND = diag(B[|(kall+1),1\(kfix+2*krnd),1|])
	}

	if (user == 1) external mixl_USERDRAWS
	
	P = J(totobs,1,0)

	i = 1
	for (n=1; n<=np; n++) {
		
		if (user == 1) {
			ERR = invnormal(mixl_USERDRAWS[.,(1+nrep*(n-1))..(nrep*n)])
		}
		else {
			ERR = invnormal(halton(nrep,krnd,(1+burn+nrep*(n-1)))')
		}
	
		if (kfix > 0) BETA = MFIX \ (MRND :+ (SRND*ERR))
		else BETA = MRND :+ (SRND*ERR)
		if (krln > 0) {
			if ((kall-krln) > 0) { 
				BETA = BETA[|1,1\(kall-krln),nrep|]\exp(BETA[|(kall-krln+1),1\kall,nrep|])
			}
			else {
				BETA = exp(BETA)
			}
		}
		t = 1
		nc = mixl_T[i,1]
		for (t=1; t<=nc; t++) {
			XMAT = mixl_X[|i,1\(i+mixl_CSID[i,1]-1),cols(mixl_X)|]
			if (command == "mixlogitwtp") {
				B1 = BETA[1..(rows(BETA)-1),.] \ J(1,cols(BETA),1)
				B2 = J(rows(XMAT),cols(BETA),1) :* BETA[rows(BETA),.] 

				V = XMAT * B1
				V = B2 :* V

				R = exp(V) :/ colsum(exp(V),1)
			}
			else {
				EV = exp(XMAT*BETA)
				R = EV :/ colsum(EV,1)
			}
			
			P[|i,1\(i+mixl_CSID[i,1]-1),1|] = mean(R',1)'
			i = i + mixl_CSID[i,1]
		}
	}
	st_store(.,P_s,TOUSE_s,P)	
}
end	

exit

