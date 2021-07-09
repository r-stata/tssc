*! version 2.0.0 cagregory 3 19 14
capture program drop switchoprobit_p
program define switchoprobit_p

	
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
	
		
	local myopts PTR XBOUT0 XBOUT1 `PFX' LF
	
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
	local type "`ptr'`xbout0'`xbout1'`pfx'`lf'"
	
	local ytr : word 1 of `e(depvar)'
   	local yout0 : word 2 of `e(depvar)'
 	local yout1 : word 3 of `e(depvar)'
 	local s = strlen("`yout0'")
 	local ss = `s'-2
 	local treatvar = substr("`yout0'",1,`ss')
 	
   tempvar zbp xb0 xb1
   qui _predict double `zbp' if `touse', xb eq(#1) 
   qui _predict double `xb0' if `touse', xb eq(#2) 
	qui _predict double `xb1' if `touse', xb eq(#3)
     tempvar psel 
	qui g double `psel' = normal(`zbp')
	
	
	tempname cutmat_tr cutmat_out0 cutmat_out1 rho0 rho1 
	local neginf = minfloat()
	local posinf = maxfloat()
	mat `cutmat_tr' = `neginf',0,`posinf'
	mat `cutmat_out0'= `neginf',`cuts0', `posinf'
	mat `cutmat_out1'= `neginf',`cuts1', `posinf'
	local `rho0' = tanh(_b[atanh_rho0:_cons])
	local `rho1' = tanh(_b[atanh_rho1:_cons])
	tempvar xb1_0
	local xvec `e(rhsout)'
	qui g double `xb1_0'=0
	foreach x of local xvec {
		qui replace `xb1_0'=`x'*_b[`yout0':`x'] if `touse' & `ytr==1'
	} 
	
	
   if (missing("`type'") | "`type'" == "p11") {
           if missing("`type'") noisily display as text "(option p11 assumed; Pr(`ytr'=1, `yout1'=1)"
			  local cut_ltr = `cutmat_tr'[1,2]
			  local cut_htr = `cutmat_tr'[1,3]
			  local cut_lout = `cutmat_out1'[1,1]
			  local cut_hout = `cutmat_out1'[1,2]
			  //di `cut_hout'
           generate `vtyp' `varn' = binorm(`cut_htr'-`zbp',`cut_hout'-`xb1', ``rho1'')-  ///
			  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xb1', ``rho1'')- ///
												binorm(`cut_htr'-`zbp', `cut_lout'-`xb1',``rho1'')+  ///
					                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xb1',``rho1'') if `touse'
           label variable `varn' "Pr(`ytr'=1,`yout'=1)"
        
	}
	
	if "`type'"=="lf" {
	forvalues i = 1/`nchoices' {
	
	tempvar m0`i' m1`i' ll0`i' ll1`i' //ll`j' 	
	qui g double `m0`i'' = `ytr'==0 & (`treatvar'==`i')
	qui g double `m1`i'' = `ytr'==1 & (`treatvar'==`i')
	qui g double `ll0`i'' = 0
	qui g double `ll1`i'' = 0
	}
	
	tempname fv_tmp
	qui g double `fv_tmp'=0
	forv d = 0/1 {
		local e = `d'+2
		local f = `d'+1
		local cut_h1 = `cutmat_tr'[1,`e']
		local cut_l1 = `cutmat_tr'[1,`f']
			forv t = 1/`nchoices' {
			local j = `t'+`nchoices'
			local k = `t'+1
				local cut_h2 = `cutmat_out`d''[1,`k']
				local cut_l2 = `cutmat_out`d''[1,`t']
				qui replace `ll`d'`t'' = `m`d'`t''*(((binorm(`cut_h1'-`zbp',`cut_h2'-`xb`d'',``rho`d'''))- ///
				(binorm(`cut_l1'-`zbp',`cut_h2'-`xb`d'',``rho`d'''))-(binorm(`cut_h1'-`zbp',`cut_l2'-`xb`d'',``rho`d'''))+ ///
				(binorm(`cut_l1'-`zbp',`cut_l2'-`xb`d'',``rho`d'''))))
				qui replace `fv_tmp' = `fv_tmp'+`ll`d'`t''			
			}
	
	}
	generate `vtyp' `varn' = `fv_tmp' if `touse'
	label variable `varn' "Likelihood Contribution"
	}
	
	forv i = 2/`nchoices' {
		if "`type'"=="p1`i'" {
				local k = `i'+1
		  		local cut_ltr = `cutmat_tr'[1,2]
		  		local cut_htr = `cutmat_tr'[1,3]
		 		local cut_lout = `cutmat_out1'[1,`i']
		  		local cut_hout = `cutmat_out1'[1,`k']
            generate `vtyp' `varn' = binorm(`cut_htr'-`zbp',`cut_hout'-`xb1', ``rho1'')- ///
 			  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xb1', ``rho1'')- ///
 												binorm(`cut_htr'-`zbp', `cut_lout'-`xb1',``rho1'')+  ///
 					                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xb1',``rho1'') if `touse'
            label variable `varn' "Pr(`ytr'=1,`yout'=`i')"
		}
	}
	forv i = 1/`nchoices' {
		if "`type'"=="p0`i'" {
			local k = `i'+1
	  		local cut_ltr = `cutmat_tr'[1,1]
	  		local cut_htr = `cutmat_tr'[1,2]
	 		local cut_lout = `cutmat_out0'[1,`i']
	  		local cut_hout = `cutmat_out0'[1,`k']
         generate `vtyp' `varn' = binorm(`cut_htr'-`zbp',`cut_hout'-`xb0', ``rho0'')- ///
		  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xb0', ``rho0'')- ///
											binorm(`cut_htr'-`zbp', `cut_lout'-`xb0',``rho0'')+  ///
				                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xb0',``rho0'') if `touse'
		
		    label variable `varn' "Pr(`ytr'=0,`yout'=`i')"
		}
		
	if "`type'"=="te`i'" {
		local k = `i'+1
		local cut_ltr = `cutmat_tr'[1,2]
		local cut_htr = `cutmat_tr'[1,3]
 		local cut_lout1 = `cutmat_out1'[1,`i']
  		local cut_hout1 = `cutmat_out1'[1,`k']
		local cut_lout0 = `cutmat_out0'[1,`i']
		local cut_hout0 = `cutmat_out0'[1,`k']
		generate `vtyp' `varn' = normal(`cut_hout1'-`xb1')-normal(`cut_lout1'-`xb1')- ///
									 normal(`cut_hout0'-`xb0')+normal(`cut_lout0'-`xb0') if `touse'	
			label variable `varn' "Marginal Effect of `ytr' on P(`yout1'=`i')"
		}
		
	if "`type'"=="sete`i'" {
		local out = `i'
		tempname W d e f g h C t sehat
		local `t'=`cutpts'
		local treatvars `e(treatx)'
		local tcount: word count `treatvars'
		local treatvec = `tcount'+1
		local xvars `e(rhsout)' 
		local wcount: word count `xvars'
		local wfirst: word 1 of `xvars'
		local wlast: word `wcount' of `xvars'
		mat `W' = e(V)
		mat `d' = `W'["`yout0':`wfirst'" . . "`yout1':`wlast'", "`yout0':`wfirst'" . . "`yout1':`wlast'"]
		mat `g' = `W'["cut_01:" . . "cut_1``t'':", "cut_01:" . . "cut_1``t'':"]
		mat `e' = `W'["`yout0':", "cut_01:" . . "cut_1``t'':"]
		mat `f' = `W'["`yout1':", "cut_01:" . . "cut_1``t'':"]
		mat `h' = `e' \ `f'
		mat `C' = `W'  //`d', `h' \ `h'', `g'
		//mat list `C'
		local k = `i'+1
		local cut_ltr = `cutmat_tr'[1,2]
		local cut_htr = `cutmat_tr'[1,3]
 		local cut_lout1 = `cutmat_out1'[1,`i']
  		local cut_hout1 = `cutmat_out1'[1,`k']
		local cut_lout0 = `cutmat_out0'[1,`i']
		local cut_hout0 = `cutmat_out0'[1,`k']
		qui g `sehat' = .
		mata: mata_switchoprobit_sete_predict("`sehat'","`xvars'", "`C'", "`cut_hout1'", "`cut_lout1'", ///
			"`cut_hout0'", "`cut_lout0'", "`xb1'", "`xb0'", "`ytr'", "`cutpts'", "`treatvec'", "`out'")
		generate `vtyp' `varn' = `sehat' if `touse'	
			label variable `varn' "Standard Error of Marginal Effect of `ytr' on P(`yout1'=`i')"
		
	
	}
}


	forv i = 1/`nchoices' {
		if "`type'"=="tt`i'" {
		local k = `i'+1
		local cut_ltr = `cutmat_tr'[1,2]
		local cut_htr = `cutmat_tr'[1,3]
 		local cut_lout1 = `cutmat_out1'[1,`i']
  		local cut_hout1 = `cutmat_out1'[1,`k']
  		local cut_lout0 = `cutmat_out0'[1,`i']
		local cut_hout0 = `cutmat_out0'[1,`k']
		tempvar zx1 zx0
		qui g double `zx1' = binorm(`cut_htr'-`zbp', `cut_hout1'-`xb1', ``rho1'')- ///
 			                 binorm(`cut_ltr'-`zbp', `cut_hout1'-`xb1', ``rho1'')- ///
 							 binorm(`cut_htr'-`zbp', `cut_lout1'-`xb1',``rho1'')+  ///
 					         binorm(`cut_ltr'-`zbp', `cut_lout1'-`xb1',``rho1'') if `touse'
 		qui g double `zx0' = binorm(`cut_htr'-`zbp', `cut_hout0'-`xb0', ``rho0'')- ///
		  		             binorm(`cut_ltr'-`zbp', `cut_hout0'-`xb0', ``rho0'')- ///
							 binorm(`cut_htr'-`zbp', `cut_lout0'-`xb0',``rho0'')+  ///
				             binorm(`cut_ltr'-`zbp', `cut_lout0'-`xb0',``rho0'') if `touse'
		generate `vtyp' `varn' = (`zx1'-`zx0')/(`psel') if `touse' & `ytr'==1		             
		
		label variable `varn' "Effect of `ytr' on P(`treatvar'=`i') for the treated"		 				 
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
				local treatx `e(treatx)'
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
				local nsim = 100
				preserve
				capture drop _all
				scalar betaC = colsof(`beta')
				qui drawnorm `simnames', n(`nsim') means(`beta') cov(`vcv')
				mata: simbetas = st_data(.,"`simnames'")
				restore
				tempname constant
				qui g double `constant' = 1
				local treatx "`treatx' `constant'"
				tempvar outvar
				qui g double `outvar' = . if `touse' 
				mata: switchoprobit_predict_sett("`outvar'", simbetas, "`xvars'", "`treatx'", ///
				"`touse'", "`outv'", "`nsim'","`cutpts'","`r0idx'", "`r1idx'")	
				qui generate `vtyp' `varn'= `outvar' if `touse' & `ytr'==1											
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
	
/*mata: mata_switchoprobit_sete_predict("`sehat'", "`xvars'", "`C'", "`cut_hout1'", "`cut_lout1'", ///
			"`cut_hout0'", "`cut_lout0'", "`xb1'", "`xb0'", "`ytr'") */				
mata:
function mata_switchoprobit_sete_predict(string scalar new_se, string scalar xvars, string scalar Mat, string scalar chi1, string scalar clo1, ///
	 string scalar chi0, string scalar clo0, string scalar xb_1, string scalar xb_0, string scalar tvar, ///
	 string scalar cuts, string scalar tvec, string scalar out)	
		
		{
		n=st_nobs()	
		st_view(xb1,.,xb_1)
		st_view(xb0,.,xb_0)
		st_view(Y,.,tvar)
		khi1 = strtoreal(chi1)
		klo1 = strtoreal(clo1)
		khi0 = strtoreal(chi0)
		klo0 = strtoreal(clo0)
		tcols = strtoreal(tvec)
		cutpts = strtoreal(cuts)
		outr = strtoreal(out)
		nchoices = cutpts+1
		JMat = st_matrix(Mat)
		st_view(X,.,tokens(xvars))
		kx = cols(X)
		c = kx+cutpts
		newvar = J(n,1,.)
		tzero = J(n,tcols,0)
		kappa1 = J(n,cutpts, 0)
		delta1 = J(n, kx, 0)
		kappa0 = J(n, cutpts, 0)
		delta0 = J(n, kx, 0)
		rho = J(n,2,0)
		for (i=1;i<=kx;i++) {
				delta0[.,i] =  -1:*(normalden(khi0:-xb0[.,1]):-normalden(klo0:-xb0[.,1])):*X[.,i] 
				delta1[.,i] = (normalden(khi1:-xb1[.,1]):-normalden(klo1:-xb1[.,1])):*X[.,i] ///
							
				}
		if (outr==1){
				kappa0[.,1] = -1:*(normalden(khi0:-xb0[.,1]))
				kappa1[.,1] = (normalden(khi1:-xb1[.,1]))
		}
		if (outr==nchoices){
				kappa0[.,cutpts] = (normalden(klo0:-xb0[.,1]))
				kappa1[.,cutpts] = -1:*(normalden(klo1:-xb1[.,1]))
		}
		if (outr>1 & outr<nchoices){
				k = outr-1
				kappa0[.,outr] = (-1:*(normalden(khi0:-xb0[.,1]))) 
				kappa1[.,outr] = ((normalden(khi1:-xb1[.,1])))
				kappa0[.,k] = ((normalden(klo0:-xb0[.,1])))
				kappa1[.,k] = (-1:*(normalden(klo1:-xb1[.,1])))
		}
				
		delta = tzero, delta0, delta1, rho, kappa0, kappa1
		f = cols(delta)	
		for (i=1;i<=n;i++) {
			jacobmat = delta[i,.]
			newvar[i] = sqrt(jacobmat*JMat*jacobmat')
		}
		st_store(.,new_se,newvar)
	}	


end
mata:
function switchoprobit_predict_sett(string scalar newv, ///
				real matrix simbetas, string scalar xvar, string scalar trtx, ///
				string scalar touse, string scalar out, string scalar numsim, ///
				string scalar cuts, string scalar idx0, string scalar idx1)
		{
		
		st_view(X,.,tokens(xvar))
		st_view(tX,.,tokens(trtx))
		r1 = strtoreal(idx1)
		r0 = strtoreal(idx0)
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
		boot_te1 = J(n,nsim,.)
		boot_te0 = J(n,nsim,.)
		boot_te = J(n,nsim,.)
 		for(i=1;i<=nsim;i++){
 			rho0 = tanh(simbetas[i,r0])
 			rho1 = tanh(simbetas[i,r1])
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
			xb1j = cutj1:-xbeta1
			xb0j = cutj0:-xbeta0
			xb1jM1 = cutjM11:-xbeta1
			xb0jM1 = cutjM10:-xbeta0
			boot_te1[.,i] =  binormal(posinf:-eta, xb1j, rho1):- ///
 			                 binormal(-eta, xb1j, rho1):- ///
 							 binormal(posinf:-eta, xb1jM1,rho1):+  ///
 					         binormal(-eta, xb1jM1,rho1)
			boot_te0[.,i] = binormal(posinf:-eta, xb0j, rho0):- ///
 			                 binormal(-eta, xb0j, rho0):- ///
 							 binormal(posinf:-eta, xb0jM1, rho0):+  ///
 					         binormal(-eta, xb0jM1, rho0)
 			boot_te[.,i] = (boot_te1[.,i]:-boot_te0[.,i]):/psel 
 					         }
		mu_sim = (rowsum(boot_te)):/nsim
		newvar = rowsum(sqrt((boot_te:-mu_sim):^2)):/nsim
		st_store(.,newv,newvar)
		}
end








