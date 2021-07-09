*! TMPM: v2.5.0 01/27/2013 Osler and Cook. //
*! Calculates Trauma Mortality Prediction Model values //
*!  for each observation using AIS, ICD-9 or ICD-10 Codes. //
*! The 1p1v additions allow for a one-patient-one-variable data space. //

program tmpm, rclass
version 11.0

syntax [varlist], [ idvar(varname) aispfx(string) icd9pfx(string) icd10pfx(string) NOREPORT ]
quietly local directory "`c(pwd)'/"
sort `idvar'
quietly {
	preserve
	use "C:\ado\personal\marc_table.dta", clear
		keep if lexi=="ais"
		sort index
		save "C:\ado\personal\aislookup.dta", replace
	use "C:\ado\personal\marc_table.dta", clear
		keep if lexi=="icdX"
		sort index
		save "C:\ado\personal\icd10lookup.dta", replace    
	use "C:\ado\personal\marc_table.dta", clear
		keep if lexi=="icdIX"
		sort index
		save "C:\ado\personal\icd9lookup.dta", replace
	restore	
}
if "`icd9pfx'" != "" {
		erase "C:\ado\personal\icd10lookup.dta"
		erase "C:\ado\personal\aislookup.dta"
		noisily {
		display as txt "_____________________________________________________________"
		display as txt "Trauma Mortality Prediction Model p(Death) Estimation Module"
		display as txt "Based on Glance, et al., Annals of Surgery. 2009;249(6):1032"
		display as txt "Input Lexicon: ICD-9"
		display as txt "_____________________________________________________________"
		}  
		tempvar id2
		scalar userfile = c(filename)
		gen `id2' = `idvar'
		capture tostring `id2', replace
	preserve
	
	***************  1p1v step 1  *******************************
		quietly count																			
		scalar pt_no = r(N)
	***************  1p1v end step 1  ***************************
	
		quietly {
			tempvar injcnt maxinj shapel shapew
			capture renpfix `icd9pfx' index
			egen `injcnt' = rownonmiss(index*), strok
		
	***************  1p1v step 2  *******************************
			scalar TMO = pt_no * `injcnt'                  		
	***************  1p1v end step 2  ***************************
			if TMO >1 {
				egen `maxinj' = max(`injcnt')
				gen `shapel' = 1 if `maxinj'==1
				gen `shapew'=0 if `maxinj'>=2
				keep `id2' index* `shapew' `shapel'
				}
			else {
				keep `id2' index* 
				}
			sort `id2'
		
	***************  1p1v step 3  *******************************
			if TMO == 1 {
				rename index1 index
				}
	***************  1p1v step 3  *******************************
	*Handle shape
	
	***************  1p1v step 4  *******************************	
			if TMO != 1 {											 
				if `shapew'==0	{									//If dataset wide, need to make it long
					reshape long index, i(`id2') j(ordinal)			//Dataset now long 
					drop if index==""
					}	
				else if `shapel'==1 {
					sort `id2'
					by `id2', sort: egen ordinal = seq()
					}
				}													 
	**************  1p1v end step 4  ****************************
	
			capture confirm string variable index
			if !_rc {
				}
			else {
				display in red "ICD-9 codes must be of vartype string"
				exit
				}
			
			capture drop if index=="" | index=="."
		
	***************  1p1v step 5  ********************************
			if TMO !=1 {											 
				quietly summarize ordinal
				scalar ADC = r(max)
				}													
	**************  1p1v end step 5  *****************************
	
	///////////   This section is for ICD-9 Lexicon Only /////////
			sort index
			quietly capture icd9 check index, any gen(check)
			quietly count if check!=0
			if ("`noreport'" =="") {		
				noisily display
				display as txt "Proportion of invalid ICD-9 codes:  " %12.2f ((r(N)/_N)*100) "%"
				}
	*Drop instances of invalid icd9 codes
			quietly {
				drop if check!=0
				icd9 clean index, dots
				icd9 generate check2 = index, range(800.00/959.9)
				quietly count if check2!=1
				}
			if ("`noreport'" =="") {	
				noisily display
				noisily display as txt "Proportion of ICD-9 codes unrelated to trauma:  " %12.2f ((r(N)/_N)*100) "%"
				}
			else if ("`noreport'" != "") {
				}
			drop if check2!=1
			drop check check2
			drop if index==""
			sort index
	/////////// End of ICD-9 Only Section //////////////////////
	
	*Merge to get MARC values and body region values
	
	**************  1p1v step 6  *******************************
		if TMO ==1 {											 		
			merge 1:1 index using "C:\ado\personal\icd9lookup.dta", force
			erase "C:\ado\personal\icd9lookup.dta"
			drop  _merge  index  lexi  bodyregion 
			gen pDeathicd9=normal((1.406958*marc)-(2.217565))
			lab var pDeathicd9 "p(Death) ICD-9"
			drop marc
			capture save "C:\ado\personal\tmpm1x1.dta", replace
		restore
			merge 1:1 `id2' using "C:\ado\personal\tmpm1x1.dta"
			capture drop index*
			drop _merge 
		noisily display as txt "p(Death) estimation from ICD-9 lexicon is complete"	
			exit
			}
	*****************  1p1v end step 6  ****************************
		else if TMO !=1 {
			merge m:1 index using "C:\ado\personal\icd9lookup.dta", force
			erase "C:\ado\personal\icd9lookup.dta"
			drop if `id2'==""  | `id2'=="."
			drop if _merge==2
			quietly count if _merge==3
			if ("`noreport'" =="") {
				noisily display as txt "Proportion of codes matched with marc values:  " %12.2f ((r(N)/_N)*100) "%"
				count if _merge==1
				if r(N) !=0 {
					gen unmatch=index if _merge==1 & (index!="." | index!="")
					lab var unmatch "Unmatched ICD-9 Codes"
					noisily display as txt "Your unmatched ICD-9 codes:"
					noisily tab unmatch
					quietly drop unmatch
					}
				}	
			else if ("`noreport'" !=""){
				}
			by index, sort: gen unique= _n==1
			gen uniquematch = 1 if unique==1 & _merge==3
			quietly count if unique==1
			scalar uni1=r(N)
			quietly count if uniquematch==1
			scalar unim=r(N)
			if ("`noreport'" =="") {	
				noisily display
				noisily display as txt "Your data contain " uni1 " unique ICD-9 codes"
				}
			else if ("`noreport'" !=""){
				}
			quietly {
				drop _merge  uniquematch unique
				gsort `id2' -marc
				drop if marc==.
				drop if `id2'==""
				save "C:\ado\personal\temp6.dta", replace							//temp6
				use "C:\ado\personal\temp6.dta", replace
			*Deal with "same region"
				by `id2', sort: gen sr=_n
				drop if ordinal==. & `shapew'==0		//If master dataset was wide, need to drop 'ordinal' var
				keep if sr==1|sr==2							//keep two worst injuries
				keep `id2' sr bodyregion
				sort `id2' bodyregion
				reshape wide bodyregion, i(`id2') j(sr)			//spread them out wide 
				gen same_region=0
				if ADC>1 {
					replace same_region=1 if bodyregion1==bodyregion2	//generate same region
					}
				keep `id2' same_region
				drop if `id2'==""
				sort `id2'
				save "C:\ado\personal\temp7.dta", replace							//and save it temp7
			*Get marc data (again) and make it wide:
				use "C:\ado\personal\temp6.dta", replace
				keep `id2' marc
				gsort `id2' -marc
				drop if `id2'=="" 
				by `id2', sort: gen place=_n
				drop if place>5								//keep only 5 worst (highest) marc values
				reshape wide marc, i(`id2') j(place)			
				foreach var of varlist marc* {				//turn missing values to zeros	
						replace `var'=0	if `var'==.
						}
				sort `id2'
				merge 1:1 `id2' using "C:\ado\personal\temp7.dta"			//attach same_region
				drop _merge
				sort `id2'
				save "C:\ado\personal\temp8.dta", replace							//temp8
			*Get ais data (again) and make it wide:
				use "C:\ado\personal\temp6.dta", replace
				keep `id2' index marc 
				gsort `id2' -marc
				by `id2', sort: gen place=_n
				drop if place>5	
				drop marc									//keep only 5 worst (highest) marc values drop if `idvar'==""	| `idvar'==.				
				reshape wide index, i(`id2') j(place)
				sort `id2'
				merge 1:1 `id2' using "C:\ado\personal\temp8.dta"				//attach same_region
				drop _merge
				save "C:\ado\personal\temp9.dta", replace							//temp9
				if ADC < 5 {
					if ADC == 4 {
						gen marc5=0
						}
					if ADC == 3 {
						gen marc4=0
						gen marc5=0
						}
					if ADC == 2 {
						gen marc5=0
						gen marc4=0
						gen marc3=0	
						}
					if ADC == 1 {
						gen marc5=0
						gen marc4=0
						gen marc3=0	
						gen marc2=0
						}
					}
			*Calculate the model:
				gen Imarc=marc1*marc2						//generate the interaction term
					gen xBeta =	(1.406958*marc1)			+	///
							(1.409992* marc2)			+	///
							(0.5205343* marc3)		+	///
							(0.4150946* marc4)		+	///
							(0.8883929* marc5)		+	///
							(-(0.0890527)* same_region)	+	///
							(-(0.7782696)* Imarc)		+	///
							-(2.217565)
				gen pDeathicd9=normal(xBeta)
				lab var pDeathicd9 "p(Death) ICD-9"
				order `id2' pDeathicd9
				keep `id2' pDeathicd9
				sort `id2'
				save "C:\ado\personal\temp10.dta", replace						//temp10
				}
		restore											//Restores master dataset
			quietly {
				tempvar injcnt maxinj shapel shapew
				capture renpfix `icd9pfx' index
				egen `injcnt' = rownonmiss(index*), strok
				capture renpfix index `icd9pfx' 
				egen `maxinj' = max(`injcnt')
				gen `shapel' = 1 if `maxinj'==1         
				gen `shapew' = 0 if `maxinj'>=2		
				sort `id2'
			*Must again address master dataset shape
				if `shapew'==0 {
					merge 1:1 `id2' using "C:\ado\personal\temp10.dta", nogenerate norep	//Merges p(Death) values with original wide dataset 
						}
				else if `shapel'==1 {
					merge m:1 `id2' using "C:\ado\personal\temp10.dta", nogenerate norep	//Merges p(Death) values with original long dataset 																
						}
				}
			noisily display 
			noisily display as txt "p(Death) estimation from ICD-9 lexicon is complete"
				erase "C:\ado\personal\temp6.dta"
				erase "C:\ado\personal\temp7.dta"
				erase "C:\ado\personal\temp8.dta"
				erase "C:\ado\personal\temp9.dta"	
				erase "C:\ado\personal\temp10.dta"
	}
	}
	}
else if "`aispfx'" != "" {
		erase "C:\ado\personal\icd9lookup.dta"
		erase "C:\ado\personal\icd10lookup.dta"
		noisily {
		display "_____________________________________________________________"
		display "Trauma Mortality Prediction Model p(Death) Estimation Module"
		display "Based on Osler, et al., Annals of Surgery. 2008;247(6):1041"
		display "Input Lexicon: AIS"
		display "_____________________________________________________________"
		}   
		tempvar id2
		gen `id2' = `idvar'
		capture tostring `id2', replace
	preserve
	
	***************  1p1v step 1  *******************************
		quietly count																			
		scalar pt_no = r(N)
	***************  1p1v end step 1  ***************************
	
		quietly {
		tempvar injcnt maxinj shapel shapew
		capture renpfix `aispfx' index
		egen `injcnt' = rownonmiss(index*), strok
		
	***************  1p1v step 2  *******************************
		scalar TMO = pt_no * `injcnt'                  		
	***************  1p1v end step 2  ***************************
			if TMO >1 {
				egen `maxinj' = max(`injcnt')
				gen `shapel' = 1 if `maxinj'==1
				gen `shapew'=0 if `maxinj'>=2
				keep `id2' index* `shapew' `shapel'
				}
			else {
				keep `id2' index* 
				}
			sort `id2'
		
	***************  1p1v step 3  *******************************
			if TMO == 1 {
				rename index1 index
				}
	***************  1p1v step 3  *******************************
	*Handle shape
	
	***************  1p1v step 4  *******************************	
			if TMO != 1 {											 
				if `shapew'==0	{									//If dataset wide, need to make it long
					reshape long index, i(`id2') j(ordinal)			//Dataset now long 
					drop if index==""
					}	
				else if `shapel'==1 {
					sort `id2'
					by `id2', sort: egen ordinal = seq()
					}
				}													 
	**************  1p1v end step 4  ****************************
			
		capture confirm string variable index
		if !_rc {
			}
		else {
			display in red "AIS codes must be of vartype string"
			exit
			}
		capture drop if index=="" | index=="."	
	***************  1p1v step 5  ********************************
		if TMO !=1 {											 
			quietly summarize ordinal
			scalar ADC = r(max)
			}													
	**************  1p1v end step 5  *****************************
	
	*Merge to get MARC values	
	
	**************  1p1v step 6  *******************************
		if TMO ==1 {											 		
			merge 1:1 index using "C:\ado\personal\aislookup.dta", force
			erase "C:\ado\personal\aislookup.dta"
			drop _merge index lexi  bodyregion
			gen pDeathais=normal((1.3138*marc)-(2.3281))
			lab var pDeathais "p(Death) AIS"
			drop marc
			drop if `id2'=="" 
			capture save "C:\ado\personal\tmpm1x1.dta", replace
		restore
			merge 1:1 `id2' using "C:\ado\personal\tmpm1x1.dta"
			capture drop index*
			drop _merge
		noisily display as txt "p(Death) estimation from AIS lexicon is complete"	
			exit
			}													 
	*****************  1p1v end step 6  ****************************
	
		else if TMO !=1 {	
			merge m:1 index using "C:\ado\personal\aislookup.dta", force
			erase "C:\ado\personal\aislookup.dta"
			drop if `id2'==""
			drop if _merge==2
			quietly count if _merge==3
			if ("`noreport'" =="") {
				noisily display as txt "Proportion of codes matched with marc values:  " %12.2f ((r(N)/_N)*100) "%"
				count if _merge==1
				if r(N) !=0 {
					gen unmatch=index if _merge==1 & (index!="." | index!="")
					lab var unmatch "Unmatched AIS Codes"
					noisily display as txt "Your unmatched AIS codes:"
					noisily tab unmatch
					drop unmatch
					}
				}	
			else if ("`noreport'" != "") {
				}
			by index, sort: gen unique= _n==1
			gen uniquematch = 1 if unique==1 & _merge==3
			quietly count if unique==1
			scalar uni1=r(N)
			quietly count if uniquematch==1
			scalar unim=r(N)
			if ("`noreport'" =="") {	
				noisily display
				noisily display as txt "Your data contain " uni1 " unique AIS codes"
				}
			else if ("`noreport'" != "") {
				}
			quietly {
			drop _merge uniquematch unique
			gsort `id2' -marc
			drop if marc==.
			drop if `id2'==""
			save "C:\ado\personal\temp1.dta", replace							//temp1
			use "C:\ado\personal\temp1.dta", replace
		*Deal with "same region"
			by `id2', sort: gen sr=_n
			drop if ordinal==. & `shapew'==0		//If master dataset was wide, need to drop 'ordinal' var
			keep if sr==1|sr==2							//keep two worst injuries
			keep `id2' sr bodyregion
			sort `id2' bodyregion
			reshape wide bodyregion, i(`id2') j(sr)			//spread them out wide 
			gen same_region=0
			if ADC>1 {
				replace same_region=1 if bodyregion1==bodyregion2	//generate same region
				}
			keep `id2' same_region
			drop if `id2'==""
			sort `id2'
			save "C:\ado\personal\temp2.dta", replace							//and save it temp2
		*Get marc data (again) and make it wide:
			use "C:\ado\personal\temp1.dta", replace
			keep `id2' marc
			gsort `id2' -marc
			drop if `id2'=="" 
			by `id2', sort: gen place=_n
			drop if place>5								//keep only 5 worst (highest) marc values
			reshape wide marc, i(`id2') j(place)			
			foreach var of varlist marc* {				//turn missing values to zeros	
					replace `var'=0	if `var'==.
					}
			sort `id2'
			merge 1:1 `id2' using "C:\ado\personal\temp2.dta"				//attach same_region
			drop _merge
			sort `id2'
			save "C:\ado\personal\temp3.dta", replace							//temp3
		*Get icd9 data (again) and make it wide:
			use "C:\ado\personal\temp1.dta", replace
			keep `id2' index marc 
			gsort `id2' -marc
			by `id2', sort: gen place=_n
			drop if place>5	
			drop marc									//keep only 5 worst (highest) marc values drop if `idvar'==""	| `idvar'==.				
			reshape wide index, i(`id2') j(place)
			sort `id2'
			merge 1:1 `id2' using "C:\ado\personal\temp3.dta"				//attach same_region
			drop _merge
			save "C:\ado\personal\temp4.dta", replace							//temp4
			if ADC < 5 {
				if ADC == 4 {
					gen marc5=0
					}
				if ADC == 3 {
					gen marc4=0
					gen marc5=0
					}
				if ADC == 2 {
					gen marc5=0
					gen marc4=0
					gen marc3=0	
					}
				if ADC == 1 {
					gen marc5=0
					gen marc4=0
					gen marc3=0	
					gen marc2=0
					}
				}
		*Calculate the model:
			gen Imarc=marc1*marc2						//generate the interaction term
				gen xBeta =	(1.3138*marc1)			+	///
						(1.5136* marc2)			+	///
						(0.4435* marc3)		+	///
						(0.4240* marc4)		+	///
						(0.6284* marc5)		+	///
						(-(0.1377)* same_region)	+	///
						(-(0.6506)* Imarc)		+	///
						-(2.3281)
			gen pDeathais =normal(xBeta)
			lab var pDeathais "p(Death) AIS"
			order `id2' pDeathais
			keep `id2' pDeathais
			sort `id2'
			save "C:\ado\personal\temp5.dta", replace							//temp5
			}
	restore											//Restores master dataset
		quietly {
			tempvar injcnt maxinj shapel shapew
			capture renpfix `aispfx' index
			egen `injcnt' = rownonmiss(index*), strok
			capture renpfix index `aispfx' 
			egen `maxinj' = max(`injcnt')
			gen `shapel' = 1 if `maxinj'==1         
			gen `shapew' = 0 if `maxinj'>=2		
			sort `id2'
		*Must again address master dataset shape
			if `shapew'==0 {
				merge 1:1 `id2' using "C:\ado\personal\temp5.dta", nogenerate norep	//Merges p(Death) values with original wide dataset 
					}
			else if `shapel'==1 {
				merge m:1 `id2' using "C:\ado\personal\temp5.dta", nogenerate norep	//Merges p(Death) values with original long dataset 																
					}
			} 
		noisily display
		noisily display as txt "p(Death) estimation from AIS lexicon is complete"
				erase "C:\ado\personal\temp1.dta"
				erase "C:\ado\personal\temp2.dta"
				erase "C:\ado\personal\temp3.dta"
				erase "C:\ado\personal\temp4.dta"	
				erase "C:\ado\personal\temp5.dta"
	}
	}
else if "`icd10pfx'" != "" {
		erase "C:\ado\personal\icd9lookup.dta"
		erase "C:\ado\personal\aislookup.dta"
		noisily {
		display  "________________________________________________________________"
		display  "Trauma Mortality Prediction Model p(Death) Estimation Module"
		display
		di in red "WARNING: The TMPM ICD-10 module is based on the NIH/CDC mapping"
		di        "algorithm and has not been evaluated empirically. The authors"
		di        "advise that it not be used for actual risk stratification." 
		display   "                                                                "
		di as text "Input Lexicon: ICD-10"
		di        "________________________________________________________________"
		} 
		tempvar id2
		gen `id2' = `idvar'
		capture tostring `id2', replace
	preserve
	
	***************  1p1v step 1  *******************************
		quietly count																			
		scalar pt_no = r(N)
	***************  1p1v end step 1  ***************************
		quietly {
		tempvar injcnt maxinj shapel shapew
		renpfix `icd10pfx' index
		egen `injcnt' = rownonmiss(index*), strok

	***************  1p1v step 2  *******************************
		scalar TMO = pt_no * `injcnt'                  		
	***************  1p1v end step 2  ***************************
		
			if TMO >1 {
				egen `maxinj' = max(`injcnt')
				gen `shapel' = 1 if `maxinj'==1
				gen `shapew'=0 if `maxinj'>=2
				keep `id2' index* `shapew' `shapel'
				}
			else {
				keep `id2' index* 
				}
			sort `id2'
		
	***************  1p1v step 3  *******************************
		if TMO == 1 {
			rename index1 index
			}
	***************  1p1v step 3  *******************************
		
	*Handle shape
	
	***************  1p1v step 4  *******************************	
		if TMO != 1 {											 
			if `shapew'==0	{									//If dataset wide, need to make it long
				reshape long index, i(`id2') j(ordinal)			//Dataset now long 
				drop if index==""
				}	
			else if `shapel'==1 {
				sort `id2'
				by `id2', sort: egen ordinal = seq()
				}
			}													 
	**************  1p1v end step 4  ****************************
			
		capture confirm string variable index
		if !_rc {
			}
		else {
			display
			display in red "ICD-10 codes must be of vartype string"
			exit
			}	
		capture drop if index=="" | index=="."
	
	***************  1p1v step 5  ********************************
		if TMO !=1 {											 
			quietly summarize ordinal
			scalar ADC = r(max)
			}													
	**************  1p1v end step 5  *****************************
	
	*Merge to get MARC values and body region values
	
	
	**************  1p1v step 6  *******************************
		if TMO ==1 {											 		
			merge 1:1 index using "C:\ado\personal\icd10lookup.dta", force
			}
			drop if `id2' == ""
			drop _merge index lexi  bodyregion
			gen pDeathicd9=normal((1.406958*marc)-(2.217565))
			lab var pDeathais "p(Death) ICD-10"
			capture save "C:\ado\personal\tmpm1x1.dta", replace
			restore
			merge 1:1 `id2' using "C:\ado\personal\tmpm1x1.dta"
			drop _merge xBeta marc
			erase "C:\ado\personal\tmpm1x1.dta"
		noisily display as txt "p(Death) estimation from ICD-10 lexicon is complete"	
			exit
			}													 
	*****************  1p1v end step 6  ****************************
		else if TMO !=1 {	
			merge m:1 index using "C:\ado\personal\icd10lookup.dta", force
			}
		erase "C:\ado\personal\icd10lookup.dta"
		drop if `id2'==""
		drop if _merge==2
		quietly count if _merge==3
		if ("`noreport'" =="") {
			noisily display
			noisily display as txt "Proportion of codes matched with marc values:  " %12.2f ((r(N)/_N)*100) "%"
			count if _merge==1
			if r(N) !=0 {
				gen unmatch=index if _merge==1 & (index!="." | index!="")
				lab var unmatch "Unmatched ICD-10 Codes"
				noisily display
				noisily display as txt "Your unmatched ICD-10 codes:"
				noisily tab unmatch
				drop unmatch
			}
			}	
		else if ("`noreport'" != "") {
		}
		by index, sort: gen unique= _n==1
		gen uniquematch = 1 if unique==1 & _merge==3
		quietly count if unique==1
		scalar uni1=r(N)
		quietly count if uniquematch==1
		scalar unim=r(N)
		if ("`noreport'" =="") {	
			noisily display
			noisily display as txt "Your data contain " uni1 " unique ICD-10 codes"
		}
		else if ("`noreport'" != "") {
		}
		quietly {
		drop _merge uniquematch unique
		gsort `id2' -marc
		drop if marc==.
		drop if `id2'==""
		save "C:\ado\personal\temp11.dta", replace							//temp11
		use "C:\ado\personal\temp11.dta", replace
	*Deal with "same region"
		by `id2', sort: gen sr=_n
		drop if ordinal==. & `shapew'==0		//If master dataset was wide, need to drop 'ordinal' var
		keep if sr==1|sr==2							//keep two worst injuries
		keep `id2' sr bodyregion
		sort `id2' bodyregion
		reshape wide bodyregion, i(`id2') j(sr)			//spread them out wide 
		gen same_region=0
		if ADC>1 {
			replace same_region=1 if bodyregion1==bodyregion2	//generate same region
			}
		keep `id2' same_region
		drop if `id2'==""
		sort `id2'
		save "C:\ado\personal\temp12.dta", replace							//and save it temp12
	*Get marc data (again) and make it wide:
		use "C:\ado\personal\temp11.dta", replace
		keep `id2' marc
		gsort `id2' -marc
		drop if `id2'=="" 
		by `id2', sort: gen place=_n
		drop if place>5								//keep only 5 worst (highest) marc values
		reshape wide marc, i(`id2') j(place)			
		foreach var of varlist marc* {				//turn missing values to zeros	
				replace `var'=0	if `var'==.
				}
		sort `id2'
		merge 1:1 `id2' using "C:\ado\personal\temp12.dta"				//attach same_region
		drop _merge
		sort `id2'
		save "C:\ado\personal\temp13.dta", replace							//temp13
	*Get icd9 data (again) and make it wide:
		use "C:\ado\personal\temp11.dta", replace
		keep `id2' index marc 
		gsort `id2' -marc
		by `id2', sort: gen place=_n
		drop if place>5	
		drop marc									//keep only 5 worst (highest) marc values drop if `id2'==""	| `id2'==.				
		reshape wide index, i(`id2') j(place)
		sort `id2'
		merge 1:1 `id2' using "C:\ado\personal\temp13.dta"				//attach same_region
		drop _merge
		save "C:\ado\personal\temp14.dta", replace							//temp14
		if ADC < 5 {
			if ADC == 4 {
				gen marc5=0
				}
			if ADC == 3 {
				gen marc4=0
				gen marc5=0
				}
			if ADC == 2 {
				gen marc5=0
				gen marc4=0
				gen marc3=0	
				}
			if ADC == 1 {
				gen marc5=0
				gen marc4=0
				gen marc3=0	
				gen marc2=0
				}
			}
	*Calculate the model:
		gen Imarc=marc1*marc2						//generate the interaction term
			gen xBeta =	(1.406958*marc1)			+	///
					(1.409992* marc2)			+	///
					(0.5205343* marc3)		+	///
					(0.4150946* marc4)		+	///
					(0.8883929* marc5)		+	///
					(-(0.0890527)* same_region)	+	///
					(-(0.7782696)* Imarc)		+	///
					-(2.217565)
		gen pDeathicd10=normal(xBeta)
		lab var pDeathicd10 "p(Death) ICD-10"
		order `id2' pDeathicd10
		keep `id2' pDeathicd10
		sort `id2'
		save "C:\ado\personal\temp15.dta", replace							//temp15
		}
	restore											//Restores master dataset
		quietly {
		tempvar injcnt maxinj shapel shapew
		renpfix `icd10pfx' index
		egen `injcnt' = rownonmiss(index*), strok
		renpfix index `icd10pfx'
		egen `maxinj' = max(`injcnt')
		gen `shapel' = 1 if `maxinj'==1         
		gen `shapew' = 0 if `maxinj'>=2		
		sort `id2'
	*Must again address master dataset shape
		if `shapew'==0 {
			merge 1:1 `id2' using "C:\ado\personal\temp15.dta", nogenerate norep	//Merges p(Death) values with original wide dataset 
				}
		else if `shapel'==1 {
			merge m:1 `id2' using "C:\ado\personal\temp15.dta", nogenerate norep	//Merges p(Death) values with original long dataset 																
				}
	}
	
	noisily display 
	noisily display as txt "p(Death) estimation from ICD-10 lexicon is complete"
			erase "C:\ado\personal\temp11.dta"
			erase "C:\ado\personal\temp12.dta"
			erase "C:\ado\personal\temp13.dta"
			erase "C:\ado\personal\temp14.dta"
			erase "C:\ado\personal\temp15.dta"
	}
	}
end
exit
