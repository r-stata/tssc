*!relicoef version 1.0
*!Written 07Apr2015
*!Written by Mehmet Mehmetoglu
capture program drop relicoef
program relicoef
version 13.1
//set trace on
di ""	
	di in green "  Raykov's factor reliability coefficient"
	di as smcl as txt  "{c TLC}{hline 41}{c TRC}"
	di in yellow "  {bf:Factor}{dup 14: }{c |}{bf:    Coefficient} "
	di as smcl as txt  "{c BLC}{hline 41}{c BRC}"
    qui estat framework,fitted
			//return list
			mat Psi = r(Psi) 
			//mat list Psi 
			mat Phi = r(Phi) 
			//mat list Phi 
			mat Lambda = r(Gamma) 
			//mat list Lambda 
	  
	  /*takes the sum of columns in Lambda and create the L matrix*/
	  mat R = J(rowsof(Lambda),1,1)
	  //mat list R
	  mat L = R'*Lambda
	  //mat list L
			
	  local oyvarstripes : rowfullnames Lambda 
	  //di in yellow "`oyvarstripes'" 
	  local lxvarstripes : colfullnames Lambda 
	  //di in yellow "`lxvarstripes'"
	  local lxvars "`e(lxvars)'"
	  //di "`lxvars'"
	  local ncols = colsof(Psi) 
	  local nrows = rowsof(Psi) 
	  local ii=1
	  local w=1
	  
	 foreach construct of local lxvars {  
			local totevar=0  
            local totecov=0 
			
			/*sum of factor loadings*/
			tempname suml
			scalar `suml' = L[1, `ii'] 
			//di in green `suml' 
			
			/*sum of factor variances*/
			tempname varl
			scalar `varl' = Phi[`ii',`ii']
			//di in green `varl' 
			local ++ii	
			
			/*sum of error covariances*/
			forvalues j=1/`ncols' {
			local z =`j'+1
			forvalues q =`z'/`nrows' {
			if Lambda[`j',`w'] !=0 {
			local totecov = `totecov' + Psi[`q',`j']
			         }
			      }
		     	}
			local ++w
			
			local i = 1 
			/*sum of error variances*/
		foreach oyvar of local oyvarstripes {
			if Lambda[rownumb(Lambda, "`oyvar'") , colnumb(Lambda,"`construct'")] !=0 {  
			local totevar = `totevar' + Psi[`i', `i'] 
		        }
			local ++i
			    }
	        //di in yellow "total error variance: " `totevar'  
		    //di in white "total error covariace: " `totecov'
		    tempname recoef
		    scalar `recoef' = ((`suml'^2)*(`varl'))/(((`suml'^2)*(`varl'))+(`totevar')+(2*`totecov'))
		if `recoef' >= 0.7 {
			di in green "  " %-12s abbrev("`construct'",12) "{dup 8: }{c |}"%9.3f `recoef' "" 
				   }
			else {
			di in red "  " %-12s abbrev("`construct'",12) "{dup 8: }{c |}"%9.3f `recoef' "" 
				   }
				}
		 di as smcl as txt  "{c BLC}{hline 41}{c BRC}"
	     di in green "  Note: We seek coefficients >= 0.7"
end






