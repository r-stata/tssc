*! version 3.0  05sep2002 NJGW
* v 1.3.1 Nicholas Winter  15aug2002
* v 1.3 altered to deal with error checking - arrgh!
* v 1.2.1 fixed bug where observations not recored in ratio estimation
prog define svrcalc, rclass
	version 7

	global dbug1 *

	syntax varlist [pweight iweight/] [if] , /*
		*/ SVRWeights(string) method(string) dof(real) [ b(string) type(string) v(string)  /*
		*/ vsrs(string) by(varname) nby(integer 0) obs(string) npop(string) /*
		*/  SRSSUBpop fay(real 0) Error(string)  ]

	if "`exp'"!="" {
		local wt "[aw=`exp']"
		local iwt "[iw=`exp']"
		local mainweight `exp'
	}

	local svrwspec "`svrweights'"
	unab svrw : `svrweights'
	local nsvrw : word count `svrw'

	marksample touse
	tempname totb repb accumV

	local n_err 0

	if "`type'"=="" { local type mean }
	if !("`type'"=="mean" | "`type'"=="total" | "`type'"=="ratio") { error 198 }

	local nvar : word count `varlist'
	if "`type'"=="ratio" {
		if mod(`nvar',2) { error 198 }		/* must have even number */
	}

	if "`by'"!="" {
		tempname byrows
		qui ta `by' , matrow(`byrows')
		forval r=1/`nby' {
			local curval = `byrows'[`r',1]
			local byvals "`byvals' `curval'"
		}
		local bycalc "by(`by') byvals(`byvals') nby(`nby')"
		local bysvy "by(`by') nby(`nby')"
	}
	if "`obs'"=="" {
		tempname obs
	}
	local obscalc "obs(`obs')"
	if "`npop'"=="" {
		tempname npop
	}
	local obscalc "`obscalc' npop(`npop')"
	if "`error'"=="" {
		tempname error
	}
	local errcalc "emat(`error')"
	tempname reperr
	local errrep "emat(`reperr')"

*DO FULL-SAMPLE ESTIMATE OF MEANS or TOTALS

$dbug1 di
$dbug1 di `"full sample call: DoSvrCalc `varlist' `wt' , bmat(`totb') type(`type') touse(`touse') `bycalc' geterr(n_err) `obscalc' `errcalc'"'
$dbug1 di

	DoSvrCalc `varlist' `wt' , bmat(`totb') type(`type') touse(`touse') `bycalc' geterr(n_err) `obscalc' `errcalc'

$dbug1 di
$dbug1 di "{red} main call matrix -error-:
$dbug1 mat list `error'

	local size=colsof(`totb')
	matrix `accumV'=J(`size',`size',0)


* RUN THROUGH REPLICATIONS

	local rfac 1
	forval rep = 1/`nsvrw' {
		local curw : word `rep' of `svrw'

$dbug1 di
$dbug1 di "Call for replicates:
$dbug1 di
$dbug1 di "DoSvrCalc `varlist' [aw=`curw'] , bmat(`repb') type(`type') touse(`touse') geterr(n_err) `errcalc' `bycalc'"


		DoSvrCalc `varlist' [aw=`curw'] , bmat(`repb') type(`type') touse(`touse') geterr(n_err) `errrep' `bycalc'


		mat `reperr'=`reperr'/10					/* this gives replicate-based errors a lower number than */
											/* full-sample errors, so the full sample will trump */
		local dim_err = colsof(`reperr')
		forval i=1/`dim_err' {
			local m = `error'[1,`i']
			local r = `reperr'[1,`i']
			matrix `error'[1,`i']=max(`m',`r')
		}

$dbug1 di
$dbug1 di "{red} after rep call within svrcalc: updated full error matrix:
$dbug1 mat list `error'

		matrix `repb' = `repb' - `totb'				/* turn into deviation */
		if "`method'"=="jkn" {
			local rfac : word `rep' of $S_VYpsus
			local rfac = ((`rfac'-1)/`rfac')
		}
		matrix `accumV' = `accumV' + (`rfac')* ((`repb'')*(`repb'))		/* add this one:  (b_k - b_tot)'(b_k - b_tot) */
													/* NOTE: Stata stores b as ROW vector, so b'b is  */
													/*       OUTER product, not inner				*/
	}

	tempname scalefac
	if "`method'"=="brr" {
		scalar `scalefac' = 1 / (`nsvrw' * (1-`fay')^2 )
	}
	else if "`method'"=="jk1" {
		scalar `scalefac' = (`nsvrw'-1)/`nsvrw'
	}
	else if "`method'"=="jk2" | "`method'"=="jkn" {
		scalar `scalefac' = 1
	}
	matrix `accumV'=`accumV' * `scalefac'

	tempname N_pop N
	qui sum `mainweight' if `touse'
	scalar `N'=r(N)
	scalar `N_pop'=`r(sum)'


* CALCULATE VSRS if needed

	if "`vsrs'"!="" {
		tempname V_srs

		if "`by'"=="" {

			cap matrix accum `V_srs' = `varlist' `wt' if `touse' , dev nocons

			if _rc | r(N)==0 {	/* problem -- likely no cases.  If so, the error matrix is already set, just need to fake out here */
				local  i : word count `varlist'
				matrix `V_srs'=J(`i',`i',0)
			}
			else {
				if "`type'"=="mean" {
					mat `V_srs' = `V_srs' / ((`r(N)'-1)*`r(N)')
				}
				else if "`type'"=="total" {
					mat `V_srs' = (`V_srs' / ((`r(N)'-1)*`r(N)')) * `N_pop'^2
				}
				else if "`type'"=="ratio" {
					_svy `varlist' `iwt' if `touse' , type(ratio) vsrs(`V_srs') `srssub'
				}
			}

		}
		else {

			cap _svy `varlist' `iwt' if `touse' , type(`type') vsrs(`V_srs') `bysvy' `srssub'
			if r(N)==0 {
				local nosrs 1
			}

			/*
			local i 1
			foreach val of local byvals {
				tempname mat`i'
				qui matrix accum `mat`i'' = `varlist' `wt' if `touse' & `by'==`val' , dev nocons
				if "`type'"=="mean" {
					matrix `mat`i'' = `mat`i'' / ((`r(N)'-1)*`r(N)')
				}
				else if "`type'"=="total" {
					matrix `mat`i'' = MatTotDiv(`mat`i'',`obs')
				}
				else if "`type'"=="ratio" {
					????
				}

				local addstr "`addstr' + `mat`i''"
				local i=`i'+1

			}
			local addstr=substr(`"`addstr'"',4,.)
			local end=(`nby'*`nvar')-1
			forval i=0/`end' {
				forval j=1/`nby' {
					local themod= mod(`i'+1,`nby')
					if `themod'==0 { local themod `nby' }
					if `themod' != `j' {
						MatAddRC `mat`j'' `i' `mat`j''
					}
				}
			}

			matrix `vsrs' = `addstr'
			*/

		}


	}


*POST MATRIX RESULTS

	if "`b'"!="" {
		matrix `b'=`totb'
	}
	if "`v'"!="" {
		matrix `v'=`accumV'
	}

	if "`vsrs'"!="" & "`vsrs'"!="*" & "`nosrs'"!="1" {		/* These should be same answers provided by _svy */
		matrix `vsrs'=`V_srs'
	}


*	if `dof' == -1 {
*		local dof : char _dta[svrdof]
*		if "`dof'"=="" | "`dof'"=="-1" {
*			local dof `nsvrw'
*		}
*	}

*	return scalar errcode = `n_err'	/* not used anymore... */
	if `nvar'==1 & "`by'"=="" {
		if "`vsrs'"!="" {
			return scalar Var_srs = `V_srs'[1,1]
		}
		return scalar Var      = `accumV'[1,1]
		return scalar estimate = `totb'[1,1]
	}
	return scalar N_pop = `N_pop'
	return scalar N_psu = `dof'*2		/* kludge to get svy-based wrapper to work right */
	return scalar N_strata = `dof'
	return scalar N = `N'

end

program define DoSvrCalc

	syntax varlist [aw] , type(string) bmat(string) touse(string) 	/*
		*/ [ by(varname) byvals(string) nby(integer 0) 		/*
		*/   obs(string) npop(string) emat(string) geterr(string) Error(string) ]


	local geterr 0

	if "`obs'`npop'`error'"!="" {
		local nv : word count `varlist'
		if "`type'"=="ratio" {
			local nv=`nv'/2
		}
		local nby = `nby'
		local dim=max(`nv'*`nby',1)
		if "`obs'"!="" {
			mat `obs'=J(1,`dim',0)
		}
		if "`npop'"!="" {
			mat `npop'=J(1,`dim',0)
		}
		if "`error'"!="" {
			mat `error'=J(1,`dim',0)
		}

	}

	tempname omat pmat
	mat `bmat'=(0)						/* initialize the matrix */
	mat `omat'=(0)
	mat `pmat'=(0)
	mat `emat'=(0)
	if "`type'"!="ratio" {
		foreach var of local varlist {
			if !`nby' {
				sum `var' [`weight'`exp'] if `touse' , meanonly
				if r(N)!=0 {
					if "`type'"=="total" {
						mat `bmat'=`bmat',r(sum)
					}
					else { /* mean */
						mat `bmat'=`bmat',r(mean)
					}
					mat `emat'=`emat',0
				}
				else {	/* N==0, so error! */
					mat `bmat'=`bmat',1e99
					mat `emat'=`emat',1
					local geterr 1
				}
				if "`obs'"!="" {
					mat `omat'=`omat',r(N)
				}
				if "`npop'"!="" {
					mat `pmat'=`pmat',r(sum_w)
				}
			}
			else {  /* THERE ARE by variables */
				local i 1
				foreach val of local byvals {
					sum `var' [`weight'`exp'] if `touse' & `by'==`val', meanonly
					if r(N)!=0 {
						if "`type'"=="total" {
							mat `bmat'=`bmat',r(sum)
						}
						else { /* mean */
							mat `bmat'=`bmat',r(mean)
						}
						mat `emat'=`emat',0
					}
					else {	/* N==0, so error! */
						mat `bmat'=`bmat',1e99
						mat `emat'=`emat',1
						local geterr 1
					}
					if "`obs'"!="" {
						mat `omat'=`omat',r(N)
					}
					if "`npop'"!="" {
						mat `pmat'=`pmat',r(sum_w)
					}

					local i=`i'+1
				}
			}
		}
	}



	else { /* type is ratio */
		tempname tot1
		tokenize `varlist'
		while "`1'"!="" {
			if !`nby' {
				sum `1' [`weight'`exp'] if `touse' , meanonly
				scalar `tot1'=r(sum)
				if r(N)==0 {
					mat `bmat'=`bmat',1e99
					mat `emat'=`emat',1
					local geterr 1
				}
				else {
					sum `2' [`weight'`exp'] if `touse' , meanonly
					if r(sum)!=0 {
						mat `bmat'=`bmat',(`tot1'/r(sum))
						mat `emat'=`emat',0
					}
					else {
						mat `bmat'=`bmat',(1e99)
						mat `emat'=`emat',4
						local geterr 4
					}
				}

				if "`obs'"!="" {
					mat `omat'=`omat',r(N)
				}
				if "`npop'"!="" {
					mat `pmat'=`pmat',r(sum_w)
				}
			}
			else {
				local i 1
				foreach val of local byvals {
					sum `1' [`weight'`exp'] if `touse' & `by'==`val' , meanonly
					scalar `tot1'=r(sum)
					if r(N)==0 {
						mat `bmat'=`bmat',1e99
						mat `emat'=`emat',1
						local geterr 1
					}
					else {
						sum `2' [`weight'`exp'] if `touse' & `by'==`val' , meanonly
						if r(sum)!=0 {
							mat `bmat'=`bmat',(`tot1'/r(sum))
							mat `emat'=`emat',0
						}
						else {
							mat `bmat'=`bmat',(1e99)
							mat `emat'=`emat',4
							local geterr 4
						}
					}

					if "`obs'"!="" {
						mat `omat'=`omat',r(N)
					}
					if "`npop'"!="" {
						mat `pmat'=`pmat',r(sum_w)
					}
					local i=`i'+1
				}
			}
			mac shift 2
		}
	}

	mat `bmat'=`bmat'[1,2...]			/* drop initialized zero */
	if "`obs'"!="" {
		mat `obs'=`omat'[1,2...]
	}
	if "`npop'"!="" {
		mat `npop'=`pmat'[1,2...]
	}
	if "`emat'"!="" {
		mat `emat'=`emat'[1,2...]
	}

end /* DoSvrCalc */



prog define MatAddRC
	version 7
	args mat num newmat	/* insert row/col after existing r/c num */

	local nr=scalar(rowsof(`mat'))
	local nc=scalar(colsof(`mat'))
	if `nr'!=`nc' {
		di in red "must be square matrix"
		error 198
	}
	if `num'>(`nr') | `num'<0 {
		di in red "`num' out of range"
		error 198
	}
	tempname part1 part2 add

*ADD ROW*
	if `num'>0 {
		matrix `part1' = `mat'[1..`num',1...]
		local a "`part1' \"
	}

	if `num'<`nr' {
		matrix `part2' = `mat'[`num'+1...,1...]
		local b "\ `part2'"
	}

	matrix `add' = J(1,`nc',0)
	mat `newmat' = `a' `add' `b'

*ADD COLUMN*
	if `num'>0 {
		matrix `part1' = `newmat'[1... , 1..`num' ]
		local a "`part1' ,"
	}

	if `num'<`nr' {
		matrix `part2' = `newmat'[1... , `num'+1...]
		local b ", `part2'"
	}

	matrix `add' = J(`nc'+1,1,0)
	matrix `newmat' = `a' `add' `b'

*RELABEL
	local nr1=`nr'+1
	forval i=1/`nr1' {
		local cname "`cname' c`i'"
		local rname "`rname' r`i'"
	}
	matrix colnames `newmat' = `cname'
	matrix rownames `newmat' = `rname'

end
