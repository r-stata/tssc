*! version 17feb09

program define icc23, rclass
   version 9
   syntax varlist(min=3 max=3) [if] [, MOdel(integer 2) LEvel(real .95)]
   tokenize "`varlist'"
   marksample touse

   local dv `1'
   local rater `2'
   local id `3'

   capture assert `model'==2 |`model'==3
   	if _rc~=0 {
	di
	di in re "The ICC model must be specified as either 2 or 3"
	exit 198
	}

   capture assert `level'>0 & `level'<1.0
   	if _rc~=0 {
	di
	di in re "The CI level must be a value between 0 and 1.0"
	exit 198
	}

   qui anova `dv' `rater' `id' `if', repeated(`rater') 

   local f1 e(F_1)
   local ss2 e(ss_2)
   local df2 e(df_2)
   local rss e(rss)
   local dfr e(df_r)
   local df1 e(df_1)
   local ss1 e(ss_1)
   local n e(N_bse)    /* the number of subjects tested */
   local k = `df1'+1   /* the number of raters */

*Compute F-test for rater
   local p_rater=Ftail(`df1',`dfr',`f1')

*Compute components of ICC

   local bms = `ss2'/`df2'
   local ems = `rss'/`dfr'
   local jms = `ss1'/`df1'
   local Fj = `jms'/`ems'
   local alpha2 =1-((1-`level')/2)
   local cilevel = `level'*100
   
   
   if `model' == 2 {

    *Compute ICC Model 2 for single observations (ICC21) and for means (ICC2k)
     
        local num21  = `bms'-`ems'
           local dentmp = (`k'*(`jms'-`ems'))/`n'  /* the ratio within the denominator */
        local den21  = `bms'+(`k'-1)*`ems'+`dentmp'
        local icc21 = `num21'/`den21'
        
    *Compute ICC21 confidence intervals (values will be used for ICC2k confidence intervals)

        local nu_num21 = (`k'-1)*(`n'-1)*(`k'*`icc21'*`Fj'+`n'*(1+(`k'-1)*`icc21')-`k'*`icc21')^2
        local nu_den21 = (`n'-1)*(`k'^2)*((`icc21')^2)*((`Fj')^2)+(`n'*(1+(`k'-1)*`icc21')-`k'*`icc21')^2
        local nu21 = `nu_num21'/`nu_den21'
        local Fsuper = invF(`df2',`nu21',`alpha2')
        local Fsub = invF(`nu21',`df2',`alpha2')    
        local cilower = (`n'*(`bms'-`Fsuper'*`ems'))/(`Fsuper'*(`k'*`jms'+(`k'*`n'-`k'-`n')*`ems')+`n'*`bms')
        local ciupper = (`n'*(`Fsub'*`bms'-`ems'))/(`k'*`jms'+(`k'*`n'-`k'-`n')*`ems'+`n'*`Fsub'*`bms')   

    *Compute ICC2k and its confidence intervals
        local num2k  = `bms'-`ems'
           local dentmp1 = (`jms'-`ems')/`n'  /* the ratio within the denominator */
        local den2k  = `bms'+`dentmp1'
        local icc2k = `num2k'/`den2k'
        local cilowerK = (`k'*`cilower')/(1+(`k'-1)*`cilower')
        local ciupperK = (`k'*`ciupper')/(1+(`k'-1)*`ciupper')

     di
     di in gr "        **************************************************************************"
     di in ye "                    Two-Way Random Effects Models: ICC[2,1] and ICC[2,k]"
     di in gr "        **************************************************************************"
     di
     di in gr "                          The total number of subjects is: " in ye %3.0f `n'
     di in gr "                            The total number of raters is: " in ye %3.0f `k'
     di
     di in gr "          Reliability of observations:  ICC[2,1] = " in ye %4.3f `icc21' ", (" `cilevel' "% CI: " %5.3f `cilower' ", " %5.3f `ciupper' ")"
     di
     di in gr "              Reliability of the mean:  ICC[2,`k'] = " in ye %4.3f `icc2k' ", (" `cilevel' "% CI: " %5.3f `cilowerK' ", " %5.3f `ciupperK' ")"
     di
     di in gr "        **************************************************************************"
     di
        if `p_rater' <= .05 {
        di in red "                   Note: There is a significant `rater' effect: p = " %5.4f `p_rater'
        }
     }

   if `model' == 3 {

    * Compute ICC31
    
     local num31  = `bms'-`ems'
     local den31 = `bms'+(`k'-1)*`ems'
     local icc31 = `num31'/`den31'

    *Compute ICC Model 3 Confidence Interval (Single Observations)
    
     local fzero = `bms'/`ems'
     local fdistL = invF(`n'-1,(`n'-1)*(`k'-1),`alpha2')
     local fdistU = invF((`n'-1)*(`k'-1),`n'-1,`alpha2')
     local FL = `fzero'/`fdistL'
     local FU = `fzero'*`fdistU'
     local cilower = (`FL'-1)/(`FL'+(`k'-1))
     local ciupper = (`FU'-1)/(`FU'+(`k'-1))
     
     *Compute ICC3k
     
     local num3k  = `bms'-`ems'
     local den3k  = `bms'
     local icc3k = `num3k'/`den3k'
     
     *Compute ICC3k confidence intervals
     
     local cilowerK = 1-(1/`FL')
     local ciupperK = 1-(1/`FU')
    
        di
        di in gr "        **************************************************************************"
        di in ye "                    Two-Way Mixed Effects Models: ICC[3,1] and ICC[3,k]"
        di in gr "        **************************************************************************"
        di
        di in gr "                          The total number of subjects is: " in ye %3.0f `n'
        di in gr "                            The total number of raters is: " in ye %3.0f `k'
        di
        di in gr "          Reliability of observations:  ICC[3,1] = " in ye %4.3f `icc31' ", (" `cilevel' "% CI: " %5.3f `cilower' ", " %5.3f `ciupper' ")"
        di
        di in gr "              Reliability of the mean:  ICC[3,`k'] = " in ye %4.3f `icc3k' ", (" `cilevel' "% CI: " %5.3f `cilowerK' ", " %5.3f `ciupperK' ")"
        di
        di in gr "        **************************************************************************"
        di

        if `p_rater' <= .05 {
           di in red "                   Note: There is a significant `rater' effect: p = " %5.4f `p_rater'
        }
     }
end
