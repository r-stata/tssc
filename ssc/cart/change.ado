*!change.ado
*!12/11/97 -> 3/5/99
*!WvP
/*
changes variable attributes

change varname [newname|.  [label|.   [+]varlab]]]

1. varname existing variable
2. newname new name (should not exist) or . if the same name
		if newname is equal to the full name of the existing variable, the name will not be changed.
3. label   name of value label
4. varlab  variable label, optionally preceded or followed by a + sign, which implies that the 
   variable label specified by change will be attached (pre or post) to the existing variable label.

1,2 and 3 without embedded blanks.

Example:

 change var1 boter . . Boter is beter

hernoemt var1 in boter met variable label  "Boter is beter"

3/5/99: odd blanks are allowed now in variable label part! 
*/
program define change
version 7.0
quietly {
   tokenize `"`0'"',parse(" ")
   local total `0'
   local l1=length("`1'")+1 
   local l2=length("`2'")+1 
   local l3=length("`3'")+1 

   _crcunab `1'
   local var $S_1
   if "`2'"~="."&"`2'"~="-" &"`2'"~=""&"`2'"!="`var'" {
   	rename `var' `2' 
   	local var `2'
   }
   if "`3'"=="-" {label values `var'  }
   else if "`3'"!="."&"`3'"!=""&"`3'"~="" {label values `var' `3' }
   macro shift 3
   
   local varlab `*'
   if "`varlab'"~=""&"`varlab'"~="."&"`varlab'"~="-"  {
    if substr("`*'",1,1)=="+" {
      local plus =substr("`*'",2,.) 
      local varlab: var label `var'
      macro shift
      local varlab `varlab' `plus'  
   }
   else if substr(`"`*'"',length(`"`*'"'),1)=="+" {
    local plus=substr(`"`*'"',1, length(`"`*'"')-1)
    local varlab: var label `var'
    local varlab `plus' `varlab' 
   }
	 label variable `var' "`varlab'" 
  }	     
  else if "`varlab'"=="-" { label variable `var'  }
}   
end
