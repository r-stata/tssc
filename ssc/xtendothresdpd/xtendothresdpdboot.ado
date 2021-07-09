*! version 1.0.1
*! Bootstrap Finder 
*! for the Command xtendothresdpd 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop xtendothresdpdboot
program xtendothresdpdboot, rclass sortpreserve
        version 16.0
		syntax, comdline(string asis)  
		local lalignecomd = "`comdline'"
		quietly `lalignecomd' nographs
		local lapartievindbt = e(datasignaturevars)
		local lasectionoptbt = e(lesoptionsdp)
		local lavargamma     = e(gammavarzha)
		local lasousseuil    = e(belowthreszha)
		local lasurseuil     = e(abovethreszha)
		local lavardepend    = e(depvar)
		local laaddendogene  = e(additendox)
		tempvar monechantil
		quietly generate `monechantil' = e(sample) 
		local lavardepretard = "L.`lavardepend'"
		local ladeuxseuils `"`lasousseuil' `lasurseuil'"'
		local layxvars : list lapartievindbt - ladeuxseuils
		local laseulxvars : list layxvars - lavardepend
		local laxvarsansvdr : list laseulxvars - lavardepretard
		if "`laaddendogene'" == "." {
							local laadendovrai 
		}
		else {
				local laadendovrai "`laaddendogene'"
		}
		local grideffectbt   = e(gridpoints) - 1
		tempvar louisstubgam
		quietly generate `louisstubgam' = "`lavargamma'"
		quietly split `louisstubgam', p(_)
		local stubbt = `louisstubgam'1[1]
		drop `louisstubgam'*
		local lavbthreshold  = e(thresvaribzha)
		local lapivitzvbttso = e(pivaribzha)
		tempvar lapivitzvbt
		quietly generate double `lapivitzvbt' = `lapivitzvbttso' if `monechantil'
		tempvar thresvalterbt
        quietly generate double `thresvalterbt' = `lavbthreshold' if `monechantil'
		quietly tsset
        local panelvarbt "`r(panelvar)'"
        local timevarbt  "`r(timevar)'"
		capture drop wnstar_`stubbt' nnztotalbt_`stubbt' 
		quietly generate double wnstar_`stubbt'     = .
		quietly generate double nnztotalbt_`stubbt' = .
		quietly tsset
		quietly sort `lavargamma', stable
		forvalues i = 1(1)`grideffectbt' {
			quietly tsset
			quietly sort `lavargamma', stable				
			quietly generate double inferieurbt_`stubbt' = `lapivitzvbt'*(`thresvalterbt' <= `lavargamma'[`i']) /// 
			if `monechantil' & !missing(`lapivitzvbt') & !missing(`thresvalterbt')
			quietly tsset
			quietly sort `lavargamma', stable				
			quietly generate double superieurbt_`stubbt' = `lapivitzvbt'*(`thresvalterbt' >  `lavargamma'[`i']) ///
			if `monechantil' & !missing(`lapivitzvbt') & !missing(`thresvalterbt')
			quietly tsset
			quietly bysort `panelvarbt': generate double etai_`stubbt' = rnormal() if `monechantil'			
			quietly tsset
			quietly xtdpd `lavardepend' `lavardepretard' inferieurbt_`stubbt' superieurbt_`stubbt' `laxvarsansvdr' ///
			`laadendovrai' if `monechantil', `lasectionoptbt'
			quietly predict double residusbt_`stubbt' if `monechantil', e
			quietly tsset
			quietly generate double yitstar_`stubbt' = residusbt_`stubbt'*etai_`stubbt' if `monechantil'
			quietly tsset
			quietly generate double yitstarlag_`stubbt' = L.yitstar_`stubbt' if `monechantil'
			quietly tsset
			quietly sort `lavargamma', stable			
			quietly xtdpd yitstar_`stubbt' yitstarlag_`stubbt' inferieurbt_`stubbt' superieurbt_`stubbt' `laxvarsansvdr' ///
			`laadendovrai' if `monechantil', `lasectionoptbt'
			quietly replace nnztotalbt_`stubbt' = e(N) if _n == `i'
			quietly test inferieurbt_`stubbt' = superieurbt_`stubbt'
			quietly replace wnstar_`stubbt' = r(chi2) if _n == `i'
			capture drop inferieurbt_`stubbt' superieurbt_`stubbt' residusbt_`stubbt' etai_`stubbt' yitstar_`stubbt' yitstarlag_`stubbt'
		}
		tempname supwstar nnhawabt 
		quietly gsort -wnstar_`stubbt'
		quietly scalar `supwstar'   = wnstar_`stubbt'[1]
		quietly scalar `nnhawabt'   = nnztotalbt_`stubbt'[1]
		return clear
        return scalar supwstarboots = `supwstar'
        return scalar ntotalboots   = `nnhawabt'
		capture drop wnstar_`stubbt' nnztotalbt_`stubbt' 
		
end


