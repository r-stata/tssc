*! 1.5 16 Apr 2017 Austin Nichols add new default for age indicator option 
*  1.4 31 Mar 2017 Austin Nichols removed lnmvnormal and replaced with (-.5*(x-m)*invsym(v)*(x-m)')-ln(pi()*det(v))
*  1.3 31 Mar 2017 Austin Nichols added round() and missok options
*  1.2 20 Mar 2017 Austin Nichols removed grouplist and gvar options, added agevar and modevar options
*  1.1 19 Mar 2017 Austin Nichols renumbered groups, added check for correct average correlations across items, added round() and missok options, changed variable name defaults
*  1.0 17 Oct 2016 Austin Nichols
prog pfs, rclass
 version 10.2
 syntax name [if] [in] [, modevar(varname numeric) agevar(varname numeric) qlist(varlist numeric min=10 max=10) replace INTPoints(int 31) zlimit(real 4) ghq round(real 1) missok skipcorr]
 marksample touse
 if "`replace'"=="" qui g double `namelist'=.
 else {
  cap g double `namelist'=.
  }
 *check rounding value
 if `round'<0 {
  di as err "Rounding value for scores must be positive"
  error 198
  }
 *check mode var
 if "`modevar'"=="" {
  loc modevar "self"
  }
 cap assert inlist(`modevar',0,1) if `touse'
 if _rc {
  di as err "mode variable `modevar' not defined correctly"
  err 459
  }
 *check age var
 if "`agevar'"=="" {
  loc agevar "age18_61"
  }
 cap assert inlist(`agevar',0,1) if `touse'
 if _rc {
  di as err "age variable `agevar' not defined correctly"
  err 459
  }
 *check group var
 tempvar gvar
 qui g byte `gvar'=1+2*`agevar'+`modevar' if `touse'
 cap conf numeric var `gvar'
 if _rc!=0 {
  di as err "Error: group var `gvar' not found"
  error 198
  }
 cap assert inlist(`gvar',1,2,3,4) if `touse'
 if _rc!=0 {
  di as err "Error: group var not in {1,2,3,4}"
  error 459
  }
 *check ghq option
 loc GHQ=cond("`ghq'"!="",1,0)
 if "`ghq'"!="" {
  if "`zlimit'"!="6" {
   di as err "zlimit option is ignored when option ghq is specified"
   }
  }
 *check questions
if "`qlist'"=="" loc qlist "fs1_complexdecision fs2_goodnewdecision fs3_followthrough fs4_recognizegoodinvestment fs5_keepfromspending fs6_howtosave fs7_findadvice fs8_notenoughinfo fs9_whenadvice fs10_struggleunderstand"
if wordcount("`qlist'")!=10 {
 di as err "Must specify 10 variables holding all 10 items in FS instrument (even if some are everywhere missing)"
 error 198
 }
if "`skipcorr'"=="" {
 tokenize `qlist'
 loc avgcorr=0
 loc ctcorr=0
 loc c 0
 foreach pos in 1 2 3 4 5 6 7 8 9 {
  foreach neg in 10 {
   cap corr ``pos'' ``neg''
   if _rc==0 loc c=r(rho)
   if `c'<. {
    loc avgcorr=`avgcorr'+`c'
    loc ctcorr=`ctcorr'+1
    }
   }
  }
 if `avgcorr'<0 {
  di as err "Reverse-coded items seem to have a negative correlation with other items; check coding of items."
  di as err "If you are sure of your coding of items, use the" as txt " skipcorr " as err "option." _n
  err 459
  }
 }
if "`grouplist'"=="" {
  loc grouplist "1 2 3 4"
  }
tempvar allmiss
g byte `allmiss'=1
 foreach v in `qlist' {
  cap conf numeric var `v'
  if _rc!=0 {
   di as err "Error: question var `v' not found"
   di as err "Every question needs to be present, though all values may be missing."
   error 198
   }
  cap assert inlist(`v',0,1,2,3,4)|mi(`v')
  if _rc!=0 {
   di as err "Error: question var `v' responses not in {0,1,2,3,4}"
   di as err "Every question needs to be coded 0 to 4, or missing."
   error 198
   }
  qui replace `allmiss'=0 if !mi(`v')
  }
 foreach v in `qlist' {
  cap conf numeric var `v'
  if _rc!=0 {
   di as err "Error: question var `v' not found"
   di as err "Every question needs to be present, though all values may be missing."
   error 198
   }
  cap assert inlist(`v',0,1,2,3,4)|mi(`v')
  if _rc!=0 {
   di as err "Error: question var `v' responses not in {0,1,2,3,4}"
   di as err "Every question needs to be coded 0 to 4, or missing."
   error 198
   }
  }
di as res "Computing scores... this may take some time."
 * define parameter vectors
 mat g1m=(.6441367,.0752469,.5430175,.3178859,.0341296)
 mat g1v=(1.2708368,1.0376652,2.6169667,2.7600912,2.3128359)
 mat g1q1a=(2.4110204,1.6608551,0,0,0)
 mat g1q1c=(-3.8782355,-1.7671008,.9215354,3.767286)
 mat g1q2a=(2.6124065,.9456864,0,0,0)
 mat g1q2c=(-4.7960932,-2.5118584,.5013833,3.4591656)
 mat g1q3a=(2.94338,0,.6065566,0,0)
 mat g1q3c=(-5.5042085,-3.321763,-.2910979,2.9441576)
 mat g1q4a=(2.1575548,1.3135908,0,0,0)
 mat g1q4c=(-3.6915979,-1.6576427,.9776602,3.5609863)
 mat g1q5a=(2.7242041,0,1.823336,0,0)
 mat g1q5c=(-6.2985207,-3.9930611,-1.0702193,2.299984)
 mat g1q6a=(2.6266401,0,1.2713007,0,0)
 mat g1q6c=(-5.2970614,-3.2486689,-.6403721,2.2178339)
 mat g1q7a=(2.1436959,1.3510367,0,0,0)
 mat g1q7c=(-4.1650335,-2.3304422,.0861086,2.7708504)
 mat g1q8a=(1.6588753,0,0,1.4824103,0)
 mat g1q8c=(-5.8700343,-3.9450868,-.889881,2.2294792)
 mat g1q9a=(1.4490391,0,0,1.097,0)
 mat g1q9c=(-4.854968,-3.1900848,-.6261177,1.9932152)
 mat g1q10a=(.9935323,0,0,0,1.4649552)
 mat g1q10c=(-3.4590475,-1.677168,.426561,2.8675858)
 mat g2m=(.0681382,-.0824054,.2943358,.1840323,.4392121)
 mat g2v=(1.0099854,.8838703999999999,1.2562739,.9213053,.3354192)
 mat g2q1a=(2.4110204,1.6608551,0,0,0)
 mat g2q1c=(-3.8782355,-1.7671008,.9215354,3.767286)
 mat g2q2a=(2.6124065,.9456864,0,0,0)
 mat g2q2c=(-4.7960932,-2.5118584,.5013833,3.4591656)
 mat g2q3a=(2.94338,0,.6065566,0,0)
 mat g2q3c=(-5.5042085,-3.321763,-.2910979,2.9441576)
 mat g2q4a=(2.1575548,1.3135908,0,0,0)
 mat g2q4c=(-3.6915979,-1.6576427,.9776602,3.5609863)
 mat g2q5a=(2.7242041,0,1.823336,0,0)
 mat g2q5c=(-6.2985207,-3.9930611,-1.0702193,2.299984)
 mat g2q6a=(2.6266401,0,1.2713007,0,0)
 mat g2q6c=(-5.2970614,-3.2486689,-.6403721,2.2178339)
 mat g2q7a=(2.1436959,1.3510367,0,0,0)
 mat g2q7c=(-4.1650335,-2.3304422,.0861086,2.7708504)
 mat g2q8a=(1.6588753,0,0,1.4824103,0)
 mat g2q8c=(-5.8700343,-3.9450868,-.889881,2.2294792)
 mat g2q9a=(1.4490391,0,0,1.097,0)
 mat g2q9c=(-4.854968,-3.1900848,-.6261177,1.9932152)
 mat g2q10a=(.9935323,0,0,0,1.4649552)
 mat g2q10c=(-3.4590475,-1.677168,.426561,2.8675858)
 mat g3m=(.4085444,.2285651,.6113262,.349839,.3778126)
 mat g3v=(1.292261,.9167938,2.2512673,2.6216329,1.5590249)
 mat g3q1a=(2.4110204,1.6608551,0,0,0)
 mat g3q1c=(-3.8782355,-1.7671008,.9215354,3.767286)
 mat g3q2a=(2.6124065,.9456864,0,0,0)
 mat g3q2c=(-4.7960932,-2.5118584,.5013833,3.4591656)
 mat g3q3a=(2.94338,0,.6065566,0,0)
 mat g3q3c=(-5.5042085,-3.321763,-.2910979,2.9441576)
 mat g3q4a=(2.1575548,1.3135908,0,0,0)
 mat g3q4c=(-3.6915979,-1.6576427,.9776602,3.5609863)
 mat g3q5a=(2.7242041,0,1.823336,0,0)
 mat g3q5c=(-6.2985207,-3.9930611,-1.0702193,2.299984)
 mat g3q6a=(2.6266401,0,1.2713007,0,0)
 mat g3q6c=(-5.2970614,-3.2486689,-.6403721,2.2178339)
 mat g3q7a=(2.1436959,1.3510367,0,0,0)
 mat g3q7c=(-4.1650335,-2.3304422,.0861086,2.7708504)
 mat g3q8a=(1.6588753,0,0,1.4824103,0)
 mat g3q8c=(-5.8700343,-3.9450868,-.889881,2.2294792)
 mat g3q9a=(1.4490391,0,0,1.097,0)
 mat g3q9c=(-4.854968,-3.1900848,-.6261177,1.9932152)
 mat g3q10a=(.9935323,0,0,0,1.4649552)
 mat g3q10c=(-3.4590475,-1.677168,.426561,2.8675858)
 mat g4m=(0,0,0,0,0)
 mat g4v=(1,1,1,1,1)
 mat g4q1a=(2.4110204,1.6608551,0,0,0)
 mat g4q1c=(-3.8782355,-1.7671008,.9215354,3.767286)
 mat g4q2a=(2.6124065,.9456864,0,0,0)
 mat g4q2c=(-4.7960932,-2.5118584,.5013833,3.4591656)
 mat g4q3a=(2.94338,0,.6065566,0,0)
 mat g4q3c=(-5.5042085,-3.321763,-.2910979,2.9441576)
 mat g4q4a=(2.1575548,1.3135908,0,0,0)
 mat g4q4c=(-3.6915979,-1.6576427,.9776602,3.5609863)
 mat g4q5a=(2.7242041,0,1.823336,0,0)
 mat g4q5c=(-6.2985207,-3.9930611,-1.0702193,2.299984)
 mat g4q6a=(2.6266401,0,1.2713007,0,0)
 mat g4q6c=(-5.2970614,-3.2486689,-.6403721,2.2178339)
 mat g4q7a=(2.1436959,1.3510367,0,0,0)
 mat g4q7c=(-4.1650335,-2.3304422,.0861086,2.7708504)
 mat g4q8a=(1.6588753,0,0,1.4824103,0)
 mat g4q8c=(-5.8700343,-3.9450868,-.889881,2.2294792)
 mat g4q9a=(1.4490391,0,0,1.097,0)
 mat g4q9c=(-4.854968,-3.1900848,-.6261177,1.9932152)
 mat g4q10a=(.9935323,0,0,0,1.4649552)
 mat g4q10c=(-3.4590475,-1.677168,.426561,2.8675858)
 loc qn 1
 loc qqlist
 foreach q in `qlist' {  
  * turn each response into five columns in {0,1} to multiply probability
  tempvar q`qn'c1
  tempvar q`qn'c2
  tempvar q`qn'c3
  tempvar q`qn'c4
  tempvar q`qn'c5
  g byte `q`qn'c1'=(`q'==0)
  g byte `q`qn'c2'=(`q'==1)
  g byte `q`qn'c3'=(`q'==2)
  g byte `q`qn'c4'=(`q'==3)
  g byte `q`qn'c5'=(`q'==4)
  loc qqlist `qqlist' `q`qn'c1' `q`qn'c2' `q`qn'c3' `q`qn'c4' `q`qn'c5'
  loc qn=`qn'+1
  }
 *loop over groups
 if "`grouplist'"=="" {
  loc grouplist "1 2 3 4"
  }
 foreach g of numlist `grouplist' {
  qui count if `touse' & `gvar'==`g'
  if r(N)>0 {
   timer clear 1
   timer on 1
   mat FAmn=g`g'm
   mat FAva=g`g'v
   forv q=1/10 {
    mat FAq`q'a=g`g'q`q'a
    mat FAq`q'c=g`g'q`q'c
    }
   tempname tmp`g'
   g byte `tmp`g''=min(`touse',`gvar'==`g')
   mata:ipr_fa("`namelist'","`qqlist'","`tmp`g''",`intpoints',`zlimit',`GHQ')
   timer off 1
   qui timer list 1
   di as res "Group `g' complete in " r(t1) " seconds."
   }
  }
 qui replace `namelist'=round(`namelist',`round')
 if "`missok'"=="" qui replace `namelist'=. if `allmiss'==1
 ret scalar round=`round'
 ret scalar ghq=`GHQ'
 ret scalar intpoints=`intpoints'
 if "`ghq'"==""  ret scalar zlimit=`zlimit'
 ret local name "`namelist'"
end
version 10.2
mata:
void ipr_fa(string scalar f, string scalar x, string scalar tousename, real intpt, real zlim, real ghq) {
  st_view(y, ., tokens(f), tousename)
  q = st_data(., tokens(x), tousename)
  mean = st_matrix("FAmn")
  v = st_matrix("FAva")
  var=diag(v)
q1a= st_matrix("FAq1a")
q1c= st_matrix("FAq1c")  
q2a= st_matrix("FAq2a")   
q2c= st_matrix("FAq2c")  
q3a= st_matrix("FAq3a")   
q3c= st_matrix("FAq3c")  
q4a= st_matrix("FAq4a")  
q4c= st_matrix("FAq4c")  
q5a= st_matrix("FAq5a")  
q5c= st_matrix("FAq5c")  
q6a= st_matrix("FAq6a")  
q6c= st_matrix("FAq6c")  
q7a= st_matrix("FAq7a")  
q7c= st_matrix("FAq7c")  
q8a= st_matrix("FAq8a")  
q8c= st_matrix("FAq8c")  
q9a= st_matrix("FAq9a")  
q9c= st_matrix("FAq9c")  
q10a=st_matrix("FAq10a")  
q10c=st_matrix("FAq10c")  
P=J(rows(q),1,0)
Pf=J(rows(q),1,0)
Pft=J(rows(q),1,0)
 Z=_gauss_hermite_nodes(intpt)
 for (i=1; i<=intpt; i++) {
  if (ghq==1) t1=Z[1,i]
  else t1=(i-1)*2*zlim/(intpt-1)-(zlim)
  for (j=1; j<=intpt; j++) {
   if (ghq==1) t2=Z[1,j]
   else t2=(j-1)*2*zlim/(intpt-1)-(zlim)
   for (k=1; k<=intpt; k++) {
    if (ghq==1) t3=Z[1,k]
    else t3=(k-1)*2*zlim/(intpt-1)-(zlim)
    for (l=1; l<=intpt; l++) {
     if (ghq==1) t4=Z[1,l]
     else t4=(l-1)*2*zlim/(intpt-1)-(zlim)
     for (n=1; n<=intpt; n++) {
      if (ghq==1) t5=Z[1,n]
      else t5=(n-1)*2*zlim/(intpt-1)-(zlim)
 theta=(t1,t2,t3,t4,t5)
 a1theta=theta*q1a'
 a2theta=theta*q2a'
 a3theta=theta*q3a'
 a4theta=theta*q4a'
 a5theta=theta*q5a'
 a6theta=theta*q6a'
 a7theta=theta*q7a'
 a8theta=theta*q8a'
 a9theta=theta*q9a'
 a10theta=theta*q10a'
 lp1=(ln(1-invlogit(a1theta-q1c[1]))\ln(invlogit(a1theta-q1c[1])-invlogit(a1theta-q1c[2]))\ln(invlogit(a1theta-q1c[2])-invlogit(a1theta-q1c[3]))\ln(invlogit(a1theta-q1c[3])-invlogit(a1theta-q1c[4]))\ln(invlogit(a1theta-q1c[4])))
 lp2=(ln(1-invlogit(a2theta-q2c[1]))\ln(invlogit(a2theta-q2c[1])-invlogit(a2theta-q2c[2]))\ln(invlogit(a2theta-q2c[2])-invlogit(a2theta-q2c[3]))\ln(invlogit(a2theta-q2c[3])-invlogit(a2theta-q2c[4]))\ln(invlogit(a2theta-q2c[4])))
 lp3=(ln(1-invlogit(a3theta-q3c[1]))\ln(invlogit(a3theta-q3c[1])-invlogit(a3theta-q3c[2]))\ln(invlogit(a3theta-q3c[2])-invlogit(a3theta-q3c[3]))\ln(invlogit(a3theta-q3c[3])-invlogit(a3theta-q3c[4]))\ln(invlogit(a3theta-q3c[4])))
 lp4=(ln(1-invlogit(a4theta-q4c[1]))\ln(invlogit(a4theta-q4c[1])-invlogit(a4theta-q4c[2]))\ln(invlogit(a4theta-q4c[2])-invlogit(a4theta-q4c[3]))\ln(invlogit(a4theta-q4c[3])-invlogit(a4theta-q4c[4]))\ln(invlogit(a4theta-q4c[4])))
 lp5=(ln(1-invlogit(a5theta-q5c[1]))\ln(invlogit(a5theta-q5c[1])-invlogit(a5theta-q5c[2]))\ln(invlogit(a5theta-q5c[2])-invlogit(a5theta-q5c[3]))\ln(invlogit(a5theta-q5c[3])-invlogit(a5theta-q5c[4]))\ln(invlogit(a5theta-q5c[4])))
 lp6=(ln(1-invlogit(a6theta-q6c[1]))\ln(invlogit(a6theta-q6c[1])-invlogit(a6theta-q6c[2]))\ln(invlogit(a6theta-q6c[2])-invlogit(a6theta-q6c[3]))\ln(invlogit(a6theta-q6c[3])-invlogit(a6theta-q6c[4]))\ln(invlogit(a6theta-q6c[4])))
 lp7=(ln(1-invlogit(a7theta-q7c[1]))\ln(invlogit(a7theta-q7c[1])-invlogit(a7theta-q7c[2]))\ln(invlogit(a7theta-q7c[2])-invlogit(a7theta-q7c[3]))\ln(invlogit(a7theta-q7c[3])-invlogit(a7theta-q7c[4]))\ln(invlogit(a7theta-q7c[4])))
 lp8=(ln(1-invlogit(a8theta-q8c[1]))\ln(invlogit(a8theta-q8c[1])-invlogit(a8theta-q8c[2]))\ln(invlogit(a8theta-q8c[2])-invlogit(a8theta-q8c[3]))\ln(invlogit(a8theta-q8c[3])-invlogit(a8theta-q8c[4]))\ln(invlogit(a8theta-q8c[4])))
 lp9=(ln(1-invlogit(a9theta-q9c[1]))\ln(invlogit(a9theta-q9c[1])-invlogit(a9theta-q9c[2]))\ln(invlogit(a9theta-q9c[2])-invlogit(a9theta-q9c[3]))\ln(invlogit(a9theta-q9c[3])-invlogit(a9theta-q9c[4]))\ln(invlogit(a9theta-q9c[4])))
 lp10=(ln(1-invlogit(a10theta-q10c[1]))\ln(invlogit(a10theta-q10c[1])-invlogit(a10theta-q10c[2]))\ln(invlogit(a10theta-q10c[2])-invlogit(a10theta-q10c[3]))\ln(invlogit(a10theta-q10c[3])-invlogit(a10theta-q10c[4]))\ln(invlogit(a10theta-q10c[4])))
 lp=lp1\lp2\lp3\lp4\lp5\lp6\lp7\lp8\lp9\lp10
 P=exp(cross(q',lp):+((-.5*(theta-mean)*invsym(var)*(theta-mean)')-ln(pi()*det(var))))
 Pf=Pf+P
 Pft=Pft+P:*t1
     }
    }
   }
  }
 }
y[.,.]=Pft:/Pf:*15:+50
}
end

exit

