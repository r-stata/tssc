* ************************************************************************************* *
*                                                                                       *
*   goprobit_ll                                                                         *
*   Version 1.1 - last revised September 05, 2006                                       *
*                                                                                       *
*   Author: Stefan Boes, boes@sts.unizh.ch                                              *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*                                                                                       *
*   goprobit is a user-written procedure to estimate generalized ordered probit models  *
*   in Stata. It is a rewritten version of Vincent Fu's and Richard Williams' gologit   *
*   routines that assumes normally instead of logistically distributed error terms.     *
*   The current version of Richard Williams' gologit2 allows to estimate the            *
*   generalized ordered probit model using the link(probit) option and therefore        *
*   produces results equivalent to goprobit.                                            *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*   This is the subroutine providing the log-likelihood function.                       *
*                                                                                       *
* ************************************************************************************* *



program define goprobit_ll
	version 8
	gettoken lnf xbeta: 0
	foreach xb in `xbeta' {
		local i = `i' + 1
		local xb`i' `xb'
	}
	local Numeqs = `i'
	local J = `i' + 1

	* J = # of categories in DV *************************************************** *
	* Numeqs = Number of equations = number of categories - 1

	* The global variables $dv_ contain the values for the 1rst, 2nd, 3rd
	* etc. values of Y.  e.g. if Y is coded -3, 0, 3, then
	* $dv_1 = -3, $dv_2 = 0, $dv_3 = 3.
	* These should be set by the calling program.

	* First (lowest) value of Y *************************************************** *
	quietly replace `lnf' =  ln(norm(-`xb1')) if $ML_y1 == $dv_1

	* Middle values of Y ********************************************************** *
	forval i = 2/`Numeqs'	{
		local j = `i' - 1
		quietly replace `lnf' = ///
			ln( norm(-`xb`i'') - norm(-`xb`j'') ) if $ML_y1 == ${dv_`i'}
	}

	* Last (highest) value of Y *************************************************** *
	quietly replace `lnf' =  ln( 1 - norm(-`xb`Numeqs'') ) if $ML_y1 == ${dv_`J'}

end
