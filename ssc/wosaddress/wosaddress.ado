*! 2.0 VERSION OF WOSADDRESS
program define wosaddress
	
version 8.2

quietly {


if "`1'" != "" {
	use "`1'", clear
	}

g id_wos = _n
local varcount = c1_count - 1 in 1



*FIRST IDENTIFYING AND CORRECTING WHERE 244+ OBS WHERE SPLIT BETWEEN BRACKETS
forvalues x = 1(1)`varcount' {
	g splitvar`x' = (strpos(c1_`x',"]") < strpos(c1_`x',"[") | (strmatch(c1_`x',"*]*") & strmatch(c1_`x',"*[*")==0))
	replace c1_`x' = substr(c1_`x',strpos(c1_`x',"]")+1,.) if splitvar`x'
	
	*ALSO CHANGING LONG_ADDR INDICATOR TO ZERO IN THESE CIRCUMSTANCES
	replace long_addr`x' = 0 if splitvar`x'
	}



*NOW REMOVING BLOCKS WITH AUTHOR NAMES IN THEM

forvalues x = 0(1)`varcount' {

	*IN SECOND SECTION OF VARIABLE
	count if strmatch(c1_`x',"*[*]*") 
	while r(N) != 0 {
		replace c1_`x' = subinstr(c1_`x',substr(c1_`x',strpos(c1_`x',"["),strpos(c1_`x',"]")-strpos(c1_`x',"[")+1),"",.) if strmatch(c1_`x',"*[*]*")
		count if strmatch(c1_`x',"*[*]*")
		}
		
		replace c1_`x' = substr(c1_`x',1,strpos(c1_`x',"[")-1) if strmatch(c1_`x',"*[*")==1

		}
		
	

*PARSING VARIABLES INTO DIFFERENT ADDRESSES
*AND COUNTING NUMBER OF VARIABLES PARSED INTO


forvalues j = 0(1)`varcount' { 

	split c1_`j', parse(";") g(c1_`j'_)
	rename c1_`j' long_c1_`j'
	local varmax =  r(nvars) 
	g varnum`j' = 0
	forvalues x = 1(1)`varmax' {
		replace varnum`j' = `x' if c1_`j'_`x' != "" 
		}
}



*WHEN THERE IS A SECOND VARIABLE, JOINING THE FIRST SPLIT SECTION
*FROM THE SECOND VARIABLE TO THE LAST SECTION FROM THE FIRST VARIABLE

local varcount = c1_count in 1
local varcount = `varcount' - 1
local obs = _N

sort id_wos

forvalues j = 1(1)`varcount' {
	
	local h = `j' - 1
	
	forvalues i = 1(1)`obs' {
	
		local num1 = varnum`h' in `i' 
		local num2 = varnum`j' in `i'
		local num3 = `num2' - 1
		
		*this joins last variable in the first c1 set 
		*with the 1st one in the 2nd set
		
		if `num2' != 0 {
			replace c1_`h'_`num1' = c1_`h'_`num1' + c1_`j'_1 if long_addr`j' & id_wos== `i'
	
			*this shifts the variables up one in the 2nd set of c1 vars
			*if the first var has been joined to the 1st set
		
			forvalues z = 1(1)`num3' {
				local k = `z'+1
				replace c1_`j'_`z' = c1_`j'_`k' if long_addr`j' & id_wos== `i'
				}
				
			*NOW ONE LESS VAR IN THE NEXT SET OF C1 VARS
			replace varnum`j' = varnum`j' - 1 if long_addr`j' & id_wos == `i'
			
			*sets the last var to blank in the 2nd set of c1 var
			*if the first var has been joined to 1st set
		
			replace c1_`j'_`num2' = "" if long_addr`j'  & id_wos== `i'
			
			}
	}
}


drop c1_count
sort id_wos
reshape long c1, i(id_wos) j(auth) string


*DROPPING BLANK ADDRESSES WHEN THERE ARE MULTIPLE ADDRESSES
bysort id_wos (c1): g add_num = _n
drop if c1 == "" & add_num > 1
duplicates tag id_wos, g(dupe)
drop if c1== "" & dupe>0



*GETTING THE GEOCODEABLE ADDRESS

g c1_r = reverse(c1)
g addr1_p1 = substr(c1_r,1,strpos(c1_r,",")-1)
replace c1_r = substr(c1_r,strpos(c1_r,",")+1,.)
g addr1_p2= substr(c1_r,1,strpos(c1_r,",")-1)
replace addr1_p1 = reverse(addr1_p1)
replace addr1_p2 = reverse(addr1_p2)
g addr1  = addr1_p2 + ", " + addr1_p1
replace addr1 = "" if trim(addr1) == ","
rename addr1 c1_address

*GENERATING A COUNTRY VARIABLE
g  country = addr1_p1
replace country = "USA" if  strmatch(country,"* USA*")

*SOME JUST HAVE THE US STATE AND ZIP CODE. FIXING THESE
egen nums = sieve(country), keep(numeric)
replace country = "USA" if nums!=""
g state = upper(country) if strlen(country)==2
replace country = "USA" if ( state == "AL" | state == "AK" |  state == "AZ" |  state == "AR" |  state == "CA" |  state == "CO" |  state == "CT" |  state == "DE" |  state == "FL" |  state == "GA" |  state == "HI" |  state == "ID" |  state == "IL" |  state == "IN" |  state == "IA" |  state == "KS" |  state == "KY" |  state == "LA" |  state == "ME" |  state == "MD" |  state == "MA" |  state == "MI" |  state == "MN" |  state == "MS" |  state == "MO" |  state == "MT" |  state == "NE" |  state == "NV" |  state == "NH" |  state == "HI" |  state == "NJ" |  state == "NM" |  state == "NY" |  state == "NC" |  state == "ND" |  state == "OH" |  state == "OK" |  state == "OR" |  state == "PA" |  state == "RI" |  state == "SC" |  state == "SD" |  state == "TN" |  state == "TX" |  state == "UT" |  state == "VT" |  state == "VA" |  state == "WA" |  state == "WV" |  state == "WI" |  state == "WY"  | state=="DC")

replace country = itrim(trim(upper(country)))


drop addr* varnum* c1_r splitvar* long_addr* add_num dupe nums state auth
rename c1_address address


*REPLACING OBSERVATIONS THAT ARE TOO SHORT AND THUS LIKELY ERRORS
*g strlen = strlen(address)
*replace address`i' = "" if strlen`i' < 8
*drop strlen`i'
*}




renvars long_c1_*, predrop(7)
renvars _*, prefix(c1)
label var c1 "Full Address"

aorder c1_*

forvalues x = 100(-1)0 {
	capture: label var c1_`x' "Original Address Variable, Part `x'"
	capture: move c1_`x' c1
}

move c1 address
move address c1

label var address "Short Address"
duplicates tag id_wos, g(address_count)
label var address_count "Number of Addresses"
replace address_count = address_count + 1
label var country "Country"
egen auths_cnt = sieve(au), char(;)
g author_count = strlen(auths_cnt)
drop auths_cnt
label var author_count "Number of Authors"
label var file "WOS File Name"
label var id_wos "Unique Identifier"
}

end

*END OF FILE

