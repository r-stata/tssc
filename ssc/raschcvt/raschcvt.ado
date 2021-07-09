*! raschcvt version 1.2.1 fw 8/1/00 Prepares data file and c0ntrol file for Winsteps
*! 5/26/01 update to version 7. turns off log output, 1.2.2 (12/20/01) corrects 
*! decimal point formatting error and removes "LOADING = 40".
program define raschcvt
   version 7.0
   syntax varlist, outfile(string) id(varlist) max(integer) [min(integer 0)] [Xwide(integer 2)]
   tokenize `varlist'
   set more off
   preserve
   
   confirm variable `id'
   
   di in gr "Building Rasch files"
   
   local itemno = 0
   local counter = 0
   while "`1'" != "`id'" {
      local itemno = `itemno' + 1
      mac shift
   }      
   capture log close
   qui log using `outfile'.con, replace
   
   di ";The id variable is " "`id'"
   di ";There are `itemno' items"
   
   di ";Items and lengths"
   tokenize `varlist'
   while "`1'" != "" {
      capture assert `1' == int(`1')
      if _rc != 0 {
         di "non-integer value found"
         exit _rc
      }
      local counter = `counter' + 1
      qui su `1'
      local f = length("`r(max)'")
      di ";" "`1'" " " `f' " " `g'
      if `counter' <= `itemno' {
         local f = `xwide'
      }
      format `1' %0`f'.0f
      qui replace `1' = 99 if `1' == . & `f' == 2
      qui replace `1' = 999 if `1' == . & `f' == 3
      macro shift
   }
   order `varlist'
   qui outfile `varlist' using `outfile'.dat, nolabel wide replace 
   di ";`outfile' has been written to disc"  

   di in gr ";Start control file below"
   di
   di  "TITLE="
   di  "DATA=`outfile'.dat"
   di  "ITEM1=1"
   di  "NI=" "`itemno'"
   di  "NAME1=" `itemno' +1
   di  "DELIMITER = SPACE"
   di  "XWIDE=`xwide'"
   di  "CODES="_c
   if `xwide' == 1{
      for num `min' / `max', noheader: di X _c 
   }
   if `xwide' == 2{
      for num `min' / `max', noheader: if X == 0{di "00"_c} \ if X >0 & X <10{di "0"X _c} \ if X >9 & X < 99 {di X _c}
   }
   if `xwide' == 3{
      for num `min' / `max', noheader: if X == 0{di "000"_c} \ if X >0 & X <10{di "00"X _c} \ if X >9 & X < 99 {di "0"X _c} \ if X >99 {di X _c}
   }
   di
   di  "MAXPAG=60"
   di  "PRCOMP=S"
   di  "MUCON=0"
   di  "LCONV= .001
   di  "RCONV= .1"
   di  "GROUPS="
   di  "HLINES=Y"
   di  ";PSELECT= ?????1*"
   di  ";TABLES=11110110011111000001111"
   di  ";ISFILE=`outfile'.isf"
   di  ";IFILE=`outfile'.IFL"
   di  ";PFILE=`outfile'.PFL"
   di  ";XFILE=`outfile'.XFL"
   
   di 
   di  "&END"
   di
   tokenize `varlist'    
   while "`1'" != "`id'" {
      local lbl:variable label `1'
      di "`lbl'"
      macro shift
   }
   di "END LABELS"
   di
   tokenize `varlist'
      while "`1'" != "`id'" {
         di "`1'" 
         macro shift
   }
      di "END NAMES"

   qui log close
   restore
end
