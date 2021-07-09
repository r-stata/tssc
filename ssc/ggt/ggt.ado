*! version 1.0.1 8September2019

program define ggt

version 14.0

syntax, outcomevar(varname) orgchoice(varname) indID(varname) orgID(varname) choicechar(varlist)  ///
 	[, orgchar(varlist max=10) indchar(varlist max=20) niter(numlist integer max=1 min=1) alphapriorvar(numlist max=1 min=1) ///
	gammapriorvar(numlist max=1 min=1) deltapriorvar(numlist max=1 min=1) ///
	 priortau(numlist max=2 min=2) savedraws noselection noCONStant]


*check niter is larger than burnin
	if("`niter'"!=""){
		local check=(`niter'>10000)
		if (`check'!=1){
			display as error "Number of Iterations must be larger than 10,000 burn-in"
			exit 505
		}
	}


*check second element of tauprior is integer
	if ("`priortau'"!=""){
		local check=`: word 2 of `priortau''
		if (mod(`check',1)!=0){
			display as error "Second element of priortau must be an integer"
		exit 498
		}
	}

*check if conflicting variable names
local constraint_varlist temp_ggt_ temp_lastorg temp_lastorg_val temp_lastorg_val_all temp_Z_diff_

foreach var in `constraint_varlist' {
    capture confirm variable `var'
    if !_rc {
        display as error "Please rename `var' variable to avoid conflict in GGT code"
	exit 505
   }
}


egen temp_ggt_persid=group(`indID') 
egen temp_ggt_orgID=group(`orgID')
tempfile temp_ggt_master   
qui save "`temp_ggt_master'" 
	


*check outcomevar is 0 1 and sum to 0 or 1 for a given patient
	qui gen temp_GGT_flag=0
	qui replace temp_GGT_flag=1 if (`outcomevar'!=1 & `outcomevar'!=0)
	qui su temp_GGT_flag
	local error=r(max)
	if (`error'!=0){
		cap drop temp_ggt_persid temp_ggt_ordID
		display as error "outcomevar must be binary {0,1}"
		exit 499
	}
	qui replace temp_GGT_flag=0
	qui bysort temp_ggt_persid: egen temp_GGT_outcomesum=sum(`outcomevar') 
	qui su temp_ggt_orgID
	local lastOrg=r(max)
	qui replace temp_GGT_flag=1 if (temp_GGT_outcomesum!=`lastOrg' & temp_GGT_outcomesum!=0)
	qui su temp_GGT_flag
	local error=r(max)
	if (`error'!=0){
		cap drop temp_ggt_persid temp_ggt_ordID
		display as error "outcomevar must be constant within individuals"
		exit 504
	}	
*check orgchoice are 0 1 and sum to 1 
	qui replace temp_GGT_flag=0
	qui replace temp_GGT_flag=1 if (`orgchoice'!=1 & `orgchoice'!=0)
	qui su temp_GGT_flag
	local error=r(max)
	if (`error'!=0){
		cap drop temp_ggt_persid temp_ggt_ordID
		display as error "orgchoice must be binary {0,1}"
		exit 500
	}

	qui replace temp_GGT_flag=0
	qui bysort temp_ggt_persid: egen temp_GGT_choicesum=sum(`orgchoice') 
	qui replace temp_GGT_flag=1 if (temp_GGT_choicesum!=1)
	qui su temp_GGT_flag
	local error=r(max)
	if (`error'!=0){
		cap drop temp_ggt_persid temp_ggt_ordID
		display as error "orgchoice must sum to 1 within individuals"
		exit 501
	}


*processing stata dataset
*get temp_GGT_Inddata.csv for C code
	gen temp_ggt_choice_number=temp_ggt_orgID*`orgchoice'
	collapse (mean) `outcomevar' `indchar' (max) temp_ggt_choice_number, by(temp_ggt_persid) 
	gen temp_ggt_cons=1
	rename temp_ggt_persid indID
	rename `outcomevar' outcomevar 
	rename temp_ggt_choice_number choice
	local j=2
	if ("`constant'"=="noconstant"){
		drop temp_ggt_cons
		local j=1
	}
	foreach var in `indchar'{
		rename `var' x`j'
		local j=`j'+1
	}
	cap rename temp_ggt_cons x1
	order indID outcomevar choice 
	cap order x*, after(choice) sequential
	sort indID
	qui outsheet using temp_GGT_Inddata.csv , comma replace
	clear
	use "`temp_ggt_master'" 
	

*get temp_GGT_Orgdata.csv for C code
	local orgcharcount: word count `orgchar' 
	if(`orgcharcount'==0){
		collapse (firstnm) `orgID', by(temp_ggt_orgID)
		rename temp_ggt_orgID orgID_recode
		rename `orgID' orgID
		keep orgID orgID_recode
		qui outsheet  using temp_GGT_Orgdata.csv, comma replace
	} 
	else{
		local i=1
		foreach var in `orgchar'{
		egen temp_ggt_orgchar`i'=group(`var')
		local i=`i'+1
		}
	collapse (mean) temp_ggt_orgchar* (firstnm) `orgID', by(temp_ggt_orgID)
	rename temp_ggt_orgID orgID_recode
	rename `orgID' orgID
	forvalues k=1/`orgcharcount'{ 
		rename temp_ggt_orgchar`k' type`k'
	}
	order orgID orgID_recode
	cap order type*, after(orgID_recode) sequential 
	sort orgID_recode
	qui outsheet  using temp_GGT_Orgdata.csv, comma replace
	}
	clear
	use "`temp_ggt_master'" 

*get temp_GGT_Zdata.csv for C code 
	qui su temp_ggt_orgID
	local lastOrg=r(max)
	gen temp_lastorg=(temp_ggt_orgID==`lastOrg')
	local l=1
	foreach var in `choicechar'{
		gen temp_lastorg_val=temp_lastorg*`var'
		bysort temp_ggt_persid: egen temp_lastorg_val_all=max(temp_lastorg_val)
		gen temp_Z_diff_`l'=`var'-temp_lastorg_val_all
		drop temp_lastorg_val*
		local l=`l'+1
	}

	qui drop if temp_ggt_orgID==`lastOrg'
	rename temp_ggt_persid indID
	rename temp_ggt_orgID orgID
	local zcount: word count `choicechar' 
	if(`zcount'==0){
		keep indID orgID
	} 
	else {
		keep indID orgID temp_Z_diff*
	}
	if(`zcount'>0){	
		local l=`l'-1
		forvalues n=1/`l'{
			rename temp_Z_diff_`n' choicechar`n'
		}
	}
	order indID orgID
	cap order choicechar*, after(orgID) sequential
	sort indID orgID
	qui outsheet using temp_GGT_Zdata.csv, comma replace
	clear
	use "`temp_ggt_master'" 



*prepping to send options to C code 
	local last=""
	foreach var in niter alphapriorvar gammapriorvar deltapriorvar priortau{
		if ("``var''"!=""){
			local last="`var'(``var'')"
		}
	}
	if ("`selection'"=="noselection"){
	local last="`selection'"
	}
	foreach var in niter alphapriorvar gammapriorvar deltapriorvar priortau {
		if (("``var''"!="") & ("`var'(``var'')"!="`last'")){
			local `var'="`var'(``var''),"
		}
		if (("``var''"!="") & ("`var'(``var'')"=="`last'")){
			local `var'="`var'(``var'')"
		}
	}



*write file and delete 
	qui file open useroptions using "temp_GGT_useroptions.txt", write replace
	file write useroptions "`niter' `alphapriorvar' `gammapriorvar' `deltapriorvar' `priortau' `selection'"
	file close useroptions

*calling C code	
cap program drop callCcode
callCcode

*quality output display 
	cap rm "temp_ggt_qual.dta"
	clear
	qui import delimited using "temp_GGT_output.csv"
	qui keep iter
	qui save	"temp_ggt_qual", replace
	clear
	qui import delimited using "temp_GGT_Orgdata.csv"
	qui describe
	local rows=r(N)

	tempfile temp_org
	qui save "`temp_org'"

	

	if ("`orgchar'"==""){
		forvalues r=1/`rows'{
			clear
			qui use "`temp_org'"
			qui keep if _n==`r'
			genQual, orgid(orgid) orgid_recode(orgid_recode)
			}
	}
	else{
		forvalues r=1/`rows'{
			clear
			qui use "`temp_org'"
			qui keep if _n==`r'
			genQual,  orgid(orgid) orgid_recode(orgid_recode) typevars(type*) 
		}
	}

	qui drop if iter<10001
	su q_*

	clear	
	use "`temp_ggt_master'"
	qui drop temp_ggt_persid temp_ggt_orgID

			
		
		
	
	

*removing the temp files created? (add back in at end) 	
	if ("`savedraws'"==""){
		rm "temp_GGT_output.csv"
	}
	rm "temp_GGT_useroptions.txt"  
	rm "temp_GGT_Orgdata.csv"
	rm "temp_GGT_Inddata.csv"
	rm "temp_GGT_Zdata.csv"
	rm "temp_ggt_qual.dta"

end

program define genQual
	syntax, orgid(varname) orgid_recode(varname) [, typevars(varlist)]
	qui su `orgid_recode'
	local hosp_num=r(max)
	local orgid_name = `orgid'[_N]
	
	if ("`typevars'"!=""){
		local j=1
		foreach var in `typevars'{
			qui su `var'
			local temp_type_val`j'=r(max)
			local j=`j'+1
		}
	}
	
	clear
	qui import delimited using "temp_GGT_output.csv" 
	
	if ("`typevars'"!=""){	
		local j=1
		foreach var in `typevars'{
			qui gen temp_ggt_orgatt`j'value=beta_orgatt`j'_type`temp_type_val`j''
			local j=`j'+1
		}
		qui keep iter beta_orgatt`j'_type`hosp_num' temp_ggt_orgatt*
		qui egen q_`orgid_name'=rowtotal(beta_orgatt`j'_type`hosp_num' temp_ggt_orgatt*)
	}

	
	if ("`typevars'"==""){
		qui rename beta_orgatt1_type`hosp_num' q_`orgid_name'
	}
	
	qui keep iter q_*
	qui merge 1:1 iter using "temp_ggt_qual"
	qui drop _merge
	qui keep iter q_*
	qui save "temp_ggt_qual", replace

end


