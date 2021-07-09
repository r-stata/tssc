*!sumscale version 1.0
*!Written 22Jan2015
*!Written by Mehmet Mehmetoglu
//set trace on
capture program drop sumscale
	program  sumscale
	version 13.1
syntax, [f1(varlist) f2(varlist) f3(varlist) f4(varlist) ///
		f5(varlist) f6(varlist) f7(varlist) f8(varlist) ///
		f9(varlist) f10(varlist) f11(varlist) f12(varlist) ///
		f13(varlist) f14(varlist) f15(varlist) f16(varlist) ///
		f17(varlist) f18(varlist) f19(varlist) f20(varlist) ///
		f21(varlist) f22(varlist) f23(varlist) f24(varlist) f25(varlist) ///
		fsum fdummy] 	
tokenize "`0'"
	local utyped `0'
	macro shift
	local def `1'
	macro shift
	//di "`def'"
if "`def'" != "" & "`fsum'" == "" & "`fdummy'" == "" {
di ""
di as smcl as txt  "{c TLC}{hline 100}{c TRC}"	
di in yellow "  {bf:Factor}{dup 6: }{c |}{bf:    N}{dup 6: }{c |} {bf:    Mean}{dup 4: }{c |} {bf:    Std}{dup 5: }{c |} {bf:    Min}{dup 4: } {c |} {bf:    Max}{dup 4: } {c |} {bf: Cronbach Alpha}{dup 5: }"
di in yellow "  {bf:(Items)}
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"	
local i=25
forvalues num = 1/`i' { 
    capture drop Factor`num'_average
	if "`f`num''" != "" {
	qui egen Factor`num'_average = rowmean (`f`num'')
	label variable Factor`num'_average "average of variables"
	qui alpha `f`num''
	tempname relcoef
	scalar `relcoef' = r(alpha)
	qui sum Factor`num'_average if Factor`num'_average !=. 
	//return list
	tempname rmean rsd minn maxx nn
	scalar `rmean' = r(mean)
	scalar `rsd' = r(sd)
	scalar `minn' = r(min)
	scalar `maxx' = r(max)
	scalar `nn' = r(N)
	if `relcoef' <= 0.6 {
di in red "  Factor`num'{dup 5: }{c |}  "%-9.0f `nn' "{c |}"%9.2f `rmean' "{dup 4: }{c |}"%9.2f `rsd' "{dup 4: }{c |}"%9.2f `minn' "{dup 4: }{c |}"%9.2f `maxx' "{dup 4: }{c |}"%9.2f `relcoef' "{dup 5: }" 
di in yellow "  (`f`num'')" 
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"		
}
else {
di in green "  Factor`num'{dup 5: }{c |}  "%-9.0f `nn' "{c |}"%9.2f `rmean' "{dup 4: }{c |}"%9.2f `rsd' "{dup 4: }{c |}"%9.2f `minn' "{dup 4: }{c |}"%9.2f `maxx' "{dup 4: }{c |}"%9.2f `relcoef' "{dup 5: }" 
di in yellow "  (`f`num'')" 
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"		
	}
}
}
di in yellow "  New factor-average variable/s are generated in your data set!"	 
}


if "`def'" != "" & "`fsum'" == "fsum" & "`fdummy'" == "" {
di ""
di as smcl as txt  "{c TLC}{hline 100}{c TRC}"	
di in yellow "  {bf:Factor}{dup 6: }{c |}{bf:    N}{dup 6: }{c |} {bf:    Mean}{dup 4: }{c |} {bf:    Std}{dup 5: }{c |} {bf:    Min}{dup 4: } {c |} {bf:    Max}{dup 4: } {c |} {bf: Cronbach Alpha}{dup 5: }"
di in yellow "  {bf:(Items)}
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"	
local i=25
forvalues num = 1/`i' { 
    capture drop Factor`num'_sum
	if "`f`num''" != "" {
		capture which imputeitems
	if _rc==111 qui ssc install imputeitems //capture and if lines check if imputeitems installed or not 
	//imputeitems is a user-written program by Jean-Benoit Hardouin
	capture drop xkmztwd2*
    imputeitems `f`num'', prefix(xkmztwd2)
	qui egen Factor`num'_sum = rowtotal (xkmztwd2*), missing 
	label variable Factor`num'_sum "sum of variables"
	drop xkmztwd2*
	qui alpha `f`num''
	tempname relcoef
	scalar `relcoef' = r(alpha)
	qui recode Factor`num'_sum 0=. 
	qui sum Factor`num'_sum if Factor`num'_sum !=.
	tempname rmean rsd minn maxx nn
	scalar `rmean' = r(mean)
	scalar `rsd' = r(sd)
	scalar `minn'= r(min)
	scalar `maxx'= r(max)
	scalar `nn' = r(N)
	if `relcoef' <= 0.6 {
di in red "  Factor`num'{dup 5: }{c |}  "%-9.0f `nn' "{c |}"%9.2f `rmean' "{dup 4: }{c |}"%9.2f `rsd' "{dup 4: }{c |}"%9.2f `minn' "{dup 4: }{c |}"%9.2f `maxx' "{dup 4: }{c |}"%9.2f `relcoef' "{dup 5: }" 
di in yellow "  (`f`num'')" 
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"		
}
else {
di in green "  Factor`num'{dup 5: }{c |}  "%-9.0f `nn' "{c |}"%9.2f `rmean' "{dup 4: }{c |}"%9.2f `rsd' "{dup 4: }{c |}"%9.2f `minn' "{dup 4: }{c |}"%9.2f `maxx' "{dup 4: }{c |}"%9.2f `relcoef' "{dup 5: }" 
di in yellow "  (`f`num'')" 
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"		
	}
}
}	   
di in yellow "  New factor-sum variable/s are generated in your data set!"	 

}
if "`def'" != "" & "`fsum'" == "" & "`fdummy'" == "fdummy" {
di ""
di as smcl as txt  "{c TLC}{hline 100}{c TRC}"	
di in yellow "  {bf:Factor}{dup 6: }{c |}{bf:    N}{dup 6: }{c |} {bf:    Mean}{dup 4: }{c |} {bf:    Std}{dup 5: }{c |} {bf:    Min}{dup 4: } {c |} {bf:    Max}{dup 4: } {c |} {bf: KR-coefficient}{dup 5: }"
di in yellow "  {bf:(Items)}
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"	
local i=25
forvalues num = 1/`i' { 
    capture drop Factor`num'_dsum
	if "`f`num''" != "" { 
	capture drop xkmztwdn*
    imputeitems `f`num'', prefix(xkmztwdn)
	qui egen Factor`num'_dsum = rowtotal (xkmztwdn*), missing 
	label variable Factor`num'_dsum "sum of dummy/dichotomous variables"
	drop xkmztwdn*
	capture which kr20
	//kr20 is a user-written program by Herve M. CACI
	if _rc==111 qui ssc install kr20 //capture and if lines check if kr20 installed or not
	qui kr20 `f`num''
	tempname relcoef
	scalar `relcoef' = $S_6
	qui sum Factor`num'_dsum if Factor`num'_dsum !=.
	tempname rmean rsd minn maxx nn
	scalar `rmean' = r(mean)
	scalar `rsd' = r(sd)
	scalar `minn'= r(min)
	scalar `maxx'= r(max)
	scalar `nn' = r(N)
	if `relcoef' <= 0.6 {
di in red "  Factor`num'{dup 5: }{c |}  "%-9.0f `nn' "{c |}"%9.2f `rmean' "{dup 4: }{c |}"%9.2f `rsd' "{dup 4: }{c |}"%9.2f `minn' "{dup 4: }{c |}"%9.2f `maxx' "{dup 4: }{c |}"%9.2f `relcoef' "{dup 5: }" 
di in yellow "  (`f`num'')" 
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"		
}
else {
di in green "  Factor`num'{dup 5: }{c |}  "%-9.0f `nn' "{c |}"%9.2f `rmean' "{dup 4: }{c |}"%9.2f `rsd' "{dup 4: }{c |}"%9.2f `minn' "{dup 4: }{c |}"%9.2f `maxx' "{dup 4: }{c |}"%9.2f `relcoef' "{dup 5: }" 
di in yellow "  (`f`num'')" 
di as smcl as txt  "{c BLC}{hline 100}{c BRC}"		

}
}
}
di in yellow "  New factor-dsum variable/s are generated in your data set!"	 

}
end


