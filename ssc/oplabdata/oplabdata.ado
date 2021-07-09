*===============================================================================
* Program: oplabdata.ado
* Purpose: Explore and load datasets from equality-of-opportunity.org
* Version: 1.1, 2017/10/18 by MD
*===============================================================================

program define oplabdata

version 12.1
               
syntax, [paper(string asis) table(integer 0) nologo clear]


* Display logo unless otherwise specified
if "`nologo'"=="" oplabdata_helper_logo 

set more off

*-------------------------------------------------------------------------------
* Set up local directory for storing datasets
*-------------------------------------------------------------------------------

* Define local directory to store dats
local oplabdata_local `c(sysdir_personal)'chettydata

* If local directory doesn't exist, create it
confirmdir "`oplabdata_local'"
local local_dir_exists = r(confirmdir)
if `local_dir_exists'==1 {
	mkdir "`c(sysdir_personal)'chettydata"
}

*-------------------------------------------------------------------------------
* Exception handling
*-------------------------------------------------------------------------------

* Check to see if paper() valid
if ~inlist("`paper'", "", "mrc", "absmob", "neighborhoods", "gendergaps", "mortality", "ige_trends", "ige") {
	di as error "Error: invalid paper() option specified. For usage and valid options, type oplabdata."
	exit
}

*-------------------------------------------------------------------------------
* Table handling: College MRC
*-------------------------------------------------------------------------------

if "`paper'"=="mrc" {
	
	if `table'==0 {
		di as text "{bf:Mobility Report Cards: The Role of Colleges in Intergenerational Mobility}"
		di " "
		di "  • {ul:Online Data Table 1}  - {stata oplabdata, paper(mrc) table(1)}"
		di "    - Preferred Estimates of Access and Mobility Rates by College"
		di "  • {ul:Online Data Table 2}  - {stata oplabdata, paper(mrc) table(2)}"
		di "    - Baseline Cross-Sectional Estimates by College"
		di "  • {ul:Online Data Table 3}  - {stata oplabdata, paper(mrc) table(3)}"
		di "    - Baseline Longitudinal Estimates by College and Child's Cohort"
		di "  • {ul:Online Data Table 4}  - {stata oplabdata, paper(mrc) table(4)}"
		di "    - Cross-Sectional Estimates by College: Heterogeneity by Gender & Alt. College / Income Definitions"
		di "  • {ul:Online Data Table 5}  - {stata oplabdata, paper(mrc) table(5)}"
		di "    - Longitudinal Estimates by College and Cohort: Heterogeneity by Gender & Alt. College / Income Definitions"
		di "  • {ul:Online Data Table 6}  - {stata oplabdata, paper(mrc) table(6)}"
		di "    - Cross-Sectional Statistics by College Tier and Parent Income Percentile"
		di "  • {ul:Online Data Table 7}  - {stata oplabdata, paper(mrc) table(7)}"
		di "    - Cross-Sectional Statistics on Children’s Income Distributions by College Tier"
		di "  • {ul:Online Data Table 8}  - {stata oplabdata, paper(mrc) table(8)}"
		di "    - Longitudinal Statistics by College Tier, Parent Income Ventile, and Cohort"
		di "  • {ul:Online Data Table 9}  - {stata oplabdata, paper(mrc) table(9)}"
		di "    - Percentile Cutoffs for Parent and Child Income by Birth Cohort"
		di "  • {ul:Online Data Table 10} - {stata oplabdata, paper(mrc) table(10)}"
		di "    - College Level Characteristics"
		di "  • {ul:Online Data Table 11} - {stata oplabdata, paper(mrc) table(11)}"
		di "    - Crosswalk from College-Level OPEIDs to Super-OPEID Groups"
	}
	
	else if ~inrange(`table',1,11) {
		di as error "Error: table specified (`table') is invalid. Valid options for paper(mrc) are 1 to 11."
		di as error "Type {stata oplabdata, paper(mrc)} for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,11) {
		di as text "Loading Mobility Report Cards table `table'."
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/college/
			qui webuse mrc_table`table'.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/college/Codebook%20MRC%20Table%20`table'.pdf":here} for a readme."'
	}
}
 
*-------------------------------------------------------------------------------
* Table handling: Absolute Mobility
*-------------------------------------------------------------------------------

if "`paper'"=="absmob" {
	
	if `table'==0 {
		di as text "{bf:The Fading American Dream: Trends in Absolute Income Mobility Since 1940}"
		di " "
		di "  • {ul:Online Data Table 1} - {stata oplabdata, paper(absmob) table(1)}"
		di "    - Baseline Estimates of Absolute Mobility by Parent Income Percentile and Child Birth Cohort"
		di "  • {ul:Online Data Table 2} - {stata oplabdata, paper(absmob) table(2)}"
		di "    - Absolute Mobility by Child Birth Cohort and State"
		di "  • {ul:Online Data Table 3} - {stata oplabdata, paper(absmob) table(3)}"
		di "    - Absolute Mobility by Child Birth Cohort, Parent Income Percentile, and Gender"
		di "  • {ul:Online Data Table 4} - {stata oplabdata, paper(absmob) table(4)}"
		di "    - Alternative Estimates of Absolute Mobility by Birth Cohort"
		di "  • {ul:Online Data Table 5} - {stata oplabdata, paper(absmob) table(5)}"
		di "    - Counterfactuals by Parent Income Percentile"
		di "  • {ul:Online Data Table 6} - {stata oplabdata, paper(absmob) table(6)}"
		di "    - Levels of Child and Parent Income by Income Percentile and Child Birth Cohort"
		di "  • {ul:Online Data Table 7} - {stata oplabdata, paper(absmob) table(7)}"
		di "    - Rank Required to Beat Parent by Child Birth Cohort and Parent Income Percentile"
		di "  • {ul:Online Data Table 8} - {stata oplabdata, paper(absmob) table(8)}"
		di "    - Copula for 1980-1982 Cohorts"
	}
	
	else if ~inrange(`table',1,8) {
		di as error "Error: table specified (`table') is invalid. Valid options for paper(absmob) are 1 to 8."
		di as error "Type {stata oplabdata, paper(absmob)} for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,8) {
		di as text "Loading Absolute Mobility table `table'."
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/absolute/
			webuse table`table'.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/absolute/Online%20Table%20`table'%20Readme.pdf":here} for a readme."'
	}
}

*-------------------------------------------------------------------------------
* Table handling: Neighborhoods
*-------------------------------------------------------------------------------

if "`paper'"=="neighborhoods" {
	
	if `table'==0 {
		di as text "{bf:The Effects of Neighborhoods on Intergenerational Mobility}"
		di " "
		di "  • {ul:Online Data Table 1} - {stata oplabdata, paper(neighborhoods) table(1)}"
		di "    - Preferred Estimates of Causal Place Effects by Commuting Zone"
		di "  • {ul:Online Data Table 2} - {stata oplabdata, paper(neighborhoods) table(2)}"
		di "    - Preferred Estimates of Causal Place Effects by County"
		di "  • {ul:Online Data Table 3} - {stata oplabdata, paper(neighborhoods) table(3)}"
		di "    - Complete CZ-Level Dataset: Causal Effects and Covariates"
		di "  • {ul:Online Data Table 4} - {stata oplabdata, paper(neighborhoods) table(4)}"
		di "    - Complete County-Level Dataset: Causal Effects and Covariates"
		di "  • {ul:Online Data Table 5} - {stata oplabdata, paper(neighborhoods) table(5)}"
		di "    - Pairwise Place Effects by Origin-Destination Pairs of Commuting Zones"
		di "  • {ul:Online Data Table 6} - {stata oplabdata, paper(neighborhoods) table(6)}"
		di "    - Parent Income Distribution by Child's Birth Cohort"
	}
	
	else if ~inrange(`table',1,6) {
		di as error "Error: table specified (`table') is invalid. Valid options for paper(neighborhoods) are 1 to 6."
		di as error "Type {stata oplabdata, paper(neighborhoods)} for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,11) {
		di as text "Loading Neighborhoods table `table'."
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/neighborhoods/
			qui webuse online_table`table'.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/neighborhoods/online_table`table'.pdf":here} for a readme."'
	}
}

*-------------------------------------------------------------------------------
* Table handling: Gender Gaps
*-------------------------------------------------------------------------------

if "`paper'"=="gendergaps" {
	
	if `table'==0 {
		di as text "{bf:Childhood Environment and Gender Gaps in Adulthood}"
		di " "
		di "  • {ul:Online Data Table 1} - {stata oplabdata, paper(gendergaps) table(1)}"
		di "    - CZ-level Employment Rates by Gender and Parent Income Quintile and other CZ Covariates"
		di "  • {ul:Online Data Table 2} - {stata oplabdata, paper(gendergaps) table(2)}"
		di "    - County-level Employment Rates by Gender and Parent Income Quintile and other County Covariates"
		di "  • {ul:Online Data Table 3} - {stata oplabdata, paper(gendergaps) table(3)}"
		di "    - National Employment Rates, Earnings, and Other Outcomes by Parent Percentile and Gender"
	}
	
	else if ~inrange(`table',1,3) {
		di as error "Error: table specified (`table') is invalid. Valid options for paper(gendergaps) are 1 to 3."
		di as error "Type {stata oplabdata, paper(gendergaps)} for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,3) {
		di as text "Loading Gender Gaps table `table'."
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/gender/
			qui webuse table`table'.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/gender/table`table'_readme.pdf":here} for a readme."'
	}
}

*-------------------------------------------------------------------------------
* Table handling: Mortality
*-------------------------------------------------------------------------------

if "`paper'"=="mortality" {
	
	if `table'==0 {
		di as text "{bf:The Association Between Income and Life Expectancy in the United States, 2001-2014}"
		di " "
		di "  • {ul:Online Data Table 1} - {stata oplabdata, paper(mortality) table(1)}"
		di "    - National life expectancy estimates by gender-income percentile"
		di "  • {ul:Online Data Table 2} - {stata oplabdata, paper(mortality) table(2)}"
		di "    - National life expectancy estimates by year-gender-income percentile"
		di "  • {ul:Online Data Table 3} - {stata oplabdata, paper(mortality) table(3)}"
		di "    - Life expectancy estimates by state-gender-income percentile"
		di "  • {ul:Online Data Table 4} - {stata oplabdata, paper(mortality) table(4)}"
		di "    - Life expectancy estimates by state-gender-income quartile"
		di "  • {ul:Online Data Table 5} - {stata oplabdata, paper(mortality) table(5)}"
		di "    - Life expectancy estimates by state-year-gender-income quartile"
		di "  • {ul:Online Data Table 6} - {stata oplabdata, paper(mortality) table(6)}"
		di "    - Life expectancy estimates by CZ-gender-income quartile"
		di "  • {ul:Online Data Table 7} - {stata oplabdata, paper(mortality) table(7)}"
		di "    - Life expectancy estimates by CZ-gender-income ventile"
		di "  • {ul:Online Data Table 8} - {stata oplabdata, paper(mortality) table(8)}"
		di "    - Life expectancy trends estimates by CZ-gender-income quartile"
		di "  • {ul:Online Data Table 9} - {stata oplabdata, paper(mortality) table(9)}"
		di "    - Life expectancy estimates by CZ-year-gender-income quartile"
		di "  • {ul:Online Data Table 10} - {stata oplabdata, paper(mortality) table(10)}"
		di "    - CZ-level characteristics"
		di "  • {ul:Online Data Table 11} - {stata oplabdata, paper(mortality) table(11)}"
		di "    - Life expectancy estimates by county-gender-income quartile"
		di "  • {ul:Online Data Table 12} - {stata oplabdata, paper(mortality) table(12)}"
		di "    - County-level characteristics"
		di "  • {ul:Online Data Table 13} - {stata oplabdata, paper(mortality) table(13)}"
		di "    - Mean life expectancy at age 40 by country-gender"
		di "  • {ul:Online Data Table 14} - {stata oplabdata, paper(mortality) table(14)}"
		di "    - Population and death counts in tax data and NCHS data by gender-age-year"
		di "  • {ul:Online Data Table 15} - {stata oplabdata, paper(mortality) table(15)}"
		di "    - National mortality rates by gender-age-year-income percentile"
	}
	
	else if ~inrange(`table',1,15) {
		di as error "Error: table specified (`table') is invalid. Valid options for paper(mortality) are 1 to 15."
		di as error "Type {stata oplabdata, paper(mortality)} for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,15) {
		di as text "Loading Mortality table `table'."
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/health/
			qui webuse health_ineq_online_table_`table'.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/health/health_ineq_online_table_`table'_readme.pdf":here} for a readme."'
	}
}

*-------------------------------------------------------------------------------
* Table handling: IGE trends
*-------------------------------------------------------------------------------

if "`paper'"=="ige_trends" {
	
	if `table'==0 {
		di as text "{bf:Is the United States Still a Land of Opportunity?}"
		di as text "{bf:Recent Trends in Intergenerational Mobility}"
		di " "
		di "{ul:Online Data Table 1} - {stata oplabdata, paper(ige_trends) table(1)}"
		di "  Intergenerational Mobility Estimates by Commuting Zone and Birth Cohort"
	}
	
	else if ~inrange(`table',1,1) {
		di as error "Error: table specified (`table') is invalid. There is only one table for paper(ige_trends), so the only valid option is table(1)."
		di as error "Type {stata oplabdata, paper(ige_trends)} for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,1) {
		di as text "Loading IGE trends table `table'."
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/trends/
			qui webuse onlinedata`table'_trends.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/trends/onlinedata1_trends.xls":here} for a readme."'
	}
}

*-------------------------------------------------------------------------------
* Table handling: IGE
*-------------------------------------------------------------------------------

if "`paper'"=="ige" {
	
	if `table'==0 {
		di as text "{bf:Where is the Land of Opportunity?}"
		di as text "{bf:The Geography of Intergenerational Mobility in the United States}"
		di " "
		di "  • {ul:Online Data Table 1} - {stata oplabdata, paper(ige) table(1)}"
		di "    - National 100 by 100 Transition Matrix"
		di "  • {ul:Online Data Table 2} - {stata oplabdata, paper(ige) table(2)}"
		di "    - Marginal Income Distributions by Centile"
		di "  • {ul:Online Data Table 3} - {stata oplabdata, paper(ige) table(3)}"
		di "    - Intergenerational Mobility Statistics and Selected Covariates by County"
		di "  • {ul:Online Data Table 4} - {stata oplabdata, paper(ige) table(4)}"
		di "    - Intergenerational Mobility Statistics by Metropolitan Statistical Area"
		di "  • {ul:Online Data Table 5} - {stata oplabdata, paper(ige) table(5)}"
		di "    - Intergenerational Mobility Statistics by Commuting Zone"
		di "  • {ul:Online Data Table 6} - {stata oplabdata, paper(ige) table(6)}"
		di "    - Quintile-Quintile Transition Matrices by Commuting Zone"
		di "  • {ul:Online Data Table 7} - {stata oplabdata, paper(ige) table(7)}"
		di "    - Income Distributions by Commuting Zone"
		di "  • {ul:Online Data Table 8} - {stata oplabdata, paper(ige) table(8)}"
		di "    - Commuting Zone Characteristics"
	}
	
	else if ~inrange(`table',1,8) {
		di as error "Error: table specified (`table') is invalid. Valid options for paper(ige) are 1 to 8."
		di as error "Type oplabdata, paper(ige) for more details on valid table options."
		exit
	}
	
	else if inrange(`table',1,8) {
		di " "
		di as text "Loading IGE table `table'."
		qui webuse set http://www.equality-of-opportunity.org/data/descriptive/
		qui webuse onlinedata`table'.dta, clear
		qui webuse set
		* Check to see if table is in local storage
		capture confirm file `oplabdata_local'/`paper'_table`table'.dta
		local table_local = _rc
		if `table_local'==0 {
			di "  Table `table' was found on local storage, loading it from there."
			qui use `oplabdata_local'/`paper'_table`table'.dta, clear
		}
		* If not in local storage, load from online and put in local storage
		else {
			di "  Table was not found on local machine, loading from equality-of-opportunity.org."
			qui webuse set http://www.equality-of-opportunity.org/data/descriptive
			qui webuse onlinedata`table'.dta, clear
			qui webuse set
			qui save `oplabdata_local'/`paper'_table`table'.dta, replace
		}
		di `"  Click {browse "http://www.equality-of-opportunity.org/data/descriptive/table1/online_data_tables.xls":here} for a readme."'
	}
}

*-------------------------------------------------------------------------------
* No table specified
*-------------------------------------------------------------------------------

if "`paper'"=="" {

	di as text "{bf:Available Datasets}:"
	di " "
	di "  • {ul:Mobility Report Cards: The Role of Colleges in Intergenerational Mobility}"
	di "      - 11 datasets; type {stata oplabdata, paper(mrc)} for more information."
	di " "
	di "  • {ul:The Fading American Dream: Trends in Absolute Income Mobility Since 1940}"
	di "      - 8 datasets;  type {stata oplabdata, paper(absmob)} for more information."
	di " "
	di "  • {ul:The Effects of Neighborhoods on Intergenerational Mobility}"
	di "      - 6 datasets;  type {stata oplabdata, paper(neighborhoods)} for more information."
	di " "
	di "  • {ul:Childhood Environment and Gender Gaps in Adulthood}"
	di "      - 3 datasets;  type {stata oplabdata, paper(gendergaps)} for more information."
	di " "
	di "  • {ul:The Association Between Income and Life Expectancy in the United States, 2001-2014}"
	di "      - 15 datasets; type {stata oplabdata, paper(mortality)} for more information."
	di " "
	di "  • {ul:Is the United States Still a Land of Opportunity? Recent Trends in Intergenerational Mobility}"
	di "      - 1 dataset;   type {stata oplabdata, paper(ige_trends)} for more information."
	di " "
	di "  • {ul:Where is the Land of Opportunity? The Geography of Intergenerational Mobility in the United States}"
	di "      - 8 datasets;  type {stata oplabdata, paper(ige)} for more information."
}


end


program define oplabdata_helper_logo

di "{hline 80}"
di "   ____        __         __    ____        __       "
di "  / __ \____  / /  ____ _/ /_  / __ \____ _/ /_____ _"
di " / / / / __ \/ /  / __ `/ __ \/ / / / __ `/ __/ __ `/"
di "/ /_/ / /_/ / /__/ /_/ / /_/ / /_/ / /_/ / /_/ /_/ / "
di "\____/ .___/_____\__,_/_.___/_____/\__,_/\__/\__,_/  "
di "    /_/   Version 1.1, updated 2017/10/17"
di as text `"  Load and browse data from the {browse "http://www.equality-of-opportunity.org/":Equality of Opportunity Project}."'
di as text `"  Type {stata oplabdata} to view all projects with available datasets."'
di as input "{hline 80} "
di as text as text " "
end


program define confirmdir, rclass
 version 8
 local cwd `"`c(pwd)'"'
 quietly capture cd `"`1'"'
 local confirmdir=_rc 
 quietly cd `"`cwd'"'
 return local confirmdir `"`confirmdir'"'
end 
