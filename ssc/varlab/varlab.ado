*! varlab: save and load variable labels
*! version 1.0    05mar2002    PJoly

program define varlab
      version 7

      gettoken fcn 0 : 0
      if !("`fcn'"=="save" | "`fcn'"=="load") {
            di as err "invalid syntax, specify -save- or -load-"
            exit 198
      }

      syntax [varlist] using/ [, replace ]

      * parse filename
      gettoken name using : using, parse(".")
      gettoken dot  ext   : using, parse(".")
      if "`ext'"=="" { local filename `name'.lbl }
      else { local filename `name'.`ext' }

      tempname labels
      if ("`fcn'"=="save") {
            file open  `labels' using "`filename'", write `replace' text
            file write `labels' "beginvarlablist" _n
            foreach var of local varlist {
                  local lbl : var la `var'
                  file write `labels' "v" _col(3) `"`var'"' _n
                  file write `labels' "l" _col(3) `"`lbl'"' _n
            }
            file write `labels' "endvarlablist" _n
            file close `labels'
      }

      if ("`fcn'"=="load") {
            file open `labels' using "`filename'", read text
            IsVarlab `labels' "`filename'"
            file seek `labels' tof
            file read `labels' line
            file read `labels' line
            while `"`line'"'!="endvarlablist" {
                  gettoken v var : line
                  file read `labels' line
                  gettoken l lbl : line
                  local var = trim("`var'")
                  local lbl = trim(`"`lbl'"')
                  local varlist : subinstr local varlist "`var'" "",        /*
                                          */  all word count(local isin_vlist)
                  if `isin_vlist' {
                        local exists : var la `var'
                        if ("`replace'"!="" | `"`exists'"'=="") {
                              cap la var `var' `"`lbl'"'
                              if !(_rc==0 | _rc==111) { error _rc }
                        }
                  }
                  file read `labels' line
            }
            file close `labels'

            cap unab notfound : `varlist'
            if !_rc {
                  di as txt "labels for the following variable(s) were not" _c
                  di " found in file " as res `"`filename'"' as txt ":"
                  di as res "`notfound'"
            }
      }
end


* check integrity of _filename_
program define IsVarlab
      args labels filename

      local errmsg "`filename' not a valid -varlab- file or is corrupted"
      file read `labels' line
      if (`"`line'"'!="beginvarlablist") {
            di as err "`errmsg'"
            exit 198
      }
      file read `labels' line1
      file read `labels' line2
      while r(eof)==0 {
            gettoken tok1 : line1
            gettoken tok2 : line2
            if !(`"`tok1'"'=="v" & `"`tok2'"'=="l") {
                  di as err "`errmsg'"
                  exit 198
            }
            file read `labels' line1
            file read `labels' line2
      }
      if (`"`line1'"'!="endvarlablist") {
            di as err "`errmsg'"
            exit 198
      }
end

exit
