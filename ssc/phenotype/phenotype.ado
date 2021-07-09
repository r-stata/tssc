****************************************************************
*! Version 9.0.1, 5 October 2006
*! Author: James Cui, Monash University
*! Simulate disease status and censored age for family data
*! Original publication: May 2001 STB 61: 8-10 (dm92)
****************************************************************

capture program drop phenotype
program phenotype
version 9.0

	gettoken hr 0 : 0, parse(" ,")

	if (`hr' < 0 ) {
		di in red "negative numbers invalid"
		exit 498
	}
		
	syntax [, Type(string) Alpha(real 4.21) Lambda(real 9.95e-10) 		/*
	*/	Maxage(real 100) Gamma(real 15) Sex(string) Saving(string)]
		
	if "`type'" ~= "" {
		parse "`type'", parse (" ")
		gen str1 inher = substr("`1'", 1, 1)
	}
	else {
	        gen str1 inher = "d"
	}

	if inher ~= "d" & inher ~= "r" {
		di in red "inheritance type invalid"
	}

	if "`sex'" ~= "" {
		parse "`sex'", parse (" ")
		gen str1 gender = substr("`1'",1,1)
	}
	else {
	        gen str1 gender = "b"
	}

	if gender ~= "b" & gender ~= "f" & gender ~= "m" {
		di in red "sex affect invalid"
	}

	if "`saving'" ~= "" {
		parse "`saving'", parse (" ")
		local  output = "`1'"
	}	
	else {
		local  output = "temp1.dta"
	}

	qui sort famid id
	qui gen x = uniform() 
	qui gen y = uniform() 
	qui gen z = uniform() 

	qui gen age_dth = int(`maxage'^(y^(1 / `gamma')))

*---------------------------------------------------------------
* 1. ACCORDING TO WEIBULL DISTRIBUTION 
*---------------------------------------------------------------

	#delimit;

	qui gen age_dis = int((-log(1-x) / `lambda')^(1 / `alpha')) 
		if genotype == "AA" | inher == "r" & genotype == "Aa";

	qui replace age_dis = int((-log(1-x) / `lambda' / `hr')^(1 / `alpha')) 
		if inher == "d" & genotype ~= "AA" | inher == "r" & genotype == "aa";

	#delimit cr

	qui replace age_dis = . if gender == "m" & female == 1 | gender == "f" & female == 0

	qui gen age_cen = min(age, age_dth, age_dis) 

	qui gen byte disease = cond(age_cen >= age_dis, 1, 0)

	qui replace disease = 0 if gender == "m" & female == 1 | gender == "f" & female == 0

	qui drop x y z inher gender
		
	qui save `output', replace

	di _n in ye `"A new file named "`output'" has been created, which contains disease status and censored age"'

end

