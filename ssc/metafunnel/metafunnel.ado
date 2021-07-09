*! Version 1.0.2, JACS, 18 August 2003
program define metafunnel
  version 8.1
  * Graphs funnel plot, with standard error on the vertical axis

  if ("`*'" == "") {
    di "Syntax is:"
    di in wh "metafunnel " in gr "{ theta { se | var } | " _c
    di in gr "exp(theta) | ll ul [cl] } [" _c
    di in wh "if " in gr "exp] [" in wh "in " in gr "range]"
    di in gr "             [ " in wh ", by(" in gr "by_var"in wh ")"  _c
    di in gr " { " in wh "v" in gr "ar | " in wh "ci" in gr " } " _c
    di in wh "nol" in gr "ines " in wh "forc" in gr "enull " _c
    di in wh "rev" in gr "erse " in wh "ef" in gr "orm"
    di in gr "             graph_options ]"

    exit
  }

  syntax varlist(numeric min=2 max=4) [if] [in], [ by(varname) ///
    Var CI SUbtitle(str) NOLines FORCenull REVerse EForm  ///
    XTitle(string) YTitle(string) XScale(string) YScale(string) ///
    MSymbol(string) * ]

  tempvar touse theta setheta etheta zz
  tempvar ll2 ul2 vl z mmm vvar w sw wl swl RRm orign 
  tempname oe 

  tokenize `varlist'
  local theta    `1'

  if "`3'" == "" {
    local setheta `2'
  }
  else {
    tempvar ll ul cl
    local ll `2'
    local ul `3'
    local cl `4'
  }

  * input error traps
  if "`ci'" != "" & "`var'" != "" {
    di _n as error "Error: options 'ci' and 'var' cannot " _c
    di as error "be specified together."
    exit
  }
  if "`ci'" == "ci" & "`ul'" != "" {
    di _n as text "Note: option 'ci' specified."
  }
  if "`ci'" == "ci" & "`ul'" == "" {
    di _n as error "Error: option 'ci' specified but varlist " _c
    di as error "has only 2 variables."
    exit
  }
  if "`ci'" != "ci" & "`var'" != "var" & "`ul'" != "" {
    di _n as text "Warning: varlist has 3 variables but option " _c
    di as text "'ci' not specified; 'ci' assumed."
    local ci "ci"
    local var ""
  }
  if "`var'" == "var" & "`ul'" != "" {
    di _n as error "Error: option 'var' specified but varlist " _c
    di as error "has more than 2 variables."
    exit
  }
  if "`var'" == "var" & "`ul'" == "" {
    di _n as text "Note: option 'var' specified."
  }
  if "`var'" != "var" & "`ul'" == "" {
    di _n as text "Note: default data input format (theta, " _c
    di as text "se_theta) assumed."
  }

  * Select data to analyze
  mark `touse' `if' `in'
  if "`ul'" == "" {
    markout `touse' `theta' `setheta'
  }
  else {
    markout `touse' `theta' `ll' `ul'
  }

  preserve
  quietly keep if `touse'
  quietly count
  if r(N)==0 {
    di as error "No observations with nonmissing values of `by'"
    exit 999
  }


  * initial calculations...
  if "`var'" == "var" {
    qui replace `setheta' = sqrt(`setheta')
  }

  if "`ci'" == "ci" {
    di _n as text "Warning: ci option assumes that ratio measures are being used"
    capture confirm variable `cl'
    if _rc~=0 {
      qui gen `zz'  = invnorm(.975)
    }
    else {
      qui replace `cl' = `cl' * 100 if `cl' < 1
      qui gen `zz' = -1 * invnorm((1- `cl' / 100) / 2 )
      qui replace `zz' = invnorm(.025) if `zz'==.
    }
    qui gen   `setheta' = ( ln(`ul') - ln(`ll')) / 2 / `zz'
    qui replace `theta' = ln(`theta')
  }

  * Graph options

  if "`xtitle'" == "" {
    local xti : variable label `theta'
    if "`xti'" == "" {
      local xti "`theta'"
    }
  }
  else if "`xtitle'" ~= "" {
    local xti "`xtitle'"
  }

  if "`ytitle'" == "" {
    local yti : variable label `setheta'
    if "`yti'" == "" {
      local yti "s.e. of `theta'"
    }
  }
  else if "`ytitle'" ~= "" {
    local yti "`ytitle'"
  }

  capture assert "`ysca'"==""
  if _rc~=0 {
    display as error "ysca option not permitted"
    exit 999
  }

  if "`yscale'"~="" {
    local chkrev=index("`yscale'","rev")
    display "chkrev: `chkrev'"
    if `chkrev'~=0 & "`reverse'"=="" {
      local ysca "`yscale'"
    }
    if `chkrev'==0 & "`reverse'"=="" {
      local ysca "`yscale' reverse"
    }
    if `chkrev'~=0 & "`reverse'"~="" {
      display "Parsing yscale: ,`yscale' "
      tokenize `yscale'
      while "`1'"~="" {
        if index("`1'","rev")==0 {
          local ysca "`ysca' `1'"
        }
        mac shift
      }
    }
    if `chkrev'==0 & "`reverse'"~="" {
      local ysca "`yscale'"
    }
  }
  if "`yscale'"=="" {
    if "`reverse'"=="" {
      local ysca "reverse"
    }
    if "`reverse'"~="" {
      local ysca "noreverse"
    }
  }

  if "`subtitle'" == "" {
    local subtitle = "Funnel plot with pseudo 95% confidence limits"
  }
  else if "`subtitle'" == "." {     /* "." means blank it out */
    local subtitle ""  ""
  }
  local subtitle "subtitle(`subtitle')"

  if "`msymbol'"=="" {
    local symopt "O T S D + X Oh Th Sh Dh o t s d x oh th sh dh p"
  }
  if "`msymbol'"~="" {
    local symopt "`msymbol'"
  }
  local msymbol "msymbol(`symopt')"

  qui {
    gen `orign'=_n

    gen     `vvar' = `setheta'^2
    gen     `w'   = 1/`vvar'
    egen    `sw'  = sum(`w') if `touse'
    gen     `wl'  = `w' * `theta'
    egen    `swl' = sum(`wl') if `touse'
    sort `orign'
    gen     `RRm' = `swl' / `sw'
    local    rxl=`RRm'[1]
    scalar  `oe'  = `RRm'
    egen    `mmm' = min(`RRm')
    replace `RRm' = `mmm' if `setheta' == 0

    if "`forcenull'"~="" {
      local rxl=0
    }

    sort `orign'
    local obs1=_N+1
    local obs2=_N+2
    local obs3=_N+3
    local obs4=_N+4
    local obs5=_N+5
    local obs6=_N+6
    set obs `obs6'
    replace `orign'=_n
    replace `theta'=`rxl' in `obs1'
    replace `theta'=`rxl' in `obs3'
    gen `ll2' = 0 in `obs1'
    gen `ul2' = 0 in `obs3'

    sort `orign'
    qui summ `setheta'
    local maxse=r(max)
    replace `theta' = `rxl'-(1.96*`maxse') in `obs2'
    replace `theta' = `rxl'+(1.96*`maxse') in `obs4'
    replace `ll2' = `maxse' in `obs2'
    replace `ul2' = `maxse' in `obs4'

    gen `vl' = 0 in `obs5'
    replace `vl' = `maxse' in `obs6'
    replace `theta' = `rxl' in `obs5'
    replace `theta' = `rxl' in `obs6'

    label var `ll2' "Lower CI"
    label var `ul2' "Lower CI"
    label var `vl' "Pooled"
    if "`forcenull'"~="" {
      label var `vl' "No effect"
   }

  }

  *  list `setheta' `ll2' `ul2' `vl' `theta' `orign'
  *  display "RRm: `rxl'"

  local funopt "yscale(`ysca') `subtitle' ytitle("`yti'") xtitle("`xti'")" 

  if "`by'"=="" {
    local yvar "`setheta'"
    local legopt "legend(off)"
  }

  if "`by'"~="" {

    qui levels `by', local(bylev)
    local lev: word count `bylev'
    if `lev'>20 {
      di as text "Note: distinct group markers available for only 19 groups"
    }
    sort `orign'
    qui drop if `by'==.&_n<`obs1'
    qui count if `by'~=.
    if r(N)==0 {
      di as error "No observations with nonmissing values of `by'"
      exit 999
    }

    forvalues b=1/`lev' {
      local bylab ""
      local bygroup: word `b' of `bylev'
      tempname bg`b'
      qui gen `bg`b''=`setheta' if `by'==`bygroup'
      local bylab: label (`by') `b'
      if "`bylab"=="" {
        label variable `bg`b'' "`by'=`b'"
      }
      if "`bylab"~="" {
        label variable `bg`b'' "`bylab'"
      }       
    }
    local yvar "`bg1'-`bg`lev''"

  } /* end by processing */

  if "`nolines'"=="nolines"&"`eform'"=="" {
*    display "clause 1"
    twoway (scatter `yvar' `theta', `legopt' `msymbol') ///
     if `touse', `funopt'  `options'
  }

  if "`nolines'"==""&"`eform'"=="" {
*    display "clause 2"
    twoway (scatter `yvar' `theta', `legopt' `msymbol') ///
     (line `ll2' `ul2' `vl' `theta', msymbol(none none none) ///
     clcolor(black black black) clpat(dash dash solid) ///
     clwidth(medium medium medium)) ///
     if `touse', `funopt' `options'
  }

  if "`eform'"~="" {
    gen `etheta'=exp(`theta')
    if "`xtitle'"=="" {
      local xti : variable label `theta'
      if "`xti'" == "" {
        local xti "exp(`theta'), log scale"
      }
      else if "`xti'" ~= "" {
        local xti "exp(`xti'), log scale"
      }
    }

    capture assert "`xsca'"==""
    if _rc~=0 {
      display as error "xsca option not permitted"
      exit 999
    }
    if "`xscale'"~="" {
      local chklog=index("`xscale'","log")
      if `chklog'==0 {
        local xsca "`xscale' log"
      }
      else if `chklog'~=0 {
        local xsca "`xscale'"
      }
    }
    else if "`xscale'"=="" {
      local xsca "log"
    }

    if "`nolines'"=="nolines" {
*      display "clause 3"

      twoway (scatter `yvar' `etheta', `legopt' `msymbol') ///
       if `touse', `funopt' xscale(`xsca') `options'
    }

    if "`nolines'"=="" {
*      display "clause 4"
      local rxl=exp(`rxl')
      twoway (scatter `yvar' `etheta', `legopt' `msymbol') ///
       (line `ll2' `ul2' `vl' `etheta', msymbol(none none none) ///
       clcolor(black black black) clpat(dash dash solid) ///
       clwidth(medium medium medium)) ///
       if `touse', `funopt' xscale(`xsca') `options'
    }
  }
end

