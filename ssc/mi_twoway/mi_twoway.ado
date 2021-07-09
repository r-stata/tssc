program define mi_twoway,rclass
version 11.0
syntax  varlist [, SCorename(string) REPlace ADD(int 10) STyle(string) clear DA ITerate(int 10)]
qui{
tempfile bddini
save `bddini', replace
if "`scorename'"==""{
	local scorename score
}
capture tab `scorename'
if _rc==0{
	if "`replace'"!=""{
		drop `scorename'
	}
	else{
		noi di in red "variable `scorename' already exists"
		use `bddini',replace 
		error 100
	}
}
local nombase ""
if wordcount("`style'")==0{
	local style mlong
}
else if wordcount("`style'")==1{
	if "`=word("`style'", 1)'"=="ml" | "`=word("`style'", 1)'"=="mlo" | "`=word("`style'", 1)'"=="mlon" | "`=word("`style'", 1)'"=="mlong" | "`=word("`style'", 1)'"=="fl" | "`=word("`style'", 1)'"=="flo" | "`=word("`style'", 1)'"=="flon" | "`=word("`style'", 1)'"=="flong" | "`=word("`style'", 1)'"=="w"  | "`=word("`style'", 1)'"=="wi"  | "`=word("`style'", 1)'"=="wid"  | "`=word("`style'", 1)'"=="wide"{
		local style `style'
	}
	else{
		noi di in red "option {it:style} improperly fulfilled"
		noi di in red "    Only {it:mlong}, {it:flong}, {it:wide} and {it:flongsep} are available"				
		noi di in red "    A database name must be proposed if the style {it:flongsep} is selected (see mi_styles)"
		use `bddini',replace 
		error 100
	}
}
else if	wordcount("`style'")==2{
	if "`=word("`style'", 1)'"=="flongs" | "`=word("`style'", 1)'"=="flongse" | "`=word("`style'", 1)'"=="flongsep"{
		local nombase `=word("`style'", 2)'
		local style `=word("`style'", 1)'
	}
	else{
		noi di in red "option {it:style} improperly fulfilled"
		noi di in red "    Only {it:mlong}, {it:flong}, {it:wide} and {it:flongsep} are available"				
		noi di in red "    A database name must be proposed if the style {it:flongsep} is selected (see mi_styles)"
		use `bddini',replace 
		error 100
	}
} 
	
	
	

tempvar var

local M `_dta[_mi_M]'
if "`M'"!=""{
	if "`clear'"==""{
		noi di in red "no; data are mi set"
		noi di in red "    Use {it:clear} option to replace imputed values using mi_twoway, or"
		noi di in red "    other MI commands (like {it:mi extract})"
		use `bddini',replace 
		error 100
	}
	else{
	mi extract 0, clear
	}
}





gen `var'id=_n
sort `var'id
save `bddini'_bis, replace
tokenize `varlist'
if `add'==.{
	local add==10
}
if `iterate'==.{
	local iterate==10
}

egen keep=rowmean(`varlist')
keep if keep!=.
drop keep
local Nb=_N
local nbit: word count `varlist'
egen `var'i=rowmean(`varlist')
forvalues j=1/`nbit'{
	gen it_`var'_`j'=``j''
}
keep it_`var'_* `var'id `var'i
reshape long it_`var'_, i(`var'id) j(it)
rename it_`var'_ it_`var'
bysort it: egen Mj=mean(it_`var')
su it_`var'
local MM=r(mean)
gen Me=`var'i+Mj-`MM'
gen Dif2=(Me-it_`var')^2
su Dif2
local Var=r(sum)/(r(N)-1)
gen __miss=it_`var'==.
forvalues it=1/`add'{
	gen _`it'_`var'=it_`var'
	replace _`it'_`var'=rnormal(Me, `=sqrt(`Var')') if __miss==1
}
/* Data augmentation */


if "`da'"!=""{

	gen `var'present=1-__miss
	bysort `var'id: egen `var'Cpre=total(`var'present)
	bysort it: egen `var'CItpre=total(`var'present)
	su `var'present
	local Nobs=r(sum)
	gen `var'Pre=_1_`var'
	su `var'Pre
	local mu=r(mean)
	bysort it: egen `var'Be=mean(`var'Pre)
	replace `var'Be=`var'Be-`mu'
	bysort `var'id: egen `var'Al=mean(`var'Pre)
	gen `var'sigInt=(`var'Pre-`var'Be-`var'Al)^2
	su `var'sigInt
	local sigma2=r(sum)/(`nbit'-1)/(`Nb'-1)
	gen `var'tauInt=(`var'Al-`mu')^2
	su `var'tauInt if it==1
	local tau2=r(sum)/(`Nb'-1)
	forvalues it=1/`add'{
		forvalues g=1/`iterate'{
/*			noi di "it = `g'"*/
			/* Redéfinition alpha */
			capture drop A2 `var'A2 `var'A2V B2 `var'Be2 Vbe2 S2 TAU
			gen A2=(it_`var'-`var'Be)/`sigma2'
			bysort `var'id: egen `var'A2=total(A2)
			replace `var'A2=(`var'A2+`mu'/`tau2')/(1/`tau2' + `var'Cpre/`sigma2')
			gen `var'A2V=sqrt(1/(1/`tau2'+`var'Cpre/`sigma2'))
			replace `var'Al=rnormal(`var'A2, `var'A2V)

			/* Redéfinition beta */
			gen B2=(it_`var'-`var'Al)
			bysort it: egen `var'Be2=mean(B2)
			gen Vbe2=sqrt(`sigma2'/`var'CItpre)
			replace `var'Be=rnormal(`var'Be2, Vbe2)

			/* Redefinition Sigma */
			gen S2=(it_`var'-`var'Al-`var'Be)^2
			su S2
			local sigma2b=`=r(N)'*`r(mean)'/rchi2(`=r(N)')
			if `sigma2b'!=0{
				local sigma2=`sigma2b'
			}




			/* Redefinition mu */
			su `var'Al if it==1
			local mu=rnormal(`=r(mean)', `=sqrt(`tau2'/r(N))')

			/* Redefinition tau2 */
			gen TAU=(`var'Al-`mu')^2
			su TAU if it==1
			local tau2b=`=r(N)'*`r(mean)'/rchi2(`=r(N)')
			/* 1/(rgamma(`=r(N)/2', `=2/r(N)/r(mean)'))    OU      `=r(N)'*`r(mean)'/rchi2(`=r(N)')*/
			if `tau2b'!=0{
				local tau2=`tau2b'
			}
			/*noi di "mu: `mu' tau2: `tau2' sigma2: `sigma2'"
			noi su `var'Al `var'Be*/

		}
		replace _`it'_`var'=rnormal(`mu',`=sqrt(`tau2')')+`var'Be+rnormal(0,`=sqrt(`sigma2')') if __miss==1
	}

}
/* Fin de data augmentation */
bysort `var'id: egen _mi_miss=max(__miss)
drop Mj Me Dif2 `var'i __miss
keep *_`var' `var'id it _mi_miss
reshape wide *_`var', i(`var'id) j(it)
egen `scorename'=rowtotal(it_`var'*)
replace `scorename'=. if _mi_miss==1
forvalues j=1/`add'{
	egen _`j'_`scorename'=rowtotal(_`j'_*), missing
}
forvalues i=1/`nbit'{
	rename it_`var'`i' ``i''
	forvalues j=1/`add'{
		rename _`j'_`var'`i' _`j'_``i''
		label variable _`j'_``i'' ""
	}
}
drop `varlist'
order `scorename' _mi_miss, first
sort `var'id
save `bddini'_ter, replace
use `bddini'_bis
merge `var'id using `bddini'_ter
drop _merge `var'id
char _dta[_mi_pvars] `scorename'
char _dta[_mi_M] `add'
char _dta[_mi_ivars] `varlist'
char _dta[_mi_style] wide
char _dta[_mi_marker]  _mi_ds_1
char _dta[_miTW]  TW
mi convert `style' `nombase', clear
}
end
