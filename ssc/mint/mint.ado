*!minv version 2.0
*!Written 23July2018
*!Written by Mehmet Mehmetoglu
capture program drop mint
program mint
version 14
//qui ereturn list
            local usem=e(cmd) 
 			local usersem = e(cmdline) 
			local usergroup = e(groupvar)
			local latentvars = e(lxvars)				
//equal form model - step1
			qui `usersem' ginvariant(meanex) //everything apart from latent means are freely estimated
			qui estat gof, stats(all)
			//qui return list
            tempname efchi2 efdf efrmsea efcfi eftli efp
			scalar `efchi2' = r(chi2_ms)
			//di `efchi2'
			scalar `efdf' = r(df_ms)
			//di `efdf'
            scalar `efrmsea' = r(rmsea)
			//di `efrmsea'
            scalar `efcfi' = r(cfi)
			//di `efcfi' 
            scalar `eftli' = r(tli)
			//di `eftli'
			scalar `efp' =r(p_ms)
			//di `efp'
//equal loadings model -step2
			qui `usersem' ginvariant(meanex mcoef)
			qui estat gof, stats(all)
			//qui return list
            tempname elchi2 eldf elrmsea elcfi eltli elp
			scalar `elchi2' = r(chi2_ms)
			//di `elchi2'
			scalar `eldf' = r(df_ms)
			//di `eldf'
            scalar `elrmsea' = r(rmsea)
			//di `elrmsea'
            scalar `elcfi' = r(cfi)
			//di `elcfi' 
            scalar `eltli' = r(tli)
			//di `eltli'
			scalar `elp' =r(p_ms)
			//di `elp'
//equal loadings and intercepts - step3
			qui `usersem' ginvariant(mcoef mcons) 
			qui estat gof, stats(all)
			//qui return list
            tempname elintchi2 elintdf elintrmsea elintcfi elinttli elintp
			scalar `elintchi2' = r(chi2_ms)
			//di `elintchi2'
			scalar `elintdf' = r(df_ms)
			//di `elintdf'
            scalar `elintrmsea' = r(rmsea)
			//di `elintrmsea'
            scalar `elintcfi' = r(cfi)
			//di `elintcfi' 
            scalar `elinttli' = r(tli)
			//di `elinttli'
			scalar `elintp' =r(p_ms)
			//di `elintp'
//equal loadings and error variances -step4
			qui `usersem' ginvariant(mcoef mcons merrvar) 
			qui estat gof, stats(all)
			//qui return list
            tempname elerchi2 elerdf elerrmsea elercfi elertli elerp
			scalar `elerchi2' = r(chi2_ms)
			//di `elerchi2'
			scalar `elerdf' = r(df_ms)
			//di `elerdf'
            scalar `elerrmsea' = r(rmsea)
			//di `elerrmsea'
            scalar `elercfi' = r(cfi)
			//di `elercfi' 
            scalar `elertli' = r(tli)
			//di `elertli'
			scalar `elerp' =r(p_ms)
			//di `elerp'
//comparing factor means - step5
			qui `usersem' ginvariant(mcoef mcons merrvar meanex) 
			qui estat gof, stats(all)
			//qui return list
            tempname fmchi2 fmdf fmrmsea fmcfi fmtli fmp
			scalar `fmchi2' = r(chi2_ms)
			//di `fmchi2'
			scalar `fmdf' = r(df_ms)
			//di `fmdf'
            scalar `fmrmsea' = r(rmsea)
			//di `fmrmsea'
            scalar `fmcfi' = r(cfi)
			//di `fmcfi' 
            scalar `fmtli' = r(tli)
			//di `fmtli'
			scalar `fmp' =r(p_ms)
			//di `fmp'
//comparison of the models based X2-diff test
		tempname x2diff21 x2diff32 x2diff42 x2diff54 x2diff62
			scalar `x2diff21' =  `elchi2'-`efchi2'
			//di `x2diff21'
				scalar `x2diff32' =  `elintchi2'-`elchi2'
			//di `x2diff32'
				scalar `x2diff42' =  `elerchi2'-`elintchi2'
			//di `x2diff42'
				scalar `x2diff62' =  `fmchi2'-`elerchi2'
			//di `x2diff62'
		tempname dfdiff21 dfdiff32 dfdiff42 dfdiff54 dfdiff62
			scalar `dfdiff21' =  `eldf'-`efdf'
			//di `dfdiff21'
				scalar `dfdiff32' =  `elintdf'-`eldf'
			//di `dfdiff32'
				scalar `dfdiff42' =  `elerdf'-`elintdf'
			//di `dfdiff42'
				scalar `dfdiff62' =  `fmdf'-`elerdf'
			//di `dfdiff62'
		tempname pdiff21 pdiff32 pdiff42 pdiff54 pdiff62
			scalar `pdiff21' = chi2tail(`dfdiff21',`x2diff21')
			//di `pdiff21'
				scalar `pdiff32' =  chi2tail(`dfdiff32',`x2diff32')
			//di `pdiff32'
				scalar `pdiff42' =  chi2tail(`dfdiff42',`x2diff42')
			//di `pdiff42'
				scalar `pdiff62' =  chi2tail(`dfdiff62',`x2diff62')
			//di `pdiff62'	
di ""
di in yellow"     Tests of measurement invariance and factor mean difference"			
di as smcl as txt  "{c TLC}{hline 122}{c TRC}"
display in green "{bf:     Model}{dup 20: }{c |} {bf:    X2(df), p}{dup 10: }{c |}{bf: Comparison}{dup 1: }{c |} {bf:    Diff_X2(df), p}{dup 3: }{c |}{bf: RMSEA}{dup 4: }{c |}{bf: CFI}{dup 7: }{c |}{bf: TLI}"
di as smcl as txt "{c LT}{hline 122}{c RT}"	
di ""
display in green "  1. Equal form"_col(31) "{c |} " %9.2f `efchi2' "(" `efdf' ")" "," %-4.2f `efp' _col(56) "{c |} " "n.a."_col(69) "{c |} ""     n.a."_col(92) "{c |} " %-4.2f `efrmsea' _col(103) "{c |} " %-4.2f `efcfi' _col(115) "{c |} " %-4.2f `eftli'
di ""
	if `pdiff21' < 0.05 { 
display in red "  2. Equal loadings"_col(31) "{c |} " %9.2f `elchi2' "(" `eldf' ")" "," %-4.2f `elp' _col(56) "{c |} ""2 vs 1"_col(69) "{c |} " %9.2f `x2diff21' "(" `dfdiff21' ")" "," %-4.2f `pdiff21' _col(92) "{c |} " %4.2f `elrmsea' _col(103) "{c |} " %-4.2f `elcfi' _col(115) "{c |} "%-4.2f `eltli'

									}
	else {
display in green "  2. Equal loadings"_col(31) "{c |} " %9.2f `elchi2' "(" `eldf' ")" "," %-4.2f `elp' _col(56) "{c |} ""2 vs 1"_col(69) "{c |} " %9.2f `x2diff21' "(" `dfdiff21' ")" "," %-4.2f `pdiff21' _col(92) "{c |} " %4.2f `elrmsea' _col(103) "{c |} " %-4.2f `elcfi' _col(115) "{c |} "%-4.2f `eltli'

			}
di ""
	if `pdiff32' < 0.05 { 
display in red "  3. Equal intercepts"_col(31) "{c |} " %9.2f `elintchi2' "(" `elintdf' ")" "," %-4.2f `elintp' _col(56) "{c |} ""3 vs 2"_col(69) "{c |} " %9.2f `x2diff32' "(" `dfdiff32' ")" "," %-4.2f `pdiff32' _col(92) "{c |} " %4.2f `elintrmsea' _col(103) "{c |} " %-4.2f `elintcfi' _col(115) "{c |} "%-4.2f `elinttli'

									}
	else {
display in green "  3. Equal intercepts"_col(31) "{c |} " %9.2f `elintchi2' "(" `elintdf' ")" "," %-4.2f `elintp' _col(56) "{c |} ""3 vs 2"_col(69) "{c |} " %9.2f `x2diff32' "(" `dfdiff32' ")" "," %-4.2f `pdiff32' _col(92) "{c |} " %4.2f `elintrmsea' _col(103) "{c |} " %-4.2f `elintcfi' _col(115) "{c |} "%-4.2f `elinttli'

									}
di ""
	if `pdiff42' < 0.05 { 
display in red "  4. Equal error variances"_col(31) "{c |} " %9.2f `elerchi2' "(" `elerdf' ")" "," %-4.2f `elerp' _col(56) "{c |} ""4 vs 3"_col(69) "{c |} " %9.2f `x2diff42' "(" `dfdiff42' ")" "," %-4.2f `pdiff42' _col(92) "{c |} " %4.2f `elerrmsea' _col(103) "{c |} " %-4.2f `elercfi' _col(115) "{c |} "%-4.2f `elertli'

									}
	else {
display in green "  4. Equal error variances"_col(31) "{c |} " %9.2f `elerchi2' "(" `elerdf' ")" "," %-4.2f `elerp' _col(56) "{c |} ""4 vs 3"_col(69) "{c |} " %9.2f `x2diff42' "(" `dfdiff42' ")" "," %-4.2f `pdiff42' _col(92) "{c |} " %4.2f `elerrmsea' _col(103) "{c |} " %-4.2f `elercfi' _col(115) "{c |} "%-4.2f `elertli'

			}
di ""
	if `pdiff62' < 0.05 { 
display in red "  6. Equal factor means"_col(31) "{c |} " %9.2f `fmchi2' "(" `fmdf' ")" "," %-4.2f `fmp' _col(56) "{c |} ""5 vs 4"_col(69) "{c |} " %9.2f `x2diff62' "(" `dfdiff62' ")" "," %-4.2f `pdiff62' _col(92) "{c |} " %4.2f `fmrmsea' _col(103) "{c |} " %-4.2f `fmcfi' _col(115) "{c |} "%-4.2f `fmtli'

									}
	else {
display in green "  6. Equal factor means"_col(31) "{c |} " %9.2f `fmchi2' "(" `fmdf' ")" "," %-4.2f `fmp' _col(56) "{c |} ""5 vs 4"_col(69) "{c |} " %9.2f `x2diff62' "(" `dfdiff62' ")" "," %-4.2f `pdiff62' _col(92) "{c |} " %4.2f `fmrmsea' _col(103) "{c |} " %-4.2f `fmcfi' _col(115) "{c |} "%-4.2f `fmtli'
 
			}
di as smcl as txt "{c BLC}{hline 122}{c BRC}"
di in yellow "     Note: Diff_X2(df),p value < 0.05 indicates differing estimates in that the restricted model worsens the fit!"			
qui `usersem' 
end








