*! Version 1.0.0 12june2020

/*
	Syntax:

	aei, <Price> <Quantity> [<op1>] [<op2>] [<op3>]
		
		<op1> := AXiom[(string)]
			eWGARP
			eWARP
			eGARP	(Defualt)
			eSARP
			eHARP
			eCM
		<op2> := SUPPRESS
		<op3> := TOLerance[(real 1*10^-12)]

*/

/* ================================================================== */
					/* Main ado file */

program aei, rclass sortpreserve
	version 15.1

	*User input
	syntax, Price(string) Quantity(string) /// 
			[TOLerance(real 12) AXiom(string) SUPPRESS]
	
					*******************************
					*** Checking data structure ***
					***   and syntax validity   ***
					*******************************

	** Check nr 2:
	* Is there at least one product with a non-zero quantity in every given period?
	mata: st_numscalar("r(nrz)", (min(rowsum(st_matrix("`quantity'")))==0 ? 1 : 0))
	if `r(nrz)' == 1 {
		display as error 	" The data contains observations" ///
		as error 			" with zero (or missing) quantities."
		exit 459 /* "Something that should be true of your data is not" error */
	}

	** Check nr 3:
	* Are prices and quantity data of the same dimension?
	mata: checkdimension("`price'", "`quantity'")
	if `r(SR)' == 0 | `r(SC)' == 0 {
		display as error 	" Invalid matrix dimensions." ///
							" The price matrix is " r(RP) "x" r(CP) "." ///
							" The quantity matrix is " r(RX) "x" r(CX) "."
		exit 459 /* "Something that should be true of your data is not" error */
	}

	** Check nr 4:
	* Are prices strictly positive?
	mata: st_numscalar("r(PNSP)", (min(st_matrix("`price'")) < 0 ? 1 : 0))
	if `r(PNSP)' > 0 {
		display as error 	" The price matrix contains non-positive values."
		exit 411 /* "Nonpositive values encountered" error */
	}


	** Check nr 5
	* Is the tolerance level correctly specified?
	if `tolerance' < 1 | `tolerance' > 18 {
		
		display as error	"Tolerance() must be greater than or equal to 1" ///
							"and less than or equal to 18."
		display as error	"If not specified, the default setting for " ///
							"tolerance() is 12."
		display as error	"Recall that the tolerance option specifies the number of " ///
			"decimal places you would like in the tolerance level."
		display as error	"E.g., tolerance(6) implies that the tolerance level " ///
			"should be 1*10^(-6) = 1/(10^6) = 0.000001"
		
		exit 198
		
	}


	capture confirm integer number `=`tolerance''

	if (!_rc)	local tolerance = 1*10^-`tolerance'
	
	else {
		display as error	"Tolerance() must be an integer."

		exit 198
	}


	** Option nr 2:
	* Which axiom does the user want to check?
	local axiom = lower("`axiom'")
	
	if ("`axiom'"=="") local axiom egarp	/* eGARP set to default */
	else if !inlist("`axiom'", "egarp", "ewgarp", "esarp", "ewarp", "eharp", "ecm") {
		display as error 	" Axiom() must be either eGARP, eWGARP, eSARP," ///
							" eWARP, eHARP or eCM; case-insensitive."
		display as error 	" If not specified, the default setting for Axiom() is eGARP"
		exit 198 /* "Invalid syntax --> range invalid" error */
	}

				************************************		
				*** Estimating Afriat Efficiency ***
				************************************

	
	checkax, price("`price'") quantity("`quantity'") efficiency(1) ///
			axiom("`axiom'") suppress nocheck
	quietly return list

	
	if `r(PASS)' == 1 {
		
		return scalar	OBS			= r(OBS)
		return scalar	GOODS		= r(GOODS)
		return scalar	TOL		 	= `tolerance'
		return scalar 	AEI 		= r(EFF)	
	}

	else {

		tempvar eupper elower eevaluate
		
		quietly		gen `eupper'	= 1
		quietly		gen `elower'	= 0
		quietly		gen `eevaluate' = .
		
		while (`eupper' - `elower')/`elower'  >= `tolerance' {
			
			* Default tolerance level is 10^(-12)

			quietly replace `eevaluate' = (`eupper' + `elower')/2

			local eev = `eevaluate'
			
			checkax, price("`price'") quantity("`quantity'") efficiency(`eev') ///
					axiom("`axiom'") suppress nocheck
			quietly return list
			
			if `r(PASS)' == 1 {
				
				quietly replace `elower' = `eevaluate'

			}

			else {
				
				quietly replace `eupper' = `eevaluate'
				
			}
					
		}
			

		return scalar	OBS			= r(OBS)
		return scalar	GOODS		= r(GOODS)
		return scalar	TOL 		= `tolerance'
		return scalar 	AEI 		= r(EFF)	
	}
	
	
	** Display Output **
	local axiomDisplay = "e" + upper(substr("`axiom'", 2, strlen("`axiom'") - 1))

	return local AXIOM "`axiomDisplay'"

	if ("`suppress'" == "") {
		local aeiDisplay : di %6.4f scalar(r(EFF))
		
		tempname outputTable
		
		matrix `outputTable' = J(1, 4, .)
		matrix colname `outputTable' = AEI Tol Goods Obs
		matrix rowname `outputTable' = "`axiomDisplay'"
		
		matrix `outputTable'[1,1] = `aeiDisplay'
		matrix `outputTable'[1,2] = `tolerance'
		matrix `outputTable'[1,3] = `r(GOODS)'
		matrix `outputTable'[1,4] = `r(OBS)'

		matlist `outputTable', rowtitle("Axiom") border(top bottom)
				
	}
	
	if ("`suppress'" != "") {
	
	}
	
end

mata
					
/* ================================================================== */
					/* Check nr 3 */

void checkdimension(string P_temp, string X_temp)
{
	real scalar 	same_rows, same_cols, no_rows, no_cols
	real scalar		rx, rp, cx, cp
	
	x = st_matrix(X_temp)
	p = st_matrix(P_temp)
	
	rx = rows(x)
	rp = rows(p)
	
	cx = cols(x)
	cp = cols(p)
	
	//same_rows = (rx == rp ? 1 : 0)
	//same_cols = (cx == cp ? 1 : 0)
	
	if (rx == rp) 				same_rows = 1
	else 						same_rows = 0
	
	if (cx == cp)				same_cols = 1
	else						same_cols = 0
	
	// Rows
	st_numscalar("r(RX)", rx)
	st_numscalar("r(RP)", rp)
	
	// Columns
	st_numscalar("r(CX)", cx)
	st_numscalar("r(CP)", cp)
	
	// Same dimensions dummies
	st_numscalar("r(SR)", same_rows)
	st_numscalar("r(SC)", same_cols)
	
}
					/* Check nr 3 */
/* ================================================================== */

end


