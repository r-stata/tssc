*! bking  1.0.3  CF Baum  22Oct2004
*  from E. Pelz MATLAB code for Baxter-King filter; validated against
* http://www.clev.frb.org/research/workpaper/1999/bpassm.txt
* with bk1=bpass(inv,6,32,0,0,3,12)
*      bk2=bpass(inv,6,32,0,0,3,24)
*      bk3=bpass(inv,6,32,0,0,3,36)
* note that root and drift params in bpass.m are ignored for Baxter-King
* 1.0.1: perform B mtx code in variable, reduce max matrix to T
*        require tsset, enable if/in/ts ops in varlist
* 1.0.2: change naming of result vars to F..., remove generate option
* 1.0.3: correct handling of magic, restore missings in generated series,
*        create new vars with mandatory stub option; trap large K

program define bking8, rclass
	version 8.2

syntax varlist(ts) [if] [in], PLO(string) PHI(string) STUB(string) [K(int 12)] 

	marksample touse
	_ts timevar panelvar `if' `in', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
		}
	if `plo' >= `phi' {
		di in red "Lower bound (plo) must be less than upper bound (phi)"
		error 198
		}
	if `plo' < 2     {
		di in red "Lower bound (plo) must be at least 2"
		error 198
		}
	if `k' < 1     {
		di in red "K must be at least 1"
		error 198
		}
	su `touse', mean
	if 2*`k'>=r(mean)*r(N) {
		di in r "K too large for sample size"
		error 198
		}
* validate each new varname defined by stub()
	local kk: word count `varlist'
	local varlist2: subinstr local varlist "." "_", all	
	qui forval i = 1/`kk' {
		local v: word `i' of `varlist2'
		confirm new var `stub'_`v'
		gen float `stub'_`v' = .
		local varlist3 "`varlist3' `stub'_`v'"
	}
	
    tempname X F B bb b a bapi sum ess AA tee teed tf ttt
    tempvar Bv en tsum
    preserve
* to ensure that result is aligned with first obs implied by touse,
* must mkmat entire varlist
* replace missing values implied by ts operators with magic number
* and markout those values
* 1.0.3: deal with problem of missing values in following mkmat
*	local magic=1E+300
	local magic=1E+36
	tsrevar `varlist', list
	tsrevar `varlist', sub
	local vl `r(varlist)'
	markout `touse' `vl'
	qui mvencode `vl', mv(`magic')
      mkmat `vl', matrix(`X')
      mkmat `touse', matrix(`tee')
      mat `teed' = diag(`tee')
* premultiplying by diag(touse) ensures that obs lost to if, in, ts ops
* are excluded from final transformation
    mat `X' = `teed'*`X'
	local tm = rowsof(`X')
	qui gen `tsum' = sum(`touse')
	qui gen `tf' = _n if `tsum'==1
	qui summ `tf',meanonly
	local tf = r(mean)
* t is number of obs to be filtered; tf is number of first obs
* tm is number of rows of matrix X
	local t = `tsum'[_N]
	local t2p1 = `t'*2 + 1
* to avoid generating B vector of length 2 t, do as variable
	capt set obs `t2p1'
	scalar `b' = 2*_pi/`plo'
	scalar `a' = 2*_pi/`phi'
	scalar `bapi' = (`b'-`a')/_pi
* concat bap1 and sin expression into Bv, length 2T+1 
	qui gen long `en' = _n-1 in 1/`t2p1'
	qui gen double `Bv' = `bapi' in 1/1
	qui replace `Bv' = (sin(`en'*`b')-sin(`en'*`a'))/(`en'*_pi) in 2/`t2p1'
	local lbb =  2*`k'+1
	mat `bb' = J(`lbb',1,0)
	local lp1 = `k'+1
	forv i=1/`lp1' {
		mat `bb'[`i'+`k',1] = `Bv'[`i']
		}
	local j 1
	forv i=`k'(-1)1 {
		local j = `j'+1
		mat `bb'[`i',1] = `Bv'[`j']
		}
	scalar `sum' = 0
	forv i=1/`lbb' {
		scalar `sum' = `sum' + `bb'[`i',1]
		}
	scalar `sum' = `sum' / `lbb'
	mat `ess' = J(`lbb',1,`sum')
	matrix `bb' = `bb' - `ess'
* place the t elements in AA, with offset adj for touse
	matrix `AA' = J(`tm',`tm',0)
	local lend = `t' - `k'
	local adj = `tf'-1
	local lp1 = `lp1' + `adj'
	local lend = `lend' + `adj'
	forv i = `lp1'/`lend' {
		local ilo = `i'-`k'
		local ihi = `i'+`k'
		local kk 0
		forv j = `ilo'/`ihi' {
			local kk = `kk' + 1
			matrix `AA'[`i',`j'] = `bb'[`kk',1]
			}
		}
* F will be aligned with original timeseries obs
	mat `F' = `AA'*`X'
    restore
    local c = colsof(matrix(`F'))
    local r = rowsof(matrix(`F'))
    local vars
    forv i = 1/`c' {
        local v : word `i' of `varlist3'
        qui replace `v' = matrix(`F'[_n, `i']) in 1/`r'
* 1.0.3 restore missings
        qui replace `v' = . if !`touse'
    	}
	end
