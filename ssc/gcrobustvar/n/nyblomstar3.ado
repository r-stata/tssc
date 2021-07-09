
capture program drop nyblomstar3
program nyblomstar3, rclass

version 14.1

args y x z w b0 heter hac

	mat depvar = `y'-`x'*`b0'
	mat z = `z'
	mat w = `w'
	
	local T = rowsof(`x')
	local k = colsof(`x')
	
	svmat depvar, names(depvar)
	svmat z, names(zz)
	svmat w, names(ww)

	gen time_nyblomstar = _n
    tsset time_nyblomstar

	if "`hac'" != "0" {
	gmm (depvar1-{xb:zz1-zz`=colsof(z)'}), instruments(ww1-ww`=colsof(w)', noconstant) wmatrix(hac nw `hac') twostep
	    }
	else {	
	if `heter' == 0 {
	    gmm (depvar1-{xb:zz1-zz`=colsof(z)'}), instruments(ww1-ww`=colsof(w)', noconstant) onestep
        }
	if `heter' == 1 {
	    gmm (depvar1-{xb:zz1-zz`=colsof(z)'}), instruments(ww1-ww`=colsof(w)', noconstant) twostep
	    }
	}
	if "`e(scorevers)'" != "" {
		* predict changed syntax behavior in 14.2
		local residuals residuals
	}
	predict ee if e(sample), `residuals'
	mkmat ee
	mat e2 = hadamard(ee,ee)
	drop ee depvar1 zz1-zz`=colsof(z)' ww1-ww`=colsof(w)' time_nyblomstar
	
	if "`hac'" != "0" {	    
	    mat Sigma = e(S)		
	    }
	else {	
	if `heter'==1 {
		mat Sigma = e(S)
		}
	if `heter'==0 {
	    mat s2 = (J(1,rowsof(e2),1)*e2[1..`T',1])/(`T'-`k')
        mat Sigma = s2[1,1]*inv(e(W))
		}
	}	

	matsqrt Sigma, pre(sq_)
	mat Mbetabar = (inv(sq_Sigma))*(-`w''*`x'/`T')
	mat Mdeltabar = (inv(sq_Sigma))*(-`w''*`z'/`T')
	mat Pbardelta = Mdeltabar*(inv(Mdeltabar'*Mdeltabar))*Mdeltabar'
	mat omegaN = Mbetabar'*(I(rowsof(Pbardelta))-Pbardelta)*Mbetabar
	
	mat GradQ = `w'[1,1...]*ee[1,1]*(inv(sq_Sigma))*Mbetabar
	forval i = 2/`T' {
	    mat GradQ = GradQ \ `w'[`i',1...]*ee[`i',1]*(inv(sq_Sigma))*Mbetabar
	    }
	mat	GradQpiT = J(rowsof(GradQ),colsof(GradQ),-9999)	
	forval i = 1/`=rowsof(GradQ)' {
	    forval j = 1/`=colsof(GradQ)' { 
		    mat draft = J(1,`i',1)*GradQ[1..`i',`j']
		    mat	GradQpiT[`i',`j'] = draft[1,1]/sqrt(`T')
 	        }
        }	
	
	local sum1 = 0
	forval i = 1/`T' {
	    mat draft = GradQpiT[`i',1...]*(inv(omegaN))*GradQpiT[`i',1...]'/`T'
	    local sum1 = `sum1'+draft[1,1]
	    }
	local result = `sum1'	

    
return scalar result_nyblomstar = `result'


end


