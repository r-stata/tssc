*! 1.7 16 Apr 2017 Austin Nichols add new default for age indicator option 
*  1.6 21 Mar 2017 Austin Nichols removed lnmvnormal and replaced with (-.5*(x-m)*invsym(v)*(x-m)')-ln(pi()*det(v))
*  1.5 20 Mar 2017 Austin Nichols removed grouplist and gvar options, added agevar and modevar options
*  1.4 16 Mar 2017 Austin Nichols renumbered groups
*  1.3 13 Mar 2017 Austin Nichols added check for correct average correlations across items
*  1.2 09 Mar 2017 Austin Nichols removed obsolete groups
*  1.2 08 Mar 2017 Austin Nichols added round() and missok options
*  1.1 03 Mar 2017 Austin Nichols changed variable name defaults
*  1.0 17 Oct 2016 Austin Nichols <austinnichols@gmail.com>
prog pfwb, rclass
 version 10.2
 syntax name [if] [in] [, modevar(varname numeric) agevar(varname numeric) gvar(varname numeric) qlist(varlist numeric min=10 max=10) replace INTPoints(int 49) zlimit(real 6) ghq round(real 1) missok skipcorr]
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
if "`qlist'"=="" loc qlist "fwb1_exp fwb2_getby fwb3_secure fwb4_concern fwb5_never fwb6_enjoy fwb7_behind fwb8_control fwb9_strain fwb10_left" 
if wordcount("`qlist'")!=10 {
 di as err "Must specify 10 variables holding all 10 items in FWB instrument (even if some are everywhere missing)"
 error 198
 }
if "`skipcorr'"=="" {
 tokenize `qlist'
 loc avgcorr=0
 loc ctcorr=0
 loc c 0
 foreach pos in 1 3 6 10 {
  foreach neg in 2 4 5 7 8 9 {
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
di as res "Computing scores... this may take some time."
 * check gsem option
 if "`gsem'"!="" {
 mat g1=(2.1987183,2.5977786,2.0262112,-.2961961,1.6585993,1.9563691,1.9234236,-.9979853,2.5144634,-.5726793,2.1467741,2.3913435,2.1146504,.5220543,1.4970444,.159058,2.8716455,.3471574,1.5260218,1.4633664)
 mat g2=(2.578371,2.5977786,2.0262112,-.2961961,2.2843891,1.9563691,1.9234236,-.9979853,2.5144634,-.5726793,2.1467741,2.3913435,2.1146504,.5220543,1.9950379,.159058,2.8716455,.3471574,1.9723144,1.4633664)
 mat g3=(2.1987183,2.5977786,2.0262112,-.2961961,1.6585993,1.9563691,1.9234236,-.9979853,2.5144634,-.5726793,2.1467741,2.3913435,2.1146504,.5220543,1.5421585,.159058,2.8716455,.3471574,1.9723144,1.4633664)
 mat g4=(2.1987183,2.5977786,2.0262112,-.2961961,1.6585993,1.9563691,1.9234236,-.9979853,2.5144634,-.5726793,2.1467741,2.3913435,2.1146504,.5220543,1.9950379,.159058,2.8716455,.3471574,1.9723144,1.4633664)
 mat h1=(-2.2047837,-1.0882027,.3585419,2.5735247,-1.3208536,-.2740339,.8621188,1.9373029,-2.2144952,-1.059253,.4227569,2.1435156,-2.2209814,-.4245686,1.4446934,3.3603167,-3.0937724,-1.3091939,.4448066,2.4752427,-3.8399637,-2.1489973,-.1686061,1.7348393,-2.0926086,-1.0962606,-.3216849,.3565704,-2.1420109,-1.064027,.3304075,1.6338181,-2.0624651,-1.1108175,.2679782,1.535325,-1.7448388,-.7562154,.3777863,1.4842417,1.0871438,.7192873,3.2854107,0,0,0)
 mat h2=(-2.4179007,-.4122027,2.0406173,4.7737384,-2.2328062,-.5681815,.9966695,2.622802,-2.6647402,-.8492241,1.6940806,4.5478367,-2.2209814,-.4245686,1.4446934,3.3603167,-3.0937724,-1.3091939,.4448066,2.4752427,-3.5076333,-1.2281664,1.5150107,4.3227005,-3.4129491,-1.8072053,-.1601308,1.7784225,-2.8620269,-1.0488892,1.0262574,3.1092984,-3.6906161,-1.5936348,.6377263,3.1938995,-3.2028665,-1.0689037,.9702596,2.9018261,1.3285903,.4652468,.8905083,0,0,0)
 mat h3=(-1.2052772,.2585893,1.9945245,3.7360925,-2.2328062,-.5681815,.9966695,2.622802,-3.1553966,-1.2531268,.9456383,3.2224684,-2.2209814,-.4245686,1.4446934,3.3603167,-3.0937724,-1.3091939,.4448066,2.4752427,-2.9830786,-1.289892,1.2312826,3.4551957,-2.0225894,-1.1311798,.125659,1.4371861,-1.2378236,-.4001816,1.0566471,2.295852,-2.465411,-1.5280219,.0812848,1.8023567,-1.5709306,-.6284243000000001,.8178498,2.2357033,1.3252162,.512746,2.5283897,0,0,0)
 mat h4=(-2.4179007,-.4122027,2.0406173,4.7737384,-2.2328062,-.5681815,.9966695,2.622802,-3.1553966,-1.2531268,.9456383,3.2224684,-2.2209814,-.4245686,1.4446934,3.3603167,-3.0937724,-1.3091939,.4448066,2.4752427,-3.5076333,-1.2281664,1.5150107,4.3227005,-3.4129491,-1.8072053,-.1601308,1.7784225,-2.8620269,-1.0488892,1.0262574,3.1092984,-3.6906161,-1.5936348,.6377263,3.1938995,-3.2028665,-1.0689037,.9702596,2.9018261,1,1,1,0,0,0)
 mat f1=g1,h1
 mat f2=g2,h2
 mat f3=g3,h3
 mat f4=g4,h4
 set more 1
 *loop over groups
 tokenize `qlist'
 foreach i of numlist `grouplist' {
  mat coln f`i'= `"`1':F"' `"`1':P"' `"`2':F"' `"`2':N"' `"`3':F"' `"`3':P"' `"`4':F"' `"`4':N"' `"`5':F"' `"`5':N"' `"`6':F"' `"`6':P"' `"`7':F"' `"`7':N"' `"`8':F"' `"`8':N"' `"`9':F"' `"`9':N"' `"`10':F"' `"`10':P"' `"`1'_cut1:_cons"' `"`1'_cut2:_cons"' `"`1'_cut3:_cons"' `"`1'_cut4:_cons"' `"`2'_cut1:_cons"' `"`2'_cut2:_cons"' `"`2'_cut3:_cons"' `"`2'_cut4:_cons"' `"`3'_cut1:_cons"' `"`3'_cut2:_cons"' `"`3'_cut3:_cons"' `"`3'_cut4:_cons"' `"`4'_cut1:_cons"' `"`4'_cut2:_cons"' `"`4'_cut3:_cons"' `"`4'_cut4:_cons"' `"`5'_cut1:_cons"' `"`5'_cut2:_cons"' `"`5'_cut3:_cons"' `"`5'_cut4:_cons"' `"`6'_cut1:_cons"' `"`6'_cut2:_cons"' `"`6'_cut3:_cons"' `"`6'_cut4:_cons"' `"`7'_cut1:_cons"' `"`7'_cut2:_cons"' `"`7'_cut3:_cons"' `"`7'_cut4:_cons"' `"`8'_cut1:_cons"' `"`8'_cut2:_cons"' `"`8'_cut3:_cons"' `"`8'_cut4:_cons"' `"`9'_cut1:_cons"' `"`9'_cut2:_cons"' `"`9'_cut3:_cons"' `"`9'_cut4:_cons"' `"`10'_cut1:_cons"' `"`10'_cut2:_cons"' `"`10'_cut3:_cons"' `"`10'_cut4:_cons"' `"var(F):_cons"' `"var(P):_cons"' `"var(N):_cons"' `"cov(P,F):_cons"' `"cov(N,F):_cons"' `"cov(N,P):_cons"'
  mat rown f`i'="y1"
  gsem (F -> `1' `2' `3' `4' `5' `6' `7' `8' `9' `10', ologit) (P -> `1' `3' `6' `10' , ologit) (N -> `2' `4' `5' `7' `8' `9', ologit) if grp==`i'*`touse', from(f`i') iter(0) intp(`intpoints')
  tempvar f`i' 
  qui predict double `f`i'' if e(sample), latent(F)
  qui replace `namelist'=(`f`i''*15+50) if `f`i''<.
  }
 }
 else {
 * define parameter vectors
 mat g1m=(.6291655,-.0685166,.442397)
 mat g1v=(1.0871438,.7192873,3.2854107)
 mat g1q1a=(2.1987183,2.5977786,0)
 mat g1q1c=(-2.2047837,-1.0882027,.3585419,2.5735247)
 mat g1q2a=(2.0262112,0,-.2961961)
 mat g1q2c=(-1.3208536,-.2740339,.8621188,1.9373029)
 mat g1q3a=(1.6585993,1.9563691,0)
 mat g1q3c=(-2.2144952,-1.059253,.4227569,2.1435156)
 mat g1q4a=(1.9234236,0,-.9979853)
 mat g1q4c=(-2.2209814,-.4245686,1.4446934,3.3603167)
 mat g1q5a=(2.5144634,0,-.5726793)
 mat g1q5c=(-3.0937724,-1.3091939,.4448066,2.4752427)
 mat g1q6a=(2.1467741,2.3913435,0)
 mat g1q6c=(-3.8399637,-2.1489973,-.1686061,1.7348393)
 mat g1q7a=(2.1146504,0,.5220543)
 mat g1q7c=(-2.0926086,-1.0962606,-.3216849,.3565704)
 mat g1q8a=(1.4970444,0,.159058)
 mat g1q8c=(-2.1420109,-1.064027,.3304075,1.6338181)
 mat g1q9a=(2.8716455,0,.3471574)
 mat g1q9c=(-2.0624651,-1.1108175,.2679782,1.535325)
 mat g1q10a=(1.5260218,1.4633664,0)
 mat g1q10c=(-1.7448388,-.7562154,.3777863,1.4842417)
 mat g2m=(.7185538,-.3572805,.2846914)
 mat g2v=(1.3285903,.4652468,.8905083)
 mat g2q1a=(2.578371,2.5977786,0)
 mat g2q1c=(-2.4179007,-.4122027,2.0406173,4.7737384)
 mat g2q2a=(2.0262112,0,-.2961961)
 mat g2q2c=(-2.2328062,-.5681815,.9966695,2.622802)
 mat g2q3a=(2.2843891,1.9563691,0)
 mat g2q3c=(-2.6647402,-.8492241,1.6940806,4.5478367)
 mat g2q4a=(1.9234236,0,-.9979853)
 mat g2q4c=(-2.2209814,-.4245686,1.4446934,3.3603167)
 mat g2q5a=(2.5144634,0,-.5726793)
 mat g2q5c=(-3.0937724,-1.3091939,.4448066,2.4752427)
 mat g2q6a=(2.1467741,2.3913435,0)
 mat g2q6c=(-3.5076333,-1.2281664,1.5150107,4.3227005)
 mat g2q7a=(2.1146504,0,.5220543)
 mat g2q7c=(-3.4129491,-1.8072053,-.1601308,1.7784225)
 mat g2q8a=(1.9950379,0,.159058)
 mat g2q8c=(-2.8620269,-1.0488892,1.0262574,3.1092984)
 mat g2q9a=(2.8716455,0,.3471574)
 mat g2q9c=(-3.6906161,-1.5936348,.6377263,3.1938995)
 mat g2q10a=(1.9723144,1.4633664,0)
 mat g2q10c=(-3.2028665,-1.0689037,.9702596,2.9018261)
 mat g3m=(.5131654,.0516339,.5999753)
 mat g3v=(1.3252162,.512746,2.5283897)
 mat g3q1a=(2.1987183,2.5977786,0)
 mat g3q1c=(-1.2052772,.2585893,1.9945245,3.7360925)
 mat g3q2a=(2.0262112,0,-.2961961)
 mat g3q2c=(-2.2328062,-.5681815,.9966695,2.622802)
 mat g3q3a=(1.6585993,1.9563691,0)
 mat g3q3c=(-3.1553966,-1.2531268,.9456383,3.2224684)
 mat g3q4a=(1.9234236,0,-.9979853)
 mat g3q4c=(-2.2209814,-.4245686,1.4446934,3.3603167)
 mat g3q5a=(2.5144634,0,-.5726793)
 mat g3q5c=(-3.0937724,-1.3091939,.4448066,2.4752427)
 mat g3q6a=(2.1467741,2.3913435,0)
 mat g3q6c=(-2.9830786,-1.289892,1.2312826,3.4551957)
 mat g3q7a=(2.1146504,0,.5220543)
 mat g3q7c=(-2.0225894,-1.1311798,.125659,1.4371861)
 mat g3q8a=(1.5421585,0,.159058)
 mat g3q8c=(-1.2378236,-.4001816,1.0566471,2.295852)
 mat g3q9a=(2.8716455,0,.3471574)
 mat g3q9c=(-2.465411,-1.5280219,.0812848,1.8023567)
 mat g3q10a=(1.9723144,1.4633664,0)
 mat g3q10c=(-1.5709306,-.6284243000000001,.8178498,2.2357033)
 mat g4m=(0,0,0)
 mat g4v=(1,1,1)
 mat g4q1a=(2.1987183,2.5977786,0)
 mat g4q1c=(-2.4179007,-.4122027,2.0406173,4.7737384)
 mat g4q2a=(2.0262112,0,-.2961961)
 mat g4q2c=(-2.2328062,-.5681815,.9966695,2.622802)
 mat g4q3a=(1.6585993,1.9563691,0)
 mat g4q3c=(-3.1553966,-1.2531268,.9456383,3.2224684)
 mat g4q4a=(1.9234236,0,-.9979853)
 mat g4q4c=(-2.2209814,-.4245686,1.4446934,3.3603167)
 mat g4q5a=(2.5144634,0,-.5726793)
 mat g4q5c=(-3.0937724,-1.3091939,.4448066,2.4752427)
 mat g4q6a=(2.1467741,2.3913435,0)
 mat g4q6c=(-3.5076333,-1.2281664,1.5150107,4.3227005)
 mat g4q7a=(2.1146504,0,.5220543)
 mat g4q7c=(-3.4129491,-1.8072053,-.1601308,1.7784225)
 mat g4q8a=(1.9950379,0,.159058)
 mat g4q8c=(-2.8620269,-1.0488892,1.0262574,3.1092984)
 mat g4q9a=(2.8716455,0,.3471574)
 mat g4q9c=(-3.6906161,-1.5936348,.6377263,3.1938995)
 mat g4q10a=(1.9723144,1.4633664,0)
 mat g4q10c=(-3.2028665,-1.0689037,.9702596,2.9018261)
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
 foreach g of numlist `grouplist' {
  qui count if `touse' & `gvar'==`g'
  if r(N)>0 {
   timer clear 1
   timer on 1
   mat FWBmn=g`g'm
   mat FWBva=g`g'v
   forv q=1/10 {
    mat FWBq`q'a=g`g'q`q'a
    mat FWBq`q'c=g`g'q`q'c
    }
   tempname tmp`g'
   g byte `tmp`g''=min(`touse',`gvar'==`g')
   mata:ipr_fwb("`namelist'","`qqlist'","`tmp`g''",`intpoints',`zlimit',`GHQ')
   timer off 1
   qui timer list 1
   di as res "Group `g' complete in " r(t1) " seconds."
   }
  }
 ret scalar ghq=`GHQ'
 ret scalar intpoints=`intpoints'
 if "`ghq'"==""  ret scalar zlimit=`zlimit'
 }
 qui replace `namelist'=round(`namelist',`round')
 if "`missok'"=="" qui replace `namelist'=. if `allmiss'==1
 ret scalar round=`round'
 ret local name "`namelist'"
end
version 10.2
mata:
void ipr_fwb(string scalar f, string scalar x, string scalar tousename, real intpt, real zlim, real ghq) {
 st_view(y, ., tokens(f), tousename)
 q = st_data(., tokens(x), tousename)
 mean= st_matrix("FWBmn")
 v = st_matrix("FWBva")
 var= diag(v)
 q1a= st_matrix("FWBq1a")
 q1c= st_matrix("FWBq1c")  
 q2a= st_matrix("FWBq2a")   
 q2c= st_matrix("FWBq2c")  
 q3a= st_matrix("FWBq3a")   
 q3c= st_matrix("FWBq3c")  
 q4a= st_matrix("FWBq4a")  
 q4c= st_matrix("FWBq4c")  
 q5a= st_matrix("FWBq5a")  
 q5c= st_matrix("FWBq5c")  
 q6a= st_matrix("FWBq6a")  
 q6c= st_matrix("FWBq6c")  
 q7a= st_matrix("FWBq7a")  
 q7c= st_matrix("FWBq7c")  
 q8a= st_matrix("FWBq8a")  
 q8c= st_matrix("FWBq8c")  
 q9a= st_matrix("FWBq9a")  
 q9c= st_matrix("FWBq9c")  
 q10a=st_matrix("FWBq10a")  
 q10c=st_matrix("FWBq10c")  
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
 theta=(t1,t2,t3)
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
y[.,.]=Pft:/Pf:*15:+50
}
end

