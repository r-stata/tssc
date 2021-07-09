/* lasagna.ado
Geoff Dougherty, geoffdougherty@gmail.com
Creates lasagna plots as described by Swihart, Caffo et al (2010): 
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2937254/

*/ 
program define lasagna 
	version 12 
	syntax varlist(min=2 max=2) [if] [in] , over(varname) [ levels(integer 5) *]
	tokenize `varlist'
	
	preserve 
	
	marksample touse 

	keep if `touse'==1 
	 
	local stopMarker=0 
	local j=0

	* create a new uniquely named variable to hold ordered group numbers 
	* can't use tempvar because varname needs to be passed to twoway
	while `stopMarker'==0 {
		* assemble a varname from random characters
		forval a = 1/32 {
			local b=runiformint(65,90) 
			local newChar=char(0`b')
			local vString="`vString'`newChar'" 
		}	
		capture confirm variable `vString'
		if _rc {
			local stopMarker=1
		}
		else {
			local j=`j'+1
			* if we can't find a unique varname after 10 tries, error and exit. 
			if `j'>10 {
				error 507
			}
		}
     }
	 gen `vString'=. 
 	 
	 qui levels `over', local(categories)  		
		local i = 0 		
		foreach c of local categories {
			local i = `i'+1
			qui replace `vString'=`i' if `over'=="`c'" 
			local ylab `ylab' `i' `" "`c'" "'
		}	
		
	label variable `vString' "`over'"	
		
	twoway contour   `1' `vString' `2' if `touse', heatmap levels(`levels') `options'  ///
		ylabel(`ylab',  angle(horizontal))
		
	drop `vString' 	
	
	restore
end

