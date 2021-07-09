********************************************************************************
* This is a 1-1 adaptation of the .do file by Amal Tawfik, University of Geneva
* found at http://people.unil.ch/danieloesch/scripts/
* 
* There are two differences in this .ado:
* (1) It only performs the conversion for one person and hence doesn't do the 
*     final step of filling in Respondent missings with Partner class.
* (2) The original .do file uses only a limited "emprelp" and ignores "emplnop" 
*     entirely for the partner. Since this .ado can be used to calculate the 
*     class position for anyone, it uses the more complete conversion found for 
*     the respondent in the original script.
*
* see 'help iscooesch' for more Info
*
********************************************************************************
* May 2018 - Simon Kaiser, University of Bern
********************************************************************************

program define iscooesch
		version 7
		syntax newvarname, isco(varname numeric) emplrel(varname numeric) emplno(varname numeric) [sixteen eight five replace]
		
		
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
		
		display as text "Converting ISCO08 codes to Oesch classification."
		
		**** recode occupation variable (isco08 com 4-digit) for respondents
		tempvar tmpisco
		qui gen `tmpisco' = `isco'
		qui recode `tmpisco' (missing=-9)

		**** recode employment status for respondents
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

		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2000 & `tmpisco' <= 2162) 
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2164 & `tmpisco' <= 2165) 
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2200 & `tmpisco' <= 2212) 
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' == 2250)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2261 & `tmpisco' <= 2262)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2300 & `tmpisco' <= 2330)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2350 & `tmpisco' <= 2352)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2359 & `tmpisco' <= 2432)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2500 & `tmpisco' <= 2619)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' == 2621)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2630 & `tmpisco' <= 2634)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2636 & `tmpisco' <= 2640)
		qui replace `oesch16'=2 if (`selfem_mainjob'==2 | `selfem_mainjob'==3) & (`tmpisco' >= 2642 & `tmpisco' <= 2643)

		* Small business owners with employees (3)

		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 1000 & `tmpisco' <= 1439)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2163)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2166)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 2220 & `tmpisco' <= 2240)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2260)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 2263 & `tmpisco' <= 2269)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 2340 & `tmpisco' <= 2342)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 2353 & `tmpisco' <= 2356)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 2433 & `tmpisco' <= 2434)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2620)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2622)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2635)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' == 2641)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 2650 & `tmpisco' <= 2659)
		qui replace `oesch16'=3 if (`selfem_mainjob'==3) & (`tmpisco' >= 3000 & `tmpisco' <= 9629)

* Small business owners without employees (4)

		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 1000 & `tmpisco' <= 1439)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2163)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2166)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 2220 & `tmpisco' <= 2240)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2260)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 2263 & `tmpisco' <= 2269)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 2340 & `tmpisco' <= 2342)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 2353 & `tmpisco' <= 2356)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 2433 & `tmpisco' <= 2434)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2620)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2622)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2635)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' == 2641)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 2650 & `tmpisco' <= 2659)
		qui replace `oesch16'=4 if (`selfem_mainjob'==2) & (`tmpisco' >= 3000 & `tmpisco' <= 9629)

		* Technical experts (5)

		qui replace `oesch16'=5 if (`selfem_mainjob'==1) & (`tmpisco' >= 2100 & `tmpisco' <= 2162)
		qui replace `oesch16'=5 if (`selfem_mainjob'==1) & (`tmpisco' >= 2164 & `tmpisco' <= 2165)
		qui replace `oesch16'=5 if (`selfem_mainjob'==1) & (`tmpisco' >= 2500 & `tmpisco' <= 2529)

		* Technicians (6)

		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisco' >= 3100 & `tmpisco' <= 3155)
		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisco' >= 3210 & `tmpisco' <= 3214)
		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisco' == 3252)
		qui replace `oesch16'=6 if (`selfem_mainjob'==1) & (`tmpisco' >= 3500 & `tmpisco' <= 3522)

		* Skilled manual (7)

		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisco' >= 6000 & `tmpisco' <= 7549)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisco' >= 8310 & `tmpisco' <= 8312)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisco' == 8330)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisco' >= 8332 & `tmpisco' <= 8340)
		qui replace `oesch16'=7 if (`selfem_mainjob'==1) & (`tmpisco' >= 8342 & `tmpisco' <= 8344)

		* Low-skilled manual (8)

		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' >= 8000 & `tmpisco' <= 8300)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' >= 8320 & `tmpisco' <= 8321)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' == 8341)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' == 8350)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' >= 9200 & `tmpisco' <= 9334)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' >= 9600 & `tmpisco' <= 9620)
		qui replace `oesch16'=8 if (`selfem_mainjob'==1) & (`tmpisco' >= 9622 & `tmpisco' <= 9629)

		* Higher-grade managers and administrators (9)

		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisco' >= 1000 & `tmpisco' <= 1300)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisco' >= 1320 & `tmpisco' <= 1349)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisco' >= 2400 & `tmpisco' <= 2432)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisco' >= 2610 & `tmpisco' <= 2619)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisco' == 2631)
		qui replace `oesch16'=9 if (`selfem_mainjob'==1) & (`tmpisco' >= 100 & `tmpisco' <= 110)

		* Lower-grade managers and administrators (10)

		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' >= 1310 & `tmpisco' <= 1312)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' >= 1400 & `tmpisco' <= 1439)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' >= 2433 & `tmpisco' <= 2434)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' >= 3300 & `tmpisco' <= 3339)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' == 3343)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' >= 3350 & `tmpisco' <= 3359)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' == 3411)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' == 5221)
		qui replace `oesch16'=10 if (`selfem_mainjob'==1) & (`tmpisco' >= 200 & `tmpisco' <= 210)

		* Skilled clerks (11)

		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisco' >= 3340 & `tmpisco' <= 3342)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisco' == 3344)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisco' >= 4000 & `tmpisco' <= 4131)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisco' >= 4200 & `tmpisco' <= 4221)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisco' >= 4224 & `tmpisco' <= 4413)
		qui replace `oesch16'=11 if (`selfem_mainjob'==1) & (`tmpisco' >= 4415 & `tmpisco' <= 4419)

		* Unskilled clerks (12)

		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisco' == 4132)
		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisco' == 4222)
		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisco' == 4223)
		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisco' == 5230)
		qui replace `oesch16'=12 if (`selfem_mainjob'==1) & (`tmpisco' == 9621)

		* Socio-cultural professionals (13)

		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2200 &  `tmpisco' <= 2212)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' == 2250)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2261 &  `tmpisco' <= 2262)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2300 &  `tmpisco' <= 2330)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2350 &  `tmpisco' <= 2352)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' == 2359)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' == 2600)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' == 2621)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' == 2630)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2632 &  `tmpisco' <= 2634)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2636 &  `tmpisco' <= 2640)
		qui replace `oesch16'=13 if (`selfem_mainjob'==1) & (`tmpisco' >= 2642 &  `tmpisco' <= 2643)

		* Socio-cultural semi-professionals (14)

		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2163)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2166)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 2220 & `tmpisco' <= 2240)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2260)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 2263 & `tmpisco' <= 2269)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 2340 & `tmpisco' <= 2342)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 2353 & `tmpisco' <= 2356)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2620)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2622)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2635)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 2641)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 2650 & `tmpisco' <= 2659)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 3200)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 3220 & `tmpisco' <= 3230)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 3250)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 3253 & `tmpisco' <= 3257)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 3259)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 3400 & `tmpisco' <= 3410)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 3412 & `tmpisco' <= 3413)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' >= 3430 & `tmpisco' <= 3433)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 3435)
		qui replace `oesch16'=14 if (`selfem_mainjob'==1) & (`tmpisco' == 4414)

		* Skilled service (15)

		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 3240)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 3251)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 3258)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 3420 & `tmpisco' <= 3423)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 3434)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 5000 & `tmpisco' <= 5120)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 5140 & `tmpisco' <= 5142)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 5163)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 5165)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 5200)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 5220)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 5222 & `tmpisco' <= 5223)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 5241 & `tmpisco' <= 5242)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 5300 & `tmpisco' <= 5321)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' >= 5400 & `tmpisco' <= 5413)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 5419)
		qui replace `oesch16'=15 if (`selfem_mainjob'==1) & (`tmpisco' == 8331)

		* Low-skilled service (16)

		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 5130 & `tmpisco' <= 5132)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 5150 & `tmpisco' <= 5162)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' == 5164)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' == 5169)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 5210 & `tmpisco' <= 5212)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' == 5240)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 5243 & `tmpisco' <= 5249)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 5322 & `tmpisco' <= 5329)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' == 5414)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' == 8322)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 9100 & `tmpisco' <= 9129)
		qui replace `oesch16'=16 if (`selfem_mainjob'==1) & (`tmpisco' >= 9400 & `tmpisco' <= 9520)

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
