* clean_name 5/13/2020 Bouguen Adrien
cap program drop clean_name
program clean_name
version 16.0
syntax varlist [, case(string)]
quiet {
	foreach i in `varlist' {
	replace `i'=lower(`i')
	* a
	replace `i'=subinstr(`i',"à","a",.)
	replace `i'=subinstr(`i',"À","a",.)
	replace `i'=subinstr(`i',"Á","a",.)
	replace `i'=subinstr(`i',"á","a",.)
	replace `i'=subinstr(`i',"â","a",.)
	replace `i'=subinstr(`i',"Â","a",.)
	replace `i'=subinstr(`i',"Á","A",.)
	replace `i'=subinstr(`i',"Â","A",.)
	replace `i'= subinstr(`i', "`=char(224)'","a",. )

	* u
	replace `i'=subinstr(`i',"Ù","u",.)
	replace `i'=subinstr(`i',"Ú","u",.)
	replace `i'=subinstr(`i',"Ü","u",.)
	replace `i'=subinstr(`i',"ü","u",.)
	replace `i'=subinstr(`i',"Ù","u",.)
	replace `i'=subinstr(`i',"Ú","u",.)
	replace `i'=subinstr(`i',"Ü","u",.)
	
	* e
	replace `i'=subinstr(`i',"È","e",.)
	replace `i'=subinstr(`i',"Ê","e",.)
	replace `i'=subinstr(`i',"É","e",.)
	replace `i'=subinstr(`i',"Ë","e",.)
	replace `i'=subinstr(`i',"è","e",.)
	replace `i'=subinstr(`i',"ê","e",.)
	replace `i'=subinstr(`i',"é","e",.)
	replace `i'=subinstr(`i',"ç","c",.)
	replace `i'=subinstr(`i',"è","e",.)
	replace `i'=subinstr(`i',"ê","e",.)
	replace `i'=subinstr(`i',"é","e",.)
	replace `i'=subinstr(`i',"ë","e",.)
	replace `i'=subinstr(`i',"Ê","e",.)
	replace `i'=subinstr(`i',"Ë","e",.)
	replace `i'=subinstr(`i',"É","e",.)
	replace `i'=subinstr(`i',"È","e",.)
 	replace `i'=subinstr(`i', "`=char(234)'","e",. )
	replace `i'=subinstr(`i', "`=char(233)'","e",. )
	replace `i'=subinstr(`i', "`=char(232)'","e",. )
	* i 
	replace `i'=subinstr(`i',"Ï","i",.)
	replace `i'=subinstr(`i',"Ï","i",.)
	replace `i'=subinstr(`i',"ï","i",.)
	
	* o
	replace `i'=subinstr(`i',"ô","o",.)
	replace `i'= subinstr(`i', "`=char(244)'","o",. )
	replace `i'=subinstr(`i',"ñ","n",.)
	replace `i'=subinstr(`i',"ç","c",.)
	replace `i'= subinstr(`i', "`=char(231)'","c",. )	
		
	* space 
	replace `i'=subinstr(`i',"`=char(160)'","",.)
	replace `i'=subinstr(`i',"'"," ",.)
	replace `i'=subinstr(`i',"-"," ",.)
	replace `i'=trim(`i') 
	replace `i'=subinstr(`i',"    "," ",.)
	replace `i'=subinstr(`i',"   "," ",.)
	replace `i'=subinstr(`i',"  "," ",.)
	replace `i'="" if `i'=="."
	if "`case'"=="proper" {
		replace `i'=proper(`i')
	}
	if "`case'"=="upper" {
		replace `i'=upper(`i')
	}
	if "`case'"=="lower" {
		replace `i'=lower(`i')
	}
}	


}
end

