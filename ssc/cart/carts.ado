*!carts.ado
*!CART analysis performs the searching and splitting 
/*
Syntax
  carts varlist , fail() time() pval() minsize() minfail() pnominal strata() adjust()
  
  Option adjust() in fact not (yet) used! But available for option to recalculate _h_ by refitting
  the Cox model within each CART group - if adjustment is needed.

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
  save `temp1',replace
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
    use `temp1',clear
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

    su `exp' if `x'<=`value'*1.000000001
    local e=_result(1)*_result(3)
    count if `x'<=`value'*1.0000001&`fail'==1
    local f=_result(1)
    count if  `x'<=`value'*1.00000001
    local nn=_result(1)
*    nois displ "x1 $x1 , nn `nn', N " _N
*    pause
    capture drop `totf'
    count if `fail'==1
    local totf=r(N)
    local hr=`f'*(`totf'-`e')/(`e'*(`totf'-`f'))

    su `x' if `x'<=`value'*1.00000001
    local minval=_result(5)
    su `x' if `x'>`value'*1.0000001
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
      replace _CART=$CARTn if `x'>`value'*1.00000001 
      replace _Corder=_Corder+.5^$CARTl if `x'>`value'*1.00000001 
      replace _Corder=_Corder-.5^$CARTl if `x'<=`value'*1.00000001 
      post $post ($CARTi) ($CARTl) ($CARTi) (`order'-.5^$CARTl) (`var') (`value') (`minval')  (`value')  (`dec') (`cc') (`ppnom') (`ppadj') (`nn') (`f') (`e')  (${RHR$CARTi}) (`hr')
      post $post ($CARTn) ($CARTl) ($CARTi) (`order'+.5^$CARTl) (`var') (`value') (`minval2') (`maxval') (`dec') (`cc') (`ppnom') (`ppadj') (_N-`nn') (`totf'-`f') (`totf'-`e') (${RHR$CARTn}) (1/`hr')
    }
    else      { 
      global RHR$CARTn= ${RHR$CARTi}*`f'/`e'
      global RHR$CARTi= ${RHR$CARTi}*(`totf'-`f')/(`totf'-`e')
      replace _CART=$CARTn if `x'<=`value'*1.00000001
      replace _Corder=_Corder-.5^$CARTl if `x'>`value'*1.00000001 
      replace _Corder=_Corder+.5^$CARTl if `x'<=`value'*1.00000001 
      post $post ($CARTi) ($CARTl) ($CARTi) (`order'-.5^$CARTl) (`var') (`value') (`minval2') (`maxval') (`dec') (`cc') (`ppnom') (`ppadj') (_N-`nn') (`totf'-`f') (`totf'-`e') (${RHR$CARTi}) (1/`hr')
      post $post ($CARTn) ($CARTl) ($CARTi) (`order'+.5^$CARTl) (`var') (`value') (`minval')  (`value')  (`dec') (`cc') (`ppnom') (`ppadj') (`nn') (`f') (`e') (${RHR$CARTn}) (`hr')
    } 
    save `temp2',replace
    use `temp1',clear

    replace _CART=0  if  _CART==$CARTi
    append using `temp2'
    drop if  _CART==0 
    save $name,replace
  }
  else { /* no split of this group */
    global CARTi=$CARTi +1
    global CARTl ${L$CARTi}
    use `temp1',clear
    save $name,replace
  }
}
end


