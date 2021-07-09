*! v 1.0.2 Chunsen Wu 19April2019 simple bias analysis for Two-way table of frequencies

****************************************************************************************************
//biastab2
****************************************************************************************************

capture program drop biastab2
program biastab2, rclass
version 13.1
syntax varlist(max=2) [if] [in] 

marksample touse 
tokenize `varlist'

tab2 `1' `2' if `touse', matcell(A)

local RN=rowsof(A)
local CN=colsof(A)
mat B=J(`RN', `CN',.)
local downr=0
foreach r of numlist 1/`RN' {
	local i= `RN'-`downr'
	local downc=0
	foreach c of numlist 1/`CN' {
	local j=`CN'- `downc'
	mat B[`r', `c']=A[`i', `j']
	local downc= `downc'+1
	}
	local downr= `downr'+1
	}
*

qui {
tab `1', matrow(E)
tab `2', matrow(O)
}
*

foreach x of numlist 1/`RN' {
local r=`RN'-`x'+1
local rowv`x'v=E[`r',1]

}
*


foreach x of numlist 1/`CN' {
local r=`CN'-`x'+1
local colv`x'v=O[`r',1]
}
*


if `RN'==2 {
 mat rownames B=`rowv1v'  `rowv2v' 
}
*
if `RN'==3 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v'
}
*
if `RN'==4 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v'
}
*
if `RN'==5 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v' `rowv5v'
}
*
if `RN'==6 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v' `rowv5v' `rowv6v'
}
*
if `RN'==7 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v' `rowv5v' `rowv6v' `rowv7v'
}
*
if `RN'==8 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v' `rowv5v' `rowv6v' `rowv7v' `rowv8v'
}
*
if `RN'==9 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v' `rowv5v' `rowv6v' `rowv7v' `rowv8v' `rowv9v'
}
*
if `RN'==10 {
 mat rownames B=`rowv1v'  `rowv2v'  `rowv3v' `rowv4v' `rowv5v' `rowv6v' `rowv7v' `rowv8v' `rowv9v' `rowv10v'
}
*
if `CN'==2 {
mat colnames B=`colv1v'  `colv2v' 
}
*
if `CN'==3 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'
}
*
if `CN'==4 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'
}
*
if `CN'==5 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'  `colv5v'
}
*
if `CN'==6 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'  `colv5v'  `colv6v'
}
*
if `CN'==7 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'  `colv5v'  `colv6v'  `colv7v' 
}
*
if `CN'==8 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'  `colv5v'  `colv6v'  `colv7v'  `colv8v'
}
*
if `CN'==9 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'  `colv5v'  `colv6v'  `colv7v'  `colv8v'  `colv9v' 
}
*
if `CN'==10 {
mat colnames B=`colv1v'  `colv2v'  `colv3v'  `colv4v'  `colv5v'  `colv6v'  `colv7v'  `colv8v'  `colv9v'  `colv10v'
}
*

display _newline(1)"tabulation of `1' and `2'"
mat list B, noheader



if `RN'==2 & `CN'==2 {
	forvalue r=1/`RN' {
		forvalue c=1/`CN' {
		local v`r'`c'v=B[`r',`c']
		}
		}
		
return scalar d=`v22v'	
return scalar c=`v21v'	
return scalar b=`v12v'
return scalar a=`v11v'



}
return mat B=B
end
