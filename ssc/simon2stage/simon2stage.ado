*! Date    : 13 Jan 2012
*! Version : 1.09
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! The Simon two stage design written for Stata 11.0 with Mata

/* Example commands
simon2stage, p0(0.1) p1(0.3)admiss eff minn(33)
simon2stage, p0(0.1) p1(0.3) beta(0.15) admiss eff minn(33)
simon2stage, p0(0.1) p1(0.5) beta(0.15) admiss eff maxn(14) minn(7)
simon2stage, p0(0.1) p1(0.5) beta(0.15) admiss maxn(14) minn(7)
*/
/*
 09/06/09  v1.00 The command is born
 18/11/09  v1.02 The command is extended to Mata and stopping for efficacy
 25/11/09  v1.03 checking some weird results that meant stopping for efficacy was worse!
  1/ 2/10  v1.04 Added the return list and added the A&B matrices to the Mata code
 11/ 5/10  v1.05 BUG FIX - returned a1
 11/11/10  v1.06 Added the option to find the delta-minimax
  3/12/10  v1.07 Added admissible design code
 19/ 5/11  v1.08 Going to add in the vectorised version to benefit from MATA MP
 13/ 1/12  v1.09 Bug on output
*/

pr simon2stage, rclass
version 11.0
syntax [,p0(real 0.1) p1(real 0.4) alpha(real 0.05) beta(real 0.2) MINN(real 1) MAXN(real 35) /*
*/ OPTIMAL OPTP(real -1) DIsplay(int 200000) EFF NOISE DELTAminimax ADMISS FAST]

/********************************************************************
 * Argument checking
 * Although we are now just going to look for the optp
 * The default optimal probability is set as  p0 if there are errors
 ********************************************************************/
 
if "`optp'"=="-1" {
  local optp `p0'
  local optptxt "p0"
}
else if `optp'<0 {
  local optp `p0'
  local optptxt "p0"
}
else if `optp'>1 {
  local optp `p0'
  local optptxt "p0"
}
local optptxt: di %4.2f `optp'

if `minn'>`maxn' {
  di "{err} Warning: minn() value should be less than maxn() value"
  local maxn `minn'
}
local startmin `minn'

if "`deltaminimax'"~="" & "`eff'"=="" {
  di "{err} Warning: the deltaminimax design is the minimax design when not stopping for efficacy"
  di "to use the deltaminimax option you must specify the eff option as well"
  exit(198)  
}

/******************************************************************
 * The admissible design if statement
 ******************************************************************/

if "`admiss'"=="" {
  /******************************************************************
   * This does the optimal or minimax without stopping for efficacy
   ******************************************************************/
  if "`eff'"=="" mata: s2s(`p0', `p1', `optp', `alpha', `beta', `minn', `maxn', "`optimal'", "`noise'", `display')
  /****************************************************************
   * Mata command does the optimal or minimax OR deltaminimax
   ****************************************************************/
  else mata: a2s(`p0', `p1', `optp', `alpha', `beta', `minn', `maxn', "`optimal'", "`noise'", `display', "`deltaminimax'")
}
else{
  if "`fast'"=="" {
    di
    di "{err} NOTE: The admiss() option may take a long time"
    if "`eff'"=="" mata: admisss2s(`p0', `p1', `optp', `alpha', `beta', `minn', `maxn', "`optimal'", "`noise'", `display')
    else mata: admissa2s(`p0', `p1', `optp', `alpha', `beta', `minn', `maxn', "`optimal'", "`noise'", `display')
  }
  else {
    if "`eff'"=="" mata: vecadmisss2s(`p0', `p1', `optp', `alpha', `beta', `minn', `maxn', "`optimal'", "`noise'", `display')
    else mata: vecadmissa2s(`p0', `p1', `optp', `alpha', `beta', `minn', `maxn', "`optimal'", "`noise'", `display')
  }
  
}

/*******************************************************
 * Create the scatter plot from the admissible designs
 *******************************************************/
if "`admiss'"~="" {
  cap clear
  qui svmat grid
  if "`eff'"=="" qui gen d = "{"+string(grid3)+"/"+string(grid4)+" "+string(grid5)+"/"+string(grid6)+"}"
  else qui gen d = "{("+string(grid3)+" "+string(grid4)+")/"+string(grid5)+" "+string(grid6)+"/"+string(grid7)+"}"
  lab var grid1 "q0"
  lab var grid2 "q1"
  rename grid1 g1
  rename grid2 g2
  preserve
  sort d
  qui by d:keep if _n==1
  forv i=1/`=_N' {
    local tmp = d[`i']
    local leg `"`leg'lab(`i' "`tmp'") "'
    local g `"`g'(scatter g1 g2 if d=="`tmp'",ms(s) msize(*.75))"'
  }
  restore
  di "NOTE: Just about to create plot of the admissible designs"
  twoway `g', legend(on cols(1) `leg' ring(0) pos(2)) aspect(1) title(Admissible designs) subtitle("n {&isin}[`minn',`maxn']") /*
  */ note("({&alpha},{&beta},p0,p1)=(`alpha',`beta',`p0',`p1')")
}

/*************************************************************
 * Return the values EN and PET for H0, H1 and Hopt
 * The A matrix is created at the end of the Mata functions
 *************************************************************/

if "`admiss'"=="" {
  return local EN0 = A[1,1]
  return local EN1 = A[1,2]
  return local ENo = A[1,3]
  return local PET0 = A[2,1]
  return local PET1 = A[2,2]
  return local PETo = A[2,3]
  return local r1 = B[1,1]
  return local n1 = B[1,2]
  return local r = B[1,3]
  return local n = B[1,4]
  if "`eff'"~="" return local a1 = B[1,5]
}

end

/********************************
 * Start of MATA commands       *
 ********************************/
 
mata:

/********************************
 * The minimum of two numbers
 ********************************/
 
real mymin(real scalar a, real scalar b) 
{
  if (a<b) return(a)
  else return(b)
}

/********************************************************
 * All the calculations needed for the binomial sums
 ********************************************************/

void s2s(p0, p1, po, alpha, beta, minn, maxn, optimal, noise , display)
{

printf("\n{txt}Simon's Two Stage Design\n")
printf("{dup 24:{c -}}\n")
printf("A design is indexed by four values {res} r1/n1 r/n \n")

printf("{txt}Type I error ={res} %g\n", alpha)
printf("{txt}Power        ={res} %g\n", 1-beta)
printf("{txt}H0: p = p0\n")

printf("{txt}H1: p = p1 >=p0\n")
printf("{txt}where p0 is {res}%g{txt} and p1 is {res}%g\n\n", p0, p1)

printf("{txt}The study is stopped if there are <= r1 responders out of the first n1 participants\n")
printf("The null hypothesis is rejected if there are >r responders out of n participants\n")

printf("{txt}R(p) is the probability of concluding there is no evidence of a treatment effect\n")
printf("PET(p) is the probability of early termination\n")
printf("EN(p) is the expected sample size\n\n")
printf("{txt}NOTE: this program searches many designs and can take a while to find the best design\n")
printf("An occassional design is displayed with The current best design is always displayed\n\n")

if (optimal=="") printf("{txt}This algorithm is searching for the {res}minimax {txt}design\n")
else printf("{txt}This algorithm is searching for the Optimal design i.e smallest {res}EN(%g)\n", po)

printf("{txt}Design {col 17}R(p0) {col 26} R(p1) {col 36}PET(%g){col 46}EN(%g)\n",po, po)

currentmin = 10000000000
found = 0

/***************************************
 * Check what we are optimising 
 ***************************************/
if (optimal=="optimal") minimax=0
else minimax = 1

n=minn
count=1
while(!found) {
  while(n<=maxn) {
    for(r=0; r<=n; r++) {
      for(n1=1; n1<= mymin(n,currentmin); n1++) {
        for(r1=0; r1<= mymin(r,n1); r1++) {
          sum0 =0
          sum1 =0
          sumo =0

          for(x=r1+1;x<=mymin(r,n1);x++) {
            sum0 = sum0+binomialp(n1,x,p0)*binomial(n-n1,r-x,p0)
            sum1 = sum1+binomialp(n1,x,p1)*binomial(n-n1,r-x,p1)
            sumo = sumo+binomialp(n1,x,po)*binomial(n-n1,r-x,po)
          }
          Rp0 = binomial(n1,r1,p0)+sum0
          PETp0 = binomial(n1,r1,p0)
          ENp0 = PETp0*n1+(1-PETp0)*n
          Rp1 = binomial(n1,r1,p1)+sum1
          PETp1 = binomial(n1,r1,p1)
          ENp1 = PETp1*n1+(1-PETp1)*n
          Rpo = binomial(n1,r1,po)+sumo
          PETpo = binomial(n1,r1,po)
          ENpo = PETpo*n1+(1-PETpo)*n
        
          if ((ENpo<currentmin) & (Rp0 >= 1-alpha) & (Rp1 <= beta)) {
            currentmin=ENpo
            found = 1
            printf("{txt} %g/%g %g/%g {res} {col 17}%5.3f {col 26}%5.3f {col 36}%5.3f {col 46}%7.3f  {txt}(Best design so far)\n" , r1, n1, r, n, Rp0, Rp1, PETpo, ENpo)
            mr1=r1
            mr=r
            mn1=n1
            mn=n
            men0 = ENp0
            mpetp0 = PETp0
            men1 = ENp1
            mpetp1 = PETp1
            meno = ENpo
            mpetpo = PETpo
            mpe1 = Rp0
            mpe2 = Rp1
          }
        
          if (mod(count,display)==0 & count>1) printf("{txt}%g/%g %g/%g {res} {col 17}%5.3f {col 26}%5.3f {col 36}%5.3f {col 46}%7.3f \n", r1, n1, r, n, Rp0, Rp1, PETpo, ENpo)
          count++
        }
      }
    }

  if ((found) & (minimax)) {
    printf("\n{txt} The minimax design is             {res}%g/%g %g/%g\n", mr1, mn1, mr, mn)
    printf("{txt}  Expected sample size is          {res} %7.3f\n", meno)
    printf("{txt}  Probability of early termination {res}   %5.3f\n", mpetpo)
    printf("{txt}  Probability of type 1 error      {res}   %5.3f\n", 1-mpe1)
    printf("{txt}  Probability of type 2 error      {res}   %5.3f\n", mpe2)
    n=maxn+1
  }

    n++
  }

  if (!found) {
    minn=maxn
    maxn++
    printf("{err}Increasing n by 1 to %g\n", maxn)
    displayflush()
  }

}

if ((found) & !(minimax)) {
  printf("\n{txt}The optimal design at p={res}%g{txt} (%g<= n <= %g) {res}%g/%g %g/%g\n", po, minn, maxn, mr1, mn1, mr, mn)
  printf("{txt}    Expected sample size is             {res} %7.3f\n", meno)
  printf("{txt}    Probability of early termination    {res}   %5.3f\n", mpetpo)
  printf("{txt}    Probability of type 1 error         {res}   %5.3f\n", 1-mpe1)
  printf("{txt}    Probability of type 2 error         {res}   %5.3f\n", mpe2)
}

/* Print everything for the best design*/

if (noise=="noise") {
  printf("\n{txt}EN(p0)= {res}%7.3f\n", men0)
  printf("{txt}EN(p1)= {res}%7.3f\n", men1)
  printf("{txt}EN(po)= {res}%7.3f\n", meno)
  printf("{txt}PET(p0)= {res}%7.3f\n", mpetp0)
  printf("{txt}PET(p1)= {res}%7.3f\n", mpetp1)
  printf("{txt}PET(po)= {res}%7.3f\n", mpetpo)
}

/**********************************************************
 * Create matrices of results and then pass back to Stata 
 * and then eventually return
 **********************************************************/
results = ( men0, men1, meno \ mpetp0, mpetp1, mpetpo )
design = (mr1, mn1, mr, mn)
st_matrix("A", results)
st_matrix("B", design)


}/*END of s2s function!*/

/********************************************************
 * The ade 2 stage design stopping for efficacy
 ********************************************************/

void a2s(p0, p1, po, alpha, beta, minn, maxn, optimal, noise, display, deltaminimax)
{

printf("\n{txt}Simon's Two Stage Design with stopping for Efficacy\n")
printf("{dup 51:{c -}}\n")
printf("A design is indexed by five values {res}(r1 a1)/n1 r/n\n")

printf("{txt}Type I error ={res} %g\n", alpha)
printf("{txt}Power        ={res} %g\n", 1-beta)
printf("{txt}H0: p = p0\n")

printf("{txt}H1: p = p1 >=p0\n")
printf("{txt}where p0 is {res}%g{txt} and p1 is {res}%g\n\n", p0, p1)

printf("{txt}The study is stopped for futility if there are <= r1 responders out of the first n1 participants\n")
printf("{txt}The study is stopped for efficacy if there are >a1 responders out of the first n1 participants\n")
printf("The null hypothesis is rejected if there are >r responders out of n participants\n")

printf("{txt}R(p) is the probability of concluding there is no evidence of a treatment effect\n")
printf("PET(p) is the probability of early termination\n")
printf("EN(p) is the expected sample size\n\n")
printf("{txt}NOTE: this program searches many designs and can take a while to find the best design\n")
printf("An occassional design is displayed with The current best design is always displayed\n\n")

if (deltaminimax~="") printf("{txt}This algorithm is searching for the {res}delta-minimax {txt}design\n")
if ((optimal=="")&(deltaminimax=="")) printf("{txt}This algorithm is searching for the {res}minimax {txt}design\n")
else printf("{txt}This algorithm is searching for the Optimal design i.e smallest {res}EN(%g)\n", po)

printf("{txt}Design {col 17}R(p0) {col 26} R(p1) {col 36}PET(%g){col 46}EN(%g)\n",po, po)

/*********************************************************
 * Set the smallest expected sample size as a big number
 * and state we haven't found the best design
 *********************************************************/
 
currentmin = 10000000000
found = 0

/*****************************************
 * Check what we are optimising 
 *****************************************/
if (optimal=="optimal") minimax=0
else minimax = 1


n=minn
count=1
while(!found) {

/****************************
 * loop through every design
 ****************************/
  while(n<=maxn) {
    for(r=0; r<=n; r++) {
      for(n1=1; n1<= mymin(n,currentmin); n1++) {
        for(r1=0; r1<= mymin(r,n1); r1++) {
          for(r2=r1; r2<= n1; r2++) { /*NOTE: It is possible to have r2>r &r2<=n1 but weird design*/
            /****************************************
             * Work out the reject H0 probabilities 
             ****************************************/
            sum0 =0
            sum1 =0
            sumo =0

            for(x=r1+1;x<=mymin(r2,n1);x++) {
              sum0 = sum0+binomialp(n1,x,p0)*binomial(n-n1,r-x,p0)
              sum1 = sum1+binomialp(n1,x,p1)*binomial(n-n1,r-x,p1)
              sumo = sumo+binomialp(n1,x,po)*binomial(n-n1,r-x,po)
            }
           /*************************
            * THE PETs have changed
            *************************/
            Rp0 = binomial(n1,r1,p0)+sum0
            PETp0 = 1-binomial(n1,r2,p0)+binomial(n1,r1,p0)
            ENp0 = PETp0*n1+(1-PETp0)*n
            Rp1 = binomial(n1,r1,p1)+sum1
            PETp1 = 1-binomial(n1,r2,p1)+binomial(n1,r1,p1)
            ENp1 = PETp1*n1+(1-PETp1)*n
            Rpo = binomial(n1,r1,po)+sumo
            PETpo =  1-binomial(n1,r2,po)+binomial(n1,r1,po)
            ENpo = PETpo*n1+(1-PETpo)*n

            EMAXpsi = ( ( (factorial(n1-r2-1))*factorial(r2) )/( factorial(r1)*factorial(n1-r1-1) ) )^(1/(r2-r1))
            EMAXp = EMAXpsi/(1+EMAXpsi)
            PETmax= 1- binomial(n1,r2,EMAXp) + binomial(n1,r1,EMAXp)
            ENmax = n-(n-n1)*PETmax
            if (deltaminimax~="") {
              if ((ENmax<currentmin) & (Rp0 >= 1-alpha) & (Rp1 <= beta)) {
               currentmin=ENmax
               found = 1
               printf("{txt}(%g %g)/%g %g/%g {res} {col 17}%5.3f {col 26}%5.3f {col 36}%5.3f {col 46}%7.3f  {txt}(Best design so far)\n" , r1, r2, n1, r, n, Rp0, Rp1, PETmax, ENmax)
               mr1=r1
               mr2=r2
               mr=r
               mn1=n1
               mn=n
               men0 = ENp0
               mpetp0 = PETp0
               men1 = ENp1
               mpetp1 = PETp1
               meno = ENpo
               mpetpo = PETpo
               mpe1 = Rp0
               mpe2 = Rp1
             }            
            }
            else {
              if ((ENpo<currentmin) & (Rp0 >= 1-alpha) & (Rp1 <= beta)) {
               currentmin=ENpo
               found = 1
               printf("{txt}(%g %g)/%g %g/%g {res} {col 17}%5.3f {col 26}%5.3f {col 36}%5.3f {col 46}%7.3f  {txt}(Best design so far)\n" , r1, r2, n1, r, n, Rp0, Rp1, PETpo, ENpo)
               mr1=r1
               mr2=r2
               mr=r
               mn1=n1
               mn=n
               men0 = ENp0
               mpetp0 = PETp0
               men1 = ENp1
               mpetp1 = PETp1
               meno = ENpo
               mpetpo = PETpo
               mpe1 = Rp0
               mpe2 = Rp1
             }
            }
            if (mod(count,display)==0 & count>1 ) printf("{txt}(%g %g)/%g %g/%g {res} {col 17}%5.3f {col 26}%5.3f {col 36}%5.3f {col 46}%7.3f \n", r1, r2, n1, r, n, Rp0, Rp1, PETpo, ENpo)
            count++
          } /*r2 loop*/
        } /*r1 loop */
      } /*n1 loop*/
    } /*r loop*/

    if ((found) & (minimax)) {
      printf("\n{txt} The minimax design is             {res}(%g %g)/%g %g/%g\n", mr1, mr2, mn1, mr, mn)
      printf("{txt}  Expected sample size is          {res} %7.3f\n", meno)
      printf("{txt}  Probability of early termination {res}   %5.3f\n", mpetpo)
      printf("{txt}  Probability of type 1 error      {res}   %5.3f\n", 1-mpe1)
      printf("{txt}  Probability of type 2 error      {res}   %5.3f\n", mpe2)
      n=maxn+1
    }

    n++
  } /* n loop */

  if (!found) {
    minn=maxn
    maxn++
    printf("{err}Increasing n by 1 to %g\n", maxn)
    displayflush()
  }

}

if ((found) & !(minimax)) {
  printf("\n{txt}The optimal design at p={res}%g{txt} (%g<= n <= %g) {res}(%g %g)/%g %g/%g\n", po, minn, maxn, mr1, mr2, mn1, mr, mn)
  printf("{txt}    Expected sample size is             {res} %7.3f\n", meno)
  printf("{txt}    Probability of early termination    {res}   %5.3f\n", mpetpo)
  printf("{txt}    Probability of type 1 error         {res}   %5.3f\n", 1-mpe1)
  printf("{txt}    Probability of type 2 error         {res}   %5.3f\n", mpe2)
}

/*Print everything for the best design*/

if (noise=="noise") {
  printf("\n{txt}EN(p0)= {res}%7.3f\n", men0)
  printf("{txt}EN(p1)= {res}%7.3f\n", men1)
  printf("{txt}EN(po)= {res}%7.3f\n", meno)
  printf("{txt}PET(p0)= {res}%7.3f\n", mpetp0)
  printf("{txt}PET(p1)= {res}%7.3f\n", mpetp1)
  printf("{txt}PET(po)= {res}%7.3f\n", mpetpo)
}
  
/**********************************************************
 * Create matrices of results and then pass back to Stata 
 * and then eventually return
 **********************************************************/
results = ( men0, men1, meno \ mpetp0, mpetp1, mpetpo )
design = (mr1, mn1, mr, mn, mr2)
st_matrix("A", results)
st_matrix("B", design)

}/*END of a2s() function!*/

/********************************************************
 * The admiss 2 stage design stopping for efficacy
 ********************************************************/

void admissa2s(p0, p1, po, alpha, beta, minn, maxn, optimal, noise, display)
{

printf("\n{txt}Simon's Two Stage Design with stopping for Efficacy\n")
printf("{dup 51:{c -}}\n")
printf("A design is indexed by five values {res}(r1 a1)/n1 r/n\n")
printf("{txt}Type I error ={res} %g\n", alpha)
printf("{txt}Power        ={res} %g\n", 1-beta)
printf("{txt}H0: p = p0\n")
printf("{txt}H1: p = p1 >=p0\n")
printf("{txt}where p0 is {res}%g{txt} and p1 is {res}%g\n\n", p0, p1)
printf("{txt}The study is stopped for futility if there are <= r1 responders out of the first n1 participants\n")
printf("{txt}The study is stopped for efficacy if there are >a1 responders out of the first n1 participants\n")
printf("The null hypothesis is rejected if there are >r responders out of n participants\n\n")
printf("{txt}This algorithm is searching for the set of {res}admissible {txt}designs\n\n")


found=0
n=minn
count=1
while(!found) {

/*****************************
 * loop through EVERY design
 *****************************/
  while(n<=maxn) {
    for(r=0; r<=n; r++) {
      for(n1=1; n1<= n; n1++) {
        for(r1=0; r1<= mymin(r,n1); r1++) {
          for(r2=r1; r2<= n1; r2++) { /*NOTE: It is possible to have r2>r &r2<=n1 but weird design*/
            /****************************************
             * Work out the reject H0 probabilities 
             ****************************************/
            sum0 =0
            sum1 =0
            for(x=r1+1;x<=mymin(r2,n1);x++) {
              sum0 = sum0+binomialp(n1,x,p0)*binomial(n-n1,r-x,p0)
              sum1 = sum1+binomialp(n1,x,p1)*binomial(n-n1,r-x,p1)
            }
           /*************************
            * THE PETs have changed
            *************************/
            Rp0 = binomial(n1,r1,p0)+sum0
            PETp0 = 1-binomial(n1,r2,p0)+binomial(n1,r1,p0)
            ENp0 = PETp0*n1+(1-PETp0)*n
            Rp1 = binomial(n1,r1,p1)+sum1
            PETp1 = 1-binomial(n1,r2,p1)+binomial(n1,r1,p1)
            ENp1 = PETp1*n1+(1-PETp1)*n
           

            if ((Rp0 >= 1-alpha) & (Rp1 <= beta)) {
               /* First design then set up the admissible designs matrix */
               if (!found) {
                 admissible = (r1, r2, n1, r, n, ENp0, ENp1)
                 found = 1
               }
               /* If second design then first check it isn't dominated by another admissible design */
               else {
                 test = (r1, r2, n1, r, n, ENp0, ENp1)
                 domin =0
                 for (i=1;i<=rows(admissible);i++) {
                   if ((test[5]>=admissible[i,5])&(test[6]>admissible[i,6])&(test[7]>admissible[i,7])) domin=1
                 }
               /* If it isn't dominated then add it to the admissible design matrix BUT
               NEED to check whether it dominates another design so a little tricky
               */
                 if (!domin) {
                   keep=NULL
                   for (i=1;i<=rows(admissible);i++) {
                     if (!((test[5]<=admissible[i,5])&(test[6]<admissible[i,6])&(test[7]<admissible[i,7])))  {
                       if (keep==NULL) keep= (i)
                       else keep = keep,i
                     }
                   }
                   if (keep==NULL) admissible = test
                   else {
                    admissible = admissible[keep,] \ test
                   }
                 }
               }
            }
            if (mod(count,display)==0 & count>1 ) printf("Still searching [until n=%3.0f..] found {res}%2.0f {txt}potential designs (current n=%3.0f n1=%3.0f)\n", maxn, rows(admissible), n, n1)
            count++
          } /*r2 loop*/
        } /*r1 loop */
      } /*n1 loop*/
    } /*r loop*/

    n++
  } /* n loop */

  if (!found) {
    minn=maxn
    maxn++
    printf("{err}MAXN too low .. Increasing n by 1 to %g\n", maxn)
    displayflush()
  }

}

/**********************************************************
 * Need to then go through a grid of values to find the 
 * admissible designs
 **********************************************************/

printf("\nNOTE: Creating the matrix that contains the admissible designs\n")
grid=NULL
gstep = 0.0075
i=0
do {
  if (i==0) j=gstep
  else j=0
  do {
    sum = (1-i-j):*admissible[,5]+i:*admissible[,6]+j:*admissible[,7] 
    minindex(sum,1,a,b)
    if (grid==NULL) grid = i,j, admissible[a,], sum[a]
    else grid = grid \ (i,j, admissible[a,], sum[a])
    j=j+gstep
  } while (i+j<=1)
  i=i+gstep
} while (i<=1)

/**********************************************************
 * Create matrices of results and then pass back to Stata 
 * and then eventually return
 **********************************************************/

st_matrix("grid", grid)
st_matrix("admissible", admissible)

}/*END of admiss2s() function!*/


/********************************************************
 * All the calculations needed for the binomial sums
 ********************************************************/

void admisss2s(p0, p1, po, alpha, beta, minn, maxn, optimal, noise , display)
{

printf("\n{txt}Simon's Two Stage Design\n")
printf("{dup 24:{c -}}\n")
printf("A design is indexed by four values {res} r1/n1 r/n \n")

printf("{txt}Type I error ={res} %g\n", alpha)
printf("{txt}Power        ={res} %g\n", 1-beta)
printf("{txt}H0: p = p0\n")

printf("{txt}H1: p = p1 >=p0\n")
printf("{txt}where p0 is {res}%g{txt} and p1 is {res}%g\n\n", p0, p1)

printf("{txt}The study is stopped if there are <= r1 responders out of the first n1 participants\n")
printf("The null hypothesis is rejected if there are >r responders out of n participants\n")

printf("{txt}This algorithm is searching for the {res}admissible {txt}designs\n")


found = 0
n=minn
count=1
while(!found) {
  while(n<=maxn) {
    for(r=0; r<=n; r++) {
      for(n1=1; n1<= n; n1++) {
        for(r1=0; r1<= mymin(r,n1); r1++) {
          sum0 =0
          sum1 =0

          for(x=r1+1;x<=mymin(r,n1);x++) {
            sum0 = sum0+binomialp(n1,x,p0)*binomial(n-n1,r-x,p0)
            sum1 = sum1+binomialp(n1,x,p1)*binomial(n-n1,r-x,p1)
          }
          Rp0 = binomial(n1,r1,p0)+sum0
          PETp0 = binomial(n1,r1,p0)
          ENp0 = PETp0*n1+(1-PETp0)*n
          Rp1 = binomial(n1,r1,p1)+sum1
          PETp1 = binomial(n1,r1,p1)
          ENp1 = PETp1*n1+(1-PETp1)*n

          if ((Rp0 >= 1-alpha) & (Rp1 <= beta)) {
             /* First design then set up the admissible designs matrix */
             if (!found) {
               admissible = (r1, n1, r, n, ENp0, ENp1)
               found = 1
             }
             /* If second design then first check it isn't dominated by another admissible design */
             else {
               test = (r1, n1, r, n, ENp0, ENp1)
               domin =0
               for (i=1;i<=rows(admissible);i++) {
                 if ((test[4]>=admissible[i,4])&(test[5]>admissible[i,5])&(test[6]>admissible[i,6])) domin=1
               }
               /* If it isn't dominated then add it to the admissible design matrix BUT
               NEED to check whether it dominates another design so a little tricky
               */
               if (!domin) {
                 keep=NULL
                 for (i=1;i<=rows(admissible);i++) {
                   if (!((test[4]<=admissible[i,4])&(test[5]<admissible[i,5])&(test[6]<admissible[i,6])))  {
                     if (keep==NULL) keep= (i)
                     else keep = keep,i
                   }
                 }
                 if (keep==NULL) admissible = test
                 else {
                  admissible = admissible[keep,] \ test
                 }
               }
             }
           }

        
        
          if (mod(count,display)==0 & count>1 ) printf("Still searching [until n=%3.0f..] found {res}%2.0f {txt}potential designs (current n=%3.0f n1=%3.0f)\n", maxn, rows(admissible), n, n1)
          count++
        }
      }
    }


    n++
  }

  if (!found) {
    minn=maxn
    maxn++
    printf("{err}MAXN() too low! increasing n by 1 to %g\n", maxn)
    displayflush()
  }

}



/**********************************************************
 * Need to then go through a grid of values to find the 
 * admissible designs
 **********************************************************/

printf("\nNOTE: Creating the matrix that contains the admissible designs\n")
grid=NULL
gstep = 0.0075
i=0
do {
  if (i==0) j=gstep
  else j=0
  do {
    sum = (1-i-j):*admissible[,4]+i:*admissible[,5]+j:*admissible[,6] 
    minindex(sum,1,a,b)
    if (grid==NULL) grid = i,j, admissible[a,], sum[a]
    else grid = grid \ (i,j, admissible[a,], sum[a])
    j=j+gstep
  } while (i+j<=1)
  i=i+gstep
} while (i<=1)




/**********************************************************
 * Create matrices of results and then pass back to Stata 
 * and then eventually return
 **********************************************************/

st_matrix("grid", grid)
st_matrix("admissible", admissible)

}/*END of admisss2s function!*/


/********************************************************
 * All the calculations needed for the binomial sums
 ********************************************************/

void vecadmisss2s(p0, p1, po, alpha, beta, minn, maxn, optimal, noise , display)
{

printf("\n{txt}Simon's Two Stage Design\n")
printf("{dup 24:{c -}}\n")
printf("A design is indexed by four values {res} r1/n1 r/n \n")
printf("{txt}Type I error ={res} %g\n", alpha)
printf("{txt}Power        ={res} %g\n", 1-beta)
printf("{txt}H0: p = p0\n")
printf("{txt}H1: p = p1 >=p0\n")
printf("{txt}where p0 is {res}%g{txt} and p1 is {res}%g\n\n", p0, p1)
printf("{txt}The study is stopped if there are <= r1 responders out of the first n1 participants\n")
printf("The null hypothesis is rejected if there are >r responders out of n participants\n")
printf("{txt}This algorithm is searching for the {res}admissible {txt}designs\n")

/*******************************************************
 * Now to create a loop vector of all possibilities
 *******************************************************/

nd = maxn*maxn*maxn*maxn
loop = (0::nd-1)

n1=mod(loop,maxn+1)
loop = (loop:-mod(loop,maxn+1) ) :/ (maxn+1)
r1=mod(loop,maxn+1)
loop = (loop:-mod(loop,maxn+1) ) :/ (maxn+1)
n2=mod(loop,maxn+1)
loop = (loop:-mod(loop,maxn+1) ) :/ (maxn+1)
r2=mod(loop,maxn+1)
loop = (loop:-mod(loop,maxn+1) ) :/ (maxn+1)

r=r1+r2
n=n1+n2
design = r1, n1, r, n, r2, n2

design
design = select(design, n1<n)
design
design = select(design, design[,2]< design[,4])

/*design = select(design, design[,1]<= design[,2])
design = select(design, design[,1] <= design[,3])
*/
design
exit
found = 0
n=minn
count=1
while(!found) {
  while(n<=maxn) {
    for(r=0; r<=n; r++) {
      for(n1=1; n1<= n; n1++) {
        for(r1=0; r1<= mymin(r,n1); r1++) {
          sum0 =0
          sum1 =0

          for(x=r1+1;x<=mymin(r,n1);x++) {
            sum0 = sum0+binomialp(n1,x,p0)*binomial(n-n1,r-x,p0)
            sum1 = sum1+binomialp(n1,x,p1)*binomial(n-n1,r-x,p1)
          }
          Rp0 = binomial(n1,r1,p0)+sum0
          PETp0 = binomial(n1,r1,p0)
          ENp0 = PETp0*n1+(1-PETp0)*n
          Rp1 = binomial(n1,r1,p1)+sum1
          PETp1 = binomial(n1,r1,p1)
          ENp1 = PETp1*n1+(1-PETp1)*n

          if ((Rp0 >= 1-alpha) & (Rp1 <= beta)) {
             /* First design then set up the admissible designs matrix */
             if (!found) {
               admissible = (r1, n1, r, n, ENp0, ENp1)
               found = 1
             }
             /* If second design then first check it isn't dominated by another admissible design */
             else {
               test = (r1, n1, r, n, ENp0, ENp1)
               domin =0
               for (i=1;i<=rows(admissible);i++) {
                 if ((test[4]>=admissible[i,4])&(test[5]>admissible[i,5])&(test[6]>admissible[i,6])) domin=1
               }
               /* If it isn't dominated then add it to the admissible design matrix BUT
               NEED to check whether it dominates another design so a little tricky
               */
               if (!domin) {
                 keep=NULL
                 for (i=1;i<=rows(admissible);i++) {
                   if (!((test[4]<=admissible[i,4])&(test[5]<admissible[i,5])&(test[6]<admissible[i,6])))  {
                     if (keep==NULL) keep= (i)
                     else keep = keep,i
                   }
                 }
                 if (keep==NULL) admissible = test
                 else {
                  admissible = admissible[keep,] \ test
                 }
               }
             }
           }

        
        
          if (mod(count,display)==0 & count>1 ) printf("Still searching [until n=%3.0f..] found {res}%2.0f {txt}potential designs (current n=%3.0f n1=%3.0f)\n", maxn, rows(admissible), n, n1)
          count++
        }
      }
    }


    n++
  }

  if (!found) {
    minn=maxn
    maxn++
    printf("{err}MAXN() too low! increasing n by 1 to %g\n", maxn)
    displayflush()
  }

}



/**********************************************************
 * Need to then go through a grid of values to find the 
 * admissible designs
 **********************************************************/

printf("\nNOTE: Creating the matrix that contains the admissible designs\n")
grid=NULL
gstep = 0.0075
i=0
do {
  if (i==0) j=gstep
  else j=0
  do {
    sum = (1-i-j):*admissible[,4]+i:*admissible[,5]+j:*admissible[,6] 
    minindex(sum,1,a,b)
    if (grid==NULL) grid = i,j, admissible[a,], sum[a]
    else grid = grid \ (i,j, admissible[a,], sum[a])
    j=j+gstep
  } while (i+j<=1)
  i=i+gstep
} while (i<=1)




/**********************************************************
 * Create matrices of results and then pass back to Stata 
 * and then eventually return
 **********************************************************/

st_matrix("grid", grid)
st_matrix("admissible", admissible)

}/*END of vecadmisss2s function!*/






end  /* this is the END OF MATA!*/




