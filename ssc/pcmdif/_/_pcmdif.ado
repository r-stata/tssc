program define _pcmdif, eclass 
version 12.0
syntax varlist [if][, cov(string) LTCov(string) ITerate(string)  ADapt RObust Constraints(string)]

preserve
tokenize `varlist' `cov'
local nbit: word count `varlist'
local nbcov: word count `cov'
local nbit2:word count `difficulties'
local converge=0
local contraintePre "`constraints'"
local nbcons: word count `contraintePre'
foreach i in `contraintePre'{
	cons get `i'
	local CONS "`=r(contents)'"
	local itCONS`i' "`=subinstr("`CONS'","_"," ",.)'"
	local itCONS`i' "_`=word("`itCONS`i''",-3)'_`=word("`itCONS`i''",-2)'"
}
tempfile bddini
qui{
	save `bddini'pre,replace
	if "`if'"=="" {
		local if "if 1"
	}
	else{
		keep `if'
	}
	forvalues i=1/`nbit'{
		tab ``i'', matrow(rep__`i')
		forvalues j=1/`=rowsof(rep__`i')'{
			replace ``i''=`j'-1 if ``i''==rep__`i'[`j',1]
		}
	}
	save `bddini'_b,replace
	q memory
}
local matsizeini=r(matsize)
if "`iterate'"==""{
	local it=""
}
else{
	local iterateII="it(`iterate')"
}
tempvar one id item reponse obs wt x choix it covariable covverytemp
qui save `bddini'_b, replace
  /*************************************/
 /*	Estimation of the parameters	  */
/*************************************/
if `nbcov'!=0{
	local nbtotmodacov=0
	forvalues i=1/`nbcov'{
		qui tab ``=`nbit'+`i''', matrow(nom) matcell(val)
		local nbModCov`i'=r(r)
		forvalues k=1/`nbModCov`i''{
			local valmod`k'cov`i'=nom[`k',1]
			local nbmod`k'cov`i'=val[`k',1]
		}
		local nbtotmodacov=`nbtotmodacov'+`nbModCov`i''
		if `nbModCov`i''>15{
			noi di in ye "Are you sure that ``=`nbit'+`i''' is a qualitative variable? (``=`nbit'+`i''' has `nbModCov`i'' modalities)"
			noi di in gr ""
		}
		local tot`i'=r(N)
		forvalues k=1/`nbModCov`i''{
			local sum=0
			forvalues k2=1/`nbModCov`i''{
				if `k2'!=`k'{
					local sum=`sum'+val[`k2',1]
				}
			}
			local a`i'_`k'=round((`sum'-`tot`i'')/`tot`i'',0.01)
			local b`i'_`k'=round((`sum')/`tot`i'',0.01)
		}
	}
}
qui{
	keep `varlist' `cov' `ltcov'
	local nbdifftot=0
	forvalues i=1/`nbit'{
		gen `reponse'`i' = ``i''
		drop ``i''
		tab `reponse'`i'
		local moda`i'=`=r(r)'
		local nbdifftot=`nbdifftot'+`moda`i''-1
	}
	gen `one'=1
	su `one'
	local Nbid=r(N)
	collapse (sum) `wt'2=`one', by(`reponse'1-`reponse'`nbit' `cov' `ltcov')
	gen `id'=_n
	reshape long `reponse', i(`id') j(`item')
	drop if `reponse'==.
	gen `obs'=_n
	forvalues i=1/`nbit'{
		expand `moda`i'' if `item'==`i'
	}
	by `obs', sort: gen `x'=_n-1
	gen `choix'=`reponse'==`x'
	tab `item', gen(`it')
	forvalues i=1/`nbit'{
		forvalues g=1/`=`moda`i''-1'{
			gen d_``i''_`g'=(-1)*`it'`i'*(`x'>=`g')
		}
	}
	if `nbcov'!=0{
		forvalues i=1/`nbcov'{
			gen `covverytemp'=``=`nbit'+`i'''
			drop ``=`nbit'+`i'''
			rename `covverytemp' ``=`nbit'+`i'''
			tab ``=`nbit'+`i''', gen(``=`nbit'+`i'''__) matrow(nom)
			local nbModCov`i'=r(r)
			forvalues k=1/`nbModCov`i''{
				gen ``=`nbit'+`i'''__`k'_old=``=`nbit'+`i'''__`k'
				order ``=`nbit'+`i'''__`k'_old, first
				replace ``=`nbit'+`i'''__`k'=``=`nbit'+`i'''__`k'*`x'
				local ident`i'_`k'=nom[`k',1]
				if `k'==1 & `i'==1{
					local ident1=`ident`i'_`k''
				}
				rename ``=`nbit'+`i'''__`k' ``=`nbit'+`i'''_`ident`i'_`k''
			}
		}
		forvalues i=1/`nbcov'{
			drop ``=`nbit'+`i'''
		}
	}
	rename `id' theta
	rename `x' estimates
}
foreach variable in `ltcov'{
	qui replace `variable'=`variable'*estimates
}
eq slope:estimates
gen obs=`obs'
gen choix=`choix'
gen wt=`wt'
	if `nbcov'!=0{
/* Recherche de valeurs initiales */
		matrix a0=J(1,`=`nbdifftot'+`nbtotmodacov'-`nbcov'-`nbcons'',0)
		qui{
			tempfile bddencours
			save `bddencours', replace 
			use `bddini'_b, replace
			local countdif=1
			forvalues i=1/`nbit'{
				local pasEst=0
				foreach cons in `contraintePre'{
					if "`itCONS`cons''"=="``i''"{
						local pasEst=1
					}
				}
				if `pasEst'==0{
					ologit ``i''
					matrix ttt=e(b) 
					matrix a0[1,`countdif']=ttt
					local countdif=`countdif'+e(k)
				}
				else{
					matrix a0[1,`countdif']=0
					local countdif=`countdif'+1
				}
			}
		use `bddencours', replace 
		}
		constraint free
		local contrainte=r(free)
		local subgroup0 "``=`nbit'+1'':`ident1_1'"
		constraint `contrainte' ``=`nbit'+1''_`ident1_1'=0
		matrix a1=J(1,1,1)
		matrix a=(0,0)
		ereturn clear
		qui gllamm estimates d_`1'_1-d_``nbit''_`=`moda`nbit''-1' ``=`nbit'+1''_`ident1'-``=`nbit'+`nbcov'''_`ident`nbcov'_`nbModCov`nbcov''' `ltcov', i(theta) eqs(slope) link(mlogit) expand(`obs' `choix' o) weight(`wt') `adapt' `robust' nocons `iterateII' from(a) constraint(`contraintePre' `contrainte') skip /*copy*/
		matrix eB=e(b)
		local nbc=colsof(eB)
		matrix eV=e(V)
		local lll=e(ll)
		local ccnn=e(cn)
		local Nbic=e(N)
		local Kbic=e(k)
		local converge=e(converged)
		matrix estimations = eB
		local sdmu=abs(estimations[1,`=colsof(estimations)'])
	cons drop `contrainte'
}
else{
	ereturn clear
		matrix a0=J(1,`=`nbdifftot'-`nbcons'',0)
		qui{
			tempfile bddencours
			save `bddencours', replace 
			use `bddini'_b, replace
			local countdif=1
			forvalues i=1/`nbit'{
				local pasEst=0
				foreach cons in `contraintePre'{
					if "`itCONS`cons''"=="``i''"{
						local pasEst=1
					}
				}
				if `pasEst'==0{
					ologit ``i''
					matrix ttt=e(b) 
					matrix a0[1,`countdif']=ttt
					local countdif=`countdif'+e(k)
				}
				else{
					matrix a0[1,`countdif']=0
					local countdif=`countdif'+1
				}
			}
			use `bddencours', replace 
		}
		matrix a1=J(1,1,1)
				matrix a=(0,0)
		qui gllamm estimates d_`1'_1-d_``nbit''_`=`moda`nbit''-1' `ltcov', i(theta) eqs(slope) link(mlogit) expand(`obs' `choix' o) weight(`wt') `iterateII' `adapt' `robust' nocons from(a) skip /*copy*/ constraint(`contraintePre')
		matrix estimations = e(b)
		local sdmu=abs(estimations[1,`=colsof(estimations)'])
			matrix eB=e(b)
	local nbc=colsof(eB)
	matrix eV=e(V)
	
	local lll=e(ll)
local ccnn=e(cn)
local Nbic=e(N)
local Kbic=e(k)
local converge=e(converged)
}
clear
use `bddini'_b
use `bddini'pre, replace
restore
end
