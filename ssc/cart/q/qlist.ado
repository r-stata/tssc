*!qlist.ado
*!WvP
*!2/2/00
*Quiet listing: no output if condition not satisfied
* nobs and nodis are the default in this listing.
*1/2001: data are eformatted before listing (within subset to list) to produce compact lists.
*24/1/2001 descr option added
*23/11/2004 noljust opion added and made version 8.0 compatible
*2/2/2006   rjust() option added
program define qlist
version 8.0
syntax [varlist] [if] [, Obs Dis Header(string) DEscr STars BY(string) PBreak BLank noLJust RJust(varlist)]
if "`obs'"==""      local obs noobs 
if "`varlist'" =="" local varlist  _all
local linesize : set linesize
quietly count `if'
if r(N)>0 {	
	if "`stars'"~=""  local stars **** 
	if `"`header'"'==""&`"`if'"'!="" local header **** `if'
	else if `"`header'"'=="."  local header `stars' 
	else local header `stars' `header' 
  if upper(`"`header'"')!="NO" & `"`header'"'~="" 	display  _n `"`header'"' 
 
	preserve
	if `"`if'"'!=""  quie keep `if' 
	eformat `varlist' , vn val lab
  
  *20/11/2004 First remove all variables in the by varlist that contain only missing values
  if "`by'"!="" {
    local byold `by'
    local by
    foreach var of varlist `byold' {
      local type : type `var'
      if index("`type'","str")>0 qui count if trim(`var')!=""
      else                       qui count if `var'!=.
      if r(N)>0 local by `by' `var'
    }  

    local alvars: list by | varlist
    local alvars : list uniq alvars
  }
  else local alvars : list uniq varlist
  
  if "`descr'`dis'"!=""  varlst `alvars' ,nohead 


  if "`ljust'"=="" qui ljust _all
  if "`rjust'"!="" qui rjust `rjust' 
  
  if "`by'"!="" {
    local sorted: sortedby
    local sort `by' 
    if "`sorted'"!="" {
      foreach var of varlist `sorted' {
        if index(" `sort' "," `var' ")==0  local sort `sort' `var'
      }
    }  
    sort `sort'   
*    local byby byvar2 `by' :  /* modified 20/5/2005 */
    local byby by `by' :  
  }

  capture clist `varlist' in 1
  if _rc==0 {
*  	`byby' clist `varlist'  ,`obs' nodis   /* uses the old list command with less spaces between columns */
  	`byby' list `varlist'  ,clean `obs' nodis linesize(`linesize')   /* uses the old list command with less spaces between columns */
  }
  else {	
  	capture `byby' list `varlist'  ,`obs' nodis notrim  linesize(`linesize')
  	if _rc==0 {
    	`byby' list `varlist'  ,`obs' nodis notrim linesize(`linesize')
  	}  
  	else {
    	`byby' list `varlist'  ,`obs' nodis  linesize(`linesize')
  	}  
  }
	restore
	if "`blank'"~="" di ""
	if "`pbreak'"~=""  pbreak 
}

end
