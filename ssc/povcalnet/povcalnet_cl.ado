/*==================================================
project:       Interaction with the PovcalNet API at the country level
Author:        R.Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Jun 2019 - 15:12:13
Modification Date:   
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
                        0: Program set up
==================================================*/
program define povcalnet_cl, rclass
syntax , [                       ///
           country(string)       ///
           year(string)          ///
           povline(numlist)      ///
           ppp(numlist)          ///
           server(string)        ///
           coverage(string)      /// 
           clear                 ///
           pause                 /// 
           iso                   /// 
           noDIPSQuery           /// 
         ]

version 11.0

if ("`pause'" == "pause") pause on
else                      pause off

qui {
/*==================================================
           conditions and setup 
==================================================*/

local base="http://iresearch.worldbank.org/PovcalNet/PovcalNetAPI.ashx"

if "`server'"!=""  {
	local base="`server'/PovcalNetAPI.ashx"
}


if ("`povline'" == "")  local povline  1.9
if ("`ppp'" == "")      local ppp      -1
if ("`coverage'" == "") local coverage -1

*---------- download guidence data
povcalnet_info, clear justdata `pause'
gen n = _n
levelsof country_code, local(countries) clean

if (lower("`country'") != "all") {

	local uniq_country : list uniq country
	
	local ncountries: list uniq_country  - countries
	local avai_country: list uniq_country  & countries
	
	local countries:  list country | avai_country

}

if ("`ncountries'" != "") {
	if wordcount("`ncountries'") == 1 local be "is"
	if wordcount("`ncountries'") > 1 local be "are"

	noi disp as err "Warning: " _c
	noi disp as input `"`ncountries' `be' not part of the country list"' /* 
	 */ _n "available in PovcalNet. See {stata povcalnet info}"
	 
}	

if ("`countries'" == "") {
	noi disp in red "None of the countries provided in {it:country()} is available in Povcalnet"
	error
}

*---------- alternative macros
local ct = "`countries'" 
local pl = "`povline'" 
local pp = "`ppp'"     
local yr = "`year'"    
local cv = "`coverage'"

/*==================================================
              1: Evaluate parameters
==================================================*/

*----------1.1: counting words

local nct = wordcount("`ct'")  // number of countries
local npl = wordcount("`pl'")  // number of poverty lines
local npp = wordcount("`pp'")  // number of PPP values
local nyr = wordcount("`yr'")  // number of years
local ncv = wordcount("`cv'")  // number of coverage

matrix A = `nct' \ `npl' \ `npp' \ `nyr' \ `ncv'
mata:  A = st_matrix("A"); /* 
 */    B = ((A :== A[1]) + (A :== 1) :>= 1); /* 
 */    st_local("m", strofreal(mean(B)))

if (`m' != 1) {
	noi disp in r "number of elements in options {it:povline(), ppp(), year()} and " _n /* 
	 */ "{it:coverage()} must be equal to 1 or to the number of countries in option {it:country()}"
	 error 197
}

*----------1.2: Expand macros of size one

foreach o in pl pp yr cv {
	if (`n`o'' == 1) {
		local `o': disp _dup(`nct') " ``o'' "
	}
}

/*==================================================
            2: Create query
==================================================*/


*----------create query in loop

local j = 0
local n = 1
local query = ""   // whole query
foreach ict of local countries {
	
	* corresponding element to each country
	foreach o in pl yr pp cv {
		local i`o': word `n' of ``o''
	}
	
	*---------- 	query  coverage
	if inlist("`icv'", "-1", "all") local qcv ""
	else {
		sum n if country_code == "`ict'" & coverage_level == "`icv'", meanonly
		local nobs = r(min)
		local qcv = "_"+"`=coverage_code[`nobs']'"
	}
	
	local qct = "C`j'=`ict'`qcv'"  // query country
	local qpl = "PL`j'=`ipl'"      // query poverty line
	local qyr = "&Y`j'=`iyr'"      // query year
	 
	if ("`ipp'" == "-1") {         // query  ppp
		local qpp ""
	}
	else {
		local qpp "&PPP`j'=`ipp'"
	}
	
	local query "`query'&`qct'&`qpl'`qyr'`qpp'"
	
	local query_`j' = "`qct'&`qpl'`qyr'`qpp'"
	return local query_`j' = "`query_`j''"
	
	local ++j
	local ++n
}

*----------2.2: format query
local query = substr("`query'", 2, .) + "&format=csv"
return local query = "`query'"
global pcn_query = "`query'"

/*==================================================
            3:  Download data
==================================================*/

*----------3.1:
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

*----------3.2: clean data

povcalnet_clean 1, year("`year'") `iso' rc(`rc')

if ("`dipsquery'" == "") {

	noi di as res _n "{title: One-on-one query}"
	noi di as res "{hline}"

	foreach x of numlist 0/`=`j'-1' {
		noi di as res "Query `x':" as txt _col(15) "`query_`x''"
	}
		noi di as res "{hline}"
}


}
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


