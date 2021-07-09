*! Nikolas Mittag 31mar2012

cap program drop twfe_p
program define twfe_p
version 10.0
local myopts "UE E XBU"
_pred_se "`myopts'" `0'
if `s(done)' { exit }
local vtyp `s(typ)'
local varn `s(varn)'
local 0    `"`s(rest)'"'
syntax [if] [in] [, `myopts' noOFFset]
local type "`e'`ue'`xbu'"

*default: predict xb
if "`type'"=="" {
	di in gr "(option xb assumed; fitted values)"
	_predict `vtyp' `varn' `if' `in', xb `offset'
	exit
}

*get sample: except for ue, only allows subsamples of estimation sample
marksample touse
if "`type'"!="ue" {
	qui: sum `touse' if e(sample)==0, meanonly
	if r(max)>0 & r(max)!=. {
		di in red "predict with `type' can only be used for subsamples of the estimaton sample, excluding observations not marked by e(sample)"
		qui: replace `touse'=0 if e(sample)==0
	}
}

tempvar xb
local fes "fe1+fe2"
if "`e(model)'"=="match" local fes "`fes'+matchef"
quietly _predict double `xb' if `touse', xb `offset'
if "`type'" =="ue" {
	gen `vtyp' `varn' = `e(depvar)' - `xb' if `touse'
	label var `varn' "y-xb=`fes'+e"
	exit
}

if "`type'" =="e" {
	gen `vtyp' `varn' = `e(depvar)' - `xb' - (`fes') if `touse'
	label var `varn' "residuals"
	exit	
}
if "`type'"=="xbu" {
	gen `vtyp' `varn' =  `xb' + `fes' if `touse'
	label var `varn' "y-e=xb+`fes'"
	exit	
}
error 198
end



