capture program drop switchoprobitsim_p
program define switchoprobitsim_p, eclass
*! version 1.0.0 cagregory
version 11
tempname cuts1 cuts0
	local cutpts = e(cuts)
	mat `cuts0' = J(1,`cutpts',0)
	mat `cuts1' = J(1,`cutpts',0)
	forv i = 1/`cutpts' {
		mat `cuts0'[1,`i']=_b[cut_0`i':_cons]
		mat `cuts1'[1,`i']=_b[cut_1`i':_cons]
		}
	
 
 	local nchoices=`cutpts'+1 
	 
 	local PFX
		forv i = 1/`nchoices'{
			local PFX "`PFX' P1`i' P0`i' TE`i' TT`i' SETE`i' SETT`i'"
		 	}
	
		
	local myopts PTR XBOUT0 XBOUT1 LF `PFX' 
	
	
	
	_pred_se "`myopts'" `0'	
	if (`s(done)') { 
		exit 
	}
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'

	syntax [if] [in] [, `myopts' noOFFset ]

	
*mark sample
	marksample touse 
	
	
	local pfx
	forv i = 1/`nchoices'{
		local pfx "`pfx'`p1`i''`p0`i''`te`i''`tt`i''`sete`i''`sett`i''"
	 	}
	local type "`ptr'`xbout0'`xbout1'`lf'`pfx'"
	
	
	local ytr : word 1 of `e(depvar)'
  	local yout0 : word 2 of `e(depvar)'
 	local yout1 : word 3 of `e(depvar)'
	local yout: word 4 of `e(depvar)'
   tempvar zbp xb0 xb1
   qui _predict double `zbp' if `touse', xb eq(#1) 
   qui _predict double `xb0' if `touse', xb eq(#2) 
	 qui _predict double `xb1' if `touse', xb eq(#3)
   tempvar psel
   
   
	tempname cutmat_tr cutmat_out0 cutmat_out1  
	local neginf = minfloat()
	local posinf = maxfloat()
	local lambda0 = (_b[lambda0:_cons])
	local lambda1 = (_b[lambda1:_cons])
	mat `cuts0' = `cuts0'
	mat `cuts1' = `cuts1'
	mat `cutmat_tr' = `neginf',0,`posinf'
	mat `cutmat_out0'= `neginf',`cuts0', `posinf'
	mat `cutmat_out1'= `neginf',`cuts1', `posinf'
	
	local pi1 = `e(mixpi)'/100

	tempname lambda01
	qui g double `lambda01' = `ytr'*`lambda1'+(1-`ytr')*`lambda0'
	tempname unused
	qui g `unused' = 1-e(sample) //`touse'==0
	qui count if `unused'
	qui count if `touse'
	scalar nobs = `r(N)'
	mata : simobs = rows(_switchoprobit_rnd)
	mata : nobs = st_numscalar("nobs")
	mata : simxN = nobs-simobs
	local factormean = e(facmean)
	local facscale = e(facscale)
	local facdensity = e(facdensity)
	local startpoint = e(startpoint)
	local facskew = e(facskew)
	local nsim = e(sedraws) //500
	
	mata: st_numscalar("simxtra", simxN)
	tempvar pseli 
	qui g double `pseli' = normal(`zbp')
	qui replace `pseli' = . if `ytr'==0
	qui sum `pseli'
	local psel =  (r(mean))
	//di `psel'
	//scalar list simxtra
	
		
		if (scalar(simxtra))>0 {
		
		if "`facdensity'"=="normal" {
		
		mata: _switchoprobit_rnd_x = `facscale'* ///
								invnormal(halton(simxN*_switchoprobit_S,1,`startpoint',0))
		
		}
		if "`facdensity'"=="uniform" {
			mata: _switchoprobit_rnd_x = `facscale'*sqrt(12)* ///
									((halton(simxN*_switchoprobit_S,1,`startpoint',0)):-0.5)
		}
		if "`facdensity'"=="chi2" {
			local k = `=8/(`facskew'*`facskew')'
			local sgn = `=sign(`facskew')'
			mata: _switchoprobit_rnd_x = `facscale'/sqrt(2*`k')*`sgn'* ///
									(invchi2(`k',halton(simxN*_switchoprobit_S,1,`startpoint',0)):-`k')
		}
		if "`facdensity'"=="gamma" {
			mata: fmean=strtoreal(st_local("factormean"))	
			mata: _switchoprobit_rnd_x = invgammap(fmean, halton(simxN*_switchoprobit_S,1, `startpoint',0)):-fmean
			
			
		}
		if "`facdensity'"=="logit" {
			mata: _switchoprobit_rnd_x= `facscale'*logit(halton(simxN*_switchoprobit_S,1,`startpoint',0)):-`factormean'
		}
		
		if "`facdensity'"=="lognormal"{
			
			mata: _switchoprobit_rnd_x = `facscale'*exp(invnormal(halton(simxN*_switchoprobit_S,1,`startpoint',0)))
			mata: _switchoprobit_mean = mean(_switchoprobit_rnd_x)
			mata: _switchoprobit_rnd_x = _switchoprobit_rnd_x:-_switchoprobit_mean
			/*mata: _switchoprobit_rnd_x[|1,1\5,cols(_switchoprobit_rnd_x)|]*/
			}
		
		
		if "`facdensity'"=="mixture" {
			 
			tempvar p1 p2
			qui g double `p1' = runiform()<`pi1' if `unused'==1
			qui g double `p2' = 1-`p1' if `unused'==1
			qui sort `p1'
			qui count if `unused'==1
			scalar frex = `r(N)'
			local pi `p1' `p2'
			mata: st_view(p=.,(1,st_numscalar("frex")),tokens(st_local("pi")))
			mata: p1 = p[.,1]
			mata: p2 = p[.,2]
			
			mata: _switchoprobit_c1 = invnormal(halton(simxN*_switchoprobit_S,1,`startpoint',0))
			mata: _switchoprobit_c2 = `factormean':+(`facscale'*invnormal(halton(simxN*_switchoprobit_S,1,`startpoint',0)))
			mata: _switchoprobit_c1 = colshape(_switchoprobit_c1, _switchoprobit_S)
			mata: _switchoprobit_c2 = colshape(_switchoprobit_c2, _switchoprobit_S)	
			mata: _switchoprobit_rnd_x = p1:*_switchoprobit_c1:+p2:*_switchoprobit_c2
	
			}
		
		mata: _switchoprobit_rnd_x=colshape(_switchoprobit_rnd_x,_switchoprobit_S)
		/*mata: _switchoprobit_rnd_x[|1,1\5,cols(_switchoprobit_rnd_x)|]*/
		mata: _switchoprobit_rnd = _switchoprobit_rnd\_switchoprobit_rnd_x
		
		}
		
	if (missing("`type'") | "`type'" == "p11") {
           if missing("`type'") noisily display as text "(option p11 assumed; Pr(`ytr'=1, `yout'=1)"
			  local trtv=1
			  local outv=1 
			  tempvar vtemp lmb1
		 	qui g double `vtemp'=.
		 	qui g double `lmb1' = `lambda1'
		 	//di `cut_hout'
		 	qui generate `vtyp' `varn' = . if `touse'
		 	mata: mata_switchoprobitsim_predict("`vtemp'", "`zbp'", "`xb1'", "`cutmat_out1'", /*"`lambda01'"*/"`lmb1'" , ///
		  		_switchoprobit_rnd, _switchoprobit_S, "`touse'", "`trtv'", "`outv'" )
		  	qui replace `varn'=`vtemp' if `touse'
			  label variable `varn' "Pr(`ytr'=1,`yout1'=1)"
        
	}
	if "`type'"=="lf" {
		forvalues i = 1/`nchoices' {
			tempvar m0`i' m1`i' 
			qui g double `m0`i'' = `ytr'==0 & (`yout'==`i')
			qui g double `m1`i'' = `ytr'==1 & (`yout'==`i')
			}
		
		/*re indexing outcome*/	
		tempvar xbouti
		qui g double `xbouti' = 0
		qui replace `xbouti' = `xb0'*(1-`ytr')+`xb1'*(`ytr')
		tempvar xbj xbjM1
		qui g double `xbj'= 0
		qui g double `xbjM1' =0
		forv d = 0/1 {
			forv i = 1/`nchoices' {
				local k = `i'+1
				local cut_h2 = `cutmat_out`d''[1,`k']
				local cut_l2 = `cutmat_out`d''[1,`i']
			qui replace `xbj' = `xbj'+`m`d'`i''*(`cut_h2'-`xbouti')
			qui replace `xbjM1' = `xbjM1'+`m`d'`i''*(`cut_l2'-`xbouti')
			}
		}	
			
		tempvar likefunc
		qui g double `likefunc' =.  if `touse'
		mata: mata_switchoprobitsim_predict_lf("`likefunc'", "`zbp'", "`xbj'", "`xbjM1'", "`lambda01'", ///
			_switchoprobit_rnd, _switchoprobit_S, "`touse'", "`ytr'")
		qui generate `vtype' `varn' = `likefunc' if `touse'
		label variable `varn' "Likelihood Contribution"
		}

	
	forv i = 2/`nchoices' {
		if "`type'"=="p1`i'" {
		  local trtv=1
		  local outv=`i' 
		  tempvar vtemp lmb1
		  qui g double `lmb1'=1
		 	qui g double `vtemp'=.
		  //di `cut_hout'
         qui generate `vtyp' `varn' = . if `touse'
		  mata: mata_switchoprobitsim_predict("`vtemp'", "`zbp'", "`xb1'", "`cutmat_out1'", "`lambda01'", ///
		  	 	_switchoprobit_rnd, _switchoprobit_S, "`touse'", "`trtv'", "`outv'" )
         qui replace `varn'=`vtemp'
         label variable `varn' "Pr(`ytr'=1,`yout1'=`i')"
		}
	}
	forv i = 1/`nchoices' {
		if "`type'"=="p0`i'" {
		  local trtv=0
		  local outv=`i' 
		  tempvar vtemp lmb0
		  qui g double `lmb0' = `lambda0'
		 	qui g double `vtemp'=.
		  //di `cut_hout'
         qui generate `vtyp' `varn' = . if `touse'
		  mata: mata_switchoprobitsim_predict("`vtemp'", "`zbp'", "`xb0'", "`cutmat_out0'", /*"`lambda01'"*/ "`lmb0'", ///
		  	 	_switchoprobit_rnd, _switchoprobit_S, "`touse'", "`trtv'", "`outv'" )
         qui replace `varn'=`vtemp'
		      label variable `varn' "Pr(`ytr'=0,`yout1'=`i')"
		}
	}
	
	forv i=1/`nchoices' {
		if "`type'"=="te`i'" {
			
			local outv = `i'
			tempvar atexb
			qui g double `atexb' = . if `touse'
			mata: mata_switchoprobitsim_predict_te("`atexb'", "`zbp'", "`xb1'", "`cutmat_out1'", "`xb0'", "`cutmat_out0'", ///
			 		"`lambda01'", _switchoprobit_rnd, _switchoprobit_S, "`touse'", "`outv'" , "`facscale'")	
			qui generate `vtype' `varn'= `atexb' if `touse'							
			label variable `varn' "Marginal Effect of `ytr' on `yout1' outcome `i'"								
		}
		
		if "`type'"=="sete`i'" {
				local outv = `i'
				
				tempname beta vcv 
				mat `beta' = e(b)
				mat `vcv' = e(V)
				local xvars `e(rhsout)'
				local beta0 
				local beta1
				foreach x of local xvars {
					local beta0 "`beta0' beta0_`x'"
					local beta1 "`beta1' beta1_`x'"
					}
				local treatx `e(treatrhs)'
				local trtx
				foreach x of local treatx {
					local trtx "`trtx' btreat_`x'"
					}
				local trtx "`trtx' bconstant"
				local loading atanhl0 atanhl1
				local cuts0
				local cuts1
				forv i = 1/`cutpts' {
					local cuts0 "`cuts0' betacut_0`i'"
					local cuts1 "`cuts1' betacut_1`i'"	
					}
				local simnames `trtx' `beta0' `beta1' `loading' `cuts0' `cuts1'
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
				mata: switchoprobitsim_predict_sete("`atexb'", _switchoprobit_rnd, _switchoprobit_S, ///
					simbetas, "`xvars'", "`treatx'", "`touse'", "`outv'", "`nsim'","`cutpts'", "`lambda01'" ///
					)	
				qui generate `vtype' `varn'= `atexb' if `touse'											
				label variable `varn' "Standard Error of the Effect of `ytr' on `yout1' outcome `i'"
			}
		
		/*if "`type'"=="sete`i'" {
				tempname W t sehat
				mat `W' = e(V)
				local `t'=`cutpts'
				local xvars `e(rhsout)' 
				local tvars `e(treatrhs)'
				local wcount: word count `tvars'
				local tcount = `wcount'+1
				local outv = `i'
				tempvar sehat
				qui g double `sehat' = . 
				mata: switchoprobitsim_predict_sete("`sehat'", "`xb1'", "`cutmat_out1'", "`xb0'", "`cutmat_out0'", ///
							 	 _switchoprobit_rnd, _switchoprobit_S, "`cutpts'", "`outv'", "`W'", "`xvars'", ///
								 "`tcount'" )	
				qui generate `vtype' `varn'= `sehat' if `touse'							
				label variable `varn' "Standard Error of the Marginal Effect of `ytr' on `yout1' outcome `i'"
		}*/
	}
	
	forv i=1/`nchoices' {
		if "`type'"=="tt`i'"{
			local outv = `i'
			tempvar zxb1
			qui g double `zxb1' = . if `touse'
			 mata: mata_switchoprobitsim_predict_tt("`zxb1'", "`zbp'", "`xb1'", "`cutmat_out1'", "`xb0'", "`cutmat_out0'", ///
			 		"`lambda0'", "`lambda1'", _switchoprobit_rnd, _switchoprobit_S, "`touse'", "`outv'", "`facscale'" )
		  local sqrt2 = sqrt(2)	
		 
		  
		  qui generate `vtype' `varn' = (`zxb1')/(`psel') if `touse' & `ytr'==1 	
			label variable `varn' "Marginal Effect of `ytr' on `yout1' outcome `i' if treated"								
		}
		
		if "`type'"=="sett`i'" {
			local outv = `i'
				tempname beta vcv 
				mat `beta' = e(b)
				mat `vcv' = e(V)
				local xvars `e(rhsout)'
				local beta0 
				local beta1
				foreach x of local xvars {
					local beta0 "`beta0' beta0_`x'"
					local beta1 "`beta1' beta1_`x'"
					}
				local treatx `e(treatrhs)'
				local trtx
				foreach x of local treatx {
					local trtx "`trtx' btreat_`x'"
					}
				local trtx "`trtx' bconstant"
				local loading atanhl0 atanhl1
				local cuts0
				local cuts1
				forv i = 1/`cutpts' {
					local cuts0 "`cuts0' betacut_0`i'"
					local cuts1 "`cuts1' betacut_1`i'"	
					}
				local simnames `trtx' `beta0' `beta1' `loading' `cuts0' `cuts1'
				local partx `trtx' `beta0' `beta1'
				local idx : word count `partx'
				local r0idx = `idx'+1
				local r1idx = `idx'+2
				local nsim = e(sedraws) //500
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
				mata: switchoprobitsim_predict_sett("`atexb'", _switchoprobit_rnd, _switchoprobit_S, ///
					simbetas, "`xvars'", "`treatx'", "`touse'", "`outv'", "`nsim'","`cutpts'", ///
					"`r0idx'","`r1idx'", "`facscale'")	
				qui generate `vtype' `varn'= `atexb' if `touse' & `ytr'==1											
				label variable `varn' "Standard Error of the Effect of `ytr' on `yout1' outcome `i' among Treated"		
		}
	}
		
if "`type'" =="ptr" {
		generate `vtyp' `varn' = normal(`zbp') if `touse'
		label variable `varn' "Probability of selection into `ytr'"
		}
	
	if "`type'" =="xbout1" {
			generate `vtyp' `varn' = `xb1' if `touse'
			label variable `varn' "Outcome index, treated group"
	}
	if "`type'" =="xbout0" {
			generate `vtyp' `varn' = `xb0' if `touse'
			label variable `varn' "Outcome index, untreated group"
	}


	
end	
	
mata:
function mata_switchoprobitsim_predict(string scalar newv, string scalar zb, string scalar xb, string scalar cutmat, string ///
		scalar lam01, real matrix rnd, real scalar S, string scalar touse, string scalar treat, string scalar out)	
		
		{		
		st_view(zbeta,.,zb,touse)
		st_view(xbeta,.,xb,touse)
		st_view(lambda_t,., lam01,touse)
		r = rows(zbeta)
		z = rows(rnd)
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
		xbjrnd = xbj:-lambda_t:*rnd
		xbjM1 = cutjM1:-xbeta
		xbjM1rnd = xbjM1:-lambda_t:*rnd
		newvar = rowsum((normal(etarnd)):*((normal(xbjrnd)):-(normal(xbjM1rnd)))):/S
		st_store(.,newv,newvar)
		}	
end

mata:
function mata_switchoprobitsim_predict_lf(string scalar newv, string scalar zb, string scalar xbji, string scalar xbjM1i, string ///
		scalar lam01, real matrix rnd, real scalar S, string scalar touse, string scalar Yt )	
		
		{		
		st_view(zbeta,.,zb,touse)
		st_view(xbetaj,.,xbji,touse)
		st_view(xbetajM1,.,xbjM1i,touse)
		st_view(lambda_t,., lam01,touse)
		st_view(Y,.,Yt,touse)
		k = 2:*Y:-1
		eta = k:*zbeta
		etarnd = eta:+rnd
		xbj = xbetaj
		xbjrnd = xbj:-lambda_t:*rnd
		xbjM1 = xbetajM1
		xbjM1rnd = xbjM1:-lambda_t:*rnd
		normzb = normal(etarnd)
		normxb = ((normal(xbjrnd)):-(normal(xbjM1rnd)))
		liketemp = normzb:*normxb
		L = (rowsum(liketemp)):/S
		newvar =rowmax((L , J(rows(L),1,smallestdouble())))
		//newvar = ln(temp)
		st_store(.,newv,newvar)		
		
		}	
end



mata:
function mata_switchoprobitsim_predict_tt(string scalar newv, string scalar zb, string scalar xb_1, string scalar cutmat1, ///
		string scalar xb_0, string scalar cutmat0, string scalar lam0, string scalar lam1, real matrix rnd, real scalar S,  ///
		string scalar touse, string scalar out, string scalar scale)	
		
		{		
		st_view(zbeta,.,zb, touse)
		st_view(xbeta1,.,xb_1, touse)
		st_view(xbeta0,.,xb_0, touse) 
		//st_view(lambda_t,.,lam01, touse)
		lambda1 = strtoreal(lam1)
		lambda0 = strtoreal(lam0)
		r = rows(zbeta)
		z = rows(rnd)
		cutpts1 = st_matrix(cutmat1)
		
		cutpts0 = st_matrix(cutmat0)
	
		c = cols(cutpts1)
		outr = strtoreal(out)
		facscale = strtoreal(scale)
		eta = zbeta
		etarnd = (eta:+rnd)
		cutj1 = cutpts1[1,outr+1]
		cutjM11 = cutpts1[1,outr]
		cutj0 = cutpts0[1,outr+1]
		cutjM10 = cutpts0[1,outr]
		xb1j = cutj1:-xbeta1
		xb0j = cutj0:-xbeta0
		xb1jrnd = (xb1j:-lambda1:*rnd)
		xb0jrnd = (xb0j:-lambda0:*rnd)
		xb1jM1 = cutjM11:-xbeta1
		xb0jM1 = cutjM10:-xbeta0
		xb1jM1rnd = (xb1jM1:-lambda1:*rnd)
		xb0jM1rnd = (xb0jM1:-lambda0:*rnd)
		n1 = rowsum((normal(etarnd)):*((normal(xb1jrnd):-normal(xb1jM1rnd)))):/S
		n0 = rowsum((normal(etarnd)):*((normal(xb0jrnd):-normal(xb0jM1rnd)))):/S
		newvar = n1:-n0
		//newvar  =rowsum((normal(etarnd)):*((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
		//	:-normal(xb0jM1rnd)))):/S
		st_store(.,newv,newvar)
		}	
end


mata:
function switchoprobitsim_predict_sett(string scalar newv, real matrix rnd, real scalar S, ///
				real matrix simbetas, string scalar xvar, string scalar trtx, ///
				string scalar touse, string scalar out, string scalar numsim, ///
				string scalar cuts, string scalar idx0, string scalar idx1,  string scalar scale)
		{
		st_view(X,.,tokens(xvar),touse)
		st_view(tX,.,tokens(trtx),touse)
		//st_view(lambda_t,.,lam01,touse)
		r0 = strtoreal(idx0)
		r1 = strtoreal(idx1)
		n = rows(X)
		cts = strtoreal(cuts)
		outr = strtoreal(out)
		facscale = strtoreal(scale)
		nsim = strtoreal(numsim)
		csim = cols(simbetas)
		rsim = rows(simbetas)
		tCols = cols(tX)
		xCols = cols(X)
		neginf = st_numscalar("c(minfloat)")
		posinf = st_numscalar("c(maxfloat)")
		c1beg = csim-cts+1
		c1end = csim
		c0beg = c1beg-cts
		c0end = c1beg-1
		l1idx = c0beg-1
		l0idx = l1idx-1
		x1end = l0idx-1
		x1beg = l0idx-xCols
		x0end = x1beg-1
		x0beg = x1beg-xCols
		trend = x0beg-1
		sim_te = J(n,nsim,.)
 		for(i=1;i<=nsim;i++){
	 		lambda0 = (simbetas[i,r0])
 			lambda1 = (simbetas[i,r1])
			cutpts1 = neginf, simbetas[i,c1beg..c1end], posinf
			cutpts0 = neginf, simbetas[i,c0beg..c0end], posinf
			beta1 = simbetas[i,x1beg..x1end]'
			beta0 = simbetas[i,x0beg..x0end]'
			beta_t = simbetas[i,1..trend]'
			cutj1 = cutpts1[1,outr+1]
			cutjM11 = cutpts1[1,outr]
			cutj0 = cutpts0[1,outr+1]
			cutjM10 = cutpts0[1,outr]
			xbeta1 = X*beta1
			xbeta0 = X*beta0
			eta = (tX*beta_t)
			psel = mean(normal(eta))
			etarnd = (eta:+rnd)
			xb1j = cutj1:-xbeta1
			xb0j = cutj0:-xbeta0
			xb1jrnd = (xb1j:-lambda1:*rnd)
			xb0jrnd = (xb0j:-lambda0:*rnd)
			xb1jM1 = cutjM11:-xbeta1
			xb0jM1 = cutjM10:-xbeta0
			xb1jM1rnd = (xb1jM1:-lambda1:*rnd)
			xb0jM1rnd = (xb0jM1:-lambda0:*rnd)
			n1 = rowsum((normal(etarnd)):*((normal(xb1jrnd):-normal(xb1jM1rnd)))):/S
			n0 = rowsum((normal(etarnd)):*((normal(xb0jrnd):-normal(xb0jM1rnd)))):/S
			sim_te[.,i] = (n1:-n0):/psel
		}
		mu_sim = rowsum(sim_te):/nsim
		newvar = rowsum(sqrt((sim_te:-mu_sim):^2)):/nsim
		st_store(.,newv,newvar)
		}
end



mata:
function mata_switchoprobitsim_predict_te(string scalar newv, string scalar zb, string scalar xb_1, string scalar cutmat1, ///
		string scalar xb_0, string scalar cutmat0, string scalar lam01, real matrix rnd, real scalar S,  ///
		string scalar touse, string scalar out, string scalar scale)	
		
		{		
		st_view(zbeta,.,zb)
		st_view(xbeta1,.,xb_1)
		st_view(xbeta0,.,xb_0) 
		st_view(lambda_t,.,lam01)
		//lambda0 = strtoreal(lam0)
		//lambda1 = strtoreal(lam1)
		cutpts1 = st_matrix(cutmat1)
		cutpts0 = st_matrix(cutmat0)
		c = cols(cutpts1)
		outr = strtoreal(out)
		facscale = strtoreal(scale)
		cutj1 = cutpts1[1,outr+1]
		cutjM11 = cutpts1[1,outr]
		cutj0 = cutpts0[1,outr+1]
		cutjM10 = cutpts0[1,outr]
		xb1j = cutj1:-xbeta1
		xb0j = cutj0:-xbeta0
		xb1jrnd = (xb1j:-lambda_t:*rnd)
		xb0jrnd = (xb0j:-lambda_t:*rnd)
		xb1jM1 = cutjM11:-xbeta1
		xb0jM1 = cutjM10:-xbeta0
		xb1jM1rnd = (xb1jM1:-lambda_t:*rnd)
		xb0jM1rnd = (xb0jM1:-lambda_t:*rnd)
		newvar = rowsum(((normal(xb1jrnd):-normal(xb1jM1rnd)):-(normal(xb0jrnd) ///
			:-normal(xb0jM1rnd)))):/S
		st_store(.,newv,newvar)
		}	
end	

mata:
function switchoprobitsim_predict_sete(string scalar newv, real matrix rnd, real scalar S, ///
					real matrix simbetas, string scalar xvar, string scalar trtx, ///
					string scalar touse, string scalar out, string scalar numsim, ///
					string scalar cuts, string scalar lam01)
		{
		st_view(X,.,tokens(xvar),touse)
		st_view(tX,.,tokens(trtx),touse)
		st_view(lambda_t,.,lam01,touse)
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
		/*indexes*/
		c1beg = csim-cts+1
		c1end = csim
		c0beg = c1beg-cts
		c0end = c1beg-1
		l1idx = c0beg-1
		l0idx = l1idx-1
		x1end = l0idx-1
		x1beg = l0idx-xCols
		x0end = x1beg-1
		x0beg = x1beg-xCols
		trend = x0beg-1
		sim_te = J(n,nsim,.)
 		for(i=1;i<=nsim;i++){
			cutpts1 = neginf, (simbetas[i,c1beg..c1end]) , posinf
			cutpts0 = neginf, (simbetas[i,c0beg..c0end]) , posinf
			beta1 = (simbetas[i,x1beg..x1end])'
			beta0 = (simbetas[i,x0beg..x0end])'
			cutj1 = cutpts1[1,outr+1]
			cutjM11 = cutpts1[1,outr]
			cutj0 = cutpts0[1,outr+1]
			cutjM10 = cutpts0[1,outr]
			xbeta1 = X*beta1
			xbeta0 = X*beta0
			xb1j = cutj1:-xbeta1
			xb0j = cutj0:-xbeta0
			xb1jrnd = xb1j:-lambda_t:*rnd
			xb0jrnd = xb0j:-lambda_t:*rnd
			xb1jM1 = cutjM11:-xbeta1
			xb0jM1 = cutjM10:-xbeta0
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
function switchoprobitsim_predict_sete(string scalar newv, string scalar xb_1, string scalar cutmat1, ///
		string scalar xb_0, string scalar cutmat0, real matrix rnd, real scalar S,  ///
		string scalar cuts, string scalar out, string scalar Mat, string scalar xvar, string scalar tvec)	
		{		
		n=st_nobs()
		st_view(X,.,tokens(xvar))
		st_view(xbeta1,.,xb_1)
		st_view(xbeta0,.,xb_0) 
		JMat = st_matrix(Mat)
		cutpts1 = st_matrix(cutmat1)
		cutpts0 = st_matrix(cutmat0)
		cutpts = strtoreal(cuts) //cols(cutpts1)
		tcols = strtoreal(tvec)
		nchoices = cutpts+1
		kx = cols(X)
		outr = strtoreal(out)
		cutj1 = cutpts1[1,outr+1]
		cutjM11 = cutpts1[1,outr]
		cutj0 = cutpts0[1,outr+1]
		cutjM10 = cutpts0[1,outr]
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
		rho = J(n,2,0)
		zeta = tzero, delta0, delta1, rho, kappa0, kappa1
		
		for (i=1;i<=kx;i++) {
				delta0[.,i] =  -1:*(rowsum((normalden(xb0jrnd):-normalden(xb0jM1rnd))):/S):*X[.,i] 
				delta1[.,i] = (rowsum((normalden(xb1jrnd):-normalden(xb1jM1rnd))):/S):*X[.,i]
							
				}
		if (outr==1){
				kappa0[.,1] = -1:*(rowsum(normalden(xb0jrnd)):/S)
				kappa1[.,1] = (rowsum(normalden(xb1jrnd)):/S)
		}
		if (outr==nchoices){
				kappa0[.,cutpts] = (rowsum(normalden(xb0jM1rnd)):/S)
				kappa1[.,cutpts] = -1:*(rowsum(normalden(xb1jM1rnd)):/S)
		}
		if (outr>1 & outr<nchoices){
				k = outr-1
				
				kappa0[.,outr] = (-1:*(rowsum(normalden(xb0jrnd))):/S) 
				kappa1[.,outr] = (rowsum((normalden(xb1jrnd))):/S)
				kappa0[.,k] = (rowsum((normalden(xb0jM1rnd))):/S)
				kappa1[.,k] = (-1:*(rowsum(normalden(xb1jM1rnd))):/S)
		}
				
		delta = tzero, delta0, delta1, rho, kappa0, kappa1
			
		for (i=1;i<=n;i++) {
			jacobmat = delta[i,.]
			newvar[i] = sqrt(jacobmat*JMat*jacobmat')
		}
		st_store(.,newv,newvar)
	}	


end

	*/





					
					
