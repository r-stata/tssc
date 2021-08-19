
capture program drop mmat
program mmat, rclass

syntax namelist(max=1) [, Row(numlist) Col(numlist)]
version 14
tokenize `namelist'

if "`1'"=="B" {
	display as error "Capital letter B is not allowed, please provide another capital letter"
	exit
}

local rn=rowsof(`namelist')
local cn=colsof(`namelist')
capture mat drop B

local hi=1
foreach r of numlist `row' {
	 local hi= `hi' + 1
 }
 
local hj=1
foreach c of numlist `col' {
    local hj= `hj' + 1
}


local hi=`hi' - 1
*display "hi = " `hi'
local hj= `hj' -  1
*display "hj = " `hj'

if `hi'==1 {
	mat K=`1'[`row', 1...]
} 

if `hi'>1 {
	local i=1
    foreach r of numlist `row' {
		 capture mat drop K`i'
		 mat K`i'=`1'[`r', 1...]
		 *mat list K`i'
		 local i= `i' + 1
	     }

	capture mat drop K
	mat K=K1
	local maxrow=`i'-1
	foreach d of numlist 2/`maxrow' {
		mat K=K\K`d'
	}	
		
}

*mat list K

if `hj'==1 {
	mat B=K[1..., `col']
}

if `hj'>1 {
	
	local j=1
	foreach c of numlist `col' {
		capture mat drop F`j'
		mat F`j'=K[1..., `c']
		*mat list F`j'
		local j= `j' + 1
		}

	capture mat drop B
	mat B=F1
	local maxcol=`j'-1
	foreach h of numlist 2/`maxcol' {
    mat B=B,F`h'
	}
	
}


mat list B
return mat B=B
end 


