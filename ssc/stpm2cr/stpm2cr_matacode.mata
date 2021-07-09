*! version 2.3 11Nov2018
/*
Notes: 
PS changed to mdl: indicates the variables in the model, but we can treat mdl as 1 variable.
Changed stpm2cr_main to stpm2cr_state
*/
//clear all
version 14.1

/* Label variable types */
local structName 			string scalar
local delayedEntry			real scalar
local numObs				real scalar
local numCauses				real scalar
local causeList				real scalar
local firstDerivCols		real scalar
local deathIndicator		real matrix


mata:
mata clear
struct stpm2cr_state {															// Define the structure/box which we may need in the likelihood function
	
	real colvector 		t, t0, d
	real matrix			xb, dxb, expxb, ht, st, ft, Ft, xb0, expxb0, Ft0, prod
	`numCauses'			nCauses
	`causeList'			cList
	`delayedEntry' 		delentry
	`numObs' 			nObs
	`deathIndicator'	di, D
	`firstDerivCols'	ScoreCols	
	
}


void stpm2cr_setup(`structName' temp)											// this is the setup function to create the global struct stpm2cr_state
{
	struct stpm2cr_state scalar mdl
	pointer scalar p															// memory address
	rmexternal(temp)
	p = crexternal(temp)
	touse = st_local("touse_obs")
	scale = st_local("scale")
	
		
	mdl.delentry = strtoreal(st_local("del_entry"))
	mdl.nObs = strtoreal(st_local("nobs"))
	mdl.nCauses = strtoreal(st_local("nCauses"))
	mdl.ScoreCols = 2:*(mdl.nCauses) :+ ((mdl.delentry:==1):*(mdl.nCauses))
	mdl.cList = strtoreal(tokens(st_local("causelist")))
	
	
	// data
	mdl.d = st_data(.,"_d",touse)
	mdl.t = st_data(.,"_t",touse)
	if (mdl.delentry) mdl.t0 = st_data(.,"_t0",touse)
	
	mdl.D = st_data(.,"i._status",touse)
	//mdl.di = J(mdl.nObs,mdl.nCauses,0)
//"p1"
	//mdl.di = mdl.di + mdl.D[,2::mdl.nCauses+1]									// death indicator for each of the causes
	mdl.di = mdl.D[,2::mdl.nCauses+1]
	
	
	
//"p2"
	// equations
	mdl.xb = J(mdl.nObs,mdl.nCauses,.) 											// nObs rows, ncauses column of missing values (.)
	mdl.dxb = J(mdl.nObs,mdl.nCauses,.)
	mdl.ft = J(mdl.nObs,mdl.nCauses,.)
	
	if(scale=="hazard" | scale=="odds") {
		mdl.expxb = J(mdl.nObs,mdl.nCauses,.)
		if (mdl.delentry) {
			mdl.xb0 = mdl.expxb0 = J(mdl.nObs,mdl.nCauses,.)
			mdl.Ft0 = J(mdl.nObs,mdl.nCauses,0)
		}
	}
	if(scale=="hazard") {
		mdl.st = J(mdl.nObs,mdl.nCauses,.)
		mdl.ht = J(mdl.nObs,mdl.nCauses,.)
		mdl.Ft = J(mdl.nObs,mdl.nCauses,.)
		mdl.prod = J(mdl.nObs,mdl.nCauses,.)
	}
	if(scale=="odds") {
		mdl.Ft = J(mdl.nObs,mdl.nCauses,.)
	}
	
	//Done 	
	swap((*p), mdl)
}



/* Hazard scale */

void stpm2cr_ml_hazard(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2cr_state scalar) scalar mdl
	mdl = &moptimize_util_userinfo(M,1)

	for (j=1; j<=cols((*mdl).xb); j++) {
		mdl-> xb[,j] = moptimize_util_xb(M,b,j)
		k = j :+ (*mdl).nCauses
		mdl-> dxb[,j] = moptimize_util_xb(M,b,k)
	}
		
	if ((*mdl).delentry) {
		sumFt0 = J((*mdl).nObs,1,1)
		delent = J((*mdl).nObs,1,0)
		for (j=1; j<=cols((*mdl).xb); j++) {
			l = (((*mdl).nCauses) :* 2) :+ j
			mdl-> xb0[,j] = moptimize_util_xb(M,b,l)
			mdl-> Ft0[,j] = ((*mdl).t0:>0) :* (1 :- exp(-exp((*mdl).xb0[,j])))
			sumFt0 = sumFt0 :- (*mdl).Ft0[,j]
		}
		delent = ln(sumFt0) 
	}
	
	mdl-> expxb = exp((*mdl).xb)
	
	denSum = J((*mdl).nObs,1,0)
	sumFt = J((*mdl).nObs,1,1)
	
	for (j=1; j<=cols((*mdl).xb); j++) {

		mdl-> ht[,j] = (*mdl).dxb[,j] :* (*mdl).expxb[,j]

		mdl-> st[,j] = exp(-exp((*mdl).xb[,j]))
		
		mdl-> Ft[,j] = 1 :- exp(-exp((*mdl).xb[,j]))

		mdl-> ft[,j] = (*mdl).ht[,j] :* (*mdl).st[,j]
		
		mdl-> prod[,j] = (*mdl).expxb[,j]:*(*mdl).st[,j]
		
		sumFt = sumFt :- (*mdl).Ft[,j]

		denSum = denSum :+ ((*mdl).di[,j] :* ln((*mdl).ft[,j]))
	}
	
	
	lnfj = denSum :+ ((1 :- (*mdl).d) :* ln(sumFt))
	
	if ((*mdl).delentry) {
		lnfj = lnfj :- delent
	}
	

	
	if (todo==0) return

	S = J((*mdl).nObs,(*mdl).ScoreCols,.)
	for (j=1; j<=cols((*mdl).xb); j++) {
		S[,j] = (*mdl).di[,j]:*(1 :- (*mdl).expxb[,j]) :- (1 :- (*mdl).d):*(((*mdl).expxb[,j] :* (*mdl).st[,j])) :/ (sumFt)
		
		k = j :+ (*mdl).nCauses
		S[,k] = (*mdl).di[,j]:/(*mdl).dxb[,j]
	}
	if ((*mdl).delentry) {
		for (j=1; j<=cols((*mdl).xb); j++) {
			l = (((*mdl).nCauses) :* 2) :+ j
			S[,l] = ((*mdl).t0:>0):*((exp((*mdl).xb0[,j]):*exp(-exp((*mdl).xb0[,j]))) :/ sumFt0) 
		}
	}
	if (todo==1) return
	
	 
	for (j=1; j<=cols((*mdl).xb); j++) {
		k = j :+ (*mdl).nCauses

		H[|moptimize_util_eq_indices(M, j, j)|] = moptimize_util_matsum(M,j,j,-1:*(*mdl).di[,j]:*((*mdl).expxb[,j]) :- ( ((1 :- (*mdl).d):*(*mdl).expxb[,j]:*(*mdl).st[,j]) :/ (sumFt) ) 
													:+ ( ((1 :- (*mdl).d):*((*mdl).expxb[,j]:^2):*(*mdl).st[,j]) :/ 
													(sumFt) ) :- ( (((1 :- (*mdl).d):*((*mdl).expxb[,j]:^2):*((*mdl).st[,j]):^2)) :/ ((sumFt):^2) ),lnfj[1])		
		
		H[|moptimize_util_eq_indices(M, k, k)|] = moptimize_util_matsum(M,k,k,-1:*((*mdl).di[,j] :/ ((*mdl).dxb[,j]):^2),lnfj[1])		
		
	}
	
	if ((*mdl).delentry) {
		for (k=(*mdl).nCauses:+1; k<=2:*(*mdl).nCauses; k++) {
			for (j=1; j<=(*mdl).ScoreCols; j++) {
				if(k != j) {				
					H[|moptimize_util_eq_indices(M, k, j)|] = moptimize_util_matsum(M,k,j,0,lnfj[1])
				}
			}
		}
		for (k=(2:*(*mdl).nCauses):+1; k<=(*mdl).ScoreCols; k++) {
			for (j=1; j<=2:*(*mdl).nCauses; j++) {				
				H[|moptimize_util_eq_indices(M, k, j)|] = moptimize_util_matsum(M,k,j,0,lnfj[1])
			}
		}
		l = (*mdl).nCauses:*2
		for (k=1; k<=(*mdl).nCauses; k++) {
			
			l = l :+ 1
			H[|moptimize_util_eq_indices(M, l, l)|] = moptimize_util_matsum(M,l,l,((*mdl).t0:>0) :* ((exp((*mdl).xb0[,k]):*exp(-exp((*mdl).xb0[,k])):*
													(  sumFt0 :* (1:-exp((*mdl).xb0[,k])):+exp((*mdl).xb0[,k]):*exp(-exp((*mdl).xb0[,k])) ))  :/ (sumFt0):^2 ) ,lnfj[1])
			
		}
		for (i=(2:*(*mdl).nCauses):+1; i<=(*mdl).ScoreCols; i++) {
			c1 = i :- (*mdl).nCauses:*2
			for (j=(2:*(*mdl).nCauses):+1; j<=(*mdl).ScoreCols; j++) {
				c2 = j :- (*mdl).nCauses:*2
				if(i != j) {
					H[|moptimize_util_eq_indices(M, i, j)|] = moptimize_util_matsum(M,i,j,((*mdl).t0:>0):*((exp((*mdl).xb0[,c1]):*exp(-exp((*mdl).xb0[,c1])):*exp((*mdl).xb0[,c2]):*exp(-exp((*mdl).xb0[,c2]))):/(sumFt0):^2),lnfj[1])
				}
			}
		}
	}
	else {
		for (k=(*mdl).nCauses; k<=2:*(*mdl).nCauses; k++) {
			for (j=1; j<=2:*(*mdl).nCauses; j++) {
				if(k != j) {				
					H[|moptimize_util_eq_indices(M, k, j)|] = moptimize_util_matsum(M,k,j,0,lnfj[1])
				}
			}
		}
	}
	
	for (i=1; i<=(*mdl).nCauses; i++) {
		for (j=1; j<=(*mdl).ScoreCols; j++) {
			if((i != j) & j <= (*mdl).nCauses) {
				H[|moptimize_util_eq_indices(M, i, j)|] = moptimize_util_matsum(M,i,j,-1:*( ((1 :- (*mdl).d):*(*mdl).prod[,i]:*(*mdl).prod[,j]) :/ ((sumFt):^2) ),lnfj[1])
			}
			if((i != j) & j > (*mdl).nCauses) {
				H[|moptimize_util_eq_indices(M, i, j)|] = moptimize_util_matsum(M,i,j,0,lnfj[1])
			}
		}
	}

	

}

/* Odds scale */

void stpm2cr_ml_odds(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2cr_state scalar) scalar mdl
	mdl = &moptimize_util_userinfo(M,1)

	for (j=1; j<=cols((*mdl).xb); j++) {
		mdl-> xb[,j] = moptimize_util_xb(M,b,j)
		
		k = j + (*mdl).nCauses
		mdl-> dxb[,j] = moptimize_util_xb(M,b,k)
	}

	mdl-> expxb = exp((*mdl).xb)
	
	denSum = J((*mdl).nObs,1,0)
	sumFt = J((*mdl).nObs,1,0)
	
	for (j=1; j<=cols((*mdl).xb); j++) {
		mdl-> Ft[,j] = (*mdl).expxb[,j] :/ (1 :+ (*mdl).expxb[,j])            
		mdl-> ft[,j] = ((*mdl).dxb[,j]:*(*mdl).expxb[,j]) :/ (1 :+ (*mdl).expxb[,j]):^2
		sumFt = sumFt :+ (*mdl).Ft[,j]
		denSum = denSum :+ ((*mdl).di[,j] :* ln((*mdl).ft[,j]))
	}
	
	mFt = 1 :- (sumFt)
	//mFt = (mFt:<0.0000000001):*0.0000000001 :+ (mFt:>0.0000000001):*mFt
	
	/*
	if ((*mdl).delentry) {
		mdl->xb0 = moptimize_util_xb(M,b,3)
		mdl->expxb0 = exp((*mdl).xb0)
	}
	*/
	lnfj = denSum :+ ((1 :- (*mdl).d) :* ln(mFt))
	/*if ((*mdl).delentry) lnfj = lnfj :+ ((*mdl).t0:>0):* (*mdl).expxb0*/

	if (todo==0) return

	S = J((*mdl).nObs,(*mdl).ScoreCols,.)
	for (j=1; j<=cols((*mdl).xb); j++) {
		S[,j] = (*mdl).di[,j] :* ((1 :- (*mdl).expxb[,j]) :/ (1 :+ (*mdl).expxb[,j])) :+ (1 :- (*mdl).d) :* ( ((*mdl).Ft[,j]:^2 :- (*mdl).Ft[,j]) :/ mFt)
		k = j + (*mdl).nCauses
		S[,k] = (*mdl).di[,j]:/(*mdl).dxb[,j]
	}
	/*if ((*mdl).delentry) S[,3] = ((*mdl).t0:>0):*(*mdl).expxb0 */

	if (todo==1) return

	 
	for (j=1; j<=cols((*mdl).xb); j++) {
		k = j + (*mdl).nCauses

		H[|moptimize_util_eq_indices(M, j, j)|] = moptimize_util_matsum(M,j,j, -2:*(*mdl).di[,j]:*((*mdl).expxb[,j]:/(1 :+ (*mdl).expxb[,j]):^2) :+
			(1 :- (*mdl).d):*((-1:*(*mdl).Ft[,j] :+ 3:*((*mdl).Ft[,j]):^2 :- 2:*((*mdl).Ft[,j]):^3):/mFt) :-  
			(1 :- (*mdl).d):*((((*mdl).Ft[,j]):^2 :- (*mdl).Ft[,j]):^2:/(mFt):^2), lnfj[1])
		
		H[|moptimize_util_eq_indices(M, k, k)|] = moptimize_util_matsum(M,k,k, -1:*((*mdl).di[,j] :/ ((*mdl).dxb[,j]):^2),lnfj[1])		
		
	}
	
	
	for (j=1; j<=2:*(*mdl).nCauses; j++) {
		for (k=1; k<=2:*(*mdl).nCauses; k++) {
			if(j != k) {
				H[|moptimize_util_eq_indices(M, j, k)|] = moptimize_util_matsum(M,j,k,0,lnfj[1])
				
				H[|moptimize_util_eq_indices(M, k, j)|] = moptimize_util_matsum(M,k,j,0,lnfj[1])
			}
		}
	}

	/*if ((*mdl).delentry) {
		real matrix H13, H23, H33
		H33 = moptimize_util_matsum(M,3,3,((*mdl).t0:>0):* (-(*mdl).expxb0),lnfj[1]) 
		H13 = moptimize_util_matsum(M,1,3,0,lnfj[1])
		H23 = moptimize_util_matsum(M,2,3,0,lnfj[1])
		H = -1*(H11, H12, H13 \ H12', H22, H23 \ H13', H23', H33)
	}
	else*/ //H = -1*(H11,H12 \ H12',H22)
	//H = h

}


end

mata mata mlib create lstpm2cr, replace
mata mata mlib add lstpm2cr stpm2cr_state() stpm2cr_setup() stpm2cr_ml_hazard() stpm2cr_ml_odds()
