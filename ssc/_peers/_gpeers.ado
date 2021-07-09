/************************************
 *                                  *
 * Peers: an extension to egen      *
 *                                  *
 ************************************/
 
/*
 *
 * Syntax: egen NEWVAR = peers(INDIVIDUALVAR), by(UNIT)
 *
 * NEWVAR will contain the average of INDIVIDUALVAR in UNIT,
 * excluding the current observation
 *
 */
 
/*
 *
 * Missing values: missing values are ignored, that is
 * 	everything is computed assuming missing values
 *	'don't' exist. The number of missing values in
 *      NEWVAR will be the number of missing values in
 *	INDIVIDUALVAR + the number of UNITs with only
 *	one observation
 *
 */
 

cap program drop _gpeers

program define _gpeers,  sortpreserve

	version 9.1 /* May work with older versions, but I haven't tested */

	gettoken type 0 : 0    /* Type of the generated variable. Double is recommended */
	gettoken h    0 : 0    /* The name of the new variable */
	gettoken eqs  0 : 0	/* Not used */
	
	syntax varlist(min=1 max=1) [if] [in], by(varname) [label(string)]
	
	/* Check whether varname is numeric */
	confirm numeric variable `varlist'
	marksample touse, novarlist strok
	
	/* Temporary variable that will hold the number of elements in each unit */
	tempvar t
	quietly egen `t' = count(`varlist') if `touse', by(`by')
	quietly egen `type' `h' = mean(`varlist')  if `touse', by(`by')
	quietly replace `h' = (`t' * `h' - `varlist' ) / ( `t'-1 )  if `touse'
	/* h will contain a missing value if there is only one individual in the unit */
	if ("`label'" == "") {
		label variable `h' "Average `varlist' among peers in unit defined by `by'"	
	}
	else	
	{
		label variable `h' "`label'"
	}
		
end
