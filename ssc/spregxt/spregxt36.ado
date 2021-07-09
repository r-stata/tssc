 program define spregxt36 , eclass
 version 11.0
 syntax, [Level(int $S_level) robust]

 if inlist("`e(title)'", "MSTAR1n", "MSTAR1w") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
   diparm(Sigma, label("Sigma"))
 local PARM1 "Rho1"
di as txt " Wald Test [`PARM1'=0]:" _col(35) %9.4f e(waldr) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1
 }

 if inlist("`e(title)'", "MSTAR1e") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1"))
 local PARM1 "Rho1"
di as txt " Wald Test [`PARM1'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1
 }

 if inlist("`e(title)'", "MSTAR1h") {
 ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
          diparm(Sigma, label("Sigma"))
 local PARM1 "Rho1"
di as txt " Wald Test [`PARM1'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1
 }

 if inlist("`e(title)'", "MSTAR2n", "MSTAR2w") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Sigma, label("Sigma"))
 local PARM2 "Rho1+Rho2"
di as txt " Wald Test [`PARM2'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(2)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2
 }

 if inlist("`e(title)'", "MSTAR2e") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2"))
 local PARM2 "Rho1+Rho2"
di as txt " Wald Test [`PARM2'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(2)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2
 }

 if inlist("`e(title)'", "MSTAR2h") {
 ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Sigma, label("Sigma"))
 local PARM2 "Rho1+Rho2"
di as txt " Wald Test [`PARM2'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(2)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2
 }

 if inlist("`e(title)'", "MSTAR3n", "MSTAR3w") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) diparm(Sigma, label("Sigma"))
 local PARM3 "Rho1+Rho2+Rho3"
di as txt " Wald Test [`PARM3'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(3)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
 }

 if inlist("`e(title)'", "MSTAR3e") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3"))
 local PARM3 "Rho1+Rho2+Rho3"
di as txt " Wald Test [`PARM3'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(3)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
 }

 if inlist("`e(title)'", "MSTAR3h") {
 ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) diparm(Sigma, label("Sigma"))
 local PARM3 "Rho1+Rho2+Rho3"
di as txt " Wald Test [`PARM3'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(3)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
 }

 if inlist("`e(title)'", "MSTAR4n", "MSTAR4w") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) ///
 diparm(Rho4, label("Rho4")) diparm(Sigma, label("Sigma"))
 local PARM4 "Rho1+Rho2+Rho3+Rho4"
di as txt " Wald Test [`PARM4'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(4)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
di as txt " Acceptable Range for Rho4: " %6.4f minEig4 " < Rho4 < " %6.4f maxEig4
 }

 if inlist("`e(title)'", "MSTAR4e") {
 ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) diparm(Rho4, label("Rho4")) 
 local PARM4 "Rho1+Rho2+Rho3+Rho4"
di as txt " Wald Test [`PARM4'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(4)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
di as txt " Acceptable Range for Rho4: " %6.4f minEig4 " < Rho4 < " %6.4f maxEig4
 }

 if inlist("`e(title)'", "MSTAR4h") {
 ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) ///
 diparm(Rho4, label("Rho4")) diparm(Sigma, label("Sigma"))
 local PARM4 "Rho1+Rho2+Rho3+Rho4"
di as txt " Wald Test [`PARM4'=0]:" _col(37) %9.4f e(waldr) _col(52) "P-Value > Chi2(4)" _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
di as txt " Acceptable Range for Rho4: " %6.4f minEig4 " < Rho4 < " %6.4f maxEig4
 }

 if inlist("`e(title)'" ,"SEM1n", "SEM1w") {
 ml display, level(`level') neq(1) noheader diparm(Lambda, label("Lambda")) ///
            diparm(Sigma, label("Sigma"))
di as txt " LR Test SEM vs. OLS (Lambda=0):" _col(33) %9.4f e(waldl) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldlp)
di as txt " Acceptable Range for Lambda:" _col(33) %9.4f e(minEig) "  < Lambda < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'" ,"SEM1e") {
 ml display, level(`level') neq(1) noheader diparm(Lambda, label("Lambda"))
di as txt " LR Test SEM vs. OLS (Lambda=0):" _col(33) %9.4f e(waldl) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldlp)
di as txt " Acceptable Range for Lambda:" _col(33) %9.4f e(minEig) "  < Lambda < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'", "SAR1n", "SAR1w") {
 ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
            diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SAR vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
 }
 if "`robust'"=="" {
di as txt " LR Test SAR vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
 }
di as txt " Acceptable Range for Rho:" _col(33) %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'" ,"SAR1e") {
 ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho"))
 if "`robust'"!="" {
di as txt " Wald Test SAR vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
 }
 if "`robust'"=="" {
di as txt " LR Test SAR vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
 }
di as txt " Acceptable Range for Rho:" _col(33) %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'" ,"SAR1h") {
 ml display, level(`level') neq(2) noheader diparm(Rho, label("Rho")) ///
          diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SAR vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
 }
 if "`robust'"=="" {
di as txt " LR Test SAR vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
 }
di as txt " Acceptable Range for Rho:" _col(33) %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'", "SDM1n", "SDM1w") {
 ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
          diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SDM vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
di as txt " Wald Test (wX's =0):" _col(33) %9.4f e(waldx) _col(45) "P-Value > Chi2(" e(waldx_df) ")" _col(65) %5.4f e(waldxp)
 }
 if "`robust'"=="" {
di as txt " LR Test SDM vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
di as txt " LR Test (wX's =0):" _col(33) %9.4f e(waldx) _col(45) "P-Value > Chi2(" e(waldx_df) ")" _col(65) %5.4f e(waldxp)
 }
di as txt " Acceptable Range for Rho:" _col(33) %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'" ,"SDM1e") {
 ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho"))
 if "`robust'"!="" {
di as txt " Wald Test SDM vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
di as txt " Wald Test (wX's =0):" _col(33) %9.4f e(waldx) _col(45) "P-Value > Chi2(" e(waldx_df) ")" _col(65) %5.4f e(waldxp)
 }
 if "`robust'"=="" {
di as txt " LR Test SDM vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
di as txt " LR Test (wX's =0):" _col(33) %9.4f e(waldx) _col(45) "P-Value > Chi2(" e(waldx_df) ")" _col(65) %5.4f e(waldxp)
 }
di as txt " Acceptable Range for Rho:" _col(33) %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'" ,"SDM1h") {
 ml display, level(`level') neq(2) noheader diparm(Rho, label("Rho")) ///
          diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SDM vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
di as txt " Wald Test (wX's =0):" _col(33) %9.4f e(waldx) _col(45) "P-Value > Chi2(" e(waldx_df) ")" _col(65) %5.4f e(waldxp)
 }
 if "`robust'"=="" {
di as txt " LR Test SDM vs. OLS (Rho=0):" _col(33) %9.4f e(waldr) _col(45) "P-Value > Chi2(1)" _col(65) %5.4f e(waldrp)
di as txt " LR Test (wX's =0):" _col(33) %9.4f e(waldx) _col(45) "P-Value > Chi2(" e(waldx_df) ")" _col(65) %5.4f e(waldxp)
 }
di as txt " Acceptable Range for Rho:" _col(33) %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
 if inlist("`e(title)'", "SAC1n", "SAC1w") {
 ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
            diparm(Lambda, label("Lambda")) diparm(Sigma, label("Sigma"))
di as txt " LR Test (Rho=0):" _col(40) %9.4f e(waldr) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldrp)
di as txt " LR Test (Lambda=0):" _col(40) %9.4f e(waldl) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldlp)
di as txt " LR Test SAC vs. OLS (Rho+Lambda=0):" _col(40) %9.4f e(waldj) _col(52) "P-Value > Chi2(2)" _col(70) %5.4f e(waldjp) 
di as txt " Acceptable Range for Rho:" _col(40) %9.4f e(minEig) _col(52) "<  Rho  < " %5.4f e(maxEig) 
 }
 if inlist("`e(title)'" ,"SAC1e") {
 ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
            diparm(Lambda, label("Lambda"))
di as txt " LR Test (Rho=0):" _col(40) %9.4f e(waldr) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldrp)
di as txt " LR Test (Lambda=0):" _col(40) %9.4f e(waldl) _col(52) "P-Value > Chi2(1)" _col(70) %5.4f e(waldlp)
di as txt " LR Test SAC vs. OLS (Rho+Lambda=0):" _col(40) %9.4f e(waldj) _col(52) "P-Value > Chi2(2)" _col(70) %5.4f e(waldjp) 
di as txt " Acceptable Range for Rho:" _col(40) %9.4f e(minEig) _col(52) "<  Rho  < " %5.4f e(maxEig) 
 }
 if inlist("`e(title)'" ,"MLEREMLN") {
 ml display, level(`level') neq(1) noheader diparm(Sigu, label("Sigu")) ///
   diparm(Sige, label("Sige"))
 }
 if inlist("`e(title)'" ,"MLEREMLH") {
 ml display, level(`level') neq(2) noheader diparm(Sigu, label("Sigu")) ///
   diparm(Sige, label("Sige"))
 }
 if !inlist("`e(title)'" ,"MLEREMLN", "MLEREMLH") {
di _dup(78) "-"
 }
 end

