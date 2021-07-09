*! erate: Importing world exchange rates
*! Version 1.4.0: 2013/02/22
*! Authors: Damian C. Clarke & Pavel Luengas Sierra  
*! Department of Economics
*! The University of Oxford
*! damian.clarke@economics.ox.ac.uk & pavel.luengas-sierra@economics.ox.ac.uk

capture program drop erate
program define erate, rclass
	vers 10.0
	set more off
	****************************************************************************
	*** SYNTAX
	****************************************************************************
	#delimit ;
	syntax anything(id="Exchange rates" name=rates)
	[, 
	Quantity(numlist max=1)
	vars
	]
	;
	#delimit cr

	****************************************************************************
	*** GET EXCHANGE RATES FROM USER COMMAND
	****************************************************************************
	tempname exchange_data currency1 currency2
	tempvar c1 c2
	tokenize `rates'
	local `currency1' "`1'"
	local `currency2' "`2'"
	if length("`quantity'")!=0 local qty `quantity'
	else if length("`quantity'")==0 local qty 1

	****************************************************************************
	*** ERROR CHECKING
	****************************************************************************	
	/* - Error Check - Country list- */
	local countrylist AED ANG ARS AUD BGN BHD BND BOB BRL BWP CAD CHF CLP CNY COP CRC CZK DKK DOP DZD EGP EUR FJD GBP HKD HNL HRK HUF IDR ILS INR JMD JOD JPY KES KRW KWD KYD KZT LBP LKR LTL LVL MAD MDL MKD MUR MXN MYR NAD NGN NIO NOK NPR NZD OMR PEN PGK PHP PKR PLN PYG QAR RON RSD RUB SAR SCR SEK SGD SLL SVC THB TND TRY TTD TWD TZS UAH UGX USD UYU UZS VEF VND YER ZAR
	local cn1 = upper("`1'") 
	local cn2 = upper("`2'")
	local cn3 = upper("`3'") 

	/* 1 Only one or more than two countries are specified  */		
	if length("`cn2'")==0  | length("`cn3'")!=0 {
		di as error "Submit two countries"
		exit 111
	}
	/* 2 Country not on list of countries - */
	forvalues no=1/2 {	
		local cty_error`no' = 1
		foreach elem of local countrylist {
			if  "`elem'" == "`cn`no''" {
				local cty_error`no' = 0
				}
			}
		if `cty_error`no'' ==   1 {
			di as error "Country " as input "`cn`no''" as error " is not a valid country. Refer to the {help erate##options:list} of available countries."
		}
	}
	// End program 
	local cty_error = `cty_error1' + `cty_error2'
	if `cty_error'  !=   0 {
		exit 111
	}
	
	****************************************************************************
	*** IMPORT EXCHANGE RATE DATA
	****************************************************************************
	tempfile exchange

	capture copy "http://www.google.com/ig/calculator?hl=en&q=``currency1''=?``currency2''" `exchange', replace
	/* - Error Check - Access to internet and to Google site - */
	if _rc==0 {
	file open `exchange_data' using `exchange', read
	file read `exchange_data' line
	}
	else {
	di as error "Could not access " as input "www.google.com/finance/converter/" as error " please check your internet connection and try again."
	exit 2
	}

	****************************************************************************
	*** EXTRACT EXCHANGE RATE DATA
	****************************************************************************
	if c(N)==0 qui set obs 1
	qui gen `c1'=regexs(0) if(regexm(`"`line'"', `"lhs: "[0-9]+\.*[0-9]*"'))
	qui replace `c1'=regexs(0) if(regexm(`c1', "[0-9]+\.*[0-9]*"))
	qui gen `c2'=regexs(0) if(regexm(`"`line'"', `"rhs: "[0-9]+\.*[0-9]*"'))
	qui replace `c2'=regexs(0) if(regexm(`c2', "[0-9]+\.*[0-9]*"))
	qui destring `c1', replace
	qui destring `c2', replace

	qui mkmat `c1' `c2' in 1, mat(currmat)
	qui return scalar `1'=currmat[1,1]*`qty'
	qui return scalar `2'=currmat[1,2]*`qty'

	/* - Error Check - Google does not have the exchange rate - */
	if `c1'==. | `c2'==. {
		di as error "Exchange rate not available."
		exit 111
	}

	****************************************************************************
	*** DISPLAY AND/OR STORE OUTPUT
	****************************************************************************
	*first 6 lines make new variables equal to currency if user specifies "vars"
	if length("`vars'") != 0 {
		cap drop _rate`1'
		cap drop _rate`2'	
		gen double _rate`1'=`c1'*`qty'
		gen double _rate`2'=`c2'*`qty'
	}

	*program output
	dis in green "{hline 60}"
	dis `"`1'"' " and " `"`2'"' " exchange rate. Rates stored as r(`1'), r(`2')"  
	dis in green "{hline 60}"
	dis "{tab}" "`1':" in yellow "{tab}" `c1'*`qty'
	dis "{tab}" in green "`2':" in yellow "{tab}" `c2'*`qty'
	dis in green "{hline 60}"
	dis "consulted on " c(current_date) " at " c(current_time)
	dis in smcl "See " `"{browse "www.google.com/finance/converter"}"'
	
end
