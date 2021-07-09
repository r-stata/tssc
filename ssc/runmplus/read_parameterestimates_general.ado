*** THIS ONE WORKS 
* Read in Mplus output file and load parameter estimtes
*

version 10

capture program drop read_parameterestimates_general
program define read_parameterestimates_general , rclass 

syntax , out(string) [debug]



if "`debug'"=="debug" {
   noisily di _n _col(3) "... now running read_parameter_estimates_general.ado" _n ///
                _col(7) "with debug mode on." _n _n
}


if _N==0 {
   set obs 1
   tempvar thud
   gen `thud'=1
}

qui tempfile origdat
qui save `origdat', replace

set more off


*** new material added 6/29/2011 (read matrices) see program below
*** now run the program
runmplus_read_matrices , out(`"`out'"') `debug'
if "`debug'"=="debug" {
   noisily di _n _col(7) " here are the saved results from runmplus_read_matrices" _n 
   noisily return list
}
   
if `"`r(outmatrices)'"'~="" {
   return local outmatrices "`r(outmatrices)'"
   foreach m in `r(outmatrices)' {
      matrix `m' = r(`m')
      return matrix `m' = `m'
   }
}
if `"`r(outmatrices)'"'=="" {
   di _n ///
      in yellow "NOTICE: " in green "no matrices were output by the sub-routine  " in yellow "runmplus_read_matrices" _n ///
      in green "which is defined and called in " in yellow "read_parameterestimates_general.ado. " in green "Most likely" _n ///
      "there is a problem processing the output, since r(covariancecoverage) would be" _n ///
      "expected to be returned at a minimum. Check your results carefully" in yellow "." _n
}


* look for special case output code
infix ///
   str col2 2-2 ///
   str line 1-99 ///
   using `out' , clear
format line %90s
gen isspecialcase=regexm(trim(itrim(lower(line))),"stdyx std")
qui su isspecialcase
local isspecialcase=r(max)
if `isspecialcase'==1 {
   * stop reading parameter estimates at
   local stopat "STANDARDIZED MODEL RESULTS"
   di in yellow "Caution - " in green "Note that the standardized parameter estimates" /// 
      "are reported in a seperate saved matrix ("in white "r(StdEstimates)" ///
      in green ") and do not have standard errors"
}




**** check and see if this is a bootstrap
**** and if there are confidence intervals to obtain
tempname fh
local linenum = 0
file open `fh' using `out', read
file read `fh' line
local ci_start=0
local ci_stop=0
local test1=0
local test2=0
while r(eof)==0 {
   local linenum = `linenum' + 1
   capture findfile lstrfun.ado
   if _rc==601 {
      di in red "runmplus can't look for confidence intervals"
      di in red "without lstrfun.ado. To install it type
      di in white "findit lstrfun"  in green " at the command line"
   }
   else {
      * if lstrfun is installed
      if `ci_start'==0 {
         lstrfun test1 , strpos(`"`line'"',"Lower .5%")
         if `test1'>0 {
            local ci_start = `linenum'+1
         }
      }
      if `ci_start'>0 {
         lstrfun test2 , strpos(`"`line'"',"Beginning Time:")
         if `test2'>0 {
            local ci_stop = `linenum'-1
         }
      }
   }
   file read `fh' line
}
file close `fh'
** end collect tests if confidence intervals are present
** now process confidence intervals
if `ci_start'>0 & `ci_stop'>`ci_start' {
   qui {
      infix str col2 2-2 ///
             str line 1-99 ///
             using `out' , clear
      format line %90s
      keep in `ci_start'/`ci_stop'
      gen name1=word(line,1)
      gen name2=word(line,2)
      replace name2="" if inlist(name2,"BY","WITH","ON","Variances")==0
      gen prefix=name1 if col2~=""
      replace prefix=name1+"_"+name2 if name2~="" & col2~=""
      replace prefix=prefix[_n-1] if prefix==""
      gen param=prefix+"_"+name1 if col2==""
      gen linewords=wordcount(line)
      list linewords line
      keep if linewords==8
      list line
      gen values=word(line,2)
      forvalues i=3/8 {
         replace values=values+", "+word(line,`i')
      }
      replace param=subinstr(param," ","_", .)
      forvalues loop=1/10 {
         replace param = subinstr(param,"__","_", .)
      }
      replace param=lower(param)
      replace param = subinstr(param,"|","by", .)
      keep param values
      strparse values , parse(,) gen(p)
      drop values
      forvalues i=1/7 {
         destring p`i' , replace
      }
      mkmat p1-p7 , mat(CI) rownames(param) 
      matrix colnames CI = p005 p025 p050 est p950 p975 p995
      return matrix CI = CI 
   }
}
** end process confidence intervals


*** pull out STDYX and STDY in special case reporting
if "`isspecialcase'"=="1" {
   tempname fh
   local linenum = 0
   file open `fh' using `out', read
   file read `fh' line
   local std_start=0
   local std_stop=0
   local test1=0
   local test2=0
   while r(eof)==0 {
      local linenum = `linenum' + 1
      capture findfile lstrfun.ado
      if _rc==601 {
         di in red "runmplus can't look for Special reporting of standardized effects"
         di in red "without lstrfun.ado. To install it type
         di in white "findit lstrfun"  in green " at the command line"
      }
      else {
         * if lstrfun is installed
         if `std_start'==0 {
            lstrfun test1 , strpos(`"`line'"',"STANDARDIZED MODEL RESULTS")
            if `test1'>0 {
               local std_start = `linenum'+4
            }
         }
         if `std_start'>0 {
            lstrfun test2 , strpos(`"`line'"',"QUALITY OF NUMERICAL RESULTS")
            if `test2'>0 {
               local std_stop = `linenum'-1
            }
         }
      }
      file read `fh' line
   }
   file close `fh'
   ** end collect start and end of standardized results in special case
   ** now process confidence intervals
   if `std_start'>0 & `std_stop'>`std_start' {
      qui {
         infix str col2 2-2 ///
                str line 1-99 ///
                using `out' , clear
         format line %90s
         keep in `std_start'/`std_stop'
         gen name1=word(line,1)
         gen name2=word(line,2)
         replace name2="" if inlist(name2,"BY","WITH","ON","Variances")==0
         gen prefix=name1 if col2~=""
         replace prefix=name1+"_"+name2 if name2~="" & col2~=""
         replace prefix=prefix[_n-1] if prefix==""
         gen param=prefix+"_"+name1 if col2==""
         gen linewords=wordcount(line)
         drop if substr(reverse(trim(param)),1,1)=="_"  | trim(param)==""
         gen value2=reverse(word(reverse(line),1))
         gen value1=reverse(word(reverse(line),2))
         destring value2 , replace force
         destring value1 , replace force
         drop if value1==. & value2==.
         order param value1 value2
         keep param value1 value2
         mkmat value1 value2 , mat(StdEstimates) rownames(param) 
         matrix colnames StdEstimates = StdYX Std
         return matrix StdEstimates = StdEstimates 
      }
   }
   ** end process standardized results in special case
}





qui infix str line 1-85 ///
      str name 1-19 ///
      str value 20-67 ///
      using `out' , clear
format line %85s


qui {


        * IDENTIFY START AND END OF Parameter estimates
        if "`stopat'"=="" {
            local stopat = "QUALITY OF NUMERICAL RESULTS"
        }
        gen linenum=_n
        gen x1=_n if (trim(line)=="MODEL RESULTS")|((trim(line)=="`stopat'")|(trim(line)=="CONFIDENCE INTERVALS OF MODEL RESULTS"))
        summarize x1
        keep if inrange(linenum,r(min)+1,r(max)-1)
        drop if trim(line)==""
        drop x1
        drop linenum
        gen linenum = _n

        list linenum line , clean
        
        * cleanup
        drop if substr(trim(line),1,10)=="Two-Tailed"
        drop if substr(trim(line),1,8)=="Estimate"
        replace line=subinstr(line,"Latent Class","Class",.)
        
        * suffix
        gen suffix= lower(word(trim(line),2)) if wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,5)=="Class")
        replace suffix=suffix[_n-1] if _n>1 & suffix==""

        *prefix
        gen prefix=line if (wordcount(line)==2|wordcount(line)==1) & (wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,5)=="Class"))~=1
        replace prefix=lower(prefix)
        replace prefix=prefix[_n-1] if _n>1 & prefix==""
        
        * Second prefix
        gen eset =""
        replace eset = line if substr(trim(line),1,22)=="Base Hazard Parameters"
        replace eset = line if substr(trim(line),1,21)=="STDYX Standardization"
        replace eset = line if substr(trim(line),1,20)=="STDY Standardization"
        replace eset = line if substr(trim(line),1,19)=="STD Standardization"
        replace eset = "IRT" if substr(trim(line),1,20)=="IRT PARAMETERIZATION"
        replace eset = "r-square" if substr(trim(line),1,8)=="R-SQUARE"
        replace eset = lower(eset)
        replace eset = subinstr(eset,"standardization","",.)
        replace eset = subinstr(eset,"parameterization","",.)
        replace eset = eset[_n-1] if _n>1 & eset==""
        
        
        * parameter
        gen parameter = lower(word(trim(line),1)) if (wordcount(line)==2 & substr(trim(line),1,5)=="Group")~=1
        
        * estimate
        gen estimate=word(trim(line),2)
        gen se=word(trim(line),3)
        replace se="" if estimate=="Undefined" 
        replace estimate="" if estimate=="Undefined" 
        destring se, force replace
        drop if se==. & eset~="r-square"
        drop if eset=="r-square" & real(word(line),2)==.
        destring estimate, replace
        
        gen x = eset + " " + prefix + " " + parameter + " " + suffix
        replace x= eset + " " + word(line,1) + suffix if eset=="r-square"
        replace x=lower(x)
        
        replace x=trim(x)
        replace x = subinstr(x,"     "," ",.)
        replace x = subinstr(x,"    "," ",.)
        replace x = subinstr(x,"   "," ",.)
        replace x = subinstr(x,"  "," ",.)
        replace x = subinstr(x,"  "," ",.)
        replace x = subinstr(x,"observed two-tailed","",.)
        replace x = subinstr(x,"  "," ",.)
        replace x = subinstr(x,"  "," ",.)
        replace x = subinstr(x,"  "," ",.)
        replace x = subinstr(x,"new/additional parameters","new",.)
        
        replace x = subinstr(x,"|","by",.)
        * new 4/27/2011 thanks to George Leckie g.leckie@bristol.ac.uk
        replace x = subinstr(x,"#","_",.)
        replace x = subinstr(x,"c.","c_",.)
        
        
        * added 1/2/2009 by Frances Yang
        drop if regexm(x,"category")==1
        destring estimate , replace
        destring se , replace
        
        
        keep x estimate se
        
        capture matrix drop estimate
        capture matrix drop se
        
        local MS=_N
        capture set matsize `MS'
        if _rc==0 {
         set matsize `MS'
        }
        
             
        cap mkmat estimate , rownames(x)
        cap mkmat se , rownames(x)
        
        cap confirm matrix estimate
        if _rc==0 {
           return matrix estimate = estimate
        }
        
        cap confirm matrix se
        if _rc==0 {
         return matrix se = se
        }
        
        qui use `origdat' , replace
        
}




end

*** ------------------------------------------------------------------------
*** Start of new section added 6/29/2011
*** runmplus_read_matrices
*** Rich Jones
*** June 29, 2011
***    This program an Mplus output file
*** and looks for matrices to read in and save out to
*** stata.
***   For example, convergence, sample statistics (means, correlations, covariances)
*** technical 1 (parameter specification, starting values, estimates, residuals, etc.)
*** It is a work in progress.
***
*** It is included as part of read_parameter_estimates_general.ado
* Read in Mplus output file and load parameter estimtes
capture program drop runmplus_read_matrices
program define runmplus_read_matrices , rclass
syntax , out(string) [debug]

local lookfor1 "COVARIANCE COVERAGE" // specify matrices to look for 

local lookfor2 "Means"
local lookfor2in "ESTIMATED SAMPLE STATISTICS"

local lookfor3 "Correlations"
local lookfor3in "ESTIMATED SAMPLE STATISTICS"

local lookfor4 "Covariances"
local lookfor4in "ESTIMATED SAMPLE STATISTICS"

local lookfor5 "Model Estimated Means/Intercepts/Thresholds"
local lookfor5s "ModelEstMeans"
local L=5

local lookfor`++L' "Model Estimated Covariances/Correlations/Residual Correlations"
local lookfor`L's  "ModelEstCov"

local lookfor`++L' "Standardized Residuals (z-scores) for Means/Intercepts/Thresholds"
local lookfor`L's  "StdResMeans"

local lookfor`++L' "Normalized Residuals for Means/Intercepts/Thresholds"
local lookfor`L's  "NmlResMeans"

local lookfor`++L' "Standardized Residuals (z-scores) for Covariances/Correlations/Residual Corr"
local lookfor`L's  "StdResCov"

local lookfor`++L' "Normalized Residuals for Covariances/Correlations/Residual Correlations"
local lookfor`L's  "NmlResCov"

local lookfor`++L' "TAU"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecTau"

local lookfor`++L' "NU"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecNu"

local lookfor`++L' "LAMBDA"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecLambda"

local lookfor`++L' "THETA"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecTheta"

local lookfor`++L' "ALPHA"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecAlpha"

local lookfor`++L' "BETA"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecBeta"

local lookfor`++L' "PSI"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecPsi"

local lookfor`++L' "GAMMA"
local lookfor`L'in "PARAMETER SPECIFICATION"
local lookfor`L's  "SpecGamma"


local lookfor`++L' "TAU"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartTau"

local lookfor`++L' "NU"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartNu"

local lookfor`++L' "LAMBDA"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartLambda"

local lookfor`++L' "THETA"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartTheta"

local lookfor`++L' "ALPHA"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartAlpha"

local lookfor`++L' "BETA"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartBeta"

local lookfor`++L' "PSI"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartPsi"

local lookfor`++L' "GAMMA"
local lookfor`L'in "STARTING VALUES"
local lookfor`L's  "StartGamma"

local outmatrices ""

forvalues l=1/`L'  {                    // loop over number of potential matrices to find
qui {
   *** find the span of lines where the headding matches the thing to look for
   *** if lookforin is specified
   cap   macro drop _W
   cap   macro drop _matname
   cap   macro drop _i`l'_startin
   cap   macro drop _i`l'_stopin
   cap   macro drop _i`l'_start
   cap   macro drop _i`l'_start_span
   cap   macro drop _i`l'_end
   cap   macro drop _foo
   cap   macro drop _goo
   cap   macro drop _rowvarsare
   cap   macro drop _w1
   cap   macro drop _w2
   cap   macro drop _w3
   cap   macro drop _w4
   cap   macro drop _w5
   cap   macro drop _w6
   cap   cap erase _newdata.do
   cap   macro drop _colnames
   cap   macro drop _S
   cap   macro drop _cont
   cap   macro drop _tf
   cap   macro drop _eq
   cap  macro  drop _Nis
   if "`lookfor`l'in'" ~= "" {
      if "`lookfor`l's'"=="" {
         local matname=lower(subinstr(substr("`lookfor`l'in'",1,4)," ","",.))+lower(subinstr("`lookfor`l''"," ","",.))
      }
      else {
         local matname "`lookfor`l's'"
      }
      if "`debug'"=="debug" {
         noisily di in red _n "### GOT HERE INSIDE runmplus_read_matrices ### " _n
      }
      infix str col2 1-2 str line 1-99 using `out' , clear
      format line %90s
      gen linenum=_n
      gen target=lower(trim(line))==lower(trim("`lookfor`l'in'"))
      su linenum if target==1
      local i`l'_startin = r(min)
      gen blankline=trim(line)==""
      gen stop=blankline[_n-1]==1 & blankline[_n-2]==1 & col2~=""
      if "`lookfor`l'in'"=="ESTIMATED SAMPLE STATISTICS" {
         replace stop=.
         replace stop=1 if substr(trim(lower(line)),1,22)=="maximum log-likelihood"
      }
      if "`lookfor`l'in'"=="PARAMETER SPECIFICATION" {
         replace stop=.
         replace stop=1  if substr(trim(lower(line)),1,15)=="starting values"
      }
     
      su linenum if stop==1 & linenum>`i`l'_startin'
      local i`l'_stopin=r(min)-3
      keep if inrange(linenum,`i`l'_startin',`i`l'_stopin')
      drop linenum
      drop target
      drop blankline
      drop stop
      list line
   }
   if "`lookfor`l'in'"=="" {
      infix str col2 2-2 str line 1-99 using `out' , clear
      format line %90s
      if "`lookfor`l's'"=="" {
         local matname=lower(subinstr("`lookfor`l''"," ","",.))
      }
      else {
         local matname "`lookfor`l's'"
      }
   }
   gen linenum=_n
   gen target=lower(trim(line))==lower(trim("`lookfor`l''"))
   su linenum if target==1
   local i`l'_start = r(min)
   local i`l'_start_span = r(max)
   gen blankline=trim(line)==""
   di in yellow "i`l'start -> `i`l'_start'
   di in yellow "i`l'start_span -> `i`l'_start_span'
   su linenum if linenum>`i`l'_start_span' & blankline==1
   local i`l'_end = r(min)
   keep if inrange(linenum,`i`l'_start',`i`l'_end')
   drop if target==1
   drop if blankline==1
   drop if trim(substr(line,1,5))=="_____"
   replace line=subinstr(line,"  ",",",.)
   forvalues q=1/10 {
      replace line=subinstr(line,",,",",",.)
   }
   strparse line , parse(,) gen(p)
   *** Matrices may be chuncked apart
   *** if the row variables are all strings, these are "varnames" (and the first variable is blank)
   *** if the column contains 1 string and the rest are numbers, then the first column is the rowname 
   *** and the remainder are values
   *** Mplus seems to give 5 at a time, so this might help
   *** so there should always be p1-p6,
   foreach v of numlist 1/6 {
      cap confirm var p`v'
      if _rc==0 {
         gen v`v'=real(p`v')
         gen s`v'=p`v'
         if "`eq'"~="" {
            local eq "`eq' & "
         }
         local eq "`eq' v`v'==."
      }
   }
   cap confirm var s6
   if _rc==0 {
      replace s6=p5 if `eq'
      local S=6
   }
   cap confirm var s5
   if _rc==0 {
      replace s5=p4 if `eq'
      if "`S'"=="" {
         local S=5
      }
   }
   cap confirm var s4
   if _rc==0 {
      replace s4=p3 if `eq'
      if "`S'"=="" {
         local S=4
      }
   }
   cap confirm var s3
   if _rc==0 {
      replace s3=p2 if `eq'
      if "`S'"=="" {
         local S=3
      }
   }
   cap confirm var s2
   if _rc==0 {
      replace s2=p1 if `eq'
      if "`S'"=="" {
         local S=2
      }
   }
   cap confirm var s1
   if _rc==0 {
      replace s1="row" if `eq'
      if "`S'"=="" {
         local S=1
      }
   }
   keep s*
   gen linenum=_n
   su linenum if _n>1 & s1=="row"
   local Nis=r(N)
   if `Nis'==0 {
      drop linenum
      foreach var of varlist _all {
         local vname=`var'
         local vname=lower("`vname'")
         local vname=subinstr("`vname'","$","_",.)
         local vname=subinstr("`vname'","#","_",.)         
         cap rename `var' `vname'
         if _rc~=0 {
            noisily di in yellow "WARNING" in green "there was a problem with a renaming command " _n "in read_parameterestimates_general.ado"
            noisily di "var-> `var'"
            noisily di "vname-> `vname'"
            noisily di "read_parameterestimates_general.ado will now terminate. " _n "Check saved results carefully"
            noisily di exit
         }
      }
      findname * , local(colnames)
      local row "row linenum"
      replace row=lower(row)
      local colnames : list colnames -  row
      drop in 1
      foreach var of varlist `colnames' {
         destring `var' , replace
      }
      rename row rowname
      *** make sure rowname is string
      cap confirm string var rowname
      if _rc~=0 {
         rename rowname _rowname
         gen rowname=string(_rowname)
         drop _rowname
      }
   }
   if `Nis'>0 {
      local foo  = `r(min)'-1
      if `foo'>=2 {
         preserve
         keep in 2/`foo'
         while _N>0 {
            local goo = lower(s1)
            local rowvarsare "`rowvarsare' `goo'"
            drop in 1
         }
         restore
         di "`rowvarsare'"
         local W : word count `rowvarsare'
         * write a text file 
         tempname f
         capture file close `f'
         local tf=0
         file open `f' using _newdata.do , write text replace
         forvalues i=1/`S' {
            local w`i' = s`i'
            if "`w`i''"=="" {
               local w`i' = "." 
            }
         }
         file write `f' `" file open csv using _tmp`++tf'.csv , write text replace  "' _n
         file write `f' `" file write csv "rowname , `w2'  , `w3' , `w4' , `w5' , `w6' " _n"' _n
         forvalues i=1/`S' {
            macro drop _w`i'
         }
         drop in 1
         while _N>0 {
            forvalues i=1/`S' {
                  macro drop _w`i'
            }
            forvalues i=1/`S' {
               local w`i' = s`i'
               if "`w`i''"=="" {
                  local w`i' = "." 
               }
            }
            if "`w1'"=="row" {
               file write `f' `" file write csv _n "' _n
               file write `f' `" file close csv    "' _n
               file write `f' `" file open csv using _tmp`++tf'.csv, write text replace "' _n
               file write `f' `" file write csv "rowname , `w2'  , `w3' , `w4' , `w5' , `w6' " _n"' _n
            }
            if "`w1'"~="row" {
               file write `f' `" file write csv "`w1' , `w2' , `w3' , `w4' , `w5' , `w6' " _n "' _n
            }
            drop in 1
         }
         file write `f' `" file write csv _n "' _n
         file write `f' `" file close csv    "' _n
         file write `f' "" _n
         file close `f'
         * end write a text file
         do _newdata.do
         forvalues i=1/`tf' {
            insheet using _tmp`i'.csv , clear names
            *** make sure rowname is string
            cap confirm string var rowname
            if _rc~=0 {
               rename rowname _rowname
               gen rowname=string(_rowname)
               drop _rowname
            }
            save _tmp`i' , replace
         }
         use _tmp1 , clear
         forvalues i=2/`tf' {
            merge rowname using _tmp`i'  , sort
            drop _merge
         }
         gen order=.
         forvalues i=1/`W' {
            local foo = word("`rowvarsare'",`i')
            di "`foo'"
            cap confirm string variable rowname
            if _rc==0 {
               replace order=`i' if rowname=="`foo'"
            }
            if _rc~=0 {
               replace order=`i' if rowname==`foo'
            }
         }
         sort order
         cap drop order 
         cap drop v*
         forvalues i=1/`tf' {
            cap erase _tmp`i'.csv 
            cap erase _tmp`i'.dta
         }
         foreach var of varlist _all {
            if "`var'"~="rowname" {
               local colnames "`colnames' `var'"
            }
         }
      }
   }
   if "`colnames'"~="" {
      mkmat `colnames' , rownames(rowname) matrix(`matname')
      cap confirm matrix `matname'
      if _rc==0 {
         local outmatrices "`outmatrices' `matname'"
      }
   }

   cap   macro drop _W
   cap   macro drop _matname
   cap   macro drop _i`l'_startin
   cap   macro drop _i`l'_stopin
   cap   macro drop _i`l'_start
   cap   macro drop _i`l'_start_span
   cap   macro drop _i`l'_end
   cap   macro drop _foo
   cap   macro drop _goo
   cap   macro drop _rowvarsare
   cap   macro drop _w1
   cap   macro drop _w2
   cap   macro drop _w3
   cap   macro drop _w4
   cap   macro drop _w5
   cap   macro drop _w6
   cap   cap erase _newdata.do
   cap   macro drop _colnames
   cap   macro drop _S
   cap   macro drop _cont
   cap   macro drop _tf
   cap   macro drop _eq
   cap   macro drop _Nis

} // close qui
}

foreach x in `outmatrices' {
   return mat `x' = `x'
}
return local outmatrices "`outmatrices'"
end
**** end of new material added 6/29/2011
****=============================================================================
