program define revcat, eclass byable(recall)
version 11.2

syntax varlist(min=2 max=3 numeric) [if] [in] [ fweight pweight ] , [ change(numlist min=1 ascending) minage(real 1) smooth rr lambda(varlist) age ///
		init(name) level(integer `c(level)') nolog * ]

quietly{
	//*************************************************
	//*************************************************
	mlopts mlopts, `options'

	local nc : word count `change'
	local nl=`nc'+1

	matrix revcat_mat=J(`nl', 1, .)
	forval i=1/`nc'{
		matrix revcat_mat[`i', 1]=`:word `i' of `change''
	}
	matrix revcat_mat[`nl', 1]=1E20

	marksample touse
	local nv : word count `varlist'
	if `nv'==3{
		gettoken pos varlist : varlist
		gettoken a date : varlist
	}
	else{
		gettoken pos a : varlist
		tempvar date
		gen byte `date'=0
		if `nc'>0 & "`age'"==""{
			tempname tc
			matrix `tc'=revcat_mat
			forval i=1/`nc'{
				matrix revcat_mat[`i', 1]=-`tc'[`nc'-`i'+1, 1]
			}
		}
	}
	replace `touse'=0 if `a'<`minage'-1E-8
	markout `touse' `lambda'
	
	if "`lambda'"~="" local p1 : word count `lambda'

	if "`lambda'"~="" & "`rr'"=="" & `nc'>0{
		di as error "When there is at least one change in lambda, lambda can only depend on covariates if the option " _c
		di as input "rr " _c
		di as error "is specified"
		exit 198
	}

	count if `pos'!=0 & `pos'!=1 & `touse'
	if r(N)>0{
		di as error "Outcome variable may only take values 0 and 1"
		exit 459
	}
	foreach d in 1 0{
		count if `pos'==`d' & `touse'
		if(r(N)==0){
			di as error "Outcome variable must have at least one observation equal to `d' to fit the model"
			exit 459
		}
	}
	
	if "`weight'" != "" local wgt [`weight'`exp']
	
	//*************************************************

	forval i=1/`nl'{
		if(`i'==1 | "`rr'"=="") local y`i' lambda`i'
		else local y`i' r`i'
	}

	tempname b
	if "`init'"~=""{
		matrix `b'=`init'
	}
	else{
		if "`lambda'"=="" & `nv'==2 & `nc'==0{
			_pctile `a' if `touse' `wgt', percentiles(50)
			local ma=r(r1)
			capt{
				mean `pos' if `a'>=`ma' & `touse' `wgt'
				local q=_b[`pos']
			}
			if(_rc!=0 | `q'==0 | `q'==1) local q=0.5

			count if `a'<=`ma' & `touse' & `pos'==1
			if r(N)>0{
				tempvar a2
				gen `a2'=`a'^2
				reg `pos' `a' `a2' if `a'<=`ma' & `touse' `wgt', nocons
				if _b[`a']>0{
					local lambda0=_b[`a']
				}
				else{
					reg `pos' `a' if `a'<=`ma' & `touse' `wgt', nocons
					local lambda0=_b[`a']
				}
			}
			else{
				reg `pos' `a', nocons
				local lambda0=_b[`a']
			}
			local rho0=`lambda0'*(1-`q')/`q'
			local log_lambda01=log(`lambda0')
			local log_lambda02=`log_lambda01'
			local log_rho=log(`rho0')
		}
		else if(`nc'<=1 & "`smooth'"==""){
			tempname c0
			matrix `c0'=revcat_mat
			revcat `pos' `a' if `touse' `wgt' , iter(20)
			matrix revcat_mat=`c0'
			local log_lambda01=[log_lambda1]_b[_cons]
			local log_lambda02=`log_lambda01'
			local log_rho=[log_rho]_b[_cons]
		}
		else{
			if mod(`nc', 2)==0 local ch=(revcat_mat[`nc'/2, 1] + revcat_mat[`nc'/2+1, 1])*0.5
			else local ch=revcat_mat[ceil(`nc'/2), 1]
			tempname c0
			matrix `c0'=revcat_mat
			revcat `pos' `a' `date' if `touse' `wgt' , iter(20) `age' change(`ch')
			matrix revcat_mat=`c0'
			tempname b0
			matrix `b0'=e(b)
			local log_lambda01=[log_lambda1]_b[_cons]
			local log_lambda02=[log_lambda2]_b[_cons]
			local log_rho=[log_rho]_b[_cons]
		}

		local log_lambda=(`log_lambda01' + `log_lambda02')/2
		local dr=2*(`log_lambda01' - `log_lambda02')/(`nl')
		
		local ps
		forval i=1/`nl'{
			local h=(`nl'+1)/2 -`i'
			if(`i'==1) local ps `ps' `=`log_lambda' + `h'*`dr'',
			else if("`rr'"=="") local ps `ps' `=`log_lambda' + `h'*`dr'',
			else local ps `ps' `=-(`i'-1)*`dr'',
		}
		if "`lambda'"~="" local mat1 "J(1, `p1', 0),"
		matrix `b'=(`mat1' `ps' `log_rho')
		if "`smooth'"~="" matrix `b'=(`b', 0)
		local names
		foreach s in `lambda'{
			local names `names' log_lambda1:`s'
		}
		local names `names' log_lambda1:_cons
		forval i=2/`nl'{
			local names `names' log_`y`i'':_cons
		}
		local names `names' log_rho:_cons
		if "`smooth'"~="" local names `names' log_sigma:_cons
		matrix colnames `b' = `names'
	}

	local eqns (log_lambda1:`pos' `a' `date'=`lambda')
	forval i=2/`nl'{
		local eqns `eqns' (log_`y`i'':)
	}
	local eqns `eqns' (log_rho:)
	if "`smooth'"~=""{
		local eqns `eqns' (log_sigma:)
		global revcat_smooth=1
	}
	else{
		global revcat_smooth=0
	}
	if("`rr'"=="") global revcat_rr=0
	else global revcat_rr=1
	if("`age'"=="") global revcat_age=0
	else global revcat_age=1

	//*************************************************
	//*************************************************
}

ml model lf2 revcat_ll `eqns' if `touse'  `wgt', maximize init(`b', skip) nooutput `log' `mlopts' search(off)

local di
forval i=1/`nl'{
	if(`i'>1 | "`lambda'"==""){
		ereturn scalar `y`i''=exp([log_`y`i'']_b[_cons])
		local di `di' diparm(log_`y`i'' , exp label("`y`i''"))
	}
	if(`i'>1 & "`rr'"~=""){
		ereturn scalar lambda`i'=exp([log_r`i']_b[_cons] + [log_lambda1]_b[_cons])
	}
}
ereturn scalar rho=exp([log_rho]_b[_cons])
local di `di'  diparm(log_rho , exp label("rho"))
if "`smooth'"~=""{
	ereturn scalar sigma=exp([log_sigma]_b[_cons])
	local di `di'  diparm(log_sigma , exp label("sigma"))
}
if `nc'>0{
	tempname rc
	matrix `rc'=revcat_mat[1..`nc',1]
	ereturn matrix change=`rc'
}
if `nv'==2{
	ereturn local depvar `pos' `a'
}
ereturn local age=$revcat_age
macro drop revcat_smooth
macro drop revcat_rr
macro drop revcat_age
matrix drop revcat_mat

ereturn local cmd "revcat"

ml display , level(`level') `di'

end
