********************************	
********** KOBO2STATA **********
******* Felix Schmieding *******
******* v1.05,14/06/2020 *******
********************************

* VERSION LOG
	* v1.00 First submission to SSC
	* v1.01 Allowed for line breaks in value labels
	* v1.02 Allowed for non-exclusive values in value labels
	* v1.03 Added "multi" option
	* v1.04 Relaxed requirements on labelbook (capture); moved "multi" to core funtionality rather than optional.
	* v1.05 Added "fullreport" option

* DEFINING THE PROGRAMME

program define kobo2stata
  version 14
  syntax using, xlsform(string) [ surveylabel(string) choiceslabel(string) dropnotes usenotsave fullreport ]
	
quietly { 
  
* SET DEFAULT VALUES FOR OPTIONAL ITEMS OF SYNTAX IF NOT SPECIFIED
	if mi(`"`surveylabel'"') {
		local surveylabel="label"
	}
	if mi(`"`choiceslabel'"') {
		local choiceslabel="label"
	}

* BASIC CHECKS ON INPUT DATA FILES
	local checkdatafile = length(`"`using'"') - length(subinstr(`"`using'"', ".xlsx", "", .))
	capture assert `checkdatafile'==5 // if the difference is 5 characters, we can assume that .xlsx appears once and only once, as required.
	if _rc!=0 {
		noisily dis " "
		dis as err "ERROR: Your raw data file must be in format xlsx. Please {stata help kobo2stata:view the help file} for advice on how to export your input data from Kobo."
	}	

	local checkdatafile = length(`"`xlsform'"') - length(subinstr(`"`xlsform'"', ".xls", "", .))
	capture assert `checkdatafile'==4 // if the difference is 4 characters, we can assume that .xls appears once and only once, as required.
	if _rc!=0 {
		noisily dis " "
		dis as err "ERROR: Your XLSForm file must be in format xls. Please {stata help kobo2stata:view the help file} for advice on how to export your input data from Kobo."
	}	
	import excel "`xlsform'", describe
	local checkforsurvey=0
	foreach num of numlist 1/`r(N_worksheet)' {
		if "`r(worksheet_`num')'"=="survey" {
			local checkforsurvey = `checkforsurvey'+1 
		}
	}
	capture assert `checkforsurvey'==1 
	if _rc!=0 {
		noisily dis " "
		dis as err "ERROR: Your XLSForm file must contain a 'survey' tab. Please {stata help kobo2stata:view the help file} for advice on how to export your input data from Kobo."
	}	
	local checkforchoices=0
	foreach num of numlist 1/`r(N_worksheet)' {
		if "`r(worksheet_`num')'"=="choices" {
			local checkforchoices = `checkforchoices'+1 
		}
	}
	capture assert `checkforchoices'==1 
	if _rc!=0 {
		noisily dis " "
		dis as err "ERROR: Your XLSForm file must contain a 'choices' tab. Please {stata help kobo2stata:view the help file} for advice on how to export your input data from Kobo."
	}	
	
* EXTRACT VALUE LABELS FROM XLSFORM
	noisily dis " "
	noisily dis "Reading choices tab of XLSForm..."
	
	import excel "`xlsform'", sheet(choices) clear firstrow
	destring name, replace force
	drop if name == .
	drop if list_name==""
	
	local strippedchoiceslabel=subinstr("`choiceslabel'", ":", "",.)
	keep list_name name `strippedchoiceslabel'
	
	capture assert `strippedchoiceslabel'==. 
	if _rc==0{
		dis as err "ERROR: The label column in your XLSForm's choices tab is empty. Please {stata help kobo2stata:view the help file} and specify a different label header column."
	}
	drop if `strippedchoiceslabel'==""
	
	replace `strippedchoiceslabel'=subinstr(`strippedchoiceslabel',char(10)," ",.)   // remove line breaks.
	
	local numofchoices=_N
	foreach num of numlist 1/`numofchoices' {
		local choiceslistname`num'=list_name[`num']
		local choicesname`num'=name[`num']
		local choiceslabel`num'=`strippedchoiceslabel'[`num']
	}
		

* EXTRACT VARIABLE LABELS AND VARIABLE-TO-LABEL-LINKS FROM XLSFORM
	noisily dis "Reading survey tab of XLSForm..."
	
	import excel "`xlsform'", sheet(survey) clear firstrow
	
	local strippedsurveylabel=subinstr("`surveylabel'", ":", "",.)
	keep type name `strippedsurveylabel'
	
	capture assert type==. 
	if _rc==0{
		dis as err "ERROR: The type column in your XLSForm's survey tab is empty. Please {stata help kobo2stata:view the help file}."
	}
	drop if type=="begin_group"
	drop if type=="begin group"
	drop if type=="end_group"
	drop if type=="end group"
	drop if type=="begin_repeat"
	drop if type=="begin repeat"
	drop if type=="end repeat"
	drop if type==""
	capture assert name==. 
	if _rc==0{
		dis as err "ERROR: The name column in your XLSForm's survey tab is empty. Please {stata help kobo2stata:view the help file}."
	}
	drop if name==""
	capture assert `strippedsurveylabel'==. 
	if _rc==0{
		dis as err "ERROR: The label column in your XLSForm's survey tab is empty. Please {stata help kobo2stata:view the help file} and specify a different label header column."
	}
	drop if `strippedsurveylabel'==""
	
	replace `strippedsurveylabel'=ustrregexra(`strippedsurveylabel',"<[^\>]*>","")   // remove HTML tags.
	replace `strippedsurveylabel'=subinstr(`strippedsurveylabel',char(10)," ",.)   // remove line breaks.
	
	local numofsurveyvars=_N  // store variable labels
	foreach num of numlist 1/`numofsurveyvars' {
		local surveyvarname`num'=name[`num']
		local surveyvarlabel`num'=`strippedsurveylabel'[`num']
	}

	levelsof name if type=="note", local(listofnotevars) clean // store note-type variables
		
	gen tempforlink1=substr(type,1,10)
	gen tempforlink2=substr(type,12,.)
	
	gen tempforlink3=substr(type,1,15)
	gen tempforlink4=substr(type,17,.)
	foreach num of numlist 1/`numofsurveyvars' {
		if tempforlink3[`num']=="select_multiple" {
			local listofmultis="`listofmultis' `num'" 
			local surveymultiname`num'=name[`num']
			local surveymultilink`num'=tempforlink4[`num']
		}
	}
	
	keep if tempforlink1=="select_one"
	
	local numofsurveylinks=_N  // store variable-to-label-links
	foreach num of numlist 1/`numofsurveylinks' {
		local surveylinkname`num'=name[`num']
		local surveylinklink`num'=tempforlink2[`num']
	}
	
* IMPORT RAW KOBO DATA, APPLY LABELS, AND SAVE
	noisily dis "Reading raw data file..."
	noisily dis " "
	import excel `using', describe
	local numofsheets=`r(N_worksheet)'
	foreach num of numlist 1/`numofsheets' {
		local sheetname`num'="`r(worksheet_`num')'"
	}
	foreach numbr of numlist 1/`numofsheets' {
		if !mi(`"`fullreport'"') {
			noisily dis "  - Importing sheet `sheetname`numbr''"
		}
		import excel `using', sheet(`sheetname`numbr'') clear firstrow
		destring _all, replace
		if !mi(`"`fullreport'"') {
			noisily dis "  - Resetting variable labels to blank"
		}
		foreach var of varlist _all {
			label var `var' " "
		}
		if !mi(`"`fullreport'"') {
			noisily dis "  - Initializing transformation of select_multiple"
		}
		if !mi(`"`listofmultis'"') {
			foreach numouter of numlist `listofmultis' {
				foreach numinner of numlist 1/`numofchoices' {
					if "`choiceslistname`numinner''"=="`surveymultilink`numouter''" {
						capture local absofchoicesname`numinner'=abs(`choicesname`numinner'')
						capture label var `surveyvarname`numouter''`absofchoicesname`numinner'' `"`choiceslabel`numinner''"'
						capture label def m_`surveyvarname`numouter''`absofchoicesname`numinner'' 1 "Selected" 0 "Not selected"
						capture label val `surveyvarname`numouter''`absofchoicesname`numinner'' m_`surveyvarname`numouter''`absofchoicesname`numinner''
					}	
				}
			}
		}
		if !mi(`"`fullreport'"') {
			noisily dis "  - Initializing labelling of variables"
		}
		foreach num of numlist 1/`numofsurveyvars' {
			capture label var `surveyvarname`num'' `"`surveyvarlabel`num''"'
		}
		if !mi(`"`fullreport'"') {
			noisily dis "  - Initializing labelling of values"
		}
		foreach num of numlist 1/`numofchoices' {
			capture label def `choiceslistname`num'' `choicesname`num'' `"`choiceslabel`num''"', modify
		}
		foreach num of numlist 1/`numofsurveylinks' {
			capture label val `surveylinkname`num'' `surveylinklink`num''
		} 
		if !mi(`"`fullreport'"') {
			noisily dis "  - Removing unused value labels"
		}
		capture labelbook, problems		// remove unused labels (since all labels from XLSForm were added indiscriminately above)
		loc notused `r(notused)'
		if !mi(`"`notused'"') {
			foreach l of loc notused {
				la drop `l'
			}
		}
		if !mi(`"`fullreport'"') {
			noisily dis "  - Applying dropnotes option if specified"
		}
		if !mi(`"`dropnotes'"') {
			foreach var of local listofnotevars {
				capture drop `var'
			}
		}
		if !mi(`"`fullreport'"') {
			noisily dis "  - Saving dataset unless usenotsave option specified"
			noisily dis " "
		}
		compress
		if mi(`"`usenotsave'"') {
			local savingname=substr(`"`using'"',7,.)
			local savingname=subinstr(`savingname',".xlsx","-`sheetname`numbr''.dta",1)
			save `"`savingname'"', replace
			noisily dis `"Successfully created dataset "`savingname'""'
		}
	}
	
	if mi(`"`usenotsave'"') {
		clear 
	}


}
end
