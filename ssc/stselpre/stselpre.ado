*! version 1.2.1  10feb2010
program define stselpre, eclass

*! Cox model with Self Prentice variance estimate for case-cohort design
*! Syntax: varlist(min=1) [if] [in] [ ,
*!         SELF to save estimates as in Self Prentice scheme
*!         noHR Level(integer $S_level) noSHow BRESlow EFRon EXACTM EXACTP FORCE]
*!         STRata(varnames) - Added 07Apr2003
*  Enzo Coviello (enzo.coviello@alice.it)

	version 6.0
        if replay() {
		if `"`e(cmd)'"' ~= "stselpre" { 
			error 301
		}
		syntax [, Level(integer $S_level) noHR ]
		if "`hr'"==""{
			local eform "eform(Haz. Ratio)"
		}
		di _n in gr "Self Prentice Variance Estimate for Case-Cohort Design"
        	di _n in gr "`e(scheme)' Scheme" _n
		estimates display, level(`level') `eform'
		exit
	}
	
	st_is 2 analysis

        syntax varlist(min=1) [if] [in] [, /*
        */ noHR Level(integer $S_level) STRata(varlist max=5) /*
        */ noSHow BRESlow EFRon EXACTM EXACTP SELF FORCE ]
        
	if "`_dta[wBarlow]'" == "" | "`_dta[wSelPre]'" == "" | /*
	   */ "`_dta[Subco]'" == "" { 
		if "`force'"=="" { /*
           */ di in re _n "Data do not appear processed by stcascoh" /*
           */ " or were corrupted"
                exit 459
		}
        }

        local id : char _dta[st_id]
        local event : char _dta[st_bd]
        local timeto : char _dta[st_bt]
        local t_ent : char _dta[st_enter]
        local t_int : char _dta[st_bt0]
        local sub : char _dta[Subco]
        local sel : char _dta[wSelPre]
        local barl : char _dta[wBarlow]
        local oldev: char _dta[Oldev]
        local oldti: char _dta[Oldti]
        cap confirm var `sub' `sel' `barl'
        if _rc { di _n in re "Some variables created by stcascoh" /*
	         */ " have been deleted"
                 exit 459
	} 

        local ties = trim("`efron' `breslow' `exactp' `exactm'")
	if "`ties'" =="" {
		local ties "efron"
	}
        if "`strata'" !="" {
                local strmes "Stratified by `strata'"
                local strata "strata(`strata')"
	}

        tempvar touse n_id
	st_smpl `touse' `"`if'"' `"`in'"' 
	markout `touse' `varlist'
	st_show `show'

        preserve
        qui {
              keep if `touse'
              count if `event' & `sub'==1
              local subev = r(N)
              drop `barl'
              cap confirm var `oldti'
              if ~_rc { drop `oldti' }
              cap confirm var `oldev'
              if ~_rc { drop `oldev' }
              local n = _N
              stjoin     /* Therneau's scheme requires no splitting of records */
              if `n' - _N < `subev' & "`force'"==""{ 
                      di in re _n "Data were corrupted from previous stcascoh" 
                      error 459
              }
              stcox `varlist', `ties' `strata'
              local N_Pre = e(N)
              local subj = e(N_sub)
              tempname b_Pre b_Sel 
              mat `b_Pre' = get(_b) /* save b estimates as in Prentice scheme */
	
	      /* prepare dataset for Self Prentice method to reproduce
		    delta-betas estimates as in Therneau (LDA 1999) */
              egen long `n_id' = group(`id')
              expand 2 if `event' & `sub'==1  /* sub-cases are now double */
              replace `n_id' = `n_id' * 2
              
	      /* all cases must have weight -100 */
              sort `id' `event'
              by `id': replace `sel'=-100 if `event' & _n==_N 
              by `id': replace `event'=0 if ~`sel' & _n==_N-1
              
	      /* set id cases to a different (odd) id: observations in 
              Self Prentice scheme are larger than in Prentice */
              by `id': replace `n_id' = `n_id' + 1 if `sel'==-100
              stset `timeto',f(`event') id(`n_id') enter(`t_ent') time0(`t_int')
        }

        qui Self `sel' `varlist', `ties' `strata'

        di _n in gr "Method for ties: `ties'"
        di _n in gr "Self Prentice Variance Estimate for Case-Cohort Design"
        di _n in gr "Self Prentice Scheme" _n
        if "`hr'" == ""{
		local eform "eform(Haz. Ratio)"
        }
        estimates display, `eform' level(`level') 
        mat `b_Sel' = get(_b)
	
	/* displaying Prentice estimates. Variance is the same as in Self */
	estimates repost b = `b_Pre'

        di _n(2) in gr "Prentice Scheme" _n
	estimates display, `eform' level(`level')
        di in gr _skip(58) "`strmes'"
	local hold Prentice
	/* save estimates as in Self Prentice scheme */
	if "`self'" != "" {
                local hold "Self Prentice"
                estimates repost b = `b_Sel'
	}
        else {est sca N = `N_Pre'} /* in Prentice observations are less */
	restore
	estimates repost, esample(`touse')
        est sca N_sub = `subj'
        est local scheme "`hold'"
        est local predict stcox_p
	est local ties "`ties'"
	global S_E_cmd "stselpre"         /* double save */
        est local cmd "stselpre"
end

program define Self /* delta-beta are estimated as in stdb */
        gettoken self 0 : 0
        syntax varlist(min=1) , * 
	local id : char _dta[st_id]
        local event : char _dta[st_bd]
        local timeto : char _dta[st_t]
        local alpha : char _dta[Alpha]
        tokenize `varlist'
        local nv 1
        local ulist ""
        while "``nv''" ~= ""{
                tempvar u`nv'
                local ulist "`ulist' `u`nv''"
                local nv=`nv'+1
        }
        stcox `varlist', offset(`self') `options' esr(`ulist')
        local N_Sel = e(N) 
        tempname V b junk DB
        matrix `V' = get(VCE)
        matrix `b' = get(_b)
        local i 1
        matrix accum `junk'=`ulist', nocons
        local nn : colnames(`junk')
        matrix colnames `V' =`nn'
        tempvar n_rec
	sort `id' `event'

	/* multiple records per subject should be allowed */ 
	by `id': gen `n_rec' = _n
	local i 1
        quietly {
                while "``i''" ~= ""{
                	tempvar d`i' t`i'
                	local namei "`d`i''"
                	matrix define v`i'=`V'[`i',1...]
                	matrix score `namei' = v`i' 
                        egen `t`i''=sum(`namei'), by(`id')
                        local db "`db' `t`i''"
                        local i = `i'+1
                }
                matrix accum `DB' = `db' if ~`event' & `n_rec'==1, noc
                matrix `DB' = (1 - `alpha') * `DB'
                mat `V' = `V' + `DB'
        }
        local nn : colnames(`b')
        matrix colnames `V' = `nn'
        matrix rownames `V' = `nn' 
        estimates post `b' `V', obs(`N_Sel')
end

exit



. qui stcascoh stage histo, a(20) seed(1234)

. xi: stselpre i.stage*i.histol, nohr 
i.stage               Istage_1-4   (naturally coded; Istage_1 omitted)
i.histol              Ihisto_1-2   (naturally coded; Ihisto_1 omitted)
i.stage*i.histol      IsXh_#-#     (coded as above)


         failure _d:  _d
   analysis time _t:  _t
  enter on or after:  time _t0
                 id:  seqno

Assumed Efron method for ties

Self Prentice Variance Estimate for Case-Cohort Design

Self Prentice Scheme

------------------------------------------------------------------------------
         |      Coef.   Std. Err.       z     P>|z|       [95% Conf. Interval]
---------+--------------------------------------------------------------------
Istage_2 |   .7890808    .164111      4.808   0.000       .4674291    1.110732
Istage_3 |   .7650795   .1699244      4.502   0.000       .4320339    1.098125
Istage_4 |   .8611392   .1982699      4.343   0.000       .4725373    1.249741
Ihisto_2 |   1.238626   .2990406      4.142   0.000       .6525172    1.824735
IsXh_2_2 |  -.0510886   .4007636     -0.127   0.899      -.8365709    .7343936
IsXh_3_2 |   .3566914   .3925826      0.909   0.364      -.4127564    1.126139
IsXh_4_2 |   1.560424   .5442153      2.867   0.004       .4937821    2.627067
------------------------------------------------------------------------------


Prentice Scheme

------------------------------------------------------------------------------
         |      Coef.   Std. Err.       z     P>|z|       [95% Conf. Interval]
---------+--------------------------------------------------------------------
Istage_2 |   .7883662    .164111      4.804   0.000       .4667145    1.110018
Istage_3 |   .7644673   .1699244      4.499   0.000       .4314216    1.097513
Istage_4 |   .8606358   .1982699      4.341   0.000       .4720339    1.249238
Ihisto_2 |   1.237414   .2990406      4.138   0.000       .6513053    1.823523
IsXh_2_2 |  -.0528366   .4007636     -0.132   0.895      -.8383189    .7326456
IsXh_3_2 |     .35322   .3925826      0.900   0.368      -.4162278    1.122668
IsXh_4_2 |   1.536801   .5442153      2.824   0.005       .4701587    2.603443
------------------------------------------------------------------------------

