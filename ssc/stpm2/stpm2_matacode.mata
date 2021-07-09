*! version 1.5.7
/* run this to create mata library (lstpm2.mlib) */

version 11.2

local SS 	string scalar
local RS	real scalar
local NM	numeric matrix

mata:
struct stpm2_main {
	real colvector t,t0,d, calct0, bhazard,xb,dxb,xb0,expxb, expxb0, nxb, ndenxb, nxb0, ndenxb0, theta
	`RS' delentry, Nobs, ScoreCols
}

void stpm2_setup(`SS' temp)
{
	struct stpm2_main scalar PS
	pointer scalar p
	rmexternal(temp)
	p = crexternal(temp)
	touse = st_local("touse")
	scale = st_local("scale")
		
	PS.delentry = strtoreal(st_local("del_entry"))
	PS.Nobs = strtoreal(st_local("nobs"))
	PS.ScoreCols = 2 :+ (PS.delentry:==1)
	
// data
	PS.t = st_data(.,"_t",touse)
	if (PS.delentry) {
		PS.t0 = st_data(.,"_t0",touse)
		PS.calct0 = (PS.t0:>0)
	}

	PS.d = st_data(.,"_d",touse)
	if (st_local("bhazard") != "") 	PS.bhazard = st_data(.,st_local("bhazard"),touse)

// equations
	PS.xb = J(PS.Nobs,1,.)
	PS.dxb = J(PS.Nobs,1,.)
	if(scale=="hazard" | scale=="odds") {
		PS.expxb = J(PS.Nobs,1,.)
		if (PS.delentry) PS.xb0 = PS.expxb0 = J(PS.Nobs,1,.)
	}
	else if(scale=="normal") { 
		PS.nxb = normal(PS.xb)
		PS.ndenxb = normalden(PS.xb)
		if (PS.delentry) PS.nxb0 = PS.ndenxb0 = J(PS.Nobs,1,.)
	}
	else if(scale=="theta") {
		if (PS.delentry) PS.theta = J(PS.Nobs,1,.)
	}
	
	//Done 	
	swap((*p), PS)
}

// hazard scale

void stpm2_ml_hazard(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->dxb = moptimize_util_xb(M,b,2)
	PS->expxb = exp((*PS).xb)
	
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
		PS->expxb0 = exp((*PS).xb0)
	}
	lnfj = (*PS).d :*(log((*PS).dxb) :+ (*PS).xb) :-(*PS).expxb
	if ((*PS).delentry) lnfj = lnfj :+ ((*PS).calct0):* (*PS).expxb0
	if (todo==0) return

	S = J((*PS).Nobs,(*PS).ScoreCols,.)
	S[,1] = (*PS).d :- (*PS).expxb
	S[,2] = (*PS).d:/(*PS).dxb
	if ((*PS).delentry) S[,3] = ((*PS).calct0):*(*PS).expxb0 
	if (todo==1) return
	
	real matrix H11, H22, H12
	H11 = moptimize_util_matsum(M,1,1,(*PS).expxb,lnfj[1])
	H12 = moptimize_util_matsum(M,1,2,0,lnfj[1])
	H22 = moptimize_util_matsum(M,2,2,(1:/((*PS).dxb:^2):*(*PS).d),lnfj[1])

	if ((*PS).delentry) {
		real matrix H13, H23, H33
		H33 = moptimize_util_matsum(M,3,3,((*PS).calct0):* (-(*PS).expxb0),lnfj[1]) 
		H13 = moptimize_util_matsum(M,1,3,0,lnfj[1])
		H23 = moptimize_util_matsum(M,2,3,0,lnfj[1])
		H = -1*(H11, H12, H13 \ H12', H22, H23 \ H13', H23', H33)
	}
	else H = -1*(H11,H12 \ H12',H22)
}


// odds scale

void stpm2_ml_odds(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->dxb = moptimize_util_xb(M,b,2)
	PS->expxb = exp((*PS).xb)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
		PS->expxb0 = exp((*PS).xb0)
	}

	lnfj = (*PS).d :*(log((*PS).dxb) :+ (*PS).xb :- log(1:+(*PS).expxb)) :-ln(1:+(*PS).expxb)
	if ((*PS).delentry) lnfj = lnfj :+ ((*PS).calct0):* ln(1:+(*PS).expxb0)
	if (todo==0) return
	S = J((*PS).Nobs,(*PS).ScoreCols,.)
	S[,1] = ((*PS).d :- (*PS).expxb):/(1:+(*PS).expxb)
	S[,2] = (*PS).d:/(*PS).dxb
	if ((*PS).delentry) S[,3] = ((*PS).calct0):* (*PS).expxb0:/(1:+(*PS).expxb0) 
	if (todo==1) return

	real matrix H11, H22, H12
	H11 = moptimize_util_matsum(M,1,1,((*PS).d:+1):*(*PS).expxb:/(1:+(*PS).expxb):^2,lnfj[1])
	H12 = moptimize_util_matsum(M,1,2,0,lnfj[1])
	H22 = moptimize_util_matsum(M,2,2,(1:/((*PS).dxb:^2):*(*PS).d),lnfj[1])

	
	if ((*PS).delentry) {
		real matrix H13, H23, H33
		H33 = moptimize_util_matsum(M,3,3,((*PS).calct0):* (-(*PS).expxb0:/(1:+(*PS).expxb0):^2),lnfj[1]) 
		H13 = moptimize_util_matsum(M,1,3,0,lnfj[1])
		H23 = moptimize_util_matsum(M,2,3,0,lnfj[1])
		H = -1*(H11, H12, H13 \ H12', H22, H23 \ H13', H23', H33)
	}
	else H = -1*(H11,H12 \ H12',H22)
}

// normal scale

void stpm2_ml_normal(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->dxb = moptimize_util_xb(M,b,2)
	PS->nxb = normal(-(*PS).xb)
	PS->ndenxb = normalden((*PS).xb)

	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
		PS->nxb0 = normal(-(*PS).xb0)
		PS->ndenxb0 = normalden((*PS).xb0)
	}
	lnfj = (*PS).d :*(log((*PS).dxb) :+ lnnormalden((*PS).xb) :- lnnormal(-(*PS).xb)) :+ lnnormal(-(*PS).xb)
	if ((*PS).delentry) lnfj = lnfj :- ((*PS).calct0):* ln((*PS).nxb0)
	if (todo==0) return

	S = J((*PS).Nobs,(*PS).ScoreCols,.)
	S[,1] = (-(*PS).d :* (*PS).xb :* (*PS).nxb :+ ((*PS).d :- 1):*(*PS).ndenxb):/(*PS).nxb
	S[,2] = (*PS).d:/(*PS).dxb
	if ((*PS).delentry) S[,3] = ((*PS).calct0):*(*PS).ndenxb0:/(*PS).nxb0 
	if (todo==1) return

	
	real matrix H11, H22, H12
	H11 = moptimize_util_matsum(M,1,1,(*PS).d :- ((*PS).d:-1):*((*PS).ndenxb:*((*PS).ndenxb :-(*PS).xb:*(*PS).nxb)):/((*PS).nxb:^2),lnfj[1])
	H12 = moptimize_util_matsum(M,1,2,0,lnfj[1])
	H22 = moptimize_util_matsum(M,2,2,((*PS).d:/((*PS).dxb:^2)),lnfj[1])

	if ((*PS).delentry) {
		real matrix H13, H23, H33
		H33 = moptimize_util_matsum(M,3,3,((*PS).calct0):*((*PS).nxb0:*(*PS).xb0:*(*PS).ndenxb0 - (*PS).ndenxb0:^2):/(*PS).nxb0:^2,lnfj[1]) 
		H13 = moptimize_util_matsum(M,1,3,0,lnfj[1])
		H23 = moptimize_util_matsum(M,2,3,0,lnfj[1])
		H = -1*(H11, H12, H13 \ H12', H22, H23 \ H13', H23', H33)
	}
	else H = -1*(H11,H12 \ H12',H22)
}
// theta scale

void stpm2_ml_theta(transmorphic scalar M,
					real rowvector b,
					real colvector lnf)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->theta = exp(moptimize_util_xb(M,b,2))
	PS->dxb = moptimize_util_xb(M,b,3)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,4)
	}
	lnf = (*PS).d :*(log((*PS).dxb) :+ (*PS).xb :-log((*PS).theta:*exp((*PS).xb) :+ 1)) :- 1:/(*PS).theta:*log((*PS).theta:*exp((*PS).xb) :+ 1)
	if ((*PS).delentry) lnf = lnf :+ ((*PS).calct0):* 1:/(*PS).theta:*log((*PS).theta:*exp((*PS).xb0) :+ 1)
}

// log link

void stpm2_ml_log(transmorphic scalar M,
					real rowvector b,
					real colvector lnf)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->dxb = moptimize_util_xb(M,b,2)
	PS->expxb = exp((*PS).xb)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
		PS->expxb0 = exp((*PS).xb0)
	}
	
	// `ht' =  exp(ln(`dxb') + `xb' - ln(1-exp(`xb')))
	// `st' = 1- exp(`xb')


	lnf = (*PS).d :*(ln((*PS).dxb) :+ (*PS).xb :- ln(1:-(*PS).expxb)) :+ log(1 :-(*PS).expxb)
	if ((*PS).delentry) lnf = lnf :- ((*PS).calct0):* log(1:-(*PS).expxb0)
}

// hazard scale (relative survival)

void stpm2_ml_hazard_rs(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->dxb = moptimize_util_xb(M,b,2)
	PS->expxb = exp((*PS).xb)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
		PS->expxb0 = exp((*PS).xb0)
	}
	
	lnfj = (*PS).d :*(log((*PS).bhazard :+ (*PS).dxb:*(*PS).expxb:/(*PS).t)) :-(*PS).expxb
	if ((*PS).delentry) lnfj = lnfj :+ ((*PS).calct0:>0):* (*PS).expxb0
	if (todo==0) return
	S = J((*PS).Nobs,(*PS).ScoreCols,.)
	S[,1] = (*PS).expxb:*((*PS).d:*(*PS).dxb :/ ((*PS).expxb:*(*PS).dxb:+(*PS).t:*(*PS).bhazard):-1)
	S[,2] = (*PS).d:*(*PS).expxb:/((*PS).expxb:*(*PS).dxb:+(*PS).t:*(*PS).bhazard)
	if ((*PS).delentry) S[,3] = ((*PS).calct0):*(*PS).expxb0 
	if (todo==1) return

	real matrix H11, H22, H12
	H11 = moptimize_util_matsum(M,1,1,-(*PS).expxb:*((*PS).d:*(*PS).dxb:*(*PS).t:*(*PS).bhazard:/
								((*PS).expxb:*(*PS).dxb:+(*PS).t:*(*PS).bhazard):^2 :- 1),lnfj[1])
	H12 = moptimize_util_matsum(M,1,2,-(*PS).d:*(*PS).expxb:*(*PS).t:*(*PS).bhazard:/
								((*PS).expxb:*(*PS).dxb:+(*PS).t:*(*PS).bhazard):^2,lnfj[1])
	H22 = moptimize_util_matsum(M,2,2,(*PS).d:*exp((*PS).xb:*2):/
								((*PS).expxb:*(*PS).dxb:+(*PS).t:*(*PS).bhazard):^2,lnfj[1])

	if ((*PS).delentry) {
		real matrix H13, H23, H33
		H33 = moptimize_util_matsum(M,3,3,((*PS).calct0):* (-(*PS).expxb0),lnfj[1]) 
		H13 = moptimize_util_matsum(M,1,3,0,lnfj[1])
		H23 = moptimize_util_matsum(M,2,3,0,lnfj[1])
		H = -1*(H11, H12, H13 \ H12', H22, H23 \ H13', H23', H33)
	}
	else H = -1*(H11,H12 \ H12',H22)
}

// odds scale (relative survival)

void stpm2_ml_odds_rs(transmorphic scalar M,
					real scalar todo,
					real rowvector b,
					real colvector lnfj,
					real matrix S,
					real matrix H)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)

	PS->dxb = moptimize_util_xb(M,b,2)
	PS->expxb = exp((*PS).xb)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
		PS->expxb0 = exp((*PS).xb0)
	}
	
	lnfj = (*PS).d :*(log((*PS).bhazard :+ ((*PS).dxb:*(*PS).expxb):/((*PS).t:*(1:+(*PS).expxb)))) :- ln(1:+(*PS).expxb)
	if ((*PS).delentry) lnfj = lnfj :+ ((*PS).calct0):* ln(1:+(*PS).expxb)
	if (todo==0) return

	S = J((*PS).Nobs,(*PS).ScoreCols,.)
	S[,1] = -((*PS).expxb:*(-(*PS).d:*(*PS).dxb:+(*PS).t:*(*PS).bhazard:+
				(*PS).expxb:*((*PS).dxb:+(*PS).t:*(*PS).bhazard))):/
				((1:+(*PS).expxb):*((*PS).t:*(*PS).bhazard :+ (*PS).expxb:*((*PS).dxb:+ (*PS).t:*(*PS).bhazard)))
	S[,2] = (*PS).d:*(*PS).expxb:/((*PS).t:*(*PS).bhazard :+ (*PS).expxb:*((*PS).dxb :+ (*PS).t:*(*PS).bhazard))
	if ((*PS).delentry) S[,3] = ((*PS).calct0):*(*PS).expxb0:/(1 :+ (*PS).expxb0)
	if (todo==1) return

	real matrix H11, H22, H12

	H11 = moptimize_util_matsum(M,1,1,
		(*PS).expxb:*(2:*(*PS).expxb:*(*PS).t:*(*PS).bhazard:*((*PS).dxb :+ (*PS).t:*(*PS).bhazard):+
			exp(2:*(*PS).xb):*((*PS).d:*(*PS).dxb:+(*PS).dxb:+
			(*PS).t:*(*PS).bhazard):*((*PS).dxb:+(*PS).t:*(*PS).bhazard):+
			(*PS).t:*(*PS).bhazard:*((*PS).t:*(*PS).bhazard:-(*PS).d:*(*PS).dxb)):/
			((1:+(*PS).expxb):^2 :* ((*PS).t:*(*PS).bhazard :+ (*PS).expxb:*(*PS).dxb:+(*PS).t:*(*PS).bhazard):^2),lnfj[1])
	H12 = moptimize_util_matsum(M,1,2,-((*PS).d:*(*PS).expxb:*(*PS).t:*(*PS).bhazard):/
					((*PS).t:*(*PS).bhazard:+(*PS).expxb:*((*PS).dxb:+(*PS).t:*(*PS).bhazard)):^2,lnfj[1])
	H22 = moptimize_util_matsum(M,2,2,(*PS).d:*exp(2:*(*PS).xb):/
								((*PS).t:*(*PS).bhazard:+(*PS).expxb:*((*PS).dxb:+(*PS).t:*(*PS).bhazard)):^2,lnfj[1])
								
	if ((*PS).delentry) {
		real matrix H13, H23, H33
		H33 = moptimize_util_matsum(M,3,3,((*PS).calct0):* (-(*PS).expxb0:/(1 :+ (*PS).expxb0):^2),lnfj[1]) 
		H13 = moptimize_util_matsum(M,1,3,0,lnfj[1])
		H23 = moptimize_util_matsum(M,2,3,0,lnfj[1])
		H = -1*(H11, H12, H13 \ H12', H22, H23 \ H13', H23', H33)
	}
	else H = -1*(H11,H12 \ H12',H22)
}

// normal scale (relative survival)

void stpm2_ml_normal_rs(transmorphic scalar M,
					real rowvector b,
					real colvector lnf)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->dxb = moptimize_util_xb(M,b,2)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,3)
	}

	lnf = (*PS).d :*(log((*PS).bhazard :+ (*PS).dxb:*normalden((*PS).xb):/((*PS).t):*normal(-(*PS).xb))) :+
			lnnormal(-(*PS).xb)
	if ((*PS).delentry) lnf = lnf :- ((*PS).calct0):* lnnormal(-(*PS).xb0)
}

// theta scale (relative survival)

void stpm2_ml_theta_rs(transmorphic scalar M,
					real rowvector b,
					real colvector lnf)
{
	pointer(struct stpm2_main scalar) scalar PS
	PS = &moptimize_util_userinfo(M,1)
	PS->xb = moptimize_util_xb(M,b,1)
	PS->theta = exp(moptimize_util_xb(M,b,2))
	PS->dxb = moptimize_util_xb(M,b,3)
	PS->expxb = exp((*PS).xb)
	if ((*PS).delentry) {
		PS->xb0 = moptimize_util_xb(M,b,4)
		PS->expxb0 = exp((*PS).xb0)
	}

	lnf = (*PS).d :*(log((*PS).bhazard :+ (*PS).dxb:*(*PS).expxb:/((*PS).t:*((*PS).theta:*(*PS).expxb:+1)))) :-
			log((*PS).theta:*(*PS).expxb:+1):/(*PS).theta

	if ((*PS).delentry) lnf = lnf :+ ((*PS).calct0):* log((*PS).theta:*(*PS).expxb0:+1):/(*PS).theta
}

void  msurvpop() 
{
-9999
printf("-9999 + 11")
-123
}

end

mata mata mlib create lstpm2, replace
mata mata mlib add lstpm2 stpm2_main() stpm2_setup() stpm2_ml_hazard() stpm2_ml_odds() stpm2_ml_normal() stpm2_ml_theta() stpm2_ml_log()
mata mata mlib add lstpm2 stpm2_ml_hazard_rs() stpm2_ml_odds_rs() stpm2_ml_normal_rs() stpm2_ml_theta_rs()
