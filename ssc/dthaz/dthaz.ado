*! version 2.0.0 4dec2011 by alexis dot dinno at pdx dot edu
*! discrete-time event history analysis command with parsimonious
*! smoothing of time, different estimation strategies, graphing
*! and more

*   Copyright Notice
*   dthaz and dthaz.ado are Copryright (c) 2001, 2011 Alexis Dinno
*
*   This file is part of dthaz.
*
*   dthaz is free software; you can redistribute it and/or modify       
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation; either version 2 of the License, or          
*   (at your option) at any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program (dthaz.copying); if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

* Syntax:  dthaz [varlist] [if] [in] [fweight pweight iweight/] [, 
*          specify(#[,#,#,...]) tpar(#) truncate(#) pretrunc(#) display(#) level(#)
*          model Link(string) cluster(varlist) reuse suppress graph(#) XLAbel(string) 
*          YLAbel(string) XTick(numlist) YTick(numlist) graph_options copyleft]


* Check for version compatibility and notify user of version incompatibility 
* and let them know I am ammennable to making back-compatible revisions.

program define dthaz

  if int(_caller())<7 {
    di in r "dthaz- does not support this version of Stata." _newline
    di as txt "Requests for a v6 compatible version may be challenging to honor." 
    di as txt "Requests for a version compatible with versions of STATA earlier than v6 are "
    di as txt "untenable since I do not have access to the software." _newline 
    di as txt "All requests are welcome and will be considered."
    exit
  }
  if int(_caller()) >= 8 {
    dthaz8 `0'
  }
  if int(_caller()) == 7 {
    dthaz7 `0'
  }

end


*******************************************************************************
*******************************************************************************
* dthaz for STATA Versions 8+                                                 *
*******************************************************************************
*******************************************************************************

program define dthaz8, eclass
 version 8.0
 syntax [varlist] [if] [in] [fweight pweight iweight] [, SPecify(numlist)    /*
 */     TPar(integer -1) Truncate(integer 0) Pretrunc(integer 0)             /*
 */     Display(integer 0) Model Link(string) level(cilevel)                 /*
 */     CLUSter(varlist numeric min=1 max=1) reuse suppress GRaph(integer 0) /*
 */     YLAbel(string) XLAbel(string) XTick(numlist ascending)               /*
 */     YTick(numlist ascending) copyleft * ]

*NOTE: The reuse switch is a programming aid for use by msdthaz. This option
*tells dthaz to calculate the specified probabilities, but use whatever the
*most recent estimate was. In this way, computing time is reduced by avoiding
*repeadted estimation of the model in msdthaz. This is especially helpful when 
*using the complementary log-log link. Reuse is NOT intended for user 
*application of dthaz.


quietly {

  preserve

*******************************************************************************
*Set up shop, prepare variables, confirm truncate, pretrunc, tpar, etc.       *
*******************************************************************************

* display the copyleft information if requested

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "dthaz and dthaz.ado are Copyright (c) 2001, 2011 alexis dinno" _newline
      di "This file is part of dthaz." _newline
      di "dthaz is free software; you can redistribute it and/or modify"
      di "it under the terms of the GNU General Public License as published by"
      di "the Free Software Foundation; either version 2 of the License, or"
      di "(at your option) at any later version." _newline
      di "This program is distributed in the hope that it will be useful,"
      di "but WITHOUT ANY WARRANTY; without even the implied warranty of"
      di "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
      di "GNU General Public License for more details." _newline
      di "You should have received a copy of the GNU General Public License"
      di "along with this program (dthaz.copying); if not, write to the Free Software"
      di "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA" _newline
      }
    }

*Validate link function

  if "`link'"=="" {
    local link = "logit"
    }
  if (!("`link'"=="logit" | "`link'"=="cloglog" | "`link'"=="probit")) {
    noisily {
      di as err "invalid link():  `link'." _newline "valid link() options are logit, cloglog, or probit."
      }
    error (199)
    }


*Validate for use of both truncate and pretrunc. truncate+pretrunc must
*be < maxl (of the original dataset) minus 2 or there will be no periods
*to analyse change for!

  sum _period
  if (`truncate' ~= 0 & `pretrunc' ~=0) {
    if ( (`truncate'-`pretrunc') <= 2 ) {
      noisily {
        di as err "truncate() and pretrunc() values are incompatible."
        di as err "not enough periods left to analyze: (`truncate'-`pretrunc') <= 2."
        }
      exit
      }
    }

*Set up truncate appropriately; maxl is the MAXimum Length; mxm1 is the
*MaXimum length Minus 1

  sum _period
  if (`truncate'<1 | `truncate'>r(max)) {
    local maxl=r(max)
    if (`truncate' ~= 0) {
      noisily {
        di as err "Truncation value out of range."
        di as white "No truncation used." _newline
        }
      }
    }
   else {
    local maxl=`truncate'
    }

  local mxm1=`maxl'-1
  local newobs=`maxl'+1 

*Evaluate whether any of the time periods are entirely absent event occurence. 
*Terminate program if this is the case and notify user.

  forvalues x=1/`maxl' {
    count if _period==`x' & _Y==1
    local events=r(N)
    count if _period==`x' & _Y==0
    local noevents=r(N)  
    if `events'==0 | `noevents'==0 {
      noisily {
        di as err "No variation in event occurence for period " `x' "!"
        di as err "(no events occured at this time period)"
        }
      error `events'==0
      exit
      }
    }

*Deal with  pretrunc... make sure that pretrunc is either greater than or 
*equal to zero AND less than maxl-l, or do pre-truncation.

  if (`pretrunc'<0 | `pretrunc'>=`mxm1') {
    noisily {
      di as err "Pre-truncation value out of range."
      di as white "No pre-truncation used." _newline
      }
    }
   else {
    if (`pretrunc' ~= 0) {

* Dropping the first `pretrunc' number of period indicator variables
      forvalues x=1/`pretrunc' { 
        drop _d`x'
        }
    
* Sequentially renaming the remaining period indicators.
      local maxl = `maxl'-`pretrunc'
      local mxm1 = `mxm1'-`pretrunc'
      local newobs = `newobs'-`pretrunc'
      forvalues x=1/`maxl' {
        local curper = `pretrunc'+`x'
        rename _d`curper' _d`x'
        }
    
* Dropping observations in the pre-truncated periods    
      drop if _period<=`pretrunc'

* Revaluing _period so that the earliest time value is 1 (i.e.
* subtracting the pre-truncation number from _period.
      replace _period = _period-`pretrunc'
      }
    }

*Deal with tpar values. For those too low, slap on wrist and set to default.
*For those overspecified, alert and lower to maximum order polynomial
*representation of time.

*Here's the slap on wrist
  if `tpar'<-2 {
    noisily {
      di as error "The specified value for time parameterization out of range."
      di as white "Time modeled as fully discreet." _newline
      }
    local tpar = -1
    }

*Here's the alert
  if `tpar'>=`maxl' {
    noisily {
      di as error "Polynomial parameterization of time overspecified. "
      di as error `mxm1' " is the highest order polynomial parameterization allowed for this dataset."
      di as white "Time parameterized as a polynomial of order " `mxm1' "." _newline
      }
    local tpar = `mxm1'
    }

*Create an explicit constant term for later funky parameterizations of time
  if `tpar'~=-1 {
    generate _one=1
    }
 
*This line is here to facilitate the "macro shift" style yumminess later
  tokenize `varlist'


*******************************************************************************
*Specify which time range to estimate for different parameterizations of time *
*******************************************************************************

*For fully discrete time
  if `tpar'==-1 {
    local tvars = "_d1-_d"+"`maxl'"
    }

*For constant effect of time

  if `tpar'==0 {
    local tvars="_one"
    }
  
*Take care of n-polynomial time variables for n>=2

  if `tpar'>=1 {

  *The local variable npoly is the order of the polynomial
    local npoly=`tpar'
    
  *_period_1 through _periodX are the predictors representing npoly time
    for num 1/`npoly': generate _period_X = _period^X
    
  *These predictors are arranged from highest to lowest order
    for num 1/`npoly': order _period_X

  *And the local variable tvars which describes which time-predictors to use
  *in the regression model is specified.
    local tvars="_period_"+"`npoly'"+"-_period_1 _one"
    local tvars = "`tvars'"
    }

*And let's not forget root parameterization of time...

  if `tpar'==-2 {
    generate _periodrt=_period^.5
    local tvars="_periodrt _period _one"
    }


*******************************************************************************
*Prepare to tortuously create the specification matrix for predictors         *
*The matrix _Zero will be prepended to _Spec to create an NxN matrix          *
*containing the estimate specification values from specify().                 *
*******************************************************************************
  
  if `tpar'==-1 {
    matrix _Zero=J(1,`maxl',0)
    }
    
  if `tpar'==0 {
    matrix _Zero=J(1,`maxl',0)
    }

  if `tpar'==-2 {
    local maxlp=2*`maxl'
    matrix _Zero = J(1,`maxlp',0)
    }

*_Spec contains the variable values for the specified estimate
  matrix _One = (1)
  matrix input _Spec = (`specify')
  local argnum = colsof(_Spec)
  if `tpar'~=-1 {
    matrix _Spec = _One,_Spec
    }

*End the quietly block so the following output is visible
  }

*******************************************************************************
*Initial output. Tell the user what's in store, reiterate specification for   *
*estimate. At this point _Spec holds values corresponding to the tokenized    *
*variables in varlist.                                                        *
*******************************************************************************

if "`suppress'"=="" {
  noisily {

    di _newline
    di as txt "Discrete-Time Estimation of Conditional Hazard and Survival Probabilities"
    di as txt "------------------------------------------------------------------------------" 

    if `tpar'==-2 { 
      di as txt "Time Parameterization:  Square Root" 
      }
    if `tpar'==-1 {
      di as txt "Time Parameterization: Fully Discrete" 
      }
    if `tpar'==0 {
      di as txt "Time Parameterization: Constant Effect polynomial of order 0)" 
      } 
    if `tpar'==1 {
      di as txt "Time Parameterization: Linear (polynomial of order 1)" 
      }
    if `tpar'==2 {
      di as txt "Time Parameterization: Quadratic (polynomial of order 2)" 
      }
    if `tpar'==3 {
      di as txt "Time Parameterization: Cubic (polynomial of order 3)" 
      }
    if `tpar'>=4 {
      di as txt "Polynomial Time Parameterization of Order " `tpar' 
      }

    if "`specify'"=="" {
      di as txt "Baseline model (no additional predictors)"
      }
    if "`specify'"~="" {
      di _newline as txt "Additional predictors specified as:"
      }

    if `tpar'==-1 {
      forvalues x=1/`argnum' {
        di as txt "`1'" " = " as inp el(_Spec,1,`x')
        macro shift
        }
      }

    if `tpar'~=-1 {
      local newarg = `argnum'+1
      forvalues x=2/`newarg' {
        di as txt "`1'" " = " as inp el(_Spec,1,`x')
        macro shift
        }
      }
    }
  } 
quietly {


*******************************************************************************
*Now _Spec can be transmogrified into a form applicable to later estimate.    *
*******************************************************************************

  if `tpar'==-1 | `tpar'==-2 {
* if `tpar'<=-1 {
    matrix _Spec = _Zero,_Spec
    }

  
*Make _Spec diagonal so it can multiply with _Q2 for hazard calculation

  matrix _Spec = diag(_Spec)


*******************************************************************************
*Whip out the estimation... ensuring the appropriate predictors (if `varlist' *
*is empty, then the numbered macros `1', `2', etc. contain the variable names *
*from the dataset in order of appearance. Please see the note about the intent*
*of the reuse switch at the start of this code.                               *
*******************************************************************************


  if "`reuse'"=="" { 

    if "`link'"=="logit" {

       if "`specify'"=="" {
         logit _Y `tvars' `if' `in' [`weight' `exp'], nocons cluster(`cluster')
         }
        else {
         logit _Y `tvars' `varlist' `if' `in' [`weight' `exp'], nocons cluster(`cluster')
         }

       if "`model'"~="" {
         noisily logit 
         }
 
       if "`suppress'"=="suppress" { 
         exit
         }
       }


    if "`link'"=="cloglog" {

      if "`specify'"=="" {
        cloglog _Y `tvars' `if' `in' [`weight' `exp'], nocons cluster(`cluster')
        }
       else {
        cloglog _Y `tvars' `varlist' `if' `in' [`weight' `exp'], nocons cluster(`cluster')
        }
      
      if "`model'"~="" {
        noisily cloglog 
        }    

      if "`suppress'"=="suppress" { 
        exit
        }
      }
    
    
    if "`link'"=="probit" {

       if "`specify'"=="" {
         probit _Y `tvars' `if' `in' [`weight' `exp'], nocons cluster(`cluster')
         }
        else {
         probit _Y `tvars' `varlist' `if' `in' [`weight' `exp'], nocons cluster(`cluster')
         }

       if "`model'"~="" {
         noisily probit 
         }
 
       if "`suppress'"=="suppress" { 
         exit
         }
       }
            
*Clean up for constant effect time
    if `tpar'==0 {
      drop _one 
      }
 
*Clean up for n-polynomial time
    if `tpar'>=1 {
      drop `tvars' 
      }

*Clean up for root time
    if `tpar'==-2 {
      drop _one _periodrt 
      }

    }


*******************************************************************************
*At this point this program departs to highly convoluted realms. The basic    *
*strategy is to obtain a representation of estimates for the effect of time at*
*each period of the dataset. How this is done varies depending on the         *
*parameterization of time, but usually involves creating a vector "_Q" holding*
*estimates for each period. The second part of the strategy is the creation of*
*a constant estimate term called "est" which contains the parameter estimates *
*for the constant, pre-specified portion of the model.                        * 
*******************************************************************************


*It all starts with the estimates

  matrix _Q = e(b)


*******************************************************************************
*Discrete-time estimates of time's effect: copy estimates from coeficient     *
*matrix. _Q will be used to describe the period estimates, while _Q2 will     *
*provide the estimates from the estimate's specification.                     *
*******************************************************************************

  if `tpar'==-1 { 
    matrix _Q2 = diag(e(b)) 
    }

*for constant effect of time...

  if `tpar'==0 {
    matrix _Q = e(b)
    matrix _Q2 = diag(_Q)
    }


*******************************************************************************
*The following code generates a number of matrices equal to the order of the  *
*polynomial time parameterization. Each matrix is named PolyTimeXO where X is * 
*the power that the value of period is raised to. These values are then       *
*aggregated for each time period in the matrix _ParameterizedTime which will  *
*be used in the conditional hazard probability calculation.                   *
*******************************************************************************

  if `tpar'>=1 {

*This loop creates the separate matrix for each exponentiation of time
    forvalues npolynum=1/`npoly' {
      local no = 1+`npoly'-`npolynum'
      for num `no': matrix _PolyTimeXO = J(1,`maxl',0)

*This loop creates the values within the exponentiation for each period
      forvalues per=1/`maxl' {

*Replace the placeholder in each period position of PolyTimeXO with the
*appropriate exponentiation of period times the parameter estimate.
        matrix _PolyTime`no'O[1,`per']=(`per'^`no')*el(_Q,1,`npolynum')
        }
      }

*Get collapse the previously arranged matrices into one and loose 'em...
    matrix _ParameterizedTime = J(1,`maxl',0)
    forvalues order=1/`npoly' {
      matrix _ParameterizedTime = _ParameterizedTime + _PolyTime`order'O
      matrix drop _PolyTime`order'O
      }

*Create the matrix _Q2 which holds the model specifications for the constant  *
*term _one plus any predictors in the model.
    local specs = `npoly'+1
      
*Do so by copying the estimates _after_ the terms representing time
    matrix _Q2 = _Q[1,`specs'...]
    matrix _Q2 = diag(_Q2)

    }

*******************************************************************************
*For root parameterizations of time Matrix _Root holds the estimates for      *
*linearly parameterized time for each period. _Toor is _Root reversed... If   *
*this looks wierd, you ought to have seen the code before I wrote the above   *
*bit of prettiness for n-polynomial representation...                         *
*******************************************************************************

  if `tpar'==-2 {

*Create linear time vector
    forvalues x=2/`maxl' {
      local place = (`x')*el(_Q,1,2)
      if `x'==2 {
        matrix _Linear = (`place')
        matrix _Raenil = _Linear
        }
       else {
        matrix _Linear = (`place'),_Linear
        matrix _Raenil = _Raenil,(`place')
        }
      }
    local place = el(_Q,1,2)
    matrix _Raenil = (`place'),_Raenil

*Create root time vector
    forvalues x=1/`maxl' {
      local place = ((`x')^.5)*el(_Q,1,1)
      if `x'==1 {
        matrix _Root = (`place')
        matrix _Toor = _Root
        }
       else {
        matrix _Root = (`place'),_Root
        matrix _Toor = _Toor,(`place')
        }
      }

*At this point _Q is B_psq B_p B_one B_predictors... We need to get rid of the 
*B_sq term, so:
    local bark = (`argnum'+3)
    forvalues x=2/`bark' {
      local sploof = el(_Q,1,`x')
      if `x'==2 {
        matrix _Blar = (`sploof')
        }
       else {
        matrix _Blar = _Blar,(`sploof')
        }
      }
    matrix _Q = _Blar
    matrix _Q2 = _Root,_Linear,_Q
    matrix _Q2 = diag(_Q2)
    matrix drop _Blar _Linear _Root
    }


*******************************************************************************
*_Q2 contains the parameter*specified variable values for the estimate at hand*
*******************************************************************************

  matrix _Q2 = _Q2*_Spec

*******************************************************************************
*est contains the actual quantity employed in adjusting the calculation of    *
*hazard. The wierdness in producing the estimates for root-represented time is*
*apparent in the need to clean up for it especially here.                     *
*******************************************************************************

  if `tpar'>=-1 {
    local est = trace(_Q2) 
    }

  if `tpar'==-2 {
    local est = trace(_Q2)
    matrix _Q = _Toor,_Raenil
    matrix drop _Toor _Raenil
    }


*******************************************************************************
*Into the home stretch. Matrix _Hazard will be created and populated using    *
*some variation of the basic algorithm.                                       *
*******************************************************************************

*Generate hazard matrix, with a non-calculated 0th period

  matrix _Hazard = (0, 0)


*The following bit of flow-control limits the number of periods displayed if  
*the user asked for it with the display option

  if (`display'>0 & `display'<`maxl') {
    local maxl=`display'
    local newobs=`maxl'+1
    }

*Set the number of coeficients from the estimate matrix and specification matrix

*Hazard probabilities

  forvalues num=1/`maxl' {

    *for fully discrete and _Linear time
    if `tpar'==-1 {
      local specest = el(_Q,1,`num')+`est'
      }

    *for constant effect of time
    if `tpar'==0 {
      local specest = `est'
      }

    *for root time
    if `tpar'==-2 {
      local lin = `num'+`maxl'
      local specest = el(_Q,1,`num')+el(_Q,1,`lin')+`est'
      }

    *for polynomial time
    if `tpar'>=1 {
      local specest = el(_ParameterizedTime,1,`num')+`est'
      }

    if "`link'"=="logit" {
      local haz = 1/(1+(exp(-1*(`specest'))))
      }      
    if "`link'"=="cloglog" {
      local haz = 1-(exp(-1*exp(`specest'))) 
      }
    if "`link'"=="probit" {
      local haz = normal(`specest')
      }      
    matrix _Period = (`num',`haz')
    matrix _Hazard = _Hazard\_Period
    }


*Produce survival probabilities and append to _Hazard
  forvalues num=1/`newobs' {
    if `num'==1 {
      local lastsur = 1
      matrix _Survival = (1)
      }
     else {
      local back = `num'-1
      local lastsur = el(_Survival,`back',1)
      }
    local haz = el(_Hazard,`num',2)
    local sur = (1-`haz')*(`lastsur')
    matrix _Period = (`sur')
    if `num'~=1 {
      matrix _Survival = _Survival\_Period
      }
    }


*Produce standard errors for h_t and S_t

  local q          = e(df_m)
  matrix _sigma_h  = vecdiag(I(`maxl'))
  matrix _sigma_Sa = vecdiag(I(`maxl'))    
  matrix _sigma_Sb = vecdiag(I(`maxl'))
  matrix _sigma_S  = vecdiag(I(`maxl'))
  matrix betas     = e(b)
  matrix V         = e(V)
  forvalues t=1/`maxl' {
    if `tpar' == -2 {
      matrix Z = (`t'^.5, `t', 1)
      }
    if `tpar' == -1 {
      matrix Z = I(`maxl')
      matrix Z = Z[`t',1..`maxl']
      }
    if `tpar' == 0 {
      matrix Z = (1)
      }
    if `tpar' >0 {
      matrix Z = (1)
      forvalues polynomial=1/`tpar' {
        matrix Z = `t'^`polynomial',Z
        }
      } 
    if "`specify'" ~= "" {
      tokenize `specify'
      foreach specification in `*' {
        matrix Z = Z,(`specification')
        }
      }
    local lZ = colsof(betas)
    matrix bZ = Z
    forvalues i=1/`lZ' {
      matrix bZ[1,`i'] = betas[1,`i']*Z[1,`i']
      } 
    if "`link'"=="logit" {
      matrix _sigma_h[1,`t'] = ( trace(( ((exp( trace(diag(bZ)) ))/((1+exp( trace(diag(bZ)) ))^2))^2 * Z*V*(Z')) )^.5)
      matrix _sigma_Sa[1,`t'] = ( trace( ((exp( trace(diag(bZ)) ))/(1+exp( trace(diag(bZ)) )))^2 * Z*V*(Z')) )
      matrix _sigma_Sb[1,`t'] = (1/(1 + exp( trace(diag(bZ)) )))
      }
    if "`link'"=="cloglog" {
      matrix _sigma_h[1,`t'] = ( trace(( ( exp( trace(diag(bZ)) - exp(trace(diag(bZ))) ) )^2 * Z*V*(Z')) )^.5)
      matrix _sigma_Sa[1,`t'] = ( trace( ( exp(trace(diag(bZ)) ) )^2 * Z*V*(Z'))  )
      matrix _sigma_Sb[1,`t'] = exp( -exp( trace(diag(bZ)) ) )
      }
    if "`link'"=="probit" {
      matrix _sigma_h[1,`t'] = ( trace(( ( (1/sqrt(2*_pi))*exp((-(trace(diag(bZ))^2))/(2)) )^2 * Z*V*(Z')) )^.5)
      matrix _sigma_Sa[1,`t'] = ( trace( ( ((1/sqrt(2*_pi))*exp((-(trace(diag(bZ))^2))/(2))) / (1-normal(trace(diag(bZ)))) )^2 * Z*V*(Z'))  )
      matrix _sigma_Sb[1,`t'] = 1 - normal(trace(diag(bZ)))
      }
    if `t' > 1 {
      matrix _sigma_Sa[1,`t'] = (_sigma_Sa[1,`t'] + _sigma_Sa[1,(`t'-1)])
      matrix _sigma_Sb[1,`t'] = (_sigma_Sb[1,`t'] * _sigma_Sb[1,(`t'-1)])
      }
    matrix _sigma_S[1,`t'] = ( (_sigma_Sa[1,`t']*((_sigma_Sb[1,`t'])^2))^.5 )
    }

  matrix _sigma_h = (0),_sigma_h
  matrix _sigma_S = (0),_sigma_S
  matrix _Hazard = _Hazard,_Survival,(_sigma_h'),(_sigma_S')
  matname _Hazard Period Hazard Survival sigma_h sigma_S, columns(1...) explicit

  }


*******************************************************************************
*Final bit of output: display results to user                                 *
*******************************************************************************

 if "`suppress'"=="" {
   noisily {

     di _newline
     di as txt "-------------------------------------------------------------"
     di   as txt _col(4) "Period" _col(16) "p(Hazard)" _col(28) "Std. Err.  " _col(39) "p(Survival)" _col(52) "Std. Err.  "
     di   as txt _col(4) " (t)" _col(16) " ^h(t)" _col(28) " ^h(t)" _col(39) " ^S(t)" _col(52) " ^S(t)"
     di as txt "-------------------------------------------------------------"
     di  as result _col(6) "0" _col(19) "--" _col(31) "--" _col(39) " 1" _col(52) " 0" as result
     forvalues i=2/`newobs' {
       display  as result _col(6) el(_Hazard,`i',1) _col(16) %10.7f el(_Hazard,`i',2) _col(28) %10.7f el(_Hazard,`i',4) _col(39) %10.7f el(_Hazard,`i',3) _col(52) %10.7f el(_Hazard,`i',5) as result
     }
     di as txt "-------------------------------------------------------------"

  *Note estimation assumptions

     if "`link'"=="logit" {
       di as txt "Logit Link (assumes proportional odds)"
       }
     if "`link'"=="cloglog" {
       di as txt "Complementary Log-Log Link (assumes proportional hazards)" 
       }
     if "`link'"=="probit" {
       di as txt "Probit Link (assumes proportional probits)"
       }
     }
   }

   quietly {


*******************************************************************************
*Clean this mess on up!                                                       *
*******************************************************************************

*Drop that which must be dropped
 matrix drop _One _Period _Q _Q2 _Spec _Survival Z bZ
 if `tpar'==-2 | `tpar'==-1 {
   matrix drop _Zero 
   }
 if `tpar'>=1 {
   matrix drop _ParameterizedTime 
   }
 

*******************************************************************************
*Graph some output!                                                           *
*******************************************************************************

 restore, preserve

 svmat _Hazard, names(col)

 
*Generate cumulative incidence
    gen InvSurvival = 1 - Survival


*Generate upper and lower bounds for Hazard
    gen Hub = Hazard+(invnormal(1-((1-(`level'/100))/2))*sigma_h) if Period > 0
    replace Hub = 1 if Hub > 1 & Period > 0
    gen Hlb = Hazard-(invnormal(1-((1-(`level'/100))/2))*sigma_h) if Period > 0
    replace Hlb = 0 if Hlb < 0 & Period > 0


*Generate upper and lower bounds for Survival
    gen Sub = Survival+(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Sub = 1 if Sub > 1 & Period > 0
    gen Slb = Survival-(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Slb = 0 if Slb < 0 & Period > 0


*Generate upper and lower bounds for cumulative incidence
    gen Cub = InvSurvival+(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Cub = 1 if Cub > 1 & Period > 0
    gen Clb = InvSurvival-(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Clb = 0 if Clb < 0 & Period > 0


 set more on

*Manage graphing options input for all graphs

 if `graph'> 4 | `graph'<1 {
   local `graph'=0 
 } 

 if `"`xtitle'"'==`""' {
   local b1title = `"b1title("Period")"'
   local xtitle = `"xtitle("Period")"'
 }
  else {
    local b1title = `"b1title(`xtitle')"'
    local xtitle = `"xtitle(`xtitle')"'
  }  

 if "`ytick'"=="" {
   local ytick "yt(0(.2)1)" 
 }
  else {
    local ytick "yt(`ytick')" 
  }

 if "`ylabel'"=="" {
   local ylabel "yla(0(.2)1)" 
 }
  else {
    local ylabel "ylabel(`ylabel')" 
  }

*Graph conditional hazard probabilities
   if `graph'==1 {

*Deal with axes specific to conditional hazard curves
    if "`xtick'"=="" {
      local xtick "xt(1(1)`maxl')" 
    }
     else {
       local xtick "xs(`xtick')" 
     }
	if "`xlabel'"=="" {
	  local xlabel "xla(1(1)`maxl')" 
	}
     else {
       local xlabel "xlabel(`xlabel')" 
     }
    if `"`ytitle'"'==`""' {
      local ytitle = `"ytitle("Estimated Conditional Hazard Probability")"'
    }
     else {
       local ytitle = `"ytitle(`ytitle')"'
     }
 
    graph twoway line Hazard Period if Period~=0, `ytick' `ylabel' `ytitle' `xtick' `xlabel' `xtitle' title("Hazard Curve") subtitle("Conditional hazard probability vs. period") `options' legend(off) || line Hub Period, lwidth(vvthin) lcolor(gs8) || line Hlb Period, lwidth(vvthin) lcolor(gs8)

   }
   
*Graph survival probabilities
   if `graph'==2 | `graph'==4 {

*Deal with axes specific to survival curves
    if "`xtick'"=="" {
      local xtick = "xt(0(1)`maxl')" 
    }
     else {
       local xtick = "xt(`xtick')" 
     }
	if "`xlabel'"=="" {
	  local xlabel = "xla(0(1)`maxl')" 
	}
     else {
       local xlabel = "xlabel(`xlabel')" 
     }
    if `"`ytitle'"'==`""' {
      if `graph' == 2 {
        local ytitle = `"ytitle("Estimated Survival Probability")"'
        }
      if `graph' == 4 {
        local ytitle = `"ytitle("Estimated Cumulative Incidence Probability")"'        
        }
    }
     else {
       local ytitle = `"ytitle(`ytitle')"'
     }


    if `graph' == 2 {
      line Survival Period, `ytick' `ylabel' `ytitle' `xtick' `xlabel' `xtitle' title("Survival Curve") subtitle("survival probability vs. period") `options' legend(off) || line Sub Period, lwidth(vvthin) lcolor(gs8) || line Slb Period, lwidth(vvthin) lcolor(gs8)
      }
    if `graph' == 4 {
      line InvSurvival Period, `ytick' `ylabel' `ytitle' `xtick' `xlabel' `xtitle' title("Cumulative Incidence Curve") subtitle("cumulative incidence probability vs. period") `options' legend(off) || line Cub Period, lwidth(vvthin) lcolor(gs8) || line Clb Period, lwidth(vvthin) lcolor(gs8)
      }

   }

*Graph both conditional hazard and survival probabilities
   if `graph'==3 {
   
*Prepare for different x-axis labeling needs for hazard and survival
    local tempxt = "`xtick'"
    local tempxla = "`xlabel'"
    local tempytitle = "`ytitle'"
    
    if "`xtick'"=="" {
      local xtick = "xt(1(1)`maxl')" 
    }
     else {
       local xtick = "xt(`xtick')" 
     }
	if "`xlabel'"=="" {
	  local xlabel = "xla(1(1)`maxl')" 
	}
     else {
       local xlabel = "xlabel(`xlabel')" 
     }
    if "`ytitle'"=="" {
      local ytitle = `"ytitle("Estimated Conditional Hazard Probability")"' 
    }
     else {
       local ytitle = "ytitle(`ytitle')"
     }

    line Hazard Period if Period~=0, `ytick' `ylabel' `ytitle' `xtick' `xlabel' `xtitle' title("Hazard Curve") subtitle("conditional hazard probability vs. period") `options' legend(off) || line Hub Period, lwidth(vvthin) lcolor(gs8) || line Hlb Period, lwidth(vvthin) lcolor(gs8)
    more

    local xtick = "`tempxt'"
    local xlabel = "`tempxla'"
    local ytitle = "`tempytitle'"
    if "`xtick'"=="" {
      local xtick = "xt(0(1)`maxl')" 
    }
     else {
       local xtick = "xt(`xtick')"
     }
	if "`xlabel'"=="" {
	  local xlabel = "xla(0(1)`maxl')" 
	}
     else {
       local xlabel = "xlabel(`xlabel')" 
     }
    if `"`ytitle'"'==`""' {
      local l1title = `"l1title("Estimated Survival Probability")"'
      local ytitle = `"ytitle("Estimated Survival Probability")"'
    }
     else {
       local l1title = `"l1title(`ytitle')"'
       local ytitle = `"ytitle(`ytitle')"'
     }

    line Survival Period,  `ytick' `ylabel' `ytitle' `xtick' `xlabel' `xtitle' title("Survival Curve") subtitle("estimated survival probability vs. period") `options' legend(off) || line Sub Period, lwidth(vvthin) lcolor(gs8) || line Slb Period, lwidth(vvthin) lcolor(gs8)
    
   }

   restore, preserve 
 
 
*******************************************************************************
*Say goodbye to the nice user!                                                *
*******************************************************************************

mata: st_matrix("Hazard", st_matrix("_Hazard")[.,2]')
mata: st_matrix("HazardSE", st_matrix("_Hazard")[.,4]')
mata: st_matrix("Survival", st_matrix("_Hazard")[.,3]') 
mata: st_matrix("SurvivalSE", st_matrix("_Hazard")[.,5]') 

* clean up
matrix drop _Hazard _sigma_S _sigma_h V betas _sigma_Sb _sigma_Sa


 *Retain _Hazard for user...
  ereturn matrix SurvivalSE = SurvivalSE
  ereturn matrix Survival   = Survival
  ereturn matrix HazardSE   = HazardSE

  ereturn matrix Hazard     = Hazard
  return clear
 }

 
end





*******************************************************************************
*******************************************************************************
* dthaz for STATA v7
*******************************************************************************
*******************************************************************************
program define dthaz7, rclass
 version 7.0
 syntax [varlist] [if] [in] [fweight pweight iweight] [, SPecify(numlist)    /*
 */     TPar(integer -1) Pretrunc(integer 0) Display(integer 0)              /* 
 */     Model Link(string) level(cilevel) Truncate(integer 0)                /*
 */     CLUSter(varlist numeric min=1 max=1) reuse YLAbel(string)            /*
 */     XLAbel(string) XTick(numlist ascending) suppress GRaph(integer 0)    /*
 */     YTick(numlist ascending) copyleft * ]

*NOTE: The reuse switch is a programming aid for use by msdthaz. This option
*tells dthaz to calculate the specified probabilities, but use whatever the
*most recent estimate was. In this way, computing time is reduced by avoiding
*repeadted estimation of the model in msdthaz. This is especially helpful when 
*using the complementary log-log link. Reuse is NOT intended for user 
*application of dthaz.

 quietly {

  preserve

*******************************************************************************
*Set up shop, prepare variables, confirm truncate, pretrunc, tpar, etc.       *
*******************************************************************************

* display the copyleft information if requested

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "dthaz and dthaz.ado are Copyright (c) 2001, 2011 alexis dinno" _newline
      di "This file is part of dthaz." _newline
      di "dthaz is free software; you can redistribute it and/or modify"
      di "it under the terms of the GNU General Public License as published by"
      di "the Free Software Foundation; either version 2 of the License, or"
      di "(at your option) at any later version." _newline
      di "This program is distributed in the hope that it will be useful,"
      di "but WITHOUT ANY WARRANTY; without even the implied warranty of"
      di "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
      di "GNU General Public License for more details." _newline
      di "You should have received a copy of the GNU General Public License"
      di "along with this program (dthaz.copying); if not, write to the Free Software"
      di "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA" _newline
    }
  }

*Confirm the validity of cluster (for v7)

  if "`cluster'" ~= "" {
    local cluster = "cluster(`cluster')"
    }

*Validate link function

  if "`link'"=="" {
    local link = "logit"
    }
  if (!("`link'"=="logit" | "`link'"=="cloglog" | "`link'"=="probit")) {
    noisily {
      di as err "invalid link():  `link'." _newline "valid link() options are logit, cloglog, or probit."
      }
    error (199)
    }

*Validate for use of both truncate and pretrunc. truncate+pretrunc must
*be < maxl (of the original dataset) minus 2 or there will be no periods
*to analyse change for!

  sum _period
  if (`truncate' ~= 0 & `pretrunc' ~=0) {
    if ( (`truncate'-`pretrunc') <= 2 ) {
      noisily {
        di as err "truncate() and pretrunc() values are incompatible."
        di as err "not enough periods left to analyze: (`truncate'-`pretrunc') <= 2."
        }
      exit
      }
    }

*Set up truncate appropriately; maxl is the MAXimum Length; mxm1 is the
*MaXimum length Minus 1

  sum _period
  if (`truncate'<1 | `truncate'>r(max)) {
    local maxl=r(max)
    if (`truncate' ~= 0) {
      noisily {
        di as err "Truncation value out of range."
        di as white "No truncation used." _newline
      }
    }
  }
    else {
      local maxl=`truncate'
    }

  local mxm1=`maxl'-1
  local newobs=`maxl'+1 

*Evaluate whether any of the time periods are entirely absent event occurence. 
*Terminate program if this is the case and notify user.

  forvalues x=1/`maxl' {
   count if _period==`x' & _Y==1
   local events=r(N)
   count if _period==`x' & _Y==0
   local noevents=r(N)  
   if `events'==0 | `noevents'==0 {
     noisily {
       di as err "No variation in event occurence for period " `x' "!"
       di as err "(no events occured at this time period)"
     }
     error `events'==0
     exit
   }
  }

*Deal with  pretrunc... make sure that pretrunc is either greater than or 
*equal to zero AND less than maxl-l, or do pre-truncation.

  if (`pretrunc'<0 | `pretrunc'>=`mxm1') {
    noisily {
      di as err "Pre-truncation value out of range."
      di as white "No pre-truncation used." _newline
    }
  }
    else {
      if (`pretrunc' ~= 0) {

* Dropping the first `pretrunc' number of period indicator variables
        forvalues x=1/`pretrunc' { 
          drop _d`x'
        }
    
* Sequentially renaming the remaining period indicators.
        local maxl = `maxl'-`pretrunc'
        local mxm1 = `mxm1'-`pretrunc'
        local newobs = `newobs'-`pretrunc'
        forvalues x=1/`maxl' {
          local curper = `pretrunc'+`x'
          rename _d`curper' _d`x'
        }
    
* Dropping observations in the pre-truncated periods    
        drop if _period<=`pretrunc'

* Revaluing _period so that the earliest time value is 1 (i.e.
* subtracting the pre-truncation number from _period.
        replace _period = _period-`pretrunc'

      }

    }

*Deal with tpar values. For those too low, slap on wrist and set to default.
*For those overspecified, alert and lower to maximum order polynomial
*representation of time.

*Here's the slap on wrist
  if `tpar'<-2 {
    noisily {
      di as error "The specified value for time parameterization out of range."
      di as white "Time modeled as fully discreet." _newline
    }
    local tpar = -1
  }

*Here's the alert
  if `tpar'>=`maxl' {
    noisily {
      di as error "Polynomial parameterization of time overspecified. "
      di as error `mxm1' " is the highest order polynomial parameterization allowed for this dataset."
      di as white "Time parameterized as a polynomial of order " `mxm1' "." _newline
    }
    local tpar = `mxm1'
  }

*Create an explicit constant term for later funky parameterizations of time
  if `tpar'~=-1 {
    generate _one=1
  }
 
*This line is here to facilitate the "macro shift" style yumminess later
  tokenize `varlist'


*******************************************************************************
*Specify which time range to estimate for different parameterizations of time *
*******************************************************************************

*For fully discrete time
  if `tpar'==-1 {
    local tvars = "_d1-_d"+"`maxl'"
  }

*For constant effect of time

  if `tpar'==0 {
    local tvars="_one"
  }
  
*Take care of n-polynomial time variables for n>=2

  if `tpar'>=1 {

  *The local variable npoly is the order of the polynomial
    local npoly=`tpar'
    
  *_period_1 through _periodX are the predictors representing npoly time
    for num 1/`npoly': generate _period_X = _period^X
    
  *These predictors are arranged from highest to lowest order
    for num 1/`npoly': order _period_X

  *And the local variable tvars which describes which time-predictors to use
  *in the regression model is specified.
    local tvars="_period_"+"`npoly'"+"-_period_1 _one"
    local tvars = "`tvars'"

  }

*And let's not forget root parameterization of time...

  if `tpar'==-2 {
    generate _periodrt=_period^.5
    local tvars="_periodrt _period _one"
  }


*******************************************************************************
*Prepare to tortuously create the specification matrix for predictors         *
*The matrix _Zero will be prepended to _Spec to create an NxN matrix          *
*containing the estimate specification values from specify().                 *
*******************************************************************************
  
    if `tpar'==-1 {
      matrix _Zero=J(1,`maxl',0)
    }
    
    if `tpar'==0 {
      matrix _Zero=J(1,`maxl',0)
    }

    if `tpar'==-2 {
      local maxlp=2*`maxl'
      matrix _Zero = J(1,`maxlp',0)
    }

*_Spec contains the variable values for the specified estimate
  matrix _One = (1)
  matrix input _Spec = (`specify')
  local argnum = colsof(_Spec)
  if `tpar'~=-1 {
    matrix _Spec = _One,_Spec
  }

*End the quietly block so the following output is visible
 }

*******************************************************************************
*Initial output. Tell the user what's in store, reiterate specification for   *
*estimate. At this point _Spec holds values corresponding to the tokenized    *
*variables in varlist.                                                        *
*******************************************************************************

 if "`suppress'"=="" {
   noisily {

    di _newline
    di as txt "Discrete-Time Estimation of Conditional Hazard and Survival Probabilities"
    di as txt "------------------------------------------------------------------------------" 

    if `tpar'==-2 { 
      di as txt "Time Parameterization:  Square Root" 
    }
    if `tpar'==-1 {
      di as txt "Time Parameterization: Fully Discrete" 
    }
    if `tpar'==0 {
      di as txt "Time Parameterization: Constant Effect polynomial of order 0)" 
    } 
    if `tpar'==1 {
      di as txt "Time Parameterization: Linear (polynomial of order 1)" 
    }
    if `tpar'==2 {
      di as txt "Time Parameterization: Quadratic (polynomial of order 2)" 
    }
    if `tpar'==3 {
      di as txt "Time Parameterization: Cubic (polynomial of order 3)" 
    }
    if `tpar'>=4 {
      di as txt "Polynomial Time Parameterization of Order " `tpar' 
    }

    if "`specify'"=="" {
      di as txt "Baseline model (no additional predictors)"
    }
    if "`specify'"~="" {
      di _newline as txt "Additional predictors specified as:"
    }

    if `tpar'==-1 {
      forvalues x=1/`argnum' {
        di as txt "`1'" " = " as result el(_Spec,1,`x')
        macro shift
      }
    }

    if `tpar'~=-1 {
      local newarg = `argnum'+1
      forvalues x=2/`newarg' {
        di as txt "`1'" " = " as result el(_Spec,1,`x')
        macro shift
      }
    }
   }
 } 
 quietly {


*******************************************************************************
*Now _Spec can be transmogrified into a form applicable to later estimate.    *
*******************************************************************************

  if `tpar'==-1 | `tpar'==-2 {
*  if `tpar'<=-1 {
    matrix _Spec = _Zero,_Spec
  }

  
*Make _Spec diagonal so it can multiply with _Q2 for hazard calculation

  matrix _Spec = diag(_Spec)


*******************************************************************************
*Whip out the estimation... ensuring the appropriate predictors (if `varlist' *
*is empty, then the numbered macros `1', `2', etc. contain the variable names *
*from the dataset in order of appearance. Please see the note about the intent*
*of the reuse switch at the start of this code.                               *
*******************************************************************************


  if "`reuse'"=="" { 

    if "`link'"=="cloglog" {

    if "`link'"=="logit" {

       if "`specify'"=="" {
         logit _Y `tvars' `if' `in' [`weight' `exp'], nocons `cluster'
         }
        else {
         logit _Y `tvars' `varlist' `if' `in' [`weight' `exp'], nocons `cluster'
         }

       if "`model'"~="" {
         noisily logit
         }
 
       if "`suppress'"=="suppress" { 
         exit
         }
       }


      if "`specify'"=="" {
        cloglog _Y `tvars' `if' `in' [`weight' `exp'], nocons `cluster'
        }
       else {
        cloglog _Y `tvars' `varlist' `if' `in' [`weight' `exp'], nocons `cluster'
        }
      
      if "`model'"~="" {
        noisily cloglog 
        }      

      if "`suppress'"=="suppress" { 
        exit
        }
      }
    
    
    if "`link'"=="probit" {

       if "`specify'"=="" {
         probit _Y `tvars' `if' `in' [`weight' `exp'], nocons `cluster'
         }
        else {
         probit _Y `tvars' `varlist' `if' `in' [`weight' `exp'], nocons `cluster'
         }

       if "`model'"~="" {
         noisily probit
         }
 
       if "`suppress'"=="suppress" { 
         exit
         }
       }
            
*Clean up for constant effect time
    if `tpar'==0 {
      drop _one 
      }
 
*Clean up for n-polynomial time
    if `tpar'>=1 {
      drop `tvars' 
      }

*Clean up for root time
    if `tpar'==-2 {
      drop _one _periodrt 
      }

    }


*******************************************************************************
*At this point this program departs to highly convoluted realms. The basic    *
*strategy is to obtain a representation of estimates for the effect of time at*
*each period of the dataset. How this is done varies depending on the         *
*parameterization of time, but usually involves creating a vector "_Q" holding*
*estimates for each period. The second part of the strategy is the creation of*
*a constant estimate term called "est" which contains the parameter estimates *
*for the constant, pre-specified portion of the model.                        * 
*******************************************************************************


*It all starts with the estimates

  matrix _Q = e(b)


*******************************************************************************
*Discrete-time estimates of time's effect: copy estimates from coeficient     *
*matrix. _Q will be used to describe the period estimates, while _Q2 will     *
*provide the estimates from the estimate's specification.                     *
*******************************************************************************

  if `tpar'==-1 { 
    matrix _Q2 = diag(e(b)) 
    }

*for constant effect of time...

  if `tpar'==0 {
    matrix _Q = e(b)
    matrix _Q2 = diag(_Q)
    }


*******************************************************************************
*The following code generates a number of matrices equal to the order of the  *
*polynomial time parameterization. Each matrix is named PolyTimeXO where X is * 
*the power that the value of period is raised to. These values are then       *
*aggregated for each time period in the matrix _ParameterizedTime which will  *
*be used in the conditional hazard probability calculation.                   *
*******************************************************************************

  if `tpar'>=1 {

*This loop creates the separate matrix for each exponentiation of time
    forvalues npolynum=1/`npoly' {
      local no = 1+`npoly'-`npolynum'
      for num `no': matrix _PolyTimeXO = J(1,`maxl',0)

*This loop creates the values within the exponentiation for each period
      forvalues per=1/`maxl' {

*Replace the placeholder in each period position of PolyTimeXO with the
*appropriate exponentiation of period times the parameter estimate.
        matrix _PolyTime`no'O[1,`per']=(`per'^`no')*el(_Q,1,`npolynum')
        }
      }

*Get collapse the previously arranged matrices into one and loose 'em...
    matrix _ParameterizedTime = J(1,`maxl',0)
    forvalues order=1/`npoly' {
      matrix _ParameterizedTime = _ParameterizedTime + _PolyTime`order'O
      matrix drop _PolyTime`order'O
      }

*Create the matrix _Q2 which holds the model specifications for the constant  *
*term _one plus any predictors in the model.
    local specs = `npoly'+1
      
*Do so by copying the estimates _after_ the terms representing time
    matrix _Q2 = _Q[1,`specs'...]
    matrix _Q2 = diag(_Q2)

    }

*******************************************************************************
*For root parameterizations of time Matrix _Root holds the estimates for      *
*linearly parameterized time for each period. _Toor is _Root reversed... If   *
*this looks wierd, you ought to have seen the code before I wrote the above   *
*bit of prettiness for n-polynomial representation...                         *
*******************************************************************************

  if `tpar'==-2 {

*Create linear time vector
    forvalues x=2/`maxl' {
      local place = (`x')*el(_Q,1,2)
      if `x'==2 {
        matrix _Linear = (`place')
        matrix _Raenil = _Linear
        }
       else {
        matrix _Linear = (`place'),_Linear
        matrix _Raenil = _Raenil,(`place')
        }
      }
    local place = el(_Q,1,2)
    matrix _Raenil = (`place'),_Raenil

*Create root time vector
    forvalues x=1/`maxl' {
      local place = ((`x')^.5)*el(_Q,1,1)
      if `x'==1 {
        matrix _Root = (`place')
        matrix _Toor = _Root
        }
       else {
        matrix _Root = (`place'),_Root
        matrix _Toor = _Toor,(`place')
        }
      }

*At this point _Q is B_psq B_p B_one B_predictors... We need to get rid of the 
*B_sq term, so:
    local bark = (`argnum'+3)
    forvalues x=2/`bark' {
      local sploof = el(_Q,1,`x')
      if `x'==2 {
        matrix _Blar = (`sploof')
        }
       else {
        matrix _Blar = _Blar,(`sploof')
        }
      }
    matrix _Q = _Blar
      
    matrix _Q2 = _Root,_Linear,_Q
    matrix _Q2 = diag(_Q2)
    matrix drop _Blar _Linear _Root
    }


*******************************************************************************
*_Q2 contains the parameter*specified variable values for the estimate at hand*
*******************************************************************************

  matrix _Q2 = _Q2*_Spec

*******************************************************************************
*est contains the actual quantity employed in adjusting the calculation of    *
*hazard. The wierdness in producing the estimates for root-represented time is*
*apparent in the need to clean up for it especially here.                     *
*******************************************************************************

  if `tpar'>=-1 {
    local est = trace(_Q2) 
    }

  if `tpar'==-2 {
    local est = trace(_Q2)
    matrix _Q = _Toor,_Raenil
    matrix drop _Toor _Raenil
    }


*******************************************************************************
*Into the home stretch. Matrix _Hazard will be created and populated using    *
*some variation of the basic algorithm.                                       *
*******************************************************************************

*Generate hazard matrix, with a non-calculated 0th period

  matrix _Hazard = (0, 0)


*The following bit of flow-control limits the number of periods displayed if  
*the user asked for it with the display option

  if (`display'>0 & `display'<`maxl') {
    local maxl=`display'
    local newobs=`maxl'+1
    }

*Set the number of coeficients from the estimate matrix and specification matrix

*Hazard probabilities

  forvalues num=1/`maxl' {

    *for fully discrete and _Linear time
    if `tpar'==-1 {
      local specest = el(_Q,1,`num')+`est'
      }

    *for constant effect of time
    if `tpar'==0 {
      local specest = `est'
      }

    *for root time
    if `tpar'==-2 {
      local lin = `num'+`maxl'
      local specest = el(_Q,1,`num')+el(_Q,1,`lin')+`est'
      }

    *for polynomial time
    if `tpar'>=1 {
      local specest = el(_ParameterizedTime,1,`num')+`est'
      }

    if "`link'"=="logit" {
      local haz = 1/(1+(exp(-1*(`specest'))))
      }      
    if "`link'"=="cloglog" {
      local haz = 1-(exp(-1*exp(`specest'))) 
      }
    if "`link'"=="probit" {
      local haz = normal(`specest')
      }      
    matrix _Period = (`num',`haz')
    matrix _Hazard = _Hazard\_Period
    }


*Produce survival probabilities and append to _Hazard
  forvalues num=1/`newobs' {
    if `num'==1 {
      local lastsur = 1
      matrix _Survival = (1)
      }
     else {
      local back = `num'-1
      local lastsur = el(_Survival,`back',1)
      }
    local haz = el(_Hazard,`num',2)
    local sur = (1-`haz')*(`lastsur')
    matrix _Period = (`sur')
    if `num'==1 {
      }
     else {
      matrix _Survival = _Survival\_Period
      }
    }

  
*Produce standard errors for h_t and S_t

  local q          = e(df_m)
  matrix _sigma_h  = vecdiag(I(`maxl'))
  matrix _sigma_Sa = vecdiag(I(`maxl'))    
  matrix _sigma_Sb = vecdiag(I(`maxl'))
  matrix _sigma_S  = vecdiag(I(`maxl'))
  matrix betas     = e(b)
  matrix V         = e(V)
  forvalues t=1/`maxl' {
    if `tpar' == -2 {
      matrix Z = (`t'^.5, `t', 1)
      }
    if `tpar' == -1 {
      matrix Z = I(`maxl')
      matrix Z = Z[`t',1..`maxl']
      }
    if `tpar' == 0 {
      matrix Z = (1)
      }
    if `tpar' >0 {
      matrix Z = (1)
      forvalues polynomial=1/`tpar' {
        matrix Z = `t'^`polynomial',Z
        }
      } 
    if "`specify'" ~= "" {
      tokenize `specify'
      foreach specification in `*' {
        matrix Z = Z,(`specification')
        }
      }
    local lZ = colsof(betas)
    matrix bZ = Z
    forvalues i=1/`lZ' {
      matrix bZ[1,`i'] = betas[1,`i']*Z[1,`i']
      } 
    if "`link'"=="logit" {
      matrix _sigma_h[1,`t'] = ( trace(( ((exp( trace(diag(bZ)) ))/((1+exp( trace(diag(bZ)) ))^2))^2 * Z*V*(Z')) )^.5)
      matrix _sigma_Sa[1,`t'] = ( trace( ((exp( trace(diag(bZ)) ))/(1+exp( trace(diag(bZ)) )))^2 * Z*V*(Z')) )
      matrix _sigma_Sb[1,`t'] = (1/(1 + exp( trace(diag(bZ)) )))
      }
    if "`link'"=="cloglog" {
      matrix _sigma_h[1,`t'] = ( trace(( ( exp( trace(diag(bZ)) - exp(trace(diag(bZ))) ) )^2 * Z*V*(Z')) )^.5)
      matrix _sigma_Sa[1,`t'] = ( trace( ( exp(trace(diag(bZ)) ) )^2 * Z*V*(Z'))  )
      matrix _sigma_Sb[1,`t'] = exp( -exp( trace(diag(bZ)) ) )
      }
    if "`link'"=="probit" {
      matrix _sigma_h[1,`t'] = ( trace(( ( (1/sqrt(2*_pi))*exp((-(trace(diag(bZ))^2))/(2)) )^2 * Z*V*(Z')) )^.5)
      matrix _sigma_Sa[1,`t'] = ( trace( ( ((1/sqrt(2*_pi))*exp((-(trace(diag(bZ))^2))/(2))) / (1-normal(trace(diag(bZ)))) )^2 * Z*V*(Z'))  )
      matrix _sigma_Sb[1,`t'] = 1 - normal(trace(diag(bZ)))
      }      
    if `t' > 1 {
      matrix _sigma_Sa[1,`t'] = (_sigma_Sa[1,`t'] + _sigma_Sa[1,(`t'-1)])
      matrix _sigma_Sb[1,`t'] = (_sigma_Sb[1,`t'] * _sigma_Sb[1,(`t'-1)])
      }
    matrix _sigma_S[1,`t'] = ( (_sigma_Sa[1,`t']*((_sigma_Sb[1,`t'])^2))^.5 )
    }

  matrix _sigma_h = (0),_sigma_h
  matrix _sigma_S = (0),_sigma_S
  matrix _Hazard = _Hazard,_Survival,(_sigma_h'),(_sigma_S')
  matname _Hazard Period Hazard Survival sigma_h sigma_S, columns(1...) explicit
  }


*******************************************************************************
*Final bit of output: display results to user                                 *
*******************************************************************************

 if "`suppress'"=="" {
   noisily {

     di _newline
     di as txt "-------------------------------------------------------------"
     di   as txt _col(4) "Period" _col(16) "p(Hazard)" _col(28) "Std. Err.  " _col(39) "p(Survival)" _col(52) "Std. Err.  "
     di   as txt _col(4) " (t)" _col(16) " ^h(t)" _col(28) " ^h(t)" _col(39) " ^S(t)" _col(52) " ^S(t)"
     di as txt "-------------------------------------------------------------"
     di  as result _col(6) "0" _col(19) "--" _col(31) "--" _col(39) " 1" _col(52) " 0" as result
     forvalues i=2/`newobs' {
       display  as result _col(6) el(_Hazard,`i',1) _col(16) %10.7f el(_Hazard,`i',2) _col(28) %10.7f el(_Hazard,`i',4) _col(39) %10.7f el(_Hazard,`i',3) _col(52) %10.7f el(_Hazard,`i',5) as result
       }
     di as txt "-------------------------------------------------------------"

  *Note estimation assumptions

     if "`link'"=="logit" {
       di as txt "Logit Link (assumes proportional odds)" 
       }
     if "`link'"=="cloglog" {
       di as txt "Complementary Log-Log Link (assumes proportional hazards)" 
       }
     if "`link'"=="probit" {
       di as txt "Probit Link (assumes proportional probits)" 
       }
     }
   }

quietly {


*******************************************************************************
*Clean this mess on up!                                                       *
*******************************************************************************

*Drop that which must be dropped
  matrix drop _One _Period _Q _Q2 _Spec _Survival 
  if `tpar'==-2 | `tpar'==-1 {
    matrix drop _Zero 
    }
  if `tpar'>=1 {
    matrix drop _ParameterizedTime 
    }
 

*******************************************************************************
*Graph some output!                                                           *
*******************************************************************************

 restore, preserve

 svmat _Hazard, names(col)


*Generate cumulative incidence
    gen InvSurvival = 1 - Survival


*Generate upper and lower bounds for Hazard
    gen Hub = Hazard+(invnormal(1-((1-(`level'/100))/2))*sigma_h) if Period > 0
    replace Hub = 1 if Hub > 1 & Period > 0
    gen Hlb = Hazard-(invnormal(1-((1-(`level'/100))/2))*sigma_h) if Period > 0
    replace Hlb = 0 if Hlb < 0 & Period > 0


*Generate upper and lower bounds for Survival
    gen Sub = Survival+(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Sub = 1 if Sub > 1 & Period > 0
    gen Slb = Survival-(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Slb = 0 if Slb < 0 & Period > 0


*Generate upper and lower bounds for cumulative incidence
    gen Cub = InvSurvival+(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Cub = 1 if Cub > 1 & Period > 0
    gen Clb = InvSurvival-(invnormal(1-((1-(`level'/100))/2))*sigma_S) if Period > 0
    replace Clb = 0 if Clb < 0 & Period > 0

    set more on

*Manage graphing options input for all graphs

    if `graph'>4 | `graph'<1 {
      local `graph'=0 
      } 

    if `"`b1title'"'==`""' {
      local b1title = `"b1title("Period")"'
      }
     else {
      local b1title = `"b1title(`b1title')"'
      }  

    if "`ytick'"=="" {
      local ytick "yt(0(.2)1)" 
      }
     else {
      local ytick "yt(`ytick')" 
      }

    if "`ylabel'"=="" {
      local ylabel "yla(0(.2)1)" 
      }
     else {
      local ylabel "ylabel(`ylabel')" 
      }

*Graph conditional hazard probabilities
    if `graph'==1 {

*Deal with axes specific to conditional hazard curves
      if "`xtick'"=="" {
        local xtick "xt(1(1)`maxl')" 
        }
       else {
        local xtick "xs(`xtick')" 
        }
	  if "`xlabel'"=="" {
	    local xlabel "xla(1(1)`maxl')" 
        }
       else {
        local xlabel "xlabel(`xlabel')" 
        }
      if `"`l1title'"'==`""' {
        local l1title = `"l1title("Estimated Conditional Hazard Probability")"'
        }
       else {
        local l1title = `"l1title(`l1title')"'
        }
     
      gr Hazard Period if Period~=0, `ytick' `ylabel' `l1title' `xtick' `xlabel' `b1title' title("Hazard Curve: conditional hazard probability vs. period") connect(l) `options'

      }
   
*Graph survival probabilities
    if `graph'==2 | `graph'==4 {

*Deal with axes specific to survival curves
      if "`xtick'"=="" {
        local xtick = "xt(0(1)`maxl')" 
        }
       else {
        local xtick = "xt(`xtick')" 
        }
	  if "`xlabel'"=="" {
	    local xlabel = "xla(0(1)`maxl')" 
        }
       else {
        local xlabel = "xlabel(`xlabel')" 
        }
      if `"`l1title'"'==`""' {
        if `graph' == 2 {
          local l1title = `"l1title("Estimated Survival Probability")"'
          }
        if `graph' == 4 {
          local l1title = `"l1title("Estimated Cumulative Event Probability")"'
          }
        }
       else {
        local l1title = `"l1title(`l1title')"'
        }


      gen InvSurvival = 1 - Survival
      if `graph' == 2 {
        gr Survival Period, `ytick' `ylabel' `l1title' `xtick' `xlabel' `b1title' title("Survival Curve: survival probability vs. period") connect(l) `options'      
        }
      if `graph' == 4 {
        gr InvSurvival Period, `ytick' `ylabel' `l1title' `xtick' `xlabel' `b1title' title("Cumulative Event Curve: cumulative event probability vs. period") connect(l) `options'      
        }

      }

*Graph both conditional hazard and survival probabilities
    if `graph'==3 {
   
*Prepare for different x-axis labeling needs for hazard and survival
    local tempxt = "`xtick'"
    local tempxla = "`xlabel'"
    local tempytitle = "`ytitle'"
    
    if "`xtick'"=="" {
      local xtick = "xt(1(1)`maxl')" 
      }
     else {
      local xtick = "xt(`xtick')" 
      }
	if "`xlabel'"=="" {
	  local xlabel = "xla(1(1)`maxl')" 
	  }
     else {
      local xlabel = "xlabel(`xlabel')" 
      }
    if "`l1title'"=="" {
      local l1title = `"l1title("Estimated Conditional Hazard Probability")"' 
      }
     else {
      local l1title = "l1title(`l1title')"
      }

    gr Hazard Period if Period~=0, `ytick' `ylabel' `l1title' `xtick' `xlabel' `b1title' title("Hazard Curve: conditional hazard probability vs. period") connect(l) `options'

    local xtick = "`tempxt'"
    local xlabel = "`tempxla'"
    local ytitle = "`tempytitle'"
    if "`xtick'"=="" {
      local xtick = "xt(0(1)`maxl')" 
      }
     else {
      local xtick = "xt(`xtick')"
      }
	if "`xlabel'"=="" {
	  local xlabel = "xla(0(1)`maxl')" 
	  }
     else {
      local xlabel = "xlabel(`xlabel')" 
      }
    if `"`l1title'"'==`""' {
      local l1title = `"l1title("Estimated Survival Probability")"'
      }
     else {
      local l1title = `"l1title(`l1title')"'
      }

    gr Survival Period,  `ytick' `ylabel' `t1title' `xtick' `xlabel' `b1title' title("Survival Curve: estimated survival probability vs. period") connect(l) `options'
    
    }

   restore, preserve 
 
 
*******************************************************************************
*Say goodbye to the nice user!                                                *
*******************************************************************************


 *Retain _Hazard for user...
  ereturn matrix SurvivalSE = _Hazard[1..`maxl',2]
  ereturn matrix Survival   = _Hazard[1..`maxl',4]
  ereturn matrix HazardSE   = _Hazard[1..`maxl',3]

  ereturn matrix Hazard     = _Hazard[1..`maxl',5]
  return clear


 * clean up
 matrix drop _Hazard _sigma_S _sigma_h V betas _sigma_Sb _sigma_Sa
 }
end

