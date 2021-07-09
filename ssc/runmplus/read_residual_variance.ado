* Read in Mplus output file and load parameter estimtes
* 20130730 destring replace force added
version 10

capture program drop read_residual_variance
program define read_residual_variance , rclass 

syntax , out(string) [debug]

if "`debug'"=="debug" {
  di in yellow _n _col(10) "Now inside" in green " read_residual_variance.ado in debug mode" _n
}

if `c(N)'==0 {
   set obs 1
   tempvar thud
   gen `thud'=1
}

qui tempfile origdat
qui save `origdat', replace

set more off


if "`debug'"=="debug" {
  di in yellow _n _col(10) "about to read the output file (line 30)"
}


qui infix str line 1-85 ///
      str name 1-19 ///
      str value 20-67 ///
      using `out' , clear
format line %85s

if "`debug'"=="debug" {
  di in yellow _n _col(10) "output file read successfully"
}


qui {


        * CONFIRM THERE IS AN R-SQUARE SECTION
        gen _foo1=_n if trim(line)=="R-SQUARE"
        su _foo1
        if r(N)==0 {
           if "`debug'"=="debug" {
              di _col(15) "Could not find R-SQUARE section in output. exiting." _n
           }
           exit
        }
        drop _foo1
        if "`debug'"=="debug" {
          di in yellow _n _col(10) "we seem to have found R-SQUARE section"
        }       
        * CONFIRM THERE IS AN VARIANCE COLUMN 
        gen _foo1=_n if regexm(trim(lower(line)),"variance")==1
        su _foo1
        if r(N)==0 {
           if "`debug'"=="debug" {
              di _col(15) "Could not find variance column in output. exiting." _n
           }
           exit
        }
        drop _foo1
        if "`debug'"=="debug" {
          di in yellow _n _col(10) "we seem to have found a variance column"
        }       
        * IDENTIFY START AND END OF Parameter estimates
        gen linenum=_n
        * MODIFIED 20150301
        gen x1=_n if (trim(line)=="R-SQUARE")| ///
         (trim(line)=="QUALITY OF NUMERICAL RESULTS") | ///
         (trim(line)=="CONFIDENCE INTERVALS OF MODEL RESULTS")
        summarize x1
        keep if inrange(linenum,r(min)+1,r(max)-1)
        drop if trim(line)==""
        if `c(N)'==0 {
           if "`debug'"=="debug" {
              di _col(15) "Turns out there are not R-SQUARE or residual variance after all. exiting." _n
           }
           exit          
        }
        drop x1
        drop linenum
        gen linenum = _n
       
        * cleanup
        drop if substr(trim(line),1,8)=="Observed"
        drop if substr(trim(line),1,8)=="Variable"
        replace line=subinstr(line,"Latent Class","Class",.)
        list linenum line , clean
        * suffix
        gen suffix= lower(word(trim(line),2)) if wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,5)=="Class")
        replace suffix=suffix[_n-1] if _n>1 & suffix==""

        *prefix
        gen prefix=line if (wordcount(line)==2|wordcount(line)==1) & (wordcount(line)==2 & (substr(trim(line),1,5)=="Group"|substr(trim(line),1,5)=="Class"))~=1
        replace prefix=lower(prefix)
        replace prefix=prefix[_n-1] if _n>1 & prefix==""
        
        * Second prefix
        gen eset =""
        replace eset = line if substr(trim(line),1,21)=="STDYX Standardization"
        replace eset = line if substr(trim(line),1,20)=="STDY Standardization"
        replace eset = line if substr(trim(line),1,19)=="STD Standardization"
        replace eset = "residual_variance" if substr(trim(line),1,8)=="R-SQUARE"
        replace eset = lower(eset)
        replace eset = subinstr(eset,"standardization","",.)
        replace eset = eset[_n-1] if _n>1 & eset==""
     
        * parameter
        gen parameter = lower(word(trim(line),1)) if (wordcount(line)==2 & substr(trim(line),1,5)=="Group")~=1
        
        * estimate
        gen estimate=word(trim(line),3) // word 3 only applies to residual variance
        replace estimate="" if estimate=="Undefined" 
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
        
        * added 1/2/2009 by Frances Yang
        drop if regexm(x,"category")==1
        destring estimate , replace
      
       
        keep x estimate 
        rename estimate residual_variance
        * added 20130730
        destring residual_variance , force replace
        
        capture matrix drop residual_variance
       
        local MS=_N
        capture set matsize `MS'
        if _rc==0 {
         set matsize `MS'
        }
        
             
        mkmat residual_variance , rownames(x)
        
        return matrix residual_variance = residual_variance
        
        qui use `origdat' , replace
        
}




end

