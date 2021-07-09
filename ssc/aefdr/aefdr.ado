/*FDR adjustment as per Mehrotra and Adewale
V1.0 10/02/2020 
*/

cap prog drop aefdr
program define aefdr , rclass
version 15.0

/*Description:
Adjusting p-values according to work of Mehrotra and Adewale 
Start with a row per event - require variable for bodysystem ID, AE ID and unadjusted p-value 
v0.1: original  
*/


*Syntax
syntax, BODYsys(varname) EVENT(varname) PVALUEADJ(varname)  [FDRval(real 0.1)]


/*
Syntax explanation 
bodysys - can contain numeric or string. 
			indicates the variable that contains the higher level AE name/identifier
			
event -  can contain numeric or string. 
			indicates the variable that contains the lower level AE name/identifier

pvalueadj - contains numeric variable containing unadjusted p-values

fdrval - optional command that indicates the alpha value to flag events at. Default is 0.1
*/

qui{
****Error checking*********
	
*Confirm  pvalue numeric
cap confirm numeric variable `pvalueadj' 
local pval_num =  _rc
if `pval_num' !=0 {
	display as error "pvalue variable not numeric"
	exit 7
	} /*closes if pval_num loop*/

*****************************************************************************

tokenize `bodysys'
local by_bs "`1'"
tokenize  `event' 
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
		disp "bodysystem" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if bs_id==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in bodsystem" `num' ":" `maxevents`num''

		disp `maxevents`num''
		local maxevents = `maxevents`num''
		
		*Numbers do not have to be consecutive so if a bodysystem number is not 
		*used then this will allow the code to keep running
		if `maxevents' == . {
			gen  error`num' = _rc
			} /*closing if loop*/
			
		
		else {
	
		*Looping through each event in a bodysystem (from largerst to smallest)
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

	sort  `bodysys' `pvalueadj' `event'

	gen bs_id = `bodysys'
	gen ae_id = aefdr_int_1
	
	*local bsid = `bodysys'
	
	*Ranks events within bodysystems
	bysort `bodysys' : gen rank =  [_n]

	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort `bodysys' : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	summ `bodysys'
	return list
	local max = r(max)
	disp `max'

	*Generating variable for body-system p-value
	gen bs_p = .

	*Generating variable for event p-value
	gen p2 =.

*Looping through each bodysystem in turn
	foreach num of numlist 1(1)`max' {
		disp "bodysystem" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if `bodysys'==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in bodsystem" `num' ":" `maxevents`num''

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
				
				*Bounding adjusted p-values by the maximum unadjusted value in that bodysystem
				replace p2 = p1 if rank==max  & `bodysys'==`num'

				*Establishing minimum p-value for each of the N-1 events
				replace  p2 =  p1[_n] if p2 ==. & rank==`num1' & p1[_n]< p2[_n+1] & `bodysys'==`num'
				replace p2 = p2[_n+1] if p2 ==. & rank==`num1' & p2[_n+1]<= p1[_n] & `bodysys'==`num'
				
				} /*closes the else loop*/

		} /*closes the foreach num loop*/
			
			*Creating a bodysystem p-value equal to the minimum adjusted event p-value
			cap summ p2 if `bodysys'==`num'
			replace bs_p = r(min) if `bodysys'==`num'
			sort `bodysys' rank

	} /*close the  else loop*/
	} /*close the big else loop*/

if  substr("`:type `by_bs''" ,1,3) == "str"  & substr("`:type `by_ae''" ,1,3) != "str" {

	/*STRING OPTION FOR BODYSYSTEM AND NUMERIC EVENT*/
	
	cap encode `by_bs', gen(aefdr_int_2)
	
	if _rc!=0 {
		gen aefdr_int_2=real(`by_bs')
	}

	sort  `bodysys' `pvalueadj' `event'

	gen bs_id = aefdr_int_2
	gen ae_id = `event'
	
	*local bsid = `bodysys'
	
	*Ranks events within bodysystems
	bysort `bodysys' : gen rank =  [_n]

	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort `bodysys' : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	*summ `bodysys'
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
		disp "bodysystem" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if bs_id==`num'

		*cap summ rank if `bodysys'==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in bodsystem" `num' ":" `maxevents`num''

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
				
				*Bounding adjusted p-values by the maximum unadjusted value in that bodysystem
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

	sort  `bodysys' `pvalueadj' `event'

	gen bs_id = `bodysys'
	gen ae_id = `event'
	
	*Ranks events within bodysystems
	bysort `bodysys' : gen rank =  [_n]

	*Generates the max rank in each bodysytem to indicate total number of events within each
	bysort `bodysys' : egen max =max(rank)

	*Generate the maximum p-value for each bodysystem
	gen p1_max = `pvalueadj' if rank==max

	*Generate an inflated p-value
	gen p1 = (max/rank)*`pvalueadj'

	*Create a local macro that indicates total number of bodysystems
	summ `bodysys'
	return list
	local max = r(max)
	disp `max'

	*Generating variable for body-system p-value
	gen bs_p = .

	*Generating variable for event p-value
	gen p2 =.

*Looping through each bodysystem in turn
	foreach num of numlist 1(1)`max' {
		disp "bodysystem" `num'
		
		*Generating local macro with max number of events in each bodysystem
		cap summ rank if `bodysys'==`num'
		return list
		local maxevents`num' = r(max)
		disp "Number of events in bodsystem" `num' ":" `maxevents`num''

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
			
			*Bounding adjusted p-values by the maximum unadjusted value in that bodysystem
			replace p2 = p1 if rank==max  & `bodysys'==`num'

			*Establishing minimum p-value for each of the N-1 events
			replace  p2 =  p1[_n] if p2 ==. & rank==`num1' & p1[_n]< p2[_n+1] & `bodysys'==`num'
			replace p2 = p2[_n+1] if p2 ==. & rank==`num1' & p2[_n+1]<= p1[_n] & `bodysys'==`num'
			
			} /*closes the else loop*/

		} /*closes the foreach num loop*/
			
			*Creating a bodysystem p-value equal to the minimum adjusted event p-value
			cap summ p2 if `bodysys'==`num'
			replace bs_p = r(min) if `bodysys'==`num'
			sort `bodysys' rank

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
	
*sort p1_bs
sort rank_bs
*sort bs_p

*Bounding maximum adusted bodysystem p-value 
gen p2_bs = p1_bs if rank_bs==max_bs_rank
	
*Looping through each bodysystem to calculate adjusted p-value
foreach num of numlist `max'(1)1 {
		
	replace  p2_bs   =  p1_bs[_n] if p2_bs ==. & rank_bs==`num' & p1_bs[_n]< p2_bs[_n+1]
	replace p2_bs = p2_bs[_n+1] if p2_bs ==. & rank_bs==`num' &  p2_bs[_n+1]<= p1_bs[_n]
	
	summ  p2_bs if rank_bs == `num' 
	replace p2_bs  = r(min) if p2_bs==. & rank_bs_grp == `num'
		
	} /*close foreach num loop*/
	
sort bs_id ae_id
	
*Flagging the events that satisfy max threshold p-value to indicate a signal
gen flag = 1 if  p2<`fdrval' & p2_bs<`fdrval'
	
keep   `bodysys'  `event'  `pvalueadj' p2   p2_bs flag
cap lab var p2 "FDR adjusted p-value for AE (lower level)"
cap lab var p2_bs "FDR adjusted p-value for bodysystem (higher level)"
cap lab var flag "Flag for events that satisfy p-value threshold in fdrval"

noi display as text  "Dataset with adjusted p-values now loaded in memory"	

noi save adjusted_pvalues.dta , replace

}
end
exit
