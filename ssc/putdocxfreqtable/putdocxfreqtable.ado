*! Original author : Jan Brogger (jan@brogger.no)
*! Description     : Produces frequency oneway tables with putdocx.
*! Maintained at   : https://github.com/janbrogger/putdocxfreqtable
capture program drop putdocxfreqtable
program define putdocxfreqtable
	version 15.1
	syntax varlist(min=1 max=1) [if], [noCUM] [noSUM] [PERCDigits(integer 0)] [LABLen(integer 0)]
	capture putdocx describe
	if _rc {
		di in smcl as error "ERROR: No active docx."
		exit = 119
	}
	
	if `lablen'<0 {
		di in smcl as error "ERROR: LABLEN cannot be negative"
		exit = 120
	}	
		
	preserve	
	if `"`if'"'!=`""' {
		keep `if'
	}
	tempname freq percent cumcount cumpercent
	contract `varlist' , freq(`freq')
			
	//Add sum row
	if "`sum'"!="nosum" {
		qui count
		local newobs= `r(N)'+1
		qui set obs `newobs'
		capture confirm numeric variable `varlist'
		if !_rc {
			qui replace `varlist'=. if _n==_N
		}
		else {
			qui replace `varlist'="" if _n==_N
		}
		qui summ `freq'
		qui replace `freq'=`r(sum)' if _n==_N		
		local sumif "if _n<_N"		
	}
	else {
		local sumif ""	
	}	
	
	order `varlist'	
	qui summ `freq' `sumif'
	qui gen `percent'=`freq'/`r(sum)'*100	
	qui gen `cumcount' = sum(`freq') `sumif'
	qui summ `freq' `sumif'
	qui gen `cumpercent'= `cumcount'/`r(sum)'*100	
	drop `cumcount'
	format `percent' `cumpercent' %3.1f
	label variable `freq' "Count"
	label variable `percent' "%"
	label variable `cumpercent' "Cumulative %"
	
	if "`sum'"!="nosum" {
		qui replace `cumpercent'=. if _n==_N
	}
	
	

	if "`cum'"=="nocum" {
		local matvars `freq' `percent' 
		local colnames `""Count" "%" "'
	}
	else {
		local matvars `freq' `percent' `cumpercent' 
		local colnames `""Count" "%" "Cum. %""'
	}
		
	mkmat `matvars' , mat(data)	
			
	//Make temporary rownames	
	qui levelsof `varlist' , local(levels)
	local rownames ""
	local rowcount : word count `levels'

	local lbe : value label `varlist'
	qui levelsof `varlist' , local(levels)
	
	foreach l of local levels {
		if "`lbe'"!="" {
			local vallab : label `lbe' `l'
			//Truncate label length if specified
			if `lablen' >= 1 {
				local vallab=substr(`'"`vallab'"',1,`lablen')
			}
			if strlen(`"`vallab'"')>32 {
				local vallab=substr(`'"`vallab'"',1,32)
				local vallab `"`vallab'"'
			}
			local rownames `"`rownames' `vallab'"'
		}
		else {			
			local rownames `'"`rownames' `l'"'
		}		
	}		

	//Add sum rowname if present
	if "`sum'"!="nosum" {
		local rownames `"`rownames' "SUM" "'
	}	
	
	matrix rownames data = `rownames'

	//Fix column names
	local varlab : variable label `varlist'
	if `"`varlab'"'=="" {
		local varlab `"`varlist'"'
	}
	matrix colnames data = `colnames'
	
	local title `"Frequency table for `varlab'"'
	di `"`title'"'
	matlist data 


	*tempname doesn't work?
	*tempname mytable
	local mytable=floor(runiform()*10000)
	local mytable="t`mytable'"
	local nformat "%4.`percdigits'f"
	
	putdocx table `mytable' = matrix(data), width(70%) title(`"`title'"')  rownames  colnames 
	cap putdocx table `mytable'(., 3), nformat(`nformat')
	cap putdocx table `mytable'(., 4), nformat(`nformat')
	
	
	//Do rownames better to avoid truncation of long labels
	local lbe : value label `varlist'
	qui levelsof `varlist' , local(levels)
	local row=3
		
	foreach l of local levels {
		if "`lbe'"!="" {
			local vallab : label `lbe' `l'
			//Truncate label length if specified
			if `lablen' >= 1 {
				local vallab=substr("`vallab'",1,`lablen')
			}
			putdocx table `mytable'(`row',1) = (`"`vallab'"')
		}
		else {			
			putdocx table `mytable'(`row',1) = (`l')
		}		
		local row=`row'+1
	}		
	
	restore
	
	
end
