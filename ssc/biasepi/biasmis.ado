*! v 1.0.1 Chunsen Wu 8march2019 bias analysis for misclassification
*! v 1.0.2 Chunsen Wu 19April2019 bias analysis for misclassification

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

capture program drop biasmis
program biasmis, rclass
syntax varlist(max=2) [if] [in] [, sa(real 0.75) sb(real 0.95) sc(real 0.75) sd(real 0.95) MIStype(real 1)  GENerate(namelist max=1)  seed(numlist max=1)]
version 13.1
tokenize `varlist'
marksample touse


qui {
biastab2 `varlist'
mat X=r(B)
local r=rowsof(X)
local c=colsof(X)
if `r'!= 2  {
display as error "The outcome (`1') has to be a binary variable"
exit
}
if `c'!=2 {
display as error "The exposure (`2') has to be a binary variable"
exit
}
}
*
biastab2 `varlist'
local a=r(a)
local b=r(b)
local c=r(c)
local d=r(d)

biasmisi `a' `b' `c' `d', sa(`sa') sb(`sb') sc(`sc') sd(`sd') mistype(`mistype')

**************************************************
//return values
**************************************************
local RD_Corrected=  r(RD_Corrected)
local OR_Corrected=  r(OR_Corrected)
local RR_Corrected=  r(RR_Corrected)
local RD_Observed= r(RD_Observed)
local OR_Observed= r(OR_Observed)
local RR_Observed= r(RR_Observed)


local illegal=r(illegal)

matrix S=r(S)  /*distribution according to the sensitivity*/
matrix P=r(P)  /*predictive value*/
matrix C=r(C)  /*corrected*/
matrix SE=r(SE)  /*SE for standard RR, OR, and RD*/
matrix O=r(O)  /*observed*/



		   
mat P=r(Predicted)
local pa=P[1,1]
local pb=P[1,2]
local pc=P[2,1]
local pd=P[2,2]

local ngen: word count `generate'
if `ngen'!=0 {
qui {
tab1 `1', matrow(D)
tab1 `2', matrow(E)


capture drop _pv
gen _pv=.
replace _pv=`pa' if `1'==D[2,1] & `2'==E[2,1]
replace _pv=`pb' if `1'==D[2,1] & `2'==E[1,1]
replace _pv=`pc' if `1'==D[1,1] & `2'==E[2,1]
replace _pv=`pd' if `1'==D[1,1] & `2'==E[1,1]

gen `generate'=.
local seedroot: word count `seed'
if `seedroot'!=0 {
set seed `seed'
}
replace `generate'=rbinomial(1, _pv)
}
}
*
**************************************************
//return values
**************************************************
return scalar RD_Corrected=  `RD_Corrected'
return scalar OR_Corrected=  `OR_Corrected'
return scalar RR_Corrected=  `RR_Corrected'
return scalar RD_Observed= `RD_Observed'
return scalar OR_Observed= `OR_Observed'
return scalar RR_Observed= `RR_Observed'


return scalar illegal=`illegal'

retur matrix S=S  /*distribution according to the sensitivity*/
return matrix P=P  /*predictive value*/
return matrix C=C  /*corrected*/
return matrix SE=SE
return matrix O=O  /*observed*/
end

