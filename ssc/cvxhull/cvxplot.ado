* 1.0 18 December 2003, R Allan Reese, University of Hull
program cvxplot, sortpreserve
*set trace on
    version 8.0
    syntax varlist(min=4) [if] [in] ///
    [ , Hulls(numlist int min=0 max=2 >0) ///
        GROup(varname) SELect(numlist int min=0 >0 sort) ///
        MEAns noREPort SCATopt(string) SAVing(string)]

    loc reporting = ("`report'" != "noreport")

    if "`saving'" != "" { //  Check saving filename   
      tokenize "`saving'", parse(",")
      args saving comma replace
      if index("`saving'", ".") == 0 loc saving "`saving'.gph"
      capture confirm file `saving'
      if _rc == 0 { /* existing file */
        if "`replace'" != "replace" {
          di as err "Invalid save file - did you mean to replace?"
          exit 198
        }
        loc saving `"`saving',replace"'
      }
      else confirm new file `saving' // invalid file - unless new
      loc saving `"saving("`saving'")"'
    }

***** Check allowable set of variables
    loc numvars = 0
    foreach vpair of varlist `varlist' {
      loc ++numvars
    }
    if `numvars'/2>int(`numvars'/2) {
      di as err "Invalid varlist: must be y, x & pairs of hull lines"
      exit 498
    }

    tempname gap
    loc maxhull = 0
    if `"`hulls'"' == "" {
      loc hulls = 1 
      loc hullgap = 1 // Set default values
    }
    else {
      tokenize "`hulls'"
      loc hulls = `1'
      if "`2'" == ""  loc hullgap = 1
      else            loc hullgap = `2'
    }

***** Loop to select hulls ******************************************
    tokenize "`varlist'"
    loc y  "`1'" 
    loc x  "`2'"
    loc hulllist "`3' `4'"     // Force draw of first hull
    loc gap = 0
    loc depth = 1
    forvalues vpair = 5 (2) `numvars' {
      loc ++gap
      loc ++depth
      if `gap' == `hullgap' & `depth' <= `hulls' {
        loc hulllist "`hulllist' ``vpair'' ``=`vpair'+1''"
        loc gap = 0
      }
    }

* Standard set up sample of obs.  NJC
    marksample touse, novarlist // Deal with `if' and `in'
    markout `touse' `y' `x'
    qui count if `touse'
    if r(N) == 0 error 2000

    tempvar sample use2
    qui gen `sample' = `touse'

* Other options
    if "`group'" == "" { // group variable may be absent, string or numeric
      tempvar grp
      qui gen `grp' = 1
      loc select "1"
      loc maxgrp = 1
    }
    else {
      tempvar grp
      qui egen `grp' = group(`group') if `touse', label        
      if "`select'" != "" {
        loc j = 0
        foreach i in `select' {
          loc ++j
        }
        loc maxgrp = `j'
      }
      else {
        su `grp', meanonly
        loc maxgrp = r(max)
        loc select "1/`maxgrp'"
      }
    qui {
      egen `use2' = eqany(`grp'), values(`select')
      replace `touse' = `touse' * `use2'
    }
    if `reporting' di as txt "Codes for groups based on " as res "`group'"
    label list `grp'
    }
    loc retd = 1 + int((`hulls'-1)/`hullgap')
    loc hull = plural(`retd', "hull")
    loc gs = plural(`maxgrp', "group")
    if `reporting'  di as txt "Up to `retd' `hull' to be plotted for `maxgrp' `gs'"

***** Make plot 
    if `reporting' di as txt "Graph will be plotted presently"
* Build and execute graph command ... as a very long macro text!
    loc colours "black black blue blue dkorange dkorange magenta magenta emerald emerald khaki khaki cyan cyan red red"
* Set up point plot and add line plots for each selected group
* RAR's preference for default horizontal labels
    loc gr `"scatter `y' `x' if `sample',yti("`y'")yla(,angle(0))`saving' `scatopt'"'
    if "`means'" == "means" {
      tempvar ymean xmean
      egen `ymean' = mean(`y') if `sample', by(`grp')
      egen `xmean' = mean(`x') if `sample', by(`grp')
      loc gr `"`gr'||scatter `ymean' `xmean', ms(T) xti("`x'")"'
    }
    foreach i of numlist `select' {
      loc gr `"`gr'||line `hulllist' `x' if `grp'==`i',clc(`colours')legend(off) sort(`grp' `x' `y')"'
    }
    `gr' // & execute macro command 

    if `reporting' di as txt "cvxplot run"

end // of cvxplot

