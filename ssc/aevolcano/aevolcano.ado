*! ae_volcano ver 1.0 10/02/2020
*start with row per event
cap prog drop aevolcano
cap postclose ae_volc 
program define aevolcano, rclass 
version 15.0


tempfile original
tempfile ae_volcano_1

/*
  DESCRIPTION: Creating a volcano plot for AE data in clinical trials
  ver 1.0: original   
*/
 
	
*Current syntax	
	 syntax varlist ,  treat(varname) id(varname) n1(integer) n2(integer) ///
   [ ODDSratio(integer 0) RISKratio(integer 0) PVALue(integer 0) ///
	 PADJ(integer 0) fdrlower(varname) fdrhigher(varname)  FDRval(real 0.1)  ///
	 labelyn(integer 0)  label(real 1) labelnum(integer 0) ///
	 labcol(string) labang(integer 90) labpos(integer 12) labgap(integer 5) ///
	 labcol1(string) labang1(integer 90) labpos1(integer 12) labgap1(integer 5) ///
	 labcol2(string) labang2(integer 90) labpos2(integer 12) labgap2(integer 5) ///
	 xaxismin(real 0) xaxismax(real 0) xaxisdp(real 0.1)  xaxisticks(real 4) ///
	 yaxismin(real 0) yaxismax(real 0) yaxisdp(real 0.1) yaxisticks(real 4)  ///
	 xaxistitle(string) yaxistitle(string) title(string) subtitle(string)  ///
	 ylineyn(integer 0) yline(numlist)  ylinepat(string) ylinecol(string) ylinewidth(real 0.5) ///
	 mfcolor(string)   mlcolor(string)  ///
	 mfcolor1(string)  mlcolor1(string)  ///
	 mfcolor2(string)  mlcolor2(string)  /// 
	 grphcol(string) plotcol(string) ///
     legendyn(integer 0) legend1(string) legend2(string)  legendpos(integer 6) legendcol(integer 1) legendrow(integer 2)  ///
	 SAVing(string) graphsave(string) clear ]
	 
	 preserve

	/* 
	Syntax explanation
	varlist - can contain string or numeric and indicates variable that contains the AE name/identifier
	treat - variable containing treat allocation - recommend code treatment as 1 and placebo as 2
	id - individual patient ID - patients can have more than one entry (row) 
	n1 - number in treatment group (participants may not have all had an AE so n may be higher than n in AE dataset)
	n2 - number in control group  (participants may not have all had an AE so n may be higher than n in AE dataset)
	*/
	
/*	 
 Optional commands
	(1) oddsratio is optional and if not specified default is 0 which indicates output risk difference,
		if oddsratio is 1 then output odds ratio
	
	(2) riskratio is optional and if not specified default is 0 which indicates output risk difference,
		if riskratio is 1 then output risk ratio
		
	(3) pvalue is optional and if not specified default is 0 which indicates the p-value from the Fisher's exact test is used,
		if pvalue is 1 then p-value from Pearson's chi-squared is used
		
		*******************************************
	(4)  padj is optional and if not specified default is 0 which indicates no p-value adjustement
		  if padj is 1 then the FDR p-value adjustment is invoked
		 
		(5-7) these commands are available if call on aefdr command
		if padj is 1 then user needs to specify:
		
		(5) fdrhigher - to indicate variable with bodysystem event/higher term
		(6) fdrlower  - to indicate variable with preferred term/lower level event term
		  if these are not specified then error should be returned 
		  
		(7) fdrval is optional and indicates the value that adjustment carried out on (flags events with adjusted event/lowerterm 
				and bodysystem/higher term p-value below it) - default is 0.1
		 *******************************************
		  
	(8) labelyn is optional and if not specified default is 0 which indicates bubble labels turned off,
			if labelyn is 1 then bubble/circle labels turned on and the option `label' can be used to indicate
			threshold for labels based on p-values
		
		(9) label(real 1) is optional and if not specified default value is 1 which means any variables with 
		log10 P-value greater than 1 will be labeled, this equates to a p-value <0.1. 
			
		(10) labelnum is optional and if not specified default is 0 which indicates number labels not required,
			if labelnum is 1 then bubble labels assigned numeric values - only applies when varlist numeric
			if labelnum is 2 then bubble labels assigned label values - only applies when varlist numeric
				
		(11) labcol is optional - gives overall label color. If labcol not specified then: 
			labcol1 and labcol2 are optional and if not specified default to black - allows bubble label colour to be changed - can differ between treatment groups
			 labcol1 and labcol2 take strings and acceptable entries include Stata colorstyle. See help colorstyle. Error message issued if entered incorrectly
	
	(12) labang is optional - gives overall label angel. If not specified then:
		labang1 and labang2 are optional and if not specified default is 90 giving vertical bubble labels - can differ between treatment groups

	(13) labpos is optional - gives overall label position. If not specified then:
		labpos1 and labpos2 are optional and if not specified default is 12 giving bubble labels above the point -
		can differ between treatment groups 

	(14) labgap is optional - gives overall label gap. If not specified then: 
		labgap1 and labgap2 are optional and if not specified default is 5 giving a gap of 5 points between point and bubble label
		- can differ between treatment groups

	(15) xaxismin, xaxismax, yaxismin and yaxismax(real 0) are optional commands with default 0 - 
			they allow user to add a value to min and max x and y axis values to extend the plot area - 
			the default 0 results in the actual min and max values being using for axis limits e.g. a value of 2 adds 2 units to the maximum.
			
	(16) xaxisticks and yaxisticks are optional with default 4 - they allow the user to specify how the xaxis and yaxis are 
		divided/how the ticks are spaced. This divides the range (max-min) of xaxis and yaxis values 
		and will incorporate and additions made to this range through xaxismin, xaxismax, yaxismin and yaxismax
			
	(17) xaxisdp and yaxisdp are optional with default 0.1 - they allow the user to specify the units the xaxis and yaxis values are rounded to
				
	(18) ylineyn is optional and if not specified then default is 0 which indicates that yline is "off"
			which means line colour is white and therefore does not appear on the plot i.e. sets default to yline off
			if ylineyn is 1 then defaults below apply
	
	(19) yline is optional and if not specified default is to give a line at value of 1 which equates to a p-value of 0.1
			Unless the aefdr adjustment used in which case the yline is plotted at the min adjusted p-value to indicate significance and if
			no events were flagged as significant after adjustment the line is set at 0
			yline can take a list of numbers to produce multiple horizontal lines

	(20) ylinepat is optional and if not specified defaults to dash - giving a dashed yline 
			ylinepat takes strings, acceptable entries include Stata linepatternstyle e.g.
			solid, dash, dot, dash dot, shortdash, shortdash dot, longdash, longdash dot, blank. See help linepatternstyle.
			Error message issued if entered incorrectly

	(21) ylinecol is optional and if not specified defaults to bluishgray - giving a bluishgrey horizontal line
			ylinecol takes strings and acceptable entries include Stata colorstyle. See help colorstyle
			Error message issued if entered incorrectly

	(22) ylinewidth is optional and if not specified defaults to line width of 0.5

	(23)  mfcolor is optional - gives overall bubble fill  color. If mfcolor not specified then: 
			mfcolor1 and mfcolor2 are optional and default to red and blue filled bubbles if not specified 
			mfcolor1 and mfcolor2 take strings and acceptable entries include Stata colorstyle. See help colorstyle
			Error message issued if entered incorrectly

	(24) mlcolor - mlcolor1 and mlcolor2 are optional and default to red and blue outlines for bubbles if not specified 
			mlcolor1 and mlcolor2 take strings and acceptable entries include Stata colorstyle. See help colorstyle
			Error message issued if entered incorrectly 

	(25) mfcolsat, mfcolsat1 and mfcolsat2  default to 80 - gives saturation of bubble fill colour

	(26) mlcolsat, mlcolsat1 and mlcolsat2 are restricted 80 - gives saturation of bubble outline colour

	****mfcolsat1, mfcolsat2, mlcolsat1 and mlcolsat2 are restricting the bubble colour opacity and are set at standard values

	(27) grphcol and plotcol are optional and default to white background for plot and graph background colour
			grphcol and plotcol  take strings and acceptable entries include colorstyle. See help colorstyle
			Error message issued if entered incorrectly

	(28) legendyn is optional and if not specified default value is 0 which indicates legend turned off 
			if legendyn is 1 then legend on and the options `legend1' and `legend2' can be used to add text to the legend
			If legendyn is 1 and legend1 and legend2 not specified legend will display "Risk in Group 1" and "Risk in Group 2"
*/

/*
*NOTES 
  (1) Allow labels to change position, angle and gap from bubble but sometimes labels still overlap - in this scenario advise users to switch labels off and insert own labels. 
			Alternatively use a numeric variable and label with numbers
  (2) Number of labels specified by choosing log10 P-value that should be exceeded e.g. 1 which equates to p-value less than 0.1. 
  (3) Incorporates a continuity correction (adds 0.5 an event to each group) when fitting odds or risk and there are 0 events in one of the arms
  (4) Odds ratio risk ratio plotted on log scale to ensure symmetrical axis
  
  */

**********************************************************************************
qui{ /* open the big quietly loop around aevolcano*/

local mlcolsat = 80
local mlcolsat1 = 80
local mlcolsat2 = 80
local mfcolsat = 80
local mfcolsat1 = 80
local mfcolsat2 = 80


****Error checking*********
*Confirm patient id numeric
cap confirm numeric variable `id' 
local id_num =  _rc
if `id_num' !=0 {
	display as error "id variable not numeric"
	exit 7
	}
	
*treat needs to contain a number 
cap confirm numeric variable `treat' 
local treat_num = _rc
if `treat_num' !=0 {
	display as error "treat variable not numeric"
	exit 7
	}
		
*Only one of oddsratio or riskratio can be specified 
if `oddsratio'==1 & `riskratio'==1 {
	display as error "only one of oddsratio or riskratio can be specified at a time"
	exit 7
	}
	
*pvalue can only take values 0 or 1 to indicate if Fisher's exact or Pearson's chi squared p-values should be used
if `pvalue' >1 | `pvalue'<0  {  
	display as error "pvalue can only take values 0 or 1"
	exit 7
	}
	
*padj can only take values 0 or 1 to indicate if p-value adjustment should be used
if `padj' >1 | `padj'<0  {  
	display as error "padj can only take values 0 or 1"
	exit 7
	}
	
*if padj=1 then calls aefdr command which requires fdrhigher and fdrlower to be specified
if (`padj' ==1 & "`fdrhigher'"=="") | (`padj' ==1 & "`fdrlower'"=="")   {
	display as error "if padj specified then fdrhigher and fdrlower required"
	exit 7
	}
	
if (`padj' ==0 & "`fdrhigher'"!="")  {
	display as error "fdrhigher not applicable if no adjustment"
	exit 7
	}

if (`padj' ==0 & "`fdrlower'"!="")  {
	display as error "fdrlower not applicable if no adjustment"
	exit 7
	}
	
*labelyn can only take values 0 or 1 to indicate if labels off or on, respectively 	
if `labelyn' >1 | `labelyn'<0  {  
	display as error "labelyn can only take values 0 or 1"
	exit 7
	}
	
*labelnum can only take values 0 or 1 or 2 to indicate if labels should take numeric values or labels - only applicable when varlist is numeric	- this is checked further down 
if `labelnum' >2 | `labelnum'<0  {  
	display as error "labelnum can only take values 0, 1 or 2"
	exit 7
	}
	
if `labelyn'==0 & `labelnum'!=0 {
	display as error "labelnum only applicable when labels turned on"
	exit 7
	}
	
if "`labcol'"!=""{
	local labcol1="`labcol'"
	local labcol2="`labcol'"
}

*If labang not equal to default value then individual labang commands can be used
if "`labang'"!="90"{
	local labang1=`labang'
	local labang2=`labang'
}

if "`labpos'"!="12"{
	local labpos1=`labpos'
	local labpos2=`labpos'
}

if "`labgap'"!="5"{
	local labgap1=`labgap'
	local labgap2=`labgap'
	}

if "`mfcolor'"!=""{
	local mfcolor1="`mfcolor'"
	local mfcolor2="`mfcolor'"
}

if "`mlcolor'"!=""{
	local mlcolor1="`mlcolor'"
	local mlcolor2="`mlcolor'"
}

*labpos can only take integer values between 0 and 12
if "`labpos'"!=""{
	if `labpos' >12 | `labpos'<0  {  
		display as error "labpos can only take integer values between 0 and 12"
		exit 7
		}
	}
	
if `labpos1' >12 | `labpos1'<0  {  
	display as error "labpos1 can only take integer values between 0 and 12"
	exit 7
	}	
if `labpos2' >12 | `labpos2'<0  {  
	display as error "labpos2 can only take integer values between 0 and 12"
	exit 7
	}	

******setting linepattern default before error checking***************************
*Linepattern defaults to dash 
if "`ylinepat'" == "" {	
	local ylinepat= "dash"
	}

*if default y line off then use ylineyn to default colour to white so can't see it
if `ylineyn' >1 | `ylineyn'<0  {  
	display as error "ylineyn can only take values 0 or 1"
	exit 7
	}
	
if `ylineyn'==0 {
	local ylinecol = "white"
	}

*yline colour defaults to bluishgray 
if `ylineyn'==1 & "`ylinecol'" == "" {
	local ylinecol = "bluishgray"
	}
		
*******Error checking - restrict ylinepat to the linepattern available in Stata********
local test = c(sysdir_base)
local test2 = "`test'"+"style"
local linepatopt : dir "`test2'" files "linepattern-*.style"
local linepatopt : list clean linepatopt
local linepatopt: subinstr local linepatopt "linepattern-" "", all
local linepatopt: subinstr local linepatopt ".style" "", all
local linepatopt: subinstr local linepatopt "blank" "", all

tempvar lpat1
gen `lpat1'=0 
if  "`ylinepat'"!="" {
	foreach lname in `linepatopt' {
		cap replace `lpat1'=1  if "`lname'"=="`ylinepat'"
		}
	}
	
if `lpat1'== 0 {
	disp as error "`ylinepat' is not a Stata linepattern style. Please see Stata linepatternstyle for acceptable options"
	exit 198
	}

*************Setting default colours before error checking************
*Label colours
if "`labcol1'" == "" {
		local labcol1 = "black"
		}

if "`labcol2'" == "" {
		local labcol2 = "black"
		}
		
*Default bubble colour fill in group with risk difference >=0 plot to red (if treatment =1 and control = 2 then riskdiff>=0 indicates increased risk in treatment grp)
if "`mfcolor1'" == "" {
	local mfcolor1 ="red"
	}

*Default bubble colour fill in group with risk difference <0 plot to blue (if treatment =1 and control = 2 then riskdiff<0 indicates increased risk in control grp)
if "`mfcolor2'" == "" {
	local mfcolor2 ="blue"
	}
		
*Default bubble colour outline in risk difference >=0 plot to red
if "`mlcolor1'" == "" {
	local mlcolor1 ="red"
	}

*Default bubble colour outline in risk difference <0 plot to blue
if "`mlcolor2'" == "" {
	local mlcolor2 ="blue"
	}	

*Default plot background colour to white
if "`plotcol'" =="" {
	local plotcol = "white"
	}
	
*Default graph background colour to white
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
if  "`mfcolor1'"!="" {
	foreach lname in `coloropt' {
		cap replace `col1'=1  if "`lname'"=="`mfcolor1'"
		}
	}
if `col1'== 0 {
	disp as error "`mfcolor1' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col2
gen `col2'=0 
if  "`mfcolor12"!="" {
	foreach lname in `coloropt' {
		cap replace `col2'=1  if "`lname'"=="`mfcolor2'"
		}
	}
if `col2'== 0 {
	disp as error "`mfcolor2' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col3
gen `col3'=0 
if  "`labcol1"!="" {
	foreach lname in `coloropt' {
		cap replace `col3'=1  if "`lname'"=="`labcol1'"
		}
	}
if `col3'== 0 {
	disp as error "`labcol1' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col4
gen `col4'=0 
if  "`labcol2"!="" {
	foreach lname in `coloropt' {
		cap replace `col4'=1  if "`lname'"=="`labcol2'"
		}
	}
if `col4'== 0 {
	disp as error "`labcol2' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col5
gen `col5'=0 
if  "`ylinecol"!="" {
	foreach lname in `coloropt' {
		cap replace `col5'=1  if "`lname'"=="`ylinecol'"
		}
	}
if `col5'== 0 {
	disp as error "`ylinecol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col6
gen `col6'=0 
if  "`mlcolor1"!="" {
	foreach lname in `coloropt' {
		cap replace `col6'=1  if "`lname'"=="`mlcolor1'"
		}
	}
if `col6'== 0 {
	disp as error "`mlcolor1' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col7
gen `col7'=0 
if  "`mlcolor2"!="" {
	foreach lname in `coloropt' {
		cap replace `col7'=1  if "`lname'"=="`mlcolor2'"
		}
	}
if `col7'== 0 {
	disp as error "`mlcolor2' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
tempvar col8
gen `col8'=0 
if  "`plotcol"!="" {
	foreach lname in `coloropt' {
		cap replace `col8'=1  if "`lname'"=="`plotcol'"
		}
	}
if `col8'== 0 {
	disp as error "`plotcol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}

tempvar col9
gen `col9'=0 
if  "`grphcol"!="" {
	foreach lname in `coloropt' {
		cap replace `col9'=1  if "`lname'"=="`grphcol'"
		}
	}
if `col9'== 0 {
	disp as error "`grphcol' is not a colour. Please see Stata colorstyle for acceptable options"
	exit 198
	}
	
*legendyn can only take values 0 or 1
if `legendyn' >1  | `legendyn'<0 {  
	display as error "legendyn can only take values 0 or 1"
	exit 7
	}
	
*Legend labels can only be specified when legend on
if `legendyn' ==0 & "`legend1'"!=""   {
	display as error "legend1 can only be specified when legend on"
	exit 7
	}

if `legendyn' ==0 & "`legend2'"!=""   {
	display as error "legend2 can only be specified when legend on"
	exit 7
	}
	
*legendpos can only take integer values between 0 and 12
if `legendpos' >12 | `legendpos'<0  {  
	display as error "legendpos can only take integer values between 0 and 12 "
	exit 7
	}	
	
*Error checking - saving command correctly specified
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
	

*************************************************************************************************************************


tokenize `varlist'
local by "`1'"
*local event "`1'"  

*Error message if specify more than one variable to analyse by
if "`2'"!="" {
	display as error "too many variables specified. Please specify only one variable to examine the adverse events by."
	exit 198
}


*Create numeric/string indicators for higher/loewr fdr for use after post file below to direct ae_fdr
cap confirm numeric variable `fdrhigher'
local higher_n_rc=_rc
di `higher_n_rc'

cap confirm numeric variable `fdrlower'
local lower_n_rc=_rc
di `lower_n_rc'

cap confirm string variable `fdrhigher' 
local higher_s_rc=_rc
di `higher_s_rc'

*If numerical can keep labels if required
cap confirm numeric variable `by'
local num_status =  _rc
if `num_status' ==0 {
	if `labelnum'==2{
		tempvar by_decoded
		decode `by', gen(`by_decoded')
		local by "`by_decoded'"
		local varlist "`by_decoded'"
	}
}

	/*Code for string variable*/
	if substr("`:type `by''" ,1,3) == "str" {
			
			levelsof `treat', matrow(uniqlist)
			mat list uniqlist
			*matrix with a row for each treatment arm

			local count_treat=r(r)
			*local var with number of treatment arms

			mat define results=J(`count_treat',3,.)
			*matrix with 3 columns and number of rows as defined by `count_treat' which is number of treatment arms

			egen ae_id = group(`by')
			*gen a numeric variable for each AE listed in by (where by is the list of variables in varlist of syntax)
			
			tab ae_id
			local count=r(r)
			*local var with number of distinct AEs
	
			save `original'.dta  , replace

			postfile  ae_volc r1 r2 risk_diff odds_ratio log_OR risk_ratio log_RR n_events p_val log_p_val p_val_chi log_p_val_chi str80 event str80 bs_event  using `ae_volcano_1'.dta, replace

			forvalues i=1(1)`count' {
			*runs through the following for each AE
	
				use `original'.dta , clear
				keep if ae_id==`i'
				*Keeps all occurrences of the first AE, then on next run through the second AE and so on
				
				forvalues t=1(1)`count_treat'{
				*runs through it for each treatment group separately
	
					local arm_level=uniqlist[`t',1]
					di `arm_level'
											
					inspect `id' if `treat'==`arm_level'
					*Summarises every variable when treatment group =1 and then 2 and so dependent on how many arms there are but the plot really only applicable when two groups
									
					 local n_`t' = r(N_unique)
					*local var with number of AEs
				
					*If there are more than 99 unique values then r(N_unique) will be set to missing
					*to overcome this use the levelsof command instead 
					
					if `n_`t'' ==. {
						levelsof `id' if `treat'==`arm_level'
						local n_`t' = r(r)
						}

					local r`t' = `n_`t''/`n`t''	
					*local var with proportion where n_t comes from previous line and nt comes from syntax line
					
					local n`t'_p2 = `n`t''-`n_`t''
					*local var with number on treatment arm minus those with event - gives number without event
				
					local tot_`t' = `n`t''
				}
	
				**********RISK DIFFERENCE & P-VALUE*****************				
				*Now using info from each treatment group
				local risk_diff=(`n_1'/`n1')-(`n_2'/`n2')
				*local var with proportion in treatment 1 - proportion in treatment 2			
		
				tabi `n_1' `n1_p2' \ `n_2' `n2_p2', exact chi
				*direct test with number with and without event in each treatment group
				*gives fishers exact p-value and chi-squared p-value
				
				local p_val = r(p_exact)
				*local var containing p-value from Fisher's exact test from the tabi command
				
				local log_p = -1*log10(`p_val')
				*local var containing the log of the above p-value
				
				local p_val_chi = r(p)
				*local var containing p-value from chi squared test issued in tabi command
				
				local log_p_chi = -1*log10(`p_val_chi')
				*local var containing the log of the chi-squared p-value
				************************************************
				
				*If 0 events present then the risk ratio and odds ratio are non-calcuable, to avoid this we add 0.5 an event 
				if `n_1'==0 & `n_2'!=0 {
					local n_1 = 0.5
					local n_2 = `n_2'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					
					local n1_p2 = `tot_1'-`n_1'
					local n2_p2 = `tot_2'-`n_2'
					}
					
				if `n_2'==0 & `n_1'!=0 {
					local n_2  = 0.5
					local n_1 = `n_1'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					
					local n1_p2 = `tot_1'-`n_1'
					local n2_p2 = `tot_2'-`n_2'
					}
				
				*****************ODDS RATIO*******************
				local odds_ratio=(`n_1'/`n1_p2')/(`n_2'/`n2_p2')
				
				local logOR = log((`n_1'/`n1_p2')/(`n_2'/`n2_p2'))

				************************************************
				
				*****************RISK RATIO*****************
				local risk_ratio=(`n_1'/`tot_1')/(`n_2'/`tot_2')
				
				local logRR = log((`n_1'/`tot_1')/(`n_2'/`tot_2'))
				**********************************************
				
								
				count
				*count is a local var that will call number of individual AEs
				local events = r(N)
				local e_name = "`varlist'" in 1 
				di `e_name'
				
				if "`fdrhigher'" !="" {
						local bs_name = `fdrhigher' in 1 
						di "`bs_name'"
						}
						
				else {
						local bs_name = "" 
					}
			  
			post ae_volc (`r1') (`r2') (`risk_diff') (`odds_ratio') (`logOR') (`risk_ratio') (`logRR') (`events') (`p_val') (`log_p') (`p_val_chi') (`log_p_chi') (`e_name') ("`bs_name'")  

			use `original'.dta , clear
			}
	}

	
	else { 
			/* numeric option*/
			local by "`1'"
			macro shift
					
			levelsof `treat', matrow(uniqlist)
			mat list uniqlist

			local count_treat=r(r)

			mat define results=J(`count_treat',3,.)

			egen ae_id = group(`by')
			tab ae_id
			local count=r(r)
			
			save `original'.dta  , replace
			
			postfile  ae_volc r1 r2 risk_diff odds_ratio log_OR risk_ratio log_RR n_events p_val log_p_val p_val_chi log_p_val_chi    eventnum   bsnum str80 bs_event using `ae_volcano_1'.dta, replace

			forvalues i=1(1)`count' {
				use `original'.dta , clear
				keep if ae_id==`i'
				
				forvalues t=1(1)`count_treat'{
	
					local arm_level=uniqlist[`t',1]
					di `arm_level'
				
					inspect `id' if `treat'==`arm_level'
					local n_`t' = r(N_unique)
					
					*If there are more than 99 unique values then r(N_unique) will be set to missing
					*to overcome this  use the levelsof command instead 
					
					if `n_`t'' ==. {
						levelsof `id' if `treat'==`arm_level'
						local n_`t' = r(r)
						}
					
					local r`t' = `n_`t''/`n`t''		
					local n`t'_p2 = `n`t''-`n_`t''
					local tot_`t' = `n`t''
				}
					
				********RISK DIFFERENCE & P-VALUE******************
				local risk_diff=(`n_1'/`n1')-(`n_2'/`n2')
				tabi `n_1' `n1_p2' \ `n_2' `n2_p2', exact chi
				local p_val = r(p_exact)
				local log_p = -1*log10(`p_val')
				
				local p_val_chi = r(p)
				local log_p_chi = -1*log10(`p_val_chi')
					
				****************************************************	
				if `n_1'==0 & `n_2'!=0 {
					local n_1 = 0.5
					local n_2 = `n_2'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					
					local n1_p2 = `tot_1'-`n_1'
					local n2_p2 = `tot_2'-`n_2'

					}
					
				if `n_2'==0 & `n_1'!=0 {
					local n_2  = 0.5
					local n_1 = `n_1'+0.5
					local tot_1 = `tot_1'+0.5
					local tot_2 = `tot_2'+0.5
					
					local n1_p2 = `tot_1'-`n_1'
					local n2_p2 = `tot_2'-`n_2'
					}

					
				*****************ODDS RATIO*******************
				local odds_ratio=(`n_1'/`n1_p2')/(`n_2'/`n2_p2')
				
				local logOR = log((`n_1'/`n1_p2')/(`n_2'/`n2_p2'))
				***********************************************
							
				*****************RISK RATIO*****************
				local risk_ratio=(`n_1'/`tot_1')/(`n_2'/`tot_2')
				
				local logRR = log((`n_1'/`tot_1')/(`n_2'/`tot_2'))
				**********************************************
				
				count
				local events = r(N)
							
				*getting the numeric value for the event
				local e_name_num = "`by'" in 1 
				di `e_name_num'
				
				cap confirm numeric variable `fdrhigher' 
				local bs_num = _rc 
				
				*if higherterm is also numeric capturing the numeric value 
				if "`fdrhigher'" !="" & `bs_num'==0  {
					local bs_name_num = "`fdrhigher'" in 1 
					di `bs_name_num'
					}
			
					if "`fdrhigher'" =="" | `bs_num'!=0  {
						local bs_name_num = .
					}
				
				*if higherterm is string then 
				if "`fdrhigher'" !="" & `bs_num'!=0  {
					*getting the string label for the event				
					local bs_name = `fdrhigher' in 1 
					di "`bs_name'"
					}
					
				if "`fdrhigher'" =="" | `bs_num'==0  {
						local bs_name = "" 
					}
			  
				post ae_volc (`r1') (`r2') (`risk_diff') (`odds_ratio') (`logOR') (`risk_ratio') (`logRR') (`events') (`p_val') (`log_p') (`p_val_chi') (`log_p_chi')   (`e_name_num')    (`bs_name_num')  ("`bs_name'")
	
				use `original'.dta , clear
			}
	}
	
postclose ae_volc


use `ae_volcano_1'.dta, clear
lab var r1 "Proportion with event in group 1"
lab var r2 "Proportion with event in group 2"
lab var risk_diff "Risk difference"
lab var odds_ratio "Odds ratio"
lab var log_OR "log(odds ratio)" 
lab var risk_ratio "Risk ratio"
lab var log_RR "log(risk ratio)"
lab var n_events "Total number of events"
lab var p_val "Fisher's exact p-value"
lab var log_p_val "log(Fisher's exact p-value)"
lab var p_val_chi "Chi-squared test p-value"
lab var log_p_val_chi "log(Chi-squared test p-value)"
cap lab var event "AE name (lower level)"
cap lab var bs_event "Bodysystem name (higher level)"
cap lab var eventnum "AE number (lower level)"
cap lab var bsnum "Bodysystem number (higher level)"

sort event
save `ae_volcano_1'.dta , replace


******************************************************************************************************
 
*call on aefdr command  - current version aefdr.ado - program included at the end of this code

*For string variables (this will include numerics with labels turned into strings - if lablnum=2)
cap confirm string variable bs_event 
local body_string = _rc

cap confirm string variable event
local event_string = _rc

*PATH FOR STRING STRING or STRING NUMERIC (as bs_event always a string within even when body system started numeric)
if `body_string'==0 & `event_string'==0 {

	if `padj' ==1 {
	*If p-value adjustment on 

		if `pvalue'==0 {
			*if default p-value calculated (Fisher's exact) use variable "p_val" for aefdr command
			 
			aefdr  , fdrhigher(bs_event) fdrlower(event) pvalueadj(p_val) fdrval(`fdrval') 
				
			summ p_val if flag==1
			local ynumadj= r(max) 
			local log_ynumadj = -1*log10(`ynumadj')

			sort event
			merge  event using `ae_volcano_1'.dta
			*aefdr replace the dataset that  we need - ae_volcano_1. Merge ae_volcano_1 in so that now includes the adjusted p-values
			}

		 else {
			 *if  p-value chi-squared p-value calculated use variable "p_val_chi" for aefdr command

			aefdr  , fdrhigher(bs_event ) fdrlower(event) pvalueadj(p_val_chi) fdrval(`fdrval') 
				
			summ p_val_chi if flag==1
			local ynumadj= r(max)
			local log_ynumadj = -1*log10(`ynumadj')

			sort event
			merge  event using `ae_volcano_1'.dta
			}
		}
	}

*For numeric variables (excluding those which have aready been turned to string for labels if labelnum==2)

if `labelnum'!=2 {
	local body_numeric = `higher_n_rc'
	local event_numeric = `lower_n_rc'
}

else {
	local body_numeric = 123
	local event_numeric = 123
}

*PATH FOR NUMERIC NUMERIC
if `body_numeric'==0 & `event_numeric'==0 {

	if `padj' ==1 {
	*If p-value adjustment on 

		if `pvalue'==0 {
		*if default p-value calculated (Fisher's exact) use variable "p_val" for aefdr command
		 
			aefdr  , fdrhigher(bsnum) fdrlower(eventnum) pvalueadj(p_val) fdrval(`fdrval') 
				
			*egen ynum_adj = max(p_val) if flag==1
			summ p_val if flag==1
			local ynumadj= r(max) 
			local log_ynumadj = -1*log10(`ynumadj')

			sort event
			merge  event using `ae_volcano_1'.dta
			}

		else {
			 *if  p-value chi-squared p-value calculated use variable "p_val_chi" for aefdr command

			aefdr  , fdrhigher(bsnum ) fdrlower(eventnum) pvalueadj(p_val_chi) fdrval(`fdrval') 
				
			summ p_val_chi if flag==1
			local ynumadj= r(max)
			local log_ynumadj = -1*log10(`ynumadj')
		
			sort event
			merge  event using `ae_volcano_1'.dta
			}
		}
	}
		
	**PATH FOR NUMERIC STRING:
	if `labelnum'!=2 {
		local body_string2 = `higher_s_rc'
		local event_numeric = `lower_n_rc'
	}

	else {
		local body_string2 = 123
		local event_numeric = 123
	}
	
	if `body_string2'==0 & `event_numeric'==0 {

		if `padj' ==1 {
		*If p-value adjustment on 

			if `pvalue'==0 {
				*if default p-value calculated (Fisher's exact) use variable "p_val" for aefdr command
				*bsnum will be numeric or empty if body system is a string
				aefdr  , fdrhigher(bs_event) fdrlower(eventnum) pvalueadj(p_val) fdrval(`fdrval') 
				summ p_val if flag==1
				local ynumadj= r(max) 
				local log_ynumadj = -1*log10(`ynumadj')
				sort event
				merge  event using `ae_volcano_1'.dta
			}

			*if `pvalue'==1 {
				else {
					*if  p-value chi-squared p-value calculated use variable "p_val_chi" for aefdr command
					aefdr  , fdrhigher(bs_event ) fdrlower(eventnum) pvalueadj(p_val_chi) fdrval(`fdrval') 
					summ p_val_chi if flag==1
					local ynumadj= r(max)
					local log_ynumadj = -1*log10(`ynumadj')
					sort event
					merge  event using `ae_volcano_1'.dta
				}
			}
	}

	
cap drop _merge

summ p_val, d
sort p_val
save `ae_volcano_1'.dta , replace

****************Creating labels******************
/*Creates a label (mylabel) for all events that exceed log_p value above a specified value in the syntax 
 The default is 1 which means any variables with log10 p-value greater than 1 will be labeled which equates to a 
p-value <0.1 
*/

*If no adjustment and Fisher's exact test used then use log_p_val for labels
if `padj' ==0 & `pvalue'==0 {
		*If labelyn is 1 then labels are switched on
		*if label not specified then default value for label is 1 
		*this labels all events with log_p_val>1
	if `labelyn' ==1 & (`labelnum'==0 | `labelnum'==2) {
		gen mylabel = event if log_p_val>`label'
		}
	}

*If no adjustment and Chi squared test used then use log_p_val for labels
if `padj' ==0 & `pvalue'==1 {
		*If labelyn is 1 then labels are switched on
		*if label not specified then default value for label is 1 
		*this labels all events with log_p_val>1
if `labelyn' ==1 & (`labelnum'==0 | `labelnum'==2)  {
		gen mylabel = event if log_p_val_chi>`label'
		}
	}

*If adjustment used and Fisher's exact then
if `padj' ==1 & `pvalue'==0 {	
	*If labelyn is 1 then labels are switched on
	*and if ynumadj has a value use this as label threshold
	if `labelyn' ==1 & (`labelnum'==0 |`labelnum'==2 ) & `ynumadj'!=.  {
		gen mylabel = event if log_p_val>`log_ynumadj'
		}
	}

*If adjustment used and Chi squared used then
if `padj' ==1 & `pvalue'==1 {	
	*If labelyn is 1 then labels are switched on
	*and if ynumadj has a value use this as label threshold
	if `labelyn' ==1 & (`labelnum'==0 |`labelnum'==2 ) & `ynumadj'!=.  {
		gen mylabel = event if log_p_val_chi>`log_ynumadj'
		}
	}
	
if `padj' ==1 & `pvalue'==0 {	
	*If labelyn is 1 then labels are switched on
	*but if ynumadj is missing then default to value of label
	if `labelyn' ==1 & (`labelnum'==0 |`labelnum'==2 ) & `ynumadj'==.  {
		gen mylabel = event if log_p_val>`label'
		}
	}
	
if `padj' ==1 & `pvalue'==1 {	
	*If labelyn is 1 then labels are switched on
	*but if ynumadj is missing then default to value of label
	if `labelyn' ==1 & (`labelnum'==0 |`labelnum'==2 ) & `ynumadj'==.  {
		gen mylabel = event if log_p_val_chi>`label'
		}
	}

*******************
*Allowing numeric labels when input variables are numeric
if `labelnum'!=2 {
	cap confirm numeric variable eventnum 
	local event_num = _rc 
	
	if `event_num'!=0 & `labelnum'!=0 {
		display as error "labelnum=1 only applicable when varlist is a numeric variable"
		exit 7
	}
}

else {
	local event_num = 123
}

*If no adjustment and Fisher's exact then use log_p_val for labels 
if `padj' ==0 & `pvalue'==0 {
	if `labelyn' ==1 & `labelnum'==1 & `event_num'==0 {
		gen mylabel = eventnum if log_p_val>`label'
		}
	}
	
*If no adjustment and Chi squared used then use log_p_val for labels 
if `padj' ==0 & `pvalue'==1 {
	if `labelyn' ==1 & `labelnum'==1 & `event_num'==0 {
		gen mylabel = eventnum if log_p_val_chi>`label'
		}
	}

*If adjustment and Fisher's exact used then
if `padj' ==1 & `pvalue'==0  {
	if `labelyn' ==1 & `labelnum'==1 & `event_num'==0 & `ynumadj'!=.  {
		gen mylabel = eventnum if log_p_val>`log_ynumadj'
		}
	}
	
*If adjustment and Fisher's exact used then
if `padj' ==1 & `pvalue'==1  {
	if `labelyn' ==1 & `labelnum'==1 & `event_num'==0 & `ynumadj'!=.  {
		gen mylabel = eventnum if log_p_val_chi>`log_ynumadj'
		}
	}
		
if `padj' ==1 & `pvalue'==0   {	
	*If labelyn is 1 then labels are switched on
	*but if ynumadj is missing then default to value of label
	if `labelyn' ==1 & `labelnum'==1 & `event_num'==0 & `ynumadj'==.   {
		gen mylabel = eventnum if log_p_val>`label'
		}
	}
	
if `padj' ==1 &  `pvalue'==1   {	
	*If labelyn is 1 then labels are switched on
	*but if ynumadj is missing then default to value of label
	if `labelyn' ==1 & `labelnum'==1 & `event_num'==0 & `ynumadj'==.   {
		gen mylabel = eventnum if log_p_val_chi>`label'
		}
	}
	
cap confirm variable mylabel
if _rc==0 {
	cap confirm string variable mylabel
	if _rc!=0 {
		tostring mylabel, gen(mylabel2)
		drop mylabel
		rename mylabel2 mylabel
		replace mylabel="" if mylabel=="."
	}
}
	
*If labelyn is 0 then labels switched off 
if `labelyn' ==0  {
	gen mylabel = "" 
	}
	
	
*************Setting defaults************

*xaxis title and yaxis title
if "`xaxistitle'" =="" & `oddsratio'==0 & `riskratio'==0 {
	local xaxistitle = "Risk difference"
	}
	
if "`xaxistitle'" =="" & `oddsratio'==1 {
	local xaxistitle = "log10(Odds ratio)"
	}	

	
if "`xaxistitle'" =="" & `riskratio'==1 {
	local xaxistitle = "log10(Risk ratio)"
	}


if "`yaxistitle'" =="" & `pvalue'==0  {
	local yaxistitle = "-log10(Fishers' Exact P-value)"
	}
	
if "`yaxistitle'" =="" & `pvalue'==1  {
	local yaxistitle = "-log10(Pearson's Chi-Squared P-value)"
	}
	
*Add horizontal lines to the plot  - default to the same value as default for label i.e. 1
if `padj' ==0 {
	if "`yline'" == ""  {
		local ynum = 1
		}
	else  {
		local ynum `yline'
		}
	}

if `padj' ==1 {	
	if "`yline'" == ""  & `ynumadj'!=. {
		local ynum  `log_ynumadj'
		}
	*if adjustment on and user not specified a point for yline	then default colour to white so no line appears
	if "`yline'" == ""  & `ynumadj'==. {
		local ynum  0
		local ylinecol = "white"
		}
	if "`yline'" != ""  & `ynumadj'==. {
		local ynum  `yline'
		}
	if "`yline'" != ""  & `ynumadj'!=. {
		local ynum  `yline' `log_ynumadj'
		}
	}

	
**************************************************
*Specifying min and max axis values 
*xaxis
if `oddsratio'==0 & `riskratio'==0 {
	summ risk_diff , det
	local min = r(min)
	local max = r(max)
	local min_whole = (round(`min' , `xaxisdp')+`xaxismin')
	local max_whole = (round(`max' , `xaxisdp')+`xaxismax')
	
	local range = `max_whole' - `min_whole'
	local ticks = `range' / `xaxisticks'
	local ticks_xaxis = (round(`ticks' ,`xaxisdp'))
	}
	
if `oddsratio'==1 {
	summ log_OR , det
	local min = r(min)
	local max = r(max)
	local min_whole = (round(`min' , `xaxisdp')+`xaxismin')
	local max_whole = (round(`max' , `xaxisdp')+`xaxismax')
	
	local range = `max_whole' - `min_whole'
	local ticks = `range' / `xaxisticks'
	local ticks_xaxis = (round(`ticks' ,`xaxisdp'))
	}
	
if `riskratio'==1 {
	summ log_RR , det
	local min = r(min)
	local max = r(max)
	local min_whole = (round(`min' , `xaxisdp')+`xaxismin')
	local max_whole = (round(`max' , `xaxisdp')+`xaxismax')

	local range = `max_whole' - `min_whole'
	local ticks = `range' / `xaxisticks'
	local ticks_xaxis = (round(`ticks' ,`xaxisdp'))
	}
	
*yaxis
if `pvalue'== 0  {
	summ log_p_val , det
	local min_lp = r(min)
	local max_lp = r(max)
	local min_whole_lp = (round(`min_lp' , `yaxisdp')+`yaxismin')
	local max_whole_lp = (round(`max_lp' , `yaxisdp')+`yaxismax')
	
	local range_yaxis = `max_whole_lp' - `min_whole_lp'
	local ticksyaxis = `range_yaxis' / `yaxisticks'
	local ticks_yaxis = (round(`ticksyaxis' ,`yaxisdp'))
	}
	
if `pvalue'== 1  {
	summ log_p_val_chi , det
	local min_lp = r(min)
	local max_lp = r(max)
	local min_whole_lp = (round(`min_lp' , `yaxisdp')+`yaxismin')
	local max_whole_lp = (round(`max_lp' , `yaxisdp')+`yaxismax')
	
	local range_yaxis = `max_whole_lp' - `min_whole_lp'
	local ticksyaxis = `range_yaxis' / `yaxisticks'
	local ticks_yaxis = (round(`ticksyaxis' ,`yaxisdp'))
	}
	

*******************************************************************************
*Plot 
*************RISK DIFFERENCE************************************
*To give risk-diff using Fisher's exact p-value	

	if `oddsratio'==0 & `riskratio'==0 {
		if `pvalue'==0  {
			
			gen pvalue_cat=1 if log_p_val<0.5
			replace pvalue_cat=0 if log_p_val>=0.5
			replace pvalue_cat=3 if log_p_val<0.5 & log_p_val>=0.25
			replace pvalue_cat=2 if log_p_val>=0.75

			gen group =1 if risk_diff>=0 & pvalue_cat==1
			recode group .=2 if risk_diff>=0 & pvalue_cat==0 
			recode group .=3 if risk_diff>=0 & pvalue_cat==2
			recode group .=4 if risk_diff>=0 &  pvalue_cat==3
			recode group .=5 if risk_diff<0 &  pvalue_cat==1 
			recode group .=6 if  risk_diff<0 & pvalue_cat==0
			recode group .=7 if risk_diff<0 & pvalue_cat==2
			recode group .=8 if risk_diff<0 & pvalue_cat==3 
			
			*Ensuring the weights are accurate and not just based on observations within the if restrictions
			expand 8
			replace risk_diff = . if mod(_n,8) > 0
			recode group (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=1) if mod(_n,8) == 1
			recode group (1=3) (2=4) (3=5) (4=6) (5=7) (6=8) (7=1) (8=2) if mod(_n,8) == 2
			recode group (1=4) (2=5) (3=6) (4=7) (5=8) (6=1) (7=2) (8=3) if mod(_n,8) == 3
			recode group (1=5) (2=6) (3=7) (4=8) (5=1) (6=2) (7=3) (8=4) if mod(_n,8) == 4
			recode group (1=6) (2=7) (3=8) (4=1) (5=2) (6=3) (7=4) (8=5) if mod(_n,8) == 5
			recode group (1=7) (2=8) (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) if mod(_n,8) == 6
			recode group (1=8) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) if mod(_n,8) == 7
			
			
			*Check that have individuals in each arm in each p-value category:
			*& Costruct graph code only including lines that have the combinations in data set
			*Incorporating legend code so that only two labels displayed (or 1 if events all in one direction)
			local graphcode "twoway"
			
			local segments_counter=0
		
			count if risk_diff>=0 & pvalue_cat==2 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group==3    [fw=n_events] , mfcolor(`mfcolor1'%`mfcolsat1')  mlcolor(`mlcolor1'%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1 & "`legend1'"=="" {
					local legenddef1 = "Risk in Group 1"
					} 
				else {
					local legenddef1 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef1 = "`legend1'"
					} 
				}		
							
			count if risk_diff>=0 & pvalue_cat==0 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group==2   [fw=n_events] , mfcolor(`mfcolor1'*0.75%`mfcolsat1')  mlcolor(`mlcolor1'*0.75%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef1'"=="" {
					local legenddef2 = "Risk in Group 1"
					} 
				else {
					local legenddef2 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef2 = "`legend1'"
					}
			}	
				
			count if risk_diff>=0 & pvalue_cat==3 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff  if group==4  [fw=n_events] , mfcolor(`mfcolor1'*0.5%`mfcolsat1')  mlcolor(`mlcolor1'*0.5%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef2'"=="" {
					local legenddef3 = "Risk in Group 1"
					} 
				else {
					local legenddef3 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef3 = "`legend1'"
					}
				}		
			
			count if risk_diff>=0 & pvalue_cat==1 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group==1 [fw=n_events] , mfcolor(`mfcolor1'*0.25%`mfcolsat1')  mlcolor(`mlcolor1'*0.25%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef3'"=="" {
					local legenddef4 = "Risk in Group 1"
				}
				else {
						local legenddef4 = ""
						}
				if `legendyn' ==1 & "`legend1'"!="" {
						local legenddef4 = "`legend1'"
						}
				}
					
			count if risk_diff<0 & pvalue_cat==2
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group==7   [fw=n_events] ,  mfcolor(`mfcolor2'%`mfcolsat2') mlcolor(`mlcolor2'%`mlcolsat2') )"
				if `legendyn' ==1 & "`legend5'"=="" {
					local legenddef5 = "Risk in Group 2"
					} 
				else {
					local legenddef5= ""
					}	
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef5 = "`legend2'"
					}
				}			

			count if risk_diff<0 & pvalue_cat==0
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group==6  [fw=n_events] ,  mfcolor(`mfcolor2'*0.75%`mfcolsat2') mlcolor(`mlcolor2'*0.75%`mlcolsat2') )"
				if `legendyn' ==1 & "`legenddef5'"==""  {
					local legenddef6 = "Risk in Group 2"
					} 
				else {
					local legenddef6 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef6 = "`legend2'"
					}		
				}

			count if risk_diff<0 & pvalue_cat==3
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group==8 [fw=n_events] ,  mfcolor(`mfcolor2'*0.5%`mfcolsat2') mlcolor(`mlcolor2'*0.5%`mlcolsat2') )"
				if `legendyn' ==1 &  "`legenddef6'"=="" {
					local legenddef7 = "Risk in Group 2" 
					} 
				else {
					local legenddef7 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef7 = "`legend2'"
					}
				}
				
			count if risk_diff<0 & pvalue_cat==1
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val risk_diff 	if group==5   [fw=n_events] ,  mfcolor(`mfcolor2'*0.25%`mfcolsat2') mlcolor(`mlcolor2'*0.25%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef7'"==""  {
					local legenddef8 = "Risk in Group 2"
					} 
				else {
					local legenddef8 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef8 = "`legend2'"
					}
				}	
	
		*To account for possibility of 0 events in either RD<0 or RD>=0
		count if risk_diff>=0 & risk_diff!=.
		local rd_pos = r(N)
		count if risk_diff <0 & risk_diff!=.
		local rd_neg = r(N)
		
		if (`rd_pos'!=0  & `rd_pos'!=.) & (`rd_neg'!=0 & `rd_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val risk_diff if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') )"
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
					
		local graphcode "`graphcode' (scatter log_p_val risk_diff if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
			if `legendyn' ==1 & "`legend10'"=="" {
				local legenddef10 = "" 
				}
			}	
			
		if (`rd_pos'!=0  & `rd_pos'!=.) & (`rd_neg'==0 | `rd_neg'==.)  {
			local graphcode "`graphcode' (scatter log_p_val risk_diff if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') "
				if `legendyn' ==1 & "`legend9'"=="" {
					local legenddef9 = "" 
					}
			}	
	
		if (`rd_pos'==0  | `rd_pos'==.) & (`rd_neg'!=0 & `rd_neg'!=.)  {
			local graphcode "`graphcode' (scatter log_p_val risk_diff if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
				if `legendyn' ==1 & "`legend10'"=="" {
					local legenddef10 = "" 
					}
			}	
			
		if `rd_pos'==0  {
			local segments_counter=`segments_counter'+1
		}
		local segments_counter=`segments_counter'+1
			
			*Build legend text
			if `legendyn' ==1 &  "`legenddef1'"!="" {
				local legendtext1 = "lab(1 `legenddef1')" 
			}
			
			if `legendyn' ==1 &  "`legenddef1'"=="" &  "`legenddef2'"!=""  {
				local legendtext1 = "lab(1 `legenddef2')"
			}
					
			if `legendyn' ==1 &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef3'"!=""  {
				local legendtext1 = "lab(1 `legenddef3')" 
			}
						
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"!=""   {
				local legendtext1 = "lab(1 `legenddef4')" 
			}
			
			if "`legend1'"!="" {
				local legenddef9 = "`legend1'"
			}
			
			if "`legend1'"=="" {
				local legenddef9 = "Risk in Group 2"
				}
			
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"==""   {
				local legendtext1 = "lab(1 `legenddef9')" 
			}
							
			if `legendyn' ==1 &  "`legenddef5'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef5')" 
			}	

			if `legendyn' ==1 &  "`legenddef5'"=="" &  "`legenddef6'"!=""  {
				local legendtext2 = "lab(`segments_counter' `legenddef6')"
			}
				
			if `legendyn' ==1 &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef7'"!=""  {
				local legendtext2 = "lab(`segments_counter' `legenddef7')" 
			}
					
			if `legendyn' ==1 &  "`legenddef7'"=="" &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef8'"!=""    {
				local legendtext2 = "lab(`segments_counter' `legenddef8')" 
			}
		
		if "`legend2'"!="" {
			local legenddef10 = "`legend2'"
			}

		if "`legend2'"=="" {
			local legenddef10 = "Risk in Group 1"
			}
			
		if `legendyn' ==1 &  "`legenddef8'"==""  &  "`legenddef7'"=="" &  "`legenddef6'"=="" &  "`legenddef5'"==""   {
			local legendtext2 = "lab(1 `legenddef10')" 
			}
			
		local legendtext = "order(1 `segments_counter') `legendtext1' `legendtext2'"
		
		if `rd_pos'==0 {
			local legendtext = "order(1) `legendtext1'"
			}
		
		if `rd_neg'==0 {
			local legendtext = "order(1) `legendtext2'"
			}
		
		if `legendyn' ==0  {
				local legendtext = "off"
			}
			
		*xlab options:
		if `min_whole'!=0 & `ticks_xaxis'!=0 & `max_whole'!=0 {
			local xlab = "xlab(`min_whole'(`ticks_xaxis')`max_whole')"
			}
	
	*Add in graph options:
	local graphcode "`graphcode' title(`title') subtitle(`subtitle')  xtitle(`xaxistitle') ytitle(`yaxistitle') yline( `ynum' , lpattern(`ylinepat') lcolor(`ylinecol') lwidth(`ylinewidth')  ) ylab(`min_whole_lp'(`ticks_yaxis')`max_whole_lp' , nogrid) `xlab' graphregion(color(`grphcol')) plotregion(color(`plotcol'))), legend(`legendtext'  pos(`legendpos') cols(`legendcol') rows(`legendrow'))"

			*Run the above to get the scatterplot code
			noi `graphcode'
			cap drop if risk_diff == .
				}
			}

***********To give risk-difference with Pearson's chi-squared************

		if `oddsratio'==0 & `riskratio'==0 {
			if `pvalue'==1   {
			
			gen pvalue_cat=1 if log_p_val_chi<0.5
			replace pvalue_cat=0 if log_p_val_chi>=0.5
			replace pvalue_cat=3 if log_p_val_chi<0.5 & log_p_val_chi>=0.25
			replace pvalue_cat=2 if log_p_val_chi>=0.75
			
			gen group =1 if risk_diff>=0 & pvalue_cat==1
			recode group .=2 if risk_diff>=0 & pvalue_cat==0 
			recode group .=3 if risk_diff>=0 & pvalue_cat==2
			recode group .=4 if risk_diff>=0 &  pvalue_cat==3
			recode group .=5 if risk_diff<0 &  pvalue_cat==1 
			recode group .=6 if  risk_diff<0 & pvalue_cat==0
			recode group .=7 if risk_diff<0 & pvalue_cat==2
			recode group .=8 if risk_diff<0 & pvalue_cat==3 

			expand 8
			replace risk_diff = . if mod(_n,8) > 0
			recode group (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=1) if mod(_n,8) == 1
			recode group (1=3) (2=4) (3=5) (4=6) (5=7) (6=8) (7=1) (8=2) if mod(_n,8) == 2
			recode group (1=4) (2=5) (3=6) (4=7) (5=8) (6=1) (7=2) (8=3) if mod(_n,8) == 3
			recode group (1=5) (2=6) (3=7) (4=8) (5=1) (6=2) (7=3) (8=4) if mod(_n,8) == 4
			recode group (1=6) (2=7) (3=8) (4=1) (5=2) (6=3) (7=4) (8=5) if mod(_n,8) == 5
			recode group (1=7) (2=8) (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) if mod(_n,8) == 6
			recode group (1=8) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) if mod(_n,8) == 7
			
			*Check that have individuals in each different colour category:
			*& Costruct graph code only including lines that have the combinations in data set

			local graphcode "twoway"
			
			local segments_counter=0

			count if risk_diff>=0 & pvalue_cat==2 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group==3    [fw=n_events] , mfcolor(`mfcolor1'%`mfcolsat1')  mlcolor(`mlcolor1'%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1 & "`legend1'"=="" {
					local legenddef1 = "Risk in Group 1"
					} 
				else {
					local legenddef1 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef1 = "`legend1'"
					} 
				}		
				
			count if risk_diff>=0 & pvalue_cat==0 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group==2   [fw=n_events] , mfcolor(`mfcolor1'*0.75%`mfcolsat1')  mlcolor(`mlcolor1'*0.75%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef1'"=="" {
					local legenddef2 = "Risk in Group 1"
					} 
				else {
					local legenddef2 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef2 = "`legend1'"
					}
				}	
			
			count if risk_diff>=0 & pvalue_cat==3 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff  if group==4  [fw=n_events] , mfcolor(`mfcolor1'*0.5%`mfcolsat1')  mlcolor(`mlcolor1'*0.5%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef2'"=="" {
					local legenddef3 = "Risk in Group 1"
					} 
				else {
					local legenddef3 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef3 = "`legend1'"
					}
				}			
						
			count if risk_diff>=0 & pvalue_cat==1 & risk_diff!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group==1 [fw=n_events] , mfcolor(`mfcolor1'*0.25%`mfcolsat1')  mlcolor(`mlcolor1'*0.25%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1  & "`legenddef3'"=="" {
					local legenddef4 = "Risk in Group 1"
				}
			else {
					local legenddef4 = ""
					}
			if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef4 = "`legend1'"
					}
				}
				
			count if risk_diff<0 & pvalue_cat==2
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group==7   [fw=n_events] ,  mfcolor(`mfcolor2'%`mfcolsat2') mlcolor(`mlcolor2'%`mlcolsat2') )"
				if `legendyn' ==1 & "`legend5'"=="" {
					local legenddef5 = "Risk in Group 2"
					} 
				else {
					local legenddef5= ""
					}	
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef5 = "`legend2'"
					}
				}			
								
			count if risk_diff<0 & pvalue_cat==0
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group==6  [fw=n_events] ,  mfcolor(`mfcolor2'*0.75%`mfcolsat2') mlcolor(`mlcolor2'*0.75%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef5'"==""  {
					local legenddef6 = "Risk in Group 2"
					} 
				else {
					local legenddef6 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef6 = "`legend2'"
					}		
				}
				
			count if risk_diff<0 & pvalue_cat==3
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group==8 [fw=n_events] ,  mfcolor(`mfcolor2'*0.5%`mfcolsat2') mlcolor(`mlcolor2'*0.5%`mlcolsat2') )"
				if `legendyn' ==1  &  "`legenddef6'"=="" {
					local legenddef7 = "Risk in Group 2" 
					} 
				else {
					local legenddef7 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef7 = "`legend2'"
					}
				}
				
			count if risk_diff<0 & pvalue_cat==1
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff 	if group==5   [fw=n_events] ,  mfcolor(`mfcolor2'*0.25%`mfcolsat2') mlcolor(`mlcolor2'*0.25%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef7'"==""  {
					local legenddef8 = "Risk in Group 2"
					} 
				else {
					local legenddef8 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef8 = "`legend2'"
					}
				}	
			
		*To account for possibility of 0 events in either RD<0 or RD>=0
		count if risk_diff>=0   & risk_diff!=.
		local rd_pos = r(N)
		count if risk_diff <0 & risk_diff!=.
		local rd_neg = r(N)
			
		if (`rd_pos'!=0  & `rd_pos'!=.) & (`rd_neg'!=0 & `rd_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') )"
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
							
		if (`rd_pos'!=0  & `rd_pos'!=.) & (`rd_neg'==0 | `rd_neg'==.)  {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') "
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
			}		
	
		if (`rd_pos'==0  | `rd_pos'==.) & (`rd_neg'!=0 & `rd_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val_chi risk_diff if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
			
		if `rd_pos'==0  {
			local segments_counter=`segments_counter'+1
		}
		local segments_counter=`segments_counter'+1	
				
			*building legend text
			if `legendyn' ==1 &  "`legenddef1'"!="" {
				local legendtext1 = "lab(1 `legenddef1')" 
			}
							
			if `legendyn' ==1 &  "`legenddef1'"==""   &  "`legenddef2'"!=""  {
				local legendtext1 = "lab(1 `legenddef2')"
			}
						
			if `legendyn' ==1 &  "`legenddef2'"==""  &  "`legenddef1'"=="" &  "`legenddef3'"!=""  {
				local legendtext1 = "lab(1 `legenddef3')" 
			}
						
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"!=""    {
				local legendtext1 = "lab(1 `legenddef4')" 
			}
			
			if "`legend1'"!="" {
				local legenddef9 = "`legend1'"
			
			}
			
			if "`legend1'"=="" {
				local legenddef9 = "Risk in Group 2"
			
			}
			
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"==""   {
				local legendtext1 = "lab(1 `legenddef9')" 
			}
					
			if `legendyn' ==1 &  "`legenddef5'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef5')" 
			}
						
			if `legendyn' ==1 &  "`legenddef5'"==""   &  "`legenddef6'"!=""  {
				local legendtext2 = "lab(`segments_counter'  `legenddef6')"
			}
										
			if `legendyn' ==1 &  "`legenddef6'"=="" &  "`legenddef5'"=="" &  "`legenddef7'"!=""    {
				local legendtext2 = "lab(`segments_counter' `legenddef7')" 
			}
						
			if `legendyn' ==1 &  "`legenddef7'"==""  &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef8'"!=""   {
				local legendtext2 = "lab(`segments_counter' `legenddef8')" 
			}
			
			
			if "`legend2'"!="" {
				local legenddef10 = "`legend2'"
				}

			if "`legend2'"=="" {
				local legenddef10 = "Risk in Group 1"
				}
			
			if `legendyn' ==1 &  "`legenddef8'"==""  &  "`legenddef7'"=="" &  "`legenddef6'"=="" &  "`legenddef5'"==""   {
				local legendtext2 = "lab(1 `legenddef10')" 
			}
			
			local legendtext = "order(1 `segments_counter') `legendtext1' `legendtext2'"
			
			if `rd_pos'==0 {
				local legendtext = "order(1) `legendtext1'"
				}
		
			if `rd_neg'==0 {
				local legendtext = "order(1) `legendtext2'"
				}
					
			if `legendyn' ==0  {
				local legendtext = "off"
			}
			
			*xlab options:
			if `min_whole'!=0 & `ticks_xaxis'!=0 & `max_whole'!=0 {
				local xlab = "xlab(`min_whole'(`ticks_xaxis')`max_whole')"
			}
			
			*Add in graph options:
			local graphcode "`graphcode' title(`title') subtitle(`subtitle')  xtitle(`xaxistitle') ytitle(`yaxistitle') yline( `ynum' , lpattern(`ylinepat') lcolor(`ylinecol') lwidth(`ylinewidth')  ) ylab(`min_whole_lp'(`ticks_yaxis')`max_whole_lp' , nogrid) `xlab' graphregion(color(`grphcol')) plotregion(color(`plotcol'))), legend(`legendtext'  pos(`legendpos') cols(`legendcol') rows(`legendrow'))"

			*Run graph code:			
			noi `graphcode'
			cap drop if risk_diff == .
					}
			}
		
		
****************************ODDS RATIO****************************
**********To give odds ratio with Fisher's exact p-value*********

	if `oddsratio'==1 {
		if `pvalue'==0  {
			
			gen pvalue_cat=1 if log_p_val<0.5
			replace pvalue_cat=0 if log_p_val>=0.5
			replace pvalue_cat=3 if log_p_val<0.5 & log_p_val>=0.25
			replace pvalue_cat=2 if log_p_val>=0.75
			
			gen group =1 if log_OR>=0 & pvalue_cat==1
			recode group .=2 if log_OR>=0 & pvalue_cat==0 
			recode group .=3 if log_OR>=0 & pvalue_cat==2
			recode group .=4 if log_OR>=0 &  pvalue_cat==3
			recode group .=5 if log_OR<0 &  pvalue_cat==1 
			recode group .=6 if  log_OR<0 & pvalue_cat==0
			recode group .=7 if log_OR<0 & pvalue_cat==2
			recode group .=8 if log_OR<0 & pvalue_cat==3 

			expand 8
			replace log_OR = . if mod(_n,8) > 0
			recode group (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=1) if mod(_n,8) == 1
			recode group (1=3) (2=4) (3=5) (4=6) (5=7) (6=8) (7=1) (8=2) if mod(_n,8) == 2
			recode group (1=4) (2=5) (3=6) (4=7) (5=8) (6=1) (7=2) (8=3) if mod(_n,8) == 3
			recode group (1=5) (2=6) (3=7) (4=8) (5=1) (6=2) (7=3) (8=4) if mod(_n,8) == 4
			recode group (1=6) (2=7) (3=8) (4=1) (5=2) (6=3) (7=4) (8=5) if mod(_n,8) == 5
			recode group (1=7) (2=8) (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) if mod(_n,8) == 6
			recode group (1=8) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) if mod(_n,8) == 7
			
			*Check that have individuals in each differnt colour category:
			*& Costruct graph code only including lines that have the combinations in data set

			local graphcode "twoway"
			local segments_counter=0

			count if log_OR>=0 & pvalue_cat==2 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group==3    [fw=n_events] , mfcolor(`mfcolor1'%`mfcolsat1')  mlcolor(`mlcolor1'%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1 & "`legend1'"=="" {
					local legenddef1 = "Odds higher in Group 1"
					} 
				else {
					local legenddef1 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef1 = "`legend1'"
					} 
				}		
				
			count if log_OR>=0 & pvalue_cat==0 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group==2   [fw=n_events] , mfcolor(`mfcolor1'*0.75%`mfcolsat1')  mlcolor(`mlcolor1'*0.75%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1  & "`legenddef1'"=="" {
					local legenddef2 = "Odds higher in Group 1"
					} 
				else {
					local legenddef2 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef2 = "`legend1'"
					}
			}	
			
			count if log_OR>=0 & pvalue_cat==3 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR  if group==4  [fw=n_events] , mfcolor(`mfcolor1'*0.5%`mfcolsat1')  mlcolor(`mlcolor1'*0.5%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1  & "`legenddef2'"=="" {
					local legenddef3 = "Odds higher in Group 1"
					} 
				else {
					local legenddef3 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef3 = "`legend1'"
					}
			}			
			
			count if log_OR>=0 & pvalue_cat==1 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group==1 [fw=n_events] , mfcolor(`mfcolor1'*0.25%`mfcolsat1')  mlcolor(`mlcolor1'*0.25%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1  & "`legenddef3'"=="" {
					local legenddef4 = "Odds higher in Group 1"
				}
			else {
					local legenddef4 = ""
					}
			if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef4 = "`legend1'"
					}
			}
				
			count if log_OR<0 & pvalue_cat==2 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group==7   [fw=n_events] ,  mfcolor(`mfcolor2'%`mfcolsat2') mlcolor(`mlcolor2'%`mlcolsat2') )"
				if `legendyn' ==1 & "`legend5'"=="" {
					local legenddef5 = "Odds higher in Group 2"
					} 
				else {
					local legenddef5= ""
					}	
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef5 = "`legend2'"
					}
			}			
		
			count if log_OR<0 & pvalue_cat==0
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group==6  [fw=n_events] ,  mfcolor(`mfcolor2'*0.75%`mfcolsat2') mlcolor(`mlcolor2'*0.75%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef5'"==""  {
					local legenddef6 = "Odds higher in Group 2"
					} 
				else {
					local legenddef6 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef6 = "`legend2'"
					}		
			}

			count if log_OR<0 & pvalue_cat==3
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group==8 [fw=n_events] ,  mfcolor(`mfcolor2'*0.5%`mfcolsat2') mlcolor(`mlcolor2'*0.5%`mlcolsat2') )"
				if `legendyn' ==1  &  "`legenddef6'"=="" {
					local legenddef7 = "Odds higher in Group 2" 
					} 
				else {
					local legenddef7 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef7 = "`legend2'"
					}
				}
				
			count if log_OR<0 & pvalue_cat==1
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_OR 	if group==5   [fw=n_events] ,  mfcolor(`mfcolor2'*0.25%`mfcolsat2') mlcolor(`mlcolor2'*0.25%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef7'"==""  {
					local legenddef8 = "Odds higher in Group 2"
					} 
				else {
					local legenddef8 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef8 = "`legend2'"
					}
				}	
			
		*To account for possibility of 0 events in either OR<1 or OR>=1
		count if log_OR>=0 & log_OR!=.
		local or_pos = r(N)
		count if log_OR <0 & log_OR!=.
		local or_neg = r(N)
			
		if (`or_pos'!=0  & `or_pos'!=.) & (`or_neg'!=0 & `or_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') )"
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
				local graphcode "`graphcode' (scatter log_p_val log_OR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
			
		if (`or_pos'!=0  & `or_pos'!=.) & (`or_neg'==0 | `or_neg'==.)  {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') "
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
			}		
	
		if (`or_pos'==0  | `or_pos'==.) & (`or_neg'!=0 & `or_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val log_OR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
			
		if `or_pos'==0  {
			local segments_counter=`segments_counter'+1
			}
		local segments_counter=`segments_counter'+1
		
			
			*Building legend text
			if `legendyn' ==1 &  "`legenddef1'"!="" {
				local legendtext1 = "lab(1 `legenddef1')" 
			}
							
			if `legendyn' ==1 &  "`legenddef1'"==""  &  "`legenddef2'"!=""  {
				local legendtext1 = "lab(1 `legenddef2')"
			}
						
			if `legendyn' ==1 &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef3'"!=""   {
				local legendtext1 = "lab(1 `legenddef3')" 
			}
						
			if `legendyn' ==1 &  "`legenddef3'"=="" &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"!=""   {
				local legendtext1 = "lab(1 `legenddef4')" 
			}
			
			if "`legend1'"!="" {
				local legenddef9 = "`legend1'"
				}
			
			if "`legend1'"=="" {
				local legenddef9 = "Odds higher in Group 2"
				}
			
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"==""   {
				local legendtext1 = "lab(1 `legenddef9')" 
			}
							
			if `legendyn' ==1 &  "`legenddef5'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef5')" 
			}
						
			if `legendyn' ==1 &  "`legenddef5'"==""  &  "`legenddef6'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef6')"
			}
						
			if `legendyn' ==1 &  "`legenddef6'"==""   &  "`legenddef5'"=="" &  "`legenddef7'"!=""   {
				local legendtext2 = "lab(`segments_counter' `legenddef7')" 
			}
						
			if `legendyn' ==1 &  "`legenddef7'"==""  &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef8'"!=""  {
				local legendtext2 = "lab(`segments_counter'  `legenddef8')" 
			}
			
			if "`legend2'"!="" {
				local legenddef10 = "`legend2'"
				}

			if "`legend2'"=="" {
				local legenddef10 = "Odds higher in Group 1"
				}
				
			if `legendyn' ==1 &  "`legenddef8'"==""  &  "`legenddef7'"=="" &  "`legenddef6'"=="" &  "`legenddef5'"==""   {
				local legendtext2 = "lab(1 `legenddef10')" 
			}
			
			local legendtext = "order(1 `segments_counter') `legendtext1' `legendtext2'"
			
			if `or_pos'==0 {
				local legendtext = "order(1) `legendtext1'"
				}
		
			if `or_neg'==0 {
				local legendtext = "order(1) `legendtext2'"
				}
					
			if `legendyn' ==0  {
				local legendtext = "off"
			}
			
			*xlab options:
			if `min_whole'!=0 & `ticks_xaxis'!=0 & `max_whole'!=0 {
				local xlab = "xlab(`min_whole'(`ticks_xaxis')`max_whole')"
			}
			
			*Add in graph options:
			local graphcode "`graphcode' title(`title') subtitle(`subtitle')  xtitle(`xaxistitle') ytitle(`yaxistitle') yline( `ynum' , lpattern(`ylinepat') lcolor(`ylinecol') lwidth(`ylinewidth')  ) ylab(`min_whole_lp'(`ticks_yaxis')`max_whole_lp' , nogrid) `xlab' graphregion(color(`grphcol')) plotregion(color(`plotcol'))), legend(`legendtext'  pos(`legendpos') cols(`legendcol') rows(`legendrow'))"

			*Run graph code:			
			noi `graphcode'
			cap drop if log_OR == .
				}
			}
	
*Using log odds to make sure x-axis symmetrical
		if `oddsratio'==1 {
			if `pvalue'==1  {
			
			gen pvalue_cat=1 if log_p_val_chi<0.5
			replace pvalue_cat=0 if log_p_val_chi>=0.5
			replace pvalue_cat=3 if log_p_val_chi<0.5 & log_p_val_chi>=0.25
			replace pvalue_cat=2 if log_p_val_chi>=0.75
			
			gen group =1 if log_OR>=0 & pvalue_cat==1
			recode group .=2 if log_OR>=0 & pvalue_cat==0 
			recode group .=3 if log_OR>=0 & pvalue_cat==2
			recode group .=4 if log_OR>=0 &  pvalue_cat==3
			recode group .=5 if log_OR<0 &  pvalue_cat==1 
			recode group .=6 if  log_OR<0 & pvalue_cat==0
			recode group .=7 if log_OR<0 & pvalue_cat==2
			recode group .=8 if log_OR<0 & pvalue_cat==3 

			expand 8
			replace log_OR = . if mod(_n,8) > 0
			recode group (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=1) if mod(_n,8) == 1
			recode group (1=3) (2=4) (3=5) (4=6) (5=7) (6=8) (7=1) (8=2) if mod(_n,8) == 2
			recode group (1=4) (2=5) (3=6) (4=7) (5=8) (6=1) (7=2) (8=3) if mod(_n,8) == 3
			recode group (1=5) (2=6) (3=7) (4=8) (5=1) (6=2) (7=3) (8=4) if mod(_n,8) == 4
			recode group (1=6) (2=7) (3=8) (4=1) (5=2) (6=3) (7=4) (8=5) if mod(_n,8) == 5
			recode group (1=7) (2=8) (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) if mod(_n,8) == 6
			recode group (1=8) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) if mod(_n,8) == 7
			
			*Check that have individuals in each differnt colour category:
			*& Costruct graph code only including lines that have the combinations in data set

			local graphcode "twoway"
			local segments_counter=0

			count if log_OR>=0 & pvalue_cat==2 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group==3    [fw=n_events] , mfcolor(`mfcolor1'%`mfcolsat1')  mlcolor(`mlcolor1'%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1 & "`legend1'"=="" {
					local legenddef1 = "Odds higher in Group 1"
					} 
				else {
					local legenddef1 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef1 = "`legend1'"
					} 
				}		
				
			count if log_OR>=0 & pvalue_cat==0 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group==2   [fw=n_events] , mfcolor(`mfcolor1'*0.75%`mfcolsat1')  mlcolor(`mlcolor1'*0.75%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef1'"=="" {
					local legenddef2 = "Odds higher in Group 1"
					} 
				else {
					local legenddef2 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef2 = "`legend1'"
					}
			}	
			
			count if log_OR>=0 & pvalue_cat==3 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR  if group==4  [fw=n_events] , mfcolor(`mfcolor1'*0.5%`mfcolsat1')  mlcolor(`mlcolor1'*0.5%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1 & "`legenddef2'"=="" {
					local legenddef3 = "Odds higher in Group 1"
					} 
				else {
					local legenddef3 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef3 = "`legend1'"
					}
				}			
			
			count if log_OR>=0 & pvalue_cat==1 & log_OR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group==1 [fw=n_events] , mfcolor(`mfcolor1'*0.25%`mfcolsat1')  mlcolor(`mlcolor1'*0.25%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef3'"=="" {
					local legenddef4 = "Odds higher in Group 1"
					}
				else {
					local legenddef4 = ""
					}
			if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef4 = "`legend1'"
					}
				}
			
			count if log_OR<0 & pvalue_cat==2
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group==7   [fw=n_events] ,  mfcolor(`mfcolor2'%`mfcolsat2') mlcolor(`mlcolor2'%`mlcolsat2') )"
				if `legendyn' ==1 & "`legend5'"=="" {
					local legenddef5 = "Odds higher in Group 2"
					} 
				else {
					local legenddef5= ""
					}	
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef5 = "`legend2'"
					}
			}			

			count if log_OR<0 & pvalue_cat==0
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group==6  [fw=n_events] ,  mfcolor(`mfcolor2'*0.75%`mfcolsat2') mlcolor(`mlcolor2'*0.75%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef5'"==""  {
					local legenddef6 = "Odds higher in Group 2"
					} 
				else {
					local legenddef6 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef6 = "`legend2'"
					}		
			}

			count if log_OR<0 & pvalue_cat==3
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group==8 [fw=n_events] ,  mfcolor(`mfcolor2'*0.5%`mfcolsat2') mlcolor(`mlcolor2'*0.5%`mlcolsat2') )"
				if `legendyn' ==1  &  "`legenddef6'"=="" {
					local legenddef7 = "Odds higher in Group 2" 
					} 
				else {
					local legenddef7 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef7 = "`legend2'"
					}
				}
				
			count if log_OR<0 & pvalue_cat==1
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR 	if group==5   [fw=n_events] ,  mfcolor(`mfcolor2'*0.25%`mfcolsat2') mlcolor(`mlcolor2'*0.25%`mlcolsat2') )"
				if `legendyn' ==1 & "`legenddef7'"==""  {
					local legenddef8 = "Odds higher in Group 2"
					} 
				else {
					local legenddef8 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef8 = "`legend2'"
					}
				}	
							
		*To account for possibility of 0 events in either OR<1 or OR>=1
		count if log_OR>=0 & log_OR!=.
		local or_pos = r(N)
		count if log_OR<0 & log_OR!=.
		local or_neg = r(N)
			
		if (`or_pos'!=0  & `or_pos'!=.) & (`or_neg'!=0 & `or_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') )"
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
				
		if (`or_pos'!=0  & `or_pos'!=.) & (`or_neg'==0 | `or_neg'==.)  {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') "
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
			}		
	
		if (`or_pos'==0  | `or_pos'==.) & (`or_neg'!=0 & `or_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val_chi log_OR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
			
		if `or_pos'==0  {
			local segments_counter=`segments_counter'+1
		}
		local segments_counter=`segments_counter'+1
			
			*Building legend text
			if `legendyn' ==1 &  "`legenddef1'"!="" {
				local legendtext1 = "lab(1 `legenddef1')" 
			}
							
			if `legendyn' ==1 &  "`legenddef1'"=="" & "`legenddef2'"!=""   {
				local legendtext1 = "lab(1 `legenddef2')"
			}
						
			if `legendyn' ==1 &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef3'"!=""  {
				local legendtext1 = "lab(1 `legenddef3')" 
			}
						
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"!=""    {
				local legendtext1 = "lab(1 `legenddef4')" 
			}
			
			if "`legend1'"!="" {
				local legenddef9 = "`legend1'"
				}
			
			if "`legend1'"=="" {
				local legenddef9 = "Odds higher in Group 2"
				}
			
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"==""   {
				local legendtext1 = "lab(1 `legenddef9')" 
			}
							
			if `legendyn' ==1 &  "`legenddef5'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef5')" 
			}
						
			if `legendyn' ==1 &  "`legenddef5'"==""  &  "`legenddef6'"!=""  {
				local legendtext2 = "lab(`segments_counter'  `legenddef6')"
			}
						
			if `legendyn' ==1 &  "`legenddef6'"=="" &  "`legenddef5'"=="" &  "`legenddef7'"!=""   {
				local legendtext2 = "lab(`segments_counter'  `legenddef7')" 
			}
						
			if `legendyn' ==1 &  "`legenddef7'"=="" &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef8'"!=""   {
				local legendtext2 = "lab(`segments_counter' `legenddef8')" 
			}
		
			if "`legend2'"!="" {
				local legenddef10 = "`legend2'"
				}

			if "`legend2'"=="" {
				local legenddef10 = "Odds higher in Group 1"
				}
			
			if `legendyn' ==1 &  "`legenddef8'"==""  &  "`legenddef7'"=="" &  "`legenddef6'"=="" &  "`legenddef5'"==""   {
				local legendtext2 = "lab(1 `legenddef10')" 
				}

			local legendtext = "order(1 `segments_counter') `legendtext1' `legendtext2'"
			
			if `or_pos'==0 {
				local legendtext = "order(1) `legendtext1'"
				}
		
			if `or_neg'==0 {
				local legendtext = "order(1) `legendtext2'"
				}
			
			if `legendyn' ==0  {
				local legendtext = "off"
			}
			
			*xlab options:
			if `min_whole'!=0 & `ticks_xaxis'!=0 & `max_whole'!=0 {
				local xlab = "xlab(`min_whole'(`ticks_xaxis')`max_whole')"
			}
			
			*Add in graph options:
			local graphcode "`graphcode' title(`title') subtitle(`subtitle')  xtitle(`xaxistitle') ytitle(`yaxistitle') yline( `ynum' , lpattern(`ylinepat') lcolor(`ylinecol') lwidth(`ylinewidth')  ) ylab(`min_whole_lp'(`ticks_yaxis')`max_whole_lp' , nogrid) `xlab' graphregion(color(`grphcol')) plotregion(color(`plotcol'))), legend(`legendtext'  pos(`legendpos') cols(`legendcol') rows(`legendrow'))"
			
			*Run graph code:			
			noi `graphcode'
			cap drop if log_OR == .
				}
			}
		
************************RISK RATIO****************************************************	
*Using log RR to make sure x-axis symmetrical
*To give risk-ratio and Fisher's exact p-value 	
		if `riskratio'==1 {
			if `pvalue'==0  {
			
			gen pvalue_cat=1 if log_p_val<0.5
			replace pvalue_cat=0 if log_p_val>=0.5
			replace pvalue_cat=3 if log_p_val<0.5 & log_p_val>=0.25
			replace pvalue_cat=2 if log_p_val>=0.75
			
			gen group =1 if log_RR>=0 & pvalue_cat==1
			recode group .=2 if log_RR>=0 & pvalue_cat==0 
			recode group .=3 if log_RR>=0 & pvalue_cat==2
			recode group .=4 if log_RR>=0 &  pvalue_cat==3
			recode group .=5 if log_RR<0 &  pvalue_cat==1 
			recode group .=6 if log_RR<0 & pvalue_cat==0
			recode group .=7 if log_RR<0 & pvalue_cat==2
			recode group .=8 if log_RR<0 & pvalue_cat==3 

			expand 8
			replace log_RR = . if mod(_n,8) > 0
			recode group (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=1) if mod(_n,8) == 1
			recode group (1=3) (2=4) (3=5) (4=6) (5=7) (6=8) (7=1) (8=2) if mod(_n,8) == 2
			recode group (1=4) (2=5) (3=6) (4=7) (5=8) (6=1) (7=2) (8=3) if mod(_n,8) == 3
			recode group (1=5) (2=6) (3=7) (4=8) (5=1) (6=2) (7=3) (8=4) if mod(_n,8) == 4
			recode group (1=6) (2=7) (3=8) (4=1) (5=2) (6=3) (7=4) (8=5) if mod(_n,8) == 5
			recode group (1=7) (2=8) (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) if mod(_n,8) == 6
			recode group (1=8) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) if mod(_n,8) == 7

			*Check that have individuals in each differnt colour category:
			*& Costruct graph code only including lines that have the combinations in data set

			local graphcode "twoway"
			local segments_counter=0
			
			count if log_RR>=0 & pvalue_cat==2 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group==3    [fw=n_events] , mfcolor(`mfcolor1'%`mfcolsat1')  mlcolor(`mlcolor1'%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1 & "`legend1'"=="" {
					local legenddef1 = "Risk in Group 1"
					} 
				else {
					local legenddef1 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef1 = "`legend1'"
					} 
				}		
				
			count if log_RR>=0 & pvalue_cat==0 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group==2   [fw=n_events] , mfcolor(`mfcolor1'*0.75%`mfcolsat1')  mlcolor(`mlcolor1'*0.75%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef1'"=="" {
					local legenddef2 = "Risk in Group 1"
					} 
				else {
					local legenddef2 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef2 = "`legend1'"
					}
			}	
			
			count if log_RR>=0 & pvalue_cat==3 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR  if group==4  [fw=n_events] , mfcolor(`mfcolor1'*0.5%`mfcolsat1')  mlcolor(`mlcolor1'*0.5%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef2'"=="" {
					local legenddef3 = "Risk in Group 1"
					} 
				else {
					local legenddef3 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef3 = "`legend1'"
					}
				}			
			
			count if log_RR>=0 & pvalue_cat==1 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group==1 [fw=n_events] , mfcolor(`mfcolor1'*0.25%`mfcolsat1')  mlcolor(`mlcolor1'*0.25%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef3'"=="" {
					local legenddef4 = "Risk in Group 1"
				}
			else {
					local legenddef4 = ""
					}
			if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef4 = "`legend1'"
					}
				}
					
			count if log_RR<0 & pvalue_cat==2
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group==7   [fw=n_events] ,  mfcolor(`mfcolor2'%`mfcolsat2') mlcolor(`mlcolor2'%`mlcolsat2') )"
				if `legendyn' ==1 & "`legend5'"=="" {
					local legenddef5 = "Risk in Group 2"
					} 
				else {
					local legenddef5= ""
					}	
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef5 = "`legend2'"
					}
			}			
	
			count if log_RR<0 & pvalue_cat==0
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group==6  [fw=n_events] ,  mfcolor(`mfcolor2'*0.75%`mfcolsat2') mlcolor(`mlcolor2'*0.75%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef5'"==""  {
					local legenddef6 = "Risk in Group 2"
					} 
				else {
					local legenddef6 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef6 = "`legend2'"
					}		
				}

			count if log_RR<0 & pvalue_cat==3
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group==8 [fw=n_events] ,  mfcolor(`mfcolor2'*0.5%`mfcolsat2') mlcolor(`mlcolor2'*0.5%`mlcolsat2') )"
				if `legendyn' ==1  &  "`legenddef6'"=="" {
					local legenddef7 = "Risk in Group 2" 
					} 
				else {
					local legenddef7 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef7 = "`legend2'"
					}
				}
				
			count if log_RR<0 & pvalue_cat==1
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val log_RR 	if group==5   [fw=n_events] ,  mfcolor(`mfcolor2'*0.25%`mfcolsat2') mlcolor(`mlcolor2'*0.25%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef7'"==""  {
					local legenddef8 = "Risk in Group 2"
					} 
				else {
					local legenddef8 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef8 = "`legend2'"
					}
				}	
			
		*To account for possibility of 0 events in either RR<1 or RR>=1
		count if log_RR>=0 & log_RR!=.
		local rr_pos = r(N)
		count if log_RR <0 & log_RR!=.
		local rr_neg = r(N)
			
		if (`rr_pos'!=0  & `rr_pos'!=.) & (`rr_neg'!=0 & `rr_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') )"
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
				local graphcode "`graphcode' (scatter log_p_val log_RR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
			
		if (`rr_pos'!=0  & `rr_pos'!=.) & (`rr_neg'==0 | `rr_neg'==.)  {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') "
					if `legendyn' ==1 & "`legend9'"=="" {
						local legenddef9 = "" 
					}
			}		
	
		if (`rr_pos'==0  | `rr_pos'==.) & (`rr_neg'!=0 & `rr_neg'!=.)  {
				local graphcode "`graphcode' (scatter log_p_val log_RR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
					if `legendyn' ==1 & "`legend10'"=="" {
						local legenddef10 = "" 
					}
			}	
		
		if `rr_pos'==0  {
			local segments_counter=`segments_counter'+1
		}
		local segments_counter=`segments_counter'+1
		
			
			*Building legend text
			if `legendyn' ==1 &  "`legenddef1'"!="" {
				local legendtext1 = "lab(1 `legenddef1')" 
				}
							
			if `legendyn' ==1 &  "`legenddef1'"=="" &  "`legenddef2'"!=""    {
				local legendtext1 = "lab(1 `legenddef2')"
				}
						 
			if `legendyn' ==1 &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef3'"!="" {
				local legendtext1 = "lab(1 `legenddef3')" 
			}
						
			if `legendyn' ==1 &  "`legenddef3'"=="" &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"!=""    {
				local legendtext1 = "lab(1 `legenddef4')" 
			}
				
								
			if "`legend1'"!="" {
				local legenddef9 = "`legend1'"
				}
			
			if "`legend1'"=="" {
				local legenddef9 = "Risk in Group 2"
				}
			
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"==""   {
				local legendtext1 = "lab(1 `legenddef9')" 
			}
					
			if `legendyn' ==1 &  "`legenddef5'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef5')" 
			}
						
			if `legendyn' ==1 &  "`legenddef5'"==""  &  "`legenddef6'"!=""  {
				local legendtext2 = "lab(`segments_counter' `legenddef6')"
			}
						
			if `legendyn' ==1 &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef7'"!=""   {
				local legendtext2 = "lab(`segments_counter' `legenddef7')" 
			}
						
			if `legendyn' ==1 &  "`legenddef7'"=="" &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef8'"!=""    {
				local legendtext2 = "lab(`segments_counter' `legenddef8')" 
			}
			
			if "`legend2'"!="" {
				local legenddef10 = "`legend2'"
				}

			if "`legend2'"=="" {
				local legenddef10 = "Risk in Group 1"
				}
			
			if `legendyn' ==1 &  "`legenddef8'"==""  &  "`legenddef7'"=="" &  "`legenddef6'"=="" &  "`legenddef5'"==""   {
				local legendtext2 = "lab(1 `legenddef10')" 
			}

			local legendtext = "order(1 `segments_counter') `legendtext1' `legendtext2'"
			
			if `rr_pos'==0 {
				local legendtext = "order(1) `legendtext1'"
				}
		
			if `rr_neg'==0 {
				local legendtext = "order(1) `legendtext2'"
				}
		
			if `legendyn' ==0  {
				local legendtext = "off"
			}
		
		*xlab options:
			if `min_whole'!=0 & `ticks_xaxis'!=0 & `max_whole'!=0 {
				local xlab = "xlab(`min_whole'(`ticks_xaxis')`max_whole')"
			}
			
			*Add in graph options:
			local graphcode "`graphcode' title(`title') subtitle(`subtitle')  xtitle(`xaxistitle') ytitle(`yaxistitle') yline( `ynum' , lpattern(`ylinepat') lcolor(`ylinecol') lwidth(`ylinewidth')  ) ylab(`min_whole_lp'(`ticks_yaxis')`max_whole_lp' , nogrid) `xlab' graphregion(color(`grphcol')) plotregion(color(`plotcol'))), legend(`legendtext'  pos(`legendpos') cols(`legendcol') rows(`legendrow'))"
	
		*Run graph code:			
			noi `graphcode'
			cap drop if log_RR == .
				}
			}
		
*************To give risk-ratio and Pearson's chi-squared************
*using log RR to make sure x axis symmetrical
		if `riskratio'==1 {
			if `pvalue'==1  {
			
			gen pvalue_cat=1 if log_p_val_chi<0.5
			replace pvalue_cat=0 if log_p_val_chi>=0.5
			replace pvalue_cat=3 if log_p_val_chi<0.5 & log_p_val_chi>=0.25
			replace pvalue_cat=2 if log_p_val_chi>=0.75
			
			gen group =1 if log_RR>=0 & pvalue_cat==1
			recode group .=2 if log_RR>=0 & pvalue_cat==0 
			recode group .=3 if log_RR>=0 & pvalue_cat==2
			recode group .=4 if log_RR>=0 &  pvalue_cat==3
			recode group .=5 if log_RR<0 &  pvalue_cat==1 
			recode group .=6 if log_RR<0 & pvalue_cat==0
			recode group .=7 if log_RR<0 & pvalue_cat==2
			recode group .=8 if log_RR<0 & pvalue_cat==3 

			expand 8
			replace log_RR = . if mod(_n,8) > 0
			recode group (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=1) if mod(_n,8) == 1
			recode group (1=3) (2=4) (3=5) (4=6) (5=7) (6=8) (7=1) (8=2) if mod(_n,8) == 2
			recode group (1=4) (2=5) (3=6) (4=7) (5=8) (6=1) (7=2) (8=3) if mod(_n,8) == 3
			recode group (1=5) (2=6) (3=7) (4=8) (5=1) (6=2) (7=3) (8=4) if mod(_n,8) == 4
			recode group (1=6) (2=7) (3=8) (4=1) (5=2) (6=3) (7=4) (8=5) if mod(_n,8) == 5
			recode group (1=7) (2=8) (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) if mod(_n,8) == 6
			recode group (1=8) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) if mod(_n,8) == 7
		
			*Check that have individuals in each differnt colour category:
			*& Costruct graph code only including lines that have the combinations in data set

			local graphcode "twoway"
			local segments_counter=0

			count if log_RR>=0 & pvalue_cat==2 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group==3    [fw=n_events] , mfcolor(`mfcolor1'%`mfcolsat1')  mlcolor(`mlcolor1'%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1 & "`legend1'"=="" {
					local legenddef1 = "Risk in Group 1"
					} 
				else {
					local legenddef1 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef1 = "`legend1'"
					} 
				}		
				
			count if log_RR>=0 & pvalue_cat==0 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group==2   [fw=n_events] , mfcolor(`mfcolor1'*0.75%`mfcolsat1')  mlcolor(`mlcolor1'*0.75%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
			if `legendyn' ==1  & "`legenddef1'"=="" {
					local legenddef2 = "Risk in Group 1"
					} 
				else {
					local legenddef2 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef2 = "`legend1'"
					}
				}	
			
			count if log_RR>=0 & pvalue_cat==3 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR  if group==4  [fw=n_events] , mfcolor(`mfcolor1'*0.5%`mfcolsat1')  mlcolor(`mlcolor1'*0.5%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef2'"=="" {
					local legenddef3 = "Risk in Group 1"
					} 
				else {
					local legenddef3 = ""
					}
				if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef3 = "`legend1'"
					}
				}			
			
			count if log_RR>=0 & pvalue_cat==1 & log_RR!=.
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group==1 [fw=n_events] , mfcolor(`mfcolor1'*0.25%`mfcolsat1')  mlcolor(`mlcolor1'*0.25%`mlcolsat1') )"
				local segments_counter=`segments_counter'+1
				if `legendyn' ==1  & "`legenddef3'"=="" {
					local legenddef4 = "Risk in Group 1"
					}
				else {
					local legenddef4 = ""
					}
			if `legendyn' ==1 & "`legend1'"!="" {
					local legenddef4 = "`legend1'"
					}
				}
					
			count if log_RR<0 & pvalue_cat==2
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group==7   [fw=n_events] ,  mfcolor(`mfcolor2'%`mfcolsat2') mlcolor(`mlcolor2'%`mlcolsat2') )"
				if `legendyn' ==1 & "`legend5'"=="" {
					local legenddef5 = "Risk in Group 2"
					} 
				else {
					local legenddef5= ""
					}	
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef5 = "`legend2'"
					}
			}			
	
			count if log_RR<0 & pvalue_cat==0
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group==6  [fw=n_events] ,  mfcolor(`mfcolor2'*0.75%`mfcolsat2') mlcolor(`mlcolor2'*0.75%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef5'"==""  {
					local legenddef6 = "Risk in Group 2"
					} 
				else {
					local legenddef6 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef6 = "`legend2'"
					}		
			}

			count if log_RR<0 & pvalue_cat==3
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group==8 [fw=n_events] ,  mfcolor(`mfcolor2'*0.5%`mfcolsat2') mlcolor(`mlcolor2'*0.5%`mlcolsat2') )"
				if `legendyn' ==1  &  "`legenddef6'"=="" {
					local legenddef7 = "Risk in Group 2" 
					} 
				else {
					local legenddef7 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef7 = "`legend2'"
					}
				}
				
			count if log_RR<0 & pvalue_cat==1
			if r(N)>0 & r(N)!=. {
				local graphcode "`graphcode' (scatter log_p_val_chi log_RR 	if group==5   [fw=n_events] ,  mfcolor(`mfcolor2'*0.25%`mfcolsat2') mlcolor(`mlcolor2'*0.25%`mlcolsat2') )"
				if `legendyn' ==1  & "`legenddef7'"==""  {
					local legenddef8 = "Risk in Group 2"
					} 
				else {
					local legenddef8 = ""
					}
				if `legendyn' ==1 & "`legend2'"!="" {
					local legenddef8 = "`legend2'"
					}
				}	
						
			*To account for possibility of 0 events in either RR<1 or RR>=1
			count if log_RR>=0 & log_RR!=.
			local rr_pos = r(N)
			count if log_RR <0   & log_RR!=.
			local rr_neg = r(N)
				
			if (`rr_pos'!=0  & `rr_pos'!=.) & (`rr_neg'!=0 & `rr_neg'!=.)  {
					local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') )"
						if `legendyn' ==1 & "`legend9'"=="" {
							local legenddef9 = "" 
						}
					local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
						if `legendyn' ==1 & "`legend10'"=="" {
							local legenddef10 = "" 
						}
				}	
				
			if (`rr_pos'!=0  & `rr_pos'!=.) & (`rr_neg'==0 | `rr_neg'==.)  {
					local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group>=1 & group<=4   , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol1')  mlabangle(`labang1') mlabposition(`labpos1') mlabgap(`labgap1') "
						if `legendyn' ==1 & "`legend9'"=="" {
							local legenddef9 = "" 
						}
				}		
		
			if (`rr_pos'==0  | `rr_pos'==.) & (`rr_neg'!=0 & `rr_neg'!=.)  {
					local graphcode "`graphcode' (scatter log_p_val_chi log_RR if group>=5 & group<=8 , msymbol(i)  mlabel(mylabel) mlabcolor(`labcol2')  mlabangle(`labang2') mlabposition(`labpos2') mlabgap(`labgap2') " 
						if `legendyn' ==1 & "`legend10'"=="" {
							local legenddef10 = "" 
						}
				}
				
			if `rr_pos'==0  {
				local segments_counter=`segments_counter'+1
				}
			local segments_counter=`segments_counter'+1
			
			*Building legend text
			if `legendyn' ==1 &  "`legenddef1'"!="" {
				local legendtext1 = "lab(1 `legenddef1')" 
			}
							
			if `legendyn' ==1 &  "`legenddef1'"==""  &  "`legenddef2'"!=""   {
				local legendtext1 = "lab(1 `legenddef2')"
			}
						
			if `legendyn' ==1 &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef3'"!=""  {
				local legendtext1 = "lab(1 `legenddef3')" 
			}
						
			if `legendyn' ==1 &  "`legenddef3'"=="" &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"!=""     {
				local legendtext1 = "lab(1 `legenddef4')" 
			}
			
			if "`legend1'"!="" {
				local legenddef9 = "`legend1'"
				}
			
			if "`legend1'"=="" {
				local legenddef9 = "Risk in Group 2"
				}
			
			if `legendyn' ==1 &  "`legenddef3'"==""  &  "`legenddef2'"=="" &  "`legenddef1'"=="" &  "`legenddef4'"==""   {
				local legendtext1 = "lab(1 `legenddef9')" 
			}
										
			if `legendyn' ==1 &  "`legenddef5'"!="" {
				local legendtext2 = "lab(`segments_counter' `legenddef5')" 
			}
						
			if `legendyn' ==1 &  "`legenddef5'"==""  &  "`legenddef6'"!=""  {
				local legendtext2 = "lab(`segments_counter' `legenddef6')"
			}
						
			if `legendyn' ==1 &  "`legenddef6'"=="" &  "`legenddef5'"=="" &  "`legenddef7'"!=""   {
				local legendtext2 = "lab(`segments_counter' `legenddef7')" 
			}
						
			if `legendyn' ==1 &  "`legenddef7'"=="" &  "`legenddef6'"==""  &  "`legenddef5'"=="" &  "`legenddef8'"!=""    {
				local legendtext2 = "lab(`segments_counter' `legenddef8')" 
			}
			
			if "`legend2'"!="" {
				local legenddef10 = "`legend2'"
				}

			if "`legend2'"=="" {
				local legenddef10 = "Risk in Group 1"
				}
				
			if `legendyn' ==1 &  "`legenddef8'"==""  &  "`legenddef7'"=="" &  "`legenddef6'"=="" &  "`legenddef5'"==""   {
				local legendtext2 = "lab(1 `legenddef10')" 
				}

			local legendtext = "order(1 `segments_counter') `legendtext1' `legendtext2'"
			
			if `rr_pos'==0 {
				local legendtext = "order(1) `legendtext1'"
				}
		
			if `rr_neg'==0 {
				local legendtext = "order(1) `legendtext2'"
				}
			
			if `legendyn' ==0  {
				local legendtext = "off"
			}
			
			*xlab options:
			if `min_whole'!=0 & `ticks_xaxis'!=0 & `max_whole'!=0 {
				local xlab = "xlab(`min_whole'(`ticks_xaxis')`max_whole')"
			}
			
			*Add in graph options:
			local graphcode "`graphcode' title(`title') subtitle(`subtitle')  xtitle(`xaxistitle') ytitle(`yaxistitle') yline( `ynum' , lpattern(`ylinepat') lcolor(`ylinecol') lwidth(`ylinewidth')  ) ylab(`min_whole_lp'(`ticks_yaxis')`max_whole_lp' , nogrid) `xlab' graphregion(color(`grphcol')) plotregion(color(`plotcol'))), legend(`legendtext'  pos(`legendpos') cols(`legendcol') rows(`legendrow'))"

			*Run graph code:			
			noi `graphcode'
			cap drop if log_RR == .
				}
			}

************************

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
	restore , not
	use `ae_volcano_1'.dta , clear
}

} /*close the big quietly loop around aevolcano*/

end


*****************************************************************
/*FDR adjustment as per Mehrotra and Adewale
V1.0 10/02/2020
*/

cap prog drop aefdr
program define aefdr , rclass
version 15.0

/*Description:
Adjusting p-values according to work of Mehrotra and Adewale 
Start with a row per event - require variable for bodysystem ID, AE ID and unadjsuted p-value 
v0.1: original  
*/


*Syntax
syntax, FDRHIGHER(varname) FDRLOWER(varname) PVALUEADJ(varname)  [FDRval(real 0.1)]


/*
Syntax explanation 
fdrhigher - can contain numeric or string. 
			indicates the variable that contains the higher level/bodysystem AE name/identifier
			
fdrlower -   can contain numeric or string.
			indicates the variable that contains the lower level AE name/identifier

pvalueadj - contains numeric variable containing unadjusted p-values

fdrval - optional command that indicates the alpha value to flag events at. Default is 0.1
*/

qui{ /* open the big quietly loop for aefdr*/
****Error checking*********
	
*Confirm  pvalue numeric
cap confirm numeric variable `pvalueadj' 
local pval_num =  _rc
if `pval_num' !=0 {
	display as error "pvalue variable not numeric"
	exit 7
	} /*closes if pval_num loop*/

*****************************************************************************

tokenize `fdrhigher'
local by_bs "`1'"
tokenize  `fdrlower' 
local by_ae "`1'"

if  substr("`:type `by_bs''" ,1,3) == "str"  & substr("`:type `by_ae''" ,1,3) == "str" {
	/*STRING OPTION FOR BODYSYSTEM AND EVENT */
	
	egen bs_id = group(`by_bs')
	egen ae_id = group(`by_ae')
	
	sort  bs_id `pvalueadj' ae_id

	*Ranks events within bodysystems
	bysort bs_id : gen rank =  [_n]

	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort bs_id : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value for each event
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	 summ bs_id
	return list
	local max = r(max)
	disp `max'
	
	*Generating variable for body-system p-value
	gen bs_p = .

	*Generating variable for event p-value
	gen p2 =.

*Looping through each bodysystem in turn
	foreach num of numlist 1(1)`max' {
		disp "fdrhigher" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if bs_id==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in higher term" `num' ":" `maxevents`num''

		disp `maxevents`num''
		local maxevents = `maxevents`num''
		
		*Numbers do not have to be consecutive so if a bodysystem number is not 
		*used then this will allow the code to keep running
		if `maxevents' == . {
			gen  error`num' = _rc
			} /*closing if loop*/
			
		else {
	
		*Looping through each event in a bodysystem/higher term (from largerst to smallest)
			foreach num1 of numlist `maxevents'(-1)1  {
				disp `maxevents' 
				
				*Bounding adjusted p-values by the maximum unadjusted value in that bodysystem
				replace p2 = p1 if rank==max  & bs_id==`num'

				*Establishing minimum p-value for each of the N-1 events
				replace  p2 =  p1[_n] if p2 ==. & rank==`num1' & p1[_n]< p2[_n+1] & bs_id==`num'
				
				replace p2 = p2[_n+1] if p2 ==. & rank==`num1' & p2[_n+1]<= p1[_n] & bs_id==`num'
				} /*closes foreach num1 loop*/

		} /*closes else loop*/
			
			*Creating a bodysystem p-value equal to the minimum adjusted event p-value
			cap summ p2 if bs_id==`num'
			replace bs_p = r(min) if bs_id==`num'
			sort bs_id rank

	} /*closes foreach num loop */
	
} /*closes the big if substring loop*/
	

if  substr("`:type `by_bs''" ,1,3) != "str"  & substr("`:type `by_ae''" ,1,3) == "str" {

	/*NUMERIC OPTION FOR BODYSYSTEM AND STRING EVENT*/
	
	cap encode `by_ae', gen(aefdr_int_1)
	
	if _rc!=0 {
		gen aefdr_int_1=real(`by_ae')
	}

	sort  `fdrhigher' `pvalueadj' `fdrlower'

	gen bs_id = `fdrhigher'
	gen ae_id = aefdr_int_1
	
	*Ranks events within bodysystems
	bysort `fdrhigher' : gen rank =  [_n]

	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort `fdrhigher' : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem/higher term
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	summ `fdrhigher'
	return list
	local max = r(max)
	disp `max'

	*Generating variable for body-system p-value
	gen bs_p = .

	*Generating variable for event p-value

	gen p2 =.

*Looping through each bodysystem in turn
	foreach num of numlist 1(1)`max' {
		disp "fdrhigher" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if `fdrhigher'==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in higher term" `num' ":" `maxevents`num''

		disp `maxevents`num''
		local maxevents = `maxevents`num''
		
		*Numbers do not have to be consecutive so if a bodysystem number is not 
		*used then this will allow the code to keep running
		if `maxevents' == . {
			gen  error`num' = _rc
			} /* closes the if maxevents loop*/
		
	else {
	
		*Looping through each event in a bodysystem (from largerst to smallest)
		foreach num1 of numlist `maxevents'(-1)1  {
			disp `maxevents' 
			
			*Bounding adjusted p-values by the maximum unadjusted value in that higherterm/bodysystem
			replace p2 = p1 if rank==max  & `fdrhigher'==`num'

			*Establishing minimum p-value for each of the N-1 events
			replace  p2 =  p1[_n] if p2 ==. & rank==`num1' & p1[_n]< p2[_n+1] & `fdrhigher'==`num'
			
			replace p2 = p2[_n+1] if p2 ==. & rank==`num1' & p2[_n+1]<= p1[_n] & `fdrhigher'==`num'
			
			} /*closes the else loop*/

		} /*closes the foreach num loop*/
			
			*Creating a bodysystem p-value equal to the minimum adjusted event p-value
			cap summ p2 if `fdrhigher'==`num'
			replace bs_p = r(min) if `fdrhigher'==`num'
			sort `fdrhigher' rank

	} /*close the  else loop*/
	} /*close the big else loop*/


if  substr("`:type `by_bs''" ,1,3) == "str"  & substr("`:type `by_ae''" ,1,3) != "str" {

	/*STRING OPTION FOR BODYSYSTEM AND NUMERIC EVENT*/
	
	cap encode `by_bs', gen(aefdr_int_2)
	
	if _rc!=0 {
		gen aefdr_int_2=real(`by_bs')
	}

	sort  `fdrhigher' `pvalueadj' `fdrlower'

	gen bs_id = aefdr_int_2
	gen ae_id = `fdrlower'
		
	*Ranks events within bodysystems
	bysort `fdrhigher' : gen rank =  [_n]
	
	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort `fdrhigher' : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	*summ `fdrhigher'
	summ bs_id
	return list
	local max = r(max)
	disp `max'

	*Generating variable for body-system p-value
	gen bs_p = .

	*Generating variable for event p-value

	gen p2 =.

*Looping through each bodysystem in turn
	foreach num of numlist 1(1)`max' {
		disp "fdrhigher" `num'
		
		*Generating local macro with max number of events in each bodysystem
		*cap summ rank if `fdrhigher'==`num'
		cap summ rank if bs_id==`num'

		return list
		local maxevents`num' = r(max)
		disp "Number of events in higher term" `num' ":" `maxevents`num''

		disp `maxevents`num''
		local maxevents = `maxevents`num''
		
		*Numbers do not have to be consecutive so if a bodysystem number is not 
		*used then this will allow the code to keep running
		if `maxevents' == . {
			gen  error`num' = _rc
			} /* closes the if maxevents loop*/
		
		else {
	
		*Looping through each event in a bodysystem/higher term (from largerst to smallest)
			foreach num1 of numlist `maxevents'(-1)1  {
				disp `maxevents' 
				
				*Bounding adjusted p-values by the maximum unadjusted value in that bodysystem
				*replace p2 = p1 if rank==max  & `fdrhigher'==`num'
				replace p2 = p1 if rank==max  & bs_id==`num'

				*Establishing minimum p-value for each of the N-1 events
				replace  p2 =  p1[_n] if p2 ==. & rank==`num1' & p1[_n]< p2[_n+1] & bs_id==`num'

				replace p2 = p2[_n+1] if p2 ==. & rank==`num1' & p2[_n+1]<= p1[_n] & bs_id==`num'

				} /*closes the else loop*/
		} /*closes the foreach num loop*/
			
			*Creating a bodysystem p-value equal to the minimum adjusted event p-value
			cap summ p2 if bs_id==`num'
			replace bs_p = r(min) if bs_id==`num'
			sort bs_id rank

	} /*close the  else loop*/
	} /*close the big else loop*/


else if  substr("`:type `by_bs''" ,1,3) != "str"  & substr("`:type `by_ae''" ,1,3) != "str" {

	/*NUMERIC OPTION FOR BODYSYSTEM AND EVENT*/

	sort  `fdrhigher' `pvalueadj' `fdrlower'

	gen bs_id = `fdrhigher'
	gen ae_id = `fdrlower'
		
	*Ranks events within bodysystems
	bysort `fdrhigher' : gen rank =  [_n]

	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort `fdrhigher' : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	summ `fdrhigher'
	return list
	local max = r(max)
	disp `max'

	*Generating variable for body-system p-value
	gen bs_p = .

	*Generating variable for event p-value

	gen p2 =.

*Looping through each bodysystem in turn
	foreach num of numlist 1(1)`max' {
		disp "fdrhigher" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if `fdrhigher'==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in bodsystem" `num' ":" `maxevents`num''

		disp `maxevents`num''
		local maxevents = `maxevents`num''
		
		*Numbers do not have to be consecutive so if a bodysystem/higher term number is not 
		*used then this will allow the code to keep running
		if `maxevents' == . {
			gen  error`num' = _rc
			} /* closes the if maxevents loop*/
		
		else {
		*Looping through each event in a bodysystem/higherterm (from largerst to smallest)
			foreach num1 of numlist `maxevents'(-1)1  {
				disp `maxevents' 
				
				*Bounding adjusted p-values by the maximum unadjusted value in that higherterm
				replace p2 = p1 if rank==max  & `fdrhigher'==`num'

				*Establishing minimum p-value for each of the N-1 events
				replace  p2 =  p1[_n] if p2 ==. & rank==`num1' & p1[_n]< p2[_n+1] & `fdrhigher'==`num'
				
				replace p2 = p2[_n+1] if p2 ==. & rank==`num1' & p2[_n+1]<= p1[_n] & `fdrhigher'==`num'
				} /*closes the else loop*/
		} /*closes the foreach num loop*/
			
			*Creating a bodysystem p-value equal to the minimum adjusted event p-value
			cap summ p2 if `fdrhigher'==`num'
			replace bs_p = r(min) if `fdrhigher'==`num'
			sort `fdrhigher' rank

	} /*close the  else loop*/
	} /*close the big else loop*/
	
cap drop error*

*Rank bodysystem p-values
egen rank_bs = rank(bs_p) if rank==1 , unique // assign unique ties, arbitrary assigning different values for tied ranks

**Create a variable to indicate bodysystem rank on each row
bysort bs_id : egen rank_bs_grp = max(rank_bs)

*Generate the max number of bodysystems
egen max_bs_rank =max(rank_bs)
 
gen max_bs_p = bs_p if rank_bs==max_bs_rank

*Inflating the body system p-values
gen p1_bs  = (max_bs_rank/rank_bs)*bs_p
	
sort rank_bs

*Bounding maximum adusted bodysystem p-value 
gen p2_bs = p1_bs if rank_bs==max_bs_rank
	
*Looping through each bodysystem to calculate adjusted p-value
foreach num of numlist `max'(1)1 {
		
	replace p2_bs   =  p1_bs[_n] if p2_bs ==. & rank_bs==`num' & p1_bs[_n]< p2_bs[_n+1]
	replace p2_bs = p2_bs[_n+1] if p2_bs ==. & rank_bs==`num' &  p2_bs[_n+1]<= p1_bs[_n]
	
	summ  p2_bs if rank_bs == `num' 
	replace p2_bs  = r(min) if p2_bs==. & rank_bs_grp == `num'
		
	} /*close foreach num loop*/

sort bs_id ae_id
	
*Flagging the events that satisfy max threshold p-value to indicate a signal
gen flag = 1 if  p2<`fdrval' & p2_bs<`fdrval'
	
keep   `fdrhigher'  `fdrlower'  `pvalueadj' p2   p2_bs flag
cap lab var p2 "FDR adjusted p-value for AE (lower level)"
cap lab var p2_bs "FDR adjusted p-value for bodysystem (higher level)"
cap lab var flag "Flag for events that satisfy p-value threshold in fdrval"

noi display as text  "Dataset with adjusted p-values now saved in working directory"	
noi save adjusted_pvalues.dta , replace
} /*closes the big quietly loop for aefdr*/

end

exit
