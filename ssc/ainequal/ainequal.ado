*! This version 6.0     <10apr2007> 	   JPAzevedo
*   include atkinson, relsgini and GE for all alphas
*   include relative poverty lines
*  This version 5.0     <25apr2005> 	   JPAzevedo


pr def ainequal , rclass

  version 7.0

  syntax varlist(min=1 max=5)   ///
        [if] [in]               ///
        [aweight fweight] [,    ///
        Format(string)          ///
        ATKinson                ///
        EPSilon(string)         ///  /* default 1 */
        RELSGini                ///
        Delta(string)           ///  /* default 2 */
        nogini                  ///
        notheil                 ///
        rmd                     ///
        cov                     ///
        sdl                     ///
        mehran                  ///
        piesch                  ///
        kakwani                 ///
        mld                     ///
        ge_1                    ///
        ge2                     ///
        shorrocks               ///
        alpha(string)           ///
        all                     ///
        BENCHmark               ///
        NOSPACE                ///
        ]

  if "`format'"==""{
      local format "%6.5f"
  }

  if ("`all'"!="") {
      local rmd         rmd
      local cov         cov
      local sdl         sdl
      local mehran      mehran
      local piesch      piesch
      local kakwani     kakwani
      local mld         mld
      local ge_1        ge_1
      local ge2         ge2
      local atkinson    atkinson
      local relsgini    relsgini
      local shorrocks   shorrocks
  }

  if ("`nogini'"=="") {
    local gini gini
  }
  if ("`notheil'"=="") {
    local theil theil
  }
  if ("`atkinson'"!="") & ("`epsilon'"=="") {
    local epsilon = 1
  }
  if ("`relsgini'"!="") & ("`delta'"=="") {
    local delta = 2
  }
  if ("`shorrocks'"!="") & ("`alpha'"=="") {
    local alpha = 1
  }

  local maxorder = wordcount("gini gini gini theil `rmd' `cov' `sdl' `mehran' `piesch' `kakwani' `mld' `ge_1' `ge2'  `epsilon'  `delta'  `alpha' ")
  local maxvar = wordcount("`varlist'")
  local max = `maxorder'*`maxvar'

  quietly {

    loc k 0

    tempvar touse i index tmptmp temp order ratio
    tempvar value1 value2 value3 value4 value5
    tempvar benchmark1 benchmark2 benchmark3 benchmark4 benchmark5

    preserve            /* optional but computation actually faster on */

    mark `touse' `if' `in'
    keep if `touse'==1
    loc ntot=_N
    markout `touse' `var'
    keep if `touse'==1
    loc nobs=_N

    gen byte `index' = .
    gen `order' =  _n in 1/`max'
    gen `tmptmp'=.
    gen `i'=.
    gen `temp'=.
    gen `ratio'=.

    foreach 1 of varlist `varlist'  {

        loc k = `k'+1
        loc j 1
        tempvar value`k'
        gen `value`k'' = .
        loc varval "`varval' `value`k''"
        label variable `value`k'' "`1'"

        tempvar benchmark`k'
        gen `benchmark`k'' = .
        loc benchmarkval "`benchmarkval' `benchmark`k''"
        label variable `benchmark`k'' "`1'"


*        mark `touse' `if' `in'
        count if `touse' == 1
        loc N = r(N)  /* number of usable obs. */

        sum `1' [`weight'`exp'] if `touse' == 1, d
        local mn    = _result(3)
        local tot   = _result(2)
        local vari  = _result(4)

        gsort -`touse' +`1'             /* puts usable obs. on top */
        local wt : word 2 of `exp'
        if "`wt'"=="" {
            replace `i' = _n in 1/`N'
            local wt = 1
        }
        else {
            replace `tmptmp' = sum(`wt')  in 1/`N'
            replace `i' = ((2*`tmptmp')-`wt'+1)/2  in 1/`N'
        }

        qui replace `ratio' = `1'/`mn'  if `touse'

    * relative mean deviation
    if "`rmd'"~="" {
        replace `temp' = sum(`wt'*abs(`1'-`mn'))  in 1/`N'
        local rmd = `temp'[`N']/(2*`mn'*`tot')
        replace `value`k'' = `rmd'  if `order'==`j'
        label define `order' `j' "Relative mean deviation", modify
        return local rmd_`k' = `rmd'
        loc j = `j'+1
    }
    * coefficient of variation
    if "`cov'"~="" {
        local cov = `vari'^0.5/`mn'
        replace `value`k'' = `cov'  if `order'==`j'
        label define `order' `j' "Coefficient of variation", modify
        return local cov_`k' = `cov'
        loc j = `j'+1
    }
    * standard deviation of logs
    if "`sdl'"~="" {
        replace `temp' = ln(`1')  in 1/`N'
        su `temp' [`weight'`exp'] in 1/`N'
        local sdl = (_result(4))^0.5
        replace `value`k'' = `sdl'  if `order'==`j'
        label define `order' `j'"Standard deviation of logs", modify
        return local sdl_`k' = `sdl'
        loc j = `j'+1
    }

    * gini
    if "`gini'"~="" {
        replace `temp' = sum(`wt'*`i'*(`1'-`mn')) in 1/`N'
        local gini = (2*`temp'[`N'])/(`tot'^2*`mn')
	    local dG = 100*(`gini'+1)/2
        _pctile `1' [`weight'`exp'] if `touse', percentiles(`dG')
 	    local dGb = r(r1)
        replace `value`k'' = `gini'  if `order'==`j'
        label define `order' `j' "Gini coefficient", modify
        loc j = `j'+1
        replace `benchmark`k'' = `dG' if `order'==`j'
        label define `order' `j' "Gini Benchmark Percentile", modify
        loc j = `j'+1
        replace `benchmark`k'' = `dGb' if `order'==`j'
        label define `order' `j' "Gini benchmark income", modify
        loc j = `j'+1
        return local gini_`k'  = `gini'
    }

    * mehran
    if "`mehran'"~="" {
        replace `temp' = sum(`wt'*`i'*(2*`tot'+1 -`i')*(`1' - `mn')) in 1/`N'
        local mehran = (3*`temp'[`N'])/(`tot'^3*`mn')
        replace `value`k'' = `mehran'  if `order'==`j'
        label define `order' `j' "Mehran measure", modify
        return local mehran_`k' = `mehran'
        loc j = `j'+1
    }
    * piesch
    if "`piesch'"~="" {
        replace `temp' = sum(`wt'*`i'*(`i'-1)*(`1'-`mn')) in 1/`N'
        local piesch = 3*`temp'[`N']/(2*`tot'^3*`mn')
        replace `value`k'' = `piesch'  if `order'==`j'
        label define `order' `j' "Piesch measure", modify
        return local piesch_`k' = `piesch'
        loc j = `j'+1
    }
    * kakwani
    if "`kakwani'"~="" {
        replace `temp' = sum(`wt'*((`1'^2+`mn'^2)^0.5)) in 1/`N'
        local kakwani = (1/(2-2^0.5))*((`temp'[`N']/(`tot'*`mn')-2^0.5))
        replace `value`k'' = `kakwani'  if `order'==`j'
        label define `order' `j' "Kakwani measure", modify
        loc j = `j'+1
        return local kakwani_`k' = `kakwani'
    }
    * theil
    if "`theil'"~="" {
        replace `temp' =  ln(`ratio')*`ratio'  in 1/`N'
        qui sum `temp'  [`weight'`exp']
        local theil = `r(mean)'
        local  dTLb = `mn'
        replace `value`k'' = `theil'  if `order'==`j'
        label define `order' `j' "Theil index (GE(a), a = 1)", modify
        loc j = `j'+1
	    replace `benchmark`k'' = `dTLb' if `order'==`j'
        label define `order' `j' "Theil benchmark income", modify
        loc j = `j'+1
        return local theil_`k' = `theil'
    }
    * mean log deviation
    if "`mld'"~="" {
        replace `temp' =  ln(`ratio')  in 1/`N'
        qui sum `temp'  [`weight'`exp']  in 1/`N'
        local mld  = -`r(mean)'
	    local  dTTb = exp(`mld'+ln(`mn'))
        replace `value`k'' = `mld'  if `order'==`j'
        label define `order' `j' "Mean Log Deviation (GE(a), a = 0)", modify
        loc j = `j'+1
	    replace `benchmark`k'' = `dTTb' if `order'==`j'
        label define `order' `j' "Mean Log Deviation benchmark income", modify
        loc j = `j'+1
        return local mld_`k' = `mld'
    }
    * GE -1
    if "`ge_1'"~="" {
        local a = -1
        qui replace `temp' = (`ratio')^`a'  in 1/`N'
        qui sum `temp'  [`weight'`exp']      in 1/`N'
        local ge_1 = (`r(mean)'-1)/((`a')^2-`a')
        replace `value`k'' = `ge_1'  if `order'==`j'
        label define `order' `j' "Entropy index (GE(a), a = -1)", modify
        return local ge_1_`k' = `ge_1'
        loc j = `j'+1
    }
    * GE 2
    if "`ge2'"~="" {
        local a = 2
        qui replace `temp' = (`ratio')^`a'  in 1/`N'
        qui sum `temp'  [`weight'`exp']      in 1/`N'
        local ge2 = (`r(mean)'-1)/((`a')^2-`a')
        replace `value`k'' = `ge2'  if `order'==`j'
        label define `order' `j' "Half (Coeff.Var. squared) (GE(a), a = 2)", modify
        return local ge2_`k' = `ge2'
        loc j = `j'+1
    }

    * Atkinson
    if "`atkinson'"~="" {
      foreach var in `epsilon' {
          if "`var'"=="1" {
                replace `temp' = exp(sum((`wt'*log((`1'/`mn')^(1/`tot'))))) in 1/`N'
                local atkin = 1-`temp'[`N']
                replace `value`k'' = `atkin'  if `order'==`j'
                label define `order' `j' "Atkinson inequality measures (eps = 1)", modify
                return local atkin1_`k'   = `atkin'
                loc j = `j'+1
          }
          if ("`var'"!="1") {
                replace `temp' = sum(`wt'*((`1'/`mn')^(1-`var'))) in 1/`N'
                local atkin = 1-(`temp'[`N']/`tot')^(1/(1-`var'))
                replace `value`k'' = `atkin'  if `order'==`j'
                label define `order' `j' "Atkinson inequality measures (eps = `var')", modify
                local var2 = subinstr("`var'",".","_",.)
                return local atkin`var2'_`k'   = `atkin'
                loc j = `j'+1
           }
        }
    }


    * Shorrocks
    if "`shorrocks'"~="" {
      foreach a in `alpha' {
          if ((`a'!=1.00)  | (`a'!=0.00)) {
            	qui replace `temp' = (`ratio')^`a'  in 1/`N'
                qui sum `temp'  [`weight'`exp']      in 1/`N'
             	local shor = (`r(mean)'-1)/((`a')^2-`a')
                replace `value`k'' = `shor'  if `order'==`j'
                label define `order' `j' "Generalized enthrophy (alpha = `a')", modify
                local a2 = subinstr("`a'","-","_",.)
                local a2 = subinstr("`a2'",".","_",.)
                return local sh`a2'_`k' = `shor'
                loc j = `j'+1
                replace `temp' = .
           }
           if (`a'==0.00) {
                replace `temp' =  ln(`ratio')  in 1/`N'
                qui sum `temp'  [`weight'`exp']  in 1/`N'
                local shor = -`r(mean)'
                replace `value`k'' = `shor'  if `order'==`j'
                label define `order' `j' "Generalized enthrophy (alpha = 0.00)", modify
                local a2 = subinstr("`a'","-","_",.)
                local a2 = subinstr("`a2'",".","_",.)
                return local sh`a2'_`k' = `shor'
                loc j = `j'+1
                replace `temp' = .
          }
          if (`a'==1.00) {
                replace `temp' =  ln(`ratio')*`ratio'  in 1/`N'
                qui sum `temp'  [`weight'`exp']  in 1/`N'
                local shor = `r(mean)'
                replace `value`k'' = `shor'  if `order'==`j'
                label define `order' `j' "Generalized enthrophy (alpha = 1.00)", modify
                local a2 = subinstr("`a'","-","_",.)
                local a2 = subinstr("`a2'",".","_",.)
                return local sh`a2'_`k' = `shor'
                loc j = `j'+1
                replace `temp' = .
          }
        }
    }


    * Donaldson-Weymark relative S-Gini
    if "`relsgini'"~="" {
      foreach dl in `delta' {
          if `dl'~=. {
              if `dl'~=1 {
                  replace `temp' = sum(`wt'*`1'*((`tot'-`i'+1)^`dl'-(`tot'-`i')^`dl')) in 1/`N'
                  local sgini = (`mn' - `temp'[`N']/(`tot'^`dl'))/`mn'
                  replace `value`k'' = `sgini'  if `order'==`j'
                  label define `order' `j' "S-Gini inequality measures (d = `dl')", modify
                  return local sgini`dl'_`k'   = `sgini'
                  loc j = `j'+1
              }
              else {
                  local sgini = 0
                  replace `value`k'' = `sgini'  if `order'==`j'
                  label define `order' `j' "S-Gini inequality measures (d = `dl')", modify
                  return local sgini`dl'_`k'   = `sgini'
                  loc j = `j'+1
              }
          }
      }
    }
   replace `ratio' = .
   }
 }

  label variable `order' "Inequality measures"

  if ("`nospace'" != "") {
    forvalues i = 1(1)`j' {
        local label : label `order' `i'
        local newlabel = subinstr("`label'"," ","_",.)
        label define `order' `i' "`newlabel'", modify
    }
  }



  label values `order' `order'
  local word = word("`varval'",1)

  tabdisp `order' if `word' != .,c(`varval') format(`format') concise

  if("`benchmark'" != "") {
	di ""
    label variable `order' "Relative Poverty Line"
	di in y "Relative Poverty Line or Benchmark Income Level"
	tabdisp `order' ,c(`benchmarkval') format(%8.2fc) concise
  } 	

  if "`rmd'"    ~="" {global S_1 = `rmd'}
  if "`cov'"    ~="" {global S_2 = `cov'}
  if "`sdl'"    ~="" {global S_3 = `sdl'}
  if "`gini'"   ~="" {global S_4 = `gini'}
  if "`mehran'" ~="" {global S_5 = `mehran'}
  if "`piesch'" ~="" {global S_6 = `piesch'}
  if "`kakwani'"~="" {global S_7 = `kakwani'}
  if "`theil'"  ~="" {global S_8 = `theil'}
  if "`mld'"    ~="" {global S_9 = `mld'}
  if "`ge_1'"   ~="" {global S_10 = `ge_1'}
  if "`ge2'"    ~="" {global S_11 = `ge2'}

  mat `temp' = `gini', `theil'

  if "`rmd'"    ~="" {mat `temp' = `temp', `rmd'}
  if "`cov'"    ~="" {mat `temp' = `temp', `cov'}
  if "`sdl'"    ~="" {mat `temp' = `temp', `sdl'}
  if "`mehran'" ~="" {mat `temp' = `temp', `mehran'}
  if "`piesch'" ~="" {mat `temp' = `temp', `piesch'}
  if "`kakwani'"~="" {mat `temp' = `temp', `kakwani'}
  if "`mld'"    ~="" {mat `temp' = `temp', `mld'}
  if "`ge_1'"   ~="" {mat `temp' = `temp', `ge_1'}
  if "`ge2'"    ~="" {mat `temp' = `temp', `ge2'}


  local rowlabel "ineq:gini ineq:theil "

  local complement ""
  if "`rmd'"    ~="" {local complement "`complement' ineq:rmd"}
  if "`cov'"    ~="" {local complement "`complement' ineq:cov"}
  if "`sdl'"    ~="" {local complement "`complement' ineq:sdl"}
  if "`mehran'" ~="" {local complement "`complement' ineq:mehran"}
  if "`piesch'" ~="" {local complement "`complement' ineq:piesch"}
  if "`kakwani'"~="" {local complement "`complement' ineq:kakwani"}
  if "`mld'"    ~="" {local complement "`complement' ineq:mld"}
  if "`ge_1'"   ~="" {local complement "`complement' ineq:ge_1"}
  if "`ge2'"    ~="" {local complement "`complement' ineq:ge2"}

  mat colnames `temp' = `rowlabel' `complement'

  mat `temp' = `temp''

  return matrix b=`temp'

  restore

end
