*! version 1.0 11June2016
*! author: Demetris Christodoulou
version 10

program define optaspect, rclass

syntax varlist(ts numeric min=2 max=2)    /// Two variables (y,x); no factor variables
       [if] [in] [aw fw pw iw]            /// qualifiers and weights
       ,                                  ///
       [                                  ///
       sort                               /// sort on x
       rank                               /// replace x with t, where sum{t}=n
       CULLzero                           /// Remove slopes=0
       STACKby(varname)                   /// split-and-stack long series
       y0                                 /// baseline zero in y 
       GOR                                /// calculate GOR criterion
       LOR                                /// calculate LOR criterion
       WLC                                /// calculate WLC criterion
       ITERate(integer 100)               /// default iter low to exit optimize quickly in case of non-convergence
       TOLerance(real 1e-6)               /// convergence precision default set low
       ]

// [if] [in] qualifiers: mark estimation sample e(sample) 
marksample touse
markout `touse' `varlist'

// y and x variables
gettoken y x: varlist   // only 2 variables allowed in varlist


****************************
**** OPTIONS and ERRORS **** 
****************************


// check that dataset is sorted on x
cap assert `x'[_n]-`x'[_n-1]>= 0 in 2/L if `touse' // check that the dataset is sorted on x
if _rc & "`sort'"=="" {
   di in err "Must sort dataset on x variable - use option " as res "sort"
   error 5
}
if "`sort'"!="" {
   sort `x'
}

// Use the deterministic trend as x
if "`rank'"!="" {
   tempvar rankvar
   generate `rankvar' = _n
   local x `rankvar'
}

// Range of y and x before first differences because touse will change the range
mata {
   st_view(y=.,  ., st_local("y"), st_local("touse"))
   st_view(x=.,  ., st_local("x"), st_local("touse"))

   if ("`y0'"!="") Ry = max(y)
   else            Ry = max(y)-min(y)
   Rx = max(x)-min(x)
}

// First differences
tempvar dy dx
qui generate `dy' = `y'[_n] - `y'[_n-1]
qui generate `dx' = `x'[_n] - `x'[_n-1]
markout `touse' `dy' `dx'

// No infinite slopes that are set to missing
tempvar infsl
qui generate `infsl' = `dy'/`dx'
qui count if `touse' & `infsl'==.
local noinfsl = r(N)
markout `touse' `infsl'

// converge local to scalar to enter as arguments to optimize
tempname sc_ite sc_tol
scalar `sc_ite' = `iterate'
scalar `sc_tol' = `tolerance'

// Option cullzero
tempname cullvarno
if "`cullzero'"!="" {
   tempvar cullvar
   qui generate `cullvar' = 1 if abs(`dy' / `dx') > 0  ///
                               & abs(`dy' / `dx') < .  & `touse'
   qui count if `cullvar'!=1 & `touse'
   scalar `cullvarno' = r(N)
   markout `touse' `cullvar'
}
else {
   qui count if !(abs(`dy' / `dx') > 0 & abs(`dy' / `dx') < .) & `touse'
   scalar `cullvarno' = r(N) // minus the one lost due to first differencing
}

// Option stackby
if "`stackby'"!="" {
   tempvar stackvar
   qui egen `stackvar' = group(`stackby')
   qui levelsof `stackvar', local(stacklevels)
}
else {
   local stacklevels = 1
   tempvar stackvar
   qui gen `stackvar' = `stacklevels'
}

// options GOR and LOR
if "`gor'"=="" mata: gorin = 0
if "`gor'"!="" mata: gorin = 1

if "`lor'"=="" mata: lorin = 0
if "`lor'"!="" mata: lorin = 1

if "`wlc'"=="" mata: wlcin = 0
if "`wlc'"!="" mata: wlcin = 1

if ("`lor'"!="" | "`gor'"!="") & "`cullzero'"=="" & `cullvarno'>0 {
   di in err "There are zero slopes in the data. " _c
   di in err "Must specify " as res "cullzero " _c
   di in err "together with " as res "lor " as err "and " as res "gor "
   error
}

********************
**** ESTIMATION **** 
********************


mata { // initialise scalars for calcuting the average over stacklevels
   mas  = 0
   aas  = 0
   aao  = 0
   waao = 0
   rv   = 0
   lor  = 0
   gor  = 0
   arc  = 0
   wlc  = 0
}

foreach i of local stacklevels {
   preserve
   qui keep if `stackvar'==`i'

  // Calculate dyd, dxd, slopes, weight
  mata {
     st_view(dy=., ., st_local("dy"), st_local("touse"))
     st_view(dx=., ., st_local("dx"), st_local("touse"))

     sl  = J(rows(dy), 1, .)
     dyd = J(rows(dy), 1, .)
     dxd = J(rows(dy), 1, .)

     sl  = abs(dy:/dx)   // absolute slopes for mas, aas
     dyd = abs(dy:/Ry)   // for aao, waao
     dxd = abs(dx:/Rx)   // for aao, waao

     n = colnonmissing(sl)                 // number of slope observations
     st_numscalar("sc_obs",rows(sl))

     r = (pi()*45/180)                     // 45 degrees in radiants, same as atan(1)
  }


  // MAS criterion (Cleveland, McGill and McGill 1988)
  mata {
     sl_sort = sort(abs(sl),1)
     if (colmissing(sl_sort)>0) sl_sort = sl_sort[(1::colnonmissing(sl_sort)), .]
     if (mod(colnonmissing(sl_sort),2)==1) sl_median = sl_sort[colnonmissing(sl_sort)/2+.5]
     else sl_median = (sl_sort[colnonmissing(sl_sort)/2] + sl_sort[colnonmissing(sl_sort)/2+1])/2 
     mas = mas + (1/sl_median)*(Ry/Rx)
     st_numscalar("g_mas",mean(mas))
  }


  // AAS criterion (Heer and Agrawala 2006)
  mata {
     sl_mean = mean(abs(sl))
     aas = aas + (1/sl_mean)*(Ry/Rx)
     st_numscalar("g_aas",mean(aas))
  }


  // WAAO (Cleveland 1993)
  mata {
     c = (r)
     S = optimize_init()                   // S handle for defining the opt problem
     optimize_init_evaluator(S, &waao())
     optimize_init_evaluatortype(S, "d0") // todo=0 evaluator, just calc. v=f(p)
     optimize_init_which(S,"min")          // minimize the difference between obj.function and r

     optimize_init_params(S, 1)            // initialise using naive aspect ratio
     optimize_init_argument(S, 1, c)       // pass c to aao
     optimize_init_argument(S, 2, dyd)
     optimize_init_argument(S, 3, dxd)

     optimize_init_technique(S,"nr")       // modified Newton-Raphson
     optimize_init_conv_maxiter(S,  st_numscalar(st_local("sc_ite")))  // maximum iterations to limit
  
     optimize_init_conv_warning(S, "off")  // switch off non-convergence message
     optimize_init_verbose(S, 0)           // suppress all error messages
     optimize_init_tracelevel(S,"none")
     optimize_init_conv_ptol(S, st_numscalar(st_local("sc_tol")))
     optimize_init_conv_vtol(S, st_numscalar(st_local("sc_tol")))

     p = optimize(S)                       // find the p that minimizes v=f(p)
     waao = waao + exp(p)
     st_numscalar("g_waao",mean(waao))
  }


  // AAO (Cleveland 1993)
  mata {
     c = (r)
     S = optimize_init()                   // S handle for defining the opt problem
     optimize_init_evaluator(S, &aao())
     optimize_init_evaluatortype(S, "d0") // todo=0 evaluator, just calc. v=f(p)
     optimize_init_which(S,"min")          // minimize the difference between obj.function and r

     optimize_init_params(S, 1)            // initialise using naive aspect ratio
     optimize_init_argument(S, 1, c)       // pass c to aao
     optimize_init_argument(S, 2, dyd)     // pass dyd to aao
     optimize_init_argument(S, 3, dxd)     // pass dxd to aao

     optimize_init_technique(S,"nr")       // modified Newton-Raphson
     optimize_init_conv_maxiter(S, st_numscalar(st_local("sc_ite")))  // maximum iterations to limit
  
     optimize_init_conv_warning(S, "off")  // switch off non-convergence message
     optimize_init_verbose(S, 0)           // suppress all error messages
     optimize_init_tracelevel(S,"none")
     optimize_init_conv_ptol(S, st_numscalar(st_local("sc_tol")))
     optimize_init_conv_vtol(S, st_numscalar(st_local("sc_tol")))

     p = optimize(S)                       // find the p that minimizes v=f(p)
     aao = aao + exp(p)
     st_numscalar("g_aao",mean(aao))
  }

  
  // RESULTANT VECTOR criterion (Guha and Cleveland 2011)
  mata {
     sum_dy = quadcolsum(abs(dy))
     sum_dx = quadcolsum(abs(dx))
     rv = rv + ( (Ry/sum_dy) / (Rx/sum_dx) )
     st_numscalar("g_rv",mean(rv))
  }

  // ARC LENGTH criterion (Talbot, Gerth, Hanrahan 2011)
  mata {
     S = optimize_init()                   // S handle for defining the opt problem
     optimize_init_evaluator(S, &arclength()) 
     optimize_init_evaluatortype(S, "d0") // todo=0 evaluator, just calculate v=f(p)
     optimize_init_which(S,"min")          // minimize objective function v
 
     optimize_init_params(S, 1)            // initialise using naive aspect ratio
     optimize_init_argument(S, 1, dy)
     optimize_init_argument(S, 2, dx)

     optimize_init_technique(S,"nr")       // modified Newton-Raphson
     optimize_init_conv_maxiter(S, st_numscalar(st_local("sc_ite")))  // maximum iterations to limit

     optimize_init_conv_warning(S, "off")  // switch off non-convergence message
     optimize_init_verbose(S, 0)           // suppress all error messages
     optimize_init_tracelevel(S,"none")
     optimize_init_conv_ptol(S, st_numscalar(st_local("sc_tol")))
     optimize_init_conv_vtol(S, st_numscalar(st_local("sc_tol")))

     p = optimize(S)                       // find the p that minimizes v=f(p)
     arc = arc + exp(p)
     st_numscalar("g_arc",mean(arc))
  }


  // GLOBAL ORIENTATION RESOLUTION criterion (Heer and Agrawala 2006)
  mata {
     id = J(rows(dy)*(rows(dy)-1),1,0) // n*(n-1) combinations of slopes
     si = J(rows(dy)*(rows(dy)-1),1,0)
     sj = J(rows(dy)*(rows(dy)-1),1,0)

     k = 0
     for(i=1; i<=rows(dy); i++) {  // n*(n-1) pairs of slopes
        for(j=1; j<=rows(dy); j++) {
           if (i!=j) {
              k=k+1
              id[k] = i
              si[k] = abs(dy[i] / dx[i])
              sj[k] = abs(dy[j] / dx[j]) ; 
           }
        }
     }

     info = panelsetup(id, 1) // treat i_th slopes as panels, and j_th slopes as within panel obs

     if (gorin==1) {
      S = optimize_init()                   // S handle for defining the opt problem
      optimize_init_evaluator(S, &gor()) 
      optimize_init_evaluatortype(S, "d0") // todo=0 evaluator, just calculate v=f(p)
      optimize_init_which(S,"max")          // minimize objective function v
 
      optimize_init_params(S, 1)            // initialise using naive aspect ratio
      optimize_init_argument(S, 1, info)
      optimize_init_argument(S, 2, si)
      optimize_init_argument(S, 3, sj)

      optimize_init_technique(S,"nr")       // modified Newton-Raphson
      optimize_init_conv_maxiter(S, st_numscalar(st_local("sc_ite")))  // maximum iterations to limit

      optimize_init_conv_warning(S, "off")  // switch off non-convergence message
      optimize_init_verbose(S, 0)           // suppress all error messages
      optimize_init_tracelevel(S,"none")
      optimize_init_conv_ptol(S, st_numscalar(st_local("sc_tol")))
      optimize_init_conv_vtol(S, st_numscalar(st_local("sc_tol")))

      p = optimize(S)                          // find the p that minimizes v=f(p)
      gor = gor + exp(p)
      st_numscalar("g_gor",mean(gor))
     } ;
  }

  
  // LOCAL ORIENTATION RESOLUTION criterion (Heer and Agrawala 2006)
  mata {
     if (lorin==1) {
      S = optimize_init()                   // S handle for defining the opt problem
      optimize_init_evaluator(S, &lor()) 
      optimize_init_evaluatortype(S, "d0") // todo=0 evaluator, just calculate v=f(p)
      optimize_init_which(S,"max")          // minimize objective function v
     
      optimize_init_params(S, 1)            // initialise using naive aspect ratio
      optimize_init_argument(S, 1, sl)
   
      optimize_init_technique(S,"nr")       // modified Newton-Raphson
      optimize_init_conv_maxiter(S, st_numscalar(st_local("sc_ite")))  // maximum iterations to limit

      optimize_init_conv_warning(S, "off")  // switch off non-convergence message
      optimize_init_verbose(S, 0)           // suppress all error messages
      optimize_init_tracelevel(S,"none")
      optimize_init_conv_ptol(S, st_numscalar(st_local("sc_tol")))
      optimize_init_conv_vtol(S, st_numscalar(st_local("sc_tol")))

      p = optimize(S)                          // find the p that minimizes v=f(p)
      lor = lor + exp(p)
      st_numscalar("g_lor",mean(lor))
     } ;
  }


  // WEIGHTED LOCAL CURVATURE criterion (Han, Wang, Zhang, Deussen, Chen 2015)
  mata {
     if (wlcin==1) {
      S = optimize_init()                   // S handle for defining the opt problem
      optimize_init_evaluator(S, &wlc()) 
      optimize_init_evaluatortype(S, "d0") // todo=0 evaluator, just calculate v=f(p)
      optimize_init_which(S,"max")          // minimize objective function v
     
      optimize_init_params(S, 1)            // initialise using naive aspect ratio
      optimize_init_argument(S, 1, sl)
   
      optimize_init_technique(S,"nr")       // modified Newton-Raphson
      optimize_init_conv_maxiter(S, st_numscalar(st_local("sc_ite")))  // maximum iterations to limit

      optimize_init_conv_warning(S, "off")  // switch off non-convergence message
      optimize_init_verbose(S, 0)           // suppress all error messages
      optimize_init_tracelevel(S,"none")
      optimize_init_conv_ptol(S, st_numscalar(st_local("sc_tol")))
      optimize_init_conv_vtol(S, st_numscalar(st_local("sc_tol")))

      p = optimize(S)                          // find the p that minimizes v=f(p)
      wlc = wlc + exp(p)
      st_numscalar("g_wlc",mean(wlc))
     } ;
  }


  restore
} // end forvalues i = 1/stacklevels


********************
**** REPORT **** 
********************


n di as txt "{c TLC}{hline 47}{c TT}{hline 15}{c TRC}"
n di as txt "{c |}{col 11}Aspect ratio criterion{col 49}{c |}{col 54}aspect(#){col 65}{c |}"
n di as txt "{c LT}{hline 47}{c +}{hline 15}{c RT}"
n di as txt "{c |} " as res "Median Absolute Slope" as txt "{col 49}{c |}" _c
n di as res "{center 15:{lalign 13: `:di %9.4f `=g_mas''}}" as txt "{col 49}{c |}"
n di as txt "{c |} " as res "   {it:Compare to} Average Absolute Slope" as txt "{col 49}{c |}" _c
n di as res "{center 15:{lalign 13: `:di %9.4f `=g_aas''}}" as txt "{col 49}{c |}"
n di as txt "{c |} " as res "Weighted Average Absolute Orientation" as txt "{col 49}{c |}" _c
n di as res "{center 15:{lalign 13: `:di %9.4f `=g_waao''}}" as txt "{col 49}{c |}"
n di as txt "{c |} " as res "   {it:Compare to} Average Absolute Orientation" as txt "{col 49}{c |}" _c
n di as res "{center 15:{lalign 13: `:di %9.4f `=g_aao''}}" as txt "{col 49}{c |}"
n di as txt "{c |} " as res "Arc Length based" as txt "{col 49}{c |}" _c
n di as res "{center 15:{lalign 13: `:di %9.4f `=g_arc''}}" as txt "{col 49}{c |}"
if "`gor'"!="" {
   n di as txt "{c |} " as res "Global Orientation Resolution" as txt "{col 49}{c |}" _c
   n di as res "{center 15:{lalign 13: `:di %9.4f `=g_gor''}}" as txt "{col 49}{c |}"
}
if "`lor'"!="" {
   n di as txt "{c |} " as res "Local Orientation Resolution" as txt "{col 49}{c |}" _c
   n di as res "{center 15:{lalign 13: `:di %9.4f `=g_lor''}}" as txt "{col 49}{c |}"
}
if "`wlc'"!="" {
   n di as txt "{c |} " as res "Weighted Local Curvature" as txt "{col 49}{c |}" _c
   n di as res "{center 15:{lalign 13: `:di %9.4f `=g_wlc''}}" as txt "{col 49}{c |}"
}
n di as txt "{c |} " as res "Resultant Vector" as txt "{col 49}{c |}" _c
n di as res "{center 15:{lalign 13: `:di %9.4f `=g_rv''}}" as txt "{col 49}{c |}"
n di as txt "{c BLC}{hline 47}{c BT}{hline 15}{c BRC}"
// complete output tabular report
if "`cullzero'"!="" & `noinfsl'==0 {
   di as txt "{col 2}Note: " `cullvarno' " zero slopes have been culled"
}
if "`cullzero'"!="" & `noinfsl'>0 {
   di as txt "{col 2}Note: `noinfsl' infinity slopes are discarded. " `cullvarno' " zero slopes have been culled"
}
if "`cullzero'"=="" & `cullvarno'>0 & `noinfsl'==0 {
   di as txt "{col 2}Note: There are " `cullvarno' " zero slopes; consider option " as res "cull"
}
if "`cullzero'"=="" & `cullvarno'>0 & `noinfsl'>0 {
   di as txt "{col 2}Note: `noinfsl' infinity slopes are discarded. There are " `cullvarno' " zero slopes; consider option " as res "cull"
}

***********************
**** SAVED RESULTS ****
***********************


return clear
return scalar n = sc_obs
foreach i in mas aas aao waao arc rv {
   return scalar `i' = g_`i'
}
if "`gor'"!="" return scalar gor = g_gor
if "`lor'"!="" return scalar lor = g_lor
if "`wlc'"!="" return scalar wlc = g_wlc

if "`cullzero'"!="" {
   return scalar culled = `cullvarno'
}

end  // end program optaspect


***************
**** MATA  **** 
***************


// set optimize() to minimize (f(x)-c)^2 which is the same as finding a root of f(x)-c 

// WAAO (Cleveland 1993)
mata :
void waao(todo, p, c, dyd, dxd, v, g, H)
   {
    r = c[1]
    a = exp(p[1]) // restrict aspect ratio to positive

    theta  = atan(a:*dyd:/dxd)
    length = sqrt(dxd:^2 :+ a^2 :* dyd:^2)
    v = (mean(theta,length) - r)^2  // weighted mean
   }
end


// AAO (Cleveland 1993)
mata :
void aao(todo, p, c, dyd, dxd, v, g, H)
   {
    r = c[1]
    a = exp(p[1])

    theta = atan(a:*dyd:/dxd)
    v = (mean(theta) - r)^2         // unweighted mean
   }
end


// ARC LENGTH criterion (Talbot, Gerth, Hanrahan 2011)
mata :
void arclength(todo, p, dy, dx, v, g, H)
   {
    a = exp(p[1])

    // Sum of all Euclidean lengths: Sum{sqrt((x2-x1)^2+(y2-y1)^2)}
    v = quadcolsum(sqrt( (dx:/sqrt(a)):^2 + (dy:*sqrt(a)):^2 ), 1)
   }
end


// GLOBAL ORIENTATION RESOLUTION criterion (Heer and Agrawala 2006)
mata : 
void gor(todo, p, info, si, sj, v, g, H)
   {
    a = exp(p[1])

    sum_ij = J(rows(info),1,0)
    min2   = J(2,1,0)

    for (i=1; i<=rows(info); i++) {
         min2[1] = quadcolsum(panelsubmatrix(abs(atan(a:*si):-atan(a:*sj)), i, info ), 1)
         min2[2] = pi() - quadcolsum(panelsubmatrix(abs(atan(a:*si):-atan(a:*sj)), i, info ), 1)
         sum_ij[i] = colmin(min2)^2  // get smallest angle
    }
    v = quadcolsum(sum_ij,1)
   }
end


// LOGAL ORIENTATION RESOLUTION criterion (Heer and Agrawala 2006)
mata :
void lor(todo, p, sl, v, g, H)
   {
    a = exp(p[1])

    sum_ij = J(rows(sl),1,0)
    min2   = J(2,1,0)

    for (i=2; i<=rows(sl); i++) {
         min2[1] = (atan(a*sl[i]) - atan(a*sl[i-1]))^2
         min2[2] = (pi() - abs(atan(a*sl[i]) - atan(a*sl[i-1])))^2
         sum_ij[i] = colmin(min2)  // get smallest angle
    }
    v = quadcolsum(sum_ij,1)

   }
end


// WLC criterion (Han, Wang, Zhang, Deussen, Chen 2015)
mata :
void wlc(todo, p, sl, v, g, H)
   {
    a = exp(p[1])

    sum_ij = J(rows(sl),1,0)
    min2   = J(2,1,0)

    for (i=2; i<=rows(sl); i++) {
         min2[1] = abs( atan(a*sl[i]) - atan(a*sl[i-1]) )
         min2[2] = (pi() - abs( atan(a*sl[i]) - atan(a*sl[i-1]) ))
         sum_ij[i] = colmin(min2)  // get smallest angle
    }
    v = quadcolsum(sum_ij,1)
   }
end


*********************

exit // exit ado-file
