version 16.0
mata:

void _somdtransf(string scalar transf, real matrix theta, real matrix zeta , | real matrix dzeta)
{
/*
  Calculate transformations used in the somersd package
  and (optionally) their derivatives.
  transf contains the transformation name.
  theta contains the input untransformed values of Somers' D or Kendall's tau-a.
  zeta contains the output transformed values.
  dzeta contains the derivatives of the transformed values.
*! Author: Roger Newson
*! Date: 25 May 2012
*/
string colvector transflist
real colvector thetamax
real matrix signtheta
real scalar transfseq, nrtheta, nctheta, thmax, zetaij, done, i1, i2, i3
/*
  transflist contains a list of possible transformation names.
  thetamax contains a list of maximum untransformed values,
  to which input theta values of greater magnitude are reset before transformation.
  signtheta contains the signs of the theta elements.
  transfseq is sequential order of transformation,
  defined as the index of transflist at which transf is found,
  or as zero if transf is not found.
  nrtheta is number of rows of theta.
  nctheta is number of columns of theta.
  thmax contains the chosen element of thetamax.
  zetaij is a scalar for storing an element of zeta.
  done is a flag indicating that a task is done.
  i1, i2 and i3 are counters.
*/

transflist=("iden" \ "z" \ "asin" \ "rho" \ "zrho" \ "c")
thetamax=(1 \ 0.999999999999999 \ 0.999999999999999 \ 1 \ 0.99999999 \ 1)
nrtheta=rows(theta)
nctheta=cols(theta)

/*
  Locate the correct transformation sequence in transflist
  and initialize zeta to truncated value of theta
*/
signtheta=sign(theta)
zeta=abs(theta)
transfseq=0
done=0
for(i1=rows(transflist);!done;i1--) {
  if(transf==transflist[i1]) {
    /* Correct transformation found */
    transfseq=i1
    thmax=thetamax[transfseq]
    for(i2=1;i2<=nrtheta;i2++) {
      for(i3=1;i3<=nctheta;i3++) {
        zetaij=zeta[i2,i3]
        zeta[i2,i3] = missing(zetaij) ? zetaij :  min((thmax , zetaij))
      }
    }
    zeta = zeta :* signtheta
    done=1
  }
  else {
    /* Transformation not found */
    done=i1==1
  }
}

/*
  Apply transformations to truncated theta-values
*/
if(transfseq==0) {
  /* Transformation still not found */
  zeta[.,.]=.
  if (args()>3) {
    dzeta=zeta
  }
}
else if(transfseq==1) {
  /* Identity transformation */
  dzeta=0 :* zeta :+ 1
}
else if(transfseq==2) {
  /* Fisher's z */
  if (args()>3) {
    dzeta = 1 :/ (1 :- zeta :* zeta)
  }
  zeta=0.5*log( (1 :+ zeta) :/ (1 :- zeta) )
}
else if(transfseq==3) {
  /* Daniels' arcsine */
  if (args()>3) {
    dzeta = 1 :/ sqrt(1 :- zeta :* zeta)
  }
  zeta=asin(zeta)
}
else if(transfseq==4) {
  /* Greiner's rho */
  if (args()>3) {
    dzeta = 0.5*pi()*cos(0.5*pi()*zeta)
  }
  zeta=sin(0.5*pi()*zeta)
}
else if(transfseq==5) {
  /* z-transform of Greiner's rho */
  if (args()>3) {
    dzeta = 0.5*pi()*cos(0.5*pi()*zeta)
  }
  zeta=sin(0.5*pi()*zeta)
  if (args()>3) {
    dzeta = dzeta :/ (1 :- zeta :* zeta)
  }
  zeta=0.5*log((1 :+ zeta) :/ (1 :- zeta))
}
else if(transfseq==6) {
  /* Harrell's c */
  if (args()>3) {
    dzeta = 0 :* zeta :+ 0.5
  }
  zeta= 0.5 * (zeta :+ 1)
}

}
end
