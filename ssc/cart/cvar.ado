*!cvar.ado
*!Puts Characteristics of a VARiable in a new variable and macro's.
*!Programming utility.
*22/3/97
*5/7/98 added: the different values  of the variable are also stored in macro's
/*

cvar var ,[nomis|mis] nam(string) select(string)


Creates int variable

`nam' 		with values 1,2,3,.., corresponding to the ordered values
		of var. If nam() not specified it will be default the first 
		6 characters of the name of var, followed by underscore _.

and global macro's 

$`nam'`i' 	The value label of the i-th value of var (if existing). 
		If no value label is associated with (the i-th value of) var
		it will contain the value itself.
		The label is embedded in double quotes " ", unless
		there is no value label associated with the variable.
$v`nam'`i' 	The i-th value of var.

$n`nam'	 	Number of classes
$l`nam'		Variable label of var.
$f`nam'		Display format in case of floating vars or date formatted vars
		without value label. 
$w`nam'		Width required to display the $`nam'`i', i.e. max(length("$nami")).



Var may be any type of variable.

If mis specified the missing value (or blank string) will be considered a 
separate class. If nomis is specified, records with var missing will be 
deleted! Default mis: missing values considered a separate class.

select() offers the possibility to create only the macro's or
	the new variable. If not specified: all macro's and the new variable
	will be created. If select is specified macro's and variable will
	be created dependent on the characters in select():
   v|V	           the variable `nam' only
   n|N|w|W|f|F 	   all the macro's  only
   l|L		   the l`nam' macro  only
		
Note: `nam' should not start with an underscore _, and may be maximum 5 
	characters. If not, the name will be shortened and/or the underscore  
	removed.


*/
program define cvar
version 6.0
local options "noMis Nam(string) SELect(string)"
local varlist "req ex min(1) max(1) "
local if "opt"
local in "opt"
parse `"`0'"' 
count `if' `in' 
if r(N)==0 {
  	noisily display `"`if' `in' : no observations"'
  	exit
}
local var `varlist'

*If nam starts with an underscore, remove it.
while index("`nam'","_")==1 { local nam=substr("`nam'",2,5) }
if "`nam'"=="" {  local nam =substr("`var'",1,4)+"_" }
local nam=substr("`nam'",1,5)

tempvar  x y
if "`select'"=="" {
	local ALL ALL
	local L L 
	local VAR VAR
}
else {
	nel ,str(A`select') el(vV)
	if $S_1>=1  {local VAR VAR }
	nel ,str(A`select') el(wWfFnN)
	if $S_1>=1  {local ALL ALL }
	nel ,str(A`select') el(wWfFnNlL)
	if $S_1>=1   {local L L }
}

eformat `var',lab val
local type   : type `var'
local format : format `var'
local vallab : value label `var'
local varlab : variable label `var'
if `"`varlab'"'=="" {local varlab "`var'" }

if "`L'"=="L" { global l`nam' `"`varlab'"' }

if "`VAR'"=="VAR" |"`ALL'"=="ALL" {
 if "`mis'"=="nomis" {
  if index("`type'","str")>0 	{	drop if `var'==""  }
  else 				{	drop if `var'==.   }
 }
 if _N==0 { 
  	noisily display "Only missing observations"
  	exit
 }

 sort `var'
 quietly by `var':gen int  `x'=1 if _n==1
 sort `x' `var'
 replace `x'=sum(`x') 
 quietly sum `x'

 if "`ALL'"=="ALL" {
  global w`nam':char `var'[width]
  global n`nam' =r(max) 
  local nn= r(max)

  if "`vallab'"~="" {              /* variable with value label */
   local i=1
   while `i'<=`nn' {
     local val=`var'[`i']
     global v`nam'`i' `val'
     local lab:label `vallab' `val' 
*     local val =substr("`lab'",1,8)   /* 14/9/01 modification: length macro may be longer than 8 now
                                                  unclear whether this may cause a problem elsewhere!
                                                  Can be made optional */
     local val  `lab'
     global `nam'`i' ""`val'""
     local i=`i'+1
   }
   global f`nam' 
  }
  else  {
   local i=1
   while `i'<=`nn' {
     local val =`var'[`i']
     global v`nam'`i' `val'
     if index("`type'","str")>0 {
         global `nam'`i' ""`val'""
     }
     else {
         global `nam'`i' ""`val'""
     }
     local i=`i'+1
   }
   if index("`type'","str")>0 {
     global f`nam' 
   }
   else {
     global f`nam' `format'
   }
  }
 }
*nois display "A1 VAR: `VAR'"
}
*nois display "A2 VAR: `VAR'"
if "`VAR'"=="VAR" {
*Test that `nam' is a new varname should be done!
  sort  `var' `x'
*nois display "A3 VAR: `VAR'"
  quietly by `var':gen int `nam'=`x'[1]
}
end
     
