cap program drop midas
*! version 2.00 December 21, 2008
*! version 1.00 August 15, 2007
*! Ben A. Dwamena: bdwamena@umich.edu 

program define midas, rclass byable(recall) sortpreserve
version 9
 #delimit;
 syntax varlist(min=4 max=4) [if] [in] , [ ID(varlist max=4)  
 NIP(integer 7) MODCHK(string) EBpred(string) LEVEL(integer 95) SCHEME(passthru) 
 qtab(varlist) qbar(varlist) QLAB   RESults(string) TABle(string)   
 BIVBOX  CHIPlot GALB(string) INF(string)  FUNnel PUBBias 
 BFORest(string) UFORest(string) FORData  forID(string asis) FORStats HETfor MScale(real 0.45) TEXTScale(real 0.45) 
 ROCPlane SROC(string)
 FAGAN(real -1) PDDAM(numlist min=2 max=2) LRMatrix
 PLOTtype TESTlab(string asis) HSIZE(integer 8) VSIZE(integer 8)
 REGvars(varlist) ZCF(real 0.5) CSIZE(real 36)  *];
#delimit cr


qui {
preserve
marksample touse, novarlist
keep if `touse'
}

tokenize `varlist'
global tp `1'
global fp `2'    
global fn `3'
global tn `4'


/* Check syntax */

if `level' < 10 | `level' > 99 {
di as error "level() must be between 10 and 99"
	exit 198
}



	
/*Data Management*/
qui {
tempvar pid
gen `pid'= _n
datasig
local checksig = r(datasignature)
global alph = (100-`level')/200
local numobs = _N
return scalar nstudies=`numobs'
if "`id'" != "" {
egen StudyIds = concat(`id'), p("/") 
}
else {
tempvar id
gen `id'=_n
gen StudyIds = `id'  
} 

if `"`testlab'"' == "" {
local tlab  "" 
}
else if `"`testlab'"' != "" {
local tlab `"`testlab'"'
}

if "`modchk'" != "" {
if "`modchk'" == "inf" {
version 10: xtmodchk tp fp fn tn, plot(inf)
}
else if "`modchk'" == "bvn" {
version 10: xtmodchk tp fp fn tn, plot(bvn)
}
else if "`modchk'" == "gof" {
version 10: xtmodchk tp fp fn tn, plot(gof)
}
else if "`modchk'" == "out" {
version 10: xtmodchk tp fp fn tn, plot(out)
}
else if "`modchk'" == "all" {
version 10: xtmodchk tp fp fn tn, plot(all)
}
exit
}


if "`ebpred'" != "" {
if "`ebpred'" == "for" {
version 10: ebayes tp fp fn tn, plot(for)
} 
else if "`ebpred'" == "roc" {
version 10: ebayes tp fp fn tn, plot(roc)
} 
exit
}




 if `fagan' ~= -1 {
        cap assert inrange(`fagan',0,1)
        if _rc ~= 0 {
            di in red "fagan(#) argument must be between 0 and 1 if specified"
            error 198
        }
}
nois di ""
nois di ""
nois di ""


 
/* QUALITY ASSESSMENT */

if "`qbar'" != "" {
if "`qlab'" == "qlab" {
noisily quadas `qbar',  labvar(`qlab') qgraph
}
else if "`qlab'" == "" {
noisily quadas `qbar', qgraph 
}     
}

else  if "`qtab'" != "" {
if "`qlab'" == "qlab" {
noisily quadas `qtab', labvar(`qlab') qtable
}
else if "`qlab'" == "" {
noisily quadas `qtab', qtable 
}
}


/* CALCULATE TOTALS */
tempvar sum sumtp sumfn sumtn sumfp sumtpfn sumtnfp sumsu
egen `sumtp' = total($tp)
egen `sumfn' = total($fn)
egen `sumtn' = total($tn)
egen `sumfp' = total($fp)
gen `sumtpfn' = `sumtp' + `sumfn'
gen `sumtnfp' = `sumtn' + `sumfp'
egen `sum' = rsum($tp $fn $tn $fp)
global prev = `sumtpfn'/(`sumtnfp' + `sumtpfn')
gen `sumsu' = sum(`sum')


/* Study Specific Adjustment for Zeros */
tempvar zc_tp zc_fn zc_fp zc_tn zero zc_sens zc_fpr zc_spec zc_tpr zc_fnr zc_tot 
gen `zc_tp' = $tp
gen `zc_fp' = $fp
gen `zc_fn' = $fn
gen `zc_tn' = $tn
gen `zero' = 0
replace `zero' = 1 if $tp == 0 | $fp == 0 | $fn == 0 | $tn == 0
replace `zc_tp' = `zc_tp' + `zcf' if `zero' == 1
replace `zc_fp' = `zc_fp' + `zcf' if `zero' == 1
replace `zc_fn' = `zc_fn' + `zcf' if `zero' == 1
replace `zc_tn' = `zc_tn' + `zcf' if `zero' == 1
gen `zc_sens' = `zc_tp'/(`zc_tp'+`zc_fn')    /* adjusted sensitivity */
gen `zc_tpr' = `zc_sens'             /* adjusted true pos rate */
gen `zc_fnr' = `zc_fn'/(`zc_tp'+`zc_fn')     /* adjusted false neg rate */  
gen `zc_spec' = `zc_tn'/(`zc_tn'+`zc_fp')    /* adjusted specificity */
gen `zc_fpr' = `zc_fp'/(`zc_tn'+`zc_fp')     /* adjusted false pos rate */
gen `zc_tot' = `zc_tp'+`zc_fp'+`zc_fn'+`zc_tn'   /* adjusted total */


/* STUDY-SPECIFIC Sensitivity (True Positive Rate)*/
tempvar sens senslo senshi sensse spec speclo spechi specse FPR          
gen `sens' = $tp/($tp+$fn)  
gen `senslo' = invbinomial($tp+$fn,$tp,$alph)   
gen `senshi' = invbinomial($tp+$fn,$tp,1-$alph)
gen `sensse' = (`senshi'-`senslo')/(2*invnorm(1-$alph)) 

/* STUDY-SPECIFIC Specificity (True Negative Rate) */

gen `spec' = $tn/($tn+$fp)      
gen `speclo' = invbinomial($tn+$fp,$tn,$alph)  
gen `spechi' = invbinomial($tn+$fp,$tn,1-$alph) 
gen `specse' =(`spechi'-`speclo')/(2*invnorm(1-$alph)) 
gen `FPR' = 1 - `spec'


/* Study Specific Positive Likelihood Ratio And Confidence Interval */
tempvar lrp llrp llrpvar llrpse lrplo lrphi lrpse 
gen `lrp' = `zc_sens'/`zc_fpr'
gen `llrp' = ln(`zc_sens'/`zc_fpr')
gen `llrpvar' = (1/`zc_tp')+(1/`zc_fp')-(1/(`zc_tp'+`zc_fn'))-(1/(`zc_fp'+`zc_tn'))
gen `llrpse' = sqrt((1/`zc_tp')+(1/`zc_fp')-(1/(`zc_tp'+`zc_fn'))-(1/(`zc_fp'+`zc_tn')))
gen `lrplo' = exp(`llrp' - invnorm(1-$alph)*`llrpse')
gen `lrphi' = exp(`llrp' + invnorm(1-$alph)*`llrpse')
gen `lrpse' = (`lrphi'-`lrplo')/(2*invnorm(1-$alph))

/* Study Specific Negative Likelihood Ratio And Confidence Interval */
tempvar lrn llrn llrnvar llrnse lrnlo lrnhi lrnse 

gen `lrn' = `zc_fnr'/`zc_spec'
gen `llrn' = ln(`zc_fnr'/`zc_spec')
gen `llrnvar' = (1/`zc_fn')+(1/`zc_tn')-(1/(`zc_tp'+`zc_fn'))-(1/(`zc_fp'+`zc_tn'))
gen `llrnse' = sqrt((1/`zc_fn')+(1/`zc_tn')-(1/(`zc_tp'+`zc_fn'))-(1/(`zc_fp'+`zc_tn')))
gen `lrnlo' = exp(`llrn' - invnorm(1-$alph)*`llrnse')
gen `lrnhi' = exp(`llrn' + invnorm(1-$alph)*`llrnse')
gen `lrnse' = (`lrnhi'-`lrnlo')/(2*invnorm(1-$alph))

/* Study Specific Diagnostic Odds Ratio And Confidence Interval */
tempvar dor dorvar dorse dorlo dorhi ldor ldorvar ldorse ldorlo ldorhi 
tempname ecf
scalar `ecf' = sqrt(3)/_pi
gen `dor' = (`zc_tp'*`zc_tn')/(`zc_fp'*`zc_fn')
gen `ldor' = ln(`dor')
gen `dorvar' = (1/`zc_fn')+(1/`zc_tn')+(1/`zc_fp')+(1/`zc_tp')
gen `ldorvar' = (1/`zc_fn')+(1/`zc_tn')+(1/`zc_fp')+(1/`zc_tp')
gen `ldorse' = sqrt(`ldorvar')
gen `ldorlo' = `ldor'-invnorm(1-$alph)*`ldorse'
gen `ldorhi' = `ldor'+invnorm(1-$alph)*`ldorse'
gen `dorlo' = exp(`ldor'-invnorm(1-$alph) * `ldorse')
gen `dorhi' = exp(`ldor'+invnorm(1-$alph) * `ldorse')
gen `dorse' = (`dorhi'-`dorlo')/(2*invnorm(1-$alph))
replace `ldorse' = `ldorse' * `ecf'
replace `ldorlo' = `ldorlo' * `ecf'
replace `ldorhi' = `ldorhi' * `ecf'


/* Study Specific Logit Transform of Sensitivity (TPR) and CI */
tempvar lsens lsensvar lsensse lsenslo lsenshi 
gen `lsens' = logit(`zc_sens')
gen `lsensvar' = 1/(`zc_sens'*(1-`zc_sens')*(`zc_tp'+`zc_fn'))
gen `lsensse' = sqrt(`lsensvar')
gen `lsenslo' = `lsens' - invnormal(1-$alph) * `lsensse'
gen `lsenshi' = `lsens' + invnormal(1-$alph) * `lsensse'

/* Study Specific Logit Transform of Specificity and CI */
tempvar lspec lspecvar lspecse lspeclo lspechi
gen `lspec' = logit(`zc_spec')
gen `lspecvar' = 1/(`zc_spec'*(1-`zc_spec')*(`zc_tn'+`zc_fp'))
gen `lspecse' = sqrt(`lspecvar')
gen `lspeclo' = `lspec' - invnormal(1-$alph) * `lspecse'
gen `lspechi' = `lspec' + invnormal(1-$alph) * `lspecse'


/* Study Specific Logit Transform of 1 - Specificity (FPR) and CI */
tempvar lfpr lfprvar lfprsd lfprlo lfprhi
gen `lfpr' = logit(`zc_fpr')
gen `lfprvar' = 1/(`zc_fpr'*(1-`zc_fpr')*(`zc_tn'+`zc_fp'))
gen `lfprsd' = sqrt(`lfprvar')
gen `lfprlo' = `lfpr' - invnormal(1-$alph) * `lfprsd'
gen `lfprhi' = `lfpr' + invnormal(1-$alph) * `lfprsd'
nois di ""


/*GALBRAITH PLOT FOR INVESTIGATING HETEROGENEITY AND SMALL STUDY BIAS*/     


if "`galb'" != ""{
if "`plottype'" != "" {
local plottype "Galbraith Plot"
}
else if "`plottype'" == "" {
local plottype " "
}

if "`galb'" == "ldor" {
nois midagalb `ldor' `ldorse'
}

else if "`galb'" == "lrp" {
nois midagalb `llrp' `llrpse'
}

else if "`galb'" == "lrn" {
nois midagalb `llrn' `llrnse'
}
else if "`galb'" == "tpr" {
nois midagalb `lsens' `lsensse'
}
else if "`galb'" == "tnr" {
nois midagalb `lspec' `lspecse'
}
}


/* BIVARIATE BOX PLOT */
if "`bivbox'"=="bivbox" {
tempvar boxvar1 boxvar2
gen `boxvar1' = `lsens'
label var `boxvar1' "LOGIT_SENS"
gen `boxvar2' = `lspec'
label var `boxvar2' "LOGIT_SPEC"
nois bvbox `boxvar1' `boxvar2' 
}
          
                                     
/* CHI PLOT */

if "`chiplot'" == "chiplot" {
tempvar cvar1 cvar2
gen `cvar1' = `lsens'
label var `cvar1' "LOGIT_SENS"
gen `cvar2' = `lspec'
label var `cvar2' "LOGIT_SPEC"
nois di as text "CHIPLOT OF LOGIT_SENS AND LOGIT_SPEC"

nois midachi `cvar1' `cvar2'
}


/* INFLUENCE ANALYSIS */
   	if  "`inf'" !="" {

tempvar var1 var1lo var1hi var2 var2lo var2hi
     gen `var1' = `sens'			
     gen `var1lo' = `senslo' 
     gen `var1hi' = `senshi' 
     gen `var2' = `spec'			
     gen `var2lo' = `speclo' 
     gen `var2hi' = `spechi'
     	
tempvar so 
gen `so' = _n
sort `so'
version 10
xtbbrre tp fp fn tn
local isumvar1=$mtpr
local isumvar2=$mtnr
tempvar istvar1 istvar1se istvar1lo istvar1hi istvar2 istvar2se istvar2lo istvar2hi 
      local n = _N
      gen `istvar1' = .
      gen `istvar1lo' = .
      gen `istvar1hi' = .
      gen `istvar2' = .
      gen `istvar2lo' = .
      gen `istvar2hi' = .
	 local i = 1
     tempvar s
     gen `s' = _n
     while (`i' <= `n') { 
     sort `so'
   xtbbrre tp fp fn tn if `s' != `i'
   nois di ""
	local study "`=StudyIds[`i']'"
	nois di as text"Influence Analysis Omitting {hilite: `study'}"
 	nois di "" 	
	replace `istvar1' = $mtpr in `i'  
     replace `istvar1hi' = $mtprhi in `i' 
     replace `istvar1lo' = $mtprlo in `i' 
     replace `istvar2' = $mtnr in `i' 
     replace `istvar2hi' =  $mtnrhi in `i'
     replace `istvar2lo' = $mtnrlo in `i'  
     local i=`i'+1     
 }     
    
if "`inf'"=="stats" {
local iobs=_N
      
      nois di as text "{title: Influence Analysis in meta-analysis of `iobs' studies/datasets}"
      nois di " "
      nois di as text "Sensitivity"
      nois di " "
      nois di as text "{hline 65}"
      noi di as text _col(2) "Study omitted" _col(20) "{c |}" _col(24) "Estimate" _col(39) "[95%  Conf.  Interval]"
      nois di as text "{hline 19}{c +}{hline 57}"
      local i = 1
      while `i' <= `n' {
      local a = StudyIds in `i' 
      local b = `istvar1' in `i'
      local c = `istvar1lo'  in `i'
      local d = `istvar1hi'  in `i'
      noi di as text _col(2) %6.3f "`a'" _col(20) in gr "{c |}" as res _col(24) %6.3f `b' _col(39) %6.3f `c' _col(49) %6.3f `d'
      local i=`i'+1
      }
      nois di as text "{hline 19}{c BT}{hline 57}"
      nois di " "
      nois di " "
      nois di as text "`Specificity"
      nois di " "
      nois di as text "{hline 65}"
      noi di as text _col(2) "Study omitted" _col(20) "{c |}" _col(24) "Estimate" _col(39) "[95%  Conf.  Interval]"
      nois di as text "{hline 19}{c +}{hline 57}"
      local i = 1
      while `i' <= `n' { 
         local a = StudyIds in `i' 
         local b = `istvar2' in `i'
         local c = `istvar2lo'  in `i'
         local d = `istvar2hi'  in `i'
         noi di as text _col(2) %6.3f "`a'" _col(20) in gr "{c |}" as res _col(24) %6.3f `b' _col(39) %6.3f `c' _col(49) %6.3f `d'
         local i=`i'+1
      }
      nois di as text "{hline 19}{c BT}{hline 57}"
}
else if "`inf'" == "graph" {	

tempvar obs studyvar1 studyvar2 studyvar1lo studyvar1hi studyvar2lo studyvar2hi
 
gen `studyvar2' = `istvar2'
gen `studyvar2lo' = `istvar2lo'
gen `studyvar2hi' = `istvar2hi'
gen `studyvar1' = `istvar1'
gen `studyvar1lo' = `istvar1lo'
gen `studyvar1hi' = `istvar1hi'
	
gen `obs' = _n 	
count
local max = r(N)
label value `obs' obs
forval i = 1/`max'{
local value = `"`value' `i'"'
label define obs `i' "`=StudyIds[`i']'", modify
}
local mscale2 = 1.5 * `mscale'
local ylabopt "labsize(*`textscale') tl(*0) labgap(*10)"

local xlab "xlab(minmax, format(%5.2f) labsize(*`textscale'))"
set graphics off
#delimit;
twoway (rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`"`value'"', valuelabel `ylabopt' angle(360)) 
hor s(i) lpat(blank)  `xlab')(scatter `obs' `studyvar1', ms(i) msize(`mscale2') mcolor(gs10)), 
legend(off) xtitle("", size(*.5)) yscale(noline) ysc(reverse) xscale(off fill) plotregion(style(none)) ytitle("", size(*.5)) 
title("Study Omitted", size(*.75) pos(1)) fxsize(0) name(idplot, replace);
#delimit cr
#delimit;
twoway (rcap `studyvar1lo' `studyvar1hi' `obs', ylabel(`"`value'"', nolabel `ylabopt' angle(360)) 
hor s(i) blpattern(solid) blwidth(thin) blcolor(black) `xlab')
(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10) xline(`isumvar1', lpattern(-)))
(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black))
, nodraw legend(off) title(Sensitivity, size(*.75)) xtitle("")  ytitle("") ysc(reverse) name(infplot1, replace);
#delimit cr

#delimit;
twoway (rcap `studyvar2lo' `studyvar2hi' `obs', ylabel(`"`value'"', nolabel `ylabopt' angle(360)) 
hor s(i) blpattern(solid) blwidth(thin) blcolor(black) `xlab')
(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10) xline(`isumvar2', lpattern(-)))
(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black)),  nodraw 
legend(off) title("Specificity", size(*.75)) xtitle("") ytitle("") ysc(reverse) name(infplot2, replace);
#delimit cr
set graphics on
noi graph combine idplot infplot1  infplot2,  xsize(4) ysize(7) row(1) `scheme' 
}

}	 


	

/* PUBLICATION BIAS */
 
 if "`pubbias'" == "pubbias" { 
local ptitle: di "Deeks' Funnel Plot Asymmetry Test"
tempvar  n1 n2 nt ESS zero lthetai thetai sethetai xb yb stpred logn pubwgt  
tempname stbias
gen `n1' = `zc_tp' + `zc_fn'  
gen `n2' = `zc_tn' + `zc_fp'
gen `nt' =  `n1' + `n2'
gen `ESS' =(4 * `n1' * `n2')/(`n1' + `n2')
gen `lthetai' = log((`zc_tp' * `zc_tn')/(`zc_fp' * `zc_fn')) 
gen `thetai' =.
gen `sethetai' =.
gen `pubwgt' =.
gen `xb' =.
gen `yb' =.

nois di " "
nois di " "
nois di as text "{title:STATISTICAL TESTS FOR SMALL STUDY EFFECTS/PUBLICATION BIAS}"
replace `thetai'=`lthetai' 
replace `sethetai' = sqrt(`ESS') 
replace `xb'=1/sqrt(`ESS')
label var `xb' "1/root(ESS)"
replace `yb' = `thetai'
label var `yb' "Diagnostic Odds Ratio"
replace `pubwgt' = `ESS'
nois di " "
nois di " "
nois di " "
sum `xb', detail
local xbmax=r(max)
local xbmin=r(min)
sum `yb', detail
local ybmax=r(max)
local ybmin=r(min)
local ymean= r(mean)
mylabels 1 10 100 1000, myscale(log(@)) local(ylab) 
regress  `yb' `xb'[weight=`pubwgt'], level(`level')
estimates store `stbias'
scalar intercept = _b[_cons]
scalar se_intercept = _se[_cons]
scalar rmse = e(rmse)
scalar df = e(df_r)
scalar p = 2*ttail(e(df_r), abs(return(score_bc)/return(score_se)))
nois matrix define vcov = e(V)
nois matrix define b = e(b)
matrix colnames b =     Bias Intercept
matrix rownames vcov =  Bias Intercept 
matrix colnames vcov =  Bias Intercept 
nois matrix post b vcov, dep(yb) dof(`e(df_r)') obs(`e(N)')
local pbias=2*ttail(e(df_r), abs(_b[Bias]/_se[Bias]))
nois ereturn display, level(`level')
local note: di "pvalue  = "%6.2f `pbias'
estimates restore `stbias'
predict `stpred'
local stline "(line `xb' `stpred' ,  clpattern(dash) clwidth(vthin))"

#delimit;
nois twoway `stline'(scatter `xb' `yb' , sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O) `options')
(scatter `xb' `yb', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)), 
xlab(`ylab', angle(horizontal)labsize(*`textscale') format(%7.2f)) 
legend(label(2 "Study") label(1 "Regression" "Line") order(2 1) pos(2) col(1) size(*.75)) 
 ylab(, labsize(*`textscale') angle(horizontal)) title("`plottype' `tlab'", size(*0.75)) aspectratio(1) 
plotregion(margin(zero)) xtitle("Diagnostic Odds Ratio") xline(`ybmean')
subtitle("`ptitle'" "`note'", size(*.65)) yscale(rev) `scheme';
#delimit cr
}
 



if ("`qualitab'`qbar'`qqplot'`pubbias'`bivbox'`chiplot'" == "") /// 
& ("`galb'`maxbias'`funnel'`cum'`inf'" == "") {




/*  MODEL SPECIFICATION AND ESTIMATION   */
if "`checksig'" != "$checksig" {
version 10: xtbbrre tp fp fn tn
}

*saving transformed estimates
mat vv=r(matV)
mat bb=r(matb)
return matrix matv= vv, copy
return matrix matb= bb, copy

return scalar dev = $dev
return scalar AIC = $AIC
return scalar BIC = $BIC
return scalar BICdiff = $BICdiff
return scalar mtpr = $mtpr
return scalar mtprlo = $mtprlo 
return scalar mtprhi = $mtprhi
return scalar mtprse = $mtprse

return scalar mtnr = $mtnr
return scalar mtnrlo = $mtnrlo
return scalar mtnrhi = $mtnrhi
return scalar mtnrse = $mtnrse

return scalar mldor =  $mldor
return scalar mldorlo = $mldorlo
return scalar mldorhi = $mldorhi
return scalar mldorse = $mldorse

return scalar mdor = $mdor
return scalar mdorlo = $mdorlo
return scalar mdorhi = $mdorhi
return scalar mdorse = $mdorse

return scalar mlrp = $mlrp
return scalar mlrplo = $mlrplo
return scalar mlrphi = $mlrphi
return scalar mlrpse = $mlrpse

return scalar mlrn = $mlrn
return scalar mlrnlo = $mlrnlo
return scalar mlrnhi = $mlrnhi
return scalar mlrnse = $mlrnse

return scalar  reffs1 = $mreffs1
return scalar  reffs1lo = $mreffs1lo
return scalar  reffs1hi = $mreffs1hi
return scalar  reffs1se = $mreffs1se


return scalar  reffs2 = $mreffs2
return scalar  reffs2lo = $mreffs2lo
return scalar  reffs2hi = $mreffs2hi
return scalar  reffs2se = $mreffs2se
return scalar  ICC1 = $ICC1
return scalar  ICC1lo = $ICC1lo
return scalar  ICC1hi = $ICC1hi
return scalar  ICC1se = $ICC1se
return scalar  ICC2 = $ICC2
return scalar  ICC2lo = $ICC2lo
return scalar  ICC2hi = $ICC2hi
return scalar  ICC2se = $ICC2se
return scalar  tprmed = $tprmed
return scalar  tprmedlo = $tprmedlo
return scalar  tprmedhi = $tprmedhi
return scalar  tnrmed = $tnrmed
return scalar  tnrmedlo = $tnrmedlo
return scalar  tnrmedhi = $tnrmedhi
return scalar  rho = $mrho
return scalar  rholo = $mrholo
return scalar  rhohi = $mrhohi
return scalar  covar = $mcovar

return scalar fsens = $fsens
return scalar fspec = $fspec
return scalar fldor = $fldor
return scalar fdor =  $fdor
return scalar flrp =  $flrp
return scalar flrn =  $flrn

return scalar Islrt = $Islrt
return scalar Islrtlo = $Islrtlo
return scalar Islrthi = $Islrthi

*SUMMARY ESTIMATES

local dev = $dev
local AIC = $AIC
local BIC = $BIC
local BICdiff = $BICdiff
local cov01 = $covsnsp
local mtpr = $mtpr
local mtprlo = $mtprlo 
local mtprhi = $mtprhi
local mtprse = $mtprse

local mtnr = $mtnr
local mtnrlo = $mtnrlo
local mtnrhi = $mtnrhi
local mtnrse = $mtnrse

local mldor =  $mldor
local mldorlo = $mldorlo
local mldorhi = $mldorhi
local mldorse = $mldorse

local mdor = $mdor
local mdorlo = $mdorlo
local mdorhi = $mdorhi
local mdorse = $mdorse

local mlrp = $mlrp
local mlrplo = $mlrplo
local mlrphi = $mlrphi
local mlrpse = $mlrpse

local mlrn = $mlrn
local mlrnlo = $mlrnlo
local mlrnhi = $mlrnhi
local mlrnse = $mlrnse

local reffs1 = $mreffs1
local reffs1lo = $mreffs1lo
local reffs1hi = $mreffs1hi
local reffs1se = $mreffs1se


local reffs2 = $mreffs2
local reffs2lo = $mreffs2lo
local reffs2hi = $mreffs2hi
local reffs2se = $mreffs2se

local  ICC1 = $ICC1
local  ICC1lo = $ICC1lo
local  ICC1hi = $ICC1hi
local  ICC1se = $ICC1se

local  ICC2 = $ICC2
local  ICC2lo = $ICC2lo
local  ICC2hi = $ICC2hi
local  ICC2se = $ICC2se
local  tprmed = $tprmed
local  tnrmed = $tnrmed
local  tprmedlo = $tprmedlo
local  tnrmedlo = $tnrmedlo
local  tprmedhi = $tprmedhi
local  tnrmedhi = $tnrmedhi
local rho = $mrho
local rholo = $mrholo
local rhohi = $mrhohi
local covar = $mcovar

tempname sp sn spse snse lrtchi lrtpchi lrtdf 
tempname Islrt Islrtlo Islrthi
scalar `sp' = $sp
scalar `spse' = $spse
scalar `sn' = $sn
scalar `snse' = $snse
scalar `lrtchi'  = $lrtchi
scalar `lrtpchi' = $lrtpchi
scalar `lrtdf' = $lrtdf
scalar `Islrt' = $Islrt
scalar `Islrtlo' = $Islrtlo
scalar `Islrthi' = $Islrthi


 
    
/* HETEROGENEITY: Sensitivity */ 

tempvar devsens Qsens
tempname  Qsensdf  prsens Isqsens Isqsenslo Isqsenshi
gen `devsens' = ((`sens' - $fsens)^2)/(($fsens*(1-$fsens))/($tp+$fn))
egen `Qsens' = total(`devsens')
scalar `Qsensdf' = `numobs' - 1
scalar `prsens' = chi2tail(`Qsensdf',`Qsens')
homogeni `Qsens' `Qsensdf'
scalar `Isqsens' = r(Isq)
scalar `Isqsenslo' = r(Isqlo)
scalar `Isqsenshi' = r(Isqhi)


/* HETEROGENEITY: Specificity  */

tempvar devspec Qspec
tempname  Qspecdf  prspec Isqspec Isqspeclo Isqspechi
gen `devspec' = ((`spec' - $fspec)^2)/(($fspec*(1-$fspec))/($tn+$fp))
egen `Qspec' = total(`devspec')
scalar `Qspecdf' = `numobs' - 1

scalar `prspec' = chi2tail(`Qspecdf',`Qspec')
homogeni `Qspec' `Qspecdf'
scalar `Isqspec' = r(Isq)
scalar `Isqspeclo' = r(Isqlo)
scalar `Isqspechi' = r(Isqhi)


/* HETEROGENEITY: Positive Likelihood Ratio */

tempvar Qlrp devlrp
tempname prlrp Qlrpdf Isqlrp Isqlrplo Isqlrphi 
gen `devlrp' = ((`llrp' - ln($flrp))^2)/`llrpvar'
egen `Qlrp' = total(`devlrp')
scalar `Qlrpdf' = `numobs' - 1
scalar `prlrp' = chi2tail(`Qlrpdf',`Qlrp')
homogeni `Qlrp' `Qlrpdf'
scalar `Isqlrp' = r(Isqlo)
scalar `Isqlrplo' = r(Isqlo)
scalar `Isqlrphi' = r(Isqhi)


/* HETEROGENEITY:  Negative Likelihood Ratio */

tempvar Qlrn devlrn
tempname prlrn Qlrndf Isqlrn Isqlrnlo Isqlrnhi 

gen `devlrn' = ((`llrn' - ln($flrn))^2)/`llrnvar'
egen `Qlrn' = total(`devlrn')
scalar `Qlrndf' = `numobs' - 1
scalar `prlrn' = chi2tail(`Qlrndf',`Qlrn')
homogeni `Qlrn' `Qlrndf'
scalar `Isqlrn' = r(Isq)
scalar `Isqlrnlo' = r(Isqlo)
scalar `Isqlrnhi' = r(Isqhi)


/*  HETEROGENEITY: Diagnostic Odds Ratio */

tempvar Qldor devldor
tempname prldor Qldordf Isqldor Isqldorlo Isqldorhi
gen `devldor' = (`ldor' - $fldor)^2/`ldorvar'
egen `Qldor' = total(`devldor')
scalar `Qldordf' = `numobs' - 1
scalar `prldor' = chi2tail(`Qldordf',`Qldor')

homogeni `Qldor' `Qldordf'
scalar `Isqldor' = r(Isq)
scalar `Isqldorlo' = r(Isqlo)
scalar `Isqldorhi' = r(Isqhi)


tempvar Qdor devdor
tempname prdor Qdordf Isqdor Isqdorlo Isqdorhi
gen `devdor' = exp(((`ldor' - ln($fdor))^2)/`ldorvar')
egen `Qdor' = total(`devdor')
scalar `Qdordf' = `numobs' - 1
scalar `prdor' = chi2tail(`Qdordf',`Qdor')

homogeni `Qdor' `Qdordf'
scalar `Isqdor' = r(Isq)
scalar `Isqdorlo' = r(Isqlo)
scalar `Isqdorhi' = r(Isqhi)

tempvar var1 var2 var1se var2se var1lo var2lo var1hi var2hi
tempname Isq1 Isq1lo Isq1hi Isq2 Isq2lo Isq2hi 
tempname Qvar1 Qvar1df pr1 Qvar2  Qvar2df pr2
     
     gen `var1' = .
     gen `var1se' = .
     gen `var1lo' = . 
     gen `var1hi' = . 
     gen `var2' = .
     gen `var2se' = .
     gen `var2lo' = .
     gen `var2hi' = .
     
if ("`uforest'" == "dss" | "`bforest'" == "dss" | "`table'" == "dss" | "`rocplane'" == "rocplane" )  {
     	
     replace `var1' = `sens'
     replace `var1se' = `sensse'
     replace `var1lo' = `senslo' 
     replace `var1hi' = `senshi' 
     replace `var2' = `spec'
     replace `var2se' = `specse'
     replace `var2lo' = `speclo' 
     replace `var2hi' = `spechi'
     
     local mvar1 = `mtpr'
     local mvar1lo = `mtprlo'
     local mvar1hi = `mtprhi'
     local mvar2 = `mtnr'
     local mvar2lo = `mtnrlo'
     local mvar2hi = `mtnrhi'
     
     scalar `Isq1' = `Isqsens'
     scalar `Isq1lo' = `Isqsenslo'
     scalar `Isq1hi' = `Isqsenshi'
     scalar `Isq2' = `Isqspec'
     scalar `Isq2lo' = `Isqspeclo'
     scalar `Isq2hi' = `Isqspechi'
	scalar `Qvar1' = `Qsens' 
	scalar `Qvar1df' = `Qsensdf' 
	scalar `pr1' = `prsens' 
	scalar `Qvar2' = `Qspec'  
	scalar `Qvar2df' = `Qspecdf' 
	scalar `pr2' = `prspec'

local note1a: di " "%4.2f `mvar1' " [" %4.2f `mvar1lo' " - " %4.2f `mvar1hi' "]"
local note1b: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local note1c: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local note2a: di " "%4.2f `mvar2' " [" %4.2f `mvar2lo' " - " %4.2f `mvar2hi' "]"
local note2b: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local note2c: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 


     
     local gtitle1 "SENSITIVITY"
     local gtitle2 "SPECIFICITY"
     }
     

if ("`uforest'" == "dlr" | "`bforest'" == "dlr" | "`table'" == "dlr") {
     	
     replace `var1' = `lrp'
     replace `var1se' = `lrpse'
     replace `var1lo' = `lrplo' 
     replace `var1hi' = `lrphi' 
     replace `var2' = `lrn'
     replace `var2se' = `lrnse'
     replace `var2lo' = `lrnlo' 
     replace `var2hi' = `lrnhi'
     
     local mvar1 = `mlrp'
     local mvar1lo = `mlrplo'
     local mvar1hi = `mlrphi'
     local mvar2 = `mlrn'
     local mvar2lo = `mlrnlo'
     local mvar2hi = `mlrnhi'
     
     scalar `Isq1' = `Isqlrp'
     scalar `Isq1lo' = `Isqlrplo'
     scalar `Isq1hi' = `Isqlrphi'
     scalar `Isq2' = `Isqlrn'
     scalar `Isq2lo' = `Isqlrnlo'
     scalar `Isq2hi' = `Isqlrnhi'
     
          scalar `Qvar1' = `Qlrp' 
	scalar `Qvar1df' = `Qlrpdf' 
	scalar `pr1' = `prlrp' 
	scalar `Qvar2' = `Qlrn'  
	scalar `Qvar2df' = `Qlrndf' 
	scalar `pr2' = `prlrn'
	
	local note1a: di " "%4.2f `mvar1' " [" %4.2f `mvar1lo' " - " %4.2f `mvar1hi' "]"
local note1b: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local note1c: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local note2a: di " "%4.2f `mvar2' " [" %4.2f `mvar2lo' " - " %4.2f `mvar2hi' "]"
local note2b: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local note2c: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 

     
     local gtitle1 "DLR POSITIVE"
     local gtitle2 "DLR NEGATIVE"
     }
     
if ("`uforest'" == "dlor" | "`bforest'" == "dlor" | "`table'" == "dlor") {
     	
     replace `var1' = `ldor'
     replace `var1se' = `ldorse'
     replace `var1lo' = `ldorlo' 
     replace `var1hi' = `ldor' 
     replace `var2' = `dor'
     replace `var2se' = `dorse'
     replace `var2lo' = `dorlo' 
     replace `var2hi' = `dorhi'
     
     local mvar1 = `mldor'
     local mvar1lo = `mldorlo'
     local mvar1hi = `mldorhi'
     local mvar2 = `mdor'
     local mvar2lo = `mdorlo'
     local mvar2hi = `mdorhi'
     
     scalar `Isq1' = `Isqldor'
     scalar `Isq1lo' = `Isqldorlo'
     scalar `Isq1hi' = `Isqldorhi'
     scalar `Isq2' = `Isqdor'
     scalar `Isq2lo' = `Isqdorlo'
     scalar `Isq2hi' = `Isqdorhi'
     scalar `Qvar1' = `Qldor' 
     scalar `Qvar1df' = `Qldordf' 
     scalar `pr1' = `prldor' 
     scalar `Qvar2' = `Qdor'  
     scalar `Qvar2df' = `Qdordf' 
     scalar `pr2' = `prdor'

local note1a: di " "%4.2f `mvar1' " [" %4.2f `mvar1lo' " - " %4.2f `mvar1hi' "]"
local note1b: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local note1c: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local note2a: di " "%4.2f `mvar2' " [" %4.2f `mvar2lo' " - " %4.2f `mvar2hi' "]"
local note2b: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local note2c: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 

     local gtitle1 "DIAGNOSTIC SCORE"
     local gtitle2 "ODDS RATIO"
     } 
     
      
     
 if "`table'" != "" {
nois di ""
nois di ""
nois di as text "{title: STUDY-SPECIFIC TEST PERFORMANCE ESTIMATES}"
nois di " "
nois di " "
sum `var1', detail
local n1=r(N)
nois di as text "`gtitle1'"
nois di " "
nois di as text"{hline 65}"
nois di in gr _col(2) "Study" _col(20) "{c |}" _col(24) "Estimate" _col(39) "[95%  Conf.  Interval]"
nois di as text"{hline 19}{c +}{hline 47}"
local i = 1
while `i' <= `n1' {            
local a1 = StudyIds in `i' 
local b1 = `var1' in `i'
local c1 = `var1lo'  in `i'
local d1 = `var1hi'  in `i'
nois di in gr _col(2) %6.2f "`a1'" _col(20) in gr "{c |}" in ye _col(24) %6.2f `b1' _col(39) %6.2f `c1' _col(49) %6.2f `d1'
local i=`i'+1
}
nois di as text"{hline 65}"
nois di in gr _col(2) "Combined" _col(20) in gr "{c |}" in ye _col(24) %6.2f `mvar1' _col(39) %6.2f `mvar1lo' _col(49) %6.2f `mvar1hi'
nois di as text"{hline 19}{c BT}{hline 47}"
nois di ""
nois di as txt "Heterogeneity (Chi-square): Q = "as result %5.2f `Qvar1' ///
as txt ", df = "as result %3.2f `Qvar1df' as txt", p = "as result %5.2f `pr1'
nois di " "
nois di as txt"Inconsistency (I-square): I2 = "as res %3.2f `Isq1' _c
nois di as txt", 95% CI = ["as res %3.2f `Isq1lo'                _c
nois di as txt" - "as res %3.2f `Isq1hi' as txt"]"               _n
nois di " "
nois di ""
nois di as text "`gtitle2'"
nois di " "
nois di as text"{hline 65}"
nois di in gr _col(2) "Study" _col(20) "{c |}" _col(24) "Estimate" _col(39) "[95%  Conf.  Interval]"
nois di as text"{hline 19}{c +}{hline 47}"
local i = 1
while `i' <= `n1' {
local a2 = StudyIds in `i' 
local b2 = `var2' in `i'
local c2 = `var2lo'  in `i'
local d2 = `var2hi'  in `i'
nois di in gr _col(2) %6.2f "`a2'" _col(20) in gr "{c |}" in ye _col(24) %6.2f `b2' _col(39) %6.2f `c2' _col(49) %6.2f `d2'
local i=`i'+1
}
nois di as text"{hline 65}" 
nois di in gr _col(2) "Combined" _col(20) in gr "{c |}" in ye _col(24) %6.2f `mvar2' _col(39) %6.2f `mvar2lo' _col(49) %6.2f `mvar2hi'
nois di as text"{hline 19}{c BT}{hline 47}"
nois di ""
nois di as txt "Heterogeneity (Chi-square): Q = " as result %5.2f `Qvar2' ///
as txt ", df =" as result %3.2f `Qvar2df' as txt", p ="as result %5.2f `pr2'
nois di " "
nois di as txt "Inconsistency (I-square): I2 = "as res %3.2f `Isq2' _c
nois di as txt ", 95% CI = ["as res %3.2f `Isq2lo'                _c
nois di as txt " - "as res %3.2f `Isq2hi' as txt"]"               _n
nois di " "
nois di "" 
}


/*ROC PLANE*/
if "`rocplane'" != "" {
local msens = `mvar1'
local msenslo = `mvar1lo'
local msenshi= `mvar1hi'
local mspec = 1-`mvar2'
local mspeclo = 1-`mvar2hi'
local mspechi = 1-`mvar2lo'
nois twoway (pci `msens' 0 `msens' 1, lpat(longdash) lwidth(vthin)) /*
*/ (pci  0 `mspec' 1 `mspec' , lpat(shortdash) lwidth(vthin)) /*
*/ (scatter `sens' `FPR', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O)) /* 
*/ (scatter `sens' `FPR', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)), /*
*/ ytitle("Sensitivity", size(*.90)) xtitle("1-Specificity", size(*.90)) yscale(range(0 1)) /*
*/ yline(`msenslo' `msenshi', lpat(longdash) lwidth(vthin)) aspect(1) /*
*/ xline(`mspeclo' `mspechi', lpat(shortdash) lwidth(medthin)) ylabel( 0(.2)1, nogrid angle(horizontal) format(%7.2f)) /*
*/ xscale(range(0 1)) xlabel(0(.2)1, nogrid format(%7.2f)) title(ROC Plane, size(*.5)) /*
*/ legend(order(1 "Sensitivity" "`note1a'" "`note1b'" "`note1c'" 2 "Specificity" "`note2a'" "`note2b'" "`note2c'") /*
*/ pos(4) ring(0) symxsize(3) forcesize rowgap(1) col(1) size(*.65)) `scheme' ysize(`vsize') name(ROCplot, replace) 
}

if "`forid'" =="" {
local forid "StudyId"
}
if "`bforest'" != "" {
    
/*BIVARIATE FOREST PLOTS*/
tempname obs obs1 obs2 studyvar1 studyvar2 studyvar1lo studyvar1hi studyvar2lo studyvar2hi 
gen `obs' = _n 
gen `obs1' = _n 
gen `obs2' = _n 
local null1: di " "
count
local max = r(N)
local maxx = `max' + 2
label value `obs' obs
forval i = 1/`max'{
local value = `"`value' `i'"'
label define obs `i' "`=StudyIds[`i']'", modify
}

gen `studyvar2' = .
gen `studyvar2lo' = .
gen `studyvar2hi' = .
gen `studyvar1' = .
gen `studyvar1lo' = .
gen `studyvar1hi' = .
	
local ylabopt "labsize(*`textscale') tl(*0) labgap(*5)"

if "`bforest'" == "dss"{
if "`forstats'"=="forstats" {
local notef1a: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local notef1b: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local notef2a: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local notef2b: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 
}
replace `studyvar2' = `var2'
replace `studyvar2lo' = `var2lo'
replace `studyvar2hi' = `var2hi'
replace `studyvar1' = `var1'
replace `studyvar1lo' = `var1lo'
replace `studyvar1hi' = `var1hi'
local xlab1 "xlab(minmax, format(%5.1f) labsize(*`textscale'))"
local xlab2 "xlab(minmax, format(%5.1f) labsize(*`textscale'))"
tostring `studyvar1lo' `studyvar1' `studyvar1hi', gen(`studyvar1lo'1 `studyvar1'1 `studyvar1hi'1) format(%7.2f) force
replace `studyvar1lo'1 = " [" + `studyvar1lo'1 + " - "
replace `studyvar1hi'1 = `studyvar1hi'1 + "]"
egen studyvar1ci = concat(`studyvar1'1 `studyvar1lo'1 `studyvar1hi'1)
label value `obs1' obs1
forval i = 1/`max'{
local value1 = `"`value' `i'"'
label define obs1 `i' "`=studyvar1ci[`i']'", modify
}
tostring `studyvar2lo' `studyvar2' `studyvar2hi', gen(`studyvar2lo'1 `studyvar2'1 `studyvar2hi'1) format(%7.2f) force
replace `studyvar2lo'1 = " [" + `studyvar2lo'1 + " - "
replace `studyvar2hi'1= `studyvar2hi'1 + "]"
egen studyvar2ci = concat(`studyvar2'1 `studyvar2lo'1 `studyvar2hi'1)
label value `obs2' obs2
forval i = 1/`max'{
local value2 = `"`value' `i'"'
label define obs2 `i' "`=studyvar2ci[`i']'", modify
} 	
}

else if "`bforest'" == "dlr" {
if "`forstats'"=="forstats" {
local notef1a: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local notef1b: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local notef2a: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local notef2b: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 
}
replace `studyvar2' = `var2'
replace `studyvar2lo' = max(0.01, `var2lo')
replace `studyvar2hi' = min(1.00, `var2hi')
replace `studyvar1' = `var1'
replace `studyvar1lo' = max(0.01, `var1lo')
replace `studyvar1hi' = min(1000, `var1hi')	
local xlab1 "xlab(minmax, format(%5.1f) labsize(*`textscale'))xsc(log)"
local xlab2 "xlab(minmax, format(%5.0f) labsize(*`textscale'))"
tostring `studyvar1lo' `studyvar1' `studyvar1hi', gen(`studyvar1lo'1 `studyvar1'1 `studyvar1hi'1) format(%7.2f) force
replace `studyvar1lo'1 = " [" + `studyvar1lo'1 + " - "
replace `studyvar1hi'1 = `studyvar1hi'1 + "]"
egen studyvar1ci = concat(`studyvar1'1 `studyvar1lo'1 `studyvar1hi'1)
label value `obs1' obs1
forval i = 1/`max'{
local value1 = `"`value' `i'"'
label define obs1 `i' "`=studyvar1ci[`i']'", modify
}
tostring `studyvar2lo' `studyvar2' `studyvar2hi', gen(`studyvar2lo'1 `studyvar2'1 `studyvar2hi'1) format(%7.2f) force
replace `studyvar2lo'1 = " [" + `studyvar2lo'1 + " - "
replace `studyvar2hi'1= `studyvar2hi'1 + "]"
egen studyvar2ci = concat(`studyvar2'1 `studyvar2lo'1 `studyvar2hi'1)
label value `obs2' obs2
forval i = 1/`max'{
local value2 = `"`value' `i'"'
label define obs2 `i' "`=studyvar2ci[`i']'", modify

}
}

else if "`bforest'" == "dlor" {
if "`forstats'"=="forstats" {
local notef1a: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local notef1b: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local notef2a: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local notef2b: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 
} 
replace `studyvar2' = `var2'
replace `studyvar2lo' = max(0.01, `var2lo')
replace `studyvar2hi' = min(1000, `var2hi')
replace `studyvar1' = `var1'
replace `studyvar1lo' = max(0.01, `var1lo')
replace `studyvar1hi' = `var1hi'
local xlab1 "xlab(minmax, format(%5.1f) labsize(*`textscale')) "
local xlab2 "xlab(minmax, format(%5.0f) labsize(*`textscale')) xsc(log)"
tostring `studyvar1lo' `studyvar1' `studyvar1hi', gen(`studyvar1lo'1 `studyvar1'1 `studyvar1hi'1) format(%7.2f) force
replace `studyvar1lo'1 = " [" + `studyvar1lo'1 + " - "
replace `studyvar1hi'1 = `studyvar1hi'1 + "]"
egen studyvar1ci = concat(`studyvar1'1 `studyvar1lo'1 `studyvar1hi'1)
label value `obs1' obs1
forval i = 1/`max'{
local value1 = `"`value' `i'"'
label define obs1 `i' "`=studyvar1ci[`i']'", modify
}
tostring `studyvar2lo' `studyvar2' `studyvar2hi', gen(`studyvar2lo'1 `studyvar2'1 `studyvar2hi'1) format(%7.2f) force
replace `studyvar2lo'1 = " [" + `studyvar2lo'1 + " - "
replace `studyvar2hi'1= `studyvar2hi'1 + "]"
egen studyvar2ci = concat(`studyvar2'1 `studyvar2lo'1 `studyvar2hi'1)
label value `obs2' obs2
forval i = 1/`max'{
local value2 = `"`value' `i'"'
label define obs2 `i' "`=studyvar2ci[`i']'", modify
}
}

if "`bforest'" != "" {
if "`plottype'" != "" {
local plottype "Forest Plot"
}
else if "`plottype'" == "" {
local plottype " "
}

local null  " "

local note1f: di " "%4.2f `mvar1'  "[" %4.2f `mvar1lo' " - " %4.2f `mvar1hi' "]"
local note2f: di " "%4.2f `mvar2'  "[" %4.2f `mvar2lo' " - " %4.2f `mvar2hi' "]"

if ("`fordata'" == "") {
if "`forstats'"=="forstats" {
nois twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" -2 "`notef1a'" -3 "`notef1b'" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)),  /*
*/ legend(off)  nodraw xtitle("`gtitle1'", size(*.5)) name(forplot1, replace)


nois twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" -2 "`notef2a'" -3 "`notef2b'"  `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) c(l) s(i) lpat(solid)), /*
*/ legend(off) nodraw xtitle("`gtitle2'", size(*.5)) name(forplot2, replace)
nois graph combine forplot1 forplot2, imargin(0 0 0 0) title("`plottype'" "`tlab'", size(*0.75)) 
}
else if "`forstats'"=="" {
nois twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)),  /*
*/ legend(off)  nodraw xtitle("`gtitle1'", size(*.5)) name(forplot1, replace)


nois twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) c(l) s(i) lpat(solid)), /*
*/ legend(off) nodraw xtitle("`gtitle2'", size(*.5)) name(forplot2, replace)

nois graph combine forplot1 forplot2, imargin(0 0 0 0) title("`plottype'" "`tlab'", size(*0.75)) 
 }
}
else if "`fordata'" == "fordata" {
if "`forstats'"=="forstats" {
twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" -3 "`null1'" -2 "`null1'" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatter `obs1' `studyvar1', ms(i) yaxis(2) ylab(`maxx' "`gtitle1' (95% CI)" -2 "`notef1a'" -3 "`notef1b'" -1 "`note1f'" `"`value1'"', valuelabel labsize(*`textscale') noticks labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ , nodraw legend(off)  yti("", axis(2)) xtitle("`gtitle1'", size(*.5)) ysize(`vsize') name(forplot1, replace)

twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" -3 "`null1'" -2 "`null1'" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatter `obs2' `studyvar2', ms(i) yaxis(2) ylab(`maxx' "`gtitle2' (95% CI)"  -2 "`notef2a'" -3 "`notef2b'" -1 "`note2f'" `"`value2'"', valuelabel labsize(*`textscale') noticks  labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) /*
*/ c(l) s(i) lpat(solid)), nodraw legend(off) xtitle("`gtitle2'", size(*.5))  yti("", axis(2))  name(forplot2, replace)

nois graph combine forplot1 forplot2, imargin(0 0 0 0) title("`plottype'" "`tlab'", size(*0.75)) 
}

else if "`forstats'"=="" {

 twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`bforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatter `obs1' `studyvar1', ms(i) yaxis(2) ylab(`maxx' "`gtitle1' (95% CI)" -1 "`note1f'" `"`value1'"', valuelabel labsize(*`textscale') noticks labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ , nodraw legend(off)  yti("", axis(2)) xtitle("`gtitle1'", size(*.5)) ysize(`vsize') name(forplot1, replace)


twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`bforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`bforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED"  `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatter `obs2' `studyvar2', ms(i) yaxis(2) ylab(`maxx' "`gtitle2' (95% CI)" -1 "`note2f'" `"`value2'"', valuelabel labsize(*`textscale') noticks  labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) /*
*/ c(l) s(i) lpat(solid)), nodraw legend(off) xtitle("`gtitle2'", size(*.5))  yti("", axis(2))  name(forplot2, replace)

nois graph combine forplot1 forplot2, imargin(0 0 0 0) title("`plottype'" "`tlab'", size(*0.75)) 
}

}

}
}



else if "`uforest'" != "" {
    
/*UNIVARIATE FOREST PLOTS*/
tempname obs obs1 obs2 studyvar1 studyvar2 studyvar1lo studyvar1hi studyvar2lo studyvar2hi 
gen `obs' = _n 
gen `obs1' = _n 
gen `obs2' = _n 
local null1: di " "
count
local max = r(N)
local maxx = `max' + 2
label value `obs' obs
forval i = 1/`max'{
local value = `"`value' `i'"'
label define obs `i' "`=StudyIds[`i']'", modify
}

gen `studyvar2' = .
gen `studyvar2lo' = .
gen `studyvar2hi' = .
gen `studyvar1' = .
gen `studyvar1lo' = .
gen `studyvar1hi' = .
	
local ylabopt "labsize(*`textscale') tl(*0) labgap(*5)"

if "`uforest'" == "dss"{
if "`forstats'"=="forstats" {
local notef1a: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local notef1b: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local notef2a: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local notef2b: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 
}
replace `studyvar2' = `var2'
replace `studyvar2lo' = `var2lo'
replace `studyvar2hi' = `var2hi'
replace `studyvar1' = `var1'
replace `studyvar1lo' = `var1lo'
replace `studyvar1hi' = `var1hi'
local xlab1 "xlab(minmax, format(%5.1f) labsize(*`textscale'))"
local xlab2 "xlab(minmax, format(%5.1f) labsize(*`textscale'))"
tostring `studyvar1lo' `studyvar1' `studyvar1hi', gen(`studyvar1lo'1 `studyvar1'1 `studyvar1hi'1) format(%7.2f) force
replace `studyvar1lo'1 = " [" + `studyvar1lo'1 + " - "
replace `studyvar1hi'1 = `studyvar1hi'1 + "]"
egen studyvar1ci = concat(`studyvar1'1 `studyvar1lo'1 `studyvar1hi'1)
label value `obs1' obs1
forval i = 1/`max'{
local value1 = `"`value' `i'"'
label define obs1 `i' "`=studyvar1ci[`i']'", modify
}
tostring `studyvar2lo' `studyvar2' `studyvar2hi', gen(`studyvar2lo'1 `studyvar2'1 `studyvar2hi'1) format(%7.2f) force
replace `studyvar2lo'1 = " [" + `studyvar2lo'1 + " - "
replace `studyvar2hi'1= `studyvar2hi'1 + "]"
egen studyvar2ci = concat(`studyvar2'1 `studyvar2lo'1 `studyvar2hi'1)
label value `obs2' obs2
forval i = 1/`max'{
local value2 = `"`value' `i'"'
label define obs2 `i' "`=studyvar2ci[`i']'", modify
} 	
}

else if "`uforest'" == "dlr" {
if "`forstats'"=="forstats" {
local notef1a: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local notef1b: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local notef2a: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local notef2b: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 
}
replace `studyvar2' = `var2'
replace `studyvar2lo' = max(0.01, `var2lo')
replace `studyvar2hi' = min(1.00, `var2hi')
replace `studyvar1' = `var1'
replace `studyvar1lo' = max(0.01, `var1lo')
replace `studyvar1hi' = min(1000, `var1hi')	
local xlab1 "xlab(minmax, format(%5.1f) labsize(*`textscale'))xsc(log)"
local xlab2 "xlab(minmax, format(%5.0f) labsize(*`textscale'))"
tostring `studyvar1lo' `studyvar1' `studyvar1hi', gen(`studyvar1lo'1 `studyvar1'1 `studyvar1hi'1) format(%7.2f) force
replace `studyvar1lo'1 = " [" + `studyvar1lo'1 + " - "
replace `studyvar1hi'1 = `studyvar1hi'1 + "]"
egen studyvar1ci = concat(`studyvar1'1 `studyvar1lo'1 `studyvar1hi'1)
label value `obs1' obs1
forval i = 1/`max'{
local value1 = `"`value' `i'"'
label define obs1 `i' "`=studyvar1ci[`i']'", modify
}
tostring `studyvar2lo' `studyvar2' `studyvar2hi', gen(`studyvar2lo'1 `studyvar2'1 `studyvar2hi'1) format(%7.2f) force
replace `studyvar2lo'1 = " [" + `studyvar2lo'1 + " - "
replace `studyvar2hi'1= `studyvar2hi'1 + "]"
egen studyvar2ci = concat(`studyvar2'1 `studyvar2lo'1 `studyvar2hi'1)
label value `obs2' obs2
forval i = 1/`max'{
local value2 = `"`value' `i'"'
label define obs2 `i' "`=studyvar2ci[`i']'", modify

}
}

else if "`uforest'" == "dlor" {
if "`forstats'"=="forstats" {
local notef1a: di "Q ="%6.2f `Qvar1' ", df = " %3.2f `Qvar1df' ", p = "%5.2f `pr1' "
local notef1b: di "I2 = "%3.2f `Isq1' " [" %3.2f `Isq1lo' " - " %3.2f `Isq1hi' "]"               
local notef2a: di "Q ="%6.2f `Qvar2' ", df = " %3.2f `Qvar2df' ", p = "%5.2f `pr2' "
local notef2b: di "I2 = "%3.2f `Isq2' " [" %3.2f `Isq2lo' " - " %3.2f `Isq2hi' "]" 
}
replace `studyvar2' = `var2'
replace `studyvar2lo' = max(0.01, `var2lo')
replace `studyvar2hi' = min(1000, `var2hi')
replace `studyvar1' = `var1'
replace `studyvar1lo' = max(0.01, `var1lo')
replace `studyvar1hi' = `var1hi'
local xlab1 "xlab(minmax, format(%5.1f) labsize(*`textscale')) "
local xlab2 "xlab(minmax, format(%5.0f) labsize(*`textscale')) xsc(log)"
tostring `studyvar1lo' `studyvar1' `studyvar1hi', gen(`studyvar1lo'1 `studyvar1'1 `studyvar1hi'1) format(%7.2f) force
replace `studyvar1lo'1 = " [" + `studyvar1lo'1 + " - "
replace `studyvar1hi'1 = `studyvar1hi'1 + "]"
egen studyvar1ci = concat(`studyvar1'1 `studyvar1lo'1 `studyvar1hi'1)
label value `obs1' obs1
forval i = 1/`max'{
local value1 = `"`value' `i'"'
label define obs1 `i' "`=studyvar1ci[`i']'", modify
}
tostring `studyvar2lo' `studyvar2' `studyvar2hi', gen(`studyvar2lo'1 `studyvar2'1 `studyvar2hi'1) format(%7.2f) force
replace `studyvar2lo'1 = " [" + `studyvar2lo'1 + " - "
replace `studyvar2hi'1= `studyvar2hi'1 + "]"
egen studyvar2ci = concat(`studyvar2'1 `studyvar2lo'1 `studyvar2hi'1)
label value `obs2' obs2
forval i = 1/`max'{
local value2 = `"`value' `i'"'
label define obs2 `i' "`=studyvar2ci[`i']'", modify
}
}

if "`uforest'" != "" {
if "`plottype'" != "" {
local plottype "Forest Plot"
}
else if "`plottype'" == "" {
local plottype " "
}

local null  " "

local note1f: di " "%4.2f `mvar1'  "[" %4.2f `mvar1lo' " - " %4.2f `mvar1hi' "]"
local note2f: di " "%4.2f `mvar2'  "[" %4.2f `mvar2lo' " - " %4.2f `mvar2hi' "]"

if ("`fordata'" == "") {
if "`forstats'"=="forstats" {
nois twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" -2 "`notef1a'" -3 "`notef1b'" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)),  /*
*/ legend(off)  xtitle("`gtitle1'", size(*.5)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot1, replace)

nois twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" -2 "`notef2a'" -3 "`notef2b'"  `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) c(l) s(i) lpat(solid)), /*
*/ legend(off) xtitle("`gtitle2'", size(*.5)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot2, replace)
}
else if "`forstats'"=="" {

nois twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)),  /*
*/ legend(off)  xtitle("`gtitle1'", size(*.5)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot1, replace)


nois twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) c(l) s(i) lpat(solid)), /*
*/ legend(off) xtitle("`gtitle2'", size(*.5)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot2, replace)
}
}
else if "`fordata'" == "fordata" {
if "`forstats'"=="forstats" {
nois twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED"  -3 "`null1'" -2 "`null1'" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatter `obs1' `studyvar1', ms(i) yaxis(2) ylab(`maxx' "`gtitle1' (95% CI)" -2 "`notef1a'" -3 "`notef1b'" -1 "`note1f'" `"`value1'"', valuelabel labsize(*`textscale') noticks labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ , legend(off)  yti("", axis(2)) xtitle("`gtitle1'", size(*.5)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot1, replace)


nois twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED"  -3 "`null1'" -2 "`null1'"  `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatter `obs2' `studyvar2', ms(i) yaxis(2) ylab(`maxx' "`gtitle2' (95% CI)" -2 "`notef2a'" -3 "`notef2b'" -1 "`note2f'" `"`value2'"', valuelabel labsize(*`textscale') noticks  labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) /*
*/ c(l) s(i) lpat(solid)), legend(off) xtitle("`gtitle2'", size(*.5))  yti("", axis(2)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot2, replace)
}
else if "`forstats'"=="" {

nois twoway (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1lo' `obs' `studyvar1hi'  if (`studyvar1hi' == 1000 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar1hi' `obs' `studyvar1lo'  if (`studyvar1lo' == 0.01 & "`uforest'" == "dlr"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/(rspike `studyvar1lo' `studyvar1hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab1')(scatter `obs' `studyvar1', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar1', ms(o) msize(*`mscale') mcolor(black) xline(`mvar1', lpattern(-)))/*
*/ (scatter `obs1' `studyvar1', ms(i) yaxis(2) ylab(`maxx' "`gtitle1' (95% CI)" -1 "`note1f'" `"`value1'"', valuelabel labsize(*`textscale') noticks labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar1lo' -0.8 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar1lo' -1.2 `mvar1', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar1' -1 /*
*/ `mvar1hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar1' -1 `mvar1hi', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ , legend(off)  yti("", axis(2)) xtitle("`gtitle1'", size(*.5)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot1, replace)


nois twoway (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlor"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2lo' `obs' `studyvar2hi'  if (`studyvar2hi' == 1000 & "`uforest'" == "dlor"),  lwidth(vthin) lpat(solid)  barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (pcarrow `obs' `studyvar2hi' `obs' `studyvar2lo'  if (`studyvar2lo' == 0.01 & "`uforest'" == "dlr"),  lpat(solid) lwidth(vthin)   barbsize(0) mlwidth(vthin) ylabel(-1 "" `"`value'"', valuelabel labc(none)))/*
*/ (rspike `studyvar2lo' `studyvar2hi' `obs', ylabel(`maxx' "`forid'" -1 "COMBINED" `"`value'"', valuelabel `ylabopt' angle(360)) /*
*/ hor s(i) blpattern(solid) blwidth(vthin) blcolor(black) `xlab2')(scatter `obs' `studyvar2', ms(S) msize(`mscale2') mcolor(gs10))(scatter `obs' `studyvar2', ms(o) msize(*`mscale') mcolor(black) xline(`mvar2', lpattern(-)))/*
*/ (scatter `obs2' `studyvar2', ms(i) yaxis(2) ylab(`maxx' "`gtitle2' (95% CI)" -1 "`note2f'" `"`value2'"', valuelabel labsize(*`textscale') noticks  labgap(*5) angle(360) axis(2)))(scatteri -1 `mvar2lo' -0.8 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) /*
*/ (scatteri -1 `mvar2lo' -1.2 `mvar2', clcolor(black) c(l) s(i) lpat(solid)) (scatteri -0.8 `mvar2' -1 /*
*/ `mvar2hi', clcolor(black) c(l) s(i) lpat(solid))(scatteri -1.2 `mvar2' -1 `mvar2hi', clcolor(black) /*
*/ c(l) s(i) lpat(solid)), legend(off) xtitle("`gtitle2'", size(*.5))  yti("", axis(2)) title("`plottype'" "`tlab'", size(*0.75)) ysize(`vsize') name(forplot2, replace)

}
 }

}

}



/* FAGAN PLOT */
if `fagan' != -1 {
local prev "`fagan'"
nois di " "
nois di " "
nois di as text "FAGAN'S(BAYESIAN) NOMOGRAM"
nois di " "
nois di " "
fagani `prev' `mlrp' `mlrn'
}



/*LIKELIHOOD RATIO SCATTERGRAM */

if "`lrmatrix'" == "lrmatrix" {
nois di as text "LIKELIHOOD RATIO SCATTERGRAM "
nois lrmat `lrp' `lrn', `level' sum1(`mlrp' `mlrplo' `mlrphi') sum2(`mlrn' `mlrnlo' `mlrnhi')
}

/*UNCONDITIONAL PREDICTIVE VALUES OR CONDITIONAL PROBABILITY PLOT*/

 if "`pddam'" != "" {
tokenize `pddam'
local mu1 `1' 
local mu2 `2'
nois di as text "CONDITIONAL PROBABILITY PLOT AND UNCONDITIONAL PREDICTIVE VALUES"
nois di " "
nois di " "
nois pddami `mtpr' `mtprse' `mtnr' `mtnrse', pred(`mu1' `mu2') sum1(`mlrp' `mlrplo' `mlrphi') sum2(`mlrn' `mlrnlo' `mlrnhi')

}



/* BIVARIATE MIXED-EFFECTS METAREGRESSION */

if "`regvars'" !="" {
version 10
nois bivreg $tp $fp $fn $tn, covars(`regvars') `level'

}



/*SUMMARY ROC CURVE*/
tempvar  x CB1 CB2 CBsens CBspec yroc llyroc ulyroc
tempvar PB1 PB2 PBsn PBsp CPI 
	          
/* model-based parameters */

local rhoci = `cov01'/ (`snse' * `spse')
local pred1se = sqrt(`reffs2' + `snse'^2)
local pred2se = sqrt(`reffs1' + `spse'^2)
local rhopred = (`covar' + `cov01')/(`pred1se'*`pred2se')
local NP = 500
range `CPI' 0 `=2* c(pi)' `NP'

/* Parameters for mean operating point and SROC Space */
local mbeta = (max(0.001, `reffs1')/max(0.001, `reffs2'))^.25
local malpha = `sn'*`mbeta' + `sp'/`mbeta'

/*local malpha=logit(`mtnr')-(`reffs2'`reffs1'+((`reffs2'-`reffs1')^2+4*`cov01'^2)^0.5)/(2*`cov01')*logit(`mtpr') 
local mbeta=(`reffs2'-`reffs1'+((`reffs2'-`reffs1')^2+4*`cov01'^2)^0.5)/(2*`cov01')*/

range `x' 0 1 `NP'
gen double `yroc' = invlogit((-logit(`x')/`mbeta'+`malpha')/`mbeta')
replace `yroc' = 0 if `x' == 1
replace `yroc' = 1 if `x' == 0
integ `yroc' `x',  trapezoid
local AUC = r(integral)
scalar N=r(N_points)
return scalar AUC = `AUC'
local AUClo = min(1.00, (`AUC'+(invnormal(0.975)^2)/(2*N)-invnormal(0.975)*sqrt((`AUC'*(1-`AUC')+/*
*/((invnormal(0.975)^2)/(4*N)))/N))/(1+((invnormal(0.975)^2)/N)))

local AUChi = max(0, (`AUC'+(invnormal(0.975)^2)/(2*N)+invnormal(0.975)*sqrt((`AUC'*(1-`AUC')+/*
*/((invnormal(0.975)^2)/(4*N)))/N))/(1+((invnormal(0.975)^2)/N)))
return scalar AUClo = `AUClo'
return scalar AUChi = `AUChi'

local note: di "AUC = "%3.2f `AUC' " [" %3.2f `AUClo' " - " %3.2f `AUChi' "]" 
local snnote: di "SENS = "%3.2f `mtpr' " [" %3.2f `mtprlo' " - " %3.2f `mtprhi' "]" 
local spnote: di "SPEC = "%3.2f `mtnr' " [" %3.2f `mtnrlo' " - " %3.2f `mtnrhi' "]"
				
/* Derivation of parameters for 95% confidence ellipse about mean operating point*/

local kci = sqrt(2*invF(2, `numobs'-2,`level'/100))
gen `CB2' = `sp' + `spse' * `kci' * cos(`CPI')
gen `CB1' = `sn' + `snse' * `kci' * cos(`CPI' + acos(`rhoci'))
gen `CBsens' = invlogit(`CB1')
gen `CBspec' = invlogit(`CB2')
					
/* Derivation of 95% prediction ellipse*/
		
gen `PB2' = `sp' + `pred2se' * `kci' * cos(`CPI')
gen `PB1' = `sn' + `pred1se' * `kci' * cos(`CPI' + acos(`rhopred'))
gen `PBsn' = invlogit(`PB1')
gen `PBsp' = invlogit(`PB2') 

if "`sroc'" == "none" {
if "`plottype'" != "" {
local plottype "SROC without Confidence and Prediction Contours"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))
(line `yroc' `x', clpat(solid) clc(black))
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)), 
xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) plotregion(margin(zero)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating Point" "`snnote'" "`spnote'"
3 "SROC Curve" "`note'") pos(5) ring(0) col(1) symxsize(2) forcesize rowgap(1)  size(*.50))
 xsize(`hsize') ysize(`vsize') `scheme' aspect(1) title("`plottype'" "`tlab'", size(*0.75)) ;
#delimit cr
}
if "`sroc'" == "pred" {
if "`plottype'" != "" {
local plottype "SROC with Prediction Contour"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))(line `yroc' `x', clpat(solid) clc(black))
(line `PBsn' `PBsp', clpat(dot)  clc(black))(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) xti(Specificity) plotregion(margin(zero))
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating Point" "`snnote'" "`spnote'"
3 "SROC Curve" "`note'" 4 "`level'% Prediction Contour") pos(5) ring(0) col(1)
 symxsize(2) forcesize rowgap(1) size(*.50))xsize(`hsize') aspect(1) `scheme' 
ysize(`vsize') title("`plottype'" "`tlab'", size(*0.75)) ;
#delimit cr
}

if "`sroc'" == "conf" {
if "`plottype'" != "" {
local plottype "SROC with Confidence Contour"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))
(line `yroc' `x', clpat(solid) clc(black))(line `CBsens' `CBspec', clpat(dash) clc(black) clw(thin)) 
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating 
Point" "`snnote'" "`spnote'"
3 "SROC Curve" "`note'" 4 "`level'% Confidence Contour") 
pos(5) ring(0) col(1)  symxsize(2) forcesize rowgap(1) size(*.50)) xsize(`hsize')
  `scheme' plotregion(margin(zero)) aspect(1) ysize(`vsize') 
title("`plottype'" "`tlab'", size(*0.75)) ;
#delimit cr
}

if "`sroc'" == "both" {
if "`plottype'" != "" {
local plottype "SROC with Prediction & Confidence Contours"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))
(line `yroc' `x', clpat(solid) clc(black))
(line `CBsens' `CBspec', clpat(dash) clc(black) clw(thin))
(line `PBsn' `PBsp', clpat(dot)  clc(black))
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
plotregion(margin(zero)) xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating Point" "`snnote'" "`spnote'"
3 "SROC Curve" "`note'" 4 "`level'% Confidence Contour" 5 "`level'% Prediction Contour") 
pos(5) ring(0) col(1) symxsize(2) forcesize rowgap(1) size(*.50)) xsize(`hsize') 
`scheme' ysize(`vsize') aspect(1) title("`plottype'" "`tlab'", size(*0.75)) ;
#delimit cr
}
if "`sroc'" == "pnoc" {
if "`plottype'" != "" {
local plottype "SROC with Prediction Contour"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))(line `PBsn' `PBsp', clpat(dot)  clc(black)) 
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating Point" "`snnote'" "`spnote'"
3 "`level'% Prediction Contour") pos(5) ring(0) col(1)
 symxsize(2) forcesize rowgap(1) size(*.50))xsize(`hsize') aspect(1) `scheme' 
ysize(`vsize') title("`plottype'" "`tlab'", size(*0.75)) plotregion(margin(zero));
#delimit cr
}
if "`sroc'" == "cnoc" {
if "`plottype'" != "" {
local plottype "SROC with Confidence Contour"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))
(line `CBsens' `CBspec', clpat(dash) clc(black) clw(thin))
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
xsc(range(0 1) rev) ysc(range(0 1))   plotregion(margin(zero))
xla(0(.5)1, nogrid format(%7.1f)) yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating 
Point" "`snnote'" "`spnote'"
3 "`level'% Confidence Contour") 
pos(5) ring(0) col(1)  symxsize(2) forcesize rowgap(1) size(*.50)) xsize(`hsize')
  `scheme' aspect(1) ysize(`vsize') title("`plottype'" "`tlab'", size(*0.75)) ;
#delimit cr
}

if "`sroc'" == "bnoc" {
if "`plottype'" != "" {
local plottype "SROC with Prediction & Confidence Contours"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))
(line `CBsens' `CBspec', clpat(dash) clc(black) clw(thin))
(line `PBsn' `PBsp', clpat(dot)  clc(black))
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 2 "Summary Operating Point" "`snnote'" "`spnote'"
3 "`level'% Confidence Contour" 4 "`level'% Prediction Contour") 
pos(5) ring(0) col(1) symxsize(2) forcesize rowgap(1) size(*.50)) xsize(`hsize') 
`scheme' ysize(`vsize') aspect(1) title("`plottype'" "`tlab'", size(*0.75)) 
plotregion(margin(zero));
#delimit cr
}
if "`sroc'" == "nnoc" {
if "`plottype'" != "" {
local plottype "SROC without Confidence and Prediction Contours"
}
else if "`plottype'" == "" {
local plottype " "
}

#delimit;				
nois twoway (scatter `sens' `spec', sort mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatteri `mtpr' `mtnr', msym(D))
(scatter `sens' `spec', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)),  
xsc(range(0 1) rev) ysc(range(0 1))  xla(0(.5)1, nogrid format(%7.1f)) 
yla(0(.5)1, nogrid angle(horizontal) format(%7.1f)) 
plotregion(margin(zero)) xti(Specificity) 
yti(Sensitivity)  legend(order(1 "Observed Data" 
2 "Summary Operating Point" "`snnote'" "`spnote'") 
pos(5) ring(0) col(1) symxsize(2) forcesize rowgap(1)  size(*.50))
 xsize(`hsize') ysize(`vsize') `scheme' aspect(1) 
title("`plottype'" "`tlab'", size(*0.75)) ;
#delimit cr
}

nois di ""
nois di ""

if "`results'" == "all" {
nois di "SUMMARY DATA AND PERFORMANCE ESTIMATES"
nois di ""
nois di " "
nois di as txt "Number of studies = ", as res `numobs'
nois di " "
nois di as txt "Reference-positive Units ="as result %5.0f `sumtpfn'
nois di " "
nois di as txt "Reference-negative Units ="as result %5.0f `sumtnfp'
nois di " "
nois di as txt "Pretest Prob of Disease ="as result %5.2f $prev
nois di " "
nois di ""
nois di as txt "Deviance = " as res %5.1f `dev'
nois di " "
nois di as txt "AIC = " as result %5.1f `AIC'
nois di " "
nois di as txt "BIC = " as result %5.1f `BIC'
nois di ""
nois di ""
nois di as txt "BICdiff = " as result %5.1f `BICdiff'
nois di " "
nois di " "
nois di as txt "Correlation (Mixed Model)= " as result %5.2f `rho' 
nois di " "
nois di as text "Proportion of heterogeneity likely due to threshold effect =" as res %5.2f (`rho')^2 
nois di ""
nois di ""
nois di as txt "Interstudy variation in Sensitivity: ICC_SEN = "as result %5.2f `ICC2' _c
nois di as txt ", 95% CI = ["as res %5.2f `ICC2lo'                _c
nois di as txt "-"as res %5.2f `ICC2hi' as txt"]"               _n
nois di ""
nois di ""
nois di as txt "Interstudy variation in Sensitivity: MED_SEN = "as result %5.2f `tprmed' _c
nois di as txt ", 95% CI = ["as res %5.2f `tprmedlo'                _c
nois di as txt "-"as res %5.2f `tprmedhi' as txt"]"               _n
nois di " "
nois di as txt "Interstudy variation in Specificity: ICC_SPE = "as result %5.2f `ICC1' _c  
nois di as txt ", 95% CI = ["as res %5.2f `ICC1lo'                _c
nois di as txt "-"as res %5.2f `ICC1hi' as txt"]"               _n
nois di " "
nois di " "
nois di as txt "Interstudy variation in Specificity: MED_SPE = "as result %5.2f `tnrmed' _c  
nois di as txt ", 95% CI = ["as res %5.2f `tnrmedlo'                _c
nois di as txt "-"as res %5.2f `tnrmedhi' as txt"]"               _n
nois di " "
nois di " "
nois di as txt "ROC Area, AUROC = " as res %3.2f `AUC' " [" as res %3.2f `AUClo' " - " as res %3.2f `AUChi' "]" 
nois di ""
nois di ""
nois di as txt "Heterogeneity (Chi-square): LRT_Q = " as result %5.3f `lrtchi' ///
as txt ", df =" as result %3.2f `lrtdf' as txt", LRT_p ="as result %5.3f `lrtpchi'
nois di ""
nois di as txt "Inconsistency (I-square): LRT_I2 = "as res %3.0f `Islrt' _c
nois di as txt ", 95% CI = ["as res %3.0f `Islrtlo'                _c
nois di as txt "-"as res %3.0f `Islrthi' as txt"]"               _n
nois di ""
nois di ""
nois di %-28s "Parameter" %8s "Estimate" %16s "`level'% CI"
nois di ""

nois di as text %-28s "Sensitivity" as res %8.2f `mtpr' as text " " "[" as res %8.2f `mtprlo' as text "," as res %8.2f `mtprhi' as text"]"
nois di ""
nois di as text %-28s "Specificity" as res %8.2f `mtnr' as text " " "[" as res %8.2f `mtnrlo' as text "," as res %8.2f `mtnrhi' as text"]"  
nois di ""
nois di as text %-28s "Positive Likelihood Ratio" as res %8.1f `mlrp' as text " " "[" as res %8.1f `mlrplo' as text "," as res %8.1f `mlrphi' as text"]"
nois di ""
nois di as text %-28s "Negative Likelihood Ratio" as res %8.2f `mlrn' as text " " "[" as res %8.2f `mlrnlo' as text "," as res %8.2f `mlrnhi' as text"]"
nois di ""
nois di as text %-28s "Diagnostic Odds Ratio" as res %8.0f `mdor' as text " " "[" as res %8.0f `mdorlo' as text "," as res %8.0f `mdorhi' as text"]"
nois di ""
nois di ""	  
}
else if "`results'" == "het" {
nois di ""
nois di ""
nois di "HETEROGENEITY STATISTICS"
nois di ""
nois di as txt "Heterogeneity (Chi-square): LRT_Q = " as result %5.3f `lrtchi' ///
as txt ", df =" as result %3.2f `lrtdf' as txt", LRT_p ="as result %5.3f `lrtpchi'
nois di ""
nois di as txt "Inconsistency (I-square): LRT_I2 = "as res %3.0f `Islrt' _c
nois di as txt ", 95% CI = ["as res %3.0f `Islrtlo'                _c
nois di as txt "-"as res %3.0f `Islrthi' as txt"]"               _n
nois di " "
nois di " "
nois di as text "Proportion of heterogeneity likely due to threshold effect =" as res %5.2f (`rho')^2 
nois di ""
nois di ""
nois di as txt "Interstudy variation in Sensitivity: ICC_SEN = "as result %5.2f `ICC2' _c
nois di as txt ", 95% CI = ["as res %5.2f `ICC2lo'                _c
nois di as txt "-"as res %5.2f `ICC2hi' as txt"]"               _n
nois di ""
nois di ""
nois di as txt "Interstudy variation in Sensitivity: MED_SEN = "as result %5.2f `tprmed' _c
nois di as txt ", 95% CI = ["as res %5.2f `tprmedlo'                _c
nois di as txt "-"as res %5.2f `tprmedhi' as txt"]"               _n
nois di " "
nois di as txt "Interstudy variation in Specificity: ICC_SPE = "as result %5.2f `ICC1' _c  
nois di as txt ", 95% CI = ["as res %5.2f `ICC1lo'                _c
nois di as txt "-"as res %5.2f `ICC1hi' as txt"]"               _n
nois di " "
nois di " "
nois di as txt "Interstudy variation in Specificity: MED_SPE = "as result %5.2f `tnrmed' _c  
nois di as txt ", 95% CI = ["as res %5.2f `tnrmedlo'                _c
nois di as txt "-"as res %5.2f `tnrmedhi' as txt"]"               _n
nois di " "
nois di " "
}
else if "`results'" == "sum" {
nois di ""
nois di "SUMMARY PERFORMANCE ESTIMATES"
nois di ""
nois di ""
nois di %-28s "Parameter" %8s "Estimate" %16s "`level'% CI"
nois di ""
nois di as text %-28s "Sensitivity" as res %8.2f `mtpr' as text " " "[" as res %8.2f `mtprlo' as text "," as res %8.2f `mtprhi' as text"]"
nois di ""
nois di as text %-28s "Specificity" as res %8.2f `mtnr' as text " " "[" as res %8.2f `mtnrlo' as text "," as res %8.2f `mtnrhi' as text"]"  
nois di ""
nois di as text %-28s "Positive Likelihood Ratio" as res %8.1f `mlrp' as text " " "[" as res %8.1f `mlrplo' as text "," as res %8.1f `mlrphi' as text"]"
nois di ""
nois di as text %-28s "Negative Likelihood Ratio" as res %8.2f `mlrn' as text " " "[" as res %8.2f `mlrnlo' as text "," as res %8.2f `mlrnhi' as text"]"
nois di ""
nois di as text %-28s "Diagnostic Odds Ratio" as res %8.0f `mdor' as text " " "[" as res %8.0f `mdorlo' as text "," as res %8.0f `mdorhi' as text"]"
nois di ""
nois di ""	  
}
else if "`results'" == "fit" {
nois di ""
nois di "FIT STATISTICS"
nois di ""
nois di ""
nois di as txt "Deviance = " as res %5.1f `dev'
nois di " "
nois di as txt "AIC = "as result %5.1f `AIC'
nois di " "
nois di as txt "BIC = "as result %5.1f `BIC'
nois di ""
nois di as txt "BICdiff = " as result %5.1f `BICdiff'
nois di ""
nois di ""

}
}
}
end


program xtbbrre, rclass sortpreserve byable(recall)
version 10
syntax varlist(min=4 max=4 numeric) [if] [in], [ NIP(integer 7) INDex(string) LEVEL(integer 95) *] 

qui {
preserve
marksample touse, novarlist
keep if `touse'
}
tokenize `varlist'
local tp `1'
local fp `2'
local fn `3'
local tn `4'
datasig
global chksig= r(datasignature)

/* MIXED EFFECTS ESTIMATION */

qui {
local alph = (100-`level')/200
gen study = _n
gen ttruth1 = `tn'                   
gen ttruth2 = `tp'                    
gen num1 = `tn'+`fp'                      
gen num2 = `tp'+`fn'                      
reshape long num ttruth, i(study) j(dtruth) string
tabulate dtruth, generate(disgrp)
}
count 
local nnobs = r(N)
if `nnobs' <= `nip' {
xtmelogit (ttruth disgrp1 disgrp2, noc)(study: disgrp1 disgrp2, noc cov(unstr)), ///
bin(num) laplace var nofet noret nohead refineopts(iterate(4))
}
else if `nnobs' > `nip' {
xtmelogit (ttruth disgrp1 disgrp2, noc)(study: disgrp1 disgrp2, noc cov(unstr)), ///
bin(num) intp(`nip') var nofet noret nohead refineopts(iterate(4))
}
qui {
 nois di " "
 nois di " " 
estimates store modr 
local ll = e(ll)
local k = e(k)
local NOBS = e(N)
global dev = -2 * `ll'
global AIC =  -2 * `ll' + 2*`k' 
global BIC= -2 * `ll' + `k' * log(`NOBS')
global BICdiff = (-2*(e(ll_c)- e(ll))+ (e(k_f)- e(k))*log(e(N)))

estimates save xtmodel, replace
mat V = e(V)
mat b = e(b)
return matrix matV = V, copy
return matrix matb = b, copy

global covsnsp = V[1,2]
global mcovar = tanh(_b[atr1_1_1_2:_cons]) * _b[lns1_1_1:_cons] * _b[lns1_1_2:_cons] 
nlcom (spbeta: _b[disgrp1])(snbeta: _b[disgrp2])/*
*/(mrho: _b[atr1_1_1_2:_cons])/*
*/(mreffs1: _b[lns1_1_1:_cons])(mreffs2: _b[lns1_1_2:_cons])/*
*/(ICC1: exp(_b[lns1_1_1:_cons])^2/(exp(_b[lns1_1_1:_cons])^2 + (_pi^2/3))) /*
*/(ICC2: exp(_b[lns1_1_2:_cons])^2/(exp(_b[lns1_1_2:_cons])^2 + (_pi^2/3))) /*
*/(msens: _b[disgrp2])(mspec: _b[disgrp1])(mldor: _b[disgrp2]+_b[disgrp1]) /*
*/(mdor: _b[disgrp2]+_b[disgrp1]) /*
*/(mlrp: log(invlogit(_b[disgrp2])/(1-invlogit(_b[disgrp1]))))/* 
*/(mlrn: log((1-invlogit(_b[disgrp2]))/invlogit(_b[disgrp1]))), post
global mrho = tanh(_b[mrho])
global mrholo = tanh(_b[mrho] - invnorm(1-`alph')*_se[mrho])
global mrhohi = tanh(_b[mrho] + invnorm(1-`alph')*_se[mrho])
global mreffs1 = exp(_b[mreffs1])^2
global mreffs1se = exp(_se[mreffs1])^2
global mreffs1lo = exp(_b[mreffs1] - invnorm(1-`alph') * _se[mreffs1])^2
global mreffs1hi = exp(_b[mreffs1] + invnorm(1-`alph') * _se[mreffs1])^2
global mreffs2 = exp(_b[mreffs2])^2
global mreffs2se = exp(_se[mreffs2])^2
global mreffs2lo = exp(_b[mreffs2] - invnorm(1-`alph') * _se[mreffs2])^2
global mreffs2hi = exp(_b[mreffs2] + invnorm(1-`alph') * _se[mreffs2])^2
global ICC1 = _b[ICC1]
global ICC1se = _se[ICC1]
global ICC1lo = max(0, _b[ICC1]-invnorm(1-`alph') * _se[ICC1])
global ICC1hi = _b[ICC1]+invnorm(1-`alph') * _se[ICC1]
global ICC2 = _b[ICC2]
global ICC2se = _se[ICC2]
global ICC2lo = max(0, _b[ICC2]-invnorm(1-`alph') * _se[ICC2])
global ICC2hi = _b[ICC2]+invnorm(1-`alph') * _se[ICC2]
global tprmed = invlogit(sqrt(2*$mreffs2)*invnormal(0.75))
global tprmedlo = invlogit(sqrt(2*$mreffs2lo)*invnormal(0.75))
global tprmedhi = invlogit(sqrt(2*$mreffs2hi)*invnormal(0.75))
global tnrmed = invlogit(sqrt(2*$mreffs1)*invnormal(0.75))
global tnrmedlo = invlogit(sqrt(2*$mreffs1lo)*invnormal(0.75))
global tnrmedhi = invlogit(sqrt(2*$mreffs1hi)*invnormal(0.75))

global mtpr = invlogit(_b[msens])
global mtprlo = invlogit(_b[msens] - invnorm(1-`alph')*_se[msens]) 
global mtprhi = invlogit(_b[msens] + invnorm(1-`alph')*_se[msens])
global mtprse = ($mtprhi-$mtpr)/invnorm(1-`alph')
global mtnr = invlogit(_b[mspec])
global mtnrlo = invlogit(_b[mspec] - invnorm(1-`alph')*_se[mspec])
global mtnrhi = invlogit(_b[mspec] + invnorm(1-`alph')*_se[mspec])
global mtnrse = ($mtnrhi-$mtnr)/invnorm(1-`alph')
global mldor = _b[mldor]
global mldorlo = _b[mldor] - invnorm(1-`alph')*_se[mldor]
global mldorhi = _b[mldor] + invnorm(1-`alph')*_se[mldor]
global mldorse = ($mldorhi-$mldor)/invnorm(1-`alph')
global mdor = exp(_b[mdor])
global mdorlo = exp(_b[mdor] - invnorm(1-`alph')*_se[mdor])
global mdorhi = exp(_b[mdor] + invnorm(1-`alph')*_se[mdor])
global mdorse = ($mdorhi-$mdor)/invnorm(1-`alph')
global mlrp = exp(_b[mlrp])
global mlrplo = exp(_b[mlrp] - invnorm(1-`alph')*_se[mlrp])
global mlrphi = exp(_b[mlrp] + invnorm(1-`alph')*_se[mlrp])
global mlrpse = ($mlrphi-$mlrp)/invnorm(1-`alph')
global mlrn = exp(_b[mlrn])
global mlrnlo = exp(_b[mlrn] - invnorm(1-`alph')*_se[mlrn])
global mlrnhi = exp(_b[mlrn] + invnorm(1-`alph')*_se[mlrn])
global mlrnse = ($mlrnhi-$mlrn)/invnorm(1-`alph')
global sp = _b[spbeta]
global spse = _se[spbeta]
global splo = _b[snbeta] - invnorm(1-$alph)*_se[spbeta]
global sphi = _b[snbeta] + invnorm(1-$alph)*_se[spbeta]
global sn = _b[snbeta]
global snse = _se[snbeta]
global snlo = _b[snbeta] - invnorm(1-$alph) * _se[snbeta]
global snhi = _b[snbeta] + invnorm(1-$alph) * _se[snbeta]

/* FIXED EFFECTS ESTIMATION */

xtmelogit (ttruth disgrp1 disgrp2, noc)(study: ), bin(num) 
estimates store modf
nlcom (fsens: _b[disgrp2])/*
*/(fspec: _b[disgrp1])/*
*/(fldor: (_b[disgrp2]+_b[disgrp1])) /*
*/(fdor: _b[disgrp2]+_b[disgrp1]) /*
*/(flrp: log(invlogit(_b[disgrp2])/(1-invlogit(_b[disgrp1]))))/* 
*/(flrn: log((1-invlogit(_b[disgrp2]))/invlogit(_b[disgrp1]))), post

global fsens = invlogit(_b[fsens])
global fspec =  invlogit(_b[fspec])
global fldor = _b[fldor]
global fdor = exp(_b[fdor])
global flrp = exp(_b[flrp])
global flrn = exp(_b[flrn])

/*LRT STATISTICS AND HETEROGENEITY*/

tempname lrtchi lrtpchi lrtdf
lrtest modr modf, stats force
scalar `lrtchi' = r(chi2)
scalar `lrtpchi'= 0.5 * r(p)
scalar `lrtdf' = r(df)
global lrtchi = r(chi2)
global lrtpchi= 0.5 * r(p)
global lrtdf = r(df)
homogeni `lrtchi' `lrtdf'
global Islrt = r(Isq)
global Islrtlo = r(Isqlo)
global Islrthi = r(Isqhi)



}


end




program define quadas, sortpreserve
version 9
syntax varlist(min=2) [if] [in] [, LABvar(string) qtable qgraph *] 
qui {
preserve
marksample touse, novarlist
keep if `touse'
}

tokenize `varlist'
qui{
tempfile qualires
tempname qualifile
postfile `qualifile' str40 Criterion Yes No Yes_percent No_percent using qualires, replace
foreach var in `varlist' {
count 
local totalvar = r(N)
count if `var' == 1
local yesvar = r(N)
count if `var' == 0
local novar = r(N)
local yes_cent = (`yesvar'/`totalvar') * 100
local no_cent = (`novar'/`totalvar') * 100

if "`labvar'" != "" {
local critvar : variable label `var'
post `qualifile' ("`critvar'") (`yesvar') (`novar') (`yes_cent') (`no_cent')
}
else { 
post `qualifile' ("`var'") (`yesvar') (`novar') (`yes_cent') (`no_cent')
}
} 
postclose `qualifile'
postutil clear
use qualires, clear
summarize Yes
}
local N = r(N)
if "`qtable'"=="qtable" {
di as text "{title: METHODOLOGICAL QUALITY ASSESSMENT}"
di " "
di as text"{hline 83}"
di as text _col(2) "Criterion" _col(44)  "{c |}"  _col(48) "Yes" _col(54) "Yes(%)" _col(64) "No" _col(72) "No(%)"
di as text"{hline 43}{c +}{hline 39}"
local i = 1
while `i' <= `N' {            
local a1 = Criterion in `i' 
local b1 = Yes in `i'
local c1 = Yes_percent  in `i'
local d1 = No  in `i'
local e1 = No_percent  in `i'
di as text _col(2)  "`a1'" _col(44) in gr "{c |}" as result _col(45) %6.0f `b1' _col(50) %6.0f `c1' _col(60) %6.0f `d1' _col(68) %6.0f `e1'
local i=`i'+1
}
di as text"{hline 43}{c BT}{hline 39}"
}
if "`qgraph'"=="qgraph" {
#delimit;
graph hbar (asis) Yes No, over(Criterion, sort(Total) descending) 
nolab  bar (1, fcolor(gs0)) bar(2, fcolor(gs16)) aspect(1.5) legend(rows(1) position(6))
stack percent lintensity(*.50) xsize(`hsize') ysize(`vsize');
#delimit cr 
}
end



program define midachi
version 9

syntax varlist(num min=2 max=2)[if][in][,`options' *] 
marksample touse
tokenize `varlist'
local chivar1 `1'
local chivar2 `2'

qui {
local yvar : variable label `chivar1'
tempvar ry rx Hi Fi Gi Si CHIi Li pid
gen `pid'=_n
 * Gi
 egen `ry' = rank(`chivar1'), field
 gsort -`ry'
 gen `Gi' = (_N - `ry') / (_N - 1)
 * Fi
 egen `rx' = rank(`chivar2'), field
 gsort -`rx'
 gen `Fi' = (_N - `rx') / (_N - 1)
 * Hi
 sort `ry'
  by `ry': replace `ry' = _N 
 sort `chivar1'
 tempname xi
 gen `Hi' = 0
 local r1 = 1
 local N = _N 
 forvalues i = 1 / `N' { 
  if `chivar1'[`i'] == `chivar1'[`i'-1] {
 local r1 = `r1' + 1
 }
    else {
 local r1 = 1 
}
    local k = min(`N', `i' + `ry'[`i'] - `r1')
    scalar `xi' = `chivar2'[`i']
    count if `chivar2' <= `xi' & _n != `i' in 1/`k'
    replace `Hi' = r(N) in `i'       
 }
 replace `Hi' = `Hi' / (_N - 1)
 * Si, CHIi, Li
  gen `Si'   = sign((`Fi' - .5)*(`Gi' - .5))
 gen `CHIi' = (`Hi' - `Fi'*`Gi') / (`Fi'*(1 - `Fi')*`Gi'*(1 - `Gi'))^.5
 gen `Li'   = 4 * `Si' * max((`Fi' - .5)^2, (`Gi' - .5)^2)  
 label var `CHIi' "CHI"
 label var `Li' "LAMBDA"
 
    
 spearman `chivar1' `chivar2'
 local r = r(rho)
 local note: di "rho = " %3.2f `r' "

*Scatterplot 
#delimit;
twoway (scatter `chivar1' `chivar2', mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(lfit `chivar1' `chivar2')(scatter `chivar1' `chivar2', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)) , 
name(splot, replace) title(ScatterPlot) plotregion(margin(zero)) 
ylab( , angle(360)) legend(off) ytitle("`yvar'") nodraw `options';
#delimit cr 

* cp lines
 
 local cp = 1.78 
 local cphi = `cp' / sqrt(_N)
 local cplo= -`cp' / sqrt(_N)

*chi-plot

#delimit;
twoway (scatter `CHIi' `Li', mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(S))
(scatter `CHIi' `Li', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black)) , 
yline(`cplo' `cphi', lpat(solid) lwidth(vvthin)) legend(off)
yline(0, lpat(dash) lwidth(vvthin)) xline(0, lpat(dash) lwidth(vvthin)) 
xla(-1(0.5)1) yla(-1(.5)1, angle(360)) title(Chi-Plot) plotregion(margin(zero)) 
nodraw name(cplot, replace) `options';
#delimit cr
nois graph combine splot cplot, xsize(`hsize') ysize(`vsize')       
}

end




program bivreg, rclass sortpreserve byable(recall)
version 9
syntax varlist(min=4 max=4) [if] [in], COVars(varlist)  [ LEVEL(integer 95) *] 

qui {
preserve
marksample touse, novarlist
keep if `touse'
}
tokenize `varlist'
local tp `1'
local fp `2'
local fn `3'
local tn `4'

if "`covars'" =="" {
di as error " covariate varlist required" 
exit 198
}		


/* MIXED EFFECTS ESTIMATION */

qui {
datasig
global chksig2= r(datasignature)

local alph = (100-`level')/200

gen ctruth1 = `tn'                  
gen ctruth2 = `tp'                   
gen cnum1 = `tn'+`fp'                   
gen cnum2 = `tp'+`fn'                      
gen cstudy = _n
reshape long cnum ctruth, i(cstudy) j(cdtruth) string
tabulate cdtruth, generate(cdisgrp)

tempname covfile
tempfile covresults
tempname covfile
tempfile covresults
postfile `covfile' str30 Parameter str5 category str40 Para1 str40 Para2 nstudies cTPR cTPRse cTPRlo cTPRhi z1 p1 cTNR cTNRse cTNRlo cTNRhi /*
*/ z2 p2 LRTChi2 Pvalue I2 I2lo I2hi using covresults, replace
xtmelogit (ctruth cdisgrp1 cdisgrp2, noc)(cstudy: cdisgrp1 cdisgrp2, noc cov(unstr)), /// 
bin(cnum) laplace nolr nofet noret nohead refineopts(iterate(4))
estimates store mod0
nlcom (cspec: invlogit(_b[cdisgrp1]))(csens: invlogit(_b[cdisgrp2])), post
local cspec= _b[cspec]
local csens=_b[csens]

foreach var in `covars' {
local varlab "`var'"
su `var', meanonly
local varmean= r(mean)
local varmax= r(max)
local varmin= r(min) 
replace `var'= `var'-`varmean' if `varmin'!=0 & `varmax'!=1

forvalues i=1/2 {
g `var'_`i' = cdisgrp`i'*`var'
   }
nois di " "
nois di " "
nois di in gr "Estimating Covariate Effect Of: " in white " `varlab'"
nois di " "

if `varmin'==0 & `varmax'==1 {
count if `var' ==0
local num0 = abs(0.5*r(N))
count if `var' ==1
local num1 = abs(0.5*r(N))
xtmelogit (ctruth cdisgrp1 cdisgrp2 `var'_1 `var'_2, noc)(cstudy: cdisgrp1 cdisgrp2, noc cov(unstr)), /// 
bin(cnum) laplace nolr nofet noret nohead refineopts(iterate(4))
 
estimates store mod`var'
nlcom (cVAR21: invlogit(_b[cdisgrp1] + _b[`var'_1])) /*
*/(cVAR20: invlogit(_b[cdisgrp1])) /*
*/(cVAR11: invlogit(_b[cdisgrp2] + _b[`var'_2])) /*
*/(cVAR10: invlogit(_b[cdisgrp2])) /*
*/(zVAR21: _b[cdisgrp1] + _b[`var'_1]) /*
*/(zVAR20: _b[cdisgrp1]) /*
*/(zVAR11: _b[cdisgrp2] + _b[`var'_2]) /*
*/(zVAR10: _b[cdisgrp2]), post

local cVAR20= _b[cVAR20]
local cVAR20se=_se[cVAR20]
local cVAR20lo=`cVAR20'-invnorm(1-$alph) * `cVAR20se'
local cVAR20hi=min(1.00, `cVAR20' + invnorm(1-$alph) * `cVAR20se')

local zVAR20= _b[zVAR20]
local zVAR20se=_se[zVAR20]

local cVAR21= _b[cVAR21]
local cVAR21se=_se[cVAR21]
local cVAR21lo=`cVAR21'-invnorm(1-$alph) * `cVAR21se'
local cVAR21hi= min(1, `cVAR21' + invnorm(1-$alph) * `cVAR21se')

local zVAR21= _b[zVAR21]
local zVAR21se=_se[zVAR21]

local cVAR10= _b[cVAR10]
local cVAR10se=_se[cVAR10]
local cVAR10lo=`cVAR10'- invnorm(1-$alph) * `cVAR10se'
local cVAR10hi= min(1, `cVAR10' + invnorm(1-$alph) * `cVAR10se')

local zVAR10= _b[zVAR10]
local zVAR10se=_se[zVAR10]

local cVAR11= _b[cVAR11]
local cVAR11se=_se[cVAR11]
local cVAR11lo=`cVAR11'- invnorm(1-$alph) * `cVAR11se'
local cVAR11hi=min(1, `cVAR11' + invnorm(1-$alph) * `cVAR11se')

local zVAR11= _b[zVAR11]
local zVAR11se=_se[zVAR11]
local z_cVAR11=`zVAR11'-`zVAR10'/(sqrt((`zVAR11se'*`zVAR11se')+ (`zVAR10se'*`zVAR10se')))
if `z_cVAR11' <=0{
local p_cVAR11=2*normal(`z_cVAR11')
}
else {
local p_cVAR11=2*(1-normal(`z_cVAR11'))
}

local z_cVAR21=`zVAR21'-`zVAR20'/(sqrt((`zVAR21se'*`zVAR21se')+ (`zVAR20se'*`zVAR20se')))
if `z_cVAR21' <=0{
local p_cVAR21=2*normal(`z_cVAR21')
}
else {
local p_cVAR21=2*(1-normal(`z_cVAR21'))
}


local z_cVAR10 =.
local z_cVAR20 =.
local p_cVAR10 =.
local p_cVAR20 =.
local present1 "Yes"
local present0 "No"
qui lrtest mod0 mod`var', stats force
local LRTchi = r(chi2)
local LRTpchi = r(p)
local LRTdf = r(df)
homogeni `LRTchi' `LRTdf'
scalar I2 = r(Isq)
scalar I2lo = r(Isqlo)
scalar I2hi = r(Isqhi)
scalar I22 = .
scalar I22lo = .
scalar I22hi = .

if `p_cVAR11' > 0.05 {
  local para1 "`var'"  
  }
  else if `p_cVAR11' <0.05 & `p_cVAR11' >=0.01{
     local para1 "*`var'"  
  }
  else if `p_cVAR11' <0.01& `p_cVAR11' >=0.001 {
     local para1 "**`var'"  
  } 
  else if `p_cVAR11' <0.001 {
     local para1 "***`var'" 
  } 

if `p_cVAR21' > 0.05 {
  local para2 "`var'"  
  }
  else if `p_cVAR21' <0.05 & `p_cVAR21' >=0.01{
     local para2 "*`var'"  
  }
  else if `p_cVAR21' <0.01 & `p_cVAR21' >=0.001 {
     local para2 "**`var'"  
  } 
  else if `p_cVAR21' <0.001 {
     local para2 "***`var'" 
  } 

nois post `covfile' ("`var'") ("`present1'") ("`para1'") ("`para2'") (`num1') (`cVAR11') (`cVAR11se') (`cVAR11lo') (`cVAR11hi') (`z_cVAR11') (`p_cVAR11') (`cVAR21') (`cVAR21se') (`cVAR21lo') (`cVAR21hi') (`z_cVAR21') (`p_cVAR21') (`LRTchi' ) (`LRTpchi') (I2) (I2lo) (I2hi)

nois post `covfile' ("") ("`present0'") ("") ("") (`num0') (`cVAR10') (`cVAR10se') (`cVAR10lo') (`cVAR10hi') (`z_cVAR10') (`p_cVAR10') (`cVAR20') (`cVAR20se') (`cVAR20lo') (`cVAR20hi') (`z_cVAR20') (`p_cVAR20') (`LRTchi' ) (`LRTpchi') (I22) (I22lo) (I22hi)

}
else if `varmin'!=0 & `varmax'!=1 {
count 
local num = abs(0.5*r(N))
xtmelogit (ctruth cdisgrp1 cdisgrp2 `var'_1 `var'_2, noc)(cstudy: cdisgrp1 cdisgrp2, noc cov(unstr)), ///
bin(cnum) laplace nolr nofet noret nohead refineopts(iterate(4))
 
estimates store mod`var'
nlcom (csens: _b[cdisgrp2] + _b[`var'_2]) /*
*/(csens0: _b[cdisgrp2]) /*
*/(cspec: _b[cdisgrp1] + _b[`var'_1]) /*
*/(cspec0: _b[cdisgrp1]), post

local cvar2= invlogit(_b[cspec])
local cvar2se=_se[cspec]
local cvar2lo=invlogit(_b[cspec]-invnorm(1-$alph) * _se[cspec])
local cvar2hi=min(1, invlogit(_b[cspec] + invnorm(1-$alph) * _se[cspec]))
local cvar1= invlogit(_b[csens])
local cvar1se=_se[csens]
local cvar1lo=invlogit(_b[csens]- invnorm(1-$alph) * _se[csens])
local cvar1hi= min(1, invlogit(_b[csens] + invnorm(1-$alph) * _se[csens]))
local z_cov2=(_b[cspec]-_b[cspec0])/sqrt((_se[cspec]^2) + (_se[cspec0]^2))
if `z_cov2' <=0{
local p_cov2=2*normal(`z_cov2')
}
else {
local p_cov2=2*(1-normal(`z_cov2'))
}
local z_cov1=(_b[csens]-_b[csens0])/sqrt((_se[csens]^2) + (_se[csens0]^2))
if `z_cov1' <=0{
local p_cov1=2*normal(`z_cov1')
}
else {
local p_cov1=2*(1-normal(`z_cov1'))
}

if `p_cov1' > 0.05 {
  local para1 "`var'"  
  }
  else if `p_cov1' <0.05 & `p_cov1' >=0.01{
     local para1 "*`var'"  
  }
  else if `p_cov1' <0.01& `p_cov1' >=0.001 {
     local para1 "**`var'"  
  } 
  else if `p_cov1' <0.001 {
     local para1 "***`var'" 
  } 

if `p_cov2' > 0.05 {
  local para2 "`var'"  
  }
  else if `p_cov2' <0.05 & `p_cov2' >=0.01{
     local para2 "*`var'"  
  }
  else if `p_cov2' <0.01 & `p_cov2' >=0.001 {
     local para2 "**`var'"  
  } 
  else if `p_cov2' <0.001 {
     local para2 "***`var'" 
  } 


qui lrtest mod0 mod`var', stats force
local LRTchi = r(chi2)
local LRTpchi = r(p)
local LRTdf = r(df)
homogeni `LRTchi' `LRTdf'
scalar I2 = r(Isq)
scalar I2lo = r(Isqlo)
scalar I2hi = r(Isqhi)
nois post `covfile' ("`var'") ("") ("`para1'") ("`para2'") (`num') (`cvar1') (`cvar1se') (`cvar1lo') (`cvar1hi') (`z_cov1') (`p_cov1') ///
 (`cvar2') (`cvar2se') (`cvar2lo') (`cvar2hi') (`z_cov2') (`p_cov2') (`LRTchi') (`LRTpchi') ///
 (I2) (I2lo) (I2hi)

}
} 
nois postclose `covfile'
postutil clear
use covresults, clear

format cTPR cTPRlo cTPRhi cTNR cTNRlo cTNRhi z1 z2 p1 p2 LRTChi2 Pvalue %-7.2f
format I2 I2lo I2hi %-7.0f
format Parameter category %-30s
foreach var of varlist cTPR cTNR {
	tostring `var'lo `var' `var'hi, gen(`var'lo1 `var'1 `var'hi1) format(%7.2f) force
	replace `var'lo1=" " + "[" + `var'lo1 +" - "
	replace `var'hi1= `var'hi1+ "]"
	gen str21 `var'_ci=`var'1+`var'lo1+`var'hi1 
	format `var'_ci %-40s force
}

replace LRTChi2 if category == "No" =.
replace Pvalue if category == "No" =.


rename cTPR_ci Sensitivity
rename cTNR_ci Specificity
nois di ""
nois di ""

local ctitle1 "Sensitivity"
local ctitle2 "Specificity"
nois di as text "`ctitle1' and `ctitle2'""
nois di ""
nois list Parameter category nstudies Sensitivity p1 Specificity p2, separator(0) abbreviate(20) absolute noob 
nois di ""
nois di ""
nois di "Joint Model"
nois di ""

nois list Parameter category LRTChi2 Pvalue I2 I2lo I2hi, separator(0) abbreviate(20) absolute noob 
tempname obs1 obs2
gen `obs1' = _n 
gen `obs2' = _n 

local max=_N
egen studyname1 = concat(Para1 category), p(" ")
format studyname1  %-40s
label value `obs1' obs1
forval i = 1/`max' {
local value = `"`value' `i'"'
label define obs1 `i' "`=studyname1[`i']'", modify
}
set graphics off
local xlab "xlab(minmax, format(%5.2f))"
twoway (rcap cTPRlo cTPRhi `obs1', ylabel(`"`value'"', valuelabel ///
 angle(360)) hor s(i) blpattern(solid) blwidth(thin) blcolor(black) `xlab') ///
(scatter `obs1' cTPR), legend(off) ytitle("") xlabel(, angle(360)) ///
xline(`csens', lstyle(foreground)) xtitle("Sensitivity(95% CI)", angle(vertical)) /// 
note("*p<0.05, **p<0.01, ***p<0.001") ysc(rev) nodraw saving(univ1,replace)


egen studyname2 = concat(Para2 category), p(" ") 
format studyname2  %-40s
label value `obs2' obs2
forval i = 1/`max'{
local value = `"`value' `i'"'
label define obs2 `i' "`=studyname2[`i']'", modify
} 	

twoway (rcap cTNRlo cTNRhi `obs2', ylabel(`"`value'"', valuelabel ///
angle(360)) hor s(i) blpattern(solid) blwidth(thin) blcolor(black) `xlab') ///
(scatter `obs2' cTNR), legend(off) ytitle("") xlabel(, angle(360)) xline(`cspec', lstyle(foreground)) ///
xtitle("Specificity(95% CI)", angle(vertical)) ///
note("*p<0.05, **p<0.01, ***p<0.001") ysc(rev) nodraw saving(univ2,replace)
set graphics on
graph combine univ1.gph univ2.gph, ysize(7) row(1) ycommon ///
subtitle(Univariable Meta-regression & Subgroup Analyses, size(*.75))
}

end



program xtmodchk, rclass sortpreserve byable(recall)
version 10
syntax varlist(min=4 max=4 numeric) [if] [in], [ NIP(integer 7) plot(string) LEVEL(integer 95) *] 

qui {
preserve
marksample touse, novarlist
keep if `touse'
}
tokenize `varlist'
local tp `1'
local fp `2'
local fn `3'
local tn `4'
datasig
global chksig= r(datasignature)

/* MIXED EFFECTS ESTIMATION */

qui {
local alph = (100-`level')/200
gen study = _n
gen ttruth1 = `tn'                   
gen ttruth2 = `tp'                    
gen num1 = `tn'+`fp'                      
gen num2 = `tp'+`fn'                      
reshape long num ttruth, i(study) j(dtruth) string
tabulate dtruth, generate(disgrp)
}
count 
local nnobs = r(N)
if `nnobs' <= `nip' {
xtmelogit (ttruth disgrp1 disgrp2, noc)(study: disgrp1 disgrp2, noc cov(unstr)), ///
bin(num) laplace var nofet noret nohead refineopts(iterate(4))
}
else if `nnobs' > `nip' {
xtmelogit (ttruth disgrp1 disgrp2, noc)(study: disgrp1 disgrp2, noc cov(unstr)), ///
bin(num) intp(`nip') var nofet noret nohead refineopts(iterate(4))
}
estimates store modchk
qui {
 nois di " "
 nois di " " 

if "`plot'"=="inf" {
predict redisgrp*, reffects
predict sedisgrp*, reses
predict g*, scores
tempname H
matrix `H' = e(V)
local k = colsof(`H')
local N = _N
tempname scorei ci
qui gen cooksd = .
 local i = 1
 while `i'<=`N'{
 mkmat g1-g`k' if _n==`i', matrix(`scorei')
 matrix `ci' = 2*`scorei'*`H'*`scorei''
 qui replace cooksd= `ci'[1,1] in `i'
 local i = `i' + 1
  }
format cooksd %5.2f
count if cooksd !=. 
local xmax=r(N)
local n = 4*e(k)/r(N)

tw (spike cooksd study)(scatter cooksd study if cooksd !=. & cooksd > `n', ///
mlw(medthin) mfc(yellow) mlc(black) msize(*1.5) ms(O)) ///
(scatter cooksd study if cooksd !=. & cooksd > `n', ///
ms(i) mlabp(0) mlabel(study) mlabs(*.5) mlabc(black)) , ///
legend(off) yline(`n', lpat(dash) lw(thin)) ylab(, angle(hor) nogrid) xlab(, nogrid) ///
name(cooksd, replace) ytitle(Cook's Distance) title("(c) Influence Analysis")
}

else if "`plot'"=="bvn" {
predict redisgrp*, reffects
predict sedisgrp*, reses
mkmat redisgrp*, matrix(xvar) 
matrix accum cov = redisgrp*, noc dev 
matrix cov = cov/(r(N)-1) 
matrix mahascorex= (xvar) * (inv(cov)) * (xvar') 
matrix mahascore= (vecdiag(mahascorex))' 
svmat mahascore, names(mahascore)
version 10: pchi mahascore1, df(2) name(bivar, replace) ///
ylab(, angle(hor)) title("(b) Bivariate Normality") ///
xtitle(Chi-squared Quantile) nodraw ytitle(Mahalanobis D-squared)
version 10: pchi mahascore1, df(2) name(bivar, replace) ///
ylab(, angle(hor)) title("(b) Bivariate Normality") ///
xtitle(Chi-squared Quantile) ytitle(Mahalanobis D-squared)
}
else if "`plot'"=="gof" {
predict dresid, d
pnorm dresid, name(pdresid, replace) title("(a) Goodness-Of-Fit") ///
xtitle(Normal Quantile) ylab(, angle(hor) format(%7.2f)) ytitle(Deviance Residual)
}
 else if "`plot'"=="out" {

gen stdres1=(1-disgrp1)* redisgrp1/ sqrt(exp(2 * [lns1_1_1]_b[_cons]) - sedisgrp1^2) 
gen stdres2=disgrp2* redisgrp2/ sqrt(exp(2 * [lns1_1_2]_b[_cons]) - sedisgrp2^2)
tw (scatter stdres2 stdres1, mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O)) ///
(scatter stdres2 stdres1 if (stdres2 <-2 | stdres2>2)|(stdres1 <-2 | stdres1>2), mlw(medthin) mlc(black) mfc(yellow) msize(*1.5) ms(O)) ///
(scatter stdres2 stdres1, ms(i) mlabp(0) mlabel(study) mlabs(*.5) mlabc(black)), ylab(-3(1)3, angle(hor) format(%7.1f) nogrid) ///
xlab(-3(1)3, format(%7.1f) nogrid) xline(-2 0 2, lw(thin) lpat(dash)) yline(-2 0 2, lpat(dash) lw(thin) ) legend(off) ///
name(outlier, replace) ytitle("Standardized Residual(Diseased)") xtitle("Standardized Residual(Healthy)") ///
title("(d) Outlier Detection")
}

else if "`plot'"=="all" {
predict redisgrp*, reffects
predict sedisgrp*, reses
predict dresid, d
predict g*, scores
tempname H
matrix `H' = e(V)
local k = colsof(`H')
local N = _N
tempname scorei ci
qui gen cooksd = .
 local i = 1
 while `i'<=`N'{
 mkmat g1-g`k' if _n==`i', matrix(`scorei')
 matrix `ci' = 2*`scorei'*`H'*`scorei''
 qui replace cooksd= `ci'[1,1] in `i'
 local i = `i' + 1
  }
format cooksd %5.2f
count if cooksd !=. 
local xmax=r(N)
local n = 4*e(k)/r(N)
set graphics off
tw (spike cooksd study)(scatter cooksd study if cooksd !=. & cooksd > `n', ///
mlw(medthin) mfc(yellow) mlc(black) msize(*1.5) ms(O)) ///
(scatter cooksd study if cooksd !=. & cooksd > `n', ///
ms(i) mlabp(0) mlabel(study) mlabs(*.5) mlabc(black)) , ///
legend(off) yline(`n', lpat(dash) lw(thin)) ylab(, angle(hor) nogrid) xlab(, nogrid) ///
name(cooksd, replace) ytitle(Cook's Distance) title("(c) Influence Analysis")

mkmat redisgrp*, matrix(xvar) 
matrix accum cov = redisgrp*, noc dev 
matrix cov = cov/(r(N)-1) 
matrix mahascorex= (xvar) * (inv(cov)) * (xvar') 
matrix mahascore= (vecdiag(mahascorex))' 
svmat mahascore, names(mahascore)
version 10: pchi mahascore1, df(2) name(bivar, replace) ///
ylab(, angle(hor)) title("(b) Bivariate Normality") ///
xtitle(Chi-squared Quantile) nodraw ytitle(Mahalanobis D-squared)
version 10: pchi mahascore1, df(2) name(bivar, replace) ///
ylab(, angle(hor)) title("(b) Bivariate Normality") ///
xtitle(Chi-squared Quantile) ytitle(Mahalanobis D-squared)


pnorm dresid, name(pdresid, replace) title("(a) Goodness-Of-Fit") ///
xtitle(Normal Quantile) ylab(, angle(hor) format(%7.2f)) ytitle(Deviance Residual)

gen stdres1=(1-disgrp1)* redisgrp1/ sqrt(exp(2 * [lns1_1_1]_b[_cons]) - sedisgrp1^2) 
gen stdres2=disgrp2* redisgrp2/ sqrt(exp(2 * [lns1_1_2]_b[_cons]) - sedisgrp2^2)
tw (scatter stdres2 stdres1, mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O)) ///
(scatter stdres2 stdres1 if (stdres2 <-2 | stdres2>2)|(stdres1 <-2 | stdres1>2), mlw(medthin) mlc(black) mfc(yellow) msize(*1.5) ms(O)) ///
(scatter stdres2 stdres1, ms(i) mlabp(0) mlabel(study) mlabs(*.5) mlabc(black)), ylab(-3(1)3, angle(hor) format(%7.1f) nogrid) ///
xlab(-3(1)3, format(%7.1f) nogrid) xline(-2 0 2, lw(thin) lpat(dash)) yline(-2 0 2, lpat(dash) lw(thin) ) legend(off) ///
name(outlier, replace) ytitle("Standardized Residual(Diseased)") xtitle("Standardized Residual(Healthy)") ///
title("(d) Outlier Detection")

set graphics on
graph combine pdresid bivar cooksd outlier, cols(2) 

}
}


end





program bvbox, sortpreserve 
	version 9   
	syntax varlist(numeric min=2 max=2) [if] [in][, smooth(str asis) data(str asis) `options' *] 
	
	// observations to use 
	marksample touse 
		
	tempvar use diff sum diff1 sum1 work theta radius radius1 sm order pid
          tempname ymed ymad xmed xmad dmad smad
	
	// variables set-up 
	tokenize `varlist' 
	args y x 
	gen `pid'=_n
	quietly { 
		// initialize 
		gen `work' = . 
		gen byte `use' = . 
		gen `diff' = . 
		gen `sum' = . 
		gen `radius' = . 
		gen `diff1' = . 
		gen `sum1' = . 
		gen `radius1' = .
		gen `theta' = . 
		gen `order' = . 		
					
	
		tempvar s sx S SX s1 S1  sx1 SX1
 
		replace `use' = `touse' & `y' < . 
			
		// y <- (y - median y) / MAD y 
		mata : median("`y'", "`use'")  
		scalar `ymed' = r(p50)
                    replace `work' = abs(`y' - `ymed') if `use' 
		mata : median("`work'", "`use'")  
		scalar `ymad' = r(p50)
                    clonevar `s' = `y' 
		if `"`: variable label `s''"' == "" label var `s' "`y'"
		replace `s' = (`y' - `ymed') / `ymad' if `use' 
		
		// x <- (x - median x) / MAD x 
		mata : median("`x'", "`use'") 
		scalar `xmed' = r(p50) 
		replace `work' = abs(`x' - `xmed') if `use' 
		mata : median("`work'", "`use'")  
		scalar `xmad' = r(p50)
		gen `sx' = (`x' - `xmed') / `xmad' if `use' 
		
		// (y - x), (y + x) scaled to z / MAD z 
		replace `diff' = `s' - `sx' if `use' 
		mata : median("`diff'", "`use'")  
		replace `work' = abs(`diff' - r(p50)) 
		mata : median("`work'", "`use'")  
		scalar `dmad' = r(p50)
		replace `diff' = `diff' / `dmad'
		
		replace `sum' = `s' + `sx' if `use' 
		mata : median("`sum'", "`use'")  
		replace `work' = abs(`sum' - r(p50))
		mata : median("`work'", "`use'")  
		scalar `smad' = r(p50)
		replace `sum' = `sum' / `smad'

		// radius = cube root of sum^2 + diff^2 
		// theta = arctan of diff / sum 
		replace `radius' = sqrt(`sum'^2 + `diff'^2)
		replace `radius' = `radius'^(2/3)
		replace `theta' = atan2(`diff', `sum')   

		local sc  
		tempvar S C
		gen `S' = sin(`theta') 
		gen `C' = cos(`theta') 
		local sc `sc' `S' `C'
			 
		capture regress `radius' `sc' if `use' 
		if _rc gen `sm' = . if `use' 
		else predict `sm' if `use' 

		drop `sc' 
			
		// reverse transformation, (x, y) coordinates, scale 
		replace `radius' = `sm'^(3/2)
		replace `radius1' = 1.58 * `sm'^(3/2)
		drop `sm' 
		replace `diff' = `dmad' * `radius' * sin(`theta')
		replace `sum' = `smad' * `radius' * cos(`theta')
		replace `sx' = `xmed' + `xmad' * (`sum' - `diff')/2
		replace `s' = `ymed' + `ymad' * (`sum' + `diff')/2
		replace `diff1' = `dmad' * `radius1' * sin(`theta')
		replace `sum1' = `smad' * `radius1' * cos(`theta')
		gen `sx1' = `xmed' + `xmad' * (`sum1' - `diff1')/2
		gen `s1' = `ymed' + `ymad' * (`sum1' + `diff1')/2


		// sort order and end points for closing loop 
		bysort `use' (`theta') : replace `order' = _n if `use' 
		count if !`use'
		local first = 1 + r(N) 
		gen `SX' = `sx' in `first' 
		gen `S' = `s' in `first' 
		replace `SX' = `sx' in l 
		replace `S' = `s' in l 
		gen `SX1' = `sx1' in `first' 
		gen `S1' = `s1' in `first' 
		replace `SX1' = `sx1' in l 
		replace `S1' = `s1' in l 
                   
                    local hshade "color(gs14) nodropbase recast(area)"
                    local fshade "color(gs12) nodropbase recast(area)"
                    local clpcw1 "clpat(solid) clc(black) clw(thin)"
                    local clpcw2 "clpat(dash) clc(black) clw(thin)"
                    
                    
		// construct graph call 
		// line plot of smooth 
		local l "(line `s' `sx', `clpcw1' `hshade' `smooth')" 
		local l1 "(line `s1' `sx1', `clpcw2' `fshade' `smooth')"
		// line plot to close loop 
		local p	"(line `S' `SX', `clpcw1' `hshade' `smooth')" 
		local p1	"(line `S1' `SX1', `clpcw2' `fshade' `smooth')" 
			
		// scatter of data 
		local d "(scatter `y' `x' if `touse', mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O) `data')"  
		local e "(scatter `y' `x' if `touse', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black) `data')"  

		local call "`call'  `l1' `p1' `l' `p' `d' `e'" 		
	

	local off "legend(off)" 
	
	// final graph preparation 
	sort `order' 
	local yttl : variable label `y' 
	if `"`yttl'"' == "" local yttl "`y'" 
	local xttl : variable label `x' 
	if `"`xttl'"' == "" local xttl "`x'" 

	// graph 
	#delimit;
    	twoway `call', ti("Bivariate Boxplot", size(*.75)) yti(`"`yttl'"') xti(`"`xttl'"') 
	legend(order(`show')) ylabel( , angle(360)) plotregion(margin(zero)) `off' `options';
	#delimit cr
}
end


mata : 
void median(string scalar varname, string scalar which) 
{ 
	real scalar L, U 
	real matrix X
	
	st_view(X, ., varname, which) 
	X = sort(X,1)
	L = ceil(rows(X) / 2) 
	U = floor((rows(X) + 2) / 2) 
	 
	st_numscalar("r(p50)", (X[L,1] + X[U,1]) / 2) 
}
end 





program define midagalb
version 9.0

	syntax varlist(numeric min=2 max=2) [if] [in] ///
       [ , Title(str) ID(varname) LEvel(real 95) XTitle(string) YTitle(string) * ]

	tokenize `varlist'
	tempvar theta setheta pid
	gen `pid'=_n

	local theta `1'
	local setheta `2'
qui {
        tempvar x y 
        su `theta',detail        
        local emax=r(max)
        local emay=r(min)
        gen `x' = 1 / `setheta'
        su `x' , detail
        local maxx = r(max) 
        gen `y' = `theta'/`setheta' 
        reg `y' `x', noconstant  

    local galbropts " yscale(r(-2 2) noline) ylab(-2 2,angle(horizontal) nogrid )"  
  } 
#delimit; 
    twoway(scatter `y' `x', mlw(medthin) mlc(black) mfc(gs15) msize(*1.5) ms(O))
(scatter `y' `x', ms(i) mlabp(0) mlabel(`pid') mlabs(*.5) mlabc(black))(scatteri -2 0 2 0, s(i) recast(line)) 
    (function fitted = _b[`x'] * x, ra(0 `maxx') `fitted') (function upper = 2 + _b[`x'] * x, ra(0 `maxx') 
	clp(dash) clc(green) `upper' )(function lower = -2 + _b[`x'] * x, ra(0 `maxx')
    clp(dash) clc(green) `lower'), legend(off)  yti("standardized effect size",) xti("precision") yline(0, lpat(shortdash)) 
	`galbropts' plotregion(margin(zero)) xsc(r(0 `maxx')) `options' ;
#delimit cr
 end


program ebayes, rclass sortpreserve byable(recall)
version 10
syntax varlist(min=4 max=4 numeric) [if] [in], [ NIP(integer 7) PLOT(string) LEVEL(integer 95) *] 

qui {
preserve
marksample touse, novarlist
keep if `touse'
}
tokenize `varlist'
local tp `1'
local fp `2'
local fn `3'
local tn `4'
datasig
global chksig= r(datasignature)

/* STUDY-SPECIFIC Sensitivity (True Positive Rate)*/
tempvar sens senslo senshi sensse spec speclo spechi specse FPR          
gen `sens' = $tp/($tp+$fn)  
gen `senslo' = invbinomial($tp+$fn,$tp,$alph)   
gen `senshi' = invbinomial($tp+$fn,$tp,1-$alph)
gen `sensse' = (`senshi'-`senslo')/(2*invnorm(1-$alph)) 

/* STUDY-SPECIFIC Specificity (True Negative Rate) */

gen `spec' = $tn/($tn+$fp)      
gen `speclo' = invbinomial($tn+$fp,$tn,$alph)  
gen `spechi' = invbinomial($tn+$fp,$tn,1-$alph) 
gen `specse' =(`spechi'-`speclo')/(2*invnorm(1-$alph)) 

/* MIXED EFFECTS ESTIMATION */

qui {
local alph = (100-`level')/200
gen study = _n
gen ttruth1 = `tn'                   
gen ttruth2 = `tp'                    
gen num1 = `tn'+`fp'                      
gen num2 = `tp'+`fn'                      
reshape long num ttruth, i(study) j(dtruth) string
tabulate dtruth, generate(disgrp)
}
count 
local nnobs = r(N)
if `nnobs' <= `nip' {
xtmelogit (ttruth disgrp1 disgrp2, noc)(study: disgrp1 disgrp2, noc cov(unstr)), ///
bin(num) laplace var nofet noret nohead refineopts(iterate(4))
}
else if `nnobs' > `nip' {
xtmelogit (ttruth disgrp1 disgrp2, noc)(study: disgrp1 disgrp2, noc cov(unstr)), ///
bin(num) intp(`nip') var nofet noret nohead refineopts(iterate(4))
}
qui {
 nois di " "
 nois di " " 

predict redisgrp*, reffects
predict sedisgrp*, reses
gen ebsens = invlogit(redisgrp2 + _b[disgrp2])
gen ebsenslo = invlogit(redisgrp2  + _b[disgrp2] - 1.96*sedisgrp2)
gen ebsenshi = invlogit(redisgrp2  + _b[disgrp2] + 1.96*sedisgrp2)
gen ebsensse = (ebsenshi-ebsens)/invnormal(0.975)
gen ebspec = invlogit(redisgrp1 + _b[disgrp1])
gen ebspechi = invlogit(redisgrp1  + _b[disgrp1] + 1.96*sedisgrp1)
gen ebspeclo = invlogit(redisgrp1  + _b[disgrp1] - 1.96*sedisgrp1)
gen ebspecse=(ebspechi-ebspec)/invnorm(0.975)
format ebsens ebsenslo ebsenshi ebspec ebspeclo ebspechi %9.2f
format `sens' `senslo' `senshi' `spec' `speclo' `spechi' %9.2f
sort study
qui by study: gen last=_n==_N
drop if last!=1
tempvar obs obs1 wgt1 wgt2 
gen `obs' = _n 
gen `obs1' = _n + 0.30
count
local max1 = r(N)
label value `obs' obs
label value `obs1' obs1

forval i = 1/`max1'{
local value = `"`value' `i'"'
local value1 = `"`value' `i'"'
label define obs `i' "`=StudyId[`i']'", modify
label define obs1 `i' "`=StudyId[`i']'", modify

}

local ylabopt "labsize(*.75) tl(*0) labgap(*3)"

local xlab1 "xlab(0(0.25)1.00, format(%5.2f) labsize(*.50))"

gen `wgt1' = 1/(ebsensse *ebsensse)
set graphics off
if "`plot'"=="for" {
#delimit ;
twoway (rspike ebsenslo ebsenshi `obs' if last==1, ylabel(`"`value'"', valuelabel labsize(*.75) tl(*0) angle(360)) 
hor s(i) lpat(blank)  `xlab1')(scatter `obs1' `sens' if last==1, ms(i) msize(`mscale2') mcolor(gs10)) 
(scatter `obs' ebsens if last==1, ms(i) msize(`mscale2') mcolor(gs10))
(rspike `senslo' `senshi' `obs1' if last==1, ylabel(`"`value1'"', valuelabel labsize(*.75) tl(*0) angle(360)) 
hor s(i) lpat(blank)  `xlab1'), legend(off) xtitle("", size(*.5)) yscale(noline) xscale(off fill) 
plotregion(style(none)) ytitle("", size(*.5)) ysca(rev) title("study", size(*.5) pos(1)) fxsize(0) name(mplot, replace);
#delimit cr

#delimit ;
twoway (rspike ebsenslo ebsenshi `obs' if last==1, ylabel(`"`value'"', nolabel 
`ylabopt' angle(360)) hor s(i) blpattern(solid) blwidth(thin) blcolor(black) `xlab1')
(rspike `senslo' `senshi' `obs1' if last==1, ylabel(`"`value1'"', nolabel 
`ylabopt' angle(360)) hor s(i) blpattern(dash) blwidth(thin) blcolor(black) `xlab1')
(scatter `obs' ebsens if last==1, ms(o) mcolor(black))
(scatter `obs1' `sens' if last==1, ms(oh) mcolor(black)), ytitle("", size(*.5)) 
legend(off) xtitle("", size(*.5)) title("Sensitivity", size(*.5) 
justification(left)) ysca(rev) name(mplot1, replace) xline(`msens') ;
#delimit cr

gen `wgt2' = 1/(ebspecse*ebspecse)

#delimit ;
twoway (rspike ebspeclo ebspechi `obs' if last==1, ylabel(`"`value'"', nolabel 
`ylabopt' angle(360)) hor s(i) blpattern(solid) blwidth(thin) blcolor(black) `xlab1')
(rspike `speclo' `spechi' `obs1' if last==1, ylabel(`"`value1'"', nolabel 
`ylabopt' angle(360)) hor s(i) blpattern(dash) blwidth(thin) blcolor(black) `xlab1')
(scatter `obs' ebspec if last==1, ms(o) mcolor(black))
(scatter `obs1' `spec' if last==1, ms(oh) mcolor(black)), legend(off) 
xtitle("", size(*.5)) ytitle("", size(*.5))  title("Specificity", size(*.5) 
justification(left)) ysca(rev) nodraw name(mplot2, replace) xline(`mspec');
#delimit cr
set graphics on
#delimit ;
graph combine mplot mplot1 mplot2,  row(1) ysize(6) xsize(4) name(foreb, replace)
note("MLE of mean sensitivity and specificity (solid vertical lines)"
"Empirical Bayes (solid lines and markers)" 
"Observed data (dashed lines and markers)", 
position(6) justification(center) size(*.50)) scheme(sj);                                  
#delimit cr
}
else if "`plot'"=="roc" {
set graphics on
#delimit;	
version 10: twoway (pci 0 1 1 0, clpat(solid) clc(black))
(pcspike `sens' `spec' ebsens ebspec, lwidth(vvthin) lpatt(solid) lcol(black*5))
(scatter `sens' `spec', mlab(study) mlabsize(*.5) 
mlabpos(0) mcolor(gray) mlabc(black*2) msym(O) sort)
(scatter ebsens ebspec, mlabel(study) mlabpos(0) mlabsize(*.5) 
mlabc(black*2) mcolor(black) msym(Sh) sort)
, legend(order(3 "Observed Data" 4 "EBayes" 1 "Null Line") size(*.75) 
symxsize(2) pos(5) ring(0) col(1))
xsc(range(0 1)) ysc(range(0 1))  xla(0(.2)1, nogrid format(%7.1f)) 
yla(0(.2)1, nogrid angle(horizontal) format(%7.1f))  
plotregion(margin(zero)) xsc(rev) xti(Specificity) 
yti(Sensitivity) name(ebroc, replace)  scheme(sj);                                  
#delimit cr
}
}


end










  
                                                              
               
















   















   

