*! Date    : 14 Jul 2020
*! Version : 1.03
*! Author  : Adrian Mander
*! Email   : mandera@cardiff.ac.uk
*! PIPE - the product of independent probabilities escalation
*! A dose escalation command using a model-free approach
/*
31Oct12 v1.00 The command is born
25Feb15 v1.01 25Feb15 Trying to finalise command post publication
31Jul15 v1.02 Just continuing my efforts
14Jul20 v1.03 picking this up in Cardiff
*/

/*
 NOTES TO ME 
------------
Need a version to read in a dataset
*/


/* START HELP FILE
title[A curve-free dual-agent dose-escalation design]

desc[
 {cmd:pipe} either takes a dataset and suggests the next dose combination and reports
various outputs or it performs simulations.
]

opt[maxsims() specifies the maximum number of simulations to perform.]
opt[maxn() specifies the maximum sample size per trial.]
opt[cohortsize() specifies the size of the cohort per dose administration.]
opt[graph() specifies that graphs of the simulation outputs are produced.]
opt[saving() specifies that the simulation output graphs are saved.] 
opt[theta() specifies the target toxicity limit.]
opt[pwt() specifies the total prior sample size, this can be very low and often 1 is sufficient]
opt[prior() specifies the prior matrix of DLT probabilities.]
opt[true() specifies the true matrix of DLT probabilities. ]
opt[nxzone() specifies the which doses to escalate to.]
opt[nxcons() specifies whether there are any constraints of the dose escalation.]
opt[nxsafe() specifies the safety limit on administering a dose combination.]
opt[nxsel() specifies the dose escalation rule. ]

opt2[nxcons() specifies whether there are any constraints of the dose escalation. There are 3 different options either: 0 no constraint; 1 escalation is to neighbours of the current dose and does not allow dose skipping; or 2 escalation is allowed anywhere but no dose skipping is allowed.
]

example[
 {stata pipe}
]

author[Prof Adrian Mander]
institute[Cardiff University]
email[mandera@cardiff.ac.uk]

return[n1 The first stage sample size]

freetext[]

references[
AP Mander and MJ Sweeting (2015) A product of independent beta probabilities dose escalation design for dual‐agent phase I trials. SiM 34:1261-1276.
]

seealso[
{help crm} (if installed)   {stata ssc install crm} (to install this command)

{help mtpi} (if installed)  {stata ssc install mtpi} (to install this command)
]

END HELP FILE */


pr pipe,rclass
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
  syntax [, MAXSims(integer 1) MAXN(integer 8) Cohortsize(integer 2) Graph(string) Saving(string)  /*
*/ Theta(real 0.3) PWT(real 1) PRIOR(string) TRUE(string) /*
*/ NXZone(string) NXCons(integer 0) NXSAFE(real 0.6) NXSel(string)] 

  clear
/******************************
 * Set up some default values
 ******************************/
  if "`prior'"=="" {
    matrix prior = ( 0.32, 0.34 \  0.26,  0.33 )
    matrix true = ( 0.32,  0.34 \ 0.26,   0.33 )
  }
  else {
    matrix prior = `prior'
    matrix true = `true'
  }
  local truerownames: rownames true
  local truecolnames: colnames true
 
/* The next default values are about selecting the next dose
nxcons 0 no constraint
nxcons 1 neighbour nodose skipping
nxcons 2 non-neighbour no dose skipping

nxsafe 1 safety constraint as well

nxsel 1 SS <--- only one implemented for now!
nxsel 2 WR ss
nxsel 3 pdf <- DROPPED
nxsel 4 both <- DROPPED
nxsel 5 most informative doses but need cohort size to be even!
*/

  if "`nxzone'"=="" local nxzone "closest"
  if "`nxzone'"=="adjacent" local nx_zone 1
  else if "`nxzone'"=="closest" local nx_zone 2
  else { 
    di "{err} WARNING: Problem with nxzone() option, adjacent now selected"
    local nx_zone 1
    local nxzone "adjacent"
  }

  if "`nxsel'"=="" local nxsel "ss"
  if "`nxsel'"=="ss" local nx_sel 1
  else {
    local nx_sel 1
    local nxsel "ss"
    di "{err}Note: NXsel() only allows ss at the moment"
  }

/*****************************************************
 * Introductory output 
 *****************************************************/
 
  di "{txt}PIPE, product of independent probabilities escalation"
  di "{dup 53:{c -}}"

  if colsof(prior)==1 di "Single dose escalation was selected and there are {res}" rowsof(prior) "{txt} doses"
  else di "Dual agent dose escalation was selected and there are {res}" 
  di colsof(prior) "{txt} doses of one drug and {res}" rowsof(prior) "{txt} of the other"
  di "Target toxicity level is  {res} `theta' "
  di "{txt}Prior weight is {res}`pwt'"
  di "{txt}Maximum study size {res}`maxn'{txt}, Cohortsize {res}`cohortsize'{txt} and maximum simulations {res}`maxsims'" 
  di
  if "`nxcons'"=="0" di "{txt}Dose-skipping constraints are not enabled"
  if "`nxcons'"=="1" di "{txt}Dose-skipping constraints are neighbouring the {bf:current} dose"
  if "`nxcons'"=="2" di "{txt}Dose-skipping constraints are neighbouring any {bf:previous} dose"
  if "`nxzone'"=="adjacent" di "Pick from {bf:adajacent} dose combinations"
  if "`nxzone'"=="closest" di "Pick from {bf:closest} dose combinations"
  if "`nxsel'"=="ss" di "Pick the next dose combination with {bf:smallest sample size}"
  di
  di "{p}Under the safety constraint no dose combinations with a probability above the TTL averaged over the MTD contours can exceed {res}`nxsafe'{txt}"
  di

/*************************************************
 * Run pipe and sort out the output matrix names
 *************************************************/
  mata: pipe( `theta', `pwt', `maxn', `cohortsize', `maxsims', `nx_zone', `nxcons', `nxsafe', `nx_sel')
  cap matrix rownames dlt= `truerownames'
  if _rc~=0 { 
    di "{Err}ERROR: Problem with row names of dlt"
    matrix rownames dlt= `truerownames'
  }
  cap matrix colnames dlt= `truecolnames'
  if _rc~=0 { 
    di "{Err}ERROR: Problem with col names of dlt"
    matrix colnames dlt= `truecolnames'
  }
  matrix rownames experimentation= `truerownames'
  matrix colnames experimentation= `truecolnames'
  matrix rownames recommended= `truerownames'
  matrix colnames recommended= `truecolnames'

/*************************************************************
 * with the matrices created above heatmaps are produced
 *************************************************************/
  if "`graph'"~="" {
    qui plotmatrix, mat(dlt) title(Observed P(DLT)) saving(dlt,replace) nodraw s(0 0.0001 0.01(0.01)1)
    qui plotmatrix, mat(recommended) title(Recommendation) saving(rec,replace) nodraw s(0.001 0.01 0.05 0.1 0.2 0.4 0.6 0.8 1)
    qui plotmatrix, mat(experimentation) title(Experimentation) saving(exp,replace) nodraw s(0.001 0.01 0.05 0.01 0.02 0.03 0.04 0.06 0.08 0.1 0.2 1)
    qui plotmatrix, mat(true) title(True P(DLT)) saving(true,replace) nodraw s(0.01 0.05 0.15 0.25 0.35 0.45 0.8 1) 
    qui graph combine dlt.gph rec.gph exp.gph true.gph, saving(`graph', replace)
  }

/***************************************************************
 * The simulation results are saved as a dataset
 ***************************************************************/
  qui svmat tox_rec
  qui svmat tox_exp
  qui svmat dlt, names(dlt)
  qui svmat experimentation, names(exp)
  qui svmat recommended, names(rec)
  qui svmat true, names(true)
  if "`saving'"~="" qui save `saving'

/****************************************
 * the code to do the nice mike graphics
 ****************************************/

  if "`maxsims'"=="1" {
    di 
    di "{txt}About to produce individual trial graph..."
    local nog = nog[1,1]
    local gg "g1.gph"
    forv i=2/`=`nog'' {
      local gg "`gg' g`i'.gph"
    }
    graph combine `gg', imargin(small) 
  }
  qui restore
end

/***************************** MATA START **************************************/
mata:

/*******************************************************************************
 * Define structures
 *  design - prior,data and posterior probs 
 *  dltcont - possible monotonic contours, how doses above MTC, MTC distribution
 *  siminfo - capture all the simulation data
 *******************************************************************************/
struct design {
  real a		       /* The prior value */
  real b		       /* The prior value */
  real dlt             /* observed dlts */
  real n               /* current sample size */
  real pa              /* these are the posterior Beta distn values*/
  real pb              /*  the b of the posterior Beta value */
  real ppt  , pptu, pptl  /* posterior probs <=theta , thetau and thetal  currently we don't need upper and lower values*/
  real ppt1, ppt2, ppt3, ppt4, ppt5, ppt6, ppt7, ppt8, ppt9, ppt10, ppt11, ppt12, ppt13, /*
  */   ppt14, ppt15, ppt16, ppt17, ppt18, ppt19 /* posterior tails for 0.05,...,0.95*/
  real pdft            /* posterior density at theta , again an idea not really needed */
  real matrix F   /* Posterior tails */
  real matrix Fp  /* Posterior tail probabilities */
  real matrix sc
  real matrix scp
  real matrix sc1, sc2, sc3, sc4, sc5, sc6, sc7, sc8, sc9, sc10, sc11, sc12, sc13, sc14, sc15, sc16, sc17, sc18, sc19   
      /* this is the calculation of prob over TTL averaged over all mtd contours for each 0.05...0.95 for each dose combination */
  real ledge       /* contains the left edge row probability averaged over MTD contour */
  real bedge       /* contains the bottom edge col probability averaged over MTD contour */
  real median      /* contains the bottom edge col probability averaged over MTD contour */
}

struct dltcont {  /* this contour structure contains all possible contours  .gt[i,j] , 
                    then the probability of each of them and sum */
  real matrix gt  /* this contains the contour binary matrix, 1 being above MTC 0 below */
  real gtsum      /* this is the sum of ones within gt i.e. number of doses above the MTC  ?used in safety constraint?*/
  real pt  , ptu, ptl       /* these are the probabilities of each contour given theta, theta upper and theta lower */
  real sumt , sumtu, sumtl  /* this is the sum of the probs above (Obviously restricted to monotonic contours only) */
  real pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8, pt9, pt10, pt11, pt12, pt13, pt14, pt15, pt16, pt17, pt18, pt19     
  /* these are the probabilities of each contour given theta = 0.05 ... 0.95 (and their sum) */
  real sumt1, sumt2, sumt3, sumt4, sumt5, sumt6, sumt7, sumt8, sumt9, sumt10, sumt11, sumt12, sumt13, sumt14, sumt15, sumt16, sumt17, sumt18, sumt19     
}  
 
struct siminfo {                  /* a structure to accumulate any simulations */
  real matrix nexp, ndlt, nrmtd   /* no experimented on , no dlts, no rmtd?*/  
}

/******************************************************************************* 
 * The MAIN program loop 
 *******************************************************************************/
void pipe(theta, priorwt, maxn, cohortsize, maxsims, nxzon, nxcon, nxsaf, nxsel)
{
 
  /* rseed(1) */
 
  /* Start by passing through the information from Stata */ 
  prior = st_matrix("prior")
  priorrowname = st_matrixrowstripe("prior")
  priorcolname = st_matrixcolstripe("prior")
  true = st_matrix("true")
  truerowname = st_matrixrowstripe("true")
  truecolname = st_matrixcolstripe("true")

  /* Checking errors in the prior and whether true is a different dim to prior*/
  if (rows(prior)~=rows(true)) { 
    printf("{err}The prior has a different dimension to the truth")
    exit(201)
  }
  if (cols(prior)~=cols(true)) {
    printf("{err}The prior hass a different dimension to the truth")
    exit(201)
  }
  for(i=1;i<=rows(prior);i++) {
    for(j=1;j<=cols(prior);j++) {
      if (j~=cols(prior)) {
          if (prior[i,j]>=prior[i,j+1]) {
            printf("{err}WARNING: prior is not monotonic along columns\n")
            printf("Is  %f > %f?\n", prior[i,j], prior[i,j+1])
          }
      }
      if (i~=rows(prior)) {
        if (prior[i,j]<=prior[i+1,j]) {
          printf("{err}WARNING: prior is not monotonic along rows at elements (%f,%f) and (%f,%f) \n", i,j, i+1,j)
          printf("NOTE: the prior matrix should have the lowest dose combination in the left bottom corner")
          printf("Is  %f < %f\n", prior[i,j], prior[i+1,j])
        }
      }
    }
  }
  /********************** Print the prior *******************************/
  printf("{txt}Priors for each dose combination \n")
  for(i=1;i<=rows(prior);i++) {
    if (i==1) {
      for(jj=1;jj<=cols(prior);jj++) {
        if (jj==1) printf("{txt}         %2s", priorcolname[jj,2])
        else printf("{txt}      %2s", priorcolname[jj,2])
      }
      printf("\n     {c TLC}")
      for(jj=1;jj<=cols(prior);jj++) {
        printf("{txt}{dup 8:{c -}}")
      }
      printf("{c TRC}\n")
    }
    for(j=1;j<=cols(prior);j++) {
      if (j==1) printf("{txt} %3s {c |}{res} %4.3f  ", priorrowname[i,2], prior[i,j])
      else printf("{res} %4.3f  ", prior[i,j])
    }
    printf("{txt}{c |}\n")
    if(i==rows(prior)) {
      printf("     {c BLC}")
      for(jj=1;jj<=cols(prior);jj++) {
        printf("{txt}{dup 8:{c -}}")
      }
    printf("{c BRC}\n")
    }
  }
  /****** Print the true values ***********/
  printf("{txt}True values for each dose combination \n")
  for(i=1;i<=rows(true);i++) {
    if (i==1) {
      for(jj=1;jj<=cols(true);jj++) {
        if (jj==1) printf("{txt}         %2s", truecolname[jj,2])
        else printf("{txt}      %2s", truecolname[jj,2])
      }
      printf("\n     {c TLC}")
      for(jj=1;jj<=cols(true);jj++) {
        printf("{txt}{dup 8:{c -}}")
      }
      printf("{c TRC}\n")
    }
    for(j=1;j<=cols(true);j++) {
      if (j==1) printf("{txt} %3s {c |}{res} %4.3f  ", truerowname[i,2], true[i,j])
      else printf("{res} %4.3f  ", true[i,j])
    }
    printf("{txt}{c |}\n")
    if(i==rows(true)) {
      printf("     {c BLC}")
      for(jj=1;jj<=cols(true);jj++) {
        printf("{txt}{dup 8:{c -}}")
      }
    printf("{c BRC}\n")
    }
  }

 /*
 NEED a version that reads in a DATASET to be entered here
 */
 
 /*****************************************************************************
  * Structures for contours  and put all the possible monotonic contours
  * in the allcontours structure   
  * NOTE mtd contains all the possible contours!!!!!
  *****************************************************************************/
  struct dltcont scalar icontours
  icontours.pt = 0
  icontours.pt1 = 0
  icontours.pt2 = 0
  icontours.pt3 = 0
  icontours.pt4 = 0
  icontours.pt5 = 0
  icontours.pt6 = 0
  icontours.pt7 = 0
  icontours.pt8 = 0
  icontours.pt9 = 0
  icontours.pt10 = 0
  icontours.pt11 = 0
  icontours.pt12 = 0
  icontours.pt13 = 0
  icontours.pt14 = 0
  icontours.pt15 = 0
  icontours.pt16 = 0
  icontours.pt17 = 0
  icontours.pt18 = 0
  icontours.pt19 = 0
  icontours.sumt1 = 0
  icontours.sumt2 = 0
  icontours.sumt3 = 0
  icontours.sumt4 = 0
  icontours.sumt5 = 0
  icontours.sumt6 = 0
  icontours.sumt7 = 0
  icontours.sumt8 = 0
  icontours.sumt9 = 0
  icontours.sumt10 = 0
  icontours.sumt11 = 0
  icontours.sumt12 = 0
  icontours.sumt13 = 0
  icontours.sumt14 = 0
  icontours.sumt15 = 0
  icontours.sumt16 = 0
  icontours.sumt17 = 0
  icontours.sumt18 = 0
  icontours.sumt19 = 0
  icontours.sumt = 0
  struct dltcont vector contours  /* set up vector of contours */
  contours = icontours            /* put in initial values as nothing into structure*/
  ndoses = (rows(prior), cols(prior))
  mtd = findallcontours(ndoses, contours)
  
 /*
 printcontours(mtd)
 */
 
/****************************************************************************
 * Set up the structures for design i.e. data, priors, posterior probabilities no data
 * struct mtddist matrix mtd
 ****************************************************************************/ 
  struct design matrix stprior
  struct design scalar idp        /* idp stands for initialise data and prior to be nothing */
  idp.dlt=0                       /* no. dlts*/
  idp.n=0                         /* no. people */
  idp.sc=J(1,19,0)                /* the safety contour */
  idp.scp = range(0.05,0.95,0.05) /* the safety contour probabilities */
  idp.F=J(1,19,0)                 /* the posterior probabilities */
  idp.Fp = range(0.05,0.95,0.05)  /* the posterior tail contour probabilities */
  idp.ledge = 0                   /* the left edge probabilities */
  /* struct design matrix dataprior containing 0 data */
  dataprior = J(rows(prior),cols(prior), idp)

  /* keep track of dosing */
  previousdoses = J(rows(prior),cols(prior), 0)
 
  /* structures for sims */
  struct siminfo vector allsim
  struct siminfo scalar isim
  isim.nexp = J(rows(true),cols(true),0)
  isim.ndlt = J(rows(true),cols(true),0)
  isim.nrmtd = J(rows(true),cols(true),0)
  allsim = isim

/********************************************************************
 *                         Start simulations
 ********************************************************************/
  for(sims=1;sims<=maxsims;sims++) {
    if ((maxsims>10) & (mod(sims,10)==0)) {
      if (sims==10) printf("\nRunning simulations\n")
      printf(".%f", sims)
    }
    /*
      For each dose combination find the a,b values given the prior distribution and weight
      NOTE that priorwt is specified by stata option pwt() default is 1.
      medianbpriors returns a DESIGN structure containing the stprior  dataprior was a null structure
    */
    /*betaprior = meanbpriors(prior, priorwt)   <--- MEAN priors but this won't work anymore as not in structure language*/
    stprior = medianbpriors(prior, priorwt, dataprior)  

    /* 
     * The next command works out the posterior distributions adding dlt and n data to a and b   
     *  and then all tail probabilities for each dose combination
     *  independently and store it in the stprior structure  THIS IS REALLY where the TTL (theta) is set 
     *  and where ****NXSAFE**** should be!
     */
    stprior = calcposterior(stprior, theta)   
   
    /*
     * With the data and tail probabilities work out the probability of each possible mtd contour 
     *  assuming all the different percentiles 5%-95% and theta=TTL
     *  mtd holds all monotonic contours and stprior has data/prior
     *  this must return a dltcont structure and gets passed a dltcont structure 
     *  with gt=contour, pts, sumts
     */
    newmtd = calcmtd(stprior, mtd)


    /* Calculate the median MTD contour 
        stprior[i,j].median contains 1 for being above median (average prob) and 0 otherwise
    */
    stprior = calcmedianmtd(stprior, newmtd)

//    if (maxsims==1) printdes(stprior)
//     printmtd(newmtd)
 
    /* MAIN loop for each new patient */  
    /* A reminder of the options
		nxcons 0 no constraint
		nxcons 1 neighbour nodose skipping
		nxcons 2 non-neighbour no dose skipping

		nxsafe 1 safety constraint as well

		nxsel 1 SS
		nxsel 2 WR ss
		nxsel 3 pdf <- DROPPED
		nxsel 4 both <- DROPPED
		nxsel 5 most informative doses but need cohort size to be even!
	*/
	
   /* NEED to allocate first dose as the lowest dose to the first cohort*/
    newdose = (rows(prior),1)                               /* pick lowest dose as new dose*/
    stprior = gendata(stprior, true, newdose, cohortsize)   /* adds to n and dlt of stprior at newdose*/
    stprior = calcposterior(stprior, theta)
    newmtd = calcmtd(stprior, mtd)
    stprior = calcmedianmtd(stprior, newmtd)
    currentdose = J(rows(prior),cols(prior), 0)

    /* This means start at (max which is lowest doseA,1) reversed things to go up page */
    currentdose[newdose[1],newdose[2]]=1  
    /* Add latest dose to the previousdoses NOTE not sure if this should be cohortsize, n or 1 */
    previousdoses[newdose[1], newdose[2]]=previousdoses[newdose[1], newdose[2]]+cohortsize 

/* DEBUG PRINTS
   printf("NEED to check lowest dose is below safety constraint... \n")
   printf("{err}------------ After first cohort of patients------- \n")
       desout(stprior)
       printtopmtd(newmtd,6)    
*/

    /* Do a plot if maxsims==1 */
    if (maxsims==1) {/* Do the first graph for a single sim evolution graph*/
      nog=1
      stata("qui clear")
      gn=get_n(stprior)
      gdlt=get_dlt(stprior)
      gmtd=get_modal_mtd(newmtd)  /* the modal estimator the original */
      a=rows(uniqrows(select(vec(gn),vec(gn):~=0)))
      b=rows(uniqrows(select(vec(gdlt),vec(gdlt):~=0)))
      stata("qui twoway "+pipe_heatmap(gn,1)+pipe_scatter(gdlt,a)+pipe_contour(gmtd, 2, a+b+1)+pipe_median_contour(stprior, a+b+2)+" , title(Cohort "+strofreal(nog)+") saving(g"+strofreal(nog)+",replace) nodraw ")
//    stata(pipe_heatmap(gn,1)+pipe_scatter(gdlt,a)+" , title(Cohort "+strofreal(nog)+") saving(g"+strofreal(nog)+",replace)  ")
//    stata(pipe_heatmap(gn,1)+pipe_scatter(gdlt,a)+pipe_wt_edges(stprior)+" ,title(Cohort "+strofreal(nog)+") saving(gg"+strofreal(nog)+",replace) legend(off) nodraw xscale(off) yscale(off)")
    }

    for(pat=1+cohortsize;pat<=maxn;pat=pat+cohortsize) { /* Now start at the second cohort */
      safety_con = calc_safety(stprior, newmtd)
      stprior = calc_safety2(stprior, newmtd)
      newdose = nxdose(currentdose, previousdoses, newmtd, stprior, nxzon, nxcon, nxsaf, nxsel, (safety_con:>nxsaf))
      if (newdose~=(0,0)) { /* i.e. we have a new dose and the trial continues*/
        /* update the current dose to this new dose*/
        currentdose = J(rows(prior),cols(prior), 0)
        currentdose[newdose[1],newdose[2]]=1
        previousdoses[newdose[1], newdose[2]]=previousdoses[newdose[1], newdose[2]]+cohortsize
  
        /*Need to generate some data at new dose*/
        stprior = gendata(stprior, true, newdose, cohortsize)
        stprior = calcposterior(stprior, theta)
        newmtd = calcmtd(stprior, mtd)
        stprior = calcmedianmtd(stprior, newmtd)
 
        /* Do a plot if maxsims==1 */
        if (maxsims==1) {
          nog++
          stata("qui clear")
          gn=get_n(stprior)
          gdlt=get_dlt(stprior)
          gmtd=get_modal_mtd(newmtd)
          a=rows(uniqrows(select(vec(gn),vec(gn):~=0)))
          b=rows(uniqrows(select(vec(gdlt),vec(gdlt):~=0)))
          stata("qui twoway "+pipe_heatmap(gn,1)+pipe_scatter(gdlt,a)+pipe_contour(gmtd, 2, a+b+1)+pipe_median_contour(stprior, a+b+2)+" ,title(Cohort "+strofreal(nog)+") saving(g"+strofreal(nog)+",replace) nodraw ")
//        stata(pipe_heatmap(gn,1)+pipe_scatter(gdlt,a)+pipe_wt_edges(stprior)+" ,title(Cohort "+strofreal(nog)+") saving(gg"+strofreal(nog)+",replace) legend(off) nodraw xscale(off) yscale(off)")
          st_matrix("nog",nog)
        }
     
      } /* end of dose (0,0) if statement */
      else {
        break
      }
    } /* end of pat loop */

    /* Some code at end to get recommended dose*/
    recdose = recdose(currentdose, previousdoses, newmtd, stprior, nxzon, nxcon, nxsaf, nxsel, (safety_con:>nxsaf))
 
    if (maxsims==1) {
      printf("\nEnd of a single simulation\n")
      desout(stprior)
      printtopmtd(newmtd,6)
//     stata(pipe_smooth(stprior, newmtd, theta))
      printf("Recommended dose(s)\n")
      recdose
    }
    allsim= storesim(allsim, stprior, newmtd, sims, recdose)
  } /* end of sim loop */
  displaysims(allsim, ndoses, true, maxn)
/*
printmtd(newmtd)
*/
st_matrix("nog",nog)

} /* end of pipe*/

/**********************************************************************************
 * Make a structure which contains each possible monotonic? contour
 *  Each contour is in the gt matrix arrayed over cont
 *   mkkbase() and mkbin() help with the combintorics or getting all the contours
 **********************************************************************************/
struct dltcont vector findallcontours(ndoses, struct dltcont cont)
{
  struct dltcont scalar tecont
  for(i=0; i<(ndoses[2]+1)^(ndoses[1]); i++) {
    temp = mkkbase(ndoses[2]+1, i, ndoses[1])
    error=0
    for(j=2;j<=cols(temp);j++) {
      if (temp[j]>temp[j-1]) error=1
    }
    if (!error) {
      for(j=1;j<=cols(temp);j++) {
        temp1 = mkbin( 2^temp[j]-1, ndoses[2])
        if (j==1) temat = temp1
        else temat = temat \ temp1
      }
      if (i==0) cont[1].gt=temat
      else {
        tecont.gt = temat
        cont = cont \ tecont 
      }
    }
  }
 return(cont)
}
real matrix mkbin(no, nd) 
{
  for(i=nd;i>=1;i--) {
    if (no>=2^(i-1)) {
      if (i==nd) m= 1
      else m= m, 1
      no = no-2^(i-1)
    }
    else {
      if (i==nd) m=0
      else m= m,0
    }
  }
  return(m)
}
real matrix mkkbase(b, nn, nd) 
{
  teno=nn
  for(j=nd;j>=1;j--) {
    if (j==nd) {
      m = (teno - mod(teno, b^(j-1))) / b^(j-1)
    }    
    else {
      m = m, (teno - mod(teno, b^(j-1))) / b^(j-1) 
    }
    teno =  mod(teno, b^(j-1))
  }
  return(m)
}

/*******************************************************************
 * Store sim information and process it into outputs
 * nxd should contain the matrix with 1s for recommended doses
 *******************************************************************/
struct siminfo matrix storesim(struct siminfo sim, struct design des, struct dltcont mtd, nsim, matrix nxd)
{
  /*NEED to store contour */
  struct siminfo scalar te
  te.nexp = J(rows(des),cols(des),0)
  te.ndlt = J(rows(des), cols(des),0)
  te.nrmtd = nxd
  for(i=1;i<=rows(des);i++) {
    for(j=1;j<=cols(des);j++) {
      te.nexp[i,j] = des[i,j].n
      te.ndlt[i,j] = des[i,j].dlt
    }
  }
  if (nsim>1) return(sim \ te) /* te is a single element structure*/
  else return(te)
} /* end of storesim */

/* here nxd is just rows/cols of prior i.e. grid dimension*/
void displaysims(struct siminfo sim, vector nxd, true, maxn)
{
  struct siminfo scalar sum
  sum.nexp = J(nxd[1],nxd[2],0)
  sum.ndlt = J(nxd[1],nxd[2],0)
  sum.nrmtd = J(nxd[1],nxd[2],0)
  nsims = rows(sim)
  for(i=1;i<=rows(sim);i++) {
    for(j=1;j<=nxd[1];j++) {
      for(k=1;k<=nxd[2];k++) {
        sum.ndlt[j,k] = sum.ndlt[j,k]+sim[i].ndlt[j,k]
        sum.nexp[j,k] = sum.nexp[j,k]+sim[i].nexp[j,k]
        sum.nrmtd[j,k]= sum.nrmtd[j,k]+sim[i].nrmtd[j,k]
      }
    }
  }
  /* Create the matrix of experimentation, dlts, recommended */
  experimentation = sum.nexp:/nsims
  dlt = sum.ndlt:/nsims
  recommended = sum.nrmtd:/nsims
  percdlt = dlt:/experimentation
  percexp = experimentation :/ sum(experimentation)
  
 /* The initial table display */
  printf("\n \n{bf: Table of simulation results over {res}%5.0f {txt}simulations}", nsims)
  printf("{txt}\n Average number and percentage of DLTs, Average experimentation and Average number of times recommended, per dose combination \n")
  /* Print first row of column numbers */
  for(j=1;j<=cols(dlt);j++) {
    printf("{col 12}         %f        ", j )
  }
  /* print first lines of table */
  printf("\n{col 12}")
  for(j=1;j<=cols(dlt);j++) {
    if (cols(des)==1) printf("{c TLC}{dup 18:{c -}}{c TRC}\n")
    else if (j==1) printf("{c TLC}{dup 18:{c -}}{c TT}")
    else if (j==cols(dlt)) printf("{dup 18:{c -}}{c TRC}\n")
    else printf("{dup 18:{c -}}{c TT}")
  }
  /* print first elements*/
  for(i=1;i<=rows(dlt);i++) {
    printf("%f DLTs (%%) {col 12}{c |}", rows(dlt)-i+1)
    for(j=1;j<=cols(dlt);j++) {
      printf("{res}  %5.2f (%6.2f%%) {txt}{c |}", dlt[i,j], 100*percdlt[i,j])
    }
  
    /* Print every left edge prob of the distribution*/
    printf("\n  Exp (%%) {col 12}{c |}")
    for(j=1;j<=cols(dlt);j++) {
      printf("{res}  %5.2f (%6.2f%%) {txt}{c |}", experimentation[i,j], 100*percexp[i,j])
    }  
    printf("\n  Rec #{col 12}{c |}")
    for(j=1;j<=cols(dlt);j++) {
      printf("{res}  %5.2f           {txt}{c |}", recommended[i,j])
    }  
   
    /* print the last row*/
    if (i==rows(dlt)) {
      printf("\n{col 12}")
      for(j=1;j<=cols(dlt);j++) {
        if (cols(dlt)==1) printf("{c BLC}{dup 18:{c -}}{c BRC}\n")
        else if (j==1) printf("{c BLC}{dup 18:{c -}}{c BT}")
        else if (j==cols(dlt)) printf("{dup 18:{c -}}{c BRC}\n")
        else printf("{dup 18:{c -}}{c BT}")
      }
    }
    /* print rows */
    else {
      printf("\n{col 12}")
      for(j=1;j<=cols(dlt);j++) {
        if (cols(des)==1) printf("{c LT}{dup 18:{c -}}{c RT}\n")
        else if (j==1) printf("{c LT}{dup 18:{c -}}{c +}")
        else if (j==cols(dlt)) printf("{dup 18:{c -}}{c RT}\n")
        else printf("{dup 18:{c -}}{c BT}")
      }
    }
  }

  st_matrix("experimentation", experimentation)
  st_matrix("dlt", dlt)
  st_matrix("recommended", recommended)
}

/********************************************************************
 * Want a function that sorts structure array in order of element .pt
 ********************************************************************/
real vector structureorder(struct dltcont mtd)
{
  order = 1..rows(mtd)
  swapped=1
  while (swapped) {
    swapped=0
    for(i=1; i<=rows(mtd)-1;i++) {
      if (mtd[order[i+1]].pt > mtd[order[i]].pt) {
        neworder = order
        neworder[i+1]= order[i]
        neworder[i]= order[i+1]
        order=neworder
        swapped=1
      }
    }
  }
  return(order)
}

 /***************************************************************************
 * Calculate the next dose from the MTD distribution, dp(data,prior,pprobs)
 * cdose and pdoses are current and previous doses as matrices
 * mtd is the structure with the contours
 * dp has the data and prior stuff
 * nxzon indicates whether closest or adjacent
 * nxcon is neighbour or non-neighbour
 * nxsaf is the safety constraint
 * nxsel is the selection algorithm either inverse SS
    /* A reminder of the options
		nxcons 0 no constraint
		nxcons 1 neighbour nodose skipping
		nxcons 2 non-neighbour no dose skipping

		nxsafe 1 safety constraint as well

		nxsel 1 SS  <-- only one implemented so far!
		nxsel 2 WR ss
		nxsel 3 pdf <- DROPPED
		nxsel 4 both <- DROPPED
		nxsel 5 most informative doses but need cohort size to be even!
	*/
 ********************************* NXDOSE ******************************************/
real vector nxdose(cdose, pdoses, struct dltcont mtd, struct design dp, nxzon, nxcon, nxsaf, nxsel, safety)
{
  /* Go through every contour getting most likely contour (maxc contains the contour#), TAKES first in event of TIE */
  maxc = 0
  maxcpt = 0
  for(i=1;i<=rows(mtd);i++) {
    if (mtd[i].pt > maxcpt) {
      maxcpt = mtd[i].pt
      maxc = i
    }
  }

/* 
 Now we have the contour and what are the current and previous doses
 We want to set up the constraint zone! nxcon 0 skipping allowed 1 local neighbour 2 non-neighbour
*/
  if (nxcon==0) {
    admiss = J(rows(cdose),cols(cdose),1) /*all doses are available*/
  }
  else if (nxcon==1) {
    admiss = J(rows(cdose),cols(cdose),0) /* start no doses are admiss */
    for(i=1;i<=rows(cdose);i++) {
      for(j=1;j<=cols(cdose);j++) {
        if (i<rows(cdose)) {
          if (j>1) {
            if (cdose[i+1,j-1]==1) admiss[i,j]=1
          }
          if (cdose[i+1,j]==1) admiss[i,j]=1
          if (j<cols(cdose)) {
            if (cdose[i+1,j+1]==1) admiss[i,j]=1
          }
        }
        if (i>1) {
          if (j>1) {
            if (cdose[i-1,j-1]==1) admiss[i,j]=1
          }
          if (cdose[i-1,j]==1) admiss[i,j]=1
          if (j<cols(cdose)) {
            if (cdose[i-1,j+1]==1) admiss[i,j]=1
          }
        }
        if (j>1) {
          if (cdose[i,j-1]==1) admiss[i,j]=1
        }
        if (cdose[i,j]==1) admiss[i,j]=1
        if (j<cols(cdose)) {
          if (cdose[i,j+1]==1) admiss[i,j]=1
        }
      }
    }
  } /* should have a matrix of ones around current dose */
  else if (nxcon==2) {
    admiss = J(rows(pdoses),cols(pdoses),0)
    for(i=1;i<=rows(pdoses);i++) {
      for(j=1;j<=cols(pdoses);j++) {
        if (i<rows(pdoses)) {
          if (j>1) {
            if (pdoses[i+1,j-1]>0) admiss[i,j]=1
          }
          if (pdoses[i+1,j]>0) admiss[i,j]=1
          if (j<cols(pdoses)) {
            if (pdoses[i+1,j+1]>0) admiss[i,j]=1
          }
        }
        if (i>1) {
          if (j>1) {
            if (pdoses[i-1,j-1]>0) admiss[i,j]=1
          }
          if (pdoses[i-1,j]>0) admiss[i,j]=1
          if (j<cols(pdoses)) {
            if (pdoses[i-1,j+1]>0) admiss[i,j]=1
          }
        }
        if (j>1) {
          if (pdoses[i,j-1]>0) admiss[i,j]=1
        }
        if (pdoses[i,j]>0) admiss[i,j]=1
        if (j<cols(pdoses)) {
          if (pdoses[i,j+1]>0) admiss[i,j]=1
        }
      }
    }
  }

  /************ Now using safety constraint**********************/
  admiss = admiss:*(1:-safety) /* removes unsafe doses from the admiss grid */

/*
 * FIRST calculate the next possible doses, note the zone is out at the moment!
 */

  if (nxzon==1) { /* adjacent zone*/  /* .gt this contains the contour binary matrix, 1 being above MTC 0 below */
    adjacent = J(rows(mtd[maxc].gt),cols(mtd[maxc].gt),0)
    for(i=1;i<=rows(mtd[maxc].gt);i++) {
      for(j=1;j<=cols(mtd[maxc].gt);j++) {
        if (mtd[maxc].gt[i,j]==0) {
          if (j==cols(mtd[maxc].gt)) adjacent[i,j]=1
          else if (mtd[maxc].gt[i,j+1]==1) adjacent[i,j]=1
          else if (i~=1) {
            if (mtd[maxc].gt[i-1,j]==1) adjacent[i,j]=1
            if (mtd[maxc].gt[i-1,j+1]==1) adjacent[i,j]=1
          }
        }
        if (mtd[maxc].gt[i,j]==1) {
          if (j==1) adjacent[i,j]=1
          else if (mtd[maxc].gt[i,j-1]==0) adjacent[i,j]=1
          else if (i~=rows(mtd[maxc].gt)) {
            if (mtd[maxc].gt[i+1,j]==0) adjacent[i,j]=1
            if (mtd[maxc].gt[i+1,j-1]==0) adjacent[i,j]=1
          }
        }
      }
    }

    /* now check how many closest are admissible if none then pick the highest doses*/
    if (sum(admiss:*adjacent)>0) pickset=admiss:*adjacent
    else {
      pickset=admiss
      if (sum(admiss)==0) {
        pickset[rows(admiss),1]=1
      }
      else {
        for(i=1;i<=rows(admiss);i++) {
          for(j=1;j<cols(admiss);j++) {
            if (j<cols(admiss)) {
              if (admiss[i,j]==1 & admiss[i,j+1]==1) pickset[i,j]=0
            }
            if (i>1) {
              if (admiss[i,j]==1 & admiss[i-1,j]==1) pickset[i,j]=0
            }
          }
        }
      }
    }
  } /* end of nxzon 1 */ 
  else if (nxzon==2) { /* closest zone */
    closest_above = mtd[maxc].gt:*admiss
    closest_below = (1:-mtd[maxc].gt):*admiss
    for(i=1;i<=rows(closest_above);i++) { /* taking each point and look at top right or bottom left for other doses */
      for(j=1;j<=cols(closest_above);j++) {
        if ((closest_above[i,j]==1) & (sum(closest_above[i..rows(closest_above), 1..j])>1)) closest_above[i,j]=0
        if ((closest_below[i,j]==1) & (sum(closest_below[1..i, j..cols(closest_below)])>1)) closest_below[i,j]=0     
      }
    }
    closest= closest_above+closest_below /* closest now contains the closest doses*/
/*
printf("Closest  below  above\n")
closest_below, J(rows(closest), 1, .) , closest_above, J(rows(closest), 1, .) , admiss, J(rows(closest), 1, .) , safety
*/
  /* now check how many closest are admissible if none then pick the highest doses*/
    if (sum(closest)>0) pickset=closest
    else {
      pickset=admiss
      if (sum(admiss)==0) { /* This means nothing is admissible and so select no dose */
        return( (0,0) )
      }
      else {
        for(i=1;i<=rows(admiss);i++) {
          for(j=1;j<=cols(admiss);j++) {
            if (j<cols(admiss)) {
              if (admiss[i,j]==1 & admiss[i,j+1]==1) pickset[i,j]=0
            }
            if (i>1) {
              if (admiss[i,j]==1 & admiss[i-1,j]==1) pickset[i,j]=0
            }
          }
        }
      }
    }
 } /* end of nxzon 2 */
 
/*
 Now we have pickset and now need the sample size and then do random by jumble or not
 Note that if pickset is well below most likely contour then you do not pick biggest dose combo but
 a random one
*/
  if (nxsel==1) {
    ss=pickset
    for(i=1;i<=rows(pickset);i++) { /* Puts effective sample size for pickset into SS*/
      for(j=1;j<=cols(pickset);j++) {
        ss[i,j]=pickset[i,j]*(dp[i,j].n+dp[i,j].b+dp[i,j].a)
      }
    }
    maxs = max(ss) /* Find max SS and then add that to the 0s in SS, want min SS but not 0!*/
    for(i=1;i<=rows(ss);i++) {
      for(j=1;j<=cols(ss);j++) {
        if (ss[i,j]==0) ss[i,j] = maxs+1
      }
    }
    te = (ss:==min(ss)) /* te now has the next doses and we want to pick a random one in the event of ties*/
    first=1
    for(i=1;i<=rows(te);i++) {
      for(j=1;j<=cols(te);j++) {
        if (te[i,j]==1 & first==0) dose = dose \ (i,j)
        else if (te[i,j]==1 & first==1) {
          dose = (i,j)
          first=0
        }
      }
    }
    nxdose = jumble(dose)[1,]
    return(nxdose)
  } /*end of nxsel 1*/
  else if (nxsel==2) {
    printf("{err}WARNING: method for selecting the next dose is not implemented yet")
    exit(198)
  }
  else {
    printf("{err}WARNING: method for selecting the next dose is incorrect")
    exit(198)
  }
} /*end of nxdose*/

/**************************************************
 * The recommended dose at the end of the trial
 **************************************************/
real matrix recdose(cdose, pdoses, struct dltcont mtd, struct design dp, nxzon, nxcon, nxsaf, nxsel, safety)
{
  /* Go through every contour getting most likely contour (maxc contains the contour#), TAKES first in event of TIE */
  maxc = 0
  maxcpt = 0
  for(i=1;i<=rows(mtd);i++) {
    if (mtd[i].pt > maxcpt) {
      maxcpt = mtd[i].pt
      maxc = i
    }
  }

  /*  All safe doses below MTC can be selected as recommendation */
  admiss = (1:-safety):*(1:-mtd[maxc].gt)
  pickset = admiss:* (pdoses:>0) /* needs to be a dose that has been experimented on*/

  if (sum(pickset)==0) { /* This means nothing is safe below contour so recommend no dose */
    return(pickset)  /* this is no dose */ 
  }
  else { /* there is a recommended dose but remove doses dominated */
    for(i=1;i<=rows(pickset);i++) {
      for(j=1;j<=cols(pickset);j++) {

        if (i==1 & j==cols(pickset)) {
              
        }
        else if (i==1 & j<cols(pickset)) {
          if ((pickset[i,j]==1) & (sum(pickset[1,(j+1)..cols(pickset)])>0)) pickset[i,j]=0
        }
        else if (j==cols(pickset) & i>1) {
          if ((pickset[i,j]==1) & (sum(pickset[1..(i-1),j])>0)) pickset[i,j]=0
        }
        else {
          if ((pickset[i,j]==1) & (sum(pickset[1..(i-1),j..cols(pickset)])>0)) pickset[i,j]=0
          if ((pickset[i,j]==1) & (sum(pickset[1..i,(j+1)..cols(pickset)])>0)) pickset[i,j]=0
        }
      }
    }
    return(pickset)
  }
} /*end of recdose*/

/******************************************************************
 * Generate new data, new dose will NEED to be a vector!!
 ******************************************************************/
struct design gendata(struct design dp, true, vector newdose, no)
{
  for(i=1;i<=no;i++) {
    dp[newdose[1],newdose[2]].n = dp[newdose[1],newdose[2]].n+1
    if (runiform(1,1)<true[newdose[1],newdose[2]]) dp[newdose[1],newdose[2]].dlt = dp[newdose[1],newdose[2]].dlt+1
  }
  return(dp)
} /*end gendata*/

/************************************************************************
 * Calculate the MTD probability distribution
 *  each row of MTD is a contour dose and probability 
 *  normalising for non-monotonic events
 * The .pt element contains the probability that the contour is the MTD
 ************************************************************************/
struct dltcont matrix calcmtd(struct design matrix dp, struct dltcont matrix mtd)
{ 
  for(i=1;i<=rows(mtd);i++) { /* for each contour */
    mtd[i].pt1 = 1
    mtd[i].pt2 = 1
    mtd[i].pt3 = 1
    mtd[i].pt4 = 1
    mtd[i].pt5 = 1
    mtd[i].pt6 = 1
    mtd[i].pt7 = 1
    mtd[i].pt8 = 1
    mtd[i].pt9 = 1
    mtd[i].pt10 = 1
    mtd[i].pt11 = 1
    mtd[i].pt12 = 1
    mtd[i].pt13 = 1
    mtd[i].pt14 = 1
    mtd[i].pt15 = 1
    mtd[i].pt16 = 1
    mtd[i].pt17 = 1
    mtd[i].pt18 = 1
    mtd[i].pt19 = 1
    mtd[i].sumt1 = 0
    mtd[i].sumt2 = 0
    mtd[i].sumt3 = 0
    mtd[i].sumt4 = 0
    mtd[i].sumt5 = 0
    mtd[i].sumt6 = 0
    mtd[i].sumt7 = 0
    mtd[i].sumt8 = 0
    mtd[i].sumt9 = 0
    mtd[i].sumt10 = 0
    mtd[i].sumt11 = 0
    mtd[i].sumt12 = 0
    mtd[i].sumt13 = 0
    mtd[i].sumt14 = 0
    mtd[i].sumt15 = 0
    mtd[i].sumt16 = 0
    mtd[i].sumt17 = 0
    mtd[i].sumt18 = 0
    mtd[i].sumt19 = 0
    mtd[i].pt = 1
    mtd[i].sumt = 0
    for(ii=1;ii<=rows(mtd[i].gt);ii++) { /* calculate probability of contour */
      for(jj=1;jj<=cols(mtd[i].gt);jj++) {
        if (mtd[i].gt[ii,jj]==1) {
          mtd[i].pt = mtd[i].pt*(1-dp[ii,jj].ppt)
          mtd[i].pt1 = mtd[i].pt1*(1-dp[ii,jj].ppt1)
          mtd[i].pt2 = mtd[i].pt2*(1-dp[ii,jj].ppt2)
          mtd[i].pt3 = mtd[i].pt3*(1-dp[ii,jj].ppt3)
          mtd[i].pt4 = mtd[i].pt4*(1-dp[ii,jj].ppt4)
          mtd[i].pt5 = mtd[i].pt5*(1-dp[ii,jj].ppt5)
          mtd[i].pt6 = mtd[i].pt6*(1-dp[ii,jj].ppt6)
          mtd[i].pt7 = mtd[i].pt7*(1-dp[ii,jj].ppt7)
          mtd[i].pt8 = mtd[i].pt8*(1-dp[ii,jj].ppt8)
          mtd[i].pt9 = mtd[i].pt9*(1-dp[ii,jj].ppt9)
          mtd[i].pt10 = mtd[i].pt10*(1-dp[ii,jj].ppt10)
          mtd[i].pt11 = mtd[i].pt11*(1-dp[ii,jj].ppt11)
          mtd[i].pt12 = mtd[i].pt12*(1-dp[ii,jj].ppt12)
          mtd[i].pt13 = mtd[i].pt13*(1-dp[ii,jj].ppt13)
          mtd[i].pt14 = mtd[i].pt14*(1-dp[ii,jj].ppt14)
          mtd[i].pt15 = mtd[i].pt15*(1-dp[ii,jj].ppt15)
          mtd[i].pt16 = mtd[i].pt16*(1-dp[ii,jj].ppt16)
          mtd[i].pt17 = mtd[i].pt17*(1-dp[ii,jj].ppt17)
          mtd[i].pt18 = mtd[i].pt18*(1-dp[ii,jj].ppt18)
          mtd[i].pt19 = mtd[i].pt19*(1-dp[ii,jj].ppt19)
        }
        else {
          mtd[i].pt = mtd[i].pt*dp[ii,jj].ppt
          mtd[i].pt1 = mtd[i].pt1*dp[ii,jj].ppt1
          mtd[i].pt2 = mtd[i].pt2*dp[ii,jj].ppt2
          mtd[i].pt3 = mtd[i].pt3*dp[ii,jj].ppt3
          mtd[i].pt4 = mtd[i].pt4*dp[ii,jj].ppt4
          mtd[i].pt5 = mtd[i].pt5*dp[ii,jj].ppt5
          mtd[i].pt6 = mtd[i].pt6*dp[ii,jj].ppt6
          mtd[i].pt7 = mtd[i].pt7*dp[ii,jj].ppt7
          mtd[i].pt8 = mtd[i].pt8*dp[ii,jj].ppt8
          mtd[i].pt9 = mtd[i].pt9*dp[ii,jj].ppt9
          mtd[i].pt10 = mtd[i].pt10*dp[ii,jj].ppt10
          mtd[i].pt11 = mtd[i].pt11*dp[ii,jj].ppt11
          mtd[i].pt12 = mtd[i].pt12*dp[ii,jj].ppt12
          mtd[i].pt13 = mtd[i].pt13*dp[ii,jj].ppt13
          mtd[i].pt14 = mtd[i].pt14*dp[ii,jj].ppt14
          mtd[i].pt15 = mtd[i].pt15*dp[ii,jj].ppt15
          mtd[i].pt16 = mtd[i].pt16*dp[ii,jj].ppt16
          mtd[i].pt17 = mtd[i].pt17*dp[ii,jj].ppt17
          mtd[i].pt18 = mtd[i].pt18*dp[ii,jj].ppt18
          mtd[i].pt19 = mtd[i].pt19*dp[ii,jj].ppt19
        }
      }
    }
  }
 /* Now we need to sum up over all contours to see how likely monotonicity is */
  mtd[1].sumt=mtd[1].pt
  mtd[1].sumt1=mtd[1].pt1
  mtd[1].sumt2=mtd[1].pt2
  mtd[1].sumt3=mtd[1].pt3
  mtd[1].sumt4=mtd[1].pt4
  mtd[1].sumt5=mtd[1].pt5
  mtd[1].sumt6=mtd[1].pt6
  mtd[1].sumt7=mtd[1].pt7
  mtd[1].sumt8=mtd[1].pt8
  mtd[1].sumt9=mtd[1].pt9
  mtd[1].sumt10=mtd[1].pt10
  mtd[1].sumt11=mtd[1].pt11
  mtd[1].sumt12=mtd[1].pt12
  mtd[1].sumt13=mtd[1].pt13
  mtd[1].sumt14=mtd[1].pt14
  mtd[1].sumt15=mtd[1].pt15
  mtd[1].sumt16=mtd[1].pt16
  mtd[1].sumt17=mtd[1].pt17
  mtd[1].sumt18=mtd[1].pt18
  mtd[1].sumt19=mtd[1].pt19
  for(i=2;i<=rows(mtd);i++) {
    mtd[i].sumt = mtd[i-1].sumt + mtd[i].pt
    mtd[i].sumt1 = mtd[i-1].sumt1 + mtd[i].pt1
    mtd[i].sumt2 = mtd[i-1].sumt2 + mtd[i].pt2
    mtd[i].sumt3 = mtd[i-1].sumt3 + mtd[i].pt3
    mtd[i].sumt4 = mtd[i-1].sumt4 + mtd[i].pt4
    mtd[i].sumt5 = mtd[i-1].sumt5 + mtd[i].pt5
    mtd[i].sumt6 = mtd[i-1].sumt6 + mtd[i].pt6
    mtd[i].sumt7 = mtd[i-1].sumt7 + mtd[i].pt7
    mtd[i].sumt8 = mtd[i-1].sumt8 + mtd[i].pt8
    mtd[i].sumt9 = mtd[i-1].sumt9 + mtd[i].pt9
    mtd[i].sumt10 = mtd[i-1].sumt10 + mtd[i].pt10
    mtd[i].sumt11 = mtd[i-1].sumt11 + mtd[i].pt11
    mtd[i].sumt12 = mtd[i-1].sumt12 + mtd[i].pt12
    mtd[i].sumt13 = mtd[i-1].sumt13 + mtd[i].pt13
    mtd[i].sumt14 = mtd[i-1].sumt14 + mtd[i].pt14
    mtd[i].sumt15 = mtd[i-1].sumt15 + mtd[i].pt15
    mtd[i].sumt16 = mtd[i-1].sumt16 + mtd[i].pt16
    mtd[i].sumt17 = mtd[i-1].sumt17 + mtd[i].pt17
    mtd[i].sumt18 = mtd[i-1].sumt18 + mtd[i].pt18
    mtd[i].sumt19 = mtd[i-1].sumt19 + mtd[i].pt19
  }
 /* Then scale up all the probabilities to sum to 1 */
  for(i=1;i<=rows(mtd);i++) {
    mtd[i].pt = mtd[i].pt / mtd[rows(mtd)].sumt
    mtd[i].pt1 = mtd[i].pt1 / mtd[rows(mtd)].sumt1
    mtd[i].pt2 = mtd[i].pt2 / mtd[rows(mtd)].sumt2
    mtd[i].pt3 = mtd[i].pt3 / mtd[rows(mtd)].sumt3
    mtd[i].pt4 = mtd[i].pt4 / mtd[rows(mtd)].sumt4
    mtd[i].pt5 = mtd[i].pt5 / mtd[rows(mtd)].sumt5
    mtd[i].pt6 = mtd[i].pt6 / mtd[rows(mtd)].sumt6
    mtd[i].pt7 = mtd[i].pt7 / mtd[rows(mtd)].sumt7
    mtd[i].pt8 = mtd[i].pt8 / mtd[rows(mtd)].sumt8
    mtd[i].pt9 = mtd[i].pt9 / mtd[rows(mtd)].sumt9
    mtd[i].pt10 = mtd[i].pt10 / mtd[rows(mtd)].sumt10
    mtd[i].pt11 = mtd[i].pt11 / mtd[rows(mtd)].sumt11
    mtd[i].pt12 = mtd[i].pt12 / mtd[rows(mtd)].sumt12
    mtd[i].pt13 = mtd[i].pt13 / mtd[rows(mtd)].sumt13
    mtd[i].pt14 = mtd[i].pt14 / mtd[rows(mtd)].sumt14
    mtd[i].pt15 = mtd[i].pt15 / mtd[rows(mtd)].sumt15
    mtd[i].pt16 = mtd[i].pt16 / mtd[rows(mtd)].sumt16
    mtd[i].pt17 = mtd[i].pt17 / mtd[rows(mtd)].sumt17
    mtd[i].pt18 = mtd[i].pt18 / mtd[rows(mtd)].sumt18
    mtd[i].pt19 = mtd[i].pt19 / mtd[rows(mtd)].sumt19
  } 
  return(mtd)
}

/***********************************************************************
 * Calculate the median contour
 ***********************************************************************/
struct design matrix calcmedianmtd(struct design matrix dp, struct dltcont matrix mtd)
{ 
/*desout(dp)
printmtd(mtd)
*/
  for(i=1; i<=rows(dp); i++) {
    for(j=1; j<=cols(dp); j++) {
      dp[i,j].ledge = 0
      dp[i,j].bedge = 0
      for(k=1; k <= rows(mtd); k++) { /* left edge adding all probabilities of contour */
        if (j==1) {
          if(mtd[k].gt[i,j]==1) dp[i,j].ledge = dp[i,j].ledge+mtd[k].pt
        }
        else { 
          if (mtd[k].gt[i,j]==1 & mtd[k].gt[i,j-1]==0) dp[i,j].ledge= dp[i,j].ledge+mtd[k].pt
        }
      }
      for(k=1; k <= rows(mtd); k++) { /* bottom edge  adding all probabilities is the average probs */
        if (i==rows(dp)) {
          if(mtd[k].gt[i,j]==1) dp[i,j].bedge = dp[i,j].bedge+mtd[k].pt
        }
        else {
          if (mtd[k].gt[i,j]==1 & mtd[k].gt[i+1,j]==0) dp[i,j].bedge= dp[i,j].bedge+mtd[k].pt
        }
      }
    }
  }
  /* now identify whether below median or not going along rows*/
  for(i=1; i<=rows(dp); i++) {
    ledge=0
    for(j=1; j<=cols(dp); j++) {
      ledge=ledge+dp[i,j].ledge 
      if (ledge<0.5) dp[i,j].median=0
      else dp[i,j].median=1
    }
  }
  return(dp)
}

/* Calculate the safety constraint matrix  checked and definitely right 30.7.20 */
matrix calc_safety(struct design matrix dp, struct dltcont matrix mtd) 
{
  safety = J(rows(mtd[1].gt),cols(mtd[1].gt),0)
  for(ii=1;ii<=rows(mtd[1].gt);ii++) { 
    for(jj=1;jj<=cols(mtd[1].gt);jj++) {
      for(i=1;i<=rows(mtd);i++) {
        if (mtd[i].gt[ii,jj]==1) {
          safety[ii,jj] = safety[ii,jj] + mtd[i].pt
        }
      }
    }
  }
  return(safety)
}


struct design matrix calc_safety2(struct design matrix dp, struct dltcont matrix mtd) 
{
  for(ii=1;ii<=rows(mtd[1].gt);ii++) { 
    for(jj=1;jj<=cols(mtd[1].gt);jj++) {
      dp[ii,jj].sc1 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc2 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc3 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc4 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc5 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc6 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc7 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc8 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc9 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc10 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc11 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc12 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc13 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc14 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc15 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc16 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc17 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc18 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
      dp[ii,jj].sc19 = J(rows(mtd[1].gt), cols(mtd[1].gt), 0)
    }
  }
  for(ii=1;ii<=rows(mtd[1].gt);ii++) { 
    for(jj=1;jj<=cols(mtd[1].gt);jj++) {
      for(i=1;i<=rows(mtd);i++) {
        if (mtd[i].gt[ii,jj]==1) {
          dp[ii,jj].sc1[ii,jj] = dp[ii,jj].sc1[ii,jj]+mtd[i].pt1
          dp[ii,jj].sc2[ii,jj] = dp[ii,jj].sc2[ii,jj]+mtd[i].pt2
          dp[ii,jj].sc3[ii,jj] = dp[ii,jj].sc3[ii,jj]+mtd[i].pt3
          dp[ii,jj].sc4[ii,jj] = dp[ii,jj].sc4[ii,jj]+mtd[i].pt4
          dp[ii,jj].sc5[ii,jj] = dp[ii,jj].sc5[ii,jj]+mtd[i].pt5
          dp[ii,jj].sc6[ii,jj] = dp[ii,jj].sc6[ii,jj]+mtd[i].pt6
          dp[ii,jj].sc7[ii,jj] = dp[ii,jj].sc7[ii,jj]+mtd[i].pt7
          dp[ii,jj].sc8[ii,jj] = dp[ii,jj].sc8[ii,jj]+mtd[i].pt8
          dp[ii,jj].sc9[ii,jj] = dp[ii,jj].sc9[ii,jj]+mtd[i].pt9
          dp[ii,jj].sc10[ii,jj] = dp[ii,jj].sc10[ii,jj]+mtd[i].pt10
          dp[ii,jj].sc11[ii,jj] = dp[ii,jj].sc11[ii,jj]+mtd[i].pt11
          dp[ii,jj].sc12[ii,jj] = dp[ii,jj].sc12[ii,jj]+mtd[i].pt12
          dp[ii,jj].sc13[ii,jj] = dp[ii,jj].sc13[ii,jj]+mtd[i].pt13
          dp[ii,jj].sc14[ii,jj] = dp[ii,jj].sc14[ii,jj]+mtd[i].pt14
          dp[ii,jj].sc15[ii,jj] = dp[ii,jj].sc15[ii,jj]+mtd[i].pt15
          dp[ii,jj].sc16[ii,jj] = dp[ii,jj].sc16[ii,jj]+mtd[i].pt16
          dp[ii,jj].sc17[ii,jj] = dp[ii,jj].sc17[ii,jj]+mtd[i].pt17
          dp[ii,jj].sc18[ii,jj] = dp[ii,jj].sc18[ii,jj]+mtd[i].pt18
          dp[ii,jj].sc19[ii,jj] = dp[ii,jj].sc19[ii,jj]+mtd[i].pt19
        }
      }
    }
  }
  return(dp)
} /* end of calc_safety2 */

/************************************************************************
 * Work out posterior for a matrix of probabilities
 ************************************************************************/
struct design matrix calcposterior(struct design matrix dp, real scalar theta)
{
  for(i=1;i<= rows(dp);i++) {
    for(j=1;j<= cols(dp);j++) {
      dp[i,j].pa   = dp[i,j].a+dp[i,j].dlt
      dp[i,j].pb   = dp[i,j].b-dp[i,j].dlt+dp[i,j].n
      dp[i,j].ppt  = ibeta(dp[i,j].pa, dp[i,j].pb, theta)   /* Post Prob of p <= theta */
      for(k=1;k<=cols(dp[i,j].F);k++) {
        dp[i,j].F[k] = ibeta(dp[i,j].pa, dp[i,j].pb, dp[i,j].Fp[k]) /* tail probs */
      }
      dp[i,j].ppt1 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.05)     /* 5% tail*/
      dp[i,j].ppt2 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.1)      /* 10% tail*/
      dp[i,j].ppt3 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.15)     /* 15% tail*/
      dp[i,j].ppt4 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.2)      /* 20% tail*/
      dp[i,j].ppt5 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.25)     /* 25% tail*/
      dp[i,j].ppt6 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.3)      /* 30% tail*/
      dp[i,j].ppt7 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.35)     /* 35% tail*/
      dp[i,j].ppt8 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.4)      /* 40% tail*/
      dp[i,j].ppt9 =ibeta(dp[i,j].pa, dp[i,j].pb, 0.45)     /* 45% tail*/
      dp[i,j].ppt10=ibeta(dp[i,j].pa, dp[i,j].pb, 0.5)     /* 50% tail*/
      dp[i,j].ppt11=ibeta(dp[i,j].pa, dp[i,j].pb, 0.55)    /* 55% tail*/
      dp[i,j].ppt12=ibeta(dp[i,j].pa, dp[i,j].pb, 0.6)     /* 60% tail*/
      dp[i,j].ppt13=ibeta(dp[i,j].pa, dp[i,j].pb, 0.65)    /* 65% tail*/
      dp[i,j].ppt14=ibeta(dp[i,j].pa, dp[i,j].pb, 0.7)     /* 70% tail*/
      dp[i,j].ppt15=ibeta(dp[i,j].pa, dp[i,j].pb, 0.75)    /* 75% tail*/
      dp[i,j].ppt16=ibeta(dp[i,j].pa, dp[i,j].pb, 0.8)     /* 80% tail*/
      dp[i,j].ppt17=ibeta(dp[i,j].pa, dp[i,j].pb, 0.85)    /* 85% tail*/
      dp[i,j].ppt18=ibeta(dp[i,j].pa, dp[i,j].pb, 0.9)     /* 90% tail*/
      dp[i,j].ppt19=ibeta(dp[i,j].pa, dp[i,j].pb, 0.95)    /* 95% tail*/
      dp[i,j].pdft =betaden(dp[i,j].pa, dp[i,j].pb, theta) /* Posterior density at theta */
    }
  }
  return(dp)
}

/***************************************************************************
 * Calculate priors centred at prior vector with given weight>0  
 ***************************************************************************/
matrix meanbpriors(prior, wt) 
{
  for(i=1;i<=cols(prior);i++) {
    if (i==1) {
      a = wt*prior[i]
    }
    else {
      a = (a\wt*prior[i])
    }
  }
  b = wt:-a
  return((a,b))
} /* end of meanbpriors */

/************************************************************************
 * Need to use optimize to calculate the prior(a,b) for median
 *  probably need some error checking on this.
 ************************************************************************/
void findmedian(todo, x, wt, prob, y, g, H)
{
  y = (ibeta(x, wt-x, prob)-0.5)^2
}
struct design matrix medianbpriors(prior, wt, struct design matrix dp) 
{
  for(i=1;i<=rows(prior);i++) {
    for(j=1;j<=cols(prior);j++) {
      A = optimize_init()
      optimize_init_which(A, "min")
      optimize_init_evaluator(A, &findmedian())
      optimize_init_params(A, 0.5*wt)
      optimize_init_argument(A,1,wt)
      optimize_init_argument(A,2,prior[i,j])
      optimize_init_trace_value(A, "off")
      aa= optimize(A)
      dp[i,j].a = aa
      dp[i,j].b = wt-aa
    }
  }
  return(dp)
} /* end of medianbpriors */

/************************************************************************
 * Need to extract matrices from the structure holding all the information
 ************************************************************************/
matrix get_modal_mtd(struct dltcont mtd)
{
  maxcpt = -1
  for(i=1;i<=rows(mtd);i++) {
    if (mtd[i].pt> maxcpt) {
      maxcpt = mtd[i].pt
      maxc = i
    }
  }
  return(mtd[maxc].gt)
} /* end get_model_mtd*/

matrix get_median_mtd(struct design dp)
{
  med = J(rows(dp), cols(dp),-1)
  for(i=1;i<=rows(dp);i++) {
    for(j=1;j<=cols(dp);j++) {
      med[i,j]=dp[i,j].median
    }
  }
  return(med)
} /* end get_median_mtd*/

matrix get_dlt(struct design matrix dp) 
{
  dlt = J(rows(dp),cols(dp),-1)
  for(i=1;i<=rows(dp);i++) {
    for(j=1;j<=cols(dp);j++) {
      dlt[i,j]=dp[i,j].dlt
    }
  }
  return(dlt)
} /* end of get_dlt */
matrix get_n(struct design matrix dp) 
{
  n = J(rows(dp),cols(dp),-1)
  for(i=1;i<=rows(dp);i++) {
    for(j=1;j<=cols(dp);j++) {
      n[i,j]=dp[i,j].n
    }
  }
  return(n)
} /* end of get_n */

/*****************************************************************
 * Make pretty output from structures
 *     print MTD
 *****************************************************************/
void printmtd(struct dltcont mtd)
{
  printf("{txt}\nMTD distribution (1=above MTC, 0=below MTC) \n")
  printf("{dup 7:{c -}}{c TT}{txt}{dup 20:{c -}}\n")
  for(i=1;i<=rows(mtd);i++) {
    for(j=1;j<=rows(mtd[i].gt);j++) {
      for(k=1;k<=cols(mtd[i].gt);k++) {
        printf("{txt}%f", mtd[i].gt[j,k])
      }
      if (j==1) printf("{col 8}{c |}{res} %5.3f \n", mtd[i].pt)  
      else printf("{txt}{col 8}{c |}\n")   
    }
    printf("{txt}{dup 7:{c -}}{c +}{dup 20:{c -}}\n")
  }
  printf("{res}All{txt} {col 8}{c |}{res} %5.3f \n", mtd[rows(mtd)].sumt)
  printf("{txt}{dup 7:{c -}}{c BT}{dup 20:{c -}}\n")
} /* end of printmtd*/

void printtopmtd(struct dltcont mtd, real topi)  /* Print just the topi most likely mtd*/
{
  order=structureorder(mtd)
  if (topi < cols(order)) maxi = topi
  else maxi=cols(order)
  printf("{txt}\nMTD distribution (1=above MTC, 0= below MTC) \n")
  printf("{dup 7:{c -}}{c TT}{txt}{dup 20:{c -}}\n")
  for(i=1;i<=maxi;i++) {
    for(j=1;j<=rows(mtd[order[i]].gt);j++) {
      for(k=1;k<=cols(mtd[order[i]].gt);k++) {
        printf("{txt}%f", mtd[order[i]].gt[j,k])
      }
      if (j==1) printf("{col 8}{c |}{res} %5.3f \n", mtd[order[i]].pt)  
      else printf("{txt}{col 8}{c |}\n")   
    }
    printf("{txt}{dup 7:{c -}}{c +}{dup 20:{c -}}\n")
  }
  printf("{res}All{txt} {col 8}{c |}{res} %5.3f \n", mtd[rows(mtd)].sumt)
  printf("{txt}{dup 7:{c -}}{c BT}{dup 20:{c -}}\n")
} /* end of printtopmtd*/

/***********************************************************************
 * Display the Prior tail probabilities
 ***********************************************************************/
void printdes(struct design des)
{
  /* The initial table display */
  printf("{txt}\nPrior tail chance <= theta (TTL)\n Row Prob(contour is left of this dose combination) \n")
  /* Print first row of column numbers */
  for(j=1;j<=cols(des);j++) {
    printf("{col 5}      %f     ", j )
  }
  /* print first lines of table */
  printf("\n{col 5}")
  for(j=1;j<=cols(des);j++) {
    if (cols(des)==1) printf("{c TLC}{dup 11:{c -}}{c TRC}\n")
    else if (j==1) printf("{c TLC}{dup 11:{c -}}{c TT}")
    else if (j==cols(des)) printf("{dup 11:{c -}}{c TRC}\n")
    else printf("{dup 11:{c -}}{c TT}")
  }
  /* print first elements*/
  for(i=1;i<=rows(des);i++) {
    printf("%f{col 5}{c |}", rows(des)-i+1)
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].ppt)
    }
   /* Print every tail of the distribution*/
/*    printf("\n{col 5}")
    for(k=1;k<=cols(des.F);k++) {
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].F[k])
    }
	 printf("\n{col 5}")
   }
*/   
    /* Print every left edge prob of the distribution*/
    printf("\n{col 5}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].ledge)
    }  
   
    /* print the last row*/
    if (i==rows(des)) {
      printf("\n{col 5}")
      for(j=1;j<=cols(des);j++) {
        if (cols(des)==1) printf("{c BLC}{dup 11:{c -}}{c BRC}\n")
        else if (j==1) printf("{c BLC}{dup 11:{c -}}{c BT}")
        else if (j==cols(des)) printf("{dup 11:{c -}}{c BRC}\n")
        else printf("{dup 11:{c -}}{c BT}")
      }
    }
    /* print rows */
    else {
      printf("\n{col 5}")
      for(j=1;j<=cols(des);j++) {
        if (cols(des)==1) printf("{c LT}{dup 11:{c -}}{c RT}\n")
        else if (j==1) printf("{c LT}{dup 11:{c -}}{c +}")
        else if (j==cols(des)) printf("{dup 11:{c -}}{c RT}\n")
        else printf("{dup 11:{c -}}{c BT}")
      }
    }
  }
} /* end of printdes*/

void desout(struct design des)
{
  /* The initial table display */
  printf("{txt}\nPosterior tail chance <= theta (TTL) \n data and pdf density at theta\n Row prob of contour to the left\n Col prob of contour below\n Median \n")
  /* Print first row of column numbers */
  printf("{col 30}{txt}Drug A\nDrug B")
  for(j=1;j<=cols(des);j++) {
    printf("{col 7}{txt}      %f     ", j )
  }
  /* print first lines of table */
  printf("\n{col 8}")
  for(j=1;j<=cols(des);j++) {
    if (cols(des)==1) printf("{c TLC}{dup 11:{c -}}{c TRC}\n")
    else if (j==1) printf("{c TLC}{dup 11:{c -}}{c TT}")
    else if (j==cols(des)) printf("{dup 11:{c -}}{c TRC}\n")
    else printf("{dup 11:{c -}}{c TT}")
  }
  /* print first elements*/
  for(i=1;i<=rows(des);i++) {
    printf("  %f{col 8}{c |}", rows(des)-i+1)
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].ppt)
    }
/*
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}   pa=%5.3f  pb=%5.3f   {txt}{c |}", des[i,j].pa, des[i,j].pb)
    }
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}  a= %5.3f b= %5.3f   {txt}{c |}", des[i,j].a, des[i,j].b)
    }
*/
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res} %4.0f/%4.0f {txt}{c |}", des[i,j].dlt,des[i,j].n)
    }
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].pdft)
    }
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].ledge)
    }
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.3f   {txt}{c |}", des[i,j].bedge)
    }
    printf("\n{col 8}{c |}")
    for(j=1;j<=cols(des);j++) {
      printf("{res}   %5.0f   {txt}{c |}", des[i,j].median)
    }

   /* print the last row*/
    if (i==rows(des)) {
      printf("\n{col 8}")
      for(j=1;j<=cols(des);j++) {
        if (cols(des)==1) printf("{c BLC}{dup 11:{c -}}{c BRC}\n")
        else if (j==1) printf("{c BLC}{dup 11:{c -}}{c BT}")
        else if (j==cols(des)) printf("{dup 11:{c -}}{c BRC}\n")
        else printf("{dup 11:{c -}}{c BT}")
      }
    }
    /* print rows */
    else {
      printf("\n{col 8}")
      for(j=1;j<=cols(des);j++) {
        if (cols(des)==1) printf("{c LT}{dup 11:{c -}}{c RT}\n")
        else if (j==1) printf("{c LT}{dup 11:{c -}}{c +}")
        else if (j==cols(des)) printf("{dup 11:{c -}}{c RT}\n")
        else printf("{dup 11:{c -}}{c BT}")
      } 
    }
  }
} /* end of desout*/

void printcontours(struct dltcont vector dc)
{
  for(i=1;i<=rows(dc);i++) {
    printf("{txt}Contour %f\n", i)
    te =dc[i].gt
    te
  }
} /* end of printcontours*/

/**********************************************************************
 * Code to produce a heatmap from a matrix
 **********************************************************************/
string pipe_heatmap(real matrix A, real scalar legstart) 
{
  clist=("ltblue", "ltblue", "emidblue", "emidblue", "edkblue", "edkblue", "dkorange", "dkorange", "cranberry", "cranberry", "pink", "pink", "purple", "purple", "sienna", "sienna", "lavender", "lavender", "forest_green", "forest_green", "dkgreen", "dkgreen", "midgreen", "midgreen", "mint", "mint", "lime", "lime", "chocolate", "chocolate", "olive", "olive", "magenta", "magenta")
  hm = J(rows(A)*cols(A)*3,4,.)
  line=1
  for(i=1;i<=cols(A);i++) {
    for(j=1;j<=rows(A);j++) {
  	  hm[line++,] = (i-0.5, rows(A)-j+0.5, rows(A)-j+1.5, A[j,i]) 
      hm[line++,] = (i+0.5, rows(A)-j+0.5, rows(A)-j+1.5, A[j,i])
      hm[line++,] = (., ., ., A[j,i])
    }
  }
  Udata=uniqrows(hm[,4])
  st_matrix("hm",hm)
  stata("qui svmat hm")
  g = ""
  legi = legstart
  for(i=1;i<=rows(Udata);i++) {
    if (Udata[i]~=0) {
      if (Udata[i]<= cols(clist)) hc="color("+clist[Udata[i]]+")"
      else hc="color(red)"
      g = g+"(rarea hm2 hm3 hm1 if hm4=="+strofreal(Udata[i])+", "+hc+"legend(rows(1) symx(*.5) lab("+strofreal(legi)+`" ""' +strofreal(Udata[i])+`"")) ylabel(,nogrid) cmissing(n))"'
	   legi++
    }
  }
  return(g)
} /*end of heatmap*/
 
/**********************************************
 * Code to produce a scatter plot of a matrix
 **********************************************/
string pipe_scatter(real matrix A, real scalar legstart)
{
  slist =("o","O", "d", "D", "t", "T", "s","S","x","+","X")
  line=1
  gd=J(rows(A)*cols(A),3,.)
  for(i=1;i<=rows(A);i++) {
    for(j=1;j<=cols(A);j++) {
  	  gd[line++,] = (rows(A)-i+1, j, A[i,j]) 
    }
  }
  Udatate=uniqrows(gd[,3])
  Udata=select(Udatate,Udatate:~=0)
  st_matrix("gd",gd)
  stata("qui svmat gd")
  g=""   
  for(i=1;i<=rows(Udata);i++) {
    if (Udata[i]<=cols(slist)) mark = "ms("+slist[Udata[i]]+") mc(black)"
    else mark = "ms(Oh) mc(black)"
    g = g+"(scatter gd1 gd2 if gd3=="+strofreal(Udata[i])+", msize(*1.5) "+mark+"legend(lab("+strofreal(i+legstart)+`" ""' +strofreal(Udata[i])+`"D")) cmissing(n))"'
  }
  return(g)
} /*end of pipe_Scatter*/
 
/***********************************************************
 * Code to produce a line plot for a contour 
 *  A is a matrix of the contour in binary
 ***********************************************************/  
string pipe_contour(real matrix A, real scalar linewidth, real scalar legstart)
{
  line=1
	pc=J(rows(A)+cols(A)+1,2,.) /* all the paircoordinates */
	i=1
	j=1
	pc[line++,] = (0.5,rows(A)+0.5)  /* start point */
	while(i<=rows(A) & j<=cols(A)) {
    if (A[i,j]==0) {
		  pc[line,]=pc[line-1,]+(1,0)
		  j++
		}
		else if (A[i,j]==1){
		  pc[line,]=pc[line-1,]-(0,1)
		  i++
		}
		line++
  }
	pc[line,]=(cols(A)+0.5, 0.5)	 /* end point*/
	/* a loop for the x and y labels */
	xt = "0.5 "
	for(i=1;i<=cols(A);i++) {
	  xt = xt+ strofreal(i+0.5) + " " 
	}
	yt = "0.5 "
	for(j=1;j<=rows(A);j++) {
	  yt = yt +strofreal(j+0.5)+ " "
  }
	xr = "0.5 "+strofreal(cols(A)+0.5)
	yr = "0.5 "+strofreal(rows(A)+0.5)
	st_matrix("pc",pc)
  stata("qui svmat pc")  /* convert points into stata data*/
	
  return("(line pc2 pc1, lc(black) lw(*"+strofreal(linewidth)+") plotr(m(zero)) xscale(off) yscale(off) ylabel("+yt+", nogex grid) xlabel("+xt+",grid nogex) legend(lab("+strofreal(legstart)+`" "MTD" )))"')
} /*end of pipe_contour*/
  
/***************************************************************
 * Code to produce a line plot for the median contour
 ****************************************************************/
string pipe_median_contour(struct design matrix dp, real scalar legstart)
{
  line=1
	pc=J(rows(dp)+cols(dp)+1,2,.) 
	i=1
	j=1
	pc[line++,] = (0.5,rows(dp)+0.5)
	while(i<=rows(dp) & j<=cols(dp)) {
    if (dp[i,j].median==0) {
		  pc[line,]=pc[line-1,]+(1,0)
		  j++
		}
		else if (dp[i,j].median==1){
		   pc[line,]=pc[line-1,]-(0,1)
		  i++
		}
		line++
  }
	pc[line,]=(cols(dp)+0.5, 0.5)	
	/* a loop for the x and y labels */
	xt = "0.5 "
	for(i=1;i<=cols(dp);i++) {
	  xt = xt+ strofreal(i+0.5) + " " 
	}
	yt = "0.5 "
	for(j=1;j<=rows(dp);j++) {
	  yt = yt +strofreal(j+0.5)+ " "
  }
	st_matrix("pmc", pc)
  stata("qui svmat pmc")
	
  return("(line pmc2 pmc1, lc(maroon) lp(dash) lw(*2) plotr(m(zero)) xscale(off) yscale(off) ylabel("+yt+", nogex grid) xlabel("+xt+",grid nogex) legend(lab("+strofreal(legstart)+`" "Med" )))"')
} /*end of pipe_median_contour*/
  
/*************************************************************************
 * Code to weighted lines for every edge
 **************************************************************************/
string pipe_wt_edges(struct design matrix dp)
{
  graph = ""
  line=1
	/* Find maximum edge probabilities to scale the maximum width to 10 */
	maxledge = 0
	lastledge = J(rows(dp),1,0)
	for(i=1;i<=rows(dp);i++) {
	  suml =0
	  for(j=1;j<=cols(dp);j++) {
	    suml=suml+dp[i,j].ledge
	    if (maxledge< dp[i,j].ledge) maxledge = dp[i,j].ledge
	  }
	  lastledge[i,1]= 1-suml
	  if (maxledge<(1-suml)) maxledge=1-suml
	}
	maxbedge = 0
	lastbedge = J(cols(dp),1,0)
	for(j=1;j<=cols(dp);j++) {
	  sumb =0
      for(i=1;i<=rows(dp);i++) {
	    sumb=sumb+dp[i,j].bedge
	    if (maxbedge< dp[i,j].bedge) maxbedge = dp[i,j].bedge
	  }
	  lastbedge[j,1]=1-sumb
	  if (maxbedge<(1-sumb)) maxbedge=1-sumb
	}
	maxedge=max((maxbedge,maxledge))
	
	for(i=1;i<=rows(dp);i++) {
	  graph = graph+"(pci "+strofreal(rows(dp)-i+1-0.5)+" "+strofreal(cols(dp)+0.5)+" "+strofreal(rows(dp)-i+1+0.5)+" "+strofreal(cols(dp)+0.5)+",lc(black) lw(*"+strofreal(7*lastledge[i,1]/maxedge)+") )" 
	  for(j=1;j<=cols(dp);j++) {
	    if (i==1) graph = graph+"(pci "+strofreal(rows(dp)-i+1+0.5)+" "+strofreal(j-0.5)+" "+strofreal(rows(dp)-i+1.5)+" "+strofreal(j+0.5)+",lc(black) lw(*"+strofreal(7*lastbedge[j,1]/maxedge)+") )" 
	    graph = graph+"(pci "+strofreal(rows(dp)-i+0.5)+" "+strofreal(j-0.5)+" "+strofreal(rows(dp)-i+0.5)+" "+strofreal(j+0.5)+",lc(black) lw(*"+strofreal(7*dp[i,j].bedge/maxedge)+") )" 
	    graph = graph+"(pci "+strofreal(rows(dp)-i+1-0.5)+" "+strofreal(j-0.5)+" "+strofreal(rows(dp)-i+1+0.5)+" "+strofreal(j-0.5)+",lc(black) lw(*"+strofreal(7*dp[i,j].ledge/maxedge)+") )" 
	  }
	}
	return(graph)
} /*end of pipe_median_contour*/
 
/*************************************************************
 * pipe graph contour dist line width weighted by probability
 *************************************************************/
string pipe_contourdist(struct dltcont matrix mtd, real scalar theta)
{
  /* First get max pt to scale the line drawings */
  maxpt = 0
  for(i=1;i<=rows(mtd);i++) {
    if (mtd[i].pt>maxpt) maxpt =mtd[i].pt
  }  
  gclist = "" 
  for(i=1;i<=rows(mtd);i++) {
    gclist = gclist + "gc"+strofreal(i)+".gph "
    stata("clear")
    stata("qui twoway "+pipe_contour(mtd[i].gt, 7*mtd[i].pt/maxpt+0.5, i)+", nodraw saving(gc"+strofreal(i)+",replace)")
  }
  return("graph combine "+gclist+", imargin(medium)")
}

/*************************************************************
 * pipe smoothed pdf loop over each drug combination, create
 * bar chart from paired differences in the expected probs
 *************************************************************/
string pipe_smooth(struct design matrix dp, struct dltcont matrix mtd, real scalar theta)
{
  glist = ""
  for(i=1;i<=rows(dp);i++) {
    for(j=1; j<=cols(dp);j++) {
      bh = J(2,18,0)
      bh[1,1] = dp[i,j].sc1[i,j] -dp[i,j].sc2[i,j]
      bh[1,2] = dp[i,j].sc2[i,j] -dp[i,j].sc3[i,j]
      bh[1,3] = dp[i,j].sc3[i,j] -dp[i,j].sc4[i,j]
      bh[1,4] = dp[i,j].sc4[i,j] -dp[i,j].sc5[i,j]
      bh[1,5] = dp[i,j].sc5[i,j] -dp[i,j].sc6[i,j]
      bh[1,6] = dp[i,j].sc6[i,j] -dp[i,j].sc7[i,j]
      bh[1,7] = dp[i,j].sc7[i,j] -dp[i,j].sc8[i,j]
      bh[1,8] = dp[i,j].sc8[i,j] -dp[i,j].sc9[i,j]
      bh[1,9] = dp[i,j].sc9[i,j] -dp[i,j].sc10[i,j]
      bh[1,10] = dp[i,j].sc10[i,j] -dp[i,j].sc11[i,j]
      bh[1,11] = dp[i,j].sc11[i,j] -dp[i,j].sc12[i,j]
      bh[1,12] = dp[i,j].sc12[i,j] -dp[i,j].sc13[i,j]
      bh[1,13] = dp[i,j].sc13[i,j] -dp[i,j].sc14[i,j]
      bh[1,14] = dp[i,j].sc14[i,j] -dp[i,j].sc15[i,j]
      bh[1,15] = dp[i,j].sc15[i,j] -dp[i,j].sc16[i,j]
      bh[1,16] = dp[i,j].sc16[i,j] -dp[i,j].sc17[i,j]
      bh[1,17] = dp[i,j].sc17[i,j] -dp[i,j].sc18[i,j]
      bh[1,18] = dp[i,j].sc18[i,j] -dp[i,j].sc19[i,j]
      for(k=1;k<=18;k++) {
        bh[2,k] = k/20
      }
      stata("qui clear")
      st_matrix("bh",bh')
      stata("qui svmat bh")
      stata("qui twoway (bar bh1 bh2 if bh2<="+strofreal(theta)+", yscale(off) xscale(off) barw(0.05) color(forest_green))" + /*
	*/ "(bar bh1 bh2 if bh2>"+strofreal(theta)+", barw(0.05) color(maroon)),legend(off) title("+strofreal(rows(dp)-i+1)+" "+strofreal(j)+") saving(smooth"+strofreal(rows(dp)-i+1)+strofreal(j)+",replace) nodraw")
      glist = glist + "smooth"+strofreal(rows(dp)-i+1)+strofreal(j)+".gph "
    }
  }
  return("qui graph combine "+glist+", imargin(small) rows("+strofreal(rows(dp))+")")
} /* end of pipe_smooth */

end

