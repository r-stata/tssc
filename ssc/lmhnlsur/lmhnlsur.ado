*! lmhnlsur V1.0 28/06/2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define lmhnlsur , rclass
version 10
tempname Y Yh E lmharch lmharchp lmhp1 lmhp1p lmhp2 lmhp2p lmhp3 lmhp3p lmhw lmhwp
tempname Sig2 Omega detw SigLRs SigWs SigWs SigLRs lmhlr lmhlrp lmhlmp
tempvar  Sig2 SigW Time SigLR detw Yh Yh2 LYh2 E E2 time LE U2 
marksample touse
qui gen `Time' =_n
qui tsset `Time'
matrix `Omega'= e(Sigma)
matrix `detw'=log(det(`Omega'))
matrix `Sig2' = corr(`Omega')
matrix `Sig2' = `Sig2' * `Sig2''
local cmd `e(cmdline)'
local `e(cmdline)'
local method `e(method)'
local N=e(N)
local Q=e(k_eq)
local eQ `Q'
local vars `e(depvar)'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* NL-SUR System Heteroscedasticity Tests}}"
di _dup(78) "{bf:{err:=}}"
di "{bf:*** Single Equation Heteroscedasticity Tests:}
di as txt _col(2) "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
di
qui forvalue i=1/`Q' {
qui predict `E'`i' if `touse' , equation(#`i') res
qui predict `Yh'`i' if `touse' , equation(#`i')
 }
 forvalue i=1/`Q' {
qui gen `Yh2'`i'=`Yh'`i'^2 if `touse'
qui gen `LYh2'`i'=ln(`Yh2'`i') if `touse'
qui gen `E2'`i'=`E'`i'^2 if `touse'
qui gen `LE'`i'=L1.`E2'`i' if `touse'
qui regress `E2'`i' `LE'`i' if `touse'
scalar `lmharch'`i'=e(r2)*e(N)
scalar `lmharchp'`i'=chi2tail(1,abs(`lmharch'`i'))
qui regress `E2'`i' `Yh'`i' if `touse'
scalar `lmhp1'`i'=e(N)*e(r2)
scalar `lmhp1p'`i'=chi2tail(1,abs(`lmhp1'`i'))
qui regress `E2'`i' `Yh2'`i' if `touse'
scalar `lmhp2'`i'=e(N)*e(r2)
scalar `lmhp2p'`i'=chi2tail(1,abs(`lmhp2'`i'))
qui regress `E2'`i' `LYh2'`i' if `touse'
scalar `lmhp3'`i'=e(N)*e(r2)
scalar `lmhp3p'`i'=chi2tail(1,abs(`lmhp3'`i'))
di as txt _col(2) "Eq. `i'" _col(12) ": Engle LM ARCH Test: E2 = E2_1" _col(45) "=" as res %8.4f `lmharch'`i' _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmharchp'`i'
di as txt _col(2) "Eq. `i'" _col(12) ": Hall-Pagan LM Test: E2 = Yh" _col(45) "=" as res %8.4f `lmhp1'`i' _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhp1p'`i'
di as txt _col(2) "Eq. `i'" _col(12) ": Hall-Pagan LM Test: E2 = Yh2" _col(45) "=" as res %8.4f `lmhp2'`i' _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhp2p'`i'
di as txt _col(2) "Eq. `i'" _col(12) ": Hall-Pagan LM Test: E2 = LYh2" _col(45) "=" as res %8.4f `lmhp3'`i' _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhp3p'`i'
di _dup(78) "-"
return scalar lmharch_`i'=`lmharch'`i'
return scalar lmharchp_`i'=`lmharchp'`i'
return scalar lmhp1_`i'=`lmhp1'`i'
return scalar lmhp1p_`i'=`lmhp1p'`i'
return scalar lmhp2_`i'=`lmhp2'`i'
return scalar lmhp2p_`i'=`lmhp2p'`i'
return scalar lmhp3_`i'=`lmhp3'`i'
return scalar lmhp3p_`i'=`lmhp3p'`i'
 }
di
di "{bf:*** Overall System NL-SUR Heteroscedasticity Tests:}
di as txt "{bf: Ho: No Overall System Heteroscedasticity}"
di
qui gen double `SigLR' = . if `touse' 
qui gen double `SigW'  = . if `touse' 
scalar `SigLRs' = 0
scalar `SigWs'  = 0
qui forvalue i =1/`eQ' {
replace `SigW' = `Omega'[`i',`i'] if `touse'
qui summ `SigW' if `touse' , meanonly
scalar `SigWs' = `SigWs' + r(mean)
 }
qui forvalue i =1/`eQ' {
replace `SigLR' = log(`Omega'[`i',`i']) if `touse'
qui summ `SigLR' if `touse' , meanonly
scalar `SigLRs' = `SigLRs' + r(mean)
 }
local dflm =`eQ'*(`eQ'-1)/2
local dflr =`eQ'*(`eQ'-1)/2
local dfw = `eQ'*(`eQ'-1)/2
scalar `lmhlr'=`N'*(`SigLRs'-`detw'[1,1])
scalar `lmhlrp'= chi2tail(`dflr',`lmhlr')
local lmhlm = (trace(`Sig2')-`eQ')*`N' / 2
scalar lmhlm = `lmhlm' 
scalar `lmhlmp'= chi2tail(`dflm',`lmhlm')
scalar `lmhw' =`N'*(`detw'[1,1]/`SigWs'-1)^2
scalar `lmhwp'= chi2tail(`dfw',`lmhw')
di as txt "- Breusch-Pagan LM Test" _col(33) "=" as res %9.4f `lmhlm' as txt _col(50) "P-Value > Chi2(" `dflm' ")" _col(70) %5.4f as res `lmhlmp'
di as txt "- Likelihood Ratio LR Test" _col(33) "=" as res %9.4f `lmhlr' _col(50) as txt "P-Value > Chi2(" `dflr' ")" _col(70) %5.4f as res `lmhlrp'
di as txt "- Wald Test" as res _col(33) "=" as res %9.4f `lmhw' _col(50) as txt "P-Value > Chi2(" `dfw' ")" _col(70) %5.4f as res `lmhwp'
di _dup(78) "-"
qui `cmd'
return scalar lmhw  = `lmhw'
return scalar lmhwp = `lmhwp'
return scalar lmhlr = `lmhlr'
return scalar lmhlrp= `lmhlrp'
return scalar lmhlm = `lmhlm'
return scalar lmhlmp= `lmhlmp'
end
