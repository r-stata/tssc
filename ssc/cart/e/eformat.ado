*! eformat.ado  WvP ,                                                            04/02/2002
*! first version:28/10/96
*! gedeeltelijk afgeleid uit FORMLAB.ADO  BvdH, 030696, 14:50
* 14/10/98:   order of variables stored and maintained!
*  8/12/98:   other way to calculate the number of decimals:
*             #decimals in principle sufficient to discriminate between 
*             smallest difference between consecutive values.
* 5/12/2001   small corrections that guarantee that after completion of the command, the observations
*             will be in the same order.
* 4/2/02      a slight improvement useful for str variables who are left justified: remove as many blanks 
*             from the right as possible, but keeps the variable left justified (useful in qlist)
* 10/4/04     trim option added: trims string variables
* 1/12/2004   double will be automatically changed into float, since double precision is not necessary for our type of data 

program define eformat
quietly {
    version 7.0
    set more 0
    local varlist "req min(1)"
    local options "VName Label Value  Date(string) Newdec TRIM"
    parse "`*'"
    local vars `varlist'
    local varlist "req min(1)"
    parse "_all"
    local order `varlist'
    local sorted: sortedby
    *store original order of observations
    tempvar obsorder
    if "`sorted'"!="" { 
      qby `sorted' : gen  `obsorder'=_n 
    }
    else { 
      gen `obsorder'=_n 
    }
    
    local varlist `vars'
       
    compress `varlist'
    parse "`varlist'", parse(" ")
    if "`date'"~=""{  /* accept only if the specified date-format is valid,
              otherwise replace by default %dDlY  */
        if substr("`date'",1,2)~="%d" { local date %dDlY }
        else {
            local df =substr("`date'",3,.)
            if "`df'"=="" { local date %dDlY }
            else {
                nel ,str(`df') el(nNmMlLdDcCyY_.,:-/')
                if $nel!=length("`df'") {  local date %dDlY }
            }
        }
    }

    tempvar temp ll temp1
    while "`1'"~="" {
        /* Op basis van het format worden een aantal lokale macro's gevuld:
            - form   : het format, bv. %8.2f
            - point  : de positie waar de (eventuele) `.' staat, = 0 indien datum of string
            - len    : de lengte van de string `form'
            - dec    : het aantal cijfers achter de `.', bij %8.2f is dit 1
            - n1     : het getal voor de `.', bij %8.2f is dit 8
            - n2     : het aantal decimalen in het huidige format, bij %8.2f is dit 2
            - decstr : de substring vanaf de `.': bij %8.2f is dit `.2f'
        */
        capture drop `temp'
        capture drop `ll'
        local type: type `1'
        if "`type'"=="double" {   /* 1/12/2004 Wvp Added. Could be made optional with an option*/
          recast float `1', force
          local type float
        }
        if "`type'"=="float" {
            count if int(`1')~=`1'
            if r(N)==0 {
                su `1'
                if r(min)>-2*10^9&r(max)<2*10^9 {
                    recast  long `1'
                    local type long
                }
            }
        } 
        local vallab: value label `1'
        if "`vallab'"~="" {
           capture label list `vallab'
           if _rc>0 {   /* value label not defined */
            local vallab 
           }
        }
        local form: format `1'
        if index(upper("`form'"),"D")>0 {local dat dat}
        else {local dat }
        if index("`type'","str")>0 {
          local string string
          if "`trim'"=="trim" { replace `1' =trim(`1') }
          else {
             /* 4/2/02 a slight improvement useful for str variables who are left justified: remove as many blanks 
             from the right as possible */
            tempvar lstr
            gen `lstr'=length(`1')
            su `lstr'
            if r(min)==r(max)&r(min)>0 { /* this implies left justified */
              ljust `1'         /* left justifies again, but first trims! added 4/2/2002 */
              local type: type `1'
            }
            drop `lstr'
          }  
        }
        else {local string }
        if "`string'"~="string"&"`dat'"~="dat" {
              local point=index("`form'",".")
              local len=length("`form'")
              local dec=`len'-`point'-1
              local n1=real(substr("`form'",2,`point'-2))
              local n2=real(substr("`form'",`point'+1,`dec'))
              local decstr=substr("`form'",`point',.)
        }   
        local wvar = 1
        if "`vname'"=="vname" { local wvar = max(`wvar',length("`1'")) }
        if "`label'"~=""&"`vallab'"~=""  /* removed on 14/8/02 &`wvar'<8 */ {
           decode `1', gen(`temp')
           gen byte `ll'=length(ltrim(`temp'))
           su `ll'
           local wvar=max(`wvar',r(max))
        }
    
        if index("`type'","str")>0 {
          local wvar =max(`wvar',real(substr("`type'",4,.))) 
          format `1' %`wvar's 
        }
        else if "`dat'"=="dat" {
          su `1'
          if r(N)>0 {  
            if "`date'"~="" { 
              local form `date' 
              format `1' `form' 
            }
            else if "`form'"=="%d"|"`form'"=="%td" { local form %dDlY }
            
            local form =subinstr("`form'","td","d",1)  /* 14/1/2004 %td is equivalent to %d in Stata 8 */
            local format=substr("`form'",3,.) 
            nel ,str(`format') el(_.,:-/')
            local nel1 $S_1
            nel ,str(`format') el(ML)
            local nel9 $S_1
            nel ,str(`format') el(ml)
            local nel3 $S_1
            nel ,str(`format') el(cCyYnNdD)
            local nel2 $S_1
            local ldat =`nel1'+2*`nel2'+3*`nel3'+9*`nel9'
            if `ldat'<`wvar' {
              local i=`ldat'
              while `i'<`wvar'{
                local format  _`format' 
                local i=`i'+1 
              }
              format `1' %d`format' 
            }
            local wvar =max(`ldat',`wvar')
          }
          else { format `1' %`wvar'.0f } /* all dates missing */
        }
        else if "`value'"!="value"&"`label'"=="label"&"`vallab'"~="" { 
        /* format niet baseren op values !*/
          if `n2'>`wvar'-1 {
            local n2=`wvar'-1
            local last=substr("`form'",-1,1)
            local decstr .`n2'`last'
          }
          format `1' %`wvar'`decstr'
        } 
        else if "`value'"=="value"|"`label'"==""|"`vallab'"=="" {
          su `1'
          local nobs=r(N) 
          local max =r(max)
          local min =r(min)
          if `nobs'<1 { format `1' %`wvar'.0f} 
          else if `nobs'>=1 {
           if ("`type'"=="int"|"`type'"=="byte"|"`type'"=="long") {
            local wvar=max(`wvar',length("`min'"),length("`max'"))      
            format `1' %`wvar'.0f 
           }
           else  {
              /* for float variables */
            capture drop `temp'
            su `1'
            local max =r(max)
            local min =r(min)
            local lint=length(string(int(`max')))
            if `min'<0 { local  lint=max(`lint',1+length(string(int(abs(`min'))))) }
            local dj=1
            if `max'<=1&`min'>=-1 { local dj=2 }
    *Anders op 8/12/98 en later op 19/1/99 Alles bij elkaar een tamelijk ondoorzichtige regel!
            sort `1'
            gen `temp1'=`1'
            gen `temp'=`temp1'-`temp1'[_n-1]
            su `temp' if `temp'>0
            local mindif=r(min) /*smallest diff consecutive values */
            replace `temp1'=abs(`temp1')  
            su `temp1' if `temp1'~=0
            local minabs=r(min) /* smallest abs value <>0 */
            local deltabs=r(max)-r(min) /* max-min of abs value <>0 */
            if r(N)>0 {
                while `mindif'*10^`dj'<0.8&`dj'+`lint'+1<=8&`minabs'*10^(`dj'-1)<0.8&`deltabs'*10^(`dj'-3)<0.8  {local dj=`dj'+1 }
            }
            drop `temp1' `temp' 
     *Anders op 8/12/98
            if `n2'>0&"`newdec'"=="" { local dj=`n2' } /* if decimals specified do not change, unless newdec ! */
            local wvar =max(`wvar',`lint'+1+`dj')
            if      `wvar'<=10        { format `1' %`wvar'.`dj'f }
            else if (`n2'==0|"`newdec'"=="")&`wvar'>10    { 
                format `1' %10.0g 
                local wvar 10
            }
            else if `n2'>0&"`newdec'"~=""&`wvar'>8 &`n2'<=6 { 
                format `1' %8.`n2'g 
                local wvar 8
            }
            else if `n2'>0&"`newdec'"~="" &`wvar'>8 &`n2'>6 { 
                local wvar=`n2'+2
                format `1' %`wvar'.`n2'g 
            }
           }
          }
        }
        char `1'[width] `wvar'
        mac shift
    }/* end while */
    order `order'  /* restores the original order of all variables */
    if "`sorted'"!="" { sort `sorted' `obsorder' } /* restores original sort - if any */
    else {sort `obsorder'}
} /* end quietly */
end

