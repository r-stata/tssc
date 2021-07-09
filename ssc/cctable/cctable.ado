* cctable.ado, for Stata version 8.0 or higher
* Sept 2007
* version 1.02
*
* Univariate case control analysis for each exposures, results are summarized into one table. One row, one exposure.
* 
* Result file contains: ordering number of food item(id), name of variable (exposure), number of exposed cases, 
* number of unexposed cases, percentage of exposed among cases, number of exposed controls, number of unexposed controls, 
* percentage of exposed among controls, odds ratio, 95%CI interval, 95% p value. 
* 
*
* NOTA BENE:
* - There is no limitation in the number of exposures.
*
* - With the replace option, command will write the result table into the memory, 
*   so the original file will be deleted from the memory! (But not from the disk)
*   Consequence: you can save the result table as stata file.
*
* syntax: cctable casevariable expvariable [expvariables...] , [nosort or pvalue pe replace exact]
* default is results sorted by 95% p value, ascending order.
* options: nosort  -results are displayed in the same order of variables in the command line
*          or      -sorts the result by odds ratio, descending order
*          exact   -give 2-sided exact p-value (default is chi square test p-value) 
*          pvalue  -sorts the result by 95% p value, ascending order
*          pe      -sorts the result by percentage of exposed among cases and non cases, descending order
*          replace -replace the current dataset with cctable results
*          noabbreviate -display full exposure name (default 12 first chars)
*
* Collaborative work by Gilles Desve and Peter Makary . 
* in case of any question please contact us: 
* g.desve@epiconcept.fr
* peter.makary@ktl.fi 
*(Opinions, notices are welcome as well!)


capture program drop cctable
program cctable
version 8
syntax varlist(min=2) [,or NOsort pe pvalue EXact replace NOABbreviate]

local rowline = "-" 
local rowname = ""
local iRow = 0
local _varsize = 12


quietly foreach var of varlist `varlist'  {
    // Nothing to do for the first var (cases)
	local iRow = `iRow'+1
	if `iRow'==1{
	continue
	}

local ilength =length("`var'")	
if `ilength' > `_varsize' {
local _varsize = `ilength'
}
// Get Exposed, Cases, AR	
count if `1' == 1
local _Totcase = r(N)
count if `var' == 1 & `1' == 1
local _Casexp = r(N)
local _ARexp = `_Casexp' / `_Totcase' * 100

// Get Exposed, Cases, AR	
count if `1' == 0
local _Totcont = r(N)
count if `var' == 1 & `1' == 0
local _Contexp = r(N)
local _ARcontexp = `_Contexp' / `_Totcont' * 100

// get RR and confidence interval
// manage exact option
if "`exact'" == "exact" {
  local exact = ", exact"
} 
cc `1' `var' `exact'
if "`exact'" == "" {
  local _p = r(p)
} 
else {
  local _p = r(p_exact)
} 
local  _rr = r(or)
local _lb_rr = r(lb_or)
local _ub_rr = r(ub_or)

// Fill the matrix
matrix input tempmat = (`iRow', `_Totcase', `_Casexp' , `_ARexp', `_Totcont', `_Contexp' , `_ARcontexp' ///
 ,`_rr',`_lb_rr',`_ub_rr',`_p' )
// First row : create the matrix
 if `iRow' == 2 {
  matrix mymat = tempmat
} 
// Next row add to the matrix
else {
  matrix mymat = mymat \ tempmat
  }

} // End of foreach var

// Select the column for the sort order 
// Pvalue is the default
scalar icol = 11

if "`or'"=="or" {
   scalar icol = -8
}
if "`nosort'"=="nosort" {
   scalar icol = 1
}
if "`pvalue'"=="pvalue" {
   scalar icol = 11
}
if "`pe'"=="pe" {
   scalar icol = -4
}

if c(stata_version) >= 9 {
// Sort the matrix
mata : sortmatrice("mymat","icol")
}

if  (c(stata_version) < 9) & (( "`or'"=="or" ) | ( "`pvalue'"=="pvalue" )| ( "`pe'"=="pe")) {  
  display as error "Sorting results only available in version 9" 
}

// get width for displaing variable labels 
if "`noabbreviate'"=="" {
   local _varsize = 12
}

display
// This number are calculated to allow copy and paste
display in text %`_varsize's "    " %14s "Cases" %22s "Controls"

display in text "{hline 70}" "{hline `_varsize'}"
display in text %`_varsize's "Exposure"  " Total Exposed   %    Total Exposed    %     Odds Ratio            p" 
display in text "{hline 70}" "{hline `_varsize'}"
forvalues jrow = 2(1)`iRow'{
   local _iorder = mymat[`jrow'-1,1]
   local _rowname : word `_iorder' of `varlist'
   local _rowname = substr("`_rowname'",1,`_varsize')
   local _rownames = "`_rownames'" + " " + "`_rowname'"
   display in text %`_varsize's "`_rowname'"  _continue 
   local stemp = el(mymat,`jrow'-1,2) 
   display as result " " %5.0f `stemp'    _continue
   local stemp = el(mymat,`jrow'-1,3) 
   display " " %5.0f `stemp'    _continue
   local stemp = el(mymat,`jrow'-1,4) 
   display " " %7.2f `stemp'   _continue
   local stemp = el(mymat,`jrow'-1,5) 
   display "  " %5.0f `stemp'   _continue
   local stemp = el(mymat,`jrow'-1,6) 
   display " " %5.0f `stemp'   _continue
   local stemp = el(mymat,`jrow'-1,7) 
   display "  " %7.2f `stemp'   _continue
   local stemp = el(mymat,`jrow'-1,8) 
   display "  " %5.2f `stemp'   _continue
   local stemp = el(mymat,`jrow'-1,9)
   local stemp : display %5.2f `stemp' 
   local stemp = " [" + ltrim("`stemp'") + "-"   
   local stemp2 = el(mymat,`jrow'-1,10)
   local stemp2 : display %5.2f `stemp2'      
   local stemp = "`stemp'" + ltrim("`stemp2'")+ "]"
   display " " %-14s  "`stemp'" _continue
   local stemp = el(mymat,`jrow'-1,11) 
   display " " %5.3f `stemp'   _continue
   display
}    
display in text "{hline 70}" "{hline `_varsize'}"
display 

 
// If replace option used : replace the dataset with result matrix 
quietly {
	if "`replace'"=="replace" {
		// forget the Id column used for sorting 
		// matrix mymat = mymat[1...,2...]
		// drop current dataset
		drop _all
		// give explicit variables names
		matrix colnames mymat = id cases exp_cases pexp_cases controls exp_controls pexp_controls OR ci95_low ci95_high pvalue 
		forvalues jrow = 2(1)`iRow' {
		  // matrix mymat[`jrow'-1,4] = mymat[`jrow'-1,2] - mymat[`jrow'-1,3] 
		  // outcome variable what numbered 1 
		  matrix mymat[`jrow'-1,1] = mymat[`jrow'-1,1] - 1 
		}

		svmat double mymat, names(col) 
		// add the exposure variable since matrix rownames are not saved
		gen str12 exposure = "" 
		// put exposure at top of variables
		order id exposure
		local iRow = c(N)
		forvalues jrow = 1(1)`iRow' {
	      local _rowname : word `jrow' of `_rownames'
	      replace exposure =  "`_rowname'" in `jrow'
		}
		format pvalue %5.3f
		format OR ci95_low ci95_high pexp_cases pexp_controls %4.2f
		browse
	}
}

// cleanup
matrix drop tempmat mymat
scalar drop _all
   
end


if c(stata_version) >= 9 {
mata: 
void sortmatrice(string scalar matname, string scalar numcol)
{
x = st_matrix(matname)
y = st_numscalar(numcol)
_sort(x,y)
st_matrix(matname,x) 
}
end
}

