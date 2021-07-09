*! eaapred 1.1.0 02Apr2016
*! author arh

program define eaapred
	version 12.1

	syntax newvarname [if] [in]

	if ("`e(cmd)'" != "eaalogit") error 301

	** Mark the prediction sample **
	marksample touse, novarlist
	markout `touse' `e(indepvars)' `e(group)' `e(id)' `e(zvars)'

	** Generate variables used to sort data **
	tempvar sorder altid
	gen `sorder' = _n
	sort `touse' `e(id)' `e(group)'
	by `touse' `e(id)' `e(group)': gen `altid' = _n 

	** Drop data not in prediction sample **
	preserve
	qui keep if `touse'

	** Generate dummy for last obs for each decision-maker**
	tempvar last
	sort `e(id)'
	by `e(id)': gen `last' = cond(_n==_N,1,0)

	** Generate individual id **
	tempvar nchoice pid
	sort `e(group)'
	by `e(group)': gen `nchoice' = cond(_n==_N,1,0)
	sort `e(id)'
	by `e(id)': egen `pid' = sum(`nchoice')		
	qui duplicates report `e(id)'
	mata: eaa_np = st_numscalar("r(unique_value)")
	mata: eaa_T = st_data(., ("`pid'"))

	** Generate choice occasion id **
	tempvar csid
	sort `e(group)'
	by `e(group)': egen `csid' = sum(1)
	qui duplicates report `e(group)'
	local nobs = r(unique_value)

	** Sort data **
	sort `e(id)' `e(group)' `altid'

	** Set Mata matrices to be used in prediction routine **
	local rhs `e(indepvars)'
	local zvars `e(zvars)'
	
	mata: eaa_X = st_data(., tokens(st_local("rhs")))
	if ("`e(zvars)'" != "") mata: eaa_Z = st_data(., tokens(st_local("zvars")), st_local("last"))
	mata: eaa_CSID = st_data(., ("`csid'"))
	local totobs = _N	

	** Restore data **
	restore
	
	tempname b
	matrix `b' = e(b)
	
	qui gen double `varlist' = .

	mata: eaa_pred_pr("`b'", "`varlist'", "`touse'")
	
	** Restore sort order **
	sort `sorder'	
end

version 12.1
mata: 
void eaa_pred_pr(string scalar B_s, string scalar P_s, string scalar TOUSE_s)
{

	external eaa_X
	external eaa_T
	external eaa_CSID
	external eaa_F
	external eaa_FCOLDUP

	external eaa_np

	np = eaa_np
	krhs = st_numscalar("e(krhs)")
	keaa = st_numscalar("e(keaa)")
	kzvs = st_numscalar("e(kzvs)")	
	totobs = strtoreal(st_local("totobs"))

	if (kzvs > 0) {
		external eaa_Z
		Z = eaa_Z,J(np,1,1)
	}	

	b = st_matrix(B_s)
	
	P = J(totobs,1,1)

	if (kzvs == 0) {
		A1 = invlogit(b[1,(krhs+1)..cols(b)])
		A0 = invlogit(-b[1,(krhs+1)..cols(b)])
		S = (eaa_F :* A1) :+ ((1:-eaa_F) :* A0)
		C = exp(rowsum(ln(S),1))
	}
	
	i = 1
	for (n=1; n<=np; n++) {

		if (kzvs > 0) {
			A1 = invlogit(Z[n,.]*b[1,(krhs+1)..(krhs+(kzvs+1))]')
			for (k=2; k<=keaa; k++) {
				A1 = A1, invlogit(Z[n,.]*b[1,(krhs+(kzvs+1)*(k-1)+1)..(krhs+(kzvs+1)*k)]')
			}
			A0 = invlogit(-Z[n,.]*b[1,(krhs+1)..(krhs+(kzvs+1))]')
			for (k=2; k<=keaa; k++) {
				A0 = A0, invlogit(-Z[n,.]*b[1,(krhs+(kzvs+1)*(k-1)+1)..(krhs+(kzvs+1)*k)]')
			}			
			S = (eaa_F :* A1) :+ ((1:-eaa_F) :* A0)
			C = exp(rowsum(ln(S),1))
		}
	
		R = J(rows(eaa_F),1,1)

		nc = eaa_T[i,1]
		for (t=1; t<=nc; t++) {
			
			XMAT = eaa_X[|i,1\(i+eaa_CSID[i,1]-1),cols(eaa_X)|]'
			
			FB = eaa_FCOLDUP :* b[1,1..krhs]						
			EV = exp(FB*XMAT)			
			EV = (EV :/ rowsum(EV,1)) 
			
			P[|i,1\(i+eaa_CSID[i,1]-1),1|] = colsum(C :* EV,1)'
			
			i = i + eaa_CSID[i,1]
		}
	}
	st_store(.,P_s,TOUSE_s,P)
}
end

exit

