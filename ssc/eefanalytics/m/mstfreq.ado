*! version 1.0.9  02feb2021
capture program drop mstfreq
program define mstfreq, rclass
version 15.1

syntax varlist(fv) [if] [in], INTervention(varlist fv max=1) RANdom(varlist max=1) [, NPerm(integer 0) NBoot(integer 0) SEED(integer 1020252) SHOWprogress noIsily ITERate(integer 100) ML REML *]

quietly {       
        preserve
        
        if "`nperm'" != "0" {
        cap drop PermC_I*_W PermC_I*_T PermUnc_I*_W PermUnc_I*_T
        }
        if "`nboot'" != "0" {
        cap drop BootC_I*_W BootC_I*_T BootUnc_I*_W BootUnc_I*_T
        }

        tempfile Original
        save `Original'
        
        local intervraw: copy local intervention
        
        
        fvrevar `intervention', list
        local intervention `r(varlist)'
        
        cap {
                local newvarlist        
                foreach var of local varlist {
                        if "`var'" != "`intervention'" & !regexm("`var'","i[^\.]*\.`intervention'$") & !regexm("`var'","\((#[0-9])\)*\.`intervention'$") | regexm("`var'","#")   {
                                local newvarlist `newvarlist' `var'
                                }
                        else {
                        noi disp as txt "Note: Inclusion of the intervention variable in the variable list is redundant."
                        }
                        }
                local varlist: copy local newvarlist
                }

        fvrevar `varlist', list
        local varlist_clean `r(varlist)'
        
        marksample touse
        markout `touse' `intervention' `random'
        keep if `touse'
        
        local maximization reml
        if "`ml'" != "" & "`reml'" != "" {
        noi disp as error "ml and reml may not be specified at the same time"
        error 198
        }
        if "`ml'" != "" {
                local maximization
                }
        if "`reml'" != "" {
                }
        
        tempname test0 test1 Beta1 Beta Cov X UschCov schCov schRand max chk b0 id_var_col1 cluster1_variance1 res_var_col res_variance1 Nu lvl res_variance2 vcovschTrt1 varB31 ///
        varB32 vcovschTrt2 b failtest group_max num mstNt colnumber min Max
        tempvar  total_chk                                      /*set temporary variables/matrices/scalars to be used*/

        tempfile mst
        save `mst'
        summ `random'
        scalar `group_max' = r(max) /*number of groups*/
        tab `random' `intervention', matcell(`X')

        drop _all
        svmat `X'
        describe
        scalar `max' = r(k) /*number of arms*/
        
        foreach i of numlist 1/`=`max'' {
                tempvar r`i' 
                gen double `r`i''=0
                replace `r`i''=1 if `X'`i' >0
                }
        egen double `total_chk' = rowtotal(`r1'-`r`=`max''')
        count if `total_chk' >1
        scalar `chk' = `r(N)'
        if `chk'==0 {
                display as error "error: This is not an MST design"
                error 459
                }

        clear
        use `mst'
        
        baseset, max(`max') intervention(`intervraw')
        local refcat `r(refcat)'
        tempfile mst 
        save `mst'
        
        levelsof `intervention', local(levels)
        tokenize `levels'
        
        foreach i of numlist 1/`=`max''{
                if "`=`refcat'+0'" != "``i''" {
                        local rowname `rowname' "`intervention'``i''"
                        local spart `spart' brokn_fctor`i'
                        }
                else {
                local fpart `fpart' brokn_fctor`i'
                }
                }
        
        gettoken depvar indepvars: varlist
        tab `intervention', gen(brokn_fctor)
        
        local broken_treatment
        foreach i of numlist 1/`=`max'' {
                local broken_treatment `broken_treatment' brokn_fctor`i' /*store all brokn_fctors in local*/
                }
        rename (`fpart' `spart') (`broken_treatment')
        gettoken baseline rest: broken_treatment /*separate between baseline(0) and rest*/
        
        tempfile mst2
        save `mst2'
        
        /*Unconditional Model*/
        mixed `depvar' || `random':, cov(unstructured) `options' `maximization' /*NOTE: CONDITIONAL IS DENOTED WITH SUFFIX 2, UNCONDITIONAL WITH SUFFIX 1*/
        matrix `b0' = e(b)
        
        scalar `id_var_col1' = colnumb(`b0', "lns1_1_1:_cons")
        matrix `cluster1_variance1' = exp(`b0'[1, `id_var_col1'])^2  /*this gives var.B31=> cluster1..`=`max'-1'_variance1*/
                
        
        scalar `res_var_col' = colnumb(`b0', "lnsig_e:_cons")
        scalar `res_variance1' = exp(`b0'[1, `res_var_col'])^2 /*this gives var.W*/
        
        scalar `Nu' = e(N)                                       /*number of obs*/
        
        estat recovariance
        scalar `lvl' = r(relevels)
        matrix xrecov1 = r(Cov`=`lvl'')         /*covariance matrix*/
        scalar `vcovschTrt1' = xrecov1[1,1]
        
        forvalues i =1/`=`max'-1' {
                tab `random' brokn_fctor`=`i'+1', matcell(Br_F`i')  /*for 3 arms, `=`max'-1' = 2 , broken factor is 1,2,3 but we only need 2,3*/
                svmat Br_F`i'
                total Br_F`i'2 /*ensures it sums the N for ones (1) not zeros (0), all matrices Br_F#1 are for zeros*/
                matrix MSTnt`i' = e(b) /*store sum in matrix*/
                }
                
        matrix `mstNt' = MSTnt1
        matrix `varB31' = `cluster1_variance1'
        if `=`max'-1'>1 {
                foreach i of numlist 2/`=`max'-1' {
                        matrix `mstNt' = `mstNt' ,MSTnt`i' /*MSTnt`i' = nt`i' (MSTnt`i' is for conditional and nt`i' for the unconditional (see subprogram gUncondMST), but they are equal)*/
                        }
                }
        
        /*Conditional Model*/
        `isily' mixed `depvar' i.`intervention' `indepvars' || `random':`rest', cov(unstructured) `options' `maximization'
        matrix `b' = e(b)
        matrix `test0' = r(table)[1...,1.."`depvar':_cons"] /*remove baseline category of intervention*/
        scalar `colnumber' = colnumb(`test0',"`=`refcat'+0'b.`intervention'")
        if "`=`colnumber''"=="1" { 
                matrix `test0' = `test0'[1...,2...]
                }
        else {
                matrix `test0' = `test0'[1...,1..`=`colnumber'-1'],`test0'[1...,`=`colnumber'+1'...]
                }
                matrix `test1' = `test0'
                forvalues i = 1/`=rowsof(`test0')' {
                        forvalues j = 1/`=colsof(`test0')' {
                                matrix `test1'[`i',`j']= round(`test0'[`i',`j'],.01)
                        }
                }
                
        matrix `Beta1' = (`test1'["b", .] \ `test1'["ll".."ul", . ])
        matrix `Beta'=`Beta1''
        matrix colnames `Beta' = "Estimate" "95% LB" "95% UB"

        
        forvalues i=1/`=`max'' {
        tempname id_var_col`i' cluster`i'_variance2 
                scalar `id_var_col`i'' = colnumb(`b', "lns1_1_`i':_cons")
                matrix `cluster`i'_variance2' = exp(`b'[1, `id_var_col`i''])^2 
                }
        
        scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
        scalar `res_variance2' = exp(`b'[1, `res_var_col'])^2 
        
        
        estat recovariance
        scalar `lvl' = r(relevels)
        matrix xrecov2 = r(Cov`=`lvl'')
        matrix `vcovschTrt2' = xrecov2[`=`max'',1..`=`max'-1']
        
        matrix `schCov' = xrecov2
        forvalues i = 1/`=rowsof(xrecov2)' {
                forvalues j = 1/`=colsof(xrecov2)' {
                        matrix `schCov'[`i',`j']= round(xrecov2[`i',`j'],.01)
                }
        }
                
        matrix rownames `schCov' = `rowname' "Intercept"
        matrix colnames `schCov' = `rowname' "Intercept"
        
                
        matrix `varB32' = `cluster1_variance2'
        if `=`max'-1'>1 {
                foreach i of numlist 2/`=`max'-1' {
                        matrix `varB32' = `varB32' , `cluster`i'_variance2'
                        }
                }
                
        scalar `num' = `=`max'-1'
        mata: func1("`mstNt'", "`Nu'", "xrecov", "`varB32'", "`vcovschTrt2'") /*calls mata to produce "sumvarB2" and "summed"=sum(N.t/N*(var.B3+2*vcov.schTrt))*/
        
        tempname varSch1 varSch2 varTT1 varTT2
        scalar `varSch1' =  xrecov1[1,1] 
        scalar `varSch2' =  xrecov2[`=`max'',`=`max'']
        scalar `varTT2' = `varSch2' + `res_variance2' + summed /*THIS IS EQUIVALENT TO vartt in R*/
        scalar `varTT1' = `varSch1' + `res_variance1'          /*THIS IS EQUIVALENT TO vartt1 in R*/
        forvalues s = 1/2 {
                tempvar ICC`s'
                scalar `ICC`s'' = sumvarB2`s' / `varTT`s''
                }
        cap matrix drop xrecov1 xrecov2 
        cap scalar drop sumvarB21 sumvarB22 summed
        
                /*ICC1 IN STATA IS EQUIVALENT TO ICC2 IN R*/
                /*ICC2 IN STATA IS EQUIVALENT TO ICC1 IN R*/
                 
        predict EstmReff*, reffects
        tempfile beta1
        save `beta1'
        
        matrix Coef = `b'[1,1..`=`max'']
        mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
        
        matrix Coef = Coef' 
        clear

        use `beta1'
        collapse EstmReff*, by(`random')
        mkmat EstmReff* `random', matrix(`test1')
        matrix `schRand'=`test1'
        forvalues i = 1/`=rowsof(`test1')' {
                forvalues j = 1/`=colsof(`test1')' {
                        matrix `schRand'[`i',`j']= round(`test1'[`i',`j'],.01)
                }
        }
        matrix colname `schRand' = `rowname' "Intercept" "School"

        clear
        use `mst'

        
        gCondMST, res_variance2(`res_variance2') vartt2(`varTT2') group_max(`group_max') max(`max') varb32(`varB32') num(`num') /*see sub-programs*/
        
        local m
        forvalues i = 1/`=`max'' {
                if "`=`refcat'+0'" != "``i''" {
                local m = `m' + 1
                
                matrix CondES``i'' = r(CondES`m') 
                local cond`m' CondES``i''
                }
                }
                
        tab `intervention', gen(brokn_fctor)
        local broken_treatment
        foreach i of numlist 1/`=`max'' {
                local broken_treatment `broken_treatment' brokn_fctor`i' /*store all brokn_fctors in local*/
                }
        rename (`fpart' `spart') (`broken_treatment') /*rename broken_factors based on new ref category (i.e. broken2 broken1 broken3 to broken1 broken2 broken3)*/
        
        
        gUncondMST, rand(`random') res_variance1(`res_variance1') res_variance2(`res_variance2') vartt2(`varTT2') vartt1(`varTT1') group_max(`group_max') ///
        max(`max') icc1(`ICC1') icc2(`ICC2') varb31(`varB31') num(`num') /*see sub-programs*/
        
        local m
        forvalues i = 1/`=`max'' {
                if "`=`refcat'+0'" != "``i''" {
                local m = `m' + 1
                
                matrix UncondES``i'' = r(UncondES`m') 
                local uncond`m' UncondES``i'' 
                }
                }
                
        
        matrix `UschCov' = round(r(UschCov)[1,1],.01)
        matrix rownames `UschCov' = "Intercept"
        matrix colnames `UschCov' = "Unconditional"
        
        matrix `Cov' = r(Cov)
        
        drop brokn_fctor*
        matrix drop Coef
        
        tempfile touseit
        save `touseit'
        
    //====================================================//    
   //===================                =================//
  //==================  PERMUTATIONS  ==================//
 //=================                ===================//
//====================================================//
        
        if "`nperm'" != "0"  {
                tempname sumconv sumnotconv sumnotconv2 N_total 
                count
                scalar `N_total' = `r(N)'
                scalar `sumnotconv2' = 0 /*sumnotconv, sumnotconv2 and sumconv are to be used later for indication of supplementary permutations*/
                scalar `sumnotconv'  = 0
                scalar `sumconv' = 0
                levelsof `random', local(levels)
                if `nperm'<1000 {
                        display as error "error: nPerm must be greater than 1000"
                        error 7
                        }
                noisily di as txt "  Running Permutations..."
                
                forvalues j = 1/`nperm' {
                        tempname  cluster1_`j'variance1  v`j'covschTrt1 var`j'B31 var`j'B32 v`j'covschTrt2 cluster1_`j'variance2 res_`j'variance2 ///
                        res_`j'variance1 v`j'arSch1 v`j'arSch2 v`j'arTT2 v`j'arTT1
                
                if "`seed'" == "1020252" {
                        local defseed = `=12890*`j'+1'
                        set seed `defseed'
                        }
                        else {
                        local seeds = `=`seed'*`j'+1'
                        set seed `seeds'
                        }
                        
                        if "`showprogress'" != "" {     
                                if !mod(`j', 100) {
                                noi di _c "`j'"
                                }
                                        else {
                                        if !mod(`j', 10) {
                                                noi di _c "." 
                                                }
                                        }
                                }
                        keep `random' `intervention'
                        tempvar rand1 rand2
                        gen double `rand1'=.
                        gen double `rand2'=.
                        foreach `random' in `levels' {
                                replace `rand1' = runiform() if `random' == ``random'' /*Stata randomnization produces less combinations than R*/
                                replace `rand2' = runiform() if `random' == ``random'' /*randomnize twice for better randomnization. */
                                }
                        sort `random' `rand1' `rand2'
                        drop `rand1' `rand2'
                        tempfile clust
                        save `clust'
                        merge 1:1 _n using `touseit', nogenerate
                        tempfile permES
                        save `permES'
                        
                        mixed `depvar' || `random':, cov(unstructured) iterate(`iterate') `options' `maximization'
                        matrix `b0' = e(b)
                        
                        capture {
                        
                                scalar `id_var_col1' = colnumb(`b0', "lns1_1_1:_cons")
                                matrix `cluster1_`j'variance1' = exp(`b0'[1, `id_var_col1'])^2  
                                
                
                                scalar `res_var_col' = colnumb(`b0', "lnsig_e:_cons")
                                scalar `res_`j'variance1' = exp(`b0'[1, `res_var_col'])^2 
                                
                                
                                scalar `Nu'= e(N) 
                
                                estat recovariance
                                scalar `lvl' = r(relevels)
                                matrix x`j'recov1 = r(Cov`=`lvl'')
                                matrix `v`j'covschTrt1' = x`j'recov1[1,1]
                                
                                tab `intervention', gen(brokn_fctor)
                                rename (`fpart' `spart') (`broken_treatment')
                
                                matrix `var`j'B31' = `cluster1_`j'variance1'
                                }
                                if _rc==1 {
                                        exit 1
                                        }
                        
                                
                        
                        capt `isily' mixed `depvar' i.`intervention' `indepvars' || `random': `rest', cov(unstructured) iterate(`iterate') `options' `maximization'
                        matrix `b' = e(b)
                
        
                        capture {
                                forvalues i=1/`=`max'' {
                                        tempname id_var_col`i' cluster`i'_`j'variance2 
                                        scalar `id_var_col`i'' = colnumb(`b', "lns1_1_`i':_cons")
                                        matrix `cluster`i'_`j'variance2' = exp(`b'[1, `id_var_col`i''])^2  
                                        }
                        
                                scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
                                scalar `res_`j'variance2' = exp(`b'[1, `res_var_col'])^2 /*this gives var.W*/
                                
                                estat recovariance
                                scalar `lvl' = r(relevels)
                                matrix x`j'recov2 = r(Cov`=`lvl'')
                                matrix `v`j'covschTrt2' = x`j'recov2[`=`max'',1..`=`max'-1']

                        
                                matrix `var`j'B32' = `cluster1_`j'variance2'
                                if `=`max'-1'>1 {
                                        foreach i of numlist 2/`=`max'-1' {
                                                matrix `var`j'B32' = `var`j'B32' ,`cluster`i'_`j'variance2'
                                                }
                                        }
                                mata: func1("`mstNt'", "`Nu'", "x`j'recov", "`var`j'B32'", "`v`j'covschTrt2'") 
                                scalar `v`j'arSch1' =  x`j'recov1[1,1] 
                                scalar `v`j'arSch2' =  x`j'recov2[`=`max'',`=`max'']
                                scalar `v`j'arTT2' = `v`j'arSch2' + `res_`j'variance2' + summed /*THIS IS EQUIVALENT TO vartt in R*/
                                
                                scalar `v`j'arTT1' = `v`j'arSch1' + `res_`j'variance1'           /*THIS IS EQUIVALENT TO vartt1 in R*/
                                forvalues s = 1/2 {
                                        scalar `ICC`s'' = sumvarB2`s' / `v`j'arTT`s''
                                        }
                                
                                cap matrix drop x`j'recov1 x`j'recov2 
                                cap scalar drop sumvarB21 sumvarB22 summed
                                
                                /*ICC1 IN STATA IS EQUIVALENT TO ICC2 IN R*/
                                /*ICC2 IN STATA IS EQUIVALENT TO ICC1 IN R*/
                        
                                matrix Coef = `b'[1,1..`=`max'']
                                mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
        
                                matrix Coef = Coef'
                                
                                clear
                                use `permES'
                                
                                tab `intervention', gen(brokn_fctor)
                                rename (`fpart' `spart') (`broken_treatment')
                                
                                gCondUncondMST, j(`j') in(`intervention') rand(`random') res_variance1(`res_`j'variance1') res_variance2(`res_`j'variance2') ///
                                group_max(`group_max') max(`max') vartt1(`v`j'arTT1') vartt2(`v`j'arTT2') num(`num') icc1(`ICC1')
								
				forvalues i = 1/`=`max'-1' {
					tempname dwC`i'`j' dtTotalC`i'`j' dwU`i'`j' dtTotalU`i'`j'
					scalar `dwC`i'`j'' = r(dwC`i'`j')
					scalar `dtTotalC`i'`j'' = r(dtTotalC`i'`j')
									
					scalar `dwU`i'`j'' = r(dwU`i'`j')
					scalar `dtTotalU`i'`j'' = r(dtTotalU`i'`j')
					}
                        
                                matrix drop Coef
                                }/*capture*/
                
                        
                        
                        scalar `failtest' = `res_`j'variance2'
                        if `failtest' ==. {
                                scalar `sumnotconv' = `sumnotconv' + 1 /*count the failed models.*/
                                }
                        else {
                                scalar `sumconv' = `sumconv' + 1 /*otherwise count succesful models*/
                                }
                        clear
                        use `touseit'
                        
                        
                        } /*nperm*/
                        
                tempname one two diff
                scalar `one' = 0
                scalar `two' = 0
                        
		    //=====================================================//
		   //============ SUPPLEMENTARY PERMUTATIONS =============//
		  //=====================================================//  
                        
                while `=`sumconv'' < `nperm' {
                        if "`showprogress'" != "" {     
                                noi disp as txt ""
                                }
                        scalar `diff' = `sumnotconv'-`sumnotconv2'
                        cap noi di " Total of `=`diff'' models failed"
                        cap noi di "  Running supplementary permutations..."
                        
                        scalar `one' = `nperm'+`=`sumnotconv2'' + 1 /*force remaining permutations to start from where previous ended; sumnotconv2 informs the model in case supplementary perm. also fail*/
                        scalar `two' = `nperm'+`=`sumnotconv''
                        
                        scalar `sumnotconv2' = `sumnotconv'
                        
                        forvalues j = `=`one''/`=`two'' {
                                tempname  cluster1_`j'variance1  v`j'covschTrt1 var`j'B31 var`j'B32 v`j'covschTrt2 cluster1_`j'variance2 res_`j'variance2 ///
                                res_`j'variance1 v`j'arSch1 v`j'arSch2 v`j'arTT2 v`j'arTT1
                                
                        if "`seed'" == "1020252" {
                                local defseed = `=12890*`j'+1'
                                set seed `defseed'
                                }
                        else {
                                local seeds = `=`seed'*`j'+1'
                                set seed `seeds'
                                }
                                        
                                if "`showprogress'" != "" {     
                                        if !mod(`j', 100) {
                                                noi di _c "`j'"
                                                }
                                        else {
                                                if !mod(`j', 10) {
                                                        noi di _c "." 
                                                        }
                                                }
                                        }
                                keep `random' `intervention'
                                gen double `rand1'=.
                                gen double `rand2'=.
                                foreach `random' in `levels' {
                                        replace `rand1' = runiform() if `random' == ``random''
                                        replace `rand2' = runiform() if `random' == ``random''
                                        }
                                sort `random' `rand1' `rand2'
                                drop `rand1' `rand2'
                                tempfile clust
                                save `clust'
                                merge 1:1 _n using `touseit', nogenerate
                                tempfile permES
                                save `permES'
                        
                                mixed `depvar' || `random':, cov(unstructured) iterate(`iterate') `options' `maximization'
                                matrix `b0' = e(b)
                
                        
                                capture {
                                        scalar `id_var_col1' = colnumb(`b0', "lns1_1_1:_cons")
                                        matrix `cluster1_`j'variance1' = exp(`b0'[1, `id_var_col1'])^2  
                                
                        
                                        scalar `res_var_col' = colnumb(`b0', "lnsig_e:_cons")
                                        scalar `res_`j'variance1' = exp(`b0'[1, `res_var_col'])^2 
                        
                                        scalar `Nu'= e(N)
                        
                                        estat recovariance
                                        scalar `lvl' = r(relevels)
                                        matrix x`j'recov1 = r(Cov`=`lvl'')
                                        matrix `v`j'covschTrt1' = x`j'recov1[1,1]
                                        
                                        tab `intervention', gen(brokn_fctor)
                                        rename (`fpart' `spart') (`broken_treatment')
                        
                                        matrix `var`j'B31' = `cluster1_`j'variance1'
                                        }
                                        
                                capt `isily' mixed `depvar' i.`intervention' `indepvars' || `random': `rest', cov(unstructured) iterate(`iterate') `options' `maximization'
                                matrix `b' = e(b)
                
        
                                capture {
                                        forvalues i=1/`=`max'' {
                                                tempname cluster`i'_`j'variance2 
                                                scalar `id_var_col`i'' = colnumb(`b', "lns1_1_`i':_cons")
                                                matrix `cluster`i'_`j'variance2' = exp(`b'[1, `id_var_col`i''])^2  
                                                }
                                
                                        scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
                                        scalar `res_`j'variance2' = exp(`b'[1, `res_var_col'])^2 
                        
                        
                                        estat recovariance
                                        scalar `lvl' = r(relevels)
                                        matrix x`j'recov2 = r(Cov`=`lvl'')
                                        matrix `v`j'covschTrt2' = x`j'recov2[`=`max'',1..`=`max'-1']
                                
                                        matrix `var`j'B32' = `cluster1_`j'variance2'
                                        if `=`max'-1'>1 {
                                                foreach i of numlist 2/`=`max'-1' {
                                                        matrix `var`j'B32' = `var`j'B32' ,`cluster`i'_`j'variance2'
                                                        }
                                                }
                                        mata: func1("`mstNt'", "`Nu'", "x`j'recov", "`var`j'B32'", "`v`j'covschTrt2'") 
                                        tempname v`j'arSch1 v`j'arSch2 v`j'arTT1 v`j'arTT2
                                        scalar `v`j'arSch1' =  x`j'recov1[1,1] 
                                        scalar `v`j'arSch2' =  x`j'recov2[`=`max'',`=`max'']
                                        scalar `v`j'arTT2' = `v`j'arSch2' + `res_`j'variance2' + summed 
                                        scalar `v`j'arTT1' = `v`j'arSch1' + `res_`j'variance1'          
                                        forvalues s = 1/2 {
                                                scalar `ICC`s'' = sumvarB2`s' / `v`j'arTT`s''
                                                }
                                        cap matrix drop x`j'recov1 x`j'recov2 
                                        cap scalar drop sumvarB21 sumvarB22 summed
                                
                                        /*ICC1 IN STATA IS EQUIVALENT TO ICC2 IN R*/
                                        /*ICC2 IN STATA IS EQUIVALENT TO ICC1 IN R*/
                                
                                        matrix Coef = `b'[1,1..`=`max'']
                                        mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
        
                                        matrix Coef = Coef'
                                        
                                        clear
                                        use `permES'
                        
                                        tab `intervention', gen(brokn_fctor)
                                        rename (`fpart' `spart') (`broken_treatment')

                                        gCondUncondMST, j(`j') in(`intervention') rand(`random') res_variance1(`res_`j'variance1') res_variance2(`res_`j'variance2') ///
                                        group_max(`group_max') max(`max') vartt1(`v`j'arTT1') vartt2(`v`j'arTT2') num(`num') icc1(`ICC1')
										
					forvalues i = 1/`=`max'-1' {
						tempname dwC`i'`j' dtTotalC`i'`j' dwU`i'`j' dtTotalU`i'`j'
						scalar `dwC`i'`j'' = r(dwC`i'`j')
						scalar `dtTotalC`i'`j'' = r(dtTotalC`i'`j')
											
						scalar `dwU`i'`j'' = r(dwU`i'`j')
						scalar `dtTotalU`i'`j'' = r(dtTotalU`i'`j')
						}
											
                                        matrix drop Coef
                                        }/*capture*/
                                        if _rc==1 {
                                        exit 1
                                        }
                
                                scalar `failtest' = `res_`j'variance2'
                                if `failtest' ==. {
                                        
                                        scalar `sumnotconv' = `sumnotconv' + 1 
                                        }
                                else {
                                        scalar `sumconv' = `sumconv' + 1
                                        }
                                clear
                                use `touseit'
                
                                } /*newnperm*/  
                        } /*while*/ 
                if "`showprogress'" != "" {     
                                noi disp as txt ""
                                }
                noisily di as txt "  Permutations completed."
                
                tempname permutations   
                scalar `permutations' = `nperm' + `=`sumnotconv''
                forvalues j = 1/`=`permutations'' {
                        forvalues i = 1/`=`max'-1' {
                                if `=`permutations''>`=`N_total'' {
                                        set obs `=`permutations''
                                        }
                                capture gen double PermC_I`i'_W=.
                                capture gen double PermC_I`i'_T=.
                                capture replace PermC_I`i'_W = `dwC`i'`j'' in `j'
                                capture replace PermC_I`i'_T = `dtTotalC`i'`j'' in `j' /*plug in estimates*/
                                                
                                capture gen double PermUnc_I`i'_W=.
                                capture gen double PermUnc_I`i'_T=.
                                capture replace PermUnc_I`i'_W = `dwU`i'`j'' in `j'
                                capture replace PermUnc_I`i'_T = `dtTotalU`i'`j'' in `j'
                                }                       
                        }
                        local m
                        forvalues i = 1/`=`max''{
                                if "`=`refcat'+0'" != "``i''" {
                                        local m = `m' + 1
                                        rename (PermC_I`m'_W PermUnc_I`m'_W PermC_I`m'_T PermUnc_I`m'_T) (PermC_I``i''_W PermUnc_I``i''_W PermC_I``i''_T PermUnc_I``i''_T)
                                        }
                                }
                        
                        keep PermC_I*_W PermUnc_I*_W PermC_I*_T PermUnc_I*_T
                        tempfile origperm
                        save `origperm'
                                                
                        use `Original'
                        merge 1:1 _n using `origperm', nogenerate
                        tempfile Original
                        save `Original' 
                        }/*if nperm*/
                
        
        
        
		    //====================================================//
		   //====================              ==================// 
		  //===================  BOOTSTRAPS  ===================//
		 //==================              ====================//
		//====================================================//   

                if "`nboot'" != "0" {
                        clear
                        use `mst'
                        count
                        tempname N_total sumnotconv2 sumnotconv sumconv
                        scalar `N_total' = `r(N)'
                        scalar `sumnotconv2' = 0
                        scalar `sumnotconv'  = 0
                        scalar `sumconv' = 0

                        if `nboot'<1000 {
                                display as error "error: nBoot must be greater than 1000"
                                error 7
                                }
        
                        set seed `seed'
                                
                        noisily di as txt "  Running Bootstraps..."
                        forvalues j = 1/`nboot' {
                                tempname cluster1_`j'variance1  v`j'covschTrt1 var`j'B31 var`j'B32 v`j'covschTrt2 cluster1_`j'variance2 res_`j'variance2 ///
                                res_`j'variance1 v`j'arSch1 v`j'arSch2 v`j'arTT2 v`j'arTT1
                                
                                if "`showprogress'" != "" {     
                                        if !mod(`j', 100) {
                                                noi di _c "`j'"
                                                }
                                        else {
                                                if !mod(`j', 10) {
                                                        noi di _c "." 
                                                        }
                                                }
                                        }
                                gettoken depvar indepvars: varlist
                                keep `varlist_clean' `intervention' `random'
                                bsample, strata(`random')
                                
                                mixed `depvar' || `random':, cov(unstructured) iterate(`iterate') `options'
                                matrix `b0' = e(b)
                        
                                capture {
                                        scalar `id_var_col1' = colnumb(`b0', "lns1_1_1:_cons")
                                        matrix `cluster1_`j'variance1' = exp(`b0'[1, `id_var_col1'])^2  /*this gives var.B3=> cluster1..`=`max'-1'_variance2, var.sch => cluster`=`max''_variance2*/
                                
                        
                                        scalar `res_var_col' = colnumb(`b0', "lnsig_e:_cons")
                                        scalar `res_`j'variance1' = exp(`b0'[1, `res_var_col'])^2 /*this gives var.W*/
                        
                                        scalar `Nu'= e(N) /*number of obs*/
                        
                                        estat recovariance
                                        scalar `lvl' = r(relevels)
                                        matrix x`j'recov1 = r(Cov`=`lvl'')
                                        matrix `v`j'covschTrt1' = x`j'recov1[1,1]
                        
                                        tab `intervention', gen(brokn_fctor)
                                        rename (`fpart' `spart') (`broken_treatment')
                                        forvalues i =1/`=`max'-1' {
                                                tab `random' brokn_fctor`=`i'+1', matcell(Br_F`i')  /*because `=`max'-1' = 2 , broken factor is 1,2,3 but we need 2,3 because 1 is baseline*/
                                                svmat Br_F`i'
                                                total Br_F`i'2 /*ensures it captures the N for ones (1) not zeros (0), all matrices Br_F#1 are for zeros*/
                                                matrix MSTnt`i' = e(b)
                                                }
                                
                                        matrix `mstNt' = MSTnt1
                        
                                        matrix `var`j'B31' = `cluster1_`j'variance1'
                                        if `=`max'-1'>1 {
                                                foreach i of numlist 2/`=`max'-1' {
                                                        matrix `mstNt' = `mstNt' ,MSTnt`i'
                                                        }
                                                }
                        
                                        } /*capture*/
                                        if _rc==1 {
                                                exit 1
                                                }

                                capt `isily' mixed `depvar' i.`intervention' `indepvars' || `random':`rest', cov(unstructured) iterate(`iterate') `options' `maximization'
                                matrix `b' = e(b)
                                        
                                        
                                capture {
                                        forvalues i=1/`=`max'' {
                                                tempname id_var_col`i' cluster`i'_`j'variance2 
                                                scalar `id_var_col`i'' = colnumb(`b', "lns1_1_`i':_cons")
                                                matrix `cluster`i'_`j'variance2' = exp(`b'[1, `id_var_col`i''])^2  /*this gives var.B3=> cluster1..`=`max'-1'_variance2, var.sch => cluster`=`max''_variance2*/
                                                }
                                
                                        scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
                                        scalar `res_`j'variance2' = exp(`b'[1, `res_var_col'])^2 /*this gives var.W*/

                                
                                        estat recovariance
                                        scalar `lvl' = r(relevels)
                                        matrix x`j'recov2 = r(Cov`=`lvl'')
                                        matrix `v`j'covschTrt2' = x`j'recov2[`=`max'',1..`=`max'-1']

                                        matrix `var`j'B32' = `cluster1_`j'variance2'
                                        if `=`max'-1'>1 {
                                                foreach i of numlist 2/`=`max'-1' {
                                                        matrix `var`j'B32' = `var`j'B32' ,`cluster`i'_`j'variance2'
                                                        }
                                                }
                                
                                        mata: func1("`mstNt'", "`Nu'", "x`j'recov", "`var`j'B32'", "`v`j'covschTrt2'") 
                                        scalar `v`j'arSch1' =  x`j'recov1[1,1] 
                                        scalar `v`j'arSch2' =  x`j'recov2[`=`max'',`=`max'']
                                        scalar `v`j'arTT2' = `v`j'arSch2' + `res_`j'variance2' + summed /*THIS IS EQUIVALENT TO vartt in R*/
                                        scalar `v`j'arTT1' = `v`j'arSch1' + `res_`j'variance1'          /*THIS IS EQUIVALENT TO vartt1 in R*/
                                        forvalues s = 1/2 {
                                                scalar `ICC`s'' = sumvarB2`s' / `v`j'arTT`s''
                                                }
                                        cap matrix drop x`j'recov1 x`j'recov2 
                                        cap scalar drop sumvarB21 sumvarB22 summed
                                                
                                        matrix Coef = `b'[1,1..`=`max'']
                                        mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
        
                                        matrix Coef = Coef'
                                
                                        clear
                                        use `mst'

                                        forvalues s = 1/2 {
                                                forvalues i=1/`=`max'-1' {
                                                        tempname Within`s'_`i'`j' Total`s'_`i'`j'
                                                                scalar `Within`s'_`i'`j'' = Coef[`i',1]/sqrt(`res_`j'variance`s'')
                                                                scalar `Total`s'_`i'`j'' = Coef[`i',1]/sqrt(`v`j'arTT`s'')
                                                                }
                                                        }
                                        matrix drop Coef        
                                        } /*capture*/
                                        if _rc==1 {
                                                exit 1
                                                }
                                
                                                
                                                        
                                scalar `failtest' = `res_`j'variance2'
                                if `failtest' ==. {
                                        scalar `sumnotconv' = `sumnotconv' + 1
                                        }
                                else {
                                        scalar `sumconv' = `sumconv' + 1
                                        }
                                } /*nboot*/

                        tempname one two diff
                        scalar `one' = 0
                        scalar `two' = 0
                                        
                                        
				    //=====================================================//
				   //============ SUPPLEMENTARY BOOTSTRAPS ===============//
				  //=====================================================//
                                
                        while `=`sumconv''<`nboot' {
                                if "`showprogress'" != "" {     
                                noi disp as txt ""
                                }
                                scalar `diff' = `sumnotconv'-`sumnotconv2'
                                noi di " Total of `=`diff'' models failed"
                                noi di "  Running supplementary bootstraps..."
                                
                                scalar `one' = `nboot'+`=`sumnotconv2'' + 1
                                scalar `two' = `nboot'+`=`sumnotconv''
                                
                                scalar `sumnotconv2' = `sumnotconv'
                                
                                forvalues j = `=`one''/`=`two'' {
                                        tempname  cluster1_`j'variance1  v`j'covschTrt1 var`j'B31 var`j'B32 v`j'covschTrt2 cluster1_`j'variance2 res_`j'variance2 ///
                                        res_`j'variance1 v`j'arSch1 v`j'arSch2 v`j'arTT2 v`j'arTT1      
                                        
                                        if "`showprogress'" != "" {     
                                                if !mod(`j', 100) {
                                                noi di _c "`j'"
                                                }
                                        else {
                                                if !mod(`j', 10) {
                                                        noi di _c "." 
                                                        }
                                                }
                                        }

                                        gettoken depvar indepvars: varlist              
                                        keep `varlist_clean' `intervention' `random'
                                        bsample, strata(`random')
                        
                                        mixed `depvar' || `random':, cov(unstructured) iterate(`iterate') `options'
                                        matrix `b0' = e(b)

                                        capture {
                                                scalar `id_var_col1' = colnumb(`b0', "lns1_1_1:_cons")
                                                matrix `cluster1_`j'variance1' = exp(`b0'[1, `id_var_col1'])^2  
                        

                                                scalar `res_var_col' = colnumb(`b0', "lnsig_e:_cons")
                                                scalar `res_`j'variance1' = exp(`b0'[1, `res_var_col'])^2 

                                                scalar `Nu'= e(N) 

                                                estat recovariance
                                                scalar `lvl' = r(relevels)
                                                matrix x`j'recov1 = r(Cov`=`lvl'')
                                                matrix `v`j'covschTrt1' = x`j'recov1[1,1]
                                                
                                                tab `intervention', gen(brokn_fctor)
                                                rename (`fpart' `spart') (`broken_treatment')
                                                forvalues i =1/`=`max'-1' {
                                                        tab `random' brokn_fctor`=`i'+1', matcell(Br_F`i')  
                                                        svmat Br_F`i'
                                                        total Br_F`i'2 
                                                        matrix MSTnt`i' = e(b)
                                                        }
                        
                                                
                                                matrix `mstNt' = MSTnt1

                                                matrix `var`j'B31' = `cluster1_`j'variance1'
                                                if `=`max'-1'>1 {
                                                        foreach i of numlist 2/`=`max'-1' {
                                                                matrix `mstNt' = `mstNt' ,MSTnt`i'
                                                                }
                                                        }
                                                } /*capture*/
                                                if _rc==1 {
                                                        exit 1
                                                        }

                                        capt `isily' mixed `depvar' i.`intervention' `indepvars' || `random':`rest', cov(unstructured) iterate(`iterate') `options' `maximization'
                                        matrix `b' = e(b)

                                        capture {
                                                forvalues i=1/`=`max'' {
                                                        tempname cluster`i'_`j'variance2 
                                                        scalar `id_var_col`i'' = colnumb(`b', "lns1_1_`i':_cons")
                                                        matrix `cluster`i'_`j'variance2' = exp(`b'[1, `id_var_col`i''])^2  
                                                        }

                                                scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
                                                scalar `res_`j'variance2' = exp(`b'[1, `res_var_col'])^2 


                                                estat recovariance
                                                scalar `lvl' = r(relevels)
                                                matrix x`j'recov2 = r(Cov`=`lvl'')
                                                matrix `v`j'covschTrt2' = x`j'recov2[`=`max'',1..`=`max'-1']
                        
                                                matrix `var`j'B32' = `cluster1_`j'variance2'
                                                if `=`max'-1'>1 {
                                                        foreach i of numlist 2/`=`max'-1' {
                                                                matrix `var`j'B32' = `var`j'B32' ,`cluster`i'_`j'variance2'
                                                                }
                                                        }

                                                mata: func1("`mstNt'", "`Nu'", "x`j'recov", "`var`j'B32'", "`v`j'covschTrt2'")  

                                                scalar `v`j'arSch1' =  x`j'recov1[1,1] 
                                                scalar `v`j'arSch2' =  x`j'recov2[`=`max'',`=`max'']
                                                scalar `v`j'arTT2' = `v`j'arSch2' + `res_`j'variance2' + summed /*THIS IS EQUIVALENT TO vartt in R*/
                                                scalar `v`j'arTT1' = `v`j'arSch1' + `res_`j'variance1'           /*THIS IS EQUIVALENT TO vartt1 in R*/
                                                forvalues s = 1/2 {
                                                        scalar `ICC`s'' = sumvarB2`s' / `v`j'arTT`s''
                                                        }
                                                cap matrix drop x`j'recov1 x`j'recov2 
                                                cap scalar drop sumvarB21 sumvarB22 summed
                                                
                                                matrix Coef = `b'[1,1..`=`max'']
                                                mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
        
                                                matrix Coef = Coef'
                                                
                                                clear
                                                use `mst'

                                                forvalues s = 1/2 {
                                                        forvalues i=1/`=`max'-1' {
                                                                tempname Within`s'_`i'`j' Total`s'_`i'`j'
                                                                scalar `Within`s'_`i'`j'' = Coef[`i',1]/sqrt(`res_`j'variance`s'')
                                                                scalar `Total`s'_`i'`j'' = Coef[`i',1]/sqrt(`v`j'arTT`s'')
                                                                }
                                                        }
                                                matrix drop Coef                        
                                                } /*capture*/   
                                                        if _rc==1 {
                                                        exit 1
                                                        }
                                        
                                        
                                        scalar `failtest' = `res_`j'variance2'
                                                
                                        if `failtest' ==. {
                                                scalar `sumnotconv' = `sumnotconv' + 1 
                                                }
                                        else {
                                                scalar `sumconv' = `sumconv' + 1
                                                }
                                        } /*newnboot*/
                                } /*while*/
                        if "`showprogress'" != "" {     
                                noi disp as txt ""
                                }
                        noisily di as txt "  Bootstraps completed."
                                                        
                        tempname bootstraps
                        scalar `bootstraps' = `nboot' + `=`sumnotconv''
                        forvalues s = 1/2 {
                                forvalues j = 1/`=`bootstraps'' {       
                                        forvalues i = 1/`=`max'-1' {
                                                if `=`bootstraps''>`=`N_total'' {
                                                        set obs `=`bootstraps''
                                                        }
                                                cap gen double Boot`s'_T`i'_W=.
                                                cap gen double Boot`s'_T`i'_T=.
                                                cap replace Boot`s'_T`i'_W = `Within`s'_`i'`j'' in `j'
                                                cap replace Boot`s'_T`i'_T = `Total`s'_`i'`j'' in `j'
                                                }
                                        }
                                }
                        capture {
                                forvalues s = 1/2 {
                                        forvalues i = 1/ `=`max'-1' {
                                                tempname  W`s'_25_`i' W`s'_975_`i' T`s'_25_`i' T`s'_975_`i'
                                                centile Boot`s'_T`i'_W, centile(2.5)                                             /*quantiles*/
                                                scalar `W`s'_25_`i''    =r(c_1)
                                                centile Boot`s'_T`i'_W, centile(97.5)
                                                scalar `W`s'_975_`i''   =r(c_1)

                                                centile Boot`s'_T`i'_T, centile(2.5)
                                                scalar `T`s'_25_`i''    =r(c_1)
                                                centile Boot`s'_T`i'_T, centile(97.5)
                                                scalar `T`s'_975_`i''   =r(c_1)
                                                }
                                        }
                                } /*capture*/
                                if _rc==1 {
                                        exit 1
                                        }
                        forvalues i = 1/`=`max'-1' {
                                tempname WC_`i' TC_`i' WU_`i' TU_`i'
                                matrix `WC_`i''                 = (round(dw`i',.01),round(`W2_25_`i'',.01),round(`W2_975_`i'',.01))
                                matrix `TC_`i''                 = (round(dtTotal`i',.01),round(`T2_25_`i'',.01),round(`T2_975_`i'',.01))
                                matrix CondES`i'                = `WC_`i'' \ `TC_`i''

                                matrix rownames CondES`i' = "Within" "Total"
                                matrix colnames CondES`i' = "Estimate" "95% (BT)LB" "95% (BT)UB"
                                
                                scalar drop dw`i' dtTotal`i'
                                }
                                                                
                        forvalues i = 1/`=`max'-1' {
                                matrix `WU_`i''                 = (round(dUw`i',.01),round(`W1_25_`i'',.01),round(`W1_975_`i'',.01))
                                matrix `TU_`i''                 = (round(dtUTotal`i',.01),round(`T1_25_`i'',.01),round(`T1_975_`i'',.01))
                                matrix UncondES`i'      = `WU_`i'' \ `TU_`i''
                                
                                matrix rownames UncondES`i' = "Within" "Total"
                                matrix colnames UncondES`i' = "Estimate" "95% (BT)LB" "95% (BT)UB"
                                
                                scalar drop dUw`i' dtUTotal`i'
                                }
                                
                                local m
                                forvalues i = 1/`=`max'' {
                                        if "`=`refcat'+0'" != "``i''" {
                                        local m = `m' + 1
                                        
                                        matrix CondES``i'' = CondES`m' 
                                        local cond`m' CondES``i'' 
                                        
                                        matrix UncondES``i'' = UncondES`m' 
                                        local uncond`m' UncondES``i'' 
                                        
                                        rename (Boot1_T`m'_W Boot2_T`m'_W Boot1_T`m'_T Boot2_T`m'_T) (BootUnc_I``i''_W BootC_I``i''_W BootUnc_I``i''_T BootC_I``i''_T )
                                        }
                                }

                                keep BootC_I*_W BootC_I*_T BootUnc_I*_W BootUnc_I*_T
                                tempfile mst
                                save `mst'
                                use `Original'
                                merge 1:1 _n using `mst', nogenerate
                                tempfile Original
                                save `Original'

                        } /* if nboot*/
                        
                        /*TABLES*/
                        
                capture {
                        noisily {
                                return matrix Beta = `Beta'
                
                                return matrix Cov = `Cov'
                
                                return matrix schCov = `schCov'

                                return matrix UschCov = `UschCov'
                
                                return matrix SchEffects = `schRand'
                
                                forvalues i = 1/`=`max'-1' {
                                        matrix list `cond`i''
                                        return matrix `cond`i'' = `cond`i''
                 
                                        matrix list `uncond`i''
                                        return matrix `uncond`i'' = `uncond`i''
                                }
                        }
                }
        restore, not
        use `Original'
        }/*quietly*/

end



/*SUB-PROGRAMS*/

capture program drop gCondMST
program define gCondMST, rclass
version 15.1
syntax, res_variance2(name) vartt2(name) group_max(name) max(name) varb32(name) num(name) 
        
forvalues i = 1/`=`max'-1' {
        tempname M v`i'termW1 v`i'termW2 seW`i' LB_W`i' UB_W`i' gwithin`i' v`i'termT1 v`i'termT2 seT`i' LB_T`i' UB_T`i' gtotal`i' N`i'

        scalar dw`i' = Coef[`i',1]/sqrt(`res_variance2')
        matrix nt`i' = Br_F`i'[1...,2]                  /*Br_F1,2  contained in matrix.*/
        matrix nc`i' = Br_F`i'[1...,1]
        scalar elemvarE`i' = `varb32'[1,`i'] /*extract each element from matrix varB32 (=VarE) to use in mata for each iteration*/
        }
        
scalar `M'=`group_max'
mata: func2( "`num'", "`res_variance2'", "`vartt2'", "nt", "nc", "elemvarE")

forvalues i = 1/`=`max'-1' {
        tempname CondES`i'
        scalar `N`i'' = Nt`i' + Nc`i' /* is equivalent to N in g.within.mst*/
        scalar `v`i'termW1' = 1/sumforvtermW1`i'
        scalar `v`i'termW2' = ((dw`i'^2)/((2*`N`i''-4*`M')))
        scalar `seW`i'' = sqrt(`v`i'termW1' + `v`i'termW2')
        scalar `LB_W`i'' = (dw`i'-1.96*`seW`i'')
        scalar `UB_W`i'' = (dw`i'+1.96*`seW`i'')
        matrix `gwithin`i'' = (round(dw`i',.01),round(`LB_W`i'',.01),round(`UB_W`i'',.01))
        
        scalar dtTotal`i' = Coef[`i',1]/sqrt(`vartt2')
        scalar `v`i'termT1' = 1/sumforvtermT1`i'
        scalar `v`i'termT2' = ((dtTotal`i'^2)/((2*`N`i''-4*`M')))
        scalar `seT`i'' = sqrt(`v`i'termT1' + `v`i'termT2')
        scalar `LB_T`i'' = (dtTotal`i'-1.96*`seT`i'')
        scalar `UB_T`i'' = (dtTotal`i'+1.96*`seT`i'')
        matrix `gtotal`i'' = (round(dtTotal`i',.01),round(`LB_T`i'',.01),round(`UB_T`i'',.01))
        
        
        matrix `CondES`i'' = (`gwithin`i'' \ `gtotal`i'')
        matrix rownames `CondES`i'' = "Within" "Total"
        matrix colnames `CondES`i'' = "Estimate" "95% LB" "95% UB"
        
        return matrix CondES`i' = `CondES`i''
        scalar drop elemvarE`i' sumforvtermW1`i' sumforvtermT1`i' Nt`i' Nc`i'
        }
end

capture program drop gUncondMST
program define gUncondMST, rclass
version 15.1
syntax, RANdom(varlist fv) res_variance1(name) res_variance2(name) vartt2(name) vartt1(name) group_max(name) max(name) icc1(name) icc2(name) varb31(name) num(name)

tempname M
scalar `M'=`group_max'
quietly {
        forvalues i = 1/`=`max'-1' {
                        
                tempname MatNt`i' Nc`i' N`i' Nt`i' Mc`i' Mt`i' M`i'

                tempfile forloop
                save `forloop'

                /*tab `random' brokn_fctor`=`i'+1', matcell(Br_F`i')*/  /*because `=`max'-1' = 2 , broken factor is 1,2,3 but we need 2,3 because 1 is baseline*/
                svmat Br_F`i'

                total Br_F`i'1 /*Generate Nt`i', Nc`i' nt`i' and nc`i' again for the unconditional model */
                matrix `MatNt`i'' = e(b) 
                scalar `Nc`i'' = `MatNt`i''[1,1]

                total Br_F`i'2
                matrix `MatNt`i'' = e(b)
                scalar `Nt`i'' = `MatNt`i''[1,1]
                
                scalar `N`i'' = `Nc`i'' + `Nt`i''
                
        
                tab `random' brokn_fctor`=`i'+1' if brokn_fctor`=`i'+1'==1, matcell(nt`i') 
                scalar `Mt`i''= r(r) 
                
                tab `random' brokn_fctor`=`i'+1' if brokn_fctor`=`i'+1'==0, matcell(nc`i') 
                scalar `Mc`i''= r(r) 
                
                scalar `M`i'' = `Mc`i'' + `Mt`i''
                
                clear 
                use `forloop'
        
                }
        
        mata: func3("`num'", "nt", "nc")
                
        forvalues i = 1/`=`max'-1' {
        tempname UncondES`i' nsim1`i' nsim2`i' nsimTotal`i' vterm1`i' vterm2U`i' vterm3U`i' Uste`i' LUB`i' UUB`i' gUwithin`i' gUtotal`i' dtUTotal`i' B`i' ///
        At`i' Ac`i' A`i' vterm1Tot`i' vterm2UTot`i' vterm3UTot`i' steUTot`i' LUBtot`i' UUBtot`i' nut`i' nuc`i' dtU_1`i' dtU_2`i' 
        
                scalar dUw`i' = Coef[`i',1]/sqrt(`res_variance1')
                scalar `nsim1`i''     = (`Nc`i'' * sqnt`i')/(`Nt`i'' * `N`i'')
                scalar `nsim2`i''    = (`Nt`i'' * sqnc`i')/(`Nc`i'' * `N`i'')
                scalar `nsimTotal`i'' = `nsim1`i'' + `nsim2`i''
                scalar `vterm1`i''    = ((`Nt`i''+`Nc`i'')/(`Nt`i''*`Nc`i''))
                scalar `vterm2U`i''    = (((1+(`nsimTotal`i''-1)*`icc1'))/(1-`icc1'))
                scalar `vterm3U`i''    = ((dUw`i'^2)/(2*(`N`i''-`M`i'')))
                scalar `Uste`i''       = sqrt(`vterm1`i''*`vterm2U`i''+`vterm3U`i'')
                scalar `LUB`i''        = (dUw`i'-1.96*`Uste`i'')
                scalar `UUB`i''        = (dUw`i'+1.96*`Uste`i'')
                matrix `gUwithin`i''    = (round(dUw`i',.01), round(`LUB`i'',.01), round(`UUB`i'',.01))
                
                
                /*End of g.within*/
                
                /*g.total*/
                
                scalar `nut`i''     = ((`Nt`i''^2-sqnt`i')/(`Nt`i'' *( `Mt`i'' -1)))
                scalar `nuc`i''     = ((`Nc`i''^2-sqnc`i')/(`Nc`i'' *( `Mc`i'' -1)))
                scalar `dtU_1`i''  = Coef[`i',1]/sqrt(`vartt1')
                scalar `dtU_2`i''  = sqrt(1-`icc1'*(((`N`i''-`nut`i''*`Mt`i''-`nuc`i''*`Mc`i'')+`nut`i''+`nuc`i''-2)/(`N`i''-2)))
                scalar dtUTotal`i' = ( `dtU_1`i'' * `dtU_2`i'' )
                
                scalar `B`i''  = (`nut`i''*(`Mt`i''-1)+`nuc`i''*(`Mc`i''-1))
                scalar `At`i'' = ((`Nt`i'' ^2*sqnt`i'+(sqnt`i')^2-2* `Nt`i'' *qnt`i')/ `Nt`i'' ^2)
                scalar `Ac`i'' = ((`Nc`i''^2*sqnc`i'+(sqnc`i')^2-2* `Nc`i'' *qnc`i')/ `Nc`i'' ^2)
        
                scalar `A`i''  = (`At`i'' + `Ac`i'')
        
                scalar `vterm1Tot`i'' = (((`Nt`i''+`Nc`i'')/(`Nt`i''*`Nc`i''))*(1+(`nsimTotal`i''-1)*`icc1'))
                scalar `vterm2UTot`i'' = (((`N`i''-2)*(1-`icc1')^2+`A`i''*`icc1'^2+2*`B`i''*`icc1'*(1-`icc1'))*dtUTotal`i'^2)
                scalar `vterm3UTot`i'' = (2*(`N`i''-2)*((`N`i''-2)-`icc1'*(`N`i''-2-`B`i'')))
                scalar `steUTot`i''    = sqrt( `vterm1Tot`i'' + `vterm2UTot`i'' / `vterm3UTot`i'')
                scalar `LUBtot`i''     = (dtUTotal`i'-1.96* `steUTot`i'' ) 
                scalar `UUBtot`i''              = (dtUTotal`i'+1.96*`steUTot`i'')
                matrix `gUtotal`i'' = (round(dtUTotal`i',.01), round(`LUBtot`i'',.01), round(`UUBtot`i'',.01))
                
                
                
                matrix `UncondES`i'' = ( `gUwithin`i'' \ `gUtotal`i'' )
                matrix rownames `UncondES`i'' = "Within" "Total"
                matrix colnames `UncondES`i'' = "Estimate" "95% LB" "95% UB"
                
                return matrix UncondES`i' = `UncondES`i''
                
                scalar drop sqnt`i' sqnc`i' qnt`i' qnc`i'
                }

        tempname Cov Cov1 Cov2 
        matrix `Cov1' = (round(`res_variance2',.01),round(`vartt2',.01),round(`icc2',.01))
        matrix colnames `Cov1' = "Pupils" "Total" "ICC"
        matrix rownames `Cov1' = "Conditional"
        matrix `Cov2' = (round(`res_variance1',.01),round(`vartt1',.01),round(`icc1',.01))
        matrix colnames `Cov2' = "Pupils" "Total" "ICC"
        matrix rownames `Cov2' = "Unconditional"
        matrix `Cov' = `Cov1' \ `Cov2'
        
        return matrix Cov = `Cov'
        
        tempname UschCov
        matrix `UschCov' = `varb31'
        matrix rownames `UschCov' = "Unconditional"
        matrix colnames `UschCov' = "School"
        
        return matrix UschCov = `UschCov'
        }
end

capture program drop gCondUncondMST
program define gCondUncondMST, rclass
version 15.1
syntax, j(numlist) Intervention(varlist fv) RANdom(varlist fv) res_variance1(name) res_variance2(name) group_max(name) max(name) vartt1(name) ///
vartt2(name) num(name) icc1(name)

forvalues i = 1/`=`max'-1' {
		tempname dwC`i'`j' dtTotalC`i'`j'
        scalar `dwC`i'`j'' = Coef[`i',1]/sqrt(`res_variance2')
        scalar `dtTotalC`i'`j''  = Coef[`i',1]/sqrt(`vartt2')
		
		return scalar dwC`i'`j' = `dwC`i'`j''
		return scalar dtTotalC`i'`j' = `dtTotalC`i'`j''
        }
        
        
        forvalues i = 1/`=`max'-1' {
        tempname MatNt`i' Nc`i' N`i' Nt`i' Mc`i' Mt`i' M`i'
        tempfile forloop2
        save `forloop2'
        
        svmat Br_F`i'

        total Br_F`i'1 
        matrix `MatNt`i'' = e(b) 
        scalar `Nc`i'' = `MatNt`i''[1,1]

        total Br_F`i'2
        matrix `MatNt`i'' = e(b)
        scalar `Nt`i'' = `MatNt`i''[1,1]

        scalar `N`i'' = `Nc`i'' + `Nt`i''


        capture tab `random' brokn_fctor`=`i'+1' if brokn_fctor`=`i'+1'==1, matcell(nt`i')
        scalar `Mt`i''= r(r)

        capture tab `random' brokn_fctor`=`i'+1' if brokn_fctor`=`i'+1'==0, matcell(nc`i')
        scalar `Mc`i''= r(r)
        
        scalar `M`i'' = `Mc`i'' + `Mt`i''

        clear
        use `forloop2'
        }

mata: func3("`num'", "nt", "nc")

forvalues i = 1/`=`max'-1' {
        tempname nut`i' nuc`i' dt_1U`i'`j' dt_2U`i' dwU`i'`j' dtTotalU`i'`j'
        
        scalar `dwU`i'`j''  = Coef[`i',1]/sqrt(`res_variance1')
        scalar `nut`i''     = ((`Nt`i''^2-sqnt`i')/(`Nt`i''*(`Mt`i''-1)))
        scalar `nuc`i''     = ((`Nc`i''^2-sqnc`i')/(`Nc`i''*(`Mc`i''-1)))
        scalar `dt_1U`i'`j''      = Coef[`i',1]/sqrt(`vartt1')
        scalar `dt_2U`i''      = sqrt(1-`icc1'*(((`N`i''-`nut`i''*`Mt`i''-`nuc`i''*`Mc`i'')+`nut`i''+`nuc`i''-2)/(`N`i''-2)))
        scalar `dtTotalU`i'`j''  = (`dt_1U`i'`j'' * `dt_2U`i'')
        
        scalar drop sqnt`i' sqnc`i' qnt`i' qnc`i'
		
		return scalar dwU`i'`j' = `dwU`i'`j''
		return scalar dtTotalU`i'`j' = `dtTotalU`i'`j''
        }
		
end
        

capture program drop baseset
program define baseset, rclass
syntax, max(name) INTervention(varlist fv)

        if regexm("`intervention'", "bn\.") | regexm("`intervention'", "^i\(?([0-9] ?)+\)?\.") {
        noi disp as error "i(numlist) not allowed; you must specify a base level"
        error 198
        }

        local refcat
        if regexm("`intervention'", "([0-9]?)[ ]*\.") local refcat = regexs(1) 
        local allow opt1
                
        if "`refcat'" == "" {
                if regexm("`intervention'", "\(\#*([0-9]?)\)[ ]*\.") local refcat = regexs(1)
                if "`refcat'"!="" local allow opt2
        }
        if "`refcat'" == "" {
                if regexm("`intervention'", "\(([a-zA-Z]+)*\)\.") local refcat = regexs(1)
                if "`refcat'"!="" local allow opt3
                }
        
        fvrevar `intervention', list
        local intervention `r(varlist)'

        levelsof `intervention', local(levels)
        tokenize `levels'
        
        tempname min Max
        scalar `min'=`1'
        scalar `Max' = ``=`max'''
        
        if "`allow'" == "opt1" { 
                forvalues i=1/`=`max'' {
                        cap if "`refcat'" != "``i''" local s = `s'+1 /*checking cases were intervention is irregular (i.e. 1 4 9) and user has specified a number of baseline that is not 1,4 or 9 and not below
>  1 and not above 9*/
                        }
                if "`refcat'" != "" {
                        if "`refcat'">"`=`Max''" | "`refcat'"<"`=`min''" | "`s'" == "`=`max''" {
                        noi disp as error "{bf:Warning:} selected baseline level `refcat' is out of bounds; level `=`Max'' chosen as baseline"
                                }
                        }
                else {
                        local refcat = `=`min''
                }
                if "`s'" == "`=`max''" & "`refcat'" != "`=`min''" {
                        local refcat = `=`Max''
                        }
        
                if "`refcat'" != "" {
                fvset base `refcat' `intervention'
                }
        }
        else if "`allow'"=="opt2" {
                fvset base ``refcat'' `intervention'
                local refcat = ``refcat''
                }
        else if "`allow'"=="opt3" {
                fvset base `refcat' `intervention'
                if strpos("`refcat'","first") >0 {
                local refcat = `=`min''
                }
                if strpos("`refcat'","last") >0 {
                local refcat = `=`Max''
                }
                if strpos("`refcat'","freq")>0 {
                tempname maximum z
                tab `intervention', matcell(`maximum')
                mata: st_local("matr", strofreal(max(st_matrix("`maximum'"))))
                forvalues i = 1/`=`max''{
                scalar `z' = `maximum'[`i',1]
                if "`matr'"== "`=`z''" local refcat = ``i''
                                }
                        }
                }
                return local refcat = `refcat'
                end