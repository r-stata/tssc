*! This version 2.4 (2007-12-03, Ph.Van Kerm)
* version 2.3 (2007-11-23, Ph.Van Kerm)
* version 2.2 (2005-09-28, Ph.Van Kerm)
* version 12/04 (Ph.Van Kerm)
* version 2/01 (amended by Ph.Van Kerm)
* version 1/98 was -inequal2- (amended by Ph.Van Kerm)
* version 2.1.0  9/8/94 (original by Edward Whitehouse)

* This file is -inequal.ado- by Edward Whitehouse published in
* STB-23 with subsequent modifications by Philippe Van Kerm, CEPS/INSTEAD
* (1998, 2001, 2004).
* It is an upgrade to Stata 7 of the previously released -inequal2.ado-.

* Compared to the original -inequal.ado- :
*
* (1) -inequal7.ado- includes the GE(-1) and GE(2) measures;
* (2) -inequal7.ado- computes ranks differently for the computation
*    of the Gini measure with weighted data (this makes -inequal7.ado-
*    suitable for grouped data). ;
* (3) -inequal7.ado- accepts aweights;
* (4) -inequal7.ado- sets global macros and returns results in r() format;
* (5) -inequal7.ado- nicely outputs results conforming to the new Stata 7
* standards.
* (6) Control over the display format is given to the user with a standard
* 'format(%fmt)' option.
* (7) up to 5 variables can be specified.

* The 12/04 update fixes a couple of bugs (treatment of <0 incomes in Theil and MLD)
* and now returns scalar results in r().
* The 11/07 update fixes a bug in GE(0) and GE(1) with <0 incomes (thanls to A Paulus  and A Peichl)

pr def inequal7 , rclass
  version 7.0
  syntax varlist(min=1 max=5)  [if] [in]  [aweight fweight] [,Format(string) RETURNScalars  ]

  if "`format'"==""{loc format "%6.5f"}

  quietly {
    tempvar touse i index tmptmp temp order value1 value2 value3 value4 value5
    marksample touse , novarlist

    preserve            /* optional but computation actually faster on */
    keep if `touse'     /* most data with it !! */

    if _N < 11 {
      set obs 11
      }

    gen byte `index' = .
    label variable `index' "Inequality measures"
    gen `order' = _n in 1/11
    gen `tmptmp'=.
    gen `i'=.
    gen `temp'=.

    loc k 0
    tokenize `varlist'


    while "`1'"~=""{

        loc k = `k'+1
        loc j 1
        gen `value`k'' = .
        loc varval "`varval' `value`k''"
        label variable `value`k'' "`1'"

        marksample touse , novarlist
        markout `touse' `1'
        count if `touse'
        loc N = r(N)  /* number of usable obs. */

        /* ADDED VERSION 12/04  - extract frm ineqdeco -*/
        count if `1' < 0 & `touse'
        loc ct = _result(1)
        if `ct' > 0 {
          noi di in blue "Warning: `1' has `ct' values < 0 *used* in calculations" 
          noi di in blue "    (except for SD logs, GE(0) (Mean log-deviation) and GE(1) (Theil))."
          }
        count if `1' == 0 & `touse'
        loc ct = _result(1)
        if `ct' > 0 {
          noi di in blue "Warning: `1' has `ct' values == 0 *used* in calculations"
          noi di in blue "    (except for SD logs, GE(-1), GE(0) (Mean log-deviation) and GE(1) (Theil))."
          }
        su `1' [`weight'`exp'] if `touse'
        local mn = _result(3)
        local tot = _result(2)
        local vari = _result(4)
        su `1' [`weight'`exp'] if `touse' & `1'>0 , meanonly
        local mnpos = _result(3)
        local totpos = _result(2)
        su `1' [`weight'`exp'] if `touse' & `1'!=0 , meanonly
        local mnnot0 = _result(3)
        local totnot0 = _result(2)

        gsort -`touse' +`1'  /* puts usable obs. on top */
        local wt : word 2 of `exp'
        if "`wt'"=="" {
            replace `i' = _n in 1/`N'
            local wt = 1
            }
        else {
            replace `tmptmp' = sum(`wt')  in 1/`N'
    	    replace `i' = ((2*`tmptmp')-`wt'+1)/2  in 1/`N'
    	    }

    * relative mean deviation
        replace `temp' = sum(`wt'*abs(`1'-`mn'))  in 1/`N'
        local rmd = `temp'[`N']/(2*`mn'*`tot')
        replace `index' = `j' if `order'==`j'
        replace `value`k'' = `rmd'  if `order'==`j'
        loc j = `j'+1
    * coefficient of variation
        local cov = `vari'^0.5/`mn'
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `cov'  if `order'==`j'
        loc j = `j'+1
    * standard deviation of logs
        replace `temp' = ln(`1')  in 1/`N'
        su `temp' [`weight'`exp'] in 1/`N'
        local sdl = (_result(4))^0.5
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `sdl'  if `order'==`j'
        loc j = `j'+1
    * gini
        replace `temp' = sum(`wt'*`i'*(`1'-`mn')) in 1/`N'
        local gini = (2*`temp'[`N'])/(`tot'^2*`mn')
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `gini'  if `order'==`j'
        loc j = `j'+1
    * mehran
        replace `temp' = sum(`wt'*`i'*(2*`tot'+1 -`i')*(`1' - `mn')) in 1/`N'
        local mehran = (3*`temp'[`N'])/(`tot'^3*`mn')
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `mehran'  if `order'==`j'
        loc j = `j'+1
    * piesch
        replace `temp' = sum(`wt'*`i'*(`i'-1)*(`1'-`mn')) in 1/`N'
        local piesch = 3*`temp'[`N']/(2*`tot'^3*`mn')
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `piesch'  if `order'==`j'
        loc j = `j'+1
    * kakwani
        replace `temp' = sum(`wt'*((`1'^2+`mn'^2)^0.5)) in 1/`N'
        local kakwani = (1/(2-2^0.5))*((`temp'[`N']/(`tot'*`mn')-2^0.5))
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `kakwani'  if `order'==`j'
        loc j = `j'+1
    * theil
        replace `temp' = sum(`wt'*((`1'/`mnpos')*(log(`1'/`mnpos')))) in 1/`N'
        local theil = `temp'[`N']/`totpos'
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `theil'  if `order'==`j'
        loc j = `j'+1
    * mean log deviation
        replace `temp' = sum(`wt'*(log(`mnpos'/`1'))) in 1/`N'
        local mld = `temp'[`N']/`totpos'
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `mld'  if `order'==`j'
        loc j = `j'+1
    * GE -1
        replace `temp' = sum(`wt'*(`mnnot0'/`1')) in 1/`N'
        local ge_1 = ((`temp'[`N']/`totnot0')-1)/2
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `ge_1'  if `order'==`j'
        loc j = `j'+1
    * GE 2
        replace `temp' = sum(`wt'*((`1'/`mn')^2)) in 1/`N'
        local ge2 = ((`temp'[`N']/`tot')-1)/2
        replace `index' = `j'  if `order'==`j'
        replace `value`k'' = `ge2'  if `order'==`j'
        loc j = `j'+1

        mac shift
        }
    }

  label define `index' 1 "Relative mean deviation"                 /*
    */ 2 "Coefficient of variation" 3 "Standard deviation of logs" /*
    */ 4 "Gini coefficient" 5 "Mehran measure"  6 "Piesch measure" /*
    */ 7 "Kakwani measure" 8 "Theil index (GE(a), a = 1)"          /*
    */ 9 "Mean Log Deviation (GE(a), a = 0)"                       /*
    */ 10 "Entropy index (GE(a), a = -1)"                          /*
    */ 11 "Half (Coeff.Var. squared) (GE(a), a = 2)"

  label values `index' `index'
  tabdisp `index' ,c(`varval') format(`format') concise

 /* returns in locals as default (for bad historical reasons) - kept for backward compatibility
    use returnscalars option to return in scalars - eg for bootstrapping */
  if "`returnscalars'"!=""  {
   return scalar rmd = `rmd'
   return scalar cov = `cov'
   return scalar sdl = `sdl'
   return scalar gini  = `gini'
   return scalar mehran = `mehran'
   return scalar piesch = `piesch'
   return scalar kakwani = `kakwani'
   return scalar theil = `theil'
   return scalar mld = `mld'
   return scalar ge_1 = `ge_1'
   return scalar ge2 = `ge2'
  }
  else   {
   return local rmd = `rmd'
   return local cov = `cov'
   return local sdl = `sdl'
   return local gini  = `gini'
   return local mehran = `mehran'
   return local piesch = `piesch'
   return local kakwani = `kakwani'
   return local theil = `theil'
   return local mld = `mld'
   return local ge_1 = `ge_1'
   return local ge2 = `ge2'
  }

 /* for backward compatibility again */
  global S_1 = `rmd'
  global S_2 = `cov'
  global S_3 = `sdl'
  global S_4 = `gini'
  global S_5 = `mehran'
  global S_6 = `piesch'
  global S_7 = `kakwani'
  global S_8 = `theil'
  global S_9 = `mld'
  global S_10 = `ge_1'
  global S_11 = `ge2'
  restore
end

