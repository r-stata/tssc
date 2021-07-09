capture program drop _all
program define treatoprobitsim_p, eclass
*! version 1.0.0 cagregory
version 11
	
	tempname cuts
	local cutpts = e(cuts)
	mat `cuts' = J(1,`cutpts',0)
	forv i = 1/`cutpts' {
		mat `cuts'[1,`i']=_b[cut`i':_cons]
		}
	
 
 	local nchoices=`cutpts'+1 
	 
 	local PFX
		forv i = 1/`nchoices'{
			local PFX "`PFX' P1`i' P0`i' TE`i' TT`i' SETE`i' SETT`i' "
		 	}
	
		
	local myopts PTR XBOUT `PFX' LF
	//di "`myopts'"
	_pred_se "`myopts'" `0'	
	if (`s(done)') { 
		exit 
	}
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'

	syntax [if] [in] [, `myopts' noOFFset ]
	
	marksample touse
	
	
	
	local pfx
	forv i = 1/`nchoices'{
		local pfx "`pfx'`p1`i''`p0`i''`te`i''`tt`i''`sete`i''`sett`i''"
	 	}
	local type "`ptr'`xbout'`pfx'`lf'"
	//di "`type'"
	
   local ytr : word 1 of `e(depvar)'
   local yout : word 2 of `e(depvar)'
 	
   tempvar zbp xbt psel
   qui _predict double `zbp' if `touse', xb eq(#1) 
   qui _predict double `xbt' if `touse', xb eq(#2) 
   qui g double `psel' = normal(`zbp'/(sqrt(2))) if `touse'
	
	
	tempname cutmat_tr cutmat_out lambda betatreat delta
	local facskew = e(facskew)
	local neginf = minfloat()
	local posinf = maxfloat()
	mat `cutmat_out'= `neginf',`cuts', `posinf'
	local `delta' = _b[lambda:_cons]
	local `betatreat' = _b[`yout':`ytr']
	tempname xbtzero xbtone
   qui gen double `xbtzero' = `xbt'-``betatreat''*`ytr'
   qui gen double `xbtone' = `xbtzero'+``betatreat''
	qui gen double `lambda' = `ytr'*``delta''+(1-`ytr')*(-``delta'')	
	qui count if `touse'
	scalar nobs = `r(N)'
	mata : simobs = rows(_treatoprobit_rnd)
	mata : nobs = st_numscalar("nobs")
	mata : simxN = nobs-simobs
	local facmean = e(facmean)
	local facscale = e(facscale)
	local facdensity = e(facdensity)
	local startpoint = e(startpoint)
	local nsim = e(sesim)
	mata: st_numscalar("simxtra", simxN)
	//scalar list simxtra
		
		if (scalar(simxtra))>0 {
	
	if "`facdensity'"=="normal" {
		mata: _treatoprobit_rnd_x = `facscale'* ///
								invnormal(halton(simxN*_treatoprobit_S,1,`startpoint',0))
		
		}
		if "`facdensity'"=="uniform" {
			mata: _treatoprobit_rnd_x = `facscale'*sqrt(12)* ///
									((halton(simxN*_treatoprobit_S,1,`startpoint',0)):-0.5)
		}
		if "`facdensity'"=="chi2" {
			local k = `=8/(`facskew'*`facskew')'
			local sgn = `=sign(`facskew')'
			di `sgn'
			mata: _treatoprobit_rnd_x = `facscale'/sqrt(2*`k')*`sgn'* ///
									(invchi2(`k',halton(simxN*_treatoprobit_S, 1,`startpoint',0)):-`k')
		}
		if "`facdensity'"=="gamma"{
		
			mata: _treatoprobit_rnd_x = invgammap(`facmean', halton(simxN*_treatoprobit_S,1, `startpoint',0)):-`facmean'
			
		}
		if "`facdensity'"=="logit" {
			mata: _treatoprobit_rnd_x= `facscale'*logit(halton(simxN*_treatoprobit_S,1,`startpoint',0))
		}
		
		
		if "`facdensity'"=="lognormal" {
			
			mata: _treatoprobit_rnd_x = `facscale'*exp(invnormal(halton(simxN*_treatoprobit_S,1,`startpoint',0)))
			mata: _treatoprobit_mean = mean(_treatoprobit_rnd_x)
			mata: _treatoprobit_rnd_x = _treatoprobit_rnd_x:-_treatoprobit_mean
			}
		
			
		mata: _treatoprobit_rnd_x=colshape(_treatoprobit_rnd_x,_treatoprobit_S)
		mata: _treatoprobit_rnd = _treatoprobit_rnd\_treatoprobit_rnd_x
	}
	
   if (missing("`type'") | "`type'" == "p11") {
           if missing("`type'") noisily display as text "(option p11 assumed; Pr(`ytr'=1, `yout'=1)"

			  local trtv=1
			  local outv=1 
			  tempvar vtemp
			 	qui g double `vtemp'=.
			  //sum `zbp'
           qui generate `vtyp' `varn' = . if `touse'
			  mata: mata_treatoprobitsim_predict("`vtemp'", "`zbp'", "`xbt'", "`cutmat_out'", "`lambda'", ///
			  	 	_treatoprobit_rnd, _treatoprobit_S, "`touse'", "`trtv'", "`outv'" )
           qui replace `varn'=`vtemp' if `touse'
			  label variable `varn' "Pr(`ytr'=1,`yout'=1)"
        
	}
	
	if "`type'"=="lf" {
	tempvar zbeta likefun
	qui g double `zbeta' = (2*(`ytr')-1)*`zbp'
	
	tempvar xbj xbjM1
	qui g double `xbj'=0
	qui g double `xbjM1'=0
		forvalues i = 1/`nchoices' {
		local k = `i'+1
		local cutjM1 = `cutmat_out'[1,`i']
		local cutj = `cutmat_out'[1,`k']
		tempvar m`i' xb`i'j xb`i'jM1 	
		qui g double `m`i'' = `yout'==`i' 
		qui g double `xb`i'jM1' = `m`i''*(`cutjM1'-`xbt') 
		qui g double `xb`i'j' = `m`i''*(`cutj'-`xbt') 
		qui replace `xbj'=`xbj'+`xb`i'j' 
		qui replace `xbjM1' = `xbjM1'+`xb`i'jM1' 
		
		}
		qui g double `likefun' = .
		mata: mata_treatoprobitsim_predict_lf("`likefun'", "`zbp'", "`xbj'", "`xbjM1'", "`lambda'", ///
		  	 	_treatoprobit_rnd, _treatoprobit_S, "`touse'", "`ytr'" )
		qui gen `vtyp' `varn' = `likefun' if `touse'
		label variable `varn' "Likelihood Contribution"
	}

	
		
	forv i = 2/`nchoices' {
		if "`type'"=="p1`i'" {
		  local trtv=1
		  local outv=`i' 
		  tempvar vtemp
		 	qui g double `vtemp'=.
		  //di `cut_hout'
         qui generate `vtyp' `varn' = . if `touse'
     
		  mata: mata_treatoprobitsim_predict("`vtemp'", "`zbp'", "`xbt'", "`cutmat_out'", "`lambda'", ///
		  	 	_treatoprobit_rnd, _treatoprobit_S, "`touse'", "`trtv'", "`outv'" )
         qui replace `varn'=`vtemp' if `touse'
		      label variable `varn' "Pr(`ytr'=1,`yout'=`i')"
		}
	}
	forv i = 1/`nchoices' {
		if "`type'"=="p0`i'" {
		  local trtv=0
		  local outv=`i' 
		  tempvar vtemp
		 	qui g double `vtemp'=.
		
         qui generate `vtyp' `varn' = . if `touse'
		 mata: mata_treatoprobitsim_predict("`vtemp'", "`zbp'", "`xbt'", "`cutmat_out'", "`lambda'", ///
		  	 	_treatoprobit_rnd, _treatoprobit_S, "`touse'", "`trtv'", "`outv'" )
         qui replace `varn'=`vtemp' if `touse'
		      label variable `varn' "Pr(`ytr'=0,`yout'=`i')"
		}
	}
	
	forv i=1/`nchoices' {
		if "`type'"=="te`i'" {
			local outv = `i'
			tempvar atexb
			qui g double `atexb' = . if `touse'
			mata: mata_treatoprobitsim_predict_te("`atexb'", "`zbp'", "`xbtone'", "`xbtzero'", ///
			"`cutmat_out'", _treatoprobit_rnd, _treatoprobit_S, "`touse'", "`outv'", "`lambda'" )	
			qui generate `vtype' `varn'= `atexb' if `touse'							
			label variable `varn' "Marginal Effect of `ytr' on `yout1' outcome `i'"								
		}
		
		/*if "`type'"=="sete`i'" {
				tempname W t sehat
				mat `W' = e(V)
				local `t'=`cutpts'
				local xvars `e(xvarout)' 
				local tvars `e(treatrhs)'
				local wcount: word count `tvars'
				local tcount = `wcount'+1
				local outv = `i'
				tempvar sehat
				qui g double `sehat' = . 
				mata: treatoprobitsim_predict_sete("`sehat'", "`xbtone'", "`cutmat_out'", "`xbtzero'", ///
							 	 _treatoprobit_rnd, _treatoprobit_S, "`cutpts'", "`outv'", "`W'", "`xvars'", ///
								 "`tcount'" )	
				qui generate `vtype' `varn'= `sehat' if `touse'							
				label variable `varn' "Standard Error of the Marginal Effect of `ytr' on `yout1' outcome `i'"
		}*/
		 
		if "`type'"=="sete`i'" {
				local outv = `i'
				tempname beta vcv 
				mat `beta' = e(b)
				mat `vcv' = e(V)
				local xvars `e(xvarout)'
				local xbeta
				foreach x of local xvars {
					local xbeta "`xbeta' beta_`x'"
					}
				local treatx `e(treatrhs)'
				local trtx
				foreach x of local treatx {
					local trtx "`trtx' btreat_`x'"
					}
				local trtx "`trtx' bconstant"
				local loading lambda
				local cuts
				forv i = 1/`cutpts' {
					local cuts "`cuts' betacut_`i'"
					}
				local simnames `trtx' `xbeta' `loading' `cuts' 
				preserve
				capture drop _all
				scalar betaC = colsof(`beta')
				qui drawnorm `simnames', n(`nsim') means(`beta') cov(`vcv')
				mata: simbetas = st_data(.,"`simnames'")
				restore
				tempname constant
				qui g double `constant' = 1
				local treatx "`treatx' `constant'"
				tempvar atexb
				qui g double `atexb' = . if `touse'
				mata: treatoprobitsim_predict_sete("`atexb'", _treatoprobit_rnd, _treatoprobit_S, ///
					simbetas, "`xvars'", "`treatx'", "`touse'", "`outv'", "`nsim'","`cutpts'", "`lambda'" )	
				qui generate `vtype' `varn'= `atexb' if `touse'											
				label variable `varn' "Standard Error of the Effect of `ytr' on `yout1' outcome `i'"		
		}
		
	}
	
	forv i=1/`nchoices' {
		if "`type'"=="tt`i'" {
			local outv = `i'
			tempvar zxb1
			qui g double `zxb1' = . if `touse'
			mata: mata_treatoprobitsim_predict_tt("`zxb1'", "`zbp'", "`xbtone'", "`xbtzero'", ///
			"`cutmat_out'","`lambda'", _treatoprobit_rnd, _treatoprobit_S, "`touse'", "`outv'" )	
			qui generate `vtype' `varn' = (`zxb1')/`psel' if `touse' & `ytr'==1 						
			label variable `varn' "Marginal Effect of `ytr' on `yout1' if treated"								
		}
		if "`type'"=="sett`i'" {
				local outv = `i'
				tempname beta vcv 
				mat `beta' = e(b)
				mat `vcv' = e(V)
				local xvars `e(xvarout)'
				local xbeta
				foreach x of local xvars {
					local xbeta "`xbeta' beta_`x'"
					}
				local treatx `e(treatrhs)'
				local trtx
				foreach x of local treatx {
					local trtx "`trtx' btreat_`x'"
					}
				local trtx "`trtx' bconstant"
				local loading lambda
				local cuts
				forv i = 1/`cutpts' {
					local cuts "`cuts' betacut_`i'"
					}
				local simnames `trtx' `xbeta' `loading' `cuts' 
				preserve
				capture drop _all
				scalar betaC = colsof(`beta')
				qui drawnorm `simnames', n(`nsim') means(`beta') cov(`vcv')
				mata: simbetas = st_data(.,"`simnames'")
				restore
				tempname constant
				qui g double `constant' = 1
				local treatx "`treatx' `constant'"
				tempvar atexb
				qui g double `atexb' = . if `touse'
				mata: treatoprobitsim_predict_sett("`atexb'", _treatoprobit_rnd, _treatoprobit_S, ///
					simbetas, "`xvars'", "`treatx'", "`touse'", "`outv'", "`nsim'","`cutpts'", "`lambda'" )	
				qui generate `vtype' `varn'= `atexb' if `touse'	& `ytr'==1										
				label variable `varn' "Standard Error of the Marginal Effect of `ytr' on `yout1' outcome `i' if treated"		
		}
	}
	
if "`type'" =="ptr" {
		qui generate `vtyp' `varn' = normal(`zbp') if `touse'
		label variable `varn' "Probability of selection into `ytr'"
		}
	
if "`type'" =="xbout" {
		qui generate `vtyp' `varn' = `xbt' if `touse'
			label variable `varn' "Outcome index"
	}	
	
end	
	
mata:
function mata_treatoprobitsim_predict(string scalar newv, string scalar zb, string scalar xb, string scalar cutmat, string ///
		scalar lmbd, real matrix rnd, real scalar S, string scalar touse, string scalar treat, string scalar out)	
		
		{		
		st_view(zbeta,.,zb, touse)
		st_view(xbeta,.,xb, touse)
		st_view(lam,.,lmbd, touse)
		cutpts = st_matrix(cutmat)
		c = cols(cutpts)
		trt = strtoreal(treat)
		outr = strtoreal(out)
		k = 2*trt-1
		eta = k:*zbeta
		etarnd = eta:+rnd
		cutj = cutpts[1,outr+1]
		cutjM1 = cutpts[1,outr]
		xbj = cutj:-xbeta
		xbjrnd = xbj:-lam:*rnd
		xbjM1 = cutjM1:-xbeta
		xbjM1rnd = xbjM1:-lam:*rnd
		newvar = rowsum((normal(etarnd)):*((normal(xbjrnd)):-(normal(xbjM1rnd)))):/S
		st_store(.,newv,newvar)
		}	
end
mata:
function mata_treatoprobitsim_predict_lf(string scalar newv, string scalar zb, string scalar xbj, string scalar ///
	xbjM1, string scalar lmbd, real matrix rnd, real scalar S, string scalar touse, string scalar y)	
	{
	st_view(y1,.,y)		
	st_view(zbetai,., zb)
	st_view(xbji,., xbj)
	st_view(xbjM1i,., xbjM1)
	st_view(lam,.,lmbd)
	
	sign = ((2:*y1):-1)
	zbetarnd = (sign:*zbetai):+rnd
	normzb = normal(zbetarnd)
	
	xbj = xbji:-lam:*rnd
	xbjM1 = xbjM1i:-lam:*rnd
	normxb0r = normal(xbj):-normal(xbjM1)
	treatoprobitsim = normzb:*normxb0r
	L = (rowsum(treatoprobitsim)):/S
	L=rowmax((L , J(rows(L),1,smallestdouble())))
	st_store(.,newv,L)
	}
mata:
function mata_treatoprobitsim_predict_tt(string scalar newv, string scalar zb, string scalar xb1, string scalar xb0, ///
		 string scalar cutmat, string scalar lmbd, real matrix rnd, real scalar S, string scalar touse, string scalar out)	
		{		
		st_view(zbeta,.,zb, touse)
		st_view(xbeta1,.,xb1, touse)
		st_view(xbeta0,.,xb0, touse) 
		st_view(lam,.,lmbd,touse)
		etarnd =zbeta:+rnd
		cutpts = st_matrix(cutmat)
		c = cols(cutpts1)
		outr = strtoreal(out)
		cutj = cutpts[1,outr+1]
		cutjM1 = cutpts[1,outr]
		xb1j = cutj:-xbeta1
		xb0j = cutj:-xbeta0
		xb1jrnd = xb1j:-lam:*rnd
		xb0jrnd = xb0j:-lam:*rnd
		xb1jM1 = cutjM1:-xbeta1
		xb0jM1 = cutjM1:-xbeta0
		xb1jM1rnd = xb1jM1:-lam:*rnd
		xb0jM1rnd = xb0jM1:-lam:*rnd
		newvar = rowsum((normal(etarnd)):*((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
			:-normal(xb0jM1rnd)))):/S
		st_store(.,newv,newvar)
		}	
end


mata:
function treatoprobitsim_predict_sett(string scalar newv, real matrix rnd, real scalar S, ///
					real matrix simbetas, string scalar xvar, string scalar trtx, ///
					string scalar touse, string scalar out, string scalar numsim, ///
					string scalar cuts, string scalar lam)
		{
		st_view(X,.,tokens(xvar),touse)
		st_view(tX,.,tokens(trtx),touse)
		st_view(lambda,.,lam,touse)
		n = rows(X)
		cts = strtoreal(cuts)
		outr = strtoreal(out)
		nsim = strtoreal(numsim)
		csim = cols(simbetas)
		rsim = rows(simbetas)
		tCols = cols(tX)
		xCols = cols(X)
		neginf = st_numscalar("c(minfloat)")
		posinf = st_numscalar("c(maxfloat)")
		ones = J(n,1,1)
		zeros = J(n,1,0)
		lambda_t = lambda:*ones
		/*indexes*/
		cbeg = csim-cts+1
		cend = csim
		lambdaidx = cbeg-1
		xend = lambdaidx-1
		xbeg = lambdaidx-xCols
		trend = xbeg-1
		sim_te = J(n,nsim,.)
 		for(i=1;i<=nsim;i++){
			cutpts = neginf, simbetas[i,cbeg..cend], posinf
			beta = simbetas[i,xbeg..xend]'
			cutj = cutpts[1,outr+1]
			cutjM1 = cutpts[1,outr]
			x1 = (X[.,1..xCols-1],ones)
			x0 = (X[.,1..xCols-1],zeros)
			beta_t = simbetas[i,1..trend]'
			xbeta1 = x1*beta
			xbeta0 = x0*beta
			eta = (tX*beta_t)
			psel = normal(eta:/(sqrt(2)))
			etarnd = (eta:+rnd)
			xb1j = cutj:-xbeta1
			xb0j = cutj:-xbeta0
			xb1jrnd = xb1j:-lambda_t:*rnd
			xb0jrnd = xb0j:-lambda_t:*rnd
			xb1jM1 = cutjM1:-xbeta1
			xb0jM1 = cutjM1:-xbeta0
			xb1jM1rnd = xb1jM1:-lambda_t:*rnd
			xb0jM1rnd = xb0jM1:-lambda_t:*rnd
			sim_te[.,i] = (rowsum((normal(etarnd)):*((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
			:-normal(xb0jM1rnd)))):/S):/psel
		}
		mu_sim = rowsum(sim_te):/nsim
		newvar = rowsum(sqrt((sim_te:-mu_sim):^2)):/nsim
		st_store(.,newv,newvar)
		}

end



mata:
function mata_treatoprobitsim_predict_te(string scalar newv, string scalar zb, string scalar xb1, string scalar xb0, ///
		 string scalar cutmat, real matrix rnd, real scalar S, string scalar touse, string scalar out, string scalar lambda)	
		
		{		
		st_view(zbeta,.,zb, touse)
		st_view(xbeta1,.,xb1, touse)
		st_view(xbeta0,.,xb0, touse) 
		st_view(lam,.,lambda,touse)
		cutpts = st_matrix(cutmat)
		c = cols(cutpts1)
		outr = strtoreal(out)
		cutj = cutpts[1,outr+1]
		cutjM1 = cutpts[1,outr]
		xb1j = cutj:-xbeta1
		xb0j = cutj:-xbeta0
		xb1jrnd = xb1j:-lam:*rnd
		xb0jrnd = xb0j:-lam:*rnd
		xb1jM1 = cutjM1:-xbeta1
		xb0jM1 = cutjM1:-xbeta0
		xb1jM1rnd = xb1jM1:-lam:*rnd
		xb0jM1rnd = xb0jM1:-lam:*rnd
		newvar = rowsum(((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
			:-normal(xb0jM1rnd)))):/S
		st_store(.,newv,newvar)
		}	
end


mata:
function treatoprobitsim_predict_sete(string scalar newv, real matrix rnd, real scalar S, ///
					real matrix simbetas, string scalar xvar, string scalar trtx, ///
					string scalar touse, string scalar out, string scalar numsim, ///
					string scalar cuts, string scalar lam)
		{
		st_view(X,.,tokens(xvar),touse)
		st_view(tX,.,tokens(trtx),touse)
		st_view(lambda,.,lam,touse)
		n = rows(X)
		cts = strtoreal(cuts)
		outr = strtoreal(out)
		nsim = strtoreal(numsim)
		csim = cols(simbetas)
		rsim = rows(simbetas)
		tCols = cols(tX)
		xCols = cols(X)
		neginf = st_numscalar("c(minfloat)")
		posinf = st_numscalar("c(maxfloat)")
		ones = J(n,1,1)
		zeros = J(n,1,0)
		lambda_t = lambda
		/*indexes*/
		cbeg = csim-cts+1
		cend = csim
		lambdaidx = cbeg-1
		xend = lambdaidx-1
		xbeg = lambdaidx-xCols
		trend = xbeg-1
		sim_te = J(n,nsim,.)
 		for(i=1;i<=nsim;i++){
			cutpts = neginf, simbetas[i,cbeg..cend], posinf
			beta = simbetas[i,xbeg..xend]'
			cutj = cutpts[1,outr+1]
			cutjM1 = cutpts[1,outr]
			x1 = (X[.,1..xCols-1],ones)
			x0 = (X[.,1..xCols-1],zeros)
			xbeta1 = x1*beta
			xbeta0 = x0*beta
			
			xb1j = cutj:-xbeta1
			xb0j = cutj:-xbeta0
			
			xb1jrnd = xb1j:-lambda_t:*rnd
			xb0jrnd = xb0j:-lambda_t:*rnd
			xb1jM1 = cutjM1:-xbeta1
			xb0jM1 = cutjM1:-xbeta0
			xb1jM1rnd = xb1jM1:-lambda_t:*rnd
			xb0jM1rnd = xb0jM1:-lambda_t:*rnd
			sim_te[.,i] = rowsum(((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
				:-normal(xb0jM1rnd)))):/S
			
		}
		
		mu_sim = rowsum(sim_te):/nsim
		newvar = rowsum(sqrt((sim_te:-mu_sim):^2)):/nsim
		st_store(.,newv,newvar)
		}
end



/*

mata:
function treatoprobitsim_predict_sete(string scalar newv, string scalar xb_1, string scalar cutmat, ///
		string scalar xb_0, real matrix rnd, real scalar S, string scalar cuts, string scalar out, /// 
		string scalar Mat, string scalar xvar, string scalar tvec)	
		{		
		n=st_nobs()
		
		st_view(X,.,tokens(xvar))
		st_view(xbeta1,.,xb_1)
		st_view(xbeta0,.,xb_0) 
		JMat = st_matrix(Mat)
		cutptsmat = st_matrix(cutmat)
		cutpts = strtoreal(cuts) //cols(cutpts1)
		tcols = strtoreal(tvec)
		nchoices = cutpts+1
		kx = cols(X)
		outr = strtoreal(out)
		cutj1 = cutptsmat[1,outr+1]
		cutjM11 = cutptsmat[1,outr]
		cutj0 = cutptsmat[1,outr+1]
		cutjM10 = cutptsmat[1,outr]
		xb1j = cutj1:-xbeta1
		xb0j = cutj0:-xbeta0
		xb1jrnd = xb1j:-rnd
		xb0jrnd = xb0j:-rnd
		xb1jM1 = cutjM11:-xbeta1
		xb0jM1 = cutjM10:-xbeta0
		xb1jM1rnd = xb1jM1:-rnd
		xb0jM1rnd = xb0jM1:-rnd
		newvar = J(n,1,.)
		tzero = J(n,tcols,0)
		kappa1 = J(n,cutpts, 0)
		delta1 = J(n, kx, 0)
		kappa0 = J(n, cutpts, 0)
		delta0 = J(n, kx, 0)
		rho = J(n,1,0)
		zeta = tzero, delta0, delta1, rho, kappa0, kappa1
		
		for (i=1;i<=kx;i++) {
				delta0[.,i] =  (rowsum((normalden(xb0jrnd):-normalden(xb0jM1rnd))):/S):*X[.,i] 
				delta1[.,i] = (rowsum((normalden(xb1jrnd):-normalden(xb1jM1rnd))):/S):*X[.,i]
							
				}
		delta = -1:*(delta1:-delta0)
		if (outr==1){
				kappa0[.,1] = (rowsum(normalden(xb0jrnd)):/S)
				kappa1[.,1] =  (rowsum(normalden(xb1jrnd)):/S)
				kappamat = (kappa1:-kappa0)
		}
		if (outr==nchoices){
				kappa0[.,cutpts] = -1:*(rowsum(normalden(xb0jM1rnd)):/S)
				kappa1[.,cutpts] = -1:*(rowsum(normalden(xb1jM1rnd)):/S)
				kappamat = (kappa1:-kappa0)
		}
		if (outr>1 & outr<nchoices){
				k = outr-1
				kappa0[.,outr] = -1:*((rowsum(normalden(xb0jrnd))):/S) 
				kappa1[.,outr] = (rowsum((normalden(xb1jrnd))):/S)
				kappa0[.,k] = (rowsum((normalden(xb0jM1rnd))):/S)
				kappa1[.,k] = -1:*((rowsum(normalden(xb1jM1rnd))):/S)
				kappamat = kappa1:-kappa0
				
				}
				
		jmat = tzero, delta, rho, kappamat
			
		for (i=1;i<=n;i++) {
			jacobmat = jmat[i,.]
			newvar[i] = sqrt(jacobmat*JMat*jacobmat')
		}
		st_store(.,newv,newvar)
	}	


end

*/

/*
mata:
function treatoprobitsim_predict_sete(string scalar newv, real matrix rnd, real scalar S, ///
					real matrix simbetas, string scalar xvar, string scalar trtx, ///
					string scalar touse, string scalar out, string scalar numsim, ///
					string scalar cuts, string scalar lam)
		{
		st_view(X,.,tokens(xvar),touse)
		st_view(tX,.,tokens(trtx),touse)
		st_view(lambda,.,lam,touse)
		n = rows(X)
		cts = strtoreal(cuts)
		outr = strtoreal(out)
		nsim = strtoreal(numsim)
		csim = cols(simbetas)
		rsim = rows(simbetas)
		tCols = cols(tX)
		xCols = cols(X)
		neginf = st_numscalar("c(minfloat)")
		posinf = st_numscalar("c(maxfloat)")
		ones = J(n,1,1)
		zeros = J(n,1,0)
		lambda_t = lambda
		/*indexes*//*
		cbeg = csim-cts+1
		cend = csim
		lambdaidx = cbeg-1
		xend = lambdaidx-1
		xbeg = lambdaidx-xCols
		trend = xbeg-1
		sim_te = J(n,nsim,.)
 		for(i=1;i<=nsim;i++){
			cutpts = neginf, simbetas[i,cbeg..cend], posinf
			beta = simbetas[i,xbeg..xend]'
			cutj = cutpts[1,outr+1]
			cutjM1 = cutpts[1,outr]
			x1 = (X[.,1..xCols-1],ones)
			x0 = (X[.,1..xCols-1],zeros)
			xbeta1 = x1*beta
			xbeta0 = x0*beta
			
			xb1j = cutj:-xbeta1
			xb0j = cutj:-xbeta0
			
			xb1jrnd = xb1j:-lambda_t:*rnd
			xb0jrnd = xb0j:-lambda_t:*rnd
			xb1jM1 = cutjM1:-xbeta1
			xb0jM1 = cutjM1:-xbeta0
			xb1jM1rnd = xb1jM1:-lambda_t:*rnd
			xb0jM1rnd = xb0jM1:-lambda_t:*rnd
			sim_te[.,i] = rowsum(((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
				:-normal(xb0jM1rnd)))):/S
			
		}
		
		mu_sim = rowsum(sim_te):/nsim
		newvar = rowsum(sqrt((sim_te:-mu_sim):^2)):/nsim
		st_store(.,newv,newvar)
		}
end
*/
