
capture program drop charlson
program define charlson, byable(recall)
version 9.0
syntax [varlist] [if] [in], index(string) ///
[idvar(varname) diagprfx(string)  assign0 wtchrl cmorb noshow]
marksample touse, novarlist
keep if `touse'
display "COMORBIDITY INDEX MACRO"
display "Providing COMORBIDITY INDEX Summary"
if "`show'" != "noshow" {
display "OPTIONS SELECTED: "
if "`index'" == "c" {
	display "INPUT DATA:   Charlson ICD-9-CM"
	}
	else if "`index'" == "e" {
		display "INPUT DATA:   Enhanced ICD-9-CM"
		}
		else if "`index'" == "10" {
			display "INPUT DATA:   Quan ICD-10"
}
if "`idvar'" != "" {
	display "OBSERVATIONAL UNIT: Patients"
	}
	else {
		display "OBSERVATIONAL UNIT: Visits"
		}
display "ID VARIABLE NAME (Given only if Unit is Patients): `idvar'"
display "PREFIX of COMORBIDITY VARIABLES:  `diagprfx'"
if "`assign0'"=="" {
      display "HIERARCHY METHOD APPLIED: NO"
      }
      else {
       display "HIERARCHY METHOD APPLIED: YES"
}
if "`wtchrl'"=="" {
      display "SUMMARIZE CHARLSON INDEX and WEIGHTS: NO"
      }
      else {
       display "SUMMARIZE CHARLSON INDEX and WEIGHTS: YES"
}
if "`cmorb'"=="" {
      display "SUMMARIZE INDIVIDUAL COMORBIDITIES: NO"
      }
      else {
       display "SUMMARIZE INDIVIDUAL COMORBIDITIES: YES"
}
}
set more off
capture drop weightch1-weightch17 
capture drop ynch1-ynch17
capture drop charlindex grpci
capture label drop ynlab

display "Please wait. Thank you!"

  forvalues i=1/17 {
    gen ch`i'=0
   }

  if "`diagprfx'" != "" {
  	unab varlist: `diagprfx'*
  	}	

  local ord = 1
  local n : word count `varlist'
  display "Program takes a few minutes - there are up to `n' ICD codes per subject."
  while `ord' <= `n' {
     local cmb : word `ord' of `varlist'

 display "Iteration `ord' of `n' - Program is running - Please wait"

*Acute Myocardial Infarction
if "`index'"=="c" {
	quietly replace ch1=1 if inlist(substr(`cmb',1,3), "410" , "412")
	}
else if "`index'"=="e" {
	quietly replace ch1=1 if inlist(substr(`cmb',1,3),"410","412")
	}
else if "`index'"=="10" {
	quietly replace ch1=1 if inlist(substr(`cmb',1,3),"I21","I22") | /*
*/ inlist(substr(`cmb',1,4),"I252")
}

*Congestive Heart Failure
if "`index'"=="c" {
      quietly replace ch2=1 if inlist(substr(`cmb',1,3), "428")
	}
else if "`index'"=="e" {  
	quietly replace ch2=1 if inlist(substr(`cmb',1,5),"39891","40201", "40211", "40291", "40401", "40403", "40411") | /*
*/ inlist(substr(`cmb',1,5),"40413", "40491", "40493") | /*
*/ inlist(substr(`cmb',1,4),"4254", "4255", "4257","4258","4259")| /*
*/ inlist(substr(`cmb',1,3),"428")
	}
else if "`index'"=="10" {
	quietly replace ch2=1 if inlist(substr(`cmb',1,3),"I43","I50") | /*
*/ inlist(substr(`cmb',1,4),"I099", "I110", "I130", "I132","I255","I420", "I425", "I426", "I427") | /*
*/ inlist(substr(`cmb',1,4),"I428", "I429", "P290")
	}

*Peripheral Vascular Disease
if "`index'"=="c" {
	quietly replace ch3=1 if inlist(substr(`cmb',1,4), "4439","V434","7854") | /*
*/ inlist(substr(`cmb',1,3),"441")	
	}
else if "`index'"=="e" {
     quietly replace ch3=1 if inlist(substr(`cmb',1,4),"0930", "4373") | /*
*/ inlist(substr(`cmb',1,3),"440","441") | /*
*/ inlist(substr(`cmb',1,4),"4431", "4432", "4438", "4439", "4471") | /*
*/ inlist(substr(`cmb',1,4),"5571", "5579", "V434")
	}
else if "`index'"=="10" {
	quietly replace ch3=1 if inlist(substr(`cmb',1,3),"I70", "I71") | /*
*/ inlist(substr(`cmb',1,4),"I731","I738", "I739", "I771", "I790", "I792", "K551", "K558","K559") | /*
*/ inlist(substr(`cmb',1,4) , "Z958", "Z959")
	}

*Cerebrovascular Disease
if "`index'"=="c" {
	quietly replace ch4=1 if inlist(substr(`cmb',1,3), "430", "431", "432", "433", "434", "435", "436","437", "438")
	}
else if "`index'"=="e" {
     quietly replace ch4=1 if inlist(substr(`cmb',1,5), "36234") | /*
*/ inlist(substr(`cmb',1,3),"430","431","432", "433", "434", "435", "436", "437", "438")
	}
else if "`index'"=="10" {
	quietly replace ch4=1 if inlist(substr(`cmb',1,3), "G45", "G46", "I60", "I61", "I62", "I63") | /*
*/ inlist(substr(`cmb',1,3),"I64","I65","I66", "I67", "I68", "I69") | /*
*/ inlist(substr(`cmb',1,4),"H340")
}

*Dementia
if "`index'"=="c" {
	quietly replace ch5=1 if inlist(substr(`cmb',1,3), "290")
	}
else if "`index'"=="e" {
     quietly replace ch5=1 if inlist(substr(`cmb',1,3),"290") | /*
*/ inlist(substr(`cmb',1,4), "2941", "3312")
	}
else if "`index'"=="10" {
	quietly replace ch5=1 if inlist(substr(`cmb',1,3),"F00", "F01", "F02", "F03", "G30") | /*
*/ inlist(substr(`cmb',1,4), "F051", "G311")
}

*Chronic Pulmonary Disease
if "`index'"=="c" {
	quietly replace ch6=1 if inlist(substr(`cmb',1,3), "490","491","492","493","494","495","496","500","501") | /*
*/ inlist(substr(`cmb',1,3), "502", "503", "504", "505") | /*
*/ inlist(substr(`cmb',1,4), "5064")
	}
else if "`index'"=="e" {
     quietly replace ch6=1 if inlist(substr(`cmb',1,4),"4168", "4169", "5064", "5081", "5088") | /*
*/ inlist(substr(`cmb',1,3),"490", "491", "492", "493", "494", "495", "496") | /*
*/ inlist(substr(`cmb',1,3),"500", "501", "502", "503", "504", "505")
	}
else if "`index'"=="10" {
     quietly replace ch6=1 if inlist(substr(`cmb',1,3),"J40", "J41", "J42", "J43", "J44", "J45", "J46", "J47") | /*
*/ inlist(substr(`cmb',1,3),"J60", "J61", "J62", "J63", "J64", "J65", "J66", "J67") | /*
*/ inlist(substr(`cmb',1,4),"I278", "I279", "J684", "J701", "J703")
}

*Rheumatologic Disease (Connective Tissue Disease) - 
if "`index'"=="c" {
	quietly replace ch7=1 if inlist(substr(`cmb',1,4), "7100", "7101", "7104", "7140", "7141", "7142") | /*
*/ inlist(substr(`cmb',1,3),"725") | /*
*/ inlist(substr(`cmb',1,5), "71481")
	}
else if "`index'"=="e" {
     quietly replace ch7=1 if inlist(substr(`cmb',1,4),"4465", "7100", "7101", "7102", "7103", "7104") | /*
*/ inlist(substr(`cmb',1,4),"7140", "7141", "7142", "7148") | /*
*/ inlist(substr(`cmb',1,3),"725")
	}
else if "`index'"=="10" {
quietly replace ch7=1 if inlist(substr(`cmb',1,3),"M05", "M32", "M33", "M34", "M06") | /*
*/ inlist(substr(`cmb',1,4),"M315", "M351", "M353", "M360")
}

*Peptic Ulcer Disease
if "`index'"=="c" {
quietly replace ch8=1 if inlist(substr(`cmb',1,3), "531", "532", "533", "534") 
	}
else if "`index'"=="e" {
     quietly replace ch8=1 if inlist(substr(`cmb',1,3),"531","532", "533","534") 
	}
else if "`index'"=="10" {
     quietly replace ch8=1 if inlist(substr(`cmb',1,3),"K25","K26", "K27","K28") 
}

*Mild Liver Disease 
if "`index'"=="c" {
	quietly replace ch9=1 if inlist(substr(`cmb',1,4),"5712", "5714","5715","5716") | /*
*/ inlist(substr(`cmb',1,5),"57140", "57141", "57149") 
	}
else if "`index'"=="e" {
     quietly replace ch9=1 if inlist(substr(`cmb',1,5), "07022","07023","07032", "07033", "07044", "07054") | /* 
*/ inlist(substr(`cmb',1,4),"0706", "0709", "5733", "5734", "5738", "5739", "V427") | /*
*/ inlist(substr(`cmb',1,3),"570", "571") 
	}
else if "`index'"=="10" {
     quietly replace ch9=1 if inlist(substr(`cmb',1,3), "B18",  "K73",  "K74") | /* 
*/ inlist(substr(`cmb',1,4),"K700", "K701", "K702", "K703", "K709", "K713", "K714", "K715", "K717") | /*
*/ inlist(substr(`cmb',1,4),"K760", "K762", "K763", "K764", "K768", "K769", "Z944") 
}

*Diabetes without complications
if "`index'"=="c" {
	quietly replace ch10=1 if inlist(substr(`cmb',1,4), "2500", "2501", "2502", "2503", "2507")
	}
else if "`index'"=="e" {
     quietly replace ch10=1 if inlist(substr(`cmb',1,4),"2500", "2501", "2502", "2503", "2508", "2509")
	}
else if "`index'"=="10" {
quietly replace ch10=1 if inlist(substr(`cmb',1,4),"E100", "E101", "E106", "E108", "E109") | /*
*/ inlist(substr(`cmb',1,4),"E110", "E111", "E116", "E118", "E119", "E120", "E121", "E126", "E128") | /*
*/ inlist(substr(`cmb',1,4),"E129","E130", "E131", "E136", "E138", "E139", "E140", "E141") | /*
*/ inlist(substr(`cmb',1,4),"E146", "E148", "E149")
}

*Diabetes with chronic complications
if "`index'"=="c" {
	quietly replace ch11=1 if inlist(substr(`cmb',1,4), "2504", "2505", "2506") 
	}
else if "`index'"=="e" {
     quietly replace ch11=1 if inlist(substr(`cmb',1,4),"2504","2505", "2506", "2507") 
	}
else if "`index'"=="10" {
	quietly replace ch11=1 if inlist(substr(`cmb',1,4),"E102","E103", "E104", "E105", "E107", "E112") | /*
*/ inlist(substr(`cmb',1,4),"E113" , "E114", "E115", "E117", "E122", "E123", "E124", "E125") | /*
*/ inlist(substr(`cmb',1,4), "E127","E132", "E133", "E134", "E135", "E137", "E142") | /*
*/ inlist(substr(`cmb',1,4), "E143", "E144", "E145", "E147")
}

*Hemiplegia or Paraplegia
if "`index'"=="c" {
     quietly replace ch12=1 if inlist(substr(`cmb',1,3), "342") | /*
*/ inlist(substr(`cmb',1,4), "3441") 
	}
else if "`index'"=="e" {
     quietly replace ch12=1 if inlist(substr(`cmb',1,3),"342", "343") | /*
*/  inlist(substr(`cmb',1,4), "3341", "3440", "3441", "3442", "3443", "3444", "3445", "3446", "3449")
	}
else if "`index'"=="10" {
   quietly replace ch12=1 if inlist(substr(`cmb',1,3),"G81", "G82") | /*
*/  inlist(substr(`cmb',1,4), "G041", "G114", "G801", "G802", "G830", "G831", "G832", "G833", "G834") | /*
*/  inlist(substr(`cmb',1,4), "G839")
}

*Renal Disease
if "`index'"=="c" {
     quietly replace ch13=1 if inlist(substr(`cmb',1,4),"5830","5831","5832","5834","5836","5837") | /*
*/ inlist(substr(`cmb',1,3),"582", "585", "586", "588")
	}
else if "`index'"=="e" {
     quietly replace ch13=1 if inlist(substr(`cmb',1,3), "582", "585", "586", "V56") | /*
*/ inlist(substr(`cmb',1,4), "5830", "5831", "5832", "5834", "5836", "5837") | /*
*/ inlist(substr(`cmb',1,4), "5880", "V420", "V451") | /*
*/ inlist(substr(`cmb',1,5), "40301", "40311", "40391", "40402", "40403", "40412", "40413", "40492", "40493")
	}
else if "`index'"=="10" {
     quietly replace ch13=1 if inlist(substr(`cmb',1,3), "N18", "N19") | /*
*/ inlist(substr(`cmb',1,4), "N052", "N053", "N054", "N055", "N056", "N057", "N250") | /*
*/ inlist(substr(`cmb',1,4), "I120", "I131", "N032", "N033", "N034", "N035", "N036", "N037") | /*
*/ inlist(substr(`cmb',1,4), "Z490", "Z491", "Z492", "Z940", "Z992")
}

*Cancer
if "`index'"=="c" {
   quietly replace ch14=1 if (substr(`cmb',1,3)>="140" & substr(`cmb',1,3)<="172") |     /* 
*/ (substr(`cmb',1,3)>="174" & substr(`cmb',1,3)<="195") |  /*
*/ (substr(`cmb',1,3)>="200" & substr(`cmb',1,3)<="208")
	}
else if "`index'"=="e" {
   quietly replace ch14=1 if inlist(substr(`cmb',1,3), "140","141","142","143","144","145","146","147","148") | /* 
*/ inlist(substr(`cmb',1,3), "149","150","151","152","153","154","155","156","157") | /*
*/ inlist(substr(`cmb',1,3), "158","159","160","161","162","163","164","165","170") | /*
*/ inlist(substr(`cmb',1,3), "171","172","174","175","176","179","180","181","182") | /*
*/ inlist(substr(`cmb',1,3), "183","184","185","186","187","188","189","190","191") | /*
*/ inlist(substr(`cmb',1,3), "192","193","194","195","200","201","202","203","204") | /*
*/ inlist(substr(`cmb',1,3),"205","206","207","208") | /*
*/ inlist(substr(`cmb',1,4),"2386") 
	}
else if "`index'"=="10" {
   quietly replace ch14=1 if inlist(substr(`cmb',1,3), "C00", "C01", "C02", "C03", "C04", "C05", "C06", "C07") | /* 
*/ inlist(substr(`cmb',1,3),"C08", "C09", "C10", "C11", "C12", "C13", "C14") | /*
*/ inlist(substr(`cmb',1,3),"C15", "C16", "C17", "C18", "C19" ) | /*
*/ inlist(substr(`cmb',1,3),"C20", "C21", "C22", "C23", "C24", "C25", "C26" ) | /*
*/ inlist(substr(`cmb',1,3),"C30", "C31", "C32", "C33", "C34", "C37", "C38", "C39" ) | /*
*/ inlist(substr(`cmb',1,3),"C40", "C41", "C43", "C45", "C46", "C47", "C48", "C49", "C50") | /*
*/ inlist(substr(`cmb',1,3),"C51", "C52", "C53", "C54", "C55", "C56", "C57", "C58", "C60") | /*
*/ inlist(substr(`cmb',1,3),"C61", "C62", "C63", "C64", "C65", "C66", "C67", "C68", "C69") | /*
*/ inlist(substr(`cmb',1,3),"C70", "C71", "C72", "C73", "C74", "C75", "C76") | /*
*/ inlist(substr(`cmb',1,3),"C81", "C82", "C83", "C84", "C85", "C88") | /*
*/ inlist(substr(`cmb',1,3),"C90", "C91", "C92", "C93", "C94", "C95", "C96", "C97")
} 

*Moderate or Severe Liver Disease
if "`index'"=="c" {
   quietly replace ch15=1 if inlist(substr(`cmb',1,4), "5722", "5723", "5724", "5728") | /*	
*/ inlist(substr(`cmb',1,4), "4560", "4561", "4562") | /*
*/ inlist(substr(`cmb',1,5), "45620", "45621")
	}
else if "`index'"=="e" {
   quietly replace ch15=1 if inlist(substr(`cmb',1,4), "4560","4561","4562","5722","5723","5724","5728") 
	}
else if "`index'"=="10" {
   quietly replace ch15=1 if inlist(substr(`cmb',1,4), "K704", "K711", "K721", "K729", "K765", "K766", "K767") | /*
*/ inlist(substr(`cmb',1,4), "I850", "I859", "I864", "I982")
}

*Metastatic Carcinoma
if "`index'"=="c" {
	quietly replace ch16=1 if inlist(substr(`cmb',1,3), "196", "197", "198", "199")
	}
else if "`index'"=="e" {
     quietly replace ch16=1 if inlist(substr(`cmb',1,3), "196","197","198","199")
	}
else if "`index'"=="10" {
     quietly replace ch16=1 if inlist(substr(`cmb',1,3), "C77", "C78", "C79", "C80")
}

*AIDS/HIV
if "`index'"=="c" {
	quietly replace ch17=1 if inlist(substr(`cmb',1,3), "042", "043", "044")
	}
else if "`index'"=="e" {
     quietly replace ch17=1 if inlist(substr(`cmb',1,3), "042","043","044")
	}
else if "`index'"=="10" {
     quietly replace ch17=1 if inlist(substr(`cmb',1,3),"B20", "B21", "B22", "B24")
}

     local ord=`ord'+1
   }

*hierarchy adjustments
***************************** 
if "`assign0'" != "" {
 quietly replace ch9=0 if ch15>0 & ch9>0
 quietly replace ch10=0 if ch11>0 & ch10>0
 quietly replace ch14=0 if ch16>0 & ch14>0 
 }
*****************************


*SUM THE FREQUENCIES of COMORBIDITIES over multiple patient records for each comobidity group
*Each ynchi will be 0 or 1, indicating absence or presence of comorbidity
*If multiple patient records, i.e. idvar option present

if "`idvar'" != "" {
bysort `idvar': egen ynch1 = max(ch1)
bysort `idvar': egen ynch2 = max(ch2)
bysort `idvar': egen ynch3 = max(ch3)
bysort `idvar': egen ynch4 = max(ch4)
bysort `idvar': egen ynch5 = max(ch5)
bysort `idvar': egen ynch6 = max(ch6)
bysort `idvar': egen ynch7 = max(ch7)
bysort `idvar': egen ynch8 = max(ch8)
bysort `idvar': egen ynch9 = max(ch9)
bysort `idvar': egen ynch10 = max(ch10)
bysort `idvar': egen ynch11 = max(ch11)
bysort `idvar': egen ynch12 = max(ch12)
bysort `idvar': egen ynch13 = max(ch13)
bysort `idvar': egen ynch14 = max(ch14)
bysort `idvar': egen ynch15 = max(ch15)
bysort `idvar': egen ynch16 = max(ch16)
bysort `idvar': egen ynch17 = max(ch17)
*RETAIN ONLY LAST OBSERVATION FOR EACH PATIENT	
	set output error /*To prevent statement re number of deleted observations being printed*/
	bysort `idvar':  keep if _n == _N
	set output proc /*Return to default messages*/
	
	keep `idvar' ynch1-ynch17
	}
	else {
		forvalues i=1/17 {
			rename ch`i' ynch`i'
			}
		}
	label define ynlab 0 "Absent" 1 "Present"
 	forvalues i=1/17 {
		label values ynch`i' ynlab
		}
display "Total Number of Observational Units (Visits OR Patients): " _N 

*If multiple records per patient retain only newly created binary comorbidity variables
*Otherwise retain all input data as well
		
*charlson index calculated from sum of weighted comorbidities

  forvalues i=1/17 {
    gen weightch`i'=0
    quietly replace weightch`i'=1 if ynch`i'==1
    }
  
*Change weights for more serious comorbidites (for calculation of charlson index, based on sum of weights)

  quietly replace weightch11=2 if ynch11>0
  quietly replace weightch12=2 if ynch12>0
  quietly replace weightch13=2 if ynch13>0
  quietly replace weightch14=2 if ynch14>0
  quietly replace weightch15=3 if ynch15>0
  quietly replace weightch16=6 if ynch16>0
  quietly replace weightch17=6 if ynch17>0

  egen charlindex=rsum(weightch*)

  gen grpci=0
  quietly replace grpci=1 if charlindex==1
  quietly replace grpci=2 if charlindex>=2
 
label var ynch1 "AMI (Acute Myocardial)"
  label var ynch2 "CHF (Congestive Heart)"
  label var ynch3 "PVD (Peripheral Vascular)"
  label var ynch4 "CEVD (Cerebrovascular"
  label var ynch5 "Dementia"
  label var ynch6 "COPD (Chronic Obstructive Pulmonary)"
  label var ynch7 "Rheumatoid Disease"
  label var ynch8 "PUD (Peptic Ulcer)"
  label var ynch9 "Mild LD (Liver)"
  label var ynch10 "Diabetes"
  label var ynch11 "Diabetes + Complications"
  label var ynch12 "HP/PAPL (Hemiplegia or Paraplegia)"
  label var ynch13 "RD (Renal)"
  label var ynch14 "Cancer"
  label var ynch15 "Moderate/Severe LD (Liver)"
  label var ynch16 "Metastatic Cancer"
  label var ynch17 "AIDS"

  label var charlindex "CHARLSON INDEX"
  label var grpci "GROUPED CHARLSON INDEX"
  
*Advise to check version of input data, in case of no recognized comorbidities
  egen smchindx = sum(grpci)
  if smchindx == 0 {
	display "NOTE: NO RECOGNIZED COMORBIDITY CODES - "
	display "Please check VERSION of input data and icd option."
	}

*Output summaries as requested
  
  if "`wtchrl'" != "" {
    
    tab charlindex 
    tab grpci 
    sum charlindex 
    }
  
 forvalues i=1/17 {
    if "`cmorb'" != "" {
    tab ynch`i'
      }
}
 
drop smchindx 

end



