*! Date    : 11 Aug 2020
*! Version : 1.00
*! Author  : Adrian Mander
*! Email   : mandera@cardiff.ac.uk
*! Doptimal - the D-optimal design calculation
/*
11Aug20 v1.00 The command is born
*/

/* START HELP FILE
title[To find the D-optimal Design for Dose Ranging studies]

desc[
 {cmd:doptimal} is a command that produces the D-optimal design within a dose ranging design. The command either
takes some data and estimates the model parameters or the user can specify the model parameter values. Then with the paramter estimates the command will find the number of design points or doses, usually including the minimum and maximum doses and then will find the weights or proportion of people who should be allocated to each dose.
]

opt[theta() specifies the model parameters or the starting values for the optimization routine.]
opt[mindose() specifies the lowest possible dose.]
opt[maxdose() specifies the highest possible dose.]
opt[model() specifies which model to assume, these can be selected from linear, quad, emax or log4.]
opt[usedata() specifies that the model parameters are estimated from the current dataset]

example[
For the Emax model and assuming the model parameters are 1, 30 and 0.2, find the D-optimal design
by the following command

 {stata doptimal, theta(1 30 0.2) model(emax) mindose(0) maxdose(1.5)}
]

author[Prof Adrian Mander]
institute[Cardiff University]
email[mandera@cardiff.ac.uk]

return[design The design matrix]
return[theta The model parameters]

freetext[]


seealso[
{help crm} (if installed)   {stata ssc install crm} (to install this command)

{help mtpi} (if installed)  {stata ssc install mtpi} (to install this command)

{help pipe} (if installed)  {stata ssc install pipe} (to install this command)
]

END HELP FILE */


/*

 doptimal, m(quad) n(10) 
 doptimal, m(quad) n(10)  s(0 1 2 3)
 il2, m(quad) n(10)  s(0 1 2 3) r(0.1)
*/

program doptimal, rclass
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

  syntax [varlist] [if] [,THETA(numlist) MAXdose(real 1.5) /*
  */ MINdose(real 0) Model(string) USEDATA]

  /* option checking */
  if "`mindose'"<"0" {
    di "{err}Minimumn dose can not be below 0"
    exit(196)
  }
  if "`mindose'">="`maxdose'" {
    di "{err}Minimumn dose must be less than maxdose"
    exit(196)
  }
  if "`model'"=="" local model "linear"
  if "`usedata'"~="" & "`theta'"=="" {
    if "`model'"=="linear" {
      local theta "1 2"
    }
     if "`model'"=="quad" {
      local theta "1 2 3"
    }
    if "`model'"=="emax" {
      local theta "1 5 .3"
    }
    if "`model'"=="log4" {
      local theta "1 5 .3 5"
    }
  }
  if "`usedata'"=="" & "`theta'"=="" {
    di "{err}Warning: you have not specified theta() or usedata so picking defaults"
    if "`model'"=="linear" {
      local theta "1 2"
    }
     if "`model'"=="quad" {
      local theta "1 2 3"
    }
    if "`model'"=="emax" {
      local theta "1 5 .3"
    }
    if "`model'"=="log4" {
      local theta "1 5 .3 5"
    }
  }

  /*****************************************************************************************************
   * Given some data, estimate the parameters of the non-linear model and find the optimal design 
   *  NEED to have the using for this option
   * OR give the exact values of the model via beta() and find the optimal design
   *
   * NEED doses used
   *****************************************************************************************************/
  di "{txt}Doptimal Design finding"
  di "{dup 23:{c -}}"
  di
  if "`usedata'"=="" local usedata 0
  else {
    local usedata 1
    local first 1
    foreach v of varlist `varlist' {
      if (`first') {  
        local first 0
        local yvar "`v'"
      }
      else {
        local linpred "`linpred' `v'"
      }
    }
    di "Using current dataset to estimate model parameters to give optimal design"
  }
  if "`theta'"~="" {
    local beta ""
    foreach num of numlist `theta' {
      if "`beta'"=="" local beta "`num'"
      else local beta "`beta',`num'"      
    }
    local theta "`beta'"
    di "{txt}The vector of model parameters is {res}(`theta')"
  }

  /********************************************************
   * STATA calling the estimation optimal design stuff
   * Linear, quad, emax, emax2, logistic 											*
   ********************************************************/

  mata: doptimal("`model'", (`theta'), `usedata', "`yvar'", "`linpred'", `mindose', `maxdose')
  return matrix design = design
  return matrix theta = betahat
end /*end of Stata*/

mata:

/************************************************
 * printing the design matrix   
 ************************************************/
  void printdesign(matrix des)
  {
    des = sort(des',1)'  /* doses might not be ascending due to initial values */
    printf("{txt}Design\n")
    for(j=1;j<=rows(des);j++) {
      if (j==1) printf("\n{txt} Dose       ")
      else if (j==2)      printf("\n{txt} Proportion ")
      for(i=1;i<=cols(des);i++) {
        printf("{res} %6.3f ", des[j,i])
      }
    }
  }

/********************************************************************************************
 * How to transform the linear single row describing the design to a matrix of doses/weights
 *  This because optimize optimizes over a vector not a matrix 
 *  designasrow should be (d1 d2 d3 w1 w2)
 ********************************************************************************************/
  matrix designrow2design(real scalar dmin, real scalar dmax, real rowvector designasrow)
  {
    width=round((cols(designasrow)+1)/2)
    top = editmissing(dmax:*invlogit(designasrow)[1..width], dmax) /* missing values are dmax */
    bot = editmissing(invlogit(designasrow)[(width+1)..cols(designasrow)], 1), 1
    bot = bot:/quadsum(bot)
    return(top \ bot)
  }

/*****************************************************
 * D-optimal design and model parameter estimation
 *****************************************************/
void doptimal(model, theta, usedata, y, linpred, dmin, dmax)
{

 /* Need to delete missing data */
  if (usedata) {
    dd = st_data(., linpred)
    dd= select(dd, rowmissing(dd):==0)
    yy = st_data(., y)
    yy= select(yy, rowmissing(yy):==0)
    data = (dd, yy)

    /* this is the routine to find the least squares estimates for the model, the data is passed via an arg */
    startvalues = theta
    printf("{txt}Estimating parameters of the %s model\n", model)
    Sbeta =optimize_init()
    optimize_init_which(Sbeta, "min")
    optimize_init_conv_maxiter(Sbeta, 100)
    optimize_init_argument(Sbeta, 1, data)
    optimize_init_tracelevel(Sbeta, "none")
    optimize_init_params(Sbeta, startvalues)
    if (model=="quad") optimize_init_evaluator(Sbeta, &findbetahat_quad())
    if (model=="linear") optimize_init_evaluator(Sbeta, &findbetahat_lin())
    if (model=="emax") optimize_init_evaluator(Sbeta, &findbetahat_emax())
    if (model=="log4") optimize_init_evaluator(Sbeta, &findbetahat_log4())
    betahat=optimize(Sbeta)
    converged = optimize_result_converged(Sbeta)
    if (!converged) {
      printf("{err}NOTE: Doing optimization for fitting model again using random starting values\n")
      Sbeta =optimize_init()
      if (cols(theta)==3) startvalues = runiform(1,3)
      if (cols(theta)==4) startvalues = runiform(1,4)
      if (model=="emax") optimize_init_evaluator(Sbeta, &findbetahat_emax())
      if (model=="log4") optimize_init_evaluator(Sbeta, &findbetahat_log4())
      optimize_init_which(Sbeta, "min")
      optimize_init_conv_maxiter(Sbeta, 100)
      optimize_init_params(Sbeta, startvalues)
      optimize_init_argument(Sbeta, 1, data)
      optimize_init_tracelevel(Sbeta, "none")
      betahat=optimize(Sbeta)
      converged = optimize_result_converged(Sbeta)
      if (!converged) exit(198)
    }
    if (cols(theta)==2) printf("{txt}Estimated model parameters = {res}(%5.2f, %5.3f)\n",  betahat[1], betahat[2])
    if (cols(theta)==3) printf("{txt}Estimated model parameters = {res}(%5.2f, %5.3f, %5.3f)\n",  betahat[1], betahat[2], betahat[3])
    if (cols(theta)==4) printf("{txt}Estimated model parameters = {res}(%5.2f, %5.3f, %5.3f, %5.3f)\n",  betahat[1], betahat[2], betahat[3], betahat[4])
   }
  else {
    betahat=theta
  }

  /* This is the code that finds the D-optimal design the optimizer goes on infinite matrix space but designrow2design uses dmin and dmax to scale inf back to the dose range and make sure weights add to 1 */
  printf("{txt}Finding D-optimal design\n")
  S=optimize_init()
  optimize_init_technique(S,"nm")
  optimize_init_argument(S, 1, betahat)
  optimize_init_argument(S, 2, dmin)
  optimize_init_argument(S, 3, dmax)
  optimize_init_tracelevel(S, "none")
  convdoptim = optimize_result_converged(S)
  if (cols(theta)==2) {
    optimize_init_nmsimplexdeltas(S, (.2,.15,.20))
    optimize_init_params(S, (runiform(1,2),5))  /* so close to dmin, dmiddle, dmax and equal weights*/
  }
  if (cols(theta)==3) {
    optimize_init_nmsimplexdeltas(S, (-.2,.10,.20,.2,.3))
    optimize_init_params(S, (-3,0,3,5,5))  /* so close to dmin, dmiddle, dmax and equal weights*/
  }
  if (cols(theta)==4) {
    optimize_init_nmsimplexdeltas(S, (-.2,.10,.20, .3, .2,.3, .4))
    optimize_init_params(S, (-3,-1, 0,3,5,5, 5))  /* so close to dmin, dmiddle, dmax and equal weights*/
  }
  if (model == "quad") optimize_init_evaluator(S, &findD_quad_design())
  if (model == "linear") optimize_init_evaluator(S, &findD_lin_design())
  if (model=="emax") optimize_init_evaluator(S, &findD_emax_design())
  if (model=="log4") optimize_init_evaluator(S, &findD_log4_design())

  p=optimize(S)
  if (model=="linear") bestI = EIkdesign_lin(betahat, designrow2design(dmin, dmax, p))
  if (model=="quad") bestI = EIkdesign_quad(betahat, designrow2design(dmin, dmax, p))
  if (model=="emax") bestI = EIkdesign_emax(betahat, designrow2design(dmin, dmax, p))
  if (model=="log4") bestI = EIkdesign_log4(betahat, designrow2design(dmin, dmax, p))
  if (!convdoptim) {
    printf("{err}Repeating optimization for finding D-optimal design with random inits\n")
    S=optimize_init()
    if (cols(theta)==3) {
      doptim_start = runiform(1,3),5,5
      optimize_init_nmsimplexdeltas(S, (-2,.15,.20,.2,.3))
    }
    if (cols(theta)==4) {
      doptim_start = runiform(1,4),5,5,5
      optimize_init_nmsimplexdeltas(S, (-2,.15,.20, .4, .2,.3, .5))
    }
    if (cols(theta)==2) {
      doptim_start = runiform(1,2),5
      optimize_init_nmsimplexdeltas(S, (-2,.15,.2))
    }
    if (model=="linear") optimize_init_evaluator(S, &findD_lin_design())
    if (model=="quad") optimize_init_evaluator(S, &findD_quad_design())
    if (model=="emax") optimize_init_evaluator(S, &findD_emax_design())
    if (model=="log4") optimize_init_evaluator(S, &findD_log4_design())
    optimize_init_conv_maxiter(S, 200)
    optimize_init_technique(S,"nm")
    optimize_init_which(S, "max")
    optimize_init_params(S, doptim_start)
    optimize_init_argument(S, 1, betahat)
    optimize_init_argument(S, 2, dmin)
    optimize_init_argument(S, 3, dmax)
    optimize_init_tracelevel(S, "none")
    convdoptim = optimize_result_converged(S)
    newp=optimize(S)
    design = designrow2design(dmin, dmax, newp)
    if (model=="linear") newI= EIkdesign_lin(betahat, design) 
    if (model=="quad") newI= EIkdesign_quad(betahat, design)
    if (model=="emax") newI= EIkdesign_emax(betahat, design)
    if (model=="log4") newI= EIkdesign_log4(betahat, design)
    if (newI>bestI) p=newp
  }

  design = designrow2design(dmin,dmax,p)
  st_matrix("betahat", betahat)
  st_matrix("design", design)
  printdesign(design)

}

/*******************************************************************************
 *                                LINEAR models                                *
 *******************************************************************************/
  /*** this is the linear model*/
  real matrix f_lin(real b, real d)   			
  {
    return(b[1] :+ b[2]:*d)
  }
  /* differentiation of f() b are the coefficients of f and d is the dose*/
  matrix difff_lin(real b, real scalar d) 
  {
    return( (1, d) )
  }
  /* The expected information for a design  ( d1,d2 \ w1,w2) */ 
  real EIkdesign_lin(b, design)   /* The expected information for a design  ( d1,d2 \ w1,w2) */ 
  {
    for(i=1;i<=cols(design);i++) {
      if(i==1) I = design[2,i]:* difff_lin(b, design[1,i])'*difff_lin(b,design[1,i]) 
      else I= I+ design[2,i]:* difff_lin(b, design[1,i])'*difff_lin(b,design[1,i]) 
    }
    return(det(I))
  }

  /** LINEAR function for the det information from a design to optimise ***/
  void findD_lin_design(todo, designasrow, b, dmin, dmax, y, S, H) 	
  {
    design = designrow2design(dmin, dmax, designasrow)
    y =  EIkdesign_lin(b, design) 
  }
  /* doing the  numerical least squares estimation */
  void findbetahat_lin(todo, b, data, y, S, H) 		/* This is the function for fitting the model */
  {
    y = quadsum( (data[,2] :- b[1] :- b[2]:*data[,1]):^2 )
  }

/********************************************************************************
 *                                QUADRATIC models                            	*
 * the function is
 * y = b[1] + b[2]*dose +b[3]*dose^2
 ********************************************************************************/
real matrix f_quad(real b, real d)   		/*** this is the non-linear model*/
{
  return(b[1] :+ b[2]:*d :+ b[3]:*d:*d)
}
matrix difff_quad(real b, real scalar d)  	/* differentiation of f() */
{
  return( (1, d, d^2) )
}
real EIkdesign_quad(b, design)   /* The expected information for a design  ( d1, d2, d3 \ w1, w2, w3) actually adding the observed information together but higher order terms disappear in expected version you need to consider next order */ 
{
  for(i=1;i<=cols(design);i++) {
    if(i==1) I = design[2,i]:* difff_quad(b, design[1,i])'*difff_quad(b,design[1,i]) 
    else I= I+ design[2,i]:* difff_quad(b, design[1,i])'*difff_quad(b,design[1,i]) 
  }
  return(det(I))
}
void findD_quad_design(todo, designasrow, b, dmin, dmax, y, S, H) 	
{
  design = designrow2design(dmin, dmax, designasrow)
  y =  EIkdesign_quad(b, design) 
}
void findbetahat_quad(todo, b, data, y, S, H) 		/* This is the function for fitting the model */
{
  y = quadsum( (data[,2] :- b[1] :- b[2]:*data[,1] :- b[3]:*data[,1]:^2):^2 )
}

/********************************************************************************
 *                                EMAX MODEL Gs                                 *
 * the function is   y = b[1] + b[2]*dose/(b[3]+dose)				*
 ********************************************************************************/
  /* the model function*/
real matrix f_emax(b,d) 
{
  return(b[1] :+ b[2]:*d:/(b[3]:+d))
}
matrix difff_emax(b, real scalar d)  	/* differentiation of f() */
{
  return( (1, d/(b[3]+d), -b[2]*d/(b[3]+d)^2 ) )
}
real EIkdesign_emax(b, design)   	/* The expected information for a design  ( d1, d2, d3 \ w1, w2, w3) */ 
{
  for(i=1;i<=cols(design);i++) {
    if(i==1) I = design[2,i]:* difff_emax(b, design[1,i])'*difff_emax(b,design[1,i]) 
    else I= I+ design[2,i]:* difff_emax(b, design[1,i])'*difff_emax(b,design[1,i]) 
  }
  return(det(I))
}
void findD_emax_design(todo, designasrow, b, dmin, dmax, y, S, H) 	
{
  design = designrow2design(dmin, dmax, designasrow)
  y =  EIkdesign_emax(b, design)
}
void findbetahat_emax(todo, b, data, y, S, H) 		/* This is the function for fitting the non-linear model */
{
  y = quadsum( (data[,2] :- b[1] :- b[2]:*data[,1]:/(b[3]:+data[,1])):^2 )
}

/********************************************************************************
 *                            LOGistic  MODEL Gs                                 *
 ********************************************************************************/
/* the function is
 * y = b[1] + b[2]*(1+exp((b[3]-dose)/b[4]))^(-1)
 * g(b, 0.5) = b[3]-b[4]*ln((b[1]+b[2]-0.5)/0.5)
 */
real matrix f_log4(b,d)
{
  return(b[1] :+ b[2]:/(1:+exp((b[3]:-d):/b[4])) )
}
matrix difff_log4(b,d)  /* b are the coefficients of f and d is the dose*/
{
  return( (1, 1/(1+exp((b[3]-d)/b[4])), (-b[2]*exp((b[3]-d)/b[4]))/(b[4]*(1+exp((b[3]-d)/b[4]))^2) , (b[2]*(b[3]-d)*exp((b[3]-d)/b[4]))/(b[4]^2*(1+exp((b[3]-d)/b[4]))^2) ) )
}
real EIkdesign_log4(b, design) /* The expected information for a design  ( d1, d2, d3, d4 \ w1, w2, w3, w4) passing through the parameter estimates b */ 
{
  for(i=1;i<=cols(design);i++) {
    if(i==1) I = design[2,i]:* difff_log4(b, design[1,i])'*difff_log4(b,design[1,i]) 
    else I= I+ design[2,i]:* difff_log4(b, design[1,i])'*difff_log4(b,design[1,i]) 
  }
  return(det(I))
}
void findD_log4_design(todo, designasrow, b, dmin, dmax, y, S, H) /* get expected infromation */
{
  design = designrow2design(dmin, dmax, designasrow)
  y =  EIkdesign_log4(b, design)  /* we are after minimising or maximising y */
}
void findbetahat_log4(todo, b, data, y, S, H)  /* a least squares estimator for the model */
{
  y = quadsum( (data[,2]:-b[1]:-b[2]:/(1:+exp((b[3]:-data[,1]):/b[4]))):^2 )
}


/********************************************************************************
 *                        NOT beta model!!!    BETA MODEL Gs                                 *
 ********************************************************************************/
/* the function is
 * y = b[1] + b[2]/(1+exp((b[3]-dose)/b[4]))
 * g(b, 0.5) = b[3]-b[4]*ln((b[1]+b[2]-0.5)/0.5)
 */
real matrix f_beta(b,d)
{
  return(b[1] :+ b[2]:/(1:+exp((b[3]:-d):/b[4])) )
}
matrix difff_beta(b,d)  /* b are the coefficients of f and d is the dose*/
{
  return( (1, 1/(1+exp((b[3]-d)/b[4])), (-b[2]*exp((b[3]-d)/b[4]))/(b[4]*(1+exp((b[3]-d)/b[4]))^2) , (b[2]*(b[3]-d)*exp((b[3]-d)/b[4]))/(b[4]^2*(1+exp((b[3]-d)/b[4]))^2) ) )
}
real EIkdesign_beta(b, design) /* The expected information for a design  ( d1, d2, d3, d4 \ w1, w2, w3, w4) passing through the parameter estimates b */ 
{
  for(i=1;i<=cols(design);i++) {
    if(i==1) I = design[2,i]:* difff_beta(b, design[1,i])'*difff_beta(b,design[1,i]) 
    else I= I+ design[2,i]:* difff_beta(b, design[1,i])'*difff_beta(b,design[1,i]) 
  }
  return(det(I))
}
void findD_beta_design(todo, designasrow, b, dmin, dmax, y, S, H) /* get expected infromation */
{
  design = designrow2design(dmin, dmax, designasrow)
  y =  EIkdesign_beta(b, design)  /* we are after minimising or maximising y */
}
void findbetahat_beta(todo, b, data, y, S, H)  /* a least squares estimator for the model */
{
  y = quadsum( (data[,2]:-b[1]:-b[2]:/(1:+exp((b[3]:-data[,1]):/b[4]))):^2 )
}






/* OLD code for Il-2 study
/****************************************************************************************
 *                                EMAX MODEL2 Gs    this is Emax substituting 1/b[3]    *
 *  28/9 cross-checked with Simon's code 						*
 ****************************************************************************************/
/* the function is
 * y = b[1] + b[2]*dose/(1+dose/b[3])
 * g(b, 0.5) = (0.5-b[1])*b[3]* (b[2]*b[3]-0.5+b[1])^(-1)
 */
real matrix f_emax2(b,d)
{
  return(b[1] :+ b[2]:*d:/(1:+d:/b[3]))
}
matrix difff_emax2(b,d)  /* b are the coefficients of f and d is the dose*/
{
  return( (1, d/(1+d/b[3]), b[2]*d^2/(b[3]^2*(1+d/b[3])^2) ) )
}
matrix hessian_emax2(b,d)  /* b are the coefficients of f and d is the dose*/
{
  return( (0,0,0 \ 0,0, d:*d:/(b[3]:^2:*(1:+d:/b[3]):^2) \ 0, d:*d:/(b[3]:^2:*(1:+d:/b[3]):^2) , 2:*b[2]:*d:^3:/(b[3]:^4:*(1:+d:/b[3]):^3) :-   2:*b[2]:*d:^2/(b[3]:^3:*(1:+d:/b[3]):^2)  ) )
}
matrix EIk_emax2(b, X)
{
  ones = J(rows(X),1,1)
  return((ones, X[,1]:/(ones:+X[,1]:/b[3]), -b[2]:*X[,1]:^2:/(b[3]:^2*(ones:+X[,1]:/b[3]):^2) )'*(ones, X[,1]:/(ones:+X[,1]:/b[3]), -b[2]:*X[,1]:^2:/(b[3]:^2*(ones:+X[,1]:/b[3]):^2) ))
}
matrix OIk_emax2(b, data)
{
  sum=difff_emax2(b,data[1,1])'*difff_emax2(b,data[1,1])-(data[1,2]-f_emax2(b,data[1,1]) ):*  hessian_emax2(b,data[1,1])
  for(i=2;i<=rows(data);i++) {
    sum= sum+difff_emax2(b,data[i,1])'*difff_emax2(b,data[i,1])-(data[i,2]- f_emax2(b,data[i,1]) ):*  hessian_emax2(b,data[i,1])
  }
  return(sum)
}
matrix diffg_emax2(b, real scalar y)                /* diff g wrt beta as a colvector */
{
  return((  -1*b[3]/(b[1]+b[2]*b[3]-y) - (b[3]*y-b[1]*b[3])/(b[1]+b[2]*b[3]-y)^2 \ (-1*b[3]*(b[3]*y-b[1]*b[3]))/(b[1]+b[2]*b[3]-y)^2  \ (y-b[1])/(b[1]+b[2]*b[3]-y)-(b[2]*(b[3]*y-b[1]*b[3]))/(b[1]+b[2]*b[3]-y)^2      ))
}
matrix vargbeta_emax2(b, y, sigma)
{
  return(diffg_emax2(b,y)'*sigma*diffg_emax2(b,y))
}
matrix egbeta_emax2(b, y)
{
  return( (y*b[3]-b[1]*b[3])/(b[2]*b[3]-y+b[1])  )
}
void findD_emax2(todo, p, Ik, b, var, y, S, H) 
{
  y = diffg_emax2(b,0.5)'* (var:*invsym( (Ik + (difff_emax2(b,p)'*difff_emax2(b,p))) )) * diffg_emax2(b,0.5)
}
real return_findD_emax2(p, Ik, b, var) /* p is future dose, Ik information, b betahat*/
{
  return(diffg_emax2(b,0.5)'* (var:*invsym( (Ik + (difff_emax2(b,p)'*difff_emax2(b,p))) ) ) * diffg_emax2(b,0.5))
}
void findbetahat_emax2(todo, b, data, y, S, H) 
{
  y = quadsum( (data[,2] :- b[1] :- b[2]:*data[,1]:/(1:+data[,1]:/b[3])):^2 )
}
/*************************************************************
 * EMAX2 MODEL
 * The estimation part and the optimisation to find next dose
 *************************************************************/
void doptimal_emax2(theta, usedata, y, linpred, dmin, dmax)
{
 /* Need to delete missing data */
  d = st_data(., linpred)
  d= select(d, rowmissing(d):==0)
  yy = st_data(., y)
  yy= select(yy, rowmissing(yy):==0)
  data = (d, yy)

  /* this is the routine to find the least squares estimates of the Emax model, the data is passed via an arg */
  Sbeta =optimize_init()
  optimize_init_evaluator(Sbeta, &findbetahat_emax2())
  optimize_init_which(Sbeta, "min")
  optimize_init_conv_maxiter(Sbeta, 100)
  optimize_init_params(Sbeta, (0.4,.1,1) )
  optimize_init_argument(Sbeta, 1, data)
  betahat=optimize(Sbeta)

  /* This gives an estimate of the residual variance, there are 3 parameters in this emax model  */
  e = (data[,2]-f_emax2(betahat,data[,1]))
  resvarhat = e'e/(rows(d)-3)

  /* This is the code to get the variance of the betas, this is correct and checked the expected information is blanked out.
  */
/* 
  EIk=EIk_emax2(betahat, data)  
  varbeta_emax = resvarhat * invsym(EIk)
*/
  OIk = OIk_emax2(betahat, data)
  varibeta_emax = resvarhat * invsym(OIk)

  if (abs(betahat[1]+betahat[2]-0.5)<0.001) {
    printf("{err}Getting close to the problem of huge doses!")
    st_numscalar("r(nxdose)",0)
    return
  }
  S=optimize_init()
  optimize_init_evaluator(S, &findD_emax2())
  optimize_init_which(S, "min")
  optimize_init_conv_maxiter(S, 100)
  optimize_init_params(S, egbeta_emax2(betahat, 0.5))
  optimize_init_argument(S, 1, OIk)
  optimize_init_argument(S, 2, betahat)
  optimize_init_argument(S, 3, resvarhat)
  p=optimize(S)
 
  st_numscalar("r(nxdose)",p)
  st_matrix("betahat", betahat)
  st_numscalar("r(edose)", egbeta_emax2(betahat, 0.5))
  st_numscalar("r(edosevar)", vargbeta_emax2(betahat, 0.5, varibeta_emax))

    design = designrow2design(dmin,dmax,p) 
    st_matrix("betahat", betahat)
    st_matrix("design", design)
    printdesign(design)
}
*/



end
