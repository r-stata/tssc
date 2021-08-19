

capture program drop mexcel
program mexcel,rclass
version 14
syntax namelist  [if] [in] [, Matrix(name) Row(real 3)]
marksample touse, strok novarlist
tokenize `namelist'
local firstname "`1'"
local cnum: word count `namelist'
local rn= rowsof(`matrix')
local cn= colsof(`matrix')
local dif= `cn' - `cnum'
if `dif'==1 {
       display as error "You must specify `dif' additional column name in Excel"
}
if `dif' > 1 {
    display as error "You must specify `dif' additional columns name in Excel"
}

if `cn' < `cnum' {
    display as error "You specify two much column names in Excel"
}
if `cn' == `cnum' {
    
	local rn= rowsof(`matrix')
	local cn= colsof(`matrix')
	foreach r of numlist 1/`rn' {
	    foreach c of numlist 1/`cn' {
		    local v`r'`c'v= `matrix'[`r', `c']
		}
	}
	
	
	if `cn'==1 {
	    local i=1
	    local start= `row'
		local end=`start' + `rn' -1
		foreach x of numlist `start'/`end' {
		    putexcel `firstname'`x'= (`v`i'1v')
			local i= `i' +1
		}
		
	}
	if `cn'>1 {
	 	local j=1	
	foreach v in  `namelist' {
	    local i=1
	    local start= `row'
		local end=`start' + `rn' -1
		foreach x of numlist `start'/`end' {
		    putexcel `v'`x'= (`v`i'`j'v')
			local i= `i' +1
		}
		local j= `j'+1
		
	}   
		
	}

} 


end
