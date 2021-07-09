/*
use "/home/doudou/Bureau/DIF sf36/gabs.dta", replace
local varlist gabs7a gabs10a gabs21a gabs30a gabs34a
gen TJ=typesdejeu==3
replace TJ=. if typesdejeu==.
local cov TJ
*/

program define pcmdif, rclass 
version 12.0
syntax varlist , cov(string) [LTCov(string) ITerate(string) ADapt RObust BIC Homo ALL]

preserve
set more off
local ltc ""
if "`ltcov'"!=""{
	local ltc "ltc(`ltcov')"
}
qui{
local nbcov: word count `cov'
tempfile bddini
save `bddini'pre,replace

if `nbcov'>1{
	noi di in red "Only one DIF covariate"
	use `bddini'pre,replace 
	error 100
}
local bic "AIC"
if "`bic'"!=""{
	local bic "BIC"
}
keep `varlist' `cov' `ltcov'
tokenize `varlist' 
local nbit: word count `varlist'
if "`homo'"!=""{
	forvalues i=1/`nbit'{
		tab ``i'' `cov', matcell(cell) matcol(col) matrow(row)
		forvalues c=1/`=colsof(col)'{
			forvalues r=1/`=rowsof(row)'{
				if cell[`r',`c']==0{
					noi di in red "pas de réponse à la modalité `=row[`r',1]' de l'item ``i'' dans le groupe `cov'=`=col[1,`c']'"
					noi di in red "regrouper des modalités pour utiliser des différences homogènes, ou rechercher des différences non homogènes"
					use `bddini'pre,replace 
					error 100
				}
			}
		}
	}
}
tab `cov', matrow(nom)
local nbModCov=r(r)
local testCov ""
forvalues k=1/`nbModCov'{
	local valmod`k'cov=nom[`k',1]
}
forvalues k=1/`nbModCov'{
	forvalues k2=`=`k'+1'/`nbModCov'{
		local testCov "`testCov' (`cov'_`valmod`k2'cov'-`cov'_`valmod`k'cov'=0)"
	}
}
local comptCons=1
forvalues i=1/`nbit'{
	local suiteCont ""
	local test`i' ""
	forvalues k=1/`nbModCov'{
		gen _``i''_g`valmod`k'cov' = ``i'' if `cov'==`valmod`k'cov'
		tab _``i''_g`valmod`k'cov', matrow(nm`i'_`k')
		local nbmoda`i'_`k'=r(r)
	}
	forvalues k=2/`nbModCov'{
		local test`i' "`test`i'' (d__``i''_g`valmod1cov'_1-d__``i''_g`valmod`k'cov'_1=0)"
		forvalues l=2/`=`nbmoda`i'_`k''-1'{
			const free
			local Cons`comptCons'=r(free)
			cons `Cons`comptCons'' d__``i''_g`valmod1cov'_`l'-d__``i''_g`valmod1cov'_`=`l'-1'=d__``i''_g`valmod`k'cov'_`l'-d__``i''_g`valmod`k'cov'_`=`l'-1'
			local suiteCont "`suiteCont' `Cons`comptCons''"
			local comptCons=1+`comptCons'
		}
	}
	local suiteCont`i' "`suiteCont'"
}
tempfile tmp
save `tmp', replace
clear
local order "cov"
set obs `=(2^`nbit')*2'
forvalues i=1/`nbit'{
	local order "`order' it`i'"
	gen it`i' =mod(ceil(_n/(2^`=`i'-1')),2)
}
gen cov =mod(ceil(_n/(2^`=`nbit'')),2)
order `order'
sort `order'
gen BIC=.
gen AIC=.
egen nbDif=rowtotal(cov it*)
sort nbDif
if "`all'"==""{
	gen aFaire=nbDif<=1
}
else{
	gen aFaire=1
}
su nbDif
local nbDif=r(max)
local nbtotmodels=_N
gen i=_n
if `nbtotmodels'>300{
	set matsize `=`nbtotmodels'+10'
}
forvalues nbDIF=0/`nbDif'{	
	forvalues i=1/`nbtotmodels'{	
		if nbDif[`i']==`nbDIF'{
			if aFaire[`i']==1{
				local model ""
				local suiteCont ""
				local cov2 ""
				forvalues it=1/`nbit'{
					local it`it'i=it`it'[`i']
					if it`it'[`i']==1{
						local model "`model' _``it''_g*"
						if "`homo'"!=""{
							local suiteCont "`suiteCont' `suiteCont`it''"
						}
					}
					else {
						local model "`model' ``it''"
					}
				}
				if cov[`i']==1{
					local cov2 `cov'
				}
				local covi=cov[`i']
				save `tmp'_step, replace
				use `tmp', replace
				noi di  in wh "`model'   `cov2' `LTCov'"				
				if `nbDIF'<`nbDif'{
					noi _pcmdif `model', cov(`cov2') it(`iterate') `adapt' `robust' c(`suiteCont') `ltc'
				}
				else{
					noi _pcmdif `model', cov(`cov2') it(15) `robust' c(`suiteCont') `ltc'
				}
				estimates store m_`i'
				local infoplus ""
				if "`homo'"!=""{
					forvalues it=1/`nbit'{
						if `it`it'i'==1{
							qui test `test`it''
							local infoplus "`infoplus' ``it'':`=round(`=r(p)',0.001)' "
						}
					}
				}
				local infopluscov ""
				if `covi'==1{
					local cov2 `cov'
					qui test `testCov'
					local infopluscov "`=round(`=r(p)',0.001)'"
				}	
				matrix b=e(b)
				matrix V=e(V)
				matrix V=vecdiag(V)
				local ll=e(ll)
				local kbic=e(k)
				local Nbic=e(N)
				local AIC=`ll'*(-2)+2*`kbic'
				local BIC=`ll'*(-2)+log(`Nbic')*`kbic'				
				use `tmp'_step, replace
				replace AIC=`AIC' if _n==`i'
				replace BIC=`BIC' if _n==`i'
				if `nbDIF'<`nbDif'{
					if cov[`i']==1{
						if "`homo'"!="" & "`infoplus'"!=""{
							noi di in gr "model " in ye "`i'" in gr" - " in gr "critère : " in ye "`bic'" in gr "   AIC : " in ye "`=round(`AIC', 0.1)'" in gr "   BIC : " in ye "`=round(`BIC', 0.1)'"in gr "   DIF : " in ye "`infoplus'" in gr "   Cov : " in ye "`infopluscov'"
						}
						else{
							noi di in gr "model " in ye "`i'" in gr" - " in gr "critère : " in ye "`bic'" in gr "   AIC : " in ye "`=round(`AIC', 0.1)'" in gr "   BIC : " in ye "`=round(`BIC', 0.1)'" in gr "   Cov : " in ye "`infopluscov'"
						}
					}
					else{
						if "`homo'"!=""& "`infoplus'"!=""{
							noi di in gr "model " in ye "`i'" in gr" - " in gr "critère : " in ye "`bic'" in gr "   AIC : " in ye "`=round(`AIC', 0.1)'" in gr "   BIC : " in ye "`=round(`BIC', 0.1)'"in gr "   DIF : " in ye "`infoplus'"
						}
						else{
							noi di in gr "model " in ye "`i'" in gr" - " in gr "critère : " in ye "`bic'" in gr "   AIC : " in ye "`=round(`AIC', 0.1)'" in gr "   BIC : " in ye "`=round(`BIC', 0.1)'"
						}
					}
				}
				else{
					noi di in gr "model " in ye "`i'" in gr" - " in gr "critère : " in ye "`bic'" in gr "   AIC : " in ye "`=round(`AIC', 0.1)'" in gr "   BIC : " in ye "`=round(`BIC', 0.1)'"
				}
			}
		}
	}	
	sort `bic'
	local cafaire "nbDif==`=`nbDIF'+1'"
	if nbDif[1]==`nbDIF'{
		if cov[1]==1{
			local cafaire "`cafaire' & cov==1"
		}
		forvalues it=1/`nbit'{
			if it`it'[1]==1{
				local cafaire "`cafaire' & it`it'==1"
			}
		}
		replace aFaire=1 if `cafaire'
	}
	sort i
	save `tmp'_step, replace
	mkmat i it* cov BIC AIC aFaire , mat(AicBic)
}
}
use `tmp'_step, replace
sort `bic'
estimates restore m_`=i[1]'
cons drop `suiteCont'
use `bddini'pre,replace
restore
return matrix AicBic=AicBic
end
