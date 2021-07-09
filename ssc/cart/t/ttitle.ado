*!ttitle.ado 
*!first version: 9/7/1998
*!last version:  16/10/2006
*!author: WvP
* Derives a title from the variable label of a variable. 
* Used in autom. generation of a t1title in kapm.ado and a title incart./ado
* previously called title.ado (this file still exists

/* 
Syntax:
		ttitle varname [,f]
     f (optional) indicates that the title is used for kapm failure-curves. 
Result:
		S_1 contains the default title string 
		S_2 short name as label in figure
		S_3 short name for recovery values
*/
program define ttitle
version 9.0
syntax varname  [, Fail ]
global S_3
local varlab:variable label `varlist'
local format:format `varlist'

*Get rid of Date (of) or  Datum (van) in the variable label
if index(upper("`varlab'"),"DATE OF")==1          local varlab =substr("`varlab'",8,.) 
else if index(upper("`varlab'"),"DATE")==1        local varlab =substr("`varlab'",5,.) 
else if index(upper("`varlab'"),"DATUM VAN")==1   local varlab =substr("`varlab'",9,.) 
else if index(upper("`varlab'"),"DATUM")==1       local varlab =substr("`varlab'",6,.) 

local varlab=upper(substr("`varlab'",1,1))+ substr("`varlab'",2,.)  /* first letter capital */

if index("`format'","d")>0 {
  /* 10/7/03 added for st data in kapm - can be extended and made smarter */
  global S_1 `varlab'
  if `"`varlab'"'=="" global S_1 `varlist' 
  global S_2 `varlist'
  global F_2 `varlist'
}
else if  (index(upper("`varlab'"),"OVERALL SURV")>0 | index("`varlist'","os")>0)& index(upper("`varlab'"),"(EXT)")==0{
  global S_1 Overall survival 
  global S_2 OS
  global F_2 Dead
}
else if  index(upper("`varlab'"),"OVERALL SURV")>0 | index("`varlist'","os")>0 {
  global S_1 Overall survival (ext)
  global S_2 OS (ext)
  global F_2 Dead (ext)
}
else if index(upper("`varlab'"),"DISEASE FREE SURV. FROM CR")>0 | index("`varlist'","dfs")>0 {
  global S_1 Disease free survival from CR 
  global S_2 DFS
  global F_2 Rel/Dead
}
else if index(upper("`varlab'"),"DISEASE FREE SURV")>0 {
  global S_1 Disease free survival
  global S_2 DFS
  global F_2 Rel/Dead
}
else if index(upper("`varlab'"),"EVENT FREE SURV")>0 | index("`varlist'","efs")>0 {
  global S_1 Event free survival 
  global S_2 EFS
  global F_2 Failure
}
else if index(upper("`varlab'"),"PROGRESSION FREE")>0 | index("`varlist'","pfs")>0 {
  global S_1 Progression free survival 
  global S_2 PFS
  global F_2 Prog
}
else if index(upper("`varlab'"),"RELAPSE FREE FROM CR")>0 |"`varlist'"=="rfd" {
	if "`fail'"=="" global S_1 Relapse free from CR 
	else           	global S_1 Relapse after CR 
  global S_2 RF
  global F_2 Relapse
}
else if index(upper("`varlab'"),"WBC")>0  | index(upper("`varlist'"),"WBC")>0  local ttt WBC 
else if index(upper("`varlab'"),"PMN")>0  | index(upper("`varlist'"),"PMN")>0  local ttt PMN 
else if index(upper("`varlab'"),"ANC")>0  | index(upper("`varlist'"),"ANC")>0  local ttt ANC 
else if index(upper("`varlab'"),"HBM")>0  | index(upper("`varlist'"),"HBM")>0  local ttt HBM 
else if index(upper("`varlab'"),"PLA")>0  | index(upper("`varlist'"),"PLA")>0  local ttt Platelets 
else if index(upper("`varlab'"),"PLT")>0  | index(upper("`varlist'"),"PLT")>0  local ttt Platelets 
else {
  global S_1 `varlab' 
  global S_2 = upper("`varlist'") 
}
if "`ttt'"~="" {
	local tt2=substr("`varlab'",index("`varlab'",">"),.)
	local pm=index("`tt2'","-")
	if `pm'>1 { local tt2=substr("`tt2'",1,`pm'-1) }
	global S_1 Recovery `ttt'`tt2'
	global S_2 `ttt'
	global S_3 `ttt'`tt2'
}
end
