*! ljust.ado  WvP; 23/4/2001
*! first version 12/3/1998
*! Left-justifies string vars by adding trailing blanks after compression
program define ljust
version 6.0
local varlist "req ex min(1)"
parse "`*'"
parse "`varlist'",parse(" ")
while "`1'"~="" {
  	local type:type  `1'
  	if index("`type'","str")>0 {
  	  replace `1'=trim(`1')
  	  compress `1'
    	local type:type  `1'
    	local n=substr("`type'  ",4,.)
		  replace `1'=trim(`1')+/*
      */ substr("                                                                                                                    ",1,`n'-length(`1'))
      /* repeat in case of long string variables - 23/4/2001 */
	  	qui replace `1'= `1'+/*
      */ substr("                                                                                                                    ",1,`n'-length(`1'))
	  }
	  macro shift
}
end
