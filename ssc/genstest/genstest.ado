*! genstest v1.0.6 28feb2020
*! authors Zachary Flynn
*! 1.0.6: updated to work with GMM in Stata 16

cap program drop genstest
program genstest, rclass
  syntax [anything] [if] [in] [pweight/] [, null(string) trim(real 0.15)/*
*/ INSTruments(string) WMATrix(string) cluster(varname)/*
*/ winitial(string) ci(string) /*
*/ nuisS varS center DERIVative(string)*/*
*/ sb init(numlist) gmm(string) test(string)/*
*/ sb_lags(string)/*
*/ stab small igmm twostep]

  if ("`nuisS'"=="" & "`varS'"=="" & "`sb'"=="sb") {
    di in red "Note: using the nuisS and/or varS options will decrease computation time for the single-break tests."

  }
  if ("`e(cmd)'"=="gmm" & "`anything'"=="") {
    if ("`test'"!="") {
      local nnull = wordcount("`test'")

      local sexp = "`e(sexp_1)'"
      tokenize "`test'"
      local i 1
      while (`i'<=wordcount("`test'")) {
        while ( regexm("`sexp'","{``i''[:_cons]*[=]*[0-9\.]*}") ) {
          local sexp = regexr("`sexp'","{``i''[:_cons]*[=]*[0-9\.]*}","<``i''>")
        }
        local i = `i' + 1
      }
    }
    else if ("`anything'" != "") {
      local sexp = "`anything'"
      local nnull = wordcount("`null'")
    }
    else {
      local sexp = "`e(sexp_1)'"
      local nnull = wordcount("`null'")
    }

    while (regexm("`sexp'", ":_cons")) {
      local sexp = regexr("`sexp'", ":_cons", "")
    }
    local first = "e(cmdline)"
    local comma = ""
  }
  else {
    ParseEquation "zero" "`anything'"
    local nnull = wordcount("`r(names)'")

    local first = "anything"
    if ("`test'"!="" & `nnull'==0) {
      local nnull = wordcount("`test'")
      local expres = "`anything'"
      local first = "expres"
      tokenize "`test'"
      local i 1
      while (`i' <= wordcount("`test'")) {
  		  while ( regexm("`expres'","{``i''[=]*[0-9\.]*}") ) {
          local expres = regexr("`expres'","{``i''[=]*[0-9\.]*}","<``i''>")
        }
        local i = `i' + 1
      }
    }
    local comma = ","
  }

  if ("`ci'"!="") {

    ParseCi `ci'
    local alpha = `r(alpha)'
    local single = "`r(single)'"
    local allpv = "`r(allpv)'"
    local rnge = "`r(range)'"
    local points = "`r(points)'"
    local tograph = "`r(autograph)'"

    local i = 1
    tempname Sci aveSci expSci supSci qllSci
    tempname avestabSci expstabSci supstabSci qllstabSci

    mata `Sci' = J(1, `nnull'+1, .)
    if ("`sb'" == "sb") {
      mata `aveSci' = J(1, `nnull'+1, .)
      mata `expSci' = J(1, `nnull'+1, .)
      mata `supSci' = J(1, `nnull'+1, .)
    }
    mata `qllSci' = J(1, `nnull'+1, .)
    if ("`stab'" == "stab") {
      if ("`sb'" == "sb") {
        mata `avestabSci' = J(1, `nnull'+1, .)
        mata `expstabSci' = J(1, `nnull'+1, .)
        mata `supstabSci' = J(1, `nnull'+1, .)
      }
      mata `qllstabSci' = J(1, `nnull'+1, .)
    }

    if (`nnull' == 1) {
      tokenize `rnge'
      local start = `1'
      local stop = `2'
      tokenize `points'
      local stepsize = (`stop'-`start')/`1'
      local cur = `start'
      local dispci = 1
      local crits = ""
      local critsstab = ""

      while (`cur' <= `stop') {
        genstest_internal ``first'' `if' `in' `pweight' `comma' null(`cur') trim(`trim')/*
*/ inst(`instruments') wmatrix(`wmatrix') cluster(`cluster') winitial(`winitial')/*
*/ `nuisS' `varS' `center' deriv(`derivative')/*
*/ `sb' init(`init') test(`test') gmm(`sexp')/*
*/ sb_lags(`sb_lags') `allpv' critsstab(`critsstab') crits(`crits') `options' `stab' `small'/*
*/ alpha(`alpha') `igmm'

        if ("`allpv'"=="allpv") {
          mata `Sci' = `Sci' \ (`r(par)', `cur')
          if ("`sb'"=="sb") {
            mata `aveSci' = `aveSci' \ (`r(pavear)', `cur')
            mata `expSci' = `expSci' \ (`r(pexpar)', `cur')
            mata `supSci' = `supSci' \ (`r(psupar)', `cur')
          }
          mata `qllSci' = `qllSci' \ (`r(pqllar)', `cur')
          if ("`stab'"=="stab") {
            mata `qllstabSci' = `qllstabSci' \ (`r(pqllstabar)', `cur')
            if ("`sb'"=="sb") {
              mata `avestabSci' = `avestabSci' \ (`r(pavestabar)', `cur')
              mata `supstabSci' = `supstabSci' \ (`r(psupstabar)', `cur')
              mata `expstabSci' = `expstabSci' \ (`r(pexpstabar)', `cur')
            }
          }
        }
        else {
          local crits = "`r(crits)'"
          local critsstab = "`r(critsstab)'"

          mata `Sci' = `Sci' \ (`r(ar)', `cur')
          if ("`sb'"=="sb") {
            mata `aveSci' = `aveSci' \ (`r(avear)', `cur')
            mata `expSci' = `expSci' \ (`r(expar)', `cur')
            mata `supSci' = `supSci' \ (`r(supar)', `cur')
          }
          mata `qllSci' = `qllSci' \ (`r(qllar)', `cur')
          if ("`stab'"=="stab") {
            mata `qllstabSci' = `qllstabSci' \ (`r(qllstabar)', `cur')
            if ("`sb'"=="sb") {
              mata `avestabSci' = `avestabSci' \ (`r(avestabar)', `cur')
              mata `supstabSci' = `supstabSci' \ (`r(supstabar)', `cur')
              mata `expstabSci' = `expstabSci' \ (`r(expstabar)', `cur')
            }
          }

        }
        local cur = `cur' + `stepsize'
      }
    }
    else if (`nnull'==2) {

      local dispci = 0
      tokenize `rnge'
      local start1 = `1'
      local stop1 = `2'
      local start2 = `3'
      local stop2 = `4'

      tokenize `points'
      local step1 = (`stop1'-`start1')/`1' + ((`stop1'-`start1') <= 0)
      local step2 = (`stop2'-`start2')/`2' + ((`stop2'-`start2') <= 0)

      local cur1 = `start1'
      local cur2 = `start2'
      local crits = ""
      while (`cur1' <= `stop1') {
        while (`cur2' <= `stop2') {
          genstest_internal ``first'' `if' `in' `pweight' `comma' null(`cur1' `cur2') trim(`trim')/*
*/ inst(`instruments') wmatrix(`wmatrix') cluster(`cluster') winitial(`winitial')/*
*/  `nuisS' `varS' `center' deriv(`derivative')/*
*/ `sb' init(`init') test(`test') gmm(`sexp') alpha(`alpha')/*
*/ sb_lags(`sb_lags') `allpv' crits(`crits') critsstab (`critsstab') `options' `stab' `small' `igmm'
          if ("`allpv'"=="allpv") {
            mata `Sci' = `Sci' \ (`r(par)', `cur1', `cur2')
            if ("`sb'"=="sb") {
              mata `aveSci' = `aveSci' \ (`r(pavear)', `cur1', `cur2')
              mata `expSci' = `expSci' \ (`r(pexpar)', `cur1', `cur2')
              mata `supSci' = `supSci' \ (`r(psupar)', `cur1', `cur2')
            }
            mata `qllSci' = `qllSci' \ (`r(pqllar)', `cur1', `cur2')
            if ("`stab'"=="stab") {
              if ("`sb'"=="sb") {
                mata `avestabSci' = `avestabSci' \ (`r(pavestabar)', `cur1', `cur2')
                mata `expstabSci' = `expstabSci' \ (`r(pexpstabar)', `cur1', `cur2')
                mata `supstabSci' = `supstabSci' \ (`r(psupstabar)', `cur1', `cur2')
              }
              mata `qllstabSci' = `qllstabSci' \ (`r(pqllstabar)', `cur1', `cur2')
            }

          }
          else {
            local crits = "`r(crits)'"
            local critsstab = "`r(critsstab)'"
            mata `Sci' = `Sci' \ (`r(ar)', `cur1', `cur2')
            if ("`sb'"=="sb") {
              mata `aveSci' = `aveSci' \ (`r(avear)', `cur1', `cur2')
              mata `expSci' = `expSci' \ (`r(expar)', `cur1', `cur2')
              mata `supSci' = `supSci' \ (`r(supar)', `cur1', `cur2')
            }
            mata `qllSci' = `qllSci' \ (`r(qllar)', `cur1', `cur2')
            if ("`stab'"=="stab") {
              if ("`sb'"=="sb") {
                mata `avestabSci' = `avestabSci' \ (`r(avestabar)', `cur1', `cur2')
                mata `expstabSci' = `expstabSci' \ (`r(expstabar)', `cur1', `cur2')
                mata `supstabSci' = `supstabSci' \ (`r(supstabar)', `cur1', `cur2')
              }
              mata `qllstabSci' = `qllstabSci' \ (`r(qllstabar)', `cur1', `cur2')
            }
          }
          local cur2 = `cur2' + `step2'
        }
        local cur1 = `cur1' + `step1'
        local cur2 = `start2'
      }
    }
    local paramnames = "`r(names)'"

    if ("`allpv'"=="") {
      tokenize `crits'
      local Scrit = invchi2tail(r(kz)-r(nest), `alpha')
      mata `Sci' = select (`Sci', `Sci'[.,1]:<=`Scrit')
      if ("`sb'"=="sb") {
        mata `aveSci' = select (`aveSci', `aveSci'[.,1]:<=`1')
        mata `expSci' = select (`expSci', `expSci'[.,1]:<=`2')
        mata `supSci' = select (`supSci', `supSci'[.,1]:<=`3')
        mata `qllSci' = select (`qllSci', `qllSci'[.,1]:<=`4')
      }
      else {
        mata `qllSci' = select (`qllSci', `qllSci'[.,1]:<=`1')
      }
      if ("`stab'"=="stab") {
        tokenize `critsstab'
        if ("`sb'"=="sb") {
          mata `avestabSci' = select (`avestabSci', `avestabSci'[.,1]:<=`1')
          mata `expstabSci' = select (`expstabSci', `expstabSci'[.,1]:<=`2')
          mata `supstabSci' = select (`supstabSci', `supstabSci'[.,1]:<=`3')
          mata `qllstabSci' = select (`qllstabSci', `qllstabSci'[.,1]:<=`4')
        }
        else {
          mata `qllstabSci' = select (`qllstabSci', `qllstabSci'[.,1]:<=`1')
        }
      }
    }


    mata st_matrix("`Sci'", `Sci')
    if ("`sb'"=="sb") {
      mata st_matrix ("`aveSci'", `aveSci')
      mata st_matrix ("`expSci'", `expSci')
      mata st_matrix ("`supSci'", `supSci')
    }
    mata st_matrix("`qllSci'", `qllSci')

    if ("`stab'"=="stab") {
      if ("`sb'"=="sb") {
        mata st_matrix ("`avestabSci'", `avestabSci')
        mata st_matrix ("`expstabSci'", `expstabSci')
        mata st_matrix ("`supstabSci'", `supstabSci')
      }
      mata st_matrix("`qllstabSci'", `qllstabSci')
    }

    if (`nnull'==2 & "`tograph'"=="autograph") {
      cap confirm matrix `qllSci'
      if (!_rc) {
        dograph "`qllSci'" "qLL-S" "qllS" "`paramnames'" `alpha' "`allpv'"
      }

      cap confirm matrix `Sci'
      if (!_rc) {
        dograph "`Sci'" "S" "S" "`paramnames'" `alpha' "`allpv'"
      }
      if ("`sb'" == "sb") {
        cap confirm matrix `aveSci'
        if (!_rc) {
          dograph "`aveSci'" "ave-S" "aveS" "`paramnames'" `alpha' "`allpv'"
        }

        cap confirm matrix `expSci'
        if (!_rc) {
          dograph "`expSci'" "exp-S" "expS" "`paramnames'" `alpha' "`allpv'"
        }

        cap confirm matrix `supSci'
        if (!_rc) {
          dograph "`supSci'" "sup-S" "supS" "`paramnames'" `alpha' "`allpv'"
        }
      }

      if ("`stab'"=="stab") {
        cap confirm matrix `qllstabSci'
        if (!_rc) {
          dograph "`qllstabSci'" "qLL-stab-S" "qllstabS" "`paramnames'" `alpha' "`allpv'"
        }
        if ("`sb'" == "sb") {
          cap confirm matrix `avestabSci'
          if (!_rc) {
            dograph "`avestabSci'" "ave-stab-S" "avestabS" "`paramnames'" `alpha' "`allpv'"
          }

          cap confirm matrix `expstabSci'
          if (!_rc) {
            dograph "`expstabSci'" "exp-stab-S" "expstabS" "`paramnames'" `alpha' "`allpv'"
          }

          cap confirm matrix `supstabSci'
          if (!_rc) {
            dograph "`supstabSci'" "sup-stab-S" "supstabS" "`paramnames'" `alpha' "`allpv'"
          }
        }
      }

    }


    genstestgraph `Sci', alpha(`alpha') `allpv'
    local outSci = "`r(output)'"
    cap return matrix Sci = `Sci'
    if ("`sb'" == "sb") {
      genstestgraph `aveSci', alpha(`alpha') `allpv'
      local outaveSci = "`r(output)'"
      genstestgraph `expSci', alpha(`alpha') `allpv'
      local outexpSci = "`r(output)'"
      genstestgraph `supSci', alpha(`alpha') `allpv'
      local outsupSci = "`r(output)'"
      cap return matrix aveSci = `aveSci'
      cap return matrix expSci = `expSci'
      cap return matrix supSci = `supSci'
    }
    genstestgraph `qllSci', alpha(`alpha') `allpv'
    local outqllSci = "`r(output)'"
    cap return matrix qllSci = `qllSci'
    if ("`stab'"=="stab") {
      genstestgraph `qllstabSci', alpha(`alpha') `allpv'
      cap return matrix qllstabSci = `qllstabSci'
      local outqllstabSci = "`r(output)'"
      if ("`sb'"=="sb") {
        genstestgraph `avestabSci', alpha(`alpha') `allpv'
        cap return matrix avestabSci = `avestabSci'
        local outavestabSci = "`r(output)'"

        genstestgraph `expstabSci', alpha(`alpha') `allpv'
        cap return matrix expstabSci = `expstabSci'
        local outexpstabSci = "`r(output)'"

        genstestgraph `supstabSci', alpha(`alpha') `allpv'
        cap return matrix supstabSci = `supstabSci'
        local outsupstabSci = "`r(output)'"
      }
    }

  }
  else {
    local dispci = 0
  }

  genstest_internal ``first'' `if' `in' `pweight' `comma' null(`null') trim(`trim')/*
*/ inst(`instruments') wmatrix(`wmatrix') cluster(`cluster') winitial(`winitial')/*
*/ `nuisS' `varS' `center' deriv(`derivative')/*
*/ `sb' init(`init') test(`test') gmm(`sexp')/*
*/ sb_lags(`sb_lags') alpha(`alpha') allpv `options' `stab' `small' `igmm'

  local nest = r(nest)
  local kz = r(kz)

  local pS = `r(par)'
  if ("`sb'"=="sb") {
    local paveS = `r(pavear)'
    local pexpS = `r(pexpar)'
    local psupS = `r(psupar)'
  }
  local pqllS = `r(pqllar)'

  local st1 = `r(ar)'
  if ("`sb'"=="sb") {
    local st2 = `r(avear)'
    local st3 = `r(expar)'
    local st4 = `r(supar)'
  }
  local st5 = `r(qllar)'
  local names = r(names)
  local N = r(N)

  return scalar nest = `nest'
  return scalar kz = `kz'
  return scalar S = `st1'
  if ("`sb'"=="sb") {
    return scalar aveS = `st2'
    return scalar expS = `st3'
    return scalar supS = `st4'
  }

  return scalar qllS = `st5'
  return scalar N = `N'
  if ("`stab'" == "stab") {
    local pqllstabS = `r(pqllstabar)'
    local qllstabS = `r(qllstabar)'
    return scalar pqllstabS = `pqllstabS'
    return scalar qllstabS = `qllstabS'
    if ("`sb'" == "sb") {
      local pavestabS = `r(pavestabar)'
      local avestabS = `r(avestabar)'
      return scalar pavestabS = `pavestabS'
      return scalar avestabS = `avestabS'

      local pexpstabS = `r(pexpstabar)'
      local expstabS = `r(expstabar)'
      return scalar pexpstabS = `pexpstabS'
      return scalar expstabS = `expstabS'

      local psupstabS = `r(psupstabar)'
      local supstabS = `r(supstabar)'
      return scalar psupstabS = `psupstabS'
      return scalar supstabS = `supstabS'
    }
  }


  local null = "`r(null)'"
  local linelength = 15
  local ll2 = 11
  local ll3 = 8
  local ll4 = 20
  if (`dispci'==1) {
    local mkdiv = `"di as txt "{hline `linelength'}{c +}{hline `ll2'}{c +}{hline `ll3'}{c +}{hline `ll4'}""'
    local mktop = `"di as txt "{hline `linelength'}{c TT}{hline `ll2'}{c TT}{hline `ll3'}{c TT}{hline `ll4'}""'
    local mktitle = `"di as txt "{lalign 15:Test}{c |}{center 11:Statistic}{c |}{center 7:P-value }{c |} CI (alpha=`alpha')""'
    local mkbot = `"di as txt "{hline `linelength'}{c BT}{hline `ll2'}{c BT}{hline `ll3'}{c BT}{hline `ll4'}""'
  }
  else {
    local mktop = `"di as txt "{hline `linelength'}{c TT}{hline `ll2'}{c TT}{hline `ll3'}""'
    local mktitle = `"di as txt "{lalign 15:Test}{c |}{center 11:Statistic}{c |}{center 7:P-value }""'
    local mkdiv = `"di as txt "{hline `linelength'}{c +}{hline `ll2'}{c +}{hline `ll3'}""'
    local mkbot = `"di as txt "{hline `linelength'}{c BT}{hline `ll2'}{c BT}{hline `ll3'}""'
  }
  `mktop'
  `mktitle'
  `mkdiv'
  di as txt "{lalign 15:S}{c |}" _continue
  di "{txt} " %-9.6f `st1' " {c |}" _continue
  return scalar pS = `pS'
  di "{txt} " %-4.3f `pS' _continue
  if (`dispci'==1) {
    di "  {c |} `outSci'"
  }
  else {
    di
  }
  di as txt "{lalign 15:qLL-S}{c |}" _continue
  di " " %-9.6f `st5' " {c |}" _continue

  return scalar pqllS = `pqllS'
  di " " %-4.3f `pqllS' _continue
  if (`dispci'==1) {
    di "  {c |} `outqllSci'"
  }
  else {
    di
  }

  if ("`sb'"=="sb") {
    di as txt "{lalign 15:ave-S}{c |}" _continue
    di "{txt} " %-9.6f `st2' " {c |}"  _continue
    return scalar paveS = `paveS'
    di "{txt} " %-4.3f `paveS' _continue
    if (`dispci'==1) {
      di "  {c |} `outaveSci'"
    }
    else {
      di
    }
    di as txt "{lalign 15:exp-S}{c |}" _continue
    di "{txt} " %-9.6f `st3' " {c |}" _continue
    return scalar pexpS = `pexpS'
    di "{txt} " %-4.3f `pexpS' _continue
    if (`dispci'==1) {
      di "  {c |} `outexpSci'"
    }
    else {
      di
    }
    di as txt "{lalign 15:sup-S}{c |}" _continue
    di "{txt} " %-9.6f `st4' " {c |}" _continue
    return scalar psupS = `psupS'
    di "{txt} " %-4.3f `psupS'  _continue
    if (`dispci'==1) {
      di "  {c |} `outsupSci'"
    }
    else {
      di
    }
  }
  if ("`stab'" == "stab") {

    di as txt "{lalign 15:qLL-stab-S}{c |}" _continue
    di " " %-9.6f `qllstabS' " {c |}" _continue

    di " " %-4.3f `pqllstabS' _continue
    if (`dispci'==1) {
      di "  {c |} `outqllstabSci'"
    }
    else {
      di
    }

    if ("`sb'"=="sb") {
      di as txt "{lalign 15:ave-stab-S}{c |}" _continue
      di " " %-9.6f `avestabS' " {c |}" _continue

      di " " %-4.3f `pavestabS' _continue
      if (`dispci'==1) {
        di "  {c |} `outavestabSci'"
      }
      else {
        di
      }

      di as txt "{lalign 15:exp-stab-S}{c |}" _continue
      di " " %-9.6f `expstabS' " {c |}" _continue

      di " " %-4.3f `pexpstabS' _continue
      if (`dispci'==1) {
        di "  {c |} `outexpstabSci'"
      }
      else {
        di
      }

      di as txt "{lalign 15:sup-stab-S}{c |}" _continue
      di " " %-9.6f `supstabS' " {c |}" _continue

      di " " %-4.3f `psupstabS' _continue
      if (`dispci'==1) {
        di "  {c |} `outsupstabSci'"
      }
      else {
        di
      }
    }

  }
  `mkbot'
  if ("`names'"!="") {
    di "{res}Tested null hypothesis vector: <`names'> = <" _continue
    tokenize "`null'"
    local i 1
    while (`i' <= wordcount("`names'")) {
      if ("`null'" == "zero") {
        di " 0.000" _continue
      }
      else {
        di " " %-7.3f ``i'' _continue
      }
      local i = `i' + 1
    }
  }
  di ">"
  di "{res}Number of Instruments - Included Instruments: `kz' - `nest'"
  di "{res}Number of Observations: `N'"


end

cap program drop dograph
program dograph
  args ciname title name params alpha allpv

  tempname var1 var2 tmp

  if ("`allpv'"=="allpv") {
    mata `tmp' = cishell (select (`ciname', `ciname'[.,1] :>= `alpha'))
  }
  else {
    mata `tmp' = cishell(`ciname')
  }
  mata st_matrix ("`var1'", `tmp'[.,1])
  mata st_matrix ("`var2'", `tmp'[.,2])

  qui svmat `var1'
  qui svmat `var2'
  qui sum `var2'
  local min2 = r(min) - r(sd)
  local max2 = r(max) + r(sd)
  qui sum `var1'
  local var1N = r(N)
  local min1 = r(min) - r(sd)
  local max1 = r(max) + r(sd)
  tokenize `params'
  twoway (line `var2' `var1' if mod(_n, 2)==0, lcolor(black)) (line `var2' `var1' if mod(_n,2)==1, lcolor(black)) /*
*/ (line `var2' `var1' if _n <= 2, lcolor(black)) (line `var2' `var1' if _n >= `var1N'-1, lcolor(black)), /*
*/ name("`name'", replace) xscale(range(`min1' `max1')) yscale(range(`min2' `max2')) title("`title'") /*
*/ xtitle("`1'") ytitle("`2'") legend(off)
end

cap program drop ParseCi
program ParseCi, rclass
  syntax anything [, alpha(real 0.05) points(numlist) single allpv AUtograph ]
  return local alpha = `alpha'
  return local autograph = "`autograph'"

  local i 1
  local rpoints = ""
  if (wordcount("`points'")>2) {
    noi di "Confidence Interval only supports up to two parameters at this time."
  }
  else if (wordcount("`points'")==2) {
    tokenize "`points'"
    local rpoints = "`1' `2'"
    local i = `i' + 1
  }
  else {
    local rpoints = "`points'"
  }
  return local points = "`rpoints'"
  if (wordcount("`anything'")>4) {
    noi di "Confidence Interval only supports up to two parameters at this time."
  }
  else if (wordcount("`anything'")==4) {
    tokenize "`anything'"
    local rrange = "`1' `2' `3' `4'"
  }
  else if (wordcount("`anything'")==2) {
    tokenize "`anything'"
    local rrange = "`1' `2'"
  }
  else {
    noi di "Confidence Interval Range incorrectly specified."
  }

  return local allpv = "`allpv'"
  return local single = "`single'"
  return local range = "`rrange'"
end

cap program drop genstestgraph
program genstestgraph, rclass
  syntax name(name=ci) [, alpha(real 0.05)* allpv]
  tempname res
  if ("`allpv'"=="allpv") {
    mata `res' = genstest_display (`ci', `alpha', 1)
  }
  else {
    mata `res' = genstest_display (`ci', `alpha', 0)
  }

  mata st_local ("tmp", `res')
  return local output = "`tmp'"
end


capture program drop genstest_internal
program genstest_internal, rclass
  syntax [anything] [if] [in] [pweight/] [, null(string) trim(real 0.15)/*
*/ INSTruments(string) WMATrix(string) cluster(varname)/*
*/ alpha(real 0.05)  winitial(string) ci(string) /*
*/ nuisS varS center DERIVative(string)*/*
*/ sb init(numlist) /*
*/ gmm(string) test(string) /*
*/ sb_lags(string) allpv crits(numlist) critsstab(numlist) stab small igmm twostep]

  if ("`sb'"=="sb") {
    local sb = ""
  }
  else {
    local sb = "sb"
  }

  local yes = 1
  local no = 0

  local tau = `trim'
  local cbar = 10

  if ("`null'"=="last") {
    local sexp = "`gmm'"
    ParseEquation "zero" "`sexp'"
    local names = "`r(names)'"
    tempname b nummat
    mat `b' = e(b)
    tokenize "`names'"
    local nn = wordcount("`names'")
    local i = 1
    local null = ""
    while (`i' <= `nn') {
      mat `nummat' = `b'[1,"``i'':_cons"]
      local num = `nummat'[1,1]
      local null = "`null' `num'"
      local i = `i' + 1
    }
  }

  marksample touse
  tempvar wvar

  if ("`weight'"!="") {
    qui gen `wvar' = `exp'
    if ("`weight'" == "fweight") {
      local wtexp = `"[`weight'=`exp']"'
    }
    else if ("`weight'" == "pweight") {
      local wtexp = `"[aweight=`exp']"'
    }
    else {
      local wtexp = ""
    }
    qui sum `wvar' if `touse' `wtexp', meanonly
    if ("`weight'"=="fweight") {
      local wf = 1
    }
    else {
      local wf = r(N)/r(sum_w)
    }
  }
  else {
    qui gen `wvar' = 1
    local wf = 1
  }

  qui replace `wvar' = `wf'*`wvar'

  if ("`null'"=="") {
    local null = "zero"
  }
  tempname spec
  mata `spec' = genstestSpec()
  mata `spec'.center = `no'
  if ("`center'"=="center") {
    mata `spec'.center = `yes'
  }
  mata `spec'.sb_center = `spec'.center

  /* Set Estimation Type */
  if ("`igmm'"=="igmm") {
    mata `spec'.twostep = `no'
    mata `spec'.sb_twostep = `no'
  }
  else {
    mata `spec'.twostep = `yes'
    mata `spec'.sb_twostep = `yes'
  }

  /* Set initial weighting matrix */
  if ("`winitial'" == "identity") {
    mata `spec'.identity =`yes'
  }
  else {
    mata `spec'.identity = `no'
  }

  mata `spec'.sb_identity = `spec'.identity

  /* Parse Expression */
  if ("`gmm'" == "") {
    local expression = "`anything'"
    gl GENSTEST_GMM_POST = 0
  }
  else {
    local expression = "`gmm'"
    gl GENSTEST_GMM_POST = 1
  }

  ParseEquation "`null'" "`expression'"
  local equation = "`r(equation)'"
  local nest = `r(nest)'
  local names = "`r(names)'"
  local est_names = "`r(est_names)'"
  local orignull = "`null'"
  tempname eq
  local i 1
  if ("`init'"!="") {
    tokenize "`init'"
  }
  while (`i' <= `nest') {
    if ("`init'"!="") {
      scalar GENSTEST_EST`i' = ``i''
    }
    else {
      scalar GENSTEST_EST`i' = 0
    }
    local i = `i' + 1
  }
  qui gen `eq' = `equation' if `touse'
  markout `touse' `eq'
  mata `spec'.nest = `nest'
  mata `spec'.hasderiv = `no'
  if ("`derivative'"!="") {
    ParseDeriv `nest' "`derivative'" "`options'" "`r(est_names)'" "`null'" "`names'"
    mata `spec'.hasderiv = `yes'
    local i 1
    while (`i' <= `nest') {
      local deriv`i' = "`r(deriv`i')'"
      local i = `i' + 1
    }
  }
  else {
    mata `spec'.hasderiv = `no'
  }

  if ("`init'"!="" & `nest'==wordcount("`init'")) {
    tokenize "`init'"
    local i 2
    mata `spec'.init = `1'
    while (`i'<=`nest') {
      mata `spec'.init = `spec'.init, ``i''
      local i = `i' + 1
    }
  }
  else {
    mata `spec'.init = J(1,`nest',0)
  }

  ********************Parse wmatrix options***********************************

  tokenize "`wmatrix'"
  ParseWMatrix `1', `2' lags(`3') sb_lags(`sb_lags')
  local wmtype = `r(wmtype)'
  mata `spec'.wmtype = `wmtype'

  local hc 1
  local hac 2
  local clst 3
  if (`wmtype'==`hc') {
    mata `spec'.adjf = `r(adjf)'
  }
  else if (`wmtype'==`hac') {
    mata `spec'.l_opt = `r(l_opt)'
    mata `spec'.l_auto = `r(l_auto)'
    mata `spec'.l_nlags = `r(l_nlags)'
    mata `spec'.sbl_opt = `r(sbl_opt)'
    mata `spec'.sbl_auto = `r(sbl_auto)'
    mata `spec'.kernel = `r(k_type)'
  }
  else if (`wmtype' == `clst') {
    local cluster = "`r(cluster)'"
  }
  if ("`small'"=="small") {
    mata `spec'.small = 1
  }
  else {
    mata `spec'.small = 0
  }

  cap confirm number `tau'
  if (_rc) {
    noi di in red "Tau must be a number."
    exit
  }
  else {
    local k 1
    while (`k'<=4) {
      local j = `k'*.05
      if (`tau'==`j') {
        continue, break
      }
      local k = `k' + 1
    }
    if (`k'==5) {
      noi di in red "Tau must be 0.05, 0.10, 0.15, or 0.20."
      exit
    }
  }


  cap confirm existence "`instruments'"
  if (_rc) {
    cap confirm existence `e(inst_1)'
    if (!_rc) {
      tempvar cons
      qui gen `cons' = 1
      local inst = "`e(inst_1)'"
      local inst = regexr("`instruments'", "_cons", "`cons'")
    }
    else {
      cap confirm variable `e(insts)'
      if (!_rc) {
        local inst = "`e(insts)'"
      }
      else {
        noi di in red "There must be at least one instrument."
        exit
      }
    }
  }

  local nest = `nest'
  tempvar cons
  ParseInst `instruments'
  local instruments = "`r(inst)'"
  local constant = "`r(constant)'"
  if ("`constant'" == "constant") {
    qui gen `cons' = 1
    local instruments = "`r(inst)' `cons'"
  }

  local kz : word count `instruments'

  tokenize "`instruments'"
  local instruments = ""
  local i 1

  while (`i'<=`kz') {
    tempvar z`i'
    qui gen `z`i'' = `wvar'*``i'' if `touse'
    local instruments = "`instruments' `z`i''"
    local i = `i' + 1
    markout `touse' `z`i''
  }

  tempname z
  mata `z' = st_data(.,"`instruments'",0)

  ********************Set Up Clusters (if applicable)************************

  cap confirm variable `cluster'
  tempname clst cl
  tempname clustvar
  if (!_rc) {
    qui gen `clustvar' = `cluster' if `touse'
    mata `clst' = st_data(.,"`clustvar'", 0)
    mata `cl' = gencluster(`clst')
    mata `spec'.cluster = `cl'
    mata `spec'.sb_clst = 0 // We do full-sample AR first
    mata `spec'.wmtype = 3
  }
  else {
    if ("`cluster'"!="") {
      noi di "Cluster variable does not exist."
      exit
    }
    else {
      mata `cl' = 0
    }
  }

**************S Computation************

  tempname gam m_touse phi ar y
  tempname large

  mata `spec'.fs_wmatrix = 0
  mata `spec'.instr = `z'

  if (`nest' > 0) {
    mata `m_touse' = J(rows(`z'),1,1)
    mata `gam' = `spec'.matgmm(`m_touse')
    mata `y' = `spec'.ufunc(`gam')
    mata `phi' = invsym(`spec'.wm1)

  }
  else {
    mata `y' = `spec'.ufunc(0)
    mata `gam' = 0
    mata `phi' = `spec'.PHI(`y', `spec'.instr)
    mata `spec'.wm1 = invsym (`phi')
  }

  tempname xx dd

  mata `xx' = cross (`z',`z')
  mata `dd' = `spec'.coeff(`y',`spec'.instr)
  mata `ar' = `dd''*(1/rows(`z'))*`xx'*`spec'.wm1*`xx'*`dd'

  if ("`nuisS'"=="nuisS") {
    mata `spec'.gam = `gam'
    mata `spec'.nuisS = `yes'
  }
  else {
    mata `spec'.gam = 0
    mata `spec'.nuisS = `no'
  }
  if ("`varS'" == "varS") {
    mata `spec'.fs_wmatrix = `spec'.wm1
    mata `spec'.varS = `yes'
  }
  else {
    mata `spec'.fs_wmatrix = 0
    mata `spec'.varS = `no'
  }
  mata `spec'.fs_gam = `gam'



  **************Single-Break Tests*******************
  if ("`sb'"=="") {
    tempname genar
    mata `genar' = `spec'.wmtype < 3 ?`spec'.arsinglebreak(`tau') : `spec'.clarsinglebreak(`z',`tau')

  }
  ************QLL Tests*************************
  tempname qll qllar pv1 pv pvstab1 pvstab
  mata `qll' = `spec'.qllstab(`y',`z',`phi')
  mata `qllar' = (`cbar'/(1+`cbar'))*(`ar') + `qll'
  if ("`allpv'"=="allpv") {
    if ("`sb'"=="") {
      mata `pv1' = pvalue (`genar' \ `qllar', `tau', `nest', `kz', 1)'
    }
    else {
      mata `pv1' = pvalue (`qllar', `tau', `nest', `kz', 0)'
    }
    vectonum `pv1'
    local pv = "`r(num)'"
  }
  tempname arvalue
  mata st_numscalar("`arvalue'",`ar')


  if ("`stab'" == "stab" & "`allpv'"=="allpv") {
    if ("`sb'"=="") {
      mata `pvstab1' = pvalue ((`genar' \ `qllar') - J( 4, 1, `ar'), `tau', `kz', `kz', 1)'
    }
    else {
      mata `pvstab1' = pvalue (`qllar' - J(1, 1, `ar'), `tau', `kz', `kz', 0)'
    }
    vectonum `pvstab1'
    local pvstab = "`r(num)'"
  }


  *************Return Values of Interest*************************
  tempname avear supar expar qllarstat

  if ("`sb'"=="") {
    mata st_numscalar("`avear'",`genar'[1,1])
    mata st_numscalar("`expar'",`genar'[2,1])
    mata st_numscalar("`supar'", `genar'[3,1])
  }
  mata st_numscalar("`qllarstat'",`qllar'[1,1])
  if ("`sb'" == "") {
    return local avear = `avear'
    return local supar = `supar'
    return local expar = `expar'
  }
  return local qllar = `qllarstat'
  if ("`stab'"=="stab") {
    return local qllstabar = `qllarstat' - `arvalue'
    if ("`sb'" == "") {
      return local avestabar = `avear' - `arvalue'
      return local supstabar = `supar' - `arvalue'
      return local expstabar = `expar' - `arvalue'
    }
  }
  return scalar kz = `kz'
  return scalar nest = `nest'
  mata st_numscalar ("r(N)", rows(`spec'.instr))
  return local null = "`null'"

  return scalar ar = `arvalue'
  if ("`allpv'"=="allpv") {
    local arpval = chi2tail(`kz'-`nest',`arvalue')
    return local par = `arpval'
  }
  return local names = "`names'"
  if ("`allpv'"=="allpv") {
    tokenize `pv'
    if ("`sb'"=="") {
      return local pavear = `1'
      return local pexpar = `2'
      return local psupar = `3'
    }
    if ("`sb'"=="") {
      local qllpv = `4'
    }
    else {
      local qllpv = `1'
    }
    return local pqllar = `qllpv'
    if ("`stab'"=="stab") {
      tokenize `pvstab'
      if ("`sb'"=="") {
        return local pavestabar = `1'
        return local pexpstabar = `2'
        return local psupstabar = `3'
        local qllpv = `4'
      }
      else {
        local qllpv = `1'
      }

      return local pqllstabar = `qllpv'
    }
  }
  tempname N
  mata st_numscalar("`N'",rows(`z'))
  return scalar N = `N'
  tempname cv cvstab
  if ("`crits'"=="" & "`allpv'"=="") {
    if ("`sb'"=="") {
      mata `cv' = chkstat(`kz', `nest', `tau', `alpha', 1)'
      if ("`stab'"=="stab") {
        mata `cvstab' = chkstat(`kz', `kz', `tau', `alpha', 1)'
      }
    }
    else {
      mata `cv' = chkstat(`kz', `nest', `tau', `alpha', 0)'
      if ("`stab'"=="stab") {
        mata `cvstab' = chkstat(`kz', `kz', `tau', `alpha', 0)'

      }
    }
    vectonum `cv'
    return local crits = "`r(num)'"
    if ("`stab'"=="stab") {
      vectonum `cvstab'
      return local critsstab = "`r(num)'"
    }
  }
  else {
    return local crits = "`crits'"
    return local critsstab = "`critsstab'"
  }

  local i 1
  while (`i'<=`nest') {
    scalar drop GENSTEST_EST`i'
    local i = `i' + 1
  }
  mata mata drop GENSTEST_*
  scalar drop GENSTEST_REALLY_TEMP
end

cap program drop vectonum
program vectonum, rclass

****Convert Mata vector to Stata numlist*****

  args vec
  local result = ""
  tempname N z
  mata st_numscalar("`N'",cols(`vec'))
  local i 1
  while (`i'<=`N') {
    mata st_numscalar("`z'", `vec'[1,`i'])
    local result = "`result' " + string(`z')
    local i = `i' + 1
  }

  return local num = "`result'"
end

cap program drop ParseEquation
program ParseEquation, rclass

  **** Parse equations into useable form ****

  args null expression
  if ("`null'"!="zero") {
    tokenize "`null'"
    local length = wordcount("`null'")
  }

  local equation = "`expression'"
  local names = ""
  local i 1
  while (1) {
    local pos1 = strpos("`equation'","<")
    if (`pos1' == 0) {
      continue, break
    }
    local substring = substr("`equation'",`pos1',.)
    local pos2 = strpos("`substring'",">")
    local name`i' = substr("`substring'",2,`pos2'-2)
    while(regexm("`equation'","<`name`i''>") == 1) {
      if ("`null'"!="zero") {
        local equation = regexr("`equation'","<`name`i''>","``i''")
      }
      else {
        local equation = regexr("`equation'","<`name`i''>","0")
      }
    }
    local names = "`names' `name`i''"
    local i = `i' + 1
  }

  local i 1

  local est_names = ""
  while (1) {
    local pos1 = strpos("`equation'","{")
    local substring = substr("`equation'",`pos1',.)
    local pos2 = strpos("`substring'","}")
    if (`pos1' == 0) {
      continue, break
    }
    local est_name`i' = substr("`substring'",2,`pos2'-2)
    while (regexm("`equation'","{`est_name`i''}") == 1) {
      local equation = regexr("`equation'","{`est_name`i''}", "GENSTEST_EST`i'")
    }
    local est_names = "`est_names' `est_name`i''"
    local i = `i' + 1
  }
  return local nest = `i' - 1
  return local est_names = "`est_names'"
  return local names = "`names'"
  return local equation = "`equation'"
end

cap program drop ParseDerivHelper
program ParseDerivHelper, rclass
  syntax [anything], DERIVative(string)* est_names(string) [null_names(string)]
  tokenize "`est_names'"
  local i 1
  local match 0
  while (`i' <= wordcount("`est_names'")) {
    if (regexm("`derivative'", "/``i''")) {
      local match 1
      continue, break
    }
    local i = `i' + 1
  }
  if ($GENSTEST_GMM_POST == 1) {
    local i 1
    tokenize "`null_names'"
    while (`i' <= wordcount("`null_names'")) {
      while (regexm("`derivative'","{``i''}")) {
        local derivative = regexr("`derivative'","{``i''}","<``i''>")
      }
      local i = `i' + 1
    }
  }

  tokenize `est_names'
  local i = 1
  while (`i' <= wordcount("`est_names'")) {
    while (regexm("`derivative'", "{``i''}")) {
      local derivative = regexr("`derivative'", "{``i''}", "GENSTEST_EST`i'")
    }
    local i = `i' + 1
  }
  if (`match'!=0) {
    return local deriv = "`derivative'"
  }
  else {
    return local deriv = ""
  }
  return local oderivs = "`options'"
end

cap program drop ParseDeriv
program ParseDeriv, rclass
  args nest strwderiv1 derivs names null null_names
  tempname nderiv pos_st pos_end
  mata `nderiv' = "`derivs'"
  ParseDerivHelper, derivative(`strwderiv1') `derivs' est_names("`names'") null_names("`null_names'")
  tempname rwderiv1
  if ("`r(deriv)'"!= "") {
    mata `rwderiv1' = "`r(deriv)'"
    local i = 2
  }
  else {
    local i = 1
  }

  while (`i'<=`nest') {
    cap ParseDerivHelper, `r(oderivs)' est_names("`names'") null_names("`null_names'")
    if (!_rc) {
      if ("`r(deriv)'"!="") {
        tempname rwderiv`i'
        mata `rwderiv`i'' = "`r(deriv)'"
      }
    }
    if ("`r(deriv)'"!="") {
      local i = `i' + 1
    }
  }

  local i 1
  local j 1
  tokenize "`names'"
  while (`i' <= `nest') {
    tempname deriv`i'
    local cur_name = "``i''"
    while (`j' <= `nest') {
      tempname iscorr eqpos
      mata `iscorr' = strpos(`rwderiv`j'',"/`cur_name'")
      mata st_local("found",strofreal(`iscorr'))
      if (`found'!=0) {
        mata `eqpos' = strpos(`rwderiv`j'', "=")
        mata `deriv`i'' = substr(`rwderiv`j'',`eqpos'+1,.)
        continue, break
      }
      local j = `j' + 1
    }
    local j 1
    local i = `i' + 1
  }
  local i 1
  local j 1
  tokenize "`names'"
  while (`i' <= `nest') {
    mata st_local("stderiv`i'",`deriv`i'')
    ParseEquation "`null'" "`stderiv`i''"
    return local deriv`i' = "`r(equation)'"
    local i = `i' + 1
  }
end

cap program drop ParseInst
program ParseInst, rclass
  syntax anything [, noCONStant]
  if ("`constant'" == "") {
    return local constant = "constant"
  }
  else {
    return local constant = "nc"
  }
  unab inst : `anything', name (inst())
  return local inst = "`inst'"
end


cap program drop ParseWMatrix
program ParseWMatrix, rclass
  syntax [anything(name=wmatrix)] [, NWest BArtlett ANDerson GAllant PARzen /*
*/ quadraticspectral qs lags(string) sb_lags(string) Andrews*]

  local unadj 0
  local hc 1
  local hac 2
  local clst 3

  local yes 1
  local no 0

  if ("`quadraticspectral'"=="") {
    local quadraticspectral = "`qs'"
  }

  if ("`wmatrix'"=="" | "`wmatrix'"=="robust") {
    local wmtype = `hc'
    local adjf = 1
  }
  else if ("`wmatrix'"=="cluster") {
    local cluster = "`options'"
    local wmtype = `clst'
  }
  else if ("`wmatrix'"=="unadjusted") {
    local wmtype = `unadj'
  }
  else if ("`wmatrix'"=="hac") {
    local wmtype = `hac'
  }
  else if (strmatch("`wmatrix'","hc?")) {
    local wmtype = `hc'
    local adjf = substr("`wmatrix'",3,3)
  }
  if (`wmtype'==`hac') {
    if ("`nwest'"!="" | "`bartlett'"!="") {
      local k_type = 0
    }
    else if ("`anderson'"!="" | "`quadraticspectral'"!="" | "`andrews'"!="") {
      local k_type = 1
    }
    else if ("`gallant'"!="" | "`parzen'"!="") {
      local k_type = 2
    }

    if ("`lags'"=="" | "`lags'"=="auto" | "`lags'"=="automatic") {
      local l_auto = `yes'
      local l_opt = `no'
      local l_nlags = `no'
    }
    else if ("`lags'"=="opt" | "`lags'"=="optimal") {
      local l_opt = `yes'
      local l_auto = `no'
      local l_nlags = `no'
    }
    else {
      local l_nlags = `lags'
      local l_opt = `no'
      local l_auto = `no'
    }

    if ("`sb_lags'" == "") {
      if (`l_nlags' == `yes') {
        local sbl_auto = `yes'
        local sbl_opt = `no'
        local sbl_nlags = `no'
      }
      else {
        local sbl_nlags = `no'
        local sbl_opt = `l_opt'
        local sbl_auto = `l_auto'
      }
    }
    else {
      if ("`sb_lags'"=="" | "`sb_lags'"=="auto" | "`sb_lags'"=="automatic") {
        local sbl_auto = `yes'
        local sbl_opt = `no'
      }
      else if ("`sb_lags'"=="opt" | "`sb_lags'"=="optimal") {
        local sbl_opt = `yes'
        local sbl_auto = `no'
      }
      else {
        local sbl_opt = `no'
        local sbl_auto = `no'
      }
    }
  }

  return local wmtype = `wmtype'
  if (`wmtype' == `hac') {
    return local l_opt = `l_opt'
    return local l_auto = `l_auto'
    return local l_nlags = `l_nlags'
    return local sbl_opt = `sbl_opt'
    return local sbl_auto = `sbl_auto'
    return local k_type = `k_type'
  }
  else if (`wmtype' == `hc') {
    return local adjf = `adjf'
  }
  else if (`wmtype' == `clst') {
    return local cluster = "`cluster'"
  }
end


mata:

  string scalar genstest_display (real matrix ci, real scalar alpha,
    real scalar allpv) {

    if (cols (ci) == 3) {
      return ("")
    }

    if (rows (ci) == 0) {
      return ("Rejected Grid")
    }

    if (allpv) {
      acc = select (ci, ci[.,1] :>= alpha)
      if (rows (acc) <= 1) {
        return ("Rejected Grid")
      }
    }
    else {
      acc = ci
    }

    real scalar c0, c1
    c0 = round (min (acc[.,2]), 0.001)
    c1 = round (max (acc[.,2]), 0.001)

    r = "[" + strofreal(c0) + ", " + strofreal(c1) + "]"
    return (r)
  }


  real matrix cishell (real matrix ci) {

    uni = uniqrows (ci[.,2])
    out = J(1, 2, .)
    for (i=1; i<=rows(uni); i++) {
      cur = select (ci, ci[.,2] :== uni[i, 1])
      min1 = min (cur[.,3])
      max1 = max (cur[.,3])
      out = out \ (uni[i], min1)
      out = out \ (uni[i], max1)
    }

    out = out[2..rows(out),.]
    return(out)
  }



  real matrix pvalue (real matrix value, real scalar tau,
    real scalar kx, real scalar kz, real scalar sb) {

    fh = _fopen (st_strscalar ("c(sysdir_plus)") + "crit_values.matrix", "r")
    if (fh < 0) {
      fh = fopen("crit_values.matrix", "r")
    }
    
    rn = kz*(kz+1)*0.5 + kz - kx + 1
    stat_cur = sb ? 4 : 1
    pval = J(1,1,.)

    cv_cur = fgetmatrix (fh)
    row_cur = cv_cur[rn, 2..cols(cv_cur)]
    vec_cur = select (row_cur, row_cur:>value[stat_cur,1])
    pval = pval \ cols(vec_cur)/1000
    stat_cur = 1

    if (sb==1) {
      k = ceil(tau / 0.05 - 1)
      for (j=1; j<=(3*k); j++) {
        cv_cur = fgetmatrix (fh)
      }

      cv_cur = fgetmatrix (fh)
      row_cur = cv_cur[rn, 2..cols(cv_cur)]
      vec_cur = select (row_cur, row_cur:>value[stat_cur,1])
      stat_cur = stat_cur + 1
      pval = pval \ cols(vec_cur)/1000

      cv_cur = fgetmatrix (fh)
      row_cur = cv_cur[rn, 2..cols(cv_cur)]
      vec_cur = select (row_cur, row_cur:>value[stat_cur,1])
      stat_cur = stat_cur + 1
      pval = pval \ cols(vec_cur)/1000

      cv_cur = fgetmatrix (fh)
      row_cur = cv_cur[rn, 2..cols(cv_cur)]
      vec_cur = select (row_cur, row_cur:>value[stat_cur,1])
      stat_cur = stat_cur + 1
      pval = pval \ cols(vec_cur)/1000

    }

    pval = pval[2..rows(pval),1]
    if (sb) {
      pval = pval[2..rows(pval),1] \ pval[1,1]
    }
    fclose (fh)

    return (pval)
  }

  real matrix chkstat (real scalar kz, real scalar kx, real scalar tau,
    real scalar a, real scalar sb) {

    clm = 1000-a*1000+1
    rn = kz*(kz+1)*0.5 + kz - kx + 1

    fh = _fopen (st_strscalar ("c(sysdir_plus)") + "crit_values.matrix", "r")
    if (fh < 0) {
      fh = fopen ("crit_values.matrix", "r")
    }
    stat_cur = 1
    crit = J(1,1,.)

    cv_cur = fgetmatrix (fh)
    stat_cur = stat_cur + 1
    crit = crit \ cv_cur[rn, clm]

    if (sb==1) {

      k = ceil(tau / 0.05 - 1)
      for (j=1; j<=(3*k); j++) {
        cv_cur = fgetmatrix (fh)
      }

      cv_cur = fgetmatrix (fh)
      stat_cur = stat_cur + 1
      crit = crit \ cv_cur[rn, clm]

      cv_cur = fgetmatrix (fh)
      stat_cur = stat_cur + 1
      crit = crit \ cv_cur[rn, clm]

      cv_cur = fgetmatrix (fh)
      stat_cur = stat_cur + 1
      crit = crit \ cv_cur[rn, clm]

    }


    crit = crit[2..rows(crit),1]
    if (sb) {
      crit = crit[2..rows(crit),1] \ crit[1,1]
    }
    fclose (fh)
    return (crit)

  }



  class genstestSpec {
    real scalar wmtype, adjf, nest
    real scalar small
    real scalar l_opt, l_auto, l_nlags
    real scalar sbl_opt, sbl_auto, sbl_nlags
    real scalar inwmatrix, cur_t, varS, nuisS
    real scalar center, sb_center, hasderiv
    real scalar identity, twostep
    real scalar sb_twostep, sb_identity
    real matrix instr, fs_wmatrix, fs_vcov, wm1, wm2
    real matrix init, gam, fs_gam

    pointer matrix cluster
    pointer matrix c1, c2 // cluster breaks
    real scalar sb_clst
    scalar kernel

    real matrix cur_v // For optimal HAC

    real matrix PHI()
    real matrix arsinglebreak()
    real matrix clarsinglebreak()
    real scalar qllstab()
    real matrix coeff()
    real matrix homoskedastic()
    real matrix HC()
    real matrix HAC()
    pointer matrix VARfilter()

    real matrix clustervar()
    real scalar optlag()
    real scalar sigmaj()
    real scalar nwest()
    real scalar andrews()
    real scalar gallant()

    void objf()
    void objfss()
    real rowvector twostep()
    real rowvector igmm()
    real matrix matgmm()
    real matrix ufunc()
    real matrix nuisfunc()
  }



  real matrix genstestSpec::PHI(real matrix u, real matrix z) {
    if (fs_wmatrix!=0) {
      phi = fs_wmatrix
    }
    else {
      if (wmtype==0) {
        phi = homoskedastic(u,z)
      }
      if (wmtype==1) {
        phi = HC(u,z)
      }
      if (wmtype==2) {
        phi = HAC(u,z)
      }
      if (wmtype==3) {
        phi = clustervar(z,u)
      }
    }

    return(phi)
  }



  real matrix genstestSpec::arsinglebreak(real scalar tau) {

    real scalar i, T, kz, start, finish
    T = rows(instr)
    kz = cols(instr)
    start = floor(T*tau)
    finish = floor(T*(1-tau))
    ars = J(1,1,.)

    l_auto = sbl_auto
    l_opt = sbl_opt

    for(i=start;i<=finish;i++)  {
      touse = J(i,1,1) \ J(T-i,1,0)
      if ((nest > 0) & (gam==0)) {
        nuis = matgmm(touse)
      }
      else if (nest > 0) {
        nuis = gam
      }
      else {
        nuis = 0
      }

      ufull = ufunc(nuis)
      u1 = select(ufull,touse)
      z1 = select(instr,touse)
      x1 = cross (z1,z1)
      d1 = coeff(u1,z1)
      ar1 = d1'*(1/rows(z1))*x1*wm1*x1*d1


      u2 = select(ufull,!touse)
      z2 = select(instr,!touse)
      x2 = cross (z2,z2)
      d2 = coeff (u2,z2)
      ar2 = d2'*(1/rows(z2))*x2*wm2*x2*d2

      temp = ar1 + ar2
      ars = ars \ J(1,1,temp)

    }
    ars = ars[2..rows(ars),1]

    arave = sum(ars)/rows(ars)
    arsup = max(ars)
    arexp = 2*ln(sum(exp(0.5*ars))/rows(ars))
    genar = arave \ arexp \ arsup
    return(genar)
  }




  real scalar genstestSpec::qllstab(real matrix Y, real matrix Z, real matrix phi) {

    T = rows(Z)
    zk = cols(Z)
    oneszk = J(1,zk,1)
    U = Y*oneszk

    O = L = .
    eigensystem(invsym(phi),O,L)
    sqrtphi = O*sqrt(diag(L))*O'
    sqrtphi = Re(sqrtphi)
    V = (U:*Z)*sqrtphi

    D = I(T)
    D = D[2..T,1..T]
    D = D', J(T,1,0)
    D = I(T) - D

    r = 1 - (10/T)
    Rcol = r :^ (0::(T-1))
    ones = J(1,1,1), J(1,(T-1),0)
    R = Toeplitz(Rcol,ones)

    W = R*(D*V)
    rtilde = r*Rcol
    B = invsym(rtilde'*rtilde)*rtilde'*W
    ehatmat = W - rtilde*B
    ehatmat = ehatmat :^ 2
    tssre = sum(ehatmat)

    vt = J(T,1,1)
    C = invsym(vt'*vt)*vt'*V
    vhatmat = V - vt*C
    vhatmat = vhatmat :^ 2
    tssrv = sum(vhatmat)
    qllarstab = Re(tssrv-r*tssre)

    return(qllarstab)

  }


  real matrix genstestSpec::coeff(real matrix y, real matrix x) {
    real matrix delta
    delta = invsym(cross(x,x))*cross(x,y)
    return(delta)
  }



  real matrix genstestSpec::homoskedastic(real matrix u, real matrix x) {
    N = rows(x)
    kx = cols(x)

    varres = (1/(N-kx))*(u'u)
    Phi = varres*(cross(x,x)*(1/N))
    return(Phi)
  }




  real matrix genstestSpec::HC(real matrix u, real matrix x) {

    N = rows(x)
    kx = cols(x)
    if (!(adjf==1)) {
      hat = x*invsym(cross(x,x))*x'
      h = (diagonal(hat))'
    }

    e = (u :^ 2)'

    if (adjf==1) {
      e = (N/(N-kx))*e
    }
    if ((1<adjf) & (adjf<4)) {
      e = e :/ ((1 :- h) :^ (adjf-1))
    }
    if (adjf==4) {
      hbar = mean(h')
      d  = (hbar < 4) ? hbar : 4 //d = min{ hbar, 4 }
      e = e :/ ((1 :- h) :^ (d))
    }


    vcov = x :* e'

    return((1/N)*x'vcov)
  }



  real matrix genstestSpec::HAC(real matrix y, real matrix x) {

    N = rows(y)
    kx = cols(x)

    V = x :* y
    if (center == 1) {
      V = V :- mean(V)
    }

    if (l_auto || l_opt) {
      cur_v = V
      cur_t = rows(x)
      if (kernel==0) {
        (void) nwest(0,0)
      }
      else if (kernel==1) {
        (void) andrews(0,0)
      }
      else {
        (void) gallant(0,0)
      }
      haclag = l_nlags
    }
    else if (l_nlags) {
      haclag = l_nlags
    }

    vcov = J(kx,kx,0)
    for(j=1;j<=N;j++) {
      for(i=1;i<=N;i++) {
        Vj = V[j,.]
        Vi = V[i,.]
        l = abs(i-j)
        if (kernel==0) {
          wt = nwest(l,haclag)
        }
        else if (kernel==1) {
          wt = andrews(l,haclag)
        }
        else {
          wt = gallant(l,haclag)
        }
        vcov = vcov + wt*(cross(Vi,Vj))
      }
    }

    vcov = (1/N)*vcov
    if (small) {
      vcov = (N/(N-kx))*vcov
    }
    return(vcov)

  }






  pointer matrix genstestSpec::VARfilter(real matrix M, real scalar k, real scalar ct) {

    X = M[1..ct-1,.]
    Y = M[2..ct,.]
    A = (cross(Y,X))*(invsym(cross(X,X)))

    svd(A, U, S, Vt)
    Stilde = J(rows(S),cols(S),0)
    for(i=1;i<=rows(S);i++) {
      for(j=1;j<=cols(S);j++) {
        if (S[i,j] >= 0.97) {
          Stilde[i,j] = 0.97
        }
        else if (S[i,j] <= -0.97) {
          Stilde[i,j] = -0.97
        }
        else {
          Stilde[i,j] = S[i,j]
        }

      }
    }
    AA      = U*diag(Stilde)*Vt
    imA     = I(k)-AA
    mMhat   = Y-X*AA'
    results = &mMhat \ &imA
    return(results)

  }

  real scalar genstestSpec::optlag (real matrix h, real scalar mrate) {
    real vector sigma
    n = rows(h)
    k = cols(h)
    w = J(k,1,1)
    f = h :* w'
    m = floor(20*(n/100)^mrate)
    sigma = J(1,1,.)
    sgm = 0
    for(j=0;j<=m;j++) {
      for(i=j+1;i<=n;i++) {
        sgm = sgm + f[i,.]*(f[(i-j),.]')
      }
      sigma = sigma, (sgm/n)
    }

    sigma = sigma[2..length(sigma)]

    s0 = sigma[1] + 2*sum(sigma[2..length(sigma)])
    s1 = 2*sum((range(1,m,1)') :* sigma[2..length(sigma)])
    s2 = 2*sum((range(1,m,1) :^ 2)' :* sigma[2..length(sigma)])
    qrate = mrate == (2/9) ? 1/(2 + 1) : 1/(4+1)

    if (mrate == (2/9)) {
      c = floor(1.1447 * (((s1/s0)^2)^qrate))
    }
    else if (mrate == (2/25)) {
      c = floor(1.3221 * (((s2/s0)^2)^qrate))
    }
    else if (mrate == (4/25)) {
      c = floor(2.6614*((s2/s0)^2)^qrate)
    }
    lags = floor(c*(n^(qrate)))
    if (mrate > (2/25)) {
      lags = round(lags) < m ? round(lags) : m
    }
    else {
      lags = lags < m ? lags : m
    }
    return(lags)

  }



  real scalar genstestSpec::sigmaj(real scalar j, real matrix h, real matrix w, real scalar m, real scalar T) {

    accum = 0
    for (t=j+2;t<=T;t++) {
      accum = accum + (w'*h[t,.]')*(w'*h[t-j,.]')
    }
    return (accum/T)
  }


  real scalar genstestSpec::nwest(real scalar l, real scalar maxlag) {

    if (l_auto) {
      maxlag = floor(4*(cur_t/100)^(2/9))
      l_nlags = maxlag
    }
    else if (l_opt && maxlag==0) {
      maxlag = optlag(cur_v,2/9)
      l_nlags = maxlag
    }
    else if (!l_opt) {
      maxlag = l_nlags
    }

    if (l > maxlag) {
      l = maxlag + 1
    }
    wt = 1 - (l/(maxlag+1))

    return(wt)
  }



  real scalar genstestSpec::andrews(real scalar l, real scalar maxlag) {

    if (l_auto) {
      maxlag = 4 * (cur_t/100)^(2/25)
      l_nlags = maxlag
    }
    else if (l_opt && maxlag==0) {
      maxlag = optlag(cur_v,2/25)
      l_nlags = maxlag
    }
    else if (!l_opt) {
      maxlag = l_nlags
    }

    z = l/(maxlag+1)
    th = 6.0*pi()*z/5.0
    if (z == 0) {
      wt = 1
    }
    else {
      wt = 3.0*(sin(th)/th - cos(th))/(th^2)
    }
    return(wt)
  }

  real scalar genstestSpec::gallant(real scalar l, real scalar maxlag) {

    if (l_auto) {
      maxlag = 4 * (cur_t/100)^(4/25)
      l_nlags = maxlag
    }
    else if (l_opt && maxlag==0) {
      maxlag = optlag(cur_v,4/25)
      l_nlags = maxlag
    }
    else if (!l_opt) {
      maxlag = l_nlags
    }

    z = l/(maxlag+1)
    if (z <= .5) {
      wt = 1 - 6*z^2 + 6*z^3
    }
    else if ((z >= 0.5) & (z <= 1)) {
      wt = 2*(1-z)^3
    }
    else {
      wt = 0
    }
    return(wt)
  }

  void genstestSpec::objf(todo,c,crit,g,H) {
    z = instr
    u = ufunc(c)

    m = z'*u - (1/rows(z))*z'u
    w = wm1

    crit = 0.5*(m'*w*m)

    if (todo>=1) {
      g = u'*z*w*z'*nuisfunc(c)
    }
  }

  void genstestSpec::objfss(todo,c,crit,g,H) {
    external GENSTEST_TOUSE
    z = instr

    z1 = select(z, GENSTEST_TOUSE)
    z2 = select(z, !GENSTEST_TOUSE)

    u = ufunc(c)

    u1 = select(u, GENSTEST_TOUSE)
    u2 = select(u, !GENSTEST_TOUSE)
    m1 = z1'*u1
    m2 = z2'*u2

    crit = 0.5*(m1'*wm1*m1 + m2'*wm2*m2)

    if (todo==1) {
      v = nuisfunc(c)
      v1 = select(v,GENSTEST_TOUSE)
      v2 = select(v,!GENSTEST_TOUSE)
      g = u1'*z1*wm1*z1'*v1 + u2'*z2*wm2*z2'*v2
    }
  }

  void optim_wrapper(todo,c,class genstestSpec M,crit,g,H) {
    M.objf(todo,c,crit,g,H)
  }

  void optimss_wrapper(todo,c,class genstestSpec M,crit,g,H) {
    M.objfss(todo,c,crit,g,H)
  }

  real rowvector genstestSpec::twostep() {
    external GENSTEST_TOUSE

    z = instr

    z1 = select(z, GENSTEST_TOUSE)
    z2 = select(z, !GENSTEST_TOUSE)

    if (z1 == z) {
      wm1 = identity ? I(cols(z)) : invsym(cross(z1,z1))
      S = optimize_init()
      optimize_init_evaluator(S, &optim_wrapper())
      optimize_init_argument(S,1,this)
      optimize_init_conv_maxiter(S,25)
      optimize_init_tracelevel(S,"none")
      optimize_init_which(S, "min")
      optimize_init_params(S, init)
      if (hasderiv) {
        optimize_init_evaluatortype(S,"d1")
      }
      else {
        optimize_init_evaluatortype(S,"d0")
      }
      p = optimize(S)
    }
    else {
      p = fs_gam
    }

    u = ufunc(p)
    u1 = select(u,GENSTEST_TOUSE)

    if (sb_clst == 1) {
      origcluster = cluster
      cluster = c1
      wm1 = invsym(PHI(u, z))
    }
    else {
      wm1 = invsym(PHI(u1,z1))
    }

    if (z1!=z) {
      u2 = select(u,!GENSTEST_TOUSE)
      if (sb_clst == 1) {
        cluster = c2
        wm2 = invsym(PHI(u, z))
      }
      else {
        wm2 = invsym(PHI(u2,z2))
      }
    }
    else {
      wm2 = 0
    }

    S = optimize_init()
    if (z1 == z) {
      optimize_init_evaluator(S, &optim_wrapper())
    }
    else {
      optimize_init_evaluator(S, &optimss_wrapper())
    }
    optimize_init_argument(S,1,this)
    optimize_init_conv_maxiter(S,25)
    optimize_init_tracelevel(S, "none")
    optimize_init_which(S, "min")
    optimize_init_params(S, init)
    if (hasderiv) {
      optimize_init_evaluatortype(S,"d1")
    }
    else {
      optimize_init_evaluatortype(S,"d0")
    }
    p = optimize(S)
    if (sb_clst == 1) {
      cluster = origcluster
    }
    return(p)
  }

  real rowvector genstestSpec::igmm() {
    external GENSTEST_TOUSE

    z = instr

    z1 = select(z, GENSTEST_TOUSE)
    z2 = select(z, !GENSTEST_TOUSE)
    if (z1 == z) {
      wm1 = identity ? I(cols(z)) : invsym(cross(z1,z1))
      S = optimize_init()
      optimize_init_evaluator(S, &optim_wrapper())
      optimize_init_argument(S,1,this)
      optimize_init_conv_maxiter(S,25)
      optimize_init_tracelevel(S,"none")
      optimize_init_which(S, "min")
      optimize_init_params(S, init)
      if (hasderiv) {
        optimize_init_evaluatortype(S,"d1")
      }
      else {
        optimize_init_evaluatortype(S,"d0")
      }
      p = optimize(S)
    }
    else {
      p = fs_gam
    }

    p1 = p :+ 1

    while (norm (p1-p) > 0.00001) {

      u = ufunc(p)
      u1 = select(u,GENSTEST_TOUSE)

      if (sb_clst == 1) {
        origcluster = cluster
        cluster = c1
        wm1 = invsym(PHI(u, z))
      }
      else {
        wm1 = invsym(PHI(u1,z1))
      }

      if (z1!=z) {
        u2 = select(u,!GENSTEST_TOUSE)
        if (sb_clst == 1) {
          cluster = c2
          wm2 = invsym(PHI(u, z))
        }
        else {
          wm2 = invsym(PHI(u2,z2))
        }
      }
      else {
        wm2 = 0
      }

      S = optimize_init()
      if (z1 == z) {
        optimize_init_evaluator(S, &optim_wrapper())
      }
      else {
        optimize_init_evaluator(S, &optimss_wrapper())
      }
      optimize_init_argument(S,1,this)
      optimize_init_conv_maxiter(S,25)
      optimize_init_tracelevel(S, "none")
      optimize_init_which(S, "min")
      optimize_init_params(S, init)
      if (hasderiv) {
        optimize_init_evaluatortype(S,"d1")
      }
      else {
        optimize_init_evaluatortype(S,"d0")
      }
      p1 = p
      p = optimize(S)
      if (sb_clst == 1) {
        cluster = origcluster
      }
    }
    return(p)
  }



  real matrix genstestSpec::matgmm(real matrix touse) {

    external GENSTEST_TOUSE

    GENSTEST_TOUSE = touse

    if (fs_wmatrix!=0) {
      wm1 = fs_wmatrix
      wm2 = fs_wmatrix

      S = optimize_init()
      if (touse == J(rows(touse),1,1)) {
        optimize_init_evaluator(S, &optim_wrapper())
      }
      else {
        optimize_init_evaluator(S, &optimss_wrapper())
      }
      optimize_init_argument(S,1,this)
      optimize_init_conv_maxiter(S,25)
      optimize_init_tracelevel(S, "none")
      optimize_init_which(S, "min")
      optimize_init_params(S, init)
      if (hasderiv) {
        optimize_init_evaluatortype(S,"d1")
      }
      else {
        optimize_init_evaluatortype(S,"d0")
      }
      p = optimize(S)
    }
    else if (twostep == 1) {
      p = twostep()
    }
    else {
      p = igmm()
    }

    return(p)
  }

  real matrix genstestSpec::ufunc(real rowvector b) {
    p = cols(b)
    for(i=1;i<=p;i++) {
      st_numscalar("GENSTEST_REALLY_TEMP",i)
      stata("local i = GENSTEST_REALLY_TEMP")
      call = st_macroexpand("GENSTEST_EST`" + "i" + "'")
      st_numscalar(call,b[i])
    }

    (void) st_addvar("double", name=st_tempname())
    call = st_macroexpand("qui replace " + name + " = `" + "wvar" + "'*(`" + "equation"/*
*/ + "') " + "if " + "`" + "touse" + "'")
    stata(call)
    u = st_data(.,name,0)
    st_dropvar(name)
    return(u)
  }

  void reParseExpression (real matrix null) {
    for (i=1;i<=cols(null);i++) {
      st_local ("new_null_temp", null[i,1])
      stata ("local result = `" + "result" + "' " + "`" + "new_null_temp" + "'")
    }

  }


  real matrix genstestSpec::nuisfunc(real rowvector b) {
    real matrix g
    p = cols(b)
    for(i=1;i<=p;i++) {
      st_numscalar("GENSTEST_REALLY_TEMP",i)
      stata("local i = GENSTEST_REALLY_TEMP")
      call = st_macroexpand("GENSTEST_EST`" + "i" + "'")
      st_numscalar(call,b[i])
    }

    for(i=1;i<=p;i++) {
      st_numscalar("GENSTEST_REALLY_TEMP",i)
      stata("local i = GENSTEST_REALLY_TEMP")
      (void) st_addvar("double", name=st_tempname())
      call = st_macroexpand("qui replace " + name + " = `" + "wvar'*(`" + "deriv`" + "i" + "'')" + " if " + "`" + "touse" + "'")
      stata(call)
      temp = st_data(.,name,0)

      if (i==1) {
        g = temp
      }
      else {
        g = g, temp
      }
      st_dropvar(name)
    }
    return(g)
  }

  pointer matrix gencluster(real matrix cluster) {
    unique = uniqrows(cluster)
    Nc = rows(unique)
    result = J(1,1,&.)
    for(i=1;i<=Nc;i++) {
      p = getindexbyv(unique[i,1],cluster)
      result = result \ p
    }
    result = result[2..rows(result),1]
    return(result)
  }

  pointer getindexbyv(real scalar value, real matrix cluster) {
    /*Creates list of indicies where cluster variable has
  certain value*/

    N = rows(cluster)
    result = J(1,1,.)
    for(i=1;i<=N;i++) {
      if(cluster[i,1] == value) {
        result = result \ i
      }
    }
    result = result[2..rows(result),1]
    p = &result
    return(p)
  }

  real matrix clustering(real scalar dimension, cluster) {
    /*Creates a touse vector for a number of clusters*/
    N = rows(cluster)
    touse = J(dimension,1,0)
    for(i=1;i<=N;i++) {
      temp = *cluster[i,1]
      for(j=1;j<=rows(temp);j++) {
        k = temp[j,1]
        touse[k,1] = 1
      }
    }
    return(touse)
  }

  real matrix genstestSpec::clarsinglebreak(real matrix Z, real scalar tau) {

    origcluster = cluster
    Nc = rows(cluster)
    begin = floor(tau*Nc)
    if (begin == 0) {
      begin = 1
    }
    finish = floor((1-tau)*Nc)
    ars = J(1,1,.)
    sb_clst = 1
    for(i=begin;i<=finish;i++) {
      c1 = origcluster[1..i,1]
      c2 = origcluster[i+1..rows(origcluster), 1]

      touse = clustering(rows(Z),c1)
      if ((nest > 0) & (gam==0)) {
        nuis = matgmm(touse)
      }
      else if (nest > 0) {
        nuis = gam
      }
      else {
        nuis = 0
      }

      ufull = ufunc(nuis)
      u1 = select(ufull,touse)
      z1 = select(instr,touse)
      zz1 = cross(z1,z1)

      cluster = c1
      d1 = coeff(u1,z1)
      v1 = zz1*invsym(clustervar(Z, ufull))*zz1
      u2 = select(ufull,!touse)
      z2 = select(instr,!touse)
      cluster = c2

      d2 = coeff(u2,z2)
      zz2 = cross (z2,z2)
      v2 = zz2*invsym(clustervar(Z,ufull))*zz2

      temp = (1/rows(z1))*d1'*v1*d1 + (1/rows(z2))*d2'*v2*d2
      ars = ars \ J(1,1,temp)
    }

    ars = ars[2..rows(ars),1]

    avear = sum(ars)/rows(ars)
    supar = max(ars)
    expar = 2*ln(sum(exp(0.5*ars))/rows(ars))
    genar = avear \ expar \ supar

    sb_clst = 0
    cluster = origcluster
    return(genar)

  }

  real matrix genstestSpec::clustervar(real matrix z, real matrix u) {

    Nc = rows(cluster)
    T = rows(z)
    vcov = J(cols(z),cols(z),0)
    touse = J(T,1,0)
    resid = u
    adjf = 1
    for(i=1;i<=Nc;i++) {
      temp = *(cluster[i,1])
      for(j=1;j<=rows(temp);j++) {
        tn = temp[j,1]
        touse[tn,1] = 1
      }

      ut = select(u,touse)
      zt = select(z,touse)
      psi = colsum((ut :* zt))
      vcov = vcov + cross(psi,psi)
      touse = J(T,1,0)
    }

    return(vcov*(1/T))
  }

end
