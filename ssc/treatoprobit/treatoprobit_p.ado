capture program drop treatoprobit_p
program define treatoprobit_p, eclass
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
			local PFX "`PFX' P1`i' P0`i' TE`i' TT`i' SETE`i' SETT`i'"
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
 	
   tempvar zbp xbt pseli 
   qui _predict double `zbp' if `touse', xb eq(#1) 
   qui _predict double `xbt' if `touse', xb eq(#2) 
   qui g double `pseli' = normal(`xbt') if `touse'
   qui sum `pseli' if `touse'
   local psel = r(mean)
	
	
	tempname cutmat_tr cutmat_out rho betatreat 
	
	local neginf = minfloat()
	local posinf = maxfloat()
	mat `cutmat_tr' = `neginf',0,`posinf'
	mat `cutmat_out'= `neginf',`cuts', `posinf'
	local `rho' = tanh(_b[atanh_rho:_cons])
	local `betatreat' = _b[`yout':`ytr']
	
	tempname xbtzero xbtone
   qui gen double `xbtzero' = `xbt'-``betatreat''*`ytr'
   qui gen double `xbtone' = `xbtzero'+``betatreat''
    
	
   if (missing("`type'") | "`type'" == "p11") {
           if missing("`type'") noisily display as text "(option p11 assumed; Pr(`ytr'=1, `yout'=1)"
			  local cut_ltr = `cutmat_tr'[1,2]
			  local cut_htr = `cutmat_tr'[1,3]
			  local cut_lout = `cutmat_out'[1,1]
			  local cut_hout = `cutmat_out'[1,2]
			  //di `cut_hout'
           qui generate `vtyp' `varn' = binorm(`cut_htr'-`zbp',`cut_hout'-`xbtone', ``rho'')-  ///
			  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xbtone', ``rho'')- ///
												binorm(`cut_htr'-`zbp', `cut_lout'-`xbtone',``rho'')+  ///
					                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xbtone',``rho'') if `touse'
           label variable `varn' "Pr(`ytr'=1,`yout'=1)"
        
	}
	if "`type'"=="lf" {
	
	forvalues i = 1/`nchoices' {
	local j = `i'+`nchoices'
	tempvar m0`i' m1`i' ll`i' ll`j' 	
	qui g double `m0`i'' = `ytr'==0 & `yout'==`i'
	qui g double `m1`i'' = `ytr'==1 & `yout'==`i'
	qui g double `ll`i'' = 0
	qui g double `ll`j'' = 0
	}
	
	tempname fv_tmp
	qui g double `fv_tmp'=0
	
	local count 0
	forv d = 0/1 {
		local e = `d'+2
		local f = `d'+1
		local cut_h1 = `cutmat_tr'[1,`e']
		local cut_l1 = `cutmat_tr'[1,`f']
		forv i = 1/`nchoices' {
			local `++count'
			local k = `i'+1
			local cut_h2 = `cutmat_out'[1,`k']
			local cut_l2 = `cutmat_out'[1,`i']
			qui replace `ll`count'' = `m`d'`i''*(((binorm(`cut_h1'-`zbp',`cut_h2'-`xbt',``rho''))- ///
			(binorm(`cut_l1'-`zbp',`cut_h2'-`xbt',``rho''))-(binorm(`cut_h1'-`zbp',`cut_l2'-`xbt',``rho''))+ ///
			(binorm(`cut_l1'-`zbp',`cut_l2'-`xbt',``rho''))))
			qui replace `fv_tmp' = `fv_tmp'+`ll`count''
			}
		}
	qui generate double `vtype' `varn' = (`fv_tmp') if `touse'
	label variable `varn' "Log Likelihood Contribution"
	}
	
	forv i = 2/`nchoices' {
		if "`type'"=="p1`i'" {
				local k = `i'+1
		  		local cut_ltr = `cutmat_tr'[1,2]
		  		local cut_htr = `cutmat_tr'[1,3]
		 		local cut_lout = `cutmat_out'[1,`i']
		  		local cut_hout = `cutmat_out'[1,`k']
            qui generate `vtyp' `varn' = binorm(`cut_htr'-`zbp',`cut_hout'-`xbtone', ``rho'')- ///
 			  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xbtone', ``rho'')- ///
 												binorm(`cut_htr'-`zbp', `cut_lout'-`xbtone',``rho'')+  ///
 					                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xbtone',``rho'') if `touse'
            label variable `varn' "Pr(`ytr'=1,`yout'=`i')"
		}
	}
	forv i = 1/`nchoices' {
		if "`type'"=="p0`i'" {
			local k = `i'+1
	  		local cut_ltr = `cutmat_tr'[1,1]
	  		local cut_htr = `cutmat_tr'[1,2]
	 		local cut_lout = `cutmat_out'[1,`i']
	  		local cut_hout = `cutmat_out'[1,`k']
         qui generate `vtyp' `varn' = binorm(`cut_htr'-`zbp',`cut_hout'-`xbtone', ``rho'')- ///
		  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xbtone', ``rho'')- ///
											binorm(`cut_htr'-`zbp', `cut_lout'-`xbtone',``rho'')+  ///
				                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xbtone',``rho'') if `touse'
		
		    label variable `varn' "Pr(`ytr'=0,`yout'=`i')"
		}
		
	if "`type'"=="te`i'" {
		local k = `i'+1
		local cut_ltr = `cutmat_tr'[1,2]
		local cut_htr = `cutmat_tr'[1,3]
 		local cut_lout = `cutmat_out'[1,`i']
  		local cut_hout = `cutmat_out'[1,`k']
		qui generate `vtyp' `varn' = normal(`cut_hout'-`xbtone')-normal(`cut_lout'-`xbtone')- ///
									 normal(`cut_hout'-`xbtzero')+normal(`cut_lout'-`xbtzero') if `touse'	
			label variable `varn' "Marginal Effect of `ytr' on P(`yout'=`i')"
		}


	if "`type'"=="sete`i'" {
		local outid = `i'
		local treatx `e(treatx)'
		local tcount: word count `treatx'
		local treatvec = `tcount'+1
		local xvar `e(indvarout)'
		
		local k = `i'+1
		local cut_lout = `cutmat_out'[1,`i']
  		local cut_hout = `cutmat_out'[1,`k']
  		tempname W  JMat secons sehat
  		mat `W' = e(V) 		
  		mat `JMat'  = `W' 
  		qui g double `sehat' = .
  		mata: mata_treatoprobit_sete_predict("`sehat'", "`xvar'", "`cut_lout'", "`cut_hout'", "`xbtone'", ///
  			"`xbtzero'", "`JMat'", "`cutpts'", "`touse'", "`treatvec'", "`outid'")
  		qui generate `vtyp' `varn' = `sehat' if `touse'	
  		label variable `varn' "Standard Error of Treatment Effect"
		}
}

	forv i = 1/`nchoices' {
		if "`type'"=="tt`i'" {
		tempvar mfx1 mfx0
		local k = `i'+1
		local cut_ltr = `cutmat_tr'[1,2]
		local cut_htr = `cutmat_tr'[1,3]
 		local cut_lout = `cutmat_out'[1,`i']
  		local cut_hout = `cutmat_out'[1,`k']
  		
  		qui g double `mfx1' = (binorm(`cut_htr'-`zbp',`cut_hout'-`xbtone', ``rho'')- ///
 			  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xbtone', ``rho'')- ///
 										 binorm(`cut_htr'-`zbp', `cut_lout'-`xbtone',``rho'')+  ///
 					                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xbtone',``rho'')) if `touse' & `ytr'==1
  		qui g double `mfx0' = (binorm(`cut_htr'-`zbp',`cut_hout'-`xbtzero', ``rho'')- ///
 			  		                     binorm(`cut_ltr'-`zbp', `cut_hout'-`xbtzero', ``rho'')- ///
 										 binorm(`cut_htr'-`zbp', `cut_lout'-`xbtzero',``rho'')+  ///
 					                     binorm(`cut_ltr'-`zbp', `cut_lout'-`xbtzero',``rho'')) if `touse' & `ytr'==1
 		qui generate `vtyp' `varn' = (`mfx1'-`mfx0')/(`psel') if `touse' & `ytr'==1			                     
  		
			label variable `varn' "Affect of `ytr' on P(`yout'=`i') for the treated"		 				 
		
		
		}
	if "`type'"=="sett`i'" {
		local outid = `i'
		local treatx `e(treatx)'
		local tcount: word count `treatx'
		local treatvec = `tcount'+1
		local xvar `e(indvarout)'
		local k = `i'+1
		local cut_lout = `cutmat_out'[1,`i']
  		local cut_hout = `cutmat_out'[1,`k']
  		tempname W  JMat secons sehat
  		mat `W' = e(V) 		
  		mat `JMat'  = `W' 
  		qui g double `sehat' = .
  		mata: mata_treatoprobit_sete_predict("`sehat'", "`xvar'", "`cut_lout'", "`cut_hout'", "`xbtone'", ///
  			"`xbtzero'", "`JMat'", "`cutpts'", "`touse'", "`treatvec'", "`outid'")
  		qui generate `vtyp' `varn' = `sehat' if `touse' & `ytr'==1	
  		label variable `varn' "Standard Error of Treatment Effect on the Treated"
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
function mata_treatoprobit_sete_predict(string scalar new_se, string scalar xvars, string scalar klo, string scalar khi, string ///
		scalar xbt1, string scalar xbt0, string scalar Mat, string scalar cuts, string scalar touse, string scalar tvec, string scalar outid ///
		)	
		
		{
		n=st_nobs()	
		st_view(xb1,.,xbt1, touse)
		st_view(xb0,.,xbt0, touse)
		k_hi = strtoreal(khi)
		k_lo = strtoreal(klo)
		tcol = strtoreal(tvec)
		outr = strtoreal(outid)
		outr1 = outr+1
		cutpts = strtoreal(cuts)
		nchoices = cutpts+1
		JMat = st_matrix(Mat)
		z = cols(JMat)
		st_view(X,.,tokens(xvars),touse)
		kx = cols(X)
		c = kx+cutpts
		newvar = J(n,1,.)
		delta = J(n, kx, 0)
		tau = J(n, cutpts, 0)
		tzero = J(n,tcol,0)
		rho = J(n,1,0)
		for (i=1;i<=kx;i++) {
			if (i<kx){
				delta[.,i] = (normalden(k_hi:-xb1[.,1]):-normalden(k_lo:-xb1[.,1]):- ///
							 normalden(k_hi:-xb0[.,1]):+normalden(k_lo:-xb0[.,1])):*X[.,i] 
			}
			if (i==kx){
				delta[.,i] = (normalden(k_hi:-xb1[.,1]):-normalden(k_lo:-xb1[.,1])) 
				}
			}
		
		if(outr==1){				 
			tau[.,1] = (normalden(k_hi:-xb1[.,1]):-normalden(k_hi:-xb0[.,1]))
				}
		if(outr==nchoices){
			tau[.,cutpts] = -(normalden(k_lo:-xb1[.,1]):-normalden(k_lo:-xb0[.,1]))
				}
		if(outr>1 & outr<nchoices) {
			k = outr-1
			tau[., outr] = (normalden(k_hi:-xb1[.,1]):-normalden(k_hi:-xb0[.,1]))
			tau[., k] = -(normalden(k_lo:-xb1[.,1]):-normalden(k_lo:-xb0[.,1]))
		} 
		jacobian = tzero,delta,rho,tau
		for (i=1;i<=n;i++) {
			jacobmat = jacobian[i,.]
			newvar[i] = sqrt(jacobmat*JMat*jacobmat')
		}
		st_store(.,new_se,newvar)
	}	
end

