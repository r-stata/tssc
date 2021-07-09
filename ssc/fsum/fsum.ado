*! fsum.ado  v 2.6.0 fw 6may14 
*! keywords: summarize 

program define fsum, sortpreserve byable(recall)   
   version 8.2
   syntax [varlist] [fweight aweight] [if] [in] [,Stats(string) Format(string) Pctvar(varlist) /*
      */ COMplete Label Uselabel Varname Addstats(string) CATvar(varlist) /*
      */ MCATvar(varlist) Decsum  not(varlist) sort ]

   if "`sort'" == "sort" {
      local varlist : list sort varlist
   }
   if "`not'" != "" {
      capture confirm var `not'
      if _rc == 0 {
         unab not : `not'
         local varlist: list varlist - not
      }
      else {
         di as error "Variable name(s) to exclude contain a non variables"
         exit 190
      }
   }

   if "`complete'" == "" {
     marksample touse, novar
   }
   else { 
      marksample touse
   }

   if "`label'" == "label" & "`uselabel'" == "uselabel" {
      di in error "label and uselabel options can not be specified together"
      exit 198
   }

                      /* catvar section */
                      
   local catvanum = 0
   local catchboth : list catvar & mcatvar
   if "`catchboth'" != "" {
      di in err "`catchboth' cannot be specified in catvar() and mcatvar() /*
         */at the same time"
      exit 190
   }
   local catvarlength = 0
   
   foreach var of varlist `varlist' {
      if index("`catvar'", "`var'") != 0 | index("`mcatvar'", "`var'") != 0 {
         local catvarnum = `catvarnum' + 1
         global catvar`catvarnum' `var'
         tempname Vals Cell
         if index("`catvar'", "`var'") != 0 { 
            qui tab `var' if `touse', matrow(`Vals') matcell(`Cell') 
         local nvals = r(r)
         local valtot = r(N)
         }
         else { 
            qui tab `var' if `touse', matrow(`Vals') matcell(`Cell') miss
            local nvals = r(r)
            local valtot = r(N)
         }
         forvalues i = 1 / `nvals' {
            local val = `Vals'[`i',1]
            local count = `Cell'[`i',1]
            local vname: label (`var') `val'
            if length("`vname'") > `catvarlength' {
               local catvarlength = length("`vname'") 
               global catvarlength `catvarlength'

            }
            local catpct = (`count'/`valtot') * 100
            
            local ctv`var'_vname_`i'  `vname'
            local ctv`var'_N_`i' = `count'
            local ctv`var'_Mean_`i' = `catpct'
            local ctv`var'_totline = `i'          
         }
      }
   }
   
                    /* set up formats and length variables */

   if "`format'" == "" {
      local format  "9.2"
   }
   /* now test format */
   local testformat = 1.23
   capture confirm number `format'
   if _rc != 0 {
      capture local testformat: di `format' `testformat'
      if _rc != 0 {
         di in error "Format specified is `format'. Must be in the form of ##.# or %##.#f"
         exit 198
      }
   }   
                         /* strip off % and f if present - make sure it is 'f' */
   if index("`format'","%") == 1  {
      local format = substr("`format'",2,.)
   }
   local tlength = length("`format'")
   capture confirm number `format'
   if _rc != 0 {
      if substr("`format'",`tlength',1) != "f" {
         di in error "Format specified is `format'. Must be in the form of ##.# or %##.#f"
         exit 198
      }
      local format = substr("`format'",1,`tlength' - 1)
   }
   
   local flength = int(`format')
   if `flength' >20 {
      di in error "Format length (`flength') is > 20"
      exit 198
   }
   local period = index("`format'",".")
   if `period' == 0 {
      di in error "Format period (.) is missing"
      exit 198
   }
   local dlength = substr("`format'",`period' + 1,.)
   local format "%`format'f"
   local eformat "%`flength'.`dlength'e"  
   local i1 = index("`format'",".")
   local f1 =substr("`format'",2,`i1'-2)
   local f2 = substr("`format'",`i1'+1,1)
   local sumformat = "%`=`f1'+0'.0f"  
   if "`decsum'" == "decsum" {
      local sumformat `format'
   }
   local spacing = `flength'
   local roundvar = 10^-`dlength'
               /* `spacing' and `flength' control column title and result positions */
   if "`stats'" == "" {
      local stats "n mean sd min max"
   }
   local stats `stats' `addstats'
   local stats = lower("`stats'")
   local stats n mean `stats'
   local stats : subinstr local stats "p50" "median",word
   local stats : subinstr local stats "med" "median",word
   local stats : list uniq stats
   local allstats n miss abspct mean vari sd se p1 p5 p10 p25 median p75 p90 p95 p99  min max lci uci sum
   local onelist : list stats - allstats

   if "`onelist'" != "" {
      di in result "`onelist'" in error " is not a valid statistic"
      exit 198
   }
   local stats : list allstats & stats
   local stats: subinstr local stats "mean" "Mean"
   local stats: subinstr local stats "n" "N",word
   local stats: subinstr local stats "miss" "Missing"
   local stats: subinstr local stats "abspct" "AbsPct"
   local stats: subinstr local stats "vari" "VAR"
   local stats: subinstr local stats "sd" "SD"
   local stats: subinstr local stats "se" "SE"
   local stats: subinstr local stats "p1" "P1"
   local stats: subinstr local stats "p5" "P5"
   local stats: subinstr local stats "p10" "P10"
   local stats: subinstr local stats "p25" "P25"
   local stats: subinstr local stats "median" "Median"
   local stats: subinstr local stats "p75" "P75"
   local stats: subinstr local stats "p90" "P90"
   local stats: subinstr local stats "p95" "P95"
   local stats: subinstr local stats "p99" "P99"
   local stats: subinstr local stats "min" "Min"
   local stats: subinstr local stats "max" "Max"
   local stats: subinstr local stats "lci" "LCI"
   local stats: subinstr local stats "uci" "UCI"
   local stats: subinstr local stats "sum" "Sum
   tokenize `stats'
                                                   /* calculate length of variable or tlabel */
   local length 0 /* will be length of longest name/tlabel */
   foreach var of varlist `varlist' {
      local vartype: type `var'   
      if substr("`vartype'",1,3) == "str" {
         continue
      }      
      local statalabel: variable label `var'
      local tlabel: char `var'[tlabel]   
      if "`tlabel'" != "" { 
         local tlength = length("`tlabel'")      /* tlength = temporary length holder */
      }   
      else if "`statalabel'" != ""  & "`uselabel'" == "uselabel" {
         local tlength = length("`statalabel'")   /* tlength = temporary length holder */
      }
      else {
         local tlength = length("`var'")
      }
         if `tlength' > `length' {
         local length `tlength'  
         }
      }
      local catvarlength = $catvarlength + 5
      local startcol = max(`catvarlength',`length', length("variable")) + 1 
      local linecol = `startcol' + 1
      local syslinesize: set linesize
      set linesize 240   
      di
      di in text "{ralign `startcol': Variable}" " {c |}" "{ralign `spacing':`1'}" "{ralign `spacing':`2'}" /*
         */ "{ralign `spacing':`3'}" "{ralign `spacing':`4'}" "{ralign `spacing':`5'}" "{ralign `spacing':`6'}" /*
         */ "{ralign `spacing':`7'}" "{ralign `spacing':`8'}" "{ralign `spacing':`9'}" "{ralign `spacing':`10'}" /*
         */ "{ralign `spacing':`11'}" "{ralign `spacing':`12'}" "{ralign `spacing':`13'}" "{ralign `spacing':`14'}" /*
         */ "{ralign `spacing':`15'}" "{ralign `spacing':`16'}" "{ralign `spacing':`17'}" "{ralign `spacing':`18'}" "{ralign `spacing':`19'}" 
      local wcount: word count `stats'
      local linelength = (`wcount' * `spacing') 
      di in text "{hline `linecol'}{c +}{hline `linelength'}"
      set linesize `syslinesize'
      local vlabstart = `linelength' + `linecol' + 4 /* starting col for varlabel */   

      local misslen = 0
      if `f1' - 9 > 0 {
         local misslen = (`f1' - 9) * 3
      }
                                            /* get and format requested variables */   
      foreach var of varlist `varlist' {
      local vartype: type `var'
      if substr("`vartype'",1,3) == "str" {
         continue
      }      
         if index("`stats'","Median") == 0 & index("`stats'","P1") == 0 & index("`stats'","P5") == 0 & index("`stats'","P10") == 0  & index("`stats'","P25") == 0 /*
            */  & index("`stats'","P75") == 0  & index("`stats'","P90") == 0 & index("`stats'","P95") == 0  & index("`stats'","P99") == 0 {  
            if("`weight'"==""){
               local weight="fweight"
               local exp="=1"
            }
            qui sum `var' [`weight' `exp'] if `touse'
         }
          else {
            qui sum `var' [`weight' `exp'] if `touse', detail
         }    
         local tlabel: char `var'[tlabel]
         local statalabel: variable label `var'
         if index("`stats'","N") != 0 {  
            local N: di %`flength'.0g `r(N)'
            if length("`N'") > `flength'  {
               local N: di %`flength'.0e `r(N)'
            }
         }
         if `r(N)' == 0{
            local miss 
            local abspct 
            local mean 
            local vari
            local sd
            local se 
            local p1
            local p5
            local p10
            local p25
            local median 
            local p75
            local p90
            local p95
            local p99
            local min 
            local max
            local lci 
            local uci 
            local sum 
            local varlabel
            if "`label'" == "label" {
               local varlabel: variable label `var'
            }
         if "`varname'" == "varname" {
            if "`tlabel'" != "" {
               di as text "{ralign `startcol' : `tlabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"  as result "{ralign 0:{col `vlabstart'}`var'}"
            }
            else if "`uselabel'" == "uselabel" & "`statalabel'" != "" {
               di as text "{ralign `startcol' : `statalabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`vari'`mean'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"  as result "{ralign 0:{col `vlabstart'}`var'}"
            }
            else {
               di as text "{ralign `startcol' : `var'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"  as result "{ralign 0:{col `vlabstart'}`var'}"
            }
         }
         else {
            if "`tlabel'" != "" {
               di as text "{ralign `startcol' : `tlabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"  as result "{ralign 0:{col `vlabstart'}`varlabel'}"
            }
            else if "`uselabel'" == "uselabel" & "`statalabel'" != "" {
               di as text "{ralign `startcol' : `statalabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"  as result "{ralign 0:{col `vlabstart'}`varlabel'}"
            }
            else {
               di as text "{ralign `startcol' : `var'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"  as result "{ralign 0:{col `vlabstart'}`varlabel'}"
            }
         }
            continue   
         }         
         if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
            local mean = `r(mean)' * 100
            local mean: di `format' `mean'
         }
         if index("`tlabel'","%") == 0 & "`var'" != "`:list pctvar & var'"{
            local routput: di %30.0f `r(mean)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
            if `addlength' >= `flength' - 1{
                local mean: di `eformat' `r(mean)'
             }         
             else {
               local mean: di `format' `r(mean)' 
            }        
         }
         if index("`stats'","VAR") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'" {   
               local vari "         "
            }
            else{ 
               local vari: di `format' `r(Var)'
            local routput: di %30.0f `r(Var)'
            capture local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local vari: di `eformat' `r(Var)'         
               }
            }   
         }      
         if index("`stats'","SD") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'" {   
               local sd "         "
            }
            else{ 
               local sd: di `format' `r(sd)'
            local routput: di %30.0f `r(sd)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local sd: di `eformat' `r(sd)'         
               }
            }   
         }      
         if index("`stats'","Sum") != 0 {     
            local sum : di `sumformat' `r(sum)' 
            local routput: di %30.0f `r(sum)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
            if `addlength' >= `flength' - 1{
               local sum: di `eformat' `r(sum)'         
            }
         }                  
        if index("`stats'","P1") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p1 "         "
            }
            else{ 
               local p1: di `format' `r(p1)'
            local routput: di %30.0f `r(p1)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p1: di `eformat' `r(p1)'         
               }
            }
         }      
         if index("`stats'","P5") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p5 "         "
            }
            else{ 
               local p5: di `format' `r(p5)'
            local routput: di %30.0f `r(p5)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p5: di `eformat' `r(p5)'         
               }
            }
         }
         if index("`stats'","P10") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p10 "         "
            }
            else{ 
               local p10: di `format' `r(p10)'
            local routput: di %30.0f `r(p10)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p10: di `eformat' `r(p10)'         
               }
            }
         }      
         if index("`stats'","P25") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p25 "         "
            }
            else{ 
               local p25: di `format' `r(p25)'
            local routput: di %30.0f `r(p25)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p25: di `eformat' `r(p25)'         
               }
            }
         }      
         if index("`stats'","Median") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local median "         "
            }
            else{ 
               local median: di `format' `r(p50)'
            local routput: di %30.0f `r(p50)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local median: di `eformat' `r(p50)'         
               }
            }
         }      
         if index("`stats'","P75") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p75 "         "
            }
            else{ 
               local p75: di `format' `r(p75)'
            local routput: di %30.0f `r(p75)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p75: di `eformat' `r(p75)'         
               }
            }
         }      
         if index("`stats'","P90") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p90 "         "
            }
            else{ 
               local p90: di `format' `r(p90)'
            local routput: di %30.0f `r(p90)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p90: di `eformat' `r(p90)'         
               }
            }
         }      
         if index("`stats'","P95") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p95 "         "
            }
            else{ 
               local p95: di `format' `r(p95)'
            local routput: di %30.0f `r(p95)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p95: di `eformat' `r(p95)'         
               }
            }
         }      
         if index("`stats'","P99") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local p99 "         "
            }
            else{ 
               local p99: di `format' `r(p99)'
            local routput: di %30.0f `r(p99)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local p99: di `eformat' `r(p99)'         
               }
            }
         }      
         if index("`stats'","Min") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local min "         "
            }
            else{ 
               local min: di `format' `r(min)'
            local routput: di %30.0f `r(min)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local min: di `eformat' `r(min)'         
               }
            }
         }
         if index("`stats'","Max") != 0 {         
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local max "         "
            }
            else {
               local max: di `format' `r(max)'
            local routput: di %30.0f `r(max)'
            local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local max: di `eformat' `r(max)'         
               }
            }
         }
         if index("`stats'","SE") != 0 | index("`stats'","LCI") != 0 /*
            */ | index("`stats'","UCI") != 0 {
            qui ci `var' if `touse'
      
            if index("`stats'","SE") != 0 {   
               if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
                  local se = "         "
               }
               else { 
                  local se: di `format' `r(se)'
                  local routput: di %30.0f `r(se)'
                  local addlength = `dlength' + length(string(`routput',"%30.0f"))
                  if `addlength' >= `flength' - 1{
                     local se: di `eformat' `r(se)'         
                  }
               }
            }         
         if index("`stats'","LCI") != 0 {   
            if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
               local lci "         "
               }
            else{ 
               local lci: di `format' `r(lb)'
               local routput: di %30.0f `r(lb)'
               local addlength = `dlength' + length(string(`routput',"%30.0f"))
               if `addlength' >= `flength' - 1{
                  local lci: di `eformat' `r(lb)'         
               }
            }
         }   
            if index("`stats'","UCI") != 0 {   
               if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
                  local uci "         "
               }
               else{ 
                  local uci: di `format' `r(ub)'
                  local routput: di %30.0f `r(ub)'
                  local addlength = `dlength' + length(string(`routput',"%30.0f"))
                  if `addlength' >= `flength' - 1{
                     local uci: di `eformat' `r(ub)'         
                  }
               }
            }      
         }
         if index("`stats'","Missing") != 0 {
            qui count if `var' == . & `touse'
            local miss: di %`flength'.0f `r(N)'
         }
         if index("`stats'","AbsPct") != 0 {
            qui count if `touse'
            local tcount = `r(N)'
            qui count if `var' == . & `touse'
            local abspct = (`r(N)' / `tcount') * 100
            local abspct: di `format' `abspct'
         }
         local varlabel
         if "`label'" == "label" {
            local varlabel: variable label `var'
         }
         *local tlabel : subinstr local tlabel " (code)" ""  // may need to fix code here
      
         if index("`tlabel'","%") > 0  | index("`tlabel'","code") > 0 | "`var'" == "`:list pctvar & var'"{   
            local space  = `misslen'
         }
         else {
            local space = 0
         }
         if "`varname'" == "varname" {
            if "`tlabel'" != "" {
               di as text "{ralign `startcol' : `tlabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'{space `space'}`sum'}"  as result "{ralign 0:{col `vlabstart'}`var'}"
            }
            else if "`uselabel'" == "uselabel" & "`statalabel'" != "" {
               di as text "{ralign `startcol' : `statalabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'{space `space'}`sum'}"  as result "{ralign 0:{col `vlabstart'}`var'}"
            }
            else {
               di as text "{ralign `startcol' : `var'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'{space `space'}`sum'}"  as result "{ralign 0:{col `vlabstart'}`var'}"
            }
            }
         else {
            if "`tlabel'" != ""  {
               di as text "{ralign `startcol' : `tlabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'{space `space'}`sum'}"  as result "{ralign 0:{col `vlabstart'}`varlabel'}"
            }
            else if "`uselabel'" == "uselabel" & "`statalabel'" != "" {
               di as text "{ralign `startcol' : `statalabel'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'{space `space'}`sum'}"  as result "{ralign 0:{col `vlabstart'}`varlabel'}"
            }
            else {
               di as text "{ralign `startcol' : `var'}" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'{space `space'}`sum'}"  as result "{ralign 0:{col `vlabstart'}`varlabel'}"
            }
         }    
         if index("`catvar'","`var'") != 0 | index("`mcatvar'","`var'") != 0 {
            local mean 
            local vari
            local sd
            local se 
            local p1
            local p5
            local p10
            local p25
            local median 
            local p75
            local p90
            local p95
            local p99
            local min 
            local max 
            local lci 
            local uci 
            local sum 
            local abspct
            local miss
            if index("`stats'","Missing") != 0 {
               local miss: di `format' 0 
            }
            if index("`stats'","AbsPct") != 0 {
               local abspct: di `format' 0
            }
            local totline = `ctv`var'_totline'
            forvalues i = 1 / `totline' {
            local outname `ctv`var'_vname_`i''
            if "`outname'" == "." {
               local outname "Missing"
            }
            local N: di %`flength'.0g `ctv`var'_N_`i''
            local mean: di `format' `ctv`var'_Mean_`i''
            di as text "{ralign `startcol' : `outname' (%) }" " {c |}" as result "{ralign 0:`N'`miss'`abspct'`mean'`vari'`sd'`se'`p1'`p5'`p10'`p25'`median'`p75'`p90'`p95'`p99'`min'`max'`lci'`uci'`sum'}"
         }
         local abspct
         local miss
      }
   }      
end


