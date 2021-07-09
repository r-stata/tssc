*! charon v1.0.0 A.Bigoni 26Out2019

program charon
		version 14.0
		syntax varlist(max=1 str), ///
				[CANcer(name max=20 )] ///
				[NEWgroup(string)] ///
				Age(string) ///
				Sex(string) ///
				Year(string) ///
				GEOlevel(string) ///
				ADJust(string)   ///
				[COEFficient(numlist max=1)]
		
		
		

		
		local garbage efbalance encephalopathy hydrocephalus parasitic ///
					cardioshock	cardioarrest paralytic embolism fever ///
					gisigns	perieffusion illa00b99 illd10d36 illf32f99 ///
					illg43g58 illh00h99	illk00k14 ill01l98 illm09m99 /// 
					illn39n97 illq10q84 illr00r99 illz00z99 pulmoedema ///
					peritonitis renalfail senility septicaemia ///
					diseaseinjuries thoraxpleural unspliverdisea ///
					unspsitucarci amyloidosis Cachexia respdisordes ///
					illcan_c_14	illcan_c_26	illcan_c_39	illcan_c_55 ///
					illcan_c_57	illcan_c_63	illcan_c_68	illcan_c_75 ///
					illcan_c_76	illcan_c_80	haemoperic

		
					qui	findfile charon_globallisticd.do
					qui	run `r(fn)'


*==============================================================================
*Checking syntax
*==============================================================================
					
if "`adjust'" == "EBF" { 
local coef *0.5
}
********************************************************************************
if "`coefficient'" != "" { /
cap assert "`adjust'" == "WHO" 
if _rc { 
di as err "Coefficient option only allowed with WHO adjustment option"
exit 198
}
local coef *`coefficient' 
}

qui if "`cancer'" == "" & "`newgroup'" == "" {
di as err "At least one cancer or newgroup option need to be specified"
exit 198
}

qui if "`newgroup'" != "" & ("`adjust'" == "GBD" | "`adjust'" == "EBF") {
di as err "New group only allowed with WHO option"
exit 198
}
		
********************************************************************************
		qui if "`cancer'" != "" { // CANCER OPTION

			foreach Z of local cancer {

				local LIST  lipora	nasoph	otpha 	esopha	stomac	///
							colon 	liver 	gallbl	pancre	larynx	trache	///
							malski	nonmel	breast	cervic	uterin	/// squacc
							ovaria	prosta	testic	kidney	bladde	brain 	///
							thyroi	mesoth	hodgki	nonhod	multip	leukem	///
							aculym 	chroni	acumye 	chromy	otleuk otmali
				local LEN = length("`Z'")
				local OK = 0
					foreach W of local LIST {
						if ("`Z'" == substr("`W'", 1, `LEN')) {
						local OK = 1
						local Z "`W'"
						continue, break
						}
					}
				if !`OK' {
					di as err "Invalid cancer() option"
					exit 198
				}
			}
		}
********************************************************************************		
		
		qui if "`adjust'" != "" { // ADJUST OPTION

			foreach Z of local adjust {

				local LIST  GBD EBF WHO NAD
				local LEN = length("`Z'")
				local OK = 0
					foreach W of local LIST {
						if ("`Z'" == substr("`W'", 1, `LEN')) {
						local OK = 1
						local Z "`W'"
						continue, break
						}
					}
				if !`OK' {
					di as err "Invalid adjust() option"
					exit 198
				}
			}
		}
********************************************************************************		
*FOR BRAZILIANS:
if ("br_" == substr("`age'", 1, 3)) {
qui replace `age' = 0 if `age' <= 400
qui replace `age' = . if `age' == 999
qui forvalue i = 1/150 {
replace `age' = `i' if `age' == `i'+400
}
}	
		
		cap confirm numeric variable `age'     // AGE OPTION
		if _rc {
			di as err "Age needs to be a numeric variable"
			exit 108
		}
		qui cap assert `age' <150 | `age' == 999 | `age' == .
		if _rc {
			di as err "Age range not allowed"
			exit 108
		}

********************************************************************************		

*FOR BRAZILIANS:
if ("br_" == substr("`sex'", 1, 3)) {
qui replace `sex' = 3 if `sex' == 0 | `sex' ==9 | `sex' ==. 
}


		cap confirm numeric variable `sex'     // SEX OPTION
		if _rc {
			di as err "Sex needs to be a numeric variable"
			exit 108
		}
		
		qui cap assert `sex' == 1 | `sex' == 2 | `sex' == 3
			if _rc {
			di as err "Sex is not properly coded"
			exit 108
		}

********************************************************************************			
		
		qui sum `sex'
		if "`r(min)'" >= "3"{
			di as err "Error in sex classification."
			di as err "Please, for optimal use, classify: "
			di as err "Male = 1"
			di as err "Female = 2" 
			di as err "Unknown = 3"
			exit 111
		}

*==============================================================================
*Deafault cancer category
*==============================================================================	
	
	qui if "`cancer'" != "" {
			local cancer neopla `cancer'
		
		}
		
		qui if "`cancer'" == "" & "`newgroup'" == "" {
		exit 198
		}
		
*==============================================================================
*Creates age groups
*==============================================================================
	
		tempfile ORIGINAL
		qui save `ORIGINAL'
		
		qui{
			gen age_groups = .
			forvalue i = 74(-5)0 {
			replace age_groups = 80 if `age' >= 80
			replace age_groups = `i'+1 if `age' <= `i'+5
			replace age_groups = 0 if `age' <=4
			replace age_groups = 99 if `age' ==.
			}
			gen getaria = (`sex'*100)+ age_groups
		}
		

*==============================================================================
*Creates dataset for Elisabeth França's method
*==============================================================================


		qui if "`adjust'" == "EBF" | "`adjust'" == "WHO" {

		
			noi di"You selected a method of proportional distribution"
			
			preserve
			
				noi di "Generating variable with the values from the XVIII chapter of ICD10"
				icd10 generate illr00r99 = `varlist' , range ( R* ) 
				
				icd10 generate external = `varlist' , range ( V* W* X* Y*)

				noi di "Generating variable with the total number of deaths"
				generate all_deaths = 1 

				collapse (sum) illr00r99 all_deaths external  , by ( `year' `geolevel' getaria `sex' age_groups)
				
				
				tempfile franca1
				save `franca1'
				
			restore
		
		}
*==============================================================================
*Updates GBD table PART I
*==============================================================================
		qui if "`adjust'" == "GBD" {				
					
				noi di "Selecting the GBD option may drastically increase the time depending of the selected range of the dataset."
				noi di ""
				noi di "Extracting Garbage Codes"
					
				local j = 0
				foreach x of local garbage {
					local lim `++j'
					}

				forvalue a = 10(10)50{
					local i = 0
						foreach x of local garbage {			
							local ++i
					
							if `i'>=`a'-9 &`i'<=`a' {
							noi di "(`i'/`lim')  ${g_nam_`x'}"
							icd10 gen `x' = `varlist', range(${g_icd_`x'})
							local listateste`a' `listateste`a'' `x'

								if `i'==`a' | `i'==`lim' {
									preserve
										collapse (sum) `listateste`a'', by ( `year' `geolevel' getaria `sex' age_groups)
										tempfile GBD_`a'
										save `GBD_`a''
									restore
								drop `listateste`a''
									}
								}
							} 
						}

				preserve
					use `GBD_10', clear
					forvalue a = 20(10)50{
					merge 1:1  `year' `geolevel' getaria `sex' age_groups using `GBD_`a'', nogen
				}
					tempfile GBD_All				
					save `GBD_All'
				restore					
					
			}

	

*==============================================================================
*Creates values by cancer type (Including D codes)
*==============================================================================
		qui if "`cancer'" != "" {	
	
			noi di "You selected the option to take into consideration the codes from the II and III chapter of ICD10"

			qui foreach x of local cancer {

			noi di "${nam_`x'}"
			icd10 gen `x' = `varlist', range(${c_icd_`x'})
			

			}
			}
			
				qui if "`newgroup'" != "" {	
			noi di "New group: `newgroup'"
			icd10 gen newgroup = `varlist', range(`newgroup')
			
			local new newgroup
			
			local allgroups `cancer' `new'
			
			}
			
			qui collapse (sum) `cancer' `new' , by ( `year' `geolevel' getaria `sex' age_groups)
	
*==============================================================================
*Apply Elisabeth França's method
*==============================================================================
		qui if "`adjust'" == "EBF" | "`adjust'" == "WHO" {

		noi di "calculating proportions"
			merge m:1 `year' `geolevel' getaria `sex' age_groups using `franca1', nogen
			
			local allgroups `cancer' `new'
			
				foreach x of local allgroups {
					gen adj_`x' =  (illr00r99*(`x'/(all_deaths - (illr00r99 + external)))) `coef'
					egen fran_`x' = rowtotal(`x' adj_`x') 
					drop `x' adj_`x' 
					rename fran_`x' `x' 
					
				}
		}

*==============================================================================
*Apply GBD method
*==============================================================================

		qui if "`adjust'" == "GBD" {
		
			merge 1:1 `year' `geolevel' getaria `sex' age_groups using `GBD_All'

			
			foreach x of local cancer {
				foreach gc of local garbage {

					preserve 												
						findfile charon_GcTabCoef.dta
						use `r(fn)', clear


						sum `x' if gcvar == "`gc'" 								
						local `x'_`gc' = r(mean)/100
						
						
						noi di " Cancer: ${nam_`x'} " 
						noi di " Garbage group: ${g_nam_`gc'} "
						
						if  "`r(mean)'" != "" {
						noi di " Coefficient: " %6.2f `r(mean)'
						}
						if  "`r(mean)'" == "" {
						noi di " Coefficient: No coefficient"
						}
						
						if  "${a_range_`x'}" != "" {
						noi di " Age range for redistribution: ${a_range_`x'}"
						}
						if  "${a_range_`x'}" == "" {
						noi di " Age range for redistribution: all"
						}
						noi di "***********************************************"
					
					
					restore 												
		
						generate adj_`x'`gc' = ``x'_`gc''*`gc' ${a_range_`x'}
		
		
				}
			}

				foreach x of local cancer{
					egen gbd_`x' = rowtotal( `x' adj_`x'*)
				}
				
				keep gbd* getaria `sex' `geolevel' age_groups `year'


				foreach x of local cancer{
					rename gbd_`x' `x'
				}
		
		}

	
*==============================================================================
*Replaces all missing values by 0
*==============================================================================
		qui foreach x of varlist _all {
			replace `x' = 0 if(`x' == .)
		} 

*==============================================================================
*Calculates weights for uknown sex and age by geolevel and year
*==============================================================================	
		
		
		qui foreach x of local cancer { 										
			noi di "Calculating weights for sex, age groups, and age groups by sex, for ${nam_`x'}"


			bys `year' `geolevel' : egen tot_`x' = total(`x') if `sex' !=3 							// Generate group for when sex is known

			bys `sex' `year' `geolevel' : egen tot_m_`x' = total(`x') if `sex' ==1 				// Generate total values for men
			 
			bys `sex' `year' `geolevel': egen tot_f_`x' = total(`x') if `sex' ==2 				// Generate total values for women

			generate sw_m_`x' = tot_m_`x'/tot_neopla 						// Generate weight for men
			 
			generate sw_f_`x' = tot_f_`x'/tot_neopla 						// Generate weight for women			 

			egen sw_`x' = rowtotal(sw_m_`x' sw_f_`x') 						// Generate a single variable containing weights

			bys age_groups `year' `geolevel': egen tot_byage_`x' = total(`x') if age_groups !=99 //age_group !=99		// CHECK THIS Generate total values for age groups for when sex is known
					
			generate aw_`x' = tot_byage_`x'/tot_neopla 						// Generates age weights for when sex is known			

			bys getaria `year' `geolevel': egen tot_byageandsex_`x' = total(`x') if age_groups !=99 	// Generate total values for age-sex groups for when sex is known
				
			generate asw_`x' = tot_byageandsex_`x'/tot_neopla 				// Generate weights for age-sex groups for when sex is known
	 
		}
		
	cap	drop sw_f_* sw_m_* tot_byage_* tot_byageandsex_* 	

*==============================================================================
*Prepares the dataset for redistribution of unknown sex and age
*==============================================================================
		qui {
			preserve
				
				keep if getaria==399
				foreach x of local cancer {
					rename `x' nosexandage_`x'
				}
	cap			keep `year' `geolevel' nosexandage_*
				tempfile temp1
				save `temp1'
			restore
			*=======
			preserve
			
				replace `sex'=1 if getaria==199
				replace `sex'=2 if getaria==299
				keep if getaria==1999 | getaria==299
				foreach x of local cancer {
					rename `x' noage_`x'
				}
	cap			keep `year' `geolevel' `sex' noage_*
				tempfile temp2
				save `temp2'
			restore
			*=======

			preserve
			
				keep if `sex'==3 
				drop if getaria==399 | getaria==299 | getaria==199
				foreach x of local cancer {
					rename `x' nosex_`x'
				}
	cap			keep `year' `geolevel' age_groups nosex_*
				tempfile temp3
				save `temp3'
			restore

			drop if `sex' ==3

			merge m:1 `year' `geolevel' using `temp1'

			rename _merge _merge3999

			merge m:1  `year' `geolevel' `sex' using `temp2'

			rename _merge _merge19992999

			merge m:1  `year' `geolevel' age_groups using `temp3'

		}

*==============================================================================
* Redistributes unknown sex and age
*==============================================================================
		qui foreach x of local cancer {
			generate adjustvar1_`x' = (nosexandage_`x'*asw_`x')
			generate adjustvar2_`x' = (noage_`x'*aw_`x')
			generate adjustvar3_`x' = (nosex_`x'*sw_`x')
			egen adj_var_`x' = rowtotal( adjustvar1_`x' adjustvar2_`x' adjustvar3_`x')
		}

*==============================================================================
* Adds all the values created by the redistribution methods
*==============================================================================
		qui { 
			foreach x of local cancer {
				egen adj_`x' =	rowtotal( adj_var_`x' `x' )
				}
	cap		keep `year' `geolevel' `sex' age_groups adj_* `new'
	cap		drop adj_var*
			}
			
*==============================================================================
* Gives back the right names
*==============================================================================
		qui foreach x of local cancer {
			rename adj_`x' `x'
			label var `x' "${nam_`x'}"
		}
	
		
		qui if "`cancer'" != "" {
			qui foreach x of local cancer {
			
				if "`x'" == "prosta" | "`x'" == "testic" {
				replace `x' = . if `sex' ==2
				}
				
				if "`x'" == "cervic" | "`x'" == "breast" | "`x'" == "uterin" {
				replace `x' = . if `sex' ==1
				}
		
			}
		}
	
	
	
cap label define `sex' 1 "Male" 2 "Female"
cap label values `sex' `sex'

keep `geolevel' `year' age_groups `sex' `cancer' `new'

sort `geolevel' `year' age_groups `sex'

qui save charodistributionfile.dta, replace

use `ORIGINAL', clear

noi di ""
noi di ""
noi di ""
noi di "Click here to open the file {stata use charodistributionfile.dta, clear :CHARON FILE} (This will replace the dataset currently in use)"

macro drop c_icd_* nam_* a_range_* g_nam_* g_icd_*

end
