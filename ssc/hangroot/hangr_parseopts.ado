*! version 1.5.0 09Aug2011 MLB
program define hangr_parseopts
    syntax  [varname(default=none)] ///
	[if] [in] [fweight /] [,        ///
	SUSPended                       ///	suspended rootogram
	noTHEORetical                   /// suppress display of theoretical distribution
	CIOpt(string)                   /// options for the confidence intervals
	THEOROpt(string)                /// options for the theoretical distribution
    DIST(string)                    ///
    ci                              ///
    par(numlist)                    /// overwrite parameters
	BY(string)                      /// not allowed
	HORizontal                      /// not allowed
	VERTical                        /// not allowed
	SPike                           /// default 
	BAR                             /// 
	withx(integer 0)                /// previous estimation command contained explanatory variables
	ninter(numlist max=1 >= 0 <=20 integer) /// number of points between bin mids
	]
	
	if "`varlist'" == "" & "`weight'" != "" {
		di as err "weights may not be specified in the post-estimation syntax"
		di as err "the weights will be copied from the last estimation command"
		exit 198
	}
	if "`varlist'" == "" & "`if'`in'" != "" {
		di as err "the if and in qualifiers may not be specified in the post-estimation syntax"
		di as err "these will be copied from the last estimation command"
		exit 198
	}

	if "`suspended'" == "" & "`theoretical'" != "" {
		di as error "the notheoretical option can only be specified when the suspended option is specified"
		exit 198
	}
	
	if "`theoretical'" != "" & `"`theoropt'"' != "" {
		di as error "the theoropt() option can not be specified together with the notheoretical option"
		exit 198
  	}
	
	if "`ci'" == "" & `"`ciopt'"' != ""  {
		di as error "the ciopt() option can only be specified together with the ci option"
		exit 198
	}
	
	// check number of parameters specified in par() option
	local kpar : word count `par'
	if inlist("`dist'", "poisson", "exponential", "geometric", "chi2") & !(`kpar' == 0 | `kpar' == 1) {
		di as error "`kpar' parameters where specified in the par() option while the `dist' distribution contains 1 parameter"
		exit 198
	}
	if (inlist("`dist'", "normal", "beta", "pareto", "laplace", "uniform", ///
	                     "lognormal", "weibull", "gumbel", "invgamma") | ///
	   inlist("`dist'", "wald", "fisk", "gamma", "logistic", "nb1", "nb2", "zip")) & !(`kpar' == 0 | `kpar' == 2 ) {
	   	di as error "`kpar' parameters where specified in the par() option while the `dist' distribution contains 2 parameter"
	   	exit 198
	}
	if inlist("`dist'", "dagum", "sm", "gev", "zinb", "oib", "zib") & !(`kpar' == 0 | `kpar' == 3) {
		di as error "`kpar' parameters where specified in the par() option while the `dist' distribution contains 3 parameter"
		exit 198
	}
	if inlist("`dist'", "gb2", "zoib") & !(`kpar' == 0 | `kpar' == 4) {
		di as error "`kpar' parameters where specified in the par() option while the `dist' distribution contains 4 parameter"
		exit 198
	}

	//poisson, geometric, negative binomial, zip, zinb implies discrete
	if "`dist'" == "poisson"    | ///
	   "`dist'" == "geometric"  | ///
	   "`dist'" == "nb1"        | ///
	   "`dist'" == "nb2"        | ///
	   "`dist'" == "zip"        | ///
	   "`dist'" == "zinb"       {
		c_local discrete "discrete"
	}
	
	// remove options that may not be passed on to -twoway rspike- or -twoway rbar-
	if `"`by'"' != "" {
		local err "by() "
	}
	if "`horizontal'" != "" {
		local err "`err'horizontal "
	}
	if "`vertical'" != "" {
		local err "`err'vertical "
	}
	if "`err'" != "" {
		local s = cond(`: word count `err''>1,"s","")
		di as err "option`s' `err'not allowed"
		exit 198
	}
	
	// default graph type is spike
	if "`spike'`bar'" == "" {
		c_local spike "spike"
	}
	
	if "`spike'" != "" & "`bar'" != "" {
		di as err "options spike and bar may not be combined"
		exit 198
	}
	
	// number of points between bin mids
	if !`withx' & "`ninter'" != "" {
		di as err "the ninter() option can only be specified when the previous estimation command contained explanatory variables"
		exit 198
	}
	if `withx' & "`ninter'" == "" {
		c_local ninter = 5
	}
	
end
