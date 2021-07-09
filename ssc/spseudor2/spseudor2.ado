*! Program to calculate goodness-of-fit measures in spatial lag models estimated by spatial 2SLS or spatial gmm.
*! Author: P. Wilner Jeanty
*! Born: April, 2010
*! Updated: September 2010
prog define spseudor2, rclass
	version 10.1
	if "`e(cmd)'"=="" {
		di
		di as err "The IV model has not been estimated. Please estimate a model"
		exit 301
	}
	else if !inlist("`e(cmd)'", "ivregress", "ivreg29", "spcgmm") {
		di
		di as txt "You are responsible as to whether SPSEUDOR2 is appropriate after your `e(cmd)' command"		
	}
	syntax, wmat(string) 
	local depv "`e(depvar)'"
	local endogvar "`e(instd)'"	
	gettoken lagv endogvar: endogvar // in case of more than one endog vars, assume that the spatially lagged dependent variable is listed as the first one. 
	local varlist `endogvar' `e(exogr)'  // assuming the other endogvars, if any, appear after the spatially lagged dependent variable
	tempvar predy
	tempname bmat rho
	scalar `rho'=_b[`lagv'] 
	mat `bmat'=e(b) 
	mat `bmat'=`bmat'[1,2 ... ] 
	di as txt "This may take some time"	
	mata: CalcSR2("`rho'", "`bmat'", "`varlist'")
	di
	di as txt "Goodness of Fit:"
    di as txt "----------------"
    qui corr `depv' `predy'
	local sqc=r(rho)*r(rho)
    di as txt "1) Squared Correlation: " as res `sqc'
    qui sum `depv'
    local var_obs=r(Var)
    qui sum `predy'
    local var_pred=r(Var)
	local vratio=`var_pred'/`var_obs'
    di as txt "2) Variance Ratio:     ", as res `vratio'
	return scalar sqcorr=`sqc'
	return scalar varRatio=`vratio'
end
version 10.1
mata:
void CalcSR2(string scalar brho, string scalar bvec, string scalar xvars) 
{
        rho=st_numscalar(brho) 
        real matrix B, C, xxs, invIRW
        xxs=st_data(., tokens(xvars))
        C=J(nc=rows(xxs),1,1)
        xxs=xxs,C
        fh = fopen(st_local("wmat"), "r") // Assuming weights matrix is from a Mata file
        w=fgetmatrix(fh)
        fclose(fh)
        nw=rows(w)
		invIRW=luinv(I(nw)-rho*w) 
        B=st_matrix(bvec)
        XB=xxs*B'
        ypred=invIRW*XB
        st_store(., st_addvar("double", st_local("predy")), ypred)
}
end
