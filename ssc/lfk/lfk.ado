* LFK version 1.0 - 09 April 2020
* Authors: Luis Furuya-Kanamori (luis.furuya-kanamori@anu.edu.au) & Suhail AR Doi


program define lfk, rclass
version 14

syntax varlist(min=2 max=4 numeric) [if] [in] [, rr or noGraph]

tokenize `varlist'
preserve

marksample touse, novarlist 
quietly keep if `touse'


*Data entry (error/warning messages)
if "`3'" != "" & "`4'" == "" {
	display as error "Must specify variables as either binary data (t_cases t_non-cases c_cases c_non-cases) or ES seES"
	exit 198
}
*

if "`rr'" != "" & "`or'" != "" {
	display as error "Options or and rr cannot both be specified"
	exit 198
}
*

if "`3'" == "" & "`4'" == "" {
	sort `2'
		if `2'[1] <= 0 {
			display as error "Variable {bf:`2'} cannot contain negative values"
			exit 198
		}
}
*

if "`3'" == "" & "`4'" == "" {
	sort `1'
		if `1'[1] > 0 {
			display in red "Verify that variable {bf:`1'} is log transformed"
		}
}
*


*Binary data input + OR assumed (default)
if "`3'" != "" & "`4'" != "" & "`or'" == "" & "`rr'" == "" {
	
	display ""
	display as text "Note: Data input format t_cases t_non-cases c_cases c_non-cases assumed"
	display as text "Note: OR assumed"  

		quietly{ 
			gen __a = `1'
			gen __b = `2'
			gen __c = `3'
			gen __d = `4'
			
				gen __drop = 1 if __a==0 & __c==0
				replace __drop = 1 if __a==. | __b==. | __c==. | __d==.
				sort __drop
				gen __drop_study_num = _n if __drop==1
				gsort -__drop_study_num
					if __drop_study_num[1]!=.{
								noisily display as text "Note: Number of studies excluded = " __drop_study_num[1]
					}
				drop if __a==0 & __c==0
				gen __continuity = 1 if __a==0 | __c==0 
				replace __a = __a+0.5 if __continuity ==1
				replace __b = __b+0.5 if __continuity ==1
				replace __c = __c+0.5 if __continuity ==1
				replace __d = __d+0.5 if __continuity ==1
				
				gen __ES = ln((__a*__d)/(__b*__c))
				gen __seES = sqrt((1/__a)+(1/__b)+(1/__c)+(1/__d))
		}
}		
*


*Binary data input + OR selected
if "`3'" != "" & "`4'" != "" & "`or'" != "" & "`rr'" == "" {
	
	display ""
	display as text "Note: Data input format t_cases t_non-cases c_cases c_non-cases assumed"
	display as text "Note: OR selected"  

		quietly{ 
			gen __a = `1'
			gen __b = `2'
			gen __c = `3'
			gen __d = `4'
			
				gen __drop = 1 if __a==0 & __c==0
				replace __drop = 1 if __a==. | __b==. | __c==. | __d==.
				sort __drop
				gen __drop_study_num = _n if __drop==1
				gsort -__drop_study_num
					if __drop_study_num[1]!=.{
						noisily display as text "Note: Number of studies excluded = " __drop_study_num[1]
					}
				drop if __a==0 & __c==0
				gen __continuity = 1 if __a==0 | __c==0 
				replace __a = __a+0.5 if __continuity ==1
				replace __b = __b+0.5 if __continuity ==1
				replace __c = __c+0.5 if __continuity ==1
				replace __d = __d+0.5 if __continuity ==1
				
				gen __ES = ln((__a*__d)/(__b*__c))
				gen __seES = sqrt((1/__a)+(1/__b)+(1/__c)+(1/__d))
		}
}			
*


*Binary data input + RR selected
if "`3'" != "" & "`4'" != "" & "`or'" == "" & "`rr'" != ""{
	
	display ""
	display as text "Note: Data input format t_cases t_non-cases c_cases c_non-cases assumed"
	display as text "Note: RR selected"  

		quietly{ 
			gen __a = `1'
			gen __b = `2'
			gen __c = `3'
			gen __d = `4'
			
				gen __drop = 1 if __a==0 & __c==0
				replace __drop = 1 if __a==. | __b==. | __c==. | __d==.
				sort __drop
				gen __drop_study_num = _n if __drop==1
				gsort -__drop_study_num
					if __drop_study_num[1]!=.{
						noisily display as text "Note: Number of studies excluded = " __drop_study_num[1]
					}
				drop if __a==0 & __c==0
				gen __continuity = 1 if __a==0 | __c==0 
				replace __a = __a+0.5 if __continuity ==1
				replace __b = __b+0.5 if __continuity ==1
				replace __c = __c+0.5 if __continuity ==1
				replace __d = __d+0.5 if __continuity ==1
				
				gen __ES = ln((__a/(__a+__b))/(__c/(__c+__d)))
				gen __seES = sqrt((1/__a)+(1/__c)-(1/(__a+__b))-(1/(__c+__d)))
		}
}			
*


*Theta SE_Theta input 
if "`3'" == "" & "`4'" == ""{
	
	display ""
	display as text "Note: Data input format ES seES assumed"
	
		quietly{
			gen __ES = `1'
			gen __seES = `2'
			
				gen __drop = 1 if __ES==. | __seES==.
				sort __drop
				gen __drop_study_num = _n if __drop==1
				gsort -__drop_study_num
					if __drop_study_num[1]!=.{
						noisily display as text "Note: Number of studies excluded = " __drop_study_num[1] 
					}
		}
}
*


*Number of studies included (output + error/warning messages) // Number of studies excluded (see above)
quietly drop if __drop==1
gen __study_num = _n
sort __study_num
	if __study_num[1] ==.{
		display as error "No studies found"
		exit 198
		}
	display as text "Note: Number of studies included = " __study_num[_N]
	
if __study_num[_N] < 5 {
	display in red "For optimal interpretation at least five studies are needed"
}
*


*LFK calculation
quietly{ 
	drop if __ES==.
	bysort __ES __seES: gen __dup = cond(_N==1,1,_n) 
	gsort -__dup __ES
	gen __dup_max = __dup[1] 
	sort __ES __dup
	gen __seES2 = __seES^2 
	egen __seES2max = max(__seES2) 
	gen __n = round(((__seES2max/__seES2)*100),1) 
	gen __rank1 = sum(__n) if __dup ==1 
	replace __rank1 = __rank1[_n-1] if __rank1==.  
	gen __pct1 = __rank1[_n-__dup_max] 
	replace __pct1 = 0 if __pct1 ==. 
	gen __rank2 = (__rank1 + __pct1)/2 
	egen __n_sum = sum(__n) if __dup==1 				
	replace __n_sum = __n_sum[_n-1] if __n_sum==. 		
	gen __i = (__rank2-0.5)/__n_sum 
	gen __z = invnorm(__i)  	
	gen __z_abs = abs(invnorm(__i)) 
	sort __z_abs 
	gen __es_z_min = __ES[1] 
	gen __es_dif = __ES - __es_z_min 
	sort __z 
	gen __z_min = __z[1] 
	gen __z_max = __z[_N] 
	sort __es_dif 
	gen __es_dif_min = __es_dif[1] 
	gen __es_dif_max = __es_dif[_N] 
	gen __r = (__z_max-__z_min) / (__es_dif_max-__es_dif_min) 
	gen __r2 = __z + (__r*(__es_dif)) 
	egen __r2_sum = sum(__r2) 
	gen __lfk = (5/(2*_N)) * (__r2_sum) 
	return scalar lfk = __lfk[1]
}
*


*LFK as string + output
	quietly tostring __lfk, gen(__lfk_str) force
	quietly gen ___lfk_str1 = substr(__lfk_str,1, strpos(__lfk_str,".")+2)
	local lfk_str1 = ___lfk_str1[1]

	display ""
	display as text "LFK index"
	display `lfk_str1'

		
*Doi plot
if "`graph'" != "nograph"{
	local es_z_min_1 = __es_z_min[1]
	local lfk_1 = round(__lfk[1],0.01)
		
	if `lfk_1' >=-1 & `lfk_1' <=1{
		twoway (connected __z_abs __ES, xline(`es_z_min_1', lcolor(black) noextend) mcolor(black) msize(vlarge) msymbol(circle) mfcolor(white) lcolor(black) lpattern(shortdash)), ///
			ytitle(| Z-score |) ytitle(, size(large)) yscale(reverse) ylabel(, labsize(large) angle(horizontal) labgap(small) nogrid) ///
			xtitle(ES) xtitle(, size(large)) xlabel(, labsize(large) labgap(small)) ///
			aspectratio(1.3) graphregion(fcolor(white)) ///
			title(LFK index = `lfk_str1' (no asymmetry), size(medsmall) margin(medium)) ///
	
	}

	if (`lfk_1' <-1 & `lfk_1' >=-2) | (`lfk_1' >1 & `lfk_1' <=2 ){
		twoway (connected __z_abs __ES, xline(`es_z_min_1', lcolor(black) noextend) mcolor(black) msize(vlarge) msymbol(circle) mfcolor(white) lcolor(black) lpattern(shortdash)), ///
			ytitle(| Z-score |) ytitle(, size(large)) yscale(reverse) ylabel(, labsize(large) angle(horizontal) labgap(small) nogrid) ///
			xtitle(ES) xtitle(, size(large)) xlabel(, labsize(large) labgap(small)) ///
			aspectratio(1.3) graphregion(fcolor(white)) ///
			title(LFK index = `lfk_str1' (minor asymmetry), size(medsmall) margin(medium)) ///
	
	}
	
	if `lfk_1' <-2 | `lfk_1' >2 {
		twoway (connected __z_abs __ES, xline(`es_z_min_1', lcolor(black) noextend) mcolor(black) msize(vlarge) msymbol(circle) mfcolor(white) lcolor(black) lpattern(shortdash)), ///
			ytitle(| Z-score |) ytitle(, size(large)) yscale(reverse) ylabel(, labsize(large) angle(horizontal) labgap(small) nogrid) ///
			xtitle(ES) xtitle(, size(large)) xlabel(, labsize(large) labgap(small)) ///
			aspectratio(1.3) graphregion(fcolor(white)) ///
			title(LFK index = `lfk_str1' (major asymmetry), size(medsmall) margin(medium)) ///  
	
	}
}		
*

restore 
end
exit
