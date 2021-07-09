* Adds Syntax and Excution to stata2mplus
*
*  mar 28 2005 added integration miterations
*  may 10 2006 fixed parameterization spelling error
*  Jun 25 2006 added standard Mplus command sections,
*              making keeping up with Mplus versions
*              a non-issue so long as new Mplus commands
*              aren't added.
*              some Mplus version 2 shortcut command/options
*              are retained.
*  Jul 12 2007 Turned off a feature that suppressed appending to variable command
*              This might mess up montecarlo runs....
*  Sep 4  2007 fixed miterations option
*  Jul 22 2008 Revererted to July 17 2008 version
*  Oct 28 2008 added define option
*  DEC 11 2008 KNOWN BUG - when reading parameter estimates, if an IRT model is estimated
*              (Mplus returns IRT parameter estimates) the matrix of returned parameter
*              includes duplicate entries, i.e.  does distinguish regular parameter
*              estimates from IRT-scaled parameter estimates.
* Jul 27 2009  Adam Carle provided wtscale option
*              It’s not well known (i.e., not documented in the actual manual), but,
*              when including weights in multilevel models or complex data, Mplus
*              automatically scales the weights. For numerous reasons, one may wish
*              to scale their weights on their own outside the program (e.g., different
*              scaling methods, same scaling method but using a zero weighting
*              technique to subpop, etc.). One can tell Mplus not to scale the
*              weights. But, like I said, the manual doesn’t show it.
*              I added a bit of code to runmplus to allow this.
* Apr 28 2010  Added code for post-processing of models using Bayesian estimation
*              for Mplus version 6
* Oct 03 2010  Added output processing for Monte Carlo
* Feb 15 2011  Added demo4, version5 options
* Oct 02 2011  Made it so you don't HAVE to put cluster var in varlist.
*              Thanks to Tor Neilands
* Dec 03 2011  Added some return of fit statistics after EFA
* Jun 05 2012  Fixed parsing of priors in model statement
* Jun 17 2012  Added extraction of Tech 11 and Tech 14 results
* Jul 30 2013  Fixed version call bug
* Aug 19 2013  Addressed classname in r(estimate) under LCA/Bayes
* Aug 20 2013  Added model missing for montecarlo runs
* Aug 21 2013  Fixed how bayesian estimation is determined for post-processing
* Oct 14 2013  Added extract of wald test of parameter constraints
* Nov 16 2013  Added po(string) option, to process output only
* Nov 16 2013  Fixed issue in read_convergence. Mplus apparently no longer automatically
*              reports when the model estimation terminates normally, in all model types
* Nov 22 2013  Added Data Missing command
* Jan 01 2015  Added aux shortcut
* Mar 01 2015  Added read_parameterestimates_indirect which reads and returns MODEL INDIRECT output
* Jun 13 2019  Update contributed to SSC. Minor bug fixes.
capture program drop runmplus
program define runmplus , rclass
version 10
  #d ;
  syntax [varlist] [if] [in] ,
          [ debug po(string)
            TScores(string)
            TItle(string)
            DATa(string)
            DATAMissing(string)
            VARiable(string)
            DEFine(string)
            ANalysis(string)
            MOdel(string)
            OUTput(string)
            SAVEdata(string)
            PLOT(string)
            MONTECARLO(string)
            DATAIMPUTATION(string)
            MC(string)
            SAVEINPutfile(string)
            SAVELOGfile(string)
            SAVEINPUTDATAfile(string)
            log(string)
            SUBPOPulation(string)
            STRATification(string)
            wgt(string)
            wtscale(string)
            CLUSter(string)
            variance(string)
            iterations(string)
            sditerations(string)
            h1iterations(string)
            miterations(string)
            mciterations(string)
            muiterations(string)
            convergence(string)
            h1convergence(string)
            coverage(string)
            logcriterion(string)
            mconvergence(string)
            mcconvergence(string)
            muconvergence(string)
            mixc(string)
            mixu(string)
            loghigh(string)
            loglow(string)
            ucellsize(string)
            algorithm(string)
            integration(string)
            missing(int -9999)
            NGroups(string)
            CATegorical(string)
            tech(string)
            GROUPing(string)
            IDvariable(string)
            within(string)
            between(string)
            centering(string)
            type(string)
            ESTimator(string)
            MATrix(string)
            PARAMeterization(string)
            MODindices(string)
            population(string)
            AUXiliary(string)
            CLASSes(string)
            modelmissing(string)
            * ] ;
#d cr

if "`aux'" ~= "" & "`auxiliary'" == "" {
   local auxiliary "`aux'"
}


#d ;
if "`debug'"=="debug" { ;
   noisily di in green "debugging mode: review of submitted options" _n ;
   foreach x in  
            algorithm
            analysis
            auxiliary
            aux
            between
            categorical
            centering
            classes
            cluster
            convergence
            coverage
            data
            dataimputation
            datamissing
            debug 
            define
            estimator
            grouping
            h1convergence
            h1iterations
            idvariable
            if 
            in  
            integration
            iterations
            log
            logcriterion
            loghigh
            loglow
            matrix
            mc
            mcconvergence
            mciterations
            mconvergence
            missing
            miterations
            mixc
            mixu
            model
            modelmissing
            modindices
            montecarlo
            muconvergence
            muiterations
            ngroups
            output
            parameterization
            plot
            po
            population
            savedata
            saveinputdatafile
            saveinputfile
            savelogfile
            sditerations
            stratification
            subpopulation
            tech
            title
            tscores
            type
            ucellsize
            variable
            variance
            varlist 
            wgt
            within
            wtscale 
            options { ;
      if "`x'"~="" { ;
         di _col(5) in green "`x'" _col(23) "->" _col(27) in yellow "``x''" ;
      } ; /* close if */
   } ; /* close foreach x */
} ; /* close if debug */

#d cr
 


   
local omatsize=`c(matsize)'


if "`po'"=="" { // only do the model setup and running mplus steps if po option not specified
* po option will skip right to the output processing of the file specified in the (string)
* part of po
* RNJ 2013 Nov 16

preserve


local varlist "`varlist' `cluster'  `auxiliary' `aux' `idvariable' "
local varlist : list uniq varlist
local numvars = wordcount("`varlist'")
local novarlist=0
if `numvars'==0 {
   local novarlist=1
}



* 18-May-2010
* too many options, had to move to anything
foreach x in ///
   SAMPStat samps ///
   STANDardized stand ///
   RESidual res ///
   FSDETerminacy fsdet ///
   FSCOEFficeint fscoef ///
   CINTerval cint ///
   NOCHIsquare nochi ///
   H1TEch3 h1te ///
   PATterns pat ///
   h1se varnocheck ///
   demo7 demo6 demo4 ///
   version5 version6 ///
   debug ///
   extractmatrices {
   local foo=lower("`x'")
   if regexm(lower("`options'"),lower("`x'"))==1 {
      local `foo' = "`x'"
   }
}

if "`debug'"=="debug" {
   di in green "demo5" _col(20) " -> " in yellow "`demo5'"
   di in green "demo6" _col(20) " -> " in yellow "`demo6'"
   di in green "demo7" _col(20) " -> " in yellow "`demo7'"
   di in green "version3" _col(20) " -> " in yellow "`version3'"
   di in green "version4" _col(20) " -> " in yellow "`version4'"
   di in green "version5" _col(20) " -> " in yellow "`version5'"
   di in green "version6" _col(20) " -> " in yellow "`version6'"
}


local agrp "samps    stand        res      fsdet         fscoef        cint      noch        h1te    pat"
local bgrp "sampstat standardized residual fsdeterminacy fscoefficeint cinterval nochisquare h1tech3 patterns"
local n : word count `agrp'
forvalues i = 1/`n' {
   local a : word `i' of `agrp'
   local b : word `i' of `bgrp'
   if "``a''"=="`a'" {
      local `b' = "`b'"
   }
}


* check for summary data, monte carlo
#d ;
if "`mc'"~="" | "`montecarlo'"~="" |
   strpos("`data'","imputation")>0 |
   strpos("`data'","montecarlo")>0 |
   strpos("`data'","covar")>0 |
   strpos("`data'","corr")>0 |
   strpos("`data'","fullc")>0 |
   strpos("`data'","means")>0 |
   strpos("`data'","std")>0 { ;
   *local novarlist=1 ;
   *local varlist="" ;
} ;
#d cr

*flag for data type imputation
lstrfun  isdatatypeimputation,   strpos(`"`data'"', "imputation")
if `isdatatypeimputation'~=0 {
   local isdatatypeimputation = 1
}

* if a montecarlo run is requested, strike the varlist
* or if type=imputation
if ("`mc'"~="" | "`montecarlo'"~="") {
   local varlist = ""
}

if "`isdatatypeimputation'"=="1" {
   local varlist = ""
   local novarlist=1
}

if "`varlist'"~="" | "`novarlist'"~="1" {
   qui marksample touse, novarlist
   qui keep if `touse'
   order `varlist'
   keep `varlist'
   * convert char to numeric
   foreach var of local varlist {
      local vartype : type `var'
      if (substr("`vartype'",1,3)=="str") {
         display "encoding `var'"
         tempvar tempenc
         encode `var', generate(`tempenc')
         drop `var'
         rename `tempenc' `var'
       }
      * added 6-27-2008
      if (substr("`vartype'",1,3)~="str") {
         qui recast float `var'
       }

    }
    foreach var of local varlist {
       quietly replace `var' = `missing' if `var' >= .
    }
    tempname using
    *capture erase `using'.dat
    qui outsheet `varlist' using `using'.dat  , comma nonames nolabel replace
}

* added 5/31/2011
if "`using'"=="" {
   tempname using
}

tempvar out
qui {
   capture file close `out'
   capture erase `using'.inp
   file open `out' using "`using'.inp", write text
}

*
* ------------------- TITLE -------------------
*
file write `out' "TITLE: " _newline
if "`title'"~="" {
   lw , out(`out') line(`"`title'"')
}

if "`varlist'"~=""|"`novarlist'"=="1" {
   file write `out' "  Variable List - " _newline
   file write `out' _newline
   quietly count
   local ncases = `r(N)'
   foreach var of local varlist {
      makelab `var' `out' `ncases'
   }
   file write `out' " " _newline

   *
   * ------------------- DATA
   *
   file write `out' "DATA: " _newline
   * added 10-5-2006
   if "`varnocheck'"=="varnocheck" {
      file write `out' "  VARIANCES = nocheck ; " _newline
   }
   if "`varlist'"~="" | "`novarlist'"~="1" {
      file write `out' "  FILE = `pwd'""`using'.dat ;" _newline
      local wrotedata=1
   }
   if "`data'"~="" {
      if strpos("`data'","file")==0 {
         if "`wrotedata'"~="1" {
            file write `out' "  FILE = `pwd'""`using'.dat ;" _newline
         }
      }
   }
   if "`data'"~="" {
      tokenize `data' , parse(";")
      while "`1'"~="" {
         if "`1'"~=";" {
            *file write `out' "   `1' ; " _n
            lw , out(`out') line(`"`1'"')
         }
         mac shift 1
      }
      file write `out' " " _newline
   }

   * ------------------- VARIABLE
   *
   * added July 26 2007
   * Checkpoint - if variable is not blank but does not include the
   * names option, then we presume what is in variable is to be appended
   * to what is automatically generated by runmplus. Otherwise, we parse out
   * what is in the variable command and ignore automatically generated stuff

   local test278=0
   if "`montecarlo'"~="" { // added 12-15-2011
      local test278=1
   }
   if "`varlist'"=="" {
      local test278=1
   }
   *if regexm(lower("`varlist'"),"name")==0 {
   *   local test278=1
   *}
   if "`isdatatypeimputation'"=="1" {
      local test278=1
   }

   *noisily {
   *   foreach x in montecarlo varlist isdatatypeimputation test278 {
   *      di "`x'" _col(30) "-> ``x''"
   *   }
   *}


   *if ("`variable'"=="" | regexm(lower("`variable'"),"name")==0) ///
   *   | "`isdatatypeimputation'"=="1" {
   if "`test278'"~="1" {
         *noisily di in red "got here"
         file write `out' "VARIABLE:" _newline
         if "`varlist'"~="" {
            file write `out' "  NAMES = " _newline "    "
            local len = 0
            lw , out(`out') line(`"`varlist'"')
         }
         file write `out' "  MISSING ARE ALL (`missing') ; " _newline
         if regexm(lower("`variable'"),"usevar")==0 {
            ** 03/15/2011
            ** Added option to put in usevariables if aux is specified
            if "`auxiliary'" ~= "" {
               local avars "`varlist'"
               local avars : list avars - auxiliary
               local avars : list avars - idvariable
               file write `out' "  USEVARIABLES =" _newline "    "
               local len = 0
               lw , out(`out') line(`"`avars'"')
         }
         }

         if "`categorical'"~="" {
            file write `out' "  CATEGORICAL = " _newline
            tokenize `categorical'
            while "`1'"~="" {
               file write `out' "    `1'" _newline
               mac shift 1
            }
            file write `out' "    ;" _n
         }
         if "`grouping'"~="" {
            file write `out' "  GROUPING = "
            lw , out(`out') line(`"`grouping'"')
         }
         if "`idvariable'" ~= "" {
            file write `out' "  IDVARIABLE = `idvariable' ;" _newline
         }
            if "`wgt'" ~= "" {
            file write `out' "  weight = `wgt' ;" _newline
         }
         if "`wtscale'" ~= "" {
            file write `out' "  wtscale = `wtscale' ;" _newline
         }
         if "`cluster'" ~= "" {
            file write `out' "  CLUSTER = `cluster' ;" _newline
         }
         if "`subpopulation'" ~= "" {
            file write `out' "  SUBPOPULATION = `subpopulation' ;" _newline
         }
         if "`stratification'" ~= "" {
            file write `out' "  STRATIFICATION = `stratification' ;" _newline
         }
         if "`within'" ~= "" {
            file write `out' "  WITHIN = " _n
            lw , out(`out') line(`"`within'"')
         }
         if "`between'" ~= "" {
            *file write `out' "  BETWEEN = `between' ;" _newline
            file write `out' "  BETWEEN = " _n
            lw , out(`out') line(`"`between'"')

         }
         if "`tscores'" ~= "" {
            *file write `out' "  TSCORES = `tscores' ;" _newline
            file write `out' "  TSCORES = " _n
            lw , out(`out') line(`"`tscores'"')
      }

      * added 6-10-2008
      if "`auxiliary'" ~= "" {
         *** 2-24-2011 file write `out' "  AUXILIARY = `auxiliary' ;" _newline
         file write `out' "  AUXILIARY = " _newline
         lw , out(`out') line(`"`auxiliary'"')
      }
      * end edited 6-10-2008

      if "`centering'" ~= "" {
         file write `out' "  CENTERING = `centering' ;" _newline
      }
      if "`patternvariable'" ~= "" {
         file write `out' "  PATTERNVARIABLE = `patternvariable' ;"          _newline
      }
      if "`cohort'" ~= "" {
         file write `out' "  COHORT = `cohort' ;" _newline
      }
      if "`copattern'" ~= "" {
         file write `out' "  COPATTERN = `copattern' ;" _newline
      }
      if "`cohrecode'" ~= "" {
         file write `out' "  COHRECODE = `cohrecode' ;" _newline
      }
      if "`timemeasures'" ~= "" {
         file write `out' "  TIMEMEASURES = `timemeasures' ;" _newline
      }
      if "`tnames'" ~= "" {
         file write `out' "  TNAMES = `tnames' ;" _newline
      }
      if "`classes'" ~= "" {
         file write `out' "  CLASSES = `classes' ;" _newline
      }
      if "`training'" ~= "" {
         file write `out' "  TRAINING = `training' ;" _newline
      }
      if "`ttype'" ~= "" {
         file write `out' "  TTYPE = `ttype' ;" _newline
      }
   }
   if "`variable'"~="" {
      * VARIABLE: only gets written if variable is not blank AND DOES
      * include the keyword name
      if regexm(lower("`variable'"),"name")==1  {
         file write `out' "VARIABLE:" _newline
      }
      tokenize `variable' , parse(";")
      while "`1'"~="" {
         if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
         }
         mac shift 1
      }
      file write `out' " " _newline
   }
   *
   * ------------------- DEFINE
   *
   if "`define'"~="" {
      file write `out' "DEFINE: " _newline
      tokenize `define' , parse(";")
      while "`1'"~="" {
         if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
         }
         mac shift 1
      }
      file write `out' " " _newline
   }

} // closes the condition on a varlist being specified

*
* ------------------- ANALYSIS
*
file write `out' "ANALYSIS: " _newline
foreach field in ///
   type         estimator     matrix        parameterization    ///
   variance     iterations sditerations  h1iterations         ///
   miterations    mciterations  muiterations         ///
   convergence  h1convergence coverage      logcriterion         ///
   mconvergence mcconvergence muconvergence mixc                 ///
   mixu         loghigh       loghigh       loglow               ///
   ucellsize    algorithm     integration   {
   if "``field''"~="" {
      local __x1 = upper("`field'")
      file write `out' "   `__x1' = ``field'' ;" _newline
   }
}
if "`analysis'"~="" {
   tokenize `analysis' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}

*
* ------------------- OUTPUT
*
file write `out' "OUTPUT: " _newline
if "`modindices'"~="" {
   file write `out' "   MODINDICES(`modindices'); " _n
}


foreach field in ///
   sampstat   standardized   residual   cinterval   nochisquare ///
   h1se       h1tech3        patterns   fscoefficeint   fsdeterminacy   {
   if "``field''"~="" {
      local __x1 = upper("`field'")
      file write `out' "   `__x1' ;" _newline
   }
}

if "`tech'"~="" {
   tokenize `tech'
   while "`1'"~="" {
      file write `out' "  TECH`1' " _newline
      mac shift 1
   }
}

if "`output'"~="" {
   tokenize `output' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}


*
* ------------------- PLOT
*
if "`plot'"~="" {
   file write `out' "PLOT: " _newline
   tokenize `plot' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}

*
* ------------------- SAVEDATA
*
if "`savedata'"~="" {
   file write `out' "SAVEDATA: " _newline
   tokenize `savedata' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}


*
* ------------------- MONTECARLO
*
if "`montecarlo'"~="" & "`mc'"~="" {
   di in red "please use the montecarlo command or the mc command, not both"
   exit
}

if "`montecarlo'"~="" {
  file write `out' "MONTECARLO: " _newline
  tokenize `montecarlo' , parse(";")
  while "`1'"~="" {
     if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
        }
     mac shift 1
     }
  file write `out' " " _newline
}

if "`mc'"~="" {
  file write `out' "MONTECARLO: " _newline
  tokenize `mc' , parse(";")
  while "`1'"~="" {
     if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
        }
     mac shift 1
     }
  file write `out' " " _newline
}


* ADDED 7-27-2006 
*
* ------------------- MODEL POPULATION 
*
***** file write `out' "MODEL: " _newline
***** tokenize "`model'" , parse(";")
***** while "`1'"~="" {
*****    if "`1'"~=";" {
*****             lw , out(`out') line(`"`1'"')
*****    }
*****    mac shift 1
***** }
***** file write `out' " " _newline
***** file close `out'
*****
*****
if "`population'"~="" {
   file write `out' "MODEL POPULATION: " _newline
   tokenize "`population'" , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}

* ADDED 11-22-2013
*
* ------------------- Data MISSING
*
if "`datamissing'"~="" {
   file write `out' "DATA MISSING: " _newline
   tokenize `datamissing' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}
* ADDED 8-20-2013
*
* ------------------- MODEL MISSING
*
if "`modelmissing'"~="" {
   file write `out' "MODEL MISSING: " _newline
   tokenize `modelmissing' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}

* ADDED 8-30-2011
*
* ------------------- DATA IMPUTATION
*
if "`dataimputation'"~="" {
   file write `out' "DATA IMPUTATION: " _newline
   tokenize `dataimputation' , parse(";")
   while "`1'"~="" {
      if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
      }
      mac shift 1
   }
   file write `out' " " _newline
}

*
* ------------------- MODEL
*
file write `out' "MODEL: " _newline
tokenize "`model'" , parse(";")
while "`1'"~="" {
   if "`1'"~=";" {
            lw , out(`out') line(`"`1'"')
   }
   mac shift 1
}
file write `out' " " _newline
file close `out'

* 7-23-2008
* edit the inp file to accomodate %
****
qui {
   tempname newusing
   capture erase `newusing'.inp
   ****
   filefilter `using'.inp `newusing'.inp , from("% ;") to("%") replace
   local nchanges = r(occurrences)
   if `nchanges'>0 {
      erase `using'.inp
      while `nchanges'~=0 {
         filefilter `newusing'.inp `using'.inp , from("% ;") to("%") replace
         filefilter `using'.inp `newusing'.inp , from("% ;") to("%") replace
         local nchanges = r(occurrences)
      }
   }
   erase `using'.inp
   qui copy `newusing'.inp `using'.inp
   erase `newusing'.inp
   ****
   filefilter `using'.inp `newusing'.inp , from("%;") to("%") replace
   local nchanges = r(occurrences)
   if `nchanges'>0 {
      erase `using'.inp
      while `nchanges'~=0 {
         filefilter `newusing'.inp `using'.inp , from("%;") to("%") replace
         filefilter `using'.inp `newusing'.inp , from("%;") to("%") replace
         local nchanges = r(occurrences)
      }
   }
   erase `using'.inp
   qui copy `newusing'.inp `using'.inp
   erase `newusing'.inp
    ****
   filefilter `using'.inp `newusing'.inp , from(\037d) to("#$#") replace
   filefilter `newusing'.inp `using'.inp , from("#$# ") to(\037d\W) replace
   filefilter `using'.inp `newusing'.inp , from("#$#") to(\037d) replace
   erase `using'.inp
   qui copy `newusing'.inp `using'.inp
   erase `newusing'.inp
   ****
   filefilter `using'.inp `newusing'.inp , from(\W\W\W) to(\W\W) replace
   local nchanges = r(occurrences)
   if `nchanges'>0 {
      erase `using'.inp
      while `nchanges'~=0 {
         filefilter `newusing'.inp `using'.inp , from(\W\W\W) to(\W\W) replace
         filefilter `using'.inp `newusing'.inp , from(\W\W\W) to(\W\W) replace
         local nchanges = r(occurrences)
      }
   }
   erase `using'.inp
   qui copy `newusing'.inp `using'.inp
   erase `newusing'.inp
}

if "`saveinputfile'"~="" {
   if "`saveinputdatafile'"~="" {
      saveinp , using(`using') saveinputfile(`saveinputfile') saveinputdatafile(`saveinputdatafile')
   }
   else {
      saveinp , using(`using') saveinputfile(`saveinputfile')
   }
}


* end of new stuff 7-23-2008
** ===================================================== SEND TO MPLUS (Line 616)
*  ------------------- RUN mplus
* demo6 option added 5-17-2010
* demo4 option added 2-14-2011
* version5 option added 2-15-2011
* version6 option added 10-3-2012
* if demo6 is not specified, we'll run a little check anyways
/* Retired this section 5-1-2013
if "`demo7'"~="demo7" |"`demo6'"~="demo6" | "`demo4'"~="demo4" {
   capture confirm file C:\PROGRA~1\MPLUS\Mplus.exe
   if _rc~=0 {
      capture confirm file C:\PROGRA~2\MPLUS\Mplus.exe
      if _rc~=0 {
         capture confirm file C:\PROGRA~1\MPLUSD~1\Mpdemo6.exe
         if _rc~=0 {
            capture confirm file C:\PROGRA~2\MPLUSD~1\Mpdemo6.exe
            if _rc==0 {
               local demo6 = "demo6"
            }
            capture confirm file C:\PROGRA~1\MPLUSD~1\Mpdemo7.exe
            if _rc~=0 {
               capture confirm file C:\PROGRA~2\MPLUSD~1\Mpdemo7.exe
               if _rc==0 {
                  local demo7 = "demo7"
               }
               if _rc~=0 {
                  di in red "Can't find mplus.exe or mpdemo#.exe"
               }
            }
         }
      }
   }
}



if "`demo7'"~="demo7" ///
   & "`demo6'"~="demo6" ///
   & "`demo4'"~="demo4" ///
   & "`demo5'"~="demo5" ///
   & "`version5'" ~= "version5" ///
   & "`version6'" ~= "version6" {
   !mplus `using'.inp
}

if "`version5'"=="version5" {
   !mplus5 `using'.inp
}

if "`version6'"=="version6" {
   !mplus6 `using'.inp
}

if "`demo6'"~="" & "`demo4'"~="" & "`version5'"~="" | {
   di in red "only one demo and/or version can be run at a time"
   exit
}


if "`demo7'"=="demo7" | "`demo6'"=="demo6" | "`demo4'"=="demo4" {
   local ver=substr(reverse(itrim("`demo7'`demo6'`demo4'")),1,1)
   capture confirm file C:\PROGRA~1\MPLUSD~1\Mpdemo`ver'.exe
   if _rc==0 {
      !C:\PROGRA~1\MPLUSD~1\Mpdemo`ver' `using'.inp
   }
   if _rc~=0 {
      di in red "can't find the Mpdemo`ver'.exe file, which I thought would" _n ///
                "be in c:\program files\mplus demo\. You might consider" _n ///
                "making sure that file exists in this location. If it exists" _n ///
                "in another location, determine what that is and make the" _n ///
                "appropriate edit to the runmplus.ado file, line #590."
  }
}
*/

* find Mplus executable
* Windows only
if "`c(os)'"~="Windows" {
   if "$mplus_path"=="" {
      global mplus_path "/applications/mplus/mplus"
      local mplusexe "/applications/mplus/mplus"
   }
   else {
      local mplusexe "$mplus_path"
   }
}

if "$mplus_path"=="" { // if the mplus_path has not be set, for example in profile.do
   cap confirm file c:\progra~1\mplus\mplus.exe
   if _rc==0 {
      global mplus_path "c:\progra~1\mplus\mplus.exe"
   }
   if _rc~=0 {
      cap confirm file c:\progra~2\mplus\mplus.exe
      if _rc==0 {
         global global mplus_path "c:\progra~2\mplus\mplus.exe"
      }
   }
}
* demo version
forvalues i=4/7 {
   if ("$mplus_path"=="" | "$mplusdemo`i'_path"=="")|"`demo`i''"~="" {
      foreach j in 1 2 {
         cap confirm file c:\progra~`j'\mplusd~1\mpdemo`i'.exe
         if _rc==0 {
            if "$mplus_path"=="" {
               global mplus_path "c:\progra~`j'\mplusd~1\mpdemo`i'.exe"
            }
            global mplusdemo`i'_path "c:\progra~`j'\mplusd~1\mpdemo`i'.exe"
            if "`demo`i''"=="demo`i'" { // if demo version specifically requested
               if `i'==4 {
                  local mplusexe "$mplusdemo4_path"
               }
               if `i'==5 {
                  local mplusexe "$mplusdemo5_path"
               }
               if `i'==6 {
                  local mplusexe "$mplusdemo6_path"
               }
               if `i'==7 {
                  local mplusexe "$mplusdemo7_path"
               }
            }
         }
      }
   }
}
* legacy version
if "`version1'"=="version1" { // if old version specifically requested
   if "$mplus1_path"=="" { // only if path to old version not already set, for e.g., in profile.do
      foreach j in 2 1 {
         cap confirm file c:\progra~`j'\mplus1\mplus.exe
         if _rc==0 {
            global mplus1_path "c:\progra~`j'\mplus1\mplus.exe"

         }
      }
   }
   local mplusexe "$mplus1_path"
}

if "`version2'"=="version2" { // if old version specifically requested
   if "$mplus2_path"=="" { // only if path to old version not already set, for e.g., in profile.do
      foreach j in 2 1 {
         cap confirm file c:\progra~`j'\mplus2\mplus.exe
         if _rc==0 {
            global mplus2_path "c:\progra~`j'\mplus2\mplus.exe"

         }
      }
   }
   local mplusexe "$mplus2_path"
}

if "`version3'"=="version3" { // if old version specifically requested
   if "$mplus3_path"=="" { // only if path to old version not already set, for e.g., in profile.do
      foreach j in 2 1 {
         cap confirm file c:\progra~`j'\mplus3\mplus.exe
         if _rc==0 {
            global mplus3_path "c:\progra~`j'\mplus3\mplus.exe"

         }
      }
   }
   local mplusexe "$mplus3_path"
}

if "`version4'"=="version4" { // if old version specifically requested
   if "$mplus4_path"=="" { // only if path to old version not already set, for e.g., in profile.do
      foreach j in 2 1 {
         cap confirm file c:\progra~`j'\mplus4\mplus.exe
         if _rc==0 {
            global mplus4_path "c:\progra~`j'\mplus4\mplus.exe"

         }
      }
   }
   local mplusexe "$mplus4_path"
}

if "`version5'"=="version5" { // if old version specifically requested
   if "$mplus5_path"=="" { // only if path to old version not already set, for e.g., in profile.do
      foreach j in 2 1 {
         cap confirm file c:\progra~`j'\mplus5\mplus.exe
         if _rc==0 {
            global mplus5_path "c:\progra~`j'\mplus5\mplus.exe"

         }
      }
   }
   local mplusexe "$mplus5_path"
}

if "`version6'"=="version6" { // if old version specifically requested
   if "$mplus6_path"=="" { // only if path to old version not already set, for e.g., in profile.do
      foreach j in 2 1 {
         cap confirm file c:\progra~`j'\mplus6\mplus.exe
         if _rc==0 {
            global mplus6_path "c:\progra~`j'\mplus6\mplus.exe"
            ** this was here
         }
      }
   }
   local mplusexe "$mplus6_path" // now it is here 20130730
   if "`debug'"=="debug" {
      noisily di "version6 was called"
      noisily di "$mplus6_path <- Mplus version 6 path"
      noisily di "`mplusexe' <- local mplusexe"
   }

}

* Note:
* if both a specific version is requested AND a specific demo version requested,
* the version trumps the demo call. Here we produce an error notice if
* this conflict exists
local check813=0
forvalues i=1/12 { // robust to version 12
  foreach x in version demo {
     if "``x'`i''"~="" {
        local check813=`check813'+1
     }
  }
}
if `check813'>1 {
   qui {
      noisily di in red _n ///
         "   please specify only one legacy version or one demo version" _n
   }
   exit
}


if "`mplusexe'"=="" {
   local mplusexe "$mplus_path"
}

if "`mplusexe'"=="" {
   qui {
      noisily di in red _n ///
         "   runmplus.ado can't find the right mplus executable" _n ///
         "   after looking in some likely places. You can avoid this" _n ///
         "   error by setting a global called mplus_path in your " _n ///
         "   profile.do See example at "
      noisily di as txt `"   {browse "https://sites.google.com/site/ifarwf/home/your-profiledo"}"'
   }
   exit
}

* final check to make sure Mplus executable found
* windows only
if "`c(os)'"=="Windows" {
   cap confirm file `mplusexe'
   if _rc~=0 {
      qui {
         noisily di in red _n ///
            "   runmplus.ado can't find the right mplus executable" _n ///
            "   after looking in some likely places. You can avoid this" _n ///
            "   error by setting a global called mplus_path in your " _n ///
            "   profile.do See example at "
         noisily di as txt `"   {browse "https://sites.google.com/site/ifarwf/home/your-profiledo"}"'
      }
      exit
   }
}

* end of looking for Mplus executable

* run Mplus
!`mplusexe' `using'.inp

* Not sure if I need this bracket x}x

} // this closes the if po!="" condition


* new 20131116
if "`po'"~="" { 
   preserve
   
   * if po is specified, take that file specified in string and and use it as the output
   tempname using
   qui copy `po' `using'.out , replace public
   if "`debug'"=="debug" {
      noisily di in red "GOt here"
      noisily di "local po -> `po'"
      noisily di "local using -> `using'.out"
      noisily cap confirm file `using'.out
   }
   
   * isdatatypeimputation
   if "`isdatatypeimputation'"=="" {
      local isdatatypeimputation=0
      *
      tempname fh
      local linenum = 0
      file open `fh' using `"`using'.out"', read
      file read `fh' line
      while r(eof)==0 & "`isdatatypeimputation'"~="1" {
         local linenum = `linenum' + 1
         if regexm(lower(`"`macval(line)'"'),"data imputation")==1 | ///
            regexm(lower(`"`macval(line)'"'),"multiple data files from")==1 {
            local isdatatypeimputation=1
            local foo=1
            return local fooisdatatypeimputation `foo'
         }
         file read `fh' line
      }
      file close `fh'
   }
}




* 5/15/2011 added read_errors
* di `"read_errors `using'.out"'
read_errors `using'.out
if "`r(error)'"=="1" {
   exit
}


   
* ------------------- SAVE OUTPUT FILE IF REQUESTED TO DO SO
if "`savelogfile'"~="" {
   qui copy `using'.out "`savelogfile'.out" , replace // thanks to Elan Cohen MS
}

************************************************************************************
************************************************************************************
************************************************************************************
**************************                               ***************************
**************************  START OF OUTPUT PROCESSING   ***************************
**************************                               ***************************
************************************************************************************
************************************************************************************
************************************************************************************
************************************************************************************

**** Added 20101003 montecarlo condition


** need seperate processing of multiple imputation output
if `isdatatypeimputation'==1 {
   qui infix str line 1-85 using `using'.out , clear
   *qui infix str line 1-85 using trash.out , clear
   format line %85s
   gen linenum=_n
   * fit statistics
   gen numberofsuccessfulcomputations=linenum if substr(line,1,33)=="Number of successful computations"
   qui levelsof numberofsuccessfulcomputations , clean
   if "`debug'"=="debug" {
      di in red "inside multiple imputation output processing"
      di in red "`r(levels)'"
   }
   foreach x in `r(levels)' {
      local w=`x'-4
      local fitstat=lower(word(line[`w'],1))
      if "`debug'"=="debug" {
         noisily di "`fitstat'<-fitstat"
      }
      if "`fitstat'"~="" {
         if substr("`fitstat'",1,7)=="degrees" {
            local fitstat="chisquare"
            local chisquaredf=substr("`fitstatline'",42,10)
         }
         local w=`w'+2
         local fitstatmean=reverse(word(reverse(line[`w']),1))
         local w=`w'+1
         local fitstatsd=reverse(word(reverse(line[`w']),1))
         local w=`w'+1
         local fitstatnsc=reverse(word(reverse(line[`w']),1))
         return local `fitstat' = `fitstatmean'
         return local `fitstat'sd = `fitstatsd'
         return local `fitstat'nsc = `fitstatnsc'
      }
   }
   * new 10-16-2013      
   * wald test
   local i=0
   while `i'<`c(N)' {
      if substr(trim(line[`++i']),1,34)=="Wald Test of Parameter Constraints" {
         local j=`i'+2
         local k=`i'+3
         local l=`i'+4
         return local WaldTest    = reverse(word(reverse(line[`j']),1))
         return local WaldTest_df = reverse(word(reverse(line[`k']),1))
         return local WaldTest_P  = reverse(word(reverse(line[`l']),1))
         local i=`c(N)'
      }
   }
   local i=0
   while `i'<`c(N)' {
      if substr(trim(line[`++i']),1,25)=="Number of Free Parameters" {
         return local free_parameters = reverse(word(reverse(line[`i']),1))
         local i=`c(N)'
      }
   }
   

         

   **** local MS=_N
   **** if `ms'>800 {
   ****       capture set matsize `MS'
   **** }

   if "`debug'"=="debug" {
      noisily di in yellow _n "This is line 1252 of runmplus.ado and" ///
         _n "you are about to call " in green "read_parameterestimates_general" _n _n
   }
   read_parameterestimates_general , out(`using'.out) `debug' `extractmatrices'
   if "`r(outmatrices)'"~="" {
      foreach x in `r(outmatrices)' {
         matrix `x' = r(`x')
         cap return mat `x' = `x'
      }
   }
   cap matrix StdEstimates = r(StdEstimates)
   cap return matrix StdEstimates = StdEstimates
   matrix estimate = r(estimate)
   matrix se = r(se)
   cap matrix z = r(z)
   if _rc==0 {
      matrix z = z
      return matrix z = z
   }

   capture matrix CI = r(CI)
   capture return matrix CI = CI
   return matrix estimate = estimate
   return matrix se = se
   read_residual_variance , out(`using'.out) `debug'
   cap matrix residual_variance = r(residual_variance)
   cap return matrix residual_variance = residual_variance
   local note "output processing for multiple imputation"
   return local note "`note'"

   * Added 20150301
   if "`debug'"=="debug" {
      noisily di in yellow _n "This is line 1285 of runmplus.ado and" ///
         _n "you are about to call " in green "read_parameterestimates_indirect" _n _n
   }
   read_parameterestimates_indirect , out(`using'.out) 
   if "`r(outmatrices)'"~="" {
      foreach x in `r(outmatrices)' {
         matrix `x' = r(`x')
         cap return mat `x' = `x'
      }
   }
   * End added 20150301

} // close output processing for multiple imputation

if "`mc'"=="" & "`montecarlo'"=="" & `isdatatypeimputation'==0 {
   * 28APR2010
   * NEW MATERIAL FOR VERSION 6
   * SPECIAL OUTPUT PROCESSING FOR BAYESIAN ESTIMATION
   * Step 1 read output and determine if estimator was bayes
   qui infix str line 1-85 using `using'.out , clear
   format line %85s
   * edit 8/21/2013
   gen keep=trim(line)=="Specifications for Bayesian Estimation" // regexm(line,"BAYES") & regexm(line,"Estimator")
   qui su keep
   local BAYES = 0
   if r(max)==1 {
      local BAYES=1
   }
   drop keep
   ************************************************************************************
   **************************                               ***************************
      *********************  BAYES ESTIMATION OF OUTPUT PROCESSING   *********************
   **************************                               ***************************
   ************************************************************************************
   if `BAYES'==1 {
      qui {
         * post-processing for Bayesian estimation
         * first model and fits info
         * chi-square confidence interval not reported, should be added
         local z=0
         local keeper`++z' = "Number of groups"
         local keeper`++z' = "Number of observations"
         local keeper`++z' = "Number of dependent variables"
         local keeper`++z' = "Number of independent variables"
         local keeper`++z' = "Number of continuous latent variables"
         local keeper`++z' = "Estimator"
         local keeper`++z' = "Point estimate"
         local keeper`++z' = "Number of MCMC chains"
         local keeper`++z' = "Random seed for the first chain"
         local keeper`++z' = "Starting value information"
         local keeper`++z' = "Treatment of categorical mediator"
         local keeper`++z' = "Algorithm used for Markov chain Monte Carlo"
         local keeper`++z' = "Convergence criterion"
         local keeper`++z' = "Maximum number of iterations"
         local keeper`++z' = "Kth iteration used for thinning"
         local keeper`++z' = "Minimum covariance coverage value"
         local keeper`++z' = "Number of Free Parameters"
         local keeper`++z' = "Posterior Predictive PValue"
         replace line = regexr(line,"Markov chain Monte Carlo (MCMC)","MCMC")
         replace line = regexr(line,"K-","K")
         replace line = regexr(line,"P-","P")
         gen keep=.
         forvalues y=1/`z' {
            replace keep=regexm(line,"`keeper`y''") if keep~=1
         }
         keep if keep==1
         gen value=reverse(word(reverse(line),1))
         *di "`z'"
         *list line value
         while _N>1 {
            forvalues y=1/`z' {
               local value=value
               local line=line
               ** di "`line'"
               ** di "`value'"
               ** list line
               local vl=length("`value'")+1
               ** di "`vl'"
               local line = reverse(substr(reverse("`line'"),`vl',.))
               ** di "`line'"
               local line=itrim("`line'")
               ** di "`line'"
               local line=trim("`line'")
               ** di "`line'"
               local line=subinstr("`line'"," ","_",.)
               ** di "`line'"
               local line = substr("`line'",1,30)
               return local `line' = "`value'"
               drop if _n == 1
            }
         }
         * now parameter estimates
         * hack of read_parameterestimates_general.ado
         * Read in Mplus output file and load parameter estimtes
         drop _all
         qui infix str line 1-85 ///
               str name 1-19 ///
               str value 20-85 ///
               using `using'.out
         format line %85s
      * IDENTIFY START AND END OF Parameter estimates
         gen linenum=_n
         gen x1=_n if ///
             trim(line)=="MODEL RESULTS"
         gen x2=_n if ///
            (substr(trim(line),1,15)=="Beginning Time:") | ///
            ( ///
               substr(        trim(line), 1,9)=="TECHNICAL" & ///
               substr(reverse(trim(line)),1,6)==reverse("OUTPUT") ///
            ) | ///
            (substr(trim(line),1,28)=="RESULTS IN PROBABILITY SCALE")
         qui su x2
         replace x1=x2 if x1==. & x2==`r(min)'
         summarize x1
         keep if inrange(linenum,r(min)+1,r(max)-1)
         drop if trim(line)==""
         drop x1
         drop linenum
         gen linenum = _n
         * cleanup
         drop if substr(trim(line),1,9)=="Posterior"
         drop if substr(trim(line),1,8)=="Estimate"
         * suffix line 1152
         gen suffix= lower(word(trim(line),3)) if wordcount(line)==3 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,12)=="Latent Class")
         replace suffix=suffix[_n-1] if _n>1 & suffix==""
         *prefix
         gen prefix=line if (wordcount(line)==2|wordcount(line)==1) & (wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,12)=="Class"))~=1
         replace prefix=lower(prefix)
         replace prefix=prefix[_n-1] if _n>1 & prefix==""
         * Second prefix
         gen eset =""
         replace eset = line if substr(trim(line),1,21)=="STDYX Standardization"
         replace eset = line if substr(trim(line),1,20)=="STDY Standardization"
         replace eset = line if substr(trim(line),1,19)=="STD Standardization"
         replace eset = "r-square" if substr(trim(line),1,8)=="R-SQUARE"
         replace eset = lower(eset)
         replace eset = subinstr(eset,"standardization","",.)
         replace eset = eset[_n-1] if _n>1 & eset==""
         * parameter
         * different if parameter is latent class proportion
         gen parameter = lower(word(trim(line),1)) if ///
            (wordcount(line)<4)~=1 | ///
            (substr(trim(line),1,5)=="Group")~=1 | ///
            (substr(trim(line),1,5)=="Class")~=1 
         replace parameter = lower(word(trim(line),1)) + lower(word(trim(line),2)) if ///
            (wordcount(line)>4) & ///
            (substr(trim(line),1,5)=="Class")==1 
         * estimate
         gen estimate=word(trim(line),2) if (substr(trim(line),1,5)=="Class")~=1 
         gen sd=word(trim(line),3) if (substr(trim(line),1,5)=="Class")~=1 
         gen pv=word(trim(line),4) if (substr(trim(line),1,5)=="Class")~=1 
         gen lci=word(trim(line),5) if (substr(trim(line),1,5)=="Class")~=1 
         gen uci=word(trim(line),6) if (substr(trim(line),1,5)=="Class")~=1 
         replace estimate=word(trim(line),3) if (substr(trim(line),1,5)=="Class")==1 
         replace sd=word(trim(line),4) if (substr(trim(line),1,5)=="Class")==1          
         replace pv=word(trim(line),5) if (substr(trim(line),1,5)=="Class")==1 
         replace lci=word(trim(line),6) if (substr(trim(line),1,5)=="Class")==1 
         replace uci=word(trim(line),7) if (substr(trim(line),1,5)=="Class")==1 
         foreach foo in estimate sd pv lci uci {
            replace `foo'=" " if estimate=="Undefined"
         }
         foreach foo in estimate sd pv lci uci {
            destring `foo', force replace
         }
         drop if estimate==.
         drop if sd==. & eset~="r-square"
         drop if eset=="r-square" & real(word(line),2)==.
         *gen x = eset + " " + prefix + " " + parameter + " " + suffix 
         gen x = eset + " " + prefix + " " + parameter + " " + suffix if lower(prefix)~="class proportions"
         replace x = eset + " " + prefix + " " + parameter if lower(prefix)=="class proportions"
         replace x= eset + " " + word(line,1) + suffix if eset=="r-square"
         replace x=lower(x)
         replace x=trim(x)
         replace x=itrim(x)
         replace x = subinstr(x,"observed two-tailed","",.)
         replace x=itrim(x)
         replace x = subinstr(x,"new/additional parameters","new",.)
         * added 1/2/2009 by Frances Yang
         drop if regexm(x,"category")==1
         destring estimate , replace
         destring sd , replace
         keep x estimate sd pv lci uci
         foreach foo in estimate sd pv lci uci {
            capture matrix drop `foo'
         }
         **** local MS=_N
         **** if `MS'>800 {
         ****    capture set matsize `MS'
         ****    if _rc==0 {
         ****       set matsize `MS'
         ****    }
         **** }
         foreach foo in estimate sd pv lci uci {
            mkmat `foo' , rownames(x)
         }
         mat se = sd
         mat ci = lci, uci
         foreach foo in estimate sd se pv ci {
            return matrix `foo' = `foo'
         }
      }
   }

   ************************************************************************************
   **************************                               ***************************
   ***************************  NON-BAYES OUTPUT PROCESSING   *************************
   **************************                               ***************************
   ************************************************************************************

   if `BAYES'~=1 {
      * stuff in this section is prior to 28APR2010
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      * BEGIN MODEL TERMINATION DISPLAY COMMAND SECTION
      * Read in MPLUS log file and
      * display line if model estimation terminated normally
      * Read in stata log file and
      * display fit statistics
      * create dictionary file
      * NOTE: not relevant for EFA, at least
      local out = "`using'"+".out"

      * new 12/3/2011
      * fit statistics for EFA
      if substr(lower("`type'"),1,3)=="efa" {
         qui infix str line 1-85 using `out' , clear
         format line %85s
         gen linenum=_n
         *mata: out = cat("`out'")
         * identify number of efa solutions
         local m=0
         local mlist ""
         local slist ""
         *set trace on
         local efais "efa"
         local mlist0 : list type - efais
         local mlist01 : word 1 of `mlist0'
         local mlist02 : word 2 of `mlist0'
         keep if substr(trim(lower(line)),1,32)=="exploratory factor analysis with"
         foreach q of numlist `mlist01'/`mlist02' {
            forvalues l=1/`c(N)' {
               if trim(lower(line[`l']))=="exploratory factor analysis with `q' factor(s):" {
                  local m=`m'+1
                  local mlist "`mlist' `q'"
                  local sis = linenum[`l']
                  local slist "`slist' `sis'"
               }
            }
         }
         qui infix str line 1-85 using `out' , clear
         format line %85s
         if `m'>0 {
            * matrix fitstatistics will hold...fit statistics
            mat fitstatistics=J(13,`m',.)
            mat rownames fitstatistics = CFI RMSEA AIC BIC aBIC Num_Para LoglikH0 LoglikH1 ChiSquareBasln DFBasln ChiSquare DF SRMR
            mat colnames fitstatistics = `mlist'
            * pull out fit statistics solution by solution
            local c=0
            foreach x in `slist' {
               local c=`c'+1
               local span=`x'+50
               foreach l of numlist `x'(1)`span' {
                  * cfi
                  if substr(trim(lower(line[`l'])),1,3)=="cfi" {
                     if substr(trim(lower(line[`l'])),1,4)~="cfi/" {
                        local foo = line[`l']
                        local cfi=real(word("`foo'",2))
                        mat fitstatistics[1,`c']=`cfi'
                     }
                  }
                  macro drop _foo
                  * rmsea
                  if substr(trim(lower(line[`l'])),1,8)=="estimate" {
                     local foo = line[`l']
                     local rmsea = real(word("`foo'",2))
                     mat fitstatistics[2,`c']=`rmsea'
                  }
                  macro drop _foo
                  * aic Akaike
                  if substr(trim(lower(line[`l'])),1,6)=="akaike" {
                     local foo = line[`l']
                     local aic= real(reverse(word(reverse("`foo'"),1)))
                     mat fitstatistics[3,`c']=`aic'
                  }
                  macro drop _foo
                  * bic bayesian
                  if substr(trim(lower(line[`l'])),1,8)=="bayesian" {
                     local foo = line[`l']
                     local bic = real(reverse(word(reverse("`foo'"),1)))
                     mat fitstatistics[4,`c']=`bic'
                  }
                  macro drop _foo
                  * abic sample-size
                  if substr(trim(lower(line[`l'])),1,11)=="sample-size" {
                     local foo = line[`l']
                     local abic = real(reverse(word(reverse("`foo'"),1)))
                     mat fitstatistics[5,`c']=`abic'
                  }
                  macro drop _foo
                  * Number of free parameters
                  if substr(trim(lower(line[`l'])),1,6)=="number" {
                     local foo = line[`l']
                     local number = real(reverse(word(reverse("`foo'"),1)))
                     mat fitstatistics[6,`c']=`number'
                  }
                  macro drop _foo
                  * loglikelihood H0
                  if substr(trim(lower(line[`l'])),1,8)=="h0 value" {
                     local foo = line[`l']
                     local h0ll = real(reverse(word(reverse("`foo'"),1)))
                     mat fitstatistics[7,`c']=`h0ll'
                  }
                  macro drop _foo
                  * Loglikelihood H1
                  if substr(trim(lower(line[`l'])),1,8)=="h1 value" {
                     local foo = line[`l']
                     local h1ll = real(reverse(word(reverse("`foo'"),1)))
                     mat fitstatistics[8,`c']=`h1ll'
                  }
                  macro drop _foo
                  * Chi-square Test of Model Fit (Value, Degrees, P-Value, First is Model Second is Baseline)
                  * third value is srmr
                  if substr(trim(lower(line[`l'])),1,5)=="value" {
                     local foo = line[`l']
                     local value = real(reverse(word(reverse("`foo'"),1)))
                     local test=fitstatistics[9,`c']
                     if `test'==. {
                        mat fitstatistics[9,`c']=`value'
                     }
                     if `test'~=. {
                        local test2=fitstatistics[11,`c']
                        if `test2'==. {
                           mat fitstatistics[11,`c']=`value'
                        }
                        if `test2'~=. {
                           mat fitstatistics[13,`c']=`value'
                        }
                     }
                  }
                  macro drop _foo
                  if substr(trim(lower(line[`l'])),1,7)=="degrees" {
                     local foo = line[`l']
                     local value = real(reverse(word(reverse("`foo'"),1)))
                     local test=fitstatistics[10,`c']
                     if `test'==. {
                        mat fitstatistics[10,`c']=`value'
                     }
                     if `test'~=. {
                        mat fitstatistics[12,`c']=`value'
                     }
                  }
                  macro drop _foo
               }
            }
            mat worsefit=J(3,`m',.)
            mat rownames worsefit  = WorsefitLRT WorsefitDF WorsefitP
            local foo=`m'-1
            local goo=`m'
            while `foo'>0 {
               mat worsefit[1,`foo']=abs(-2*(fitstatistics[7,`goo']-fitstatistics[7,`foo']))
               mat worsefit[2,`foo']=(fitstatistics[6,`goo']-fitstatistics[6,`foo'])
               mat worsefit[3,`foo']=chi2tail((fitstatistics[6,`goo']-fitstatistics[6,`foo']),abs(-2*(fitstatistics[7,`goo']-fitstatistics[7,`foo'])))
               local foo=`foo'-1
               local goo=`goo'-1
             }
            mat fitstatistics = fitstatistics \ worsefit
            return matrix fitstatistics = fitstatistics
            return matrix worsefit = worsefit
         }
      } // end output processing for efa
      * end new 12/3/2011

      if substr(lower("`type'"),1,3)~="efa" { // & "`mc'"~="" & "`montecarlo'"~=""  {

         * new on 8/17/2012
         * for Kate Xu
         * always read the sample size
         * (only works for single group models)
         * "Number of observations"
         tempname fh
         local linenum = 0
         file open `fh' using `"`out'"', read
         file read `fh' line
         while r(eof)==0 & "`bump'"=="" {
            local linenum = `linenum' + 1
            if substr(`"`macval(line)'"',1,22)=="Number of observations" {
               return scalar Number_of_observations = real(substr(`"`macval(line)'"',23,.))
               local bump=1
            }
            file read `fh' line
         }
         file close `fh'


         * another from Kate Xu 9/18/2012
         * display warnings
         * THE STANDARD ERRORS OF THE MODEL PARAMETER ESTIMATES MAY NOT BE
         local linenum = 0
         macro drop _bump
         file open `fh' using `"`out'"', read
         file read `fh' line
         while r(eof)==0 & "`bump'"=="" {
            local linenum = `linenum' + 1
            if (substr(trim(`"`macval(line)'"'),1,63)=="THE STANDARD ERRORS OF THE MODEL PARAMETER ESTIMATES MAY NOT BE") | ///
               (substr(trim(`"`macval(line)'"'),1,65)=="THE STANDARD ERRORS OF THE MODEL PARAMETER ESTIMATES COULD NOT BE") {
               if (substr(trim(`"`macval(line)'"'),1,63)=="THE STANDARD ERRORS OF THE MODEL PARAMETER ESTIMATES MAY NOT BE") {
                  return local warning "Standard errors not trustworthy"
               }
               if (substr(trim(`"`macval(line)'"'),1,65)=="THE STANDARD ERRORS OF THE MODEL PARAMETER ESTIMATES COULD NOT BE") {
                  return local warning "Standard errors not estimated"
               }
               local bump=1
               * but read and write the current line and the next four lines
               di in red `"`macval(line)'"'
               file read `fh' line
               di in red `"`macval(line)'"'
               file read `fh' line
               di in red `"`macval(line)'"'
               file read `fh' line
               di in red `"`macval(line)'"'
               file read `fh' line
               di in red `"`macval(line)'"'
               di in green _n
            }
            file read `fh' line
         }
         file close `fh'



         * end new on 8/17/2012


         read_convergence , out(`out')
         local termination = "`r(termination)'"
         local stop = "`r(stop)'"
         return local termination = "`r(termination)'"
         return local stop = "`r(stop)'"
      }
      ** Get parameter estimates
      ** new 6-23-2008
      if substr(lower("`type'"),1,3)~="efa" & substr(lower(trim("`termination'")),1,6)=="normal" {
         if "`debug'"=="debug" {
            noisily di in yellow _n "This is line 1706 of runmplus.ado and" ///
                                 _n "you are about to call " in green "x_general" _n _n
         }
         read_parameterestimates_general , out(`out') `debug' `extractmatrices'
         *** new 6/29/2011
         if "`r(outmatrices)'"~="" {
            foreach x in `r(outmatrices)' {
               matrix `x' = r(`x')
               cap return mat `x' = `x'
            }
         }
         *** end new 6/29/2011
         matrix estimate = r(estimate)
         matrix se = r(se)
         capture matrix CI = r(CI)
         capture matrix z=r(z)
         capture return matrix CI = CI
         capture return matrix z = z
         capture matrix rsquare = r(rsquare)
         capture return matrix rsquare = rsquare
         return matrix estimate = estimate
         return matrix se = se
         
            * Added 20150301
            if "`debug'"=="debug" {
               noisily di in yellow _n "This is line 1285 of runmplus.ado and" ///
                  _n "you are about to call " in green "read_parameterestimates_indirect" _n _n
            }
            read_parameterestimates_indirect , out(`using'.out) 
            if "`r(outmatrices)'"~="" {
               foreach x in `r(outmatrices)' {
                  matrix `x' = r(`x')
                  cap return mat `x' = `x'
               }
            }
            * End added 20150301

         
         if "`debug'"=="debug" {
            di in yellow _n "This is line 1733 of runmplus.ado and you are about" _n ///
                            " to call " in green "read_residual_variance.ado" _n _n
         }
         read_residual_variance , out(`out') `debug' 
         if "`debug'"=="debug" {
            di in yellow _n "Good news. " in green "read_residual_variance seems to have gone through OK" _n _n
         }
         cap matrix residual_variance = r(residual_variance)
         cap return matrix residual_variance = residual_variance
      }
      ** end new 6-23-2008

      ** new 10-9-2008
      ** This part of the code is ported from read_modelinfo.ado
      qui {
         qui infix str line 1-85 using `out' , clear
         format line %85s
         * IDENTIFY START AND END OF MODEL INFO
         gen linenum=_n
         gen x1=_n if (trim(line)=="SUMMARY OF ANALYSIS")|(trim(line)=="MODEL RESULTS")|(substr(trim(line),1,18)=="TESTS OF MODEL FIT")
         summarize x1
         keep if inrange(linenum,r(min)+1,r(max)-1)
         drop if trim(line)==""
         *** PATCH ON 6-25-2009 ***
         *** STILL NOT GETING MODEL CHI-SQURE ***
         *** STUFF ABOVE PROBABLY ONLY WORKS WITH CATEGORICAL DEPENDENT VARIABLES BUT I DON't REALLY KNOW ***
         local dim = _N-5
         *foreach j of numlist 1/`dim' {
         forvalues j = 1/`dim' {
            local k = `j'+1
            local l = `j'+2
            local m = `j'+3
            local n = `j'+4
            if substr(trim(line[`j']),1,28)=="Chi-Square Test of Model Fit" &  ///
               substr(trim(line[`k']),1,5)=="Value" & ///
               substr(trim(line[`l']),1,18)=="Degrees of Freedom" & ///
               substr(trim(line[`m']),1,7)=="P-Value" & ///
               substr(trim(line[`n']),1,25)=="Scaling Correction Factor" {
               return local chi_square = substr(trim(line[`k']),29,12)
               return local df = substr(trim(line[`l']),29,12)
               return local PValue = substr(trim(line[`m']),29,12)
               return local SCF  = substr(trim(line[`n']),29,12)
            }
         }
         *** END OF 6-25-2009 PATCH
         drop if substr(line,1,10) == "*   The ch"
         drop if substr(line,1,10) == "    for ch"
         drop if substr(line,1,10) == "    testin"
         drop if substr(line,1,10) == "    See ch"
         drop if substr(line,1,10) == "**  The de"
         drop if substr(line,1,10) == "    a form"
         drop if substr(line,1,10) == "    See de"
         drop if substr(trim(line),1,20) == "Loglikelihood change"
         drop if substr(trim(line),1,7) == "CFI/TLI"
         drop x1
         drop linenum
         gen linenum = _n
         gen x1=.
         local info1  = "Number of observations"
         local info2  = "Estimator"
         local info3  = "Parameterization"
         local info4  = "Chi-Square Test"
         local info5  = "Value"
         local info6  = "Degrees of Freedom"
         local info7  = "P-Value"
         local info8  = "Chi-Square Test of Model Fit for the Baseline Model"
         local info9  = "CFI"
         local info10 = "TLI"
         local info11 = "RMSEA"
         local info12 = "Estimate"
         local info13 = "WRMR"
         local info14 = "Loglikelihood"
         local info15 = "H0 Value"
         local info16 = "H0 Scaling Correction Factor"
         local info17 = "Number of Free Parameters"
         local info18 = "Akaike (AIC)"
         local info19 = "Bayesian (BIC)"
         local info20 = "Sample-Size Adjusted BIC"
         local info21 = "Pearson Chi-Square"
         local info22 = "Likelihood Ratio Chi-Square"
         local info23 = "Chi-Square Test for Difference Testing"
         local info24 = "Entropy"
         local info25 = "Wald Test of Parameter Constraints"
         local info26 = "SRMR (Standardized Root Mean Square Residual)"
         * easy ones 1 2 3 9 10 11 13 18 19 20 24
         local lab1   = "obs"
         local lab2   = "estimator"
         local lab3   = "Parameterization"
         local lab9   = "CFI"
         local lab10  = "TLI"
         local lab11  = "RMSEA"
         local lab13  = "WRMR"
         local lab18  = "AIC"
         local lab19  = "BIC"
         local lab20  = "aBIC"
         local lab17  = "free_parameters"
         local lab24  = "Entropy"
         local lab25  = "WaldTest"
         local lab26  = "SRMR"
         * loglikelihood
         local lab101 "LL_H0"
         local lab102 "LL_H1"
         local info101 = "H0 Value"
         local info102 = "H1 Value"
         foreach i of numlist 1/25 101 102 26 {
            local l = length("`info`i''")
            replace x1=linenum if substr(trim(line),1,`l') == "`info`i''"
         }
         keep if x1~=.
         keep line
         gen linenum = _n
         local dim = _N
         gen id=1
         su linenum
         
        
         
         if r(N)>0 {
            reshape wide line, i(id) j(linenum)
            drop id
            * first the easy ones
            foreach i in 101 102 {
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  local l = length("`info`i''")
                  if substr(trim(line`j'),1,`l')=="`info`i''" {
                     return local `lab`i'' = trim(substr(line`j',`l'+1,.))
                  }
               }
            }
            * added SRMR 3 Mar 2015
            forvalues j = 1/`dim' {
               if substr(trim(line`j'),1,4)=="SRMR" {
                  local k = `j'+1
                  return local SRMR= trim(substr(trim(line`k'),6,.))
               }
             }   // closes SRMR

            foreach i of numlist 1 2 3 9 10 11 13 17 18 19 20 24 {
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  local l = length("`info`i''")
                  if substr(trim(line`j'),1,`l')=="`info`i''" {
                     return local `lab`i'' = trim(substr(line`j',`l'+1,.))
                     if `i'==2 {
                        local estimator = trim(substr(line`j',`l'+1,.))
                     }
                     if `i'==11|`i'==13 {
                        local k = `j'+1
                        capture confirm variable line`k'
                        if _rc==0 {
                           return local `lab`i'' = trim(substr(line`k',`l'+5,.))
                        }
                     }
                  }
               }
            }
            * now the hard ones
            * start added 2013.10.15
            forvalues j = 1/`dim' {
               if substr(trim(line`j'),1,34)=="Wald Test of Parameter Constraints" {
                  local k = `j'+1
                  local l = `j'+2
                  local m = `j'+3
                  local WaldTest = trim(substr(trim(line`k'),6,.))
                  local WaldTest_df = trim(substr(trim(line`l'),21,.))
                  return local WaldTest = subinstr("`WaldTest'",char(42),"",.)
                  return local WaldTest_df = subinstr("`WaldTest_df'",char(42),"",.)
                  return local WaldTest_P  = trim(substr(trim(line`m'),8,.))
               }
            }
            if "`estimator'"~="MLR" {
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  if substr(trim(line`j'),1,28)=="Chi-Square Test of Model Fit" & ///
                     substr(trim(line`j'),1,51)!="Chi-Square Test of Model Fit for the Baseline Model" {
                     local k = `j'+1
                     local l = `j'+2
                     local m = `j'+3
                     local chisquare    = trim(substr(trim(line`k'),6,.))
                     local chisquare_df = trim(substr(trim(line`l'),21,.))
                     return local chisquare    = subinstr("`chisquare'",char(42),"",.)
                     return local chisquare_df = subinstr("`chisquare_df'",char(42),"",.)
                     return local chisquare_P  = trim(substr(trim(line`m'),8,.))
                  }
               }
               * chi-square test of model fit for the baseline model
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  if substr(trim(line`j'),1,51)=="Chi-Square Test of Model Fit for the Baseline Model" {
                     local k = `j'+1
                     local l = `j'+2
                     local m = `j'+3
                     local baseline_chisquare    = trim(substr(trim(line`k'),6,.))
                     local baseline_chisquare_df = trim(substr(trim(line`l'),21,.))
                     return local BL_chisquare    = subinstr("`baseline_chisquare'",char(42),"",.)
                     return local BL_chisquare_df = subinstr("`baseline_chisquare_df'",char(42),"",.)
                     return local BL_chisquare_P  = trim(substr(trim(line`m'),8,.))
                  }
               } // closes condition for chi-square with estimator not MLR
               * Chi-Square Test for Difference Testing
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  if substr(trim(line`j'),1,38)=="Chi-Square Test for Difference Testing" {
                     local k = `j'+1
                     local l = `j'+2
                     local m = `j'+3
                     return local difftest_chisquare    = trim(substr(trim(line`k'),6,.))
                     return local difftest_chisquare_df = trim(substr(trim(line`l'),21,.))
                  }
               } // closes condition for chi-square with estimator not MLR
            }
            if "`estimator'"=="MLR" {
               * Loglikelihood
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  if substr(trim(line`j'),1,13)=="Loglikelihood" {
                     local k = `j'+1
                     local l = `j'+2
                     return local Loglikelihood   = trim(substr(trim(line`k'),9,.))
                     return local Loglikelihood_cf = trim(substr(trim(line`l'),31,.))
                  }
               } // closes loglikelihood
               * Pearson Chi-square
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  if substr(trim(line`j'),1,18)=="Pearson Chi-Square" {
                     local k = `j'+1
                     local l = `j'+2
                     local m = `j'+3
                     return local Pearson_chi2   = trim(substr(trim(line`k'),6,.))
                     return local Pearson_chi2_df = trim(substr(trim(line`l'),21,.))
                     return local Pearson_chi2_P = trim(substr(trim(line`m'),8,.))
                  }
               }   // closes Pearson
               * Likelihood Ratio Chi-Square
               *foreach j of numlist 1/`dim' {
               forvalues j = 1/`dim' {
                  if substr(trim(line`j'),1,27)=="Likelihood Ratio Chi-Square" {
                     local k = `j'+1
                     local l = `j'+2
                     local m = `j'+3
                     capture confirm variable line`k'
                     if _rc==0 {
                        return local LR_chi2   = trim(substr(trim(line`k'),6,.))
                     }
                     capture confirm variable line`l'
                     if _rc==0 {
                        return local LR_chi2_df = trim(substr(trim(line`l'),21,.))
                     }
                     capture confirm variable line`m'
                     if _rc==0 {
                        return local LR_chi2_P = trim(substr(trim(line`m'),8,.))
                     }
                  }
               } // closes Likelihood Ratio Chi-Square
            } // closes condition if estimator is MLR
         } // closes qui on model info section
      } // closes condition on linenum
   } // closes condition if BAYES ~=1
} // closes condition if not montecarlo
if ("`mc'"~="" | "`montecarlo'"~="" ) & `isdatatypeimputation'==0 {
   *********************************************
   *********************************************
   *** output processsing for montecarlo
   *********************************************
   *********************************************
   qui { // note not indented
   drop _all
   qui infix str line 1-85 ///
         str name 1-19 ///
         str value 20-85 ///
         using `using'.out
   format line %85s
   gen linenum=_n
   *list line
   capture drop keep
   gen keep=.
   replace keep=linenum if substr(trim(line),1,13)=="MODEL RESULTS"
   replace keep=linenum if substr(trim(lower(line)),1,28)=="quality of numerical results"
   su keep
   drop if linenum<=r(min)
   su keep
   drop if linenum>=r(max)
   drop if trim(line)==""
   drop linenum
   gen linenum = _n
   * cleanup
   drop if substr(trim(lower(line)),1,9)=="estimates"
   * suffix line 1725
   gen suffix= lower(word(trim(line),2)) if wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,5)=="Class")
   replace suffix=suffix[_n-1] if _n>1 & suffix==""
   *prefix
   gen prefix=line if (wordcount(line)==2|wordcount(line)==1) & (wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,12)=="Class"))~=1
   replace prefix=lower(prefix)
   replace prefix=prefix[_n-1] if _n>1 & prefix==""
   * parameter
   gen parameter = lower(word(trim(line),1)) if (wordcount(line)==2 & substr(trim(line),1,5)=="Group")~=1
   * estimate
   gen population=word(trim(line),2)
   gen average=word(trim(line),3)
   gen sd=word(trim(line),4)
   gen se_average=word(trim(line),5)
   gen mse=word(trim(line),6)
   gen coverage95=word(trim(line),7)
   gen sig_coef_pct=word(trim(line),8)
   local resultsset "population average sd se_average mse coverage95 sig_coef_pct "
   foreach foo in `resultsset' {
      replace `foo'=" " if population=="Undefined"
   }
   foreach foo in `resultsset' {
      destring `foo', force replace
   }
   gen x = prefix + " " + parameter + " " + suffix
   replace x=lower(x)
   replace x=trim(x)
   replace x=itrim(x)
   drop if population==.
   replace x=subinstr(x," ","_",.)
   replace x=subinstr(x,"$","_",.)
   drop if regexm(x,"category")==1
   **** local MS=_N*10
   **** if `MS'>800 {
   ****    capture set matsize `MS'
   **** }
   keep x `resultsset'
   mkmat `resultsset' , rownames(x) matrix(model_results)
   return matrix model_results = model_results
   *************************
   *************************
   *****   now get fits
   *************************
   *** first drop north of "TESTS OF MODEL FIT"
   *** then drop south of "MODEL RESULTS"
   *** THEN FROM within remainder find individual fits as noted
   local mcfit1="Chi-Square Test of Model Fit"
   local mcfit2="RMSEA (Root Mean Square Error Of Approximation)"
   local mcfit3="WRMR (Weighted Root Mean Square Residual)"
   local mcfit4="Loglikelihood"
   local mcfit5="H1 Value"
   local mcfit6="Akaike (AIC)"
   local mcfit7="Sample-Size Adjusted BIC (n* = (n + 2) / 24)"
   local mcfit8="SRMR (Standardized Root Mean Square Residual)"

   *-----
   * short names
   local smcfit1="Chi-Square"
   local smcfit2="RMSEA"
   local smcfit3="WRMR"
   local smcfit4="Loglikelihood"
   local smcfit5="H1 Value"
   local smcfit6="AIC"
   local smcfit7="BIC"
   local smcfit8="SRMR"
   **** loop over fits
   forvalues i=1/8 { // 3 is the number of fits, 3 as of 10-3-2010
      *di in red "now pulling `smcfit`i'' results"
      drop _all
      qui infix str line 1-85 ///
            str name 1-19 ///
            str value 20-85 ///
            using `using'.out
      format line %85s
      gen linenum=_n
      *list line
      capture drop keep
      gen keep=.
      replace keep=linenum if substr(trim(line),1,18)=="TESTS OF MODEL FIT"
      replace keep=linenum if substr(trim(line),1,13)=="MODEL RESULTS"
      su keep
      drop if linenum<=r(min)
      su keep
      drop if linenum>=r(max)
      drop if trim(line)==""
      drop linenum
      gen linenum = _n
      replace keep=linenum if regexm(line,"`smcfit`i''")==1
      su keep
      drop if linenum<=r(min)
      replace keep=linenum+14 if regexm(line,"Percentiles")==1
      su keep
      drop if linenum>r(min)
      gen mean=word(trim(line),2) if regexm(line,"Mean")==1
      gen sd=word(trim(line),3) if regexm(line,"Std Dev")==1
      gen nsc=word(trim(line),5) if regexm(line,"Number of successful computations")==1
      destring mean, force replace
      destring sd, force replace
      destring nsc , force replace
      if "`smcfit`i''"=="Chi-Square" {
         local smcfit`i'="ChiSquare"
      }
      if "`smcfit`i''"=="H1 Value" {
         local smcfit`i'="H1Value"
      }
      if "`smcfit`i''"=="BIC" {
         local smcfit`i'="aBIC"
      }
      mat `smcfit`i'' = J(1,3,.)
      mat colnames `smcfit`i'' = Mean StdDev NSC
      su mean
      if r(N)==1 {
         mat `smcfit`i''[1,1]=r(mean)
         return local `smcfit`i''_mean=r(mean)
         su sd
         mat `smcfit`i''[1,2]=r(mean)
         return local `smcfit`i''_sd=r(mean)
         su nsc
         mat `smcfit`i''[1,3]=r(mean)
         return local `smcfit`i''_number_successful = r(mean)
      }
      return matrix `smcfit`i'' = `smcfit`i''
   }
   } // close qui
}

* start added 6-17-2012 tech 11 and 14 output
if ///
   regexm(lower("`output'"),"tech11")==1 | regexm(lower("`tech'"),"11")==1 | ///
   regexm(lower("`output'"),"tech14")==1 | regexm(lower("`tech'"),"14")==1 {
   di in green "Now processing TECH11 and/or TECH14 output"
   * Tech 11 output
   qui {
      if regexm(lower("`output'"),"tech11")==1 | regexm(lower("`tech'"),"11")==1  {
         qui infix str line 1-85 using `out' , clear
         format line %85s
         drop if trim(line)==""
         local dim=`c(N)'
         *foreach j of numlist 1/`dim' {
         forvalues j = 1/`dim' {
            if substr(trim(line[`j']),1,19)=="TECHNICAL 11 OUTPUT" {
               local k = `j'+1
               local l = `j'+2
               local m = `j'+3
               local n = `j'+4
               return local tech11_randomstarts  = trim(substr(trim(line[`l']),38,.))
               return local tech11_finalstageopz = trim(substr(trim(line[`m']),36,.))
            }
         }
         *foreach j of numlist 1/`dim' {
         forvalues j = 1/`dim' {
            if substr(trim(line[`j']),1,44)=="VUONG-LO-MENDELL-RUBIN LIKELIHOOD RATIO TEST" {
               local k = `j'+1
               local l = `j'+2
               local m = `j'+3
               local n = `j'+4
               local o = `j'+5
               local p = `j'+6
               return local tech11_vlmr_h0ll    = trim(substr(trim(line[`k']),23,.))
               return local tech11_vlmr_2lld    = trim(substr(trim(line[`l']),37,.))
               return local tech11_vlmr_dnp     = trim(substr(trim(line[`m']),41,.))
               return local tech11_vlmr_mean    = trim(substr(trim(line[`n']),5,.))
               return local tech11_vlmr_sd      = trim(substr(trim(line[`o']),19,.))
               return local tech11_vlmr_pvalue  = trim(substr(trim(line[`p']),8,.))
            }
         }
         *foreach j of numlist 1/`dim' {
         forvalues j = 1/`dim' {
            if substr(trim(line[`j']),1,34)=="LO-MENDELL-RUBIN ADJUSTED LRT TEST" {
               local k = `j'+1
               local l = `j'+2
               return local tech11_lmr_value   = trim(substr(trim(line[`k']),23,.))
               return local tech11_lmr_pvalue  = trim(substr(trim(line[`p']),8,.))
            }
         }
         * end tech 11 output
      }
      * start tech 14 output
      if regexm(lower("`output'"),"tech14")==1 | regexm(lower("`tech'"),"14")==1 {
         *foreach j of numlist 1/`dim' {
         forvalues j = 1/`dim' {
            if substr(trim(line[`j']),1,49)=="PARAMETRIC BOOTSTRAPPED LIKELIHOOD RATIO TEST FOR" {
               local k = `j'+1
               local l = `j'+2
               local m = `j'+3
               local n = `j'+4
               local o = `j'+5
               return local tech14_h0ll    = trim(substr(trim(line[`k']),23,.))
               return local tech14_2lld    = trim(substr(trim(line[`l']),37,.))
               return local tech14_dnp     = trim(substr(trim(line[`m']),39,.))
               return local tech14_pvalue  = trim(substr(trim(line[`n']),20,.))
               return local tech14_success = trim(substr(trim(line[`o']),27,.))
            }
         }
         * end tech 14 output
      }
   } // close qui
} // end if
* end added 6-17-2012

**
* ------------------- SAVE INPUT and DATA FILE IF REQUESTED TO DO SO
*
if "`saveinputfile'"~="" {
   cap confirm file `using'.inp
   if _rc==0 {
      * new on 7-20-2009
      if "`saveinputdatafile'"~="" {
         tempname foo foo2
         capture erase `foo'.inp
         local `foo2' : subinstr local saveinputdatafile "\" "\BS" , all
         local `foo2' = "``foo2''"+".dat"
         qui filefilter `using'.inp `foo'.inp ///
            , from("`using'.dat")  ///
              to(`"``foo2''"') replace
         capture erase `saveinputfile'.inp
         capture erase `using'.inp
         qui copy `foo'.inp `using'.inp , replace
      }
      capture erase "`saveinputfile'.inp"
      qui copy `using'.inp "`saveinputfile'.inp" , replace
   }
   
   if "`saveinputdatafile'"~="" {
      cap confirm file `using'.dat
      if _rc==0 {
         qui copy `using'.dat "`saveinputdatafile'.dat" , replace
      }
   }
}

capture restore

if "`log'"=="off" {
   di in green "log suppressed"
}
else {
   type `using'.out
}

capture erase `using'.inp
capture erase `using'.out
capture erase `using'.dat
capture erase `r1'.dat

* reset matsize
qui cap set matsize `omatsize'

end

** EMBEDDED PROGRAMS===========================================================
* line write program ==========================================================
capture program drop lw
program define lw
syntax , out(string) line(string)
local 1 `"`line'"'
* test length of command
local linelength : length local 1
if `linelength' < 70 {
   file write `out' "`1' ; " _n
}
else {
   local piece : piece 1 65 of `"`1'"' , nobreak
   file write `out' "`piece'" _n
   local k=2
   local piece : piece 2 65 of `"`1'"' , nobreak
   while `"`piece'"' != "" {
      file write `out' "`piece'"
      local k = `k' + 1
      local piece : piece `k' 65 of `"`1'"' , nobreak
      if trim(`"`piece'"') ~= "" {
         file write `out' " " _n
      }
   }
   file write `out' " ; " _n
}
end


* ===========================================================================
* ----- PROGRAM MAKELAB
capture program drop makelab
program define makelab
  version 7
  * variable name, variable number, n of cases, file handle
  args var myout n

  * display "args `var' `myout' `n'"
  local varl : var label `var'
  file write `myout' "  `var' : `varl'" _newline

  local vl : value label `var'
  if "`vl'" == "" {
    exit 0
  }

  tempvar lvar
  tempvar first
  decode `var', gen(`lvar')

  sort `var'
  by `var' : gen `first' = (_n == 1) & `lvar' != ""

  local casenum = 1
  while (`casenum' <= `n') {
    if `first'[`casenum'] {
      local v1 = `var'[`casenum']
      local v2 = `lvar'[`casenum']
      file write `myout' "    `v1': `v2'" _newline
    }
    local casenum = `casenum' + 1
  }
end

** ========================================================================
**-- program saveinp
capture program drop saveinp
program def saveinp
syntax , using(string) [saveinputfile(string) saveinputdatafile(string)]
if "`saveinputfile'"~="" {
   cap confirm file `using'.inp
   if _rc==0 {
      * new on 7-20-2009
      if "`saveinputdatafile'"~="" {
			* new on 6-13-2019
			cap confirm file `using'.dat
			if _rc==0 {
				qui copy `using'.dat `"`saveinputdatafile'.dat"' , replace
			}
         tempname foo foo2
         capture erase `foo'.inp
         local `foo2' : subinstr local saveinputdatafile "\" "\BS" , all
         local `foo2' = "``foo2''"+".dat"
         filefilter `using'.inp `foo'.inp ///
            , from("`using'.dat")  ///
              to(`"``foo2''"')
         qui capture erase `saveinputfile'.inp
         qui capture erase `using'.inp
         qui copy `foo'.inp `using'.inp , replace
			* new on 6-13-a
			cap confirm file `using'.dat
			if _rc==0 {
				qui copy `using'.dat `"`foo2'"' , replace
			}
      }
      qui capture erase `saveinputfile'.inp
      qui copy `using'.inp `saveinputfile'.inp , replace
   }
}
end


*** ==========================================================
** READ_ERRORS
*** USAGE: read_errors foo.out
capture program drop read_errors
program define read_errors , rclass
version 9
local 0 `"using `0'"'
syntax using/
local error=0
tempname fh
local linenum = 0
file open `fh' using `"`using'"', read
file read `fh' line
while r(eof)==0 {
   local linenum = `linenum' + 1
   if substr(`"`macval(line)'"',1,9)=="*** ERROR" {
      local error = 1
      return local error = 1
      return local stop = 1
      return local termination = "not normal"
   }
   if `error'==1 {
      if trim(`"`macval(line)'"')=="" {
         exit
      }
      noisily display in red `"  `macval(line)'"'
   }
   file read `fh' line
}
file close `fh'
end
*** ============================================================

* have a nice day

