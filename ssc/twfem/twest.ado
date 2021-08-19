capture program drop twest 
findfile twres.ado

include "`r(fn)'"
program define twest, eclass sortpreserve
    version 11
 
    syntax anything,  [,VCE(namelist)] 
	local absorb = "`e(absorb)'"

	qui{
	tempvar touse_reg
	gen byte `touse_reg'= e(sample)
	}
	
	*check if e() has not been rewritten
	capt confirm scalar e(dimN)
	if _rc { 
	   di "{err} The e() has been rewritten, please run twset again."
	   exit
	}
	
	*save the macros in scalars and arrays
	scalar dimN= e(dimN)
	scalar dimT= e(dimT)
	scalar rank_adj=e(rank_adj)
	capt confirm matrix e(invDD)
	if !_rc { 
		matrix invDD=e(invDD)
		matrix invHH=e(invHH)
		if (dimN<dimT){
			matrix CinvHHDH=e(CinvHHDH)
			matrix A= e(A)
			matrix B=e(B)
		}
		else {
			matrix AinvDDDH=e(AinvDDDH)
			matrix C= e(C)
			matrix B=e(B)
		}	
	}
	*take regtype to differentiate between estimation commands
	gettoken regtype varlist: anything
    
	if ("`regtype'"=="sureg"){
		capt assert inlist( "`vce'", "")
	if _rc { 
			di "{err} no vce option allowed"
			exit !_rc
	}
	*remove the comma and the nocons
	local anything= subinstr("`anything'",",", "",.)
	local anything= subinstr("`anything'","nocons", "",.)
	local anything= subinstr("`anything'","noc", "",.)
	
	*change the ")" for a ",nocons)"
	local anything= subinstr("`anything'",")", ",nocons)",.)
	local anything= stritrim("`anything'")
	qui{
		`anything' if `touse_reg', dfk2
	}	
	}
	else if("`regtype'"=="ivregress"){
	qui{
		`anything' if `touse_reg', small nocons vce(`vce')				
	}
	}
	else{
	qui{    
		`anything' if `touse_reg', nocons vce(`vce')
	}
	}

scalar nested_adj=0
gettoken cluster clustvar:vce
if ("`clustvar'"!=""){
	gettoken var1 var2: absorb
	cap assertnested `clustvar' `var1' 
	if !_rc {
			scalar nested_adj=dimN
	}
	cap assertnested `clustvar' `var2'
	if !_rc {
			scalar nested_adj=dimT + nested_adj
	}


}	
	
if ("`e(k_eq)'"==""){
	*standard errors robust to heteroscedasticity but assumes no correlation within group or serial correlation.
   qui{
	scalar df_r= e(N)-e(df_m)-1
	scalar df_r1= e(df_r)
	scalar vadj = df_r/(df_r- dimN - dimT+rank_adj+nested_adj)
	    }
 


	matrix b1=e(b)
	matrix V1 = vadj*e(V)
	eret repost b=b1 V=V1, esample(`touse_reg')
	ereturn scalar dof_adj=vadj
}

else{
local num 0
mat dofs= (1)
foreach x of local anything{
	if strpos("`x'" ,"("){
		foreach parns in x{
			local num= `num' + 1
			*standard errors robust to heteroscedasticity but assumes no correlation within group or serial correlation.
		   qui{
			scalar df_r`num'= e(N)-e(df_m`num')-1
			scalar vadj`num'= df_r`num'/(df_r`num'- dimN - dimT+rank_adj+nested_adj)
				}
		 

			matrix b1=e(b)
			local num_1= `num'-1
			local param= e(df_m`num')
			matrix dofs= (dofs \ J(`param',1,sqrt(vadj`num')))
			}
		}	
	}
	mat dofs = dofs[2...,1]
	*create the matrix of variance and covariances with the dof correction
	mat V0 = diag(dofs)
    mat V1=V0*e(V)*V0
	eret repost b=b1 V=V1, esample(`touse_reg')
	ereturn scalar df_r`num'= df_r`num'
	ereturn scalar dof_ad`num' =vadj`num'
}
	
  *Add the new arrays and scalars to the table of regression with standar errors with dof correction
  *macros 
  ereturn local absorb "`absorb'"
  ereturn scalar dimN= dimN
  ereturn scalar dimT= dimT
  ereturn scalar nested_adj=nested_adj
  ereturn scalar rank_adj=rank_adj
	capt confirm matrix invDD
	if !_rc { 
	  ereturn matrix invDD= invDD
	  ereturn matrix invHH= invHH
	  if (dimN<dimT){
		ereturn matrix CinvHHDH=CinvHHDH
		ereturn matrix A= A
		ereturn matrix B= B
	 }
	else {
		ereturn matrix AinvDDDH=AinvDDDH
		ereturn matrix C= C
		ereturn matrix B= B
	}
  }

 *table display
  `regtype'
	

   
end 
