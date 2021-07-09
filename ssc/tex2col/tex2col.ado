*! Version 1.0.0 - 2 July 2014                                             		
*! Author: Santiago Garriga                                                     
*! garrigasantiago@gmail.com      


/* *===========================================================================
	tex2col: Program to Split Text into Columns
	Reference: Santiago Garriga
-------------------------------------------------------------------
Created: 		09Jun2014	
Modified:			
version:		01 
*===========================================================================*/

cap program drop tex2col
program define tex2col, rclass
	version 8.1
	syntax [anything]							///
		[if] [in],								///
		[										///
		COLumns(numlist)						/// Number of columns with data
		data(string)							/// Name of the variable that contains the data
			cname(string)						/// Column names
			rname(string)						/// Row name 
			dpcomma								/// Convert data with commas as decimals to period-decimal format
			ignore(string)						/// Remove specified non-numeric characters
		]

		

*------------------------------------1.1: Error Messages ------------------------------------------

* Number of columns
if (wordcount("`columns'") > 1) {
	disp in red "You should specify only one column number"
	error
}

if ("`columns'" == "") {
	disp in red "You should specify the number of columns"
	error
}

* Column Name
if (wordcount("`cname'") > 1) {
	disp in red "You should specify only one column name"
	error
}

* Data variable 
if ("`data'" == "") {
	disp in red "You should specify the data variable"
	error
}

* Row Name 
if (wordcount("`rname'") > 1) {
	disp in red "You should specify only one row name"
	error
}

* Decimal
if ("`decimal'"!= "") & ("`decimal'" != "comma") {
	disp in red "You should specify either nothing or comma"
	error
}

*------------------------------------1.2: Default Options ------------------------------------------

* Column Name
if ("`cname'"== "")  {
	local cname "col_"
}

* Row Name
if ("`rname'"== "")  {
	local rname "row"
}


*------------------------------------1.3: Program --------------------------------------------------

* Set temporary vars
tempvar concat

qui { 
	local count 0
	foreach num of numlist `columns'/1 {	// Loop for each column data
		
		local ++count 	
		* Extract data for each column
		gen `cname'`num' = word(`data',-`count')
		local vars "`vars' `cname'`count' "
	} 

	* Extract the row name
	egen `concat' = concat(`vars'), punct(" ")
	gen `rname' =ltrim(rtrim(subinstr(`data',`concat',"",.)))


	* Replace string to numeric format for decimals with commas
	* if "`decimal'" == "comma" {
	if "`dpcomma'" == "dpcomma" {
		destring `vars', replace dpcomma ignore(". `ignore'") //force
	}

	* Convert variables to numeric format
	destring `vars', replace ignore("`ignore'")
	
	order `rname' `vars' 
	compress
}
end

exit
