*! tobithetm V2.0 10nov2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program tobithetm, properties(svyb svyj svyr swml)
 version 10
 if replay() {
 if (`"`e(cmd)'"' != "tobithetm") error 301
 Replay `0'
 }
 else	Estimate `0'
end

program Estimate, eclass sortpreserve
 syntax varlist(fv) [if] [in] [fweight pweight iweight] [, noLOg noCONStant ///
 vce(passthru) HETero(varlist) noLRTEST OFFset(varname numeric) ///
 EXPosure(varname numeric) Level(cilevel) EForm initopt * ]
 mlopts mlopts, `options'
 local cns `s(constraints)'
 gettoken lhs rhs : varlist
 _fv_check_depvar `lhs'

 if "`weight'" != "" {
 local wgt "[`weight'`exp']"
 // for initial value calculations
 if "`weight'" == "pweight" {
 local awgt "[aw`exp']"
 }
 else	local awgt "`wgt'"
 }
 if "`log'" != "" {
 local qui quietly
 }
 if "`offset'" != "" {
 local offopt "offset(`offset')"
 }
 if "`exposure'" != "" {
 local expopt "exposure(`exposure')"
 }

 marksample touse
 markout `touse' `hetero' `offset' `exposure'
 _vce_parse `touse', opt(Robust oim opg) argopt(CLuster): `wgt', `vce'
 tokenize `varlist'
 local depn "`1'"
 macro shift
 qui summarize `depn' if `touse'
 local cons = r(mean)
 local Sigma = r(sd)

if "`hetero'"!="" {
di as txt "{bf:{err:======================================================}}"
di as txt "{bf:{err:* Tobit Multiplicative Heteroscedasticity Regression *}}"
di as txt "{bf:{err:======================================================}}"
tempname olsin
qui regress `lhs' `rhs' if `touse' , `constant'
matrix `olsin'=e(b),0
qui regress `lhs' `hetero' if `touse' , noconstant
matrix `olsin'=`olsin',e(b)
local initopt init(`olsin', copy) search(on) `nolog' `mlopts' 
ml model lf tobithetm_lfh (eq1: `lhs' = `rhs', `constant' `offopt' `expopt') ///
 (Hetero: `hetero', noconst) /Sig `wgt' if `touse', ///
 `vce' `log' `mlopts' `contin' `diparm' missing `initopt' maximize continue ///
 title("Tobit Multiplicative Heteroscedasticity Regression")
}

 else if "`hetero'"=="" {
di as txt "{bf:{err:======================================================}}"
di as txt "{bf:{err:* Tobit Normal Regression                            *}}"
di as txt "{bf:{err:======================================================}}"
 tempname olsin
qui regress `lhs' `rhs' if `touse' , `constant'
matrix `olsin'=e(b),0
local initopt init(`olsin', copy) search(on) `nolog' `mlopts' 
ml model lf tobithetm_lfn (eq1: `lhs' = `rhs', `constant' `offopt' `expopt') ///
 /Sig `wgt' if `touse', `vce' `log' `mlopts' `contin' `diparm' missing ///
 `initopt' maximize continue title("Tobit NormaL Regression")
 }
 if "`hetero'" == "" {
 ereturn scalar k_aux = 1
 }
 else	ereturn scalar k_aux = 0
 ereturn local cmd tobithetm
 Replay , level(`level') `eform'
end
program Replay
 syntax [, Level(cilevel) EForm ]
 ml display , level(`level') `eform'
end

program Scores
version 11
args depn s1 s2
quietly {
predict double `s1'
gen double `s2'=(((`depn'-`s1')/[Sigma][_cons])^2-1)/[Sigma][_cons]
replace `s1'=(`depn'-`s1')/([Sigma][_cons]^2)
}
end
