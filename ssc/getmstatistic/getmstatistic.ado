capture program drop getmstatistic
*! getmstatistic v0.1.1 LEMagosi 18july2018
*  fixed a small bug where the expected standard deviation of the M statistic differed 
*  depending on whether the last study evaluated in a meta-analysis had missing variants.
*  Details of revision provided at end of program

*  getmstatistic v0.1.0 LEMagosi 25may2016
program define getmstatistic, rclass
    version 10.0
    syntax varlist(min=4 max=4) [if] [in] [, noPRInt LATexout NOGRaph SAVEdataset MM REML EB]
    *marksample touse
    tokenize `varlist'

    preserve
            
    /* Identifies samples for computation based on [if] [in] */

    if "`if'`in'" != "" {
    
        keep `if' `in'   
    }
        

     /* Check data types for input variables */
    

        capture confirm numeric variable `1' `2'
        if _rc!=0 {
        display "Error: beta and its corresponding standard error should be of type double"
        exit _rc
        }
        
        capture confirm string variable `3' `4'
        if _rc!=0 {
        display "Error: variant and study names should be of type string"
        exit _rc
        }


    /* Check whether a specific method has been selected for estimation of tau2 */
    local wc : word count "`mm' `reml' `eb'"
    if `wc' > 1 {
    
        di as error "Either mm or reml can be specified, but not both"
        exit 198
        
        }

    if ("`mm'" == "" & "`reml'" == "" & "`eb'" == "") { /* mm is the default metareg_method */
        
        local metareg_method "mm"
        di as text "tau2 estimated by default method: `metareg_method'"

        
        }


    if ("`mm'" != "") { /* applying method-of_moments option as metareg_method */
        
        local metareg_method "mm"
        di as text "Using option: method-of-moments to estimate tau2"
        
    }
        
    else if ("`reml'" != "") { /* applying reml option as metareg_method */
        
        local metareg_method "reml"
        di as text "Using option: residual maximum likelihood to estimate tau2"
        
    }


    else if ("`eb'" != "") { /* applying eb option as metareg_method */
        
        local metareg_method "eb"
        di as text "Using option: empirical bayes to estimate tau2"
        
    }
    

    /* Main code: Compute the multi-variant heterogeneity statistic (M) */
    
    quietly {
    

                /*
                 * Required variable  Type       Comment
                 * beta               double     effect-size
                 * se                 double     lambda corrected std error for beta
                 * variants           string     rsID
                 * studies            string     names of participating studies
                 *
                 * Usage:
                 * getmstatistic beta se variants studies
                 * getmstatistic beta se variants studies [, noPRInt LATEXOUT NOGRAPH]
                 */
 
                /*
                Expectations: 
                1. M identifies outlier studies showing systematically stronger or weaker effects than
                average. 
                2. M delineates the direction of effects of the outlier studies.                  
                */

                set more off

                *assign user arguments to macros 
                local beta `1'
                local se_lambda_corr `2'
                local variants `3'
                local studies `4'


                *assign study numbers
                egen study = group(`studies')

                *calculate no. of studies and assign the value to the macro nstudies
                quietly: duplicates report study
                local nstudies = r(unique_value)


                *assign snp numbers
                egen snp = group(`variants')

                *calculate no. of snps and assign the value to the macro nsnps
                quietly: duplicates report snp
                local nsnps = r(unique_value)


                di "Summary: Heterogeneity analysis is based on `nsnps' SNPs and `nstudies' studies"


                ***************** end of part 1: assign snp and study numbers     ****************
                

                *align study effects i.e. betas
                foreach snp of numlist 1(1)`nsnps' {
                quietly: metareg `beta' if snp == `snp',wsse(`se_lambda_corr') `metareg_method'
                matrix B = e(b)
                local ES B[1,1]
                if `ES'<0 replace `beta' = -`beta' if snp == `snp'
                }

                *run metareg to extract standardized predicted random effects(SPREs) i.e. usta
                gen xb = .
                gen usta = .
                gen xbu = .
                gen stdxbu = .
                gen hat = .
                gen tau2 = .
                gen I2 = .
                gen Q = .

                foreach snp of numlist 1(1)`nsnps' {
                quietly: metareg `beta' if snp == `snp',wsse(`se_lambda_corr') `metareg_method'
                quietly: replace tau2 = e(tau2) if e(sample)
                quietly: replace I2 = e(I2) if e(sample)
                quietly: replace Q = e(Q) if e(sample)
                quietly: predict b if e(sample),xb
                quietly: predict x if e(sample),ustandard
                quietly: predict y if e(sample),xbu
                quietly: predict z if e(sample),stdxbu
                quietly: predict h if e(sample),hat
                quietly:replace xb = b if snp == `snp'
                quietly:replace usta = x if snp == `snp'
                quietly:replace xbu = y if snp == `snp'
                quietly:replace stdxbu = z if snp == `snp'
                quietly:replace hat = h if snp == `snp'
                drop x y z h b

                }

                ***** end of part 2: run metareg to extract tau2, I2, Q, usta, xb, xbu, stdxbu and hat ***

                *Computing M statistic (usta_mean)

                *Mstat: aggregate the ustas by taking the mean and calculate CI
                gen usta_mean = .
                gen usta_sd = .
                gen ustamean_se = .
                gen lowerbound = .
                gen upperbound = .
                
                label variable usta_mean "Mstatistic"
                label variable lowerbound "usta_mean 95% CI lowerbound"
                label variable upperbound "usta_mean 95% CI upperbound"


                foreach study of numlist 1(1) `nstudies' {
                quietly: summ usta if study == `study'
                local umean = r(mean)
                local uobs = r(N)
                if (`uobs' == 1) {
                    local usd = 0
                } 
                else {    
                    local usd = r(sd)               
                    }
                
                cii `uobs' `umean' `usd', level(95)
                di "completed study: `study'"        

        
                *Top up allocates missing snps the average mean and sd 
                *local topup = (`nsnps'-`uobs')*(1/`nsnps')*0
                local topup = (`nsnps'-`uobs')*((1/`nsnps')*0)


                local ulb = r(lb)
                local uub = r(ub)
                local ustderr = r(se)
                quietly:replace usta_mean = `umean' + `topup' if study == `study'
                quietly:replace usta_sd = `usd' if study == `study'
                quietly:replace ustamean_se = `ustderr' if study == `study'
                quietly:replace lowerbound = `ulb' if study == `study'
                quietly:replace upperbound = `uub' if study == `study'
                di "Mstatistic for study `study' is: `umean'"
                }


                *The expected mean under the Ho:
                *local Mmu = 50*(1/50)*0
                local Mmu = `nsnps'*(1/`nsnps')*0

                *The expected spread under the Ho:
                *local Msd = ((50*(1/50)^2)*1)^0.5
                local Msd = ((`nsnps'*(1/`nsnps')^2)*1)^0.5

                di _n
                di "expected mean M statistic = `Mmu', SD = `Msd', Snps = `nsnps'"


                *Ranking M statistics
                *sort aggregated ustas to determine rank
                sort usta_mean
                egen rank = group(usta_mean)


                **** end of part 3:calculate Mstatistic (ustamean) i.e. aggregate ustas into means ******


                local alpha = 0.05

                generate pval_ustamean = .
                label variable pval_ustamean "un-corrected pvalue for Mstatistic"

                generate bonfpval_ustamean = .
                label variable bonfpval_ustamean "2-sided bonferroni corrected pvalue for Mstatistic" 

                gen zustamean = (usta_mean - `Mmu')/`Msd'


                *using 2sided pval
                quietly: replace pval_ustamean = 2*(normal(-abs(zustamean)))
                quietly: replace bonfpval_ustamean = pval_ustamean * `nstudies'
                quietly: replace bonfpval_ustamean = 1 if bonfpval_ustamean > 1
                qqvalue pval_ustamean,method(simes) qvalue(q_simes_ustamean)
        

                local zustamean_threshold = invnormal((`alpha'/`nstudies')/2)


                di "critical z-value: `zustamean_threshold'"


                local Mstatistic_threshold = (`zustamean_threshold' * `Msd') + `Mmu'

                di "critical M statistic value: `Mstatistic_threshold'"


                *** end of part 4b:Generate ustamean bonf_pvalues and calculate Mstatistic (usta_mean) threshold ***


                *Compute average variant effect size

                gen study_mean_beta = .
                gen study_N_beta = .

                *mean variant/snp effect size per study
                tabstat `beta', by (study) stat(mean n) save


                foreach study of numlist 1(1) `nstudies' {


                matrix mean_beta_mat=r(Stat`study')  // has 1 column (beta) and 2 rows(mean, N)

                local mean_beta=mean_beta_mat[1,1] // mean beta for the study
                local N_beta=mean_beta_mat[2,1] // N number of variants/snps

                di "`mean_info'"

                quietly: replace study_mean_beta = `mean_beta' if study == `study'
                quietly: replace study_N_beta = `N_beta' if study == `study'
                        }  // end of loop: that finds the mean variant/snp effect size in each study


                *take anti log of beta(log odds ratio) to determine the percentage strength of the outlier i.e.
                * how much more stronger the outlier is than average
                gen oddsratio = exp(study_mean_beta)    


                ***** end of part 4:calculate average variant effect size for each study *****************



    }



        rename usta_mean Mstatistic
        rename ustamean_se M_se
        rename usta_sd M_sd
        rename bonfpval_ustamean bonfpvalue
        rename study_mean_beta average_variant_effectsize


    /* Save results: save M statistic results */

        *generate timestamp
        local c_date = c(current_date)
        local c_time = c(current_time)

        local c_time_date = "`c_date'"+"_"+"`c_time'"
        local time_string = subinstr("`c_time_date'", ":", "_", .)
        local time_string = subinstr("`time_string'", " ", "_", .)
    
    if ("`savedataset'" == "savedataset") {
 
                *labeling the variables for easy comprehension
                label variable tau2 "tau_squared, estimates of between-study heterogeneity"
                label variable I2  "I_squared, proportion of total variation due to between study variance"
                label variable Q "Cochran's Q"
                label variable xb "fitted values excluding random effects"
                label variable usta "standardized predicted random effect (SPRE)"
                label variable xbu "fitted values including random effects"
                label variable stdxbu "standard error of prediction (fitted values) including random effects"
                label variable hat "diagonal elements of the projection hat matrix"
                label variable average_variant_effectsize "mean of beta values in each study"
                label variable oddsratio "average variant effect size expressed as oddsratio"
                label variable M_se "M statistic standard errors"
                label variable M_sd "M statistic standard deviations"
                label variable study "study number"
                label variable snp "variant number"
   
        savesome Mstatistic M_se M_sd `beta' `se_lambda_corr' `variants' `studies' lowerbound upperbound bonfpvalue tau2 I2 Q xb usta xbu stdxbu hat study snp average_variant_effectsize oddsratio using Mstatistic_results_`time_string'.dta
        
        }


    /* Print results: identify and display outlier studies */
    
    
    if ("`print'" != "noprint") {
    
                di as text _n "Multi-variant heterogeneity statistic (M)" 
                
                di as text _n "Number of variants = " as result %7.0f `nsnps' /*
                */ _col(55) as text "Number of studies = " _col(70) as result %7.0f `nstudies'
                
                di as text "Expected Mean = " as result %12.4g `Mmu' /*
                */ _col(55) as text "Expected SD = " _col(70) as result %12.4g `Msd'

                di as text "M critical = +/-" as result %12.4g abs(`Mstatistic_threshold') /*
                */ _col(55) as text "(alpha = 0.05, 2-sided Bonferroni correction)"
                
                
                
                if (`Mstatistic_threshold' > 0) {
                    di as text _n "Influential studies (Systematically stronger than average)"
                    capture tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic >= `Mstatistic_threshold', by(`studies') nototal stat(mean)
                    if (_rc == 0) {
                            tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic >= `Mstatistic_threshold', by(`studies') nototal stat(mean)
                        }
                        else {
                            di as result "No influential studies found at alpha = 0.05"
                        }                   
                        
                        di as text _n "Underperforming studies (Systematically weaker than average)"
                        capture tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic <= -`Mstatistic_threshold', by(`studies') nototal stat(mean)
                        if (_rc == 0) {
                            tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic <= -`Mstatistic_threshold', by(`studies') nototal stat(mean)                  
                        }
                        else {
                            di as result "No underperforming studies found at alpha = 0.05"
                        }                   
                    
                    }
                    
                    else {
                    
                    di as text _n "Underperforming studies (Systematically weaker than average)"
                    capture tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic <= `Mstatistic_threshold', by(`studies') nototal stat(mean)
                    if (_rc == 0) {
                            tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic <= `Mstatistic_threshold', by(`studies') nototal stat(mean)
                        }
                        else {
                            di as result "No underperforming studies found at alpha = 0.05"
                            }               
                        
                        di as text _n "Influential studies (Systematically stronger than average)"
                        capture tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic >= -`Mstatistic_threshold', by(`studies') nototal stat(mean)
                        if (_rc == 0) {
                            tabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic >= -`Mstatistic_threshold', by(`studies') nototal stat(mean)
                        }
                        else {
                            di as result "No influential studies found at alpha = 0.05"
                        }                   
                    
                    } //end of if: (`Mstatistic_threshold' > 0)
                
                
                
                if ("`latexout'" == "latexout") {
                
                    di as text _n "Displaying latex output: "
                                
                        if (`Mstatistic_threshold' > 0) {
                                di as text _n "Influential studies (Systematically stronger than average)"
                                capture latabstat Mstatistic lowerbound upperbound bonfpvalue if usta_mean >= `Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Underperforming studies showing \\ systematically weaker effects than average)
                                if (_rc == 0) {
                                    latabstat Mstatistic lowerbound upperbound bonfpvalue if usta_mean >= `Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Underperforming studies showing \\ systematically weaker effects than average)
                                }
                                else {
                                    di as result "No influential studies found at alpha = 0.05"
                                }                   
                        
                                di as text _n "Underperforming studies (Systematically weaker than average)"
                                capture latabstat Mstatistic lowerbound upperbound bonfpvalue if usta_mean <= -`Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Influential studies showing \\ systematically stronger effects than average)
                                if (_rc == 0) {
                                latabstat Mstatistic lowerbound upperbound bonfpvalue if usta_mean <= -`Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Influential studies showing \\ systematically stronger effects than average)
                                }
                                else {
                                    di as result "No underperforming studies found at alpha = 0.05"
                                }           
                        
                                }
                        
                                else {
                            
                            di as text _n "Underperforming studies (Systematically weaker than average)"
                            capture latabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic <= `Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Underperforming studies showing \\ systematically weaker effects than average)
                            if (_rc == 0) {
                                    latabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic <= `Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Underperforming studies showing \\ systematically weaker effects than average)
                                }
                                else {
                                        di as result "No underperforming studies found at alpha = 0.05"
                                        }                   
                        
                                di as text _n "Influential studies (Systematically stronger than average)"
                                capture latabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic >= -`Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Influential studies showing \\ systematically stronger effects than average)
                                if (_rc == 0) {
                                        latabstat Mstatistic lowerbound upperbound bonfpvalue if Mstatistic >= -`Mstatistic_threshold', by(`studies') nototal stat(mean) cap(Influential studies showing \\ systematically stronger effects than average)           
                                }
                                else {
                                        di as result "No influential studies found at alpha = 0.05"
                                }                   
                                } // end of if: (`Mstatistic_threshold' > 0)
                                
                        } // end of if: ("`latexout'" == "latexout")

                    
                } // end of if: ("`print'" != "noprint")


    /* Generate plots */        

    if ("`nograph'" != "nograph") {
    

        *generate lines marking 5 percent significance threshold
        local line1 `Mstatistic_threshold'
        local line2 = -1 * `Mstatistic_threshold'
    
                *plot M statistic(usta_mean) against average variant effect size
                scatter Mstatistic average_variant_effectsize, xscale(log) mlabel(study) yline(`line1' `line2', lcolor(gs15)) ylabel(, nogrid) xtitle("Average variant effect-size (log oddsratio)") graphregion(color(gs15)) mcolor(gs12) mlabcolor(gs4) name("M_nobars_`time_string'")
                *twoway (scatter Mstatistic average_variant_effectsize, xscale(log) mlabel(study) yline(`line1' `line2', lcolor(gs15)) ylabel(, nogrid) ytitle("M statistic") xtitle("Average variant effect-size (log oddsratio)") graphregion(color(gs15)) mcolor(gs12) mlabcolor(gs4)) (rcap upperbound lowerbound average_variant_effectsize, lcolor(gs13) lwidth(vthin)), legend(off) name("M_`time_string'")


                *Generate a histogram of the M statistics
                twoway histo Mstatistic, name("M_histogram_`time_string'")
                 
    
        }



    /* Stored results */
    
        return scalar number_variants = `nsnps'
        return scalar number_studies = `nstudies'
        return scalar M_expected_mean = `Mmu'
        return scalar M_expected_sd = `Msd'
        return scalar M_critical_alpha_0_05 = `Mstatistic_threshold'
        return local `varlist'
        
    restore
    
*And that's all folks

end


exit

//    getmstatistic update
//    v0.1.1 LEMagosi 18july2018
//    Fixes:
//    local topup = (`nsnps'-`uobs')*((1/`uobs')*0) has now become: local topup = (`nsnps'-`uobs')*((1/`nsnps')*0)
//    local Mmu = `nsnps'*(1/`uobs')*0              has now become: local Mmu = `nsnps'*(1/`nsnps')*0
//    local Msd = ((`nsnps'*(1/`uobs')^2)*1)^0.5    has now become: local Msd = ((`nsnps'*(1/`nsnps')^2)*1)^0.5

