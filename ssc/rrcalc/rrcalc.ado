*-------------------------------------------------------------------------------
*
*	"rrcalc: Stata program to calculate AAPOR compliant response rates"  
*	Version 1.1, 29th October 2015
*	Authors: Kai Willem Weyandt (GESIS) & Lars Kaczmirek (GESIS)
*
*-------------------------------------------------------------------------------

cap program drop rrcalc
program define rrcalc, rclass
version 12
syntax varlist(min=1 max=1 numeric) [using] [if] ,[GENerate(string) Rates(string) replace]

//------------------------------------------------------------------------------
//	define sample to use

marksample touse, novarlist

//------------------------------------------------------------------------------
//	tempvar with 8 categories corresponding to I, P, R, NC, O, UH, UO, and NE

tempvar tempaapor mirror 
qui gen byte `tempaapor'=.
qui tostring `varlist', gen(`mirror') 

capture confirm variable `varlist'
if !_rc {
	
	qui replace `tempaapor' = 1 if regexm(`mirror', "^1$")
	qui replace `tempaapor' = 1 if regexm(`mirror', "^10") | regexm(`mirror', "^1[.]0")
	qui replace `tempaapor' = 1 if regexm(`mirror', "^11") | regexm(`mirror', "^1[.]1")
	
	qui replace `tempaapor' = 2 if  regexm(`mirror', "^12") | regexm(`mirror', "^1[.]2")
	
	qui replace `tempaapor' = 3 if regexm(`mirror', "^21") | regexm(`mirror', "^2[.]1")
	qui replace `tempaapor' = 4 if regexm(`mirror', "^22") | regexm(`mirror', "^2[.]2")

	qui replace `tempaapor' = 5 if regexm(`mirror', "^23") | regexm(`mirror', "^2[.]3")
	qui replace `tempaapor' = 5 if regexm(`mirror', "^20") | regexm(`mirror', "^2[.]0")

	qui replace `tempaapor' = 6 if regexm(`mirror', "^31") | regexm(`mirror', "^3[.]1")

	qui replace `tempaapor' = 7 if regexm(`mirror', "^32") | regexm(`mirror', "^3[.]2")
	qui replace `tempaapor' = 7 if regexm(`mirror', "^33") | regexm(`mirror', "^3[.]3")
	qui replace `tempaapor' = 7 if regexm(`mirror', "^34") | regexm(`mirror', "^3[.]4")
	qui replace `tempaapor' = 7 if regexm(`mirror', "^35") | regexm(`mirror', "^3[.]5")
	qui replace `tempaapor' = 7 if regexm(`mirror', "^39") | regexm(`mirror', "^3[.]9")

	qui replace `tempaapor' = 8 if regexm(`mirror', "^4")

	qui levelsof `varlist'
	tokenize `r(levels)'
	local length = wordcount(r(levels))
	local undefinedValues = ""
	
	forval x=1(1)`length' {
		if ///
		regexm("``x''", "^1$")!=1 & ///
		regexm("``x''", "^10")!=1 & ///
		regexm("``x''", "^11")!=1 & ///
		regexm("``x''", "^12")!=1 & ///
		regexm("``x''", "^21")!=1 & ///
		regexm("``x''", "^22")!=1 & ///
		regexm("``x''", "^23")!=1 & ///
		regexm("``x''", "^20")!=1 & ///
		regexm("``x''", "^31")!=1 & ///
		regexm("``x''", "^32")!=1 & ///
		regexm("``x''", "^33")!=1 & ///
		regexm("``x''", "^34")!=1 & ///
		regexm("``x''", "^35")!=1 & ///
		regexm("``x''", "^39")!=1 & ///
		regexm("``x''", "^4")!=1 & ///
		///
		regexm("``x''", "^1[.]0")!=1 & ///
		regexm("``x''", "^1[.]1")!=1 & ///
		regexm("``x''", "^1[.]2")!=1 & ///
		regexm("``x''", "^2[.]1")!=1 & ///
		regexm("``x''", "^2[.]2")!=1 & ///
		regexm("``x''", "^2[.]3")!=1 & ///
		regexm("``x''", "^2[.]0")!=1 & ///
		regexm("``x''", "^3[.]1")!=1 & ///
		regexm("``x''", "^3[.]2")!=1 & ///
		regexm("``x''", "^3[.]3")!=1 & ///
		regexm("``x''", "^3[.]4")!=1 & ///
		regexm("``x''", "^3[.]5")!=1 & ///
		regexm("``x''", "^3[.]9")!=1 ///
		{
			local undefinedValues = "`undefinedValues' " + "``x''"
			qui replace `tempaapor'=. if `mirror'=="``x''"
		}
	}
}

//------------------------------------------------------------------------------
/*	[defining scalars for rate calculation]
	
I	=	Complete interviews (1.1)
P	=	Partial interviews (1.2)
R	=	Refusal and break-off (2.1)
NC	=	Non-contact (2.2)
O	=	Other (2.0, 2.3)

UH	=	Unknown if household/occupied HU (3.1)
UO	=	Unknown, other (3.2-3.9)

NE	=	Not eligible (4)

E	= 	e is the estimated proportion of cases of unknown 
		eligibility that are eligible
*/

qui sum `tempaapor' if `touse'
scalar NSEN =	r(N)		

qui count if `touse' & `tempaapor'==1 
scalar I	=	r(N)

qui count if `touse' & `tempaapor'==2
scalar P	=	r(N)

qui count if `touse' & `tempaapor'==3
scalar R	=	r(N)

qui count if `touse' & `tempaapor'==4
scalar NC	=	r(N)

qui count if `touse' & `tempaapor'==5
scalar O	=	r(N)

qui count if `touse' & `tempaapor'==6
scalar UH	=	r(N)

qui count if `touse' & `tempaapor'==7
scalar UO	=	r(N)

qui count if `touse' & `tempaapor'==8
scalar NE	=	r(N)

qui count if `touse' & `tempaapor'==1 | `tempaapor'==2 | `tempaapor'==3 | ///
`tempaapor'==4 | `tempaapor'==5
scalar EE	=	r(N)

scalar E	=	EE / (EE+NE)

//------------------------------------------------------------------------------
//	[calculation of response rates]

*response rate 1:	
local RR1	= 		I 		/ 	( (I+P) + (R+NC+O) + (UH+UO) )
*response rate 2:
local RR2	= 		(I+P) 	/ 	( (I+P) + (R+NC+O) + (UH+UO) )
*response rate 3:	
local RR3	= 		I 		/	( (I+P) + (R+NC+O) + E*(UH+UO) )

local outputRR1 = `RR1' * 100
local outputRR1 = string(`outputRR1',"%9.2f") //format [using filename]
local outputRR3 = `RR3' * 100
local outputRR3 = string(`outputRR3',"%9.2f") //format [using filename]


*response rate 4:	
local RR4	= 		(I+P) 	/ 	( (I+P) + (R+NC+O) + E*(UH+UO) )
*response rate 5:	
local RR5	= 		I 		/ 	( (I+P) + (R+NC+O) )
*response rate 6:	
local RR6	=		(I+P) 	/ 	( (I+P) + (R+NC+O) )

*cooperation rate 1:	
local COOP1	= 		I 		/ 	( (I+P) + R + O )
*cooperation rate 2:	
local COOP2	= 		(I+P) 	/ 	( (I+P) + R + O )
*cooperation rate 3:	
local COOP3	= 		I 		/ 	( (I+P) + R )
*cooperation rate 4:	
local COOP4	= 		(I+P) 	/ 	( (I+P) + R )

*refusal rate 1:	
local REF1	= 		R 		/ 	( (I+P) + (R+NC+O) + (UH+UO) )
*refusal rate 2:	
local REF2	= 		R 		/ 	( (I+P) + (R+NC+O) + E*(UH + UO) )
*refusal rate 3:	
local REF3	= 		R 		/ 	( (I+P) + (R+NC+O) )	

*contact rate 1:
local CON1	= 		( (I+P) + R + O ) 	/ 	( (I+P) + R + O + NC + (UH+UO) )
*contact rate 2:
local CON2	= 		( (I+P) + R + O ) 	/ 	( (I+P) + R + O + NC + E*(UH+UO) )
*contact rate 3:
local CON3	= 		( (I+P) + R + O ) 	/ 	( (I+P) + R + O + NC ) 	

//------------------------------------------------------------------------------
//	[output]: default overview

//define columns for output
local fircol 45
local seccol 49
local linlen 60

di _n
di as result _dup(`linlen') "_"
di _n
di as result "Overall cases (N)" _col(`fircol')": " _col(`seccol') NSEN
di ""
di as result "Complete interview (1.1 - I)" _col(`fircol')": " _col(`seccol') I
di as result "Partial interview (1.2 - P)"	_col(`fircol')": " _col(`seccol') P
di as result "Refusal and break-off (2.1 - R)" _col(`fircol')": " _col(`seccol') R
di as result "Non-contact (2.2 - NC)" _col(`fircol')": " _col(`seccol') NC
di as result "Other (2.0, 2.3 - O)" _col(`fircol')": " _col(`seccol') O

di as result "Unknown if household/occupied HU (3.1 - UH)"	_col(`fircol')": " _col(`seccol') UH
di as result "Unknown, other (3.2-3.5, 3.9 - UO)"	_col(`fircol')": " _col(`seccol') UO

di ""
di as result "e is the estimated proportion" _col(`fircol')": " _col(`seccol') %5.4f E
di as result "of cases of unknown eligibility"  
di as result "that are eligible" 	
di _n

di as result _dup(`linlen') "_"

//------------------------------------------------------------------------------
//	[rates()]: display options: rr, coop, con, ref, all

if "`rates'" != "" {
	if regexm("`rates'", "rr")==1 | regexm("`rates'", "all")==1 {
		di ""
		di as result "AAPOR response rate 1" _col(`fircol') ": " _col(`seccol') %5.4f `RR1'
		di as result "AAPOR response rate 2" _col(`fircol')": " _col(`seccol') %5.4f `RR2'
		di as result "AAPOR response rate 3" _col(`fircol')": " _col(`seccol') %5.4f `RR3'
		di as result "AAPOR response rate 4" _col(`fircol')": " _col(`seccol') %5.4f `RR4'
		di as result "AAPOR response rate 5" _col(`fircol')": " _col(`seccol') %5.4f `RR5'
		di as result "AAPOR response rate 6" _col(`fircol')": " _col(`seccol') %5.4f `RR6'
	}
	
	if regexm("`rates'", "coop")==1 | regexm("`rates'", "all")==1  {
		di ""
		di as result "AAPOR cooperation rate 1" _col(`fircol')": " _col(`seccol')  %5.4f `COOP1'
		di as result "AAPOR cooperation rate 2" _col(`fircol')": " _col(`seccol')  %5.4f `COOP2'
		di as result "AAPOR cooperation rate 3" _col(`fircol')": " _col(`seccol')  %5.4f `COOP3'
		di as result "AAPOR cooperation rate 4" _col(`fircol')": " _col(`seccol')  %5.4f `COOP4'
	}
	
	if regexm("`rates'", "ref")==1 | regexm("`rates'", "all")==1 {
		di ""
		di as result "AAPOR refusal rate 1" _col(`fircol')": " _col(`seccol')  %5.4f `REF1'
		di as result "AAPOR refusal rate 2" _col(`fircol')": " _col(`seccol')  %5.4f `REF2'
		di as result "AAPOR refusal rate 3" _col(`fircol')": " _col(`seccol')  %5.4f `REF3'
	}
	
	if regexm("`rates'", "con")==1 | regexm("`rates'", "all")==1 {
		di ""
		di as result "AAPOR contact rate 1" _col(`fircol')": " _col(`seccol')  %5.4f `CON1'
		di as result "AAPOR contact rate 2" _col(`fircol')": " _col(`seccol')  %5.4f `CON2'
		di as result "AAPOR contact rate 3" _col(`fircol')": " _col(`seccol')  %5.4f `CON3'
	}

	di ""
	di as result _dup(`linlen') "_"
}

//------------------------------------------------------------------------------
//	[notifications]: display undefined values 

if "`undefinedValues'"!="" {
	local worder=wordcount("`undefinedValues'")
	if "`worder'"=="1" {
		di _n
		di in red "Value `undefinedValues' does not fit the AAPOR Standards Definition and has been set to missing!"
		di _n
	}
	if "`worder'"!="1" {
		di _n
		di in red "Values `undefinedValues' do not fit the AAPOR Standards Definition and have been set to missing!"
		di _n
	}
	
}

//------------------------------------------------------------------------------
//	[generate(newvar)]: generate aapor variable with value label

if "`generate'"!="" {
	qui gen byte `generate' = `tempaapor' if `touse'

	lab def `generate' ///
	1 "1 - Complete interview" ///
	2 "2 - Partial interview" ///
	3 "3 - Refusal and break-off" ///
	4 "4 - Non-contact" ///
	5 "5 - Other" ///
	6 "6 - Unknown if household/occupied HU" ///
	7 "7 - Unknown, other" ///
	8 "8 - Not eligible" ///
	, modify
	
	lab val `generate' `generate'
}

//------------------------------------------------------------------------------
//	[r()]: put results in scalars stored in r()

return scalar CON3= `CON3'
return scalar CON2 = `CON2'
return scalar CON1 = `CON1'
return scalar REF3= `REF3'
return scalar REF2 = `REF2'
return scalar REF1 = `REF1'
return scalar COOP4 = `COOP4'
return scalar COOP3 = `COOP3'
return scalar COOP2 = `COOP2'
return scalar COOP1 = `COOP1'
return scalar RR6= `RR6'
return scalar RR5= `RR5'
return scalar RR4= `RR4'
return scalar RR3 = `RR3'
return scalar RR2 = `RR2'
return scalar RR1 = `RR1'
return scalar E=E
return scalar EE=EE
return scalar NE=NE
return scalar UO=UO
return scalar UH=UH
return scalar O=O
return scalar NC=NC
return scalar R=R
return scalar P=P
return scalar I=I
return scalar N=NSEN

//------------------------------------------------------------------------------
// [using filename]: produce text file

if `"`using'"'!="" {
	qui cap file close myfile
	if "`replace'"=="" {
		qui file open myfile `using', write 
	}
	if "`replace'"=="replace" {
		qui file open myfile `using', write replace
	}
	qui set more off
	qui file write myfile "You may use the following text in your publications which is based on text in AAPOR (2015, p. 52f.):" _n
	qui file write myfile `"`=char(34)'"'"Response rate 1 (RR1), or the minimum response rate, was `outputRR1'%. Response rate 3 (RR3) was `outputRR3'%. RR3 estimates what proportion of cases of unknown eligibility is actually eligible. All response rates are calculated with the formulae in AAPOR (2015). In addition, a table showing the final disposition codes for all cases is available upon request." _n
	qui file write myfile "References: The American Association for Public Opinion Research. 2015. Standard Definitions: Final Dispositions of Case Codes and Outcome Rates for Surveys. 8th edition. AAPOR."`"`=char(34)'"' _n
	qui cap file close myfile
	qui set more on
}

end 

