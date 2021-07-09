#delimit ;

program define neoclassical, eclass ;
 version 10.1 ;
 args outcome1 timeconstant1 timevarying1 identifiers vselpx
      outcome2 timeconstant2 timevarying2 vsubpx deff clustvar ;
 tempname out1a ;
 tempname out1b ;
 tempname out2a ;
 tempname out2b ;
 gen xones=1 ;
 gen xtwos=1 ;
 quietly heckprob `outcome2' `timeconstant2' `timevarying2',
         sel(`outcome1'=`timeconstant1' `timevarying1' `identifiers')
         cluster(`clustvar') ;
 scalar n1eq=e(N) ;
 scalar n2eq=e(N)-e(N_cens) ;
 matrix accum `out1a'=`timeconstant1' `timevarying1' `identifiers' xones,
          noconstant deviations ;
 matrix `out1b'=(`out1a'/n1eq) ;
 matrix accum `out2a'=`timeconstant2' `timevarying2' xtwos if `outcome1'==1,
          noconstant deviations ;
 matrix `out2b'=(`out2a'/n2eq) ; 
 scalar vselp = `vselpx' ;
 scalar vselp1 = (vselp+1) ;
 scalar vsubp = `vsubpx' ;
 scalar vsubp1 = (vsubp+1) ;
 scalar vforcorr = 1 ;
 scalar vsela = (vsubp1+1) ;
 scalar vselb = (vsubp1+vselp1) ;
 scalar rpos = (vselb+vforcorr) ;
 matrix MyunB=e(b) ;
 matrix out2bcoeff=MyunB[1..1, 1..vsubp1] ;
 matrix out1bcoeff=MyunB[1..1, vsela..vselb] ;
 matrix out2vari=(out2bcoeff*`out2b'*out2bcoeff') + 1 ;
 matrix out1vari=(out1bcoeff*`out1b'*out1bcoeff') + 1 ;
 scalar yvariance2= el(out2vari,1,1) ;
 scalar yvariance1= el(out1vari,1,1) ;
 matrix MystdOUT2B=(out2bcoeff / (sqrt(yvariance2))) ;
 matrix MystdOUT1B=(out1bcoeff / (sqrt(yvariance1))) ;
 matrix Myrho=MyunB[1..1, rpos..rpos] ;
 matrix MyBeta=[MystdOUT2B, MystdOUT1B, Myrho] ;
 matrix MyV=e(V) ;
 matrix TheirVVA=MyV[1..vsubp1, 1..vsubp1] ;
 matrix TheirVVB=MyV[1..vsubp1, vsela..rpos] ;
 matrix TheirVVC=MyV[vsela..rpos, 1..vsubp1] ;
 matrix TheirVVD=MyV[vsela..rpos, vsela..rpos] ;
 matrix VA=TheirVVA/yvariance2 ;
 matrix VB=TheirVVB/((sqrt(yvariance1))*(sqrt(yvariance2))) ;
 matrix VC=TheirVVC/((sqrt(yvariance1))*(sqrt(yvariance2))) ;
 matrix VD=TheirVVD/yvariance1 ;
 matrix VARMULT01=[VA, VB] ;
 matrix VARMULT02=[VC, VD] ;
 matrix VARMULT=`deff'*[VARMULT01 \ VARMULT02] ;
 matrix MyVCVBeta=VARMULT ;
        tempname vmat1 ;
        tempname bmat1 ;
        tempname trans2n ;
        matrix `vmat1' = MyVCVBeta ;
        matrix `bmat1' = MyBeta ;
        ereturn repost V = `vmat1' ;
        ereturn repost b = `bmat1' ;
        scalar `trans2n' = e(N)-e(N_cens) ;
   display "   ><Neo-Classical Education Transitions Model Results, Rho Estimated><" ;
   display "   " ;
   display "     1st Transition Observations: " e(N) ;
   display "     Censored Observations:       " e(N_cens) ;
   display "     2nd Transition Observations: " `trans2n' ;
   display "     Log-likelihood:              " e(ll) ;
   display "     Degrees of freedom:          " e(df_m) ;
   display "     Wald chi-square:             " e(chi2) ;
   display "     Prob > chi2:                 " e(p) ;
   display "     Number of Clusters:          " e(N_clust) ;
   display "   " ;
   ereturn display ;
  drop xones xtwos ;
  matrix drop TheirVVA TheirVVB TheirVVC TheirVVD VA VB VC VD VARMULT01 VARMULT02
  VARMULT MyVCVBeta MyBeta ;
end ;
