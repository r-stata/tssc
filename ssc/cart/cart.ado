*!cart.ado WvP ,  20/5/2002
*!first version 6/4/98
*!id() option added to save identifier in _CART.dta
program define cart
version 7.0
local varlist "req ex min(1) "
local if "opt"
local in "opt"
#delimit ;
local options "Pval(real 0.05) PNOMinal MINSize(int 10) MINFail(int 10) Time(string) 
               Fail(string)  NAme(string) SUmby(string) TABby(string)
         Strata(string) Adjust(string) AT(string) ID(string) ";
#delimit cr
local cmd cart `*'
parse "`*'"
quietly {
  preserve
  if "`if'`in'"~="" { keep `if'`in' }
  local if
  local in
  if "`name'"=="" {
    local name  _cart 
    local save  _cart 
    local post _cartx 
  }
  else {
    local save `name' 
    local post `name'x 
  }  
  global name `name'
  if "`fail'"=="" {
     noisily display "fail(var) must be specified!"
     restore
     exit 
  }
  unabbrev "`fail'"
  local fail "$S_1"
  drop if `fail'==.
  replace `fail'=`fail'>0.001    /* explicit definition of failures */
  local ffail "f(`fail')"

  if "`time'"=="" {
     noisily display "time(var) must be specified!"
     restore
     exit 
  }
  unabbrev "`time'"
  local time "$S_1"
  drop if `time'==.|`time'<0
  replace `time'=max(.001,`time')   /* no zero times */
  local ttime "t(`time')"
  ttitle `time'
  local title1 $S_1 
  keep `id' `adjust' `strata' `time' `fail' `varlist' `sumby' `tabby'
  *drop records with missing values
  parse "`varlist'",parse(" ")
  local vars `varlist'
  local labdef label define varnr
  local i=1
  while "`1'"~="" {
    drop if `1'==.    /* listwise deletion */
    global VAR`i' `1'  
    local varlab:  var label `1'
    if "`varlab'"=="" {local varlab `1' }
    local labdef  "`labdef' `i'"`varlab'""
    local vlab`i' : value label `1'
    local vlab `vlab' `vlab`i''
    local i=`i'+1
    macro shift
  }
  if "`vlab'"~="" { label save `vlab' using vlab ,replace }
  if "`strata'"~="" {
    unabbrev `strata'
    local strata $S_1
    parse "`strata'",parse(" ")
    while "`1'"~="" {
      drop if `1'==.
      macro shift
    }
    local titstr `strata'
    local strata strata(`strata')
  }        
  if "`adjust'"~="" {
    unabbrev `adjust'
    local adjust $S_1
    parse "`adjust'",parse(" ")
    while "`1'"~="" {
      drop if `1'==.
      macro shift
    }
    local titadj `adjust'
    local adjust adjust(`adjust')
  }        

  /* Two new variables will be generated with fixed name:
     _h_     will contain the exp(b'x) for each subject for adjusted (stratified) Cox model. 
             If no adjustment is done b=0 and _h_=1.
     _tmin_  used for reverse order of time. required for the calculation of the expected
                           number of events per subject within a CART group 
  */
  gen _tmin_=-`time'      
  if "`adjust'"!="" {
    stset `time' `fail' 
* nois di "`titadj'"
* pause
    qui  stcox `titadj' ,`strata'
    predict _h_ , hr
  }
  else {    gen byte _h_=1   }
  global NVAR =`i'-1
  global post `post'
  global RHR1=1
  postfile $post group level from order varnr value minval maxval dec chi2 pnom padj n f e rhr hr  using `post',replace    
  local minsize =max(1,`minsize')
  local minfail =max(1,`minfail')
  gen byte _CART=1
  label var _CART "CART group number"
  gen  _Corder=10
  label var _Corder "CART order of group"

  tempvar nf atr n1  dx
  global CARTi 1      /* index for current CART group */
  global CARTn 1      /* current number of CART groups */
  global CARTl 0      /* to be used as level of split */
  global RHR1=1
  while $CARTi<=$CARTn {   
    nois display "CARTi=$CARTi  , CARTn=$CARTn "
    pause
    noisily carts `vars' , `ffail' `ttime' pval(`pval') `pnominal' minsize(`minsize') minfail(`minfail') `strata' `adjust'
    pause
  }
  save `save',replace
  postclose $post

  if $CARTn>1 {
    uc $post
    sort order
    count if order<=10
    local node1= _result(1)+1
    char _dta[node1]  `node1'   /* stores location of first split node */
    char _dta[cmd]    `cmd'     /* stores command and characteristics */
    char _dta[time]   `title1'
    char _dta[vars]   `vars'
    char _dta[strata] `titstr'
    char _dta[adjust] `titadj'

    replace order=_n + (order>10)
    sort group level
    quietly by group:gen byte last=(_n==_N)  /* end groups if last==1 */
    format chi2 hr rhr %6.2f
    label var group "Group"
    label var level "Level of split"
    label var order "Order branch/node"
    label var last  "End group indicator"
    label var from  "Split from group:"
    `labdef'   
    change varnr . varnr  Split on variable
    label var value "Split cutpoint "
    label var minval "Minimum of range after split"
    label var maxval "Maximum of range after split"
    label var dec    "Number of decimals for value"
    label var chi2   "Chisquare value"
    label var pnom   "Nominal P-value"
    label var padj   "Adjusted P-value min Miller & Siegmund, Worsley"
    label var n "Total Number in group"
    label var f "Number of failures"
    label var e  "Expected # failures | upper level" 
    label var rhr "Relative hazard rate [overall]" 
    label var hr "Hazard Ratio | upper level"
    change minval min
    change maxval max
    change value val
 
    gen str20 mima =""  /* gen string variable that contains description of the split*/
    if "`vlab'"~="" { do vlab }
    local i=1
    while `i'<=_N {
      local j=varnr[`i']
      local min=min[`i'] 
      local max=max[`i'] 
      local dec= dec[`i']
      if "`vlab`j''"~="" {
        local mi:label `vlab`j'' `min'  
        if `max'>`min' {local ma:label `vlab`j'' `max' }
      }
      else {
        fns mi `min' ,dec(`dec') 
        local mi $mi    
        if `max'>`min' {
          fns ma  `max',dec(`dec') 
          local ma $ma    
        }
      } 
      if `max' >`min' { replace mima="`mi'-`ma'" in `i' }
      else { replace mima="`mi'" in `i' }
      local i=`i'+1
    } 
    format rhr hr %4.2f
    format e  %4.1f
    eformat _all,vn val lab
    save,replace
*    relog  `name' ,240
    sort level group
    nois dis _n "CART history:"
    nois  qlist group level from order varnr val mima dec chi2 pnom padj n f e hr rhr  last,noo nodis
    nois dis _n "CART end groups:"
    nois  qlist group level from order varnr val mima dec chi2 pnom padj n f e hr rhr  if last==1,noo nodis

    uc `save'
*    keep `vars' `time' `fail' _EXP _CART  
*    save,replace
    nois dis _n "Ranges of variables:" _n
    if $CARTn <=15 {  
      nois sumby `vars' ,by(_CART) hea wi(2)  st(n min max) 
    }
    else {
      nois sumby `vars'  if _CART<=17 ,by(_CART) hea wi(2)   st(n min max) nobytot
      if $CARTn> 17 {
        nois sumby `vars'  if _CART>17&_CART<=34 ,by(_CART) hea wi(2)   st(n min max) nobytot
      }
      if $CARTn> 34 {
        nois sumby `vars'  if _CART>34 ,by(_CART) hea wi(2)   st(n min max) nobytot
      }
    }
    nois dis _n 
    if "`at'"!="" {
      capture nois sby _CART ,time(`time') dead(`fail')   st(nr f med se at) at(`at') hea
    }

    if "`sumby'"~="" {
      nois dis _n "Summary of some variables:" _n
      if $CARTn <=15 { nois sumby `sumby'  ,by(_CART) hea wi(2) }
      else {
        nois sumby `sumby' if _CART<=17  ,by(_CART) hea wi(2) nobytot 
        if $CARTn> 17 {
          nois sumby `sumby' if _CART>17&_CART<=34 ,by(_CART) hea wi(2) nobytot
        }
        if $CARTn> 34 {
          nois sumby `sumby' if _CART>34 ,by(_CART) hea wi(2)   nobytot
        }
      }
    }

    if "`tabby'"~="" {
      nois dis _n "Tabulation of some variables:" _n
      if $CARTn <=15 { nois tabby `tabby'  ,by(_CART) hea wi(2) nozero }
      else {
        nois tabby `tabby' if _CART<=17  ,by(_CART) hea wi(2) nobytot  nozero
        if $CARTn> 17 {
          nois tabby `tabby' if _CART>17&_CART<=34 ,by(_CART) hea wi(2) nozero nobytot
        }
        if $CARTn> 34 {
          nois tabby `tabby' if _CART>34 ,by(_CART) hea wi(2)   nobytot  nozero
        }
      }
    }
*    cllog
    tree file($post) save(`name',replace) pval(`pval') `pnominal'
  }
  else {noisily display "No split possible"}
}   

end

*!carts.ado Subroutine called by CART
*!CART analysis performs the searching within a group for optimal cutpoint and best covariate 
/*
Syntax
  carts varlist , fail() time() pval() minsize() minfail() pnominal strata() adjust()
  
  Option adjust() for adjustment for other covariates is in fact not (yet) used! 
  It is available for option to recalculate _h_ by refitting
  the Cox model within each CART group - if such an adjustment is needed.
*/
program define carts
version 7.0
local varlist "req ex min(1) "
local options "Pval(real 0.05) PNOMinal MINSize(int 10) MINFail(int 10)  Time(string) Fail(string) STRata(string) ADJust(string) "
parse "`*'"
quietly {
  tempfile temp1 temp2 
  tempvar nf atr cum  sf se soe c tij n1 n2 totf
  * all calculations restricted to current group: _CART= $CARTi
  save "`temp1'",replace
  keep if _CART==$CARTi
  nois dis "Group $CARTi,Level $CARTl ,Number " _N

  if "`strata'"!="" {
    local qbystrata qby `strata' :
    local bystrata by(`strata')
  }     

  egen `totf'=sum(`fail') , `bystrata'
  
  if _N<2*`minsize'|`totf'<`minfail' {
    global CARTi=$CARTi +1
    global CARTl ${L$CARTi}
    use "`temp1'",clear
    exit
  }

/* May 20, 2002 I come to the conclusion that the approach followed below is too simplistic: 
   to determine the expected values by multiplication by a factor. 
   Another and better way has been implemented.
  *Adapt the _EXP values such that they sum to `totf'
  su _EXP
  local factor=`totf'/(_result(1)*_result(3))
  gen `cum'=_EXP*`factor' 
*/
  tempvar H H1 exp 
  sort `strata' _tmin_
  `qbystrata' gen `H'=sum(_h_)
  qby `strata' _tmin_:replace `H'=`H'[_N]
  sort `strata' `time'
  `qbystrata' gen `H1'=sum(`fail'/`H')
  qby `strata' `time' :replace `H1'=`H1'[_N]
  gen `exp'= _h_*`H1'  /* expected number of failures within this CART group for this subject */
  
  local cc=0
  local pp=1
  local i=1
  while   `i'<=$NVAR {
    local x ${VAR`i'}
    sort `x' `time' `fail'  
    count if `x'>`x'[`minsize']
    if _result(1)>=`minsize' {  /*else not splittable on var i */
      
      if "`strata'"=="" {
        gen `sf'=sum(`fail')   
        gen `se'=sum(`exp') 
        quietly by `x':replace `sf'=. if _n<_N  
        quietly by `x':replace `se'=. if _n<_N  
        gen `soe'=`sf'-`se'
        gen `c'=(`soe'^2)/(`se'*(`totf'-`se')/`totf') if `totf'>0 &`se'>0& `totf'-`se'>0
        drop `sf' `se' `soe'   
      }  
      else {
        sort `strata' `x' `time' `fail'
        `qbystrata' gen `se'=sum(`exp') 
        quietly by `strata' `x':replace `se'=`se'[_N]  
        *first we calculate the variances within strata and the differences for successive cutpoints
        tempvar Var dVar
        gen `Var'=(`se'*(`totf'-`se')/`totf')             if `totf'>0 &`se'>0& `totf'-`se'>0
        replace `Var'=0 if `Var'==.
        `qbystrata' gen  `dVar'=`Var'-max(0,`Var'[_n-1])   /* we need the differences! */
        sort `x' `time'  `strata' `fail'
        gen `soe'=sum(`fail' - `exp')
        qby `x': replace `soe'=. if _n<_N
        replace `Var'=sum(`dVar')                    /* now we have the variance for a cutpoint */
        gen   `c'=(`soe'^2)/`Var'     if `Var'>0       /* now turned into Chi2 value */        
        drop  `se' `soe' `Var' `dVar'  
      }  
      
      su `c' if `x'>=`x'[`minsize']&`x'<`x'[_N-`minsize']  
      local ncutp=r(N)
      local max=_result(6) 
      local pnom=chiprob(1,`max')  /* unadjusted P-value */
      
* nois display "Max chi square= `max', P nominal= `pnom'"     
* nois display "pnominal `pnominal'"     
*pause on  
*nois su `sf' `se' `soe' `c'
*pause 
*pause off      
      /* now we have to adjust for the multiple testing. The adjustment is optional via the otion
         "pnominal". The adjustment will be done in the same way as in SRD.ADO. 
         Adjustment will not be done if the nominal P-value is already larger than required `pval'
         or larger than the smaller p-value on another factor. It will only be done if there is 
         really multiple testing, i.e. at least 2 potential cutpoints
         
         Note, that even with the option pnominal we calculate the adjusted P-value. Only it will not be
         used for the decisions.
      */
      if `pnom'<min(`pp',`pval')  {
        if `ncutp'>1 {
          *  adjustment Formula Altman Miller&Siegmund
          * Calculate fractions eps1 and eps2 for Miller&Siegmund correction
          count if `x'<=`x'[`minsize']
          local eps1=r(N)/_N
          count if `x'>=`x'[_N-`minsize']
          local eps2=r(N)/_N
          local pcor1=normd(`max'^.5)*(4+(`max'-1)*log((1-`eps1')*(1-`eps2')/(`eps1'*`eps2')))/`max'^.5

          *   adjustment improved Bonferroni (Worsley)
          local totn=_N
          qby `x': gen int `n1'=_N if _n==1
          gen int `n2'=sum(`n1') 
          qby `x': replace `n2'=`n2'[_N] 
          replace `n2'=. if `n2'<`minsize'|`n2'>_N-`minsize'
          su `n2'
          replace `n2'=. if `n2'>=r(max)-.0001
          gen `tij'= (`totn'*`n1'[_n+1]/(`n2'[_n+1]*(`totn'-`n2')))^0.5
          replace `tij'= (`tij'-(`max'/4-1)*`tij'^3/6) if `tij'!=.
          replace `tij'=sum(`tij')
          local pcor2=chiprob(1,`max')+(1/_pi)*exp(-`max'/2)*`tij'[_N] 
          ** The result is sometimes negative! This implies an error somewhere. 
          ** For the time being pcor2 will be ignored if pcor2<pnom 
          if `pcor2'<`pnom' {local pcor2 . }
          local pcor=min(`pcor1',`pcor2')   
          drop `n1' `n2' `tij'
        }
        else { local pcor `pnom' }         
* nois displ "pcor `pcor', pp `pp', pval `pval', `pnominal'"        
        if (`pcor'<`pp'&`pcor'<`pval') | "`pnominal'"!="" {
          su `x' if abs(`c'-`max')<.000001
          local value =_result(5)  /* if more cutpoints with the same max Chi square value the smallest is chosen */
          if `value'<0 {local minval0=0.99999999*`value' }
          else {local minval0=1.00000001*`value'}
          local var    `i'
          local varnam `x'
          if `ncutp'>1 {local ppadj `pcor'}
          else         {local ppadj .     }
          local cc `max'    
          local ppnom `pnom'
          local pp =min(`pnom',`ppadj') 
          if "`pnominal'"!="" { local pp `pnom' }
        }
      }  
      drop `c'  
    }
    local i=`i'+1
  }

  if `pp'<`pval' {
    global CARTn   =$CARTn +1
    global CARTl   =$CARTl +1
    global L$CARTn = $CARTl
    local x `varnam'

    su `exp' if `x'<=`minval0'
    local e=_result(1)*_result(3)
    count if `x'<=`minval0' &`fail'==1
    local f=_result(1)
    count if  `x'<=`minval0'
    local nn=_result(1)
*    nois displ "x1 $x1 , nn `nn', N " _N
*    pause
    capture drop `totf'
    count if `fail'==1
    local totf=r(N)
    local hr=`f'*(`totf'-`e')/(`e'*(`totf'-`f'))

    su `x' if `x'<=`minval0'
    local minval=_result(5)
    su `x' if `x'>`minval0'
    local minval2=_result(5)
    local maxval=_result(6)
    local format:format `x' 
    local type: type `x'
    if "`type'"!="float" &"`type'"!="double"  {
      local minval=int(`minval')
      local minval2=int(`minval2')
      local maxval=int(`maxval')
    }  
    local dec =substr("`format'",index("`format'",".")+1,1)
    local order=_Corder[1]

    if `hr'<1 { 
      global RHR$CARTn= ${RHR$CARTi}*(`totf'-`f')/(`totf'-`e')
      global RHR$CARTi= ${RHR$CARTi}*`f'/`e'
      replace _CART=$CARTn if `x'>`minval0' 
      replace _Corder=_Corder+.5^$CARTl if `x'>`minval0' 
      replace _Corder=_Corder-.5^$CARTl if `x'<=`minval0' 
      post $post ($CARTi) ($CARTl) ($CARTi) (`order'-.5^$CARTl) (`var') (`value') (`minval')  (`value')  (`dec') (`cc') (`ppnom') (`ppadj') (`nn') (`f') (`e')  (${RHR$CARTi}) (`hr')
      post $post ($CARTn) ($CARTl) ($CARTi) (`order'+.5^$CARTl) (`var') (`value') (`minval2') (`maxval') (`dec') (`cc') (`ppnom') (`ppadj') (_N-`nn') (`totf'-`f') (`totf'-`e') (${RHR$CARTn}) (1/`hr')
    }
    else      { 
      global RHR$CARTn= ${RHR$CARTi}*`f'/`e'
      global RHR$CARTi= ${RHR$CARTi}*(`totf'-`f')/(`totf'-`e')
      replace _CART=$CARTn if `x'<=`minval0'
      replace _Corder=_Corder-.5^$CARTl if `x'>`minval0' 
      replace _Corder=_Corder+.5^$CARTl if `x'<=`minval0' 
      post $post ($CARTi) ($CARTl) ($CARTi) (`order'-.5^$CARTl) (`var') (`value') (`minval2') (`maxval') (`dec') (`cc') (`ppnom') (`ppadj') (_N-`nn') (`totf'-`f') (`totf'-`e') (${RHR$CARTi}) (1/`hr')
      post $post ($CARTn) ($CARTl) ($CARTi) (`order'+.5^$CARTl) (`var') (`value') (`minval')  (`value')  (`dec') (`cc') (`ppnom') (`ppadj') (`nn') (`f') (`e') (${RHR$CARTn}) (`hr')
    } 
    save "`temp2'",replace
    use "`temp1'",clear

    replace _CART=0  if  _CART==$CARTi
    append using "`temp2'"
    drop if  _CART==0 
    save $name,replace
  }
  else { /* no split of this group */
    global CARTi=$CARTi +1
    global CARTl ${L$CARTi}
    use "`temp1'",clear
    save $name,replace
  }
}
end



*!tree.ado   Subroutine for CART. 
*!10/4/98 -> 5/8/98
/* 
Generates the tree and necessary variables starting with the data in the CART history file.

Syntax :
  tree file(filename of posted CART history file) save(string) pnominal

filename is the name of the CART history file

A tree consists of split-nodes and branches.

The split-nodes are also numberd in order of generation starting with 1 as
	top-node, i.e. the first split. Per node there are in general
	two branches. However, we will try to take into account future gene-
	ralisations with more than two branches per node. For example at the 
	start of the tree, if one forces a split in three categories on a
	specified variable.
	A node with n>2 branches is thought of as cocnsiting of n-1 subnodes
	at the same level. 
	
*/
                           
program define tree
capture preserve
local options "File(string) Save(string) PNOMinal Pval(real 0.05) "
parse ",`*'"
uc `file'

quietly {
 *Create help variables for location and position of nodes and branches */

 capture confirm new var next
 if _rc==0 {  /* otherwise all help variables are already defined */
  sort group level
  by group:gen next=varnr[_n+1]  /* Var nr of next split variable, if not end-node */
 } 

 if "`pnominal'"!="" { local t1note Split if nominal P<`pval' }
 else                { local t1note Split if (adjusted) P<`pval' }

 su level
 local nlev=_result(6)  
 local nbr =_N+1
 cvar mima
 local lmima:char mima[width]
 local dy=int(20000/`nbr')

 local fh1=int(min(`dy'/2,700))  /* font group descriptor text */
* local fh1=int(min(max(`dy'/2,400),700))  /* font group descriptor text */
 local fw1=int(`fh1'/2)
 local fh2=int(1.1*`fh1')   /* font split variable text (standard font) */
 local fw2=int(1.1*`fw1')

* local fh2=int(max(1.1*`fh1',300))   /* font split variable text (standard font) */
* local fw2=int(`fh2'/2) 
 local fh1x=int(`fh2'/1.1)
 local fw1x=int(`fh1x'/2) 
 
 local dx=int(max(10,`lmima')*1.7*`fw1')
 if (`nlev'+.2)*`dx'+14*1.7*`fw2' >30000 {
	local f=30000/((`nlev'+.2)*`dx'+14*1.7*`fw2')
*	local f=90000/((`nlev'+.2)*`dx'+14*1.7*`fw2')
	local fh1=int(`fh1'*`f')
	local fw1=int(`fw1'*`f')
	local dx=int(`dx'*`f')
 }
 local font1 `fh1' `fw1'
* local font1 `fh1x' `fw1x'
 local font2 `fh2' `fw2'
 local ax=500
 local ay=2000

 local nc1=`ax'+`dx'*(`nlev'+.2)+3*1.6*`fw2'
 local nc2=`ax'+`dx'*(`nlev'+.2)+7*1.6*`fw2'
 local nc3=`ax'+`dx'*(`nlev'+.2)+12*1.6*`fw2'
 local rtop=`ay'+`dy'-2*`fh2'
 local node1 :char _dta[node1]
 local r1=`ay'+`node1'*`dy'
 local c1=`ax'
 sort group level
 local varn=varnr[1]
 local text1:label varnr `varn' 
 
*All elements for a tree are available. Let us make one.
/*
nois display "r1 `r1'"
nois display "c1 `c1'"
nois display "nc1 `nc1'"
nois display "nc2 `nc2'"
nois display "nc3 `nc3'"
nois display "dx `dx'"
nois display "dy `dy'"
nois display "ax `ax'"
nois display "ay `ay'"
nois display "font1 `font1'"
nois display "font2 `font2'"
nois display "text1 `text1'"
pause
*/
  gph open  ,saving(`save')
  gph pen 1
  gph font `font2' 
  gph text `rtop' `nc1'  0 1 N
  gph text `rtop' `nc2'  0 1 F
  gph text `rtop' `nc3'  0 1 RHR
  
  gph point  `r1' `c1' `fw1' 1
  local c1=`c1'+30
  gph pen 2
  gph font `font2' 
  gph text `r1' `c1'  0 -1 `text1'

  sort from level order
  gph pen 1
  local i=1 
  while `i'<=_N {
    if from[`i']==from[`i'-1]&level[`i']==level[`i'-1] {
	local x=`ax'+`dx'*(level[`i']-1)
	local y1=`ay'+`dy'*(order[`i'-1])
	local y2=`ay'+`dy'*(order[`i'])
	gph line `y1' `x' `y2' `x'
    }
    local i=`i'+1
  }

  sort order
  local i=1 
  while `i'<=_N {
   	local last=last[`i']
	local next=next[`i']
	local text1=mima[`i']
	
	local x1=`ax'+`dx'*(level[`i']-1)
	local x2=`ax'+`dx'*(level[`i'])
	local x3=`x2'+30
	local y1 =`ay'+`dy'*order[`i']
	local y2=`y1'-130
        gph pen 1
	gph line `y1' `x1' `y1' `x2'
	gph pen 1
	gph font `font1' 
	gph text `y2' `x1'  0 -1 `text1'
	if "`next'"~="." {
		local text2:label varnr `next' 
		gph point `y1' `x2' `fw1' 1 
		gph pen 2
		gph font `font2'
		gph text `y1' `x3'  0 -1 `text2'
	}
	else {  
		gph point `y1' `x2' `fw1' 2 
		local no=n[`i']
		local nf=f[`i']
		local rhr=rhr[`i']
		fns rhr `rhr' ,dec(2)
		gph font `font2' 
		gph text `y1' `nc1'  0 1 `no'
		gph text `y1' `nc2'  0 1 `nf'
		gph text `y1' `nc3'  0 1 $rhr
	}
	local i=`i'+1
  }
  local t1 :char _dta[time]
  local t2 :char _dta[vars] 
  local t3 :char _dta[adjust] 
  local t4 :char _dta[strata] 
  local nx=("`t3'"~="")+("`t4'"~="")
  local yt=1.2*(`fh2'+(1+`nx')*`fh1')
  local f=min(1,`ay'/`yt')
  local y1=1.2*`f'*`fh2'
  local y2=`y1'+1.2*`fh1'
  local y3=`y2'+1.2*`fh1'
  local y4=`y3'+1.2*`fh1'*(`nx'==2)
  local fh1=`f'*`fh1'
  local fw1=`f'*`fw1'
  local fh2=`f'*`fh2'
  local fw2=`f'*`fw2'
  gph pen 2
  gph font `fh2' `fw2'
  gph text `y1' `ax' 0 -1 CART analysis `t1' - `t1note'
  gph pen 1
  gph font `fh1' `fw1'
  gph text `y2' `ax' 0 -1 With variables: `t2'
  if  "`t3'"~="" {  gph text `y3' `ax' 0 -1 Adjusted for: `t3'}
  if  "`t4'"~="" {  gph text `y4' `ax' 0 -1 Stratified by: `t4'}
  gph close


end













