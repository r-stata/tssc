*** Adrien Avril 2015
cap program drop clean_class
program clean_class
version 13.1
syntax varlist 

foreach i in `varlist' {
replace `i'=upper(`i')
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","U",.)
replace `i'=subinstr(`i',"�","U",.)
replace `i'=subinstr(`i',"�","U",.)
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","I",.)
replace `i'=subinstr(`i',"`=char(160)'","",.)
replace `i'=subinstr(`i',"'"," ",.)
replace `i'=subinstr(`i',"-"," ",.)
replace `i'=trim(`i') 
replace `i'=subinstr(`i',"    "," ",.)
replace `i'=subinstr(`i',"   "," ",.)
replace `i'=subinstr(`i',"  "," ",.)
replace `i'=subinstr(`i'," ","",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","C",.)
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","U",.)
replace `i'=subinstr(`i',"�","U",.)
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","A",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","E",.)
replace `i'=subinstr(`i',"�","I",.)
replace `i'="" if `i'=="."
replace `i'=upper(`i')
replace `i'=subinstr(`i',"EME","",.)
}
end
