* tabexp ***************************
* Author : Bruno Schoumaker (UCL)  *
* bruno.schoumaker@uclouvain.be    *
* May 17, 2013                     *
*                                  *
* version 1.2.1                    *
************************************

program tabexp, byable(recall)
version 10.0
syntax [varlist(default=none)] [if] [pweight] [, /*
*/ BVar(varlist)  LENgth(integer 3) DATes(string) /* 
*/ WBirth(varname) AGeg(integer 5) CLuster(varname) /* 
*/ TRend(integer 9999) AWF(varname) MINage(integer 15) (MAXage(integer 49)/*
*/ ENTRY(varname) CYears /*
*/ SAVETAB(string)/*
*/ ENDy(integer 9999) /*
*/ FORCE NODIS RATES FRM ADJExp DV]  


*------- PRESERVE THE ORIGINAL DATA SET

if "`force'"=="" {
	preserve
}


*-------- KEEP OBSERVATIONS FOR BYABLE (and if)

marksample touse
quietly: keep if `touse'

	quietly : count if `touse'
	if r(N)==0 { 
		noisily error 2000
	}


*-------- ERROR MESSAGE FOR AGE GROUPS

if `ageg' != 5 & `ageg'!=1 {
	di as error "age group should be equal to 1 or 5."
	error 198
	exit
}

*-------- ERROR MESSAGE FOR MIN AND MAXAGE

if `minage' > `maxage' {
	di as error "maxiumum age should be greater or equal to minimum age."
	error 198
	exit
}


if (`minage'/`ageg') != int(`minage'/`ageg') {
	di as error "minimum age should be a multiple of the size of the age groups."
	error 198
	exit
}



*-------- select b3* as default birth variables

local b3list b3_01 b3_02 b3_03 b3_04 b3_05 b3_06 b3_07 b3_08 b3_09 b3_10 b3_11 b3_12 b3_13 b3_14 b3_15 b3_16 b3_17 b3_18 b3_19 b3_20 
foreach b3 of local b3list {
	capture confirm var `b3'
	if _rc==0 {
		local nb3=`nb3'+1
		local nbvar "`nbvar' `b3'"
	}
}

if "`bvar'" == "" {
	local bvar="`nbvar'" 
}

*-------- select v008 as default end date (date of survey)

if "`dates'" == "" {
	local dates="v008" 
}

tokenize "`dates'", parse("-")

foreach number of numlist  1/3 {
	local var`number'="``number''"
}

local dates=trim("`var1'")
if "`var3'"!="" {
	tempvar datesm
	gene `datesm'=`dates'-`var3'
	local dates="`datesm'"
}



*-------- select v011 as default birth date of women
if "`wbirth'" == "" {
	local wbirth="v011" 
}

*--------select awfactt as default awfactt

if "`awf'" != "" {
	tempvar awfact
	gene `awfact'=`awf'/100
	local awf="`awfact'"
}

if "`awf'" == "" {
	tempvar awfact
	local awfactt_ok=0
	capture confirm var awfactt
	if _rc==0 {
		local awfactt_ok=1
		tempvar check_aw
		sort awfactt
		quietly : gene `check_aw'=awfactt[_N]/awfactt[1]
		if `check_aw'>1 & `check_aw'!=. {
			di "By default the variable 'awfactt' is used with this data file."
			di "If you analyse fertility for sub-populations, use the correct all women factor."
		}
	}

	if `awfactt_ok'==1 {
		quietly : gene `awfact'=awfactt/100
		if `check_aw'==. {
			quietly : replace `awfact'=1
		}
	}
	
	if `awfactt_ok'==0 {
		gene `awfact'=1
	}

	local awf="`awfact'"
}


*----- use of fractional months

if "`frm'"=="frm" {
	di "fractional months are used. If you want to replicate the results, use 'set seed' before tabexo or tfr2."
	foreach var of varlist `bvar' `dates' `wbirth' {
		tempvar run
		gene `run'=runiform()
		quietly : replace `var'=`var'+`run'
	}
}


*-------- Keep the weight variable in exp

local varwei=subinstr("`exp'","=","",1)


*-------- select V005 as default weight if nothing

quietly {
	if "`exp'" == "" {
		local v005_ok=0
		capture confirm var v005
		if _rc==0 {
			local v005_ok=1
		}

		if `v005_ok'==1 {
			local varwei="v005" 
			local weight="pweight"
		}

		if `v005_ok'==0 {
			tempvar wei
			gene `wei'=1
			local varwei="`wei'"
			di "`exp'"
			local weight="pweight"
		}
	}
}

if "`varwei'"!="`wei'" {
	di "weight variable is " "`varwei'"
}

if "`varwei'"=="`wei'" {
	di "weights are not used" 
}


*-------- Display variable names

if "`dv'"!="" {
di "bvar: " "`bvar'"
di "dates: " "`dates'"
di "wbirth: " "`wbirth'"
di "cluster: " "`cluster'"

}






*-------- select TREND equal to LENgth as default 

if `trend' == 9999 {
	local trend=`length'
}


*-------- error message trend and explanatory variables

if `trend' != `length' &  "`varlist'"!=""{
	di as error "explanatory variables can not currently be combined with the trend option."
	error 198
	exit
}

*-------- select TREND equal to LENgth as default 

if `trend' == 9999 {
	local trend=`length'
}

if (`length' < `trend') {
	di as error "check that the interval for trend is smaller or equal to the length of the period."
	error 198
	exit
}

tempvar check_trend
gene `check_trend'=int(`length'/`trend')*`trend'
if (`check_trend'!=`length') {
	di as error "length should be a multiple of trend."
	error 198
	exit
}


*-------- error message for se without graph or save

if ("`se'"=="se" & ("`gr'"=="" & "`gt'"=="" & "`saverates'"=="" & "`savetrend'"=="")) {
	di as error "se is only allowed with gr, gt, saverates and savetrend."
	error 198
	exit
}


*-------- selection of endy (TO BE IMPROVED)

if `endy'!=9999 {
	local timend_a=(`endy'-1900+1)*12
	if "`dates'"!="" {
		di "endy replaces date of survey."
	}
}



*-------- tokenize savetable for the replace option

tokenize "`savetab'", parse(",")

foreach number of numlist  1/3 {
	local var`number'="``number''"
}

local savetab=trim("`var1'")
if "`var3'"=="replace" {
	local replace_t ", replace"
}

if "`var3'"!="replace" {
	local replace_t ""
}

*-------- SELECT ONLY THE VARIABLES NEEDED FOR THE COMPUTATION OF RATES

keep `dates' `bvar' `wbirth' `varwei' `cluster' `awf' `reg' `varlist' `entry'


*-------- CREATION OF TEMPORARY VARIABLES

tempvar cmcdep origin dates1 mthmin timend case mean_w


*--- ageg is the size of agegroups : multiply it by 12 to have it in months

local agegm=`ageg'*12

*---mthsp is the interval for trends expressed in months

local mthsp=`trend'*12


*-------- CHOICE OF TYPE OF PERIOD

*-------- by year before survey - as in DHS reports

if "`cyears'"=="" {
	gene `timend'=`dates'-1
	if `endy'!=9999 {
		quietly : replace `timend'=`timend_a'
	}

	tempvar meanend lastm
	egen `meanend'=mean(`timend')

	local centry=1900+((`meanend'-(`length'*12/2))/12)

	local lasty=int((`meanend'-1)/12)+1900
	gene `lastm'=int(`meanend')-(`lasty'-1900)*12

	local firsty=`lasty'-`length'
	local firstm=`lastm'+1

	if `firstm'==13 {
		local firstm=1
		local firsty=`firsty'+1
	}

	if `endy'==9999 {
		display "Preparing table of events and exposure for " `length' " year(s) preceding the survey"
	}

	if `endy'!=9999 {
		display "Preparing table of events and exposure for " `length' " year(s) ending in December `endy'"
	}
}

*-------- by calendar year : considers timend to be the last month of the last complete year

if "`cyears'"=="cyears" {
	serset create `dates'
	local mthmin: serset min `dates'
	gene `timend'=(int((`mthmin'-1)/12))*12
	local meanend=`timend'
 
	if `endy'!=9999 {
		replace `timend'=`timend_a'
	}

	local lasty=1900+int((`timend'-1)/12)
	local firsty=`lasty'-`length'+1
	local centry=(`lasty'+`firsty')/2+0.5
	display "Preparing table of events and exposure for " `length' " calendar year(s) preceding the year of the survey"

	tempvar lastm
	gene `lastm'=int(`timend')-(`lasty'-1900)*12
	local firstm 1

}

if `firsty'!=`lasty' {
	display "Period covered: " `firstm' "/" `firsty' " to " `lastm'  "/" `lasty' 
}

if `firsty'==`lasty' {
	display "Rates for year " `firsty' 
}


display "Central date is " `centry' 


************************************************************
***** CONSTRUCTION OF DATA SET - PERSON PERIOD & COLLAPSE **
************************************************************


quietly {

*-------- make sure the sum of weights is equal to sample size (first time)

	egen `mean_w'=mean(`varwei')
	quietly : replace `varwei'=`varwei'/`mean_w'

*-------- RENAME BIRTH VARIABLES 
*-------- would ideally use tempvar for db - but problem with reshape

	foreach  var of varlist `bvar'* {
		local i=`i'+1
		gene _db`i'=`var'
	}

*-------- DEFINE Caseid

	cap drop case
	gene `case'=_n


*-------- RESHAPE FROM WIDE TO LONG 

*-------- create a fictive birth for all women (survey date + 1000)

	gene _db0=`dates'+1000
	reshape long _db, i(`case') j(nume)

*-------- selection of observations

	bys `case' (_db) : keep if _db!=. |(_n==1 & _db==.) 

*-------- define births (consider missing and fictive biorth as 0)

	tempvar birth
	gene `birth'=cond(_db>=`dates'+1000,0,1)

*-------- compute rank

	tempvar rank
	bys `case' (_db), sort : gene `rank'=_n

*-------- STSET DATA

*-------- start of the window

	gene `cmcdep'=`timend'-`length'*12

*-------- date when women reach minage

	tempvar cmcmin
	gene `cmcmin'=`minage'*12+`wbirth'-1

*-------- date when women reach maxage+1

	tempvar cmcmax
	gene `cmcmax'=(`maxage'+1)*12+`wbirth'-1

*-------- choosing origin (start of window, entering 15 or date of entry - if marital fertility or other with entry)

	egen `origin'=rmax(`cmcdep' `cmcmin')

*-------- choosing exit (lower of timend or time maxage)

	tempvar exit
	egen `exit'=rmin(`timend' `cmcmax')

	if "`entry'" != "" {
		replace `origin'=`entry' if `entry'>`origin'
	}


*-------- for twins & triplets = remove small amount of time

	by `case' (nume), sort: replace _db=_db-0.01 if _db==_db[_n-1]
	by `case' (nume), sort: replace _db=_db-0.02 if _db==_db[_n-2]

*-------- stset data

	stset _db [`weight'=`varwei'], id(`case') failure(`birth'==1) enter(`origin') origin(time `origin') exit(time `exit')


*--- Compute sample size (weighted and unweighted)

	stdes
	local vw1=r(N_sub)
	local ew1=r(tr)

	stdes, w
	local vw2=r(N_sub)
	local ew2=r(tr)
}


*-------- make sure the sum of weights is equal to sample size (second time - with valid sample)
*- either adjust to number of cases (default) or to total exposure (use adjexp)

if "`adjexp'"=="" {
quietly : replace `varwei'=`varwei'/`vw2'*`vw1'
}

if "`adjexp'"=="adjexp" {
quietly : replace `varwei'=`varwei'/`ew2'*`ew1'
}

di "Number of cases (women): " `vw1'



*-------- SPLITTIING BY AGE AND PERIOD


quietly {

*-------- split by age groups

	tempvar duree
	stsplit `duree', every(`agegm') after(time=`cmcmin')

*-------- split by time interval

	tempvar period
	stsplit `period', every(`mthsp') after(time=`cmcdep')

*-------- select non empty episodes

	keep if _t!=.

*-------- computation of exposure and age variables

	tempvar exposy age1 age_g

	gene `exposy'=((_t-_t0)/12)
	gene `age1'=int(`duree'/12)+`minage'
	gene `age_g'=int(`age1'/`ageg')*`ageg'

 	egen `dates1'=mean(`dates')
	replace `dates1'=`dates1'/12

}



*-------- COLLAPSE PERSON-PERIOD DATA FILE INTO TABLE OF BIRTHS AND EXPOSURE

*-------- adjust exposure by awfact

quietly : replace `exposy'=`exposy'*`awf'
local lastctry=`meanend'


*--------collapse data
collapse (sum) _d `exposy' [`weight'=`varwei'], by(`age_g' "`cluster'" `period' "`varlist'")


*--------summary info on events and exposure

tempvar totpy tot_d
egen `totpy'=sum(`exposy')
egen `tot_d'=sum(_d)


if "`varwei'"!="`wei'" {
	di "Number of person-years (weighted): " `totpy'
	di "Number of events (weighted): " `tot_d'
}

if "`varwei'"=="`wei'" {
	di "Number of person-years: " `totpy'
	di "Number of events: " `tot_d'
}



quietly {
	rename _d events
	label var events "Events"
	rename `age_g' ageg
	label var ageg "`ageg'-year age groups (value=lower bound)"
	rename `exposy' exposure
	label var exposure "Exposure (person-years)"

	rename `period' period
	replace period=period/12
}


*-------- computation of central years

if "`cyears'"=="cyears" {
	gene centry=period+`trend'/2+`firsty'
	label var centry "Central date"

	quietly : levelsof period, local(lper)
	foreach val of local lper {
		local perlow=`val'
		local perlhi=`val'+`trend'-1
		local perloh="`perlow'-`perlhi'"
		if `perlow'==`perlhi'{
			local perloh="`perlow'"
		}
		label define period `val' "`perloh'", add
		label var period "Time period (greater=more recent)"
	}
}


if "`cyears'"!="cyears" {
	gene centry=1900+(`lastctry'-(`length'*12)+(`trend'*12/2)+(period)*12)/12
	label var centry "Central date"
	quietly : levelsof period, local(lper)
	foreach val of local lper {
	local perlow=`val'
	local perlhi=`val'+`trend'-1
	local perloh="`perlow'-`perlhi'"
	if `perlow'==`perlhi'{
		local perloh="`perlow'"
	}
	label define period `val' "`perloh'", add
	}

	label var period "Time period (greater=more recent)"
}



*------- computation of rates and standard errors

if "`rates'"=="rates" {
	gene rate = events/exposure 
	gene se_r=rate/sqrt(events)
	label var rate "Exposure rate"
	label var se_r "Standard error of rate"
}


*-------- saving table of collapsed data
if "`savetab'"!="" {
local except "`totpy' `tot_d'"
	quietly : ds
	local varlist `r(varlist)'
	local newlist: list varlist - except
	keep `newlist'
	save `savetab' `replace_t'
}


if "`nodis'"=="" {
	local except "`totpy' `tot_d'"
	quietly : ds
	local varlist `r(varlist)'
	local newlist: list varlist - except
	list `newlist',  noobs clean
}




*-------- Restore original data

if "`force'"=="" {
	restore
}

end


