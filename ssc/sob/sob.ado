cap program drop sob
program sob, eclass
version 12
syntax [varlist(default=none)] [if] [in] [, REPS(int 400) NOConstant]

preserve
tempname beta
if "`varlist'" != ""{
	marksample touse
	qui reg `varlist' if `touse', `noconstant'
	local depvar: word 1 of `varlist'
	local exis: list varlist - depvar
	mat `beta'=e(b)
	loc check = 1
	loc exis_count=0
	foreach j in `exis'{
		if colnumb(`beta',"o.`j'") == `check' local exis: list exis - j
		else loc exis_count = `exis_count'+1
		loc check = `check'+1
	}
	
	qui bootstrap, reps(`reps'): reg `depvar' `exis' if `touse', `noconstant'

	qui keep if e(sample)
	if "`noconstant'" != "" loc noc = "noconstant"
}
if "`varlist'" == ""{
	cap assert e(cmd)=="regress"
	if _rc!=0 {
	noisily di as error "Second-order bootstrap correction must be run after a regression command"
	exit
	}
	mat `beta'=e(b)

	
	
	qui keep if e(sample)
	if colnumb(`beta',"_cons") == . loc noc = "noconstant"
	local s_lower = strpos(e(cmdline),":") + 1
	local s_upper = strrpos(e(cmdline),",") 
	local s_upper2 = strrpos(e(cmdline),"if ")
	if `s_upper2' > 0 local s_upper=`s_upper2'
	if `s_upper' <= `s_lower' loc s_upper = strlen(e(cmdline)) + 1
	local s_length = `s_upper' - `s_lower'
	local command = substr(e(cmdline),`s_lower',`s_length')
	loc command_prefix = word("`command'", 1) + " " + word("`command'", 2)
	loc vars: list command - command_prefix
	qui describe `vars', varlist
	loc exis = r(varlist)
	loc check = 1
	loc exis_count=0
	foreach j in `exis'{
		if colnumb(`beta',"o.`j'") == `check' local exis: list exis - j
		else loc exis_count = `exis_count'+1
		loc check = `check'+1
		
	}
	if !(e(vce) == "bootstrap" & e(N_reps) == `reps'){
	qui bootstrap, reps(`reps'): `command_prefix'  `exis', `noc'
	}
	
}


tempname X PX Sigma Q q uhat2 c f f2 gdenom g robust virtual stde V_virt Var




mat `Var' = e(V)


local zalpha=invnormal(.975)
*local maxlength=5
mat `stde' = e(se)

tempvar uhat uhat2 ones f2 anum adenom bnum bdenom vnum vdenom
predict `uhat', r
gen `uhat2'=`uhat'^2
* calculate rothenberg formula inputs
if "`noc'" == "" {
	gen `ones'=1 
	mkmat `exis' `ones', mat(`X')
}
else mkmat `exis', mat(`X')
mat `PX'=`X'*invsym(`X''*`X')*`X''
mkmat `uhat2', mat(`uhat2')
mat `Sigma'=diag(`uhat2')
mat `Q'=_N*`PX'*`Sigma'*(`PX'-2*I(_N))
mat `q'=vecdiag(`Q')'
svmat `q', names(`q')
if "`noc'" == "" local K=`exis_count' + 1
else local K = `exis_count'
local Kminus1=`K'-1
mat `beta' = e(b)
mat `virtual' = J(1,`K',.)
mat `V_virt' = J(`K',`K',0)
forvalues k=1/`K'  {
	cap drop `f2' `anum' `adenom' `bnum' `bdenom' `vnum' `vdenom' `g'1 `f'1
	if `k'==1 mat `c'=[1]
	local kminus1=`k'-1
	forvalues i=1/`kminus1' {
		if `i'==1 mat `c'=[0]
		else mat `c'=[`c',0]
		}
	if `k'!=1 mat `c'=[`c',1]
	forvalues i=`k'/`Kminus1' {
		mat `c'=[`c',0]
		}
	mat `c' = `c''

	mat `f'=_N*`X'*invsym(`X''*`X')*`c'
	svmat `f', names(`f')
	gen `f2'=`f'1^2
	mat `gdenom'=(`f''*`Sigma'*`f'/_N)
	mat `g'=(I(_N)-`PX')*`Sigma'*`f'/(`gdenom'[1,1]^.5)
	svmat `g', names(`g')
	gen `anum'=`f2'*`g'1^2
	gen `adenom'=`f2'*`uhat2'
	qui sum `anum'
	local anumsum =r(sum)
	qui sum `adenom'
	local adenomsum=r(sum)
	local a=`anumsum'/`adenomsum'
	gen `bnum'=`f2'*`q'1
	gen `bdenom'=`f2'*`uhat2'
	qui sum `bnum'
	local bnumsum=r(sum)
	qui sum `bdenom'
	local bdenomsum=r(sum)
	local b=`bnumsum'/`bdenomsum'
	gen `vnum'=`f'1^4*`uhat'^4
	gen `vdenom'=`f2'*`uhat2'
	qui sum `vnum'
	local vnumsum=r(sum)
	qui sum `vdenom'
	local vdenomsum=r(sum)
	local V=`vnumsum'/`vdenomsum'^2
	local h=(1-(1+`zalpha'^2)*`V'/12+(`a'*(`zalpha'^2-1)+`b')/2/_N)
	if `k'==`K' & "`noc'"=="" local ex = "_cons"
	else local ex=word("`exis'",`k')
	local senew`ex'=_se[`ex']*`h'
	mat `virtual'[1,`k'] = `senew`ex''
	mat `V_virt'[`k',`k'] = `senew`ex''^2
}
ereturn local vcetype = "SOB"

ereturn matrix se_virtual = `virtual',copy
ereturn local chi2 = "" 
ereturn scalar df_r = _N-`K'
ereturn local vce = "SOB"

ereturn repost V=`V_virt'
qui test `exis'
ereturn scalar F = r(F)
_prefix_display, ptitle("SOB")
ereturn repost V=`Var'
restore

end

