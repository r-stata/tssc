*! fns.ado WvP ; 1/10/1996
*! first version 14/9/95   
*! Formats numeric string
*! 1/10/96 Adapted to strings containing elapsed dates
/*Formats a (string containing a) numeric value into a string 
 of specified width (length string, default 5)
 and specified number of decimals (default 0) 

Syntax: 

	fns new old, Width(int) Dec(int) DAte(string)

new 	the name of a global macro 
old 	a number, scalar, expression 
	or 
	a macro containing a number without blanks
string  contains a date format %d or %d...

*/
program define fns
version 4.0
parse "`*'",parse(",")
local opt `3'
parse "`1'" ,parse(" ")
local new "`1'"
local old=`2'

local options "Width(int 5) Dec(int 0) DAte(string)"
parse ",`opt'"

if "`old'"==""|"`old'"=="." {
	global `new' "." 
	exit
}
local x `old'
local p= index("`x'",".")
local l= length("`x'")

*First if not a date format specified:
if "`date'"=="" {
 *Reduce the number of decimals such that the total length fits -if possible-
 * in the specified width
 if `p'>0 {
  local dec=min(`dec', max(0,`width'-`p')) }
 else if `p'==0 {
  local dec=min(`dec', max(0,`width'-`l'-1)) }

* local z=round(`old',10^-`dec')
* local p1= index("`z'",".") 

 if `p'>0&`p'+`dec'<`l'{
	local x =`old' + sign(`old')*.499999*10^-`dec'
	local l= length("`x'")
	local p= index("`x'",".") }

 if `dec'>0{
  local y "`x'"
  if `p'==0{    /* Add . and zero's */
	local y="`x'"+"."
	local i=1 
	while `i'<=`dec' {
	   local y="`y'"+"0"
	   local i=`i'+1 }
	}
  else if `p'+`dec'>`l' & `width'>=`p'+`dec' {  /* Add zero's */
	local 0 "0"
	local y "`x'"
	local i=1 
	while `i'<=`p'+`dec'-`l' {
	 local y "`y'`0'"
	 local i=`i'+1}
	}
  else if `p'+`dec'<=`l' {
	local y=substr("`x'",1,`p'+`dec') 
	}
  }  /* end if dec > 0 */
 else {	         /* dec = 0, no decimals or decimal point */
  local y=int(round(`old',1))
 }
}
else { /* date format specified */
 local y:display `date' = `old'
}
global `new' "`y'"

*noisily display "z:  `z'"
*noisily display "y:  `y'"
end
			 
