version 16.0
mata:

real scalar _bcsf_ridders(pointer (real scalar function) scalar objfun,
  real scalar x0, real scalar x1, real scalar y0, real scalar y1,
  real scalar itcount, real scalar iterate, real scalar tolerance,
  | real scalar log)
{
/*
  Bracket convergence for step functions,
  using the Ridders method.
  The returned result is a return code,
    equal to zero if the brackets converged without error
    and to one if maximum number of iterations is reached without convergence.
  objfun() is a pointer to the object function.
  x0 is the zero bracket for the object function,
    at which the object function may be zero,
    or may be of the opposite sign to the object function at the non-zero bracket.
  x1 is the non-zero bracket for the object function,
    at which the object function may not be zero.
  y0 stores the value of the object function at x0.
  y1 stores the value of the object function at x1.
  itcount is the iteration count,
    increased on exit by the number of iterations.
  iterate is the maximum number of iterations.
  tolerance is the tolerance level for the relative difference.
  log is an indicator that the iterations must be logged,
    recording the brackets and the object functions at the brackets.  
*! Author: Roger Newson.
*! Date: 19 May 2006.
*/
real scalar ymid, xmid, sign1, maxit, h1
/*
  xmid stores the midpoint value between x0 and x1.
  ymid stores the value of the object function at xmid.
  sign1 stores the sign of y1.
  maxit stores the maximum iteration count.
  h1 stores y1*exp(lambda*(x1-x0)) for the Ridders method.
*/

/*
  Initialize log to zero if absent
*/
if (args()<9) log=0

/*
  Check for missing x- and y-brackets and iteration number
*/
if (missing(x0) | missing(x1)) return(2)
if (missing(y0) | missing(y1)) return(3)
if (missing(iterate)) return(4)

/*
  Initialize sign1 and check that zero is bracketed
*/
sign1=sign(y1)
if(sign1==0 | sign1*y0>0) return(5)


/*
  Bracket convergence
*/
if (missing(itcount)) itcount=0
if(reldif(x0,x1)<=tolerance){
  return(0)
}
maxit=itcount+iterate
while(itcount<maxit){
  itcount++
  xmid = 0.5*x0 + 0.5*x1
  if (missing(xmid)) return(2)
  ymid=(*objfun)(xmid)
  if (missing(ymid)) return(3)
  if(y0){
    /* Use Ridders' method */
    h1 = ( ymid :+ sign1 :* sqrt(ymid:*ymid - y0:*y1) ) :/ y1
    h1 = h1 :* h1 :* y1
    xmid = (h1:*x0 :- y0:*x1) :/ (h1 :- y0)
    if(missing(xmid)) return(2)
    ymid=(*objfun)(xmid)
    if(missing(ymid)) return(3)
  }
  if(sign(ymid)==sign1){
    y1=ymid
    x1=xmid
  }
  else{
    y0=ymid
    x0=xmid
  }
  if (log) printf("{txt}Iteration %8.0g:{res} x0 = %8.0g; x1 = %8.0g; y0 = %8.0g; y1 = %8.0g\n",itcount,x0,x1,y0,y1)
  if (reldif(x0,x1)<=tolerance) return(0)
}

/*
  Return with code 1 if convergence not achieved
*/
return(1)

}

end
