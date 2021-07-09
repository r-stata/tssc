* Read in Mplus output file and load parameter estimtes
* 20150301

version 10.0

capture program drop read_parameterestimates_indirect
program define read_parameterestimates_indirect , rclass

syntax , out(string) [debug]



if "`debug'"=="debug" {
   noisily di _n _col(3) "... now running read_parameter_estimates_indirect.ado" _n ///
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
* PARAMETER ESTIMATES
tempname fh
local linenum = 0
file open `fh' using `"`out'"', read
file read `fh' line
while r(eof)==0 {
   local linenum = `linenum' + 1
   if "`macval(line)'"=="TOTAL, TOTAL INDIRECT, SPECIFIC INDIRECT, AND DIRECT EFFECTS" {
      local start=`linenum'+1
   }
   if "`macval(line)'"=="CONFIDENCE INTERVALS OF MODEL RESULTS" | ///
      regexm("`macval(line)'","Beginning Time")==1  {
      local end=`linenum'-1
      continue, break // exit out of loop
   }
   file read `fh' line
}
file close `fh'
if "`start'"~="" & "`end'"~="" {
   qui {
      infix str col2 2-2 ///
            str line 1-99 ///
            using `out' , clear
      format line %90s
      keep in `start'/`end'
      replace line=subinstr(line,"Total indirect","Totalindirect",1)
      replace line=subinstr(line," ","-",.) if regexm(line,"Effects from")==1
      gen words=wordcount(line)
      gen std=lower(word(line,1)) if word(line,2)=="Standardization"
      gen group=word(line,2) if word(line,1)=="Group" & words==2
      gen class=word(line,3) if word(line,1)=="Latent" & word(line,2)=="Class"
      drop if trim(line)==""
      drop if reverse(word(reverse(line),1))=="P-Value"
      drop if reverse(word(reverse(line),1))=="Two-Tailed"
      replace std=std[_n-1] if trim(std)==""
      replace group=group[_n-1] if trim(group)==""
      replace class=class[_n-1] if trim(class)==""    
      keep if words==1|words==5
      keep if trim(line)~="Two-Tailed"
      gen pvalue=reverse(word(reverse(line),1))
      gen z=reverse(word(reverse(line),2))
      gen se=reverse(word(reverse(line),3))
      gen estimate=reverse(word(reverse(line),4))
      gen param=reverse(word(reverse(line),5))
      replace param=word(line,1) if words==1
      replace pvalue="" if words==1
      gen path = ""
      replace path=line[_n-2]+"-"+param if param=="Totalindirect"
      replace path=line[_n-1]+"-"+param if param=="Total"
      drop if words==1 & regexm(line,"Effects-from")
      gen parameter=.
      local k=0
      forvalues i=1/`c(N)' {
         if estimate[`i']~="" {
            replace parameter=`++k' in `i'
         }
      }
      gen linenum=_n
      gsort -linenum
      gen dlinenum=_n
      sort dlinenum
      replace parameter=parameter[_n-1] if parameter==.
      sort linenum
      sort parameter linenum
      by parameter: gen obs=_n
      by parameter: gen OBS=_N
      by parameter: replace path=param if obs==1 & OBS>1
      by parameter: replace path=path[_n-1]+"-"+param if obs>1
      keep path estimate se z pvalue group class std
      keep path estimate se z pvalue group class std
      replace std=std+"_" if trim(std)~=""
      replace path=trim(std)+path + "_" + group + class
      drop group
      drop class
      drop std
      * remove trailing underscore from param
      replace path=reverse(substr(reverse(path),2,.)) ///
         if substr(reverse(path),1,1)=="_"
      if `c(matsize)'<`c(N)' {
         local foo=`c(N)'*10
         set matsize `foo'
      }
      foreach x in estimate se z pvalue {
         destring `x' , force replace
      }
      drop if estimate==.
      replace path=lower(path)
      * new 2015-04-11
      replace path=subinstr(path,"effects-from-","",1)
      replace path=subinstr(path,"-to-","-",1)
      mkmat estimate se z pvalue, rownames(path) matrix(IND)
      matrix colnames IND = estimate se z pvalue
   }
}

cap macro drop _start
cap macro drop _end

* CONFIDENCE INTERVALS
* PARAMETER ESTIMATES
tempname fh
local linenum = 0
file open `fh' using `"`out'"', read
file read `fh' line
while r(eof)==0 {
   local linenum = `linenum' + 1
   if "`macval(line)'"=="CONFIDENCE INTERVALS OF TOTAL, TOTAL INDIRECT, SPECIFIC INDIRECT, AND DIRECT EFFECTS" {
      local start=`linenum'+1
   }
   if regexm("`macval(line)'","Beginning Time")==1 {
      local end=`linenum'-1
      continue, break // exit out of loop
   }
   file read `fh' line
}
file close `fh'
if "`debug'"=="debug" {
   di "start <- `start'" _n "end  <- `end'"
}
if "`start'"~="" & "`end'"~="" {
   qui {
      infix str col2 2-2 ///
            str line 1-99 ///
            using `out' , clear
      format line %90s
      keep in `start'/`end'
      replace line=subinstr(line,"Total indirect","Totalindirect",1)
      replace line=subinstr(line," ","-",.) if regexm(line,"Effects from")==1
      gen words=wordcount(line)
      gen std=lower(word(line,1)) if word(line,2)=="Standardization"
      gen group=word(line,2) if word(line,1)=="Group" & words==2
      gen class=word(line,3) if word(line,1)=="Latent" & word(line,2)=="Class"
      drop if trim(line)==""
      drop if reverse(word(reverse(line),1))=="P-Value"
      drop if reverse(word(reverse(line),1))=="Two-Tailed"
      replace std=std[_n-1] if trim(std)==""
      replace group=group[_n-1] if trim(group)==""
      replace class=class[_n-1] if trim(class)==""    
      keep if trim(line)~="Two-Tailed"
      keep if words==1|words==8 // distinct for CI and lines below
      gen p995=reverse(word(reverse(line),1))
      gen p975=reverse(word(reverse(line),2))
      gen p950=reverse(word(reverse(line),3))
      gen estimate=reverse(word(reverse(line),4))
      gen p050=reverse(word(reverse(line),5))
      gen p025=reverse(word(reverse(line),6))
      gen p005=reverse(word(reverse(line),7))
      gen param=reverse(word(reverse(line),8))
      replace p005="" if words==1  // end of section distinct for CIs
      replace param=word(line,1) if words==1
      gen path = ""
      replace path=line[_n-2]+"-"+param if param=="Totalindirect"
      replace path=line[_n-1]+"-"+param if param=="Total"
      drop if words==1 & regexm(line,"Effects-from")
      gen parameter=.
      local k=0
      forvalues i=1/`c(N)' {
         if estimate[`i']~="" {
            replace parameter=`++k' in `i'
         }
      }
      gen linenum=_n
      gsort -linenum
      gen dlinenum=_n
      sort dlinenum
      replace parameter=parameter[_n-1] if parameter==.
      sort linenum
      sort parameter linenum
      by parameter: gen obs=_n
      by parameter: gen OBS=_N
      by parameter: replace path=param if obs==1 & OBS>1
      by parameter: replace path=path[_n-1]+"-"+param if obs>1
      keep path estimate p005 p025 p050 p950 p975 p995 group class std
      order path estimate p005 p025 p050 p950 p975 p995 group class std
      replace std=std+"_" if trim(std)~=""
      replace path=trim(std)+path + "_" + group + class
      drop group
      drop class
      drop std
      * remove trailing underscore from param
      replace path=reverse(substr(reverse(path),2,.)) ///
         if substr(reverse(path),1,1)=="_"
      if `c(matsize)'<`c(N)' {
         local foo=`c(N)'*10
         set matsize `foo'
      }
      * BELOW LINE IS DISTINCT FOR CIs
      foreach x in estimate p005 p025 p050 p950 p975 p995 {
         destring `x' , force replace
      }
      drop if estimate==.
      replace path=lower(path)
      * new 2015-04-11
      replace path=subinstr(path,"effects-from-","",1)
      replace path=subinstr(path,"-to-","-",1)
      * BELOW PATH IS DISTINCT FOR CIs
      mkmat estimate p005 p025 p050 p950 p975 p995 , rownames(path) matrix(INDCI)
      matrix colnames INDCI = estimate p005 p025 p050 p950 p975 p995 
   }
}

foreach x in IND INDCI {
   cap confirm matrix `x'
   if _rc==0 {
      return mat `x' = `x'
      local outmatrices "`outmatrices' `x'"
   }
}
return local outmatrices "`outmatrices'"


use `origdat', clear

end

***=============================================================================

