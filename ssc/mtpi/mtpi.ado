*! Date    : 1 Jul 2020
*! Version : 1.0
*! Author  : Adrian Mander
*! Email   : mandera@cardiff.ac.uk
*! The modified toxicity probability interval
*! Ported from Yuan Ji's R code (7 Jan 2008) based on the mTPI method (Ji et al, 2009). 

/*
 1Jul20  v1.00 The command is born
*/

/* START HELP FILE
title[A command for the modified Toxicity Probability Interval design]

desc[
The modified Toxicity Probability Interval design is an attempt to implement a method
that is as simple as a 3+3 decision but based on statistical distributions rather
than a pure rule-based approach. This method produces decision making tables for the fully
trial so a statistician need not be involved in all the dose escalation decisions.

The command {cmd:mtpi} performs simulations to find the operating characteristics alongside
the decision matrix given a sample size and number of DLTs.
]

opt[ep1() specifies the lower bound of the interval around the TTL that is safe.]
opt[ep2() specifies the upper bound of the interval around the TTL that is safe.]
opt[safe1() specifies the safety cutoff for declaring the lowest dose to be safe.]
opt[safe2() specifies the safety cutoff for declating the dose to be safe.]
opt[ttl() specifies the target toxicity level that defines the maximum tolerated dose.]
opt[simn() specifes the number of simulations used]
opt[sampsize() specifies the sample size of each trial in the simulations.]
opt[csize() specifies the cohort size used in the trial. ]
opt[startdose() specifies the starting dose. ]
opt[priora()  specifies the a parameter of the prior Beta distribution.]
opt[priorb() specifies the a parameter of the prior Beta distribution.]
opt[truep() specifies a vector of true probabilities of DLT for each dose level.]
opt[decisiontable() specifies that the single cohort decision rules be displayed as a lookup table.]

example[
The basic command will do a simulation

 {stata mtpi}

The results show a table of each dose level with the true probabilities of a DLTs
 and the proportion of time those doses are recommended, experimented 
on and how many DLTs were observed on average.
]
author[Prof Adrian Mander]
institute[Cardiff University]
email[mandera@cardiff.ac.uk]

references[
Yuan Ji, Ping Liu, Yisheng Li and NB Bekele (2010) A modified toxicity probability
 interval method for dose-finding trials. Clin. Trials 7(6) 653-663.
]

seealso[
{help crm} (if installed)  {stata ssc install crm} (to install this command)
]
END HELP FILE */

pr mtpi
 /* Allow use on earlier versions of stata that have not been fully tested */
 local version = _caller()
 if `version' < 16.1 {
    di "{err}WARNING: Tested only for Stata version 16.1 and higher."
    di "{err}Your Stata version `version' is not officially supported."
 }
 else {
   version 16.1
 }
preserve

syntax [varlist] [, ep1(real 0.05) ep2(real 0.05) safe1(real 0.8) safe2(real 0.8) ttl(real 0.3) /*
*/ simn(real 100) sampsize(real 30) csize(real 3) startdose(real 4) priora(real 1) priorb(real 1) /*
*/ truep(numlist ascending >=0 <=1) decisiontable ] 

/* create a string of true probabilities that Mata accepts */
if "`truep'"~= "" {
  local d 0
  local troop "("
  foreach value of numlist `truep' {
    local troop "`troop'`value',"
    local `d++'
  }
  local troop = substr("`troop'", 1, length("`troop'")-1)
  local troop "`troop')"
}
else {
  local troop "(.15, .25, .35, .45, .55, .65, .75, .85)"
  local d "8"
}


di
di "{txt}modified Toxicity Probability Interval (mTPI) design"
di "{dup 52:{c -}}"

if "`decisiontable'"~="" {
  mata: singledose(`safe1', `safe2', `ep1', `ep2', `ttl', `d', `simn', `sampsize', `csize', `startdose', `priora' , `priorb')
}
mata: simulation(`safe1', `safe2', `ep1', `ep2', `ttl', `d', `simn', `sampsize', `csize', `startdose', `priora' , `priorb', `troop')

restore
end

/**********************MATA STARTS ********************************************/
mata: 
/******************************************************************************
 * PAVA is the pool adjacent violator algorithm to perform isotonic 
 * transformation for the posterior means later
 ******************************************************************************/
real pava(x, wt) 
{
  n = rows(x)
  if (n <= 1) return(x)
  if ( missing(x)>0 | missing(wt)>0 ) {
    printf("Missing values in 'x' or 'wt' not allowed")
    exit(198)
  }
  lvlsets = (1::n)
  violator = 1
  while(violator) {
    diffx = x[2::rows(x)] :- x[1::(rows(x)-1)]
    viol = (diffx :< 0)
    if (sum(viol)==0) violator=0
    else {
      maxindex(viol, 1, i, w)  /* select the first violator */
      i = i[1]
      lvl1 = lvlsets[i]
      lvl2 = lvlsets[i + 1]
      ilvl = (lvlsets :== lvl1) + ( lvlsets :== lvl2)  /*need full index..*/
      maxindex(ilvl, 1, ii, ww)
      minlvl = min(ii)
      maxlvl = max(ii)
      x[minlvl::maxlvl] = J(maxlvl-minlvl+1,1,sum( x[minlvl::maxlvl] :* wt[minlvl::maxlvl]):/sum(wt[minlvl::maxlvl]) )
      lvlsets[minlvl::maxlvl] = J(maxlvl-minlvl+1,1,minlvl)
    }
  }
  return(x)
}
// betavar computes variances of beta distributions 
real scalar betavar(a,b)
{
  return( a*b/((a+b)^2*(a+b+1)) )
}

/* Main simulation module */
void simulation(scalar xi1, scalar xi2, scalar eps1, scalar eps2, scalar pT, scalar D, scalar simN, scalar sampsize, scalar csize, scalar startdose, scalar a, scalar b, real rowvector p)
{
  datan = J(simN,D, 0)
  datax = J(simN,D, 0)
  rez = J(simN,1,0)

  //############################## Start simulations ###############
  for(sim=1;sim<=simN;sim=sim+1) {
    x = J(D,1,0)
    n = J(D,1,0)
    pa=J(D,1,0)
    pb=J(D,1,0)
    q = J(3,1,0)
    d=startdose
    st=0
    nodose=0
    maxdose=1
    toxdose=D+1
    seldose=0
    mindose=D
  
    while(st==0) {  // ## st = 1 indicates the trial must be terminated
      maxdose = max( (maxdose, d) )
      mindose = min( (mindose, d) )
      // generate random toxicity response
      xx = sum(  uniform(csize,1) :< p[d] )
      x[d] = x[d]+xx
      n[d] = n[d]+csize 
      // Update posterior beta distribution
      pa[d]=x[d]+a
      pb[d]=n[d]-x[d]+b
      if (d<D) {
        pa[d+1]=x[d+1]+a
        pb[d+1]=n[d+1]-x[d+1]+b
      }

// Compute the indicator T_{i+1} to see if the next dose is too toxic then set q[3]=0 if it is
      if(d<D){
        /* weird... they used Jeffrey's not uniform() below */
        if( (1-ibeta(0.5+x[d+1], 0.5+n[d+1], pT))  >xi1) {
          tt=1
          toxdose=d+1
        } 
        else tt=0
      }

// Compute the UPM for three intervals defined by the equivalence interval      
      q[1] = (1-ibeta(pa[d], pb[d], eps2+pT) )/(1-eps2-pT)
      q[2] = (ibeta( pa[d], pb[d], eps2+pT) - ibeta( pa[d], pb[d],pT-eps1))/(eps2+eps1)
      q[3] = (ibeta( pa[d], pb[d], pT-eps1)/(pT-eps1))*(1-tt)

     // implement the dose-assignment rules based on the UPM
      if (d==1){
        //## if the first dose is too toxic, the trial will be terminated
        if ((1-ibeta( 0.5+x[d], 0.5+n[d]-x[d], pT))>xi1) {   /* Jeffreys prior */
          st=1
          nodose=1
        } 
        else {
          if ((q[2]>q[1])&(q[2]>q[3])) d=d    /* Stay */
          if ((q[3]>q[1])&(q[3]>q[2])) d=d+1  /* Escalate */
        }
      }
      else {
        if (d==D) {
          //## if the last dose is much lower than the MTD, the trial will be terminated and no dose selected
          if (ibeta(0.5+x[d], 0.5+n[d]-x[d], pT)>xi2) { /* they used Jeffrey prior again*/
            st=1
            nodose=1
          }
          else {
            if ((q[1]>q[2])&(q[1]>q[3])) d=d-1  /* de-escalate */
            if ((q[2]>q[1])&(q[2]>q[3])) d=d    /* Stay */
          }
        }		
         else {
          if ((d>1)&(d<D)) {
            if ((q[1]>q[2])&(q[1]>q[3])) d=d-1  /* de-escalat */
            if ((q[2]>q[1])&(q[2]>q[3])) d=d    /* Stay */
            if ((q[3]>q[1])&(q[3]>q[2])) d=d+1  /* Escalate */
          }
        }
      }
      total=sum(n)
      if (total >= sampsize) st=1    
    }
    //### compute the posterior mean from the beta distribution
    if(nodose==0) {
      tdose = min( (maxdose, toxdose-1) )
      pp = J(tdose, 1, -100)
      ppvar = J(tdose,1,0)

      for(i=1; i<= tdose; i++) {
        pp[i] = (x[i]+.005)/(n[i]+.01)
        ppvar[i] = betavar(x[i]+0.005, n[i]-x[i]+0.005) 
 // here adding 0.005 is to use beta(0.005, 0.005) for estimating the MTD, which is different from the dose-finding.
      }

      pp=pava(pp, wt=1:/ppvar) 
     // ##pp[maxdose:(toxdose-1)]<-pava(pp[maxdose:(toxdose-1)], wt=1/pp.var[maxdose:(toxdose-1)])  ## perform the isotonic transformation using PAVA with weights being posterior variances
     
     // ##for(i in maxdose:(toxdose-1)){
      for(i=2;i<=tdose;i++) {
        pp[i] = pp[i] + i*1E-10 //## by adding an increasingly small number to tox prob at higher doses, it will break the ties and make the lower dose level the MTD if the ties were larger than pT or make the higher dose level the MTD if the ties are smaller than pT
      }
      minindex(abs(pp:-pT)[mindose::tdose],1, seldose, w)  /* select from experimented doses!*/
      //##seldose is the final MTD that is selected based on the order-transofromed posterior means
      rez[sim] = seldose+mindose-1;
    }
    for(i=1;i<=D;i++){
      datan[sim,i] = n[i]
      datax[sim,i] = x[i]
    }
  }
  //##rez[is.na(rez)]<-0
  aaa=J(D,1,0)

  //################## output results ################################
  for(i=1;i<=D;i++){
    aaa[i] = sum(rez:==i)/simN //### aaa is the propotion of be selected as the MTD
  }
  nodoses = 1-sum(aaa)

printf("{txt}Simulation with the following settings \n")
printf("{txt} Prior {res}Beta(a=%2.0f, b=%2.0f)\n", a,b)
printf("{txt} Target toxicity level = {res}%f  {txt}and interval {res}(eps1=%5.2f, eps2=%5.2f) \n", pT, eps1, eps2)
printf("{txt} Safety cutoffs: xi1= {res}%5.2f {txt}and xi2={res}%5.2f \n", xi1, xi2)

printf("{txt} Number of simulations {res}%f\n", simN)
printf("{txt} Sample size {res}%f\n", sampsize)
printf("{txt} Cohort size {res}%f\n", csize)
printf("{txt} Starting dose {res}%f\n", startdose)


printf("\n{txt}A table of the simulation results")
printf("\n {c TLC}{dup 17:{c -}}{c TT}")
for (i=1;i<D;i++) {
 printf("{dup 7:{c -}}{c TT}")
}
printf("{dup 7:{c -}}{c TRC}")

printf("\n {c |}Dose levels {col 20}{c |}")
for (i=1;i<=D;i++) {
  printf("%6.0f {c |}", i)
}


printf("\n {c LT}{dup 17:{c -}}{c +}")
for (i=1;i<D;i++) {
 printf("{dup 7:{c -}}{c +}")
}
printf("{dup 7:{c -}}{c RT}")


printf("\n {c |}True values {col 20}{c |}")
for (i=1;i<=D;i++) {
  printf("{res}%6.3f {txt}{c |}", p[i])
}

printf("\n {c LT}{dup 17:{c -}}{c +}")
for (i=1;i<D;i++) {
 printf("{dup 7:{c -}}{c +}")
}
printf("{dup 7:{c -}}{c RT}")


printf("\n {c |}MTD selected  {col 20}{c |}")
for (i=1;i<=D;i++) {
  printf("{res}%6.2f {txt}{c |}", aaa[i])
}

printf("\n {c LT}{dup 17:{c -}}{c +}")
for (i=1;i<D;i++) {
 printf("{dup 7:{c -}}{c +}")
}
printf("{dup 7:{c -}}{c RT}")


printf("\n {c |}Average number {col 20}{c |}")
for (i=1;i<=D;i++) {
  printf("{res}%6.2f {txt}{c |}", mean(datan)[i])
}
printf("\n {c |}of people dosed  {col 20}{c |}")
for (i=1;i<D;i++) {
 printf("{dup 7: }{c |}")
}
printf("{dup 7: }{c |}")


printf("\n {c LT}{dup 17:{c -}}{c +}")
for (i=1;i<D;i++) {
 printf("{dup 7:{c -}}{c +}")
}
printf("{dup 7:{c -}}{c RT}")


printf("\n {c |}Average number  {col 20}{c |}")
for (i=1;i<=D;i++) {
  printf("{res}%6.2f {txt}{c |}", mean(datax)[i])
}
printf("\n {c |}of toxicities {col 20}{c |}")
for (i=1;i<D;i++) {
 printf("{dup 7: }{c |}")
}
printf("{dup 7: }{c |}")

printf("\n {c BLC}{dup 17:{c -}}{c BT}")
for (i=1;i<D;i++) {
 printf("{dup 7:{c -}}{c BT}")
}
printf("{dup 7:{c -}}{c BRC}")

printf("\n {err}No MTD doses were found for {bf: %5.2f %%} trials", 100*nodoses)

}

/****************   Show decision making module ********************/
void singledose(scalar xi1, scalar xi2, scalar eps1, scalar eps2, scalar pT, scalar D, scalar simN, scalar sampsize, scalar csize, scalar startdose, scalar a, scalar b)
{

q = J(3,1,0)
printf("{txt}Decision table with the following settings \n")
printf("{txt} Prior {res}Beta(a=%2.0f, b=%2.0f)\n", a,b)
printf("{txt} Target toxicity level = {res}%f  {txt}and interval {res}(eps1=%5.2f, eps2=%5.2f) \n", pT, eps1, eps2)
printf("{txt} Safety cutoffs: xi1= {res}%5.2f {txt}and xi2={res}%5.2f \n", xi1, xi2)
printf("{txt} Sample size {res}%f\n", sampsize)

printf("\n{txt}The rows are the number of events and the columns are the sample sizes \n\n")
printf("    {c |}")
  for (n=1;n<=sampsize; n++) { 
    printf("%3.0f", n)
  }
printf("\n {dup 3:{c -}}{c +}")

  for (n=1;n<=sampsize; n++) { 
    printf("{dup 3:{c -}}")
  }
printf("\n")
  for (x=0;x<= sampsize; x++) {
    printf("%3.0f {c |}", x)
    for (n=1;n<=sampsize; n++) { 
      if (x>n) {
        printf("   ")
      }
      else {
        // Posterior beta distribution
        pa=x+a
        pb=n-x+b

        // Compute the UPM for three intervals defined by the equivalence interval      
        q[1] = (1-ibeta(pa, pb, eps2+pT) )/(1-eps2-pT)
        q[2] = (ibeta( pa, pb, eps2+pT) - ibeta( pa, pb,pT-eps1))/(eps2+eps1)
        q[3] = (ibeta( pa, pb, pT-eps1)/(pT-eps1))

        if ((q[1]>q[2])&(q[1]>q[3])) printf("{res} D") /* de-escalat */
        if ((q[2]>q[1])&(q[2]>q[3])) printf("{res} S")    /* Stay */
        if ((q[3]>q[1])&(q[3]>q[2])) printf("{res} E")  /* Escalate */

/* unacceptable dose */
        if ((1-ibeta( 0.5+x, 0.5+n-x, pT))>xi1) {   /* Jeffreys prior */
          printf("U")
        } 
        else printf(" ")
      }
    }
    printf("\n{txt}")
  }
printf("\n Key: E = Escalate  D = De-escalate  S = Stay  U = Unsafe\n\n")
     

}

end /* end of Mata*/
