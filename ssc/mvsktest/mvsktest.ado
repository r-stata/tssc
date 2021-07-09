*! Mardia's (1970) multivariate skewness and kurtosis, v.1.0 by Stas Kolenikov
program define mvsktest
  version 9
  syntax varlist [if] [in]

  preserve
  unab varlist : `varlist'
  tokenize `varlist'

  marksample touse

  * covariance matrix
  tempname S Sinv N
  qui mat accum `S' = `varlist' if `touse' , dev nocons
  scalar `N' = r(N)
  mat `S' = `S'/( `N'-1 )
  mat `Sinv' = invsym(`S')


  * preliminary work
  local p : word count `varlist'

  * center the variables
  forvalues i=1/`p' {
     tempvar x`i'
     local clist `clist' `x`i''
     sum ``i'' if `touse', meanonly
     qui gen double `x`i'' = ``i''-r(mean) if `touse'
  }

  *** multivariate skewness
  * computing the third moments of data
  tempvar m
  qui gen double `m' = .
  forvalues r=1/`p' {
    forvalues s=1/`p' {
      forvalues t=1/`p' {
        tempname M_`r'_`s'_`t'
        qui replace `m' = `x`r'' * `x`s'' * `x`t'' if `touse'
        sum `m' if `touse', meanonly
        scalar `M_`r'_`s'_`t'' = r(mean)
      }
    }
  }

  * computing b_1,p
  tempname b1p
  scalar `b1p'=0
  forvalues r=1/`p' {
    forvalues s=1/`p' {
      forvalues t=1/`p' {
        forvalues u=1/`p' {
          forvalues v=1/`p' {
            forvalues w=1/`p' {
              scalar `b1p' = `b1p' + `Sinv'[`r',`u'] * `Sinv'[`s',`v'] * `Sinv'[`t',`w'] ///
                             * `M_`r'_`s'_`t'' * `M_`u'_`v'_`w''
            }
          }
        }
      }
    }
  }

  * output
  tempname df pval A
  scalar `df' = `p'*(`p'+1)*(`p'+2)/6
  scalar `A' = `N'*`b1p'/6
  scalar `pval' = chi2tail(`df',`A')
  di _n as text "Multvariate skewness b_1,p =" as res %8.4f `b1p'
  di as text "chi2(" as res `df' as text ")= " as res %8.4f `A' _c
  di as text "; Prob > chi2 = " as res %6.4f `pval'
  if `N' <= `df' {
     di as text "#D.f. < #obs.; asymptotic distribution may not be accurate"
  }


  *** multivariate kurtosis
  tempvar mah mah2
  qui g double `mah'=.
  mata: mvsktest_Mahal("`clist'","`touse'","`Sinv'","`mah'")

  * li `clist' `mah'
  tempname b2p z pval2
  qui gen double `mah2' = `mah'*`mah' if `touse'
  sum `mah2' if `touse', mean
  scalar `b2p' = r(mean)
  scalar `z' = (`b2p' - `p'*(`p'+2)*(`N'-1)/(`N'+1))/sqrt(8*`p'*(`p'+2)/`N')
  scalar `pval2' = 2*norm( -abs(`z') )

  di _n as text "Multivariate kurtosis b_2,p =" as res %8.4f `b2p'
  di as text "z =" as res %8.4f `z' _c
  di as text "; Prob > |z| =" as res %8.4f `pval2'

end

version 9
cap mata: mata drop mvsktest_Mahal
mata:
void mvsktest_Mahal(string varlist, string scalar touse, string scalar S, string scalar mahal)
{
    real matrix x
    st_view(x,.,tokens(varlist),touse)

    SI = st_matrix(S)

    real matrix d
    st_view(d,.,tokens(mahal),touse)

    for(i=1;i<=rows(d);i++) {
       d[i,1] = x[i,.]*SI*x[i,.]'
    }

}
end