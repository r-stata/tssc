*! Date    : 19 May 2018
*! Version : 1.00
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! The fully flexible design 

/* 
START HELP FILE

title[
A command to find the optimal flexible two stage single-arm binary outcome design 
using the discrete conditional error function.
]

desc[
This command creates a two-stage fully flexible design with a binary outcome variable, often response or not,
 that uses a conditional error function. The design usually is interested in rejecting the null hypothesis
that response is {bf:H0: p=p0}. The methods are published by S. Englert and M. Keiser (2012)
Improving the flexibility and efficiency of phase 2 designs for oncology trials, Biometrics.

A discrete conditional error function, D(i) is defined for the number of responders, i, in the first phase 
of the trial. If the second stage p-value is < D(i) then the null hypothesis is rejected. The function D() must 
be non-decreasing with i but this command allows no other restrictions on what D() can take. However, 
there is no point picking values other than the discrete set of second stage p-values.

However, there are a huge number of possible first stage and second stage sample sizes but this command will
search over a range of values and find the optimal one. It can take a huge amount of time if you pick large 
sample sizes but the search
uses a branch and bound algorithm, so is efficient. Currently the optimal one is one that has the smallest expected
sample size at p0.
]

opt[p1() specifies the alternative probability that the study is powered for.]
opt[p0() specifies the null probability that is used in the null hypothesis.]
opt[alpha() specifies the significance level.]
opt[beta() specifies the type II eror level.]
opt[n1min() specifies the minimum first stage sample size.]
opt[n1max() specifies the maximum first stage sample size.]
opt[ n2min() specifies the minimum second stage sample size.]
opt[n1n1max() specifies the maximum total sample size to search over.]

example[
Assuming that p0=0.1, p1=0.5,we can run the command 

{stata cedesign, p0(0.1) p1(0.5) n1min(5) n1n2max(30)}
]

author[Dr Adrian Mander]
institute[MRC Biostatistics Unit, University of Cambridge]
email[adrian.mander@mrc-bsu.cam.ac.uk]

seealso[

{help simon2stage} (if installed) install by clicking {stata ssc install simon2stage}

{help crm} (if installed) install by clicking {stata ssc install crm}
]

END HELP FILE
*/

/*
11May18  v1.00 The command is born
*/

pr cedesign
version 15.1
preserve
syntax [, p1(real 0.3) p0(real 0.1) alpha(real 0.05) beta(real 0.1) n1min(integer 2) ///
          n1max(integer 22) n2min(integer 2) n1n2max(integer 50)]

mata: find_design(`p0', `p1', `alpha', `beta', `n1min', `n1max', `n2min', `n1n2max')

end
mata:

void find_design(real p0, real p1, real alpha, real beta,  n1min, n1max,  n2min,  n1n2max)
{
  printf("{txt}\nFinding the flexible two stage design using conditional error functions\n")
  printf("{dup 71:{c -}}\n")
  printf("{txt}p0    = {res}%f\n", p0)
  printf("{txt}p1    = {res}%f\n", p1)
  printf("{txt}alpha = {res}%f\n", alpha)
  printf("{txt}beta  = {res}%f\n", beta)
  
  printf("{txt}\nStarting the branch and bound algorithm \n")

  FD=.
  FOC=.
  Fn2=.
  Fn1=.
  FRDpv2 = .
/* loop over all designs conditional on n1 */
  minEN = . /* set min Expected sample size as missing*/
  printf("Starting loop of n1\n")
  for (n1=n1min;n1<=n1max; n1++) {
    if (n1>minEN) continue
    printf("{res}.%f",n1)
	displayflush()
    for (n2=n2min;n2+n1<=n1n2max;n2++) {
     /* some initialisations*/
      pv2 = binomialtail(n2,(0..n2),p0)       /* vector of P(X2>=l)   there are  n2+1 pvalues */
      pmf1 = binomialp(n1,(0..n1),p0)
      pmf2 = binomialp(n2,(0..n2),p0)
      pmf1h1 = binomialp(n1,(0..n1),p1)
      pmf2h1 = binomialp(n2,(0..n2),p1)
      RDpv2 = (0,binomialtail(n2,(n2..0),p0)) /* D refers to all possible p-values and 0 in reverse order */
/******************************************************************************
 * D is a conditional error function based on the number of responders in 
 * stage 1 i.e. is dimension n1+1 but can take any value of the 2nd stage p-values
 * Start at the lowest D=(1,1,...,1) note RDpv2(D) gives you the CE function
 ******************************************************************************/
      D=J(1,n1+1,1)
      while ( (D~=J(1,n1+1,n2+2)) & (D~=J(1,n1+1,n2+3))) {
        /*if (!checkorder(D)) {  /* not sure this is a problem anymore */
		  printf("{err}order problem\n")
          D = createD(D) /* might need a check*/
        }
		*/
        for(j=1;j<=n1;j++){
          OC = partial_oc(j,D, pmf1, RDpv2, pmf2h1, pmf1h1, n1, n2, pv2)
	      if (OC[1,1]>alpha) { /* failed on alpha control */ 
	        D =getnextD(D,j,n2+1) 
	        j=n1+1
	        continue
	      }
	      else if (OC[1,2]>beta) { /* failed on beta control */
	        D = getnextD(D,j,n2+1)
	        j=n1+1
	        continue
	      }
	      else if (OC[1,3]>minEN) { /* failed on beating another design on expected sample size */
	        D = getnextD(D,j,n2+1)
	        j=n1+1
	        continue
	      }
	      else if (j==n1) { /* Design has been found and they are stored */
	        FD=D
	        FOC=OC
	        FRDpv2 = RDpv2
			Fn2 = n2
			Fn1 = n1
	        minEN = OC[1,3]
	        D=nearnextD(D, n2)
	      }
        }
      }

    } /*end of n2 loop */
  } /* end of n1 loop */

  printf("\n{txt}The best conditional error function\n")
  FRDpv2[FD]'
  printf("The operating characteristics (alpha,beta, E(N))\n")
  FOC
  printf("Sample sizes  n1={res}%f  {txt}n2={res}%f\n", Fn1, Fn2)
}/* end of find_design()*/

/***********************************************************************
 * Figure out the next design after having failed to find a design at element j
 ***********************************************************************/
real vector getnextD(D,j,n)
{
 len = cols(D)
 if(D[1,j]~=n+1) {  /* check jth element isn't max n2+2 */
  if (j>1)  nextD = D[1..j-1], J(1,len+1-j,D[1,j]+1)
  else nextD = J(1,len,D[1,j]+1)
 }
 else {
   if (D[1,1]==n+1) return(D:+1)
   if ((j==2) & (D[1,2]==n+1) ) nextD = J(1,len, D[1,1]+1)
   if (j>2) nextD = D[1..j-2], J(1,len+2-j,D[1,j-1]+1)
 }
 return(nextD)
}
 /******************************************************************
 * Figure out the next D by adding one to the next non-max element 
 * and making sure it is ordered
 *******************************************************************/
 real vector nearnextD(D,n) /* n here is the sample size of 2nd stage */
{
 for(i=cols(D);i>1;i--) {
   if(D[1,i]~=n+2) {
     return( D[1..i-1], J(1,cols(D)-i+1,D[1,i]+1) )
   }
 }
 return( J(1,cols(D),n+2) )
}

/*************************************************
 * Check vector non-decreasing and returns 1 or 0
 *************************************************/
real checkorder(real vector chk)
{
 for(i=1;i<cols(chk);i++) {
   if (chk[i]>chk[i+1]) return(0)
 }
 return(1)
}

/*************************************************
 * Check vector non-decreasing and returns 1 or 0
 *************************************************/
real createD(real vector cretD)
{
 retD = cretD
 for(i=1;i<cols(cretD);i++) {
   if (cretD[i]>cretD[i+1]) {
     retD[1,i+1..cols(retD)]=J(1,cols(retD)-i,retD[1,i]) 
	 continue
   }
 }
 return(retD)
}

/**********************************************************************
 * This code calculates the alpha and beta for a given D with it only 
 * partially created 
 * here it is the element-th value that is truncated
 * D is defined for first 0 to element responses
 **********************************************************************/
real vector partial_oc(element, subD, pmf1, Dpv2, pmf2h1, pmf1h1, n1, n2, pv2) 
{
  /* For alpha just fill in the missing values as the last value */
  if (element==n2) { /* This does direct calculation on current D()*/
    alpha = sum(Dpv2[subD] :* pmf1)
    /* Expected sample size */
    EN = n1+ sum( (1:-((Dpv2[subD] :==0) :+ (Dpv2[subD] :==1 ))) :* pmf1) * n2
    /* Power P_H1(P2<= D(p1)) is pv2 <= D(p1) */
    power=0
    for (i=1;i<=cols(subD);i++) {
      power = power +  sum(pmf2h1:*(pv2:<=Dpv2[subD[1,i]]) ) * pmf1h1[i] 
    }
  }
  else { /* This is the bound part of the algorithm */
    newD=subD[1..element],J(1,n1+1-element,subD[1,element])
    newD2=subD[1..element],J(1,n1+1-element,n2+2)  /* add max possible i.e. n2+2 to min beta */
    newD3=subD[1..element],J(1,n1+1-element,1)     /* add in more terminations */
    alpha = sum(Dpv2[newD] :* pmf1)
    /* Expected sample size */
    EN = n1+ sum( (1:-((Dpv2[newD3] :==0) :+ (Dpv2[newD3] :==1 ))) :* pmf1) * n2
    /* Power P_H1(P2<= D(p1)) is pv2 <= D(p1) */
    power=0
    for (i=1;i<=cols(newD2);i++) {
      power = power +  sum(pmf2h1:*(pv2:<=Dpv2[newD2[1,i]]) ) * pmf1h1[i] 
    }
  }
  return(alpha,1-power, EN)
} /* end of partial_oc() */

end /*end of mata*/
