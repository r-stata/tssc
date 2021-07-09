


************** Start of program

capture program drop calibest
*! calibest v2.2 JCD'Souza 1Feb2011
program define calibest, rclass
version 10
syntax varlist(numeric) , MARginals(varlist) SELwt(string) CALIBwt(string) psu(string) METHod(string) [DESign(string)]


************** Check the input is correctly defined


* The marginals and weights should be numeric
confirm numeric variable `marginals' `selwt' `calibwt' 

if "`method'"=="mean" {
	
	************** The selection and calibration weights should sum to the same totals
	
	tempname sumsel sumcalib 
	tempvar ratiowt
	qui: summ `selwt'
	scalar `sumsel'=r(sum)
	qui: summ `calibwt'
	scalar `sumcalib'=r(sum)
	qui: gen `ratiowt'=`calibwt'*`sumsel'/(`selwt'*`sumcalib')
	
	
	
	local nvar: word count `varlist'
	tempname M row Bhat
	tempname rmat meff tinv
	matrix `rmat'=J(`nvar',4,.)
	matrix `meff'=J(`nvar',1,.)
	local c=1  // c indexes the variable
	
	foreach v of varlist `varlist' {
	
		qui: matrix accum `M'=`marginals' [iweight=`selwt'], noconstant   // Make the matrix
		matrix vecaccum `row'=`v' `marginals' [iweight=`selwt'], noconstant   // Make the row vector (essentially E(XY))
		matrix `Bhat'=(inv(`M'))'*(`row')' // Make the matrix Bhat (estimate of B)
	
	
		* Define temporary variables and names
		tempvar yhat`c' ge`c'
		tempname se`c' mean`c' ev`c' eb`c' N`c' meff`c'
		
		* Start by calculating fitted values
		qui: gen `yhat`c''=0
	
		local i=1
		foreach x of local marginals {
			qui: replace `yhat`c''=`yhat`c''+`Bhat'[`i',1]*`x'
			local i=`i'+1
		}
	
		qui: gen `ge`c''=(`v'-`yhat`c'')*`ratiowt'   // ge is the weighted residual
	
		* Estimation and store results as scalars
		preserve
			qui: svyset `psu' [pweight=`selwt'], `design'
			qui: svy: mean `ge`c''
			matrix `ev`c''=e(V)
			scalar `tinv'=invttail(e(df_r),0.025)
			scalar `se`c''=sqrt(el(`ev`c'',1,1))
			scalar `N`c''=e(N)
			qui: mean `v' [pweight=`calibwt']
			matrix `eb`c''=e(b)
			scalar `mean`c''=el(`eb`c'',1,1)
		
			qui: mean `v'
			matrix `ev`c''=e(V)
			scalar `meff`c''=`se`c''^2/el(`ev`c'',1,1)
			
		
			* Store results
			matrix `rmat'[`c',1]=`mean`c''
			matrix `rmat'[`c',2]=`se`c''
			matrix `rmat'[`c',3]=`mean`c''-`tinv'*`se`c''
			matrix `rmat'[`c',4]=`mean`c''+`tinv'*`se`c''
			matrix `meff'[`c',1]=`meff`c''
		restore
	local c=`c'+1
	}
	
	
	di _newline
	di in smcl in green "{hline 12}{c TT}{hline 56}"
	di in smcl in green _col(13)"{c |}"  %12s "Mean" _col(28)  %12s "Est S.E" _col(40)  %24s "[95% Conf. Interval]"
	di in smcl in green "{hline 12}{c +}{hline 56}"
	local c=1
	foreach v of varlist `varlist' {
	di in smcl in green _col(1) %12s "`v'" _col(13)  "{c |}"  _col(18) in yellow %10.8g `rmat'[`c',1] _col(30) in ye %10.8g `rmat'[`c',2] _col(42) in ye %10.8g `rmat'[`c',3] _col(54) in ye %10.8g `rmat'[`c',4]
	local c=`c'+1
	}
	di in smcl in gr "{hline 12}{c BT}{hline 56}"
	
	return matrix meff =`meff'
	return matrix rmat=`rmat'
}	
else if "`method'"=="prop"{
	tempname est xxx ncat catname
	tempvar name
	foreach v of varlist `varlist' {
		tempvar temp
		qui: tab `v', gen(i`temp')
		qui: calibest i`temp'* , marginals(`marginals') selwt(`selwt') calibwt(`calibwt') psu(`psu') method(mean) design(`design')

	matrix `est'=r(rmat)	

	qui: tab `v', matrow(`xxx')
	scalar `ncat'=r(r)

	preserve
		keep `v'
		capture decode `v', gen(`name')
		if _rc==0 {
			contract `v' `name'
			local c=1
			while(`c'<=`ncat'){
				scalar `catname'`c'=`name'[`c']
				local c=`c'+1
			}
		}
		else {
		local c=1
			while(`c'<=`ncat'){
				scalar `catname'`c'=`xxx'[`c',1]
				local c=`c'+1
			}
		}
	restore

	di _newline
	di in smcl in green "{hline 12}{c TT}{hline 56}"
	di in smcl in yellow "`v'" in green  _col(13)"{c |}"  %12s "Proportion" _col(28)  %12s "Est S.E" _col(40)  %24s "[95% Conf. Interval]"
	di in smcl in green "{hline 12}{c +}{hline 56}"
	local c=1
	while(`c'<=`ncat'){
	di in smcl in green _col(1) %12s `catname'`c' _col(13)  "{c |}"  _col(18) in yellow %10.8g `est'[`c',1] _col(30) in ye %10.8g `est'[`c',2] _col(42) in ye %10.8g `est'[`c',3] _col(54) in ye %10.8g `est'[`c',4]
	local c=`c'+1
	}
	di in smcl in gr "{hline 12}{c BT}{hline 56}"

	drop i`temp'*
	}
}
else {
	di in red "Method must be mean or prop"
}

end






