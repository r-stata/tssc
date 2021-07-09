*! Date    : 7 Aug 2014
*! Version : 1.03
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

*! Sample size calculation for Flemming single-stage design

/*
  2Jun2009 v1.00 The command is born
 29Jun2009 v1.01 The output didn't print the p0 and p1 values
  9Mar2010 v1.02 Translate the code to Mata
  7Aug2014 v1.03 Corrected the displayed power was power and not beta!
*/

program define sampsi_fleming, rclass
version 11.0
preserve
syntax [, p0(real 0.2) p1(real 0.4) Alpha(real 0.05) Power(real 0.9) N(integer 84) R(integer 13) Start(integer 1) CHECK]

local beta = 1-`power'
if "`check'"~="" {
  mata: check_design(`p0',`p1',`n',`r')
}
else {
  mata: design = singlestage(`p0', `p1', `alpha', `beta', `start')
  return local r= A[1,1]
  return local n= A[1,2]
}

end

/*****************
 * Start of MATA
 *****************/
mata: 
void singlestage(real scalar p0, real scalar p1, real scalar alpha, real scalar beta, real scalar startn)
{

  found=0
  n=startn
  while (!found) {
    for(r=0; r<=n; r++) {
      ep1 = binomialtail(n, r, p0)
      ep2 = binomialtail(n, r, p1)
      if ((ep1<=alpha)&((1-ep2)<=beta)) {
        bestn =n
        bestr =r
        besta = ep1
        bestp = ep2
        found++
      }
    }
    if (mod(n,1000)==0) printf("{err}n exceeds %g, you might want to change the options\n", n)
    n++
  }
  
  printf("\n{txt}Sample size calculation for the Fleming design\n")
  printf("{dup 46:{c -}}\n")
  printf("H0: p <= p0\n")
  printf("H1: p > p0\n\n")
  printf("{txt}p0 = %g  p1=%g\n", p0, p1)
  printf("{txt}With a sample size of {res} %g\n",bestn)
  printf("{txt}the null hypothesis is rejected if there are {res}>= %g {txt}responders\n", bestr)
  printf("{txt}Type I error = {res}%5.4f\n", besta)
  printf("{txt}Power        = {res}%5.4f\n\n", bestp)

  design = (bestr, bestn)
  st_matrix("A", design)
}
void check_design(real scalar p0, real scalar p1, real scalar n, real scalar r)
{
  alpha = binomialtail(n, r, p0)
  power = binomialtail(n, r, p1)
  printf("\n{txt}Sample size calculation for the Fleming design\n")
  printf("{dup 46:{c -}}\n")
  printf("H0: p <= p0\n")
  printf("H1: p > p0\n\n")
  printf("{txt}p0 = %g  p1=%g\n", p0, p1)
  printf("{txt}With a sample size of {res} %g\n",n)
  printf("{txt}the null hypothesis is rejected if there are {res}>= %g {txt}responders\n", r)
  printf("{txt}Type I error = {res}%5.4f\n", alpha)
  printf("{txt}Power        = {res}%5.4f\n\n", power)

}

end
