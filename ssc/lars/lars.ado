*! Date    : 14 July 2014
*! Version : 1.05
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

*! This prgram is almost a direct port of the least angle regression (LAR) package written by Trevor Hastie and Brad Efron
*! for R and Splus.

/*
9/8/07    v1.01  Various additions just after initial release 
31/10/07  v1.02 Fixed reporting error for very small coefficients
19/11/10  v1.03 Bug Fix - Changed the option default on s() from 4.1 to 0.5 just in case people use only 1 x variable!
12/ 2/14  v1.04 Add xtra goptions
14/ 7/14  v1.05 Bug in variables that are completely deterministic this error check added
*/

/*****************************************************************************
 * Not every feature of the LARS package has been tested and there are 
 * probably still bugs a plenty
 *****************************************************************************/

program define lars, rclass
preserve
version 9.2
syntax [varlist(min=3)] [if] [in] [, Algorithm(string) Eps(real 0.000001) Graph Type(string) Mode(string) S(real 0.5) GOPT(string) NOOUTPUT SLINE *]
local xtragopt "`options'"

/********************************************************
 * OVERALL Algorithm
 * Eps is epsilon the threshold to minimise the steps
 * Graph do graph
 * type in predict lars
 * mode in predict lars
 * s in predict lars
 * gopt is stuff for the graph
 *
 ********************************************************/

/********************************************************
 * Set up the sting options to default values
 ********************************************************/

di "{text}NOTE: Deleting all matrices"
matrix drop _all

if "`type'"=="" local type "coefficients"
if "`type'"~="coefficients" {
  di "{error}WARNING: The type() option contained `type' rather than coefficients"
  di "This has now been changed to the correct option"
  local type "coefficients"
}
if "`mode'"=="" local mode "step"
if "`mode'"~="step" {
  di "{error}WARNING: The mode() option contained `mode' rather than step"
  di "This has now been changed to the correct option"
  local mode "step"
}
if "`algorithm'"=="" local algorithm "lars"
/*
else if ("`algorithm'"=="lasso" | "`algorithm'"=="stagewise") {
  di "The option a(`algorithm') is not currently available"
  exit(198)
}
*/
/********************************************************
 * Sort out the missing data and the y/x variable lists 
 ********************************************************/

marksample touse
qui keep if `touse'
local largestvarname 0
local i 1
foreach v of local varlist {
  if `i++'==1 local y "`v'"
  else {
    local clist "`clist' `v'"
    if length("`v'")>`largestvarname' local largestvarname= length("`v'")
  }
}

/********************************************************
 * All calculations/estimation is done now, in Mata 
 ********************************************************/

mata: mylars("`y'", "`clist'", "`touse'", `eps', "`algorithm'")
if (error[1,1]) exit(198)
mat sbeta=r(sbeta)
mat beta=r(beta)
mat normx=r(normx)
mat cp = r(cp)
mat rss = r(rss)
mat r2 = r(r2)
mat RSS = r(RSS)
mat R2 = r(R2)
mat meanx = r(meanx)
mat mu = r(mu)
mat ade = r(ade)

mat dir
mat list sbeta

/*******************************************************************************
 * Predict one value from the estimation
 *******************************************************************************/

mata: predictlars( "", `s', "`type'", "norm")
mat newbetas = r(newbetas)

/*******************************************************************************
 * Use the variable list as the names of the matrices
 *******************************************************************************/

mat colnames beta=`clist'
mat colnames sbeta=`clist'
mat colnames newbetas=`clist'
mat colnames normx=`clist'

/*******************************************************************************
 * From the matrix beta reconstruct the actions.. this is an improvement over 
 * improving the actions[[k]] splus command in mylars.
 *******************************************************************************/

forv i=2/`=rowsof(ade)' {
  forv j=1/`=colsof(ade)' {
    if ade[`i',`j']~=0 {
      local adeval = ade[`i',`j']
      local lab : word `=abs(`adeval')' of `clist'
      if `adeval' < 0 local lab "-`lab'"
      else local lab "+`lab'"
      local actions`i' "`actions`i'' `lab'" 
    }
  }
}

local actlength 0
forv i=2/`=rowsof(ade)' {
  if length("`actions`i''")> `actlength' local actlength = length("`actions`i''")+1
}

/*******************************************************************************
 * DISPLAY RESULTS
 *
 * Find the step with the minimum Cp <- this is correct
 * Display the Cp model stuff   
 * and R-squared
 *******************************************************************************/

if "`nooutput'"=="" {
  local cpmini -1
  local cpmin =1000000000000000
  forv i=1/`=colsof(cp)' {
    if cp[1,`i'] < `cpmin' {
      local cpmin = cp[1,`i']
      local cpmini `i'
    }
  }	
  di 
  di "{txt}Algorithm is {res}`algorithm'"
  di
  di "{txt}Cp, R-squared and Actions along the sequence of models"
  di
  di "{c TLC}{dup 6:{c -}}{c TT}{dup 13:{c -}}{c TT}{dup 10:{c -}}{c TT}{dup `actlength':{c -}}{c TRC}"
  di "{c |} Step {col 8}{c |}{col 14} Cp {col 22}{c |} R-square {col 33}{c |}  Action {col `=34+`actlength''}{c |}"
  di "{c LT}{dup 6:{c -}}{c +}{dup 13:{c -}}{c +}{dup 10:{c -}}{c +}{dup `actlength':{c -}}{c RT}"
  local nrow =colsof(cp)
  forv i=1/`=colsof(cp)' {
    local cpval: di %10.4f cp[1,`i']
    local r2val: di %7.4f R2[1,`i']
    local ival: di %4.0f `i'
    if `i'==`cpmini' local xprint "*"
    else local xprint ""
    di "{txt}{c |}{res} `ival' {col 8}{txt}{c |}{res} `cpval' `xprint'{col 22}{txt}{c |} {res}`r2val' {txt}{col 33}{c |}{res}`actions`i'' {txt}{col `=34+`actlength''}{c |} "
  }
  di "{c BLC}{dup 6:{c -}}{c BT}{dup 13:{c -}}{c BT}{dup 10:{c -}}{c BT}{dup `actlength':{c -}}{c BRC}"
  di "{res}*{txt} indicates the smallest value for Cp"

/********************************************************************************
 * Display the Betas for the model with the smallest Cp value 
 ********************************************************************************/

local adj = `largestvarname'-8
if `adj'<0 local adj 0

  di
  di "The coefficient values for the minimum Cp"
  di
  di "{c TLC}{dup `=10+`adj'':{c -}}{c TT}{dup 14:{c -}}{c TRC}"
  di "{c |} Variable {col `=12+`adj''}{c |}{col `=14+`adj''} Coefficient {col `=22+`adj''}{c |}"
  di "{c LT}{dup `=10+`adj'':{c -}}{c +}{dup 14:{c -}}{c RT}"
  forv i=1/`=colsof(beta)' {
    local name: word `i' of `clist'
    if beta[`cpmini',`i']>0 & beta[`cpmini',`i']<0.0001 local value: di %11.4e beta[`cpmini',`i']
    else local value: di %11.4f beta[`cpmini',`i']
    if `value'~=0 di "{c |} `name' {col `=12+`adj''}{txt}{c |} {res} `value' {txt}{c |}"
  }
  di "{c BLC}{dup `=10+`adj'':{c -}}{c BT}{dup 14:{c -}}{c BRC}"
}

/********************************************************************************
 *  Given all the estimates do some graphs 
 ********************************************************************************/

if "`graph'"~="" {
  local coef "sbeta"
  local step "step"
  local step "summod"
  local step "modratio"

  qui gen summod=0
  lab var summod "Sum of mod(beta)"
  qui gen step=.
  lab var step "Step"
  local g ""

  forv i = 1/`=colsof(`coef')' {
    local name: word `i' of `clist'
    qui gen lars`i'=.
    lab var lars`i' "`name'"
    local g "`g' (line lars`i' `step')"
    forv j = 1/`=rowsof(`coef')' {
      qui replace summod = summod + abs(`coef'[`j',`i']) in `j'
      qui replace step = `j' in `j'
      qui replace lars`i'=`coef'[`j',`i'] in `j'
    }
  }
  qui su summod
  qui gen modratio = summod/`r(max)'
  lab var modratio "Sum mod(beta)/ Max sum mod (beta)"
  local extra "ytitle(Beta)"
  twoway `g', `extra' `gopt' `xtragopt'
}


/********************************************************************************
 * Return the various matrices 
 ********************************************************************************/

return matrix beta=beta
return matrix normx=normx
return matrix sbeta=sbeta
return matrix cp=cp
return matrix newbetas=newbetas
return matrix R2=R2
return matrix RSS=RSS

restore
end

/********************************************************************************                   predictlars
 * predictlars()
 *
 ********************************************************************************/

version 9.2
mata:
void predictlars(newx, real scalar s, string scalar type, string scalar mode)
{

  if (type=="fit") {
   type = "coefficients"
  }
  betas=st_matrix("beta")

  sbetas=st_matrix("sbeta")
  k = rows(betas)
  p = cols(betas)
  steps = (1..k)

  if (s==.) {
    s = steps
    mode = "step"
  }
  if (mode=="step") {
   if( any( s :< 0 ) | any( s :> k ) ) {
      printf("Argument s out of range")
    }
    sbeta=steps
  }
  if (mode=="fraction") {
   if( any(s :> 1) | any(s :< 0) ) {
      printf("Argument s out of range")
    }
    nbeta = abs(sbetas) * J(p,1,1)  /* Adding up ABS columns */
    sbeta = nbeta / nbeta[k]
  }
  if (mode=="norm") {
    nbeta = abs(sbetas) * J(p,1,1)  /* Adding up ABS columns */
    if( any(s :> nbeta[k]) | any(s :< 0) ) {
      printf("Argument s out of range")
    }
    sbeta = nbeta
  }

  sfrac = (s :- sbeta[1]):/(sbeta[k] - sbeta[1])
  sbeta = (sbeta :- sbeta[1]) :/ ( sbeta[k] - sbeta[1] )
  usbeta = uniqrows(sbeta')'
  useq = matchrows(usbeta,sbeta)
  sbeta = sbeta[useq]
  betas = betas[useq,]

  coord = approx(sbeta, sfrac)
  left = floor(coord)
  right = ceil(coord)

  newbetas = ( (sbeta[right,] :- sfrac) :* betas[left,] :+ ( sfrac :- sbeta[left,]) :* betas[right,] ) :/ (sbeta[right,] :- sbeta[left,])
  if (left==right) newbetas[left==right, ] = betas[ left[left==right],]

  st_matrix("r(newbetas)", newbetas)
}
end

/********************************************************************************                          approx
 * approx()
 *
 ********************************************************************************/

mata:
transmorphic matrix approx(transmorphic matrix a, real scalar sfrac)
{
  real matrix coord
  real scalar i, n, i1, c

  n = rows(a)

/*
printf("A=")
a
sfrac
*/

  for (i=1;i<=n;i++) {
    if (i>1) {
      if ( (sfrac < a[i,1]) & (sfrac > a[i-1,1] )) {
        coord = i -1 + (sfrac-a[i-1,1])/(a[i,1] - a[i-1,1])
      }
    }
  }
  return(coord)
}
end


/********************************************************************************                        matchrows
 *       matchrows(transmorphic matrix x)
 *       return sorted, unique list. 
 ********************************************************************************/

version 9.2
mata:
transmorphic matrix matchrows(transmorphic matrix a, transmorphic matrix b)
{
  real scalar             i, j, n, ns , m
  transmorphic matrix     sortx, res, index

  n = rows(b)
  m = rows(a)
  for (i=1;i<=n;i++) { 
    for(j=1;j<=m;j++) {
       if ( a[j,]==b[i,] ) {
         if ( rank(index)==0) index = j
         else index = index ,j
       }
    }
  }
  return(index)

}
end


/*****************************************************************************************                            mylars
 *
 * The main function my lars
 *
 *****************************************************************************************/

version 9.2
mata:
void mylars(string scalar yvarlist, string scalar xvarlist, string scalar touse, real scalar eps, string scalar altype)
{
  st_view(X=.,.,tokens(xvarlist), touse)
  st_view(y=.,.,tokens(yvarlist), touse)

/* trace is the usual debugging code */
  trace = 0

  m = cols(X)
  n = rows(X)
  nm = J(2,1,.)
  nm[1] = n
  nm[2] = m

  inactiverange = (1\m)
  inactive = (1::m)
  im = inactive
  one = J(1,n,1)

/* vn contains a vector of variable names */

/* Bit of code to scale/center the X  variable 
   And to center the y variable
*/
  meanx = one*X :/n
  X = X :- meanx
  
  normx = sqrt(one*(X :* X)) 
  st_matrix("error",0)
  for (i=1;i<=cols(normx);i++) {
    if (normx[i]==0) {
      printf("{error}ERROR: Zero in normalised matrix X due to variable %s \n", tokens(xvarlist)[1,i])
      st_matrix("error",1)
      return
    }
  }
  X = X :/ normx
  mu = one*y :/n
  y = y :- mu
  ignores = NULL
  Cvec = y'X
  
  useGram = 1 /* This I think is to do with huge matrices */

  if(useGram) {
    if (m>500 & n<m) printf("Might want to set useGram to false.. probably takes ages?\n")
    Gram = X'X
  }
  
/*  correlations between y and x */

  ssy = y'y
  residuals = y
  if (m>n-1) maxsteps = 8*(n-1)
  else maxsteps = 8*m
  beta = J(maxsteps+1,m,0)


  Gamrat = NULL
  arclength = NULL
  R2 = 1
  RSS = ssy
  firstin = J(1,m,0)
  active = NULL
  actions = (1::maxsteps)
/*
  drops = "FALSE"
*/
  Sign = NULL
  R = NULL



/*There is more initialisation .. */
 
/* Now the main loop over moves */

  k=0
  carryon=1
  while((k<maxsteps) & carryon) {
/*
    printf("\nStep %f",k)
*/
    k=k+1
    action = NULL

/* This isn't quite correct because inactive needs to change later and probably 0/1 is better 

C takes the same dimensions as inactive
Cvec can be row or column vectors but C is usually a row vector

My inactive can be a column vector...

*/

/*************************************************************************************MAIN TRACE */
    if (trace) {
      printf("{dup 60:{c -}}\n")
      printf("PRE    C= \n")
      C
      printf("    Cvec= \n")
      Cvec
      printf("    inactive= \n")
      inactive
      printf("   mynew=\n")
      mynew
    }
/*trace=1*/

/*PErhaps it is best to transform Cvec to a row vector now.. Splus is weird about row/column vector exchange */
    if (rows(Cvec) < cols(Cvec)) {
      C =Cvec[inactive]
    }
    else {
      if (rows(inactive) < cols(inactive)) {
         C = Cvec[inactive]
      }
      else {
       C = Cvec'[inactive']
      }
    }

    Cmax = max(abs(C))  /* Need to check what happens when this is the NULL value */

/* There is an extra bit of code about drops here */


    if(!any(drops)) {

      mynew = abs(C) :>= (Cmax-eps)

/*trace=1*/
      if (trace) {
        printf("{dup 60:{c -}}\n")
        printf("PRE    C= \n")
        C
        printf("    Cvec= \n")
        Cvec
        printf("    inactive= \n")
        inactive
        printf("   mynew=\n")
        mynew
      }

      C = C :* !mynew                  /* Not sure if this is correct.... */
      Cz = select(C,C)                 /* could be Ctemp without the zeroes is better */
      C = select(C,C)                 /*  found the place where the 0's were excluded so line above not needed */

/*trace = 1*/
     if (trace) {
       printf("{dup 60:{c -}}\n")
       printf("0.    C= \n")
       C
       printf("   inactive=\n")
       inactive
       printf(" mynew=\n")
       mynew
    }

   /* Need to check that inactive and mynew have different dimensions */

      if (rows(inactive)==rows(mynew)) mynew= inactive :* mynew
      else mynew = inactive' :* mynew         /* Again not sure might actually drop 0's */
      mynewz = select(mynew, mynew)

   /* we keep the choleski R of X[,active] (in the order they enter) */

      for (i=1; i<=rows(mynewz); i++) {
        inew = mynewz[i,1]

        if (trace) {
          printf("{dup 70:{c -}} STEP %f\n", k)
          printf("1.    R= ")
          R
          printf("   Gram= ")
          Gram
          printf(" Action= ")
          action
          printf(" Active= \n")
          active
          printf("   inew= ")
          inew
          printf(" mynewz= ")
          mynewz
        }


        if (useGram) {
          if (active==NULL) R=updateR(Gram[inew,inew], R, Gram[inew,mynewz], useGram, eps, 0)
          else {
            R=updateR(Gram[inew,inew], R, Gram[inew, active], useGram, eps, 0)
          }
        }


        if (trace) {
          printf("{dup 70:{c -}} STEP %f\n", k)
          printf("2.     R= ")
          R
          printf("    Sign= ")
          Sign 
          printf("  active= ")
          active
          printf(" firstin= ")
          firstin
          printf("    inew= ")
          inew
          printf("    Cvec= ")
          Cvec
        }

        if (rank(R) == length(active) & active~=NULL) {
          printf("Warning: Need to write this bit of code\n")
          nR = (1..length(active))
          R = R[nR,nR]
          if (ignores==NULL) ignores = inew
          else ignores = ignores, inew
          if (action==NULL) action = -1*inew
          else action = action, -1*inew
          if (trace) printf("LARS step %f variable %f collinear, dropped for good\n", k, inew )
        }
        else { /* if this ever runs there are going to be conformability problems */
          if (trace) printf("Next few lines are problems?")
          if (firstin[inew]==0) firstin[inew]=k
          if (active==NULL) active = inew
          else active = active \ inew
          if (Sign==NULL) Sign=sign(Cvec[inew])
          else Sign = Sign \ sign(Cvec[inew])
          if (action==NULL) action = inew
          else action = action \ inew
          if (trace) printf("LARS Step k Variable inew added \n")
        }
      } /* end of for rows(mynewz) */
    }
    else {
      action = -1 :* dropid
    }


    if (trace) {
      printf("{dup 70:{c -}} STEP %f\n", k)
      printf("3. R= ")
      R
      printf("Sign= ")
      Sign 
    }

/* not sure this is working*/

/*trace=1*/

    tesign = Sign
    temp = backsolvet(R, Sign, ., 0)
    Gi1 = backsolve(R, temp, 0)
    Sign = tesign


    if (trace) {
      printf("{dup 70:{c -}} STEP %f\n", k)
      printf("4. Gi1=")
      Gi1
      printf(" Sign=")
      Sign
      printf("active=") 
      active
    }

/* Translate Splus code
### Now we have to do the forward.stagewise dance
### This is equivalent to NNLS
*/
    dropouts=NULL
    if(altype == "fstagewise") {

        directions = Gi1 :* Sign
/*
printf(" directions=")
directions
*/

        if(!all(directions :> 0)) {

          if (trace) {
            printf("{dup 70:{c -}} STEP %f\n", k)
            printf("4b.  positive=\n")
            positive
          }

/* This is a break from the Splus code because if you pass through something it CAN be altered in Stata.. */
          oldactive = active
          nnlsbeta = beta

          if(useGram) nnlslars(nnlsbeta, positive, active, Sign, R, directions, Gram[active, active], eps, trace, useGram)
          else nnlslars(nnlsbeta, positive, active, Sign, R, directions, x[, active], eps, trace, useGram)

          dropouts = oldactive[ allbutrows(rows(oldactive),positive,0) ]
          action = (action \ -1 :* dropouts )
          Sign = Sign[positive]
          Gi1 = nnlsbeta[positive] :* Sign

          if (ignores==NULL) temp = active
          else temp = active, ignores


          C = Cvec[ allbutrows(rows(Cvec), temp', 0) ]
          if (rows(C)>1 & cols(C)==1) C=C'

trace=0
if (trace) {
  printf("{dup 60:{c -}}\n")
  printf("4c.   positive=\n")
  positive
  printf("active=\n")
  active
  printf("  Sign=\n")
  Sign
  printf("dropouts=\n")
  dropouts
  printf("action=\n")
  action
  printf("Gi1=\n")
  Gi1
  printf("     R=\n")
  R  
  printf("    C=\n")
  C
}
/*trace=0*/

        }
    }

/*trace=0*/
if (trace) {
  printf("{dup 60:{c -}}\n")
  printf("5.   A=")
  A
  printf("   Sign=")
  Sign
  printf("    Gi1=")
  Gi1  
}

    A= 1/sqrt(sum(Gi1 :* Sign))

    w = A :* Gi1	/*note that w has the right signs */
    if(!useGram) u = x[, active] * w


/*trace=1*/
if (trace) {
  printf("{dup 60:{c -}}\n")
  printf("6.  A=")
  A
  printf("   w=")
  w
  printf("   Gi1=")
  Gi1
}
/*trace=0*/

/*
  Now we see how far we go along this direction before the
  next competitor arrives. There are several cases

  If the active set is all of x, go all the way
*/
    if (active==NULL) activelength = 0
    else activelength = length(active)
    if (ignores==NULL) ignoreslength = 0
    else ignoreslength = length(ignores)

trace=0
if (trace) {
  printf("{dup 70:{c -}} STEP %f\n", k)
  printf("7.  Cmax=")
  Cmax
  printf("  A=")
  A
  printf("active=")
  active
  printf("ignores=")
  ignores
  printf("ignoreslength=")
  ignoreslength
  printf("w=")
  w
  printf(" Gram=")
  Gram
}
trace=0

    minmat = n-1, m-ignoreslength

/* This if statement happens when the active rows can be the number of rows/cols in Gram */

    if(activelength >=  min(minmat) ) {
      gamhat = Cmax :/ A
    }
    else {
      if(useGram) {

        if (ignores==NULL) subscript = active'
        else subscript = active', ignores


        oldtrace=trace
        trace=0
/* In Splus it doesn't seem to matter whether w is a row or a column vector this still works */
        if (cols(w)==rows(Gram[active,  allbutrows(rows(Gram), subscript, trace) ])) {
          a = w * Gram[active,  allbutrows(rows(Gram), subscript, trace) ]  /* all but subscript */
        }
        else {
          a = w' * Gram[active,  allbutrows(rows(Gram), subscript, trace) ] 
        }
        trace=oldtrace


if (trace) {
  printf("{dup 60:{c -}}\n")
  printf("7b.  Gram=")
  Gram
  printf("        a=")
  a
}


     }
      else {
        if (ignores==NULL) subscript = active
        else subscript = active, ignores
        a = u * x[, allbutrows(rows(Gram), subscript, trace) ]
      }


if (trace) {
  printf("{dup 60:{c -}}\n")
  printf("8.  Cmax=")
  Cmax
  printf("  C=")
  C
  printf("A=")
  A
  printf("a=")
  a
}

      gam = (Cmax :- C) :/ (A :- a), (Cmax :+ C) :/ (A :+ a)

/*
  printf("a.   C=")
  C
*/


if (trace) {
  printf("9{dup 70:{c -}} STEP %f\n", k)
  printf(" Gram=")
  Gram
  printf(" active=")
  active
  printf("ignores=")
  ignores
  printf("   w=")
  w
  printf("Cmax=")
  Cmax
  printf("   A=")
  A
  printf("   a=")
  a
  printf("   C=")
  C
  printf(" gam=")
  gam
}
trace=0
	
/* Any dropouts will have gam=0, which are ignored here */

      minmat = select(gam, gam :> eps) , Cmax :/A 
      gamhat = min(minmat)	
    }

trace=0
if (trace) {
  printf("{dup 70:{c -}} STEP %f\n", k)
  printf("10.   all the data to minimse minmat\n")
  minmat
  printf("gamhat=")
  gamhat
  printf(" beta=")
/*  beta*/
}
trace=0


    if(altype == "lasso") {
      dropid = NULL
      b1 = beta[k, active]	/* beta starts at 0 */
/* In Splus if active is a column vector then b1 is a column vector */
      b1=b1'
      z1 =  - b1 :/ w
      if ( select(z1, z1 :> eps) == J(0,0,0) ) {
         minmat =  gamhat
      }
      else  {
        minmat = select(z1, z1 :> eps) \ gamhat 
      }

      zmin = min(minmat)
      if(zmin < gamhat) {
        gamhat = zmin
        drops = z1 :== zmin
      }
      else drops = 0
    }

trace=0
if (trace) {
  printf("\n\n11{dup 70:{c -}} STEP %f\n", k)
  printf(" b1=\n")
  b1
  printf("  z1=\n")
  z1
  printf("zmin=")
  zmin
  printf("drops=")
  drops
  printf("gamhat=")
  gamhat
  printf("w=")
  w
 /* printf("beta =")
  beta*/
}
trace=0

    beta[k + 1,  ] = beta[k,  ]
/* Splus is ok here because w is row or col vector .. GRR   adding a transpose on w*/
    beta[k + 1, active] = beta[k + 1, active] + gamhat :* w'



trace=0
if (trace) {
  printf("{dup 70:{c -}} STEP %f\n", k)
  printf("12. beta=\n")
  /*beta*/
  printf("Gram=")
  Gram
  printf("active=")
  active
  printf("Cvec=")
  Cvec
  printf("gamhat=")
  gamhat
  printf(" w=")
  w
}
trace=0

/* The following is correct BUT Cvec can change from a row vector to a column vector... HOW annoying */

    if(useGram) {
      if (rows(Cvec) < cols(Cvec)) Cvec = Cvec' :- (gamhat :* Gram[, active] * w)
      else Cvec = Cvec :- (gamhat :* Gram[, active] * w)

    }
    else {
      printf("Haven't corrected this code one above is ok.. tricky operations")
      residuals = residuals - gamhat * u
      Cvec = (residuals' * x)
    }

trace=0
if (trace) {
  printf("{dup 70:{c -}} STEP %f\n", k)
  printf("13.  Cmax=\n")
  Cmax
  printf("Cvec=\n")
  Cvec
  printf("A=")
  A
  printf("Gamrat=")
  Gamrat
  printf("gamhat=")
  gamhat
}
/*trace=0*/
    if (Gamrat==NULL) Gamrat = gamhat:/(Cmax:/A)
    else Gamrat = Gamrat, gamhat:/(Cmax:/A)
    if (arclength==NULL) arclength =  gamhat	
    else arclength = arclength, gamhat

/*trace=0*/
if (trace) {
  printf("Gamrat=")
  Gamrat
  printf("arclength=")
  arclength
}

/*
 *  Check if we have to drop any guys
 */

trace=0
if (trace) {
  printf("\n13b{dup 70:{c -}} STEP %f\n", k)
  printf("drops=")
  drops
  printf("dropid=")
  dropid
  printf("active=")
  active
}
trace=0 

    if(altype == "lasso" & any(drops :> 0) ) {
      dropid = ( 1::(rows(drops)) ) :* drops
      dropid = select(dropid, dropid)
      for(i=1;i<=rows(dropid);i++) {
        id = dropid[i,1]
        if (trace) {
          printf("\nLasso step %f\nR=\n" , id)
          R
        }
        R = downdateR(R, id, 0)
      }
      dropid = select(active,drops)	/* indices from 1:m */
      active = select(active,!drops)
      Sign = select(Sign,!drops)


    }

trace=0
if (trace) {
  printf("\n14{dup 70:{c -}} STEP %f\n", k)
/*  printf("vn=")
  vn
  printf("names=")
  names
*/
  printf("R=\n")
  R
  printf("action=")
  action
  printf("active=")
  active
  printf("actions=")
  actions
  printf("inactive=")
  inactive
  printf("ignores=")
  ignores
  printf("im=")
  im
  printf(" dropid=")
  dropid
  printf(" drops=")
  drops

}
trace=0

/*
printf("Warning do we really need the variable names?")
    if (vn~=NULL) names(action) = vn[abs(action)]
*/

/* This is a problem  actions is a list of old actions  .. but action could be any dimension !!!!!!!!!!!!!!!!!!!!!!
in Splus you have arrays of arrays
   actions[[ k]] = action

This isn't the solution but not sure if anyone wants actions!!!
*/
    actions = actions \ action


    if (ignores==NULL) index = active
    else index = active \ ignores

  
/* active is a column vector so need to make the row vector by index' 
 * NOTE - allbutrows can return a void matrix.. I think only counting the number of rows is valid
 */

    if (cols(allbutrows(rows(im), index',0)) ~=0) inactive =im[ allbutrows(rows(im), index', trace) ]
    else inactive = J(0,0,0)


trace=0
if (trace) {
  printf("\n15{dup 70:{c -}} STEP %f\n", k)
/*
  rows(im)
  index
allbutrows(rows(im), index, trace) 
printf("\n\nis this ok\n\n")
*/
  printf(" vn=")
  vn
  printf("names=")
  names
  printf("action=")
  action
  printf("active=")
  active
  printf("inactive=")
  inactive
  printf("ignores=")
  ignores
  printf("im=")
  im
}
trace=0

/* Need to add some checks on the whhile k statement */
  if (ignores~=NULL) minmat = n-1, m-length(ignores)
  else minmat = n-1, m
  carryon = length(active)< min(minmat)

if (trace) {
  printf("END.")
  printf("\n n-1")
  n-1
  printf("\n m-lengthignores")
  m-length(ignores)
  printf("\n maxsteps=")
  maxsteps
  printf("\n active lenght")
  length(active)
}

if (trace) {
  printf("\n\nENd of the k while loop\n\n")
  printf("\n{dup 70:{c -}}\n")
}

  } /* end of k while */



beta = beta[1::k+1,]

if(trace) {
    printf("\nComputing residuals, RSS etc .....\n")
}


residuals = y :- X*beta'

beta = beta :/ normx

RSS = colsum(residuals :* residuals)

ONE = J(1, cols(RSS),1)
R2 = ONE - RSS :/ RSS[1,1]
sequence = 1..cols(RSS)
cp = ((n-k-1):* RSS ) :/ RSS[1,cols(RSS)] :- n + ( 2 :* sequence)

sbeta = beta :* normx
rowbeta = rowsum(beta)

/* Calculate the actions using the beta matrix */

ade = beta :~= 0
tade = ade
for( i=1; i <= cols(ade);i++) {
  for( j =2; j <= rows(ade);j++) {
    if ((tade[j,i]~= tade[j-1,i]) & tade[j,i]==1) ade[j,i]=i
    else if ((tade[j,i]~= tade[j-1,i]) & tade[j,i]==0) ade[j,i]=-i
    else ade[j,i]=0
  }
}


st_matrix("r(cp)", cp)
st_matrix("r(beta)", beta)
st_matrix("r(sbeta)", sbeta)
st_matrix("r(rss)", rss)
st_matrix("r(r2)", r2)
st_matrix("r(normx)", normx)
st_matrix("r(meanx)", meanx)
st_matrix("r(mu)", mu)
st_matrix("r(R2)",R2)
st_matrix("r(RSS)",RSS)
st_matrix("r(ade)",ade)

}


end


/*****************************************************************************************                              nnlslars
 *
 * The nnls.lars subroutine
 *
 *****************************************************************************************/

version 9.2
mata:
matrix nnlslars(nnlsbeta, positive, active, Sign, R, beta, Gram, eps, trace, real scalar useGram)
{

trace=0

if (!useGram) x = Gram
m = length(active)
M = m

im = (1..m)
positive = im
zero=NULL



while(m>1) {
/*
printf("zero=\n")
zero
zeroold
m
*/

    if (zero==NULL) zeroold = m
    else zeroold = m,zero
/*
printf("R=\n")
R
*/
   Rold = downdateR(R, m, trace)
    beta0 = backsolve(Rold,  backsolvet(Rold, Sign[ allbutrows(rows(Sign), zeroold, trace) ] , ., trace), trace ) :* Sign[allbutrows(rows(Sign),zeroold, trace)]

/*
printf("AH %f", m)
*/
    betaold = beta0 \ J(1,length(zeroold),0)
    if(all(beta0 :>0)) break
    m = m-1
    zero = zeroold
    positive = im[allbutrows(rows(im), zero, trace)]
    R = Rold
    beta = betaold
}

/*
printf("R=\n")
R
printf("CAH %f", m)
*/

  while(1) {
    while(!all(beta[positive] :> 0)) {
/*
printf("GOT here\n")
*/
      alpha0 = betaold :/ (betaold :- beta)


/*
  I have NO IDEA what the following does.... I am hoping looking for the minimum value in the negative betas...
     alpha = min(alpha0[positive][(beta <= 0)[positive]])
*/
      tebeta = beta[positive]
      temp=alpha0[positive] :* (tebeta :<= 0)
      alpha = min( select(temp,temp :~=0) )

      betaold = betaold :+ alpha :* (beta :- betaold)
      dropouts = match(alpha, alpha0[positive], 0) 
/*
dropouts
cols(dropouts)
dropouts[1,1]
printf("ADe 1")
*/
      for( i=1; i <= cols(dropouts);i++) {
         idropout = dropouts[1,i]
         R = downdateR(R, idropout, trace)
      }
/*
printf("STEP 2-----------------------------\n droputs positive \n")
dropouts
positive
*/
      positive = positive[ allbutrows(cols(positive), dropouts, trace) ]	
/*
printf("STEP3 --------------------------- \ndropouts positive=\n")
dropouts 
positive
*/

      zero = im[ allbut( im, positive, trace) ]
/*
Sign
positive
R
Sign[positive]
printf("nope")
*/
      beta0 = backsolve(R, backsolvet(R, Sign[positive], ., trace), trace) :*  Sign[positive]

      beta = betaold :* 0
/*
printf("asdgas")
beta
positive
*/
    beta = assignif(beta, beta0, positive, 0)

/*
printf("beta=\n")
beta

m
beta[positive]
!all(beta[positive] :> 0)
printf("not here\n")
*/
    }

/*
### Now all those in have a positive coefficient
*/


    if (useGram)  {
/*
printf("drop() deleted  here on the Gram part\n")
*/
      w = 1 :- Sign :* (Gram * (Sign :* beta))	
    }
    else {
      jw = x * (Sign :* beta)
      w = 1 :- Sign :* (jw' * x)
    }
/*
printf("w=\n")
w
*/
    if((length(zero) == 0) || all(w[zero] <= 0))      break

printf("{error} THIS NEEDS to be coded yet.. email me!!!!!!!")

/*    add <- order(w)[M]
    if(use.Gram) {
      R <- updateR(Gram[add, add], R, drop(Gram[add, 
                                                positive]), Gram = TRUE,eps=eps)
    }
    else {
      R <- updateR(x[, add], R, x[, positive], Gram = FALSE,eps=eps)
    }
    positive <- c(positive, add)
    zero <- setdiff(zero, add)
    beta0 <- backsolve(R, backsolvet(R, Sign[positive])) * Sign[
                                                        positive]
    beta[positive] <- beta0
*/

  }

/*
printf("positive beta R active\n")
positive
beta
R
active
*/

nnlsbeta = beta
active = active[positive]

/*printf("\n\n END of nnlslars\n\n")
*/

}
end

/***************************************************************          delcol
 * The mysterious  delcol
 ******************************************************************************/
/* NEED to extend this to include R not null */
version 9.2
mata:
matrix delcol(matrix r, real scalar p, real scalar k, matrix z, real scalar n, real scalar nz, real scalar trace)
{

if (trace) printf("\n delcol: Starting....")

p1 = p-1
i = k


while((i<p)) {
  a= r[i,i]
  b=r[i+1,i]
  if (!(b==0)) {
    if (!(abs(b) > abs(a))) {
      tau = -b/a
      c= 1/sqrt(1+tau^2)
      s = c* tau
    }
    else {
      tau = -a/b
      s = 1/sqrt(1+tau*tau)
      c = s*tau
    }
    r[i,i] = c*a - s*b
    r[i+1,i] = s*a+c*b
    j=i+1
    while((j<= p1)) {
      a=r[i,j]
      b = r[i+1,j]
      r[i,j] = c*a-s*b
      r[i+1,j] = s*a+c*b
      j=j+1
    }
    j=1
    while(j<=nz) {
      a = z[i,j]
      b = z[i+1,j]
      z[i,j]   = c*a-s*b
      z[i+1,j] = s*a+c*b
      j=j+1
    }
    i=i+1
  }
}

if (trace) printf("\n delcol: Just about to return....")

}
end

 
/*****************************************************************************************                        downdateR
 *
 * DOWNDATE R
 *
 *****************************************************************************************/


/* NEED to extend this to include R not null */

version 9.2
mata:
matrix downdateR(matrix rr, real scalar k, real scalar trace)
{

if (trace) printf("downdateR: Starting....")

p = rows(rr)
if (p==1) return(J(0,0,.))

terr = rr[, (allbut( (1..cols(rr)), k, 0) ) ]

delcol(terr, p, k, J(p,1,1), p, 1, trace)  /*last argument is the trace */

/* USED to be   <------------------------- everything after this point rr changed to terr2
rr= terr[allbut((1::rows(terr)),p, 0),]
 BUT this actually changed the matrix being entered....!!!
*/

terr2 = terr[allbut((1::rows(terr)),p, 0),]

if (trace) {
  printf("Returning terr2=\n")
  terr2
  printf("downdateR: Ending....")
}
/* USED to be 
return(rr)
*/

return(terr2)

}
end


/*****************************************************************************************                            updateR
 *
 * updating R
 *
 *****************************************************************************************/
/* NEED to extend this to include R not null */

version 9.2
mata:
matrix updateR(matrix xnew, matrix rr, matrix xold, real scalar useGram, real scalar eps, real scalar trace)
{
useGram =1
if (trace) printf("Entering updateR\n")

if (useGram) xtx = xnew
else xtx = sum(xnew:^2)

normxnew = sqrt(xtx)

if (rr==NULL) {
  rr = J(1,1,normxnew)
  return(rr)
}

if (useGram) xtx = xold
else xtx = xnew'*xold

if (trace) {
  printf("\n updateR: about to enter backsolvet\n rr=")
  rr
  printf("xtx=")
  xtx

  printf("normxnew =")
  normxnew
}

r = backsolvet(rr, xtx', rows(rr), 0)

if (trace) {
  printf("\n updateR:\n")
  r
  r:^2
  sum(r:^2)
  printf("normxnew =")
  normxnew
}


rpp = normxnew^2 :- sum(r:^2)
if (rpp<=eps) rpp = eps
else rpp = sqrt(rpp)


if (trace) {
  printf("\nupdateR:\nrpp=")
  rpp
  printf("normxnew =")
  normxnew
  printf("  r=")
  r
  printf("  rr=")
  rr
}

zerorow=J(1,cols(rr),0)
rr = (rr \ zerorow) , (r \ rpp)

if (trace) printf("Ending updateR")
return(rr)


}
end


/*******************************************************************************            backsolve
 *  Backsolve 
 *******************************************************************************/

version 9.2
mata: 
matrix backsolve(matrix A, matrix B, real scalar trace)
{

solution = lusolve(A,B)

if (trace) {
  printf("Backsolve. A=\n")
  A
  printf("           B=")
  B
  printf("Solution")
  solution
}

return(solution)

}
end

/*******************************************************************************             backsolvet
 *  Backsolve Transpose
 *******************************************************************************/

version 9.2
mata: 
matrix backsolvet(matrix r, matrix x, real scalar k, real scalar trace)
{

if (missing(k)) k=rows(r)

/*
	r <- t(r)[k:1, k:1, drop = F]
	x <- as.matrix(x)[k:1,  , drop = F]

NEED TO REVERSE COLUMNS and ROWS not just transpose

*/

te=r

r = r'
r=r[rows(r)..1,rows(r)::1]
/*
x=x'
*/

x=x[rows(x)..1]


if (trace) {
  printf("Backsolvet. r=\n")
  r
  printf("            x=") 
  x
  printf("            k=")
  k
}

x= backsolve(r, x, trace)
x = x[rows(x)..1]

r=te

if (trace) {
  printf("backsolvet solution x=")
  x
}

return(x)

}
end

/********************************************************             allbutrows
 * taking the number of rows
 * then an array of rows not wanted
 *
 * an array of wanted indexes is then produced
 *************************************************************************/
version 9.2
mata:
matrix allbutrows(real scalar nrows, matrix butthese, trace)
{
 if (trace) {
   printf("Entering allbutrows routine\n")
   butthese
 }
 allrows = (1..nrows)

 for(i=1; i<=cols(butthese);i++) {
   if (trace) {
     printf("selecting")
     butthese[1,i]
   }
   allrows = select( allrows, allrows :- butthese[1,i])
   if (i==1) count =  butthese[1,i]
   else count = count , butthese[1,i]
   if (trace) count
 }
 if (trace) printf("Ending the allbutrows routine\n")
 return(allrows)
}
end

/***************************************************                  allbutcols
 *
 ***************************************************/
version 9.2
mata:
matrix allbutcols(real scalar ncols, matrix butthese, trace)
{
if (trace) printf("Entering allbutcols routine\n")

allcols = (1..ncols)

for(i=1; i<=cols(butthese);i++) {
  if (trace) {
    printf("selecting")
    butthese[1,i]
  }
  allrows = select( allrows, allrows :- butthese[1,i])
  if (i==1) count =  butthese[1,i]
  else count = count , butthese[1,i]
  if (trace) count
}

if (trace) printf("Ending the allbutrows routine\n")

return(allrows)

}
end

/***************************************************                          allbut
 *
 * NEW all but
 *
 ***************************************************/

version 9.2
mata:
matrix allbut(matrix full, matrix remove, trace)
{
if (trace) printf("\nallbut: Entering....")


if (rows(full)==1) {
  for(i=1; i<=cols(full); i++) {
    for(j=1; j<=cols(remove);j++) {
      if (full[1,i]==remove[1,j]) full [1,i]=0
    }
  }
}

if (cols(full)==1) {
  for(i=1; i<=rows(full); i++) {
    for(j=1; j<=rows(remove);j++) {
      if (full[i,1]==remove[j,1]) full [i,1]=0
    }
  }
}


 if (rows(full)>1 & cols(full)>1) {
   printf("\n\ncan't handle a full matrix in allbut\n")
 } 
 if (trace) printf("\nallbut: Just about to return....")

 return( select(full,full) )

}
end

/***************************************************                       match
 * Match return the matrix of values that a is in b
 ***************************************************/
version 9.2
mata:
matrix match(real scalar a, matrix b, real scalar trace)
{
 if (trace) {
   printf("Entering match() routine")
   a
   b
 } 
 retmat = NULL
 for (i=1; i<=rows(b); i++) {
    if (a==b[i,1]) {
       if (retmat==NULL) retmat = i
       else retmat = retmat,i
    }
 }
 if (retmat==NULL) return(0)
 else return(retmat)

}
end


/***************************************************                    Assignif
 * a=b  "in" c
 ***************************************************/
version 9.2
mata:
matrix assignif(colvector a, colvector b, rowvector c, real scalar trace)
{
 if (trace) {
   printf("Entering assignif() routine")
   a 
   b
   c
 }

 for (i=1;i<=cols(c);i++) {
   ind = c[1,i]
   a[ind,1]=b[i,1]
 }
 return(a)
}
end


