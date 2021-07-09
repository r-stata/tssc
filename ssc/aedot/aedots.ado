*! ae_dot v1.0 11/02/2020
*start   with dataset with a variable for number of events in each arm  and totals in each arm
cap prog drop aedots
cap postclose ae_dot 
program define aedots, rclass 
version 15.0

tempfile original
tempfile ae_doti_1

/*
  DESCRIPTION: Creating a dot plot for AE data in clinical trials when dataset contains ///
				number of events per group for each event and number randomised in each treatment group
  v1.0: original
    
  */

syntax varlist, n1(varname) n2(varname) tot1(varname) tot2(varname)  ///
   [ RISKDiff(real 0)    ///
	 leftxtitle(string)  leftcolor1(string)  leftcolsat1(integer 50) leftcolor2(string) leftcolsat2(integer 50) leftsymb1(string) leftsymb2(string) ///
	 leftlabsize(real 1) leftlabang(real 0) leftlabel(string) ///
	  rightxline(real 0)  rightxlinepat(string) rightxlinecol(string) rightdcolor(string) rightdotcol(string) rightdotsat(integer 60) ///
	 rightlincol(string) rightlinsat(integer 60)  ///
	 legendleftyn(integer 1) legendleft1(string) legendleft2(string)  legendleftpos(integer 6) legendleftcol(integer 2)  legendleftrow(integer 1)  ///
	  legendrightyn(integer 1) legendright1(string) legendright2(string)  legendrightpos(integer 6) legendrightcol(integer 2) legendrightrow(integer 1)  ///
	 brightmargin(real 2) trightmargin(real 5) aspectright(real 0)  ///
	 bleftmargin(real 0) tleftmargin(real 0) aspectleft(real 0)  ///
	 title(string) subtitle(string) grphcol(string) plotcol(string) ///
	 SAVing(string) graphsave(string) clear ]

	 preserve
	 
/* 
	Syntax explanation
	varlist - can contain string or numeric and indicates variable that contains the AE name/identifier
	n1 - number in trt group with event 
	n2 - number in control group with event 
	tot1 - overall number in trt grp
	tot2 - overall number in control group
	*/
	
/*Optional commands

(1) riskdiff is optional - defaults to 0 which gives relative risk (and CIs) on scatter plot,
		if specify 1 allows user to change to risk difference (and CIs)

(2) leftxtitle(string) is optional title for x axis (reversed y axis) of dot plot - the default is Percentage

(3) leftcolor1(string)  is optional colour of dot fill and outline on dot plot for treatment 1 - default is blue

(4) leftcolsat1(real 50) is optional colour saturation on dot fill for dot plot - default is 50

(5) leftcolor2(string) is optional colour of dot fill and outline on dot plot for treatment 2 - default is red

(6) leftcolsat2(real 50) is optional colour saturation on dot fill for dot plot - default is 50

(7) leftsymb1 is optional symbol for first dot plot symbol - default is circle

(8) leftsymb2 is optional symbol for second dot plot symbol - default is circle

(9) leftlabsize is the size of the label for event names/labels on x axis of the dot plot 

(10) leftlabang(real 0) is the angle of the label for x axis of dot plot (default 0 to give horizontal label)
 
(11) leftlabel string variable allowing user to change the labels of the yxais of dot plot (i.e. event labels) 
	default is that this contains no text so that the original labels are used

(12) rightplot(string) is optional title for x axis of scatter plot - the default is Risk difference but this is surpressed, 
		it's only included to help legend align

(13) rightxline(real 1) is optional vertical line on scatter plot  - default is at 1 (rel risk value 1)

(14) rightxlinepat(string) is optional and can be used to change style of vertical line on scatterplot, default dash

(15) rightxlinecol is optional and can be used to change colour of vertical line on scatterplot - default is bluish gray

(16) rightdcolor(string) is optional colour of background lines on scatter plot - default is white so they aren't visible

(17) rightdotcol(string) is optional colour of dot on scatter plot - default is black

(18) rightdotsat(real) is optional colour of dot saturation on scatter plot - default is 60

(19) rightlincol(string) is optional col of confidence interval line colour on scatter plot - default is black

(20) rightlinsat(real 60) is optional colour of line saturation on scatter plot - default is 60

(21)legendleftyn is optional - default is 1 and indicates that legend turned on  for dot plot 
 
(22) legendleft1(string) and legendleft2(string)- options to add  text to the legend if it is turned on for the dot plot
 
(23) legendleftpos(integer 6) option to specify position of dot plot legend
 
(24) legendleftcol(integer 2) and  legendleftrow(integer 1) otions for number of columns and rows in scatterplot legend, 
		defaults are are 2 columns and 1 row

(25)  legendrightyn(integer 1) is optional - default is 1 and indicates that legend turned on  for scatter plot

(26) legendright1(string) and legendright2(string)  options to add  text to the legend if it is turned on for the scatter plot

(27) legendrightpos(integer 6) option to specify position of scatter plot legend

(28) legendsrightcol(integer 2)  and legendrightrow(integer 1)  options for number of columns and rows in scatterplot legend, 
		defaults are are 2 columns and 1 row
	 
(29) brightmargin(real 2) adds a margin of empty space to the bottom of the scatter plot - 
		this can be used to manipulate the scatter plot to align with the dot plot

(30) trightmargin(real 5) adds a margin of empty space to the top of the scatter plot - 
		this can be used to manipulate the scatter plot to align with the dot plot

(31) aspectright(real 0)  sets the aspect of the scatterplot - need decide if this is necessary

(32) bleftmargin(real 0) adds a margin of empty space to the bottom of the dot plot - this can be used to manipulate the scatter plot to align with the scatter plot

(33) tleftmargin(real 0) adds a margin of empty space to the top of the dot plot - this can be used to manipulate the scatter plot to align with the scatter plot
	
(34) aspectleft(real 0)  sets the aspect of the scatterplot - need decide if this is necessary

(35) title(string) and subtitle(string)  option to include titles to the plot

(36) grphcol(string) and plotcol(string) set graph and plot background colour - defaults to white
	
(37) SAVing(string) - allows outputted plot to be saved

(38) graphsave(string) - allows combined graph to be saved

(39) clear - clears original dataset from memory and keeps the newly created dataset in memory

*/

qui {

**********************************************************************************
*ERROR CHECKS 
**********************************************************************************

**********************************************************************************
*Error checking
*Confirm n1 is numeric - should contain number with that event in treatment group
cap confirm numeric variable `n1' 
local n1_num =  _rc
if `n1_num' !=0 {
	display as error "n1 variable not numeric"
	exit 7
	}
	
*Confirm n2 is numeric - should contain number with that event in control group
cap confirm numeric variable `n2' 
local n2_num =  _rc
if `n2_num' !=0 {
	display as error "n2 variable not numeric"
	exit 7
	}

*Confirm tot1 is numeric - should contain number in treatment group
cap confirm numeric variable `tot1' 
local tot1_num =  _rc
if `tot1_num' !=0 {
	display as error "tot1 variable not numeric"
	exit 7
	}

*Confirm tot2 is numeric - should contain number in treatment group
cap confirm numeric variable `tot2' 
local tot2_num =  _rc
if `tot2_num' !=0 {
	display as error "tot2 variable not numeric"
	exit 7
	}

		
*riskdiff can only take values 0 or 1
if `riskdiff' >1  | `riskdiff'<0 {  
	display as error "riskdiff can only take values 0 or 1"
	exit 7
	}

*********************************************************************************
**************Setting default linepattern to dash for xline on scatter plot  before error checking**
if "`rightxlinepat'" == "" {	
	local rightxlinepat= "dash"
	}
		
*******Error checking restrict ylinepat to the linepattern available in stata********
local test = c(sysdir_base)
local test2 = "`test'"+"style"
local linepatopt : dir "`test2'" files "linepattern-*.style"
local linepatopt : list clean linepatopt
local linepatopt: subinstr local linepatopt "linepattern-" "", all
local linepatopt: subinstr local linepatopt ".style" "", all
local linepatopt: subinstr local linepatopt "blank" "", all

tempvar lpat1
gen `lpat1'=0 
if  "`rightxlinepat'"!="" {
	foreach lname in `linepatopt' {
		cap replace `lpat1'=1  if "`lname'"=="`rightxlinepat'"
		
		}
	}
if `lpat1'== 0 {
	disp as error "`rightxlinepat' is not a Stata linepattern style. Please see Stata linepatternstyle for acceptable options"
	exit 198
	}
*********************************************************************************
	
**********Setting default symbols before error checking	
*Setting default symbol in group 1
if "`leftsymb1'" =="" {
	local leftsymb1= "circle"
}

*Setting default symbol in group 2
if "`leftsymb2'" =="" {
	local leftsymb2= "circle"
}
	
*******Error checking restrict dotsyml to the linepattern available in stata********
local test = c(sysdir_base)
local test2 = "`test'"+"style"
local symbolopt : dir "`test2'" files "symbol-*.style"
local symbolopt : list clean symbolopt
local symbolopt: subinstr local symbolopt "symbol-" "", all
local symbolopt: subinstr local symbolopt ".style" "", all
local symbolopt: subinstr local symbolopt "blank" "", all


tempvar sym1
gen `sym1'=0 
if  "`leftsymb1'"!="" {
	foreach lname in `symbolopt' {
		cap replace `sym1'=1  if "`lname'"=="`leftsymb1'"
		}
	}
if `sym1'== 0 {
	disp as error "`leftsymb1' is not a Stata symbol style. Please see Stata symbolstyle for acceptable options"
	exit 198
	}
	
tempvar sym2
gen `sym2'=0 
if  "`leftsymb2'"!="" {
	foreach lname in `symbolopt' {
		cap replace `sym2'=1  if "`lname'"=="`leftsymb2'"
		}
	}
if `sym2'== 0 {
	disp as error "`leftsymb2' is not a Stata symbol style. Please see Stata symbolstyle for acceptable options"
	exit 198
	}
*********************************************************************************
	
*************Setting default colours before error checking************
	
*Setting default line colour for xline on scatter plot to bluishgray - need to restrict what can be entered to lcolor 
if "`rightxlinecol'" == "" {
	local rightxlinecol = "bluishgray"
	}

*Setting default line colour in scatter to white so that it's not visible
if "`rightdcolor'" =="" {
   local rightdcolor = "white"
	}
	
*Setting default dot colour on scatter to black
if "`rightdotcol'" =="" {
	local rightdotcol = "black"
	}
	
*Setting default interval line colour on scatter to black
if "`rightlincol'" == "" {
	local rightlincol= "black"
	}
	
*Setting default circle colour in group one to blue on dot plot
if "`leftcolor1'" == "" {
	local leftcolor1 ="blue"
	}

*Setting default circle colour in group two to red on dot plot
if "`leftcolor2'" == "" {
	local leftcolor2 ="red"
	}
	
*Setting default plot background colour to white
if "`plotcol'" =="" {
	local plotcol = "white"
	}
	
*Setting default graph background colour to white
if "`grphcol'" =="" {
	local grphcol = "white"
	}
		
***Error checking colours****************
local test = c(sysdir_base)
local test2 = "`test'"+"style"
local coloropt : dir "`test2'" files "color-*.style"
local coloropt : list clean coloropt
local coloropt: subinstr local coloropt "color-" "", all
local coloropt: subinstr local coloropt ".style" "", all
local coloropt: subinstr local coloropt "blank" "", all

tempvar col1
gen `col1'=0 
if  "`rightxlinecol'"!="" {
	foreach lname in `coloropt' {
		cap replace `col1'=1  if "`lname'"=="`rightxlinecol'"
		}
	}
if `col1'== 0 {
	disp as error "`rightxlinecol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}	
	
tempvar col2
gen `col2'=0 
if  "`rightdcolor'"!="" {
	foreach lname in `coloropt' {
		cap replace `col2'=1  if "`lname'"=="`rightdcolor'"
		}
	}
if `col2'== 0 {
	disp as error "`rightdcolor' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col3
gen `col3'=0 
if  "`rightdotcol'"!="" {
	foreach lname in `coloropt' {
		cap replace `col3'=1  if "`lname'"=="`rightdotcol'"
		}
	}
if `col3'== 0 {
	disp as error "`rightdotcol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col4
gen `col4'=0 
if  "`rightlincol'"!="" {
	foreach lname in `coloropt' {
		cap replace `col4'=1  if "`lname'"=="`rightlincol'"
		}
	}
if `col4'== 0 {
	disp as error "`rightlincol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col5
gen `col5'=0 
if  "`leftcolor1'"!="" {
	foreach lname in `coloropt' {
		cap replace `col5'=1  if "`lname'"=="`leftcolor1'"
		}
	}
if `col5'== 0 {
	disp as error "`leftcolor1' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col6
gen `col6'=0 
if  "`leftcolor2'"!="" {
	foreach lname in `coloropt' {
		cap replace `col6'=1  if "`lname'"=="`leftcolor2'"
		}
	}
if `col6'== 0 {
	disp as error "`leftcolor2' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col7
gen `col7'=0 
if  "`plotcol'"!="" {
	foreach lname in `coloropt' {
		cap replace `col7'=1  if "`lname'"=="`plotcol'"
		}
	}
if `col7'== 0 {
	disp as error "`plotcol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col8
gen `col8'=0 
if  "`grphcol'"!="" {
	foreach lname in `coloropt' {
		cap replace `col8'=1  if "`lname'"=="`grphcol'"
		}
	}
if `col8'== 0 {
	disp as error "`grphcol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
 *****************************************************************************
*Error message if dot colour fill saturation is not a value between 0 and 100
if `leftcolsat1' >101  | `leftcolsat1'<0 {  
	display as error "leftcolsat1 can only take integer values between 0 and 100 "
	exit 7
	}
if `leftcolsat2' >101 | `leftcolsat2'<0  {  
	display as error "leftcolsat2 can only take integer values between 0 and 100 "
	exit 7
	}
	
if `rightdotsat' >101 | `rightdotsat'<0  {  
	display as error "rightdotsat can only take integer values between 0 and 100 "
	exit 7
	}
	
if `rightlinsat' >101 | `rightlinsat'<0  {  
	display as error "rightlinsat can only take integer values between 0 and 100 "
	exit 7
	}
	
*****************************************************************************	
*legendotyn can only take values 0 or 1
if `legendleftyn' >1  | `legendleftyn'<0 {  
	display as error "legendotyn can only take values 0 or 1"
	exit 7
	}
	
* legendrightyn can only take values 0 or 1
if `legendrightyn' >1  | `legendrightyn'<0 {  
	display as error "legendrightyn can only take values 0 or 1"
	exit 7
	}
	
*legendleftpos can only take integer values between 0 and 12
if `legendleftpos' >12 | `legendleftpos'<0  {  
	display as error "legendleftpos can only take integer values between 0 and 12 "
	exit 7
	}	

*legendscatpos can only take integer values between 0 and 12
if `legendrightpos' >12 | `legendrightpos'<0  {  
	display as error "legendscatpos can only take integer values between 0 and 12 "
	exit 7
	}	

*****************************************************************************
*Error checking saving command correctly specified
if "`saving'" != "" {
	tokenize "`saving'", parse(",")
	local filename `1'
	local replace `3'
	if "`replace'" == "" {
		confirm new file `filename'.dta
	}
	if "`replace'" != "" {
		if "`replace'" != "replace" {
		display as error "option saving, `replace' not allowed"
		exit 198
		}
	}
}	

if "`graphsave'"!="" {
	tokenize "`graphsave'" , parse(",")
	local graphname `1' 
	local graphreplace `3'
	if "`graphreplace'" == "" {
	confirm new file `graphname'.gph
	}
	
	if "`graphreplace'" != "" {
		if "`graphreplace'" != "replace" {
		display as error "option saving, `graphreplace' not allowed"
		
		}
	}
}	

	
***************************************************************************************************************************************************************


tokenize `varlist'
local by "`1'"

		/*Code for string variable*/
	if substr("`:type `by''" ,1,3) == "str" {
			

			gen ae_id = _n
			*gen a numeric variable for each AE listed in by (where by is the list of variables in varlist of syntax)
			
			tab ae_id
			local count=r(r)
			*local var with number of distinct AEs
			
			save `original'.dta  , replace
			
			postfile  ae_doti r1 r2 perc1 perc2 risk_diff seRD lowerRD upperRD n_events p_val log_p_val str20 event relrisk logRR stderrRR loglowerCIRR logupperCIRR lowerCIRR upperCIRR using `ae_doti_1'.dta, replace

			forvalues i=1(1)`count' {
			*runs through the following for each AE
	
				use `original'.dta , clear
				keep if ae_id==`i'
				*Keeps all occurrences of the first AE, then on next run through the second AE and so on
				
				local r1 = `n1'/`tot1'	
				local r2 = `n2'/`tot2'	
				*local var with proportion where n1, tot1, n2 and tot2 must be specified int the syntax line
				
				local perc1 = (`n1'/`tot1')*100
				local perc2 = (`n2'/`tot2')*100
				
				local n1_p1 = `tot1'-`n1'
				local n2_p2 = `tot2'-`n2'
				*local var with number on treatment arm minus those with event - gives number without event
			
		**********RISK DIFFERENCE & P-VALUE******************
				*Now using info from each treatment group
				*local var with proportion in treatment 1 - proportion in treatment 2

				local risk_diff=(`n1'/`tot1')-(`n2'/`tot2')
				*local var with proportion in treatment 1 - proportion in treatment 2
	
				local seRD = sqrt( (`r1'*(1-`r1') )/`tot1' + (`r2'*(1-`r2'))/`tot2') 
				
				local lowerRD = `risk_diff' - 1.96*`seRD'
				local upperRD = `risk_diff' + 1.96*`seRD'			
				
				local n_1 = `n1'
				local n_2 = `n2'	
				
				local tot_1 = `tot1'
				local tot_2 = `tot2'
		
				
				tabi `n_1' `n1_p1' \ `n_2' `n2_p2', exact
				*direct test with number with and without event in each treatment group
			
				local p_val = r(p_exact)
				*local var containing p-value from the tabi command
				
				local log_p = -1*log10(`p_val')
				*local var containing the log of the p-value
			
				*Relative risk
				
				*If 0 events present then the relative risk non-calcuable, to avoid this we add 0.5 an event 
				if `n_1'==0 & `n_2'!=0 {
					local n_1 = 0.5
					local n_2 = `n_2'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					}
					
				if `n_2'==0 & `n_1'!=0 {
					local n_2  = 0.5
					local n_1 = `n_1'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					}
				
				
				local rel_risk =(`n_1'/`tot_1')/(`n_2'/`tot_2')
				
				local logRR = log((`n_1'/`tot_1')/(`n_2'/`tot_2'))
				
				local seRR = sqrt( (1/`n_1' - 1/`tot_1') + (1/`n_2' - 1/`tot_2'))
				
				local log_lowerRR = `logRR' - 1.96*`seRR'
				local log_upperRR = `logRR' + 1.96*`seRR'
				
				local lowerRR = exp(`log_lowerRR')
				local upperRR = exp(`log_upperRR')
				
				count
				*count is a local var that will call number of individual AEs
				
				local events = r(N)
				local e_name = "`varlist'" in 1 
				di `e_name'
				
			post ae_doti (`r1') (`r2') (`perc1') (`perc2') (`risk_diff') (`seRD') (`lowerRD') (`upperRD') (`events') (`p_val') (`log_p') (`e_name') (`rel_risk') (`logRR') (`seRR') (`log_lowerRR') (`log_upperRR') (`lowerRR') (`upperRR')  
				
			use `original'.dta , clear

			}
	}

	else { 
			/* numeric option*/
			
			gen ae_id = _n
			tab ae_id
			local count=r(r)
			
			save `original'.dta  , replace
			
			postfile  ae_doti r1 r2 perc1 perc2 risk_diff seRD lowerRD upperRD n_events p_val log_p_val str20 event  eventnum relrisk logRR stderrRR loglowerCIRR logupperCIRR  lowerCIRR upperCIRR   using `ae_doti_1'.dta, replace

			forvalues i=1(1)`count' {
					
				use `original'.dta , clear
				keep if ae_id==`i'
								
				local r1 = `n1'/`tot1'	
				local r2 = `n2'/`tot2'	
				*local var with proportion where n1, tot1, n2 and tot2 must be specified int the syntax line
								
				local perc1 = (`n1'/`tot1')*100
				local perc2 = (`n2'/`tot2')*100
				
				local n1_p1 = `tot1'-`n1'
				local n2_p2 = `tot2'-`n2'

				*local var with number on treatment arm minus those with event - gives number without event
				
				***RISK DIFFERENCE****
				local risk_diff=(`n1'/`tot1')-(`n2'/`tot2')
				
				local seRD = sqrt((`r1'*(1-`r1'))/`tot1' + (`r2'*(1-`r2'))/`tot2') 
				
				local lowerRD = `risk_diff' - 1.96*`seRD'
				local upperRD = `risk_diff' + 1.96*`seRD'				
				
				local n_1 = `n1'
				local n_2 = `n2'	
				
				local tot_1 = `tot1'
				local tot_2 = `tot2'
				
				tabi `n_1' `n1_p1' \ `n_2' `n2_p2', exact
				local p_val = r(p_exact)
				local log_p = -1*log10(`p_val')
				
				***RELATIVE RISK ****
				
				*If 0 events present then the relative risk non-calcuable, to avoid this we add 0.5 an event 
				if `n_1'==0 & `n_2'!=0 {
					local n_1 = 0.5
					local n_2 = `n_2'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					}
					
				if `n_2'==0 & `n_1'!=0 {
					local n_2  = 0.5
					local n_1 = `n_1'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					}
				
				local rel_risk =(`n_1'/`tot_1')/(`n_2'/`tot_2')
				
				local logRR = log((`n_1'/`tot_1')/(`n_2'/`tot_2'))
			
				local seRR = sqrt( (1/`n_1' - 1/`tot_1') + (1/`n_2' - 1/`tot_2'))
			
				local log_lowerRR = `logRR' - 1.96*`seRR'
				local log_upperRR = `logRR' + 1.96*`seRR'
			
				local lowerRR = exp(`log_lowerRR')
				local upperRR = exp(`log_upperRR')
			
				count
				local events = r(N)
				
				*getting the numeric value for the event
				local e_name_num = "`by'" in 1 
				di `e_name_num'
			
				*getting the string label for the event				
				decode `by' in 1 , generate(event_label)
				local e_name = event_label 
				display "`e_name'"

				post ae_doti (`r1') (`r2') (`perc1') (`perc2') (`risk_diff') (`seRD') (`lowerRD') (`upperRD') (`events') (`p_val') (`log_p') ("`e_name'") (`e_name_num')   (`rel_risk') (`logRR') (`seRR') (`log_lowerRR') (`log_upperRR') (`lowerRR') (`upperRR') 
				
				use `original'.dta , clear
				
			}
	}
	
postclose ae_doti


use `ae_doti_1'.dta, clear

lab var r1 "Proportion in group 1"
lab var r2 "Proportion in group 2"
lab var perc1 "Percentage in group 1" 
lab var perc2 "Percentage in group 2"
lab var risk_diff "Risk difference"
lab var seRD "stderr(risk difference)"
lab var lowerRD "lower 95% CI risk difference"
lab var upperRD "upper 95% CI risk difference"
lab var n_events "Total number of events"
lab var p_val "Fisher's exact p-value"
lab var log_p_val "log(Fisher's exact p-value)"
lab var event "AE name"
cap lab var eventnum "AE number"
lab var relrisk "Relative risk"
lab var logRR "log(relative risk)"
lab var stderrRR "stderr(relative risk)"
lab var loglowerCIRR "log(lower 95% CI relative risk)"
lab var logupperCIRR "log(upper 95% CI relative risk)"
lab var lowerCIRR "lower 95% CI relative risk"
lab var upperCIRR "upper 95% CI relative risk"

save `ae_doti_1'.dta , replace

********************************************************

*Giving defaults for xaxis title and yaxis title (which is surpressed from view - but ensures legends are aligned)
if "`leftxtitle'" =="" {
	local leftxtitle = "Percentage"
	}

if "`rightplot'" =="" & `riskdiff'==0 {
	local rightplot = "Relative risk"
	}
	
if "`rightplot'" =="" & `riskdiff'==1 {
	local rightplot = "Risk difference"
	}

********************************************************

*Add horizontal lines to the plot  - default to the same value as default for label i.e. 1

if "`rightxline'" == "" & `riskdiff'==0 {
		local xnum = 0
		}
		
if "`rightxline'" == "" & `riskdiff'==1 {
		local xnum = 0
		}		
		
if "`rightxline'" !="" {
	local xnum `rightxline'

	}

**********************************************

*Code to display legend	- for dot plot
*If legendyn is 0 then legend switched off 
if `legendleftyn' ==0  {
	local legendtext = "off"
	}
		
if `legendleftyn' ==1 & "`legendleft1'"=="" {
	local legenddef1 = "Group 1"
	}

if `legendleftyn' ==1 & "`legendleft1'"!="" {
	local legenddef1 = "`legendleft1'"
	}
	
if `legendleftyn' ==1 & "`legendleft2'"=="" {
	local legenddef2 = "Group 2"
	}
if `legendleftyn' ==1 & "`legendleft2'"!="" {
	local legenddef2 = "`legendleft2'"
	}
	
if `legendleftyn' ==1 & "`legendleft1'"==""  & "`legendleft2'"=="" {
	local legenddef1 = "Group 1"
	local legenddef2 = "Group 2"
	}
	
if `legendleftyn' ==1 {
	local legendtext = 	"lab(1 `legenddef1') lab(2 `legenddef2')"
	}
	
*Code to display legend	- for scatter plot
if `legendrightyn' ==0  {
	local legendtext_scat = "off"
	}
		
if `legendrightyn' ==1 & "`legendright1'"=="" &  `riskdiff'==0 {
	local legenddefscat1 = "log10(Relative risk)"
	}

if `legendleftyn' ==1 & "`legendright1'"!="" &  `riskdiff'==0 {
	local legenddefscat1 = "`legendright1'"
	}
	
if `legendrightyn' ==1 & "`legendright1'"=="" &  `riskdiff'==1 {
	local legenddefscat1 = "Risk difference"
	}

if `legendrightyn' ==1 & "`legendright1'"!="" &  `riskdiff'==1 {
	local legenddefscat1 = "`legendright1'"
	}
	
if `legendrightyn' ==1 & "`legendright2'"=="" {
	local legenddefscat2 = "95% CI"
	}
	
if `legendrightyn' ==1 & "`legendright2'"!="" {
	local legenddefscat2 = "`legendright2'"
	}
	
if `legendrightyn' ==1 & "`legendright1'"==""  & "`legendright2'"==""  &  `riskdiff'==0 {
	local legenddefscat1 = "log10(Relative risk)"
	local legenddefscat2 = "95% CI"
	}

if `legendrightyn' ==1 & "`legendright1'"==""  & "`legendright2'"==""  &  `riskdiff'==1 {
	local legenddefscat1 = "Risk difference"
	local legenddefscat2 = "95% CI"
	}

if `legendrightyn' ==1 {
	local legendtext_scat = "lab(1 `legenddefscat1') lab(2 `legenddefscat2')"
}
	
***************************************************************************************************************

*To order events 

if `riskdiff'==0 {
	sort relrisk
	gen n=_n

	*Generates a rank of relrisk from largest to smallest

	gsort -relrisk
	gen n1 =_n

	summ n1
	local max = r(max)
	disp `max'
	
	}
	 
if `riskdiff'==1 {
	sort risk_diff
	gen n=_n

	*Generates a rank of relrisk from largest to smallest
	
	gsort -risk_diff
	gen n1 =_n

	summ n1
	local max = r(max)
	
	}

*******************PLOTS****************************

tempfile graph_abs
tempfile graph_rel
tempfile graph_rd

*Relative risk (logged)
	if `riskdiff'==0 {
					
		graph dot perc1 perc2 , over(event, sort(n1) relabel(`leftlabel')    label(labsize(*`leftlabsize') angle(`leftlabang') ))   ///
			marker(1, mfcolor(`leftcolor1'%`leftcolsat1') mlcolor(`leftcolor1') msymbol(`leftsymb1') ) marker(2, mfcolor(`leftcolor2'%`leftcolsat2') mlcolor(`leftcolor2') msymbol(`leftsymb2')) ///
			dots(mcolor(gray))  ytitle(`leftxtitle')  yscale(range (1 `max')) ///
			graphregion(color(`grphcol')) plotregion(color(`plotcol') margin(b `bleftmargin' t `tleftmargin')) aspect(`aspectleft')  ///
			legend(`legendtext'  pos(`legendleftpos') col(`legendleftcol') row(` legendleftrow'))
			
		graph save Graph `graph_abs'.gph , replace
	 
			
		twoway  (dot logRR n1   ,  horizontal sort(n1) dcolor(`rightdcolor') mcolor(`rightdotcol'%`rightdotsat') ) /// 
		   (rcap loglowerCIRR logupperCIRR n1  , horizontal sort(n1) lcolor(`rightlincol'%`rightlinsat')), /// 
			ylabel( "", angle(0) noticks nogrid) ytitle("" ) yscale(reverse) yscale(range (1 `max'))   ///
			xlabel(, noticks angle(0))  xtitle(`rightplot' , color(white) size(vlarge)) xline(`xnum' ,  lpattern(`rightxlinepat') lcolor(`rightxlinecol') lwidth(0.5)  ) ///
			legend(`legendtext_scat' pos(`legendscatpos') col(`legendscatcol') row(`legendrightrow')   ) ///
			graphregion(color(`grphcol')) plotregion(color(`plotcol') margin(b `brightmargin' t `trightmargin'))  aspect(`aspectright') 
			
		graph save Graph `graph_rel'.gph , replace
	
		graph combine  `graph_abs'.gph  `graph_rel'.gph   ,  xcommon ycommon iscale(0.5) title(`title') subtitle(`subtitle')  graphregion(color(`grphcol'))
		 
	
		}
	

*Plot of risk difference
	if `riskdiff'==1 {
			 
		graph dot perc1 perc2 , over(event, sort(n1) relabel(`leftlabel')  label(labsize(*`leftlabsize') angle(`leftlabang') ))   ///
			marker(1, mfcolor(`leftcolor1'%`leftcolsat1') mlcolor(`leftcolor1') msymbol(`leftsymb1') ) marker(2, mfcolor(`leftcolor2'%`leftcolsat2') mlcolor(`leftcolor2') msymbol(`leftsymb2')) ///
			dots(mcolor(gray))  ytitle(`leftxtitle') yscale(range (1 `max'))   ///
			graphregion(color(`grphcol')) plotregion(color(`plotcol') margin(b `bleftmargin' t `tleftmargin')) aspect(`aspectleft')  ///
			legend(`legendtext'  pos(`legendleftpos') col(`legendleftcol') row(` legendleftrow'))
			
		graph save Graph `graph_abs'.gph , replace
	 
		twoway  (dot risk_diff n1   ,  horizontal sort(n1) dcolor(`rightdcolor') mcolor(`rightdotcol'%`rightdotsat') ) /// 
		   (rcap lowerRD upperRD n1  , horizontal sort(n1) lcolor(`rightlincol'%`rightlinsat')), /// 
			ylabel( "", angle(0) noticks nogrid) ytitle("" ) yscale(reverse) yscale(range (1 `max'))  ///
			xlabel(, noticks angle(0))  xtitle(`rightplot' , color(white) size(vlarge)) xline(`xnum' ,  lpattern(`rightxlinepat') lcolor(`rightxlinecol') lwidth(0.5)  ) ///
			legend(`legendtext_scat' pos(`legendscatpos') col(`legendscatcol') row(`legendrightrow')   ) ///
			graphregion(color(`grphcol')) plotregion(color(`plotcol') margin(b `brightmargin' t `trightmargin'))  aspect(`aspectright') 
			
		graph save Graph `graph_rd'.gph , replace

		graph combine  `graph_abs'.gph  `graph_rd'.gph   ,  xcommon ycommon iscale(0.5) title(`title') subtitle(`subtitle')  graphregion(color(`grphcol'))
		 
		}
		
if "`saving'"!="" {
	noi save `filename', `replace'
}

if "`graphsave'"!="" {
	noi graph save `graphname', `graphreplace'
}

if "`clear'" == "" {
	use  `original'.dta , clear
}

else {
	restore, not
	use `ae_doti_1'.dta , clear
}
}

end
exit
