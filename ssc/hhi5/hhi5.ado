*! Version Oct16 2013
*! Author: Lian Yujun (arlionn@163.com)

cap program drop hhi5
program define hhi5
version 9

syntax varlist(min=1) [if] [in][, by(varlist) PREfix(string) /*
       */ Top(numlist >0 max=1) Minobs(numlist >0 max=1) /*
	   */ PERcentage OUTfile(string) NOExpand, replace]
	   
marksample touse

tokenize `if' `in'

tempvar rowmin
qui egen `rowmin'=rmin(`varlist')
qui sum `rowmin'
if r(min)<0{
   display as error "Negative values in varlist"
   exit 198
}

if "`percentage'"==""{
   local prop "prop"
}

if "`prefix'"==""{
   if "`top'"==""{
      local prefix "hhi"
   }
   else{
      local prefix "hhi`top'"
   }
}
else{
   cap confirm names `prefix'
   if _rc!=0{
      dis in red `"`prefix' invalid prefix name, see "'  "{help varname}"
	  exit 7
   }
}

foreach var of local varlist{
  *-Top5 or Top# HHI
  if "`top'"!=""|"`minobs'"!=""{
     tempvar ng yes
     qui bysort `by': egen `ng'_`var' = count(`var') `if' `in'
     qui gsort  `by' -`var'  
     qui bysort `by': gen `yes' = _n `if' `in'
	 if "`top'"!=""&"`minobs'"!=""{
	    qui replace `yes'=. if (`yes'>`top'|`ng'_`var'<`minobs')
	 }
	 else if "`top'"!=""&"`minobs'"==""{
	    qui replace `yes'=. if (`yes'>`top'|`ng'_`var'<`top')
	 }	 
	 else if "`top'"==""&"`minobs'"!=""{
	    qui replace `yes'=. if (`ng'_`var'<`minobs')
	 }
     tempvar pc
     qui egen `pc'_`var' = pc(`var') if `yes'!=., `prop' by(`by') 
	 qui egen `prefix'_`var' = sum(`pc'_`var'^2) if `yes'!=., by(`by') 
	 cap drop `ng' 
	 cap drop `pc' 
	 cap drop `yes'
  }
  *-Full sample HHI
  else{
     tempvar pc
     qui egen `pc'_`var' = pc(`var') `if' `in', `prop' by(`by') 
	 qui egen `prefix'_`var' = sum(`pc'_`var'^2) `if' `in', by(`by')
	 drop `pc'
  }
  
  if "`noexpand'"==""{
     qui bysort `by': replace `prefix'_`var' = `prefix'_`var'[1]  `if' `in' 
  }
}

if "`outfile'"!="" { 
  preserve
  qui egen tag=tag(`by') `if' `in'
  qui keep if tag==1 
  if wordcount("`varlist'")==1{
     qui gsort `by' -`varlist' 
  }
  else{
     qui gsort `by'
  }
  qui outsheet `by' `varlist' `prefix'*  using "`outfile'.csv", comma `replace'
  di in gr "output has been saved in default directory"
  di `"{browse `"`c(pwd)'"':dir}"'
  restore
}

end

/*
di `"{browse `"`c(pwd)'"':dir}"'
di as txt `"(output written to {browse `using0'})"'
*/
