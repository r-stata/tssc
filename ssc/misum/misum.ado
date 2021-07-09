*! version 1.0.4 05jul2011 Daniel Klein
* for history see end of file

prog misum ,rclass byable(recall)
	vers 9.2
	
	/*check mi or ice data format
	------------------------------*/
	if ("`_dta[mi_id]'" == "_mi") loc _mid _mj 
	else {
		if ("`_dta[_mi_style]'" != "flong") _mess notset
		loc _mid _mi_m 
	}
	
	syntax [varlist] [if][in] [aw fw iw] ///
	[, M(numlist int asc) Detail FORmat(passthru) MATrix(name)]
		
	/*get rid of string variables in varlist
	-----------------------------------------*/
	foreach v of loc varlist {
		cap conf numeric v `v'
		if _rc continue
		loc tmplist `tmplist' `v'
	}
	loc varlist `tmplist'
	
	/*check sample and get M
	-------------------------*/
	marksample touse ,nov
	qui count if `touse'
	if r(N) == 0 err 2000
	
	if ("`_mid'" == "_mj") {
		qui su _mj ,mean
		loc _Mis = r(max)
	}
	else loc _Mis = `_dta[_mi_M]'
	if `_Mis' == 0 _mess noimp
	
	/*option m
	-----------*/
	if ("`m'" != "") {
		loc _M : word count `m'
		if (`: word 1 of `m'' < 0) | (`: word `_M' of `m'' > `_Mis') ///
		err 125
	}
	else {
		loc _M = `_Mis'
		loc m 1/`_M'
	}
	
	/*define tempnames
	-------------------*/
	loc tmpnams mean Var min max N sum_w sum	
	if ("`detail'" != "") {
		loc tmpnams_d p50 skewness kurtosis ///
		p1 p5 p10 p25 p75 p90 p95 p99
	}
	tempname `tmpnams' sd R `tmpnams_d' mat_d

	/*create result matrix
	-----------------------*/
	mat `R' = J(`: word count `varlist'', 5, .z)
	mat rownam `R' = `varlist'
	mat colnam `R' = Mean SD min max N
	
	/*gather summary stats
	-----------------------*/
	loc mat_row 0
	foreach var of loc varlist {
		loc ++mat_row
		
		/*set empty matrices for each variable
		---------------------------------------*/
		foreach nam of loc tmpnams {
			mat ``nam'' = J(`_M', 1, .z)
		}
		if ("`detail'" != "") {
			foreach nam of loc tmpnams_d {
				mat ``nam'' = J(`_M', 1, .z)
			}
		}
		
		/*loop over imputed datasets
		-----------------------------*/
		loc i 0
		foreach val of numlist `m' {
			loc ++i
			qui su `var' [`weight' `exp'] if `_mid' == `val' ///
				& `touse' ,`detail'
			foreach nam of loc tmpnams {
				mat ``nam''[`i', 1] = r(`nam')
			}
			foreach nam of loc tmpnams_d {
				mat ``nam''[`i', 1] = r(`nam')
			}
		}
		
		/*calculate finals stats (average over m imputed datasets)
		-----------------------------------------------------------*/
		loc r_col 0
		foreach nam of loc tmpnams {
			loc ++r_col
			mata : st_matrix("``nam''" ,colsum(st_matrix("``nam''")) ///
							/ rows(st_matrix("``nam''")))
			
			/*get sd from pooled variance
			------------------------------*/
			if (`r_col' == 2) {
				sca `sd' = sqrt(``nam''[1, 1])
				mat `R'[`mat_row', `r_col'] = `sd'
				ret sca `var'_sd = `sd'
				ret sca `var'_Var = ``nam''[1, 1]
			}
			else {
				if (`r_col' <= 5) {
					mat `R'[`mat_row', `r_col'] = ``nam''[1, 1]
				}
				ret sca `var'_`nam' = ``nam''[1, 1]
			}
		}
		foreach nam of loc tmpnams_d {
			mata : st_matrix("``nam''" ,colsum(st_matrix("``nam''")) ///
							/ rows(st_matrix("``nam''")))
			ret sca `var'_`nam' = ``nam''[1, 1]
		}
	}
	
	di _n "{txt}{it:m}={res}`m' data"
	matlist `R' ,row(Variable) `format'
	if ("`matrix'" != "") ret mat `matrix' = `R'
end

prog _mess
	if ("`1'" == "notset") {
		di "{err}data must either be in {bf:ice} format " ///
		"or {bf:mi set} {it:flong} "
		exit 119
	}
	if ("`1'" == "noimp") {
		di "{err}no imputations found ({it:M}=0)"
		exit 119
	}
end
exit


History

1.0.4	05jul2011	sd_mi is now sqrt(var_mi)
					m must be given in ascending order and not contain dups
					detail matrix no longer calculated
					changes to help file
1.0.3	02jun2011	check -ice- or -mi- format using data characteristics
					(not on ssc)
1.0.2	19apr2011	downward compatibility with version 9.2 
					compatibility with data in -ice- format
					use mata function for matrix calculation
					remove string variables from varlist
					exit if M=0 with proper error (was syntax error 198)
					errors displayed in subroutine _mess
1.0.1		na		fix typo in prog define -misu-
					add -matrix- option
