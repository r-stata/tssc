*! birthsim v1.0 Stephen Cranney, 9Jan2013

program birthsim, rclass
version 11.1
syntax [,endyear(real 2100) birthday(real 5) birthmonth(real 5) ///
 birthyear(real 1985) marriageday(real 5) marriagemonth(real 5) marriageyear(real 2005) /// 
 latestageatconception(real 49.25) probabilityconceive(real .2) contraceptioneffectiveness(real 0) ///
 probabilitymiscarriage(real .25) fetallossinfertility(real 4) birthinfertility(real 12)] 

*******************************************************************************************************
*Setup data columns
*******************************************************************************************************

drop _all
set more off
set obs 1
generate id=1
generate age=25
generate births= .f

set more off
forvalues bot = `birthyear'(1)`endyear' {
  gen age`bot' = age >= `bot'
}
replace age`birthyear'=age
drop age
reshape long age, i(id) j(year)
egen month=group (year id) 
forvalues month = 1(1)12 {
  gen month`month' = month >= `month'
}
egen group=group(year id)
drop month
reshape long month, i(group) j(newvar)
drop month
rename newvar month
drop group

*******************************************************************************************
*Calculate birthday, age, and marriage day variable
*******************************************************************************************
quietly generate birthdate=mdy(`birthmonth',`birthday',`birthyear')
format birthdate %d
quietly generate marriagedate=mdy(`marriagemonth', `marriageday', `marriageyear')
format marriagedate %d
quietly generate marriageage= (marriagedate-birthdate)/365.25
local day=1
quietly generate date=mdy(month, `day', year) 
quietly replace age=(date-birthdate)/365.25
quietly generate contraceptionnoneffectiveness= 1-`contraceptioneffectiveness'
quietly generate probabilityconceive2= `probabilityconceive'* contraceptionnoneffectiveness
************************************************************************************************************
*Calculate probability of having a child, .i= postpartum infertility, generate .o= oldage infertility
**********************************************************************************************************
quietly replace births= .a if age > `latestageatconception'
quietly replace births= .a if age < marriageage
quietly replace births= rbinomial(1, probabilityconceive2) if births== .f
quietly generate miscarriage= rbinomial(1, `probabilitymiscarriage') if births== 1

******************************************************************************************
*Create postpartum and post-abortive infertility. 
******************************************************************************************
local N = _N
forvalues i = 1/`N' {
        forvalues j= 1/`birthinfertility' {
              local k = `i' + `j' 
			  local s= (`fetallossinfertility'-`j') + `i' + 1
				if births[`i']==1 & miscarriage[`i']==0 quietly replace births= .p in `k'
				if births[`i']==1 & miscarriage[`i']==1 & `s'>1 quietly replace births= .m in `s' 
                }
        }
sum births if births==1
return scalar children= r(N)
end
