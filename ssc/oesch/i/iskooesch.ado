********************************************************************************
* This is a 1-1 adaptation of the .do file by Amal Tawfik, University of Geneva
* found at http://people.unil.ch/danieloesch/scripts/
* 
* There is one difference in this .ado:
* (1) It only performs the conversion for one person and hence doesn't do the 
*     final step of filling in Respondent missings with Partner class.
*
* see 'help iskooesch' for more Info
*
********************************************************************************
* May 2018 - Simon Kaiser, University of Bern
********************************************************************************

program define iskooesch
		version 7
		syntax newvarname, isko(varname numeric) emplrel(varname numeric) emplno(varname numeric) [sixteen eight five replace]

		
		if "`sixteen'"=="sixteen" | ("`eight'"!="eight" & "`five'"!="five") {
		
			capture confirm variable oesch16_`varlist'
			if !_rc & "`replace'"!="replace" {
				display as error "Error: One or multiple of the variables to be generated already exist. Specify option 'replace' to overwrite them."
				exit 110
			}
		}
		
		if "`eight'"=="eight"{
		
			capture confirm variable oesch8_`varlist'
			if !_rc & "`replace'"!="replace" {
				display as error "Error: One or multiple of the variables to be generated already exist. Specify option 'replace' to overwrite them."
				exit 110
			}
		}
		
		if "`five'"=="five"{

			capture confirm variable oesch5_`varlist'
			if !_rc & "`replace'"!="replace" {
				display as error "Error: One or multiple of the variables to be generated already exist. Specify option 'replace' to overwrite them."
				exit 110
			}
		}
		
		display as text "Converting ISCO88 codes to Oesch classification."
		
		**** qui recode occupation variable (isco88 com 4-digit) for respondents
		tempvar tmpisko
		qui gen `tmpisko' = `isko'
		qui recode `tmpisko' (missing=-9)

		**** qui recode employment status for respondents
		tempvar tmpemplrel
		qui gen `tmpemplrel' = `emplrel'
		qui recode `tmpemplrel' (missing=9)
	
		tempvar tmpemplno
		qui gen `tmpemplno' = `emplno'

		qui recode `tmpemplno' (0=0)(1/9=1)(10/max=2)(missing=0)

		tempvar selfem_mainjob
		qui gen `selfem_mainjob' = .
		qui replace `selfem_mainjob'=1 if `tmpemplrel'==1 | `tmpemplrel'==9
		qui replace `selfem_mainjob'=2 if `tmpemplrel'==2 & `tmpemplno'==0
		qui replace `selfem_mainjob'=2 if `tmpemplrel'==3
		qui replace `selfem_mainjob'=3 if `tmpemplrel'==2 & `tmpemplno'==1
		qui replace `selfem_mainjob'=4 if `tmpemplrel'==2 & `tmpemplno'==2
		

		*************************************************
		* Create Oesch class schema for respondents
		*************************************************

		tempvar oesch16
		qui gen `oesch16' = -9

		* Large employers (1)

		qui replace `oesch16'=1 if `selfem_mainjob'==4

		* Self-employed professionals (2)

		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisko' >= 2000 & `tmpisko' <= 2229) 
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisko' >= 2300 & `tmpisko' <= 2470)

		* Small business owners with employees (3)

		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisko' >= 1000 & `tmpisko' <= 1999)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisko' >= 3000 & `tmpisko' <= 9333)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisko' == 2230)

		
		* Small business owners without employees (4)

		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisko' >= 1000 & `tmpisko' <= 1999)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisko' >= 3000 & `tmpisko' <= 9333)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisko' == 2230)

		* Technical experts (5)

		qui replace `oesch16'=5 if (`selfem_mainjob'==1) & (`tmpisko' >= 2100 & `tmpisko' <= 2213)

		
		* Technicians (6)

		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisko' >= 3100 & `tmpisko' <= 3152)
		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisko' >= 3210 & `tmpisko' <= 3213)
		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisko' == 3434)

		* Skilled manual (7)

		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisko' >= 6000 & `tmpisko' <= 7442)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisko' >= 8310 & `tmpisko' <= 8312)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisko' >= 8324 & `tmpisko' <= 8330)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisko' >= 8332 & `tmpisko' <= 8340)

		* Low-skilled manual (8)

		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisko' >= 8000 & `tmpisko' <= 8300)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisko' >= 8320 & `tmpisko' <= 8321)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisko' == 8331)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisko' >= 9153 & `tmpisko' <= 9333)

		* Higher-grade managers and administrators (9)

		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisko' >= 1000 & `tmpisko' <= 1239)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisko' >= 2400 & `tmpisko' <= 2429)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisko' == 2441)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisko' == 2470)

		* Lower-grade managers and administrators (10)

		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisko' >= 1300 & `tmpisko' <= 1319)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisko' >= 3400 & `tmpisko' <= 3433)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisko' >= 3440 & `tmpisko' <= 3450)


		* Skilled clerks (11)

		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisko' >= 4000 & `tmpisko' <= 4112)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisko' >= 4114 & `tmpisko' <= 4210)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisko' >= 4212 & `tmpisko' <= 4222)

		* Unskilled clerks (12)

		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisko' == 4113)
		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisko' == 4211)
		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisko' == 4223)
		
		* Socio-cultural professionals (13)

		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' >= 2220 &  `tmpisko' <= 2229)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' >= 2300 &  `tmpisko' <= 2320)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' >= 2340 &  `tmpisko' <= 2359)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' >= 2430 &  `tmpisko' <= 2440)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' >= 2442 &  `tmpisko' <= 2443)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' == 2445)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' == 2451)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisko' == 2460)

		
		* Socio-cultural semi-professionals (14)

		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' == 2230)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' >= 2330 & `tmpisko' <= 2332)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' == 2444)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' >= 2446 & `tmpisko' <= 2450)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' >= 2452 & `tmpisko' <= 2455)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' == 3200)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' >= 3220 & `tmpisko' <= 3224)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' == 3226)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' >= 3229 & `tmpisko' <= 3340)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' >= 3460 & `tmpisko' <= 3472)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisko' == 3480)


		* Skilled service (15)

		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' == 3225)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' >= 3227 & `tmpisko' <= 3228)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' >= 3473 & `tmpisko' <= 3475)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' >= 5000 & `tmpisko' <= 5113)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' == 5122)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' >= 5131 & `tmpisko' <= 5132)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' >= 5140 & `tmpisko' <= 5141)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' == 5143)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' >= 5160 & `tmpisko' <= 5220)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisko' == 8323)

		* Low-skilled service (16)

		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' >= 5120 & `tmpisko' <= 5121)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' >= 5123 & `tmpisko' <= 5130)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' >= 5133 & `tmpisko' <= 5139)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' == 5142)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' == 5149)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' == 5230)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' == 8322)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisko' >= 9100 &  `tmpisko' <= 9152)

		* Output the Variables
		qui mvdecode `oesch16', mv(-9)
		
		if "`sixteen'"=="sixteen" | ("`eight'"!="eight" & "`five'"!="five") {		
			
			capture confirm variable oesch16_`varlist'
			if !_rc & "`replace'"=="replace" {
				drop oesch16_`varlist'
			}
			qui gen oesch16_`varlist' = `oesch16'
			
			display as text "Created 16-class variable:"
			ds oesch16_`varlist'
			
			label variable oesch16_`varlist' "`varlist' Oesch class position - 16 classes"
			label define oesch16_`varlist' ///
			1 "Large employers" ///
			2 "Self-employed professionals" ///
			3 "Small business owners with employees" ///
			4 "Small business owners without employees" ///
			5 "Technical experts" ///
			6 "Technicians" ///
			7 "Skilled manual" ///
			8 "Low-skilled manual" ///
			9 "Higher-grade managers and administrators" ///
			10 "Lower-grade managers and administrators" ///
			11 "Skilled clerks" ///
			12 "Unskilled clerks" ///
			13 "Socio-cultural professionals" ///
			14 "Socio-cultural semi-professionals" ///
			15 "Skilled service" ///
			16 "Low-skilled service", replace
			label value oesch16_`varlist' oesch16_`varlist'
			tab oesch16_`varlist'
			
		}

		if "`eight'"=="eight"{
		
			capture confirm variable oesch8_`varlist'
			if !_rc & "`replace'"=="replace" {
				drop oesch8_`varlist'
			}
			qui recode `oesch16' (1 2=1)(3 4=2)(5 6=3)(7 8=4)(9 10=5)(11 12=6)(13 14=7)(15 16=8), gen(oesch8_`varlist')			
			
			display as text "Created 8-class variable:"
			ds oesch8_`varlist'
			
			label variable oesch8_`varlist' "`varlist' Oesch class position - 8 classes"
			label define oesch8_`varlist' ///
			1 "Self-employed professionals and large employers" ///
			2 "Small business owners" ///
			3 "Technical (semi-)professionals" ///
			4 "Production workers" ///
			5 "(Associate) managers" ///
			6 "Clerks" ///
			7 "Socio-cultural (semi-)professionals" ///
			8 "Service workers", replace
			label value oesch8_`varlist' oesch8_`varlist'
			tab oesch8_`varlist'
			
		}
		
		if "`five'"=="five"{
		
			capture confirm variable oesch5_`varlist'
			if !_rc & "`replace'"=="replace" {
				drop oesch5_`varlist'
			}
			qui recode `oesch16' (1 2 5 9 13=1)(6 10 14=2)(3 4=3)(7 11 15=4)(8 12 16=5), gen(oesch5_`varlist')
			
			display as text "Created 5-class variable:"
			ds oesch5_`varlist'
			
			label variable oesch5_`varlist' "`varlist' Oesch class position - 5 classes"
			label define  oesch5_`varlist' ///
			1 "Higher-grade service class" ///
			2 "Lower-grade service class" ///
			3 "Small business owners" ///
			4 "Skilled workers" ///
			5 "Unskilled workers", replace
			label value oesch5_`varlist' oesch5_`varlist'
			tab oesch5_`varlist'
			
		}
		
end
