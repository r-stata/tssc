*! popsim v1.0 Stephen Cranney, 4April2013


program popsim, rclass
version 11.1
syntax [,endyear(real 2100) birthday(real 5) birthmonth(real 5) ///
 birthyear(real 1985) marriageday(real 5) marriagemonth(real 5) marriageyear(real 2005) /// 
 latestageatconception(real 49.25) probabilityconceive(real .2) contraceptioneffectiveness(real 0) ///
 probabilitymiscarriage(real .25) fetallossinfertility(real 4) birthinfertility(real 12) sexratio(real 1.05) ] 
 

*******************************************************************************************************************
*Generation 1

drop _all
set more off
quietly set obs 1
quietly generate id=1
quietly generate age=25
quietly generate day=1
quietly generate female=.
quietly generate births= .f
quietly generate generationnum=1
quietly generate parentid= -1
quietly generate birthmonth= `birthmonth'
quietly generate birthyear= `birthyear'
quietly generate marriageyear= `marriageyear'
quietly local probfemale= (1/(1+`sexratio'))
quietly local realprobabilityconceive = `probabilityconceive'* (1-`contraceptioneffectiveness')


forvalues bot = `birthyear'(1)`endyear' {
  quietly gen age`bot' = age >= `bot'
}
quietly replace age`birthyear'=age
quietly drop age
quietly reshape long age, i(id) j(year)
quietly egen month=group (year id) 
forvalues month = 1(1)12 {
  quietly gen month`month' = month >= `month'
}
quietly egen group=group(year id)
quietly drop month
quietly reshape long month, i(group) j(newvar)
quietly drop month
quietly rename newvar month
quietly drop group
quietly generate birthdate=mdy(`birthmonth',`birthday',`birthyear')
format birthdate %d
quietly generate marriagedate=mdy(`marriagemonth', `marriageday', `marriageyear')
format marriagedate %d
quietly generate marriageage= (marriagedate-birthdate)/365.25
local day=1
quietly generate date=mdy(month, `day', year) 
quietly replace age=(date-birthdate)/365.25

quietly replace births= .a if age > `latestageatconception'
quietly replace births= .a if age < marriageage
quietly replace births= rbinomial(1, `realprobabilityconceive') if births== .f
quietly generate miscarriage= rbinomial(1, `probabilitymiscarriage') if births== 1

local N = _N
forvalues i = 1/`N' {
        forvalues j= 1/`birthinfertility' {
              local k = `i' + `j' 
			  local s= (`fetallossinfertility'-`j') + `i' + 1
				if births[`i']==1 & miscarriage[`i']==0 quietly replace births= .p in `k'
				if births[`i']==1 & miscarriage[`i']==1 & `s'>1 quietly replace births= .m in `s' 
                }
        }
		quietly replace female= rbinomial(1, `probfemale') if births==1
		
********************************************************************************************************************
*Generation 2

local N = _N
forvalues i = 1/`N' {
		if births[`i'] == 1 {
		quietly expand 2, gen(newvar`i')
		quietly egen Xnewvar= rowtotal (newvar*)
		quietly drop if Xnewvar>1
		quietly drop if Xnewvar== 0 & generationnum!= 1  
		quietly drop Xnewvar
		quietly replace parentid = id if newvar`i'==1
		quietly replace id= `i' if newvar`i'==1
		quietly replace birthdate= date[`i'] if newvar`i'==1
		quietly replace birthmonth= month[`i'] if newvar`i'==1
		quietly replace birthyear= year[`i'] if newvar`i'==1
		}
		}
		foreach newvar of varlist newvar** {
		quietly replace generationnum=2 if `newvar'==1
		quietly replace marriageyear= birthyear+ marriageage if `newvar'==1
		quietly replace marriagedate= birthdate + (marriageage*365.25) if `newvar'==1
		quietly format marriagedate %d if `newvar'==1
		quietly replace date=mdy(month, day, year) if `newvar'==1
		quietly replace births=.f if `newvar'==1
		quietly replace births= .a if age > `latestageatconception' & `newvar'==1
		quietly replace births= .b if age < marriageage & `newvar'==1
		quietly replace births= rbinomial(1, `realprobabilityconceive') if births== .f & `newvar'==1 & female==1
		quietly replace miscarriage= rbinomial(1, `probabilitymiscarriage') if births== 1 & `newvar'==1 & female==1
		quietly drop `newvar'
		}
		
		quietly macro drop N
		quietly local N = _N
		forvalues i = 1/`N' {
        forvalues j= 1/`birthinfertility' {
              local k = `i' + `j' 
			  local s= (`fetallossinfertility'-`j') + `i' + 1
				if births[`i']==1 & miscarriage[`i']==0 & generationnum[`i']==2 quietly replace births= .p in `k'
				if births[`i']==1 & miscarriage[`i']==1 & `s'>1 & generationnum[`i']==2 quietly replace births= .m in `s' 
				if births[`i']==1 & generationnum[`i']==2 quietly replace female= rbinomial(1, `probfemale')
                }
        }
		
		quietly compress
		quietly replace female=0 if female==. & generationnum==2
		
sum births if births==1 & female==1
return scalar children= r(N)
end

