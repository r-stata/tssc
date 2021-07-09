*** Adrien Avril 2015
cap program drop clean_class
program clean_class
version 13.1
syntax varlist 

foreach i in `varlist' {
replace `i'=upper(`i')
replace `i'=subinstr(`i',"À","A",.)
replace `i'=subinstr(`i',"Á","A",.)
replace `i'=subinstr(`i',"Ù","U",.)
replace `i'=subinstr(`i',"Ú","U",.)
replace `i'=subinstr(`i',"Ü","U",.)
replace `i'=subinstr(`i',"Á","A",.)
replace `i'=subinstr(`i',"Â","A",.)
replace `i'=subinstr(`i',"È","E",.)
replace `i'=subinstr(`i',"Ê","E",.)
replace `i'=subinstr(`i',"É","E",.)
replace `i'=subinstr(`i',"Ë","E",.)
replace `i'=subinstr(`i',"Ï","I",.)
replace `i'=subinstr(`i',"`=char(160)'","",.)
replace `i'=subinstr(`i',"'"," ",.)
replace `i'=subinstr(`i',"-"," ",.)
replace `i'=trim(`i') 
replace `i'=subinstr(`i',"    "," ",.)
replace `i'=subinstr(`i',"   "," ",.)
replace `i'=subinstr(`i',"  "," ",.)
replace `i'=subinstr(`i'," ","",.)
replace `i'=subinstr(`i',"è","E",.)
replace `i'=subinstr(`i',"ê","E",.)
replace `i'=subinstr(`i',"é","E",.)
replace `i'=subinstr(`i',"ç","C",.)
replace `i'=subinstr(`i',"à","A",.)
replace `i'=subinstr(`i',"ù","U",.)
replace `i'=subinstr(`i',"ü","U",.)
replace `i'=subinstr(`i',"à","A",.)
replace `i'=subinstr(`i',"â","A",.)
replace `i'=subinstr(`i',"è","E",.)
replace `i'=subinstr(`i',"ê","E",.)
replace `i'=subinstr(`i',"é","E",.)
replace `i'=subinstr(`i',"ë","E",.)
replace `i'=subinstr(`i',"ï","I",.)
replace `i'="" if `i'=="."
replace `i'=upper(`i')
replace `i'=subinstr(`i',"EME","",.)
}
end
