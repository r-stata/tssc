*! xtss 1.0.1 28sep2019
*! author david vincent
*! email davidwvincent@hotmail.com


program define xtss
	version 13.1
	if replay() {
	
		if (`"`e(cmd)'"' != "xtss"){
			error 301
		}		 		
		displayEstimates `0'
	}
	else{
		_xtss_estimate `0'
	}
end


program define _xtss_estimate, eclass
{
	version 13.1
	
	#delimit ;
	syntax varlist(ts fv numeric) [if] [in] 
		   [, thold(varlist ts fv numeric) 
		   initvals(numlist) noCONStant 
		   re diff INTpoints(int 12) Level(cilevel) *];
	#delimit cr

	marksample touse
	markout `touse' `thold'

	gettoken yvar xvars: varlist
	_fv_check_depvar `yvar'
	
	if "`re'"!="" & "`constant'"!=""{
		di as error "must include a constant in random effects model"
		exit 198
	}
	
	if "`xvars'"=="" & "`constant'"!=""{
		di as error "model contains no variables and no constant"
		exit 198
	}
	
	*display options
	_get_diopts diopts, `options'
	
	*check data is xtset
	qui xtset
	local ivar=r(panelvar)
	local tvar=r(timevar)
	
	*initial coefficients
	qui: _getInitvals `0' 
	
	tempname bx1 bx2 omit1 omit2
	matrix `bx1'=r(bx1)
	matrix `bx2'=r(bx2)
	
	*omitted due to collinearity
	matrix `omit1'=r(omitx1)
	matrix `omit2'=r(omitx2)

	*remove constant
	local xvars1: colnames r(bx1)
	local xvars1: subinstr local xvars1 "_cons" "",all

	*remove constant
	local xvars2: colnames r(bx2)
	local xvars2: subinstr local xvars2 "_cons" "",all

	*variance parameters
	local sigma_e=r(sigma_e)
	local sigma_c=r(sigma_c)
	local sigma_u=r(sigma_u)
	
	
	*random effect on constant
	local re=cond("`re'"=="",0,1)
 
	*include constant
	local con=cond("`constant'"!="",0,1)

	*coeffs differ in upper/lower thresholds
	local diff=cond("`diff'"=="",0,1)


	qui{
		
		*dependent variable in model
		tempvar Dprice Lprice uniq
		by `ivar': gen `Dprice'=D.`yvar' if `touse'
		by `ivar': gen `Lprice'=L.`yvar' if `touse'
 
		*update touse
		markout `touse' `Dprice' `Lprice' `xvars2'

		egen `uniq'=tag(`ivar') if `touse'
		count if `uniq'
		local ng=r(N)
		count if `touse'
		local nobs=r(N)
	}

	tempname b oim df_m logl
	
	*estimate model
	mata: estmod("`b'","`oim'","`df_m'","`logl'","`Dprice'","`Lprice'","`xvars1'","`xvars2'","`ivar'", ///
		"`touse'","`bx1'","`bx2'","`omit1'","`omit2'",`re',`con',`diff', ///
		`intpoints',`sigma_e',`sigma_c',`sigma_u') 

		
	ereturn post `b' `oim', esample(`touse') depname(`yvar') obs(`nobs') buildfvinfo

	if "`xvars1'"==""{
		local chi2=0
	}
	else{
		cap testparm `xvars1'
		local chi2=r(chi2)
	}

	*scalars returned in e() 
	ereturn scalar N_g=`ng'
	ereturn scalar k_aux = cond(!`re',2,3) 
	ereturn scalar df_m =`df_m'
	ereturn scalar ll=`logl'
	ereturn scalar chi2=`chi2'
	
	if `re'{
		ereturn scalar n_quad=`intpoints'
		
		*exponentiate variance parameter
		ereturn hidden local diparm3 lnsigma_u, exp label("sigma_u")
	}


	*macros returned in e() 
	ereturn local cmd xtss
	ereturn local cmdline `0'
	ereturn local depvar "`yvar'"
	ereturn local ivar "`ivar'"
	ereturn local tvar "`tvar'"
	
	if `re'{
		ereturn local title "ML random effects regression"
	}
	else{
		ereturn local title "ML regression"
	}
	
	ereturn local chi2type "Wald"
	ereturn local predict xtss_p
	
	*exponentiate variance parameters
	ereturn hidden local diparm1 lnsigma_c, exp label("sigma_c")
	ereturn hidden local diparm2 lnsigma_e, exp label("sigma_e")
	
	*display regression estimates
	displayEstimates, level(`level') `diopts'
	
	
}
end







program define _getInitvals, rclass
{
 
	#delimit ;
	syntax varlist(ts fv numeric) [if] [in]  
		   [, thold(varlist ts fv numeric) 
		   initvals(numlist) noCONStant re  *];
	#delimit cr

	gettoken yvar xvars: varlist
	_fv_check_depvar `yvar'
	
	
	qui xtset
	local ivar=r(panelvar)
	local tvar=r(timevar)	
		
	tempname b_init bx1 bx2 omit1 omit2
	
	*initial values set by the user
	if "`initvals'"!=""{

		local n: word count `initvals'
		
		_rmcoll `xvars', expand `constant'
		local xvars1 `r(varlist)'
		local k1=wordcount("`xvars1'")+("`constant'"=="")

		_rmcoll `thold', expand 
		local xvars2 `r(varlist)'
		local k2=wordcount("`xvars2'")+1
		
		*total parameters (diff = 1 or 0)
		local k=`k1'+`k2'+cond("`re'"!="",3,2)
		
		if `n'<`k'{
			di as err "insufficient values in {opt initval()} - must provide `k' initial values"
			exit 198
		}
		else if `n'>`k'{
			di as err "too many values in {opt initval()} - must provide `k' initial values"
			exit 198
		}
		
		local c=0
		matrix `b_init'=J(1,`n',0)
		
		foreach i of local initvals{
			matrix `b_init'[1,`++c']=`i'
		}
		
		matrix `bx1'=`b_init'[1,1..`k1']
		
		if "`constant'"==""{
			matrix colnames `bx1'=`xvars1' "_cons"
		}
		else{
			matrix colnames `bx1'=`xvars1' 
		}
		
		matrix `bx2'=`b_init'[1,`k1'+1..`k1'+`k2']
		matrix colnames `bx2'=`xvars2' "_cons"
		
		local sigma_e=`b_init'[1,`k1'+`k2'+1]
		local sigma_c=`b_init'[1,`k1'+`k2'+2]
		local sigma_u=cond("`re'"!="",`b_init'[1,`k1'+`k2'+3],.)
		
	}
	
	*initial values from OLS/RE & probit regression
	else{
		
		marksample touse
		markout `touse' `thold'

		tempvar Iu Id
		by `ivar': gen `Iu'=D.`yvar'>0 if `touse' & D.`yvar'!=.
		by `ivar': gen `Id'=D.`yvar'<0 if `touse' & D.`yvar'!=.
	
		*latent variable coefficients 
		if "`re'"!="" {
			tempvar d u1 u2
			xtreg `varlist' if (`Iu' | `Id') & `touse', re
			predict `d' ,xb
			predict `u1',u
			egen `u2'=mean(`u1'), by(id)
			replace `d'=`d'-L.`yvar'+`u2'
		}
		else{
			tempvar d 
			reg `varlist' if (`Iu' | `Id') & `touse', `constant'
			predict `d',xb
			replace `d'=`d'-L.`yvar'
		
		}

		matrix `bx1'=e(b)
		local sigma_e=cond("`re'"!="",e(sigma_e),e(rmse))
		local sigma_u=cond("`re'"!="",e(sigma_u),.)
		  
		*threshold coefficients [same values in lower/upper]
		tempname R
		fvexpand  `thold' if `touse'
		local k2: word count `r(varlist)'
		matrix `R'=(-I(`k2'+2),I(`k2'+2),J(`k2'+2,2,0)) 
		matrix `R'[1,1]=1
	
		biprobit `Iu' `Id' `d' `thold' if `touse', constraints(`R')
		
		local sigma_c=sqrt((1/_b[`Iu':`d'])^2-`sigma_e'^2)
		
		if missing(`sigma_c'){
			local sigma_c=`sigma_e'/2
		}
		
		if `sigma_u'==0{
			local sigma_u=`sigma_e'/2
		}
		
		matrix `bx2'=e(b)
		matrix `bx2'=-`bx2'[1,2..`k2'+2]*sqrt(`sigma_e'^2+`sigma_c'^2)
		matrix coleq `bx2'=""
		
	}

	*omitted due to collinearity
	tempname omitx1 omitx2
	_ms_omit_info  `bx1'
	matrix `omitx1'=r(omit)
	_ms_omit_info  `bx2'
	matrix `omitx2'=r(omit)

/*----------------verification------------*/
	di as txt "bx1"
	matrix list `bx1'
	di as txt "bx2"
	matrix list `bx2'
	di as txt "omitx1"
	matrix list `omitx1'
	di as txt "omitx2"
	matrix list `omitx2'
	di as txt "sigma_e: " `sigma_e'
	di as txt "sigma_c: " `sigma_c'
	di as txt "sigma_u: " `sigma_u'
/*-----------------------------------------*/

	return matrix bx1=`bx1'
	return matrix bx2=`bx2'
	return matrix omitx1=`omitx1'
	return matrix omitx2=`omitx2'
	return scalar sigma_e=`sigma_e'
	return scalar sigma_c=`sigma_c'
	return scalar sigma_u=`sigma_u'
	
	
}
end




program define displayEstimates
{
	syntax, [level(cilevel) *]

	_get_diopts diopts,`options'
	
	_coef_table_header
	di as txt "Log likelihood  = " as res %10.0g e(ll)

	_coef_table, level(`level') `diopts'
	
}	
end




 
 mata:

 struct data
 {
  
  real matrix X1,X2,V
  real colvector Dp,Lp,id,id_rows,omit,omit1,omit2
  real scalar N,NT,K,K1,K2,re,cons,diff,rank
 
 }
 

 
 
 struct data scalar setData(string scalar Dprice,
				            string scalar Lprice,
							string scalar xvars1,
							string scalar xvars2,
							string scalar id,
							string scalar touse,
							string scalar omit1,
							string scalar omit2,
							real scalar re,
							real scalar cons,
							real scalar diff,
							real scalar intpoints)
 {
 
 
 struct data scalar z
 real scalar i
 
 //variables
 st_view(z.Dp,.,Dprice,touse)
 st_view(z.Lp,.,Lprice,touse)
 st_view(z.X1,.,tokens(xvars1),touse)
 st_view(z.X2,.,tokens(xvars2),touse)
 st_view(z.id,.,id,touse)
 

 //id start & finish rows
 z.id_rows=panelsetup(z.id,1)
 
 //random effect
 z.re=re
 
 //constant in model
 z.cons=cons
 
 //coeffs differ in upper/lower 
 z.diff=diff

 //obs & panels
 z.N=rows(z.id_rows)
 z.NT=rows(z.X1)
 
 //model degrees of freedom
 z.rank=rank(z.X1)
 
 //add constant in latent var eqn
 z.X1=(z.cons ? (z.X1,J(z.NT,1,1)) : z.X1)
 z.K1=cols(z.X1)
 
 //add constant in threshold eqn
 z.X2=(z.X2,J(z.NT,1,1))
 z.K2=cols(z.X2)
  
 //first row = abscissa, second row = weights for Gauss-Hermite quadrature.
 z.V=(z.re ? _gauss_hermite_nodes(intpoints) : J(2,1,1))
 
 //omitted variables in e(b)
 z.omit1=st_matrix(omit1)
 
 //omitted variables in threshold hold eqns
 z.omit2=st_matrix(omit2)
 
 //all omitted
 z.omit=(z.omit1,z.omit2,z.omit2,(re ? J(1,3,0) : J(1,2,0)))
 
 //total parameters
 z.K=cols(z.omit)
 
 return(z)
 
}

 


 


 
 void estmod(string scalar b,
			 string scalar oim,
			 string scalar df_m,
			 string scalar logl,
			 string scalar Dprice,
		     string scalar Lprice,
		     string scalar xvars1,
			 string scalar xvars2,
		     string scalar id,
		     string scalar touse,
			 string scalar bx1,
			 string scalar bx2,
			 string scalar omit1,
			 string scalar omit2,
			 real scalar re,
			 real scalar cons,
			 real scalar diff,
			 real scalar intpoints,
			 real scalar sigma_e,
			 real scalar sigma_c,
			 real scalar sigma_u)

 {
 
 
 //declarations
 struct data scalar z
 transmorphic s1
 real colvector init,bhat
 real matrix OIM,C,xx,rx,rr
 real scalar r,c
 string colvector evars1,evars2,evars,enames
 string matrix mstripe
 

 //assign variables in data
 z=setData(Dprice,Lprice,xvars1,xvars2,id,touse,omit1,omit2,re,cons,diff,intpoints)

 //initial coefficient values 
 beta1=st_matrix(bx1)
 beta2=st_matrix(bx2)
 init=(beta1,beta2,beta2,log(sigma_c),log(sigma_e))

 //include sigma_u if random effect specified
 init=(z.re ? (init,log(sigma_u)) : init)

 //colinear and diff=0 constraints
 C=optCons(z)

 
 //set-up optimisation
 s1=optimize_init()
 optimize_init_which(s1,"max")
 optimize_init_evaluator(s1,&logl())
 optimize_init_evaluatortype(s1,"gf0")
 optimize_init_argument(s1,1,z)
 optimize_init_params(s1,init)
 optimize_init_technique(s1,"nr")
 optimize_init_singularHmethod(s1, "hybrid")
 optimize_init_constraints(s1, C)


 //estimate parameters
 bhat=optimize(s1)

 //log likelihood
 st_numscalar(logl,optimize_result_value(s1))
 
 //model degrees of freedom
 st_numscalar(df_m,z.rank)
 

 //observed information matrix = -H^-1
 OIM=optimize_result_V_oim(s1)
 
 evars1= (z.cons ? (tokens(xvars1), "_cons" ): tokens(xvars1))
 evars2=(tokens(xvars2),"_cons")
 
 if (z.diff){

 	//coeffs differ upper/lower
	evars=(evars1,J(1,2,evars2),"_cons","_cons")'
	enames=(J(1,z.K1,"Model"),J(1,z.K2,"Lower_threshold"),J(1,z.K2,"Upper_threshold"),"lnsigma_c","lnsigma_e")'
	
	if(z.re){
		evars=(evars\"_cons")
		enames=(enames\"lnsigma_u")
	} 
 
	st_matrix(b,bhat)
	st_matrix(oim,OIM)	

 }
 else{
 
	//coeffs same upper lower
	evars=(evars1,evars2,"_cons","_cons")'
 	enames=(J(1,z.K1,"Model"),J(1,z.K2,"Threshold"),"lnsigma_c","lnsigma_e")'
	
	if(z.re){
		evars=(evars\"_cons")
		enames=(enames\"lnsigma_u")
	}

	r=rows(OIM)
	c=cols(OIM)
	
	xx=OIM[1::z.K1+z.K2,1::z.K1+z.K2]
	rx=OIM[z.K1+2*z.K2+1::r,1::z.K1+z.K2]
	rr=OIM[z.K1+2*z.K2+1::r,z.K1+2*z.K2+1::c]
	OIM=(xx,rx'\rx,rr)
	
	st_matrix(oim,OIM)
	st_matrix(b,(bhat[1::z.K1+z.K2],bhat[z.K1+2*z.K2+1::c]))

}
 
 st_matrixcolstripe(b,(enames,evars))
 st_matrixcolstripe(oim,(enames,evars))
 st_matrixrowstripe(oim,(enames,evars))

}

 
 
 

 
 real matrix optCons(struct data scalar z)
 {
 
 real scalar i,j,J,K,c
 real matrix M
 c=0
 
 //number of constraints
 J=sum(z.omit)
 
 //JxK matrix of restrictions
 M=J(J,z.K,0)
 
 for(i=1;i<=z.K;i++){
	if(z.omit[i]){
		++c
		M[c,]=e(i,z.K)
	}
 }

 if(!z.diff){
 
	//same coeffs in upper/lower threshold means (if not colinear)
	M=(M\J(sum(!z.omit2),z.K,0))
	
	M[|J+1,z.K1+1\.,z.K1+2*z.K2|]=select((I(z.K2),-I(z.K2)),!z.omit2')
	
 }
 
 M=M,J(rows(M),1,0)
 
 return(M)
 
}

 
 
 
 

 
void logl(real scalar todo,
		  real rowvector theta,
		  struct data scalar z,
		  real colvector lnL,
		  real matrix g,
		  real matrix H)
 {
 
 
  real matrix Dpi,Lpi,X1i,X2i,Li
  real colvector beta,lambdad,lambdau,mud,muu,Iu,Id,Ic,di
  real colvector prDp,pu,pd,prIu0,prId0,pc
  real scalar sigma_c,sigma_e,sigma_u,sd,i,Ti
 
  //initial values of log-likelihood 
  lnL=J(z.N,1,0)
 
  //coefficients in latent var eqn
  beta=theta[1::z.K1]'
  
  //coefficients in threshold eqns
  lambdad=theta[z.K1+1::(z.K1+z.K2)]'
  lambdau=theta[z.K1+z.K2+1::(z.K1+2*z.K2)]'

  //variances
  sigma_c=exp(theta[z.K1+2*z.K2+1])
  sigma_e=exp(theta[z.K1+2*z.K2+2])
  sigma_u=(z.re ? exp(theta[z.K]) : 0)
  
 
  for(i=1;i<=z.N;i++){
	
	//panel data
	Dpi=panelsubmatrix(z.Dp,i,z.id_rows)
	Lpi=panelsubmatrix(z.Lp,i,z.id_rows)
	X1i=panelsubmatrix(z.X1,i,z.id_rows)
	X2i=panelsubmatrix(z.X2,i,z.id_rows)
	
	//mean vectors in lower & upper thresholds 
	mud=X2i*lambdad
	muu=X2i*lambdau
	
	//num of obs
	Ti=rows(Dpi)
	
	//indicator for price rise, fall and no-change
	Iu=Dpi:>0
	Id=Dpi:<0
	Ic=1:-(Iu+Id)
	
	//mean change in price [Ti x hdraws]
	di=J(1,cols(z.V),(X1i*beta-Lpi)):+sigma_u*z.V[1,]*sqrt(2)
	

	//sd & correlation
	sd=sqrt(sigma_e^2+sigma_c^2)	
 			
	//price up (rise)
	pDp=normalden((Dpi:-di):/sigma_e)*(1/sigma_e)
	pu=tnormal(Dpi,muu,sigma_c):*pDp
	
	//price down (fall)
	pd=tnormal(-Dpi,mud,sigma_c):*pDp

	//price constant (no change)
	prIu0=binormal(muu:/sigma_c,(muu:-di):/sd,sigma_c/sd):/normal(muu:/sigma_c)
	prId0=binormal(mud:/sigma_c,(-mud:-di):/sd,-sigma_c/sd):/normal(mud:/sigma_c)
	pc=(prIu0-prId0)
	
	
	//[Ti x hdraws] with ij-element f(yij\uj)
	Li=(pu:^Iu):*(pd:^Id):*(pc:^Ic)	
	
	//zero or missing 
	_editvalue(Li,0,1e-50)
		
	//multiply rows: [Ti x hdraws] -> [1 x hdraws]
	Li=exp(J(1,Ti,1)*log(Li))
			
	//integrate over ui ->log-likelihood
	lnL[i]=log(Li*z.V[2,]'*sqrt(1/pi()))
	
  }
   
 }


 
 //cdf for x~TN(0,inf,mu,sig2)
 real colvector tnormal(real colvector x,
					 real colvector mu,
					 real scalar sig)
 {
 
 real colvector p1
 real scalar p2,p3

 p1=normal((x:-mu)/sig)
 p2=normal(-mu:/sig)
 p3=normal(mu:/sig)
 

 return((p1:-p2):/p3)
 
 }
 
 
 end
 
