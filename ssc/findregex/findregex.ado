*! Version 1.0  07may2021   Leonardo Guizzetti
program findregex, sclass
  version 15
  syntax [varlist] , re(string) [SEnsitive]

  local cs = cond("`sensitive'"=="", 1, 0)
  
  foreach v of local varlist {
  	local ret = ustrregexm("`v'", "`re'", `cs')
    if `ret'==1 {
      local OKlist `OKlist' `v'
    }
    else if `ret'== -1 {
    	di as error "Regular expression pattern caused an error (pattern: `re')."
    	exit 198
    }
  }

  if "`OKlist'" == "" {
  	di as text "(none found)"
  }
  else {
  	di as text "{p}`OKlist'{p_end}"
  }

  sreturn local varlist "`OKlist'"
end
