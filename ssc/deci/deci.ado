/*---------------------------
01Feb2010 - version 1.0

Variable Base conversion

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
cap prog drop deci
prog define deci
	version 11
	syntax varlist(max=1), From(string) To(string) [Generate(string)]
	qui {
		if !inrange(real("`from'"),2,62) | !inrange(real("`to'"),2,62) {
			n di as result _n "Note: " as txt "number system must be between 2 and 62!"
			exit
		}
		if "`to'"=="`from'" {
			n di as result _n "Note: " as txt "From(numeric) To(numeric) must be different!"
			exit
		}
		if real("`from'")<=10 & real("`to'")<=10 {
			local num=0
			qui cap confirm numeric var `varlist' 
			if _rc!=0 {
				tempvar _deci_temp
				gen `_deci_temp'=real(`varlist')
				drop if `_deci_temp'==.
				local num=1
			}
			else {
				drop if `varlist'==.
			}
			if "`generate'"!="" {
				gen `generate'=.
			}
			count
			local n=r(N)
			forv i =1/`n' {
				if `num'==0 {
					local u=`varlist'[`i']
				}
				else {
					local u=`_deci_temp'[`i']
				}
				if "`to'"=="10" {
					inten `from' `u'
					local p=r(ten)
				}			
				else if "`from'"=="10" {
					inbase `to' `u'
					local p=r(base)
				}
				else {
					inten `from' `u'
					local q=r(ten)
					inbase `to' `q'
					local p=r(base)
				}
				if "`generate'"!="" {
					replace `generate'=`p' in `i'
				}
				else {
					if `num'==0 {
						replace `varlist'=`p' in `i'
					}
					else {
						replace `varlist'="`p'" in `i'
					}
				}
			}
		}
		else {
			local num1=0
			local num2=0
			qui cap confirm string var `varlist' 
			if _rc!=0 & "`generate'"!="" {
				tempvar _deci_temp
				gen `_deci_temp'=string(`varlist',"%50.0g")
				drop if `_deci_temp'==""
				local num1=`num1'+1
			}
			if _rc!=0 & "`generate'"=="" {
				tempvar _deci_temp
				gen `_deci_temp'=string(`varlist',"%50.0g")
				drop `varlist'
				gen `varlist'=`_deci_temp'
				drop if `varlist'==""
				local num1=`num1'+1
			}
			else {
				drop if `varlist'==""
			}
			if "`generate'"!="" {
				gen `generate'=""
			}
			count
			local n=r(N)
			forv i =1/`n' {
				if `num1'==0 {
					local u=`varlist'[`i']
				}
				else {
					local u=`_deci_temp'[`i']
				}
				if "`to'"=="10" {
					inten `from' `u'
					local p=r(ten)
				}			
				else if "`from'"=="10" {
					inbase `to' `u'
					local p=r(base)
				}
				else {
					inten `from' `u'
					local q=r(ten)
					inbase `to' `q'
					local p=r(base)
				}
				if "`generate'"!="" {
					replace `generate'="`p'" in `i'
				}
				else {
					replace `varlist'="`p'" in `i'
				}
			}
		}
	}
end
