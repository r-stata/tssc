*! Date    : 3 Aug 2015
*! Version : 1.05
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! The CRM 

/*
08Jun10  v1.00 The command is born
29Sep11  v1.01 The command is generalised
 6Feb12  v1.02 SDOSE option 
27Mar13  v1.03 using new integrate function and completing command
10Feb15  v1.04 remove dependency on integrate
 3Aug15  v1.05 add check on the doses from the dataset are nominal, return for non-binary dlt data, added ignorebinary option
*/

pr crm
version 12.0
preserve
syntax varlist (min=2 max=2) [if], Skeleton(numlist) [ Model(string) Target(real 0.2) Delta(string) Quadpts(integer 80) /*
*/ INVmodel(string) PRIOR(string) Pmean(real 1) Psd(real 1) SDosemedian  DOSE(numlist) IGNOREBINARY Graph] 

if "`if'"~="" qui keep `if'
/*************************************************************************
 * CHECKING options making sure built-in models match inverse models
 *  then check for the integrate() function is loaded
 *************************************************************************/
 if ("`model'"=="power" & "`invmodel'"=="") local invmodel "power"
 if ("`model'"=="power2" & "`invmodel'"=="") local invmodel "power2"
 
/*******************************************************************
 * Begin display
 *******************************************************************/
di
di "{txt}Continual Reassessment Model"
di "{dup 28:{c -}}"
di

/**************************************************************************
 * Set up the prior skeleton
 *  the skeleton is then put in the matrix prior
 * Also set up the doselab if it exists
 **************************************************************************/
di "Prior skeleton is {res}`skeleton'"
di "{txt}Target Toxicity Level (TTL)= {res}`target'"
local first 1
local ind 1
foreach num of numlist `skeleton' {
  if (`first') {
    mat prior = `num'
    mat dlab = `ind++'
    local `first--'
  }
  else {
    mat prior = prior, `num'
    mat dlab = dlab, `ind++'
  }
}
local ndose = colsof(prior)
di "{txt}The number of doses is taken from your skeleton and is {res}`ndose'"
di

/**************************************************************** 
 * Construct the dose label vector
 ****************************************************************/
if "`dose'"~="" {
  local first 1
  foreach num of numlist `dose' {
    if (`first') {
      mat dlab = `num'
      local `first--'
    }
    else mat dlab = dlab, `num'
  }
  if (colsof(dlab)~=colsof(prior)) {
    di "{err}WARNING: number of dose labels does not equal the number of doses in skeleton"
    exit(198)
  }
}

/*********************************************************************
 * Handle the Prior for a, Risk Model and its inverse 
 *  for any function specified
 * ALL these functions are written to a single text file and compiled
 *********************************************************************/
 tempname fh
 tempfile temp
 mata: mata clear
 file open `fh' using "`temp'", write
 file write `fh' "mata" _n
/****************************************************************************
 * WRITE THE prior FUNCTION
 *  the default function is  1/mu * exp( -a/mu)
 *
 ****************************************************************************/
 file write `fh' "real rowvector crm_g(real rowvector a)" _n
 file write `fh' "{" _n
/*****************************************************************************************/
 * The default function is Exponential distribution, 
 * the mean is used to define the function and the median is ln(2)*pmean
 * NOTE if standardisation is on median then this must be specified by 
 *  sdosemedian() option and local pmedian defined
 *****************************************************************************************/
 if "`prior'"=="" | "`prior'"=="exponential" {
   if `pmean'==0 {
     di "Prior mean chosen as 0 which is impossible for the Exponential distribution"
     exit(198)
   }
   file write `fh' "return(1/`pmean'*exp(-1:*a:/`pmean'))" _n
   di "{p 0 2}{txt}Prior for single parameter {res}a {txt}is taken as the Exponential prior with mean `pmean' i.e. {res}1/`pmean'*exp(-a/`pmean')"
   local pmedian = ln(2)*1/`pmean'
 }
 else if "`prior'"=="lognormal"  {
   file write `fh' "return( (1:/(a:*sqrt(2*pi()):*`psd')):*exp( (-1:*(log(a):-`pmean'):^2):/(2:*(`psd'^2)) ))" _n
   di "{txt}Prior for single parameter a is taken as the {res}LogNormal(`pmean', `psd'^2) {txt}prior "
   local pmedian = exp(`pmean')
   local pmean = exp(`pmean'+`psd'^2/2)
   if "`sdosemedian'"~="" di "{txt} NOTE: prior median is exp(mu) = {res}"%5.3f `pmedian'
   else  di "{txt} NOTE: prior mean is exp(mu+var/2) = {res}"%5.3f `pmean'
 }
 else file write `fh' "return(`prior')" _n
 file write `fh' "}" _n
 file write `fh' "mata mosave crm_g(), replace" _n

/**********************************************************************
 * this function defines psi RISK model  i.e. option model()
 *  the default is the hyperbolic tangent 
 *  power --- is the power model (note need to set up 
 *            prior, d and what dose relates to in skeleton
 *  power2 --- makes sure power is positive i.e. exp(a)
 **********************************************************************/
 file write `fh' "real rowvector crm_psi(real dose, real rowvector a )" _n
 file write `fh' "{" _n
 if "`model'"=="" file write `fh' "return ( ((tanh(dose)+1)/2):^a )" _n
 else if ("`model'"=="power") {
   file write `fh' "real matrix priorp" _n
   file write `fh' "real matrix d" _n
   file write `fh' "real matrix i" _n
   file write `fh' "real matrix w" _n
   file write `fh' `"priorp = st_matrix("prior")"' _n
   file write `fh' `"d = st_matrix("d")"' _n
   file write `fh' "minindex((d:-dose):^2, 1,i,w)" _n
   file write `fh' "return( priorp[i]:^a ) " _n
 }
 else if ("`model'"=="power2") file write `fh' "return ( (priorp[dose]):^(exp(a)) ) " _n
 else file write `fh' "return(`model')" _n
 file write `fh' "}" _n
 file write `fh' "mata mosave crm_psi(), replace" _n

/******************************************************
 * this function defines mypsi^-1  inverse RISK model
 *  Note here it is per element not a vector
 ******************************************************/
 file write `fh' "real crm_invpsi(real p, real a)" _n
 file write `fh' "{" _n
 if "`invmodel'"=="" {
   di "{txt}Inverse model is the inverse hyperbolic tangent"
   file write `fh' " return ( atanh(2*p^(1/a)-1)  )" _n
 }
 else if ("`invmodel'"=="power") {
  di "{txt}Inverse model is from the power model"
  file write `fh' " return ( p^(1/a) )" _n
 }
 else if ("`invmodel'"=="power2") {
   di "{txt}Inverse model is from the power model"
  file write `fh' " return ( p^(1/exp(a)) )" _n
 }
 else file write `fh' " return(`invmodel')" _n
 file write `fh' "}" _n
 file write `fh' "mata mosave crm_invpsi(), replace" _n

/*******************************************
 * Display the options selected
 *******************************************/

 if "`model'"=="" di "{txt}Model is Hyperbolic Tangent {res}((tanh(dose)+1)/2)^a"
 if "`model'"=="power" di "{txt}Model is Power Model {res}dose^a"
 if "`model'"=="power2" di "{txt}Model is Power Model {res}dose^exp(a)"
 local model "1"
 di
 di "{p 0 2}{txt}The next dose is chosen to be the one with the closest expected probability of toxicity, {bf:p}, to the TTL"
 if "`delta'"=="" local delta "1"
 if "`delta'"=="1" di " Closest is defined as the smallest {res}({bf:p}-TTL)^2"
 if "`delta'"=="2" di " Closest is defined as the smallest {res}abs({bf:p}-TTL)"
 di

/*********************************************************************
 * Check varlist, 
 * First find out if the first variable is an outcome binary variable
 * Then check that the doses are no more frequent than the skeleton
 *********************************************************************/
 local first 1
 foreach v of varlist `varlist' {
   qui levelsof `v', local(levels)
   local lev: list sort levels
   local size: list sizeof lev
   if "`first++'"=="1" {
     if `size'>2 { 
       di "{err}Too many values for the outcome `v'"
       di "This variable should be binary 0/1!"
       exit(201)
     }
     if "`size'"=="2" {
       local f: word 1 of `lev'
       local s: word 2 of `lev'
       if "`f'"~="0" || "`s'"~="1" {
         di "{err}`v' needs to be a binary variable 0/1"
         exit(201)
       }
     }
     if "`size'"=="1" {
       local f: word 1 of `lev'
       if "`f'"~="0" || "`f'"~="1" {
         di "{err}Warning: `v' needs to vary for stable estimation"
	 di "{err}Use the -ignorebinary=- option to ignore this warning"
         if "`ignorebinary'"=="" exit(201)
       }
     }
   }
   else {
     local biggestdose:word `size' of `lev'
     if (`biggestdose'>`ndose') {
       di "{pstd}{err} The biggest dose `biggestdose' is bigger than the number of doses `ndose'"
       di "{pstd} Make sure the doses in the dataset are nominal doses 1,2,... rather than the actual dose"
       di
       exit(198)
     }
     local lowestdose:word 1 of `lev'
     if (`lowestdose'<0.99999) {
       di "{pstd}{err} The lowest dose `lowestdose' is smaller than 1"
       di "{pstd} Make sure the doses in the dataset are nominal doses 1,2,... rather than the actual dose"
       di
       exit(198)
     }
     foreach a of local levels {
       if abs(`a'-int(`a')) > 0.0001 {
         di
         di "{pstd}{err} WARNING: dose `a' is not an integer!" 
	 di "Make sure the doses in the dataset are nominal doses 1,2,... rather than the actual dose"
 	 di
         exit(198)
       }
     }
     if `size' > `ndose' {
      di "{err}There are more doses in the dataset than specified by the `ndoses' in the prior"
      di
      exit(198)
     }
   }
 }

/****************************************************************
 * Run the stata code to write the new Mata codes and then
 * rum the CRM Mata code
 ****************************************************************/
 file write `fh' "end" _n
 file close `fh'
 qui do "`temp'" 

/*******************************************************************************************
 * This if statement is to check whether the prior median or mean 
 * are used to determine the standardised doses
 *  Currently if the default prior is used then the pmedian has an exact formula.. 
 *  I could implement something to get an optimize() estimate of the median and integrate()
 *******************************************************************************************/
 if "`sdosemedian'"=="" mata: mycrm(`pmean', `target', "`varlist'", `delta', `quadpts')
 else {
  if "`pmedian'"=="" {
    di
    di "{err}ERROR: no value for median is available for this prior"
    exit(198)
  }
  mata: mycrm(`pmedian', `target', "`varlist'", `delta', `quadpts')
 }

if "`graph'"~="" {
  svmat output, names(out)
  forv i=1/`=colsof(prior)' {
    local xx = out2[`i']
    local xlab `"`xlab' `i' "`xx'""'
  }
  qui su out9 if out1==pick[1,1]
  local yy = r(mean)
  local xx = pick[1,1]
  qui gen zero = 0
  lab var out1 "Dose"
  lab var out2 "Dose"
  lab var out3 "n"
  lab var out4 "tox"
  lab var out9 "Median posterior tox prob"
  twoway (rbar out8 out10 out1, barw(0.5) color(emidblue))(rspike out11 out7 out1, color(emidblue))(scatter out9 out1, color(maroon))/*
  */ (scatteri `yy' `xx', ms(D) color(red) msize(*2))   /*
  */, xlab(`xlab') yline(`target', lp(dash) lcolor(black)) nodraw saving(g1,replace) ytitle(Posterior tox probability) /*
  */ legend( lab(1 "25th-75th Perc.") lab(2 "2.5th to 97.5th Perc.") lab(3 "Median") lab(4 "Rec. Dose") rows(1) order(1 2 3 4))
  twoway (rbar out3 zero out1, barw(0.5) color(midblue))(rbar out4 zero out1,barw(0.5) color(maroon)),  xscale(alt) fysize(30) ytitle(Count) /*
  */ xlab(`xlab') legend(ring(0) pos(3) cols(1) lab(1 "No DLT") lab(2 "DLT")) nodraw saving(g2,replace)
  graph combine g2.gph g1.gph, imargin(0 0 0 0) cols(1) xcommon
}

restore
end


/************************************************************
 * Start of Mata
 ************************************************************/
version 12.0
mata:

/**************************************************************************
 * THIS is the Binomial LIKELIHOOD part, these doses are nominal doses
 **************************************************************************/
real rowvector crm_phi(real dose, real y, real rowvector a)
{
  return ( crm_psi(dose,a):^y:*(1:-crm_psi(dose,a)):^(1-y) ) 
}

/*********************************************************************************
 * this function defines the distance, this is the decision on the dose picking, 
 * actually 1 and 2 are the same, the default is squared distances
 *********************************************************************************/
real delta(real v, real w, scalar delta)
{
 if (delta==1) return ( (v-w)^2 )
 if (delta==2) return ( abs(v-w) )
}

/****************************************************
 * These are all the functions that are getting 
 * integrated
 ****************************************************/
/* this is the posterior distribution of a*/
real rowvector crm_posterior(real rowvector a, matrix doseout) 
{
  d= st_matrix("d")
  if (doseout==NULL)  return( crm_g(a) )
  for(i=1;i<=rows(doseout);i++) {
    if (i==1) prodphi = crm_phi(d[doseout[i,1]], doseout[i,2], a)
    else prodphi=prodphi:*crm_phi(d[doseout[i,1]], doseout[i,2], a)
  }
  return( crm_g(a):*prodphi )
}
/*This is the integrand for calculating the mean of the posterior of a*/
real rowvector mudenom(real rowvector a, matrix doseout) 
{
  d= st_matrix("d")
  if (doseout==NULL)  return( a:*crm_g(a) )
  for(i=1;i<=rows(doseout);i++) {
    if (i==1) prodphi = crm_phi(d[doseout[i,1]], doseout[i,2], a)
    else prodphi=prodphi:*crm_phi(d[doseout[i,1]], doseout[i,2], a)
  }
  return( a:*crm_g(a):*prodphi )
}
/*This is the integrand for calculating the mean toxicity averaged over the posterior of a*/
real rowvector mupost(real rowvector a, matrix doseout) 
{
  d= st_matrix("d")
  dosei=doseout[1,1]
  if (rows(doseout)==1)  return( crm_psi(d[dosei],a):*crm_g(a) )
  else {
   for(i=2;i<=rows(doseout);i++) {
     if (i==2) prodphi = crm_phi(d[doseout[i,1]], doseout[i,2], a)
     else prodphi=prodphi:*crm_phi(d[doseout[i,1]], doseout[i,2], a)
   } 
   return(  crm_psi(d[dosei],a):*crm_g(a):*prodphi  )
  }
}
/* This is the integrand for calculating the E(tox prob^2) to get variance of this distribution*/
real rowvector mupost2(real rowvector a, matrix doseout) 
{
  d= st_matrix("d")
  dosei=doseout[1,1]
  if (rows(doseout)==1)  return( crm_psi(d[dosei],a):*crm_psi(d[dosei],a):*crm_g(a) )
  else {
   for(i=2;i<=rows(doseout);i++) {
     if (i==2) prodphi = crm_phi(d[doseout[i,1]], doseout[i,2], a)
     else prodphi=prodphi:*crm_phi(d[doseout[i,1]], doseout[i,2], a)
   } 
   return(  crm_psi(d[dosei],a):*crm_psi(d[dosei],a):*crm_g(a):*prodphi  )
  }
}
/***************************************************
 * Functions to find quantiles of the posterior
 ***************************************************/ 
void eval_quantiles(todo, x, q, K, quadp, y, g, H)
{
  data=st_matrix("data")
  yy = data[.,1]'
  dose = data[.,2]'
  y=((1-q)- integrate_CRM(&crm_posterior(), 0, exp(x), quadp, (dose',yy'))/K)^2
  if (todo==1) {
    g= crm_posterior(x,(dose',yy'))/K
  }
}

/*************************************
 * The main CRM function
 *************************************/

void mycrm(real priormean, real target, string vlist, scalar dist, scalar quadpts)
{
/* The varlist should contain y and then dose */
  data=st_data(., vlist)
  y = data[.,1]'
  dose = data[.,2]'
  st_matrix("data", data)
  priorp = st_matrix("prior")
  dlab = st_matrix("dlab")
  ndose = cols(priorp)
/*********************************************
 * Display the observations
 *********************************************/
 
 printf("{txt}Observations\n{dup 5:{c -}}{c TT}{dup 61:{c -}}\nDose {c |}")
 for(i=1;i<=cols(dlab);i++) {
   if(i==1) {
     dosefreq = sum(dose:==i)
     toxfreq = sum(select(y,dose:==i))
   }
   else {
     dosefreq = dosefreq,sum(dose:==i)
     toxfreq = toxfreq,sum(select(y,dose:==i))
   }
   printf("{res} %3.0f", dlab[i])
 }
 printf("{col 68}{txt}\n{txt}   n {txt}{c |}")
 for(i=1;i<=cols(dlab);i++) {
   printf("{res} %3.0f", dosefreq[i]) 
 }
 printf("{col 68}{txt}\n{txt} tox {c |}")
 for(i=1;i<=cols(dlab);i++) {
   printf("{res} %3.0f", toxfreq[i]) 
 }
 printf("{col 68}{txt}\n{dup 5:{c -}}{c BT}{dup 61:{c -}}\n")

/****************************************************************
 * Doing the inverse of the psi and skeleton to get the rescaled 
 *  doses uing E(a)=priormean, will need to make this flexible 
 *  if the sd is required as well
 * Creates the Stata matrix d with the standardised doses in
 ****************************************************************/
  for (i=1;i<=cols(priorp);i++) {
    if (crm_invpsi(priorp[i], priormean)==.) {
      printf("\n{pstd}{err} standardised dose is missing for prior mean %f and prior probability of toxicity %f \n",priormean, priorp[i])
      printf("\n{pstd} Try another prior mean or distribution \n")
      exit(202)
    }
    if (i==1) d = crm_invpsi(priorp[i], priormean)
    else d = d, crm_invpsi(priorp[i], priormean)
  }
  st_matrix("d",d)

  printf("\n{txt}Standardised dose from prior toxicities \n{res}")
 printf("{txt}{dup 5:{c -}}{c TT}{dup 75:{c -}}\n")
  printf("{txt}dose {c |}")
  for(i=1;i<=cols(dlab);i++) {
    printf("{res} %4.0f", dlab[i]) 
  }
  printf("{col 68}{txt}\n{txt}sdose{txt}{c |}")
  for(i=1;i<=cols(dlab);i++) {
    printf("{res} %4.1f", d[i]) 
  }
  printf("{col 68}{txt}\n{dup 5:{c -}}{c BT}{dup 75:{c -}}\n")

/******************************************************************************************
 * With first observation need to evaluate the constant term of posterior 
 *    f(a, sig_j+1) eqn 2.2
 *  For each observation do the posterior calculations
 *    i) work out int f(x|a)h(a) da  to get scaling factor  K
 *    ii) then find E(a|x) =  int af(x|a)h(a)  / K
 *    iii) then for each dose do  int  psi(x, a) f(x|a)h(a) to get mean tox probs
 ******************************************************************************************/

  obs=cols(y)
  if (obs==0) K = integrate_CRM(&crm_posterior(), 0, ., quadpts, NULL)
  else K = integrate_CRM(&crm_posterior(), 0, ., quadpts, (dose'[1::obs],y'[1::obs]))
  if (obs==0) mu = integrate_CRM(&mudenom(), 0, .,quadpts, NULL)/K
  else  mu = integrate_CRM(&mudenom(), 0, .,quadpts, (dose'[1::obs],y'[1::obs]))/K

  if (obs==0) {
    for(i=1; i<=ndose; i++) {
      if (i==1) {
        prob = integrate_CRM(&mupost(), 0,.,quadpts, (i,i))/K
	      prob2 = integrate_CRM(&mupost2(), 0, .,quadpts, (i,i))/K
      }
      else {
	      prob =prob, integrate_CRM(&mupost(), 0,.,quadpts, (i,i))/K
	      prob2 = integrate_CRM(&mupost2(), 0, .,quadpts, (i,i))/K
      }
    }
  }
  else {
    for(i=1; i<=ndose; i++) {
      if (i==1) {
        prob = integrate_CRM(&mupost(), 0,.,quadpts, ((i,i)\(dose'[1::obs],y'[1::obs])) )/K
	      prob2 = integrate_CRM(&mupost2(), 0,.,quadpts, ((i,i)\(dose'[1::obs],y'[1::obs])) )/K
      }
      else {
	      prob =prob, integrate_CRM(&mupost(), 0,.,quadpts, ((i,i)\(dose'[1::obs],y'[1::obs])) )/K
	      prob2 =prob2, integrate_CRM(&mupost2(), 0,.,quadpts, ((i,i)\(dose'[1::obs],y'[1::obs])) )/K
      }
    }
  }
  varprob = prob2 :- prob:^2

/************************
 ************* PROBLEM do I do a plug in mean to pick the next dose??? NO NONONONONONOON
 ************************/
 
/*********************************************************
 * For each dose use the current mean a and find what the 
 *  predicted probabilities are for the model
 * Then calculate the difference of this to the TTL
 *********************************************************/
/*  for (i=1; i<=ndose; i++) {
    if (i==1) {
      theta = crm_psi(d[i], mu)
      delta = delta(theta[i], target, dist)
    }
    else {
      theta = theta, crm_psi(d[i], mu)
      delta = delta, delta(theta[i], target, dist)
    }
  }
*/  
  newdelta = (prob :- target):^2
  minindex(newdelta,1,pick, irrelevant)
    
/****************************
 * Now print the outcome
 ****************************/

  printf("\nNext recommmended dose(s)\n")
  printf("{dup 25:{c -}}\n")
  dlab[pick]
  st_matrix("pick", pick)
  
/*********************************************************************
 * Calculating the quantiles of the distribution of a and reading off 
 * the quantiles for tox risk using crm_psi(dose,quant)
 *********************************************************************/
 printf("\n{txt}Starting calculation of posterior quantiles...\n")
 qs= (0.025,0.25,0.5,0.75,0.975)
 quant=qs
 S = optimize_init()
 optimize_init_which(S, "min")
 optimize_init_evaluator(S, &eval_quantiles())
 optimize_init_evaluatortype(S, "d0")
 optimize_init_argument(S, 2, K) /* this is the normalising constant*/
 optimize_init_argument(S, 3, quadpts) /* this is quadrature points*/
 optimize_init_trace_value(S, "off")
 optimize_init_params(S, 0) 
 for(j=1;j<=cols(qs);j++) {
   optimize_init_argument(S, 1, qs[j])
   lp=optimize(S)
   chk =  optimize_result_converged(S)
   if (!chk) printf("{err}A lack of convergence in calculating quantiles... increase quad pts\n")
   quant[j]=exp(lp)
   
 }
 
 /********************************
 * Printing the results
 ********************************/

  printf("\n\n\n{txt}Probability of toxicity after last patient\n\n")
  printf(" Dose{c |} {col 8} Mean   (sd) {c |}  2.5%%    25%%    50%%    75%%  97.5%%\n")
  printf("{txt}{dup 5:{c -}}{c +}{dup 14:{c -}}{c +}{dup 34:{c -}}\n")
  for(i=1; i<=ndose;i++) {
    printf("{res}%5.0f{txt}{col 6}{c |}{res} %5.3f (%5.3f){txt}{c |}{res} %5.3f  %5.3f  %5.3f  %5.3f  %5.3f \n", dlab[i], prob[i], sqrt(varprob[i]), crm_psi(d[i],quant[1]), crm_psi(d[i],quant[2]), crm_psi(d[i],quant[3]), crm_psi(d[i],quant[4]), crm_psi(d[i],quant[5]))
    if (i==1) output = (i,dlab[i],dosefreq[i],toxfreq[i],prob[i],sqrt(varprob[i]), crm_psi(d[i],quant[1]), crm_psi(d[i],quant[2]), crm_psi(d[i],quant[3]), crm_psi(d[i],quant[4]), crm_psi(d[i],quant[5]))
    else output = output \ (i,dlab[i],dosefreq[i],toxfreq[i],prob[i],sqrt(varprob[i]), crm_psi(d[i],quant[1]), crm_psi(d[i],quant[2]), crm_psi(d[i],quant[3]), crm_psi(d[i],quant[4]), crm_psi(d[i],quant[5]))
  }
  st_matrix("output",output)
  printf("{txt}{dup 5:{c -}}{c BT}{dup 14:{c -}}{c BT}{dup 34:{c -}}\n")

/* Calculations when using the plug-in mean of posterior of a
  printf("{txt}Mean probability of tox using {bf}plug-in {sf}{txt}mean\n")
  printf(" Dose{c |} {col 8} Mean prob(sd)\n")
  printf("{txt}{dup 5:{c -}}{c +}{dup 20:{c -}}\n")
  for (i=1; i<=ndose;i++) {
     printf("{res}%5.0f{txt}{col 6}{c |}{res}  %5.3f", dlab[i], crm_psi(d[i],mu) )
     printf("{res} (%5.3f) \n", sqrt(varprob[i]))
  }
*/

} /* end of mycrm */


/***********************************************************
 * The main part of the integrate function
 *    will need to check whether this is a definite or 
 *    infinite integral by using missing data
 ***********************************************************/ 
real scalar integrate_CRM(pointer scalar integrand, real scalar lower, real scalar upper, | real scalar quadpts, transmorphic xarg1)
{
  if (quadpts==.) quadpts=60
  if (args()<5) { /* this is for single dimensional functions without arguments */
    if ((lower==. & upper==.) | (lower==0 & upper==.) |(lower~=. & upper~=.)) {
     return( Re(integrate_CRM_main(integrand, lower, upper, quadpts)) )
    }
    else if (lower==. & upper~=.) {
      return( Re(integrate_CRM_main(integrand, 0,upper,quadpts) + integrate_CRM_main(integrand, 0,.,quadpts)) )
    }
    else if (lower~=0 & upper==.) {
      return( Re(integrate_CRM_main(integrand,lower,0,quadpts)+integrate_CRM_main(integrand, 0,.,quadpts)) )
    }
    else {
      return( Re(integrate_CRM_main(integrand, lower, upper, quadpts)) )
    }
  }
  else { /*there is an argument to be handled */
    if ((lower==. & upper==.) | (lower==0 & upper==.) |(lower~=. & upper~=.)) {
     return( Re(integrate_CRM_main(integrand, lower, upper, quadpts, xarg1)) )
    }
    else if (lower==. & upper~=.) {
      return( Re(integrate_CRM_main(integrand, 0,upper,quadpts, xarg1) + integrate_CRM_main(integrand, 0,.,quadpts, xarg1)) )
    }
    else if (lower~=0 & upper==.) {
      return(  Re(integrate_CRM_main(integrand,lower,0,quadpts, xarg1)+integrate_CRM_main(integrand, 0,.,quadpts, xarg1)) )
    }
    else {
      return( Re(integrate_CRM_main(integrand, lower, upper, quadpts, xarg1)) )
    }  
  }
}/* end of integrate*/

/*******************************************************************************
 * This is the main algorithm for doing a single integral 
 * with standard limits
 *******************************************************************************/
matrix integrate_CRM_main(pointer scalar integrand, real lower, real upper, real quadpts, | transmorphic xarg1)
{
  if (args()<5) { /* This means not containing additional arguments */
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      rw = legendreRW(quadpts)
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ) )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral 0 to inf */
    else if ( lower==0 & upper==.) {
      rw = laguerreRW(quadpts, 0) /* alpha I think can be anything */
      sum = rw[2,]:* exp(Re(rw[1,])) :* (*integrand)( Re(rw[1,]) )
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral -inf to inf */
    else if( lower==. & upper==.) {
      rw = hermiteRW(quadpts)
      sum = rw[2,] :* exp( Re(rw[1,]):^2 ) :* (*integrand)( Re(rw[1,]) )
      return(quadrowsum(sum))
    }
  }
  else {
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      rw = legendreRW(quadpts)
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral 0 to inf */
    else if ( lower==0 & upper==.) {
      rw = laguerreRW(quadpts, 0) /* alpha I think can be anything */
      sum = rw[2,]:* exp(Re(rw[1,])) :* (*integrand)( Re(rw[1,]), xarg1 )
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral -inf to inf */
    else if( lower==. & upper==.) {
      rw = hermiteRW(quadpts)
      sum = rw[2,] :* exp( Re(rw[1,]):^2 ) :* (*integrand)( Re(rw[1,]), xarg1 )
      return(quadrowsum(sum))
    }
  }
} /*end integrate_main*/

/***************************************************************
 *  Legendre roots/weights
 * This is the clever code to get the roots and weights without 
 * having to use the polyroots() function which starts breaking 
 * down at n=20
 * L contains the roots and w are the weights
 ***************************************************************/
matrix legendreRW(real scalar quadpts)
{
  i = (1..quadpts-1)
  b = i:/sqrt(4:*i:^2:-1) 
  z1 = J(1,quadpts,0)
  z2 = J(1,quadpts-1,0)
  CM = ((z2',diag(b))\z1) + (z1\(diag(b),z2'))
  V=.
  L=.
  symeigensystem(CM, V, L)
  w = (2:* V':^2)[,1]
  return( L \ w') 
} /* end of legendreRW */

/****************************************************************
 * Laguerre Roots and Weights
 ****************************************************************/
matrix laguerreRW(real scalar quadpts, real scalar alpha)
{
  i1 = (1..quadpts)
  i2 = (1..quadpts-1)
  a = (2:*i1:-1):+alpha
  b = sqrt( i2 :* (i2 :+ alpha))
  z1 = J(1,quadpts,0)
  z2 = J(1,quadpts-1,0)
  CM = (diag(a)) + (z1\(diag(b),z2')) + ((z2',diag(b))\z1)
  V=.
  L=.
  symeigensystem(CM, V, L)
  w = (gamma(alpha+1) :* V':^2 )[,1]
  return( L \ w') 
} /* end of laguerreRW */

/*************************************************************************
 * Hermite Roots and Weights THERE are rounding problems with 
 * symeigensystem that mess this function up at 200+quadptsthis function!
 *************************************************************************/
matrix hermiteRW(scalar quadpts)
{
   i = (1..quadpts-1)
   b = sqrt(i:/2)
   z1=J(1,quadpts,0)
   z2=J(1,quadpts-1,0)
   CM = ((z2\diag(b)),z1') + (z1',(diag(b)\z2))
   V=.
   L=.
   symeigensystem(CM, V, L)
   w =  ( sqrt(pi()) :* V':^2 )[,1]
   return(L \ w')
   
} /* end of hermiteRW */


end /* end of Mata */





