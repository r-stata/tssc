*! version 2.1.7 29sep2014  Richard Williams, rwilliam@nd.edu
 
* This is a rewrite of Vincent Kang Fu's goll.ado program
* and is called by gologit29 written by Richard Williams
* Technical details can be found at the bottom of this file.

program gologit29_ll
	version 8.2
	gettoken lnf xbeta: 0
	foreach xb in `xbeta' {
		local j = `j' + 1
		local xb`j' `xb'
	}
	local Numeqs = `j'
	local M = `j' + 1
	
	// M = # of categories in DV 
	// Numeqs = Number of equations = number of categories - 1
	
	// The global variables $dv_ contain the values for the 1rst, 2nd, 3rd
	// etc. values of Y.  e.g. if Y is coded -3, 0, 3, then
	// $dv_1 = -3, $dv_2 = 0, $dv_3 = 3.
	// These should be set by the calling program.
	// If not already set, default Y coding is 1, 2, 3,...
	
	forval j = 1/`M' {
		if "${dv_`j'}"=="" {
			local dv_`j' `j'
		}
		else local dv_`j' ${dv_`j'}
	}
	
	// logit is the default link if none has been specified.  
	// This could be changed if someone preferred a different
	// default. But you would probably make the change in the
	// calling program.
	local link $Link
	if "`link'"=="" local link "logit"

	
	if "`link'"=="logit" {
	
	// This coding is for link logit, and is the default if
	// link is not specified.  We can use symmetry with this link.
	//
	// cdf is pr(y <= j) = F(XBj) = 1 - exp(XBj)/(1 + exp(XBj))
	//	= 1 - invlogit(XBj) = invlogit(-XBj)
	
		// First (lowest) value of Y	
		quietly replace `lnf' =  ln( invlogit(-`xb1')) if $ML_y1 == `dv_1'

		// Middle values of Y
		forval j = 2/`Numeqs'	{
			local i = `j' - 1
			quietly replace `lnf' =  ln( invlogit(-`xb`j'') - invlogit(-`xb`i'') ) ///
				if $ML_y1 == `dv_`j''
		}
	
		// Last (highest) value of Y.  Symmetry is used here.
		quietly replace `lnf' =  ln(invlogit(`xb`Numeqs'')) if $ML_y1 == `dv_`M''
	}

	else if "`link'"=="probit" {
	
	// This coding is for link probit.  Global var
	// $Link must equal "probit" in order to use this.
	// We can use symmetry with this link.
	//
	// cdf is pr(y <= j) = F(XBj) = 1 - norm(XBj) = norm(-XBj) 
	// where norm is the cumulative standard normal distribution

	
		// First (lowest) value of Y
		quietly replace `lnf' =  ln(norm(-`xb1')) if $ML_y1 == `dv_1'
	
	
		// Middle values of Y
		forval j = 2/`Numeqs'   {
			local i = `j' - 1
			quietly replace `lnf' = ln( norm(-`xb`j'') - norm(-`xb`i'') ) ///
				if $ML_y1 == `dv_`j''
		}
	
		// Last (highest) value of Y.  Symmetry is used here.
		quietly replace `lnf' =  ln( norm(`xb`Numeqs'') ) if $ML_y1 == `dv_`M''
	}
	
	else if "`link'"=="cloglog" {
	
	// This coding is for link cloglog.  Global var
	// $Link must equal "cloglog" in order to use this.
	// We cannot use symmetry with this link.
	// SPSS PLUM calls this nloglog.
	//
	// cdf is pr(y <= j) = F(XBj) = exp(-exp(XBj) = 1 - invcloglog(XBj) 
	// which is the inverse of the negative log-log function.

		// First (lowest) value of Y
		quietly replace `lnf' =  ln(exp(-exp(`xb1'))) if $ML_y1 == `dv_1'
	
	
		// Middle values of Y.  
		forval j = 2/`Numeqs'   {
			local i = `j' - 1
			quietly replace `lnf' = ln(exp(-exp(`xb`j'')) - exp(-exp(`xb`i''))) ///
				if $ML_y1 == `dv_`j''
		}
	
		// Last (highest) value of Y.  
		quietly replace `lnf' =  ln(1 - exp(-exp(`xb`Numeqs''))) if $ML_y1 == `dv_`M''

	}
	
	else if "`link'"=="loglog" {
	
	// This coding is for link loglog.  Global var
	// $Link must equal "loglog" in order to use this.
	// We cannot use symmetry with this link.
	// SPSS PLUM calls this cloglog.
	//
	// cdf is pr(y <= j) = F(XBj) = 1 - exp(-exp(-XBj) = invcloglog(-XBj) 
	// where invcloglog is the inverse of the complementary
	// log-log function

	
		// First (lowest) value of Y
		quietly replace `lnf' =  ln(1-exp(-exp(-`xb1'))) if $ML_y1 == `dv_1'
	
	
		// Middle values of Y
		forval j = 2/`Numeqs'   {
			local i = `j' - 1
			quietly replace `lnf' = ln( 1-exp(-exp(-`xb`j'')) - (1-exp(-exp(-`xb`i'')))) ///
				if $ML_y1 == `dv_`j''
		}
	

		// Last (highest) value of Y. Can't use symmetry with this link 
		quietly replace `lnf' =  ln(exp(-exp(-`xb`Numeqs''))) if $ML_y1 == `dv_`M''
	}
	
	else if "`link'" == "cauchit" {
	
	// This coding is for link cauchit (inverse Cauchy).  Global var
	// $Link must equal "cauchit" in order to use this.
	// We cannot use symmetry with this link.
	//
	// cdf is pr(y <= j) = F(XBj) = .5 + (1/_pi) * atan(-XBj) 


		// First (lowest) value of Y
		quietly replace `lnf' =  ln( .5 + (1/_pi) * atan(-`xb1')) if $ML_y1 == `dv_1'

		// Middle values of Y
		forval j = 2/`Numeqs'	{
			local i = `j' - 1
			quietly replace `lnf' =  ln( (.5 + (1/_pi) * atan(-`xb`j'')) - (.5 + (1/_pi) * atan(-`xb`i''))) ///
				if $ML_y1 == `dv_`j''
		}
	
		// Last (highest) value of Y.  Symmetry is not used here.
		local xbj ((`xb' - `kappa`Numeqs'')/`sigma')
		quietly replace `lnf' =  ln(1 - (.5 + (1/_pi) * atan(-`xb`Numeqs''))) if $ML_y1 == `dv_`M''
	}
	

end

/*  Technical details of formulas used in this routine

See the Stata Manual formulas for ologit & oprobit.  These are on p.
346 of the Stata 9 Reference Manual K-Q.  Links besides logit & probit
are derived from SPSS documentation on the algorithms for PLUM.You
add subscripts to the Betas since they are not invariant across values
of j. Also intercepts = the negative of the cutpoints in
ologit/oprobit/PLUM and are treated as beta parameters.

Stata & SPSS use different names for some links.  What SPSS calls
cloglog, Stata calls loglog.  What SPSS calls nloglog, Stata calls
cloglog.  I follow Stata's naming conventions.

Let i = j - 1.  Then

	F(XBj) = cumulative distribution function = pr(y <= j)
	pr(y = j) = F(XBj) - F(XBi)

Note that when j = 1,

	F(XB0) = pr(y <= 0) = 0 so pr(y = 1) = F(XB1)

Note that when j = M (the highest categoy of Y)

	F(XBj) = pr(y <= M) = 1 so pr(y = M) = 1 - F(XBi)
	= F(-XBi) (when link fnc is symmetric; it isn't always.)

The invlogit, norm and invcloglog functions are used in this
routine.  Each is used to convert a linear prediction into the
corresponding probability.  Here are the formulas/definitions for
these, as noted in the Stata 8.2 help:

invlogit(x) returns the inverse of the logit function of x.
invlogit(x) = exp(x)/(1 + exp(x)).

norm(z) returns the cumulative standard normal distribution.

invcloglog(x) returns the inverse of the complementary log-log
function of x.  invcloglog(x) = 1 - exp(-exp(x)).

I used the invcloglog function in earlier versions of this routine.
However, for whatever reason, I found that the program worked better
if I used the equivalent 1 - exp(-exp(x)) coding instead.

*/

