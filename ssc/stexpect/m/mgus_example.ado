*! version 1.0.2  14aug2004
program mgus_example
	if (_caller() < 8) {
		di as err "This example requires version 8"
		exit 198
	}
	if (_caller() < 8.2)  version 8
	else		      version 8.2
	gettoken dsn 0 : 0, parse(" :")
	gettoken null 0 : 0, parse(" :")
	di as txt
	di as txt "-> " as res "preserve"
	preserve
	di as txt
	di as txt "-> " as res "use `dsn', clear"
	cap findfile mgusexample.dta
	if _rc {
		di as err "file mgusexample.dta not found"
		exit 601 
	}
	local fileful `"`r(fn)'"'
	cap use `"`fileful'"'
	if _rc>900 { 
		window stopbox stop ///   
		"Dataset used in this example" ///
		"too large for Small Stata"
		exit _rc 
	}
	di as txt
	di as txt "-> " as res "Example Expected Survival" 
	`0'
	di as txt
	di as txt "-> " as res `"restore"'
end


program define Ex_MGUS

	tempfile origin ederer hakulin condit

***OBSERVED
	 local current `"`c(filename)'"' 
         stset time, failure(status) scale(365.25) 
         sts gen kaplan = s,by(sex)   
         qui gen kapmale=kaplan if sex==1
         qui gen kapfemale=kaplan if sex==2
         label var kapmal "S(males)"  
         label var kapfem "S(females)"
         qui save `origin' 
         
***EDERER        
         gen survederer=30 * 365.25   
         stset survederer, f(status) id(id) scale(365.25) noshow
         stsplit fu, at(0(1)30)
         gen age = agediagnosis+fu
	 gen year=yeardiagnosis+fu
         sort year age sex
	 cap findfile usrate.dta
	 if _rc {
	 	di as err "file usrate.dta not found"
		exit 601 
	 }
	 local merfile `"`r(fn)'"'
         qui merge year age sex using `merfile', uniqus nokeep
                                                                                                                                                                                           
/* Now expected survival is saved in a file named mgusederer */
         stexpect ederer, ratevar(rate) at(0(1)30) out(`ederer',replace) method(1) by(sex) 
         use `ederer',clear
         qui gen edermale = ederer if sex==1 
         qui gen ederfemale = ederer if sex==2 
         qui save `ederer',replace

/* two files are joined */
         append using `origin'
/* Note that t_exp is the time at which expected survival has been estimated */ 
         twoway (line kapmale kapfemale _t, sort c(J J) clc(blue*1.3 red*1.3)) ///
		(lowess edermale t_exp, bw(.3) clc(blue*1.3)) /// 
		(lowess ederfemale t_exp, bw(.3) clc(red*1.3)), ///
		xti("Years of Follow Up") yti("Survival") xla(0(5)30) /// 
		legend(label(3 "Expexted males") label(4 "Expected females") pos(7) ring(0) col(1)) ///
		t1t("MGUS example") t2t("Ederer Method")
	more
***HAKULINEN
         qui use `current',clear

/* Potential follow up if death */
         gen survhakulinen = cond(status,mdy(8,1,1990) - datediag, time) 
         stset survhakulinen, f(status) id(id) scale(365.25) noshow 
         stsplit fu, at(0(1)30) 
         gen year = yeardiagnosis + fu
         gen age = agediagnosis + fu
         sort year age sex 
         qui merge year age sex using `merfile', uniqus nokeep 
         stexpect hakulinen, ratevar(rate) at(0(1)30) out(`hakulin',replace) by(sex) 
         use `hakulin',clear 
         qui gen hakulmale = hakulinen if sex==1 
         qui gen hakulfemale = hakulinen if sex==2 
         qui save `hakulin',replace 
         qui use `origin',clear
	 append using `hakulin' 
         twoway (line kapmal kapfem _t, sort c(J J) clc(blue*1.3 red*1.3)) /// 
         	 (lowess hakulmale t_exp, bw(.3) clc(blue*1.3)) /// 
         	 (lowess hakulfemale t_exp, bw(.3) clc(red*1.3)), /// 
         	 xti("Years of Follow Up") yti("Survival") xla(0(5)30) /// 
         	 legend(label(3 "Expexted males") label(4 "Expected females") pos(7) ring(0) col(1)) /// 
         	 t1t("MGUS example") t2t("Hakulinen Method") 
         more
         
***CONDITIONAL
         qui use `current',clear 

/* Actual Follow up*/
         stset time, f(status) id(id) scale(365.25) noshow 
         stsplit fu, at(0(1)30) 
         gen year = yeardiagnosis + fu 
         gen age = agediagnosis + fu 
         sort year age sex 
         qui merge year age sex using `merfile', uniqus nokeep 
         stexpect conditional, ratevar(rate) at(0(1)30) out(`condit',replace) by(sex) method(2) 
         use `condit',clear 
         qui gen condmale = conditional if sex==1 
         qui gen condfemale = conditional if sex==2 
         qui save `condit',replace 
         append using `hakulin' 
         append using `origin' 
         twoway (line kapmale kapfemale _t,sort c(J J) clc(blue*1.3 red*1.3)) /// 
             (lowess hakulmale t_exp, bw(.3) clc(blue*1.3)) /// 
             (lowess hakulfemale t_exp, bw(.3) clc(red*1.3)) /// 
             (lowess condmale t_exp, bw(.3) clc(black) clp(shortdash)) /// 
             (lowess condfemale t_exp, bw(.3) clc(black) clp(shortdash)), /// 
             xti("Years of Follow Up") yti("Survival") xla(0(5)30) /// 
             legend(label(3 "Hakulinen males") label(4 "Hakulinen females") /// 
             label(5 "Conditional males") label(6 "Conditional females") pos(2) ring(0) col(1)) /// 
             t1t("MGUS example") t2t("Conditional vs Hakulinen Method")
         
end
