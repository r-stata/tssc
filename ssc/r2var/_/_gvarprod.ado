*! varprod V2.0 26/02/2014
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define _gvarprod
 version 6, missing
 gettoken type 0 : 0
 gettoken g 0 : 0
 gettoken eqs 0 : 0
 syntax varlist [if] [in] [, BY(string) Missing]
 version 7.0, missing
 local si $EGEN_SVarname
 version 6.0, missing
 local varlist : list varlist - si
 if `"`by'"' != "" {
 _egennoby varprod() `"`by'"'
 }
 quietly { 
 tokenize `varlist'
 if "`missing'" == "" {
 gen `type' `g' = cond(`1'>=.,0,`1') `if' `in'
 mac shift 
 while "`1'"!="" {
 replace `g'=`g'*cond(`1'>=.,0,`1') `if' `in'
 mac shift 
 }
 }
 else {
 gen `type' `g' = cond(`1'>=.,.,`1') `if' `in'
 mac shift 
 while "`1'"!="" {
 replace `g' = cond(`g'==., ///
 cond(`1'>=.,.,`1'), cond(`1'>=., ///
 `g', `g' + `1')) `if' `in'
 mac shift 
 }
 }
 }
end
