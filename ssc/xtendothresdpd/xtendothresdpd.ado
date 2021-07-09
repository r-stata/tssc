*! xtendothresdpd version 1.0.1
*! Estimates a Dynamic Panel Data Threshold 
*! Effects Model with Endogenous Regressors 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop xtendothresdpd
program xtendothresdpd, eclass byable(recall) sortpreserve
            version 16.0
			quietly capture tsset
			syntax varlist(numeric ts) [if] [in] , thresv(varname numeric ts) STUB(string) pivar(varname numeric ts) ///
			[ fpctile(real 10) lpctile(real 90) xaddendog(varlist numeric ts) sig(real 0.10)       /// 
			zaddinst(varlist numeric ts) noGRAPHS SAVing(string asis) grid(integer 400) forcereg lagsret(integer 1)  *  ]
			
            marksample touse
			markout `touse' `thresv' `xaddendog' `zaddinst' 
            quietly count if `touse'
            if r(N) == 0 {
                        di as err "No observations."
                        exit 2000
            }
			display
			display _dup(78) "="
			display "Performing Dynamic Panel Data Threshold Effects with"
			display "Endogenous Regressors Estimations."
			display "This may take some time, please wait."
			display _dup(78) "="
			display			
			quietly tsset
			local panelvar = r(panelvar)
			local timevar  = r(timevar)
			tempvar mycountidj
			if "`forcereg'" != "" {
								quietly {
									tsset
									local ivar "`r(panelvar)'"
									bysort `touse' `ivar': gen long `mycountidj' = _N
									sum `mycountidj' if `touse', meanonly
									tempvar  mc
									gen `mc' = .
									replace `mc' = 1 if `mycountidj' == r(max) & `touse'
									markout `touse' `mc'
								}
            }
          	gettoken yvar xvarone    : varlist
			gettoken yvarlag xvartwo : xvarone
			quietly tsset
			local tousendogenes "`yvarlag' `xaddendog'"
			local lstadden
			local i = 1
			foreach xaden of varlist `tousendogenes' {
										confirm new var adeg_`i'_`stub'
										quietly generate double adeg_`i'_`stub' = `xaden' if `touse'
										local lstadden  `"`lstadden' adeg_`i'_`stub'"'
										local i = `i' + 1
            }
			quietly tsset
			xtendothresdpdconv `lstadden' if `touse', rescale replace 
			local pitvarib "`r(convervarlist)'"
			local lagretinstr
			forvalues i = 1(1)`lagsret' {
									confirm new var yvarlag_`stub'_lir_`i'
									quietly generate double yvarlag_`stub'_lir_`i' = L`i'.`yvarlag' if `touse'
									local lagretinstr  `"`lagretinstr' yvarlag_`stub'_lir_`i'"'
			}
			local xvatpluszadi "`xvartwo' `zaddinst'"
			local firstsetxva
			local j = 1
			foreach indfsxv of varlist `xvatpluszadi' {
										confirm new var fsx_`j'_`stub'
										quietly generate double fsx_`j'_`stub' = `indfsxv' if `touse'
										local firstsetxva  `"`firstsetxva' fsx_`j'_`stub'"'
										local j = `j' + 1
            }			
			local secondsetxva "`lagretinstr' `firstsetxva'"
			quietly tsset
			xtendothresdpdconv `secondsetxva' if `touse', rescale replace 
			local secondsetxvafod "`r(convervarlist)'"
			local pitvarpred
			foreach pitpre of varlist `pitvarib' {
										quietly regress `pitpre' `secondsetxvafod' if `touse', noconstant 
										confirm new var hat_`pitpre'_`stub'
										quietly capture predict double hat_`pitpre'_`stub' if `touse', xb
										local pitvarpred  `"`pitvarpred' hat_`pitpre'_`stub'"'
            }
			quietly tsset
			confirm new var ydepvb_`stub'
			quietly generate double ydepvb_`stub' = `yvar' if `touse'
			xtendothresdpdconv ydepvb_`stub' if `touse', rescale replace
			local ydepvbfod "`r(convervarlist)'"
			local xvartwosecstag
			local k = 1
			foreach secstagexvtw of varlist `xvartwo' {
										confirm new var secs_`k'_`stub'
										quietly generate double secs_`k'_`stub' = `secstagexvtw' if `touse'
										local xvartwosecstag  `"`xvartwosecstag' secs_`k'_`stub'"'
										local k = `k' + 1
            }			
			quietly tsset
			xtendothresdpdconv `xvartwosecstag' if `touse', rescale replace 
			local xvartwosecstagfod "`r(convervarlist)'"
			tempvar thresvalter
            quietly generate double `thresvalter' = `thresv' if `touse'
			tempvar departtot fintot 
			quietly egen double `departtot' = pctile(`thresvalter') if `touse', p(`fpctile')
			quietly egen double `fintot'    = pctile(`thresvalter') if `touse', p(`lpctile')
			tempvar touseprime
			quietly generate `touseprime' = `touse'
			quietly replace `touseprime' = 0 if `thresvalter' <= `departtot'
			quietly replace `touseprime' = 0 if `thresvalter' > `fintot'
			tempvar gammavarib
			quietly generate double `gammavarib' = `thresvalter' if `touseprime'
			tempvar gammaquants
			quietly tsset
			quietly pctile double `gammaquants' = `gammavarib', nquantiles(`grid')
			capture drop `stub'_gamma
			confirm new var `stub'_gamma			
			rename `gammaquants' `stub'_gamma
			label var `stub'_gamma "Gamma Variable"
			local grideffect = `grid' - 1
			tempvar pivitzv
			quietly generate double `pivitzv' = `pivar' if `touse'
			quietly tsset
			quietly sort `stub'_gamma, stable			
			capture drop `stub'_sofgamma
			confirm new var `stub'_sofgamma
			quietly generate double `stub'_sofgamma = .
			label var `stub'_sofgamma "S of Gamma, S(Gamma), Variable"
			confirm new var nnztotal_`stub'
			quietly generate double nnztotal_`stub' = .
			confirm new var ttztotal_`stub'
			quietly generate double ttztotal_`stub' = .			
			quietly tsset
			quietly sort `stub'_gamma, stable		
			forvalues i = 1(1)`grideffect' {
				capture drop inferieur_`stub'
				capture drop superieur_`stub'
				quietly tsset
				quietly sort `stub'_gamma, stable				
				quietly generate double inferieur_`stub' = `pivitzv'*(`thresvalter' <= `stub'_gamma[`i']) /// 
				if `touse' & !missing(`pivitzv') & !missing(`thresvalter')
				quietly tsset
				quietly sort `stub'_gamma, stable				
				quietly generate double superieur_`stub' = `pivitzv'*(`thresvalter' >  `stub'_gamma[`i']) ///
				if `touse' & !missing(`pivitzv') & !missing(`thresvalter')
				xtendothresdpdconv inferieur_`stub' if `touse', rescale replace 
				local inferieurfodcp "`r(convervarlist)'"
				xtendothresdpdconv superieur_`stub' if `touse', rescale replace 
				local superieurfodcp "`r(convervarlist)'"
				quietly tsset
				quietly sort `stub'_gamma, stable
				quietly regress `ydepvbfod' `inferieurfodcp' `superieurfodcp' `xvartwosecstagfod' `pitvarpred' if `touse', noconstant 
				quietly replace `stub'_sofgamma = e(rss) if _n == `i'
				quietly xtreg `ydepvbfod' `inferieurfodcp' `superieurfodcp' `xvartwosecstagfod' `pitvarpred' if `touse', re
				quietly replace nnztotal_`stub' = e(N_g) if _n == `i'
				quietly replace ttztotal_`stub' = e(g_avg) if _n == `i'
				drop superieur_`stub' inferieur_`stub' `inferieurfodcp' `superieurfodcp' 
				quietly tsset
				quietly sort `stub'_gamma, stable
			}
			tempname nnhawa tthawa
			tempname sdegamchap gamchapeau sigmacarre cdealpha
			quietly tsset
			quietly sort `stub'_sofgamma, stable
			quietly scalar `gamchapeau' = `stub'_gamma[1]
			quietly scalar `sdegamchap' = `stub'_sofgamma[1]
			quietly scalar `nnhawa' = nnztotal_`stub'[1]
			quietly scalar `tthawa' = ttztotal_`stub'[1] 				
			quietly scalar `sigmacarre' = (1/(`nnhawa'*(`tthawa' - 1)))*`sdegamchap'
			quietly tsset
			quietly sort `stub'_gamma, stable			
			capture drop `stub'_lrofgamma
			confirm new var `stub'_lrofgamma
			quietly generate double `stub'_lrofgamma = (`stub'_sofgamma - `sdegamchap')/`sigmacarre'
			label var `stub'_lrofgamma "LR of Gamma, LR(Gamma), Variable"
			quietly scalar `cdealpha' = -2*ln(1 - sqrt(1 - `sig'))
			quietly tsset
			quietly sort `stub'_gamma, stable
			capture drop `stub'_subsetgamma
			confirm new var `stub'_subsetgamma
			quietly generate double `stub'_subsetgamma = `stub'_gamma if `stub'_lrofgamma <= `cdealpha'
			label var `stub'_subsetgamma "Subset of Gamma for Confidence Interval"
			tempname borninfgam bornsupgam
			quietly summarize `stub'_subsetgamma
			quietly scalar `borninfgam' = r(min)
			quietly scalar `bornsupgam' = r(max)
			quietly tsset
			quietly sort `stub'_gamma, stable
			capture drop below_thres_`stub'
			capture drop above_thres_`stub'
			quietly tsset
			quietly sort `stub'_gamma, stable				
			quietly generate double below_thres_`stub' = `pivitzv'*(`thresvalter' <= `gamchapeau') /// 
			if `touse' & !missing(`pivitzv') & !missing(`thresvalter')
			quietly tsset
			quietly sort `stub'_gamma, stable				
			quietly generate double above_thres_`stub' = `pivitzv'*(`thresvalter' >  `gamchapeau') ///
			if `touse' & !missing(`pivitzv') & !missing(`thresvalter')				
			label var below_thres_`stub' "Below the Threshold: pi_it*I(q_it <= Gamma_Hat)"
			label var above_thres_`stub' "Above the Threshold: pi_it*I(q_it >  Gamma_Hat)"
			quietly tsset
			xtdpd `yvar' L.`yvar' below_thres_`stub' above_thres_`stub' `xvartwo' `xaddendog' if `touse' , `options'
			local confianceiv = int((1-`sig')*100)
			display 
			display "Threshold Parameter" " (level = " as res `confianceiv' ")"
			display _dup(55) "_"
			display _col(15) "Threshold" _col(31) "Lower" _col(43) "Upper"
			display _dup(55) "_"
			display "Gamma_Hat" _col(12) as res %9.0g `gamchapeau' _col(28) as res %9.0g `borninfgam'  _col(40) as res %9.0g `bornsupgam'
			display _dup(55) "_"
			display 
			if "`graphs'" == "" {
				local soncalps = `cdealpha'
				twoway line `stub'_lrofgamma `stub'_gamma if `touse', title("Confidence Interval Construction for the Threshold Model")  /// 
				xtitle("Gamma") sort  yline(`soncalps', lcolor(green)) name(`stub'_dethgrp, replace)
				if `"`saving'"' != "" {
								quietly cd `saving'
								quietly graph save `stub'_dethgrp.gph, replace
				}
			}
			quietly drop `lstadden' `pitvarib' `lagretinstr' `firstsetxva' `secondsetxvafod' `pitvarpred' 	 ///
			ydepvb_`stub' `ydepvbfod' `xvartwosecstag' `xvartwosecstagfod' nnztotal_`stub' ttztotal_`stub'	
			ereturn scalar gammahat    = `gamchapeau'
			ereturn scalar sofgammahat = `sdegamchap'
			ereturn scalar sigmahatsq  = `sigmacarre'
			ereturn scalar confalpha   = `cdealpha'
			ereturn scalar noptimal    = `nnhawa'
			ereturn scalar toptimal    = `tthawa'
			ereturn scalar lowbgamma   = `borninfgam'
			ereturn scalar uppbgamma   = `bornsupgam'
			ereturn scalar firstpctz   = `fpctile'
			ereturn scalar lastpctz    = `lpctile'
			ereturn scalar alphaparam  = `sig'
			ereturn scalar gridpoints  = `grid'
			ereturn local lesoptionsdp "`options'"
			ereturn local thresvaribzha "`thresv'"
			ereturn local pivaribzha "`pivar'"
			ereturn local additendox "`xaddendog'"
			ereturn local additinstrz "`zaddinst'"
			ereturn local gammavarzha "`stub'_gamma"
			ereturn local sofgammazha "`stub'_sofgamma"
			ereturn local lrofgammazha "`stub'_lrofgamma"
			ereturn local subsetgammazha "`stub'_subsetgamma"
			ereturn local belowthreszha "below_thres_`stub'"
			ereturn local abovethreszha "above_thres_`stub'"
			ereturn local predict xtendothresdpd_p
			ereturn local cmd "xtendothresdpd"
			ereturn local cmdline "xtendothresdpd `0'"
			

end


