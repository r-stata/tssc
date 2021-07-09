*** Module UTEST ***
* Change log
* 7.17.14 Version 1.1: Option prefix to handle multiple equations
* 2.22.16 Version 1.2: Fixed bug with trivial failure to reject H0
* 1.25.19 Version 1.3: Converted to rclass, return main results

program define utest, rclass
version 9

syntax varlist(min=2 max=2 numeric) [, MInimum(real -.12345) MAximum(real .12345) Quadratic Inverse Fieller Level(cilevel) PREfix(string)]
tokenize `varlist'
local var1="`1'"
local var2="`2'"

if "`prefix'"!="" & substr("`prefix'",-1,.)!=":" {
  local prefix "`prefix':"
  } 

local df=e(df_r)

if `df'==. {
   
  local df=e(N)  
  }

mat beta=e(b)
mat covar=e(V)

mat b1=beta[1,"`prefix'`var1'"]
local  b1=b1[1,1]

mat b2=beta[1,"`prefix'`var2'"]
local  b2=b2[1,1]

mat s11=covar["`prefix'`var1'","`prefix'`var1'"]
mat s12=covar["`prefix'`var1'","`prefix'`var2'"]
mat s22=covar["`prefix'`var2'","`prefix'`var2'"]

local s11=s11[1,1]
local s12=s12[1,1]
local s22=s22[1,1]

qui su `var1'
if `minimum'==-.12345 {
  local x_min=r(min)
  }
  else {
    local x_min=`minimum'
  }

if `maximum'==.12345 {
  local x_max=r(max)
  }
  else {
    local x_max=`maximum'
  }

if "`quadratic'"!="" {
  local model="quad"
  }
else if "`inverse'"!="" {
  local model="inv"
  }
else {
preserve

  g _xsq_=(`var1')^2
  g _xinv_=1/(`var1')

  qui corr  _xsq_ `var2'
  local quad_corr=r(rho)
  
  qui corr _xinv_ `var2'
  local inv_corr=r(rho)
 
  if abs(`quad_corr')>abs(`inv_corr') {
    local model="quad"
    }
  else  {
    local model="inv"
    } 
  
restore
}

if "`model'"=="quad" {
  local t_min=(`b1'+2*(`b2')*(`x_min'))/ sqrt(`s11'+4*(`x_min')^2*`s22'+4*(`x_min')*`s12')
  local sl_min=(`b1'+2*(`b2')*(`x_min'))
  local t_max=(`b1'+2*(`b2')*(`x_max'))/ sqrt(`s11'+4*(`x_max')^2*`s22'+4*(`x_max')*`s12')
  local sl_max=(`b1'+2*(`b2')*(`x_max'))
  local top=-(`b1')/(2*(`b2'))
  local shape="U-shape"	
  local h0shape=" (vs. H0:monotone or inverse U-shape.)"
  if `t_min' > `t_max' {
    local shape="inverse U-shape"  
    local h0shape=" (vs. H0:monotone or U-shape.)"  
    }
  di
  di as text "Specification: f(x)=x^2" 
  }
  
if "`model'"=="inv" {
  local t_min=(`b1'-(`b2')/((`x_min')^2))  / sqrt( `s11'+`s22'/((`x_min')^4)-2*(`s12')/((`x_min')^2) )
  local sl_min=(`b1'-(`b2')/((`x_min')^2))
  local t_max=(`b1'-(`b2')/((`x_max')^2))  / sqrt( `s11'+`s22'/((`x_max')^4)-2*(`s12')/((`x_max')^2) )
  local sl_max=(`b1'-(`b2')/((`x_max')^2))
  local top=sqrt(`b2'/(`b1'))
  local shape="U-shape"	 
  local h0shape=" (vs. H0:monotone or inverse U-shape.)"
  if `t_min' > `t_max' {
    local shape="inverse U-shape" 
    local h0shape=" (vs. H0:monotone or U-shape.)"
    }
  di
  di as text "Specification: f(x)=1/x"
  }

local shape="U shape"	
local h0shape="Inverse U shape "
if `t_min' > `t_max' {
 local shape="Inverse U shape"
 local h0shape=" U shape "
 }

di as text "Extreme point: " in result %9.0g `top'
di
di as text "Test:"
di as text "     H1: `shape'"
di as text " vs. H0: Monotone or `h0shape'"
di

local t_sac=min(abs(`t_min'),abs(`t_max'))

di in text "{hline 17}{c TT}{hline 31}"
di in text %-17s " " "{c |}   Lower bound      Upper bound"
di in text "{hline 17}{c +}{hline 31}"
di as text %-17s "Interval" "{c |}   " in result %9.0g `x_min' "        " %9.0g `x_max'
di as text %-17s "Slope" "{c |}   " in result %9.0g `sl_min' "        " %9.0g `sl_max'
 
if (`t_min')*(`t_max')>0 {
  di in text "{hline 17}{c BT}{hline 31}"
  di
  di as text "Extremum outside interval - trivial failure to reject H0"
  
  return scalar t=.
  return scalar p=.
  }
  
  else {
  di as text %-17s "t-value" "{c |}   " in result %9.0g `t_min' "        " %9.0g `t_max'
  di as text %-17s "P>|t|" "{c |}   " in result %9.0g ttail(`df',abs(`t_min')) "        " %9.0g ttail(`df',abs(`t_max'))
  di in text "{hline 17}{c BT}{hline 31}"

  di
  di as text "Overall test of presence of a " "`shape'" ":"
  di as text "     t-value = " in  result %9.2f `t_sac'
  di as text "     P>|t|   = " in result %9.3g ttail(`df',`t_sac')

  return scalar t=`t_sac'
  return scalar p=ttail(`df',`t_sac')
  }  

  
  return scalar x_l=`x_min'
  return scalar x_u=`x_max'
  return scalar s_l=`sl_min'
  return scalar s_u=`sl_max'
  return scalar t_l=`t_min'
  return scalar t_u=`t_max'
  return scalar extr=`top'
  return local shape="`shape'"  

*** Calculation of Fieller interval ***

if "`fieller'"!="" {
di
local df=e(df_r)
if `df'==. {
  local df=e(N)  
  }

local alpha=1-`level'/100
local T=invttail(`df',.5*`alpha')
local d=((`s12')^2-`s11'*`s22')*`T'^2+(`b2')^2*`s11'+(`b1')^2*`s22'-2*(`b1')*(`b2')*(`s12')

* simplest case: interval away from inf 
if `d'>0 & ((`b2')^2-`s22'*`T'^2)>0 {
    local theta_l=(-`s12'*`T'^2+(`b1')*(`b2')-`T'*sqrt(`d')) / ((`b2')^2-`s22'*`T'^2)
    local theta_h=(-`s12'*`T'^2+(`b1')*(`b2')+`T'*sqrt(`d')) / ((`b2')^2-`s22'*`T'^2)

    if "`model'"=="quad" {
            di as text 100*(1-`alpha') "% Fieller interval for extreme point: " in result "[" -0.5*`theta_h' "; " -0.5*`theta_l' "]"
    }
    if "`model'"=="inv" & `theta_l'*`theta_h'>0 {
            di as text 100*(1-`alpha') "% Fiellers interval for extreme point: " in result "[" 1/`theta_h' "; " 1/`theta_l' "]"
    }
    if "`model'"=="inv" & `theta_l'*`theta_h'<0 {
        di as error "For the chosen level of significance it cannot be"
        di as error "rejected that either the function does not have a zero" 
        di as error "tangent and/or that the extremum point is x=0, which "
        di as error "is not allowed given the transformation f(x)=1/x"
    }
    }
    
* interval covers inf 
if `d'>0 & ((`b2')^2-`s22'*`T'^2)<0 {
    local theta_l=(-`s12'*`T'^2+(`b1')*(`b2')-`T'*sqrt(`d')) / ((`b2')^2-`s22'*`T'^2)
    local theta_h=(-`s12'*`T'^2+(`b1')*(`b2')+`T'*sqrt(`d')) / ((`b2')^2-`s22'*`T'^2)
    
    if "`model'"=="quad" {
            di as text 100*(1-`alpha') "% Fieller interval for extreme point: " in result "[-Inf;" -0.5*`theta_h' "] U [" -0.5*`theta_l' ";+Inf]"
    }
    if "`model'"=="inv" {
        di as error "For the chosen level of significance it cannot be"
        di as error "rejected that either the function does not have a zero" 
        di as error "tangent and/or that the extremum point is x=0, which "
        di as error "is not allowed given the transformation f(x)=1/x"
     }
    }
 * interval covers R
if `d'<0 {
    local theta_l=(-`s12'*`T'^2+(`b1')*(`b2')-sqrt(`d')) / ((`b2')^2-`s22'*`T'^2)
    local theta_h=(-`s12'*`T'^2+(`b1')*(`b2')+sqrt(`d')) / ((`b2')^2-`s22'*`T'^2)
    
    if "`model'"=="quad" {
              di in text 100*(1-`alpha') "% Fieller interval for extreme point: " as result "[-Inf; +Inf]"
    }
    if "`model'"=="inv" {
        di as error "For the chosen level of significance it cannot be"
        di as error "rejected that either the function does not have a zero" 
        di as error "tangent and/or that the extremum point is x=0, which "
        di as error "is not allowed given the transformation f(x)=1/x"
    }
    } 
    }  
end
