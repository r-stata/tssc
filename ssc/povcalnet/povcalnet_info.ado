*********************************************************************************
* povcalnet_info                                                          		*
*********************************************************************************


program def povcalnet_info, rclass

version 11.0

    syntax    [,         ///
      COUntry(string)    ///
      REGion             ///
      AGGregate          ///
      clear              ///
			justdata           /// programmers option
			pause              /// debuggin
			server(string)     ///
			] 

if ("`pause'" == "pause") pause on
else                      pause off

qui {
	
	if ("``clear''" == "") preserve
	
	
	*---------- API defaults
	
	if "`server'"==""  {
		local server   = "http://iresearch.worldbank.org"
	}
	
	local site_name = "PovcalNet"
	local url = "`server'/`site_name'"
	
	return local server    = "`server'"
	return local site_name = "`site_name'"
	return local url       = "`url'"
	
	***************************************************
	* 1. Load guidance database
	***************************************************
	
	tempfile temp1000
	local jsfile  = "`url'/js/initCItem2014.js"
	return local jsfile = "`jsfile'"
	
	cap copy "`jsfile'" `temp1000'
	local rccopy = _rc
	cap import delim using `temp1000',  delim(",()") stringc(_all) /* 
	 */                                stripq(yes) varnames(nonames)  clear
	local rcclear = _rc
	
	
	/*==================================================
           Data wragling 
	==================================================*/
	
	if (`rccopy' == 0 & `rcclear' == 0) {
		* Drop unnecessary variables
		drop v1
		missings dropobs, force
		missings dropvars, force
		
		*rename variables 
		/* rename (v3 v4 v5 v6 v10 v12 v13) (wb_region un_region income_region country_name ppp pppimp year) */
		
		local vars1 v2 v3 v4 v5 v6 v10 v12 v13
		local vars2 code wb_region un_region income_region country_name ppp pppimp year
		
		local i = 0
		foreach var of local vars1 {
			local ++i
			rename `var' `: word `i' of `vars2''
		}
		
		
		gen country_code   = substr(code,1,3)
		gen coverage_code  = substr(code,-1,1)
		
		gen coverage_level = ""
		replace coverage_level = "national" if inlist(v7, "N", "A")
		replace coverage_level = "urban"    if        v7 == "U"
		replace coverage_level = "rural"    if        v7 == "R"
		
		gen coverage_type = ""
		replace coverage_type = "national" if v7 == "N"
		replace coverage_type = "urban"    if v7 == "U"
		replace coverage_type = "rural"    if v7 == "R"
		replace coverage_type = "national aggregate" if v7 == "A"
		
		drop v*  // drop unneeded variables 
		order country_code country_name wb_region un_region income_region coverage_level coverage_type coverage_code year
	}
	
	
	/*==================================================
           Manage errors
	==================================================*/
	
	*---------- If didn't copy
	if (`rccopy' != 0) { //Use cache if error
		cap: findfile _initCItem2014.dta
		local file `"`r(fn)'"'
		local wd : environment HOME
		if strpos(`"`file'"', "~") == 1 & !missing(`"`wd'"') {
			local file : subinstr local file"~" "`wd'"
        }
		cap: use `"`file'"', `clear'
		noi di  as result "Guidance file couldn't be updated, using local one."
		noi di  as result "Last version saved: `_dta[note1]'"
	}
	
	*---------- If clear was not declared
	if (`rcclear' != 0) {
		noi di as err "You must start with an empty dataset; or enable the clear option."
		error `rcclear'
	}
	
	
	if ("`justdata'" != "") exit
	
	***************************************************
	* 2. Inital listing with countries and regions
	***************************************************
	
	if  ("`country'" == "") & ("`region'" == "") {
		qui{
			noi disp in y  _n "{title:Available Surveys}: " in g "Select a country or region" 
			noi disp in y  _n "{title: Countries}"  
			
			quietly levelsof country_code , local(countries) 
			local current_line = 0
			foreach cccc of local countries{
				local current_line = `current_line' + 1 
				local display_this = "{stata povcalnet_info, country(`cccc') clear: `cccc'} "
				if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
				else{
					noi display in y `"`display_this'"' 
					local current_line = 0
				}
			}
			
			noi disp in y  _n(2) "{title: Regions}"
			quietly levelsof wb_region, local(regions)
			
			foreach i_reg of local regions{
				local current_line = 0
				local dipsthis "{stata  povcalnet, region(`i_reg') year(all) aggregate clear:`i_reg' }"
				noi disp " `dipsthis' " _c
			}
			
			noi display in y _n "{stata povcalnet_info, region clear: World Bank regions by year}"		
			noi display _n ""
			exit
		}
	}

	***************************************************
	* 3. Listing of country surveys
	***************************************************
	
	if  ("`country'" != "") & ("`region'" == "") {
		qui{
			noi disp in y  _n "{title:Available Surveys for `country'}" 	
			preserve
			local country = upper("`country'")
			keep if country_code == "`country'"

			local link_detail = "`url'/Docs/CountryDocs/`country'.htm"
			noi display `"{browse "`link_detail'" : Detailed information (browser)}"'
			
			local nobs = _N
			local current_line = 0
			local index_s = 1
			
			foreach n of numlist 1/`nobs' {
			
				noi disp in y  _n "`=country_name[`index_s']'-`=coverage_level[`index_s']'" 	
				noi disp in y  "year (survey year)" 	
				local years_current = "`=year[`index_s']'"
				local coverage = "`=coverage_level[`index_s']'"
				local years_current: subinstr local years_current "," " ", all 
				local index_s = `index_s'+ 1 
				
				foreach ind_y of local years_current {
					local current_line = `current_line' + 1 
					local ind_y_c=substr("`ind_y'",1,4)
					local display_this = "{stata  povcalnet, country(`country') year(`ind_y') coverage(`coverage')   clear: `ind_y_c'(`ind_y')}"		
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					else{
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
				}	
				
				noi display `"{stata  povcalnet, country(`country') year(all) coverage(`coverage')  clear: All}"'
			}
			restore
			noi display _n ""
			exit
			break
		}
	}	
	
	***************************************************
	* 4. Listing of regions
	***************************************************
	if  ("`country'" == "") & ("`region'" != "") {
		qui{
			noi disp in y  _n "{title:Available Surveys}" 
			noi disp in y  _n "{title:Select a Year}" 	
	
			quietly levelsof wb_region, local(regions)
			
			foreach i_reg of local regions{
				local current_line = 0
				noi disp in y  _n "`i_reg'" 
				local years_current = "$refyears"
				foreach ind_y of local years_current {
					local current_line = `current_line' + 1 
					local display_this = "{stata  povcalnet, region(`i_reg') year(`ind_y') aggregate clear: `ind_y'}"		
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					else{
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
				}
				noi display in y "{stata  povcalnet, region(`i_reg') year(all) aggregate clear: All}"				
			}
			noi display _n ""
			exit
			break
		}
	}
}
		
end	
