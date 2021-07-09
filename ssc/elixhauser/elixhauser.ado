capture program drop elixhauser

program define elixhauser, byable(recall)
*set trace on

version 9.0

syntax [varlist] [if] [in], index(string) ///
[idvar(varname) diagprfx(string)smelix cmorb noshow]

* For ICD-10 (Dr. Hude Quan) or Enhanced ICD-9-CM data

marksample touse, novarlist
keep if `touse'
display "ELIXHAUSER COMORBIDITY MACRO"
display "Providing Summary of Elixhauser Codes"
if "`show'" != "noshow" { 
display "OPTIONS SELECTED: "
if "`index'" == "e" {
	display "INPUT DATA:   Enhanced ICD-9"
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
if "`smelix'"=="" {
      display "SUMMARIZE ELIXHAUSER INDEX SUM: NO"
      }
      else {
       display "SUMMARIZE ELIXHAUSER INDEX SUM: YES"
}
if "`cmorb'"=="" {
      display "SUMMARIZE INDIVIDUAL COMORBIDITIES: NO"
      }
      else {
       display "SUMMARIZE INDIVIDUAL COMORBIDITIES: YES"
}
}
set more off
capture drop ynel1-ynel31
capture drop weightel1-weightel31 elixsum
capture label drop ynlab

display "Please wait. Thank you!"

  forvalues i=1/31 {
    gen el`i'=0
   }

  if "`diagprfx'" != "" {
  	unab varlist: `diagprfx'*
  	}	

  local ord = 1
  local n : word count `varlist'
  display "Program takes a few minutes - there are up to `n' ICD-`index' codes per subject."
  while `ord' <= `n' {
     local elx : word `ord' of `varlist'

 display "Iteration `ord' of `n' - Program is running - Please wait"

*Congestive Heart Failure
if "`index'"=="e" {
	quietly replace el1=1 if inlist(substr(`elx',1,5), "39891","40201","40211","40291","40401") | /*
*/ inlist(substr(`elx',1,5),"40403","40411","40413","40491","40493") | /*
*/ inlist(substr(`elx',1,4),"4254","4255","4257","4258","4259") | /*
*/ inlist(substr(`elx',1,3),"428")
      }
else if "`index'"=="10" {
	quietly replace el1=1 if inlist(substr(`elx',1,3), "I43","I50") | /*
*/ inlist(substr(`elx',1,4), "I099", "I110", "I130", "I132","I255","I420", "I425", "I426", "I427") | /*
*/ inlist(substr(`elx',1,4), "I428", "I429", "P290")
	}

*Cardiac Arrhythmias
if "`index'"=="e" {
	quietly replace el2=1 if inlist(substr(`elx',1,5), "42613","42610","42612","99601","99604") | /*
*/ inlist(substr(`elx',1,4),"4260","4267","4269","4270","4271","4272") | /*
*/ inlist(substr(`elx',1,4),"4273","4274","4276","4278","4279","7850","V450","V533")
      }
else if "`index'"=="10" {
	quietly replace el2=1 if inlist(substr(`elx',1,4), "I441","I442","I443","I456","I459","R000","R001","R008","T821")| /*
*/ inlist(substr(`elx',1,4), "Z450", "Z950") | /*
*/ inlist(substr(`elx',1,3), "I47", "I48", "I49")
      }

*Valvular Disease
if "`index'"=="e" {
	quietly replace el3=1 if inlist(substr(`elx',1,4), "0932","7463","7464","7465","7466","V422","V433") | /*
*/ inlist(substr(`elx',1,3),"394","395","396","397","424")
      }
else if "`index'"=="10" {
	quietly replace el3=1 if inlist(substr(`elx',1,4), "A520","I091","I098","Q230","Q231","Q232","Q233","Z952","Z953") |/*
*/ inlist(substr(`elx',1,4), "Z954")| /*
*/ inlist(substr(`elx',1,3), "I05","I06","I07","I08","I34","I35","I36","I37","I38") | /*
*/ inlist(substr(`elx',1,3), "I39")
      }

*Pulmonary Circulation Disorders
if "`index'"=="e" {
	quietly replace el4=1 if inlist(substr(`elx',1,3), "416") | /*
*/ inlist(substr(`elx',1,4),"4150","4151","4170","4178","4179")
      }
else if "`index'"=="10" {
	quietly replace el4=1 if inlist(substr(`elx',1,3), "I26", "I27") | /*
*/ inlist(substr(`elx',1,4), "I280", "I288", "I289")
      }

*Peripheral Vascular Disorders
if "`index'"=="e" {
	quietly replace el5=1 if inlist(substr(`elx',1,4), "0930","4373","4431","4432","4438") | /*
*/ inlist(substr(`elx',1,4),"4439","4471","5571","5579","V434") | /*
*/ inlist(substr(`elx',1,3),"440","441")
	}
else if "`index'"=="10" {
	quietly replace el5=1 if inlist(substr(`elx',1,3), "I70", "I71") | /*
*/ inlist(substr(`elx',1,4), "I731","I738", "I739", "I771", "I790", "I792", "K551", "K558","K559") | /*
*/ inlist(substr(`elx',1,4), "Z958", "Z959")
	}

*Hypertension, uncomplicated"
if "`index'"=="e" {
	quietly replace el6=1 if inlist(substr(`elx',1,3),"401")
      }
else if "`index'"=="10" {
      quietly replace el6=1 if inlist(substr(`elx',1,3), "I10")
      }

*Paralysis
if "`index'"=="e" {
	quietly replace el7=1 if inlist(substr(`elx',1,4),"3341","3440","3441","3442","3443","3444","3445","3446","3449") | /*
*/ inlist(substr(`elx',1,3),"342","343")
      }
else if "`index'"=="10" {
      quietly replace el7=1 if inlist(substr(`elx',1,4), "G041","G114","G801","G802","G830","G831","G832","G833","G834") | /*
*/ inlist(substr(`elx',1,4), "G839")| /*
*/ inlist(substr(`elx',1,3), "G81", "G82")
      }

*Other Neurological Disorders
if "`index'"=="e" {
	quietly replace el8=1 if inlist(substr(`elx',1,5),"33392") | /*
*/ inlist(substr(`elx',1,4),"3319","3320","3321","3334","3335") | /*
*/ inlist(substr(`elx',1,4),"3481","3483","7803","7843","3362") | /*
*/ inlist(substr(`elx',1,3),"334","335","340","341","345")
      }
else if "`index'"=="10" {
      quietly replace el8=1 if inlist(substr(`elx',1,4), "G254","G255","G312","G318","G319","G931","G934","R470")| /*
*/ inlist(substr(`elx',1,3), "G10","G11","G12","G13","G20","G21","G22","G32") | /*
*/ inlist(substr(`elx',1,3), "G35","G36","G37","G40","G41","R56")
      }

*Chronic Pulmonary Disease 
if "`index'"=="e" {
	quietly replace el9=1 if inlist(substr(`elx',1,4),"4168","4169","5064","5081","5088")  | /*
*/ inlist(substr(`elx',1,3),"490","491","492","493","494","495","496") | /*
*/ inlist(substr(`elx',1,3),"500","501","502","503","504","505")
      }
else if "`index'"=="10" {
      quietly replace el9=1 if inlist(substr(`elx',1,4), "I278","I279","J684","J701","J703")| /*
*/ inlist(substr(`elx',1,3), "J40","J41","J42","J43","J44","J45","J46","J47","J60") | /*
*/ inlist(substr(`elx',1,3), "J61","J62","J63","J64","J65","J66","J67")
      }

*Diabetes,Uncomplicated
if "`index'"=="e" {
	quietly replace el10=1 if inlist(substr(`elx',1,4),"2500","2501","2502","2503")
      }
else if "`index'"=="10" {
      quietly replace el10=1 if inlist(substr(`elx',1,4), "E100","E101","E109","E110","E111","E119","E120","E121","E129") | /*
*/ inlist(substr(`elx',1,4), "E130", "E131","E139","E140","E141","E149")
      }

*Diabetes,complicated 
if "`index'"=="e" {
	quietly replace el11=1 if inlist(substr(`elx',1,4),"2504","2505","2506","2507","2508","2509")
      }
else if "`index'"=="10" {
      quietly replace el11=1 if inlist(substr(`elx',1,4), "E102","E103","E104","E105","E106","E107","E108","E112","E113") | /*
*/ inlist(substr(`elx',1,4), "E114","E115","E116","E117","E118","E122","E123","E124") | /*
*/ inlist(substr(`elx',1,4), "E125","E126","E127","E128","E132","E133") | /*
*/ inlist(substr(`elx',1,4), "E134","E135","E136","E137","E138","E142","E143","E144","E145") | /*
*/ inlist(substr(`elx',1,4), "E146","E147","E148")
      }

*Hypothyroidism
if "`index'"=="e" {
	quietly replace el12=1 if inlist(substr(`elx',1,4), "2409","2461","2468") | /*
*/ inlist(substr(`elx',1,3),"243","244")
      }
else if "`index'"=="10" {
      quietly replace el12=1 if inlist(substr(`elx',1,3), "E00","E01","E02","E03") | /*
*/ inlist(substr(`elx',1,4),"E890")
      }

*Renal Failure
if "`index'"=="e" {
	quietly replace el13=1 if inlist(substr(`elx',1,5), "40301","40311","40391","40402","40403") | /*
*/ inlist(substr(`elx',1,5),"40412","40413","40492","40493") | /*
*/ inlist(substr(`elx',1,4),"5880","V420","V451") | /*
*/ inlist(substr(`elx',1,3),"585","586","V56")
      }
else if "`index'"=="10" {
      quietly replace el13=1 if inlist(substr(`elx',1,4), "I120", "I131","N250","Z490","Z491","Z492","Z940","Z992")| /*
*/ inlist(substr(`elx',1,3), "N18","N19")
      }

*Liver disease
if "`index'"=="e" {
	quietly replace el14=1 if inlist(substr(`elx',1,5), "07022","07023","07032","07033","07044","07054") | /*
*/ inlist(substr(`elx',1,4),"0706","0709","4560","4561","4562","5722","5723") | /*
*/ inlist(substr(`elx',1,4),"5724","5728","5733","5734","5738","5739","V427") | /*
*/ inlist(substr(`elx',1,3),"570","571")
      }
else if "`index'"=="10" {
      quietly replace el14=1 if inlist(substr(`elx',1,4), "I864","I982","K711","K713","K714","K715","K717","K760","K762") | /*
*/ inlist(substr(`elx',1,4), "K763","K764","K765","K766","K767","K768","K769","Z944")| /*
*/ inlist(substr(`elx',1,3), "K70", "K72","K73","K74","B18","I85")
      }

*Peptic Ulcer Disease Excluding Bleeding
 if "`index'"=="e" {
	quietly replace el15=1 if inlist(substr(`elx',1,4),"5317","5319","5327","5329","5337","5339","5347","5349")
      }
else if "`index'"=="10" {
      quietly replace el15=1 if inlist(substr(`elx',1,4), "K257","K259","K267","K269","K277","K279","K287","K289")
      }

*AIDS/HIV
if "`index'"=="e" {
	quietly replace el16=1 if inlist(substr(`elx',1,3), "042","043","044")
      }
else if "`index'"=="10" {
      quietly replace el16=1 if inlist(substr(`elx',1,3), "B20", "B21","B22","B24")
      }

*Lymphoma
if "`index'"=="e" {
	quietly replace el17=1 if inlist(substr(`elx',1,3), "200","201","202") | /*
*/ inlist(substr(`elx',1,4),"2030","2386")
      }
else if "`index'"=="10" {
      quietly replace el17=1 if inlist(substr(`elx',1,3), "C81","C82","C83","C84","C85","C88","C96")| /*
*/ inlist(substr(`elx',1,4), "C900", "C902")
      }

*Metastatic Cancer
if "`index'"=="e" {
	quietly replace el18=1 if inlist(substr(`elx',1,3), "196","197","198","199")
      }
else if "`index'"=="10" {
      quietly replace el18=1 if inlist(substr(`elx',1,3), "C77","C78","C79","C80")
      }

*Solid Tumor Without Metastasis
if "`index'"=="e" {
	quietly replace el19=1 if inlist(substr(`elx',1,3),"140","141","142","143","144","145","146","147","148") | /*
*/ inlist(substr(`elx',1,3),"149","150","151","152","153","154","155","156","157") | /*
*/ inlist(substr(`elx',1,3),"158","159","160","161","162","163","164","165") | /*
*/ inlist(substr(`elx',1,3),"166","167","168","169") | /*
*/ inlist(substr(`elx',1,3),"170","171","172","174","175","176","177","178","179") | /*
*/ inlist(substr(`elx',1,3),"180","181","182","183","184","185","186","187","188") | /*
*/ inlist(substr(`elx',1,3),"189","190", "191","192","193","194","195")
     }
else if "`index'"=="10" {
      quietly replace el19=1 if inlist(substr(`elx',1,3), "C00","C01","C02","C03","C04","C05","C06","C07","C08")| /*
*/ inlist(substr(`elx',1,3), "C09","C10","C11","C12","C13","C14","C15","C16","C17")| /*
*/ inlist(substr(`elx',1,3), "C18", "C19","C20","C21","C22","C23","C24","C25","C26") | /*
*/ inlist(substr(`elx',1,3), "C30","C31","C32","C33","C34","C37","C38","C39")| /*
*/ inlist(substr(`elx',1,3), "C40","C41","C43","C45","C46","C47","C48","C49" ) | /*
*/ inlist(substr(`elx',1,3), "C50","C51","C52","C53","C54","C55","C56","C57","C58")| /*
*/ inlist(substr(`elx',1,3), "C60","C61","C62","C63","C64","C65","C66","C67","C68")| /*
*/ inlist(substr(`elx',1,3), "C69","C70","C71","C72","C73","C74","C75","C76","C97")
     }

*Rheumatoid arthritis/collagen vascular diseases
if "`index'"=="e" {
	quietly replace el20=1 if inlist(substr(`elx',1,3),"446","714","720","725") | /*
*/ inlist(substr(`elx',1,4),"7010","7100","7101","7102","7103","7104") | /*
*/ inlist(substr(`elx',1,4),"7108","7109","7112","7193","7285") | /*
*/ inlist(substr(`elx',1,5),"72889","72930")
     }
else if "`index'"=="10" {
      quietly replace el20=1 if inlist(substr(`elx',1,3), "M05","M06","M08","M30","M32","M33") | /*
*/ inlist(substr(`elx',1,3), "M34","M35","M45")| /*
*/ inlist(substr(`elx',1,4), "L940","L941","L943","M120","M123","M310","M311","M312","M313") | /*
*/ inlist(substr(`elx',1,4), "M461","M468","M469")
     }

*Coagulopathy
if "`index'"=="e" {
	quietly replace el21=1 if inlist(substr(`elx',1,3),"286") | /*
*/ inlist(substr(`elx',1,4),"2871","2873","2874","2875")
     }
else if "`index'"=="10" {
      quietly replace el21=1 if inlist(substr(`elx',1,3), "D65","D66","D67","D68")| /*
*/ inlist(substr(`elx',1,4), "D691","D693","D694","D695","D696")
     }

*Obesity
if "`index'"=="e" {
	quietly replace el22=1 if inlist(substr(`elx',1,4),"2780")
      }
else if "`index'"=="10" {
      quietly replace el22=1 if inlist(substr(`elx',1,3), "E66")
      }

*Weight Loss
if "`index'"=="e" {
	quietly replace el23=1 if inlist(substr(`elx',1,3), "260","261","262","263") | /*
*/ inlist(substr(`elx',1,4),"7832","7994")
      }
else if "`index'"=="10" {
      quietly replace el23=1 if inlist(substr(`elx',1,3), "E40","E41","E42","E43","E44","E45","E46","R64")| /*
*/ inlist(substr(`elx',1,4),"R634")
      }

*Fluid and Electrolyte Disorders
if "`index'"=="e" {
	quietly replace el24=1 if inlist(substr(`elx',1,3),"276") | /*
*/ inlist(substr(`elx',1,4),"2536")
      }
else if "`index'"=="10" {
      quietly replace el24=1 if inlist(substr(`elx',1,3), "E86","E87")| /*
*/ inlist(substr(`elx',1,4), "E222")
     }

*Blood Loss Anemia
if "`index'"=="e" {
	quietly replace el25=1 if inlist(substr(`elx',1,4), "2800")
      }
else if "`index'"=="10" {
      quietly replace el25=1 if inlist(substr(`elx',1,4), "D500")
      }

*Deficiency Anemia
if "`index'"=="e" {
	quietly replace el26=1 if inlist(substr(`elx',1,3),"281") | /*
*/ inlist(substr(`elx',1,4),"2801","2808","2809")
      }
else if "`index'"=="10" {
      quietly replace el26=1 if inlist(substr(`elx',1,4), "D508","D509")| /*
*/ inlist(substr(`elx',1,3),"D51","D52","D53")
      }

*Alcohol Abuse
if "`index'"=="e" {
	quietly replace el27=1 if inlist(substr(`elx',1,3),"980") | /*
*/ inlist(substr(`elx',1,4),"2652","2911","2912","2913","2915","2918","2919") | /*
*/ inlist(substr(`elx',1,4),"3030","3039","3050","3575")| /*
*/ inlist(substr(`elx',1,4),"4255","5353","5710","5711","5712","5713","V113")
      }
else if "`index'"=="10" {
      quietly replace el27=1 if inlist(substr(`elx',1,4), "G621","I426","K292","K700","K703","K709","Z502","Z714","Z721")| /*
*/ inlist(substr(`elx',1,3), "F10","E52","T51")
      }

*Drug Abuse
if "`index'"=="e" {
	quietly replace el28=1 if inlist(substr(`elx',1,3), "292","304") | /*
*/ inlist(substr(`elx',1,4),"3052","3053","3054","3055","3056","3057","3058","3059") | /*
*/ inlist(substr(`elx',1,5),"V6542")
      }
else if "`index'"=="10" {
      quietly replace el28=1 if inlist(substr(`elx',1,3), "F11","F12","F13","F14","F15","F16","F18","F19")| /*
*/ inlist(substr(`elx',1,4), "Z715","Z722")
      }

*Psychoses
if "`index'"=="e" {
	quietly replace el29=1 if inlist(substr(`elx',1,3),"295","297","298") | /*
*/ inlist(substr(`elx',1,4),"2938") | /*
*/ inlist(substr(`elx',1,5),"29604","29614","29644","29654")
      }
else if "`index'"=="10" {
      quietly replace el29=1 if inlist(substr(`elx',1,3), "F20","F22","F23","F24","F25","F28","F29") | /*
*/ inlist(substr(`elx',1,4), "F302", "F312", "F315")
      }

*Depression
if "`index'"=="e" {
	quietly replace el30=1 if inlist(substr(`elx',1,3),"309","311") | /*
*/ inlist(substr(`elx',1,4), "2962","2963","2965","3004")
      }
else if "`index'"=="10" {
      quietly replace el30=1 if inlist(substr(`elx',1,3), "F32","F33")| /*
*/ inlist(substr(`elx',1,4), "F204","F313","F314","F315","F341") | /*
*/ inlist(substr(`elx',1,4), "F412","F432")
      }

*Hypertension, complicated"
if "`index'"=="e" {
	quietly replace el31=1 if inlist(substr(`elx',1,3),"402","403","404","405")
      }
else if "`index'"=="10" {
      quietly replace el31=1 if inlist(substr(`elx',1,3), "I11", "I12", "I13", "I15")
      }
     local ord=`ord'+1
   }

*SUM THE FREQUENCIES of COMORBIDITIES over multiple patient records for each comobidity group
*Each yneli will be 0 or 1, indicating absence or presence of comorbidity
*If multiple patient records, i.e. idvar option present

if "`idvar'" != "" {
bysort `idvar': egen ynel1 = max(el1)
bysort `idvar': egen ynel2 = max(el2)
bysort `idvar': egen ynel3 = max(el3)
bysort `idvar': egen ynel4 = max(el4)
bysort `idvar': egen ynel5 = max(el5)
bysort `idvar': egen ynel6 = max(el6)
bysort `idvar': egen ynel7 = max(el7)
bysort `idvar': egen ynel8 = max(el8)
bysort `idvar': egen ynel9 = max(el9)
bysort `idvar': egen ynel10 = max(el10)
bysort `idvar': egen ynel11 = max(el11)
bysort `idvar': egen ynel12 = max(el12)
bysort `idvar': egen ynel13 = max(el13)
bysort `idvar': egen ynel14 = max(el14)
bysort `idvar': egen ynel15 = max(el15)
bysort `idvar': egen ynel16 = max(el16)
bysort `idvar': egen ynel17 = max(el17)
bysort `idvar': egen ynel18 = max(el18)
bysort `idvar': egen ynel19 = max(el19)
bysort `idvar': egen ynel20 = max(el20)
bysort `idvar': egen ynel21 = max(el21)
bysort `idvar': egen ynel22 = max(el22)
bysort `idvar': egen ynel23 = max(el23)
bysort `idvar': egen ynel24 = max(el24)
bysort `idvar': egen ynel25 = max(el25)
bysort `idvar': egen ynel26 = max(el26)
bysort `idvar': egen ynel27 = max(el27)
bysort `idvar': egen ynel28 = max(el28)
bysort `idvar': egen ynel29 = max(el29)
bysort `idvar': egen ynel30 = max(el30)
bysort `idvar': egen ynel31 = max(el31)


*RETAIN ONLY LAST OBSERVATION FOR EACH PATIENT	
	set output error /*To prevent statement re number of deleted observations being printed*/
	bysort `idvar':  keep if _n == _N
	set output proc /*Return to default messages*/
	keep `idvar' ynel1-ynel31
	}
	else {
		forvalues i=1/31 {
			rename el`i' ynel`i'
			}
		}

label define ynlab 0 "Absent" 1 "Present"
 	forvalues i=1/31 {
		label values ynel`i' ynlab
		}

display "Total Number of Observational Units (Visits OR Patients): " _N 

*If multiple records per patient retains only newly created binary comorbidity variables
*Otherwise retains all input data as well

forvalues i=1/31 {
     gen weightel`i'=0
     quietly replace weightel`i'=1 if ynel`i'==1
     }

egen elixsum= rsum(weightel*)		

label var ynel1 "Congestive Heart Failure"
  label var ynel2 "Cardiac Arrhythmias"
  label var ynel3 "Valvular Disease"
  label var ynel4 "Pulmonary Circulation Disorders"
  label var ynel5 "Peripheral Vascular Disorders"
  label var ynel6 "Hypertension, Uncomplicated"
  label var ynel7 "Paralysis"
  label var ynel8 "Other Neurological Disorders"
  label var ynel9 "Chronic Pulmonary Disease"
  label var ynel10 "Diabetes, Uncomplicated"
  label var ynel11 "Diabetes, Complicated"
  label var ynel12 "Hypothyroidism"
  label var ynel13 "Renal Failure"
  label var ynel14 "Liver Disease"
  label var ynel15 "Peptic Ulcer Disease Excluding Bleeding"
  label var ynel16 "AIDS/HIV"
  label var ynel17 "Lymphoma"
  label var ynel18 "Metastatic Cancer"
  label var ynel19 "Solid Tumor Without Metastasis"
  label var ynel20 "Rheumatoid Arthritis/Collagen Vascular"
  label var ynel21 "Coagulopathy"
  label var ynel22 "Obesity"
  label var ynel23 "Weight Loss"
  label var ynel24 "Fluid and Electrolyte Disorders"
  label var ynel25 "Blood Loss Anemia"
  label var ynel26 "Deficiency Anemia"
  label var ynel27 "Alcohol Abuse"
  label var ynel28 "Drug Abuse"
  label var ynel29 "Psychoses"
  label var ynel30 "Depression"
  label var ynel31 "Hypertension, Complicated"
  
  label var elixsum "ELIX COMORBIDITY SUM"
*Output summaries as requested
  
if "`smelix'" != "" {
	tab elixsum
	sum elixsum
	}
forvalues i=1/31 {
	if "`cmorb'" != "" {
		tab ynel`i'
    		}
	}

end



