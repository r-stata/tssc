*! Original author : Jan Brogger (jan@brogger.no)
*! Description     : Produces twoway tables with putdocx.
*! Maintained at   : https://github.com/janbrogger/putdocxcrosstab
capture program drop putdocxcrosstab
program define putdocxcrosstab
	version 15.1
	syntax varlist(min=2 max=2) [if],	[noROWSum] [noCOLSum] [TItle(string)] ///
									[MIssing] [noFREQ] [row] [col] ///
									[pformat(string)]	
	capture putdocx describe
	if _rc {
		di in smcl as error "ERROR: No active docx."
		exit = 119
	}
	
	preserve
	if `"`if'"'!=`""' {
		keep `if'
	}
	
	tokenize "`varlist'"
	
	local var1 "`1'"	
	local var2  "`2'"	
	local varlab1 : variable label `var1'
	if "`varlab1'"=="" {
		local varlab1 "`var1'"
	}
	local varlab2 : variable label `var2'
	if "`varlab2'"=="" {
		local varlab1 "`var2'"
	}
	if "`title'"=="" {		
		local title `"Crosstabulation of `varlab1' by `varlab2' "'
	}
	
	if "`row'"!="" & "`col'"!="" {
		di as err "Specify only one of row or column options"
		error -1
	}
	
	if "`pformat'"=="" {
		local pformat "%3.0f"
	}
	
	local shading1 "lightgray"
	local shading2 ""
	
	tabulate `var1' `var2' , `missing' `row' `col' `freq'
	local nrows=`r(r)'+2
	local ncols=`r(c)'+1
	
	if "`rowsum'"!="norowsum" {
		local ncols=`ncols'+1
	}
	
	if "`colsum'"!="nocolsum" {
		local nrows=`nrows'+1
	}
	
	if `ncols'>63 {
		di as error "More than 63 columns are not allowed"
		error -1
	} 
	
	tempname var1num
	capture confirm numeric variable `var1'	
	if _rc!=0 {
		encode `var1' , gen(`var1num')
		local var1 "`var1num'"
	}
	
	tempname var2num
	capture confirm numeric variable `var2'	
	if _rc!=0 {
		encode `var2' , gen(`var2num')
		local var2 "`var2num'"
	}	
	
	tempname mytable
	putdocx table `mytable' = (`nrows', `ncols')  , title(`"`title'"')
	putdocx table `mytable'(1,1), shading(`shading1')
	
	//Add row variable name
	putdocx table `mytable'(2,1) = (`"`varlab1'"'), halign(left) rowspan(2) 
	putdocx table `mytable'(2,1), shading(`shading2')
		
	** Write out row headers
	qui levelsof `var1' , local(levels1) `missing'	
	local vallab1 : value label `var1'
	local currentrow=4
	local currentcol=1
	foreach val1 in `levels1' {
		if "`vallab1'"!="" {
			local value1 : label `vallab1' `val1'			
		}
		else {
			local value1 `val1'
		}
				
		putdocx table `mytable'(`currentrow',`currentcol') = (`"`value1'"'), halign(left) 
		putdocx table `mytable'(`currentrow',`currentcol'), shading(`shading2')
		local currentrow=`currentrow'+1
	}
	
	** Write out column headers
	qui levelsof `var2' , local(levels2) `missing'
	putdocx table `mytable'(2,2) = (`"`varlab2'"'), halign(center) colspan(`r(r)') 
	putdocx table `mytable'(2,2) , shading(`shading2')
	local vallab2 : value label `var2'
	local currentrow=3
	local currentcol=2
	foreach val2 in `levels2' {
		if "`vallab2'"!="" {
			local value2 : label `vallab2' `val2'
		}
		else {
			local value2 `val2'
		}
				
		putdocx table `mytable'(`currentrow',`currentcol') = (`"`value2'"'), halign(left) 
		putdocx table `mytable'(`currentrow',`currentcol'), shading(`shading2')
		local currentcol=`currentcol'+1		
	}
	
	** Write out cell counts, percentages or both
	local sum = 0
	qui levelsof `var2' , local(levels2) `missing'
	local vallab2 : value label `var2'
	local startrow=4
	local startcol=2
	local currentrow=`startrow'
	local currentcol=`startcol'	
	foreach val1 in `levels1' {
		qui count if `var1'==`val1'
		local rowcount=`r(N)'
		foreach val2 in `levels2' {
			qui count if `var2'==`val2'
			local colcount=`r(N)'
			qui count if `var1'==`val1'	& `var2'==`val2'		
			local cellcount=`r(N)'
			local sum=`sum'+`cellcount'
			local rowperc=`cellcount'/`rowcount'*100
			local colperc=`cellcount'/`colcount'*100
			local rowpercf : di `pformat' `rowperc'
			local colpercf : di `pformat' `colperc'
			if "`freq'"=="nofreq" {
				if "`row'"=="row" {
					local cell "`rowpercf'%"
				}
				else if "`col'"=="col" {
					local cell "`colpercf'%"
				}
			}
			else {
				local cell "`r(N)'"
				if "`row'"=="row" {
					local cell "`cell' (`rowpercf'%)"
				}
				else if "`col'"=="col" {
					local cell "`cell' (`colpercf'%)"
				}
			}
			
			putdocx table `mytable'(`currentrow',`currentcol') = ("`cell'"), halign(left)
			local currentcol=`currentcol'+1									
		}
		local currentrow=`currentrow'+1
		local currentcol=`startcol'
	}
	
	** Write out row sums
	if "`rowsum'"!="norowsum" {
		qui levelsof `var1' , local(levels1) `missing'
		local currentrow=4
		local currentcol=`ncols'
		foreach val1 in `levels1' {						
			qui count if `var1'==`val1'	
			local rowcount=`r(N)'									
			if "`freq'"=="nofreq" {
				if "`row'"=="row" {
					local rowpercf : di `pformat' 100
					local cell "`rowpercf'%"
				}
				else if "`col'"=="col" {
					local rowpercf : di `pformat' `rowcount'/`sum'*100
					local cell "`rowpercf'%"
				}
			}
			else {
				local cell "`rowcount'"
				if "`row'"=="row" {
					local rowpercf : di `pformat' 100
					local cell "`cell' (`rowpercf'%)"
				}
				else if "`col'"=="col" {
					local rowpercf : di `pformat' `rowcount'/`sum'*100
					local cell "`cell' (`rowpercf'%)"
				}
			}
			putdocx table `mytable'(`currentrow',`currentcol') = ("`cell'"), halign(left) 
			putdocx table `mytable'(`currentrow',`currentcol') ,  shading(`shading2')
			local currentrow=`currentrow'+1
		}
		putdocx table `mytable'(3,`ncols') = ("Total"), halign(left) 
		putdocx table `mytable'(3,`ncols'), shading(`shading2')
	}
	
	** Write out column sums
	if "`colsum'"!="nocolsum" {
		qui levelsof `var2' , local(levels2) `missing'
		local currentrow=`nrows'+1
		local currentcol=2
		foreach val2 in `levels2' {
			qui count if `var2'==`val2'				
			local colcount=`r(N)'
			
			
			if "`freq'"=="nofreq" {
				if "`row'"=="row" {
					local colpercf : di `pformat' `colcount'/`sum'*100			
					local cell "`colpercf' %"
				}
				else if "`col'"=="col" {
					local colpercf : di `pformat' 100
					local cell "`colpercf' %"
				}
			}
			else {
				local cell "`r(N)'"
				if "`row'"=="row" {
					local colpercf : di `pformat' `colcount'/`sum'*100			
					local cell "`cell' (`colpercf'%)"
				}
				else if "`col'"=="col" {
					local colpercf : di `pformat' 100
					local cell "`cell' (`colpercf'%)"
				}
			}
			
			putdocx table `mytable'(`currentrow',`currentcol') = ("`cell'"), halign(left) 
			putdocx table `mytable'(`currentrow',`currentcol'),  shading(`shading2')
			local currentcol=`currentcol'+1
		}
		putdocx table `mytable'(`currentrow',1) = ("Total"), halign(left) 
		putdocx table `mytable'(`currentrow',1) , shading(`shading2')
	}
	
	if "`colsum'"!="nocolsum" & "`rowsum'"!="norowsum" {
		local currentrow=`nrows'+1
		qui count 
		local totalcount= `r(N)'
		local sumperc=`totalcount'/`sum'*100
		local sumpercf : di `pformat' `sumperc'
		if "`freq'"=="nofreq" {
				if "`row'"=="row" {
					local cell "`sumpercf' %"
				}
				else if "`col'"=="col" {
					local cell "`sumpercf' %"
				}
			}
			else {
				local cell "`totalcount'"
				if "`row'"=="row" {
					local cell "`cell' (`sumpercf'%)"
				}
				else if "`col'"=="col" {
					local cell "`cell' (`sumpercf'%)"
				}
			}
		putdocx table `mytable'(`currentrow',`ncols') = ("`cell'"), halign(left) 
		putdocx table `mytable'(`currentrow',`ncols'), shading(`shading2')
	}
	restore
	
end
