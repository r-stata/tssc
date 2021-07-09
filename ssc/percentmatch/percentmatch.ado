*NK 03/12/15
*Version .98


program percentmatch, rclass
version 12
syntax [varlist] [if], GENerate(name) IDvar(varname) MATCHEDID(name)

quietly capture confirm variable `generate'
if !_rc{
	di as error "`generate' already exists"
	exit
}

quietly duplicates report `idvar'
if `r(unique_value)'!=`r(N)' {
	di as error "`idvar' does not uniquely identify observations"
	exit
}

quietly capture confirm variable `matchedid'
if !_rc{
	di as error "`matchedid' already exists"
	exit
}


quietly {

	tempvar check name
	tempfile matches idlookup idlookup2
	
	marksample touse, novar

	preserve
		gen  `check'= _n
		keep `check' `idvar'
		local idtable = subinstr("`idlookup'",".tmp",".dta", 1)
		save "`idtable'", replace
	restore
	
	preserve
		gen  `name'= _n
		keep `name' `idvar'
		rename `idvar' `matchedid'
		local idtable2 = subinstr("`idlookup2'",".tmp",".dta", 1)
		save "`idtable2'", replace
	restore
	
	preserve
			keep if `touse'==1
			keep `varlist' `idvar'
			gen `check' = _n
			order `check'
			sort `check'
			local q = `c(k)'
			
			local newname = subinstr("`matches'",".tmp",".raw", 1)
			local newname2 = subinstr("`matches'",".tmp",".dta", 1)
			capture erase "`newname'"
			mata: matchobs("`check'","`varlist'","`newname'")
			
			insheet using "`newname'", clear
			drop if id1==id2
			bysort id1: egen rankorder = rank(-1 * pmatch), u
			keep if rankorder == 1
			drop rankorder
			rename id1 `check'
			merge m:m `check' using "`idtable'", keep(3) nogen
			
			
			rename pmatch `generate'
			
			rename id2 `name'
			merge m:m `name' using "`idtable2'", keep(3) nogen
			
			drop `check' `name'
			save "`newname2'", replace
	restore
	}
	quietly {
		merge 1:1 `idvar' using "`newname2'", nogen
		return clear
		count
		return scalar N = `r(N)'
		return local varlist = "`varlist'"
		return scalar vars = `q'-1
		sum `generate' if `generate'>=.9
		return scalar p90 = `r(N)'
		sum `generate' if `generate'>=.95
		return scalar p95 = `r(N)'
		sum `generate' if `generate'==1
		return scalar p100 = `r(N)'
		
		capture erase "`newname2'"
		capture erase "`newname'"	
		}
	
end
	
	version 12
	mata:

	function matchobs(string scalar ids, Xs, files) {

			real scalar n, k, fh, i, j
			real vector id
			real matrix X
			string scalar msg

			st_view(X,.,Xs)
			st_view(id,.,ids)
			n = rows(X)
			k = cols(X)

			fh = fopen(files,"w")

			msg = sprintf("id1\tid2\tpmatch")
			fput(fh,msg)

			for (i=1; i<=n; i++) {
					pmatch = rowsum(X[i,.]:==X)/k
					for (j=1; j<=n; j++) {
							msg = sprintf("%g\t%g\t%g",id[i],j,pmatch[j])
							fput(fh,msg)
					}
			}

			fclose(fh)
	}

	end

		