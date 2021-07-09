// Copyright 2009 Johannes Schmieder
// Program: gpreg
// Version: 0.9.1  (May 2009)
// NOTE:  This program is distributed under the GNU GPL.
// See end of this file and http://www.gnu.org/licenses/ for details.
// Please report errors to jfs2106 /at/ columbia.edu
 
/*---------------------------------------------------------*/
/* Guimaraes & Portugal Algorithm implemented in Mata */
/* Author: Johannes Schmieder */
/*---------------------------------------------------------*/
capture program drop gpreg 
program define gpreg, eclass 
	version 10.1
	syntax varlist [if] [in], Ivar(varname) Jvar(varname)  ///
		 [tolerance(str) maxiter(integer 0) Algorithm(integer 1) ///
		 NODOTS ife(str) jfe(str) ]
	tokenize `varlist'

	if `"`ife'"'!=`""' confirm new var `ife' 
	if `"`jfe'"'!=`""' confirm new var `jfe'
	cap assert inlist(`algorithm',1,2,3,4)
	if _rc {
		di in red "`algorithm' is an invalid argument for algorithm()"
		di in red "Available options for algorithm are: 1, 2, 3, and 4"
		error 198
	}
	
	tempvar touse
	tempname b V
	mark `touse' `if' `in'
	markout `touse' `*' `ivar' `jvar'

	di in ye "======================================="
	di in ye "Twoway Fixed Effects Estimation: gpreg" 
	if "`tolerance'"=="" local tolerance = epsfloat() // epsdouble()
*	local tolerance = `tolerance'
	local lhs `1'
	mac shift
	local rhs `*'
	unab rhs: `rhs'	
	
	tempvar uniqueid 
	g `uniqueid' = _n
	
	preserve
	qui keep if `touse'
	tempvar m
	
	sort `ivar'
	foreach var in `varlist' {
		by `ivar': g double `m' = sum(`var')/_n // Paulo's suggestion
		qui by `ivar': replace `m' = `m'[_N]
		//	egen double `m' = mean(`var'), by(`ivar') 
		tempvar __`var'
		g double `__`var'' = `var' - `m'
		drop `m'
		// This expression is needed to predict the residuals after the regression
		if "`var'"!="`lhs'" local gdumexp `gdumexp' - _b[`var'] * `__`var'' 
	}	
	
	di in ye "Tolerance Level for Iterations: `tolerance'"
	
	local dots `=cond("`nodots'"=="",1,0)'
	
	// This uses about 4 times the memory of the data used in the regression.
	if `algorithm'==1{ 
		di in ye "Transforming all variables simultaneously"
		foreach var of varlist `varlist' {
			qui recast double `var'
		}		
		mata: gpregm("`varlist'","`ivar'","`jvar'","`uniqueid'","`touse'",`tolerance',`maxiter',`dots',"")
		if `iter'==`maxiter' {
			di in red "Algorithm did not converge in `maxiter' iterations"
			di in red "Last improvement: `dif'"
			error 666
		}		
		di in yellow "Converged after `iter' Iterations"
	}
	// This uses about 4 more variables worth of memory
	if `algorithm'==2 { 
		foreach var of varlist `varlist' {
			di in ye "Transforming variable: `var'"
			recast double `var'
			mata: gpregm("`var'","`ivar'","`jvar'","`uniqueid'","`touse'",`tolerance',`maxiter',`dots',"") 
			if `iter'==`maxiter' {
				di in red "Algorithm did not converge for variable `var'"
				di in red "Last improvement: `dif'"
				error 666
			}			
			di in yellow "Variable `var' converged after `iter' Iterations"
			
		}			
	}	
	// This part closely follows G&P's program
	if `algorithm'==3 {
		foreach var of varlist `varlist' {
			di in ye "Transforming variable: `var'"
			recast double `var'
			tempvar temp fe2 lastfe2 mean
			gen double `temp'=0
			gen double `fe2'=0
			gen double `lastfe2'=0
			local iter=1
			local dif=1
			capture drop `mean'
			sort `ivar'
			by `ivar': g double `mean' = sum(`var')/_n // Paulo/Gould suggestion
			qui by `ivar': replace `var' = `var' - `mean'[_N]
			g double __`var' = `var'	
					
			while abs(`dif')>`tolerance' & `iter'!=`maxiter'{
				qui replace `lastfe2'=`fe2', nopromote
				capture drop `mean'
				sort `ivar'
				by `ivar': g double `mean' = sum(`fe2')/_n
				qui by `ivar': replace `mean' = `mean'[_N]				
				capture drop `fe2'
				sort `jvar'
				by `jvar': g double `fe2' = sum(`var'+`mean')/_n 
				qui by `jvar': replace `fe2' = `fe2'[_N]								
				qui replace `temp'=sum(reldif(`fe2',`lastfe2')), nopromote
				local dif=`temp'[_N]/_N
				if `dots' {
					if `iter'==1 {
						_dots 0, title(Iterations for gpreg) reps(`maxiter')
					}
					_dots `iter' 0
				}				
				local iter=`iter'+1
			}
			qui replace `var' = `var' - `fe2' + `mean'
					
			if `iter'==`maxiter' {
				di in red "Algorithm did not converge for variable `var'"
				di in red "Last improvement: `dif'"
				error 666
			}			
			di in yellow "Variable `var' converged after `iter' Iterations"
			
		}			
	}
	// Similar to algorithm above, but attempts to speed up convergence
	// this algorithm was contributed by Paulo Guimaraes
	if `algorithm'==4 {
		foreach var of varlist `varlist' {
			di in ye "Transforming variable: `var'"
			recast double `var'
			tempvar temp fe2 dif1 dif0 old0 old1 mean
			gen double `temp'=0
			gen double `fe2'=0
			gen double `old1'=0
			gen double `old0'=0
			local iter=1
			local dif=1
            local cond1 "(`fe2'>`old1'&`old1'>`old0'&((`fe2'+`old0')<(2*`old1')))"
            local cond2 "(`fe2'<`old1'&`old1'<`old0'&((`fe2'+`old0')>(2*`old1')))"
            capture drop `mean'
			sort `ivar'
			by `ivar': g double `mean' = sum(`var')/_n
			qui by `ivar': replace `var' = `var' - `mean'[_N]
			g double __`var' = `var'	
			while abs(`dif')>`tolerance' & `iter'!=`maxiter'{
    			capture drop `mean'
				sort `ivar'
				by `ivar': g double `mean' = sum(`fe2')/_n
				qui by `ivar': replace `mean' = `mean'[_N]				
                capture drop `old0'
                rename `old1' `old0'
				rename `fe2' `old1'
                sort `jvar'
				by `jvar': g double `fe2' = sum(`var'+`mean')/_n 
				qui by `jvar': replace `fe2' = `fe2'[_N]
                if `iter'>3 {								
                qui replace `fe2'=`fe2'+(`fe2'-`old1')^2/(`old1'-`old0') if `cond1'|`cond2', nopromote 
    		    }
            	qui replace `temp'=sum(reldif(`fe2',`old1')), nopromote
				local dif=`temp'[_N]/_N
				if `dots' {
					if `iter'==1 {
						_dots 0, title(Iterations for gpreg) reps(`maxiter')
					}
					_dots `iter' 0
				}				
				local iter=`iter'+1
			}
			qui replace `var' = `var' - `fe2' + `mean'
					
			if `iter'==`maxiter' {
				di in red "Algorithm did not converge for variable `var'"
				di in red "Last improvement: `dif'"
				error 666
			}			
			di in yellow "Variable `var' converged after `iter' Iterations"
			
		}			
	}

	// Calculate Degrees of Freedom	
	qui count if `touse'
	local N = r(N)
	local k : word count `rhs'
	sort `touse' `ivar'
	qui count if `ivar'!=`ivar'[_n-1] & `touse'
	local G1 = r(N)
	sort `touse' `jvar'
	qui count if `jvar'!=`jvar'[_n-1] & `touse'
	local G2 = r(N)
	tempvar group
	qui __makegps, id1(`ivar') id2(`jvar') groupid(`group')
	sort `touse' `group'
	qui count if `group'!=`group'[_n-1] & `touse'
	local M = r(N)	
	local dof = `N' - `k' - `G1' - `G2' + `M'	
	di in ye "Degrees of Freedom: `dof'"
	
	// Estimate Regression		
	_regress `lhs' `rhs' if `touse', nocons dof(`dof') 
	ereturn scalar iter = `iter'
	ereturn scalar Mgroups = `M'
	di

	if `"`ife'"'!=`""' & `"`jfe'"'!=`""' { 
		di in ye "Calculating Fixed Effects"
		// Compute Fixed Effect associated with Jvar group
		tempvar temp lastfe2 dum
		g double `temp'=0
		g double `lastfe2'=0
		g double `dum' = `__`lhs'' `gdumexp'
		mata: gpregm("`dum'","`ivar'","`jvar'","`uniqueid'","`touse'",`tolerance',`maxiter',`dots',"`jfe'")
		if `iter'==`maxiter' {
			di in red "Algorithm to calculate fixed effects did not converge for variable `var'"
			di in red "Last improvement: `dif'"
			error 666
		}			
		
		// Restore Dataset saving Jvar-Fixed Effect
		tempfile file
		keep `ivar' `jvar' `uniqueid' `jfe'
		qui save `file'	
		restore
		merge `ivar' `jvar' `uniqueid'  using `file', sort
		drop _merge `uniqueid'

		// Calculate the Fixed Effect associated with Ivar group
		predict `dum' if `touse', res
		qui replace `dum' = `dum' - `jfe' if `touse'
		
		sort `touse' `ivar' 
		by `touse' `ivar': g double `ife' = sum(`dum')/_n if `touse' // Paulo's suggestion
		qui by `touse' `ivar': replace `ife' = `ife'[_N] if `touse'
		
	// 	egen double `ife' = mean(`dum') if `touse', by(`ivar')

		qui sum `ife' if `touse'
		ereturn scalar sd_1 = r(sd)
		qui sum `jfe' if `touse'
		ereturn scalar sd_2 = r(sd)
		qui corr `ife' `jfe' if `touse'
		ereturn scalar rho = r(rho)			
	}
	di
		
end // gpreg

version 10.1
mata
	void gpregm(string scalar vars, string scalar ivar, string scalar jvar, string scalar uniqueid, 
		string scalar touse, real scalar tolerance, real scalar maxiter, real scalar dots,  string scalar fe2var) {
		
		dif = 1
		iter = 1
		
		V=st_data(.,(ivar,jvar,uniqueid,tokens(vars)),touse)
		Nvar = cols(tokens(vars))			
		Nobs = rows(V)	

		V = V,J(Nobs,Nvar,0),J(Nobs,Nvar,0),J(Nobs,Nvar,0) // IDs, Variables, Fe2, Lastfe2, Mean
		var     = (3+1     , 3+Nvar)
		fe2     = (3+Nvar+1, 3+2*Nvar)
		lastfe2 = (3+2*Nvar+1, 3+3*Nvar)
		mean    = (3+3*Nvar+1, 3+4*Nvar)

		V       = sort(V,(2,3))
		infoj = panelsetup(V,2)							
	
		// Demean All Variables by i category
		V       = sort(V,(1,3))
		infoi = panelsetup(V,1)			
		
		for (i=1; i<=rows(infoi); i++) { 
			V[|infoi[i,1],var[1] \ infoi[i,2],var[2]|] = 
				V[|infoi[i,1],var[1] \ infoi[i,2],var[2]|]  - 
				 (mean(V[|infoi[i,1],var[1] \ infoi[i,2],var[2]|])) :*
					J(infoi[i,2]-infoi[i,1]+1,Nvar,1) 
		}

		// Substract Category Means Until Convergence
		while (abs(dif)>tolerance) {			
			V[|1,lastfe2[1] \ .,lastfe2[2] |] = V[|1,fe2[1] \ .,fe2[2] |] // Save last Set of FE
			
			V       = sort(V,(1,3))
// 			infoi = panelsetup(V,1)		
			for (i=1; i<=rows(infoi); i++) { 
				V[|infoi[i,1],mean[1] \ infoi[i,2],mean[2]|] = 	
					(mean(V[|infoi[i,1],fe2[1] \ infoi[i,2],fe2[2]|])) :*
						J(infoi[i,2]-infoi[i,1]+1,Nvar,1) 
			}
			
			V       = sort(V,(2,3))
// 			infoj = panelsetup(V,2)							
			for (i=1; i<=rows(infoj); i++) { 
				V[|infoj[i,1],fe2[1] \ infoj[i,2],fe2[2]|] = 	
					(mean(V[|infoj[i,1],var[1] \ infoj[i,2],var[2]|] + V[|infoj[i,1],mean[1] \ infoj[i,2],mean[2]|])) :*
						J(infoj[i,2]-infoj[i,1]+1,Nvar,1) 
			}
	
			
			dif = colsum(reldif(V[|1,fe2[1] \ .,fe2[2] |],V[|1,lastfe2[1] \ .,lastfe2[2] |])) / Nobs
			dif = sum(abs(dif))
						
			if (dots==1) {
				if (iter==1) {
					stata("_dots 0, title(Iterations for gpreg) reps("+strofreal(maxiter)+") ")
				}
				stata("_dots "+strofreal(iter)+" 0")
			}
			iter = iter+1
			if (maxiter>0 & iter>=maxiter) dif = 0	
		}

		V       = sort(V,(1,3))
		if (fe2var=="") V[|1,var[1] \ .,var[2]|] = V[|1,var[1] \ .,var[2]|] - V[|1,fe2[1] \ .,fe2[2] |] + V[|1,mean[1] \ .,mean[2] |]
		if (fe2var!="") V[|1,var[1] \ .,var[2]|] = V[|1,var[1] \ .,var[2]|] - V[|1,fe2[1] \ .,fe2[2] |] 
		
		
	st_store(.,st_varindex(tokens(vars)),V[|1,var[1] \ .,var[2]|])
	
	st_local("iter",strofreal(iter))
	st_local("dif",strofreal(dif))
	if (fe2var!="") {
		ids = st_addvar("double", fe2var)
		st_store(.,ids,V[|1,fe2[1] \ .,fe2[1] |])
	}
	}

end	// mata

/* This routine is taken from Amine Quazad's a2reg program */
/* It establishes the connected groups in the data */

#delimit ;
*Find connected groups for normalization;
capture program drop __makegps;
program define __makegps;
 version 9.2;
 syntax [if] [in], id1(varname) id2(varname) groupid(name);

 marksample touse;
 markout `touse' `id1' `id2';
 confirm new variable `groupid';

 sort `id1' `id2';
 preserve;

   *Work with a subset of the data consisting of all id1-id2 combinations;
    keep if `touse';
    collapse (sum) `touse', by(`id1' `id2');
    sort `id1' `id2';
   *Start by assigning the first id1 value to group 1, then iterate to fill this out;
    tempvar group newgroup1 newgroup2;
    gen `group'=`id1';
    local finished=0;
    local iter=1;
    while `finished'==0 {;
     	quietly {;
       bysort `id2': egen `newgroup1'=min(`group');
       bysort `id1': egen `newgroup2'=min(`newgroup1');
       qui count if `newgroup2'~=`group';
       local nchange=r(N);
       local finished=(`nchange'==0);
       replace `group'=`newgroup2';
       drop `newgroup1' `newgroup2';
       };
      di in yellow "On iteration `iter', changed `nchange' assignments";
      local iter=`iter'+1;
      };
    sort `group' `id1' `id2';
    tempvar nobs complement;
    by `group': egen `nobs'=sum(`touse');
    replace `nobs'= -1*`nobs';
    egen `groupid'=group(`nobs' `group');
    keep `id1' `id2' `groupid';
    sort `id1' `id2';
    tempfile gps;
    save `gps';

    restore;
    tempvar mrg2group;
    merge `id1' `id2' using `gps', uniqusing _merge(`mrg2group');
    assert `mrg2group'~=2;
    assert `groupid'<. if `mrg2group'==3;
    assert `groupid'==. if `mrg2group'==1;
    drop `mrg2group';
end;
#delimit  

/*
This program and all programs referenced in it are free software. You
can redistribute the program or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
USA.
*/
