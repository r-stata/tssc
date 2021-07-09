// program drop _all
// mata: mata clear
program orse, rclass
*! orse  1.1.0  CFBaum  17oct2007
* 1.1.0: modified to refer to eststo rather than discontinued esto

	syntax [,ADD(string) ]
	version 9.2
	if "`e(cmd)'" ~= "logit" & "`e(cmd)'" ~= "ologit" {
    	error 301
    }
    if "`add'" != "" {
    	   capture which estadd
		   if _rc == 111 {
	       		di as error "You must install estadd to use add( )"
	       		exit 198
	       }
	       capture which eststo
		   if _rc == 111 {
	       		di as error "You must install eststo to use add( )"
	       		exit 198
	       }
	}

	tempname b v se
	mat `b' = e(b)
	local k = e(df_m)
	mat `v' = e(V)
	mata: orse(`k')
	local col: colnames `b'
	local col: subinstr local col "_cons" " ", all
	local row: rownames `b'
	mat colnames or = `col'
	mat rownames or = `row'
	mat colnames orse = `col'
	mat rownames orse = `row'
	di _n "OR, ORse stored in matrices or, orse"

	if "`add'" != "" {
		estadd matrix or = or
		estadd matrix orse = orse
		eststo `add'
		di _n "You may tabulate these estimates with "
		di "estout `add', cells(or orse(par)) style(fixed) drop(_cons)" _n
	}
	end
	
	mata:
	void orse(real scalar k)
	{
		b = st_matrix("e(b)")
		v = st_matrix("e(V)")
		or = exp(b[|1,1 \ 1,k|])
		dv = sqrt(diagonal(v[|1,1 \ k,k|]))'
		orse = or :* dv
		st_matrix("or",or)
		st_matrix("orse",orse)
	}
	end
	
