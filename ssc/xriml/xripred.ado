*! v 1.0.1 PR 22feb2008.
program define xripred
version 8
* Computes survival, density and hazard functions from recent xriml model
* in surv_ml, dens_ml and haz_ml.
if "`e(cmd)'"!="xriml" {
	error 301
}
syntax [, noLn Adj(str) ]
local dist `e(dist)'
if "`dist'"=="n"|"`dist'"=="no" {
	local dnum 0
}
else local dnum=1*("`dist'"=="sl")+2*("`dist'"=="pn") /*
 */	       +3*("`dist'"=="en")+4*("`dist'"=="eg") /*
 */ 	       +5*("`dist'"=="ep")+6*("`dist'"=="ee") /*
 */ 	       +7*("`dist'"=="mp")+8*("`dist'"=="me")
tempvar ll
local llprog `e(user)'
if "`adj'"!="" {
	tokenize `adj'
	local na 0
	while "`1'"!="" {
		confirm var `1'
		confirm num `2'
		local ++na
		local vadj`na' `1'
		local nadj`na' `2'
		cap local b = [M]`1'
		if _rc {
			di as err "[Warning: `1' not in M-curve part of model]"
		}
		mac shift 2
	}
}
quietly {
	gen double `ll'=.
	local stuff MS
	cap di [G]_cons
	if _rc==0 local stuff `stuff'G
	cap di [D]_cons
	if _rc==0 local stuff `stuff'D
	local nc=length("`stuff'")
	forvalues i=1/`nc' {
		local curve = substr("`stuff'",`i',1)
		local `curve'cons = [`curve']_cons
		if "`adj'"!="" {
			forvalues j=1/`na' {
				cap local a = [`curve']`vadj`j''*`nadj`j''
				if _rc==0 {
					local `curve'cons=``curve'cons'+`a'
				}
			}
		}
	}
	global ML_y1 `e(depvar)'
	local cens $S_cens
	global S_cens
	local wt $S_wt
	global S_wt
	local off $S_off
	global S_off
	`llprog' `ll' `Mcons' `Scons' `Gcons' `Dcons'
*	`llprog' `ll' M_ml S_ml
	cap drop dens_ml
	gen dens_ml = exp(`ll') if e(sample)
	if "`ln'"!="noln" {
		replace dens_ml = dens_ml/exp($ML_y1)
	}
	cap drop surv_ml
	rename __U surv_ml
	replace surv_ml = 1-normprob(surv_ml)
	cap drop haz_ml
	gen haz_ml = dens_ml/surv_ml
	global S_cens `cens'
	global S_wt `wt'
	global S_off `off'
}
end
