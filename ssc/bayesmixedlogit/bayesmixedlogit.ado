*! bayesmixedlogit 1.0.1 2Feb2013
*! updated 5May2013 - fixed the replay command
*! updated 7July2014 - renamed "bayesmixedlogit"
*! updated 9Sept2014-17Nov2014 - added indidividual level parameters
*! updated 1Jan2015-7Jan2015 - replace "tab" function in counting choices to allow for larger data sets
*! updated 8Jan2015 - fixed problem with using fixed coefficients in estimation
*! author Matthew J. Baker
program bayesmixedlogit
	version 11.2
	if replay() {
		if (`"`e(cmd)'"' != "bayesmixedlogit") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass
	syntax varlist [if] [in], 				///
			GRoup(varname)					///
			IDentifier(varname)				///
			RAND(varlist)					///
			[DRAWs(int 1000)				///
			DRAWRandom(int 1)				///
			DRAWFixed(int 1)				///
			BURN(int 0)						///
			ARATERandom(real .234)			///
			ARATEFixed(real .234)			///
			SAMPLERFixed(string) 			///
			SAMPLERRandom(string)			///
			DAMPPARMFixed(real 1)			///
			DAMPPARMRandom(real 1)			///
			FROM(string)					///
			FROMVariance(string)			///
			SAVING(string)					///
			REPLACE							///
			APPEND							///
			THIN(int 1)						///
			JUMBLE							///
			INDsave(string)					///
			INDKeep(int 1)					///
			INDWIDE							///
			REPLACEInd						///
			APPENDInd						///
			NOISY]			

		marksample touse
		gettoken lhs fixed : varlist
        local rhs `fixed' `rand'		
	
		markout `touse' `fixed' `rand' `group' `identifier'
	
	/* Parsing the type of problem: type 0 - default (rand and fixed) 
									type 1 - rand only		*/
	
	local rands : word count `rand'
	local fixeds: word count `fixed'

	/* Parse model type - mark null models */
	tempname modtype
	if `fixeds'==0 {
		scalar `modtype'=1
	}
	else {
		scalar `modtype'=0
	}

/* Option checking for conformity, etc. */

		/* Burn-in less than draws */
		
	if (`burn'>=`draws') {
		di as error "Error: The # of burn in draws must be less than # draws"
		exit
	}	

/* This option doesn't have much of a role right now but might be useful */
					   
	if "`samplerfixed'"!="mwg" {
		local samplerfixed "global"
	}
				
	if "`samplerrandom'"!="mwg" {
		local samplerrandom "global"
	}	
						
	/* Read in the data and problem information */
	
	mata: modtype=st_numscalar("`modtype'")
	mata: noisy=st_local("noisy")
	mata: st_view(Xr=.,.,"`rand'","`touse'")
	mata: st_view(Xf=.,.,"`fixed'","`touse'")
	mata: st_view(y=.,.,"`lhs'","`touse'")
	mata: st_view(cid=.,.,"`group'","`touse'")
	mata: st_view(pid=.,.,"`identifier'","`touse'")
	mata: m=panelsetup(pid,1)		
		
	/* Arrange data as conformable if one of null models */
	
	mata: nulldatafix(Xr,Xf,modtype)
				
	/* Check for starting values, set up initial values	  */

	mata: nr=strtoreal(st_local("rands"))

	if ("`from'"!="") {
		mata: from=st_matrix("`from'")
		if (`modtype'==0) {
			mata: nf=strtoreal(st_local("fixeds"))
			mata: beta_fn=from[1,1::nf]
			mata: b =from[1,nf+1::nr+nf]
		}
		else {
			mata: b =from
			mata: beta_fn=0
		}
	}
	else {
        qui clogit `lhs' `rhs' if `touse', group(`group')
		mata: from=st_matrix("e(b)")
		tempname from
		mata: st_matrix("`from'",from)
		if (`modtype'==0)	{ 
			mata: nf=strtoreal(st_local("fixeds"))
			mata: beta_fn=from[1,1::nf]
			mata: b =from[1,nf+1::nr+nf]
		}
		else {
			mata:  b=from
			mata: beta_fn=0
		}
	}

	if ("`fromvariance'"!="") {
		mata: W=st_matrix("`fromvariance'")
	}	
	else {
		mata: W=I(cols(Xr))*cols(Xr)
		tempname W fromvariance
		mata: st_matrix("`W'",W)
		mat `fromvariance'=`W'
	}

	mata: Winv=invsym(W)
	mata: ldetW=ln(det(W))
	mata: beta_rn=b:+rnormal(rows(m),cols(b),0,1)*cholesky(W)'

	mata: S=bml_prob_init(Xr,Xf,y,pid,cid,m,b,beta_rn,Winv,W,ldetW,beta_fn,modtype,noisy)

		/* Set up an initial MCMC problem */
		/* Parsing the necessary options  */

	mata: damper=1
	mata: arater=strtoreal(st_local("araterandom"))
	mata: aratef=strtoreal(st_local("aratefixed"))
	mata: alginfor="standalone",st_local("samplerrandom")
	mata: alginfof="standalone",st_local("samplerfixed")
	
	mata: drawsr=strtoreal(st_local("drawrandom"))
	mata: drawsf=strtoreal(st_local("drawfixed"))
	mata: draws=strtoreal(st_local("draws"))
	
	mata: dampparmr=strtoreal(st_local("dampparmrandom"))
	mata: dampparmf=strtoreal(st_local("dampparmfixed"))

	/* If user wants to save individual parameters... */
	if "`indsave'"!="" & `indkeep'==1 {
		mata: A=initialize_rand(S,dampparmr,arater,alginfor,&lncp(),drawsr,"overwrite")
	}
	else {
		mata: A=initialize_rand(S,dampparmr,arater,alginfor,&lncp(),drawsr,"append")
	}
	
	/* Last thing is to check if we are overwriting a file */
	
	if "`replaceind'"!="" {
		local `replaceind' "replace"
	}

	mata: B=initialize_fix( S,dampparmf,aratef,alginfof,&lnfp(),drawsf,"overwrite")

	mata: draw_AB(draws,S,A,B)

	/* Collect information on how to thin draws for presentation */
	mata: burn=strtoreal(st_local("burn"))
	mata: thin=strtoreal(st_local("thin"))
	mata: jumble=st_local("jumble")

	/* Collect acceptance rate information */

	mata: aratesr=J(rows(A),cols(amcmc_results_arate(A[1,])),.)
	mata: for (i=1;i<=rows(A);i++) aratesr[i,]=amcmc_results_arate(A[i,])
	mata: aratesf=amcmc_results_arate(B)

	tempname aratesr aratesf arates_fa arates_ra arates_rmax arates_rmin dof
	mata: st_matrix("`aratesr'",aratesr)
	mata: st_matrix("`aratesf'",aratesf)
	mata: st_numscalar("`arates_fa'",mean(aratesf'))
	mata: st_numscalar("`arates_ra'",mean(mean(aratesr)'))
	mata: st_numscalar("`arates_rmin'",min(aratesr))
	mata: st_numscalar("`arates_rmax'",max(aratesr))
	mata: bVrep_organize(eb=.,eV=.,S,burn,thin,jumble,bfvals=.,brvals=.,Wvals=.,vals=.)
	mata: st_numscalar("`dof'",rows(brvals))
	local dof=`dof'

	tempname b V
	mata: st_matrix("`b'",eb)
	mata: st_matrix("`V'",eV)

	/* Label matrices and equations and post results */

	local i=1
	local variance_labs
	foreach w in `rand' {
		forvalues j=`i'/`rands' {	
			local x : word `j' of `rand'
			if "`x'"=="`w'" {
				local variance_labs "`variance_labs' var_`w'"
			}
			else {
				local variance_labs "`variance_labs' cov_`w'`x'"
			}
		}
		local i=`i'+1
	}

	local eqs
	forvalues i=1/`fixeds' {
		local eqs "`eqs' Fixed:"
	}
	forvalues i=1/`rands' {
		local eqs "`eqs' Random:"
    }
	local vartms : word count `variance_labs'
	forvalues i=1/`vartms' {
		local eqs "`eqs' Cov_Random:"
	}

	mat colnames `b' = `fixed' `rand' `variance_labs'
	mat colnames `V' = `fixed' `rand' `variance_labs'
	mat rownames `V' = `fixed' `rand' `variance_labs'
	mat coleq    `b' = `eqs'
	mat coleq    `V' = `eqs'
	mat roweq    `V' = `eqs'
	
	/* Other model information */

	quietly tab `touse' if `touse'
	local nobs=`r(N)'

	tempvar tempcounter
	bysort `group': gen `tempcounter'=_n==_N
	quietly sum `tempcounter'
	local choices=r(sum)
	quietly drop `tempcounter'
	
	bysort `identifier': gen `tempcounter'=_n==_N
	quietly sum `tempcounter'
	local groups=r(sum)
	quietly drop `tempcounter'

	/* returned results */
	ereturn clear
	ereturn post `b' `V', esample(`touse') obs(`nobs') dof(`dof')

	ereturn local title "Bayesian Mixed Logit Model"
	ereturn local cmd "bayesmixedlogit"
	ereturn local indepvars `rhs'
	ereturn local depvar `lhs'
	ereturn local group `group'
	ereturn local identifier `identifier'
	ereturn local fixed `fixed'
	ereturn local random `rand'
	ereturn local random_sampler `samplerrandom'
	ereturn local fixed_sampler `samplerfixed'
	ereturn local saving `saving'

	if ("`indsave'"!="") {
		ereturn local indsave `indsave'
		ereturn scalar inddraws=`indkeep'
	}

	ereturn local append_fixed `appendfixed'
	ereturn local append_random `appendrandom'
	ereturn local jumble `jumble'
	ereturn scalar krnd=`rands'
	ereturn scalar kfix=`fixeds'
	ereturn scalar draws=`draws'
	ereturn scalar burn=`burn'
	ereturn scalar thin=`thin'
	ereturn scalar random_draws=`drawrandom'
	ereturn scalar fixed_draws=`drawfixed'
	ereturn scalar damper_fixed=`dampparmfixed'

	ereturn scalar damper_random=`dampparmrandom'
	ereturn scalar opt_arate_fixed=`aratefixed'
	ereturn scalar opt_arate_random=`araterandom'
	ereturn scalar N_groups=`groups'
	ereturn scalar N_choices=`choices'
	if (`fixeds'!=0) {
		ereturn scalar arates_fa=`arates_fa'
	}	

	ereturn scalar arates_ra=`arates_ra'
	ereturn scalar arates_rmax=`arates_rmax'
	ereturn scalar arates_rmin=`arates_rmin'
	ereturn matrix arates_rand=`aratesr'
	ereturn matrix arates_fixed=`aratesf' 
	ereturn matrix b_init=`from'
	ereturn matrix V_init=`fromvariance'

	if "`saving'"!="" {
		preserve
		clear
		getmata (brvals*)=brvals
		getmata (Wvals*)=Wvals
		getmata (fun_val)=vals
		if `modtype'==0 {
			getmata (bfvals*)=bfvals
			forvalues i=1/`fixeds' {
				local z : word `i' of `fixed'
				rename bfvals`i' `z'
			}
		}
		forvalues i=1/`rands' {
			local z : word `i' of `rand'
			rename brvals`i' `z'
		}
		local z1 : word count `variance_labs'
		forvalues i=1/`z1' {
			local z : word `i' of `variance_labs'
			rename Wvals`i' `z'
		}
		gen t=_n
		if "`append'"=="append" {
			append using "`saving'"
	}
	else {
		qui save "`saving'", `replace'
	}
	restore
	}

	/* Deal with individual-level parameters */

	if "`indsave'"!="" {
		preserve
		keep `identifier'
		tempvar last
		bysort `identifier': gen `last'=_n==_N
		quietly bysort `identifier': keep if `last'
		quietly drop `last'
		mata: indkeep=strtoreal(st_local("indkeep"))
		mata: indwide=st_local("indwide")
		clear
		mata: indparms=organize_indparms(A,indkeep,indwide)
		getmata (indparms*)=indparms

		local counter=1

		if "`indwide'"=="indwide" {
			local gv : word 1 of `group'
			gen `gv'=_n
			forvalues i=1/`indkeep' {
				forvalues j=1/`rands' {
					local z : word `j' of `rand'
					rename indparms`counter' `z'`i'
					local counter=`counter'+1	
				}
			}
		}
		else {
			local gv : word 1 of `group'
			rename indparms1 `gv'
			forvalues j=1/`rands' {
				local z : word `j' of `rand'
				rename indparms`=`j'+1' `z'
			}
		}
		if "`appendind'"=="appendind" {
			append using "`indsave'"
		}
		else {
			qui save "`indsave'", `replaceind'
		}
		restore
	}	

	di _newline
	di as txt "`e(title)'" _col(52) "Observations" _col(68) "=" as res %10.0f `e(N)'
	di as txt    		   _col(52) "Groups" _col(68) "=" as res %10.0f `e(N_groups)'
	di as txt "Acceptance rates:" 	_col(52) "Choices" _col(68) "=" as res %10.0f `e(N_choices)'
	di as txt " Fixed coefs              " "=" as res %6.3f `e(arates_fa)' _col(52) ///
		as txt "Total draws" _col(68) "=" as res %10.0f `e(draws)'
	di as txt " Random coefs(ave,min,max)" "=" as res %6.3f `e(arates_ra)' "," ///
		as res %6.3f `e(arates_rmin)' "," as res %6.3f `e(arates_rmax)'  _col(52) ///
		as txt "Burn-in draws" _col(68) "=" as res %10.0f `e(burn)'
	
	if `e(thin)'!=1		{
		di as txt			   _col(52) "*One of every " %1.0f `e(thin)' " draws kept"
	}
	
	if "`e(jumble)'"=="jumble" {
		di as txt			   _col(52) "*Draws Jumbled"
	}
	
	ereturn display
	
	if "`e(saving)'"!="" {
		di as txt "   Draws saved in " "`e(saving)'.dta"
	}
	if "`e(indsave)'"!="" {
		di as txt "   " %1.0f `e(inddraws)' " value(s) of individual-level random parameters saved in " "`e(indsave)'.dta"
	}
	
	di _newline
	di as err "   Attention!"
	di as txt "   *Results are presented to conform with Stata covention, but "
	di as txt "    are summary statistics of draws, not coefficient estimates. "  
end
program Replay
	syntax 
	ereturn display
end

/* Mata programs */

mata:
struct bml_problem_info {
	real matrix Xr,Xf,y,pid,cid,m,b,beta_rn,
				W,Winv,ldetW,beta_fn,bfvals,
				brvals,Wvals,vals
	real scalar modtype
	string scalar noisy
}
struct bml_problem_info bml_prob_init(real matrix Xr,
					 real matrix Xf,
					 real matrix y,
					 real matrix pid,
					 real matrix cid,
					 real matrix m,
					 real matrix b,
					 real matrix beta_rn,
					 real matrix Winv,
					 real matrix W,
					 real matrix ldetW,
					 real matrix beta_fn,
					 real scalar modtype,
					 string scalar noisy)	{
	struct bml_problem_info scalar S
	S.Xr=Xr
	S.Xf=Xf
	S.y=y
	S.pid=pid
	S.cid=cid
	S.m=m
	S.b=b
	S.beta_rn=beta_rn
	S.Winv=Winv
	S.W=W
	S.ldetW=ldetW
	S.beta_fn=beta_fn
	S.modtype=modtype
	S.noisy=noisy
	
	S.bfvals=J(0,cols(beta_fn),.)
	S.brvals=J(0,cols(beta_rn),.)
	S.Wvals=J(0,cols(W)*rows(W),.)
	S.vals=J(0,1,.)
	return(S)
}

/* Data arrangement programs */

void nulldatafix(transmorphic Xr,
				 transmorphic Xf,
				 real scalar modtype)
{
	if (modtype==0) return
	else if (modtype==1) Xf=J(rows(Xr),1,0)
}

/* Adaptive MCMC structure for the random components */

struct amcmc_struct matrix initialize_rand(struct bml_problem_info S,
											damper,
											arate,
											alginfo,
											lncp,
											draws,
											append)
{
	struct amcmc_struct scalar Ap
	struct amcmc_struct matrix A
	real scalar i
	real matrix W
	pointer matrix Args
	
	Ap=amcmc_init()
	amcmc_damper(Ap,damper)
	amcmc_arate(Ap,arate)
	amcmc_alginfo(Ap,alginfo)
	amcmc_lnf(Ap,lncp)
	amcmc_draws(Ap,draws)
	amcmc_append(Ap,append)
	amcmc_reeval(Ap,"reeval")	
	A=J(rows(S.m),1,Ap)
	Args=J(rows(A),8,NULL)
	for (i=1;i<=rows(S.m);i++) {
		Args[i,1]=&S.beta_fn
		Args[i,2]=&S.b
		Args[i,3]=&S.Winv
		Args[i,4]=&S.ldetW
		Args[i,5]=&panelsubmatrix(S.y,i,S.m)
		Args[i,6]=&panelsubmatrix(S.Xr,i,S.m)
		Args[i,7]=&panelsubmatrix(S.Xf,i,S.m)
		Args[i,8]=&panelsubmatrix(S.cid,i,S.m)
		amcmc_args(A[i],Args[i,])
		amcmc_xinit(A[i],S.b)
		amcmc_Vinit(A[i],S.W)
	}
	return(A)
}

/* Adaptive MCMC structure for fixed components */

struct amcmc_struct scalar initialize_fix(struct bml_problem_info S,
										  damper,
										  arate,
										  alginfo,
										  lnfp,
										  draws,
										  append)
{
	struct amcmc_struct B
	pointer matrix Brgs

	B=amcmc_init()
	Brgs=J(1,9,NULL)
	Brgs[1]=&S.beta_rn
	Brgs[2]=&S.b
	Brgs[3]=&S.Winv
	Brgs[4]=&S.ldetW
	Brgs[5]=&S.y
	Brgs[6]=&S.Xr
	Brgs[7]=&S.Xf
	Brgs[8]=&S.cid
	Brgs[9]=&S.m
	amcmc_args(B,Brgs)
	amcmc_xinit(B,S.beta_fn)
	amcmc_Vinit(B,I(cols(S.beta_fn))*cols(S.beta_fn))
	amcmc_damper(B,damper)
	amcmc_arate(B,arate)
	amcmc_alginfo(B,alginfo)
	amcmc_lnf(B,lnfp)
	amcmc_draws(B,draws)
	amcmc_append(B,append)
	amcmc_reeval(B,"reeval")
	return(B)
}

/* Drawing functions */
										  
real matrix drawb_betaW(real matrix beta,
						real matrix W) 
	return(mean(beta)+rnormal(1,cols(beta),0,1)*cholesky(W)')
real matrix drawW_bbeta(real matrix beta,
						real matrix b) 
{
	real matrix v,S1,S,L,R
    v=rnormal(cols(b)+rows(beta),cols(b),0,1)
	S1=variance(beta:-b)
	S=invsym((cols(b)*I(cols(b))+rows(beta)*S1)/(cols(b)+rows(beta)))
	L=cholesky(S)
	R=(L*v')*(L*v')'/(cols(b)+rows(beta))
	return(invsym(R))
}
real scalar lncp(real rowvector beta_rn,
					real rowvector beta_fn,
					real rowvector b,
					real matrix Winv,
					real matrix ldetW,
					real matrix y,
					real matrix Xr,
					real matrix Xf,
					real matrix cid)
{
	real scalar i,lnp,lnprior
	real matrix z,Xrp,Xfp,yp,mus
	z=panelsetup(cid,1)
	lnp=0
		
	for (i=1;i<=rows(z);i++) {
		Xrp=panelsubmatrix(Xr,i,z)
		Xfp=panelsubmatrix(Xf,i,z)
		yp =panelsubmatrix(y,i,z)
		mus=rowsum(Xrp:*beta_rn)+rowsum(Xfp:*beta_fn)
		lnp=lnp+colsum(yp:*mus):-ln(colsum(exp(mus)))
	}
	lnprior=-1/2*(beta_rn-b)*Winv*(beta_rn-b)'-
	        1/2*ldetW-cols(b)/2*ln(2*pi())
	return(lnp+lnprior)
}	
real scalar lnfp(real rowvector beta_fn,
					real matrix beta_rn,
					real rowvector b,
					real matrix Winv,
					real matrix ldetW,
					real matrix y,
					real matrix Xr,
					real matrix Xf,
					real matrix cid,
					real matrix m)
{
	real scalar i,val
	real matrix yp,Xrp,Xfp,cidp
	val=0

	for (i=1;i<=rows(m);i++) {
		yp =panelsubmatrix(y,i,m)
		Xrp=panelsubmatrix(Xr,i,m)
		Xfp=panelsubmatrix(Xf,i,m)
		cidp=panelsubmatrix(cid,i,m)
		val=val+lncp(beta_rn[i,],beta_fn,b,
		Winv,ldetW,yp,Xrp,Xfp,cidp)
							}
	return(val)
}
void draw_AB(real scalar its,
			struct bml_problem_info scalar S,
				struct amcmc_struct matrix A,
				struct amcmc_struct scalar B)
{
	real scalar i,j,k,repval
	
	for (i=1;i<=its;i++) {
		S.b    =drawb_betaW(S.beta_rn,S.W/rows(A))
		S.W    =drawW_bbeta(S.beta_rn,S.b        )
		S.Winv =invsym(S.W)
		S.ldetW=ln(det(S.W))
	
		for (j=1;j<=rows(A);j++) {
			amcmc_draw(A[j])
			S.beta_rn[j,]=amcmc_results_lastdraw(A[j])
		}

	if (S.modtype!=1) {
		amcmc_draw(B)
		repval=amcmc_results_vals(B)[rows(amcmc_results_vals(B)),1]
	}
	else {
		repval=0
		for (k=1;k<=rows(A);k++) repval=repval+
				amcmc_results_vals(A[k])[rows(amcmc_results_vals(A[k])),1]
	}
	bml_makenoise(i,its,S.noisy,repval)

		S.beta_fn=amcmc_results_lastdraw(B)
		S.bfvals=S.bfvals\S.beta_fn
		S.brvals=S.brvals\S.b
		S.Wvals=S.Wvals\rowshape(S.W,1)
		S.vals=S.vals\repval
						}
}
void bml_makenoise(real scalar its,real scalar draws,string scalar noisy,real scalar val)
{
	if (noisy!="noisy") return
	if (round(its/50)==its/50 & noisy=="noisy" & its!=draws) {
		printf(" %f: ln_fc(p) = %g\n",its,val)
		displayflush()
												}
	else if (noisy=="noisy" & its!=draws) {
		printf(".")
		displayflush()
						     }
	else {
			printf("\n %f: ln_fc(p) = %g\n",its,val)
	     }
}
void bVrep_organize(transmorphic eb,
				    transmorphic eV,
					struct bml_problem_info S,
					real scalar burn,
					real scalar thin,
					string scalar jumble,
					transmorphic bfvals,
					transmorphic brvals,
					transmorphic Wvals,
					transmorphic vals)
{
	real matrix Whold,Compdata,keep
	real scalar i,rowcount,vars

	Whold=J(rows(S.Wvals),0,.)
	rowcount=0
	for (i=1;i<=cols(S.brvals)^2;i=i+cols(S.brvals)) {
		Whold=Whold,S.Wvals[,i+rowcount::i+cols(S.brvals)-1]
		rowcount=rowcount+1
											   }
											   

	if (S.modtype==1) Compdata=S.brvals,Whold,S.vals
	else Compdata=S.bfvals,S.brvals,Whold,S.vals

	vars=cols(Compdata)-1
	
	Compdata=Compdata[burn+1::rows(Compdata),]
	
	if (jumble=="jumble") _jumble(Compdata)

	if (thin!=1) {
		keep=J(0,1,.)
		for (i=thin;i<=rows(Compdata);i=i+thin) keep=keep \ i
		Compdata=Compdata[keep,]
		}

	eb=mean(Compdata[,1::vars])
	eV=variance(Compdata[,1::vars])
	
	if (S.modtype==1) {
		brvals=Compdata[,1::cols(S.brvals)]
		Wvals=Compdata[,cols(S.brvals)+1::vars]
					}	
	else {
		bfvals=Compdata[,1::cols(S.bfvals)]
		brvals=Compdata[,cols(S.bfvals)+1::cols(S.bfvals)+cols(S.brvals)]
		Wvals=Compdata[,cols(S.bfvals)+cols(S.brvals)+1::vars]
		}
	vals=Compdata[,vars+1]
	}
/* Function to organize individual-level random parameters */
real matrix organize_indparms(struct amcmc_struct matrix A, real scalar keepind, string scalar shape)
{
	real scalar i
	real matrix pHolder,pHolderp
	pHolder=amcmc_results_draws(A[1])
	pHolder=pHolder[rows(pHolder)-keepind+1::rows(pHolder),]	
	if (shape=="indwide") {
		pHolder=rowshape(pHolder,1)
		for (i=2;i<=rows(A);i++) {
			pHolderp=amcmc_results_draws(A[i])
			pHolderp=pHolderp[rows(pHolderp)-keepind+1::rows(pHolderp),]
			pHolder=pHolder \ rowshape(pHolderp,1)
		}
	}
	else {
		pHolder=J(rows(pHolder),1,1),pHolder
		for (i=2;i<=rows(A);i++) {
			pHolderp=amcmc_results_draws(A[i])
			pHolderp=J(keepind,1,i),pHolderp[rows(pHolderp)-keepind+1::rows(pHolderp),]
			pHolder=pHolder \ pHolderp
		}
	}
	return(pHolder)
}
end	
