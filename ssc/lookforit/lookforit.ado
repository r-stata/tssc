*! lookforit Version 1.2 dan_blanchette@unc.edu 12Jul2011
*! the carolina population center, unc-ch
*  lookforit Version 1.1 dan_blanchette@unc.edu 05Mar2008
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
*  lookforit Version 1.0 dan_blanchette@unc.edu  19nov2003
*  the carolina population center, unc-ch
*  enhancement of -lookfor2- NJC 3.3.0 19nov2003 
program lookforit, rclass
	version 8 

	if `"`0'"' == "" { 
		di as err "nothing to look for" 
		exit 198 
	}
	
        local case 0
	foreach W of local 0 {
                if `"`W'"' != lower(`"`W'"') {
                  local case 1
		  local w = `"`W'"'
                }
                else { 
		  local w = lower(`"`W'"')
                }
		local looklist `"`looklist' `w'"' 
	}

	local 0 "_all"
	syntax varlist

        if `case' == 0 {
                   local lower1 "lower(" 
                   local lower2 ")" 
        }

        local fvarlist
        local vn=1
	foreach v of local varlist {
		local lbl : variable label `v'
                local touse 0
		foreach w of local looklist {
			if index(`lower1'`"`v'"'`lower2',`"`w'"') ///
			 | index(`lower1'`"`lbl'"'`lower2',`"`w'"') {
                                local touse  1
				continue, break
			}
		}
                if `touse' == 1 {
                  if `vn++' == 1 {
                    local fvarlist "`v'"
                  }
                  else {
                    local fvarlist "`fvarlist' `v'"
                  }
                }
        }
        if missing("`fvarlist'") {
          di "{res} Nothing found."
          exit
        }
        // now sort fvarlist
        quietly ds `fvarlist', alpha 
        local fvarlist "`r(varlist)'"
        local vn=0
        local list 
	foreach v of local fvarlist {
		local list "`list' `v'"
                local vn=`vn'+1
                local v15 = abbrev(`"`v'"',15)
                local typ : type `v'
                local form : format `v'
                local vlab : value label `v'
                local lab : variable label `v'
                if `vn'==1 {
                   di _col(15)"{txt}storage  display     value"
                   di "{txt}variable name   type   format      label      variable label"
                   di "{hline 60}"
                }
                di `"{stata browse `v':`v'}"' _col(17)`"{txt}`typ'"' _col(24)`"{txt}`form'"' ///
                     _col(36)`"{txt}`vlab'"'  _col(47)`"{res}`lab'"'
        }

	if "`list'" != "" {
         di "{txt}{hline 60}"
         if "`c(console)'" != "console" {
            di "{res} Click on variable name to open data browser to that variable."
         }
	 return local varlist `list'
        }
        else {
         di "{res} Nothing found."
        }

end
exit
