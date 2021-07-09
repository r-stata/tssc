*! 1.0.4 NJC 29 May 2015  
* 1.0.3 NJC 27 November 2014  
* 1.0.2 NJC 25 November 2014  
* 1.0.1 NJC 16 October 2014  
* 1.0.0 NJC 10 April 2014  
program pcacoefsave 
	version 9  
	syntax using/ [, replace noROTated comment(str)] 

	if "`e(cmd)'" != "pca" { 
		di as err "must run pca first" 
		exit 498 
	} 

	if "`rotated'" != "norotated" & "`e(r_criterion)'" != "" { 
		if "`e(r_L)'" != "matrix" { 
			di as err "rotated loadings e(r_L) not found" 
			exit 498 
		}
		local which "r_" 
	} 	

	tempname loadings rho eigenv sds means 
	matrix `loadings' = e(`which'L) 
	local J = colsof(`loadings')
	local I = rowsof(`loadings') 
	local rows : rownames `loadings'

	matrix `eigenv' = e(Ev) 
	matrix `means' = e(means) 

	tokenize "`rows'" 
	forval i = 1/`I' { 
		local name`i' "``i''"  
		local lbl`i' : var label ``i'' 
		if `"`lbl`i''"' == "" local lbl`i' "``i''"  
	} 

	quietly { 
		preserve 
		drop _all 
		local N = `I' * `I' 
		set obs `N' 

		forval i = 1/`I' { 
			label def names `i' "`name`i''", modify 
			label def labels `i' `"`lbl`i''"', modify 
		}

		egen varname = seq(), block(`I') 
		egen varlabel = seq(), block(`I') 
		egen PC = seq(), to(`I') 

		gen corr = . 
		gen loading = . 
		gen eigenvalue = . 
		gen mean = . 
		gen SD = . 
		mata: work("`rho'", "`sds'", "`e(Ctype)'") 

		forval i = 1/`I' { 
			replace SD = `sds'[1, `i'] if varname == `i' 
			replace mean = `means'[1, `i'] if varname == `i' 
			forval j = 1/`J' { 
				local n = (`i' - 1) * `I' + `j' 
		 	`star'  replace eigenvalue = `eigenv'[1, `j'] if PC == `j' 
				replace loading = `loadings'[`i', `j'] in `n' 
				replace corr = `rho'[`i', `j'] in `n' 
			}
			local star "*" 
		}	

		replace eigenvalue = 0 if eigenvalue == . 

		label val varname names
		label val varlabel labels 

		label var varname "variable" 
		label var varlabel "variable" // sic 
		label var corr "correlation" 
		label var loading "coefficient" 
		label var SD "standard deviation" 

		if "`comment'" != "" gen comment = `"`comment'"'  

		compress 
	}

	save "`using'", `replace'  
end 

mata : 

void work(string scalar corrmatname, string scalar sdname, scalar ctype) { 

	real matrix rho, L 
	real scalar nadd 

	L = st_matrix("e(L)") 
	if (nadd = rows(L) - cols(L)) { 
		L = L, J(rows(L), nadd, .) 
	} 
  
	st_matrix(corrmatname, 
		rho = L  :* sqrt(st_matrix("e(Ev)"))) 
	
 	if (ctype == "covariance") { 
		st_matrix(corrmatname, 
			rho :/ sqrt(diagonal(st_matrix("e(C)")))) 
		st_matrix(sdname, sqrt(diagonal(st_matrix("e(C)")))')
	}
	else st_matrix(sdname, st_matrix("e(sds)")) 
}

end  

