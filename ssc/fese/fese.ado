*! 1.0.2 5 Sep 2008 Austin Nichols
* 1.0.2  5 Sep 2008 fixes bug that ignores i() and absorb()
* 1.0.1 28 Feb 2008 makes abs option absorb and exits with error in no-regressor case
* 1.0.0 10 Feb 2008 Austin Nichols
prog fese, sortpreserve
 version 9.2
 loc version="1.0.0"
 if replay() eret di
 else {
  syntax [varlist] [if] [in] [, s(str) i(varname) Absorb(varname) Oonly * ]
  if "`i'`absorb'"!="" {
   if "`i'"!="" & "`absorb'"!="" {
    di as err "May not specify both " as txt "i" as err " and " as txt "absorb" as err " options."
    error 198
    }
   else loc gp "`i'`absorb'"
   }
  else loc gp:char _dta[iis]
  if "`:word 2 of `varlist''"=="" {
    di as err "You must specify at least one RHS (explanatory) variable for " as smcl "{help fese}"  as err "."
    di as err "A model without RHS (explanatory) variables can be estimated by " as smcl "{help mean}"
    di as err "with the " as smcl "{help mean:over()}" as err " option for het-robust SEs, or by hand for i.i.d. errors e.g.:"
    di as txt " areg y, a(" char(96) ":char _dta[iis]')"
    di as txt " predict fe, d"
    di as txt " replace fe=fe+_b[_cons]"
    di as txt " predict resid, r"
    di as txt " generate sqres=resid^2"
    di as txt " egen N=count(sqres), by(" char(96) ":char _dta[iis]')"
    di as txt " summarize sqres, meanonly"
    di as txt " generate se=sqrt(r(mean)*e(N)/e(df_r)/N)
    di as err "See also " as smcl `"{browse "http://www.stata.com/statalist/archive/2008-02/msg00027.html":this Statalist post}"' _c
    di as err " for an illustration using " as smcl "{help xtreg}" as err "." _n 
    di as err "Clustered SEs would be zero (within the limits of machine precision) in this case"
    di as err "(for clustering on the panel [iis] variable as assumed elsewhere)." _n _n
    error 198
    }
  loc tv:char _dta[tis]
  qui g `s'se=.
  la var `s'se "OLS SE"
  if "`oonly'"=="" {
    qui g `s'hrse=.
    la var `s'hrse "Het-robust SE"
    qui g `s'crse=.
    la var `s'crse "Cluster-robust SE"
    loc sv "`s'se `s'hrse `s'crse"
  }
  else   loc sv "`s'se"
  marksample touse
  areg `varlist' if `touse', absorb(`gp') `options'
  gettoken y x: varlist
  qui {
   predict `s'b if `touse', d
   replace `s'b=`s'b+_b[_cons]
   la var `s'b "Estimated FE"
   tempvar e
   predict `e' if `touse', r
   sort `gp' `tv', stable
  } 
  if "`oonly'"=="" mata: fese("`y'","`x'","`e'","`gp'","`touse'","`sv'")
  else mata: fese_o("`y'","`x'","`e'","`gp'","`touse'","`sv'")
 }
end
version 9.2
mata:
 void fese(string scalar depvar, string scalar x, string scalar r, string scalar G, string scalar tousename, string scalar s)
 {
  st_view(y, ., tokens(depvar), tousename)
  st_view(X, ., tokens(x), tousename)
  st_view(e, ., tokens(r), tousename)
  st_view(gp, ., tokens(G), tousename)
  st_view(sv, ., tokens(s), tousename)
  info = panelsetup(gp, 1)
  Ng=rows(info)
  N=rows(X)
  k=cols(X)+Ng
  sse=sum(e:^2)
  Xt=J(0,cols(X),0)
  for (i=1; i<=rows(info); i++) {
    Xi = panelsubmatrix(X, i, info)
    Xt=Xt\Xi:-mean(Xi)
  }
  XtXt=cross(Xt,Xt)
  _invsym(XtXt)
  OV=J(0,1,0)
  RV=J(0,1,0)
  CV=J(0,1,0)
  ov=J(0,1,0)
  rv=J(0,1,0)
  cv=J(0,1,0)
  for (i=1; i<=rows(info); i++) {
   ei = panelsubmatrix(e, i, info)
   Ti =(info[i,2]-info[i,1]+1)
   eiei=ei*ei'
   ei2=diag(ei:^2)
   di=J(info[i,1]-1,1,0)\J(Ti,1,1)\J(N-info[i,2],1,0)
   KDi=cross(Xt',cross(XtXt,cross(X,di)))
   KDii=KDi[info[i,1]..info[i,2],1]
   ci=sum(eiei)-2*cross(rowsum(eiei),KDii)
   ri=sum(ei2)-2*cross(rowsum(ei2),KDii)
   oi=Ti-2*cross(rowsum(I(Ti)),KDii)
   for (j=1; j<=rows(info); j++) {
    ej = panelsubmatrix(e, j, info)
    ejej=ej*ej'
    ej2=diag(ej:^2)
    KDji=KDi[info[j,1]..info[j,2],1]
    ci=ci+cross(KDji,cross(ejej,KDji))
    ri=ri+cross(KDji,cross(ej2,KDji))
    oi=oi+cross(KDji,cross(I(rows(ej)),KDji))
    }
   ooi=sqrt(sse/(N-k)*oi)/Ti
   rri=sqrt(N/(N-k)*ri)/Ti
   cci=sqrt((N-1)/(N-k)*(Ng/(Ng-1))*ci)/Ti
   ov=ov\ooi
   rv=rv\rri
   cv=cv\cci
   for (t=1; t<=Ti; t++) {
       OV=OV\ooi
       RV=RV\rri
       CV=CV\cci
       }
  }
  st_matrix("ov",ov)
  st_matrix("rv",rv)
  st_matrix("cv",cv)
  sv[.,.]=OV,RV,CV
}
void fese_o(string scalar depvar, string scalar x, string scalar r, string scalar G, string scalar tousename, string scalar s)
 {
  st_view(y, ., tokens(depvar), tousename)
  st_view(X, ., tokens(x), tousename)
  st_view(e, ., tokens(r), tousename)
  st_view(gp, ., tokens(G), tousename)
  st_view(sv, ., tokens(s), tousename)
  info = panelsetup(gp, 1)
  Ng=rows(info)
  N=rows(X)
  k=cols(X)+Ng
  sse=sum(e:^2)
  Xt=J(0,cols(X),0)
  for (i=1; i<=rows(info); i++) {
    Xi = panelsubmatrix(X, i, info)
    Xt=Xt\Xi:-mean(Xi)
  }
  XtXt=cross(Xt,Xt)
  _invsym(XtXt)
  OV=J(0,1,0)
  ov=J(0,1,0)
  for (i=1; i<=rows(info); i++) {
   Ti =(info[i,2]-info[i,1]+1)
   di=J(info[i,1]-1,1,0)\J(Ti,1,1)\J(N-info[i,2],1,0)
   KDi=cross(Xt',cross(XtXt,cross(X,di)))
   dKDi=cross(di,KDi)
   dKKDi=cross(KDi,KDi)
   oi=Ti-2*dKDi+dKKDi
   ooi=sqrt(sse/(N-k)*oi)/Ti
   ov=ov\ooi
   for (t=1; t<=Ti; t++) {
       OV=OV\ooi
       }
  }
  st_matrix("ov",ov)
  sv[.,.]=OV
}
end
exit

