// This ado file uses -wbopendata- (Azevedo 2014) to extract
//  the WDI numbers needed to check the ones used by country teams.
** Sean Higgins, created 22nov2015
*! v1.0 22nov2015

capture program drop ceqppp
program define ceqppp
	syntax , Country(string) Baseyear(real) Surveyyear(real) [Locals]
	
	version 9.0 // earliest compatibility of wbopendata
	local dit noisily display in smcl as text
	local dire noisily display in smcl as result
	local die noisily display in smcl as error
	
	** Install -wbopendata- if not already installed
	cap which wbopendata
	if _rc ssc install wbopendata
	
	** Parse options
	if `baseyear'!=2005 & `baseyear'!=2011 {
		`die' "{bf:baseyear()} must be 2005 or 2011"
	}
	if `baseyear'==2005 local ext ".05"
	else local ext ""
	
	cap preserve
	clear                         
	quietly {
		wbopendata, country("`country'") indicator("PA.NUS.PRVT.PP`ext'") year(`baseyear') nometadata clear
		local ppp : di yr`baseyear'
		wbopendata, country(`country') indicator(FP.CPI.TOTL) year(`surveyyear') nometadata clear
		local cpi`surveyyear' : di yr`surveyyear' 
		wbopendata, country(`country') indicator(FP.CPI.TOTL) year(`baseyear') nometadata clear
		local cpi`baseyear' : di yr`baseyear'
	}

	// Display results:
	`dit' "RESULTS FOR PPP CONVERSION"
	`dit' "Country: `country'"
	`dit' "Base year: `baseyear'"
	`dit' "Survey year: `surveyyear'"
	`dit' ""
	`dit' "PPP Conversion Factor (From Base Year LCU to Base Year PPP)"
	`dit' "(compare to cell I3)"
	if `ppp'!=. `dire' `ppp'
	else `dire' "Not available from WDI"
	`dit' "CPI (Base Year)"
	`dit' "(compare to cell M3)"
	if `cpi`baseyear''!=. `dire' `cpi`baseyear''
	else `dire' "Not available from WDI"
	`dit' "CPI (Year of Survey)"
	`dit' "(compare to cell O3)"
	if `cpi`surveyyear''!=. `dire' `cpi`surveyyear''
	else `dire' "Not available from WDI"
	`dit' "PPP Conversion Factor (from LCU in Year of Survey to Base Year PPP)"
	`dit' "(compare to cell Q3)"
	if `ppp'*(`cpi`surveyyear''/`cpi`baseyear'')!=. `dire' `ppp'*(`cpi`surveyyear''/`cpi`baseyear'')
	else `dire' "Not computed; some components not available from WDI"
	
	// Store locals to feed into ceq commands
	if "`locals'"!="" {
		c_local ppp `ppp'
		c_local cpibase `cpi`baseyear''
		c_local cpisurvey `cpi`surveyyear''
		`dit' ""
		`dit' "Results saved in the following locals: \`ppp', \`cpibase', \`cpisurvey'"
	}
	
	restore
end
