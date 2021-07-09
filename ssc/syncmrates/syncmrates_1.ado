*! version 1.2 May 2015 E. Masset
/*syntetic cohort probability subroutine*/
program syncmrates_1, rclass
version 13
    syntax varlist(min=3 max=3) [iw pw] [if] [, testby(varlist max=1) t1(integer 1) t0(integer 61) plot(string) *]
	tokenize "`0'", parse(" ,")							/*decompose varlist and ignore commas*/
	tempvar m1 m0										/*moving time intervals for mortality calculations*/
	local doi "`1'"										/*rename varlist for the routine*/
	local dob "`2'"
	local aad "`3'"
	gen `m1'=`doi'-`t1'									/*generate interval based on date of interview and time interval selected*/
	gen `m0'=`doi'-`t0'
    	qui {
	local a1 = 0										/*generate 8 group-specific time intervals*/
	local b1 = 0
	local a2 = 1
	local b2 = 2
	local a3 = 3
	local b3 = 5
	local a4 = 6
	local b4 = 11
	local a5 = 12
	local b5 = 23
	local a6 = 24
	local b6 = 35
	local a7 = 36
	local b7 = 47
	local a8 = 48
	local b8 = 59
	forvalues i=1(1)8 {									/*syntetic cohort mortality rates calculation routine*/
	tempvar group`i' group`i'a group`i'b dead`i' dead`i'a dead`i'b
	tempname e`i' e`i'a e`i'b d`i' d`i'a d`i'b mr`i'
	gen double `group`i''= `aad'>(`a`i''-1) & (`dob'>(`m0'-`a`i'') & `dob'<(`m1'-`b`i'')) `if'		/*cohort B, fully exposed - missing values are survivors*/
	gen double `group`i'a'= `aad'>(`a`i''-1) & (`dob'>=(`m1'-`b`i'') & `dob'<=(`m1'-`a`i'')) `if'   /*cohort A, right-censored*/
	gen double `group`i'b'= `aad'>(`a`i''-1) & (`dob'>=(`m0'-`b`i'') & `dob'<=(`m0'-`a`i'')) `if'   /*cohort C, left-censored*/
	gen double `dead`i''= `aad'>=`a`i'' & `aad'<=`b`i'' & `group`i''==1 `if'						/*deaths in cohort B*/
	gen double `dead`i'a'= `aad'>=`a`i'' & `aad'<=`b`i'' & `group`i'a'==1 `if'						/*deaths in cohort A*/
	gen double `dead`i'b'= `aad'>=`a`i'' & `aad'<=`b`i'' & `group`i'b'==1 `if'						/*deaths in cohort C*/	
	sum `group`i'' [`weight' `exp'] `if' 															/*(weighted) all exposed children in cohort B*/
	scalar `e`i''= r(mean)
	sum `group`i'a' [`weight' `exp']  `if' 															/*(weighted) all exposed children in cohort A*/
	scalar `e`i'a'= r(mean)
	sum `group`i'b' [`weight' `exp']  `if' 															/*(weighted) all exposed children in cohort C*/
	scalar `e`i'b'= r(mean)
	sum `dead`i'' [`weight' `exp']  `if' 															/*(weighted) all dead children in cohort B*/
	scalar `d`i''=r(mean)
	sum `dead`i'a' [`weight' `exp']  `if' 															/*(weighted) all dead children in cohort A*/
	scalar `d`i'a'=r(mean)
	sum `dead`i'b' [`weight' `exp']  `if' 															/*(weighted) all dead children in cohort C*/
	scalar `d`i'b'=r(mean)
	scalar `mr`i''= (`d`i''+1*`d`i'a'+0.5*`d`i'b')/(`e`i''+0.5*`e`i'a'+0.5*`e`i'b') 				/*group-specific mortality rates - note exception H in the numerator*/
	}
return scalar nmr =`mr1' 																				/*neoanatal mortality rate*/
return scalar pmr = 1-((1-`mr1')*(1-`mr2')*(1-`mr3')*(1-`mr4'))-`mr1'									/*derived postneonatal mortality rate*/
return scalar imr = 1-((1-`mr1')*(1-`mr2')*(1-`mr3')*(1-`mr4'))											/*infant mortality rate*/
return scalar cmr = 1-((1-`mr5')*(1-`mr6')*(1-`mr7')*(1-`mr8'))											/*child mortality rate*/
return scalar u5mr= 1-((1-`mr1')*(1-`mr2')*(1-`mr3')*(1-`mr4')*(1-`mr5')*(1-`mr6')*(1-`mr7')*(1-`mr8'))	/*under-5 mortality rate*/
}
end
