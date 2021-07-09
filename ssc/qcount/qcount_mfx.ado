*! Marginal Effects for Quantile for counts
*! Version 2.0.0
*! Author: Alfonso Miranda
*! Date: 6.03.2006

capture program drop qcount_mfx
program define qcount_mfx, rclass
version 9

syntax [if] [in],

marksample touse
mata: MagEff("e(exogv)","`touse'")
drop one
end


mata:
function MagEff(string scalar exogv,
 string scalar touse)
{
 /* Declarations */

 string scalar names
 real vector b, T, xm
 real vector index, G, junk, xmT, seG, dQz
 real matrix V, VG, g, X, out, dQy, out2
 real scalar xb, xb0, xb1, n, K, qn, Qz, Qz_se, Qy
 stata("gen one=1")


 /*Parsing data + relevant matrices*/

 names = (tokens(st_global(exogv)),"one")
 st_view(X,.,names,touse)
 b = st_matrix("e(b)")'
 V = st_matrix("e(V)")
 qn = st_numscalar("e(qv)")
 n = rows(X)
 K = cols(names)

 /* create a vectors with means of exgov*/

 xm = mean(X,1)'

 /* Vector "index" contains 1 if dummy and 0 if no dummy
 and missing if constant. Vectors T 0 if dummy, 1 if no
 dummy or if constant*/

 index = J(rows(b),1,.)
 T = J(rows(xm),1,1)
 for (i=1;i<=(cols(names));i++) {
  stata("scalar junkn = inlist(" + names[1,i] + ",1,0)")
  index[i,1]=st_numscalar("junkn")
  T[i,1] = T[i,1] - st_numscalar("junkn")
 }

 /* Create linear predictors of benchmark case */

 xb=xm'b
 xmT = xm

  /* Calculate Marginal effects*/

 G=b
 for (i=1;i<=cols(names);i++) {
  if (index[i,1] != .) {
   if (index[i,1]==1) {            /*dummy*/
    junk = xmT
    junk[i,1]=0
    xb0 = junk'b
    junk[i,1]=1
    xb1 = junk'b
    G[i,1] = exp(xb1)-exp(xb0)
   }
   else {
    G[i,1]=exp(xb)*G[i,1]   /*continous*/
   }
  }
 }

 /* Obtain the derivative of G with respect to coefficients*/

 g = J(rows(b),rows(b),0)
 for (i=1;i<=cols(names);i++) {
  for (j=1;j<=cols(names);j++) {
   if (index[i,1]==1) {              /*dummy*/
    junk = xmT
    junk[i,1]=0
    xb0 = junk'b
    junk[i,1]=1
    xb1 = junk'b
    if (i==j) g[i,j] = exp(xb1)
    else g[i,j] = (exp(xb1) - exp(xb0))*xmT[j,1]
   }
   if (index[i,1]==0) {             /* continous */
    if (i==j) g[i,j]= exp(xb)*(1 +b[i,1]*xmT[j,1])
    else g[i,j]= b[i,1]*xmT[j,1]*exp(xb)
   }
   if (index[cols(c_names)+i,1]==.) {
    if (i==j) g[i,j]=1
   }
  }
 }

 /* Use the delta method to obtain the covariance matrix of G*/

 VG=g*V*g'

 /* Obtain standard errors */

 seG=sqrt(diagonal(VG))

 /* Standard Error of Qz*/

 Qz = qn + exp(xb)
 dQz = J(1,rows(b),0)
 for (i=1;i<=cols(names);i++) {
  dQz[1,i] = exp(xb)*xmT[i,1]
 }
 Qz_se = sqrt(dQz*V*dQz')

 /* Marginal Effects on Qy */

 Qy = ceil(Qz-1)
 dQy = J(cols(names),3,0)
 for (i=1;i<=cols(names);i++) {
  dQy[i,1] = ceil(Qz+G[i,1]-1)-ceil(Qz-1)
  dQy[i,2] = ceil(Qz+G[i,1]-1.96*seG[i,1]-1)-ceil(Qz-1)
  dQy[i,3] = ceil(Qz+G[i,1]+1.96*seG[i,1]-1)-ceil(Qz-1)
 }

 /* Put results in a matrix */

 out = (G,seG,G:/seG,2*normal(-abs(G:/seG)),G:-1.96*seG,G:+1.96*seG,xmT)
 out2 = (dQy,xmT)

 /* save output in stata*/

 st_matrix("ME_Qz",out)
 st_matrix("ME_Qy",out2)

 /* Display results Qz */

 printf("\n")
 printf("{txt} Marginal effects after qcount\n")
 printf("        y = Qz({res}%3.2f{text}|X)\n",qn)
 printf("          = {res}%8.5f{text} ({res}%5.4f{text})\n",Qz,Qz_se)
 printf("{text}{hline 16}{c TT}{hline 63}\n")
 printf("{txt}{space 16}{c |}      ME     Std. Err.      z    P>|z|  [  95%% C.I  ]       X\n")
 printf("{hline 16}{c +}{hline 63}\n")
 for (i=1;i<=cols(names)-1;i++) {
  printf("{txt}%-15s {c |} {res}%10.0g {res}%10.0g  {res}%6.3g {res}%7.4f {res}%7.4f {res}%7.4f {res}%7.2f \n",
    names[1,i],out[i,1],out[i,2],out[i,3],out[i,4],out[i,5],out[i,6],out[i,7])
 }
 printf("{txt}{hline 16}{c BT}{hline 63}\n")
 printf("\n")

 /* Display results Qy */

 printf("\n")
 printf("{txt} Marginal effects after qcount\n")
 printf("        y = Qy({res}%3.2f{text}|X)\n",qn)
 printf("          = {res}%1.0f \n",Qy)
 printf("{text}{hline 16}{c TT}{hline 25}\n")
 printf("{txt}{space 16}{c |} ME{space 2}[95%% C. Set]    X\n")
 printf("{hline 16}{c +}{hline 25}\n")
 for (i=1;i<=cols(names)-1;i++) {
  printf("{txt}%-15s {c |} {space 1}{res}%1.0f{space 6}{res}%1.0f{space 2}{res}%1.0f{space 4}{res}%7.2f\n",
    names[1,i],out2[i,1],out2[i,2],out2[i,3],out2[i,4])
 }
 printf("{txt}{hline 16}{c BT}{hline 25}\n")
 printf("\n")
}


end
