* DiagMA version 1.0 - 01 August 2020
* Authors: Luis Furuya-Kanamori (luis.furuya-kanamori@anu.edu.au) & Suhail AR Doi

program define diagma, rclass
version 14

syntax varlist(min=4 max=4 numeric) [if] [in] ///
[, rr or fe peto re ivhet QE(varname numeric) noGraph lfk CUTplot] 

tokenize `varlist'

preserve
marksample touse, novarlist 
quietly keep if `touse'


*Check required packages
foreach package in lfk admetan {
capture which `package'
if _rc==111 ssc install `package'
}


*Data entry (error/warning messages)
	*Negative values
		sort `1' 
		if `1'[1] <0{
		di as error "{bf:`1'} cannot contain negative values"
		exit 198
		}
		sort `2' 
		if `2'[1] <0{
		di as error "{bf:`2'} cannot contain negative values"
		exit 198
		}
		sort `3' 
		if `3'[1] <0{
		di as error "{bf:`3'} cannot contain negative values"
		exit 198
		}
		sort `4' 
		if `4'[1] <0{
		di as error "{bf:`4'} cannot contain negative values"
		exit 198
		}
		
	*Non-integers
		cap assert int(`1')==`1'
		if _rc!=0{
		di as error "{bf:`1'} contains non-integers" 
		exit _rc
		}
		cap assert int(`2')==`2'
		if _rc!=0{
		di as error "{bf:`2'} contains non-integers" 
		exit _rc
		}
		cap assert int(`3')==`3'
		if _rc!=0{
		di as error "{bf:`3'} contains non-integers" 
		exit _rc
		}
		cap assert int(`4')==`4'
		if _rc!=0{
		di as error "{bf:`4'} contains non-integers" 
		exit _rc
		}

	*RR not allowed
		if "`rr'"!="" {
		di as error "RR option not allowed"
		exit 198
		}
		
	*More than one models specified
		if ("`fe'"!="") & ("`peto'"!="" | "`re'"!="" | "`ivhet'"!="" | "`qe'"!=""){
		di as error "Select only one model"
		exit 198
		}
		if ("`peto'"!="") & ("`fe'"!="" | "`re'"!="" | "`ivhet'"!="" | "`qe'"!=""){
		di as error "Select only one model"
		exit 198
		}
		if ("`re'"!="") & ("`fe'"!="" | "`peto'"!="" | "`ivhet'"!="" | "`qe'"!=""){
		di as error "Select only one model"
		exit 198
		}
		if ("`ivhet'"!="") & ("`fe'"!="" | "`peto'"!="" | "`re'"!="" | "`qe'"!=""){
		di as error "Select only one model"
		exit 198
		}
		if ("`qe'"!="") & ("`fe'"!="" | "`peto'"!="" | "`re'"!="" | "`ivhet'"!=""){
		di as error "Select only one model"
		exit 198
		}
		
	*More than one graph specified
		if "`lfk'"!="" & "`cutplot'"!=""{
		di as error "Select only one graph"
		exit 198
		}


*Data input for analysis
if "`1'" != "" & "`2'" != "" & "`3'" != "" & "`4'" != "" {

	quietly{ 
		gen __tp = `1'
		gen __fp = `2'
		gen __fn = `3'
		gen __tn = `4'
							
	*Continuity correction
		gen __continuity = 1 if __tp==0 | __fp==0 | __fn==0 | __tn==0
			gen __tp_c = __tp+0.5
			gen __fp_c = __fp+0.5
			gen __fn_c = __fn+0.5
			gen __tn_c = __tn+0.5
		
		
*Study specific Sens, Spec, and DOR
	gen __sens = (__tp/(__tp+__fn))
		replace __sens = (__tp_c/(__tp_c+__fn_c)) if __continuity==1
	gen __logit_sens = logit(__tp/(__tp+__fn))
		replace __logit_sens = logit(__tp_c/(__tp_c+__fn_c)) if __continuity==1
	gen __se_sens = sqrt((1/__tp)+(1/__fn))
		replace __se_sens = sqrt((1/__tp_c)+(1/__fn_c)) if __continuity==1

	gen __spec = (__tn/(__tn+__fp))
		replace __spec = (__tn_c/(__tn_c+__fp_c)) if __continuity==1
	gen __logit_spec = logit(__tn/(__tn+__fp))
		replace __logit_spec = logit(__tn_c/(__tn_c+__fp_c)) if __continuity==1
	gen __se_spec = sqrt((1/__fp)+(1/__tn))
		replace __se_spec = sqrt((1/__fp_c)+(1/__tn_c)) if __continuity==1
	
	gen __ln_dor = __logit_sens + __logit_spec
	gen __se_dor = sqrt((__se_sens^2)+(__se_spec^2)) 
	
	
*Meta-analytical models
	*FE
		if "`fe'"!="" {
		admetan __tp __fp __fn __tn, or nograph nointeger iv
		}
	*Peto
		if "`peto'"!="" {
		admetan __tp __fp __fn __tn, or nograph nointeger peto
		}
	*DerSimonian-Laird
		if "`re'"!="" {
		admetan __tp __fp __fn __tn, or nograph nointeger re
		gen __model = "Weights are from random effects model"
		}
	*IVhet (default)
		if "`ivhet'"!="" {
		admetan __tp __fp __fn __tn, or nograph nointeger ivhet
		gen __model = "Weights are from Doi's IVhet model"
		}
		if "`fe'"=="" & "`peto'"=="" & "`re'"=="" & "`ivhet'"=="" & "`qe'"=="" {
		admetan __tp __fp __fn __tn, or nograph nointeger ivhet
		gen __model = "Weights are from Doi's IVhet model"
		}
		if "`or'"!="" & "`fe'"=="" & "`peto'"=="" & "`re'"=="" & "`ivhet'"=="" & "`qe'"=="" {
		admetan __tp __fp __fn __tn, or nograph nointeger ivhet
		gen __model = "Weights are from Doi's IVhet model"
		}
	*QE
		if "`qe'"!="" {
		admetan __tp __fp __fn __tn, or nograph notable nooverall nointeger qe(`qe')
		gen __model = "Weights are from Doi's quality effects model"
		}
	
	*Num studies, num participants, I2
		gen __num_studies = r(k)
		gen __num_part = r(n)
		gen __isq = r(Isq)

		
*Pooled Sens, Spec, DOR, AUC, LR
	*DOR
		gen __ma_ln_dor=r(eff)
		gen __ma_se_dor=r(se_eff)
		gen __ma_dor=exp(__ma_ln_dor)
		gen __ma_lci_dor=exp(__ma_ln_dor-(invnormal(0.975)*__ma_se_dor))
		gen __ma_uci_dor=exp(__ma_ln_dor+(invnormal(0.975)*__ma_se_dor))
		gen __cent_ma_ln_dor = __ln_dor - __ma_ln_dor   
		
	*AUC
		gen __ma_logit_auc = __ma_ln_dor/2 
			replace __ma_logit_auc = (ln(1/__ma_dor))/2 if __ma_dor<1
		gen __ma_auc = invlogit(__ma_logit_auc)
		gen __ma_se_auc = __ma_se_dor*0.5
		gen __ma_logit_lci_auc = __ma_logit_auc - (invnormal(0.975)*__ma_se_auc)
		gen __ma_logit_uci_auc = __ma_logit_auc + (invnormal(0.975)*__ma_se_auc)
		gen __ma_lci_auc = invlogit(__ma_logit_lci_auc)
		gen __ma_uci_auc = invlogit(__ma_logit_uci_auc)
			gen __ma_aucr = 1-__ma_auc if __ma_dor<1
			gen __ma_lci_aucr = 1-__ma_uci_auc if __ma_dor<1
			gen __ma_uci_aucr = 1-__ma_lci_auc if __ma_dor<1 
				replace __ma_auc = __ma_aucr if __ma_aucr!=.
				replace __ma_lci_auc = __ma_lci_aucr if __ma_lci_aucr!=.
				replace __ma_uci_auc = __ma_uci_aucr if __ma_uci_aucr!=. 
		
	*Sens
		regress __logit_sens __cent_ma_ln_dor, vce(robust)
		gen __ma_logit_sens=_b[_cons]
		gen __ma_sens=invlogit(__ma_logit_sens)
						
	*Spec
		regress __logit_spec __cent_ma_ln_dor, vce(robust)
		gen __ma_logit_spec=_b[_cons]
		gen __ma_spec=invlogit(__ma_logit_spec)
		
	*SE Sens/Spec
			gen __prop_sens = ((__ma_sens *(1-__ma_sens))-0.25)
			gen __prop_spec = ((__ma_spec *(1-__ma_spec))-0.25)
		gen __ma_se_sens = sqrt((0.5 -__prop_sens+__prop_spec)*(__ma_se_dor^2))
		gen __ma_lci_sens=invlogit(__ma_logit_sens-(invnormal(0.975)*__ma_se_sens))
		gen __ma_uci_sens=invlogit(__ma_logit_sens+(invnormal(0.975)*__ma_se_sens))
		gen __ma_se_spec = sqrt((0.5 +__prop_sens-__prop_spec)*(__ma_se_dor^2))
		gen __ma_lci_spec=invlogit(__ma_logit_spec-(invnormal(0.975)*__ma_se_spec))
		gen __ma_uci_spec=invlogit(__ma_logit_spec+(invnormal(0.975)*__ma_se_spec))	
		
	*Positive and Negative LR
		gen __ma_ln_plr = ln(__ma_sens/(1-__ma_spec))
		gen __ma_plr = exp(__ma_ln_plr)
		gen __ma_ln_nlr = ln((1-__ma_sens)/__ma_spec)
		gen __ma_nlr = exp(__ma_ln_nlr)
			gen __prop1 = abs(__ma_ln_plr) / (abs(__ma_ln_plr)+abs(__ma_ln_nlr))
			gen	__prop2 = abs(__ma_ln_nlr) / (abs(__ma_ln_plr)+abs(__ma_ln_nlr))
		gen __ma_se_plr = sqrt(__prop1*__ma_se_dor^2) 
			replace __ma_se_plr = sqrt(0.5*__ma_se_dor^2) if __ma_dor==1
		gen __ma_lci_plr = exp(__ma_ln_plr - (invnormal(0.975)*__ma_se_plr)) 
		gen __ma_uci_plr = exp(__ma_ln_plr + (invnormal(0.975)*__ma_se_plr)) 
		gen __ma_se_nlr = sqrt(__prop2*__ma_se_dor^2) 
			replace __ma_se_nlr = sqrt(0.5*__ma_se_dor^2) if __ma_dor==1
		gen __ma_lci_nlr = exp(__ma_ln_nlr - (invnormal(0.975)*__ma_se_nlr)) 
		gen __ma_uci_nlr = exp(__ma_ln_nlr + (invnormal(0.975)*__ma_se_nlr)) 


*Prev disease
	egen __tp_tot = sum(__tp) if _rsample==1
	egen __fn_tot = sum(__fn) if _rsample==1
	gen __prev_dis = ((__tp_tot+__fn_tot)/__num_part)*100


*Pub Bias (LFK)
gen __ES = _ES
gen __seES = _seES
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
	gen 	__r2 = __z + (__r*(__es_dif)) 
	egen __r2_sum = sum(__r2) 
	gen __lfk = (5/(2*_N)) * (__r2_sum) 
}
}

	
*Graph - ROC
if "`graph'" != "nograph" & "`lfk'"=="" & "`cutplot'"==""{
	quietly cap set obs 1000

	quietly gen __gsens = __sens
	quietly gen __gspec = 1-__spec

	quietly gen __g_ma_sens = __ma_sens
	quietly gen __g_ma_spec = 1-__ma_spec
		quietly gen __g_ma_lci_sens = __ma_lci_sens
		quietly gen __g_ma_uci_sens = __ma_uci_sens
		quietly gen __g_ma_lci_spec = 1-__ma_lci_spec
		quietly gen __g_ma_uci_spec = 1-__ma_uci_spec
			quietly gen __g_ma_range_spec = __g_ma_lci_spec[1] in 1
			quietly replace __g_ma_range_spec = __g_ma_uci_spec[1] in 2
	
	quietly gen __y = (_n/100) - 0.01 if _n<=101
	quietly egen __ma_dor2 = max(__ma_dor) if _n<=101
		quietly egen __ma_lci_dor2 = max(__ma_lci_dor) if _n<=101
		quietly egen __ma_uci_dor2 = max(__ma_uci_dor) if _n<=101
	quietly gen __x = 1 - ((__ma_dor2*(1-__y)) / ((__ma_dor2*(1-__y))+__y)) if _n<=101
		quietly gen __x_lci = 1 - ((__ma_lci_dor2*(1-__y)) / ((__ma_lci_dor2*(1-__y))+__y)) if _n<=101
		quietly gen __x_uci = 1 - ((__ma_uci_dor2*(1-__y)) / ((__ma_uci_dor2*(1-__y))+__y)) if _n<=101
	quietly gen __x2 = __y

	gsort _WT
	gen __wt_min = _WT[1]
	gsort -_WT
	gen __wt_max = _WT[1]
	gen __wt_prop = __wt_max/__wt_min
	
	if __wt_prop>5{
	sort __x
	local model = __model[1]
	tw (rarea  __g_ma_lci_sens __g_ma_uci_sens __g_ma_range_spec, color(gs13) lcolor(white)) ///
		(line __y __x2, lpattern(dash) lwidth(medthick)) ///
		(line __y __x, lwidth(medthick)) ///
			(line __y __x_lci, lpattern(shortdash) lcolor(gs11)) ///
			(line __y __x_uci, lpattern(shortdash) lcolor(gs11)) ///
		(scatter __g_ma_sens __g_ma_spec, msize(vlarge) msymbol(s) color(gs4)) ///
		(scatter __gsens __gspec [aw=_WT], msize(vsmall) msymbol(oh) color(gs7)) ///
		, legend(off) sch(s1mono) ///	
		ytitle("Sensitivity", margin(small)) ///                    
		ylabel(#7, angle(horiz)) ///
		xtitle("1-Specificity", margin(small)) ///
		xlabel(#7, angle(horiz)) ///
		note(Note: `model', size(tiny)) ///
		aspectratio(1) ///
		scale(1.5)
	}	
	if __wt_prop<=5{
	sort __x
	local model = __model[1]
	tw (rarea  __g_ma_lci_sens __g_ma_uci_sens __g_ma_range_spec, color(gs13) lcolor(white)) ///
		(line __y __x2, lpattern(dash) lwidth(medthick)) ///
		(line __y __x, lwidth(medthick)) ///
			(line __y __x_lci, lpattern(shortdash) lcolor(gs11)) ///
			(line __y __x_uci, lpattern(shortdash) lcolor(gs11)) ///
		(scatter __g_ma_sens __g_ma_spec, msize(vlarge) msymbol(s) color(gs4)) ///
		(scatter __gsens __gspec [aw=_WT], msize(vsmall) msymbol(Oh) color(gs7)) ///
		, legend(off) sch(s1mono) ///	
		ytitle("Sensitivity", margin(small)) ///                    
		ylabel(#7, angle(horiz)) ///
		xtitle("1-Specificity", margin(small)) ///
		xlabel(#7, angle(horiz)) ///
		note(Note: `model', size(tiny)) ///
		aspectratio(1) ///
		scale(1.5)
	}			
}


*Graph - Doi plot
if "`lfk'"!="" & "`cutplot'"=="" & "`graph'" != "nograph" {
	quietly tostring __lfk, gen(__lfk_str) force
	quietly gen ___lfk_str1 = substr(__lfk_str,1, strpos(__lfk_str,".")+2)
	local lfk_str1 = ___lfk_str1[1]
	local es_z_min_1 = __es_z_min[1]
	local lfk_1 = round(__lfk[1],0.01)

		if `lfk_1' >=-1 & `lfk_1' <=1{
		tw (connected __z_abs __ES, xline(`es_z_min_1', lcolor(black) noextend) mcolor(black) msize(vlarge) msymbol(circle) mfcolor(white) lcolor(black) lpattern(shortdash)) ///
			, ytitle(| Z-score |) ytitle(, size(large)) yscale(reverse) ylabel(, labsize(large) angle(horizontal) labgap(small) nogrid) ///
			xtitle(LnDOR) xtitle(, size(large)margin(medsmall)) xlabel(, labsize(large) labgap(small)) ///
			aspectratio(1.3) graphregion(fcolor(white)) ///
			title(LFK index = `lfk_str1' (no asymmetry), size(medsmall) margin(medium)) 
		}
		if (`lfk_1' <-1 & `lfk_1' >=-2) | (`lfk_1' >1 & `lfk_1' <=2 ){
		tw (connected __z_abs __ES, xline(`es_z_min_1', lcolor(black) noextend) mcolor(black) msize(vlarge) msymbol(circle) mfcolor(white) lcolor(black) lpattern(shortdash)) ///
			, ytitle(| Z-score |) ytitle(, size(large)) yscale(reverse) ylabel(, labsize(large) angle(horizontal) labgap(small) nogrid) ///
			xtitle(LnDOR) xtitle(, size(large) margin(medsmall)) xlabel(, labsize(large) labgap(small)) ///
			aspectratio(1.3) graphregion(fcolor(white)) ///
			title(LFK index = `lfk_str1' (minor asymmetry), size(medsmall) margin(medium)) 
		}
		if `lfk_1' <-2 | `lfk_1' >2{
		tw (connected __z_abs __ES, xline(`es_z_min_1', lcolor(black) noextend) mcolor(black) msize(vlarge) msymbol(circle) mfcolor(white) lcolor(black) lpattern(shortdash)) ///
			, ytitle(| Z-score |) ytitle(, size(large)) yscale(reverse) ylabel(, labsize(large) angle(horizontal) labgap(small) nogrid) ///
			xtitle(LnDOR) xtitle(, size(large) margin(medsmall)) xlabel(, labsize(large) labgap(small)) ///
			aspectratio(1.3) graphregion(fcolor(white)) ///
			title(LFK index = `lfk_str1' (major asymmetry), size(medsmall) margin(medium))   
		}
}

*Graph - Cut-off plot
if "`cutplot'"!="" & "`lfk'"=="" & "`graph'" != "nograph" {
graph drop _all
set graph off
	tw (scatter __logit_sens __cent_ma_ln_dor , mcolor(maroon) msymbol(O) msize(large)) ///
		(lfit __logit_sens __cent_ma_ln_dor, lcolor(gray) lwidth(medthick) lpattern(dash)) ///
		, xtitle(Centred LnDOR) xtitle(, size(large)margin(medsmall)) xlabel(, labsize(large) labgap(small)) ///
		ytitle(Logit Sens) ytitle(, size(large)) ylabel(, labsize(large) angle(horizontal) labgap(small)) ///
		graphregion(fcolor(white)) legend(off) aspectratio(0.4) name(sens)
	tw (scatter __logit_spec __cent_ma_ln_dor , mcolor(navy) msymbol(O) msize(large)) ///
		(lfit __logit_spec __cent_ma_ln_dor, lcolor(gray) lwidth(medthick) lpattern(dash)) ///
		, xtitle(Centred LnDOR) xtitle(, size(large)margin(medsmall)) xlabel(, labsize(large) labgap(small)) ///
		ytitle(Logit Spec) ytitle(, size(large)) ylabel(, labsize(large) angle(horizontal) labgap(small)) ///
		graphregion(fcolor(white)) legend(off) aspectratio(0.4) name(spec)
set graph on		
	graph combine sens spec, colfirst xcommon cols(1) graphregion(fcolor(white))
}


*Display results
di ""
di as text "Input form: TP FP FN TN assumed"
di as text "Note: " __model[1]

sort __continuity
if __continuity[1]==1{	
di as text "Continuity correction was applied"
}
di as text "Studies included: " (__num_studies[1])
di as text "Participants included: " (__num_part[1])
di as text "Prevalence of disease: " round(__prev_dis[1],0.1) "%"
di as text "Heterogeneity (I-squared): " round(__isq[1],0.1) "%"
if __lfk[1]>=-1 & __lfk[1]<=1{
di as text "Pub bias (LFK index): " round(__lfk[1],0.1) ", no asymmetry"
}
if (__lfk[1] <-1 & __lfk[1] >=-2) | (__lfk[1] >1 & __lfk[1] <=2 ){
di as text "Pub bias (LFK index): " round(__lfk[1],0.1) ", minor asymmetry"
}
if __lfk[1] <-2 | __lfk[1] >2 {
di as text "Pub bias (LFK index): " round(__lfk[1],0.1) ", major asymmetry"
}
	
di ""
di in smcl as txt "{hline 13}{c TT}{hline 50}"
di in smcl as txt "{col 14}{c |}      Estimate      95% Conf. Interval"
di in smcl as txt "{hline 13}{c +}{hline 50}"
	
	di in smcl as res "Sens" as txt "{col 14}{c |}" ///
	"{col 22}" round(__ma_sens[1],0.001) ///
	"{col 37}" round(__ma_lci_sens[1],0.001) ///
	"{col 46}" round(__ma_uci_sens[1],0.001) 
	
	di in smcl as res "Spec" as txt "{col 14}{c |}" ///
	"{col 22}" round(__ma_spec[1],0.001) ///
	"{col 37}" round(__ma_lci_spec[1],0.001) ///
	"{col 46}" round(__ma_uci_spec[1],0.001) 

	di in smcl as res "LR+" as text "{col 14}{c |}" ///
	"{col 22}" round(__ma_plr[1],0.001) ///
	"{col 37}" round(__ma_lci_plr[1],0.001) ///
	"{col 46}" round(__ma_uci_plr[1],0.001) 
	
	di in smcl as res "LR-" as text "{col 14}{c |}" ///
	"{col 22}" round(__ma_nlr[1],0.001) ///
	"{col 37}" round(__ma_lci_nlr[1],0.001) ///
	"{col 46}" round(__ma_uci_nlr[1],0.001) 	
	
	di in smcl as res "DOR" as text "{col 14}{c |}" ///
	"{col 22}" round(__ma_dor[1],0.001) ///
	"{col 37}" round(__ma_lci_dor[1],0.001) ///
	"{col 46}" round(__ma_uci_dor[1],0.001) 

	di in smcl as res "AUC" as text "{col 14}{c |}" ///
	"{col 22}" round(__ma_auc[1],0.001) ///
	"{col 37}" round(__ma_lci_auc[1],0.001) ///
	"{col 46}" round(__ma_uci_auc[1],0.001) 	
	
di in smcl as txt "{hline 13}{c BT}{hline 50}"

if __ma_auc[1]<0.5{
di as error "AUC <0.5, check positive and negative test results are correctly tagged"
}
if "`re'"!="" & __isq[1]>25 & (__lfk[1]>=-2 & __lfk[1]<=2){
di as error "RE model selected, check for spurious significance"
}
if "`re'"!="" & __isq[1]>25 & (__lfk[1]<-2 | __lfk[1]>2){
di as error "RE model selected, check for robustness of point estimates and spurious significance"
}


*Scalars
	return scalar num_studies = __num_studies[1]
	return scalar num_participants = __num_part[1]
	return scalar prev_dis = __prev_dis[1]
	return scalar i_sq = __isq[1]
	return scalar lfk = __lfk[1]
	return scalar se_auc = __ma_se_auc[1]
	return scalar logit_auc = __ma_logit_auc[1]
	return scalar se_dor = __ma_se_dor[1]
	return scalar ln_dor = __ma_ln_dor[1]
	return scalar se_neg_lr = __ma_se_nlr[1]
	return scalar ln_neg_lr = __ma_ln_nlr[1]
	return scalar se_pos_lr = __ma_se_plr[1]
	return scalar ln_pos_lr = __ma_ln_plr[1]
	return scalar se_spec = __ma_se_spec[1]
	return scalar logit_spec = __ma_logit_spec[1]
	return scalar se_sens = __ma_se_sens[1]
	return scalar logit_sens = __ma_logit_sens[1]
	
	
*Restore data and exit
restore 
end
exit
