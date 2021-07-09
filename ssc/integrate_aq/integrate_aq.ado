*! Date    : 10 Jul 2018
*! Version : 1.02
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! A numerical integration command to do adaptive quadrature for  integrals

/*
v1.00 11Nov14 The command is born
v1.01 10Feb15 Removed the indefinite integrals
V1.02 10Jul18 Added indefinite integrals but via Gaussian Quadrature
*/
/*

START HELP FILE

title[ Adaptive Gaussian quadrature for a one dimensional integrand]

desc[
{cmd:integrate_aq} is an implementation of Gaussian adaptive quadrature, indefinite integrals
are handled by using transformations onto a definite integral. Infinity limits are
represented by a full stop . The adaptive quadrature splits any single integral, into 
two integrals, at the mid point. If the two integrals is not close to the overall integral
then the sub integrals are split further. By doing the sub-integrals there is some
measurement of the error in the integral. Occasionally some integrands can require many sub-integrals
and this can take a long time to get an answer and will likely result in a large error.

This command has been primarily written in the MATA language but is a Stata command. The function can be
 any single line
expression and the integration is with respect to x. The text from the option function()
will be used to create a new function in Mata which is then passed to the integration algorithm.

The number of quadrature points can be chosen to be any number above 1 but the larger this number the slower the algorithm.
There is no upper limit because the quadrature points are chosen by calculating the eigenvalues and eigenvectors
of a companion matrix.
]

opt[function() specifies the function to be integrated, this must be a function of x.]
opt[lower() specifies the lower limit of the integral.]
opt[upper() specifies the upper limit of the integral.]
opt[quadpts() specifies the number of quadrature points.]
opt[vectorise() specifies the function needs to be vectorised.]


example[

The distribution functions in Mata already accept vectors as arguments so can be used in the function 
directly. The following examples are all standard results that can be obtained using the cumulative distribution functions.

{stata integrate_aq, f(normalden(x)) l(-1) u(1)}

{stata integrate_aq, f(normalden(x)) l(-1.96) u(1.96)}

{stata integrate_aq, f(normalden(x)) l(-1.96) u(.)}

{stata integrate_aq, f(normalden(x)) l(.) u(.)}

An example of a user-defined function would be the polynomial x+x^2+x^3
note that because this function is not defined by the appropriate vector operations
then the option vectorise needs to be used.{p_end}

{stata integrate_aq, f(x+x^2+x^3) v l(-10) u(10)}

A quicker implementation of the same function would be

{stata integrate, f(x+x^2+x^3) l(-10) u(10) v :integrate, f(x:+x:^2+x:^3) l(-10) u(10) } 

]

return[integral The value of the integral]
return[error The size of the error associated with the integral ]


author[Dr Adrian Mander]
institute[MRC Biostatistics Unit, University of Cambridge]
email[adrian.mander@mrc-bsu.cam.ac.uk]

seealso[
{help integrate} (if installed), install by 
clicking {stata ssc install integrate}
]

END HELP FILE
*/


*! integrate_aq, f(x:+x:^2+x:^3)
*! integrate_aq, f(x+x^2+x^3) v
*! integrate_aq, f(x+x^2+x^3)
*! integrate_aq, f(x+x^2+x^3)
*! integrate_aq, f(x:^2)
*! integrate_aq, f( normalden(x) ) lower(.) upper(.)
*! integrate_aq, f( normalden(x) ) lower(.) upper(1.96)
*! integrate_aq, f( normalden(x) ) lower(-1.96) upper(.)

pr integrate_aq,rclass
 version 15.0
 syntax [, Lower(real -1) Upper(real 1) Function(string) Quadpts(int 80) Vectorise]

 /* Drop old code in mata */
  di "{txt}Note: removing the functions myfunction() and tefunction() from Mata"
  cap mata: mata drop myfunction()
  cap mata: mata drop tefunction()

/* The default function */
 if "`function'"=="" {
   local function "x:^2"
   di "{err}WARNING: the integrand was not specified in function() option so will be x^2"
   di
 }
 if `quadpts' <2 {
   di "{err}ERROR: quadrature points need to be 2 or more"
   exit(198)
 }

/* Write a MATA function */
 tempname fh
 tempfile tefile
 file open `fh' using "`tefile'.do", write replace
 file write `fh' "mata" _n
 if "`vectorise'"=="" {
   file write `fh' "rowvector myfunction(rowvector x)" _n
   file write `fh' "{" _n
   file write `fh' "return(`function')" _n
   file write `fh' "}" _n
 }
 else {
   file write `fh' "real tefunction(real x)" _n
   file write `fh' "{" _n
   file write `fh' "return(`function')" _n
   file write `fh' "}" _n _n
   file write `fh' "mata mosave tefunction(), dir(PERSONAL) replace" _n
   file write `fh' "rowvector myfunction(rowvector x)" _n
   file write `fh' "{" _n
   file write `fh' "  for (j=1; j<=cols(x); j++) {" _n
   file write `fh' "    if(j==1) vec = tefunction(x[j])" _n
   file write `fh' "    else vec = vec, tefunction(x[j])" _n
   file write `fh' "  }" _n
   file write `fh' "return(vec)" _n
   file write `fh' "}" _n
 }
 file write `fh' "mata mosave myfunction(), dir(PERSONAL) replace" _n
 file write `fh' "end" _n
 file close `fh'
 di
 di `"{pstd}{err}Note:{txt} The function to be integrated will be compiled using Mata and stored in your personal directory {res}`c(sysdir_personal)' {txt}(make sure this is writeable){p_end}"'
 di
 qui do "`tefile'.do"

/***************************************************************************************
 * The next part runs the mata code
 *  note that if you integrate a to b but a is bigger than b you get a negative answer!
 ***************************************************************************************/


 mata: integrate_quad(&myfunction(), `lower', `upper', `quadpts')

 return scalar integral= `r(integral)'
 return scalar error= `r(error)'

end

/****************************
 * Start of MATA
 ****************************/
mata:

/******************************************************************
 * ADAPTIVE QUADRATURE
 ******************************************************************/

void integrate_quad(pointer scalar integrand, real lower, real upper, real quadpts, | transmorphic xarg) 
{
 mainlower = lower
 mainupper = upper
 /* first of all get quadrature points and only do this once!*/
 rw = legendreRW(quadpts)
 /* then figure out which transformation is used */
 if (upper~=. & lower~=.) {
   type = "ab"
 }
 else if (upper~=. & lower==.) {
   type = "ib"
   lower = 0
   upper = 1
 }
 else if (upper==. & lower~=.) {
   type = "ai"
   lower = 0
   upper = 1
 }
 else if (upper==. & lower==.) {
   type = "ii"
   lower = -1
   upper = 1
 }
 else {
   printf("{err}ERROR: upper and lower bound issues\n")
 }

/* Because of a lack of recursion we have running totals of the integrals we can calculate
  One potential problem is if length of this stacking gets too long when bad integrand
*/
 llims=J(1,1000,0) /* stack for lower values */
 ulims=J(1,1000,0) /* stack for upper values */
 current_stack = 1 /* stack pointer */
 llims[current_stack]=lower
 ulims[current_stack]=upper


 total_error=0
 total = 0
 while (current_stack ~= 0) {
   temp = iq_pop(llims, ulims, current_stack)
   aa = temp[1]
   bb = temp[2]
   current_stack=temp[3]
   if (type=="ab") { /* definite integral evaluation*/
     if(args()<5) temp2 = test_recursion_stop_criterion_ab(rw, integrand, aa, bb, quadpts)
     else temp2 = test_recursion_stop_criterion_ab(rw, integrand, aa, bb, quadpts, xarg)
   }
   else if (type=="ai") { /* a to inf indefinite integral evaluation*/
     if(args()<5) temp2 = test_recursion_stop_criterion_ai(rw, mainlower, integrand, aa, bb, quadpts)
     else temp2 = test_recursion_stop_criterion_ai(rw, mainlower, integrand, aa, bb, quadpts, xarg)
   }
   if (type=="ib") {
     if(args()<5) temp2 = test_recursion_stop_criterion_ib(rw, mainupper, integrand, aa, bb, quadpts)
     else temp2 = test_recursion_stop_criterion_ib(rw, mainupper, integrand, aa, bb, quadpts, xarg)
   }
   if (type=="ii") {
     if(args()<5) temp2 = test_recursion_stop_criterion_ii(rw, integrand, aa, bb, quadpts)
     else temp2 = test_recursion_stop_criterion_ii(rw, integrand, aa, bb, quadpts, xarg)
   }
   stop =temp2[1] /* this contains the difference between whole integral and split in two halves*/
   value = temp2[2] /* This is the value of the integral by splitting into two halves*/

   if (stop < 0.001*value+0.00001) { /*just in case value is close to 0*/
     total = total + value
     total_error = total_error+stop
   } 
   else {
     m = (aa + bb)/2
     current_stack=current_stack + 1
     llims[current_stack]=m
     ulims[current_stack]=bb
     current_stack=current_stack + 1
     llims[current_stack]=aa
     ulims[current_stack]=m
   }
 }
 
 printf("{txt}Integral={res}%f\n",total)
 printf("{txt}Error={res}%f \n",total_error)
 st_numscalar("r(integral)",total)
 st_numscalar("r(error)", total_error)
}

/* this is to get the current limits from the stacked lower and upper*/
matrix iq_pop(lower, upper, current_stack)
{
  a = lower[current_stack]
  b = upper[current_stack]
  current_stack = current_stack - 1
  return(a, b, current_stack)
}


/*** This function evaluates the whole integral and the two halfs to see the difference for definite integral */
real test_recursion_stop_criterion_ab(matrix rw, pointer scalar integrand, lower, upper, quadpts, | transmorphic xarg) {
 if (args()<6) {
   m = (lower+upper)/2
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ) ))
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( Re( (m:-lower):/2:*rw[1,]:+(m:+lower):/2))) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)( Re( (upper:-m):/2:*rw[1,]:+(upper:+m):/2 ) ))
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
 else {
   m = (lower+upper)/2
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg ))
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( Re( (m:-lower):/2:*rw[1,]:+(m:+lower):/2),xarg)) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)( Re( (upper:-m):/2:*rw[1,]:+(upper:+m):/2 ),xarg ))
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
}

/*** This function evaluates the whole integral and the two halfs to see the difference for definite integral */
real test_recursion_stop_criterion_ai(matrix rw, mainlower, pointer scalar integrand, lower, upper, quadpts, | transmorphic xarg) {
   m = (lower+upper)/2
   t = Re((upper:-lower):/2:*rw[1,]:+(upper:+lower):/2)
   thi = Re((upper:-m):/2:*rw[1,]:+(upper:+m):/2)
   tlo = Re((m:-lower):/2:*rw[1,]:+(m:+lower):/2)
 if (args()<7) {
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( (mainlower :+ t:/(1:-t))):/ ((1:-t):^2)  )
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( (mainlower:+ tlo:/(1:-tlo)) ):/ ((1:-tlo):^2)) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)( (mainlower:+ thi:/(1:-thi)) ):/ ((1:-thi):^2))
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
 else {
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( (mainlower:+ t:/(1:-t)),xarg):/ ((1:-t):^2)  )
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( (mainlower:+ tlo:/(1:-tlo)) ,xarg):/ ((1:-tlo):^2)) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)( (mainlower:+ thi:/(1:-thi)),xarg):/ ((1:-thi):^2) )
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
}

/*** This function evaluates the whole integral and the two halfs to see the difference for definite integral */
real test_recursion_stop_criterion_ib(matrix rw, mainupper, pointer scalar integrand, lower, upper, quadpts, | transmorphic xarg) {
   m = (lower+upper)/2
   t = Re((upper:-lower):/2:*rw[1,]:+(upper:+lower):/2)
   thi = Re((upper:-m):/2:*rw[1,]:+(upper:+m):/2)
   tlo = Re((m:-lower):/2:*rw[1,]:+(m:+lower):/2)
 if (args()<7) {
   m = (lower+upper)/2
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( mainupper :- (1:-t):/t ):/ t:^2 )
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)(( mainupper :- (1:-tlo):/tlo ):/ tlo:^2 ) ) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)( ( mainupper :- (1:-thi):/thi ):/ thi:^2 ))
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
 else {
   m = (lower+upper)/2
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( mainupper :- (1:-t):/t , xarg):/ t:^2  )
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( mainupper :- (1:-t):/t , xarg):/ t:^2 ) + (upper-m)/2*quadrowsum(rw[2,]:*  (*integrand)( mainupper :- (1:-thi):/thi, xarg ):/ thi:^2 )
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
}

/*** This function evaluates the whole integral and the two halfs to see the difference for definite integral */
real test_recursion_stop_criterion_ii(matrix rw, pointer scalar integrand, lower, upper, quadpts, | transmorphic xarg) {
   m = (lower+upper)/2   
   t = Re((upper:-lower):/2:*rw[1,]:+(upper:+lower):/2)
   thi = Re((upper:-m):/2:*rw[1,]:+(upper:+m):/2)
   tlo = Re((m:-lower):/2:*rw[1,]:+(m:+lower):/2)
 if (args()<6) {
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( t:/(1:-t:^2) ) :* (1:+t:^2):/(1:-t:^2):^2 )
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( tlo:/(1:-tlo:^2) ):* (1:+tlo:^2):/(1:-tlo:^2):^2 ) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)( thi:/(1:-thi:^2)  ):* (1:+thi:^2):/(1:-thi:^2):^2  )
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
 else {
   Qwhole =  (upper-lower)/2*quadrowsum(rw[2,]:* (*integrand)( t:/(1:-t:^2), xarg ):* (1:+t:^2):/(1:-t:^2):^2)
   Qhalfs =(m-lower)/2*quadrowsum(rw[2,]:* (*integrand)( tlo:/(1:-tlo:^2),xarg):* (1:+tlo:^2):/(1:-tlo:^2):^2) + (upper-m)/2*quadrowsum(rw[2,]:* (*integrand)(  thi:/(1:-thi:^2),xarg ):* (1:+thi:^2):/(1:-thi:^2):^2 )
   error = abs(Qwhole-Qhalfs)
   return(error, Qhalfs)
 }
}

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

end /*end of MATA*/
