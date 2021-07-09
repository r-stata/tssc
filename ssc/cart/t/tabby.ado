program define tabby
*!Tabulation with more control over format
/*
Date: 1/10/96  
Last modification: 4/2/97, 16/6/97, 22/11/97, 20/4/98, 25/11/98, 18/2/99
Author: Wim van Putten, DDHCC, Rotterdam
Creates formatted table of one variable (or list of variables)
by another variable (optional). With possibility of suppression of
header and default display of descriptors of variables

Format:
 tabby varlist [if] [in],  options

See help.

 Other ado files required:      fns.ado

Note: bylab vervangen door blb
      byval vervangen door bvl

The by-var may also be a string variable!  Column labels will be abbreviated
to max 8 characters. With width() this may be even specified smaller.

3/4/01 Option test() added, which requests a Pearson Chisquare test, Kruskal Wallis test 
or nptrend test or Spearman rank correlation test of association between
each row var and the column variable. Note in this part of the analysis missing values in
either the row or the column are not taken into account, even though they may be listed 
in the tabby table!

11/5/01 Width convention has been changed. Specifies now the minimum width of columns.
Each column separately get a wider width if necessary.

*/

version 5.0
quietly {
local varlist "req ex min(1) "
#delimit ;
local options "BY(string) Label(string) Bymis Mis Width(int 10) 
        Head Total Col Row Perc Dec(int 0) Start(int 12)
        noBYTot noZero MAX(int 100) TEst(string) ";
#delimit cr
local weight "fweight"
local if "opt"
local in "opt"
parse `"`0'"' 
if "`weight'"~="" {local weight [`weight' `exp'] }
preserve

if `"`if'`in'"'~="" { keep `if' `in'}
if _N==0 {
        noisily display `"`if' `in' : no observations"'
        exit
}
tempvar _blb _vlab _val NN  NNN SNN CAT  rownr NR RTOT CTOT


parse "`by'",parse(" ,")
local by "`1'"               /* Only first string counts as by-variable */
local nby=1
if "`by'"~="" {
        unabbrev `by'
        local byname : variable label `by'
        local bytype : type  `by'
        if index("`bytype'","str")>0 {
                replace `by'=trim(`by')
                compress `by'
        }
        if "`byname'"=="" { local byname "`by'" }
        if "`bymis'"=="" {     /* Exclude observations missing on by-variable 
                                unless the missing are included as category */
           if index("`bytype'","str")>0 { drop if `by'=="" }
           else { drop if `by'==. }
           if _N==0 {
                noisily display "no observations with `by' non-missing"
                exit
           }
        }
        tempvar colnr
        sort `by' 
        quietly by `by' : gen int `NNN'=1 if _n==1
        gen int `colnr'=sum(`NNN')
        local nby=`colnr'[_N]
        local blb : value label `by'
        if "`blb'"~="" {
           capture label list `blb'
           if _rc>0 {   /* value label not defined */
                local blb 
           }
        }
        if index("`bytype'","str")>0 {
         local w=max(`width',2)
         gen str`w' `_blb' = `by' 
        }
        else {
         if "`blb'"~="" {  decode `by' ,gen(`_blb') }
         else           {  gen str8 `_blb'=string(`by') }
         replace `_blb'=string(`by') if `_blb'==""
        }
        local byby "by(`by')" 
}

if index("`test'","chi")>0 {local test Chi2}
else if index("`test'","tr")>0 {local test trendtest }                                           
else if index("`test'","kw")>0 {local test K-W }                                           
else if index("`test'","sp")>0 {local test Spearman} 
else if index("`test'","rh")>0 {local test Spearman }
else if index("`test'","fish")>0 {local test exact}
else if index("`test'","exac")>0 {local test exact}

if "`col'"~="" |("`perc'"=="perc"&"`by'"~="") { local perc col }
else if "`row'"~=""&"`by'"~=""                { local perc row }
if "`perc'"=="row"&`nby'<=1 {
         local perc 
         local row 
}
if `start'<12 {local start 12}

*Determine max column width of all numeric strings to be displayed.
*Separately for body of table and the total-column!
*11/5/2001: separately for each column of the table now!
if "`perc'`row'`col'"~="" {
 if `dec'>0  { local pwidth =4+`dec' }
 else        { local pwidth =3       }
}
else { local pwidth=0 }
egen `NN'=count(1),`byby'
local sumwid=0

if `nby'>1&"`row'"!="" {
  local j=1
  while `j'<=`nby' {
    local width`j'=max(`width',`pwidth')
    local sumwid=`sumwid'+`width`j''
    local j=`j'+1
  }
}
else if `nby'>1&"`perc'`col'"!="" {
  local j=1
  while `j'<=`nby' {
    quietly su `NN' if `colnr'==`j'
    local l=r(max)
    local width`j'=max(`width',`pwidth',length("`l'"))
    local sumwid=`sumwid'+`width`j''
    local j=`j'+1
  }
}
else if `nby'>1 {
  local j=1
  while `j'<=`nby' {
    quietly su `NN' if `colnr'==`j'
    local l=r(max)
    local width`j'=max(`width',length("`l'"))
    local sumwid=`sumwid'+`width`j''
    local j=`j'+1
  }
}
else {
  quietly su `NN'
  local l =r(max)
  local width1=max(`width',length("`l'"))
  if "`perc'`col'"~=""  {local width1=max(`width1',`pwidth')}
  local sumwid=`sumwid'+`width1'
}
drop `NN'  

*Create labels for head of Table, if requested
*Shorten the label if  length > width .      Modification 25/11/98.   
if "`by'"~="" { 
 sort `NNN' `colnr'
 local j=1 
 while `j'<=`nby' {
        local blb`j'= substr(`_blb'[`j'],1,`width`j'')
        local bvl`j'=`by'[`j']
        local j=`j'+1 
 }
 drop  `NNN' 
}

local l=_N 
local wtot=max(5,`width',1+length("`l'"))  /* width for total column */

keep `varlist' `by'  `colnr'

local ntot=_N
if "`total'"~=""&"`mis'"~=""&"`by'"~="" {
  egen `NN'=count(1),`byby'
  sort `by'  
  quietly by `by' : gen int `NNN'=1 if _n==1
  sort `NNN' `colnr'
  local j=1 
  while `j'<=`nby' {
        if "`perc'"=="row" {
           local b=100*`NN'[`j']/`ntot'
           fns a `b' ,w(`width`j'') d(`dec')
           local n_`j'  $a 
        }
        else { local n_`j'=max(0,`NN'[`j'])  }
        local j=`j'+1 
  }
  drop `NN' `NNN' 
}

*Adapt the start column of the body of the table to the max width required
* for variables in the varlist
eformat `varlist'" ,val lab
parse "`varlist'" ,parse(" ")
while "`1'"~="" {
 local w: char `1'[width]
 local start =max(`start',`w'+4) 
 macro shift 
}

local s1 =`start'-1
local s2 =`start'
local s3 =`start'+1

local Ppos=`start'+`sumwid'

} /* end quietly */
if "`head'"~="" &(`nby'>1|"`by'"~="") {
        display _col(`s2') "|  `byname' " 
        display _col(`s2') "|"   _continu
        local j=1 
        while `j'<=`nby' {
                local skip=`width`j''-length("`blb`j''")
                display _skip(`skip') "`blb`j'' " _contin
                local j= `j'+1 
        }
        if `nby'>1&("`bytot'"==""|"`perc'"=="row") {
                display "|" _cont  
                local skip=max(0,`wtot'-length("Total"))
                local last=max(5,`wtot')
                display  _skip(`skip') "Total" 
        }
        else { 
                display " " 
                local last 1
        }
        local j=`sumwid'+`nby'

        if "`perc'"=="row" &`nby'>1{
          if `j'>18 {
                local p1=`start'+4+int((`j'-18)/2)
                local pt [row percentages]              
                local p2=max(`p1'+18,`start'+`j'+`wtot'-1)
                local ptot [#] 
          }             
          else { 
                local p1=`start'+3+int((`j'-7)/2)
                local pt [row %]          
                local p2=max(`p1'+8,`start'+`j'+`wtot'-1)
                local ptot [#] 
          }             
        }       
        else if "`perc'"=="col" {
          if `j'>21 {
                local p1=`start'+3+int((`j'-21)/2)
                local pt [column percentages]           
                local p2=max(`p1'+22,`start'+`j'+6)
                local ptot  
          }             
          else { 
                local p1=`start'+3+int((`j'-10)/2)
                local pt [column %]             
                local p2=max(`p1'+11,`start'+`j'+6)
                local ptot  
          }     
        }               
        if "`bytot'"~=""&"`perc'"~="row" { local ptot }
        if "`perc'"~="" { display _col(`p1') "`pt'" _col(`p2') "`ptot'" }
        display _dup(`s1') "-" "+"   _continue
        if "`bytot'"==""|"`perc'"=="row" {
                display _dup(`j') "-" "+" _dup(`last') "-" 
        }
        else{
                local j1 =`j'-1
                display _dup(`j1') "-" 
        } 
}                  
else if "`head'"=="" &`nby'>1&"`perc'"!="$preperc"  {
        local j=`sumwid'+`nby'

        if "`perc'"=="row" &`nby'>1{
          if `j'>18 {
                local p1=`start'+4+int((`j'-18)/2)
                local pt [row percentages]              
          }             
          else { 
                local p1=`start'+3+int((`j'-7)/2)
                local pt [row %]          
          }             
        }       
        else if "`perc'"=="col" {
          if `j'>21 {
                local p1=`start'+3+int((`j'-21)/2)
                local pt [column percentages]           
          }             
          else { 
                local p1=`start'+3+int((`j'-10)/2)
                local pt [column %]             
          }     
        }               
        else  {
          if `j'>18 {
                local p1=`start'+4+int((`j'-18)/2)
                local pt [frequencies]           
          }             
          else { 
                local p1=`start'+3+int((`j'-7)/2)
                local pt [freq.]             
          }     
        }               
        display _col(`p1') "`pt'" 
}                  
else if `nby'<=1&"`by'"=="" & "`perc'"=="col" {
        local p1=`start'+`width1'-5
        display _col(`p1') "[column %]" 
}                  
else if `nby'<=1&"`by'"==""  & "`perc'"=="perc" &"`head'"!="" {
        local p1=`start'+`width1' - 3
        display _col(`p1') "Number     [%]" 
}                  
global preperc `perc'
if "`total'"~=""&"`mis'"~="" {
  if ("`perc'"~="row"&"`by'"~="") {
        display " Total [#]" _col(`s2') "|" _continue 
        local j=1 
        while `j'<=`nby' {
                local skip=`width`j''-length("`n_`j''")
                display _skip(`skip') "`n_`j'' " _contin
                local j= `j'+1 
        }
        if ("`bytot'"==""|"`perc'"=="row") &`nby'>1{
                display "|" _cont  
                local skip=`wtot'-length("`ntot'")
                display  _skip(`skip') "`ntot'" 
        }
        else {  display " " }
  }
  else  if "`perc'"=="row"&`nby'>1 {
        display " Total [%]" _col(`s2') "|" _continue 
        local j=1 
        while `j'<=`nby' {
                local skip=`width`j''-length("`n_`j''")
                display _skip(`skip') "`n_`j'' " _contin
                local j= `j'+1 
        }
        display "|" _cont  
        local skip=`wtot'-length("`ntot'")
        display  _skip(`skip') "`ntot'" 
  }
  else if "`by'"=="" {
        display " Total [#]" _col(`s3') "|" _continue 
        local skip=1+`width1'-length("`ntot'")
        display  _skip(`skip') "`ntot'"  _cont
        if "`perc'"=="perc" {   display  "    100%" }
        else {display " " }
  }
  display " "
}
parse "`varlist'" ,parse(" ")
while "`1'"~="" {
 quietly {
  eformat `1' ,val lab
  capture drop `NN'
  capture drop `NNN'
  capture drop `_vlab'
  capture drop `rownr'
  capture drop `NR'
  sort `1' 
  quietly by `1' : gen int `NNN'=1 if _n==1
  gen int `NR' =`NNN'
  gen int `rownr'=sum(`NNN')
  local nrow=`rownr'[_N]  /* inclusive any missing value category ! */
  global varlab : variable label `1'
  if "$varlab"=="" { global varlab "`1'"}
  if `nrow'<=`max' {
   local type : type `1'
   local form : format `1'
   local vallab : value label `1'
   local type1 : type `1'
   if index("`type'","str")~=0  {
        local form 
        gen `type1' `_vlab'=`1' 
        compress `_vlab'
        local type : type `_vlab'
   }
   else {
      if "`vallab'"~="" {
        capture label list `vallab'
        if _rc>0 {      /* value label not defined */
                local vallab 
        }
      }
      if "`vallab'"~="" {           /* variable with existing value label */
        decode `1' ,gen(`_vlab') 
        replace `_vlab'=string(`1') if `_vlab'==""
        replace `_vlab'="." if `_vlab'==""
        local form 
        local type : type `_vlab'
      }
      else  {
        gen `type' `_vlab' = `1'    /* all other variables */
      }
   }
  *Statistic for overall total
   if index("`type1'","str")==0|"`mis'"~="" { tab `1',`mis'}
   else  { tab `1' if "`1'"~=""}
   local ntot=_result(1)
   local nval=_result(2)
 
  *Statistics for row-total 
   egen `NN'=count(1),by(`1')
   sort `1' 
 
   local plus1
   if "`mis'"==""&index("`type1'","str")>0 {
    tempvar len1
    gen byte `len1'=length(`1')
    quietly su `len1'
    if _result(5)==0 { local plus1 +1}
   } /* plus1 will be used later to ignore-not display missing categories */
 
   capture drop `NNN'
   quietly by `1' : gen int `NNN'=1 if _n==1
   sort `NNN' `rownr'
   local i=1  
   while `i'<=`nrow' {
        if index("`type'","str")~=0  {
          /* Take care of possible double quotes in vlab`i'!! */
                local vlab`i' `_vlab'[`i'] 
        }
        else {
                local vlab`i'= `_vlab'[`i']
        }
        local val`i'=`1'[`i']
        if "`perc'"~="col" {
                local n`i'=`NN'[`i']}
        else {
                local b=100*`NN'[`i']/`ntot'
                fns a `b' ,w(`wtot') d(`dec')
                local n`i' $a }
        local i=`i'+1 }
   drop  `NN' `NNN' 
 
  *Statistics for column totals
   if ("`perc'"=="col"|("`total'"~=""&"`mis'"=="")|"`test'"=="Chi2")&"`by'"~="" {
    if "`mis'"~="" { 
     egen `NN'=count(1),`byby'
    }
    else if index("`type1'","str")==0  {
     egen `NN'=count(1) if `1'~=. ,`byby'
    }
    else   { /* empty strings of rowvar to be considered as missing and not counted ! */
     egen `NN'=sum(`len1'>0) ,`byby'
    }
    sort `by' `1' 
    quietly by `by' : gen int `NNN'=1 if _n==1
    sort `NNN' `colnr'
    local j=1 
    while `j'<=`nby' {
        if "`perc'"=="row" {
           local b=100*`NN'[`j']/`ntot'
           fns a `b' ,w(`width`j'') d(`dec')
           local n_`j'  $a 
        }
        else { local n_`j'=max(0,`NN'[`j']) }
        local j=`j'+1 
    }
    if "`test'"=="Chi2"&"`by'"!="" { 
      gen int `CTOT' =`NN' 
      if index("`bytype'","str")>0 { replace `CTOT'=. if `by'=="" }  /* added 8/10/01 */
      else                         { replace `CTOT'=. if `by'==.  }  /* to exclude missing obs for chi2 p_value*/
      if index("`type1'","str")>0  { replace `CTOT'=. if `1'==""  }
      else                         { replace `CTOT'=. if `1'==.   }
      
    } /* column totals needed in case of chi2 test; but restricted to non-missing obs  */
    drop `NN' `NNN' 
   }
 
  *Statistics for cells
   if "`by'"~="" {
    egen `NN'=count(1),by(`1' `by' )
    local pval
    if "`test'"=="Chi2" {
      egen `RTOT'=count(1) if `CTOT'!=.&`CTOT'!=0 ,by(`1') 
      qui tab `1' `by', chi 
      local rr=r(r)
      local rc=r(c)
      local rn=r(N)
      local rp=r(p)
      qui count if `CTOT'*`RTOT'>0&`CTOT'*`RTOT'!=.&(`CTOT'<3*`rr'|`RTOT'<3*`rc')
      if `rr'>=2&`rc'>=2&4*`rr'*`rc'<=`rn'&r(N)==0 {local pval =`rp'}
       /*changed  30/5/2001 
      A p-value for chi2 test will NOT be calculated if the mean number of counts per cell is
      less than 4 or if if the mean number of counts per cell per column (row) is less than 
      3 derived form column (row) total and number of rows (columns) */
      drop `CTOT' `RTOT'
    } 
    else if "`test'"=="Spearman" {
        cap qui spearman `1' `by'  /* 25/11/02 capture added for cases where Spearman cannot be calculated
                                               also below */
        local pval =r(p)
    }
    else if "`test'"=="K-W" {
        cap qui kwallis `1' ,by(`by')
        local chi2=r(chi2_adj)            /* 17/12/02 adapted WvP */
        if `chi2'==. { local chi2=r(chi2)}
        local pval=chi2tail(r(df),`chi2')
    }
    else if "`test'"=="trendtest" {
        cap qui nptrend `1' ,by(`by')
        local pval =r(p)
    }
    else if "`test'"=="exact" {
        cap qui tab `1' `by' , exact
        local pval = r(p_exact)
    }
    sort `1' `by'
    quietly by `1' `by' : gen int `NNN'=1 if _n==1
    sort `NNN' `rownr' `colnr'
    local i=1 
    local k=1
    while `i'<=`nrow' {
     local j=1
     while `j'<=`nby' {
        local r=`rownr'[`k']
        local c=`colnr'[`k']
        if `r'==`i' & `c'==`j' {
         if "`perc'"=="col" {
           local b=100*`NN'[`k']/`n_`j''
           fns a `b' ,w(`width`j'') d(`dec')
           local n`i'_`j'  $a 
           if "`zero'"!=""&`b'==0 { local n`i'_`j' . }
         }
         else if "`perc'"=="row" {
           local b=100*`NN'[`k']/`n`i''
           fns a `b' ,w(`width`j'') d(`dec')
           local n`i'_`j'  $a 
           if "`zero'"!=""&`b'==0 { local n`i'_`j' . }
         }
         else { 
           local n`i'_`j'=`NN'[`k']     
           if "`zero'"!=""&`NN'[`k']==0 { local n`i'_`j' . }
         }
         local j=`j'+1 
         local k=`k'+1 
        }
        else {
         local n`i'_`j'=0
         if "`zero'"!="" { local n`i'_`j' . }
         local j=`j'+1 
        }
     }
     local i=`i'+1
    }
    drop `NN' `NNN'
   } /* if by */
  }
 } /* end quietly */
 if "`pval'"!=""&`nrow'<=`max' {
   display "$varlab" _col(`Ppos') "(P=" %5.3f `pval' ", `test')"
  }
 else { display "$varlab" }
 if `nrow'>`max' {
         display " Too many (`nrow'>`max') different values"
 }
 else {
  sort `NR' `1'
  local i=1 `plus1'
  while `i'<=`nval'`plus1' {
        display _col(3) `form' `_vlab'[`i'] _col(`s2')   _continu
        if "`by'"~="" {
          display     "|"          _continu
          local j=1 
          while `j'<=`nby' {
                local skip=`width`j''-length("`n`i'_`j''")
                display _skip(`skip') "`n`i'_`j'' " _contin
                local j= `j'+1 
          }
          if `nby'>1&("`bytot'"==""|"`perc'"=="row") {
            display "|" _cont  
            local skip=`wtot'-length("`n`i''")
            display  _skip(`skip') "`n`i''" 
          }
          else {  display " " }
        }
        else {
          display  _skip(1) "|" _cont  
          local skip=1+`width1'-length("`n`i''")
          display  _skip(`skip') "`n`i''" _con
          if "`perc'"=="perc" {
                local b=100*`n`i''/`ntot'
                fns a `b' ,w(`wtot') d(`dec')
                local skip=max(1,7-length("$a"))
                display  _skip(`skip') "$a" "%"
          }
          else {display " "}
        }
        local i= `i'+1 
  }
  if "`total'"~=""&"`mis'"=="" {
        if "`perc'"=="col" {
                display _col(2) "Total [#]" _col(`s2')   _continu }
        else  {
                display _col(2) "Total " _col(`s2')   _continu }
        if "`by'"~="" {
          display     "|"          _continu
          local j=1 
          while `j'<=`nby' {
                local skip=`width`j''-length("`n_`j''")
                display _skip(`skip') "`n_`j'' " _contin
                local j= `j'+1 
          }
          if `nby'>1&("`bytot'"==""|"`perc'"=="row") {
                display "|" _cont  
                local skip=`wtot'-length("`ntot'")
                display  _skip(`skip') "`ntot'" 
          }  
          else {  display " " }
        }
        else {
          display  _skip(1) "|" _cont  
          local skip=1+`width1'-length("`ntot'")
          display  _skip(`skip') "`ntot'"  _cont
          if "`perc'"=="perc" { display  "    100%" }
          else {display "" }
        }
  }
 }
 display " "
 macro shift 
} /* end while loop over varlist */
end

