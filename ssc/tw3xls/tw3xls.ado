* Three-way to Excel (tw3xls) is a convenient tool to 
* export three-way frequency tables into Excel.
* It allows to pre-format and easily save data into a spreadsheet.
* Performance depends on disk read/write speed, number of tables (when in conjuction with -by-) and formatting options


*! tw3xls - Export three-way tables into Excel with formatting
*! Andrey Ampilogov, a.ampilogov@gmail.com
*! v1.2, 26-Aug-2017
* v1.1, 20-Apr-2017
* v1.0, 08-Nov-2016

cap program drop tw3xls

program define tw3xls, sortpreserve rclass
	version 14.2						//lowering the version will broke formatting of the putexcel commands, for example merge not working
	syntax varlist(min=3 max=3) [if] [in] using/, [ by(varname) sheet(string) STub(string) ///
		MIssing(real 12344) Format(string) sort(string) top(real 12344) Total(string) show replace modify]
	
	marksample touse
	token `varlist' 

	*~~~~~~~~~~~~~~~ preliminary ~~~~~~~~~~~~~~~; takes 0.05 sec
	* --> check if a `by' variable is present and save its type (string/numeric)
	local 4 `by'
	cap confirm variable `4'
	if _rc local four = -1
	else {
		cap confirm numeric variable `4'
		if !_rc local four = 0
		else    local four = 1
	}
	local varlist "`varlist' `4'"
	
	* --> create temporary varialbes
	foreach var of local varlist {
		tempvar levels_`var' 			//levels for each variable value (1,2,3,etc)
		tempname `var'_cnt   			//scalar for the number of levels of each variable
		tempfile labels					//temporary dataset whcich contains labels for rwos and corresponding values
	}
	tempvar freq group					//frequency values
	tempname _freq_scalar cols	rows	//frequency scalar = values of matrices, cols and rows = size of output matrix
	
	* --> save levels of each variable and its dimension (count of unique values)
	foreach var of local varlist {
		scalar ``var'_cnt' = 0
		gen `levels_`var'' = 0 
		
		qui levelsof `var', local(list`var')
		foreach x of local list`var' { 
			scalar ``var'_cnt' = ``var'_cnt' + 1
			cap confirm string variable `var'
			if _rc qui replace `levels_`var'' = ``var'_cnt' if `var' == `x'
			else   qui replace `levels_`var'' = ``var'_cnt' if `var' == "`x'"
		}
	}
	
	* --> save the size of tables/matrices and their elements = frequencies
	scalar `cols' = ``2'_cnt' * ``3'_cnt'
	scalar `rows' = ``1'_cnt'
	qui bysort `varlist': gen `freq' = _N 
	
	* --> label variables if there are no labels
	foreach var of local varlist {
		local l`var' : variable label `var' 			//save empty lables for a restore after program finishes
		local a: di `"`: var label `var''"' 
		if "`a'"=="" 	label variable `var' "`var'"	//label variables
	}
	
	
	*~~~~~~~~~~~~~~~ matrix generetaion ~~~~~~~~~~~~~~~; takes 0.5 sec
	* --> generate matrices with frequencies for each value of `4'th variable
	* -contract- is much faster than looping over three levelsof with -summ `freq' if ... - ; -r(N)-
	if `four' == -1 local list`4' = 1
	foreach y of local list`4' {
		//di "Category writen: `y'"
		
		local matcnt = `matcnt' + 1
		tempname U`matcnt'
	
		preserve
	* --> generate a frequencies dataset
		contract `varlist' `if' `in', zero freq(_freq)
		
		if `four' == -1 local happy 1
		else if `four' == 0 qui keep if `4' == `y'
		else if `four' == 1 qui keep if `4' == "`y'"
		
		** some obs left after the -keep- command
		if _N > 0 {
			qui egen `group' = group(`2' `3')
			qui egen  index  = group(`1')
			qui cap drop if `group'==. | index==.
			qui keep `group' _freq index
		
			qui reshape wide _freq, j(`group') i(index)
			* keep encoded id (index) - adjust it in mergingcells later
			order index, first
	* --> set zero freq to missing or another number; less than 0.01 sec of computing
			if `missing' == 12344  qui recode * (0=.)					// default option
			else if `missing' != 0 qui recode * (0=`missing')			// user-defined
	* --> save the matrix
			mkmat _all, mat(`U`matcnt'')
		}
		** in case no obs left 
		else {
			if `missing' == 12344 {
				matrix `U`matcnt'' = J(`=scalar(`rows')',`=scalar(`cols')'+1,.)
			}
			else if `missing' == 0 {
				matrix `U`matcnt'' = J(`=scalar(`rows')',`=scalar(`cols')'+1,0)
			}
			else {
				matrix `U`matcnt'' = J(`=scalar(`rows')',`=scalar(`cols')'+1,`missing')
			}
			//mat list  `U`matcnt''
		}
		mata: `U`matcnt'' = st_matrix("`U`matcnt''")				//copy Stata matrix to mata
		restore
	}
	
	
	*~~~~~~~~~~~~~~~ sort ~~~~~~~~~~~~~~~; 
	* sort tables by rowtot (in descending order)
	if "`sort'" != "" | `top'!=12344 { 
	* --> check entered options
		* for more than one options
		if `: word count `sort'' > 1 { 
			di as err "Please select only one sorting option: h(igh)est first or l(ow)est first"
			exit
		} 
		* for not listed options
		local sortlist "h hi hig high l lo low" 
		local sort1 = "`sort'"				//sort is a special word and usage of it gives an error in a list checking
		if !`: list sort1 in sortlist' { 
			di as err "Sorting option (`sort1') is unavailable. Please select a valid sorting: h(igh)est first or l(ow)est first"
			exit
		}
		local sort = substr("`sort'",1,1) 

	* --> save a dataset with lalbes to merge it in the end
		preserve
		qui egen index = group(`1')
		keep `1' index
		ren `1' rowlabel
		qui duplicates drop
		qui save "`labels'", replace
		restore
	}


	*~~~~~~~~~~~~~~~ TOTAL ~~~~~~~~~~~~~~~; 	
	if "`total'" != "" | "`sort'" != "" {	
	* --> check entered options
		* for more than one options
		if `: word count `total'' > 2 { 
			di as err "Please select one or two total options: r(ows) and/or c(ols)"
			exit
		} 
		* for not listed options
		local totallist = "r ro row rows c co col cols" 
		if !`: list total in totallist' { 
			di as err "Total option (`total') is unavailable. Please select a valid total option(s): r(ows) and/or c(ols)"
			exit
		}
		* check what totals to prepare
		local totallist1 = "c co col cols" 
		local totallist2 = "r ro row rows"
		if !`: list total in totallist1' { 
			local rowtot = "yes"
		}		
		if !`: list total in totallist2' { 
			local coltot = "yes"
		}

	* --> prepare matrices with rows/columns totals
		local matcnt = 0
		foreach y of local list`4' {
			local matcnt = `matcnt' + 1
			
			if "`coltot'" != "" & ("`sort'" != "" | "`rowtot'" != "" | `top'!=12344) {
				mata: s1 = sum(`U`matcnt'')			//workaround for zero matrices
				mata: st_local("s1", strofreal(s1))

				* get row sum
				mata: `U`matcnt'' = `U`matcnt'' , rowsum(`U`matcnt'')
				* adjust rowsum by index value by substracting the first column (or rowid)
				if `s1' > 0 {
				mata: for (i=1; i<=rows(`U`matcnt''); i++) `U`matcnt''[i,cols(`U`matcnt'')] = `U`matcnt''[i,cols(`U`matcnt'')] - i
				}
				* get column sum
				mata: `U`matcnt'' = `U`matcnt'' \ colsum(`U`matcnt'')				
			}
			else if "`sort'" != "" | "`rowtot'" != "" | `top'!=12344 {
				mata: s1 = sum(`U`matcnt'')
				mata: st_local("s1", strofreal(s1))
				
				* get row sum
				if `s1' > 0 {
				mata: `U`matcnt'' = `U`matcnt'' , rowsum(`U`matcnt'')
				}
				* adjust rowsum by index value by substracting the first column (or rowid)
				mata: for (i=1; i<=rows(`U`matcnt''); i++) `U`matcnt''[i,cols(`U`matcnt'')] = `U`matcnt''[i,cols(`U`matcnt'')] - i
			}
			else if "`coltot'" != "" {
				* get column sum
				mata: `U`matcnt'' = `U`matcnt'' \ colsum(`U`matcnt'')
			}
		}
	}

	
	*~~~~~~~~~~~~~~~ Servicing - label matrices ~~~~~~~~~~~~~~~; 	
	* --> prepare matrices with labels for row (rowl), columns (coll), supercolumns (scoll)  
	* duplicate each column labels by the number of supercolumns
	foreach collab of local list`2' {
		local mult = ""			
		forval i = 1/`=scalar(``3'_cnt')' {
			local mult = "`mult' `collab'"
		}
		local list`2'_2 "`list`2'_2' `mult'"
	}
	* generate string matrices with labels
	mata:	row_m  = tokens(st_local("list`1'"))
	mata:	col_m  = tokens(st_local("list`2'"))
	mata:	scol_m = tokens(st_local("list`3'"))
	mata:	rowl   = row_m'
	mata:	coll   = J(1, length(col_m), scol_m)
	mata:	scoll  = tokens(st_local("list`2'_2"))
	* Find the last column and its letter in Excel
	mata: 	st_matrix("`U`matcnt''", `U`matcnt'')			//copy mata matrix back to Stata
	local 	cols   = colsof(`U`matcnt'')
	local 	rows   = rowsof(`U`matcnt'')
	mata: 	st_local("rcolf", numtobase26(`cols'))
	
	

	
	*~~~~~~~~~~~~~~~ top(n) ~~~~~~~~~~~~~~~; 	
	* --> selects top N cases from the top (top depends on sorting: high or low)
	* adjust number of rows; more adjustments are inline with other code
	if `top'!=12344 {
		local coltotrow = 0
		if "`coltot'" != "" local coltotrow = 1
		local rows = `top' + `coltotrow'
	}
	

	*~~~~~~~~~~~~~~~ export to Excel ~~~~~~~~~~~~~~~; 
	* --> export both data and labels to Excel; that is the most intense part due to write opearions; takes ~90% computational time
	* Set default sheet name
	if "`sheet'" == "" local sheet = "Data"
	
	* Replace or modify options
	if "`replace'" == "" & "`modify'" == "" local replace = "replace"
	
	* Prepare an Excel file
	local ext = substr("`using'",-4,.)
	//writing into xls is faster than to xlsx but formatting (merged cells, borders) doesn't work as it should
	if !inlist("`ext'", "xlsx", ".xls")  	local using "`using'.xlsx"	
	qui putexcel clear
	qui putexcel set `"`using'"', sheet("`sheet'") `replace' `modify'

	
	* iterate for each table
	if "`sort'" != "" | `top'!=12344 preserve
	local matcnt = 0
	foreach y of local list`4' {
	* --> Prepare paste positions
		local matcnt = `matcnt' + 1
		mata: st_matrix("`U`matcnt''", `U`matcnt'')			//copy mata matrix back to Stata
		
		* set positions to paste the data in the spreadsheet
		local gap = 5 
		local startrow  = (`matcnt' - 1) * (`rows' + `gap') + 1
		local secondrow = `startrow' + 1	
		local thirdrow  = `startrow' + 2
		local fourthrow = `startrow' + 3
		local fifthrow  = `startrow' + 4
		local lastrow   = `secondrow' + `rows' + `gap' - 3	

		* save row positions into mata vectors
		mata: row1 = strtoreal(st_local("startrow"))
		mata: row2 = strtoreal(st_local("secondrow"))
		mata: row3 = strtoreal(st_local("thirdrow"))
		mata: row4 = strtoreal(st_local("fourthrow"))
		mata: row5 = strtoreal(st_local("fifthrow"))
		mata: rowN = strtoreal(st_local("lastrow"))

		* define table header(s)
		if `four' != -1   local title = "Table for `4' = `y'"
		else    		 		local title = ""

		
	* --> write data description (titles) and mata matrices with values
		if      "`sort'" == "" & `top'==12344 & "`rowtot'" == "" & "`coltot'" == "" {
			qui putexcel A`startrow'  = ("`title'") ///
						 A`secondrow' = ("`: var label `1''") ///
						 B`secondrow' = ("`: var label `2'' and `: var label `3''") ///
						 A`fifthrow'  = matrix(`U`matcnt'') 
		}
		else if "`sort'" == "" & `top'==12344 & "`rowtot'" != "" & "`coltot'" != "" {
			qui putexcel A`startrow'  = ("`title'") ///
						 A`secondrow' = ("`: var label `1''") ///
						 B`secondrow' = ("`: var label `2'' and `: var label `3''") ///
						 A`fifthrow'  = matrix(`U`matcnt'') ///
						 A`lastrow'   = ("Total") ///
						 `rcolf'`thirdrow' = ("Total")
						 						
		}
		else if "`sort'" == "" & `top'==12344 & "`rowtot'" != "" & "`coltot'" == "" {
			qui putexcel A`startrow'  = ("`title'") ///
						 A`secondrow' = ("`: var label `1''") ///
						 B`secondrow' = ("`: var label `2'' and `: var label `3''") ///
						 A`fifthrow'  = matrix(`U`matcnt'') ///
						 `rcolf'`thirdrow' = ("Total")
						 						
		}
		else if "`sort'" == "" & `top'==12344 & "`rowtot'" == "" & "`coltot'" != "" {
			qui putexcel A`startrow'  = ("`title'") ///
						 A`secondrow' = ("`: var label `1''") ///
						 B`secondrow' = ("`: var label `2'' and `: var label `3''") ///
						 A`fifthrow'  = matrix(`U`matcnt'') ///
						 A`lastrow'   = ("Total") 
		}
		qui else if "`sort'" != "" | `top'!=12344 {
		* use save/use algorithm instead of matrix operations for sorting
		* add table titles
			qui putexcel A`startrow'  = ("`title'") ///
						 A`secondrow' = ("`: var label `1''") ///
						 B`secondrow' = ("`: var label `2'' and `: var label `3''") ///
						 `rcolf'`thirdrow' = ("Total") 
			if "`coltot'" != "" qui putexcel A`lastrow' = ("Total")		
			if `top'!=12344 & "`sort'" == "" local sort = "h" 
			
		* add sorted data with corresponding row labels
			drop _all
			svmat `U`matcnt'', names(varn)
			ren varn1 index
			merge m:m index using "`labels'", keepusing(rowlabel) keep(master matched) nogen
			order rowlabel, first
			drop index
		* case for column totals: store the value, apply sorting, restore the totals value
			sum varn`cols' if rowlabel ==.
			if "`sort'" == "h" {
				replace varn`cols' = -1 if rowlabel ==. 
				gsort -varn`cols'
				replace varn`cols' = r(mean) if rowlabel ==. 
				replace rowlabel = -1 if rowlabel ==. 
				label define Total99 -1 "Total"
				label values rowlabel Total99
			}
			else if "`sort'" == "l" {
				replace varn`cols' = 100001 if rowlabel ==. 
				gsort varn`cols'
				replace varn`cols' = r(mean) if rowlabel ==. 
				replace rowlabel = 100001 if rowlabel ==. 
				label define Total99 100001 "Total"
				label values rowlabel Total99
			}
		* select top N cases
			if `top'!=12344  keep if _n<=`top' | rowlabel ==-1 | rowlabel == 100001
		* save sorted matrix with labels into Excel
			export excel using `"`using'"', sheet("`sheet'") cell(A`fifthrow') sheetmodify
			label drop Total99
			restore, preserve
		}
		
		* export label matrices to Excel
		mata:	b = xl()
		mata:	b.load_book("`using'")
		mata:	b.set_sheet("`sheet'")
		if "`sort'" == "" {
			mata:	b.put_string(row5, 1, rowl)			//overwrites index values in the first column
		}
		mata:	b.put_string(row4, 2, coll)
		mata:	b.put_string(row3, 2, scoll)
		mata:	b.close_book()

		
		
	*~~~~~~~~~~~~~~~ format ~~~~~~~~~~~~~~~
	* --> Excel formatting; takes ~90% of computational time
		if "`format'" != "" {
			* --> check entered options
			* for more than one options
			if `: word count `format'' > 2 { 
				di as err "Please select one or two format options: b(asic) and/or m(ergecells)"
				exit
			} 
			* for not listed options
			local formatlist = "b ba bas basic m me merge mergecells" 
			if !`: list format in formatlist' { 
				di as err "Format option (`format') is unavailable. Please select a valid format option(s): b(asic) and/or m(ergecells)"
				exit
			}
			* check what totals to prepare
			local formatlist1 = "b ba bas basic" 
			local formatlist2 = "m me merge mergecells"
			if !`: list format in formatlist1' { 
				local format_merge = "yes"
			}		
			if !`: list format in formatlist2' { 
				local format_basic = "yes"
			}

	*~~~~~~~~~~~~~~~ format(basic) ~~~~~~~~~~~~~~~
	* --> merge table titles, "total" cell, draw borders; takes ~20% of formatting step		
			if "`format_basic'" == "yes" {
			* merge table titles
				qui putexcel A`secondrow':A`fourthrow' , merge hcenter txtwrap
				qui putexcel B`secondrow':`rcolf'`secondrow', merge hcenter txtwrap
			* merge "total" cell
				if "`sort'" != "" | "`rowtot'" != "" {
				qui putexcel `rcolf'`thirdrow':`rcolf'`fourthrow', merge hcenter txtwrap
				}
			* draw borders
				qui putexcel B`fourthrow':`rcolf'`fourthrow', hcenter
				qui putexcel A`secondrow':`rcolf'`lastrow'  , border(all) vcenter 
			}
			
			
	*~~~~~~~~~~~~~~~ format(mergecells) ~~~~~~~~~~~~~~~
	* --> merge super column headers; takes ~80% of the step
			if "`format_merge'" == "yes" {	
				local colsn = `cols' - 1
				if "`sort'" != "" | "`rowtot'" != "" local colsn = `colsn' - 1
				
				forvalues i = 1(`=scalar(``3'_cnt')')`colsn' {
					local col1 = `i'+``3'_cnt'
					  mata:st_local("rcol1", numtobase26(`col1'))
					local col2 = `col1' - ``3'_cnt' + 1
					  mata:st_local("rcol2", numtobase26(`col2'))
					//di "`rcol2'`thirdrow' `rcol1'`thirdrow'"
					qui putexcel `rcol2'`thirdrow':`rcol1'`thirdrow' ,  merge hcenter
				}
			}
		//end of format option
		}
	//end of foreach loop
	}
	putexcel clear

	
	*~~~~~~~~~~~~~~~ show ~~~~~~~~~~~~~~~; ~0.2 sec
	* --> Show Stata's tabulation for three cases: a) one three-way table; 
	* b) a row of three-way tables where a fourth varialbe is numeric; 
	* c) a row of three-way tables where a fourth varialbe is string
	if "`show'" != "" {
		if `four' == -1 {
			di in yellow "Built-in view: table `1' `3' `2', c(freq)"
			cap nois table `1' `3' `2'
		}
		else if `four' == 0 {
			foreach y of local list`4' {
			di in yellow "Built-in view: table `1' `3' `2' if `4' == `y', c(freq) " 	//use label = (`: var label `4'')   
			cap nois table `1' `3' `2' if `4'==`y'
			}
		}
		else if `four' == 1 {
			foreach y of local list`4' {
			di in yellow "Built-in view: table `1' `3' `2' if `4' == " `"""' "`y'" `"""' ", c(freq)"
			cap nois table `1' `3' `2' if `4'=="`y'"
			}
		}
	}
	
	*~~~~~~~~~~~~~~~ stub ~~~~~~~~~~~~~~~
	* --> Save matrices into Stata with a user-defined name
	if "`stub'" != "" {
		forval i = 1/`matcnt'  {
			local matn = "`stub'`i'"
			mat `matn' = `U`i''
			local matlist2 "`matlist2' `matn'"
		}
		di ""
		di in yellow "Output tables stored in matrices:`matlist2'"
	}
	* --> as rclass
	forvalues i = 1/`matcnt' {
		return matrix tw`i' `U`i''
		local matlist2 "`matlist2' r(tw`i')"
	}
	
	*~~~~~~~~~~~~~~~ output ~~~~~~~~~~~~~~~
	* --> click to open the file
	di in yellow "Output written to {browse `using'}"
	
	*~~~~~~~~~~~~~~~ clear ~~~~~~~~~~~~~~~
	* --> clear mata
	mata: mata clear
	
end

