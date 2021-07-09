
program krls, eclass
        version 11

		if replay() {
			if ("`e(cmd)'"!="krls") error 301
			mata: m_krls_display()
			exit
		}
		
        syntax varlist(min=2 ts fv) [if] [in] [, Deriv(string) ///
                        SDERIV(string) ///
                        Vcov ///
                        SVCOV(string) ///
                        Keep(string) ///
                        Graph ///
                        Suppress /// 
                        LTolerance(numlist max=1 > 0) ///
                        Sigma(numlist max=1 > 0) ///
                        Quantile(numlist max=3 > 0 < 1) ///
                        LOWERbound(numlist max=1 >= 0) ///
                        Lambda(numlist max=1 > 0)] [DOUBLE] 
        
        // Handle Factor Variables and clean varlist
        local fvops = "`s(fvops)'" == "true" 
        local commandline `varlist'
        
        local depvar: word 1 of `varlist'
           
        if `fvops' { 
        		local indvar: list varlist - depvar
                local vv: di "version " ///
                string(max(11,_caller())) ", missing: " 
                _fv_check_depvar `depvar' 
                
                qui: _rmcoll `varlist', expand  // Cache original names  
                local expandedvarlist `r(varlist)'
                local expandedvarlist: list expandedvarlist - 1
       			ereturn local expandedvarlist "`expandedvarlist'"
       			
                // Prohibit interactions
                foreach var of local originalvarlist  {
                	capture: _ms_parse_parts `var'
                	 if (_rc == 0){
                	 	if ("`r(type)'" == "interaction"){
                	 		 display as error "Interactions not permitted"
                       		 exit 198
                		}
                	}
                }
                fvrevar `varlist'
                local varlist = "`r(varlist)'"
        } 
        else {  
       		foreach i of local varlist {
                	quietly summ `i'
                	if `r(Var)' == 0 {
                        	display as error "All variables must vary"
                        	exit 198
                	}       
        	}
        }
                        
        local regs: list varlist - depvar
        
        // Create two markers; one is erased after setting esample
        marksample touse
        marksample touse2

        qui: _rmcoll `regs' if `touse', forcedrop
        local regs `r(varlist)'

        quietly count if `touse'
        if `r(N)' == 0 error 2000

        // Set option indicators
        if ("`sigma'"=="") local sigma = 0
        if ("`lambda'"=="") local lambda = 0
        if ("`suppress'" != ""){
                 local suppress = "suppress"
                 local deriv = ""
        } 
        else {
                if ("`graph'" != "" & "`deriv'" == "")  local deriv = "deriv"
                if ("`sderiv'" != "" & "`deriv'" == "") local deriv = "deriv"
        }       
        
        if ("`ltolerance'"=="") local ltolerance = 0
        if ("`lowerbound'"=="") local lowerbound = -1   
        if ("`svcov'" != "") local vcov = "vcov"'
		
        // Set initial ereturn values; subsequently mata will repost directly to e()
        tempname b 
        local n_regs : word count `regs'
        mat `b' = J(1,`n_regs',1) 	// placeholder  
        local coeff_col `regs' // Set colnames of e(b) here, not allowed in Mata        
        if (`fvops') qui mata: m_krls_variablelist(1)
        	else local coeff_col `regs'
        mat colnames `b' = `coeff_col'  
        ereturn post `b', esample(`touse')
       
        ereturn local predict "krls_p"
 		ereturn local cmdconstraint "`if'"
 		if (`fvops'){
 			ereturn local indvar "`indvar'"
 			ereturn local expandedvarlist "`expandedvarlist'"
 		}
 		else {	
 			ereturn local indvar "`regs'" 
 		}	
        ereturn local depvar "`depvar'"
        ereturn local cmd "krls"

		// Ensure sort compatibility with krls_p
		tempvar originalsort
		gen `originalsort' = _n
		sort `depvar' 
		        
        // Pass to mata
        mata: m_krls("`depvar'", "`regs'", "`touse2'",`ltolerance',`lowerbound',`sigma', `lambda',"`deriv'","`vcov'","`suppress'","`quantile'")

		// restore original sort
		sort `originalsort'
		
 	    // Write file with varcov_y if specified
        if ("`svcov'" != ""){
                preserve
                mat Vcov_y = e(Vcov_y)
                svmat Vcov_y, names("varcov")
                mat drop Vcov_y
                keep varcov*
                save "`svcov'.dta", replace
                restore
        }
        
        // Results
		if ("`suppress'" == ""){
        		mata: m_krls_display()  
        		
                // Write file with derivatives if specified
                if ("`sderiv'" != ""){
                        preserve
                        keep `deriv'_*
                        save "`sderiv'.dta", replace
                        restore
                }
        
                // Graph
                if ("`graph'" != ""){
                        graph drop _all
                        foreach x of local coeff_col{
                        	hist `deriv'_`x', name(`deriv'_`x')  percent  scheme(s2mono) title("Pointwise Derivatives") 
                        }       
                }

                // Keep
                if ("`keep'" != "" ){
                        preserve
                        drop _all   
                        qui gen x = ""  
                
                        local rowcount = 0
                        foreach x of local regs{
                                local rowcount = `rowcount' + 1
                                qui set obs `rowcount'
                                qui replace x = "`x'" if _n == `rowcount'
                        }       
                        mat krlso = e(Output)
                        svmat krlso 
                        rename krlso1 avgderiv
                        rename krlso2 se
                        rename krlso3 t
                        rename krlso4 p
                
                        if ("`quantile'"==""){
                                rename krlso5 p25
                                rename krlso6 p50
                                rename krlso7 p75
                        }

                        qui gen n = "`e(n)'"
                        qui gen lambda = "`e(lambda)'"
                        qui gen tolerance  = "`e(tolerance)'"
                        qui gen sigma = "`e(sigma)'"
                        qui gen looloss = "`e(Looloss)'"
                        qui gen Eff_df =  "`e(Effective_df)'"
                        qui gen R2 = "`e(R2)'"
                
                        di ""
                        save "`keep'", replace
                        restore
                }
        }
end

version 11
mata:
mata set matastrict on
mata set matafavor speed
                      
                           
struct krls_struct {
        real scalar lambda      
        real scalar ltolerance  
        real scalar binarycol 
        real scalar sigma       
        real scalar lowerbound
        real matrix EVec        
        real matrix EVal        
        real matrix Sdy         
        real matrix SY         
        real matrix SX
        real matrix SX2
} 

function krls_struct_init(){
        struct krls_struct scalar k
        k.ltolerance = 0
        return(k)
}

// Evaluate Loo-loss
real scalar eval_opt(lambda, struct krls_struct scalar KRLS_S){
        real matrix Ginv, C
        Ginv = cross(KRLS_S.EVec,((KRLS_S.EVal :+ lambda) :^-1),KRLS_S.EVec) 
        C = cross(Ginv,KRLS_S.SY) :/ diagonal(Ginv)
        return(cross(C,C))      
}

// Fetch readable variable names with factor support
string scalar m_krls_variablelist(real scalar statacall){
		real scalar i
		string scalar indvars, indvarstemp

     	// Check for factor variables and replace temporary names
     	if (st_global("e(expandedvarlist)")!=""){

     		// Original call
     		indvars = st_global("e(expandedvarlist)")
     		// Trim off reference category
     		indvarstemp = ""
     		for (i=1; i<= cols(tokens(indvars)); i++){
				if (strpos(tokens(indvars)[i],"b.") == 0){
					indvarstemp =  indvarstemp + " " + tokens(indvars)[i] 
				}
			}
     		indvars = indvarstemp
     	} else {
     		indvars = st_global("e(indvar)")
     	}
     	
     	if (statacall == 1){
     		st_local("coeff_col",subinstr(indvars,".",""))
     	}
     	return(indvars)
}


// Custom Display Table - draws from e()
void m_krls_display(){
        real scalar tablelength, tablelength2, i, j, l
     	string scalar marker, indvars
     	
     	indvars = m_krls_variablelist(.)
		
        // Determine the width of the table
        tablelength =  strlen(substr(st_global("e(depvar)"),1,30))
        for (i=1; i<= cols(st_matrix("e(b)")); i++){
                tablelength2 = strlen(substr(tokens(indvars)[i],1,30)) + 1
                if (tablelength2 > tablelength){
                        tablelength = tablelength2
                }
        }          

        printf("\n")
        printf("{txt}Pointwise Derivatives")
        printf("{txt}{space %2.0f} ",24 + tablelength)
        printf ("Number of obs = {res}%8.0g \n",st_numscalar("e(n)"))
        printf("{txt}{space %2.0f} ", 45 + tablelength)
        printf("Lambda {space 6} = {res}%8.4g \n",st_numscalar("e(lambda)"))
        printf("{txt}{space %2.0f} ", 45 + tablelength)
        printf("Tolerance {space 3} = {res}%8.4g \n",st_numscalar("e(tolerance)"))      
        printf("{txt}{space %2.0f} ", 45 + tablelength)
        printf("Sigma {space 6}  = {res}%8.4g \n",st_numscalar("e(sigma)"))
        printf("{txt}{space %2.0f} ", 45 + tablelength)
        printf("Eff. df {space 4}  = {res}%8.4g \n",st_numscalar("e(Effective_df)"))
        printf("{txt}{space %2.0f} ", 45 + tablelength)
        printf("R2 {space 11}= {res}%8.4g \n",st_numscalar("e(R2)"))
        printf("{txt}{space %2.0f} ", 45 + tablelength)
        printf("Looloss {space 6}= {res}%8.4g",st_numscalar("e(Looloss)"))              
        printf("\n\n")
        printf("{txt}{space %2.0f}", tablelength - strlen(substr(st_global("e(depvar)"),1,30)))
        printf("%s {c |}      Avg.{space 7}SE{space 8}t{space 4}P>|t|{space 8}", substr(st_global("e(depvar)"),1,30))
	
		for (i=5; i<=cols(st_matrix("e(Output)")); i++){ 
          	 printf("P%2.0f{space 7}",strtoreal(substr(st_matrixcolstripe("e(Output)")'[2,i],2)))
      	}	
		
        printf("\n{hline %2.0f}{c +}{hline 68}\n",tablelength + 1)
       
      	// Print results, indicating binary variables
        for (i=1; i<= cols(st_matrix("e(b)")); i++){
        	 l = 0
        	 marker = ""
        	 if (st_matrix("r(Binarycols)")[i] == 1){ 
        	 	l = 1
        	 	marker = "*"
        	 }      
        	
       		 printf("{space %2.0f}", tablelength - strlen(substr(tokens(indvars)[i],1,30)) - l)
       	     printf("{txt}%s {c |} ", marker + substr(tokens(indvars)[i],1,30-l))
             printf("{res}%8.0g {space 1}", st_matrix("e(Output)")[i,1])
             printf("{res}%8.0g", st_matrix("e(Output)")[i,2])
             printf("{res}%9.3f", st_matrix("e(Output)")[i,3])
             printf("{res}%9.3f {space 1} ", st_matrix("e(Output)")[i,4])  
             
             for (j=5; j<=cols(st_matrix("e(Output)")); j++){ 
                   printf("{res}%8.0g {space 1}", st_matrix("e(Output)")[i,j])
             }
             printf("\n")
                                                        
        }                                               
        printf("{txt}{hline %2.0f}{c +}{hline 68}\n",tablelength + 1)
        
        if (l > 0){
       		 printf("* average dy/dx is the first difference using the min and max (i.e. usually 0 to 1)")
        }
        
        printf("\n")    
}

// Optimization function
void m_goldensection_recursivecache(L, U, s1, s2, iteration, itcap,passeval,passtype,opasseval,noisy, struct krls_struct scalar KRLS_S){
  real scalar s1eval, s2eval


 if (iteration ==1){
        s1 = L + (.381966)*(U-L)
        s2 = U - (.381966)*(U-L)
        s1eval = eval_opt(s1,KRLS_S)
        s2eval = eval_opt(s2,KRLS_S)
 } else {
        if (noisy == 1){
                printf("{txt}Iteration = %2.0f,",iteration - 1)
                printf(" Looloss: %-9.0g \n",opasseval * KRLS_S.Sdy)
        }
                        
         // Caching
         if (passtype ==1){
                s2eval = passeval
                s1eval = eval_opt(s1,KRLS_S)
         } else {
                s2eval = eval_opt(s2,KRLS_S)
                s1eval = passeval
         }
}  
        iteration++

        // Loop termination criteria
        if (abs(s1eval - s2eval) <= KRLS_S.ltolerance || iteration == itcap){   
                if (s1eval < s2eval){
                        KRLS_S.lambda = s1
                } else {
                        KRLS_S.lambda = s2
                }
        } else {
                // Next step
                if (s1eval < s2eval){
                        U = s2
                        s2 = s1
                        s1 = L + (.381966)*(U-L)
                        m_goldensection_recursivecache(L, U, s1, s2, iteration,itcap,s1eval,1,s2eval,noisy,KRLS_S)
                } else {
                        L = s1
                        s1 = s2
                        s2 = U - (.381966)*(U-L)
                        m_goldensection_recursivecache(L, U, s1, s2, iteration,itcap,s2eval,2,s1eval,noisy,KRLS_S)
                } 
        }
}

// Main KRLS function
void m_krls(string scalar yname, ///
                string scalar xname, ///
                string scalar touse, ///
                real scalar utolerance, ///
                real scalar lowerbound, ///            
                real scalar usigma, ///
                real scalar ulambda, ///
                string scalar deriv, ///
                string scalar vcov, ///
                string scalar noderiv, ///
                string scalar quantile)
                {
                        real matrix KM, Xmv,Ymv,Coeffs,Ginv,Vcovmc,Rw,Binary, ///
                                L,Drvmat,VarAvgDvm,Avgdrv,Sdx,Mediandrv, T, Ytemp, Contrast, OutputRow, OutputM, pYfit
                        real scalar n,d,i,j, binarycount
                        string scalar colList

                        // Initiate structure
                        struct krls_struct scalar KRLS_S 
                        KRLS_S = krls_struct_init()
                        
                        // Set defaults
                        KRLS_S.sigma = usigma 
                        KRLS_S.SY = st_data(.,  tokens(yname), touse)
                        KRLS_S.SX = st_data(.,  tokens(xname), touse)
            
                        n = rows(KRLS_S.SX)
                        d = cols(KRLS_S.SX)
                     
                        // Determine which columns in X are binary
                        binarycount = 0;
                        Binary = J(1,d,.)
                        for (i=1; i<=d; i++){
                                        colList = colList + " " + strofreal(i)
                                if (rows(uniqrows(KRLS_S.SX[.,i])) == 2){
                                        Binary[i] = 1
                                        binarycount++
                                } else {
                                        Binary[i] = 0
                                }
                        }       
                    
                        st_matrix("r(Binarycols)",Binary) // Cache binary for display table rerun
                        
                        if (binarycount > 0){
                                KRLS_S.SX2 = KRLS_S.SX
                        }
                                
                // Rescale      
                        Xmv = quadmeanvariance(KRLS_S.SX)
                        Sdx = sqrt(diagonal(Xmv[|2,1 \ .,.|])')
                        KRLS_S.SX[ ., . ] = (KRLS_S.SX :- Xmv[1,.]) :/ Sdx
                        Ymv = quadmeanvariance(KRLS_S.SY)
                        KRLS_S.Sdy =  sqrt(diagonal(Ymv[|2,1 \ .,.|]))
                        KRLS_S.SY[ ., . ] = (KRLS_S.SY :- Ymv[1,.]) :/ KRLS_S.Sdy
                
                // Find lambda
                        if (KRLS_S.sigma == 0) KRLS_S.sigma = d
                
                        // Construct kernel matrix KM
                        KM=exp((-1*m_euclidian_distance(KRLS_S.SX,n,d):^2)/KRLS_S.sigma)

                        // Eigen
                        symeigensystem(KM,KRLS_S.EVec=.,KRLS_S.EVal=.)
                        KRLS_S.EVec = KRLS_S.EVec'

                        // Determine optimal value of lambda if not supplied and solve
                        if (ulambda == 0){
                                real scalar h, k, q, l
                                KRLS_S.ltolerance = utolerance

                                if (KRLS_S.ltolerance == 0){
                                        // Not User specified
                                        if (n < 5000){
                                                KRLS_S.ltolerance = 10^-3 * n
                                        } else {
                                                KRLS_S.ltolerance = 1.25 * (10^-3 * n)
                                        }
                                }       
                                
                        // Golden Section Search
                                // Upper bound
                                h = n
                                q = 1
                                while (q > 0){
                                        if (sum(KRLS_S.EVal :/ (KRLS_S.EVal :+ h)) < 1){
                                                h--
                                        } else {
                                                q=0 
                                        }
                                }               
                                        
                                // Select Lower bound if not provided
                                if (lowerbound == -1){
                                        
                                        l = max(KRLS_S.EVal) / 1000
                                        k = length(KRLS_S.EVal)
                                        q = 1

                                        while (q > 0){
                                                if (KRLS_S.EVal[k] < l){
                                                        k --
                                                } else {
                                                        q = 0
                                                }
                                        }               
                                        lowerbound = 0
                                        q = 1
                                        
                                        while (q >0){
                                                if (sum(KRLS_S.EVal :/ (KRLS_S.EVal :+ lowerbound)) > k){
                                                        lowerbound = lowerbound +.05    
                                                } else {
                                                        q=0
                                                }
                                        }               
                                }
                                KRLS_S.lowerbound = lowerbound
                                // Kick off optimization
                                m_goldensection_recursivecache(lowerbound,h,NULL,NULL,1,50,0,NULL,10,1,KRLS_S)                      
                        } else {
                                KRLS_S.lambda = ulambda
                        }
               
                // Solve with optimal lambda
                        Ginv = cross(KRLS_S.EVec,((KRLS_S.EVal :+ KRLS_S.lambda) :^-1),KRLS_S.EVec) 
                        Coeffs = cross(Ginv,KRLS_S.SY) 
                        Rw = Coeffs :/ diagonal(Ginv)
                        Ginv = 0
                        Ytemp = KRLS_S.SY-cross(KM,Coeffs)
                        Vcovmc = cross(KRLS_S.EVec,((KRLS_S.EVal :+ KRLS_S.lambda):^-2),KRLS_S.EVec) * cross(Ytemp,(1/n),Ytemp)

                        // Save fitted vcov if specified        
                        if (vcov == "vcov"){
                                // Save some memory if not specified
                                real matrix Vcovfit 
                                Vcovfit = KRLS_S.Sdy^2 * cross(KM,Vcovmc*KM)
                                st_matrix("e(Vcov_y)",Vcovfit) 
                                Vcovfit=0
                        } 
                        st_matrix("e(Vcov_c)",KRLS_S.Sdy^2  * Vcovmc)
                      
                // Derivatives
                        if (noderiv == ""){
                                Drvmat = J(n,d,.)
                                VarAvgDvm = J(1,d,.)

                                for (i=1; i<=d; i++){
                                        L = m_distance(KRLS_S.SX[,i],n) :*KM
                                        Drvmat[,i]= cross(L',(-2/KRLS_S.sigma),Coeffs)
                                        VarAvgDvm[1,i] = (1/n^2) * sum(cross(L,(-2/KRLS_S.sigma)^2,Vcovmc*L))      
                                }
                        }    
                        L = 0
  
                 // Rescale and return results
                        if (noderiv == ""){

                                real scalar dq
                                real matrix UQuantile
                                
                                dq = cols(tokens(quantile))
                                if (dq > 0){
                                        UQuantile = J(dq,1,.)
                                        for (i=1; i<=dq; i++){ 
                                                UQuantile[i] =  strtoreal(tokens(quantile)[i])
                                        }
                                } else {
                                        UQuantile = (0.25 \ 0.5 \ 0.75)
                                }
  
                                Drvmat = Drvmat :* KRLS_S.Sdy :/ Sdx
                                Mediandrv = mms_quantile(Drvmat, UQuantile)
                                Avgdrv = colsum(Drvmat) :/ n
                                VarAvgDvm = VarAvgDvm :* ((KRLS_S.Sdy :/ Sdx):^2)
                        }
  
                // Post to e()
                        st_numscalar("e(Looloss)", cross(Rw, Rw) * KRLS_S.Sdy)
                        st_numscalar("e(lambda)",KRLS_S.lambda)
                        st_numscalar("e(R2)",1 - (variance(((Ytemp) * KRLS_S.Sdy) :+ Ymv[1,.]) / KRLS_S.Sdy^2 ))
                        st_numscalar("e(sigma)",KRLS_S.sigma)
                        st_numscalar("e(Effective_df)",sum(KRLS_S.EVal :/ (KRLS_S.EVal :+ KRLS_S.lambda)))
                        st_numscalar("e(tolerance)",KRLS_S.ltolerance)
                        st_numscalar("e(lowerbound)",KRLS_S.lowerbound)
                        st_numscalar("e(n)",n)

                        // Used by predict function: krls_p
                        st_numscalar("e(sdy)",KRLS_S.Sdy)  // cached
                        st_numscalar("e(meany)",Ymv[1,.]) // 
                        st_matrix("e(Coeffs)",Coeffs)  // to predict fitted values
                        st_matrix("e(meanx)",Xmv[1,.]) // 

 				// Generate Output 
                        if (noderiv == ""){
                                            
                        Contrast = .
                        OutputM = .
                        
                        for (i=1; i<= d; i++){
                        
                                if (Binary[i] != 1){
                                		// Non Binary Output Row
                                        OutputRow = Avgdrv[i],  sqrt(VarAvgDvm[i]), Avgdrv[i]/sqrt(VarAvgDvm[i]), 2*ttail(n-d,abs(Avgdrv[i]/sqrt(VarAvgDvm[i]))), Mediandrv[,i]'               
                                } else {
                                        // Binary Output Row - First Difference
                                        real matrix SX0, SX1, Fdif, M
                                        real scalar bse
                                        
                                        SX0 = J(n,0,.)
                                        SX1 = J(n,0,.)
                                                                                                
                                        for (j=1; j<=cols(tokens(colList)); j++){
                                                if (i != j){    
                                                        SX0 = (SX0 ,(KRLS_S.SX2[.,strtoreal(tokens(colList)[j])])) 
                                                        SX1 = (SX1 ,(KRLS_S.SX2[.,strtoreal(tokens(colList)[j])])) 
                                                } else {
                                                        SX0 = (SX0 , rangen(min(KRLS_S.SX2[,i]),min(KRLS_S.SX2[,i]),n))
                                                        SX1 = (SX1 , rangen(max(KRLS_S.SX2[,i]),max(KRLS_S.SX2[,i]),n))
                                                        KRLS_S.binarycol = j
                                                }
                                        }

                                        SX0[ ., . ] = (SX0 :- Xmv[1,.]) :/ Sdx
                                        SX1[ ., . ] = (SX1 :- Xmv[1,.]) :/ Sdx

                                        M = m_euclidian_distance_binary(SX0,SX1,rows(SX0),KRLS_S)
                                        pYfit = cross(M',KRLS_S.Sdy,Coeffs)  
    
                                        // Create the contrast vector
                                        if (Contrast == .){
                                                Contrast = rangen(1/n,1/n,n)
                                        }
                                        
                                        Fdif = cross(Contrast,pYfit)                                                    
                                        bse = sqrt(cross(cross(Contrast,cross((M * ((KRLS_S.Sdy^2 *Vcovmc) :* (1/(KRLS_S.Sdy^2))))',M') :* KRLS_S.Sdy^2 )',Contrast))*sqrt(2)
                                        OutputRow = Fdif, bse, (Fdif / bse), 2*ttail(n-d,abs(Fdif / bse)), mms_quantile(pYfit, UQuantile)'
                                }
                                                                        
                                        if (i==1){
                                                OutputM = OutputRow
                                        } else {
                                                OutputM = OutputM \ OutputRow 
                                        }       
                        }               
                        
                        // Return main results to Stata with appropriate labels
                        st_matrix("e(Output)",OutputM)      
                        string scalar indvars, _kbMat     
                        string matrix Outputcolnames, Outputrownames
               
                        Outputcolnames = J(2,cols(OutputM),"")
 					    Outputcolnames[2,1] = "Avg"
  						Outputcolnames[2,2] = "SE"
   						Outputcolnames[2,3] = "t"
    					Outputcolnames[2,4] = "P>|t|"
                        for (i=1;i <= rows(UQuantile); i++){
                        	  Outputcolnames[2,i+4] = "P" + strofreal(UQuantile[i] * 100)
                        }                        
                        st_matrixcolstripe("e(Output)",Outputcolnames')

						indvars = m_krls_variablelist(.)
						Outputrownames = J(rows(OutputM),2,"")
						for (i=1;i <= cols(tokens(indvars)); i++){
                        	  Outputrownames[i,2] = tokens(indvars)[i] 
                        }    
                        st_matrixrowstripe("e(Output)",Outputrownames)

                        st_matrix(_kbMat=st_tempname(),OutputM[,1]')
						stata("ereturn repost b=" + _kbMat + "")  

                        // Return full derivative matrix as columns in dataset
                        if (deriv != ""){
								string scalar dsuffix
								
                                for (i=1; i<=d; i++){
                                		dsuffix = subinstr(tokens(indvars)[i],".","")
                                        if (_st_varindex(deriv + "" + dsuffix)!=.) (void) st_dropvar(deriv + "_" + dsuffix)
                                        (void)  st_addvar("double",deriv + "_" +  dsuffix)
                                        st_view(T, ., deriv + "_" + dsuffix , touse)
                                        
                                        if (Binary[i] != "1"){
                                                T[.,.] = Drvmat[,i]
                                        } else {
                                                T[.,.] = pYfit
                                        }
                                }
                        }       
                        
                        
                        } else {
                                "Derivatives Suppressed"
                        }
}

// Modified Euclidean Distance used for binary
matrix m_euclidian_distance_binary(real matrix X0, real matrix X1, real scalar n, struct krls_struct scalar KRLS_S){
        real matrix D
        real scalar i,j
        D=J(n, n, .)
                
        for (i=n; i>0; i--){
                for (j=1; j<=i; j++){
                        D[i,j] = exp(sum((X1[i,]-KRLS_S.SX[j,]):^2)/-KRLS_S.sigma) - exp(sum((X0[i,]-KRLS_S.SX[j,]):^2)/-KRLS_S.sigma)
                                        
                        if (KRLS_S.SX2[j, KRLS_S.binarycol] != 0 & KRLS_S.SX2[i, KRLS_S.binarycol] == 0){
                                D[j,i] = -D[i,j] 
                        } else if (KRLS_S.SX2[i, KRLS_S.binarycol] == 0 | KRLS_S.SX2[j, KRLS_S.binarycol] != 0) {
                                D[j,i] = D[i,j] 
                        } else {
                                D[j,i] = -D[i,j]
                        }       
                    }
        }
        return(D)               
}

// Euclidean Distance, used for KM
matrix m_euclidian_distance(real matrix X, real scalar n, real scalar d){
        real matrix D
        real scalar i,j
        D=J(n, n, .)
                
        for (i=n; i>0; i--){
                        for (j=1; j<=i; j++){
                                D[i,j] = sqrt(sum((X[i,]-X[j,]):^2))
                                D[j,i] = D[i,j]
                        }
        }
        return(D)               
}

// Distance used for derivatives
matrix m_distance(real matrix X, real scalar n){
        real matrix D
        real scalar i,j
        D=J(n, n, .)
                
        for (i=n; i>0; i--){
                for (j=1; j<=i; j++){
                        D[i,j] = X[i,1]-X[j,1]
                        D[j,i] = -D[i,j] 
                }
        }
        return(D)
}

// Quantile functions [modified versions of MOREMATA]
real matrix mms_quantile(real matrix X, real matrix P){
    real rowvector result
    real scalar c, cX, cP, r, i

    if (cols(X)==1 & cols(P)!=1 & rows(P)==1) return(mms_quantile(X,  P')')
    if (missing(P) | missing(X)) _error(3351)
    r = rows(P)
    c = max(((cX=cols(X)), (cP=cols(P))))
    if (cX!=1 & cX<c) _error(3200)
    if (cP!=1 & cP<c) _error(3200)
    if (rows(X)==0 | r==0 | c==0) return(J(r,c,.))
    if (c==1) return(_mms_quantile(X, P))
    result = J(r, c, .)
    if (cP==1) for (i=1; i<=c; i++) result[,i] = _mms_quantile(X[,i], P)
    else if (cX==1) for (i=1; i<=c; i++)
     result[,i] = _mms_quantile(X, P[,i])
    else for (i=1; i<=c; i++)
     result[,i] = _mms_quantile(X[,i], P[,i])
    return(result)
}

real colvector _mms_quantile(real colvector X, real colvector P){
    real colvector g, j, j1, p
    real scalar N

    N = rows(X)
    p = order(X,1) 
    g = P*N
    j = floor(g)
    g = 0.5 :+ 0.5*((g - j):>0)
    j1 = j:+1
    j = j :* (j:>=1)
    _editvalue(j, 0, 1)
    j = j :* (j:<=N)
    _editvalue(j, 0, N)
    j1 = j1 :* (j1:>=1)
    _editvalue(j1, 0, 1)
    j1 = j1 :* (j1:<=N)
    _editvalue(j1, 0, N)
    return((1:-g):*X[p[j]] + g:*X[p[j1]])
}
end  
