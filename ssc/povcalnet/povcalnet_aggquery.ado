*********************************************************************************
* povcalnet_aggquery                                                            *
*! v1.0  		sept2018               by 	Jorge Soler Lopez					*
*											Espen Beer Prydz					*
*											Christoph Lakner					*
*											Ruoxuan Wu							*
*											Qinghua Zhao						*
*											World Bank Group					*
*********************************************************************************

program def povcalnet_aggquery, rclass

version 11.0

    syntax                    ///
      [,                      ///
				COUntry(string)       ///
				REGion(string)        ///
				YEAR(string)          ///
				POVLine(string)       ///
				CLEAR                 ///
				NOSUMmary             ///
				PPP(string)           ///
				fillgaps      ///
				SERVER(string)        ///
				coverage(string)      /// just for compatibility witn povcalnt_query
				pause                 /// for debugging
      ]     

if ("`pause'" == "pause") pause on
else                      pause off
			
quietly {
	***************************************************
	* 0. Housekeeping
	***************************************************

	local base="http://iresearch.worldbank.org/PovcalNet/PovcalNetAPI.ashx"

	if "`server'"!=""  {
		local base="`server'/PovcalNetAPI.ashx"
	} 
    
	if  ("`country'" == "") & ("`region'" == ""){
    di  as err "Either provide country(ies) or region(s), or all. Please try again."
    exit 198
  }
	
	*---------- Make sure at least one ference year is selected
	local ref_years 1981 1984 1987 1990 1993 1996 1999 2002 2005 2008 2010 2011 2012 2013 2015
	
	local ref_years_l: subinstr local ref_years " " ",", all
	
	local no_ref: list year - ref_years
	
	if (`: list no_ref === year') {
		noi disp as err "Not even one of the years select belong to reference years: `ref_years_l'"
		error
	}
	
	if ("`no_ref'" != "") {
		noi disp in y "Warning: `no_ref' is/are not part of reference years: `ref_years_l'"
	}
	
	
	***************************************************
	* 1. Will load guidance database
	***************************************************
	
	povcalnet_info, clear justdata `pause'
	
	***************************************************
	* 2. Keep selected countries and save codes
	***************************************************
	
	if ("`country'" != "") {
		gen keep_this = 0
		local country_l = `""`country'""'
		local country_l: subinstr local country_l " " `"", ""', all

		replace keep_this = 1 if inlist(country_code, `country_l')
		if lower("`country'") == "all" replace keep_this = 1
		
		keep if keep_this == 1
		
		local obs = _N
		if (`obs' == 0) {
			di  as err "No surveys found matching your criteria." _n /* 
		 */	"Type {stata povcalnet_info} to ckeck availability."
			error
		}
		levelsof code, local(country_f) sep(,) clean
	}
	
	***************************************************
	* 3. Request and copying
	***************************************************
	
	*---------- Query of years
	local y_comma: subinstr local year " " ",", all
	if ("`year'" == "last") local y_comma = "all"
	local year_q = "YearSelected=`y_comma'"
	
	*---------- Query of countries or Region
	if ("`country'" != "") {
		local country_q = "Countries=`country_f'&GroupedBy=Customized"
	}
	else {  // ("`region'" != "")
		local country_q = "Countries=all&GroupedBy=WB"
	}
	
	*---------- Query poverty line
	local povline_q = "PovertyLine=`povline'"
	
	*---------- Full Query
	local query = "`year_q'&`country_q'&`povline_q'&format=csv"
	return local query  "`query'"
	
	***************************************************
	* 4. Request and copying
	***************************************************
	
	*---------- download data
	tempfile clfile
	local queryfull "`base'?`query'"
	return local queryfull = "`queryfull'"
	
	local rc = 0

	cap copy "`queryfull'" `clfile'
	if (_rc == 0) {
		cap insheet using `clfile', clear name
		if (_rc != 0) local rc "in"
	} 
	else {
		local rc "copy"
	} 
	pause aggquery - after loading data 

	*---------- Clean data
	
	povcalnet_clean 2, year("`year'") `iso' rc(`rc') region(`region') `pause'
	
	
	order region_title region_code request_year poverty_line mean /* 
	 */ headcount poverty_gap poverty_gap_sq population
	
	sort region_title region_code request_year
	return local queryfull  "`queryfull'"
}

end

	
